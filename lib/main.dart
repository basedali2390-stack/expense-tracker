import 'package:flutter/material.dart';

void main() {
  runApp(const SmartHisabApp());
}

class SmartHisabApp extends StatelessWidget {
  const SmartHisabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Hisab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const VoiceScanScreen(),
    const VipSubscriptionScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'হোম',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mic_sharp),
            label: 'ভয়েস ও স্ক্যান',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.workspace_premium),
            label: 'VIP',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'সেটিংস',
          ),
        ],
      ),
    );
  }
}

// ১. হোম স্ক্রিন (লোগো/ছবি যুক্ত করা হয়েছে)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double totalIncome = 2000.00;
  double totalExpense = 0.00;

  // আপনার আপলোড করা ছবি/লোগোর লিংক
  final String userLogoUrl = 'https://ibb.co/cc1HzKkZ';

  final List<Map<String, String>> transactions = [
    {'title': 'bajar', 'date': '2026-08-31', 'amount': '+ ৳2000.0', 'type': 'income'}
  ];

  void _showAddTransactionDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String type = 'expense';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulWidget(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('নতুন হিসাব যুক্ত করুন'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'বিবরণ (যেমন: বাজার)'),
                  ),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'টাকার পরিমাণ (৳)'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('খরচ'),
                          value: 'expense',
                          groupValue: type,
                          onChanged: (val) {
                            setDialogState(() => type = val!);
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('আয়'),
                          value: 'income',
                          groupValue: type,
                          onChanged: (val) {
                            setDialogState(() => type = val!);
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('বাতিল'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty && amountController.text.isNotEmpty) {
                      final amt = double.tryParse(amountController.text) ?? 0.0;
                      setState(() {
                        if (type == 'income') {
                          totalIncome += amt;
                          transactions.insert(0, {
                            'title': titleController.text,
                            'date': DateTime.now().toString().split(' ')[0],
                            'amount': '+ ৳$amt',
                            'type': 'income'
                          });
                        } else {
                          totalExpense += amt;
                          transactions.insert(0, {
                            'title': titleController.text,
                            'date': DateTime.now().toString().split(' ')[0],
                            'amount': '- ৳$amt',
                            'type': 'expense'
                          });
                        }
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('সেভ করুন'),
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
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(userLogoUrl),
              backgroundColor: Colors.white,
            ),
            const SizedBox(width: 10),
            const Text('Smart Hisab', style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_done, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('অফলাইন ডাটা সেভ আছে!')),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              color: Colors.teal.shade50,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: NetworkImage(userLogoUrl),
                      backgroundColor: Colors.teal.shade100,
                    ),
                    const SizedBox(height: 10),
                    const Text('মোট ব্যালেন্স', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 5),
                    Text(
                      '৳ ${(totalIncome - totalExpense).toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                    const Divider(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('মোট আয়', style: TextStyle(color: Colors.grey)),
                            Text('৳ ${totalIncome.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('মোট খরচ', style: TextStyle(color: Colors.grey)),
                            Text('৳ ${totalExpense.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final item = transactions[index];
                  final isIncome = item['type'] == 'income';
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isIncome ? Colors.lightGreen : Colors.redAccent,
                        child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: Colors.white),
                      ),
                      title: Text(item['title']!),
                      subtitle: Text(item['date']!),
                      trailing: Text(
                        item['amount']!,
                        style: TextStyle(
                          color: isIncome ? Colors.green : Colors.red,
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
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: _showAddTransactionDialog,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}

// ২. ভয়েস ও মেমো স্ক্যান স্ক্রিন
class VoiceScanScreen extends StatelessWidget {
  const VoiceScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ভয়েস ও মেমো স্ক্যানার'), backgroundColor: Colors.teal),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                backgroundColor: Colors.teal,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ভয়েস ইনপুট চালু হচ্ছে... মুখে বলুন "বাজার ৫০০ টাকা"')),
                );
              },
              icon: const Icon(Icons.mic, color: Colors.white, size: 28),
              label: const Text('মুখে বলে হিসাব লিখুন', style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                backgroundColor: Colors.orange,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ক্যামেরা ওপেন হচ্ছে... রসিদের ছবি তুলুন')),
                );
              },
              icon: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
              label: const Text('মেমো/রসিদ স্ক্যান করুন', style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

// ৩. ভিআইপি সাবস্ক্রিপশন স্ক্রিন
class VipSubscriptionScreen extends StatefulWidget {
  const VipSubscriptionScreen({super.key});

  @override
  State<VipSubscriptionScreen> createState() => _VipSubscriptionScreenState();
}

class _VipSubscriptionScreenState extends State<VipSubscriptionScreen> {
  bool isVip = false;

  void _processPayment(String planName, String amount) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$planName রিচার্জ করুন'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('মোট দেঅয়া টাকা: ৳$amount', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
              const SizedBox(height: 15),
              const Text('পেমেন্ট মেথড বাছাই করুন:'),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet, color: Colors.pink),
                title: const Text('bKash / Nagad'),
                onTap: () => _completeRecharge(planName),
              ),
              ListTile(
                leading: const Icon(Icons.credit_card, color: Colors.blue),
                title: const Text('Card / UPI'),
                onTap: () => _completeRecharge(planName),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('বাতিল'),
            ),
          ],
        );
      },
    );
  }

  void _completeRecharge(String planName) {
    Navigator.pop(context);
    setState(() {
      isVip = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ধন্যবাদ! আপনার $planName রিচার্জ সফল হয়েছে। VIP একটিভ হয়েছে!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VIP মেম্বারশিপ'), backgroundColor: Colors.teal),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(Icons.workspace_premium, size: 80, color: isVip ? Colors.amber : Colors.grey),
            const SizedBox(height: 10),
            Text(
              isVip ? 'আপনি একজন VIP মেম্বার!' : 'Smart Hisab VIP প্রিমিয়াম',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              child: ListTile(
                title: const Text('মাসিক প্ল্যান'),
                subtitle: const Text('সকল প্রিমিয়াম সুবিধা সহ'),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  onPressed: () => _processPayment('মাসিক প্ল্যান', '৩০'),
                  child: const Text('৳ ৩০ / মাস', style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 4,
              child: ListTile(
                title: const Text('বার্ষিক প্ল্যান (সেরা ডিল)'),
                subtitle: const Text('১ বছরের জন্য সম্পূর্ণ VIP সুবিধা'),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  onPressed: () => _processPayment('বার্ষিক প্ল্যান', '৩০০'),
                  child: const Text('৳ ৩০০ / বছর', style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ৪. সেটিংস স্ক্রিন
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('সেটিংস'), backgroundColor: Colors.teal),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('বায়োমেট্রিক/ফিঙ্গারপ্রিন্ট লক'),
            subtitle: const Text('অ্যাপ সুরক্ষায় ফিঙ্গারপ্রিন্ট ব্যবহার করুন'),
            value: true,
            onChanged: (val) {},
          ),
          SwitchListTile(
            title: const Text('ডেইলি রিমাইন্ডার নোটিফিকেশন'),
            subtitle: const Text('প্রতিদিন রাত ৯টায় হিসাব দেওয়ার রিমাইন্ডার'),
            value: true,
            onChanged: (val) {},
          ),
          const ListTile(
            title: Text('মুদ্রা (Currency)'),
            subtitle: Text('টাকা (৳)'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
          ),
        ],
      ),
    );
  }
}
