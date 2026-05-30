import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Quản lý dữ liệu nhập vào
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Khởi tạo instance của Firebase Auth
  FirebaseAuth auth = FirebaseAuth.instance;

  // Khởi tạo instance cho Google Sign-In
  GoogleSignIn ggSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  void signUp() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("Đăng ký thành công: ${userCredential.user!.email}");
      // Thêm code hiển thị thông báo (SnackBar hoặc Dialog) cho người dùng
    } on FirebaseAuthException catch (e) {
      print("Lỗi đăng ký: ${e.message}");
    }
  }

  void signIn() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 1. Hiển thị thông báo trên màn hình
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đăng nhập thành công!')));
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.message}')));
      }
    }
  }

  void googleSignIn() async {
    try {
      GoogleSignInAccount? googleUser = await ggSignIn.signIn();
      if (googleUser == null) {
        print("Người dùng hủy đăng nhập");
        return;
      }

      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await auth.signInWithCredential(
        credential,
      );
      print("Google Sign-In thành công: ${userCredential.user!.displayName}");
    } catch (e) {
      print("Lỗi Google Sign-In: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ô nhập Email
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 20),

            // Ô nhập Password
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 30),

            // Nút Sign In
            ElevatedButton(
              onPressed: signIn, // Gọi hàm signIn
              child: const Text('-> Sign In'),
            ),

            // Nút Đăng ký
            TextButton(
              onPressed: signUp, // Gọi hàm signUp
              child: const Text('Create Account'),
            ),

            const SizedBox(height: 20),
            const Text('Or sign in with'),

            // Hàng chứa nút Google
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.g_mobiledata, size: 40),
                  onPressed: googleSignIn, // Gọi hàm googleSignIn
                ),
                // Bạn có thể thêm các nút Facebook, Apple, Twitter tương tự nếu muốn
              ],
            ),
          ],
        ),
      ),
    );
  }
}
