import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_ocs/data/models/user_model.dart';
import 'package:sistema_ocs/data/network/backend_url.dart';
import 'package:sistema_ocs/data/network/dio_client.dart';
import 'package:sistema_ocs/features/login/auth_notifier.dart';
import 'package:sistema_ocs/features/profile/signature_capture_screen.dart';
import 'package:sistema_ocs/features/users/user_edit_screen.dart';
import 'package:sistema_ocs/features/users/user_state_screen.dart';

class UserDetailScreen extends ConsumerStatefulWidget {
  const UserDetailScreen({super.key, required this.user});
  final UserModel user;
  @override
  ConsumerState<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends ConsumerState<UserDetailScreen> {
  late UserModel _user;
  String? _signatureUrl;
  bool _uploading=false;
  @override
  void initState(){super.initState();_user=widget.user;}

  Future<void> _photo() async {
    final picked=await FilePicker.platform.pickFiles(type:FileType.custom,withData:true,allowedExtensions:const ['jpg','jpeg','png','webp']);
    if(picked==null||picked.files.isEmpty)return;
    setState(()=>_uploading=true);
    try {
      final updated=await ref.read(authServiceProvider).uploadUserPhoto(_user.id,picked.files.single);
      if(mounted)setState(()=>_user=updated);
      _message('Foto actualizada.');
    } catch(e){_message(_detail(e,'No se pudo actualizar la foto.'));}
    finally{if(mounted)setState(()=>_uploading=false);}
  }

  Future<void> _signature() async {
    final base64=await Navigator.push<String>(context,MaterialPageRoute(builder:(_)=>const SignatureCaptureScreen()));
    if(base64==null||!mounted)return;
    setState(()=>_uploading=true);
    try {
      final updated=await ref.read(authServiceProvider).saveUserSignature(_user.id,base64);
      final signatureUrl=await ref.read(authServiceProvider).generateUserSignatureImage(_user.id);
      if(mounted)setState((){_user=updated;_signatureUrl=signatureUrl;});
      _message('Firma actualizada.');
    } catch(e){_message(_detail(e,'No se pudo actualizar la firma.'));}
    finally{if(mounted)setState(()=>_uploading=false);}
  }

  Future<void> _generateSignature() async {
    setState(()=>_uploading=true);
    try {
      final url=await ref.read(authServiceProvider).generateUserSignatureImage(_user.id);
      if(mounted)setState(()=>_signatureUrl=url);
      _message(url==null?'No se encontró una firma guardada.':'Firma lista para visualizar.');
    } catch(e){_message(_detail(e,'No se pudo generar la imagen de firma.'));}
    finally{if(mounted)setState(()=>_uploading=false);}
  }

  Future<void> _edit() async {
    final changed=await Navigator.push<bool>(context,MaterialPageRoute(builder:(_)=>UserEditScreen(user:_user)));
    if(changed!=true||!mounted)return;
    try {
      final fresh=await ref.read(authServiceProvider).getUser(_user.id);
      if(mounted)setState(()=>_user=fresh);
      ref.invalidate(authenticatedUserProvider);
    } catch(e){_message(_detail(e,'No se pudo actualizar el detalle.'));}
  }

  String _detail(Object error,String fallback){
    if(error is DioException && error.response?.data is Map){return error.response?.data['detail']?.toString()??fallback;}
    return fallback;
  }
  void _message(String text){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(text)));}

  @override
  Widget build(BuildContext context){
    final photo=buildBackendUrl(ref.read(dioProvider),_user.fotoUrl);
    return Scaffold(
      appBar:AppBar(title:const Text('Detalle de usuario')),
      body:ListView(padding:const EdgeInsets.all(20),children:[
        Card(child:Padding(padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Center(child:CircleAvatar(radius:42,backgroundImage:photo.isEmpty?null:NetworkImage(photo),child:photo.isEmpty?const Icon(Icons.person,size:42):null)),
          const SizedBox(height:14),Center(child:Text('${_user.nombre} ${_user.apellidos}',style:Theme.of(context).textTheme.headlineSmall,textAlign:TextAlign.center)),
          const SizedBox(height:8),Center(child:Text(_user.email)),const Divider(height:28),
          _row('Rol',_user.role),_row('Estado laboral',_user.estadoLaboral),_row('Cuenta',_user.activo?'Habilitada':'Deshabilitada'),
          _row('Documento','${_user.tipoDocumento??'DNI'} ${_user.dni??''}'),_row('Código',_user.codigoUnico),_row('Cargo',_user.cargo),_row('Área',_user.area),
          _row('Teléfono',_user.telefono),_row('Teléfono secundario',_user.telefonoSecundario),_row('Dirección',_user.direccion),_row('Supervisor ID',_user.supervisorId?.toString()),
        ]))),
        const SizedBox(height:12),
        FilledButton.icon(onPressed:_edit,icon:const Icon(Icons.edit),label:const Text('Editar datos y rol')),
        OutlinedButton.icon(onPressed:()async{final updated=await Navigator.push<UserModel>(context,MaterialPageRoute(builder:(_)=>UserStateScreen(user:_user)));if(updated!=null&&mounted){setState(()=>_user=updated);}},icon:const Icon(Icons.toggle_on),label:const Text('Cambiar estado')),
        OutlinedButton.icon(onPressed:_uploading?null:_photo,icon:const Icon(Icons.photo_camera),label:Text(_uploading?'Procesando...':'Cambiar foto')),
        OutlinedButton.icon(onPressed:_uploading?null:_signature,icon:const Icon(Icons.draw),label:const Text('Cambiar firma')),
        if(_user.firmaBase64?.isNotEmpty==true) OutlinedButton.icon(onPressed:_uploading?null:_generateSignature,icon:const Icon(Icons.visibility),label:const Text('Ver firma guardada')),
        if(_signatureUrl?.isNotEmpty==true) Padding(padding:const EdgeInsets.all(16),child:Image.network(buildBackendUrl(ref.read(dioProvider),_signatureUrl),height:150,fit:BoxFit.contain)),
      ]),
    );
  }

  Widget _row(String label,String? value)=>Padding(padding:const EdgeInsets.symmetric(vertical:6),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[SizedBox(width:155,child:Text(label,style:const TextStyle(fontWeight:FontWeight.w600))),Expanded(child:Text(value?.isNotEmpty==true?value!:'—'))]));
}
