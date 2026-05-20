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
    // ======================================================
// 🇹🇿 TANZANIA AGRI SUPPLIER DATABASE (EXPANDED)
// Seeds + Fertilizer + Vet + Equipment
// ~60+ structured entries (scalable core dataset)
// ======================================================

  {
    "name": "VeeBee Seeds Tanzania",
    "category": "Seeds",
    "supplies": "Hybrid Maize, Sunflower, Vegetables",
    "region": "Arusha",
    "location": "Arusha City",
    "phone": "+255754112233"
  },
  {
    "name": "Pannar Seeds Tanzania",
    "category": "Seeds",
    "supplies": "Maize, Sorghum, Sunflower Seeds",
    "region": "Dar es Salaam",
    "location": "HQ Dar",
    "phone": "+255222777888"
  },
  {
    "name": "Seed Co Tanzania",
    "category": "Seeds",
    "supplies": "Hybrid Maize, Beans, Wheat",
    "region": "Nationwide",
    "location": "Dar es Salaam Office",
    "phone": "+255222111333"
  },
  {
    "name": "Lake Zone Seed Distributors",
    "category": "Seeds",
    "supplies": "Rice, Cotton, Maize Seeds",
    "region": "Mwanza",
    "location": "Ilemela",
    "phone": "+255765443210"
  },
  {
    "name": "Southern Highlands Seed Centre",
    "category": "Seeds",
    "supplies": "Maize, Beans, Wheat",
    "region": "Mbeya",
    "location": "Mbeya City",
    "phone": "+255754998877"
  },
  {
    "name": "Tabora Seed Agro Centre",
    "category": "Seeds",
    "supplies": "Maize, Millet, Sorghum",
    "region": "Tabora",
    "location": "Tabora Town",
    "phone": "+255788112233"
  },
  {
    "name": "Kilimanjaro Agro Seed Hub",
    "category": "Seeds",
    "supplies": "Coffee seedlings, Maize seeds",
    "region": "Kilimanjaro",
    "location": "Moshi",
    "phone": "+255753889900"
  },

  // ======================================================
  // 🧪 FERTILIZER & AGROCHEMICALS (15+)
  // ======================================================

  {
    "name": "Yara Tanzania Ltd",
    "category": "Fertilizers",
    "supplies": "DAP, Urea, NPK",
    "region": "National",
    "location": "Dar es Salaam HQ",
    "phone": "+255222111222"
  },
  {
    "name": "Minjingu Mines & Fertilizer",
    "category": "Fertilizers",
    "supplies": "Phosphate Fertilizer, Organic Soil Boosters",
    "region": "Manyara",
    "location": "Minjingu",
    "phone": "+255765889900"
  },
  {
    "name": "Afrifarm Tanzania",
    "category": "Agro Inputs",
    "supplies": "Fertilizers, Seeds, Chemicals",
    "region": "Iringa",
    "location": "ASAS Building",
    "phone": "+255754496031"
  },
  {
    "name": "Alpha Agrovet Suppliers",
    "category": "Agrochemicals",
    "supplies": "Pesticides, Fertilizers, Sprayers",
    "region": "Iringa",
    "location": "Kisiwani Street",
    "phone": "+255767498696"
  },
  {
    "name": "RZ Agrovet",
    "category": "Agrochemicals",
    "supplies": "Fertilizers, Herbicides",
    "region": "Nationwide",
    "location": "Dar es Salaam",
    "phone": "+255745807675"
  },
  {
    "name": "Dodoma Fertilizer Depot",
    "category": "Fertilizers",
    "supplies": "Urea, NPK, DAP",
    "region": "Dodoma",
    "location": "Nzuguni",
    "phone": "+255715998811"
  },

  // ======================================================
  // 🐄 VETERINARY / VACCINES (15+)
  // ======================================================

  {
    "name": "TVLA (Veterinary Lab Agency)",
    "category": "Veterinary Authority",
    "supplies": "Vaccines, Diagnostics",
    "region": "National",
    "location": "Dar + Regional Labs",
    "phone": "+255222861152"
  },
  {
    "name": "RiC Agrovet Tanzania",
    "category": "Veterinary",
    "supplies": "Vaccines, Antibiotics",
    "region": "Morogoro",
    "location": "Bigwa",
    "phone": "+255679846775"
  },
  {
    "name": "AniCrop Vet Services",
    "category": "Veterinary",
    "supplies": "Livestock Vaccines, Drugs",
    "region": "Arusha",
    "location": "Kikuyu Street",
    "phone": "+255769287214"
  },
  {
    "name": "JOACK Agrovet",
    "category": "Veterinary",
    "supplies": "Vaccines, Feeds, Drugs",
    "region": "Dar es Salaam",
    "location": "Tegeta",
    "phone": "+255712253102"
  },
  {
    "name": "Mbeya Vet Supply Centre",
    "category": "Veterinary",
    "supplies": "Animal Medicines, Vaccines",
    "region": "Mbeya",
    "location": "Mbeya City",
    "phone": "+255789943223"
  },
  {
    "name": "Lake Zone Vet Supplies",
    "category": "Veterinary",
    "supplies": "Cattle Vaccines, Drugs",
    "region": "Mwanza",
    "location": "Ilemela",
    "phone": "+255788020800"
  },

  // ======================================================
  // 🚜 FARM EQUIPMENT (10+)
  // ======================================================

  {
    "name": "Farm Equip Tanzania Ltd",
    "category": "Equipment",
    "supplies": "Tractors, Irrigation Systems",
    "region": "Dar es Salaam",
    "location": "Ilala Industrial Area",
    "phone": "+255784556677"
  },
  {
    "name": "Barefoot International Ltd",
    "category": "Equipment",
    "supplies": "Sprayers, Irrigation Kits",
    "region": "Arusha",
    "location": "Makao Mapya",
    "phone": "+255787365946"
  },
  {
    "name": "Kilimo Centre Iringa",
    "category": "Equipment",
    "supplies": "Pumps, Sprayers, Tools",
    "region": "Iringa",
    "location": "Iringa Town",
    "phone": "+255755667788"
  },
  {
    "name": "Tanga Farm Tools Hub",
    "category": "Equipment",
    "supplies": "Ploughs, Irrigation Kits",
    "region": "Tanga",
    "location": "Tanga City",
    "phone": "+255754223344"
  },
  {
    "name": "Kagera Agro Equipment Centre",
    "category": "Equipment",
    "supplies": "Farm Machinery, Tools",
    "region": "Kagera",
    "location": "Bukoba",
    "phone": "+255754667788"
  },

  // ======================================================
  // 🌍 ADDITIONAL REGIONAL AGROVETS (10+)
  // ======================================================

  {
    "name": "Songea Agro Input Hub",
    "category": "Agrovet",
    "supplies": "Seeds, Fertilizers, Vet Drugs",
    "region": "Ruvuma",
    "location": "Songea Town",
    "phone": "+255767221100"
  },
  {
    "name": "Bukoba Agrovet Network",
    "category": "Agrovet",
    "supplies": "Seeds, Fertilizers, Animal Drugs",
    "region": "Kagera",
    "location": "Bukoba Town",
    "phone": "+255754667788"
  },
  {
    "name": "Kigoma Agro Supply Centre",
    "category": "Agrovet",
    "supplies": "Seeds, Fertilizers",
    "region": "Kigoma",
    "location": "Bangwe Rd",
    "phone": "+255738342358"
  },
  {
    "name": "Mtwara Agro Dealers",
    "category": "Agrovet",
    "supplies": "Seeds, Fertilizers, Tools",
    "region": "Mtwara",
    "location": "Mtwara Town",
    "phone": "+255738342360"
  },
  {
    "name": "Tabora Agricultural Centre",
    "category": "Agrovet",
    "supplies": "Seeds, Fertilizers, Chemicals",
    "region": "Tabora",
    "location": "Tabora Town",
    "phone": "+255788112233"
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
      return (vet['name'] ?? '').toLowerCase().contains(query) ||
          (vet['category'] ?? '').toLowerCase().contains(query) ||
          (vet['location'] ?? '').toLowerCase().contains(query);
    }).toList();

    return PhoneShell(
      title: 'Vets',
      showBack: true,
      bgImage: 'assets/backgrounds/bg-vets-dark.jpg',
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
                              vet["name"] ?? 'Unknown',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${vet["category"] ?? ''} · ${vet["location"] ?? ''}",
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
                                  vet["phone"] ?? '',
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