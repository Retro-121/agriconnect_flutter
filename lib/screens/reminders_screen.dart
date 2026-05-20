import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/phone_shell.dart';
import '../widgets/agri_search_bar.dart';
import '../theme.dart';
import '../services/notification_service.dart';

class Reminder {
  final String id;
  final String occasion;
  final DateTime dateTime;
  bool isCompleted;

  Reminder({
    required this.id,
    required this.occasion,
    required this.dateTime,
    this.isCompleted = false,
  });
}

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  String _searchQuery = '';
  final List<Reminder> _reminders = [];

  Future<void> _updateAiSummary() async {
    final prefs = await SharedPreferences.getInstance();
    final summary = _reminders.isEmpty 
      ? 'No upcoming reminders.' 
      : _reminders.map((r) => '${r.occasion} on ${DateFormat('MMM dd').format(r.dateTime)}').join(', ');
    await prefs.setString('reminders_summary', summary);
  }

  void _addReminder() async {
    final occasionController = TextEditingController();
    DateTime? selectedDate = DateTime.now();
    TimeOfDay? selectedTime = TimeOfDay.now();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Reminder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: occasionController,
                decoration: const InputDecoration(labelText: 'Occasion (e.g. Vaccinate)'),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text('Date: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate!,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) setDialogState(() => selectedDate = date);
                },
              ),
              ListTile(
                title: Text('Time: ${selectedTime!.format(context)}'),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: selectedTime!,
                  );
                  if (time != null) setDialogState(() => selectedTime = time);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (occasionController.text.isNotEmpty) {
                  final fullDateTime = DateTime(
                    selectedDate!.year,
                    selectedDate!.month,
                    selectedDate!.day,
                    selectedTime!.hour,
                    selectedTime!.minute,
                  );
                  final id = DateTime.now().millisecondsSinceEpoch.toString();
                  setState(() {
                    _reminders.add(Reminder(
                      id: id,
                      occasion: occasionController.text,
                      dateTime: fullDateTime,
                    ));
                  });
                  _updateAiSummary();
                  
                  // Schedule Notification (2 hours before if possible, or immediately)
                  final notificationTime = fullDateTime.subtract(const Duration(hours: 2));
                  if (notificationTime.isAfter(DateTime.now())) {
                    /* NotificationService().scheduleNotification(
                      int.parse(id.substring(id.length - 8)),
                      'Upcoming: ${occasionController.text}',
                      'Your farm occasion is in 2 hours!',
                      notificationTime,
                    ); */
                  }
                  
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredReminders = _reminders.where((rem) {
      final query = _searchQuery.toLowerCase();
      return rem.occasion.toLowerCase().contains(query);
    }).toList();

    return PhoneShell(
      title: 'Reminders',
      showBack: true,
      bgImage: 'assets/backgrounds/bg-reminders.jpg',
      bgImageDark: 'assets/backgrounds/bg-reminders-dark.jpg',
      floatingActionButton: FloatingActionButton(
        onPressed: _addReminder,
        backgroundColor: leaf,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            AgriSearchBar(
              hintText: 'Search reminders...',
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
            const SizedBox(height: 10),
            if (_reminders.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text('No reminders set. Tap + to add one.', style: TextStyle(color: Colors.grey)),
                ),
              ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredReminders.length,
              itemBuilder: (context, index) {
                final rem = filteredReminders[index];
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
                      GestureDetector(
                        onTap: () => setState(() => rem.isCompleted = !rem.isCompleted),
                        child: Container(
                          height: 44,
                          width: 44,
                          decoration: BoxDecoration(
                            color: (rem.isCompleted ? leaf : harvest).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            rem.isCompleted ? Icons.check_circle : Icons.notifications,
                            color: rem.isCompleted ? leaf : soil,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rem.occasion,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                decoration: rem.isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            Text(
                              '${DateFormat('MMM dd, yyyy').format(rem.dateTime)} · ${DateFormat('hh:mm a').format(rem.dateTime)}',
                              style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () {
                          setState(() => _reminders.remove(rem));
                          _updateAiSummary();
                          // NotificationService().cancelNotification(int.parse(rem.id.substring(rem.id.length - 8)));
                        },
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

