import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? sessionInfo;

  @override
  void initState() {
    super.initState();
    _loadSessionInfo();
  }

  Future<void> _loadSessionInfo() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final info = await authProvider.getSessionInfo();
    setState(() {
      sessionInfo = info;
    });
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to sign out? You will need to sign in again to access your data.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _performLogout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await authProvider.signOut();

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Navigate to login screen
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sign out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatSessionAge(int? sessionAge) {
    if (sessionAge == null) return 'Unknown';

    final duration = Duration(milliseconds: sessionAge);
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;

          if (user == null) {
            return const Center(
              child: Text('No user data available'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Profile Picture
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                        ),
                        child: ClipOval(
                          child: user.picture != null
                              ? Image.network(
                                  user.picture!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.white,
                                      child: Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  color: Colors.white,
                                  child: Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // User Name
                      Text(
                        user.name,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      // User Email
                      Text(
                        user.email,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      // User ID Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'ID: ${user.id}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Account Section
                Text(
                  'Account',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 16),

                Card(
                  elevation: 2,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.verified_user),
                        title: const Text('Authentication Status'),
                        subtitle: Text(authProvider.isAuthenticated ? 'Signed In' : 'Not Signed In'),
                        trailing: Icon(
                          authProvider.isAuthenticated ? Icons.check_circle : Icons.cancel,
                          color: authProvider.isAuthenticated ? Colors.green : Colors.red,
                        ),
                      ),

                      if (sessionInfo != null) ...[
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.access_time),
                          title: const Text('Session Duration'),
                          subtitle: Text(_formatSessionAge(sessionInfo!['sessionAge'])),
                          trailing: const Icon(Icons.info_outline),
                        ),
                      ],

                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.refresh),
                        title: const Text('Refresh Session Info'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: _loadSessionInfo,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Preferences Section
                Text(
                  'Preferences',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 16),

                Card(
                  elevation: 2,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.notifications),
                        title: const Text('Notifications'),
                        subtitle: Text(
                          user.preferences['notifications'] == true
                              ? 'Enabled'
                              : 'Disabled'
                        ),
                        trailing: Switch(
                          value: user.preferences['notifications'] == true,
                          onChanged: (value) async {
                            final newPrefs = Map<String, dynamic>.from(user.preferences);
                            newPrefs['notifications'] = value;
                            await authProvider.updatePreferences(newPrefs);
                          },
                        ),
                      ),

                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.schedule),
                        title: const Text('Daily Reminder'),
                        subtitle: Text(
                          user.preferences['reminderTime'] ?? '09:00'
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.of(context).pushNamed('/settings');
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Logout Button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton.icon(
                    onPressed: _showLogoutConfirmation,
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Session Debug Info (Development only)
                if (sessionInfo != null)
                  Card(
                    color: Colors.grey.shade100,
                    child: ExpansionTile(
                      leading: const Icon(Icons.bug_report),
                      title: const Text('Debug Info'),
                      subtitle: const Text('Session details for development'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...sessionInfo!.entries.map((entry) =>
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 120,
                                        child: Text(
                                          '${entry.key}:',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          '${entry.value}',
                                          style: const TextStyle(fontFamily: 'monospace'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}