import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_ocs/data/models/user_model.dart';
import 'package:sistema_ocs/features/login/auth_notifier.dart';

class UserEditScreen extends ConsumerStatefulWidget {
  const UserEditScreen({super.key, this.user, this.publicRegistration = false});
  final UserModel? user;
  final bool publicRegistration;

  @override
  ConsumerState<UserEditScreen> createState() => _UserEditScreenState();
}

class _UserEditScreenState extends ConsumerState<UserEditScreen> {
  final _form = GlobalKey<FormState>();
  final Map<String, TextEditingController> _c = {};
  String _role = 'user';
  String _documentType = 'DNI';
  String _gender = 'no_especifica';
  bool _saving = false;
  bool get _creating => widget.user == null;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _role = u?.role ?? 'user';
    _documentType = u?.tipoDocumento ?? 'DNI';
    _gender = u?.genero ?? 'no_especifica';
    const keys = ['nombre','apellidos','dni','email','password','telefono','telefono_secundario','direccion','cargo','area','fecha_nacimiento','fecha_ingreso','codigo_unico','supervisor_id'];
    final values = [u?.nombre,u?.apellidos,u?.dni,u?.email,'',u?.telefono,u?.telefonoSecundario,u?.direccion,u?.cargo,u?.area,u?.fechaNacimiento,u?.fechaIngreso,u?.codigoUnico,u?.supervisorId?.toString()];
    for (var i = 0; i < keys.length; i++) { _c[keys[i]] = TextEditingController(text: values[i] ?? ''); }
  }

  @override
  void dispose() { for (final c in _c.values) { c.dispose(); } super.dispose(); }

  String? _value(String key) { final v = _c[key]!.text.trim(); return v.isEmpty ? null : v; }
  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final payload = <String, dynamic>{
      'nombre': _c['nombre']!.text.trim(), 'apellidos': _c['apellidos']!.text.trim(),
      'tipo_documento': _documentType, 'dni': _c['dni']!.text.trim().toUpperCase(),
      'genero': _gender, 'email': _c['email']!.text.trim().toLowerCase(),
      'telefono': _value('telefono'), 'telefono_secundario': _value('telefono_secundario'),
      'direccion': _value('direccion'), 'cargo': _value('cargo'), 'area': _value('area'),
      'fecha_nacimiento': _value('fecha_nacimiento'), 'fecha_ingreso': _value('fecha_ingreso'),
      'codigo_unico': _value('codigo_unico'), 'supervisor_id': int.tryParse(_c['supervisor_id']!.text.trim()),
    };
    try {
      final service = ref.read(authServiceProvider);
      if (_creating) {
        payload['role'] = _role;
        payload['password'] = _c['password']!.text;
        await service.register(payload);
      } else {
        payload.remove('email');
        payload.remove('password');
        payload['role'] = _role;
        await service.updateUser(widget.user!.id, payload);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_creating ? 'Usuario registrado.' : 'Usuario actualizado.')));
      Navigator.pop(context, true);
    } on DioException catch (e) {
      if (!mounted) return;
      final detail = e.response?.data is Map ? e.response?.data['detail'] : null;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(detail?.toString() ?? 'No se pudo guardar el usuario.')));
    } finally { if (mounted) setState(() => _saving = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_creating ? (widget.publicRegistration ? 'Crear cuenta' : 'Registrar usuario') : 'Editar usuario')),
    body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 700), child: Form(
      key: _form, child: ListView(padding: const EdgeInsets.all(20), children: [
        Text(widget.publicRegistration
            ? 'El registro público permite crear una cuenta user o trabajador.'
            : 'El correo es inmutable. El registro solo permite user o trabajador; admin puede asignar otros roles al editar.'),
        const SizedBox(height: 16),
        _text('nombre','Nombres',required: true), _text('apellidos','Apellidos',required: true),
        DropdownButtonFormField<String>(value: _documentType, decoration: const InputDecoration(labelText: 'Tipo de documento'), items: ['DNI','CE','PASAPORTE','OTRO'].map((v)=>DropdownMenuItem(value:v,child:Text(v))).toList(), onChanged:(v)=>setState(()=>_documentType=v!)),
        _text('dni','Documento',required: true),
        DropdownButtonFormField<String>(value: _gender, decoration: const InputDecoration(labelText: 'Género'), items: ['masculino','femenino','otro','no_especifica'].map((v)=>DropdownMenuItem(value:v,child:Text(v))).toList(), onChanged:(v)=>setState(()=>_gender=v!)),
        _text('email','Correo electrónico',required: true, enabled:_creating, keyboard:TextInputType.emailAddress),
        if (_creating) _text('password','Contraseña (mínimo 8 caracteres)',required:true,password:true),
        DropdownButtonFormField<String>(value: _role, decoration: const InputDecoration(labelText: 'Rol'), items: (_creating ? ['user','trabajador'] : ['user','trabajador','almacenero','admin']).map((v)=>DropdownMenuItem(value:v,child:Text(v))).toList(), onChanged:(v)=>setState(()=>_role=v!)),
        _text('telefono','Teléfono'), _text('telefono_secundario','Teléfono secundario'), _text('direccion','Dirección'),
        _text('cargo','Cargo'), _text('area','Área'), _text('codigo_unico','Código único'),
        _text('fecha_nacimiento','Fecha de nacimiento (AAAA-MM-DD)'), _text('fecha_ingreso','Fecha de ingreso (AAAA-MM-DD)'),
        _text('supervisor_id','ID del supervisor',keyboard:TextInputType.number),
        const SizedBox(height: 20), FilledButton(onPressed:_saving?null:_save, child:_saving?const CircularProgressIndicator():Text(_creating?'Crear usuario':'Guardar cambios')),
      ]),
    ))),
  );

  Widget _text(String key, String label, {bool required=false, bool enabled=true, bool password=false, TextInputType? keyboard}) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(controller:_c[key], enabled:enabled, obscureText:password, keyboardType:keyboard,
      decoration:InputDecoration(labelText:label, border:const OutlineInputBorder()),
      validator:(v){ if(required && (v==null || v.trim().isEmpty)) return 'Campo obligatorio'; if(key=='nombre'||key=='apellidos') { if(v!=null && v.trim().length<2)return 'Ingrese al menos 2 caracteres'; } if(key=='password' && v!=null && v.length<8)return 'Use al menos 8 caracteres'; return null; }),
  );
}
