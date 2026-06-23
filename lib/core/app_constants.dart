// lib/core/app_constants.dart

class AppRoles {
  static const String admin = 'admin';
  static const String jefe = 'JEFE';
  static const String compras = 'COMPRAS';
  static const String logistica = 'LOGÍSTICA';
  static const String usuarioBase = 'USUARIO BASE';
  
  // Roles que pueden aprobar/rechazar
  static const List<String> canApprove = [admin, jefe];
  
  // Roles que ven Inventario
  static const List<String> canSeeInventory = [admin, jefe, compras, logistica];
}