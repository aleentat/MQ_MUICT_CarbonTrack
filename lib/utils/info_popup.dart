import 'package:flutter/material.dart';

class InfoPopup extends StatelessWidget {
  final String category;

  InfoPopup({required this.category});

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
              Row(
                children: [
                  Expanded(
                    child: Image.asset(
                      'assets/images/examples/ex_bottle.webp',
                      height: 140,
                    ),
                  ),
                  SizedBox(width: 7),
                  Expanded(
                    child: Image.asset(
                      'assets/images/examples/ex_bag.png',
                      height: 130,
                    ),
                  ),
                  SizedBox(width: 7),
                  Expanded(
                    child: Image.asset(
                      'assets/images/examples/ex_foam.png',
                      height: 120,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                "Plastics come in many forms and are often used for packaging and containers. Most recyclable plastics include bottles and hard containers. However, thin plastics like plastic bags and wrappers are usually non-recyclable and go into general waste. Check the recycling symbol on the item if available.",
              ),
              SizedBox(height: 10),
              Text(
                "Common subtypes:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text("🧴 Bottle - e.g., water bottles, shampoo bottles"),
              Text(
                "🛍️ Bag - e.g., grocery bags, plastic wraps (usually not recyclable)",
              ),
              Text(
                "🍱 Foam - e.g., food containers, cups (often non-recyclable)",
              ),
              SizedBox(height: 10),
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
              Row(
                children: [
                  Expanded(
                    child: Image.asset(
                      'assets/images/examples/ex_glass.png',
                      height: 140,
                    ),
                  ),
                  SizedBox(width: 7),
                  Expanded(
                    child: Image.asset(
                      'assets/images/examples/ex_brokenglass.png',
                      height: 120,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                "Glass waste typically includes bottles, jars, and containers. Clean, unbroken glass can often be recycled. However, broken glass, mirrors, and certain colored glass may not be accepted in all recycling systems and should be handled with care.",
              ),
              SizedBox(height: 10),
              Text(
                "Common subtypes:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text("🍾 Bottle - e.g., wine, soda"),
              Text("🫙 Jar - e.g., jam, sauce containers"),
              Text("🧩 Broken Glass - must be wrapped before disposal"),
              SizedBox(height: 10),
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
              Row(
                children: [
                  Expanded(
                    child: Image.asset(
                      'assets/images/examples/ex_can.png',
                      height: 110,
                    ),
                  ),
                  SizedBox(width: 7),
                  Expanded(
                    child: Image.asset(
                      'assets/images/examples/ex_foil.png',
                      height: 150,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                "Metal waste includes aluminum cans, foil, and tins used for food or drinks. These are usually recyclable if cleaned properly. Rusted or greasy metal parts may need special handling. Always rinse cans before discarding.",
              ),
              SizedBox(height: 10),
              Text(
                "Common subtypes:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text("🥫 Can - soda, canned food"),
              Text("🧻 Foil - clean aluminum foil, lids"),
              SizedBox(height: 10),
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
              Row(
                children: [
                  Expanded(
                    child: Image.asset(
                      'assets/images/examples/ex_news.webp',
                      height: 120,
                    ),
                  ),
                  SizedBox(width: 7),
                  Expanded(
                    child: Image.asset(
                      'assets/images/examples/ex_board.png',
                      height: 120,
                    ),
                  ),
                  SizedBox(width: 7),
                  Expanded(
                    child: Image.asset(
                      'assets/images/examples/ex_tissue.webp',
                      height: 120,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                "Paper products range from clean office paper to used tissues. While clean paper and cardboard are recyclable, greasy or contaminated paper such as tissue or food-stained containers usually belong in general waste or compost.",
              ),
              SizedBox(height: 10),
              Text(
                "Common subtypes:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text("📰 Newspaper - reading material, flyers"),
              Text("📦 Cardboard - shipping boxes"),
              Text("🧻 Tissue - not recyclable if used"),
              Text("📃 Mixed Paper - notebooks, receipts"),
              SizedBox(height: 10),
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
              Row(
                children: [
                  Expanded(
                    child: Image.asset(
                      'assets/images/examples/ex_fruit.png',
                      height: 120,
                    ),
                  ),
                  SizedBox(width: 7),
                  Expanded(
                    child: Image.asset(
                      'assets/images/examples/ex_bone.png',
                      height: 120,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                "Food waste includes fruit and vegetable scraps, leftovers, and bones. These items are compostable and should not be mixed with recyclables. Proper sorting of food waste reduces landfill impact and supports composting systems.",
              ),
              SizedBox(height: 10),
              Text(
                "Common subtypes:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text("🍌 Fruit/Vegetable - peels, cores"),
              Text("🍛 Leftovers - uneaten meals"),
              Text("🍗 Shells & Bones - from seafood or meat"),
              SizedBox(height: 10),
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
              Row(
                children: [
                  Expanded(
                    child: Image.asset(
                      'assets/images/examples/ex_fabric.png',
                      height: 120,
                    ),
                  ),
                  SizedBox(width: 7),
                  Expanded(
                    child: Image.asset(
                      'assets/images/examples/ex_shirt.png',
                      height: 120,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                "Textile waste includes used clothes, old towels, and shoes. Many fabrics can be reused or donated, but damaged or heavily soiled ones are often treated as general waste. Special textile recycling services may be available in some areas.",
              ),
              SizedBox(height: 10),
              Text(
                "Common subtypes:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text("👕 Clothing - worn clothes"),
              Text("🧺 Household Fabric - towels, bedsheets"),
              Text("🧵 Fabric Waste - sewing scraps"),
              Text("👟 Footwear - shoes and sandals"),
              SizedBox(height: 10),
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
              Row(
                children: [
                  Expanded(
                    child: Image.asset(
                      'assets/images/examples/ex_battery.png',
                      height: 120,
                    ),
                  ),
                  SizedBox(width: 7),
                  Expanded(
                    child: Image.asset(
                      'assets/images/examples/ex_chem.webp',
                      height: 120,
                    ),
                  ),
                  SizedBox(width: 7),
                  Expanded(
                    child: Image.asset(
                      'assets/images/examples/ex_phone.webp',
                      height: 120,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                "This category covers hazardous or special waste, such as batteries, electronics, and chemicals. These should never be disposed of in regular bins and must be brought to designated collection centers to prevent environmental harm.",
              ),
              SizedBox(height: 10),
              Text("🔋 Battery - AA, AAA, lithium"),
              Text("💻 E-Waste - phones, gadgets"),
              Text("☣️ Hazardous - chemicals, fluorescent bulbs"),
              SizedBox(height: 10),
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
              Row(
                children: [
                  Expanded(
                    child: Image.asset(
                      'assets/images/examples/ex_symbol.png',
                      height: 135,
                    ),
                  ),
                  SizedBox(width: 7),
                  Expanded(
                    child: Image.asset(
                      'assets/images/examples/ex_hazard.webp',
                      height: 100,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text("Still not sure? Look for the symbol on your item."),
              SizedBox(height: 10),
              Text("♻️ “1 PET” - water bottles → recyclable"),
              Text("♻️ “2 HDPE” - milk bottles, detergent → recyclable"),
              Text("♻️ “3 PVC” - pipes, packaging → not commonly recyclable"),
              Text("♻️ “4 LDPE” - plastic bags → sometimes recyclable"),
              Text("♻️ “5 PP” - food containers → recyclable"),
              Text("♻️ “6 PS” - foam, takeaway boxes → rarely recyclable"),
              Text("♻️ “7 OTHER” - mixed plastics → check locally"),
              SizedBox(height: 8),
              Text("☢️ Radioactive - hazardous, special disposal required"),
              Text("☣️ Biohazard - medical/infectious waste"),
              Text("🔥 Flammable - keep away from heat/fire"),
              Text("☠️ Toxic/Poisonous - harmful to humans/environment"),
              SizedBox(height: 10),
              Text(
                "✅ Choose “Symbol Guide” if your item contains a symbol or to learn what it means.",
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
      backgroundColor: const Color.fromARGB(255, 247, 252, 251),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
      contentPadding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
      actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 201, 223, 219),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Color(0xFF19ac98)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF19ac98),
                ),
              ),
            ),
          ],
        ),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 420),
        child: content,
      ),
      actions: [
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF19ac98),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    );
  }
}
