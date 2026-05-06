import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/phone_shell.dart';
import '../widgets/agri_search_bar.dart';
import '../theme.dart';

class VetsScreen extends StatefulWidget {
  const VetsScreen({super.key});

  @override
  State<VetsScreen> createState() => _VetsScreenState();
}

class _VetsScreenState extends State<VetsScreen> {
  String _searchQuery = '';

  final List<Map<String, String>> _vets = const [
    {
      "name": "TVLA Headquarters",
      "specialty": "National Veterinary Diagnostics",
      "location": "Nelson Mandela Rd, Temeke, Dar es Salaam",
      "phone": "+255222861152"
    },
    {
      "name": "TVLA Arusha Centre",
      "specialty": "Livestock Disease Control & Diagnostics",
      "location": "Arusha City",
      "phone": "+255738342352"
    },
    {
      "name": "TVLA Mwanza Centre",
      "specialty": "Regional Veterinary Laboratory",
      "location": "Isamilo / Makongoro Rd, Mwanza",
      "phone": "+255738342353"
    },
    {
      "name": "TVLA Dodoma Centre",
      "specialty": "Animal Disease Diagnostics",
      "location": "Dodoma City",
      "phone": "+255738342350"
    },
    {
      "name": "TVLA Tanga Centre",
      "specialty": "Livestock Health Services",
      "location": "Tanga City",
      "phone": "+255738342353"
    },
    {
      "name": "TVLA Tabora Centre",
      "specialty": "Veterinary Laboratory Services",
      "location": "Tabora Town",
      "phone": "+255738342355"
    },
    {
      "name": "TVLA Sumbawanga Centre",
      "specialty": "Livestock Disease Control",
      "location": "Rukwa Region",
      "phone": "+255738342357"
    },
    {
      "name": "TVLA Kigoma Centre",
      "specialty": "Animal Diagnostics",
      "location": "Bangwe Rd, Kigoma",
      "phone": "+255738342358"
    },
    {
      "name": "TVLA Mtwara Centre",
      "specialty": "Veterinary Services",
      "location": "Mtwara Region",
      "phone": "+255738342360"
    },
    {
      "name": "Vetzcapes Veterinary Services",
      "specialty": "Livestock & Mobile Farm Vet",
      "location": "Usa River, Arusha",
      "phone": "+255769577782"
    },
    {
      "name": "Nasimz Veterinary Care",
      "specialty": "Cattle & Diagnostics",
      "location": "Ilemela, Mwanza",
      "phone": "+255788020800"
    },
    {
      "name": "Rai Agrovet Clinic",
      "specialty": "Farm Animal Treatment",
      "location": "Mbeya (A104 Road)",
      "phone": "+255789943223"
    }
  ];

  void _callVet(String phone) async {
    final Uri uri = Uri.parse("tel:$phone");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredVets = _vets.where((vet) {
      final query = _searchQuery.toLowerCase();
      return vet['name']!.toLowerCase().contains(query) ||
          vet['specialty']!.toLowerCase().contains(query) ||
          vet['location']!.toLowerCase().contains(query);
    }).toList();

    return PhoneShell(
      title: 'Vets',
      showBack: true,
      bgImage: 'assets/backgrounds/bg-vets.jpg',
      bgImageDark: 'assets/backgrounds/bg-vets-dark.jpg',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            AgriSearchBar(
              hintText: 'Search vets by name or location...',
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredVets.length,
              itemBuilder: (context, index) {
                final vet = filteredVets[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: leaf,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.medical_services, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vet["name"]!,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${vet["specialty"]} · ${vet["location"]}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.phone, size: 14, color: harvest),
                                const SizedBox(width: 4),
                                Text(
                                  vet["phone"]!,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _callVet(vet["phone"]!),
                        icon: const Icon(Icons.call, color: leaf),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}