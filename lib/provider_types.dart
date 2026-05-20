import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ProviderType { vet, feed, seed, fertilizer, agrochem, greenhouse, consultant, transport, equipment, ai, dairy, poultry }

class ProviderInfo {
  final String label;
  final IconData icon;
  final String tagline;
  const ProviderInfo(this.label, this.icon, this.tagline);
}

const Map<ProviderType, ProviderInfo> kProviders = {
  ProviderType.vet:        ProviderInfo('Veterinarian',      Icons.medical_services, 'Animal health & emergency response'),
  ProviderType.feed:       ProviderInfo('Feed Supplier',     Icons.grass,             'Livestock nutrition & feed logistics'),
  ProviderType.seed:       ProviderInfo('Seed Supplier',     Icons.eco,               'Quality seeds & seasonal demand'),
  ProviderType.fertilizer: ProviderInfo('Fertilizer Dealer', Icons.science,           'Soil nutrition & yield optimization'),
  ProviderType.agrochem:   ProviderInfo('Agrochemicals',     Icons.bug_report,        'Crop protection & pest control'),
  ProviderType.greenhouse: ProviderInfo('Greenhouse Tech',   Icons.spa,               'Controlled environment systems'),
  ProviderType.consultant: ProviderInfo('Consultant',        Icons.psychology,        'Advisory & farm strategy'),
  ProviderType.transport:  ProviderInfo('Transport',         Icons.local_shipping,    'Cold-chain & rural logistics'),
  ProviderType.equipment:  ProviderInfo('Equipment',         Icons.build,             'Machinery sales & service'),
  ProviderType.ai:         ProviderInfo('AI Specialist',     Icons.memory,            'Models & precision insights'),
  ProviderType.dairy:      ProviderInfo('Dairy Expert',      Icons.local_drink,       'Herd productivity & milk quality'),
  ProviderType.poultry:    ProviderInfo('Poultry Expert',    Icons.egg,               'Flock health & egg production'),
};

class ProviderState extends ChangeNotifier {
  ProviderType _type = ProviderType.feed;
  ProviderType get type => _type;
  ProviderInfo get info => kProviders[_type]!;

  ProviderState() {
    _loadType();
  }

  Future<void> _loadType() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('providerSpecialty');
    if (saved != null) {
      final t = ProviderType.values.firstWhere((e) => e.name == saved, orElse: () => ProviderType.feed);
      _type = t;
      notifyListeners();
    }
  }

  void set(ProviderType t) async {
    _type = t;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('providerSpecialty', t.name);
  }
}
