import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_ocs/features/login/auth_notifier.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(authServiceProvider).changePassword(_current.text, _next.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña actualizada correctamente.')),
      );
      Navigator.pop(context);
    } on DioException catch (e) {
      if (!mounted) return;
      final detail = e.response?.data is Map ? e.response?.data['detail'] : null;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(detail?.toString() ?? 'No se pudo cambiar la contraseña.'),
      ));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Cambiar contraseña')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Form(
              key: _formKey,
              child: ListView(padding: const EdgeInsets.all(24), children: [
                _passwordField(_current, 'Contraseña actual'),
                const SizedBox(height: 16),
                _passwordField(_next, 'Nueva contraseña', minimum: true),
                const SizedBox(height: 16),
                _passwordField(_confirm, 'Confirmar nueva contraseña', minimum: true, confirmation: true),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _submit,
                  child: _saving
                      ? const CircularProgressIndicator()
                      : const Text('Guardar contraseña'),
                ),
              ]),
            ),
          ),
        ),
      );

  Widget _passwordField(TextEditingController controller, String label,
      {bool minimum = false, bool confirmation = false}) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Campo obligatorio';
        if (minimum && value.length < 8) return 'Use al menos 8 caracteres';
        if (confirmation && value != _next.text) return 'Las contraseñas no coinciden';
        return null;
      },
    );
  }
}
