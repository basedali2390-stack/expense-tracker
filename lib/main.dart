import 'package:flutter/material.dart';

void main() {
  runApp(const SmartHisabApp());
}

class SmartHisabApp extends StatefulWidget {
  const SmartHisabApp({super.key});

  @override
  State<SmartHisabApp> createState() => _SmartHisabAppState();
}

class _SmartHisabAppState extends State<SmartHisabApp> {
  String selectedLanguage = 'BN'; // 'BN' for Bangla, 'EN' for English
  String selectedCurrency = '৳'; // ৳, ₹, $

  void updateLanguage(String lang) {
    setState(() {
      selectedLanguage = lang;
    });
  }

  void updateCurrency(String curr) {
    setState(() {
      selectedCurrency = curr;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Hisab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: MainNavigationScreen(
        language: selectedLanguage,
        currency: selectedCurrency,
        onLangChange: updateLanguage,
        onCurrChange: updateCurrency,
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  final String language;
  final String currency;
  final Function(String) onLangChange;
  final Function(String) onCurrChange;

  const MainNavigationScreen({
    super.key,
    required this.language,
    required this.currency,
    required this.onLangChange,
    required this.onCurrChange,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final bool isBN = widget.language == 'BN';
    final List<Widget> pages = [
      HomeScreen(currency: widget.currency, language: widget.language),
      VoiceScanScreen(language: widget.language),
      VipSubscriptionScreen(currency: widget.currency, language: widget.language),
      SettingsScreen(
        language: widget.language,
        currency: widget.currency,
        onLangChange: widget.onLangChange,
        onCurrChange: widget.onCurrChange,
      ),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: isBN ? 'হোম' : 'Home',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.mic),
            label: isBN ? 'ভয়েস ও স্ক্যান' : 'Voice & Scan',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.star),
            label: isBN ? 'VIP প্ল্যান' : 'VIP Plan',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: isBN ? 'সেটিংস' : 'Settings',
          ),
        ],
      ),
    );
  }
}

// ================= ১. হোম স্ক্রিন (ক্যাটাগরি/ফাইল ফিল্টার সহ) =================
class HomeScreen extends StatefulWidget {
  final String currency;
  final String language;

  const HomeScreen({super.key, required this.currency, required this.language});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double totalIncome = 5000.0;
  double totalExpense = 1200.0;
  String selectedCategoryFilter = 'সব'; // Filter for category files

  // ডিফল্ট ক্যাটাগরি তালিকা (ফাইলস)
  final List<String> categories = ['বাড়ির খরচ', 'বাজারের খরচ', 'দোকানের খরচ', 'ব্যক্তিগত', 'অন্যান্য'];

  // লেনদেনের ডাটা
  final List<Map<String, dynamic>> transactions = [
    {
      'title': 'চাল ও সবজি কেনা',
      'category': 'বাজারের খরচ',
      'date': '2026-09-01',
      'amount': 1200.0,
      'isIncome': false
    },
    {
      'title': 'দোকানের ক্যাশ জমা',
      'category': 'দোকানের খরচ',
      'date': '2026-09-01',
      'amount': 5000.0,
      'isIncome': true
    },
  ];

  void _openAddTransactionDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCat = categories[0];
    bool isIncome = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(widget.language == 'BN' ? 'নতুন হিসাব (ফাইল) যুক্ত করুন' : 'Add New Record'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: widget.language == 'BN' ? 'বিবরণ (যেমন: চাল কেনা)' : 'Title',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '${widget.language == 'BN' ? 'টাকার পরিমাণ' : 'Amount'} (${widget.currency})',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.language == 'BN' ? 'ফাইল/ক্যাটাগরি বাছুন:' : 'Select Category:',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: selectedCat,
                      items: categories.map((String cat) {
                        return DropdownMenuItem<String>(
                          value: cat,
                          child: Text(cat),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedCat = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ChoiceChip(
                          label: Text(widget.language == 'BN' ? 'খরচ' : 'Expense'),
                          selected: !isIncome,
                          selectedColor: Colors.red.shade100,
                          onSelected: (selected) {
                            if (selected) setDialogState(() => isIncome = false);
                          },
                        ),
                        const SizedBox(width: 10),
                        ChoiceChip(
                          label: Text(widget.language == 'BN' ? 'আয়' : 'Income'),
                          selected: isIncome,
                          selectedColor: Colors.green.shade100,
                          onSelected: (selected) {
                            if (selected) setDialogState(() => isIncome = true);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(widget.language == 'BN' ? 'বাতিল' : 'Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  onPressed: () {
                    final title = titleController.text.trim();
                    final amt = double.tryParse(amountController.text.trim()) ?? 0.0;

                    if (title.isNotEmpty && amt > 0) {
                      setState(() {
                        if (isIncome) {
                          totalIncome += amt;
                        } else {
                          totalExpense += amt;
                        }
                        transactions.insert(0, {
                          'title': title,
                          'category': selectedCat,
                          'date': DateTime.now().toString().split(' ')[0],
                          'amount': amt,
                          'isIncome': isIncome
                        });
                      });
                      Navigator.pop(ctx);
                    }
                  },
                  child: Text(widget.language == 'BN' ? 'সেভ করুন' : 'Save', style: const TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isBN = widget.language == 'BN';
    final double netBalance = totalIncome - totalExpense;

    // ফিল্টার অনুযায়ী তালিকা তৈরি
    final filteredTransactions = selectedCategoryFilter == 'সব'
        ? transactions
        : transactions.where((t) => t['category'] == selectedCategoryFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Hisab', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload, color: Colors.white),
            tooltip: 'Cloud Sync',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isBN ? 'Firebase ক্লাউডে ডাটা ব্যাকআপ সফল হয়েছে!' : 'Data synced to Cloud!'),
                  backgroundColor: Colors.teal,
                ),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          // AdMob এড ব্যানার সিমুলেশন
          Container(
            color: Colors.amber.shade100,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: const Text(
              'AdMob Advertisement Banner',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // মূল ব্যালেন্স কার্ড
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  color: Colors.teal.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(isBN ? 'মোট ব্যালেন্স' : 'Total Balance', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                        const SizedBox(height: 5),
                        Text(
                          '${widget.currency} ${netBalance.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.teal),
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(isBN ? 'মোট আয়' : 'Total Income', style: const TextStyle(color: Colors.grey)),
                                Text('${widget.currency} ${totalIncome.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Column(
                              children: [
                                Text(isBN ? 'মোট খরচ' : 'Total Expense', style: const TextStyle(color: Colors.grey)),
                                Text('${widget.currency} ${totalExpense.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // ফাইল/ক্যাটাগরি ফিল্টার ড্রপডাউন
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isBN ? 'ফাইল ফিল্টার:' : 'Filter File:',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    DropdownButton<String>(
                      value: selectedCategoryFilter,
                      items: ['সব', ...categories].map((String cat) {
                        return DropdownMenuItem<String>(
                          value: cat,
                          child: Text(cat, style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            selectedCategoryFilter = val;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // হিসাবের তালিকা
          Expanded(
            child: filteredTransactions.isEmpty
                ? Center(child: Text(isBN ? 'কোন হিসাবের ফাইল পাওয়া যায়নি' : 'No record found'))
                : ListView.builder(
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final item = filteredTransactions[index];
                      final bool isInc = item['isIncome'];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isInc ? Colors.green.shade100 : Colors.red.shade100,
                            child: Icon(
                              isInc ? Icons.arrow_downward : Icons.arrow_upward,
                              color: isInc ? Colors.green : Colors.red,
                            ),
                          ),
                          title: Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${item['category']} • ${item['date']}'),
                          trailing: Text(
                            '${isInc ? '+' : '-'} ${widget.currency}${item['amount']}',
                            style: TextStyle(
                              color: isInc ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: _openAddTransactionDialog,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}

// ================= ২. ভয়েস ও ডকুমেন্ট স্ক্যানার স্ক্রিন =================
class VoiceScanScreen extends StatelessWidget {
  final String language;

  const VoiceScanScreen({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    final bool isBN = language == 'BN';

    return Scaffold(
      appBar: AppBar(
        title: Text(isBN ? 'ভয়েস ও মেমো স্ক্যানার' : 'Voice & Doc Scanner', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  backgroundColor: Colors.teal,
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (ctx) => Container(
                      padding: const EdgeInsets.all(20),
                      height: 220,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.mic, size: 60, color: Colors.teal),
                          const SizedBox(height: 10),
                          Text(
                            isBN ? 'মুখে বলুন (যেমন: "বাজারের খরচ ৫০০ টাকা")' : 'Speak Now (e.g. "Grocery 500")',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.mic, color: Colors.white, size: 28),
                label: Text(isBN ? 'ভয়েস ইনপুট (মুখে বলুন)' : 'Voice Input', style: const TextStyle(color: Colors.white, fontSize: 18)),
              ),
              const SizedBox(height: 25),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  backgroundColor: Colors.orange,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isBN ? 'ক্যামেরা স্ক্যানার অন হচ্ছে... মেমো/রসিদ স্ক্যান করুন' : 'Opening Camera Doc Scanner...'),
                    ),
                  );
                },
                icon: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
                label: Text(isBN ? 'ডকুমেন্ট/মেমো স্ক্যান করুন' : 'Scan Doc / Receipt', style: const TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= ৩. VIP সাবস্ক্রিপশন স্ক্রিন =================
class VipSubscriptionScreen extends StatefulWidget {
  final String currency;
  final String language;

  const VipSubscriptionScreen({super.key, required this.currency, required this.language});

  @override
  State<VipSubscriptionScreen> createState() => _VipSubscriptionScreenState();
}

class _VipSubscriptionScreenState extends State<VipSubscriptionScreen> {
  bool isVipActive = false;

  void _showPaymentModal(String plan, String amount) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('$plan ${widget.language == 'BN' ? 'কিনুন' : 'Purchase'}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${widget.language == 'BN' ? 'টাকার পরিমাণ' : 'Amount'}: ${widget.currency}$amount',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              const SizedBox(height: 15),
              Text(widget.language == 'BN' ? 'পেমেন্ট মাধ্যম বাছুন:' : 'Select Payment Method:'),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet, color: Colors.pink),
                title: const Text('bKash / Nagad'),
                onTap: () {
                  Navigator.pop(ctx);
                  _activateVip(plan);
                },
              ),
              ListTile(
                leading: const Icon(Icons.credit_card, color: Colors.blue),
                title: const Text('Card / UPI Payment'),
                onTap: () {
                  Navigator.pop(ctx);
                  _activateVip(plan);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(widget.language == 'BN' ? 'বাতিল' : 'Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _activateVip(String plan) {
    setState(() {
      isVipActive = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.language == 'BN' ? '$plan একটিভ হয়েছে! আপনি এখন VIP মেম্বার।' : 'VIP Plan Activated Successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isBN = widget.language == 'BN';

    return Scaffold(
      appBar: AppBar(
        title: Text(isBN ? 'VIP মেম্বারশিপ প্ল্যান' : 'VIP Membership', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(
              Icons.stars_rounded,
              size: 80,
              color: isVipActive ? Colors.amber : Colors.grey,
            ),
            const SizedBox(height: 10),
            Text(
              isVipActive
                  ? (isBN ? 'আপনি একজন VIP সদস্য!' : 'You are a VIP Member!')
                  : (isBN ? 'VIP মেম্বারশিপে আপগ্রেড করুন' : 'Upgrade to VIP'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 25),
            Card(
              child: ListTile(
                title: Text(isBN ? 'মাসিক VIP প্ল্যান' : 'Monthly VIP'),
                subtitle: Text(isBN ? 'বিজ্ঞাপন মুক্ত ও অনলিমিটেড ব্যাকআপ' : 'Ad-free & Unlimited Backup'),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  onPressed: () => _showPaymentModal('মাসিক প্ল্যান', '৩০'),
                  child: Text('${widget.currency} ৩০ / মাস', style: const TextStyle(color: Colors.white)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                title: Text(isBN ? 'বার্ষিক VIP প্ল্যান' : 'Yearly VIP'),
                subtitle: Text(isBN ? '১ বছরের ফুল সার্ভিস (সেরা ডিল)' : '1 Year Full Access (Best Deal)'),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  onPressed: () => _showPaymentModal('বার্ষিক প্ল্যান', '৩০০'),
                  child: Text('${widget.currency} ৩০০ / বছর', style: const TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= ৪. সেটিংস স্ক্রিন (ভাষা, কারেন্সি, সিকিউরিটি ও টাইম নোটিফিকেশন) =================
class SettingsScreen extends StatefulWidget {
  final String language;
  final String currency;
  final Function(String) onLangChange;
  final Function(String) onCurrChange;

  const SettingsScreen({
    super.key,
    required this.language,
    required this.currency,
    required this.onLangChange,
    required this.onCurrChange,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isBiometricEnabled = true;
  bool isNotificationEnabled = true;

  @override
  Widget build(BuildContext context) {
    final bool isBN = widget.language == 'BN';

    return Scaffold(
      appBar: AppBar(
        title: Text(isBN ? 'সেটিংস ও সুরক্ষার পয়েন্ট' : 'Settings & Security', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        children: [
          // Multi-Lang
          ListTile(
            leading: const Icon(Icons.language, color: Colors.teal),
            title: Text(isBN ? 'ভাষা বাছুন (Language)' : 'Select Language'),
            subtitle: Text(widget.language == 'BN' ? 'বাংলা' : 'English'),
            trailing: DropdownButton<String>(
              value: widget.language,
              items: const [
                DropdownMenuItem(value: 'BN', child: Text('বাংলা')),
                DropdownMenuItem(value: 'EN', child: Text('English')),
              ],
              onChanged: (val) {
                if (val != null) widget.onLangChange(val);
              },
            ),
          ),
          const Divider(),
          // Multi-Currency
          ListTile(
            leading: const Icon(Icons.monetization_on, color: Colors.teal),
            title: Text(isBN ? 'মুদ্রা সিলেক্ট (Currency)' : 'Select Currency'),
            subtitle: Text(widget.currency),
            trailing: DropdownButton<String>(
              value: widget.currency,
              items: const [
                DropdownMenuItem(value: '৳', child: Text('৳ (টাকা)')),
                DropdownMenuItem(value: '₹', child: Text('₹ (রুপি)')),
                DropdownMenuItem(value: '\$', child: Text('\$ (ডলার)')),
              ],
              onChanged: (val) {
                if (val != null) widget.onCurrChange(val);
              },
            ),
          ),
          const Divider(),
          // Security
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint, color: Colors.teal),
            title: Text(isBN ? 'সিকিউরিটি (ফিঙ্গারপ্রিন্ট & ফেস লক)' : 'Security (Biometric Lock)'),
            subtitle: Text(isBN ? 'অ্যাপ ওপেন করার সময় বায়োমেট্রিক চাওয়া হবে' : 'Require Fingerprint/Face ID'),
            value: isBiometricEnabled,
            onChanged: (val) {
              setState(() => isBiometricEnabled = val);
            },
          ),
          const Divider(),
          // Global Time Notification & Alarm
          SwitchListTile(
            secondary: const Icon(Icons.alarm_on, color: Colors.teal),
            title: Text(isBN ? 'গ্লোবাল টাইম অ্যালার্ম ও নোটিফিকেশন' : 'Global Alarm & Notification'),
            subtitle: Text(isBN ? 'প্রতিদিন রাত ৯টায় হিসাব দেওয়ার রিমাইন্ডার' : 'Daily Reminder at 9:00 PM'),
            value: isNotificationEnabled,
            onChanged: (val) {
              setState(() => isNotificationEnabled = val);
            },
          ),
          const Divider(),
          // Offline Database Status
          ListTile(
            leading: const Icon(Icons.storage, color: Colors.teal),
            title: Text(isBN ? 'অফলাইন ডাটাবেজ (Hive Storage)' : 'Offline Storage'),
            subtitle: Text(isBN ? 'অফলাইনে সব ডাটা ফাস্ট সেভ থাকবে' : 'Data stored locally'),
            trailing: const Icon(Icons.check_circle, color: Colors.green),
          ),
        ],
      ),
    );
  }
}
