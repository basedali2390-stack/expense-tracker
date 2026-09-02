import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  void toggleLanguage() {
    setState(() {
      isBangla = !isBangla;
    });
  }

  void changeCurrency(String newCurrency) {
    setState(() {
      currencySymbol = newCurrency;
    });
  }

  void unlockVIP() {
    setState(() {
      isPremium = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: isBangla ? 'স্মার্ট হিসাব খাতা' : 'Digital Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: isLocked
          ? LockScreen(onUnlock: () => setState(() => isLocked = false), isBangla: isBangla)
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

// মডেল ক্লাসেস
class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final bool isExpense;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.isExpense,
    required this.date,
  });
}

class ExpenseFile {
  final String id;
  final String title;
  final Color color;
  final List<TransactionModel> transactions;

  ExpenseFile({
    required this.id,
    required this.title,
    required this.color,
    required this.transactions,
  });
}

// মূল হোম স্ক্রিন (ফাইল ও ক্যাটাগরি সিস্টেমসহ)
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
  List<ExpenseFile> files = [
    ExpenseFile(
      id: '1',
      title: 'বাজারের খরচ',
      color: Colors.teal,
      transactions: [],
    ),
    ExpenseFile(
      id: '2',
      title: 'বাড়ির খরচ',
      color: Colors.orange,
      transactions: [],
    ),
  ];

  int selectedFileIndex = 0;

  void _addNewFile(String title) {
    setState(() {
      files.add(
        ExpenseFile(
          id: DateTime.now().toString(),
          title: title,
          color: Colors.primaries[files.length % Colors.primaries.length],
          transactions: [],
        ),
      );
      selectedFileIndex = files.length - 1;
    });
  }

  void _addTransaction(String title, double amount, bool isExpense) {
    setState(() {
      files[selectedFileIndex].transactions.insert(
            0,
            TransactionModel(
              id: DateTime.now().toString(),
              title: title,
              amount: amount,
              isExpense: isExpense,
              date: DateTime.now(),
            ),
          );
    });
  }

  void _showCreateFileDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(widget.isBangla ? 'নতুন ফাইল তৈরি করুন' : 'Create New File'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: widget.isBangla ? 'যেমন: দোকানের খরচ' : 'e.g. Shop Expense',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(widget.isBangla ? 'বাতিল' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _addNewFile(controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: Text(widget.isBangla ? 'তৈরি করুন' : 'Create'),
          ),
        ],
      ),
    );
  }

  void _showAddTransactionDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    bool isExpense = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.isBangla ? 'নতুন হিসেব যোগ করুন' : 'Add New Transaction',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: widget.isBangla ? 'বিবরণ' : 'Description',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.mic),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(widget.isBangla
                              ? 'ভয়েস ইনপুট চালু করা হয়েছে...'
                              : 'Voice input activated...'),
                        ),
                      );
                    },
                  ),
                ),
              ),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: widget.isBangla ? 'পরিমাণ' : 'Amount',
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: Text(widget.isBangla ? 'খরচ' : 'Expense'),
                    selected: isExpense,
                    onSelected: (val) => setModalState(() => isExpense = true),
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: Text(widget.isBangla ? 'জমা' : 'Income'),
                    selected: !isExpense,
                    onSelected: (val) => setModalState(() => isExpense = false),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  final amt = double.tryParse(amountController.text) ?? 0.0;
                  if (titleController.text.isNotEmpty && amt > 0) {
                    _addTransaction(titleController.text, amt, isExpense);
                    Navigator.pop(ctx);
                  }
                },
                child: Text(widget.isBangla ? 'সেভ করুন' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentFile = files[selectedFileIndex];
    double totalIncome = currentFile.transactions
        .where((t) => !t.isExpense)
        .fold(0, (sum, item) => sum + item.amount);
    double totalExpense = currentFile.transactions
        .where((t) => t.isExpense)
        .fold(0, (sum, item) => sum + item.amount);
    double totalBalance = totalIncome - totalExpense;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentFile.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: widget.onToggleLang,
          ),
          PopupMenuButton<String>(
            onSelected: widget.onChangeCurrency,
            icon: const Icon(Icons.monetization_on),
            itemBuilder: (context) => [
              const PopupMenuItem(value: '৳', child: Text('৳ BDT')),
              const PopupMenuItem(value: '₹', child: Text('₹ INR')),
              const PopupMenuItem(value: '\$', child: Text('\$ USD')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(widget.isBangla ? 'ডকুমেন্ট স্ক্যানার চালু হচ্ছে...' : 'Document Scanner opening...'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.lock),
            onPressed: widget.onLockApp,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.teal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('স্মার্ট হিসাব খাতা', style: TextStyle(color: Colors.white, fontSize: 20)),
                  const SizedBox(height: 10),
                  Text(widget.isPremium ? 'VIP Member' : 'Free Plan', style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            if (!widget.isPremium)
              ListTile(
                leading: const Icon(Icons.star, color: Colors.amber),
                title: Text(widget.isBangla ? 'VIP মেম্বার হন (৩০৳/মাস)' : 'Get VIP (30 Tk/mo)'),
                onTap: () {
                  widget.onUnlockVIP();
                  Navigator.pop(context);
                },
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.add_box),
              title: Text(widget.isBangla ? '+ নতুন ফাইল যোগ করুন' : '+ Add New File'),
              onTap: () {
                Navigator.pop(context);
                _showCreateFileDialog();
              },
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 8),
              child: Text(widget.isBangla ? 'আপনার ফাইলসমূহ:' : 'Your Files:'),
            ),
            ...files.asMap().entries.map((entry) {
              int idx = entry.key;
              ExpenseFile file = entry.value;
              return ListTile(
                leading: Icon(Icons.folder, color: file.color),
                title: Text(file.title),
                selected: selectedFileIndex == idx,
                onTap: () {
                  setState(() => selectedFileIndex = idx);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Text(widget.isBangla ? 'মোট ব্যালেন্স' : 'Total Balance'),
                Text(
                  '${widget.currencySymbol} $totalBalance',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(widget.isBangla ? 'মোট আয়' : 'Total Income'),
                        Text('${widget.currencySymbol} $totalIncome', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      children: [
                        Text(widget.isBangla ? 'মোট খরচ' : 'Total Expense'),
                        Text('${widget.currencySymbol} $totalExpense', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: currentFile.transactions.isEmpty
                ? Center(child: Text(widget.isBangla ? 'কোনো লেনদেন নেই' : 'No Transactions'))
                : ListView.builder(
                    itemCount: currentFile.transactions.length,
                    itemBuilder: (ctx, index) {
                      final item = currentFile.transactions[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: item.isExpense ? Colors.red : Colors.green,
                          child: Icon(item.isExpense ? Icons.arrow_downward : Icons.arrow_upward, color: Colors.white),
                        ),
                        title: Text(item.title),
                        subtitle: Text(DateFormat('yyyy-MM-dd').format(item.date)),
                        trailing: Text(
                          '${item.isExpense ? "-" : "+"} ${widget.currencySymbol}${item.amount}',
                          style: TextStyle(
                            color: item.isExpense ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (!widget.isPremium)
            Container(
              height: 50,
              color: Colors.grey.shade300,
              child: const Center(child: Text('AdMob Banner Ad Here')),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// লক স্ক্রিন
class LockScreen extends StatefulWidget {
  final VoidCallback onUnlock;
  final bool isBangla;
  const LockScreen({super.key, required this.onUnlock, required this.isBangla});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 80, color: Colors.teal),
              const SizedBox(height: 20),
              Text(widget.isBangla ? 'পিন নম্বর দিন (ডিফল্ট: 1234)' : 'Enter PIN (Default: 1234)'),
              TextField(
                controller: pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (pinController.text == '1234') {
                    widget.onUnlock();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(widget.isBangla ? 'ভুল পিন' : 'Wrong PIN')),
                    );
                  }
                },
                child: Text(widget.isBangla ? 'আনলক করুন' : 'Unlock'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
