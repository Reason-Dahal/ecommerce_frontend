import 'package:ecommerce_frontend/core/constants/app_colors.dart';
import 'package:ecommerce_frontend/services/auth_service.dart';
import 'package:ecommerce_frontend/ui/screens/widgets/app_text_field.dart';
import 'package:flutter/material.dart';

/// Two independent sections:
///  1. Update Username — pre-filled from cache, calls updateProfile()
///  2. Update Password — current + new + confirm, calls updatePassword()
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: const [
          _UpdateUsernameSection(),
          SizedBox(height: 24),
          _UpdatePasswordSection(),
        ],
      ),
    );
  }
}

// ── Update Username ───────────────────────────────────────────────────────────

class _UpdateUsernameSection extends StatefulWidget {
  const _UpdateUsernameSection();

  @override
  State<_UpdateUsernameSection> createState() => _UpdateUsernameSectionState();
}

class _UpdateUsernameSectionState extends State<_UpdateUsernameSection> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _usernameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _prefillUsername();
  }

  Future<void> _prefillUsername() async {
    final user = await _authService.getCurrentUser();
    if (mounted && user != null) {
      _usernameController.text = user.name;
    }
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await _authService.updateProfile(_usernameController.text.trim());
      if (!mounted) return;
      _showSuccess('Username updated successfully');
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: _SettingsCard(
        title: 'Update Username',
        icon: Icons.person_outline,
        children: [
          AppTextField(
            label: 'New Username',
            controller: _usernameController,
            validator: (v) {
              if (v == null || v.trim().isEmpty)
                return 'Username cannot be empty';
              if (v.trim().length < 3) return 'Minimum 3 characters';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _ActionButton(
            label: 'Update Username',
            isLoading: _isLoading,
            onTap: _handleUpdate,
          ),
        ],
      ),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.green.shade700),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }
}

// ── Update Password ───────────────────────────────────────────────────────────

class _UpdatePasswordSection extends StatefulWidget {
  const _UpdatePasswordSection();

  @override
  State<_UpdatePasswordSection> createState() => _UpdatePasswordSectionState();
}

class _UpdatePasswordSectionState extends State<_UpdatePasswordSection> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false;
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await _authService.updatePassword(
        _currentController.text.trim(),
        _newController.text.trim(),
      );
      if (!mounted) return;
      _currentController.clear();
      _newController.clear();
      _confirmController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password updated successfully'),
          backgroundColor: Colors.green.shade700,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: _SettingsCard(
        title: 'Update Password',
        icon: Icons.lock_outline,
        children: [
          _PasswordField(
            label: 'Current Password',
            controller: _currentController,
            obscure: !_showCurrent,
            toggle: () => setState(() => _showCurrent = !_showCurrent),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Enter current password' : null,
          ),
          const SizedBox(height: 16),
          _PasswordField(
            label: 'New Password',
            controller: _newController,
            obscure: !_showNew,
            toggle: () => setState(() => _showNew = !_showNew),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Enter new password';
              if (v.length < 8) return 'Minimum 8 characters';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _PasswordField(
            label: 'Confirm New Password',
            controller: _confirmController,
            obscure: !_showConfirm,
            toggle: () => setState(() => _showConfirm = !_showConfirm),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Confirm your new password';
              if (v != _newController.text) return 'Passwords do not match';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _ActionButton(
            label: 'Update Password',
            isLoading: _isLoading,
            onTap: _handleUpdate,
          ),
        ],
      ),
    );
  }
}

// ── Shared private widgets ────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.accent, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.bg, height: 1),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback toggle;
  final String? Function(String?)? validator;

  const _PasswordField({
    required this.label,
    required this.controller,
    required this.obscure,
    required this.toggle,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.bg,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
              onPressed: toggle,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
