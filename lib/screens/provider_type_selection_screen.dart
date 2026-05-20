import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import '../provider_types.dart';

class ProviderTypeSelectionScreen extends StatefulWidget {
  const ProviderTypeSelectionScreen({super.key});

  @override
  State<ProviderTypeSelectionScreen> createState() => _ProviderTypeSelectionScreenState();
}

class _ProviderTypeSelectionScreenState extends State<ProviderTypeSelectionScreen> {
  String _language = 'English';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _language = prefs.getString('language') ?? 'English';
    });
  }

  Future<void> _toggleLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    setState(() {
      _language = lang;
    });
  }

  String t(String en, String sw) => _language == 'Kiswahili' ? sw : en;

  String _getLabel(ProviderType type) {
    final isSw = _language == 'Kiswahili';
    return switch (type) {
      ProviderType.vet => isSw ? 'Daktari wa Wanyama' : 'Veterinarian',
      ProviderType.feed => isSw ? 'Lishe ya Mifugo' : 'Feed Supplier',
      ProviderType.seed => isSw ? 'Muuzaji wa Mbegu' : 'Seed Supplier',
      ProviderType.fertilizer => isSw ? 'Muuzaji wa Mbolea' : 'Fertilizer Dealer',
      ProviderType.agrochem => isSw ? 'Dawa za Kilimo' : 'Agrochemicals',
      ProviderType.greenhouse => isSw ? 'Kibanda cha Kijani (Greenhouse)' : 'Greenhouse Tech',
      ProviderType.consultant => isSw ? 'Mshauri wa Kilimo' : 'Consultant',
      ProviderType.transport => isSw ? 'Usafirishaji' : 'Transport',
      ProviderType.equipment => isSw ? 'Zana za Kilimo' : 'Equipment',
      ProviderType.ai => isSw ? 'Mtaalamu wa AI' : 'AI Specialist',
      ProviderType.dairy => isSw ? 'Mtaalamu wa Maziwa' : 'Dairy Expert',
      ProviderType.poultry => isSw ? 'Mtaalamu wa Kuku' : 'Poultry Expert',
    };
  }

  String _getTagline(ProviderType type) {
    final isSw = _language == 'Kiswahili';
    return switch (type) {
      ProviderType.vet => isSw ? 'Afya ya wanyama na majibu ya dharura' : 'Animal health & emergency response',
      ProviderType.feed => isSw ? 'Lishe ya mifugo na vifaa' : 'Livestock nutrition & feed logistics',
      ProviderType.seed => isSw ? 'Mbegu bora na mahitaji ya msimu' : 'Quality seeds & seasonal demand',
      ProviderType.fertilizer => isSw ? 'Virutubisho vya udongo na mazao bora' : 'Soil nutrition & yield optimization',
      ProviderType.agrochem => isSw ? 'Ulinzi wa mazao na kudhibiti wadudu' : 'Crop protection & pest control',
      ProviderType.greenhouse => isSw ? 'Mifumo ya kilimo cha kudhibitiwa' : 'Controlled environment systems',
      ProviderType.consultant => isSw ? 'Ushauri na mkakati wa shamba' : 'Advisory & farm strategy',
      ProviderType.transport => isSw ? 'Logistiki za vijijini' : 'Cold-chain & rural logistics',
      ProviderType.equipment => isSw ? 'Mauzo na huduma za mashine' : 'Machinery sales & service',
      ProviderType.ai => isSw ? 'Mifano na ufahamu wa usahihi' : 'Models & precision insights',
      ProviderType.dairy => isSw ? 'Uzalishaji wa ng\'ombe na ubora wa maziwa' : 'Herd productivity & milk quality',
      ProviderType.poultry => isSw ? 'Afya ya kundi na uzalishaji wa mayai' : 'Flock health & egg production',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(t('Select Your Specialty', 'Chagua Utaalamu Wako')),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.forestDeep,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _toggleLanguage('English'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _language == 'English' ? AppColors.forest : Colors.white,
                      border: Border.all(color: AppColors.forest),
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                    ),
                    child: Text(
                      'EN',
                      style: TextStyle(
                        color: _language == 'English' ? Colors.white : AppColors.forest,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _toggleLanguage('Kiswahili'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _language == 'Kiswahili' ? AppColors.forest : Colors.white,
                      border: Border.all(color: AppColors.forest),
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                    ),
                    child: Text(
                      'SW',
                      style: TextStyle(
                        color: _language == 'Kiswahili' ? Colors.white : AppColors.forest,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: kProviders.length,
        itemBuilder: (context, index) {
          final type = ProviderType.values[index];
          final info = kProviders[type]!;
          return InkWell(
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('providerSpecialty', type.name);
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/service-provider-home');
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black.withOpacity(0.05)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.forest.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(info.icon, color: AppColors.forest, size: 32),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getLabel(type),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.forestDeep,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getTagline(type),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.muted,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
