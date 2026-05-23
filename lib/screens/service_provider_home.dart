import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import '../widgets/profile_avatar.dart';
import '../provider_types.dart';
import 'dashboard_screen.dart';
import 'assistant_screen.dart';
import 'emergencies_screen.dart';

class ServiceProviderHomeScreen extends StatefulWidget {
  const ServiceProviderHomeScreen({super.key});

  @override
  State<ServiceProviderHomeScreen> createState() => _ServiceProviderHomeScreenState();
}

class _ServiceProviderHomeScreenState extends State<ServiceProviderHomeScreen> {
  int _index = 2;
  final _provider = ProviderState();
  String _language = 'English';
  String _userName = '';
  String _profileImageUrl = '';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _provider.addListener(() => setState(() {}));
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _language = prefs.getString('language') ?? 'English';
      _userName = prefs.getString('userName') ?? '';
      _profileImageUrl = prefs.getString('profileImageUrl') ?? '';
    });
  }

  String t(String en, String sw) => _language == 'Kiswahili' ? sw : en;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const EmergenciesScreen(),
      const ServiceProviderClientsPage(),
      DashboardScreen(provider: _provider),
      const AiChatPage(),
      const ServiceProviderProfileTab(),
    ];
    final titles = [
      t('Emergencies', 'Dharura'),
      t('Clients', 'Wateja'),
      t('Home', 'Nyumbani'),
      t('AI Assistant', 'Msaidizi wa AI'),
      t('Profile', 'Wasifu'),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.forest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.eco, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'AgriPortal',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  titles[_index],
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<ProviderType>(
            tooltip: t('Switch provider', 'Badilisha mtoa huduma'),
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_provider.info.icon, color: AppColors.forest, size: 18),
                const SizedBox(width: 4),
                const Icon(Icons.expand_more, color: Colors.black54, size: 18),
                const SizedBox(width: 8),
              ],
            ),
            onSelected: _provider.set,
            itemBuilder: (_) => kProviders.entries
                .map((e) => PopupMenuItem(
                      value: e.key,
                      child: Row(
                        children: [
                          Icon(e.value.icon, size: 16, color: AppColors.forest),
                          const SizedBox(width: 8),
                          Text(e.value.label),
                        ],
                      ),
                    ))
                .toList(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/service-provider-profile').then((_) => _loadLanguage()),
              child: ProfileAvatar(
                radius: 18,
                imageUrl: _profileImageUrl.isNotEmpty ? _profileImageUrl : null,
                initials: _userName.isNotEmpty ? _userName[0].toUpperCase() : 'A',
                backgroundColor: AppColors.forest,
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.warning_amber_outlined),
            selectedIcon: const Icon(Icons.warning_amber),
            label: t('Emergencies', 'Dharura'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline),
            selectedIcon: const Icon(Icons.people),
            label: t('Clients', 'Wateja'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: t('Home', 'Nyumbani'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.auto_awesome_outlined),
            selectedIcon: const Icon(Icons.auto_awesome),
            label: t('AI', 'AI'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: t('Profile', 'Wasifu'),
          ),
        ],
      ),
      floatingActionButton: _index == 3
          ? null
          : FloatingActionButton.extended(
              onPressed: () => setState(() => _index = 3),
              backgroundColor: AppColors.forest,
              icon: const Icon(Icons.auto_awesome, color: Colors.white),
              label: Text(t('Ask AI', 'Uliza AI'), style: const TextStyle(color: Colors.white)),
            ),
    );
  }
}

class ServiceProviderClientsPage extends StatefulWidget {
  const ServiceProviderClientsPage({super.key});

  @override
  State<ServiceProviderClientsPage> createState() => _ServiceProviderClientsPageState();
}

class _ServiceProviderClientsPageState extends State<ServiceProviderClientsPage> {
  final List<Map<String, dynamic>> _clients = [];
  final List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final clientStrings = prefs.getStringList('providerClients') ?? [];
    final orderStrings = prefs.getStringList('providerOrders') ?? [];

    setState(() {
      _clients.clear();
      _clients.addAll(clientStrings.map((item) => Map<String, dynamic>.from(json.decode(item) as Map)));
      _orders.clear();
      _orders.addAll(orderStrings.map((item) => Map<String, dynamic>.from(json.decode(item) as Map)));
    });
  }

  Future<void> _saveClients() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('providerClients', _clients.map((client) => json.encode(client)).toList());
  }

  Future<void> _saveOrders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('providerOrders', _orders.map((order) => json.encode(order)).toList());
  }

  Future<void> _showAddClientDialog() async {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final serviceCtrl = TextEditingController();
    final locationCtrl = TextEditingController(text: 'Tanzania');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Client'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Client Name')),
              const SizedBox(height: 12),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone')),
              const SizedBox(height: 12),
              TextField(controller: serviceCtrl, decoration: const InputDecoration(labelText: 'Service Required')),
              const SizedBox(height: 12),
              TextField(controller: locationCtrl, decoration: const InputDecoration(labelText: 'Location')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty || serviceCtrl.text.trim().isEmpty) return;
              _clients.add({
                'name': nameCtrl.text.trim(),
                'phone': phoneCtrl.text.trim(),
                'service': serviceCtrl.text.trim(),
                'location': locationCtrl.text.trim(),
                'added': DateTime.now().toIso8601String(),
              });
              _saveClients();
              setState(() {});
              Navigator.pop(ctx, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Client saved.')));
    }
  }

  Future<void> _showAddOrderDialog() async {
    final clientCtrl = TextEditingController();
    final itemsCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final addressCtrl = TextEditingController(text: 'Tanzania');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Order'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: clientCtrl, decoration: const InputDecoration(labelText: 'Client Name')),
              const SizedBox(height: 12),
              TextField(controller: itemsCtrl, decoration: const InputDecoration(labelText: 'Order Description')),
              const SizedBox(height: 12),
              TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount (TSH)')),
              const SizedBox(height: 12),
              TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Service Location')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (clientCtrl.text.trim().isEmpty || itemsCtrl.text.trim().isEmpty) return;
              final amount = double.tryParse(amountCtrl.text.replaceAll(',', '')) ?? 0;
              _orders.add({
                'client': clientCtrl.text.trim(),
                'items': itemsCtrl.text.trim(),
                'amount': amount,
                'location': addressCtrl.text.trim(),
                'created': DateTime.now().toIso8601String(),
              });
              _saveOrders();
              setState(() {});
              Navigator.pop(ctx, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order saved.')));
    }
  }

  Future<void> _removeClient(int index) async {
    _clients.removeAt(index);
    await _saveClients();
    setState(() {});
  }

  Future<void> _removeOrder(int index) async {
    _orders.removeAt(index);
    await _saveOrders();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Clients & Orders',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _showAddClientDialog,
                    icon: const Icon(Icons.person_add, size: 18),
                    label: const Text('Add Client'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _showAddOrderDialog,
                    icon: const Icon(Icons.add_shopping_cart, size: 18),
                    label: const Text('Add Order'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text('Clients', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  if (_clients.isEmpty)
                    const Text('No clients yet. Add a client to get started.')
                  else
                    ..._clients.asMap().entries.map((entry) {
                      final index = entry.key;
                      final client = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(client['name'] ?? 'Unknown'),
                          subtitle: Text('${client['service'] ?? ''} • ${client['location'] ?? 'Tanzania'}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _removeClient(index),
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 20),
                  Text('Orders', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  if (_orders.isEmpty)
                    const Text('No orders yet. Create orders to track service requests or product deliveries.')
                  else
                    ..._orders.asMap().entries.map((entry) {
                      final index = entry.key;
                      final order = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.shopping_bag)),
                          title: Text(order['client'] ?? 'Client'),
                          subtitle: Text('${order['items'] ?? 'Order'} · ${order['location'] ?? 'Tanzania'}'),
                          trailing: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('TSH ${order['amount']?.toStringAsFixed(0) ?? '0'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _removeOrder(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceProviderProfileTab extends StatefulWidget {
  const ServiceProviderProfileTab({super.key});

  @override
  State<ServiceProviderProfileTab> createState() => _ServiceProviderProfileTabState();
}

class _ServiceProviderProfileTabState extends State<ServiceProviderProfileTab> {
  double _balance = 0.0;
  String _selectedAgent = 'Vodacom M-Pesa';
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _withdrawController = TextEditingController();
  final List<String> _agents = ['Vodacom M-Pesa', 'Airtel Money', 'CRDB Bank', 'NMB Bank'];

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _withdrawController.dispose();
    super.dispose();
  }

  Future<void> _loadBalance() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _balance = prefs.getDouble('providerBalance') ?? 0.0;
    });
  }

  Future<void> _saveBalance() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('providerBalance', _balance);
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {
      // Ignore sign out errors and continue.
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<void> _addIncome() async {
    final amount = double.tryParse(_incomeController.text.replaceAll(',', '').trim()) ?? 0.0;
    if (amount <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid income amount.')));
      return;
    }
    setState(() => _balance += amount);
    await _saveBalance();
    _incomeController.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Income added.')));
  }

  Future<void> _withdrawFunds() async {
    final amount = double.tryParse(_withdrawController.text.replaceAll(',', '').trim()) ?? 0.0;
    if (amount <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid withdrawal amount.')));
      return;
    }
    if (amount > _balance) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Insufficient balance.')));
      return;
    }
    setState(() => _balance -= amount);
    await _saveBalance();
    _withdrawController.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Withdrawn TSH $amount via $_selectedAgent.')));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Service Provider Profile',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text('Manage your balance, withdrawals, and provider details from one place.'),
          const SizedBox(height: 20),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Current Balance', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text('TSH ${_balance.toStringAsFixed(0)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text('Your balance updates automatically when you add income or withdraw funds.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Add Income', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _incomeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Income Amount (TSH)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.add_business),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.forest),
              onPressed: _addIncome,
              child: const Text('Add Income'),
            ),
          ),
          const SizedBox(height: 24),
          Text('Withdraw Funds', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedAgent,
            items: _agents.map((agent) => DropdownMenuItem(value: agent, child: Text(agent))).toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedAgent = value);
            },
            decoration: const InputDecoration(
              labelText: 'Withdrawal Agent',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _withdrawController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount to Withdraw (TSH)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.payments),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.forest),
              onPressed: _withdrawFunds,
              child: const Text('Withdraw'),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/service-provider-profile'),
            child: const Text('Edit Full Profile'),
          ),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: _signOut,
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text(
              'Logout',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceProviderProfileScreen extends StatefulWidget {
  const ServiceProviderProfileScreen({super.key});

  @override
  State<ServiceProviderProfileScreen> createState() => _ServiceProviderProfileScreenState();
}

class _ServiceProviderProfileScreenState extends State<ServiceProviderProfileScreen> {
  String _userName = '';
  String _serviceCategory = 'General Service';
  String _farmLocation = 'Tanzania';
  String _language = 'English';
  String _profileImageUrl = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? '';
      _profileImageUrl = prefs.getString('profileImageUrl') ?? '';
      _serviceCategory = prefs.getString('serviceCategory') ?? 'General Service';
      _farmLocation = prefs.getString('farmLocation') ?? 'Tanzania';
      _language = prefs.getString('language') ?? 'English';
    });
  }

  String t(String en, String sw) => _language == 'Kiswahili' ? sw : en;

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {
      // Ignore sign out errors and continue.
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t('Service Provider Profile', 'Wasifu wa Mtoa Huduma')),
        backgroundColor: AppColors.forest,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ProfileAvatar(
                radius: 42,
                imageUrl: _profileImageUrl.isNotEmpty ? _profileImageUrl : null,
                initials: _userName.isNotEmpty ? _userName[0].toUpperCase() : 'S',
                backgroundColor: AppColors.forest,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                _userName.isNotEmpty ? _userName : t('Service Provider', 'Mtoa Huduma'),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Center(child: Text(_serviceCategory, style: const TextStyle(color: AppColors.muted))),
            const SizedBox(height: 24),
            Text(t('Service Area', 'Eneo la Huduma'), style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(_farmLocation),
            const SizedBox(height: 18),
            Text(t('Profile Settings', 'Mipangilio ya Wasifu'), style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _profileRow(t('Role', 'Jukumu'), t('Service Provider', 'Mtoa Huduma')),
                    const SizedBox(height: 12),
                    _profileRow(t('Language', 'Lugha'), _language),
                    const SizedBox(height: 12),
                    _profileRow(t('Offline Mode', 'Hali ya Nje ya Mtandao'), t('Disabled', 'Imezimwa')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.forest),
                onPressed: _signOut,
                child: Text(t('Sign Out', 'Toka')), 
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label, style: const TextStyle(color: AppColors.muted))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
