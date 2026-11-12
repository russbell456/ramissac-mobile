import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_ocs/features/profile/profile_provider.dart';

class UserDataScreen extends ConsumerStatefulWidget {
  const UserDataScreen({super.key});
  @override
  ConsumerState<UserDataScreen> createState() => _UserDataScreenState();
}

class _UserDataScreenState extends ConsumerState<UserDataScreen> {
  final _form = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _phone2 = TextEditingController();
  final _address = TextEditingController();
  bool _ready = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    final user = ref.read(profileProvider).user;
    _phone.text = user?.telefono ?? '';
    _phone2.text = user?.telefonoSecundario ?? '';
    _address.text = user?.direccion ?? '';
    _ready = true;
  }

  @override
  void dispose() {
    _phone.dispose(); _phone2.dispose(); _address.dispose(); super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final ok = await ref.read(profileProvider.notifier).updateContact(
      telefono: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      telefonoSecundario: _phone2.text.trim().isEmpty ? null : _phone2.text.trim(),
      direccion: _address.text.trim().isEmpty ? null : _address.text.trim(),
    );
    if (!mounted) return;
    if (ok) { Navigator.pop(context); return; }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ref.read(profileProvider).errorMessage ?? 'No se pudo actualizar el perfil.'),
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Editar mis datos de contacto')),
    body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 560), child: Form(
      key: _form,
      child: ListView(padding: const EdgeInsets.all(24), children: [
        const Text('Solo puedes cambiar tus teléfonos y dirección. El correo y el rol no se pueden editar aquí.'),
        const SizedBox(height: 20),
        _field(_phone, 'Teléfono', max: 20),
        const SizedBox(height: 16), _field(_phone2, 'Teléfono secundario', max: 20),
        const SizedBox(height: 16), _field(_address, 'Dirección', max: 250, lines: 3),
        const SizedBox(height: 24),
        FilledButton(onPressed: ref.watch(profileProvider).loading ? null : _save,
          child: ref.watch(profileProvider).loading ? const CircularProgressIndicator() : const Text('Guardar')),
      ]),
    ))),
  );

  Widget _field(TextEditingController c, String label, {required int max, int lines = 1}) => TextFormField(
    controller: c, maxLength: max, maxLines: lines,
    decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
  );
}
