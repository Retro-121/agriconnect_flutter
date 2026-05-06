import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String _farmType = 'Farming';

  final TextEditingController _acresController = TextEditingController();
  final TextEditingController _animalsController = TextEditingController();
  final TextEditingController _cattleTypeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _farmType = prefs.getString('farmType') ?? 'Farming';
      _acresController.text = prefs.getString('farmAcres') ?? '';
      _animalsController.text = prefs.getString('farmAnimals') ?? '';
      _cattleTypeController.text = prefs.getString('cattleType') ?? '';
    });
  }

  void _completeSetup() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('farmType', _farmType);
    await prefs.setString('farmAcres', _acresController.text);
    await prefs.setString('farmAnimals', _animalsController.text);
    await prefs.setString('cattleType', _cattleTypeController.text);
    await prefs.setBool('hasOnboarded', true);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/');
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  bool get _isValid {
    if (_farmType == 'Farming') {
      return _acresController.text.trim().isNotEmpty;
    }
    if (_farmType == 'Livestock') {
      return _animalsController.text.trim().isNotEmpty;
    }
    if (_farmType == 'Both') {
      return _acresController.text.trim().isNotEmpty &&
          _animalsController.text.trim().isNotEmpty;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Setup'),
        backgroundColor: leaf,
        foregroundColor: Colors.white,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Welcome to AgriConnect Pro!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Let us know a bit about your farm to personalize your experience.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 32),

              const Text(
                'What do you primarily do?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),

              // =========================
              // SEGMENTED BUTTON FIXED
              // =========================
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                      value: 'Farming',
                      label: Text('Crops'),
                      icon: Icon(Icons.grass)),
                  ButtonSegment(
                      value: 'Livestock',
                      label: Text('Livestock'),
                      icon: Icon(Icons.pets)),
                  ButtonSegment(
                      value: 'Both',
                      label: Text('Both'),
                      icon: Icon(Icons.agriculture)),
                ],
                selected: {_farmType},
                onSelectionChanged: (Set<String> newSelection) async {
                  final prefs = await SharedPreferences.getInstance();
                  final selected = newSelection.first;

                  setState(() {
                    _farmType = selected;

                    // Smart defaults
                    if (selected == 'Farming' &&
                        _acresController.text.isEmpty) {
                      _acresController.text = '1';
                    }

                    if (selected == 'Livestock' &&
                        _animalsController.text.isEmpty) {
                      _animalsController.text = '5';
                    }

                    if (selected == 'Both') {
                      if (_acresController.text.isEmpty) {
                        _acresController.text = '1';
                      }
                      if (_animalsController.text.isEmpty) {
                        _animalsController.text = '5';
                      }
                    }
                  });

                  await prefs.setString('farmType', selected);
                },
              ),

              const SizedBox(height: 32),

              // =========================
              // FARMING INPUT
              // =========================
              if (_farmType == 'Farming' || _farmType == 'Both') ...[
                const Text('How many acres is your farm?',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: _acresController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('farmAcres', value);
                    setState(() {});
                  },
                  decoration: const InputDecoration(
                    hintText: 'e.g. 5',
                    border: OutlineInputBorder(),
                    suffixText: 'Acres',
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // =========================
              // LIVESTOCK INPUT
              // =========================
              if (_farmType == 'Livestock' || _farmType == 'Both') ...[
                const Text('How many animals do you have?',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: _animalsController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('farmAnimals', value);
                    setState(() {});
                  },
                  decoration: const InputDecoration(
                    hintText: 'e.g. 20',
                    border: OutlineInputBorder(),
                    suffixText: 'Animals',
                  ),
                ),
                const SizedBox(height: 16),
                const Text('What type of cattle do you keep?',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: _cattleTypeController,
                  onChanged: (value) async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('cattleType', value);
                    setState(() {});
                  },
                  decoration: const InputDecoration(
                    hintText: 'e.g. Dairy Cows, Beef Cattle',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              const SizedBox(height: 32),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: leaf,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _isValid ? _completeSetup : null,
                child: const Text(
                  'Complete Setup',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}