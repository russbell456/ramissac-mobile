import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'prestamo_detalle_screen.dart';

class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({super.key});

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen>
    with SingleTickerProviderStateMixin {
  bool scanned = false;
  late AnimationController _animationController;
  late Animation<double> _scanLineAnimation;

  // Controlador para la cámara
  final MobileScannerController cameraController = MobileScannerController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _scanLineAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Escanear QR',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Botón de linterna corregido para versiones recientes de mobile_scanner
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController,
              builder: (context, state, child) {
                // Accedemos a torchState desde el estado del controlador
                switch (state.torchState) {
                  case TorchState.on:
                    return const Icon(Icons.flashlight_on, color: Colors.yellow);
                  case TorchState.off:
                  default:
                    return const Icon(Icons.flashlight_off, color: Colors.white);
                }
              },
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Escáner QR
          MobileScanner(
            controller: cameraController,
            onDetect: (barcodeCapture) {
              if (scanned) return;

              final barcode = barcodeCapture.barcodes.first;
              final String? raw = barcode.rawValue;

              if (raw != null) {
                scanned = true;

                try {
                  final data = jsonDecode(raw);

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PrestamoDetalleScreen(data: data),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('QR inválido'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  setState(() => scanned = false);
                }
              }
            },
          ),

          // Superposición con máscara y área de escaneo
          CustomPaint(
            painter: ScannerOverlayPainter(),
            child: Center(
              child: SizedBox(
                width: 280,
                height: 280,
                child: Stack(
                  children: [
                    // Borde animado (pulsante)
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.cyan.withOpacity(
                                0.6 + 0.4 * _animationController.value,
                              ),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyan.withOpacity(
                                  0.3 + 0.2 * _animationController.value,
                                ),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // Línea de escaneo móvil
                    AnimatedBuilder(
                      animation: _scanLineAnimation,
                      builder: (context, child) {
                        return Positioned(
                          top: 10 + (_scanLineAnimation.value * 260),
                          left: 10,
                          right: 10,
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.cyan.withOpacity(0.8),
                                  Colors.cyan,
                                  Colors.cyan.withOpacity(0.8),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.cyan.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // Esquinas decorativas
                    ..._buildCorner(10, 10, Alignment.topLeft),
                    ..._buildCorner(10, 10, Alignment.topRight),
                    ..._buildCorner(10, 10, Alignment.bottomLeft),
                    ..._buildCorner(10, 10, Alignment.bottomRight),
                  ],
                ),
              ),
            ),
          ),

          // Texto inferior
          Positioned(
            left: 0,
            right: 0,
            bottom: 60,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'Coloca el código QR dentro del recuadro',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'El escaneo será automático',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCorner(double size, double radius, Alignment alignment) {
    return [
      Align(
        alignment: alignment,
        child: Container(
          width: size * 2,
          height: size * 2,
          decoration: BoxDecoration(
            border: Border(
              top: alignment == Alignment.topLeft || alignment == Alignment.topRight
                  ? const BorderSide(color: Colors.cyan, width: 4)
                  : BorderSide.none,
              bottom: alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight
                  ? const BorderSide(color: Colors.cyan, width: 4)
                  : BorderSide.none,
              left: alignment == Alignment.topLeft || alignment == Alignment.bottomLeft
                  ? const BorderSide(color: Colors.cyan, width: 4)
                  : BorderSide.none,
              right: alignment == Alignment.topRight || alignment == Alignment.bottomRight
                  ? const BorderSide(color: Colors.cyan, width: 4)
                  : BorderSide.none,
            ),
          ),
        ),
      ),
    ];
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.5);
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final centerRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 280,
      height: 280,
    );

    // Usar RRect si quieres esquinas redondeadas en la máscara
    path.addRRect(RRect.fromRectAndRadius(centerRect, const Radius.circular(24)));
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}