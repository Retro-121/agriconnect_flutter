import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';
import '../provider_types.dart';
import 'api_config.dart';
import '../widgets/tile.dart';

class DashboardScreen extends StatefulWidget {
  final ProviderState provider;
  const DashboardScreen({super.key, required this.provider});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _language = 'English';
  String _activeTab = 'overview'; // active sub-panel

  // Weather state
  String _weatherTemp = '--';
  String _weatherDesc = 'Loading...';
  String _weatherLocation = 'Your Location';
  IconData _weatherIcon = Icons.wb_sunny;

  // Specialist State Lists
  List<Map<String, dynamic>> _specRequests = [];
  List<Map<String, dynamic>> _specAppointments = [];
  List<Map<String, dynamic>> _specTransactions = [];
  List<Map<String, dynamic>> _specReviews = [];
  List<Map<String, dynamic>> _specMessages = [];
  
  // Specialist Profile
  String _specCertifications = 'Certified Veterinary Surgeon (Tanzania Board)';
  String _specExperience = '8 Years';
  String _specPricing = 'TSH 0 / Session';
  String _specWorkingHours = '08:00 AM - 05:00 PM';

  // Product Provider State Lists
  List<Map<String, dynamic>> _prodOrders = [];
  List<Map<String, dynamic>> _prodInventory = [];
  List<Map<String, dynamic>> _prodDeliveries = [];
  List<Map<String, dynamic>> _prodCoupons = [];
  List<Map<String, dynamic>> _prodReviews = [];

  // Product Provider Profile
  String _prodStoreDescription = 'Your trusted agricultural inputs and feeds depot.';
  String _prodStoreHours = '07:30 AM - 06:00 PM';
  String _prodStoreRegions = 'Arusha, Kilimanjaro, Manyara';
  String _prodStorePhone = '+255 754 123 456';

  final TextEditingController _chatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAllData();
    _fetchWeather();
  }

  String t(String en, String sw) => _language == 'Kiswahili' ? sw : en;

  bool _isSeller(ProviderType type) {
    return type == ProviderType.feed ||
        type == ProviderType.seed ||
        type == ProviderType.fertilizer ||
        type == ProviderType.agrochem ||
        type == ProviderType.greenhouse ||
        type == ProviderType.equipment ||
        type == ProviderType.transport;
  }

  Future<void> _loadAllData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _language = prefs.getString('language') ?? 'English';
      
      // Load Specialist Profile Metadata
      _specCertifications = prefs.getString('spec_certs') ?? 'Certified Veterinary Surgeon (Tanzania Board)';
      _specExperience = prefs.getString('spec_exp') ?? '8 Years';
      _specPricing = prefs.getString('spec_price') ?? 'TSH 0 / Session';
      _specWorkingHours = prefs.getString('spec_hours') ?? '08:00 AM - 05:00 PM';

      // Load Product Provider Store Metadata
      _prodStoreDescription = prefs.getString('prod_desc') ?? 'Your trusted agricultural inputs and feeds depot.';
      _prodStoreHours = prefs.getString('prod_hours') ?? '07:30 AM - 06:00 PM';
      _prodStoreRegions = prefs.getString('prod_regions') ?? 'Arusha, Kilimanjaro, Manyara';
      _prodStorePhone = prefs.getString('prod_phone') ?? '+255 754 123 456';
    });

    // 1. Specialist Service Requests
    final reqsStr = prefs.getString('spec_requests');
    if (reqsStr != null) {
      _specRequests = List<Map<String, dynamic>>.from(json.decode(reqsStr));
    } else {
      _specRequests = [
        {
          'id': 'r1',
          'name': 'Mary Wanjiku',
          'category': t('Vaccination', 'Chanjo'),
          'service': 'Cow vaccination consultation',
          'datetime': 'Today · 10:30 AM',
          'urgency': 'medium',
          'type': 'Dairy Cow',
          'location': 'Kiambu',
          'status': 'pending',
          'phone': '0712345678'
        },
        {
          'id': 'r2',
          'name': 'John Otieno',
          'category': t('Diagnosis', 'Utambuzi'),
          'service': 'Poultry disease diagnosis',
          'datetime': 'Today · 02:00 PM',
          'urgency': 'critical',
          'type': 'Broiler Chickens',
          'location': 'Nakuru',
          'status': 'pending',
          'phone': '0722334455'
        },
        {
          'id': 'r3',
          'name': 'Grace Mumbi',
          'category': t('Guidance', 'Ushauri'),
          'service': 'Pig feeding guidance',
          'datetime': 'Tomorrow · 09:00 AM',
          'urgency': 'low',
          'type': 'Pigs',
          'location': 'Limuru',
          'status': 'pending',
          'phone': '0799887766'
        },
      ];
      _saveSpecRequests();
    }

    // 2. Specialist Appointments
    final apptsStr = prefs.getString('spec_appts');
    if (apptsStr != null) {
      _specAppointments = List<Map<String, dynamic>>.from(json.decode(apptsStr));
    } else {
      _specAppointments = [
        {
          'id': 'a1',
          'name': 'Joseph Kimani',
          'service': 'Mastitis Follow-up Visit',
          'type': 'Physical visit',
          'time': '11:00 AM',
          'status': 'confirmed'
        },
        {
          'id': 'a2',
          'name': 'Anna Mwangi',
          'service': 'Calving Complications Advice',
          'type': 'Video consultation',
          'time': '03:30 PM',
          'status': 'confirmed'
        },
      ];
      _saveSpecAppointments();
    }

    // 3. Specialist Transactions
    final txsStr = prefs.getString('spec_transactions');
    if (txsStr != null) {
      _specTransactions = List<Map<String, dynamic>>.from(json.decode(txsStr));
    } else {
      _specTransactions = [
        {'date': '19 May 2026', 'desc': t('Consultation Fee - Mary W.', 'Ada ya Ushauri - Mary W.'), 'amount': 'TSH 0', 'type': 'credit'},
        {'date': '18 May 2026', 'desc': t('Withdrawal to M-Pesa', 'Kutoa pesa kwenda M-Pesa'), 'amount': 'TSH 0', 'type': 'debit'},
        {'date': '17 May 2026', 'desc': t('Diagnosis - John O.', 'Utambuzi - John O.'), 'amount': 'TSH 0', 'type': 'credit'},
      ];
      _saveSpecTransactions();
    }

    // 4. Specialist Reviews
    final revsStr = prefs.getString('spec_reviews');
    if (revsStr != null) {
      _specReviews = List<Map<String, dynamic>>.from(json.decode(revsStr));
    } else {
      _specReviews = [
        {'name': 'James Nderitu', 'rating': 5, 'comment': 'Extremely helpful and saved my heifer!', 'reply': ''},
        {'name': 'Sarah Kemboi', 'rating': 4, 'comment': 'Good guidance on calf feeding.', 'reply': ''},
      ];
      _saveSpecReviews();
    }

    // 5. Specialist Chat messages
    final msgsStr = prefs.getString('spec_messages');
    if (msgsStr != null) {
      _specMessages = List<Map<String, dynamic>>.from(json.decode(msgsStr));
    } else {
      _specMessages = [
        {'sender': 'client', 'text': 'Hello Doctor, my cow is refusing to eat since morning.'},
        {'sender': 'doctor', 'text': 'Hello James, does she have a fever or high temperature?'},
        {'sender': 'client', 'text': 'Yes, her ears feel very warm and she is breathing quickly.'},
      ];
      _saveSpecMessages();
    }

    // 6. Product Provider Orders
    final ordersStr = prefs.getString('prod_orders');
    if (ordersStr != null) {
      _prodOrders = List<Map<String, dynamic>>.from(json.decode(ordersStr));
    } else {
      _prodOrders = [
        {
          'id': 'o1',
          'name': 'Mary Wanjiku',
          'products': 'Layers Feed (50kg)',
          'quantity': '10 bags',
          'status': 'Pending',
          'address': 'Kiambu Dairy Farm',
          'date': '19 May 2026',
          'phone': '0712345678'
        },
        {
          'id': 'o2',
          'name': 'Samuel Kibet',
          'products': 'NPK Fertilizer 17:17:17',
          'quantity': '5 bags',
          'status': 'Confirmed',
          'address': 'Eldoret North',
          'date': '18 May 2026',
          'phone': '0722334455'
        },
      ];
      _saveProdOrders();
    }

    // 7. Product Provider Inventory
    final invStr = prefs.getString('prod_inventory');
    if (invStr != null) {
      _prodInventory = List<Map<String, dynamic>>.from(json.decode(invStr));
    } else {
      _prodInventory = [
        {'id': 'i1', 'name': 'Layers Feed Premium', 'category': 'Feed', 'qty': 45, 'price': 'TSH 0', 'available': true},
        {'id': 'i2', 'name': 'Maize Seed Pioneer', 'category': 'Seed', 'qty': 8, 'price': 'TSH 0', 'available': true},
        {'id': 'i3', 'name': 'NPK 17:17:17 Fertilizer', 'category': 'Fertilizer', 'qty': 60, 'price': 'TSH 0', 'available': true},
      ];
      _saveProdInventory();
    }

    // 8. Product Provider Deliveries
    final delsStr = prefs.getString('prod_deliveries');
    if (delsStr != null) {
      _prodDeliveries = List<Map<String, dynamic>>.from(json.decode(delsStr));
    } else {
      _prodDeliveries = [
        {'id': 'd1', 'orderId': 'o2', 'driver': 'David Kamau', 'eta': '30 mins', 'status': 'Out for Delivery'},
        {'id': 'd2', 'orderId': 'o1', 'driver': 'Peter Omondi', 'eta': 'Tomorrow', 'status': 'Pending'},
      ];
      _saveProdDeliveries();
    }

    // 9. Product Coupons
    final couponsStr = prefs.getString('prod_coupons');
    if (couponsStr != null) {
      _prodCoupons = List<Map<String, dynamic>>.from(json.decode(couponsStr));
    } else {
      _prodCoupons = [
        {'code': 'AGRISPRING10', 'discount': '10%', 'status': 'Active'},
        {'code': 'FEEDBOOST5', 'discount': 'TSH 0', 'status': 'Active'},
      ];
      _saveProdCoupons();
    }

    // 10. Product Reviews
    final prodRevsStr = prefs.getString('prod_reviews');
    if (prodRevsStr != null) {
      _prodReviews = List<Map<String, dynamic>>.from(json.decode(prodRevsStr));
    } else {
      _prodReviews = [
        {'name': 'James Nderitu', 'rating': 5, 'comment': 'Fast feed delivery, highly recommended agrodealer.', 'reply': ''},
        {'name': 'Sarah Kemboi', 'rating': 4, 'comment': 'Maize seed quality is exceptional.', 'reply': ''},
      ];
      _saveProdReviews();
    }

    setState(() {});
  }

  // ── Spec State Savers ──
  Future<void> _saveSpecRequests() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('spec_requests', json.encode(_specRequests));
  }
  Future<void> _saveSpecAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('spec_appts', json.encode(_specAppointments));
  }
  Future<void> _saveSpecTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('spec_transactions', json.encode(_specTransactions));
  }
  Future<void> _saveSpecReviews() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('spec_reviews', json.encode(_specReviews));
  }
  Future<void> _saveSpecMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('spec_messages', json.encode(_specMessages));
  }

  // ── Seller State Savers ──
  Future<void> _saveProdOrders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('prod_orders', json.encode(_prodOrders));
  }
  Future<void> _saveProdInventory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('prod_inventory', json.encode(_prodInventory));
  }
  Future<void> _saveProdDeliveries() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('prod_deliveries', json.encode(_prodDeliveries));
  }
  Future<void> _saveProdCoupons() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('prod_coupons', json.encode(_prodCoupons));
  }
  Future<void> _saveProdReviews() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('prod_reviews', json.encode(_prodReviews));
  }

  Future<void> _fetchWeather() async {
    try {
      Position? position;
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
          position = await Geolocator.getCurrentPosition();
        }
      } catch (_) {}

      final apiKey = ApiConfig.weatherApiKey;
      final prefs = await SharedPreferences.getInstance();
      final savedLocation = prefs.getString('farmLocation') ?? 'Tanzania';
      final farmLat = prefs.getDouble('farmLat');
      final farmLon = prefs.getDouble('farmLon');
      
      String url;
      if (position != null) {
        url = 'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric';
      } else if (farmLat != null && farmLon != null) {
        url = 'https://api.openweathermap.org/data/2.5/weather?lat=$farmLat&lon=$farmLon&appid=$apiKey&units=metric';
      } else {
        url = 'https://api.openweathermap.org/data/2.5/weather?q=$savedLocation&appid=$apiKey&units=metric';
      }

      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (!mounted) return;
        setState(() {
          _weatherTemp = '${data['main']['temp'].round()}°';
          _weatherDesc = data['weather'][0]['description'].toString().toUpperCase();
          _weatherLocation = (farmLat != null && farmLon != null) 
              ? data['name'].toString().toUpperCase() 
              : savedLocation.toUpperCase();
          _weatherIcon = _getWeatherIcon(data['weather'][0]['main']);
        });
      }
    } catch (_) {}
  }

  IconData _getWeatherIcon(String mainCondition) {
    switch (mainCondition.toLowerCase()) {
      case 'clouds': return Icons.cloud;
      case 'rain': return Icons.umbrella;
      case 'clear': return Icons.wb_sunny;
      case 'snow': return Icons.ac_unit;
      case 'thunderstorm': return Icons.flash_on;
      default: return Icons.wb_cloudy;
    }
  }

  Future<void> _launchCommunication(String phone, String mode) async {
    final Uri url = Uri(scheme: mode, path: phone);
    try {
      await launchUrl(url);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t('Could not connect.', 'Imeshindikana kuunganisha.'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.provider.type;
    final isSeller = _isSeller(type);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Styled background
          Positioned.fill(
            child: Image.asset(
              isSeller ? 'assets/backgrounds/bg-suppliers-dark.jpg' : 'assets/backgrounds/bg-vets-dark.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.72))),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(isSeller),
                _buildSubNavBar(isSeller),
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    child: Container(
                      color: Theme.of(context).colorScheme.surface.withOpacity(0.94),
                      child: isSeller ? _buildSellerDashboard() : _buildSpecialistDashboard(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isSeller) {
    final p = widget.provider.info;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(p.icon, color: isSeller ? Colors.orangeAccent : leaf, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    t(p.label, isSeller ? 'Mtoa Bidhaa' : 'Mtaalamu wa Kilimo'),
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                t(p.tagline, 'Usimamizi wa shughuli za sasa na AI'),
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(12)),
            child: Text(
              _weatherTemp != '--' ? '$_weatherLocation $_weatherTemp' : t('Loading...', 'Inapakia...'),
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubNavBar(bool isSeller) {
    // List of tabs for each view
    final tabs = isSeller
        ? [
            {'id': 'overview', 'label': t('Overview', 'Muhtasari'), 'icon': Icons.dashboard_outlined},
            {'id': 'orders', 'label': t('Orders', 'Oda'), 'icon': Icons.shopping_basket_outlined},
            {'id': 'inventory', 'label': t('Inventory', 'Bidhaa'), 'icon': Icons.inventory_2_outlined},
            {'id': 'deliveries', 'label': t('Logistics', 'Usafirishaji'), 'icon': Icons.local_shipping_outlined},
            {'id': 'promos', 'label': t('Promotions', 'Matangazo'), 'icon': Icons.campaign_outlined},
            {'id': 'profile', 'label': t('Store Profile', 'Wasifu wa Duka'), 'icon': Icons.storefront_outlined},
          ]
        : [
            {'id': 'overview', 'label': t('Overview', 'Muhtasari'), 'icon': Icons.dashboard_outlined},
            {'id': 'requests', 'label': t('Requests', 'Maombi'), 'icon': Icons.pending_actions_outlined},
            {'id': 'appointments', 'label': t('Appointments', 'Miadi'), 'icon': Icons.calendar_today_outlined},
            {'id': 'communication', 'label': t('Chat', 'Soga'), 'icon': Icons.chat_bubble_outline},
            {'id': 'earnings', 'label': t('Earnings', 'Mapato'), 'icon': Icons.account_balance_wallet_outlined},
            {'id': 'reviews', 'label': t('Reviews', 'Mapitio'), 'icon': Icons.star_outline},
            {'id': 'profile', 'label': t('Profile', 'Wasifu'), 'icon': Icons.person_outline},
          ];

    final color = isSeller ? Colors.orangeAccent : leaf;
    
    // Arrange tabs in a grid (3 per row for better spacing)
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          direction: Axis.horizontal,
          children: List.generate(tabs.length, (index) {
            final tab = tabs[index];
            final isActive = _activeTab == tab['id'];
            return SizedBox(
              width: (MediaQuery.of(context).size.width - 40) / 3,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() => _activeTab = tab['id'] as String),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isActive 
                          ? color.withOpacity(0.2) 
                          : Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isActive ? color : Colors.transparent,
                        width: isActive ? 1.5 : 0,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tab['icon'] as IconData,
                          color: isActive ? color : Colors.white54,
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tab['label'] as String,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isActive ? Colors.white : Colors.white70,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── SECTION 1: AGRICULTURAL SPECIALIST DASHBOARD ──────────────────
  Widget _buildSpecialistDashboard() {
    return switch (_activeTab) {
      'requests' => _buildSpecRequestsPanel(),
      'appointments' => _buildSpecAppointmentsPanel(),
      'communication' => _buildSpecCommunicationCenter(),
      'earnings' => _buildSpecEarningsPanel(),
      'reviews' => _buildSpecReviewsPanel(),
      'profile' => _buildSpecProfilePanel(),
      _ => _buildSpecOverviewPanel(),
    };
  }

  Widget _buildSpecOverviewPanel() {
    final pendingCount = _specRequests.where((r) => r['status'] == 'pending').length;
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        // Summary row
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.1,
          children: [
            _cardSummary(t('Pending', 'Inasubiri'), '$pendingCount', Icons.pending_actions, AppColors.amber),
            _cardSummary(t('Appointments', 'Miadi'), '${_specAppointments.length}', Icons.today, leaf),
            _cardSummary(t('Earnings', 'Mapato'), 'TSH 0', Icons.wallet, AppColors.forest),
            _cardSummary(t('Active Clients', 'Wateja'), '24', Icons.people, AppColors.info),
            _cardSummary(t('Rating', 'Ukadiriaji'), '4.8 ⭐', Icons.star, Colors.orange),
            _cardSummary(t('Completed', 'Imekamilika'), '112', Icons.task_alt, leaf),
          ],
        ),
        const SizedBox(height: 18),
        
        // AI Advice
        Tile(
          gradient: const LinearGradient(colors: [Color(0xFF1B4D3E), leaf]),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  t('AI Insight: Suspected outbreak of Foot & Mouth disease within 8 km. Prepare vaccine batches.',
                    'Ushauri wa AI: Mlipuko wa ugonjwa wa Miguu na Midomo unahisiwa ndani ya km 8. Andaa chanjo.'),
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Live heatmap simulation
        Tile(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t('Disease Map & Request Frequencies', 'Ramani ya Magonjwa na Maombi'), style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statIndicator(t('Critical', 'Muhimu Sana'), '3', Colors.red),
                  _statIndicator(t('High', 'Kiwango cha Juu'), '8', Colors.amber),
                  _statIndicator(t('Medium', 'Kiwango cha Kati'), '12', Colors.blue),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpecRequestsPanel() {
    final list = _specRequests.where((r) => r['status'] == 'pending').toList();
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              t('Farmer Requests waiting', 'Maombi ya Mkulima yanayosubiri'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: leaf),
              onPressed: () => _addSpecRequestDialog(),
            )
          ],
        ),
        const SizedBox(height: 12),
        if (list.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Text(t('No pending farmer requests.', 'Hakuna maombi yanayosubiri.')),
            ),
          )
        else
          ...list.map((r) {
            Color urgencyColor = r['urgency'] == 'critical'
                ? Colors.red
                : (r['urgency'] == 'high' ? Colors.orange : Colors.blue);
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border(left: BorderSide(color: urgencyColor, width: 5)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(r['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: urgencyColor.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          r['urgency'].toString().toUpperCase(),
                          style: TextStyle(color: urgencyColor, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('${r['type']} — ${r['service']}', style: const TextStyle(color: Colors.black87, fontSize: 13)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: AppColors.muted),
                      const SizedBox(width: 4),
                      Text(r['location'], style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                      const Spacer(),
                      Text(r['datetime'], style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            r['status'] = 'accepted';
                            _specAppointments.add({
                              'id': DateTime.now().millisecondsSinceEpoch.toString(),
                              'name': r['name'],
                              'service': r['service'],
                              'type': 'Physical visit',
                              'time': 'Scheduled',
                              'status': 'confirmed'
                            });
                          });
                          _saveSpecRequests();
                          _saveSpecAppointments();
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: leaf, foregroundColor: Colors.white),
                        child: Text(t('Accept', 'Kubali')),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            r['status'] = 'rejected';
                          });
                          _saveSpecRequests();
                        },
                        child: Text(t('Reject', 'Ghairi')),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.call, color: leaf),
                        onPressed: () => _launchCommunication(r['phone'], 'tel'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.message, color: leaf),
                        onPressed: () => _launchCommunication(r['phone'], 'sms'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  void _addSpecRequestDialog() async {
    final nameCtrl = TextEditingController();
    final serviceCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    final typeCtrl = TextEditingController();
    String urgency = 'medium';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(t('Simulate Farmer Request', 'Kuiga Ombi la Mkulima')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: InputDecoration(labelText: t('Farmer Name', 'Jina la Mkulima'))),
              TextField(controller: serviceCtrl, decoration: InputDecoration(labelText: t('Service Required', 'Huduma inayohitajika'))),
              TextField(controller: typeCtrl, decoration: InputDecoration(labelText: t('Crop/Livestock Type', 'Aina ya Mazao/Mifugo'))),
              TextField(controller: locationCtrl, decoration: InputDecoration(labelText: t('Location', 'Eneo'))),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: urgency,
                items: const [
                  DropdownMenuItem(value: 'critical', child: Text('Critical')),
                  DropdownMenuItem(value: 'high', child: Text('High')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                ],
                onChanged: (val) => setS(() => urgency = val!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('Cancel', 'Ghairi'))),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty && serviceCtrl.text.isNotEmpty) {
                  setState(() {
                    _specRequests.insert(0, {
                      'id': DateTime.now().millisecondsSinceEpoch.toString(),
                      'name': nameCtrl.text,
                      'category': 'Diagnostic',
                      'service': serviceCtrl.text,
                      'datetime': 'Just now',
                      'urgency': urgency,
                      'type': typeCtrl.text,
                      'location': locationCtrl.text,
                      'status': 'pending',
                      'phone': '0711223344'
                    });
                  });
                  _saveSpecRequests();
                  Navigator.pop(ctx);
                }
              },
              child: Text(t('Add', 'Ongeza')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecAppointmentsPanel() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              t('Booked Appointments', 'Miadi Iliyowekwa'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: _addSpecAppointmentDialog,
              style: ElevatedButton.styleFrom(backgroundColor: leaf, foregroundColor: Colors.white),
              icon: const Icon(Icons.add, size: 16),
              label: Text(t('New Slot', 'Nafasi Mpya')),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_specAppointments.isEmpty)
          Center(child: Text(t('No appointments scheduled.', 'Hakuna miadi iliyopangwa.')))
        else
          ..._specAppointments.map((a) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: leaf.withOpacity(0.12),
                      child: const Icon(Icons.calendar_today, color: leaf),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(a['service'], style: const TextStyle(color: Colors.black54, fontSize: 12)),
                          Text('${a['type']} · ${a['time']}', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                      onPressed: () {
                        setState(() {
                          _specAppointments.removeWhere((item) => item['id'] == a['id']);
                        });
                        _saveSpecAppointments();
                      },
                    ),
                  ],
                ),
              )),
      ],
    );
  }

  void _addSpecAppointmentDialog() async {
    final nameCtrl = TextEditingController();
    final serviceCtrl = TextEditingController();
    String type = 'Physical visit';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(t('Add Appointment', 'Weka Miadi')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: InputDecoration(labelText: t('Client Name', 'Jina la Mteja'))),
              TextField(controller: serviceCtrl, decoration: InputDecoration(labelText: t('Service', 'Huduma'))),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: type,
                items: const [
                  DropdownMenuItem(value: 'Physical visit', child: Text('Physical visit')),
                  DropdownMenuItem(value: 'Video consultation', child: Text('Video consultation')),
                  DropdownMenuItem(value: 'Voice consultation', child: Text('Voice consultation')),
                  DropdownMenuItem(value: 'Chat consultation', child: Text('Chat consultation')),
                ],
                onChanged: (val) => setS(() => type = val!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('Cancel', 'Ghairi'))),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty) {
                  setState(() {
                    _specAppointments.add({
                      'id': DateTime.now().millisecondsSinceEpoch.toString(),
                      'name': nameCtrl.text,
                      'service': serviceCtrl.text,
                      'type': type,
                      'time': 'Today · 04:00 PM',
                      'status': 'confirmed'
                    });
                  });
                  _saveSpecAppointments();
                  Navigator.pop(ctx);
                }
              },
              child: Text(t('Save', 'Hifadhi')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecCommunicationCenter() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: _specMessages.length,
            itemBuilder: (ctx, idx) {
              final m = _specMessages[idx];
              final isMe = m['sender'] == 'doctor';
              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? leaf : Colors.grey[200],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 0),
                      bottomRight: Radius.circular(isMe ? 0 : 16),
                    ),
                  ),
                  child: Text(
                    m['text'],
                    style: TextStyle(color: isMe ? Colors.white : Colors.black87),
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.black12)),
          ),
          child: Row(
            children: [
              IconButton(icon: const Icon(Icons.mic, color: AppColors.muted), onPressed: () {}),
              IconButton(icon: const Icon(Icons.attach_file, color: AppColors.muted), onPressed: () {}),
              Expanded(
                child: TextField(
                  controller: _chatController,
                  decoration: InputDecoration(
                    hintText: t('Type a reply...', 'Andika jibu...'),
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: leaf),
                onPressed: () {
                  if (_chatController.text.isNotEmpty) {
                    setState(() {
                      _specMessages.add({'sender': 'doctor', 'text': _chatController.text});
                    });
                    _saveSpecMessages();
                    _chatController.clear();
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpecEarningsPanel() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [leaf, Color(0xFF1B4D3E)]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t('TOTAL BALANCE', 'SALIO LA JUMLA'), style: const TextStyle(color: Colors.white70, fontSize: 11)),
              const SizedBox(height: 6),
              const Text('TSH 0', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.lime, foregroundColor: AppColors.forestDeep),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(t('Withdrawal request submitted successfully.', 'Ombi la kutoa pesa limewasilishwa.'))),
                  );
                },
                child: Text(t('Withdraw Cash', 'Kutoa Pesa')),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(t('Recent Transactions', 'Miamala ya Hivi Karibuni'), style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ..._specTransactions.map((tx) => ListTile(
              title: Text(tx['desc']),
              subtitle: Text(tx['date']),
              trailing: Text(
                tx['amount'],
                style: TextStyle(
                  color: tx['type'] == 'credit' ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildSpecReviewsPanel() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(t('Customer Reviews', 'Mapitio ya Wateja'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        ..._specReviews.map((rev) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(rev['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(Icons.star, size: 14, color: i < rev['rating'] ? Colors.orange : Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('"${rev['comment']}"', style: const TextStyle(color: Colors.black87, fontSize: 13, fontStyle: FontStyle.italic)),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildSpecProfilePanel() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(t('Specialist Profile', 'Wasifu wa Mtaalamu'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),
        _profileField(t('Certifications', 'Vyeti'), _specCertifications, (val) async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('spec_certs', val);
          setState(() => _specCertifications = val);
        }),
        _profileField(t('Experience', 'Uzoefu'), _specExperience, (val) async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('spec_exp', val);
          setState(() => _specExperience = val);
        }),
        _profileField(t('Service Rate', 'Gharama ya Huduma'), _specPricing, (val) async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('spec_price', val);
          setState(() => _specPricing = val);
        }),
        _profileField(t('Working Hours', 'Saa za Kazi'), _specWorkingHours, (val) async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('spec_hours', val);
          setState(() => _specWorkingHours = val);
        }),
      ],
    );
  }


  // ── SECTION 2: PRODUCT PROVIDER DASHBOARD ───────────────────
  Widget _buildSellerDashboard() {
    return switch (_activeTab) {
      'orders' => _buildProdOrdersPanel(),
      'inventory' => _buildProdInventoryPanel(),
      'deliveries' => _buildProdDeliveriesPanel(),
      'promos' => _buildProdPromosPanel(),
      'profile' => _buildProdProfilePanel(),
      _ => _buildProdOverviewPanel(),
    };
  }

  Widget _buildProdOverviewPanel() {
    final pendingCount = _prodOrders.where((o) => o['status'] == 'Pending').length;
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        // Summary row
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.1,
          children: [
            _cardSummary(t('New Orders', 'Oda Mpya'), '$pendingCount', Icons.shopping_basket, Colors.orange),
            _cardSummary(t('Pending Del', 'Inayosafirishwa'), '2', Icons.local_shipping, Colors.blue),
            _cardSummary(t('In Stock', 'Kwenye Stoki'), '${_prodInventory.length}', Icons.inventory_2, leaf),
            _cardSummary(t('Low Stock', 'Stoki Chache'), '3', Icons.warning_amber, Colors.red),
            _cardSummary(t('Revenue', 'Mapato'), 'TSH 0', Icons.attach_money, AppColors.forestDeep),
            _cardSummary(t('Rating', 'Ukadiriaji'), '4.7 ⭐', Icons.star, Colors.orange),
          ],
        ),
        const SizedBox(height: 18),

        // Heatmap / Analytics
        Tile(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t('Weekly Sales Analytics', 'Uchambuzi wa Mauzo wa Wiki'), style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statIndicator(t('Feeds', 'Lishe'), '48%', Colors.orange),
                  _statIndicator(t('Seeds', 'Mbegu'), '32%', Colors.green),
                  _statIndicator(t('Fertilizers', 'Mbolea'), '20%', Colors.blue),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProdOrdersPanel() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(t('Incoming Customer Purchases', 'Manunuzi yanayoingia ya Wateja'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        if (_prodOrders.isEmpty)
          Center(child: Text(t('No active orders.', 'Hakuna oda yoyote.')))
        else
          ..._prodOrders.map((o) {
            Color statusColor = o['status'] == 'Pending' ? Colors.orange : Colors.green;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
                border: Border(left: BorderSide(color: statusColor, width: 5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(o['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(o['date'], style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('${o['products']} — ${o['quantity']}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: AppColors.muted),
                      const SizedBox(width: 4),
                      Text(o['address'], style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (o['status'] == 'Pending')
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              o['status'] = 'Confirmed';
                            });
                            _saveProdOrders();
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                          child: Text(t('Confirm', 'Thibitisha')),
                        )
                      else
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              o['status'] = 'Delivered';
                            });
                            _saveProdOrders();
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: leaf, foregroundColor: Colors.white),
                          child: Text(t('Deliver', 'Uwasilishaji')),
                        ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () => _launchCommunication(o['phone'], 'tel'),
                        child: Text(t('Contact', 'Wasiliana')),
                      ),
                    ],
                  )
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildProdInventoryPanel() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(t('Stock Catalog', 'Katalogi ya Bidhaa'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ElevatedButton.icon(
              onPressed: _addProdInventoryDialog,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
              icon: const Icon(Icons.add),
              label: Text(t('Add Product', 'Ongeza Bidhaa')),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._prodInventory.map((item) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.orange.withOpacity(0.12),
                    child: const Icon(Icons.shopping_bag, color: Colors.orange),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('${t('Price', 'Bei')}: ${item['price']} · ${t('Qty', 'Stoki')}: ${item['qty']}',
                            style: const TextStyle(color: Colors.black54, fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () {
                      setState(() {
                        _prodInventory.removeWhere((i) => i['id'] == item['id']);
                      });
                      _saveProdInventory();
                    },
                  ),
                ],
              ),
            )),
      ],
    );
  }

  void _addProdInventoryDialog() async {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('Add New Product', 'Ongeza Bidhaa Mpya')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: InputDecoration(labelText: t('Product Name', 'Jina la Bidhaa'))),
            TextField(controller: priceCtrl, decoration: InputDecoration(labelText: t('Price (TSH)', 'Bei (TSH)'))),
            TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: t('Quantity', 'Kiasi'))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('Cancel', 'Ghairi'))),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && priceCtrl.text.isNotEmpty) {
                setState(() {
                  _prodInventory.add({
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'name': nameCtrl.text,
                    'category': 'General',
                    'qty': int.tryParse(qtyCtrl.text) ?? 10,
                    'price': 'TSH ${priceCtrl.text}',
                    'available': true
                  });
                });
                _saveProdInventory();
                Navigator.pop(ctx);
              }
            },
            child: Text(t('Add', 'Ongeza')),
          ),
        ],
      ),
    );
  }

  Widget _buildProdDeliveriesPanel() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(t('Active Delivery Routes', 'Njia za Uwasilishaji'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        ..._prodDeliveries.map((del) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${t('Driver', 'Dereva')}: ${del['driver']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: Colors.blue.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          del['status'],
                          style: const TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('${t('Estimated Arrival', 'Muda wa Kufika')}: ${del['eta']}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildProdPromosPanel() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(t('Promotional Coupons', 'Kuponi za Punguzo'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ElevatedButton.icon(
              onPressed: _addProdCouponDialog,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
              icon: const Icon(Icons.add),
              label: Text(t('Create Coupon', 'Unda Kuponi')),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._prodCoupons.map((c) => ListTile(
              leading: const Icon(Icons.local_offer, color: Colors.orange),
              title: Text(c['code'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${t('Discount', 'Punguzo')}: ${c['discount']}'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                child: Text(c['status'], style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            )),
      ],
    );
  }

  void _addProdCouponDialog() async {
    final codeCtrl = TextEditingController();
    final discCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('Create Promo Coupon', 'Unda Kuponi Mpya')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: codeCtrl, decoration: InputDecoration(labelText: t('Coupon Code', 'Nambari ya Kuponi'))),
            TextField(controller: discCtrl, decoration: InputDecoration(labelText: t('Discount Value (e.g. 15% or TSH 200)', 'Kiasi cha Punguzo'))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('Cancel', 'Ghairi'))),
          ElevatedButton(
            onPressed: () {
              if (codeCtrl.text.isNotEmpty) {
                setState(() {
                  _prodCoupons.insert(0, {
                    'code': codeCtrl.text.toUpperCase(),
                    'discount': discCtrl.text,
                    'status': 'Active'
                  });
                });
                _saveProdCoupons();
                Navigator.pop(ctx);
              }
            },
            child: Text(t('Create', 'Unda')),
          ),
        ],
      ),
    );
  }

  Widget _buildProdProfilePanel() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(t('Provider Store Profile', 'Wasifu wa Duka la Mtoa Bidhaa'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),
        _profileField(t('Store Description', 'Maelezo ya Duka'), _prodStoreDescription, (val) async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('prod_desc', val);
          setState(() => _prodStoreDescription = val);
        }),
        _profileField(t('Operating Hours', 'Saa za Kazi'), _prodStoreHours, (val) async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('prod_hours', val);
          setState(() => _prodStoreHours = val);
        }),
        _profileField(t('Delivery Regions', 'Mikoa ya Uwasilishaji'), _prodStoreRegions, (val) async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('prod_regions', val);
          setState(() => _prodStoreRegions = val);
        }),
        _profileField(t('Contact details', 'Nambari ya Mawasiliano'), _prodStorePhone, (val) async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('prod_phone', val);
          setState(() => _prodStorePhone = val);
        }),
      ],
    );
  }


  // ── CUSTOM SHARED REUSABLE SUBWIDGETS ──
  Widget _cardSummary(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, spreadRadius: 1)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          Text(label, style: const TextStyle(fontSize: 9, color: AppColors.muted), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _statIndicator(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
          child: Center(child: Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13))),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
      ],
    );
  }

  Widget _profileField(String label, String value, Function(String) onSave) {
    final textCtrl = TextEditingController(text: value);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.muted)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 18, color: leaf),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('${t('Edit', 'Hariri')} $label'),
                      content: TextField(controller: textCtrl),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('Cancel', 'Ghairi'))),
                        ElevatedButton(
                          onPressed: () {
                            onSave(textCtrl.text);
                            Navigator.pop(ctx);
                          },
                          child: Text(t('Save', 'Hifadhi')),
                        ),
                      ],
                    ),
                  );
                },
              )
            ],
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
