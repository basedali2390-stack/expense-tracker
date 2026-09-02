import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

// ==============================================================================
// অ্যাপের প্রাথমিক নাম ও লোগোর লিংক
// ==============================================================================
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

// ------------------------------------------------------------------------------
// PIN SCREEN
// ------------------------------------------------------------------------------
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
            Image.network(logoUrl, height: 80, errorBuilder: (_, __, ___) => const Icon(Icons.account_balance_wallet, size: 80)),
            const SizedBox(height: 16),
            Text(appTitle, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text(widget.isBengali ? 'পিন নম্বর দিন (ডিফল্ট: 1234)' : 'Enter PIN (Default: 1234)'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) => Container(
                margin: const EdgeInsets.all(4),
                width: 16, height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < pin.length ? Colors.blue : Colors.grey.shade300,
                ),
              )),
            ),
            const SizedBox(height: 20),
            for (var row in [['1', '2', '3'], ['4', '5', '6'], ['7', '8', '9']])
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: row.map((num) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () => _onKeyPress(num),
                    style: ElevatedButton.styleFrom(shape: const CircleBorder(), padding: const EdgeInsets.all(20)),
                    child: Text(num, style: const TextStyle(fontSize: 20)),
                  ),
                )).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------------------
// HOME SCREEN WITH VOICE INPUT
// ------------------------------------------------------------------------------
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
  final List<Map<String, dynamic>> _transactions = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool _isIncome = false;

  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listenVoice() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _titleController.text = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _addTransaction() {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (title.isEmpty || amount <= 0) return;

    setState(() {
      _transactions.add({
        'title': title,
        'amount': amount,
        'isIncome': _isIncome,
        'date': DateTime.now(),
      });
    });
    _titleController.clear();
    _amountController.clear();
    Navigator.pop(context);
  }

  double get _totalIncome => _transactions.where((t) => t['isIncome']).fold(0.0, (sum, item) => sum + item['amount']);
  double get _totalExpense => _transactions.where((t) => !t['isIncome']).fold(0.0, (sum, item) => sum + item['amount']);

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 16, left: 16, right: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.isBengali ? 'নতুন হিসাব যোগ করুন' : 'Add New Record', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: widget.isBengali ? 'বিবরণ (বা মাইকে বলুন)' : 'Title (or use Mic)',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.red : Colors.blue),
                  onPressed: _listenVoice,
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: widget.isBengali ? 'পরিমাণ (${widget.currency})' : 'Amount (${widget.currency})',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: Text(widget.isBengali ? 'খরচ' : 'Expense'),
                    selected: !_isIncome,
                    onSelected: (val) => setState(() => _isIncome = !val),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: Text(widget.isBengali ? 'জমা / আয়' : 'Income'),
                    selected: _isIncome,
                    onSelected: (val) => setState(() => _isIncome = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addTransaction,
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(45)),
              child: Text(widget.isBengali ? 'সংরক্ষণ করুন' : 'Save Record'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.network(logoUrl, height: 32, errorBuilder: (_, __, ___) => const Icon(Icons.account_balance_wallet)),
            const SizedBox(width: 8),
            Text(appTitle),
          ],
        ),
        actions: [
          IconButton(icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode), onPressed: widget.onThemeToggle),
          IconButton(icon: const Icon(Icons.language), onPressed: widget.onLangToggle),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: widget.isDarkMode ? Colors.grey[900] : Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryCard(widget.isBengali ? 'মোট আয়' : 'Income', _totalIncome, Colors.green),
                _buildSummaryCard(widget.isBengali ? 'মোট খরচ' : 'Expense', _totalExpense, Colors.red),
                _buildSummaryCard(widget.isBengali ? 'অবশিষ্ট' : 'Balance', _totalIncome - _totalExpense, Colors.blue),
              ],
            ),
          ),
          Expanded(
            child: _transactions.isEmpty
                ? Center(child: Text(widget.isBengali ? 'কোনো হিসাব পাওয়া যায়নি' : 'No Transactions Recorded'))
                : ListView.builder(
                    itemCount: _transactions.length,
                    itemBuilder: (_, index) {
                      final item = _transactions[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: item['isIncome'] ? Colors.green.shade100 : Colors.red.shade100,
                          child: Icon(item['isIncome'] ? Icons.arrow_downward : Icons.arrow_upward, color: item['isIncome'] ? Colors.green : Colors.red),
                        ),
                        title: Text(item['title']),
                        subtitle: Text('${item['date'].day}/${item['date'].month}/${item['date'].year}'),
                        trailing: Text(
                          '${item['isIncome'] ? '+' : '-'}${widget.currency}${item['amount']}',
                          style: TextStyle(fontWeight: FontWeight.bold, color: item['isIncome'] ? Colors.green : Colors.red),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 4),
        Text('${widget.currency}${amount.toStringAsFixed(1)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

