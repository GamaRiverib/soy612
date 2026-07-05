import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_providers.dart';
import '../../core/formatting/money_formatter.dart';
import '../../data/db/app_database.dart';
import '../../data/db/tables.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_typography.dart';
import '../shared/periodo_activo_controller.dart';
import 'anual_providers.dart';
import 'tendencia_mensual_chart.dart';

/// Simulador de cierre del ejercicio fiscal (README, sección "5. Anual").
class AnualScreen extends ConsumerWidget {
  const AnualScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periodo = ref.watch(periodoActivoProvider).value;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                6,
                AppSpacing.screenHorizontal,
                2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ejercicio fiscal',
                    style: AppTypography.sans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondaryMax,
                      letterSpacing: 0.2,
                    ),
                  ),
                  Text(
                    periodo != null ? 'Anual ${periodo.anio}' : 'Anual',
                    style: AppTypography.screenTitle,
                  ),
                ],
              ),
            ),
            const Expanded(child: _AnualBody()),
          ],
        ),
      ),
    );
  }
}

class _AnualBody extends ConsumerWidget {
  const _AnualBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datosAsync = ref.watch(anualDatosProvider);

    return datosAsync.when(
      data: (datos) => ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          16,
          AppSpacing.screenHorizontal,
          28,
        ),
        children: [
          Row(
            children: [
              Expanded(
                child: _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ingresos del año',
                        style: AppTypography.label.copyWith(color: AppColors.textSecondaryMax),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formatMoney(datos.ingresosAnuales),
                        style: AppTypography.mono(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentPrimaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.cardGap),
              Expanded(
                child: _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gastos deducibles',
                        style: AppTypography.label.copyWith(color: AppColors.textSecondaryMax),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formatMoney(datos.gastosAnuales),
                        style: AppTypography.mono(fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.cardGap),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tendencia mensual', style: AppTypography.bodyStrong),
                    Row(
                      children: [
                        const _Legend(color: AppColors.accentPrimary, label: 'Ingresos'),
                        const SizedBox(width: 10),
                        const _Legend(color: AppColors.accentSecondary, label: 'Gastos'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TendenciaMensualChart(tendenciaMensual: datos.tendenciaMensual),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.cardGap),
          if (datos.hayViolacionesBancarizacion)
            _BancarizacionAlert(datos: datos)
          else
            const _BancarizacionOk(),
          const SizedBox(height: AppSpacing.cardGap),
          const _DeduccionesPersonalesCard(),
          const SizedBox(height: AppSpacing.cardGap),
          _SimuladorCierreCard(datos: datos),
          const SizedBox(height: 20),
          Text(
            'Cálculo simplificado para este prototipo. No sustituye al cálculo oficial del SAT.',
            textAlign: TextAlign.center,
            style: AppTypography.helper.copyWith(color: AppColors.textSecondaryMin),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text(
          'No se pudo calcular el Anual: $error',
          style: AppTypography.sans(color: AppColors.errorNotDeductible),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.helper.copyWith(color: AppColors.textSecondaryMax)),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: child,
    );
  }
}

class _BancarizacionAlert extends StatelessWidget {
  const _BancarizacionAlert({required this.datos});

  final AnualDatos datos;

  @override
  Widget build(BuildContext context) {
    final cantidad = datos.violacionesBancarizacion.length;
    final headline = '$cantidad gasto${cantidad == 1 ? '' : 's'} sin bancarizar este año';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.accentSecondary.withValues(alpha: 0.12),
        border: Border.all(color: AppColors.accentSecondary.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      headline,
                      style: AppTypography.sans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accentSecondaryTextLight,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Pagaste en efectivo gastos de más de \$2,000.00. El SAT no permite deducirlos '
                      'por incumplir las reglas de bancarización. En total dejaste fuera '
                      '${formatMoney(datos.totalNoBancarizado)} de tus deducciones del año.',
                      style: AppTypography.sans(
                        fontSize: 12,
                        color: AppColors.accentSecondaryTextLight.withValues(alpha: 0.85),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            spacing: 6,
            children: [
              for (final item in datos.violacionesBancarizacion)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.contraparteRazonSocial,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.sans(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formatMoney(item.factura.total),
                        style: AppTypography.mono(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentSecondaryTextLight,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BancarizacionOk extends StatelessWidget {
  const _BancarizacionOk();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.accentPrimary.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.accentPrimary.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Text('✓', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Todos tus gastos del año cumplen con la regla de bancarización.',
              style: AppTypography.sans(
                fontSize: 12.5,
                color: AppColors.accentPrimaryText,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _FormaPagoSeleccionada { tarjeta, efectivo }

class _DeduccionesPersonalesCard extends ConsumerStatefulWidget {
  const _DeduccionesPersonalesCard();

  @override
  ConsumerState<_DeduccionesPersonalesCard> createState() => _DeduccionesPersonalesCardState();
}

class _DeduccionesPersonalesCardState extends ConsumerState<_DeduccionesPersonalesCard> {
  final _conceptoController = TextEditingController();
  final _montoController = TextEditingController();
  _FormaPagoSeleccionada _formaPago = _FormaPagoSeleccionada.tarjeta;
  bool _esFunerario = false;

  @override
  void dispose() {
    _conceptoController.dispose();
    _montoController.dispose();
    super.dispose();
  }

  Future<void> _agregar() async {
    final concepto = _conceptoController.text.trim();
    final monto = double.tryParse(_montoController.text) ?? 0;
    if (concepto.isEmpty || monto <= 0) return;

    final periodo = ref.read(periodoActivoProvider).value;
    if (periodo == null) return;

    final db = ref.read(appDatabaseProvider);
    await db.agregarDeduccionPersonal(
      ejercicioFiscal: periodo.anio,
      concepto: concepto,
      monto: monto,
      formaPago: _formaPago == _FormaPagoSeleccionada.tarjeta
          ? FormaPagoPersonal.tarjeta
          : FormaPagoPersonal.efectivo,
      esFunerario: _formaPago == _FormaPagoSeleccionada.efectivo && _esFunerario,
    );

    setState(() {
      _conceptoController.clear();
      _montoController.clear();
      _formaPago = _FormaPagoSeleccionada.tarjeta;
      _esFunerario = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final datosAsync = ref.watch(anualDatosProvider);
    final deduccionesAsync = ref.watch(deduccionesPersonalesProvider);
    final db = ref.watch(appDatabaseProvider);

    final tope = datosAsync.value?.topeDeduccionesPersonales ?? 0;
    final aplicadas = datosAsync.value?.deduccionesPersonalesAplicadas ?? 0;
    final pct = datosAsync.value?.porcentajeDeduccionesAplicadas ?? 0;
    final deducciones = deduccionesAsync.value ?? const <DeduccionPersonal>[];

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bolsa de deducciones personales',
            style: AppTypography.bodyStrong.copyWith(fontSize: 13.5),
          ),
          const SizedBox(height: 2),
          Text(
            'Gastos médicos, dentales, seguros y colegiaturas. No cuenta lo pagado en '
            'efectivo (salvo gastos funerarios).',
            style: AppTypography.helper.copyWith(color: AppColors.textSecondaryMin, height: 1.4),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${formatMoney(aplicadas)} de ${formatMoney(tope)} tope anual',
                style: AppTypography.sans(fontSize: 11.5, color: AppColors.textSecondaryMax),
              ),
              Text(
                '$pct%',
                style: AppTypography.sans(fontSize: 11.5, color: AppColors.textSecondaryMax),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: SizedBox(
              height: 8,
              child: Stack(
                children: [
                  Container(color: AppColors.background),
                  AnimatedFractionallySizedBox(
                    duration: AppMotion.toggleDuration,
                    curve: Curves.linear,
                    widthFactor: pct / 100,
                    alignment: Alignment.centerLeft,
                    child: Container(color: AppColors.accentPrimary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (final deduccion in deducciones) ...[
            _DeduccionPersonalRow(
              deduccion: deduccion,
              onEliminar: () => db.eliminarDeduccionPersonal(deduccion.id),
            ),
            const SizedBox(height: 8),
          ],
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0x14FFFFFF))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                TextField(
                  controller: _conceptoController,
                  style: AppTypography.sans(fontSize: 13.5),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Concepto (ej. Consulta dental)',
                    hintStyle: AppTypography.sans(
                      fontSize: 13.5,
                      color: AppColors.textSecondaryMin,
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _montoController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        style: AppTypography.mono(fontSize: 13.5),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'Monto',
                          hintStyle: AppTypography.mono(
                            fontSize: 13.5,
                            color: AppColors.textSecondaryMin,
                          ),
                          filled: true,
                          fillColor: AppColors.background,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          _FormaPagoTab(
                            label: 'Tarjeta',
                            selected: _formaPago == _FormaPagoSeleccionada.tarjeta,
                            onTap: () => setState(() => _formaPago = _FormaPagoSeleccionada.tarjeta),
                          ),
                          _FormaPagoTab(
                            label: 'Efectivo',
                            selected: _formaPago == _FormaPagoSeleccionada.efectivo,
                            onTap: () => setState(() => _formaPago = _FormaPagoSeleccionada.efectivo),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_formaPago == _FormaPagoSeleccionada.efectivo)
                  InkWell(
                    onTap: () => setState(() => _esFunerario = !_esFunerario),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: AppMotion.toggleDuration,
                          curve: Curves.linear,
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: _esFunerario ? AppColors.accentPrimary : Colors.transparent,
                            borderRadius: BorderRadius.circular(5),
                            border: _esFunerario
                                ? null
                                : Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                          ),
                          child: _esFunerario
                              ? const Icon(Icons.check, size: 14, color: Colors.black)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Es un gasto funerario (sí se permite en efectivo)',
                            style: AppTypography.sans(
                              fontSize: 12,
                              color: AppColors.textSecondaryMax,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _agregar,
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.toggleTrackOff,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      '+ Agregar gasto personal',
                      style: AppTypography.sans(fontSize: 13.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormaPagoTab extends StatelessWidget {
  const _FormaPagoTab({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.toggleDuration,
      curve: Curves.linear,
      decoration: BoxDecoration(
        color: selected ? AppColors.toggleTrackOff : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
      ),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: selected ? Colors.white : AppColors.textSecondaryMax,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          minimumSize: Size.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        ),
        child: Text(label, style: AppTypography.sans(fontSize: 11.5, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _DeduccionPersonalRow extends StatelessWidget {
  const _DeduccionPersonalRow({required this.deduccion, required this.onEliminar});

  final DeduccionPersonal deduccion;
  final VoidCallback onEliminar;

  @override
  Widget build(BuildContext context) {
    final elegible = deduccion.formaPago != FormaPagoPersonal.efectivo || deduccion.esFunerario;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deduccion.concepto,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.sans(fontSize: 13.5, fontWeight: FontWeight.w600),
                ),
                Text(
                  elegible ? 'Deducible' : 'No deducible · pagado en efectivo',
                  style: AppTypography.helper.copyWith(
                    fontWeight: FontWeight.w600,
                    color: elegible ? AppColors.accentPrimaryText : AppColors.errorNotDeductible,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(formatMoney(deduccion.monto), style: AppTypography.amountMedium),
          IconButton(
            onPressed: onEliminar,
            icon: const Icon(Icons.close, size: 16),
            color: AppColors.textSecondaryMin,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
        ],
      ),
    );
  }
}

class _SimuladorCierreCard extends StatelessWidget {
  const _SimuladorCierreCard({required this.datos});

  final AnualDatos datos;

  @override
  Widget build(BuildContext context) {
    final saldoACargo = datos.saldoAnual > 0;
    final saldoLabel = saldoACargo ? 'Saldo a cargo estimado' : 'Saldo a favor estimado';
    final saldoColor = saldoACargo ? AppColors.accentSecondaryText : AppColors.accentPrimaryText;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Text(
            'Simulador de cierre del ejercicio',
            style: AppTypography.bodyStrong.copyWith(fontSize: 13.5),
          ),
          _SimuladorRow(label: 'Base gravable anual', valor: datos.baseGravableAnual),
          _SimuladorRow(label: 'ISR causado del año (estimado)', valor: datos.isrCausadoAnual),
          _SimuladorRow(
            label: 'Pagos provisionales ya hechos',
            valor: datos.pagosProvisionalesRealizados,
          ),
          const Divider(height: 1, color: Color(0x14FFFFFF)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(saldoLabel, style: AppTypography.sans(fontSize: 13.5, fontWeight: FontWeight.w700)),
                  Text(
                    'Estimado al cierre del ejercicio',
                    style: AppTypography.helper.copyWith(color: AppColors.textSecondaryMin),
                  ),
                ],
              ),
              Text(
                formatMoney(datos.saldoAnual.abs()),
                style: AppTypography.mono(fontSize: 20, fontWeight: FontWeight.w700, color: saldoColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SimuladorRow extends StatelessWidget {
  const _SimuladorRow({required this.label, required this.valor});

  final String label;
  final double valor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.sans(fontSize: 12.5, color: AppColors.textSecondaryMax)),
        Text(formatMoney(valor), style: AppTypography.mono(fontSize: 14, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
