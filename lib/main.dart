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
      title: isBangla ? 'ডিজিটাল হিসাব খাতা' : 'Digital Expense Tracker',
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

// মডেল ক্লাস
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
    List<TransactionModel>? transactions,
  }) : transactions = transactions ?? [];

  double get totalExpense {
    return transactions.where((t) => t.isExpense).fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalIncome {
    return transactions.where((t) => !t.isExpense).fold(0.0, (sum, item) => sum + item.amount);
  }
}

// সিকিউরিটি পিন লক স্ক্রিন
class LockScreen extends StatefulWidget {
  final VoidCallback onUnlock;
  final bool isBangla;

  const LockScreen({super.key, required this.onUnlock, required this.isBangla});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final TextEditingController _pinController = TextEditingController();

  void _verifyPin() {
    if (_pinController.text == '1234') { // ডিফল্ট পিন: 1234
      widget.onUnlock();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.isBangla ? 'ভুল পিন কোড!' : 'Invalid PIN!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade800,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_rounded, size: 80, color: Colors.white),
              const SizedBox(height: 20),
              Text(
                widget.isBangla ? 'অ্যাপ সিকিউরিটি লক' : 'App Security Lock',
                style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                widget.isBangla ? 'পিন কোড দিন (ডিফল্ট: 1234)' : 'Enter PIN Code (Default: 1234)',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 8, color: Colors.white),
                decoration: InputDecoration(
                  counterText: "",
                  filled: true,
                  fillColor: Colors.white24,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _verifyPin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: Text(
                  widget.isBangla ? 'আনলক করুন' : 'Unlock',
                  style: TextStyle(color: Colors.teal.shade800, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// হোম স্ক্রিন
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
  final List<ExpenseFile> userFiles = [];

  final List<Color> cardColors = [
    Colors.teal.shade700,
    Colors.blue.shade700,
    Colors.orange.shade700,
    Colors.purple.shade700,
    Colors.indigo.shade700,
    Colors.pink.shade700,
  ];

  void _addNewFile(String fileName) {
    setState(() {
      userFiles.add(
        ExpenseFile(
          id: DateTime.now().toString(),
          title: fileName,
          color: cardColors[userFiles.length % cardColors.length],
        ),
      );
    });
  }

  void _showAddFileDialog() {
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(widget.isBangla ? 'নতুন ফাইল তৈরি করুন' : 'Create New File'),
        content: TextField(
          controller: titleController,
          decoration: InputDecoration(
            hintText: widget.isBangla ? 'যেমন: বাজার খরচ, ঘর খরচ' : 'e.g. Market, House Expense',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(widget.isBangla ? 'বাতিল' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                _addNewFile(titleController.text.trim());
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade700),
            child: Text(widget.isBangla ? 'তৈরি করুন' : 'Create', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showVIPDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(widget.isBangla ? '👑 VIP প্ল্যান নিন' : '👑 Upgrade to VIP'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.isBangla ? 'অসীমিত ডাটা ব্যাকআপ, অ্যাড-ফ্রি অভিজ্ঞতা এবং সব ফিচার আনলক করুন!' : 'Unlock Unlimited Cloud Backup, Ad-free experience & Premium Features!'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                widget.onUnlockVIP();
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(widget.isBangla ? 'অভিনন্দন! আপনি VIP মেম্বার।' : 'Congrats! VIP Activated.')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade700),
              child: Text(widget.isBangla ? '৩০৳/মাস বা ৩০০৳/বছর আনলক' : 'Unlock 30 Tk/mo or 300 Tk/yr', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(widget.isBangla ? 'ডিজিটাল হিসাব খাতা' : 'Expense Tracker', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            onPressed: widget.onToggleLang,
            tooltip: 'Language',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.currency_exchange, color: Colors.white),
            onSelected: widget.onChangeCurrency,
            itemBuilder: (context) => [
              const PopupMenuItem(value: '৳', child: Text('৳ BDT')),
              const PopupMenuItem(value: '₹', child: Text('₹ INR')),
              const PopupMenuItem(value: '\$', child: Text('\$ USD')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.lock, color: Colors.white),
            onPressed: widget.onLockApp,
            tooltip: 'Lock App',
          ),
        ],
      ),
      body: Column(
        children: [
          // AdMob ব্যানারের নোটিশ স্থান (Ad placement area)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: Colors.amber.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.ads_click, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      widget.isPremium ? (widget.isBangla ? 'VIP সদস্য (বিজ্ঞাপন মুক্ত)' : 'VIP Member (No Ads)') : (widget.isBangla ? 'বিজ্ঞাপন দেখাচ্ছে (AdMob Enabled)' : 'Showing Ads (AdMob Enabled)'),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (!widget.isPremium)
                  GestureDetector(
                    onTap: _showVIPDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.amber.shade800, borderRadius: BorderRadius.circular(6)),
                      child: Text(widget.isBangla ? 'VIP হন' : 'Go VIP', style: const TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.isBangla ? 'আপনার ফাইলসমূহ:' : 'Your Files:',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${widget.isBangla ? 'মুদ্রা' : 'Currency'}: ${widget.currencySymbol}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: userFiles.isEmpty
                        ? Center(
                            child: Text(
                              widget.isBangla ? 'কোনো ফাইল নেই! নিচের + বাটনে চাপ দিয়ে\nবাড়ির খরচ, বাজারের খরচ ফাইল তৈরি করুন।' : 'No files created!\nPress + button to add new files.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey, fontSize: 15),
                            ),
                          )
                        : GridView.builder(
                            itemCount: userFiles.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 1.0,
                            ),
                            itemBuilder: (context, index) {
                              final file = userFiles[index];
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FileDetailScreen(
                                        file: file,
                                        currencySymbol: widget.currencySymbol,
                                        isBangla: widget.isBangla,
                                      ),
                                    ),
                                  ).then((_) => setState(() {}));
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: file.color.withOpacity(0.3), width: 1.5),
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 26,
                                        backgroundColor: file.color.withOpacity(0.15),
                                        child: Icon(Icons.folder_rounded, color: file.color, size: 30),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        file.title,
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${widget.isBangla ? 'খরচ' : 'Expense'}: ${widget.currencySymbol}${file.totalExpense.toStringAsFixed(0)}',
                                        style: TextStyle(fontSize: 13, color: Colors.red.shade600, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddFileDialog,
        backgroundColor: Colors.teal.shade700,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          widget.isBangla ? 'নতুন ফাইল তৈরি করুন' : 'Create File',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ফাইল ভিত্তিক বিবরণ স্ক্রিন
class FileDetailScreen extends StatefulWidget {
  final ExpenseFile file;
  final String currencySymbol;
  final bool isBangla;

  const FileDetailScreen({super.key, required this.file, required this.currencySymbol, required this.isBangla});

  @override
  State<FileDetailScreen> createState() => _FileDetailScreenState();
}

class _FileDetailScreenState extends State<FileDetailScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isExpense = true;

  void _addTransaction() {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    if (title.isNotEmpty && amount > 0) {
      setState(() {
        widget.file.transactions.add(
          TransactionModel(
            id: DateTime.now().toString(),
            title: title,
            amount: amount,
            isExpense: _isExpense,
            date: DateTime.now(),
          ),
        );
      });
      _titleController.clear();
      _amountController.clear();
      Navigator.pop(context);
    }
  }

  void _simulateVoiceInput() {
    setState(() {
      _titleController.text = widget.isBangla ? "ভয়েস দিয়ে কেনাকাটা" : "Voice Shopping";
      _amountController.text = "500";
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(widget.isBangla ? 'ভয়েস ইনপুট ধরা হয়েছে (৫০০ টাকা)' : 'Voice Input Captured (500)')),
    );
  }

  void _showAddTransactionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, top: 20, left: 20, right: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${widget.file.title} - ${widget.isBangla ? 'হিসাব' : 'Entry'}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.mic, color: Colors.teal),
                    onPressed: () {
                      _simulateVoiceInput();
                      setSheetState(() {});
                    },
                    tooltip: widget.isBangla ? 'ভয়েস এন্ট্রি' : 'Voice Input',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: Center(child: Text(widget.isBangla ? 'খরচ (-)' : 'Expense (-)')),
                      selected: _isExpense,
                      selectedColor: Colors.red.shade100,
                      onSelected: (val) => setSheetState(() => _isExpense = true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: Center(child: Text(widget.isBangla ? 'জমা (+)' : 'Income (+)')),
                      selected: !_isExpense,
                      selectedColor: Colors.green.shade100,
                      onSelected: (val) => setSheetState(() => _isExpense = false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: widget.isBangla ? 'বিবরণ (যেমন: চাউল কেনা)' : 'Description',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '${widget.isBangla ? 'টাকার পরিমাণ' : 'Amount'} (${widget.currencySymbol})',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _addTransaction,
                  style: ElevatedButton.styleFrom(backgroundColor: widget.file.color),
                  child: Text(widget.isBangla ? 'সংরক্ষণ করুন (Hive/Firebase)' : 'Save Data', style: const TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.file.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: widget.file.color,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(widget.isBangla ? 'ডকুমেন্ট স্ক্যানার চালু হচ্ছে...' : 'Doc Scanner Opening...')),
              );
            },
            tooltip: 'Doc Scanner',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(widget.isBangla ? 'দৈনিক হিসাবের রিমাইন্ডার সেট করা হয়েছে।' : 'Reminder set for daily updates.')),
              );
            },
            tooltip: 'Reminder Notification',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: widget.file.color.withOpacity(0.08),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(widget.isBangla ? 'মোট জমা' : 'Total Income', style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text('${widget.currencySymbol}${widget.file.totalIncome.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
                Container(height: 30, width: 1, color: Colors.grey.shade400),
                Column(
                  children: [
                    Text(widget.isBangla ? 'মোট খরচ' : 'Total Expense', style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text('${widget.currencySymbol}${widget.file.totalExpense.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: widget.file.transactions.isEmpty
                ? Center(child: Text(widget.isBangla ? 'কোনো হিসাব নেই!' : 'No Data Saved!'))
                : ListView.builder(
                    itemCount: widget.file.transactions.length,
                    itemBuilder: (context, index) {
                      final item = widget.file.transactions[index];
                      return ListTile(
                        leading: Icon(item.isExpense ? Icons.arrow_downward : Icons.arrow_upward, color: item.isExpense ? Colors.red : Colors.green),
                        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(DateFormat('dd/MM/yyyy - hh:mm a').format(item.date)),
                        trailing: Text('${item.isExpense ? '-' : '+'} ${widget.currencySymbol}${item.amount.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, color: item.isExpense ? Colors.red : Colors.green)),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionSheet,
        backgroundColor: widget.file.color,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
```eof
