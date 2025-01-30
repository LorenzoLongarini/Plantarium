import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:plantairium/common/utils/colors.dart';
import 'package:plantairium/features/account/ui/account_options/faq_data.dart';

class FAQ extends StatelessWidget {
  const FAQ({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = FAQData.faqs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQs'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              height: 220,
              child: Lottie.asset("assets/lottie/faq_green.json"),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: faqs.length,
              itemBuilder: (context, index) {
                final faqItem = faqs[index];
                return FAQCard(
                  question: faqItem['question'] ?? '',
                  answer: faqItem['answer'] ?? '',
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FAQCard extends StatelessWidget {
  final String question;
  final String answer;

  const FAQCard({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFDDE8D7), // Verde salvia chiaro
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ExpansionTile(
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: Colors.transparent),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: Colors.transparent),
        ),
        iconColor: Palette.iconsColor,
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Text(
              answer,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}