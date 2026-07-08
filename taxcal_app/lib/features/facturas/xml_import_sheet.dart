import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_typography.dart';
import 'xml_import_controller.dart';

/// Bottom sheet de importación XML (README, sección "Flujo de importación
/// XML"): selección de archivos .xml reales, estados de progreso por archivo
/// y pantalla de resumen.
void showXmlImportSheet(BuildContext context, WidgetRef ref) {
  ref.read(xmlImportControllerProvider.notifier).reiniciar();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.bottomSheet)),
    ),
    builder: (context) => const _XmlImportSheetBody(),
  );
}

Future<String?> _pedirRfcPropio(BuildContext context) {
  final controlador = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text('Tu RFC', style: AppTypography.sans(fontWeight: FontWeight.w700)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Necesitamos tu RFC para saber si cada factura es un ingreso o un '
            'gasto tuyo.',
            style: AppTypography.sans(fontSize: 13, color: AppColors.textSecondaryMax),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controlador,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(hintText: 'RFC'),
            style: AppTypography.mono(fontSize: 15),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final rfc = controlador.text.trim().toUpperCase();
            if (rfc.length >= 12) Navigator.of(context).pop(rfc);
          },
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
}

Future<void> _elegirArchivos(BuildContext context, WidgetRef ref) async {
  final controller = ref.read(xmlImportControllerProvider.notifier);
  var rfcPropio = await controller.rfcPropioConfigurado();
  if (rfcPropio == null) {
    if (!context.mounted) return;
    rfcPropio = await _pedirRfcPropio(context);
    if (rfcPropio == null) return;
    await controller.guardarRfcPropio(rfcPropio);
  }

  final resultado = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['xml'],
    allowMultiple: true,
  );
  if (resultado == null || resultado.files.isEmpty) return;

  final archivos = <(String, String)>[];
  for (final archivo in resultado.files) {
    final ruta = archivo.path;
    if (ruta == null) continue;
    archivos.add((archivo.name, await File(ruta).readAsString()));
  }
  if (archivos.isEmpty) return;

  final nombrePropio = await controller.nombrePropioConfigurado();
  await controller.importarArchivos(archivos, rfcPropio: rfcPropio, nombrePropio: nombrePropio);
}

class _XmlImportSheetBody extends ConsumerWidget {
  const _XmlImportSheetBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(xmlImportControllerProvider);

    final Widget contenido;
    if (estado.resumen != null) {
      contenido = _ResumenView(resumen: estado.resumen!);
    } else if (estado.procesando) {
      contenido = _ProcesandoView(archivos: estado.archivos);
    } else {
      contenido = const _IdleView();
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 14,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            contenido,
          ],
        ),
      ),
    );
  }
}

class _IdleView extends StatelessWidget {
  const _IdleView();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 14,
      children: [
        Text(
          'Importar facturas XML',
          style: AppTypography.sans(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        Text(
          'Selecciona tus archivos CFDI 4.0. Todo se procesa en tu teléfono; '
          'nada se sube a internet.',
          style: AppTypography.sans(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondaryMax,
            height: 1.5,
          ),
        ),
        Consumer(
          builder: (context, ref, _) => InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _elegirArchivos(context, ref),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(Icons.upload_file, size: 28, color: Colors.white.withValues(alpha: 0.5)),
                  const SizedBox(height: 8),
                  Text(
                    'Toca para elegir archivos .xml',
                    style: AppTypography.sans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProcesandoView extends StatelessWidget {
  const _ProcesandoView({required this.archivos});

  final List<ArchivoEnProceso> archivos;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 14,
      children: [
        Text(
          'Procesando tus CFDIs…',
          style: AppTypography.sans(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        Column(
          spacing: 8,
          children: [
            for (final archivo in archivos)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        archivo.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.sans(fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      switch (archivo.estado) {
                        EstadoArchivo.leyendo => 'Leyendo…',
                        EstadoArchivo.listo => '✓ Listo',
                        EstadoArchivo.error => 'No se pudo leer',
                      },
                      style: AppTypography.sans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: switch (archivo.estado) {
                          EstadoArchivo.leyendo => AppColors.textSecondaryMin,
                          EstadoArchivo.listo => AppColors.accentPrimaryText,
                          EstadoArchivo.error => AppColors.errorNotDeductible,
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ResumenView extends ConsumerWidget {
  const _ResumenView({required this.resumen});

  final ResumenImportacion resumen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = resumen.ingresos + resumen.gastos;
    final headline = total > 0
        ? '$total factura${total == 1 ? '' : 's'} importada${total == 1 ? '' : 's'}'
        : 'No se importó ninguna factura';
    final subtext = total > 0
        ? 'Ya están disponibles en tu lista de Facturas y en el Tablero de este mes.'
        : 'Revisa que tus archivos sean CFDI 4.0 válidos e inténtalo de nuevo.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 14,
      children: [
        Column(
          spacing: 6,
          children: [
            const Text('✅', style: TextStyle(fontSize: 34)),
            Text(headline, style: AppTypography.sans(fontSize: 17, fontWeight: FontWeight.w700)),
            Text(
              subtext,
              textAlign: TextAlign.center,
              style: AppTypography.sans(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondaryMax,
                height: 1.5,
              ),
            ),
          ],
        ),
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: _ResumenContador(
                valor: resumen.ingresos,
                etiqueta: 'Ingresos',
                color: AppColors.accentPrimaryText,
              ),
            ),
            Expanded(
              child: _ResumenContador(
                valor: resumen.gastos,
                etiqueta: 'Gastos',
                color: AppColors.textPrimary,
              ),
            ),
            Expanded(
              child: _ResumenContador(
                valor: resumen.nuevosContribuyentes,
                etiqueta: 'Contactos nuevos',
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        if (resumen.errores > 0)
          Text(
            '${resumen.errores} archivo${resumen.errores == 1 ? '' : 's'} no se pudo leer. '
            'Verifica que sea un CFDI 4.0 válido.',
            textAlign: TextAlign.center,
            style: AppTypography.sans(fontSize: 12, color: AppColors.errorNotDeductible),
          ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accentPrimary,
            foregroundColor: AppColors.accentPrimaryButtonText,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Ver en Facturas',
            style: AppTypography.sans(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
        TextButton(
          onPressed: () => ref.read(xmlImportControllerProvider.notifier).reiniciar(),
          child: Text(
            'Importar más',
            style: AppTypography.sans(fontSize: 13.5, color: AppColors.textSecondaryMax),
          ),
        ),
      ],
    );
  }
}

class _ResumenContador extends StatelessWidget {
  const _ResumenContador({required this.valor, required this.etiqueta, required this.color});

  final int valor;
  final String etiqueta;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '$valor',
            style: AppTypography.mono(fontSize: 18, fontWeight: FontWeight.w700, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            etiqueta,
            textAlign: TextAlign.center,
            style: AppTypography.helper.copyWith(color: AppColors.textSecondaryMin),
          ),
        ],
      ),
    );
  }
}
