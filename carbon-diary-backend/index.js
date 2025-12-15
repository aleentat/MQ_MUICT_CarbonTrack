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
  avgDailyCO2: Number,
  ecoScore: Number,
}, { timestamps: true });

// Prevent duplicates
UsageSummarySchema.index({ userId: 1, date: 1 }, { unique: true });

const UsageSummary = mongoose.model("UsageSummary", UsageSummarySchema);

// API endpoint
app.post("/usage-summary", async (req, res) => {
  try {
    await UsageSummary.create(req.body);
    res.status(201).send({ success: true });
  } catch (err) {
    // Duplicate → already synced
    if (err.code === 11000) {
      return res.status(200).send({ success: true });
    }
    res.status(400).send({ success: false });
  }
});

app.listen(process.env.PORT, () => {
  console.log("Server running");
});
