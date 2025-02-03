import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lumiers/utils/user_provider.dart';


class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  String? _initialUsername;
  String? _initialEmail;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupListeners();
  }

  void _initializeControllers() {
    final userProvider = context.read<UserProvider>();
    _initialUsername = userProvider.username;
    _initialEmail = userProvider.email;

    _usernameController = TextEditingController(text: _initialUsername);
    _emailController = TextEditingController(text: _initialEmail);
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  void _setupListeners() {
    void listener() => _checkForChanges();
    _usernameController.addListener(listener);
    _emailController.addListener(listener);
    _passwordController.addListener(listener);
    _confirmPasswordController.addListener(listener);
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }

  void _checkForChanges() {
    final hasTextChanges = _usernameController.text != _initialUsername ||
        _emailController.text != _initialEmail ||
        _passwordController.text.isNotEmpty == true;

    if (hasTextChanges != _hasChanges) {
      setState(() => _hasChanges = hasTextChanges);
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return null;

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!_hasRequiredPasswordCharacters(value)) {
      return 'Password must contain uppercase, lowercase, numbers, and special characters';
    }
    return null;
  }

  bool _hasRequiredPasswordCharacters(String value) {
    return value.contains(RegExp(r'[A-Z]')) &&
        value.contains(RegExp(r'[a-z]')) &&
        value.contains(RegExp(r'[0-9]')) &&
        value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }

  Future<bool> _confirmDiscardChanges() async {
    if (!_hasChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text(
            'You have unsaved changes. Are you sure you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userProvider = context.read<UserProvider>();

      if (mounted) {
        _showSuccessSnackBar('Profile updated successfully');
        Navigator.pop(context);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to update profile: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _confirmDiscardChanges,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      title: const Text('Edit Profile'),
      elevation: 2,
      foregroundColor: Colors.white,
      actions: [
        if (_hasChanges)
          TextButton(
            onPressed: _isLoading ? null : _updateProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
      ],
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              _buildBasicInfoSection(),
              const SizedBox(height: 24),
              _buildPasswordSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      children: [
        CustomInputField(
          label: 'Username',
          controller: _usernameController,
          icon: Icons.person_outline,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Username is required' : null,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        CustomInputField(
          label: 'Email',
          controller: _emailController,
          icon: Icons.email_outlined,
          validator: _validateEmail,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }

  Widget _buildPasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 8),
        Text(
          'Change Password',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        CustomInputField(
          label: 'New Password (optional)',
          controller: _passwordController,
          icon: Icons.lock_outline,
          obscureText: _obscurePassword,
          validator: _validatePassword,
          textInputAction: TextInputAction.next,
          suffixIcon: IconButton(
            icon: Icon(_obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        if (_passwordController.text.isNotEmpty) ...[
          const SizedBox(height: 16),
          CustomInputField(
            label: 'Confirm New Password',
            controller: _confirmPasswordController,
            icon: Icons.lock_outline,
            obscureText: _obscureConfirmPassword,
            validator: (value) => value != _passwordController.text
                ? 'Passwords do not match'
                : null,
            textInputAction: TextInputAction.done,
            suffixIcon: IconButton(
              icon: Icon(_obscureConfirmPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined),
              onPressed: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
          ),
        ],
      ],
    );
  }
}

class CustomInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  const CustomInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
    );
  }
}
