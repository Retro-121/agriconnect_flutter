import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';
import '../provider_types.dart';

class BusinessScreen extends StatefulWidget {
  final ProviderState provider;
  const BusinessScreen({super.key, required this.provider});

  @override
  State<BusinessScreen> createState() => _BusinessScreenState();
}

class _Product {
  final String id;
  final String name;
  final String price;
  final String desc;
  final bool available;

  _Product({
    required this.id,
    required this.name,
    required this.price,
    required this.desc,
    this.available = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'desc': desc,
        'available': available,
      };

  factory _Product.fromJson(Map<String, dynamic> map) => _Product(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        price: map['price'] ?? '',
        desc: map['desc'] ?? '',
        available: map['available'] ?? true,
      );
}

class _Order {
  final String id;
  final String clientName;
  final String product;
  final String quantity;
  final String residence;
  final String phone;
  final String status; // 'pending', 'accepted', 'completed'

  _Order({
    required this.id,
    required this.clientName,
    required this.product,
    required this.quantity,
    required this.residence,
    required this.phone,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'clientName': clientName,
        'product': product,
        'quantity': quantity,
        'residence': residence,
        'phone': phone,
        'status': status,
      };

  factory _Order.fromJson(Map<String, dynamic> map) => _Order(
        id: map['id'] ?? '',
        clientName: map['clientName'] ?? '',
        product: map['product'] ?? '',
        quantity: map['quantity'] ?? '',
        residence: map['residence'] ?? '',
        phone: map['phone'] ?? '',
        status: map['status'] ?? 'pending',
      );
}

class _Ad {
  final String id;
  final String productName;
  final String budget;
  final int impressions;
  final int clicks;
  final String status; // 'active', 'completed'

  _Ad({
    required this.id,
    required this.productName,
    required this.budget,
    required this.impressions,
    required this.clicks,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'productName': productName,
        'budget': budget,
        'impressions': impressions,
        'clicks': clicks,
        'status': status,
      };

  factory _Ad.fromJson(Map<String, dynamic> map) => _Ad(
        id: map['id'] ?? '',
        productName: map['productName'] ?? '',
        budget: map['budget'] ?? '',
        impressions: map['impressions'] ?? 0,
        clicks: map['clicks'] ?? 0,
        status: map['status'] ?? 'active',
      );
}

class _BusinessScreenState extends State<BusinessScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<_Product> _products = [];
  List<_Order> _orders = [];
  List<_Ad> _ads = [];
  String _language = 'English';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String t(String en, String sw) => _language == 'Kiswahili' ? sw : en;

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _language = prefs.getString('language') ?? 'English';
    });

    final productsStr = prefs.getString('biz_products');
    final ordersStr = prefs.getString('biz_orders');
    final adsStr = prefs.getString('biz_ads');

    if (productsStr != null) {
      try {
        final List<dynamic> decoded = json.decode(productsStr);
        setState(() {
          _products = decoded.map((p) => _Product.fromJson(p)).toList();
        });
      } catch (_) {}
    } else {
      // Seed default products based on provider type
      _products = [
        _Product(id: '1', name: t('Premium Crop Feed', 'Chakula cha Bora cha Mifugo'), price: 'KES 2,500', desc: t('High protein compound feed', 'Chakula chenye protini nyingi')),
        _Product(id: '2', name: t('Organic Fertilizer NPK', 'Mbolea ya Kiasili NPK'), price: 'KES 3,200', desc: t('Perfect for maize and beans', 'Nzuri sana kwa mahindi na maharagwe')),
      ];
      _saveProducts();
    }

    if (ordersStr != null) {
      try {
        final List<dynamic> decoded = json.decode(ordersStr);
        setState(() {
          _orders = decoded.map((o) => _Order.fromJson(o)).toList();
        });
      } catch (_) {}
    } else {
      // Seed default orders
      _orders = [
        _Order(
          id: '1',
          clientName: 'Mary Wanjiku',
          product: t('Premium Crop Feed', 'Chakula cha Bora cha Mifugo'),
          quantity: '10 bags',
          residence: 'Kiambu',
          phone: '0712345678',
          status: 'pending',
        ),
        _Order(
          id: '2',
          clientName: 'John Otieno',
          product: t('Organic Fertilizer NPK', 'Mbolea ya Kiasili NPK'),
          quantity: '5 bags',
          residence: 'Nakuru',
          phone: '0722334455',
          status: 'pending',
        ),
      ];
      _saveOrders();
    }

    if (adsStr != null) {
      try {
        final List<dynamic> decoded = json.decode(adsStr);
        setState(() {
          _ads = decoded.map((a) => _Ad.fromJson(a)).toList();
        });
      } catch (_) {}
    } else {
      _ads = [
        _Ad(id: '1', productName: t('Premium Crop Feed', 'Chakula cha Bora cha Mifugo'), budget: 'KES 1,500', impressions: 450, clicks: 82, status: 'active'),
      ];
      _saveAds();
    }
  }

  Future<void> _saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('biz_products', json.encode(_products.map((p) => p.toJson()).toList()));
  }

  Future<void> _saveOrders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('biz_orders', json.encode(_orders.map((o) => o.toJson()).toList()));
  }

  Future<void> _saveAds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('biz_ads', json.encode(_ads.map((a) => a.toJson()).toList()));
  }

  void _addProduct() async {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('Add Product to Catalog', 'Ongeza Bidhaa kwenye Orodha')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: t('Product Name', 'Jina la Bidhaa'),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceCtrl,
              decoration: InputDecoration(
                labelText: t('Price (e.g. KES 1,200)', 'Bei (mf. KES 1,200)'),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: InputDecoration(
                labelText: t('Description', 'Maelezo ya Bidhaa'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('Cancel', 'Ghairi'))),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && priceCtrl.text.isNotEmpty) {
                setState(() {
                  _products.add(_Product(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameCtrl.text,
                    price: priceCtrl.text,
                    desc: descCtrl.text,
                  ));
                });
                _saveProducts();
                Navigator.pop(ctx);
              }
            },
            child: Text(t('Add', 'Ongeza')),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(String id) {
    setState(() {
      _products.removeWhere((p) => p.id == id);
    });
    _saveProducts();
  }

  void _updateOrderStatus(String id, String newStatus) {
    setState(() {
      final idx = _orders.indexWhere((o) => o.id == id);
      if (idx != -1) {
        final old = _orders[idx];
        _orders[idx] = _Order(
          id: old.id,
          clientName: old.clientName,
          product: old.product,
          quantity: old.quantity,
          residence: old.residence,
          phone: old.phone,
          status: newStatus,
        );
      }
    });
    _saveOrders();
  }

  void _launchAd() async {
    if (_products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('Please add products to your catalog first.', 'Tafadhali ongeza bidhaa kwanza.'))),
      );
      return;
    }

    String selectedProd = _products.first.name;
    final budgetCtrl = TextEditingController(text: '1000');

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(t('Launch Ad Campaign', 'Zindua Kampeni ya Tangazo')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedProd,
                decoration: InputDecoration(labelText: t('Product', 'Bidhaa')),
                items: _products
                    .map((p) => DropdownMenuItem(value: p.name, child: Text(p.name)))
                    .toList(),
                onChanged: (val) => setS(() => selectedProd = val!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: budgetCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: t('Budget (KES)', 'Bajeti (KES)'),
                  prefixIcon: const Icon(Icons.money),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('Cancel', 'Ghairi'))),
            ElevatedButton(
              onPressed: () {
                if (budgetCtrl.text.isNotEmpty) {
                  setState(() {
                    _ads.insert(
                        0,
                        _Ad(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          productName: selectedProd,
                          budget: 'KES ${budgetCtrl.text}',
                          impressions: 0,
                          clicks: 0,
                          status: 'active',
                        ));
                  });
                  _saveAds();
                  Navigator.pop(ctx);
                }
              },
              child: Text(t('Launch', 'Zindua')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _callPhone(String phone) async {
    final Uri url = Uri(scheme: 'tel', path: phone);
    try {
      await launchUrl(url);
    } catch (_) {}
  }

  Future<void> _sendMessage(String phone) async {
    final Uri url = Uri(scheme: 'sms', path: phone);
    try {
      await launchUrl(url);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/backgrounds/bg-suppliers-dark.jpg', fit: BoxFit.cover)),
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.7))),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t('Business Management', 'Usimamizi wa Biashara'),
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            t('Sell, handle orders & run ads', 'Uza, shughulikia oda na tangaza'),
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  indicatorColor: harvest,
                  tabs: [
                    Tab(text: t('Catalog / Sell', 'Orodha / Uza')),
                    Tab(text: t('Orders', 'Oda')),
                    Tab(text: t('Advertise', 'Tangaza')),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCatalogTab(),
                      _buildOrdersTab(),
                      _buildAdsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatalogTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              t('My Storefront Products', 'Bidhaa za Duka Langu'),
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            ElevatedButton.icon(
              onPressed: _addProduct,
              style: ElevatedButton.styleFrom(backgroundColor: leaf, foregroundColor: Colors.white),
              icon: const Icon(Icons.add, size: 16),
              label: Text(t('Add Product', 'Ongeza Bidhaa')),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_products.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Text(t('No products listed.', 'Hakuna bidhaa zilizoorodheshwa.'), style: const TextStyle(color: Colors.white70)),
            ),
          )
        else
          ..._products.map((p) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: leaf.withOpacity(0.2),
                      child: const Icon(Icons.shopping_bag, color: leaf),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                          const SizedBox(height: 4),
                          Text(p.desc, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                          const SizedBox(height: 4),
                          Text(p.price, style: const TextStyle(fontWeight: FontWeight.bold, color: leaf, fontSize: 14)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _deleteProduct(p.id),
                    ),
                  ],
                ),
              )),
      ],
    );
  }

  Widget _buildOrdersTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          t('Incoming Customer Requests', 'Oda Zinazoingia za Wateja'),
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        if (_orders.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Text(t('No active orders.', 'Hakuna oda zinazoendelea.'), style: const TextStyle(color: Colors.white70)),
            ),
          )
        else
          ..._orders.map((o) {
            final isPending = o.status == 'pending';
            final isAccepted = o.status == 'accepted';
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border(left: BorderSide(color: isPending ? Colors.orange : (isAccepted ? leaf : Colors.grey), width: 5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isPending ? Colors.orange : (isAccepted ? leaf : Colors.grey),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          t(o.status.toUpperCase(), o.status == 'pending' ? 'INASUBIRI' : (o.status == 'accepted' ? 'IMEPATIKANA' : 'IMEKAMILIKA')),
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(o.quantity, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(o.product, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                  const SizedBox(height: 4),
                  Text('${t('Customer', 'Mteja')}: ${o.clientName} — ${o.residence}', style: const TextStyle(color: AppColors.muted)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _callPhone(o.phone),
                        icon: const Icon(Icons.call, size: 14),
                        label: Text(t('Call', 'Piga Simu')),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () => _sendMessage(o.phone),
                        icon: const Icon(Icons.message, size: 14),
                        label: Text(t('Message', 'Ujumbe')),
                      ),
                      const Spacer(),
                      if (isPending)
                        ElevatedButton(
                          onPressed: () => _updateOrderStatus(o.id, 'accepted'),
                          style: ElevatedButton.styleFrom(backgroundColor: leaf, foregroundColor: Colors.white),
                          child: Text(t('Accept', 'Kubali')),
                        )
                      else if (isAccepted)
                        ElevatedButton(
                          onPressed: () => _updateOrderStatus(o.id, 'completed'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.forestDeep, foregroundColor: Colors.white),
                          child: Text(t('Complete', 'Kamilisha')),
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

  Widget _buildAdsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              t('Active Promotions', 'Matangazo Yanayoendelea'),
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            ElevatedButton.icon(
              onPressed: _launchAd,
              style: ElevatedButton.styleFrom(backgroundColor: harvest, foregroundColor: soil),
              icon: const Icon(Icons.rocket_launch, size: 16),
              label: Text(t('Promote / Advertise', 'Tangaza Bidhaa')),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_ads.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Text(t('No running ads.', 'Hakuna matangazo yanayokimbia kwa sasa.'), style: const TextStyle(color: Colors.white70)),
            ),
          )
        else
          ..._ads.map((ad) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(ad.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                        Text(ad.budget, style: const TextStyle(color: leaf, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _adStat(t('Impressions', 'Watazamaji'), ad.impressions.toString(), Icons.remove_red_eye_outlined),
                        _adStat(t('Clicks', 'Mibofyo'), ad.clicks.toString(), Icons.ads_click_outlined),
                        _adStat(t('CTR', 'CTR'), '${ad.impressions > 0 ? ((ad.clicks / ad.impressions) * 100).toStringAsFixed(1) : "0"}%', Icons.percent),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.circle, color: Colors.green, size: 8),
                              const SizedBox(width: 4),
                              Text(t('PROMOTING', 'INATANGAZWA'), style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
      ],
    );
  }

  Widget _adStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.muted, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black)),
        Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 10)),
      ],
    );
  }
}
