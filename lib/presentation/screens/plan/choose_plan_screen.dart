import 'package:flutter/material.dart';
import 'choose_plan_screen.dart';

class ChoosePlanScreen extends StatefulWidget {
  const ChoosePlanScreen({super.key});

  @override
  State<ChoosePlanScreen> createState() => _ChoosePlanScreenState();
}

class _ChoosePlanScreenState extends State<ChoosePlanScreen> {
  int selectedPlan = 0;

  final List<Map<String, dynamic>> plans = [
    {
      "id": 1,
      "title": "PLAN A",
      "price": "199",
      "features": [
        "Free On-Boarding",
        "Access to information repository",
        "Chat Bot assistance",
        "Assistance on choosing the right collateral free loan"
      ]
    },
    {
      "id": 2,
      "title": "PLAN B",
      "price": "499",
      "features": [
        "Free On-Boarding",
        "Access to information repository",
        "Chat Bot assistance",
        "Assistance on choosing the right collateral free loan",
        "Issuance of financial report (part of loan documents)",
        "Access to our business advisors and consultants through Watsapp or text"
      ]
    },
    {
      "id": 3,
      "title": "PLAN C",
      "price": "699",
      "features": [
        "Free On-Boarding",
        "Access to information repository",
        "Chat Bot assistance",
        "Assistance on choosing the right collateral free loan",
        "Issuance of financial report (part of loan documents)",
        "Access to our business advisors and consultants through Watsapp or text",
        "Filing of Income Tax Returns",
        "Access to 24x7 ON-Call advisory services"
      ]
    },
    {
      "id": 4,
      "title": "PLAN D",
      "price": "1299",
      "features": [
        "Free On-Boarding",
        "Access to information repository",
        "Chat Bot assistance",
        "Assistance on choosing the right collateral free loan",
        "Issuance of financial report (part of loan documents)",
        "Access to our business advisors and consultants through Watsapp or text",
        "Filing of Income Tax Returns",
        "Access to 24x7 ON-Call advisory services",
        "Credit Report Enhancement Services",
        "Overall assistance in loan applications"
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/confirmPayment');
            },
            child: const Text(
              'Skip',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cardHeight = constraints.maxHeight * 0.45;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    "Choose Your Plan",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: constraints.maxWidth > 600 ? 4 : 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      mainAxisExtent: cardHeight,
                    ),
                    itemCount: plans.length,
                    itemBuilder: (context, index) {
                      final plan = plans[index];
                      return planCard(plan, cardHeight);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget planCard(Map<String, dynamic> plan, double cardHeight) {
    final isSelected = selectedPlan == plan['id'];

    return GestureDetector(
      onTap: () {
        setState(() => selectedPlan = plan['id']);
      },
      child: Container(
        height: cardHeight,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF002D72) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plan['title'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "${plan['price']} /year",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: plan['features']
                      .map<Widget>((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(Icons.check,
                              size: 16, color: Colors.green),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            feature,
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/confirmPayment',
                    arguments: plan,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002D72),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Select Plan",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}