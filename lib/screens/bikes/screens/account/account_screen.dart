import 'package:bike_buddy/constants.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String currency = "";

  @override
  void initState() {
    fetchCurrency();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Account"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Signed in as",
            style: myTextStyle.copyWith(fontSize: 18),
          ),
          Text(
            "${FirebaseAuth.instance.currentUser!.email}",
            style: myTextStyle.copyWith(fontSize: 18),
          ),
          const SizedBox(
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Currency: ",
                style: myTextStyle.copyWith(fontSize: 18),
              ),
              GestureDetector(
                onTap: () => showCurrencyPicker(
                  context: context,
                  theme: CurrencyPickerThemeData(
                    backgroundColor: myGreyColor,
                    titleTextStyle: const TextStyle(color: Colors.white),
                    subtitleTextStyle: const TextStyle(color: Colors.white),
                    currencySignTextStyle: const TextStyle(color: Colors.white),
                  ),
                  searchFieldDecoration: InputDecoration(
                    labelText: "Search",
                    labelStyle: const TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    filled: true,
                    fillColor: myGreyColor,
                  ),
                  onSelect: (Currency selectedCurrency) {
                    saveCurrency(selectedCurrency.code);
                    setState(() {
                      currency = selectedCurrency.code;
                    });
                  },
                ),
                child: Row(
                  children: [
                    Text(
                      currency,
                      style: myTextStyleBold.copyWith(fontSize: 18),
                    ),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                    )
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 140,
          ),
          GestureDetector(
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(255, 51, 56, 58),
                    blurRadius: 15,
                    offset: Offset(-4, -4),
                  ),
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 15,
                    offset: Offset(4, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                  color: myBackgroundColor,
                  child: Text(
                    'Sign out',
                    style: myTextStyleBold.copyWith(
                        color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> fetchCurrency() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? tempCurrency = prefs.getString('currency');
    if (tempCurrency == null) {
      prefs.setString('currency', 'RON');
      setState(() {
        currency = 'RON';
      });
    } else {
      setState(() {
        currency = tempCurrency;
      });
    }
  }

  Future<void> saveCurrency(String currencySymbol) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('currency', currencySymbol);
  }
}
