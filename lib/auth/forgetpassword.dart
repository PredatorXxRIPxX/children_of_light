import 'package:flutter/material.dart';
import 'package:lumiers/services/appwrite.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  int _currentStep = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> updatePassword() async {
    try {
      final Map<String, dynamic> result =
          await AppwriteServices.updatePassword(_newPasswordController.text);
      if (!result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.green,
        ));
        Future.delayed(const Duration(seconds: 2));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _handleSubmission() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      if (_currentStep == 0) {
        final Map<String, dynamic> result =
            await AppwriteServices.sendVerification(
                email: _emailController.text);
        if (!result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ));
          setState(() => _isLoading = false);
          return;
        }
      }
      if (_currentStep == 1) {
        final Map<String, dynamic> result =
            await AppwriteServices.verifyAccount(
                email: _emailController.text, code: _codeController.text);
        if (!result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ));
          setState(() => _isLoading = false);
          return;
        }
      }
      setState(() {
        _isLoading = false;
        if (_currentStep < 2) _currentStep++;
      });
    }
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
              colors: [Theme.of(context).colorScheme.secondary, Theme.of(context).colorScheme.secondary.withOpacity(0.8)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Reset Password',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getStepDescription(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 32),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (_currentStep == 0) _buildEmailStep(),
                        if (_currentStep == 1) _buildVerificationStep(),
                        if (_currentStep == 2) _buildNewPasswordStep(),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSubmission,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
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
                                : Text(
                                    _getButtonText(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
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

  Widget _buildEmailStep() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'Enter votre email',
        prefixIcon: Icon(Icons.email_outlined,color: Theme.of(context).colorScheme.primary,),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.8)),
        ),
      ),
      validator: (value) => value?.isEmpty ?? true
          ? 'votre s\'il vous plait entez votre mail valide '
          : null,
    );
  }

  Widget _buildVerificationStep() {
    return TextFormField(
      controller: _codeController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Verification de Code',
        hintText: 'Enter le code envoyé à votre email',
        prefixIcon: Icon(Icons.lock_outline,color: Theme.of(context).colorScheme.primary,),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.8)),
        ),
      ),
      validator: (value) =>
          value?.isEmpty ?? true ? 'Please enter the verification code' : null,
    );
  }

  Widget _buildNewPasswordStep() {
    return Column(
      children: [
        TextFormField(
          controller: _newPasswordController,
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            labelText: 'nouveau mot de passe',
            hintText: 'Enter votre nouveau mot de passe',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () =>
                  setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          validator: (value) => value?.isEmpty ?? true
              ? 's\'il vous plait entrer votre mot de passe'
              : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            labelText: 'Confirmez votre mot de passe',
            hintText: 'Confirmez votre mot de passe',
            prefixIcon:Icon(Icons.lock_outline,color: Theme.of(context).colorScheme.primary,),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.8)),
            ),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true)
              return 's\'il vous plait confirmez votre mot de passe';
            if (value != _newPasswordController.text) {
              return 'les mots de passe ne correspondent pas';
            }
            return null;
          },
        ),
      ],
    );
  }

  String _getStepDescription() {
    switch (_currentStep) {
      case 0:
        return 'Entez votre email pour recevoir un code de verification';
      case 1:
        return 'Entez le code de verification envoyé à votre email';
      case 2:
        return 'Entez votre nouveau mot de passe';
      default:
        return '';
    }
  }

  String _getButtonText() {
    switch (_currentStep) {
      case 0:
        return 'Code envoyé';
      case 1:
        return 'Code de verification';
      case 2:
        return 'Réinitialiser le mot de passe';
      default:
        return '';
    }
  }
}
