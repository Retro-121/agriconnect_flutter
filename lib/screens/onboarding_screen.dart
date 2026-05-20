import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_config.dart';
import '../theme.dart';
import '../widgets/phone_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // ── Step tracking ─────────────────────────────────────────
  // Step 0: Language
  // Step 1: Role Selection (Farmer vs Service Provider)
  // Step 2 (Farmer): Farm Details
  // Step 3 (Farmer): Location
  int _step = 0;

  // ── Prefs ─────────────────────────────────────────────────
  String _language = 'English';
  String _userRole = ''; // 'Farmer' or 'Service Provider'
  String _farmType = 'Farming';
  String _farmLocation = '';
  bool _locationGranted = false;
  bool _locationLoading = false;

  final TextEditingController _acresController = TextEditingController();
  final TextEditingController _animalsController = TextEditingController();
  final TextEditingController _cattleTypeController = TextEditingController();
  final TextEditingController _cropsController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  @override
  void dispose() {
    _acresController.dispose();
    _animalsController.dispose();
    _cattleTypeController.dispose();
    _cropsController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _language = prefs.getString('language') ?? 'English';
      _userRole = prefs.getString('userRole') ?? '';
      _farmType = prefs.getString('farmType') ?? 'Farming';
      _acresController.text = prefs.getString('farmAcres') ?? '';
      _animalsController.text = prefs.getString('farmAnimals') ?? '';
      _cattleTypeController.text = prefs.getString('cattleType') ?? '';
      _cropsController.text = prefs.getString('cropTypes') ?? '';
      _farmLocation = prefs.getString('farmLocation') ?? '';
      _locationController.text = _farmLocation;
    });
  }

  // ── Translations ──────────────────────────────────────────
  String t(String en, String sw) => _language == 'Kiswahili' ? sw : en;

  // ── Location ──────────────────────────────────────────────
  Future<void> _requestLocation() async {
    setState(() => _locationLoading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        _showSnack(t('Location permission denied. Please type manually.', 'Ruhusa imekataliwa. Tafadhali andika.'));
        setState(() => _locationLoading = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('farmLat', position.latitude);
      await prefs.setDouble('farmLon', position.longitude);

      String resolvedName = 'Lat: ${position.latitude.toStringAsFixed(2)}, Lon: ${position.longitude.toStringAsFixed(2)}';
      try {
        final apiKey = ApiConfig.weatherApiKey;
        final url = 'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric';
        final res = await http.get(Uri.parse(url));
        if (res.statusCode == 200) {
          final data = json.decode(res.body);
          if (data['name'] != null && data['name'].toString().isNotEmpty) {
            resolvedName = data['name'].toString();
          }
        }
      } catch (e) {
        debugPrint('Geocoding error: $e');
      }

      setState(() {
        _locationGranted = true;
        _farmLocation = resolvedName;
        _locationController.text = _farmLocation;
      });
    } catch (e) {
      _showSnack(t('Error fetching location.', 'Hitilafu kupata eneo.'));
    } finally {
      if (mounted) {
        setState(() => _locationLoading = false);
      }
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Save & finish ─────────────────────────────────────────
  Future<void> _completeSetup() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', _language);
    await prefs.setString('userRole', _userRole);
    
    if (_userRole == 'Farmer') {
      await prefs.setString('farmType', _farmType);
      await prefs.setString('farmAcres', _acresController.text);
      await prefs.setString('farmAnimals', _animalsController.text);
      await prefs.setString('cattleType', _cattleTypeController.text);
      await prefs.setString('cropTypes', _cropsController.text);
      await prefs.setString('farmLocation',
          _locationController.text.isNotEmpty ? _locationController.text : _farmLocation);
    }
    
    await prefs.setBool('hasOnboarded', true);
    
    if (!mounted) return;
    
    if (_userRole == 'Service Provider') {
      Navigator.pushReplacementNamed(context, '/provider-type-selection');
    } else {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  bool get _farmDetailsValid {
    if (_farmType == 'Farming') return _acresController.text.trim().isNotEmpty && _cropsController.text.trim().isNotEmpty;
    if (_farmType == 'Livestock') return _animalsController.text.trim().isNotEmpty;
    if (_farmType == 'Both') {
      return _acresController.text.trim().isNotEmpty &&
          _animalsController.text.trim().isNotEmpty &&
          _cropsController.text.trim().isNotEmpty;
    }
    return false;
  }

  int get _totalSteps => _userRole == 'Service Provider' ? 2 : 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/backgrounds/bg_field.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: DynamicBackgroundOverlay()),
            SafeArea(
          child: Column(
            children: [
              // ── Progress indicator ───────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  children: List.generate(_totalSteps, (i) => Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: i <= _step
                            ? Colors.white
                            : Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  )),
                ),
              ),

              const SizedBox(height: 8),

              // ── Step label ───────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    t('Step ${_step + 1} of $_totalSteps', 'Hatua ${_step + 1} ya $_totalSteps'),
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
              ),

              // ── Scrollable content ───────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _buildStep(),
                ),
              ),

              // ── Navigation buttons ───────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    if (_step > 0)
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white38),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () => setState(() => _step--),
                          child: Text(t('Back', 'Rudi')),
                        ),
                      ),
                    if (_step > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: leaf,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _canAdvance() ? _advance : null,
                        child: Text(
                          (_step == _totalSteps - 1)
                              ? t('Finish Setup ✨', 'Kamilisha ✨')
                              : t('Next →', 'Endelea →'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
          ],
        ),
      ),
    );
  }

  bool _canAdvance() {
    if (_step == 0) return true;
    if (_step == 1) return _userRole.isNotEmpty;
    if (_step == 2) return _farmDetailsValid;
    if (_step == 3) return true;
    return false;
  }

  void _advance() {
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
    } else {
      _completeSetup();
    }
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _stepLanguage();
      case 1:
        return _stepRoleSelection();
      case 2:
        return _stepFarmDetails();
      case 3:
        return _stepLocation();
      default:
        return const SizedBox.shrink();
    }
  }

  // ── Step 0: Language ──────────────────────────────────────
  Widget _stepLanguage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🌍', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        const Text(
          'Choose Language\nChagua Lugha',
          style: TextStyle(
              color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, height: 1.3),
        ),
        const SizedBox(height: 8),
        const Text(
          'Select your preferred language for the app.\nChagua lugha unayopendelea kwa programu.',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 32),
        _langCard('English', '🇬🇧', 'English — International'),
        const SizedBox(height: 16),
        _langCard('Kiswahili', '🇹🇿', 'Kiswahili — Afrika Mashariki'),
      ],
    );
  }

  Widget _langCard(String lang, String flag, String label) {
    final selected = _language == lang;
    return GestureDetector(
      onTap: () => setState(() => _language = lang),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? Colors.white : Colors.white24, width: 2),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lang,
                    style: TextStyle(
                        color: selected ? leaf : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Text(label,
                    style: TextStyle(
                        color: selected ? leaf.withOpacity(0.7) : Colors.white60,
                        fontSize: 12)),
              ],
            ),
            const Spacer(),
            if (selected)
              const Icon(Icons.check_circle, color: leaf, size: 24),
          ],
        ),
      ),
    );
  }

  // ── Step 1: Role Selection ────────────────────────────────
  Widget _stepRoleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('👤', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        Text(
          t('How will you use AgriConnect?', 'Utatumiaje AgriConnect?'),
          style: const TextStyle(
              color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          t('Choose your primary role on the platform.', 'Chagua jukumu lako kuu kwenye jukwaa.'),
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 32),
        _roleCard(
          'Farmer',
          Icons.agriculture,
          t('I am a Farmer', 'Mimi ni Mkulima'),
          t('Manage crops, livestock, and get AI advice.', 'Simamia mazao, mifugo, na pata ushauri wa AI.'),
          AppColors.lime,
        ),
        const SizedBox(height: 16),
        _roleCard(
          'Service Provider',
          Icons.business_center,
          t('I am a Service Provider', 'Mimi ni Mtoa Huduma'),
          t('Offer products, veterinary services, or equipment.', 'Toa bidhaa, huduma za mifugo, au vifaa.'),
          AppColors.amber,
        ),
      ],
    );
  }

  Widget _roleCard(String role, IconData icon, String title, String subtitle, Color color) {
    final selected = _userRole == role;
    return GestureDetector(
      onTap: () => setState(() => _userRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? Colors.white : Colors.white24, width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: selected ? color.withOpacity(0.2) : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: selected ? leaf : Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: selected ? leaf : Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style: TextStyle(
                          color: selected ? leaf.withOpacity(0.7) : Colors.white60,
                          fontSize: 12)),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: leaf, size: 24),
          ],
        ),
      ),
    );
  }

  // ── Step 2: Farm Details (For Farmers) ───────────────────
  Widget _stepFarmDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🌾', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        Text(
          t('Tell us about your farm', 'Tuambie kuhusu shamba lako'),
          style: const TextStyle(
              color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          t('This helps the AI give you personalized advice.',
              'Hii husaidia AI kukupa ushauri unaofaa.'),
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 28),

        // Farm type
        Text(t('What do you primarily do?', 'Unafanya nini zaidi?'),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.all(4),
          child: SegmentedButton<String>(
            segments: [
              ButtonSegment(
                  value: 'Farming',
                  label: Text(t('Crops', 'Mazao')),
                  icon: const Icon(Icons.grass)),
              ButtonSegment(
                  value: 'Livestock',
                  label: Text(t('Livestock', 'Mifugo')),
                  icon: const Icon(Icons.pets)),
              ButtonSegment(
                  value: 'Both',
                  label: Text(t('Both', 'Vyote')),
                  icon: const Icon(Icons.agriculture)),
            ],
            selected: {_farmType},
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return Colors.white;
                return Colors.transparent;
              }),
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return leaf;
                return Colors.white70;
              }),
            ),
            onSelectionChanged: (s) => setState(() {
              _farmType = s.first;
            }),
          ),
        ),

        const SizedBox(height: 24),

        if (_farmType == 'Farming' || _farmType == 'Both') ...[
          _whiteField(
            _acresController,
            t('How many acres?', 'Ekari ngapi?'),
            t('e.g. 5', 'mf. 5'),
            TextInputType.number,
            Icons.landscape,
            t('Acres', 'Ekari'),
          ),
          const SizedBox(height: 16),
          _whiteField(
            _cropsController,
            t('What crops do you plant?', 'Unapanda mazao gani?'),
            t('e.g. Maize, Beans, Coffee', 'mf. Mahindi, Maharage, Kahawa'),
            TextInputType.text,
            Icons.eco,
            null,
          ),
          const SizedBox(height: 16),
        ],

        if (_farmType == 'Livestock' || _farmType == 'Both') ...[
          _whiteField(
            _animalsController,
            t('Number of animals', 'Idadi ya wanyama'),
            t('e.g. 20', 'mf. 20'),
            TextInputType.number,
            Icons.pets,
            null,
          ),
          const SizedBox(height: 16),
          _whiteField(
            _cattleTypeController,
            t('Type of livestock', 'Aina ya mifugo'),
            t('e.g. Dairy Cows, Goats', 'mf. Ng\'ombe wa Maziwa, Mbuzi'),
            TextInputType.text,
            Icons.category_outlined,
            null,
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _whiteField(
    TextEditingController ctrl,
    String label,
    String hint,
    TextInputType type,
    IconData icon,
    String? suffix,
  ) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        suffixText: suffix,
        suffixStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white60),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white38),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
      ),
    );
  }

  // ── Step 3: Location (For Farmers) ───────────────────────
  Widget _stepLocation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('📍', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        Text(
          t('Where is your farm?', 'Shamba lako liko wapi?'),
          style: const TextStyle(
              color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          t('Location helps us give accurate weather & market data.\nThis is optional — you can skip.',
              'Eneo husaidia kupata hali ya hewa na bei sahihi.\nHii ni hiari — unaweza kuruka.'),
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 32),

        // Auto-detect button
        GestureDetector(
          onTap: _locationLoading ? null : _requestLocation,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _locationGranted
                  ? Colors.white
                  : Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _locationGranted ? Colors.white : Colors.white24,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _locationGranted
                        ? leaf.withOpacity(0.15)
                        : Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: _locationLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Icon(
                          _locationGranted
                              ? Icons.my_location
                              : Icons.location_searching,
                          color: _locationGranted ? leaf : Colors.white,
                          size: 24,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _locationGranted
                            ? t('Location detected!', 'Eneo limepatikana!')
                            : t('Use my GPS location', 'Tumia GPS yangu'),
                        style: TextStyle(
                          color: _locationGranted ? leaf : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _locationGranted
                            ? _farmLocation
                            : t('Tap to detect automatically',
                                'Gusa kugundua kiotomatiki'),
                        style: TextStyle(
                          color: _locationGranted
                              ? leaf.withOpacity(0.7)
                              : Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),
        Text(t('— or type it manually —', '— au andika kwa mkono —'),
            style: const TextStyle(color: Colors.white38, fontSize: 12),
            textAlign: TextAlign.center),
        const SizedBox(height: 12),

        _whiteField(
          _locationController,
          t('Farm location', 'Eneo la shamba'),
          t('e.g. Arusha, Tanzania', 'mf. Arusha, Tanzania'),
          TextInputType.text,
          Icons.place_outlined,
          null,
        ),

        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white54, size: 16),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  t('Your location is stored only on your device and is never shared.',
                      'Eneo lako linahifadhiwa kwenye kifaa chako tu na haishirikiwa na mtu yeyote.'),
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}