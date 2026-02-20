import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../theme_provider.dart';
import 'login_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {

  final storage = const FlutterSecureStorage();
  String email = "";
  String name = "";

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    String? storedEmail = await storage.read(key: "userEmail");
    String? storedName = await storage.read(key: "userName");
    setState(() {
      name = storedName ?? "";
      email = storedEmail ?? "";
    });
  }

  Future<void> logout() async {
    await storage.deleteAll();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF121212) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.teal,
                  child: Text(
                    email.isNotEmpty ? name[0].toUpperCase() : "U",
                    style: const TextStyle(fontSize: 22,color: Colors.white),
                  ),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(email,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.grey)),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 30),

          const Text("Appearance",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 10),

          ListTile(
            title: const Text("Dark Mode"),
            leading: const Icon(Icons.dark_mode_outlined),
            trailing: Switch(
              value: ref.watch(themeProvider) == ThemeMode.dark,
              onChanged: (_) =>
                  ref.read(themeProvider.notifier).toggleTheme(),
            ),
          ),

          const Divider(),
          const SizedBox(height: 10),

          const Text("Account",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 10),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout"),
            onTap: logout,
          ),
          const SizedBox(height: 10),
          const Divider(
            color: Colors.black,
          ),
          const SizedBox(height: 10),
          Column(
            children: [
              Text('Designed & Developed by',style: TextStyle(
                color: Colors.grey,
                fontSize: 10,
              ),),
              const SizedBox(height: 5),
              Text('Harman',style: TextStyle(
                color: isDark ? Colors.tealAccent : Colors.teal,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),),
            ],
          ),
        ],
      ),
    );
  }
}