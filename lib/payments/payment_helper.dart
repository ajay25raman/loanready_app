import 'package:razorpay_flutter/razorpay_flutter.dart';

Razorpay razorpay = Razorpay();
class PaymentHelper {

  void pay(){

    var options = {
      'key': 'rzp_test_TSis4pWjeA97nb',
      'amount': 50000,
      'name': 'Flutter Course',
      'description': 'Payment',
      'prefill': {
        'contact': '9117719625',
        'email': 'ajay.kumar@gmail.com'
      }
    };

    razorpay.on(
      Razorpay.EVENT_PAYMENT_SUCCESS,
      (){
        print("Payment Success");
      },
    );
    razorpay.on(
      Razorpay.EVENT_PAYMENT_ERROR,
      (){
        print("Payment Error");
      },
    );
    razorpay.on(
      Razorpay.EVENT_EXTERNAL_WALLET,
      (){
        print("External Wallet");
      },
    );
    razorpay.open(options);

  }
}