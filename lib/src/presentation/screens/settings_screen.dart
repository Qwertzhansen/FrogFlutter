import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/app_config.dart';
import '../../services/notifications_service.dart';
import '../../services/sync_service.dart';
import '../../data/blocs/profile/profile_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _mockAI = AppConfig.instance.mockAI;
  bool _notifications = AppConfig.instance.notificationsEnabled;
  String _lunch = AppConfig.instance.lunchTime;
  String _evening = AppConfig.instance.eveningTime;
  bool _syncing = false;
  Map<String,int>? _pending;

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  Future<void> _loadPending() async {
    final p = await SyncService.instance.getPendingCounts();
    setState(() { _pending = p; });
  }

  Future<void> _pickTime({required bool isLunch}) async {
    final initial = _parse(_lunch);
    final res = await showTimePicker(context: context, initialTime: isLunch ? _parse(_lunch) : _parse(_evening));
    if (res != null) {
      final hhmm = _fmt(res);
      if (isLunch) {
        setState(() => _lunch = hhmm);
        await AppConfig.instance.setLunchTime(hhmm);
      } else {
        setState(() => _evening = hhmm);
        await AppConfig.instance.setEveningTime(hhmm);
      }
      if (_notifications) {
        // reschedule
        await NotificationsService.instance.cancelAll();
        await NotificationsService.instance.scheduleDailyReminder(id: 1001, time: _parse(_lunch), title: 'Log your lunch', body: 'Track your meal to keep your streak going! 💪');
        await NotificationsService.instance.scheduleDailyReminder(id: 1002, time: _parse(_evening), title: 'Plan tomorrow', body: 'Prepare your workout and meals for tomorrow.');
      }
    }
  }

  TimeOfDay _parse(String hhmm) {
    final parts = hhmm.split(':');
    final h = int.tryParse(parts[0]) ?? 12; final m = int.tryParse(parts.length>1?parts[1]:'0') ?? 0;
    return TimeOfDay(hour: h, minute: m);
  }
  String _fmt(TimeOfDay t) => '${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('General', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Use Mock AI (no API required)'),
            value: _mockAI,
            onChanged: (v) async {
              setState(() => _mockAI = v);
              await AppConfig.instance.setMockAI(v);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Mock AI ${v? 'enabled':'disabled'}')));
            },
          ),
          const Divider(),
          const Text('Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Enable reminders'),
            value: _notifications,
            onChanged: (v) async {
              setState(() => _notifications = v);
              await AppConfig.instance.setNotificationsEnabled(v);
              if (v) {
                await NotificationsService.instance.scheduleDailyReminder(id: 1001, time: _parse(_lunch), title: 'Log your lunch', body: 'Track your meal to keep your streak going! 💪');
                await NotificationsService.instance.scheduleDailyReminder(id: 1002, time: _parse(_evening), title: 'Plan tomorrow', body: 'Prepare your workout and meals for tomorrow.');
              } else {
                await NotificationsService.instance.cancelAll();
              }
            },
          ),
          ListTile(
            title: const Text('Lunch reminder'),
            subtitle: Text(_lunch),
            trailing: const Icon(Icons.schedule),
            onTap: () => _pickTime(isLunch: true),
          ),
          ListTile(
            title: const Text('Evening reminder'),
            subtitle: Text(_evening),
            trailing: const Icon(Icons.schedule),
            onTap: () => _pickTime(isLunch: false),
          ),
          const Divider(),
          const Text('Data & Sync', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Sync pending entries now'),
            subtitle: Text(_pending==null? '': 'Nutrition: ${_pending!['nutrition']}, Workouts: ${_pending!['workout']}'),
            onTap: () async {
              setState(() => _syncing = true);
              String userId = 'mock-user-id';
              // Try to get userId from ProfileBloc if available
              final bloc = context.read<ProfileBloc>();
              // We cannot access bloc.userId directly; rely on mock for now.
              await SyncService.instance.trySyncAll(userId);
              await _loadPending();
              setState(() => _syncing = false);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sync attempt completed')));
            },
          ),
          if (_syncing) const LinearProgressIndicator(),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Export data (CSV/JSON)'),
            subtitle: const Text('Coming soon'),
            enabled: false,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}