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
      title: 'স্মার্ট হিসাব',
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

// ------------------- PIN SCREEN -------------------
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
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, size: 70, color: Colors.teal),
            const SizedBox(height: 20),
            Text(
              widget.isBengali ? 'পিন কোড দিন (ডিফল্ট: 1234)' : 'Enter PIN (Default: 1234)',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                4,
                (i) => Container(
                  margin: const EdgeInsets.all(8),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < pin.length ? Colors.teal : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            GridView.builder(
              shrinkWrap: true,
              itemCount: 9,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 2),
              itemBuilder: (ctx, i) => TextButton(
                onPressed: () => _onKeyPress('${i + 1}'),
                child: Text('${i + 1}', style: const TextStyle(fontSize: 22)),
              ),
            ),
            TextButton(
              onPressed: () => _onKeyPress('0'),
              child: const Text('0', style: TextStyle(fontSize: 22)),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------- MODEL -------------------
class Transaction {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final bool isIncome;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.isIncome,
  });
}

// ------------------- HOME SCREEN -------------------
class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final bool isBengali;
  final bool isVipUser;
  final String currency;
  final VoidCallback onThemeToggle;
  final VoidCallback onLangToggle;
  final VoidCallback onVipUpgrade;
  final Function(String) onCurrencyChange;

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

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Transaction> _transactions = [];

  double get totalIncome =>
      _transactions.where((t) => t.isIncome).fold(0.0, (sum, item) => sum + item.amount);

  double get totalExpense =>
      _transactions.where((t) => !t.isIncome).fold(0.0, (sum, item) => sum + item.amount);

  void _addTransaction(String title, double amount, String category, bool isIncome) {
    setState(() {
      _transactions.add(Transaction(
        id: DateTime.now().toString(),
        title: title,
        amount: amount,
        category: category,
        date: DateTime.now(),
        isIncome: isIncome,
      ));
    });
  }

  void _showAddModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddTransactionModal(
        onAdd: _addTransaction,
        isBengali: widget.isBengali,
        currency: widget.currency,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isBengali ? 'স্মার্ট হিসাব' : 'Smart Hisab'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onThemeToggle,
          ),
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: widget.onLangToggle,
          ),
        ],
      ),
      drawer: NavigationDrawer(
        isBengali: widget.isBengali,
        isVipUser: widget.isVipUser,
        currency: widget.currency,
        onVipUpgrade: widget.onVipUpgrade,
        onCurrencyChange: widget.onCurrencyChange,
      ),
      body: Column(
        children: [
          // Banner Ad Demo
          if (!widget.isVipUser)
            Container(
              color: Colors.amber.shade200,
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              child: Text(
                widget.isBengali ? 'বিজ্ঞাপন: VIP কিনে অ্যাড ফ্রি করুন' : 'Ad: Upgrade to VIP to remove ads',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black87),
              ),
            ),
          
          // Balance Overview Card
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    widget.isBengali ? 'মোট ব্যালেন্স' : 'Total Balance',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${widget.currency} ${(totalIncome - totalExpense).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: (totalIncome - totalExpense) >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  const Divider(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _balanceItem(widget.isBengali ? 'আয়' : 'Income', totalIncome, Colors.green, widget.currency),
                      _balanceItem(widget.isBengali ? 'ব্যয়' : 'Expense', totalExpense, Colors.red, widget.currency),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Feature Grid Shortcuts
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _featureShortcut(Icons.mic, widget.isBengali ? 'ভয়েস' : 'Voice', () => _showVoiceInput(context)),
                _featureShortcut(Icons.document_scanner, widget.isBengali ? 'স্ক্যান' : 'Scan', () => _showDocScanner(context)),
                _featureShortcut(Icons.alarm, widget.isBengali ? 'অ্যালার্ম' : 'Alarm', () => _showAlarmDialog(context)),
                _featureShortcut(Icons.cloud_upload, widget.isBengali ? 'ব্যাকআপ' : 'Backup', () => _showBackupDialog(context)),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Transaction List
          Expanded(
            child: _transactions.isEmpty
                ? Center(
                    child: Text(
                      widget.isBengali ? 'কোন লেনদেন যুক্ত করা হয়নি' : 'No transactions added yet',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _transactions.length,
                    itemBuilder: (ctx, i) {
                      final t = _transactions[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: t.isIncome ? Colors.green.shade100 : Colors.red.shade100,
                          child: Icon(
                            t.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                            color: t.isIncome ? Colors.green : Colors.red,
                          ),
                        ),
                        title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${t.category} • ${t.date.day}/${t.date.month}/${t.date.year}'),
                        trailing: Text(
                          '${t.isIncome ? '+' : '-'} ${widget.currency}${t.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: t.isIncome ? Colors.green : Colors.red,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddModal(context),
        label: Text(widget.isBengali ? 'হিসাব লিখুন' : 'Add Record'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }

  Widget _balanceItem(String title, double amount, Color color, String currency) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('$currency ${amount.toStringAsFixed(2)}', style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _featureShortcut(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CircleAvatar(backgroundColor: Colors.teal.shade50, child: Icon(icon, color: Colors.teal)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _showVoiceInput(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(widget.isBengali ? 'ভয়েস ইনপুট' : 'Voice Input'),
        content: Text(widget.isBengali ? 'কথা বলুন... (যেমন: ৫০০ টাকা বাজারে খরচ)' : 'Speak now... (e.g. Spent 500 on market)'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _addTransaction(widget.isBengali ? 'ভয়েস এনট্রি' : 'Voice Entry', 500.0, 'General', false);
            },
            child: Text(widget.isBengali ? 'টেস্ট যুক্ত করুন' : 'Add Test Entry'),
          )
        ],
      ),
    );
  }

  void _showDocScanner(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(widget.isBengali ? 'ডকুমেন্ট স্ক্যানার' : 'Document Scanner'),
        content: Text(widget.isBengali ? 'মেমো বা রসিদের ছবি তুলুন' : 'Scan Memo or Receipt'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(widget.isBengali ? 'বন্ধ করুন' : 'Close'),
          )
        ],
      ),
    );
  }

  void _showAlarmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(widget.isBengali ? 'ডেইলি রিমাইন্ডার' : 'Daily Alarm'),
        content: Text(widget.isBengali ? 'প্রতিদিন রাত ৯টায় রিমাইন্ডার সেট করা হয়েছে' : 'Reminder set for 9:00 PM daily'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(widget.isBengali ? 'ওকে' : 'OK'),
          )
        ],
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(widget.isBengali ? 'ক্লাউড ব্যাকআপ' : 'Cloud Backup'),
        content: Text(widget.isBengali ? 'আপনার ডেটা সফলভাবে ক্লাউডে ব্যাকআপ নেওয়া হয়েছে।' : 'Data successfully backed up to cloud.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(widget.isBengali ? 'ঠিক আছে' : 'OK'),
          )
        ],
      ),
    );
  }
}

// ------------------- ADD TRANSACTION MODAL -------------------
class AddTransactionModal extends StatefulWidget {
  final Function(String, double, String, bool) onAdd;
  final bool isBengali;
  final String currency;

  const AddTransactionModal({
    super.key,
    required this.onAdd,
    required this.isBengali,
    required this.currency,
  });

  @override
  State<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _category = 'খাবার';
  bool _isIncome = false;

  final List<String> _categories = ['খাবার', 'বাজার', 'বিল', 'বেতন', 'অন্যান্য'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 16,
        right: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.isBengali ? 'নতুন হিসাব লিখুন' : 'Add New Record',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: Text(widget.isBengali ? 'ব্যয়' : 'Expense'),
                selected: !_isIncome,
                onSelected: (val) => setState(() => _isIncome = !val),
              ),
              const SizedBox(width: 10),
              ChoiceChip(
                label: Text(widget.isBengali ? 'আয়' : 'Income'),
                selected: _isIncome,
                onSelected: (val) => setState(() => _isIncome = val),
              ),
            ],
          ),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: widget.isBengali ? 'বিবরণ' : 'Title'),
          ),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: widget.isBengali ? 'পরিমাণ' : 'Amount',
              prefixText: '${widget.currency} ',
            ),
          ),
          const SizedBox(height: 10),
          DropdownButton<String>(
            value: _category,
            isExpanded: true,
            items: _categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _category = val);
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () {
              if (_titleController.text.isEmpty || _amountController.text.isEmpty) return;
              widget.onAdd(
                _titleController.text,
                double.parse(_amountController.text),
                _category,
                _isIncome,
              );
              Navigator.pop(context);
            },
            child: Text(widget.isBengali ? 'সংরক্ষণ করুন' : 'Save Record', style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ------------------- NAVIGATION DRAWER & VIP -------------------
class NavigationDrawer extends StatelessWidget {
  final bool isBengali;
  final bool isVipUser;
  final String currency;
  final VoidCallback onVipUpgrade;
  final Function(String) onCurrencyChange;

  const NavigationDrawer({
    super.key,
    required this.isBengali,
    required this.isVipUser,
    required this.currency,
    required this.onVipUpgrade,
    required this.onCurrencyChange,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.teal),
            accountName: Text(isBengali ? 'ইউজার নাম' : 'User Name'),
            accountEmail: Text(isVipUser ? 'VIP Member 👑' : 'Free User'),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.teal),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.star, color: Colors.amber),
            title: Text(isBengali ? 'VIP মেম্বারশিপ' : 'VIP Membership'),
            subtitle: Text(isVipUser ? (isBengali ? 'সক্রিয় আছে' : 'Active') : (isBengali ? 'অ্যাডস মুক্ত করুন' : 'Remove Ads')),
            onPressed: () {
              Navigator.pop(context);
              _showVipDialog(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.currency_exchange),
            title: Text(isBengali ? 'কারেন্সি পরিবর্তন' : 'Change Currency'),
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
        ],
      ),
    );
  }

  void _showVipDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isBengali ? 'VIP প্ল্যান নির্বাচন করুন' : 'Choose VIP Plan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _paymentPackageCard(
              context: ctx,
              title: isBengali ? '১ মাস - ৳৯৯ / ₹৯৯' : '1 Month - \$0.99',
              subTitle: isBengali ? 'সকল অ্যাড বন্ধ ও ব্যাকআপ' : 'No Ads + Backup',
              onSuccess: onVipUpgrade,
            ),
            const SizedBox(height: 10),
            _paymentPackageCard(
              context: ctx,
              title: isBengali ? 'লাইফটাইম - ৳৪৯৯ / ₹৪৯৯' : 'Lifetime - \$4.99',
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
                content: Text(isBengali
                    ? 'পেমেন্ট সফল হয়েছে! আপনি এখন VIP ইউজার।'
                    : 'Payment Successful! VIP Activated.'),
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
}
