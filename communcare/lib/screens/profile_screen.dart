import 'package:flutter/material.dart';
import '../main.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await supabase.auth.signOut();

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(
            radius: 36,
            backgroundColor: kLightGreen,
            child: Icon(Icons.person, size: 40, color: kForestGreen),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text('Citizen User',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 24),
          _tile(Icons.settings_outlined, 'Settings', onTap: () {}),
          _tile(Icons.notifications_outlined, 'Notifications', onTap: () {}),
          _tile(Icons.help_outline, 'Help & Support', onTap: () {}),
          const Divider(height: 32),
          _tile(
            Icons.logout,
            'Log Out',
            color: Colors.red,
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String label, {Color? color, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: color ?? kForestGreen),
      title: Text(label, style: TextStyle(color: color)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}