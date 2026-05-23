import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/phone_shell.dart';
import '../widgets/agri_search_bar.dart';
import '../theme.dart';

class CattleGroup {
  final String category; // e.g. Dairy, Beef, Calves
  int totalCount;
  int vaccinatedCount;
  double healthScore; // 0.0 to 1.0
  int deathCount;

  CattleGroup({
    required this.category,
    this.totalCount = 0,
    this.vaccinatedCount = 0,
    this.healthScore = 1.0,
    this.deathCount = 0,
  });

  Map<String, dynamic> toJson() => {
        'category': category,
        'totalCount': totalCount,
        'vaccinatedCount': vaccinatedCount,
        'healthScore': healthScore,
        'deathCount': deathCount,
      };

  factory CattleGroup.fromJson(Map<String, dynamic> json) => CattleGroup(
        category: json['category'] ?? '',
        totalCount: json['totalCount'] ?? 0,
        vaccinatedCount: json['vaccinatedCount'] ?? 0,
        healthScore: (json['healthScore'] ?? 1.0).toDouble(),
        deathCount: json['deathCount'] ?? 0,
      );
}

class LivestockScreen extends StatefulWidget {
  const LivestockScreen({super.key});

  @override
  State<LivestockScreen> createState() => _LivestockScreenState();
}

class _LivestockScreenState extends State<LivestockScreen> {
  String _searchQuery = '';
  final List<CattleGroup> _livestock = [];
  double _farmAcres = 0.0;

  @override
  void initState() {
    super.initState();
    _loadLivestock();
    _loadAcres();
  }

  Future<void> _loadLivestock() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('livestock_data');
    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      setState(() {
        _livestock.clear();
        _livestock.addAll(jsonList.map((e) => CattleGroup.fromJson(e)).toList());
      });
    }
  }

  Future<void> _loadAcres() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _farmAcres = prefs.getDouble('farm_acres') ?? 0.0;
    });
  }

  Future<void> _saveAcres() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('farm_acres', _farmAcres);
  }

  Future<void> _editAcres() async {
    final acresController = TextEditingController(text: _farmAcres > 0 ? _farmAcres.toString() : '');
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Farm Size'),
        content: TextField(
          controller: acresController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Acres',
            hintText: 'Enter farm size in acres',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(acresController.text.trim());
              if (value != null) {
                setState(() {
                  _farmAcres = value;
                });
                _saveAcres();
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveLivestock() async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(_livestock.map((e) => e.toJson()).toList());
    await prefs.setString('livestock_data', data);
    await _updateAiSummary();
  }

  Future<void> _updateAiSummary() async {
    final prefs = await SharedPreferences.getInstance();
    final summary = _livestock.isEmpty 
      ? 'No livestock groups added.' 
      : _livestock.map((g) => '${g.category}: ${g.totalCount} head, ${(g.healthScore * 100).round()}% health').join('; ');
    await prefs.setString('livestock_summary', summary);
  }

  void _addCattleCategory() async {
    final categoryController = TextEditingController();
    int count = 1;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Cattle Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: 'Category (e.g. Dairy Cow, Beef)'),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Initial Count'),
              keyboardType: TextInputType.number,
              onChanged: (val) => count = int.tryParse(val) ?? 1,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (categoryController.text.isNotEmpty) {
                setState(() {
                  _livestock.add(CattleGroup(
                    category: categoryController.text,
                    totalCount: count,
                  ));
                });
                _saveLivestock();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _editStats(CattleGroup group) async {
    final countController = TextEditingController(text: group.totalCount.toString());
    final vacController = TextEditingController(text: group.vaccinatedCount.toString());
    final deathController = TextEditingController(text: group.deathCount.toString());

    double calculateHealth() {
      int tCount = int.tryParse(countController.text) ?? group.totalCount;
      int vCount = int.tryParse(vacController.text) ?? group.vaccinatedCount;
      int dCount = int.tryParse(deathController.text) ?? group.deathCount;

      int effectiveTotal = tCount + dCount;
      if (effectiveTotal <= 0) return 1.0;

      double deathPenalty = dCount / effectiveTotal;
      double unvacPenalty = tCount > 0 ? ((tCount - vCount).clamp(0, tCount) / tCount) * 0.3 : 0.0;
      return (1.0 - deathPenalty - unvacPenalty).clamp(0.0, 1.0);
    }

    double currentHealth = calculateHealth();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          void updateHealth(String _) {
            setDialogState(() {
              currentHealth = calculateHealth();
            });
          }
          return AlertDialog(
            title: Text('Edit ${group.category} Stats'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: countController,
                    decoration: const InputDecoration(labelText: 'Total Count'),
                    keyboardType: TextInputType.number,
                    onChanged: updateHealth,
                  ),
                  TextField(
                    controller: vacController,
                    decoration: const InputDecoration(labelText: 'Vaccinated Count'),
                    keyboardType: TextInputType.number,
                    onChanged: updateHealth,
                  ),
                  TextField(
                    controller: deathController,
                    decoration: const InputDecoration(labelText: 'Death Count'),
                    keyboardType: TextInputType.number,
                    onChanged: updateHealth,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Auto-Calculated Health'),
                      Text('${(currentHealth * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    group.totalCount = int.tryParse(countController.text) ?? group.totalCount;
                    group.vaccinatedCount = int.tryParse(vacController.text) ?? group.vaccinatedCount;
                    group.deathCount = int.tryParse(deathController.text) ?? group.deathCount;
                    group.healthScore = currentHealth;
                  });
                  _saveLivestock();
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredLivestock = _livestock.where((group) {
      final query = _searchQuery.toLowerCase();
      return group.category.toLowerCase().contains(query);
    }).toList();

    return PhoneShell(
      title: 'Livestock',
      showBack: true,
      bgImage: 'assets/backgrounds/bg-livestock.jpg',
      bgImageDark: 'assets/backgrounds/bg-livestock-dark.jpg',
      floatingActionButton: FloatingActionButton(
        onPressed: _addCattleCategory,
        backgroundColor: leaf,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Farm Size', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(
                          _farmAcres > 0 ? '$_farmAcres acres' : 'No acreage set yet',
                          style: TextStyle(color: Theme.of(context).hintColor),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _editAcres,
                    style: ElevatedButton.styleFrom(backgroundColor: leaf),
                    child: const Text('Edit'),
                  ),
                ],
              ),
            ),
            AgriSearchBar(
              hintText: 'Search by category...',
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
            const SizedBox(height: 10),
            if (_livestock.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text('No livestock groups added yet.', style: TextStyle(color: Colors.grey)),
                ),
              ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredLivestock.length,
              itemBuilder: (context, index) {
                final group = filteredLivestock[index];
                final isWarning = group.healthScore < 0.6 || group.deathCount > 0;

                return GestureDetector(
                  onTap: () => _editStats(group),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                color: isWarning ? harvest : leaf,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.pets, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    group.category,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text(
                                    'Count: ${group.totalCount} | Vaccinated: ${group.vaccinatedCount}',
                                    style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
                                  ),
                                ],
                              ),
                            ),
                            if (group.deathCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Deaths: ${group.deathCount}',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Health', style: TextStyle(fontSize: 12)),
                            Text('${(group.healthScore * 100).round()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: group.healthScore,
                            backgroundColor: Colors.black12,
                            color: isWarning ? harvest : leaf,
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
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

