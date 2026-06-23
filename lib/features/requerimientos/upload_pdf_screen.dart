import 'package:flutter/material.dart';
import 'package:sistema_ocs/core/theme/app_theme.dart';
import 'package:dotted_border/dotted_border.dart';

class UploadPDFScreen extends StatelessWidget {
  const UploadPDFScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXXXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.picture_as_pdf, size: 80, color: AppTheme.primary),
            const SizedBox(height: AppTheme.spacingXL),
            Text(
              'Cargar Requerimiento desde PDF',
              style: AppTheme.titleLarge.copyWith(color: AppTheme.primary),
            ),
            const SizedBox(height: AppTheme.spacingXXL),
            DottedBorder(
              color: AppTheme.secondary,
              strokeWidth: 2,
              dashPattern: const [8, 4],
              borderType: BorderType.RRect,
              radius: const Radius.circular(10),
              child: Container(
                height: 150,
                width: double.infinity,
                color: AppTheme.secondaryLight,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload, size: 40, color: AppTheme.secondary),
                    SizedBox(height: AppTheme.spacingS),
                    Text('Arrastre o toque para seleccionar archivo PDF'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingXXL),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.save_alt),
              label: const Text('Subir RQ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondary,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
