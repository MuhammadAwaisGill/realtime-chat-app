import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../home/home_screen.dart';
import '../signup/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _Login() async {
      if (_formKey.currentState!.validate()) {
        setState(() {
          _isLoading = true;
        });
        try {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim()
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } on FirebaseAuthException catch (e) {
          String message = "An error Occurred!";
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message))
          );
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      }
  }

  Future<void> _ContinueWithGoogle() async {
    try{
      String webClientId = "650822100252-k33j3padt7p7l8828t6iqb1i6nfdvkpc.apps.googleusercontent.com";
      GoogleSignIn signIn = GoogleSignIn.instance;
      await signIn.initialize(serverClientId: webClientId);
      GoogleSignInAccount account = await signIn.authenticate();
      GoogleSignInAuthentication googleAuth = account.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken
      );
      setState(() {
        _isLoading = true;
      });
      auth.signInWithCredential(credential);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()))
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(child: Text(
                  "Welcome Back!",
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)
                  ),
                ),
                SizedBox(height: 40,),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Enter you Email",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email)
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your Email!";
                    }
                    if (!value.contains('@')) {
                      return "Please enter a valid email";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 22,),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Password",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock)
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your password";
                    }
                    if (value.length < 8) {
                      return "Password must be 8 character atleast";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 28,),
                _isLoading ? CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: () {
                    _Login();
                  },
                  child: Text('Login'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50)
                  ),
                ),
                SizedBox(height: 16,),
                TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SignupScreen())
                    );
                  },
                  child: Text("Don\'t have an account? Sign Up"),
                ),
                SizedBox(height: 16,),
                ElevatedButton(
                  onPressed: () {
                    _ContinueWithGoogle();
                  },
                  child: Text('Continue with Google'),
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50)
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
