import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AdvancedExpenseTrackerApp());
}

class AdvancedExpenseTrackerApp extends StatefulWidget {
  const AdvancedExpenseTrackerApp({super.key});

  @override
  State<AdvancedExpenseTrackerApp> createState() => _AdvancedExpenseTrackerAppState();
}

class _AdvancedExpenseTrackerAppState extends State<AdvancedExpenseTrackerApp> {
  bool isBangla = true;
  String currencySymbol = '৳';
  bool isPremium = false;
  bool isLocked = false;

  void toggleLanguage() => setState(() => isBangla = !isBangla);
  void changeCurrency(String symbol) => setState(() => currencySymbol = symbol);
  void unlockVIP() => setState(() => isPremium = true);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: isLocked
          ? LockScreen(onUnlock: () => setState(() => isLocked = false))
          : HomeScreen(
              isBangla: isBangla,
              currencySymbol: currencySymbol,
              isPremium: isPremium,
              onToggleLang: toggleLanguage,
              onChangeCurrency: changeCurrency,
              onUnlockVIP: unlockVIP,
              onLockApp: () => setState(() => isLocked = true),
            ),
    );
  }
}

// Transaction Model
class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String category;
  final bool isExpense;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.isExpense,
    required this.date,
  });
}

// Lock Screen Widget
class LockScreen extends StatefulWidget {
  final VoidCallback onUnlock;
  const LockScreen({super.key, required this.onUnlock});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final TextEditingController _pinController = TextEditingController();

  void _verify() {
    if (_pinController.text == "1234") {
      widget.onUnlock();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ভুল পিন! সঠিক পিন হলো: 1234')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 80, color: Colors.teal),
              const SizedBox(height: 20),
              const Text('অ্যাপ আনলক করতে পিন দিন (Default: 1234)', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 15),
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'PIN (1234)',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _verify,
                child: const Text('আনলক করুন'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Home Screen Widget
class HomeScreen extends StatefulWidget {
  final bool isBangla;
  final String currencySymbol;
  final bool isPremium;
  final VoidCallback onToggleLang;
  final Function(String) onChangeCurrency;
  final VoidCallback onUnlockVIP;
  final VoidCallback onLockApp;

  const HomeScreen({
    super.key,
    required this.isBangla,
    required this.currencySymbol,
    required this.isPremium,
    required this.onToggleLang,
    required this.onChangeCurrency,
    required this.onUnlockVIP,
    required this.onLockApp,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<TransactionModel> _transactions = [
    TransactionModel(id: '1', title: 'কাঁচাবাজার', amount: 450, category: 'বাজার খরচ', isExpense: true, date: DateTime.now()),
    TransactionModel(id: '2', title: 'বাসা ভাড়া', amount: 8000, category: 'বাড়ি খরচ', isExpense: true, date: DateTime.now()),
    TransactionModel(id: '3', title: 'দোকান মালামাল', amount: 15000, category: 'দোকান খরচ', isExpense: true, date: DateTime.now()),
  ];

  String selectedCategoryFilter = 'সব';
  final List<String> categories = ['সব', 'বাজার খরচ', 'বাড়ি খরচ', 'দোকান খরচ', 'অন্যান্য'];

  double get totalExpense {
    return _transactions.where((t) => t.isExpense).fold(0, (sum, item) => sum + item.amount);
  }

  void _addTransaction(String title, double amount, String category) {
    setState(() {
      _transactions.insert(
        0,
        TransactionModel(
          id: DateTime.now().toString(),
          title: title,
          amount: amount,
          category: category,
          isExpense: true,
          date: DateTime.now(),
        ),
      );
    });
  }

  void _showAddDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCat = 'বাজার খরচ';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(widget.isBangla ? 'নতুন হিসাব যোগ করুন' : 'Add New Record'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: minAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: InputDecoration(labelText: widget.isBangla ? 'বিবরণ' : 'Title')),
              TextField(controller: amountController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: widget.isBangla ? 'টাকা' : 'Amount')),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedCat,
                items: ['বাজার খরচ', 'বাড়ি খরচ', 'দোকান খরচ', 'অন্যান্য'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) { if (val != null) selectedCat = val; },
                decoration: const InputDecoration(labelText: 'ক্যাটাগরি'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && amountController.text.isNotEmpty) {
                _addTransaction(titleController.text, double.parse(amountController.text), selectedCat);
                Navigator.pop(ctx);
              }
            },
            child: const Text('সেভ করুন'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<TransactionModel> filteredList = selectedCategoryFilter == 'সব'
        ? _transactions
        : _transactions.where((t) => t.category == selectedCategoryFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isBangla ? 'হিসাব খাতা' : 'Expense Tracker'),
        actions: [
          IconButton(icon: const Icon(Icons.language), onPressed: widget.onToggleLang),
          IconButton(icon: const Icon(Icons.lock_outline), onPressed: widget.onLockApp),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(widget.isBangla ? 'ইউজার নাম' : 'User Account'),
              accountEmail: Text(widget.isPremium ? '🌟 VIP সদস্য' : 'ফ্রি মেম্বার'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.teal),
              ),
              decoration: const BoxDecoration(color: Colors.teal),
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: Text(widget.isBangla ? 'কারেন্সি সিলেক্ট' : 'Change Currency'),
              trailing: DropdownButton<String>(
                value: widget.currencySymbol,
                items: ['৳', '₹', '\$'].map((symbol) {
                  return DropdownMenuItem(value: symbol, child: Text(symbol));
                }).toList(),
                onChanged: (val) {
                  if (val != null) widget.onChangeCurrency(val);
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.cloud_sync),
              title: const Text('Cloud Backup (Firebase)'),
              subtitle: const Text('অটোমেটিক সিঙ্ক অন'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('☁️ ক্লাউড ব্যাকআপ সফল হয়েছে!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_active),
              title: const Text('Notification Reminder'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('🔔 প্রতিদিনের রিমাইন্ডার সেট করা হলো')),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.workspace_premium, color: Colors.amber),
              title: const Text('VIP Plan (৩০৳/মাস)'),
              subtitle: Text(widget.isPremium ? 'আনলক করা আছে' : 'প্রিমিয়াম সুবিধা নিতে আপগ্রেড করুন'),
              onTap: () {
                widget.onUnlockVIP();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('🎉 VIP প্ল্যান সফলভাবে আনলক করা হয়েছে!')),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.amber.shade100,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: const Text(
              '📢 AdMob Banner Space (গুগল বিজ্ঞাপন)',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.teal.shade700, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.isBangla ? 'মোট খরচ:' : 'Total Expense:', style: const TextStyle(color: Colors.white, fontSize: 18)),
                Text('${widget.currencySymbol} ${totalExpense.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🎙️ ভয়েস ইনপুট শুনছে...'))),
                    icon: const Icon(Icons.mic),
                    label: Text(widget.isBangla ? 'ভয়েস ইনপুট' : 'Voice Input'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📷 রসিদ স্ক্যানার চালুর মোড...'))),
                    icon: const Icon(Icons.document_scanner),
                    label: Text(widget.isBangla ? 'রসিদ স্ক্যান' : 'Doc Scanner'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: categories.map((cat) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: selectedCategoryFilter == cat,
                    onSelected: (selected) => setState(() => selectedCategoryFilter = cat),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(),
          Expanded(
            child: filteredList.isEmpty
                ? const Center(child: Text('কোনো ডাটা পাওয়া যায়নি!'))
                : ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (ctx, i) {
                      final item = filteredList[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal.shade100,
                          child: Icon(
                            item.category == 'বাজার খরচ' ? Icons.shopping_cart : item.category == 'বাড়ি খরচ' ? Icons.home : Icons.store,
                            color: Colors.teal,
                          ),
                        ),
                        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${item.category} • ${item.date.day}/${item.date.month}/${item.date.year}'),
                        trailing: Text('- ${widget.currencySymbol}${item.amount}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: _showAddDialog, child: const Icon(Icons.add)),
    );
  }
}
