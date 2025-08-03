import 'package:flutter/material.dart';

class InfoPopup extends StatelessWidget {
  final String category;

  InfoPopup({required this.category});

  Widget imageBox(String assetPath) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(image: AssetImage(assetPath), fit: BoxFit.cover),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String title = category;
    Widget content = SizedBox();

    switch (category) {
      case "Plastic":
        title = "Plastic";
        content = SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image.asset('assets/images/examples/plastic_bottle.jpg', height: 120),
              SizedBox(height: 10),
              Text(
                "Plastics come in many forms and are often used for packaging and containers. Most recyclable plastics include bottles and hard containers. However, thin plastics like plastic bags and wrappers are usually non-recyclable and go into general waste. Check the recycling symbol on the item if available.",
              ),
              SizedBox(height: 8),
              Text(
                "Common subtypes:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("🧴 Bottle - e.g., water bottles, shampoo bottles"),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  imageBox('assets/images/examples/plastic_bottle.jpg'),
                  imageBox('assets/images/examples/banana.jpg'),
                  imageBox('assets/images/examples/battery.jpg'),
                  // เพิ่มรูปตามต้องการ
                ],
              ),
              Text(
                "🛍️ Bag - e.g., grocery bags, plastic wraps (usually not recyclable)",
              ),
              Text(
                "🍱 Foam - e.g., food containers, cups (often non-recyclable)",
              ),
              SizedBox(height: 8),
              Text(
                "✅ Choose “Plastic” if your item is mostly made of synthetic plastic material.",
              ),
            ],
          ),
        );
        break;

      case "Glass":
        title = "Glass";
        content = SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/images/examples/wine.jpg', height: 120),
              SizedBox(height: 10),
              Text(
                "Glass waste typically includes bottles, jars, and containers. Clean, unbroken glass can often be recycled. However, broken glass, mirrors, and certain colored glass may not be accepted in all recycling systems and should be handled with care.",
              ),
              SizedBox(height: 8),
              Text("Common subtypes:"),
              Text("🍾 Bottle - e.g., wine, soda"),
              Text("🫙 Jar - e.g., jam, sauce containers"),
              Text("🧩 Broken Glass - must be wrapped before disposal"),
              SizedBox(height: 8),
              Text(
                "✅ Choose “Glass” if your item is made of thick glass (not mirrors or ceramics).",
              ),
            ],
          ),
        );
        break;

      case "Metal":
        title = "Metal";
        content = SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/images/examples/soda.jpg', height: 120),
              SizedBox(height: 10),
              Text(
                "Metal waste includes aluminum cans, foil, and tins used for food or drinks. These are usually recyclable if cleaned properly. Rusted or greasy metal parts may need special handling. Always rinse cans before discarding.",
              ),
              SizedBox(height: 8),
              Text("Common subtypes:"),
              Text("🥫 Can - soda, canned food"),
              Text("🧻 Foil - clean aluminum foil, lids"),
              SizedBox(height: 8),
              Text("✅ Choose “Metal” if your item is made of aluminum or tin."),
            ],
          ),
        );
        break;

      case "Paper":
        title = "Paper";
        content = SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/images/examples/news.jpg', height: 120),
              SizedBox(height: 10),
              Text(
                "Paper products range from clean office paper to used tissues. While clean paper and cardboard are recyclable, greasy or contaminated paper such as tissue or food-stained containers usually belong in general waste or compost.",
              ),
              SizedBox(height: 8),
              Text("Common subtypes:"),
              Text("📰 Newspaper - reading material, flyers"),
              Text("📦 Cardboard - shipping boxes"),
              Text("🧻 Tissue - not recyclable if used"),
              Text("📃 Mixed Paper - notebooks, receipts"),
              SizedBox(height: 8),
              Text(
                "✅ Choose “Paper” if your item is mainly paper-based and clean.",
              ),
            ],
          ),
        );
        break;

      case "Food":
        title = "Food";
        content = SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/images/examples/banana.jpg', height: 120),
              SizedBox(height: 10),
              Text(
                "Food waste includes fruit and vegetable scraps, leftovers, and bones. These items are compostable and should not be mixed with recyclables. Proper sorting of food waste reduces landfill impact and supports composting systems.",
              ),
              SizedBox(height: 8),
              Text("Common subtypes:"),
              Text("🍌 Fruit/Vegetable - peels, cores"),
              Text("🍛 Leftovers - uneaten meals"),
              Text("🍗 Shells & Bones - from seafood or meat"),
              SizedBox(height: 8),
              Text("✅ Choose “Food” for organic waste or edible scraps."),
            ],
          ),
        );
        break;

      case "Textile":
        title = "Textile";
        content = SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/images/examples/cloth.jpg', height: 120),
              SizedBox(height: 10),
              Text(
                "Textile waste includes used clothes, old towels, and shoes. Many fabrics can be reused or donated, but damaged or heavily soiled ones are often treated as general waste. Special textile recycling services may be available in some areas.",
              ),
              SizedBox(height: 8),
              Text("Common subtypes:"),
              Text("👕 Clothing - worn clothes"),
              Text("🧺 Household Fabric - towels, bedsheets"),
              Text("🧵 Fabric Waste - sewing scraps"),
              Text("👟 Footwear - shoes and sandals"),
              SizedBox(height: 8),
              Text(
                "✅ Choose “Textile” for anything made from fabric or leather.",
              ),
            ],
          ),
        );
        break;

      case "Other":
        title = "Other";
        content = SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/images/examples/battery.jpg', height: 120),
              SizedBox(height: 10),
              Text(
                "This category covers hazardous or special waste, such as batteries, electronics, and chemicals. These should never be disposed of in regular bins and must be brought to designated collection centers to prevent environmental harm.",
              ),
              SizedBox(height: 8),
              Text("🔋 Battery - AA, AAA, lithium"),
              Text("💻 E-Waste - phones, gadgets"),
              Text("☣️ Hazardous - chemicals, fluorescent bulbs"),
              SizedBox(height: 8),
              Text(
                "✅ Choose “Other” if your item is dangerous, electronic, or needs special care.",
              ),
            ],
          ),
        );
        break;

      case "Symbol Guide":
        title = "Symbol Guide";
        content = SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/images/examples/recy1.png', height: 120),
              SizedBox(height: 10),
              Text(
                "Still not sure? Look for the recycling symbol on your item.",
              ),
              SizedBox(height: 8),
              Text("♻️ “1 PET” - water bottles → recyclable"),
              Text(""),
              SizedBox(height: 8),
              Text(
                "✅ Choose “Symbol Guide” if your item contains specific symbol or to learn what symbols mean.",
              ),
            ],
          ),
        );
        break;

      default:
        title = "Info";
        content = Text("Information is not available.");
    }

    return AlertDialog(
      title: Text(title),
      content: content,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Close"),
        ),
      ],
    );
  }
}
