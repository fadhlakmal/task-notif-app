import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/app/screens/login_screen.dart';
import 'package:myapp/app/widgets/drawer_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void logout(context) async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, 'login');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LoginScreen();
        }

        final uid = _auth.currentUser?.uid;
        if (uid == null) {
          return LoginScreen();
        }

        return FutureBuilder(
          future: _db.collection("users").doc(uid).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            if (snapshot.hasError) {
              return Scaffold(
                appBar: AppBar(title: const Text("Hi Mom"), centerTitle: true),
                body: const Center(child: Text('Error loading data')),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Scaffold(
                appBar: AppBar(title: const Text("Hi Mom"), centerTitle: true),
                body: const Center(child: Text('User data not found')),
              );
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final username = userData['username'] ?? 'User';

            return Scaffold(
              appBar: AppBar(title: Text("Hi Mom"), centerTitle: true),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Hello $username"),
                    const SizedBox(height: 24),
                    OutlinedButton(
                      onPressed: () => logout(context),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              ),
              drawer: const DrawerWidget(),
            );
          },
        );
      },
    );
  }
}
