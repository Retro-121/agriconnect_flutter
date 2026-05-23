import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import '../widgets/phone_shell.dart';
import '../widgets/profile_avatar.dart';
import '../theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = '';
  String _profileImageUrl = '';
  String _farmAcres = '0';
  String _farmAnimals = '0';
  String _farmType = 'Farming';
  String _serviceCategory = 'General Service';
  String _farmLocation = 'Tanzania';
  String _language = 'English';
  bool _offlineMode = false;
  String _userRole = 'Farmer';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'Farmer';
      _profileImageUrl = prefs.getString('profileImageUrl') ?? '';
      _farmAcres = prefs.getString('farmAcres') ?? '0';
      _farmAnimals = prefs.getString('farmAnimals') ?? '0';
      _farmType = prefs.getString('farmType') ?? 'Farming';
      _serviceCategory = prefs.getString('serviceCategory') ?? 'General Service';
      _farmLocation = prefs.getString('farmLocation') ?? 'Tanzania';
      _language = prefs.getString('language') ?? 'English';
      _offlineMode = prefs.getBool('offlineMode') ?? false;
      _userRole = prefs.getString('userRole') ?? 'Farmer';
    });
  }

  // ── Sign Out ────────────────────────────────────────────────
  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
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
      // Ignore sign out failures and continue clearing local state.
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  // ── Offline Toggle ──────────────────────────────────────────
  Future<void> _toggleOffline() async {
    final prefs = await SharedPreferences.getInstance();
    final newVal = !_offlineMode;
    await prefs.setBool('offlineMode', newVal);
    setState(() => _offlineMode = newVal);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(newVal
            ? (_language == 'Kiswahili' ? 'Hali ya Nje ya Mtandao Imewashwa' : 'Offline Mode Enabled')
            : (_language == 'Kiswahili' ? 'Hali ya Nje ya Mtandao Imezimwa' : 'Offline Mode Disabled')),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Change Profile Picture ──────────────────────────────────
  Future<void> _changeProfilePicture() async {
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(_language == 'Kiswahili' ? 'Badilisha Picha' : 'Change Profile Picture'),
        content: const Text('Choose an option'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'cancel'),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: leaf,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, 'camera'),
            icon: const Icon(Icons.camera_alt),
            label: Text(_language == 'Kiswahili' ? 'Kamera' : 'Camera'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: leaf,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, 'gallery'),
            icon: const Icon(Icons.photo_library),
            label: Text(_language == 'Kiswahili' ? 'Picha' : 'Gallery'),
          ),
        ],
      ),
    );

    if (result == null || result == 'cancel') return;

    try {
      final picker = ImagePicker();
      XFile? pickedFile;

      if (result == 'camera') {
        pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
      } else if (result == 'gallery') {
        pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      }

      if (pickedFile != null && mounted) {
        // Read image as bytes and convert to base64
        final bytes = await pickedFile.readAsBytes();
        final base64Image = base64Encode(bytes);

        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profileImageUrl', 'data:image/png;base64,$base64Image');

        setState(() => _profileImageUrl = 'data:image/png;base64,$base64Image');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_language == 'Kiswahili' ? 'Picha Imetengenezwa' : 'Profile picture updated'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_language == 'Kiswahili' ? 'Hitilafu na kukamatia picha' : 'Error picking image'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ── Language Picker ─────────────────────────────────────────
  Future<void> _changeLanguage() async {
    String selected = _language;
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Select Language / Chagua Lugha'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['English', 'Kiswahili'].map((lang) => RadioListTile<String>(
              title: Text(lang),
              value: lang,
              groupValue: selected,
              activeColor: leaf,
              onChanged: (v) => setS(() => selected = v!),
            )).toList(),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: leaf, foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(ctx, selected),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (result == null || !mounted) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', result);
    setState(() => _language = result);
  }

  // ── Farm Settings Editor ────────────────────────────────────
  Future<void> _editFarmSettings() async {
    final acresCtrl = TextEditingController(text: _farmAcres);
    final animalsCtrl = TextEditingController(text: _farmAnimals);
    final locationCtrl = TextEditingController(text: _farmLocation);
    String farmType = _farmType;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _language == 'Kiswahili' ? 'Mipangilio ya Shamba' : 'Farm Settings',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Farming', label: Text('Crops'), icon: Icon(Icons.grass)),
                  ButtonSegment(value: 'Livestock', label: Text('Livestock'), icon: Icon(Icons.pets)),
                  ButtonSegment(value: 'Both', label: Text('Both'), icon: Icon(Icons.agriculture)),
                ],
                selected: {farmType},
                onSelectionChanged: (s) => setModal(() => farmType = s.first),
              ),
              const SizedBox(height: 16),
              if (farmType == 'Farming' || farmType == 'Both') ...[
                TextField(
                  controller: acresCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: _language == 'Kiswahili' ? 'Ekari za Shamba' : 'Farm Acres',
                    suffixText: _language == 'Kiswahili' ? 'Ekari' : 'Acres',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.landscape),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (farmType == 'Livestock' || farmType == 'Both') ...[
                TextField(
                  controller: animalsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: _language == 'Kiswahili' ? 'Idadi ya Wanyama' : 'Number of Animals',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.pets),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: locationCtrl,
                decoration: InputDecoration(
                  labelText: _language == 'Kiswahili' ? 'Eneo la Shamba' : 'Farm Location',
                  hintText: 'e.g. Arusha, Tanzania',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: leaf,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('farmAcres', acresCtrl.text);
                    await prefs.setString('farmAnimals', animalsCtrl.text);
                    await prefs.setString('farmType', farmType);
                    await prefs.setString('farmLocation', locationCtrl.text);
                    setState(() {
                      _farmAcres = acresCtrl.text;
                      _farmAnimals = animalsCtrl.text;
                      _farmType = farmType;
                      _farmLocation = locationCtrl.text;
                    });
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: Text(_language == 'Kiswahili' ? 'Hifadhi Mabadiliko' : 'Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editProviderSettings() async {
    final nameCtrl = TextEditingController(text: _userName);
    final locationCtrl = TextEditingController(text: _farmLocation);
    final categoryCtrl = TextEditingController(text: _serviceCategory);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _language == 'Kiswahili' ? 'Mipangilio ya Mtoa Huduma' : 'Provider Settings',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: _language == 'Kiswahili' ? 'Jina lako' : 'Your Name',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationCtrl,
                decoration: InputDecoration(
                  labelText: _language == 'Kiswahili' ? 'Eneo la Huduma' : 'Service Location',
                  hintText: 'e.g. Arusha, Tanzania',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: categoryCtrl,
                decoration: InputDecoration(
                  labelText: _language == 'Kiswahili' ? 'Aina ya Huduma' : 'Service Category',
                  hintText: 'e.g. Veterinary, Equipment',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.business_center),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: leaf,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('userName', nameCtrl.text);
                    await prefs.setString('farmLocation', locationCtrl.text);
                    await prefs.setString('serviceCategory', categoryCtrl.text.isNotEmpty ? categoryCtrl.text : 'General Service');
                    setState(() {
                      _userName = nameCtrl.text;
                      _farmLocation = locationCtrl.text;
                      _serviceCategory = categoryCtrl.text.isNotEmpty ? categoryCtrl.text : 'General Service';
                    });
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: Text(_language == 'Kiswahili' ? 'Hifadhi Mabadiliko' : 'Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final parts = _userName.trim().split(' ');
    final initials = parts
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    return PhoneShell(
      title: _language == 'Kiswahili' ? 'Wasifu' : 'Profile',
      showBack: true,
      showThemeToggle: true,
      bgImage: 'assets/backgrounds/bg-profile.jpg',
      bgImageDark: 'assets/backgrounds/bg-profile-dark.jpg',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          children: [
            // ── Profile Hero Card ──────────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [leaf, Color(0xFF1F5A38)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(color: leaf.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _changeProfilePicture,
                    child: Stack(
                      children: [
                        ProfileAvatar(
                          radius: 40,
                          imageUrl: _profileImageUrl.isNotEmpty ? _profileImageUrl : null,
                          initials: initials.isEmpty ? 'F' : initials,
                          backgroundColor: Colors.white24,
                          iconColor: Colors.white,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)],
                            ),
                            child: const Icon(Icons.camera_alt, size: 16, color: Color(0xFF1F5A38)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _userName,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    _userRole == 'Service Provider'
                        ? '${_farmLocation.isNotEmpty ? _farmLocation : "Tanzania"} · ${_language == 'Kiswahili' ? 'Mtoa Huduma' : 'Service Provider'}'
                        : '${_farmLocation.isNotEmpty ? _farmLocation : "Tanzania"} · $_farmType',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  Row(children: [
                    if (_userRole == 'Service Provider') ...[
                      _stat(_language == 'Kiswahili' ? 'Jukumu' : 'Role', _language == 'Kiswahili' ? 'Mtoa Huduma' : 'Provider'),
                      _stat(_language == 'Kiswahili' ? 'Hali' : 'Status', _language == 'Kiswahili' ? 'Imesawazishwa' : 'Synced'),
                      _stat(_language == 'Kiswahili' ? 'Lugha' : 'Language', _language == 'Kiswahili' ? 'SW' : 'EN'),
                    ] else ...[
                      _stat(_language == 'Kiswahili' ? 'Ekari' : 'Acres', _farmAcres),
                      _stat(_language == 'Kiswahili' ? 'Wanyama' : 'Animals', _farmAnimals),
                      _stat(_language == 'Kiswahili' ? 'Lugha' : 'Language',
                          _language == 'Kiswahili' ? 'SW' : 'EN'),
                    ]
                  ]),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Settings List ──────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                children: [
                  _tile(
                    Icons.language,
                    _language == 'Kiswahili' ? 'Lugha' : 'Language',
                    _language,
                    _changeLanguage,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  SwitchListTile(
                    secondary: Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.wifi_off, size: 18),
                    ),
                    title: Text(
                      _language == 'Kiswahili' ? 'Hali ya Nje ya Mtandao' : 'Offline Mode',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      _offlineMode
                          ? (_language == 'Kiswahili' ? 'Imewashwa' : 'Enabled')
                          : (_language == 'Kiswahili' ? 'Imezimwa' : 'Disabled'),
                      style: const TextStyle(fontSize: 11),
                    ),
                    value: _offlineMode,
                    activeColor: leaf,
                    onChanged: (_) => _toggleOffline(),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                   _userRole == 'Service Provider'
                      ? _tile(
                          Icons.settings,
                          _language == 'Kiswahili' ? 'Mipangilio ya Mtoa Huduma' : 'Provider Settings',
                          _farmLocation,
                          _editProviderSettings,
                        )
                      : _tile(
                          Icons.settings,
                          _language == 'Kiswahili' ? 'Mipangilio ya Shamba' : 'Farm Settings',
                          '$_farmAcres ${_language == 'Kiswahili' ? 'Ekari' : 'Acres'} · $_farmAnimals ${_language == 'Kiswahili' ? 'Wanyama' : 'Animals'}',
                          _editFarmSettings,
                        ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _tile(
                    Icons.help_outline,
                    _language == 'Kiswahili' ? 'Msaada na Usaidizi' : 'Help & Support',
                    '',
                    () => Navigator.pushNamed(context, '/help'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Sign Out ───────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: _signOut,
                icon: const Icon(Icons.logout, color: Colors.red),
                label: Text(
                  _language == 'Kiswahili' ? 'Toka' : 'Sign Out',
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(IconData icon, String title, String subtitle, VoidCallback onTap) =>
      ListTile(
        leading: Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18),
        ),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        subtitle: subtitle.isEmpty ? null : Text(subtitle, style: const TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      );

  Widget _stat(String l, String v) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: [
            Text(v, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(l, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ]),
        ),
      );
}
