import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:http/http.dart' as http;

import 'package:flutter_stripe/flutter_stripe.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? paymentIntent;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stripe Payment'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              child: const Text('Make Payment'),
              onPressed: () async {
                await makePayment();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> makePayment() async {
    try {
      Map<String, dynamic> body = {'amount': '10000', 'currency': 'INR'};

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET']}',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );

      paymentIntent = json.decode(response.body);

      //STEP 2: Initialize Payment Sheet

      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntent![
                      'client_secret'], //Gotten from payment intent

                  style: ThemeMode.light,
                  merchantDisplayName: 'Test'))
          .then((value) {});

      //STEP 3: Display Payment sheet

      try {
        await Stripe.instance
            .presentPaymentSheet()
            .then((value) => print('payment successful'));
      } catch (error) {}
    } catch (err) {
      throw Exception(err);
    }
  }
}
