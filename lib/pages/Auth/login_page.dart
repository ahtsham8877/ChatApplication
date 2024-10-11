import 'package:chat_app/Utilities/colors.dart';
import 'package:chat_app/pages/Auth/signup_page.dart';
import 'package:chat_app/pages/ChatSc/chat_sc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Components/button.dart';
import '../../Components/text_feild.dart';
import '../MainPage/mainPage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  bool _obscurePassword = true; // Add this line

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final UserCredential userCredential =
            await _auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        if (userCredential.user != null) {
          Get.to(() => Mainpage(
                userId: userCredential.user!.uid,
                email: emailController.text.trim(),
              ));
          print("User ID: ${userCredential.user}");
        }
      } catch (e) {
        String errorMessage;
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'user-not-found':
              errorMessage = 'No user found for that email.';
              break;
            case 'wrong-password':
              errorMessage = 'Wrong password provided.';
              break;
            case 'invalid-email':
              errorMessage = 'Invalid email address.';
              break;
            default:
              errorMessage = 'An error occurred.';
          }
        } else {
          errorMessage = 'An error occurred.';
        }
        Get.snackbar("Error", errorMessage,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: buttonColor.withOpacity(0.5));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Image.asset(
              "assets/fs.jpg",
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        keyboardType: TextInputType.emailAddress,
                        textSize: 16,
                        labelText: "Email",
                        text: "Enter Email",
                        validateText: "Email is required",
                        controller: emailController,
                      ),
                      CustomTextField(
                        textSize: 16,
                        labelText: "Password",
                        text: "Enter Password",
                        validateText: "Password is required",
                        obscureText: _obscurePassword, // Use the boolean here
                        controller: passwordController,
                        suffixicon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword =
                                  !_obscurePassword; // Toggle the boolean value
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _isLoading
                    ? CircularProgressIndicator(
                        color: buttonColor,
                      )
                    : Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: CustomButton(
                          onTap: _login,
                          height: 50,
                          width: double.infinity,
                          text: "Login",
                          color: buttonColor,
                          Textcolor: Colors.white,
                        ),
                      ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Get.to(() => SignUpPage());
                  },
                  child: const Text(
                    "Don't have an account? Sign Up",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                    onPressed: () {
                      Get.to(() => const ChatPage(
                          title: "Test Chat",
                          userId: "fsdf",
                          chatPartnerId: "3yBqyTObFyXLKqGz1NXMHiXk4l83"));
                    },
                    child: Text(
                      "Direct login",
                      style: TextStyle(color: whiteColor),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
