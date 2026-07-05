import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_providers.dart';
import '../../core/xml/cfdi.dart';
import '../../core/xml/cfdi_parser.dart';
import '../../data/db/app_database.dart';
import '../../data/db/tables.dart';
import 'facturas_ejemplo_fixtures.dart';

enum EstadoArchivo { leyendo, listo, error }

class ArchivoEnProceso {
  const ArchivoEnProceso({required this.nombre, required this.estado, this.mensajeError});

  final String nombre;
  final EstadoArchivo estado;
  final String? mensajeError;

  ArchivoEnProceso copyWith({EstadoArchivo? estado, String? mensajeError}) => ArchivoEnProceso(
    nombre: nombre,
    estado: estado ?? this.estado,
    mensajeError: mensajeError ?? this.mensajeError,
  );
}

/// Contadores de la pantalla de resumen (README, sección "Flujo de
/// importación XML": "contadores de ingresos/gastos/nuevos contribuyentes
/// importados, con manejo de errores").
class ResumenImportacion {
  const ResumenImportacion({
    required this.ingresos,
    required this.gastos,
    required this.nuevosContribuyentes,
    required this.errores,
  });

  final int ingresos;
  final int gastos;
  final int nuevosContribuyentes;
  final int errores;
}

class XmlImportState {
  const XmlImportState({
    this.archivos = const [],
    this.resumen,
    this.procesando = false,
  });

  final List<ArchivoEnProceso> archivos;
  final ResumenImportacion? resumen;
  final bool procesando;

  XmlImportState copyWith({
    List<ArchivoEnProceso>? archivos,
    ResumenImportacion? resumen,
    bool? procesando,
  }) => XmlImportState(
    archivos: archivos ?? this.archivos,
    resumen: resumen ?? this.resumen,
    procesando: procesando ?? this.procesando,
  );
}

/// Orquesta el pipeline de importación de CFDI (sección 4 de la
/// especificación funcional): parseo en isolate, alta automática de
/// contribuyentes, clasificación ingreso/egreso por RFC y mapeo del flujo de
/// efectivo (PUE/PPD).
class XmlImportController extends Notifier<XmlImportState> {
  @override
  XmlImportState build() => const XmlImportState();

  /// Devuelve el RFC propio configurado, o `null` si el usuario todavía no
  /// lo ha capturado (caso en el que la UI debe pedirlo antes de continuar).
  Future<String?> rfcPropioConfigurado() async {
    final prefs = await ref.read(appPreferencesProvider.future);
    final rfc = prefs.rfcContribuyente;
    return (rfc == null || rfc.isEmpty) ? null : rfc;
  }

  Future<void> guardarRfcPropio(String rfc) async {
    final prefs = await ref.read(appPreferencesProvider.future);
    await prefs.guardarRfcContribuyente(rfc);
  }

  Future<String> nombrePropioConfigurado() async {
    final prefs = await ref.read(appPreferencesProvider.future);
    return prefs.nombreContribuyente ?? prefs.rfcContribuyente ?? '';
  }

  /// Genera y procesa las 3 facturas de ejemplo. Si el usuario no ha
  /// configurado su RFC todavía, se asigna un RFC de demostración para que
  /// el ejemplo funcione de inmediato sin depender de Configuración.
  Future<void> importarFacturasDeEjemplo() async {
    final prefs = await ref.read(appPreferencesProvider.future);
    var rfcPropio = prefs.rfcContribuyente;
    if (rfcPropio == null || rfcPropio.isEmpty) {
      await prefs.guardarRfcContribuyente(demoRfcPorDefecto);
      await prefs.guardarNombreContribuyente(demoNombrePorDefecto);
      rfcPropio = demoRfcPorDefecto;
    }
    final nombrePropio = prefs.nombreContribuyente ?? demoNombrePorDefecto;

    final archivos = generarFacturasDeEjemplo(rfcPropio: rfcPropio, nombrePropio: nombrePropio);
    await _importar(archivos, rfcPropio: rfcPropio, nombrePropio: nombrePropio);
  }

  Future<void> importarArchivos(
    List<(String nombre, String contenido)> archivos, {
    required String rfcPropio,
    required String nombrePropio,
  }) => _importar(archivos, rfcPropio: rfcPropio, nombrePropio: nombrePropio);

  Future<void> _importar(
    List<(String nombre, String contenido)> archivos, {
    required String rfcPropio,
    required String nombrePropio,
  }) async {
    final db = ref.read(appDatabaseProvider);

    state = XmlImportState(
      archivos: [
        for (final (nombre, _) in archivos)
          ArchivoEnProceso(nombre: nombre, estado: EstadoArchivo.leyendo),
      ],
      procesando: true,
    );

    final rfcsExistentesAntes = (await db.watchContribuyentes().first).map((c) => c.rfc).toSet();
    final nuevosContribuyentes = <String>{};
    var ingresos = 0;
    var gastos = 0;
    var errores = 0;

    for (var indice = 0; indice < archivos.length; indice++) {
      final (_, contenido) = archivos[indice];
      try {
        final cfdi = await compute(parsearCfdi, contenido);

        // Si emití el CFDI, es un ingreso mío; si lo recibí, es un egreso mío
        // (especificación funcional, sección 4.2: "Receptor si la factura es
        // de ingreso, Emisor si es de egreso" se refiere a la contraparte).
        final esIngreso = cfdi.emisorRfc == rfcPropio;
        final esEgreso = cfdi.receptorRfc == rfcPropio;
        if (!esIngreso && !esEgreso) {
          throw const CfdiInvalidoException('Este CFDI no corresponde a tu RFC configurado.');
        }

        await db.altaContribuyenteSiNoExiste(rfc: rfcPropio, razonSocial: nombrePropio);
        final contraparteRfc = esIngreso ? cfdi.receptorRfc : cfdi.emisorRfc;
        final contraparteNombre = esIngreso ? cfdi.receptorNombre : cfdi.emisorNombre;
        await db.altaContribuyenteSiNoExiste(rfc: contraparteRfc, razonSocial: contraparteNombre);
        if (!rfcsExistentesAntes.contains(contraparteRfc)) {
          nuevosContribuyentes.add(contraparteRfc);
        }

        final tipo = esIngreso ? TipoCfdi.ingreso : TipoCfdi.egreso;
        final estatus = cfdi.esPue
            ? (esIngreso ? EstatusPago.cobrado : EstatusPago.pagado)
            : EstatusPago.pendiente;

        await db.insertarFacturaSiNoExiste(
          FacturasCompanion.insert(
            uuid: cfdi.uuid,
            folioInterno: Value(cfdi.folio),
            fechaEmision: cfdi.fechaEmision,
            fechaPagoEfectivo: cfdi.esPue
                ? Value(cfdi.fechaEmision)
                : const Value.absent(),
            rfcEmisor: cfdi.emisorRfc,
            rfcReceptor: cfdi.receptorRfc,
            tipoCfdi: tipo,
            subtotal: cfdi.subtotal,
            tasaIva: Value(cfdi.tasaIva),
            ivaTrasladado: Value(cfdi.ivaTrasladado),
            ivaRetenido: Value(cfdi.ivaRetenido),
            isrRetenido: Value(cfdi.isrRetenido),
            total: cfdi.total,
            metodoPago: cfdi.esPue ? MetodoPagoCfdi.pue : MetodoPagoCfdi.ppd,
            formaPago: cfdi.formaPago,
            estatusPago: estatus,
          ),
        );

        if (esIngreso) {
          ingresos++;
        } else {
          gastos++;
        }
        _actualizarArchivo(indice, EstadoArchivo.listo);
      } catch (error) {
        errores++;
        _actualizarArchivo(indice, EstadoArchivo.error, mensajeError: error.toString());
      }
    }

    state = state.copyWith(
      procesando: false,
      resumen: ResumenImportacion(
        ingresos: ingresos,
        gastos: gastos,
        nuevosContribuyentes: nuevosContribuyentes.length,
        errores: errores,
      ),
    );
  }

  void _actualizarArchivo(int indice, EstadoArchivo estado, {String? mensajeError}) {
    final lista = [...state.archivos];
    lista[indice] = lista[indice].copyWith(estado: estado, mensajeError: mensajeError);
    state = state.copyWith(archivos: lista);
  }

  void reiniciar() => state = const XmlImportState();
}

final xmlImportControllerProvider = NotifierProvider<XmlImportController, XmlImportState>(
  XmlImportController.new,
);
