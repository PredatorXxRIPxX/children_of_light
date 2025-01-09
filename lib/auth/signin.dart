import 'package:flutter/material.dart';
import 'package:lumiers/auth/forgetpassword.dart';
import 'package:lumiers/auth/signup.dart';
import 'package:lumiers/pages/mainpage.dart';
import 'package:lumiers/services/appwrite.dart';
import 'package:lumiers/utils/user_provider.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late UserProvider userprovider;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool stay_connected = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final Map<String, dynamic> response = await AppwriteServices.signIn(
        email: _emailController.text,
        password: _passwordController.text,
        stayConnected: stay_connected,
      );
      final message = response['success'];
      if (message == true) {
        final username =
            await AppwriteServices.getUsername(email: _emailController.text);
            
        userprovider.setEmail(_emailController.text);
        userprovider.setUsername(username['username']);
      

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainPage(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkSession() async {
    final Map<String, dynamic> response =
        await AppwriteServices.getCurrentSession();
    final message = response['success'];
    if (message == true) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainPage(),
        ),
      );
    }
  }

  @override
  void initState() {
    userprovider = Provider.of<UserProvider>(context, listen: false);
    _checkSession();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.deepPurple.shade50,
                Colors.white,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  // Header
                  Text(
                    'Bienvenue',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'identifiez-vous pour continuer',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 48),
                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'Enter votre email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 's\'il vous plait entrer votre email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'mot de passe',
                            hintText: 'Enter votre mot de passe',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 's\'il vous plait entrer votre mot de passe';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Checkbox(
                              value: stay_connected,
                              onChanged: (value) {
                                setState(() {
                                  stay_connected = value!;
                                });
                              },
                            ),
                            const Text('Rester connecté'),
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPasswordPage(),
                                ),
                              );
                            },
                            child: const Text('mot de passe oublié?'),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Sign In Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSignIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Se connecter',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  Center(
                    child: InkWell(
                      onTap: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const SignUpPage(),
                        ),
                      ),
                      child: RichText(
                        text: TextSpan(
                          text: "Vous n'avez pas de compte? ",
                          style: TextStyle(color: Colors.grey[600]),
                          children: [
                            TextSpan(
                              text: 'S\'inscrire',
                              style: const TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
