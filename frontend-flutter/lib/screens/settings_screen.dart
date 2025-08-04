import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 9, minute: 0);
  String _fcmToken = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadFCMToken();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      final hour = prefs.getInt('notification_hour') ?? 9;
      final minute = prefs.getInt('notification_minute') ?? 0;
      _notificationTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  Future<void> _loadFCMToken() async {
    // For demo: Mock FCM token
    setState(() {
      _fcmToken = 'demo-fcm-token-12345';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setInt('notification_hour', _notificationTime.hour);
    await prefs.setInt('notification_minute', _notificationTime.minute);

    // For demo: Skip notification scheduling
    print('Notifications ${_notificationsEnabled ? 'enabled' : 'disabled'} for ${_notificationTime.format(context)}');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved!')),
      );
    }
  }

  Future<void> _selectNotificationTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
    );

    if (time != null) {
      setState(() {
        _notificationTime = time;
      });
      await _saveSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Notifications Section
          const Text(
            'Notifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 15),
          
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Daily Affirmations'),
                  subtitle: const Text('Receive daily positive messages'),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    _saveSettings();
                  },
                ),
                
                if (_notificationsEnabled) ...[
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Notification Time'),
                    subtitle: Text(_notificationTime.format(context)),
                    trailing: const Icon(Icons.access_time),
                    onTap: _selectNotificationTime,
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          // About Section
          const Text(
            'About',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 15),
          
          Card(
            child: Column(
              children: [
                const ListTile(
                  title: Text('App Version'),
                  subtitle: Text('1.0.0'),
                  trailing: Icon(Icons.info_outline),
                ),
                
                const Divider(height: 1),
                
                ListTile(
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // TODO: Open privacy policy
                  },
                ),
                
                const Divider(height: 1),
                
                ListTile(
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // TODO: Open terms of service
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Developer Info
          const Text(
            'Developer Info',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 15),
          
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('FCM Token'),
                  subtitle: Text(
                    _fcmToken.length > 50 
                        ? '${_fcmToken.substring(0, 50)}...'
                        : _fcmToken,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      // TODO: Copy token to clipboard
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Token copied to clipboard')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Support Section
          const Text(
            'Support',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 15),
          
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Contact Support'),
                  subtitle: const Text('Get help with the app'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // TODO: Open contact support
                  },
                ),
                
                const Divider(height: 1),
                
                ListTile(
                  title: const Text('Rate the App'),
                  subtitle: const Text('Help us improve'),
                  trailing: const Icon(Icons.star_outline),
                  onTap: () {
                    // TODO: Open app store rating
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 50),
          
          // Footer
          Center(
            child: Column(
              children: [
                Text(
                  'Made with 💖 for mental wellness',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'You are not alone. You matter.',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}