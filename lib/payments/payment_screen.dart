import 'package:flutter/material.dart';
import 'package:loanready_app/payments/payment_helper.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentHelper helper=PaymentHelper();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(onPressed: (){

          helper.pay();
        }, child: Text("Pay Now")),
      ),
    );
  }
}
