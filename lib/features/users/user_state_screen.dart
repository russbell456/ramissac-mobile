import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_ocs/data/models/user_model.dart';
import 'package:sistema_ocs/data/services/auth_service.dart';
import 'package:sistema_ocs/features/login/auth_notifier.dart';

class UserStateScreen extends ConsumerStatefulWidget {
  const UserStateScreen({super.key, required this.user});
  final UserModel user;
  @override
  ConsumerState<UserStateScreen> createState() => _UserStateScreenState();
}

class _UserStateScreenState extends ConsumerState<UserStateScreen> {
  late String _state;
  late bool _active;
  bool _saving = false;
  @override
  void initState() { super.initState(); _state=widget.user.estadoLaboral ?? 'activo'; _active=widget.user.activo; }

  Future<void> _save() async {
    setState(()=>_saving=true);
    try {
      final user = await ref.read(authServiceProvider).updateUserStatus(widget.user.id, _active, _state);
      if (!mounted) return;
      Navigator.pop(context, user);
    } on DioException catch(e) {
      if(!mounted)return;
      final detail=e.response?.data is Map?e.response?.data['detail']:null;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(detail?.toString()??'No se pudo actualizar el estado.')));
    } finally {if(mounted)setState(()=>_saving=false);}
  }

  @override
  Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('Estado de usuario')),
    body:Center(child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:520),child:ListView(padding:const EdgeInsets.all(24),children:[
      Text('${widget.user.nombre} ${widget.user.apellidos}',style:Theme.of(context).textTheme.titleLarge),
      const SizedBox(height:20),
      DropdownButtonFormField<String>(value:_state,decoration:const InputDecoration(labelText:'Estado laboral',border:OutlineInputBorder()),items:const [DropdownMenuItem(value:'activo',child:Text('Activo')),DropdownMenuItem(value:'suspendido',child:Text('Suspendido')),DropdownMenuItem(value:'cesado',child:Text('Cesado'))],onChanged:(v)=>setState(()=>_state=v!)),
      SwitchListTile(title:const Text('Cuenta habilitada'),value:_active,onChanged:(v)=>setState(()=>_active=v)),
      const Text('Al guardar como suspendido o cesado, el backend deshabilita la cuenta. Al marcar activo, se reactiva y se limpia la fecha de baja.'),
      const SizedBox(height:24),FilledButton(onPressed:_saving?null:_save,child:_saving?const CircularProgressIndicator():const Text('Guardar estado')),
    ]))),
  );
}
