import express from "express";
import mongoose from "mongoose";
import dotenv from "dotenv";
import cors from "cors";

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

// MongoDB connection
mongoose.connect(process.env.MONGODB_URI)
  .then(() => console.log("MongoDB connected"))
  .catch(err => console.error(err));

// Schema
const UsageSummarySchema = new mongoose.Schema({
  userId: String,
  date: String,
  totalLogs: Number,
  // store precise decimal values for CO₂
  totalDailyCO2: mongoose.Schema.Types.Decimal128,
  // allow storing an average value as well
  avgDailyCO2: mongoose.Schema.Types.Decimal128,
  ecoScore: Number,
}, { timestamps: true });

// Prevent duplicates
UsageSummarySchema.index({ userId: 1, date: 1 }, { unique: true });

const UsageSummary = mongoose.model("UsageSummary", UsageSummarySchema);

// API endpoint with casting and fallback
async function createUsageSummary(req, res) {
  try {
    console.log('Incoming summary:', req.body);

    const payload = { ...req.body };

    // If avgDailyCO2 present but totalDailyCO2 missing, compute total
    if ((payload.totalDailyCO2 === undefined || payload.totalDailyCO2 === null) && payload.avgDailyCO2 !== undefined && payload.totalLogs) {
      const total = Number(payload.avgDailyCO2) * Number(payload.totalLogs);
      payload.totalDailyCO2 = total;
      console.log('Computed totalDailyCO2 from avgDailyCO2 (raw):', payload.totalDailyCO2);
    }

    // Cast numeric/string values to Decimal128 where schema expects it
    try {
      if (payload.totalDailyCO2 !== undefined && payload.totalDailyCO2 !== null) {
        payload.totalDailyCO2 = mongoose.Types.Decimal128.fromString(String(payload.totalDailyCO2));
      }
      if (payload.avgDailyCO2 !== undefined && payload.avgDailyCO2 !== null) {
        payload.avgDailyCO2 = mongoose.Types.Decimal128.fromString(String(payload.avgDailyCO2));
      }
    } catch (castErr) {
      console.error('Failed to cast CO2 values to Decimal128:', castErr);
    }

    const saved = await UsageSummary.create(payload);
    console.log('Saved UsageSummary:', saved);

    res.status(201).send({ success: true });
  } catch (err) {
    // Duplicate → already synced
    if (err.code === 11000) {
      return res.status(200).send({ success: true });
    }
    console.error('Error creating UsageSummary:', err);
    res.status(400).send({ success: false });
  }
}

app.post("/usage-summary", createUsageSummary);
app.post("/api/usage-summary", createUsageSummary);

app.listen(process.env.PORT, () => {
  console.log("Server running");
});
