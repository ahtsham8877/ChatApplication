import 'package:chat_app/Utilities/colors.dart';
import 'package:chat_app/pages/Auth/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Components/button.dart';
import '../../Components/text_feild.dart';
import '../MainPage/mainPage.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  bool _obscurePassword = true; // Add this line

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        if (userCredential.user != null) {
          // Store additional user data in Firestore
          final userId = userCredential.user!.uid;
          await FirebaseFirestore.instance.collection('users').doc(userId).set({
            'name': nameController.text.trim(),
            'email': emailController.text.trim(),
            'userId': userId,
          });

          Get.to(() => Mainpage(
                userId: userCredential.user!.uid,
                email: emailController.text.trim(),
              ));
          print("User ID in sign Up page: ${userCredential.user}");
        }
      } catch (e) {
        String errorMessage;
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'email-already-in-use':
              errorMessage = 'The account already exists for that email.';
              break;
            case 'weak-password':
              errorMessage = 'The password provided is too weak.';
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
            snackPosition: SnackPosition.BOTTOM);
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
      body: Stack(
        children: [
          Image.asset(
            "assets/fs.jpg",
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        labelText: "Name",
                        text: "Enter Name",
                        validateText: "Name is required",
                        controller: nameController,
                      ),
                      CustomTextField(
                        keyboardType: TextInputType.emailAddress,
                        labelText: "Email",
                        text: "Enter Email",
                        validateText: "Email is required",
                        controller: emailController,
                      ),
                      CustomTextField(
                        labelText: "Password",
                        text: "Enter Password",
                        validateText: "Password is required",
                        obscureText: _obscurePassword,
                        controller: passwordController,
                        suffixicon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
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
                    ? const CircularProgressIndicator()
                    : Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: CustomButton(
                          onTap: _signUp,
                          height: 50,
                          width: double.infinity,
                          text: "Sign Up",
                          Textcolor: Colors.white,
                          color: buttonColor,
                        ),
                      ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Get.to(() => LoginPage());
                  },
                  child: Text(
                    "Already have an account? Login",
                    style: TextStyle(color: whiteColor),
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
