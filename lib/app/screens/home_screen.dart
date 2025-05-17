import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/app/models/user_model.dart';
import 'package:myapp/app/screens/login_screen.dart';
import 'package:myapp/app/services/user_service.dart';
import 'package:myapp/app/widgets/drawer_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

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

        return StreamBuilder<UserModel?>(
          stream: _userService.userStream(uid),
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

            if (!snapshot.hasData) {
              return Scaffold(
                appBar: AppBar(title: const Text("Hi Mom"), centerTitle: true),
                body: const Center(child: Text('User data not found')),
              );
            }

            final userData = snapshot.data!;

            return Scaffold(
              appBar: AppBar(title: Text("Hi Mom"), centerTitle: true),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Hello ${userData.username}"),
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
