import 'package:Grasp/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';
import 'main_wrapper.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final storage = const FlutterSecureStorage();
  bool loading = true;
  bool loggedIn = false;

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    String? refreshToken = await storage.read(key: "refreshToken");
    print("REFRESH TOKEN FROM STORAGE: $refreshToken");

    if (refreshToken != null) {
      print("Trying silent refresh...");
      String? newToken = await ApiService.refreshAccessToken();

      print("NEW ACCESS TOKEN: $newToken");

      if (newToken != null) {
        loggedIn = true;
      } else {
        loggedIn = false;
      }
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (loggedIn) {
      return const MainWrapper();
    } else {
      return const LoginScreen();
    }
  }
}