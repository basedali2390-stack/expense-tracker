import 'package:flutter/material.dart';

void main() {
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'আমার হিসাব খাতা',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// ট্রানজেকশন (হিসাব) মডেল
class TransactionModel {
  final String title;
  final double amount;
  final bool isExpense;
  final DateTime date;

  TransactionModel({
    required this.title,
    required this.amount,
    required this.isExpense,
    required this.date,
  });
}

// ফাইল/ক্যাটাগরি মডেল
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
    return transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalIncome {
    return transactions
        .where((t) => !t.isExpense)
        .fold(0.0, (sum, item) => sum + item.amount);
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ইউজারদের তৈরি করা ফাইলগুলো এখানে জমা থাকবে (শুরুতে খালি থাকবে)
  final List<ExpenseFile> userFiles = [];

  // র‍্যান্ডম কালার সিলেক্টর
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

  void _deleteFile(int index) {
    setState(() {
      userFiles.removeAt(index);
    });
  }

  void _showAddFileDialog() {
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'নতুন ফাইল তৈরি করুন',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'আপনার ফাইলের নাম লিখুন (যেমন: বাজার খরচ, বাড়ির খরচ, দোকান খরচ):',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: titleController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'ফাইলের নাম লিখুন...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                _addNewFile(titleController.text.trim());
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade700,
            ),
            child: const Text('তৈরি করুন', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'আমার হিসাব ফাইলসমূহ',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.teal.shade700,
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.create_new_folder, color: Colors.teal, size: 30),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'নিচের "+ নতুন ফাইল তৈরি করুন" বাটনে চাপ দিয়ে আপনার ইচ্ছেমতো ফাইল বানান।',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'আপনার তৈরি ফাইলসমূহ:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'মোট: ${userFiles.length}টি',
                  style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: userFiles.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_open_rounded,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'এখনো কোনো ফাইল তৈরি করা হয়নি!\nনিচের বাটন চেপে নতুন ফাইল তৈরি করুন।',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
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
                                builder: (context) => FileDetailScreen(file: file),
                              ),
                            ).then((_) => setState(() {}));
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: file.color.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Stack(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 26,
                                      backgroundColor: file.color.withOpacity(0.15),
                                      child: Icon(
                                        Icons.folder_rounded,
                                        color: file.color,
                                        size: 30,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      file.title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade800,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'খরচ: ৳${file.totalExpense.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.red.shade600,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('ফাইল ডিলিট করবেন?'),
                                          content: Text('আপনি কি সত্যিই "${file.title}" ফাইলটি মুছে ফেলতে চান?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx),
                                              child: const Text('না'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                _deleteFile(index);
                                                Navigator.pop(ctx);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                              ),
                                              child: const Text('হ্যাঁ', style: TextStyle(color: Colors.white)),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddFileDialog,
        backgroundColor: Colors.teal.shade700,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'নতুন ফাইল তৈরি করুন',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ফাইলের ভেতরে ঢুকে হিসাব যুক্ত করার স্ক্রিন
class FileDetailScreen extends StatefulWidget {
  final ExpenseFile file;

  const FileDetailScreen({super.key, required this.file});

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

  void _showAddTransactionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'হিসাব যোগ করুন (${widget.file.title})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('খরচ (-)')),
                      selected: _isExpense,
                      selectedColor: Colors.red.shade100,
                      onSelected: (val) {
                        setSheetState(() => _isExpense = true);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('জমা (+)')),
                      selected: !_isExpense,
                      selectedColor: Colors.green.shade100,
                      onSelected: (val) {
                        setSheetState(() => _isExpense = false);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'বিবরণ (যেমন: চাল কেনা / বেতন)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'টাকার পরিমাণ (৳)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _addTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.file.color,
                  ),
                  child: const Text(
                    'সংরক্ষণ করুন',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
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
      ),
      body: Column(
        children: [
          // সামারি কার্ড
          Container(
            padding: const EdgeInsets.all(20),
            color: widget.file.color.withOpacity(0.08),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('মোট জমা', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(
                      '৳${widget.file.totalIncome.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                Container(height: 30, width: 1, color: Colors.grey.shade400),
                Column(
                  children: [
                    const Text('মোট খরচ', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(
                      '৳${widget.file.totalExpense.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // ট্রানজেকশন লিস্ট
          Expanded(
            child: widget.file.transactions.isEmpty
                ? const Center(
                    child: Text(
                      'এখনো কোনো হিসাব যোগ করা হয়নি।\nনিচের + বাটনে চাপ দিয়ে যোগ করুন।',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  )
                : ListView.builder(
                    itemCount: widget.file.transactions.length,
                    itemBuilder: (context, index) {
                      final item = widget.file.transactions[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: item.isExpense
                                ? Colors.red.shade50
                                : Colors.green.shade50,
                            child: Icon(
                              item.isExpense
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: item.isExpense ? Colors.red : Colors.green,
                            ),
                          ),
                          title: Text(
                            item.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${item.date.day}/${item.date.month}/${item.date.year}',
                          ),
                          trailing: Text(
                            '${item.isExpense ? '-' : '+'} ৳${item.amount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: item.isExpense ? Colors.red : Colors.green,
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
        onPressed: _showAddTransactionSheet,
        backgroundColor: widget.file.color,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
```eof

### অ্যাপে কী পরিবর্তন করা হয়েছে:
১. **ইউজারদের স্বাধীনতা:** অ্যাপ ওপেন করলে তারা একদম পরিষ্কার ইন্টারফেস দেখবে। নিচে একটি **"+ নতুন ফাইল তৈরি করুন"** বাটন থাকবে।  
২. **পছন্দমতো ফাইলের নাম:** প্লাস বাটনে চাপ দিলে একটি পপআপ আসবে যেখানে ইউজার তার ইচ্ছামতো নাম (যেমন: *বাজার খরচ*, *ঘরের কাজ*, *দোকান*, ইত্যাদি) দিয়ে ফাইল বানিয়ে নিতে পারবে।  
৩. **ফাইল ম্যানেজমেন্ট:** প্রতিটি ফাইলের সাথে ডিলিট (Trash/Delete) অপশন রাখা হয়েছে, যাতে কোনো ফাইল ভুল করে বানানো হলে সেটা মুছে ফেলা যায়।  
৪. **ফায়ারের ভেতরে জমা-খরচ:** ফাইল বানিয়ে সেটার ওপর চাপ দিলে তার ভেতরে ঢুকে স্বাধীনভাবে জমা বা খরচের হিসাব রাখা যাবে।
