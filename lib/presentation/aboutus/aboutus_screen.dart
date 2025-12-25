import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About us'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'About Us - Loan Ready App',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Mission - EXACT SAME TEXT
            Text(
              'Our Mission',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Loan Ready ka mission hai har vyakti ko asaani se aur surakshit tarike se financial sahayata pahunchana. Hum loan application ko asaan aur transparent banate hain jisme jaldi approval mile.',
            ),
            SizedBox(height: 16),

            // What We Do - EXACT SAME TEXT
            Text(
              'What We Do',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Loan Ready app users ko financial schemes, loan options, aur instant registration ke zariye unke sapne poore karne mein madad karta hai. Hamari service easy registration process aur real-time support provide karti hai.',
            ),
            SizedBox(height: 16),

            // Our Values - EXACT SAME TEXT
            Text(
              'Our Values',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              '• Transparency: Har step par clear information aur updates.\n'
                  '• Trust: User data ki suraksha hamara prathamikta hai.\n'
                  '• Simplicity: Easy navigation aur samajhne mein asaani.',
            ),
            SizedBox(height: 16),

            // Why Choose - EXACT SAME TEXT
            Text(
              'Why Choose Loan Ready?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              '• Direct registration process through the app\n'
                  '• Latest loan schemes information available\n'
                  '• Reliable customer support through chatbot\n'
                  '• Safe and secure transactions',
            ),
            SizedBox(height: 16),

            // Contact - EXACT SAME TEXT
            Text(
              'Contact Us',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text('For any queries or support, contact us at:'),
            Text('Email: support@loameadyapp.com'),
            Text('Phone: +91 98765 43210'),
          ],
        ),
      ),
    );
  }
}