import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';

class EmergenciesScreen extends StatefulWidget {
  const EmergenciesScreen({super.key});

  @override
  State<EmergenciesScreen> createState() => _EmergenciesScreenState();
}

class _Case {
  final String id;
  final String title;
  final String who;
  final String where;
  final String phone;
  final String severity; // 'critical', 'high', 'medium'
  final double km;
  final String ago;

  _Case({
    required this.id,
    required this.title,
    required this.who,
    required this.where,
    required this.phone,
    required this.severity,
    required this.km,
    required this.ago,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'who': who,
    'where': where,
    'phone': phone,
    'severity': severity,
    'km': km,
    'ago': ago,
  };

  factory _Case.fromJson(Map<String, dynamic> map) => _Case(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    who: map['who'] ?? '',
    where: map['where'] ?? '',
    phone: map['phone'] ?? '',
    severity: map['severity'] ?? 'medium',
    km: (map['km'] as num?)?.toDouble() ?? 5.0,
    ago: map['ago'] ?? 'just now',
  );
}

class _EmergenciesScreenState extends State<EmergenciesScreen> {
  List<_Case> _cases = [];
  String _language = 'English';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _language = prefs.getString('language') ?? 'English';
    });
    
    final casesStr = prefs.getString('provider_emergencies');
    if (casesStr != null) {
      try {
        final List<dynamic> decoded = json.decode(casesStr);
        setState(() {
          _cases = decoded.map((c) => _Case.fromJson(c)).toList();
        });
      } catch (e) {
        debugPrint('Error parsing emergencies: $e');
      }
    }
  }

  Future<void> _saveCases() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _cases.map((c) => c.toJson()).toList();
    await prefs.setString('provider_emergencies', json.encode(data));
  }

  String t(String en, String sw) => _language == 'Kiswahili' ? sw : en;

  void _addCase() async {
    final titleCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final residenceCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String severity = 'medium';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(t('Add Client Triage', 'Ongeza Tathmini ya Mteja')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: t('Client Name', 'Jina la Mteja'),
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: t('Summary of Issue', 'Muhtasari wa Tatizo'),
                    prefixIcon: const Icon(Icons.description),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: t('Phone Number', 'Nambari ya Simu'),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: residenceCtrl,
                  decoration: InputDecoration(
                    labelText: t('Residence / Location', 'Makazi / Eneo'),
                    prefixIcon: const Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: severity,
                  decoration: InputDecoration(
                    labelText: t('Severity', 'Ukali'),
                  ),
                  items: [
                    DropdownMenuItem(value: 'critical', child: Text(t('Critical', 'Muhimu Sana'))),
                    DropdownMenuItem(value: 'high', child: Text(t('High', 'Kiwango cha Juu'))),
                    DropdownMenuItem(value: 'medium', child: Text(t('Medium', 'Kiwango cha Kati'))),
                  ],
                  onChanged: (val) => setS(() => severity = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(t('Cancel', 'Ghairi')),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty && titleCtrl.text.isNotEmpty) {
                  final newCase = _Case(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleCtrl.text,
                    who: nameCtrl.text,
                    where: residenceCtrl.text,
                    phone: phoneCtrl.text,
                    severity: severity,
                    km: 1.0 + (10.0 * (1.0 - (1.0 / (1.0 + _cases.length)))), // mock distance
                    ago: t('1 min ago', 'Dk 1 iliyopita'),
                  );
                  setState(() {
                    _cases.insert(0, newCase);
                  });
                  _saveCases();
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

  void _deleteCase(_Case c) {
    setState(() {
      _cases.removeWhere((item) => item.id == c.id);
    });
    _saveCases();
  }

  Future<void> _callPhone(String phone) async {
    if (phone.isEmpty) return;
    final Uri url = Uri(scheme: 'tel', path: phone);
    try {
      if (await launchUrl(url)) {
        // successfully launched
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t('Could not place call.', 'Imeshindikana kupiga simu.'))),
        );
      }
    }
  }

  Future<void> _sendMessage(String phone) async {
    if (phone.isEmpty) return;
    final Uri url = Uri(scheme: 'sms', path: phone);
    try {
      if (await launchUrl(url)) {
        // successfully launched
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t('Could not send message.', 'Imeshindikana kutuma ujumbe.'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: Image.asset('assets/backgrounds/bg_emergency.jpg', fit: BoxFit.cover)),
        Positioned.fill(child: Container(color: Colors.black.withOpacity(0.65))),
        SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t('Emergency Triage', 'Tathmini ya Dharura'),
                                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(t('Live farmer requests, sorted by severity', 'Maombi ya dharura ya wakulima, yaliyopangwa kwa ukali'),
                                style: TextStyle(color: Colors.white.withOpacity(0.7))),
                          ],
                        ),
                        FloatingActionButton.small(
                          onPressed: _addCase,
                          backgroundColor: AppColors.emergency,
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    if (_cases.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 80.0),
                          child: Text(
                            t('No emergency cases. Tap + to add one.', 'Hakuna dharura yoyote. Gonga + kuongeza.'),
                            style: const TextStyle(color: Colors.white70, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else
                      ..._cases.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _EmergencyCard(
                              c: c,
                              onCall: () => _callPhone(c.phone),
                              onMessage: () => _sendMessage(c.phone),
                              onDelete: () => _deleteCase(c),
                              t: t,
                            ),
                          )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmergencyCard extends StatelessWidget {
  final _Case c;
  final VoidCallback onCall;
  final VoidCallback onMessage;
  final VoidCallback onDelete;
  final String Function(String, String) t;

  const _EmergencyCard({
    required this.c,
    required this.onCall,
    required this.onMessage,
    required this.onDelete,
    required this.t,
  });

  Color get _color => switch (c.severity) {
        'critical' => AppColors.emergency,
        'high' => AppColors.amber,
        _ => AppColors.info,
      };

  String get _label => switch (c.severity) {
        'critical' => t('CRITICAL', 'MUHIMU SANA'),
        'high' => t('HIGH', 'JUU'),
        _ => t('MEDIUM', 'KATI'),
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(20),
        border: Border(left: BorderSide(color: _color, width: 5)),
        boxShadow: [
          BoxShadow(
              color: _color.withOpacity(c.severity == 'critical' ? 0.35 : 0.15),
              blurRadius: 24,
              spreadRadius: 1)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: _color, borderRadius: BorderRadius.circular(999)),
                child: Text(_label,
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
              ),
              const Spacer(),
              const Icon(Icons.location_on, size: 14, color: Colors.black54),
              Text(' ${c.km.toStringAsFixed(1)} km · ${c.ago}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(c.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black)),
          const SizedBox(height: 4),
          Text('${c.who} — ${c.where}', style: const TextStyle(color: AppColors.muted)),
          if (c.phone.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(c.phone, style: const TextStyle(color: AppColors.muted, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: onCall,
                icon: const Icon(Icons.call, size: 16),
                label: Text(t('Call', 'Piga Simu')),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: onMessage,
                icon: const Icon(Icons.chat_bubble_outline, size: 16),
                label: Text(t('Message', 'Tuma Ujumbe')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
