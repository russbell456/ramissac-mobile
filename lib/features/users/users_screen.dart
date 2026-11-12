import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_ocs/data/models/user_model.dart';
import 'package:sistema_ocs/features/login/auth_notifier.dart';
import 'package:sistema_ocs/features/users/user_detail_screen.dart';
import 'package:sistema_ocs/features/users/user_edit_screen.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});
  @override
  ConsumerState<UsersScreen> createState()=>_UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  final _search=TextEditingController();
  List<UserModel> _users=[];
  String _role='Todos',_status='Todos',_active='Todos';
  bool _loading=true;
  String? _error;

  @override
  void initState(){super.initState();_load();}
  @override
  void dispose(){_search.dispose();super.dispose();}

  Future<void> _load() async {
    setState(()=>_loading=true);
    try {
      final service=ref.read(authServiceProvider);
      final current=await service.fetchCurrentUser();
      if(current.role!='admin') {
        if(mounted)setState(()=>_error='Solo admin puede gestionar usuarios.');
        return;
      }
      final users=await service.listUsers(search:_search.text,role:_role,status:_status,active:_active=='Todos'?null:_active=='Activa');
      if(!mounted)return;
      setState(() {
        _users=users..sort((a,b)=>a.apellidos.compareTo(b.apellidos));
        _error=null;
      });
    } on DioException catch(e) {
      if(!mounted)return;
      final code=e.response?.statusCode;
      final detail=e.response?.data is Map?e.response?.data['detail']:null;
      setState(()=>_error=code==403?'Solo admin puede gestionar usuarios.':detail?.toString()??'No se pudo cargar los usuarios.');
    } catch(_) {if(mounted)setState(()=>_error='No se pudo cargar los usuarios.');}
    finally {if(mounted)setState(()=>_loading=false);}
  }

  Future<void> _open(UserModel user) async {
    await Navigator.push(context,MaterialPageRoute(builder:(_)=>UserDetailScreen(user:user)));
    _load();
  }

  Future<void> _create() async {
    await Navigator.push(context,MaterialPageRoute(builder:(_)=>const UserEditScreen()));
    _load();
  }

  @override
  Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('Gestión de usuarios'),actions:[IconButton(onPressed:_load,icon:const Icon(Icons.refresh))]),
    floatingActionButton:FloatingActionButton.extended(onPressed:_create,icon:const Icon(Icons.person_add),label:const Text('Registrar')),
    body:Column(children:[
      Padding(padding:const EdgeInsets.fromLTRB(16,16,16,8),child:TextField(controller:_search,textInputAction:TextInputAction.search,onSubmitted:(_)=>_load(),decoration:InputDecoration(labelText:'Buscar por nombre, correo o documento',prefixIcon:const Icon(Icons.search),suffixIcon:IconButton(onPressed:_load,icon:const Icon(Icons.arrow_forward)),border:const OutlineInputBorder()))),
      Padding(padding:const EdgeInsets.symmetric(horizontal:16),child:Row(children:[
        Expanded(child:DropdownButtonFormField<String>(value:_role,decoration:const InputDecoration(labelText:'Rol'),items:['Todos','user','trabajador','almacenero','admin'].map((v)=>DropdownMenuItem(value:v,child:Text(v))).toList(),onChanged:(v){setState(()=>_role=v!);_load();})),
        const SizedBox(width:12),
        Expanded(child:DropdownButtonFormField<String>(value:_status,decoration:const InputDecoration(labelText:'Estado laboral'),items:['Todos','activo','suspendido','cesado'].map((v)=>DropdownMenuItem(value:v,child:Text(v))).toList(),onChanged:(v){setState(()=>_status=v!);_load();})),
      ])),
      Padding(padding:const EdgeInsets.fromLTRB(16,8,16,4),child:DropdownButtonFormField<String>(value:_active,decoration:const InputDecoration(labelText:'Estado de la cuenta'),items:['Todos','Activa','Deshabilitada'].map((v)=>DropdownMenuItem(value:v,child:Text(v))).toList(),onChanged:(v){setState(()=>_active=v!);_load();})),
      if(_loading) const LinearProgressIndicator(),
      if(_error!=null) Expanded(child:Center(child:Padding(padding:const EdgeInsets.all(24),child:Column(mainAxisSize:MainAxisSize.min,children:[Text(_error!,textAlign:TextAlign.center),const SizedBox(height:12),OutlinedButton(onPressed:_load,child:const Text('Reintentar'))]))))
      else if(!_loading&&_users.isEmpty) const Expanded(child:Center(child:Text('No se encontraron usuarios.')))
      else Expanded(child:RefreshIndicator(onRefresh:_load,child:ListView.builder(padding:const EdgeInsets.only(bottom:90),itemCount:_users.length,itemBuilder:(context,i){final u=_users[i];return ListTile(leading:CircleAvatar(child:Text(u.nombre.isEmpty?'?':u.nombre[0].toUpperCase())),title:Text('${u.nombre} ${u.apellidos}'),subtitle:Text('${u.email}\n${u.role} · ${u.estadoLaboral??'—'}${u.activo?'':' · Deshabilitado'}'),isThreeLine:true,trailing:const Icon(Icons.chevron_right),onTap:()=>_open(u));}))),
    ]),
  );
}
