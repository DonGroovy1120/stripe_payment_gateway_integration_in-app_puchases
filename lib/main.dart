import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'home_screen_behavior.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = 'pk_test_51LEGX7A0pvbOz3WZlJQdvGbiSHWPxp6HKHuXDiM4qmV38TNt3on7acIy3i3Yf8Pxfd5T9dxArEvCbMCKq6xUlsde00KCZytbv9';

  runApp(const MaterialApp(
    title: 'Stripe payment gateway integration',
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with HomeBehavior {

  void createPaymentIntent() async {
    setState((){
      isProcessing = true;
    });
    try {
      Response response = await dio.post('https://api.stripe.com/v1/payment_intents',
          data: {
            'amount': '5000',
            'currency': 'USD',
            'payment_method_types[]': 'card'
          },
          options: Options(
              headers: {
                //usama Stripe account secret is here after Bearer
                'Authorization': 'Bearer sk_test_51LEGX7A0pvbOz3WZnISs7VVFc67zdLVwbvBYT8K4ewhbUBoIzF2bpj4p9IomOyqBqfCemQmOgrIVmnCCskYgHiDl00isWi4hAi',
                'Content-Type': 'application/x-www-form-urlencoded'
              })
      );
      initThePaymentSheet(stripeApiResponse: response.data);
    } catch (err) {
      setState((){
        isProcessing = false;
      });
      debugPrint('error in createPaymentIntent in Dio post API charging user: ${err.toString()}');
    }
  }

  void initThePaymentSheet({required Map<String, dynamic> stripeApiResponse}) async {
    try {
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: stripeApiResponse['client_secret'],
              applePay: true,
              googlePay: true,
              testEnv: true,
              style: ThemeMode.system,
              merchantCountryCode: 'US',
              merchantDisplayName: 'Usama'));

      displayPaymentSheet(stripeApiResponse: stripeApiResponse);
    } catch (e, s) {
      setState((){
        isProcessing = false;
      });
      debugPrint('exception in initPaymentSheet method:$e$s');
    }
  }

  void displayPaymentSheet({required Map<String, dynamic> stripeApiResponse}) async {
    try {
      await Stripe.instance.presentPaymentSheet();
      setState((){
        isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("paid successfully")));
    } on StripeException catch (e) {
      setState((){
        isProcessing = false;
      });
      debugPrint(' on StripeException: Exception in displaying payment sheet  ${e.toString()}');
      setState((){
        isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.error.message.toString())));
    } catch (e) {
      setState((){
        isProcessing = false;
      });
      debugPrint('Exception in displaying payment sheet in general catch ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stripe Integration '),
      ),
      body: Center(
        child: isProcessing ?
        const CircularProgressIndicator()
            :
        OutlinedButton(
          onPressed: () async{
            createPaymentIntent();
          },
          child: const Text(
            'Pay with stripe 50\$ ',
            style: TextStyle(
              fontSize: 16
            ),
          ),
        ),
      )
    );
  }
}
