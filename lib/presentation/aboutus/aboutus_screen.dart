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
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Us - Loan Ready App',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Mission
            Text(
              'Our Mission',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              'Providing a holistic all round support to micro and small business enterprises for them to sustain and flourish in this dynamic and highly competitive market.',
            ),
            SizedBox(height: 16),

            // What We Do / How We Serve
            Text(
              'What We Do / How We Serve',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              '• Supporting small and micro entrepreneurs in their businesses through our advisory and consultancy services.\n'
                  '• Making low interest bearing and collateral free institutional finance available to such businesses.\n'
                  '• Building a better business resume through proper documentation and record.\n'
                  '• Helping businesses create a favorable credit profile.',
            ),
            SizedBox(height: 16),

            // Why Choose
            Text(
              'Why Choose Loan Ready',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              '• We pioneer in providing business consultancy and advisory services to micropreneurs.\n'
                  '• We solve the problem of securing finance, especially schemes which are collateral free and at lower rates of interest through our document building process.\n'
                  '• We offer end to end services to secure institutional finance.\n'
                  '• We build credit worthiness by addressing adverse issues in credit report of such businesses.',
            ),
          ],
        ),
      ),
    );
  }
}