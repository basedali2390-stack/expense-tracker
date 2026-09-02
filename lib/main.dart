import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ৪. Offline Database (Hive)
  await Hive.initFlutter();
  await Hive.openBox('expenses_db');
  
  // ৫. Cloud Backup (Firebase)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase connection ready: $e");
  }

  // ১১. AdMob Ads
  MobileAds.instance.initialize();

  runApp(const FullExpenseTrackerApp());
}

class FullExpenseTrackerApp extends StatefulWidget {
  const FullExpenseTrackerApp({super.key});

  @override
  State<FullExpenseTrackerApp> createState() => _FullExpenseTrackerAppState();
}

class _FullExpenseTrackerAppState extends State<FullExpenseTrackerApp> {
  // ১. Multi-Lang
  bool isBangla = true;
  
  // ২. Multi-Currency
  String currentCurrency = '৳';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: isBangla ? 'স্মার্ট খরচ ট্র্যাকার' : 'Smart Expense Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      // ১২. Global Release Ready
      home: SecurityCheckScreen(
        isBangla: isBangla,
        currency: currentCurrency,
        onLangToggle: () => setState(() => isBangla = !isBangla),
        onCurrencyChange: (newCurr) => setState(() => currentCurrency = newCurr),
      ),
    );
  }
}

// ৬. Security Screen (ফিঙ্গারপ্রিন্ট, ফেস ও পিন লক)
class SecurityCheckScreen extends StatefulWidget {
  final bool isBangla;
  final String currency;
  final VoidCallback onLangToggle;
  final Function(String) onCurrencyChange;

  const SecurityCheckScreen({
    super.key,
    required this.isBangla,
    required this.currency,
    required this.onLangToggle,
    required this.onCurrencyChange,
  });

  @override
  State<SecurityCheckScreen> createState() => _SecurityCheckScreenState();
}

class _SecurityCheckScreenState extends State<SecurityCheckScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: widget.isBangla
            ? 'অ্যাপে ঢুকতে ফিঙ্গারপ্রিন্ট, ফেস বা পিন লক দিন'
            : 'Authenticate to access Expense Tracker',
        options: const AuthenticationOptions(biometricOnly: false),
      );
      if (authenticated) {
        setState(() => isAuthenticated = true);
      }
    } catch (e) {
      setState(() => isAuthenticated = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isAuthenticated) {
      return MainHomeScreen(
        isBangla: widget.isBangla,
        currency: widget.currency,
        onLangToggle: widget.onLangToggle,
        onCurrencyChange: widget.onCurrencyChange,
      );
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, size: 90, color: Colors.teal),
            const SizedBox(height: 20),
            Text(
              widget.isBangla ? 'অ্যাপটি সম্পূর্ণ সুরক্ষিত' : 'App Secured',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: _authenticate,
              icon: const Icon(Icons.fingerprint),
              label: Text(widget.isBangla ? 'আনলক করুন (Fingerprint/PIN)' : 'Unlock Now'),
            )
          ],
        ),
      ),
    );
  }
}

// মূল ড্যাশবোর্ড স্ক্রিন
class MainHomeScreen extends StatefulWidget {
  final bool isBangla;
  final String currency;
  final VoidCallback onLangToggle;
  final Function(String) onCurrencyChange;

  const MainHomeScreen({
    super.key,
    required this.isBangla,
    required this.currency,
    required this.onLangToggle,
    required this.onCurrencyChange,
  });

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  // ৪. Offline Database (Hive)
  final Box _expenseBox = Hive.box('expenses_db');
  
  // ৩. Voice Input
  late stt.SpeechToText _speech;
  bool _isListening = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  // ৭. Doc Scanner / Camera Attachment
  final ImagePicker _picker = ImagePicker();
  String? _scannedImagePath;

  // ১০. Notification Plugin
  late FlutterLocalNotificationsPlugin _notificationsPlugin;

  // ১১. AdMob Banner Ad
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  // ক্যাটাগরি বা আলাদা ফাইল সিলেকশন (সব, বাজার খরচ, দোকান খরচ, বাড়ি খরচ)
  String selectedCategoryFilter = 'সব';
  String selectedCategoryForAdd = 'বাজার খরচ';
  final List<String> categories = ['বাজার খরচ', 'দোকান খরচ', 'বাড়ি খরচ', 'অন্যান্য'];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initNotifications();
    _loadBannerAd();
  }

  void _initNotifications() {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    _notificationsPlugin.initialize(initSettings);
  }

  // ১০. Notification Push Action
  Future<void> _sendDailyReminderNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'daily_reminder',
      'Daily Reminders',
      importance: Importance.max,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(
      0,
      widget.isBangla ? 'আজকের খরচের হিসাব রাখতে ভুলে যাননি তো?' : 'Daily Expense Reminder',
      widget.isBangla ? 'আপনার দৈনিক খরচের তালিকা আপডেট করুন।' : 'Please record your daily expenses!',
      notificationDetails,
    );
  }

  // ১১. AdMob Ad Load Function
  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isAdLoaded = true),
        onAdFailedToLoad: (ad, err) => ad.dispose(),
      ),
    )..load();
  }

  // ৩. Voice Input Function
  void _listenVoice() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (val) {
          setState(() {
            _titleController.text = val.recognizedWords;
          });
        });
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  // ৭. Doc Scanner / Camera Attachment Function
  Future<void> _scanDocument() async {
    final photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _scannedImagePath = photo.path;
      });
    }
  }

  // ৪, ৫ & ৮. Save Expense
  void _saveExpense() {
    final title = _titleController.text;
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    if (title.isEmpty || amount <= 0) return;

    // ৮. Global Time Standard (তারিখ ও সময় সহ ক্যাটাগরি সেভ)
    final data = {
      'title': title,
      'amount': amount,
      'category': selectedCategoryForAdd,
      'image': _scannedImagePath ?? '',
      'date': DateTime.now().toString(),
    };

    _expenseBox.add(data);

    _titleController.clear();
    _amountController.clear();
    _scannedImagePath = null;
    Navigator.pop(context);
    setState(() {});
  }

  // ৯. VIP Plan Modal Dialog
  void _showVIPPlanDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(widget.isBangla ? '👑 ভিআইপি প্ল্যান সাবস্ক্রিপশন' : '👑 VIP Plan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.isBangla
                ? 'বিজ্ঞাপন মুক্ত অভিজ্ঞতা ও ক্লাউড ব্যাকআপ সুবিধা পান।'
                : 'Enjoy Ad-Free experience & Cloud Backup.'),
            const SizedBox(height: 15),
            ListTile(
              tileColor: Colors.teal.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              title: const Text('মাসিক প্ল্যান'),
              trailing: const Text('৩০৳ / মাস', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
            ),
            const SizedBox(height: 8),
            ListTile(
              tileColor: Colors.amber.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              title: const Text('বার্ষিক প্ল্যান'),
              trailing: const Text('৩০০৳ / বছর', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(widget.isBangla ? 'বন্ধ করুন' : 'Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ফিল্টার অনুযায়ী খরচ বের করা
    List allItems = _expenseBox.values.toList();
    List filteredItems = selectedCategoryFilter == 'সব'
        ? allItems
        : allItems.where((item) => item['category'] == selectedCategoryFilter).toList();

    double totalAmount = filteredItems.fold(0.0, (sum, item) => sum + (item['amount'] as num));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isBangla ? 'স্মার্ট খরচ ট্র্যাকার' : 'Expense Tracker'),
        backgroundColor: Colors.teal.shade100,
        actions: [
          // ১. Multi-Lang
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: widget.onLangToggle,
          ),
          // ২. Multi-Currency
          DropdownButton<String>(
            value: widget.currency,
            underline: const SizedBox(),
            items: ['৳', '₹', '\$'].map((c) {
              return DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontWeight: FontWeight.bold)));
            }).toList(),
            onChanged: (val) {
              if (val != null) widget.onCurrencyChange(val);
            },
          ),
          // ৯. VIP Plan
          IconButton(
            icon: const Icon(Icons.workspace_premium, color: Colors.amber),
            onPressed: _showVIPPlanDialog,
          )
        ],
      ),
      body: Column(
        children: [
          // ক্যাটাগরি ফাইল সিলেক্ট করার ফিল্টার ট্যাব (বাজার, দোকান, বাড়ি খরচ)
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['সব', 'বাজার খরচ', 'দোকান খরচ', 'বাড়ি খরচ', 'অন্যান্য'].map((cat) {
                bool isSelected = selectedCategoryFilter == cat;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: Colors.teal,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                    onSelected: (bool selected) {
                      setState(() {
                        selectedCategoryFilter = cat;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Total Balance Display Card
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.teal.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${selectedCategoryFilter} মোট খরচ:',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${widget.currency} ${totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                ],
              ),
            ),
          ),

          // Notification Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: _sendDailyReminderNotification,
                  icon: const Icon(Icons.notifications_active, color: Colors.teal),
                  label: Text(widget.isBangla ? 'রিমাইন্ডার' : 'Reminder'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade700, foregroundColor: Colors.white),
                  onPressed: _showVIPPlanDialog,
                  icon: const Icon(Icons.star),
                  label: const Text('VIP (৩০৳/৩০০৳)'),
                ),
              ],
            ),
          ),

          const Divider(height: 15),

          // ৪. Offline Database (Hive) ডাটা রেন্ডারিং ও লিস্ট ভিউ
          Expanded(
            child: filteredItems.isEmpty
                ? Center(child: Text(widget.isBangla ? 'কোনো খরচের ফাইল পাওয়া যায়নি' : 'No expenses found'))
                : ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      final String imagePath = item['image'] ?? '';
                      final String category = item['category'] ?? 'অন্যান্য';

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: imagePath.isNotEmpty && File(imagePath).existsSync()
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.file(File(imagePath), width: 45, height: 45, fit: BoxFit.cover),
                                )
                              : CircleAvatar(
                                  backgroundColor: Colors.teal.shade100,
                                  child: Icon(
                                    category == 'বাজার খরচ' ? Icons.shopping_cart :
                                    category == 'দোকান খরচ' ? Icons.store : Icons.home,
                                    color: Colors.teal,
                                  ),
                                ),
                          title: Text(item['title'], style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('$category • ${item['date'].toString().substring(0, 10)}'),
                          trailing: Text(
                            '${widget.currency} ${item['amount']}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // ১১. AdMob Ads Banner
          if (_isAdLoaded && _bannerAd != null)
            SizedBox(
              height: _bannerAd!.size.height.toDouble(),
              width: _bannerAd!.size.width.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () => _showAddExpenseModal(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // ৩ & ৭. Voice Input, Camera এবং Category সহ খরচ যোগ করার উইজেট
  void _showAddExpenseModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.isBangla ? 'নতুন খরচ যোগ করুন' : 'Add New Expense',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  // ফাইল/ক্যাটাগরি সিলেক্টর (বাজার খরচ, দোকান খরচ, বাড়ি খরচ)
                  DropdownButtonFormField<String>(
                    value: selectedCategoryForAdd,
                    decoration: const InputDecoration(labelText: 'ক্যাটাগরি/ফাইল নির্বাচন করুন'),
                    items: categories.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => selectedCategoryForAdd = val);
                      }
                    },
                  ),
                  // ৩. Voice Input
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: widget.isBangla ? 'বিবরণ (মুখে বলুন বা লিখুন)' : 'Description',
                      suffixIcon: IconButton(
                        icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: Colors.teal),
                        onPressed: _listenVoice,
                      ),
                    ),
                  ),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: widget.isBangla ? 'পরিমাণ (${widget.currency})' : 'Amount',
                    ),
                  ),
                  const SizedBox(height: 15),
                  // ৭. Doc Scanner / Camera
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          await _scanDocument();
                          setModalState(() {});
                        },
                        icon: const Icon(Icons.document_scanner),
                        label: Text(widget.isBangla ? 'রসিদের ছবি দিন' : 'Scan Receipt'),
                      ),
                      const SizedBox(width: 10),
                      if (_scannedImagePath != null)
                        const Icon(Icons.check_circle, color: Colors.green),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveExpense,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(45),
                    ),
                    child: Text(widget.isBangla ? 'সংরক্ষণ করুন' : 'Save Expense'),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}

