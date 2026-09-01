import 'package:flutter/material.dart';

// =========================================================
// অ্যাপের প্রাথমিক নাম ও লোগোর লিংক
// =========================================================
const String appTitle = "স্মার্ট হিসাব";
const String logoUrl = "https://i.ibb.co/c5K96X2/image.jpg";

void main() {
  runApp(const SmartHisabApp());
}

class SmartHisabApp extends StatefulWidget {
  const SmartHisabApp({super.key});

  @override
  State<SmartHisabApp> createState() => _SmartHisabAppState();
}

class _SmartHisabAppState extends State<SmartHisabApp> {
  bool isDarkMode = false;
  bool isBengali = true;
  bool isVipUser = false;
  bool isPinLocked = true;
  String currentCurrency = '৳';

  void toggleTheme() => setState(() => isDarkMode = !isDarkMode);
  void toggleLanguage() => setState(() => isBengali = !isBengali);
  void unlockApp() => setState(() => isPinLocked = false);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appTitle,
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: isPinLocked
          ? PinScreen(onSuccess: unlockApp, isBengali: isBengali)
          : HomeScreen(
              isDarkMode: isDarkMode,
              isBengali: isBengali,
              isVipUser: isVipUser,
              currency: currentCurrency,
              onThemeToggle: toggleTheme,
              onLangToggle: toggleLanguage,
              onVipUpgrade: () => setState(() => isVipUser = true),
              onCurrencyChange: (val) => setState(() => currentCurrency = val),
            ),
    );
  }
}

// ---------------------------------------------------------
// PIN SCREEN
// ---------------------------------------------------------
class PinScreen extends StatefulWidget {
  final VoidCallback onSuccess;
  final bool isBengali;
  const PinScreen({super.key, required this.onSuccess, required this.isBengali});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String pin = '';

  void _onKeyPress(String val) {
    if (pin.length < 4) {
      setState(() => pin += val);
      if (pin == '1234') {
        widget.onSuccess();
      } else if (pin.length == 4) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isBengali ? 'ভুল পিন! সঠিক পিন: 1234' : 'Wrong PIN! Correct PIN: 1234'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => pin = '');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.isBengali ? 'পিন লিখুন' : 'Enter PIN', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            Text(pin.padRight(4, '*'), style: const TextStyle(fontSize: 30, letterSpacing: 10)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(10, (index) {
                int number = (index + 1) % 10;
                return ElevatedButton(
                  onPressed: () => _onKeyPress(number.toString()),
                  child: Text(number.toString()),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// HOME SCREEN
// ---------------------------------------------------------
class HomeScreen extends StatelessWidget {
  final bool isDarkMode;
  final bool isBengali;
  final bool isVipUser;
  final String currency;
  final VoidCallback onThemeToggle;
  final VoidCallback onLangToggle;
  final VoidCallback onVipUpgrade;
  final ValueChanged<String> onCurrencyChange;

  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.isBengali,
    required this.isVipUser,
    required this.currency,
    required this.onThemeToggle,
    required this.onLangToggle,
    required this.onVipUpgrade,
    required this.onCurrencyChange,
  });

  void _showWipDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isBengali ? 'VIP প্ল্যান নির্বাচন করুন' : 'Choose VIP Plan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _paymentPackageCard(
              context: ctx,
              title: isBengali ? '১ মাস - ৯৯৳ / \$0.99' : '1 Month - \$0.99',
              subTitle: isBengali ? 'সকল অ্যাড বন্ধ ও ব্যাকআপ' : 'No Ads + Backup',
              onSuccess: onVipUpgrade,
            ),
            const SizedBox(height: 10),
            _paymentPackageCard(
              context: ctx,
              title: isBengali ? 'লাইফটাইম - ৯৯৯৳ / \$4.99' : 'Lifetime - \$4.99',
              subTitle: isBengali ? 'আজীবন প্রিমিয়াম সুবিধা' : 'Lifetime Premium Access',
              onSuccess: onVipUpgrade,
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentPackageCard({
    required BuildContext context,
    required String title,
    required String subTitle,
    required VoidCallback onSuccess,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subTitle),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade700),
          onPressed: () {
            onSuccess();
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isBengali
                      ? 'পেমেন্ট সফল হয়েছে! আপনি এখন VIP ব্যবহারকারী।'
                      : 'Payment Successful! VIP Activated.',
                ),
                backgroundColor: Colors.green.shade800,
              ),
            );
          },
          child: Text(
            isBengali ? 'কিনুন' : 'Pay',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appTitle),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: onThemeToggle,
          ),
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: onLangToggle,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(appTitle),
              accountEmail: Text(isVipUser ? 'VIP User' : 'Free User'),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(logoUrl),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.currency_exchange),
              title: Text(isBengali ? 'মুদ্রা পরিবর্তন' : 'Change Currency'),
              subtitle: Text(currency),
              trailing: DropdownButton<String>(
                value: currency,
                items: const [
                  DropdownMenuItem(value: '৳', child: Text('৳ (BDT)')),
                  DropdownMenuItem(value: '₹', child: Text('₹ (INR)')),
                  DropdownMenuItem(value: '\$', child: Text('\$ (USD)')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    onCurrencyChange(val);
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: Text(isBengali ? 'VIP আপগ্রেড' : 'VIP Upgrade'),
              onTap: () {
                Navigator.pop(context);
                _showWipDialog(context);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
          isBengali ? 'স্বাগতম!' : 'Welcome!',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
