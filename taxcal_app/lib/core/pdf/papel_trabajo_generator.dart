import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../formatting/money_formatter.dart';
import '../../features/espejo_sat/espejo_providers.dart';

/// Cláusula legal bloqueante (especificación funcional y técnica, sección
/// 6.4): debe aparecer, sin excepción, en el pie de página de los reportes
/// PDF generados.
const String clausulaLegalPapelTrabajo =
    'Esta aplicación constituye únicamente una bitácora contable de uso '
    'privado y un simulador interactivo diseñado para facilitar la '
    'preparación visual de los datos fiscales. La herramienta carece de '
    'conexión, API o autorización formal por parte del Servicio de '
    'Administración Tributaria (SAT) o la Secretaría de Hacienda y Crédito '
    'Público. El cálculo de los impuestos simulados se realiza de forma '
    'indicativa basada en la interpretación de las guías de llenado del SAT. '
    'La presentación legal de las declaraciones y el cumplimiento de las '
    'obligaciones tributarias recaen bajo la estricta responsabilidad '
    'personal del contribuyente, quien deberá ingresar, validar y transmitir '
    'manualmente sus datos directamente en el sitio web oficial del SAT para '
    'la obtención del acuse de recibo y la línea de captura válidos.';

/// Genera el "papel de trabajo" en PDF de la determinación Espejo SAT
/// (README, sección "4. Espejo SAT"; especificación técnica, sección 4:
/// "Generador de Papeles de Trabajo").
class PapelTrabajoGenerator {
  const PapelTrabajoGenerator._();

  static Future<Uint8List> generar({
    required String nombreContribuyente,
    required String rfcContribuyente,
    required String periodoLabel,
    required EspejoIsrDatos isr,
    required EspejoIvaDatos iva,
    required double totalAPagar,
    required String fechaLimiteLabel,
  }) async {
    final documento = pw.Document();

    documento.addPage(
      pw.MultiPage(
        footer: (context) => pw.Padding(
          padding: const pw.EdgeInsets.only(top: 8),
          child: pw.Text(
            clausulaLegalPapelTrabajo,
            style: pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
            textAlign: pw.TextAlign.justify,
          ),
        ),
        build: (context) => [
          pw.Text(
            'Soy612 - Papel de trabajo',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text('Periodo: $periodoLabel'),
          pw.Text('Contribuyente: $nombreContribuyente'),
          pw.Text('RFC: $rfcContribuyente'),
          pw.SizedBox(height: 18),
          pw.Text(
            'Determinación de ISR Propio',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headers: ['Concepto', 'Importe'],
            data: [
              ['Ingresos acumulados', formatMoney(isr.ingresosAcumulados)],
              ['Deducciones acumuladas', formatMoney(isr.deduccionesAcumuladas)],
              ['PTU pagada en el ejercicio', formatMoney(isr.ptuPagada)],
              ['Pérdidas fiscales de ejercicios anteriores', formatMoney(isr.perdidasFiscales)],
              ['Subsidio al empleo', '(vacío a propósito)'],
              ['Base gravable acumulada', formatMoney(isr.baseGravableAcumulada)],
              [
                'Pagos provisionales de meses anteriores',
                formatMoney(isr.pagosProvisionalesAnteriores),
              ],
              ['ISR a cargo del periodo', formatMoney(isr.isrACargo < 0 ? 0 : isr.isrACargo)],
            ],
            cellAlignment: pw.Alignment.centerLeft,
            cellAlignments: {1: pw.Alignment.centerRight},
          ),
          pw.SizedBox(height: 18),
          pw.Text(
            'Determinación de IVA Definitivo',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headers: ['Concepto', 'Importe'],
            data: [
              ['IVA cobrado (16%)', formatMoney(iva.ivaCobrado)],
              ['IVA acreditable (16%)', formatMoney(iva.ivaAcreditable)],
              ['Saldo a favor de periodos anteriores', formatMoney(iva.saldoFavorAnterior)],
              [
                iva.esACargo ? 'IVA a cargo del periodo' : 'Saldo a favor de IVA',
                formatMoney(iva.impuestoNeto.abs()),
              ],
            ],
            cellAlignment: pw.Alignment.centerLeft,
            cellAlignments: {1: pw.Alignment.centerRight},
          ),
          pw.SizedBox(height: 18),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400)),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Total a pagar este periodo: ${formatMoney(totalAPagar < 0 ? 0 : totalAPagar)}',
                  style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text('Fecha límite estimada: $fechaLimiteLabel'),
              ],
            ),
          ),
        ],
      ),
    );

    return documento.save();
  }
}
