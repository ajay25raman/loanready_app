import 'package:flutter/material.dart';

class AlertsScreen extends StatefulWidget {
  final ScrollController scrollController;

  const AlertsScreen({
    super.key,
    required this.scrollController,
  });

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen>
    with AutomaticKeepAliveClientMixin {

  final List<Map<String, String>> alerts = [
    {
      'title': 'Loan Application Submitted',
      'message': 'Your loan application has been submitted successfully.'
    },
    {
      'title': 'Document Approved',
      'message': 'Your Aadhaar document has been approved.'
    },
    {
      'title': 'Profile Updated',
      'message': 'Your profile information was updated successfully.'
    },
    {
      'title': 'Loan Status Updated',
      'message': 'Your application is under review.'
    },
    {
      'title': 'Reminder',
      'message': 'Complete your pending KYC verification.'
    },
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Alerts',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        controller: widget.scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.amber.shade100,
                child: const Icon(
                  Icons.notifications,
                  color: Colors.orange,
                ),
              ),
              title: Text(
                alerts[index]['title']!,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(alerts[index]['message']!),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          );
        },
      ),
    );
  }
}