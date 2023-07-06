import 'package:bike_buddy/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('No Internet'),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'No internet connection',
                style: myTextStyle,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  bool isDeviceConnected = false;
                  try {
                    final response =
                        await head(Uri.parse("https://www.google.com"));
                    isDeviceConnected = response.statusCode == 200;
                  } catch (e) {
                    isDeviceConnected = false;
                  }

                  if (isDeviceConnected && context.mounted) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Still no internet connection'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
                child: const Text('Check Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
