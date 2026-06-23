import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';
import 'package:sistema_ocs/core/database/db_helper.dart';
import 'package:sistema_ocs/core/theme/app_theme.dart';
import 'package:sistema_ocs/features/rq_urgente/models/rq_local_model.dart';
import 'package:sistema_ocs/features/rq_urgente/services/urgent_rq_service.dart';
import 'package:sistema_ocs/features/rq_urgente/urgent_rq_screen.dart';

class RQListScreen extends StatefulWidget {
  const RQListScreen({super.key});

  @override
  State<RQListScreen> createState() => _RQListScreenState();
}

class _RQListScreenState extends State<RQListScreen> {
  List<RQLocal> _requerimientos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _refreshList() async {
    final data = await DBHelper.obtenerRQs();
    setState(() => _requerimientos = data);
  }

  Future<void> _procesoDeEnvio(RQLocal rq) async {
    bool? confirmar = await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: AppTheme.borderRadiusExtraLarge,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
                ),
                child: Icon(
                  LucideIcons.alertTriangle,
                  color: AppTheme.warning,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "CONFIRMAR ENVÍO",
                style: AppTheme.headlineSmall.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Se enviará al área de Logística. Una vez enviado no podrá editar ni borrar este registro.",
                textAlign: TextAlign.center,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppTheme.borderRadiusMedium,
                        ),
                        side: BorderSide(color: AppTheme.border),
                      ),
                      child: Text(
                        "CANCELAR",
                        style: AppTheme.labelLarge.copyWith(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: AppTheme.background,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppTheme.borderRadiusMedium,
                        ),
                        elevation: 4,
                        shadowColor: AppTheme.primary.withOpacity(0.4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.send, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            "CONTINUAR",
                            style: AppTheme.labelLarge.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmar != true) return;

    final SignatureController sigController = SignatureController(
      penStrokeWidth: 4,
      penColor: AppTheme.textPrimary,
      exportBackgroundColor: AppTheme.background,
    );

    bool? firmado = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: AppTheme.borderRadiusExtraLarge,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(LucideIcons.edit, color: AppTheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "FIRMA DE CONFORMIDAD",
                      style: AppTheme.titleMedium.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                "Su firma es necesaria para validar el requerimiento",
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.border, width: 2),
                  borderRadius: AppTheme.borderRadiusLarge,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.textPrimary.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: AppTheme.borderRadiusLarge,
                  child: SizedBox(
                    height: 200,
                    width: 300,
                    child: Signature(
                      controller: sigController,
                      backgroundColor: AppTheme.background,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context, false),
                      icon: Icon(LucideIcons.arrowLeft, size: 18),
                      label: Text("VOLVER"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: AppTheme.border),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => sigController.clear(),
                      icon: Icon(LucideIcons.trash2, size: 18),
                      label: Text("LIMPIAR"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: AppTheme.error),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context, true),
                      icon: Icon(LucideIcons.send, size: 18),
                      label: Text("ENVIAR"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondary,
                        foregroundColor: AppTheme.background,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (firmado != true || sigController.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final signature = await sigController.toPngBytes();
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/firma_final.png').create();
      await file.writeAsBytes(signature!);

      await UrgentRQService().enviarRequerimiento(
        servicio: rq.servicio,
        solicitante: "Residente App",
        email: "danieldecr7@gmail.com",
        productosJson: rq.productosJson,
        firmaFile: file,
      );

      await _marcarComoEnviado(rq);
    } catch (e) {
      if (e.toString().contains("200") || e.toString().contains("201")) {
        await _marcarComoEnviado(rq);
      } else {
        _showSnack("Error: $e", isError: true);
      }
    } finally {
      setState(() => _isLoading = false);
      sigController.dispose();
    }
  }

  Future<void> _marcarComoEnviado(RQLocal rq) async {
    rq.enviado = 1;
    await DBHelper.actualizarRQ(rq);
    _refreshList();
    _showSnack("✅ Enviado con éxito a Logística");
  }

  void _showSnack(String msg, {bool isError = false}) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 60,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isError ? AppTheme.error : AppTheme.success,
              borderRadius: AppTheme.borderRadiusLarge,
              boxShadow: [
                BoxShadow(
                  color: (isError ? AppTheme.error : AppTheme.success).withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
              border: Border.all(
                color: isError ? AppTheme.error.darken20 : AppTheme.success.darken20,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isError ? LucideIcons.alertCircle : LucideIcons.checkCircle,
                  color: AppTheme.background,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    msg,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.background,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () => overlayEntry.remove());
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.textPrimary, AppTheme.textPrimary.darken20],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textPrimary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primary, width: 2),
                ),
                child: Icon(
                  LucideIcons.files,
                  color: AppTheme.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "REQUERIMIENTOS URGENTES",
                      style: AppTheme.labelSmall.copyWith(
                        color: AppTheme.background,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Gestione sus borradores y envíos",
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.background.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildInfoChip(
                icon: LucideIcons.fileText,
                text: "TOTAL: ${_requerimientos.length}",
                color: AppTheme.primary,
              ),
              const SizedBox(width: 12),
              _buildInfoChip(
                icon: LucideIcons.send,
                text: "ENVIADOS: ${_requerimientos.where((r) => r.enviado == 1).length}",
                color: AppTheme.secondary,
              ),
              const SizedBox(width: 12),
              _buildInfoChip(
                icon: LucideIcons.edit,
                text: "BORRADORES: ${_requerimientos.where((r) => r.enviado == 0).length}",
                color: AppTheme.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppTheme.borderRadiusMedium,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTheme.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: AppTheme.borderRadiusLarge,
          border: Border.all(color: AppTheme.border, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.05),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
              ),
              child: Icon(
                LucideIcons.fileX,
                color: AppTheme.textSecondary.withOpacity(0.4),
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "NO HAY REQUERIMIENTOS",
              style: AppTheme.titleMedium.copyWith(
                color: AppTheme.textSecondary.withOpacity(0.6),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Crea tu primer requerimiento urgente\npresionando el botón +",
              textAlign: TextAlign.center,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UrgentRQScreen()),
                );
                _refreshList();
              },
              icon: Icon(LucideIcons.plus, size: 18),
              label: Text("CREAR PRIMER RQ"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.background,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: AppTheme.borderRadiusMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRQCard(RQLocal rq, int index) {
    final bool esEnviado = rq.enviado == 1;
    final fecha = rq.fecha.split(' ')[0];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: esEnviado ? null : () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => UrgentRQScreen(rqExistente: rq)),
            );
            _refreshList();
          },
          borderRadius: AppTheme.borderRadiusLarge,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: AppTheme.borderRadiusLarge,
              border: Border.all(
                color: esEnviado ? AppTheme.success.withOpacity(0.2) : AppTheme.warning.withOpacity(0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.textPrimary.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: esEnviado 
                        ? AppTheme.success.withOpacity(0.1) 
                        : AppTheme.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: esEnviado 
                          ? AppTheme.success.withOpacity(0.3) 
                          : AppTheme.warning.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        esEnviado ? LucideIcons.lock : LucideIcons.fileEdit,
                        color: esEnviado ? AppTheme.success : AppTheme.warning,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                rq.servicio,
                                style: AppTheme.titleMedium.copyWith(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: esEnviado 
                                  ? AppTheme.success.withOpacity(0.1) 
                                  : AppTheme.warning.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: esEnviado 
                                    ? AppTheme.success.withOpacity(0.3) 
                                    : AppTheme.warning.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                esEnviado ? "ENVIADO" : "BORRADOR",
                                style: AppTheme.labelSmall.copyWith(
                                  color: esEnviado ? AppTheme.success : AppTheme.warning,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Fecha: $fecha",
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "#${index + 1}",
                            style: AppTheme.labelSmall.copyWith(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  esEnviado
                      ? Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.success.withOpacity(0.3)),
                          ),
                          child: Icon(
                            LucideIcons.checkCircle,
                            color: AppTheme.success,
                            size: 24,
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppTheme.primary, AppTheme.secondary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: () => _procesoDeEnvio(rq),
                            icon: Icon(LucideIcons.send, color: AppTheme.background),
                            tooltip: "Enviar a Logística",
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

  Widget _buildFloatingButton() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: AppTheme.borderRadiusLarge,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UrgentRQScreen()),
          );
          _refreshList();
        },
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.background,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppTheme.borderRadiusLarge,
        ),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(LucideIcons.plus, color: AppTheme.textPrimary, size: 20),
        ),
        label: Text(
          "NUEVO REQUERIMIENTO",
          style: AppTheme.labelLarge.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation(AppTheme.primary),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "PROCESANDO ENVÍO...",
                          style: AppTheme.labelMedium.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : _requerimientos.isEmpty
                    ? _buildEmptyState()
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            ..._requerimientos.asMap().entries.map((entry) {
                              return _buildRQCard(entry.value, entry.key);
                            }).toList(),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFloatingButton(),
    );
  }
}