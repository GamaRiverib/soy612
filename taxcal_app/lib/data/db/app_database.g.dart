// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ContribuyentesTable extends Contribuyentes
    with TableInfo<$ContribuyentesTable, Contribuyente> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContribuyentesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _rfcMeta = const VerificationMeta('rfc');
  @override
  late final GeneratedColumn<String> rfc = GeneratedColumn<String>(
    'rfc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _razonSocialMeta = const VerificationMeta(
    'razonSocial',
  );
  @override
  late final GeneratedColumn<String> razonSocial = GeneratedColumn<String>(
    'razon_social',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TipoPersona, int> tipoPersona =
      GeneratedColumn<int>(
        'tipo_persona',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<TipoPersona>($ContribuyentesTable.$convertertipoPersona);
  static const VerificationMeta _creadoEnMeta = const VerificationMeta(
    'creadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> creadoEn = GeneratedColumn<DateTime>(
    'creado_en',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    rfc,
    razonSocial,
    tipoPersona,
    creadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contribuyentes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Contribuyente> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('rfc')) {
      context.handle(
        _rfcMeta,
        rfc.isAcceptableOrUnknown(data['rfc']!, _rfcMeta),
      );
    } else if (isInserting) {
      context.missing(_rfcMeta);
    }
    if (data.containsKey('razon_social')) {
      context.handle(
        _razonSocialMeta,
        razonSocial.isAcceptableOrUnknown(
          data['razon_social']!,
          _razonSocialMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_razonSocialMeta);
    }
    if (data.containsKey('creado_en')) {
      context.handle(
        _creadoEnMeta,
        creadoEn.isAcceptableOrUnknown(data['creado_en']!, _creadoEnMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {rfc};
  @override
  Contribuyente map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Contribuyente(
      rfc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rfc'],
      )!,
      razonSocial: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}razon_social'],
      )!,
      tipoPersona: $ContribuyentesTable.$convertertipoPersona.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}tipo_persona'],
        )!,
      ),
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creado_en'],
      )!,
    );
  }

  @override
  $ContribuyentesTable createAlias(String alias) {
    return $ContribuyentesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TipoPersona, int, int> $convertertipoPersona =
      const EnumIndexConverter<TipoPersona>(TipoPersona.values);
}

class Contribuyente extends DataClass implements Insertable<Contribuyente> {
  final String rfc;
  final String razonSocial;
  final TipoPersona tipoPersona;
  final DateTime creadoEn;
  const Contribuyente({
    required this.rfc,
    required this.razonSocial,
    required this.tipoPersona,
    required this.creadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['rfc'] = Variable<String>(rfc);
    map['razon_social'] = Variable<String>(razonSocial);
    {
      map['tipo_persona'] = Variable<int>(
        $ContribuyentesTable.$convertertipoPersona.toSql(tipoPersona),
      );
    }
    map['creado_en'] = Variable<DateTime>(creadoEn);
    return map;
  }

  ContribuyentesCompanion toCompanion(bool nullToAbsent) {
    return ContribuyentesCompanion(
      rfc: Value(rfc),
      razonSocial: Value(razonSocial),
      tipoPersona: Value(tipoPersona),
      creadoEn: Value(creadoEn),
    );
  }

  factory Contribuyente.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Contribuyente(
      rfc: serializer.fromJson<String>(json['rfc']),
      razonSocial: serializer.fromJson<String>(json['razonSocial']),
      tipoPersona: $ContribuyentesTable.$convertertipoPersona.fromJson(
        serializer.fromJson<int>(json['tipoPersona']),
      ),
      creadoEn: serializer.fromJson<DateTime>(json['creadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'rfc': serializer.toJson<String>(rfc),
      'razonSocial': serializer.toJson<String>(razonSocial),
      'tipoPersona': serializer.toJson<int>(
        $ContribuyentesTable.$convertertipoPersona.toJson(tipoPersona),
      ),
      'creadoEn': serializer.toJson<DateTime>(creadoEn),
    };
  }

  Contribuyente copyWith({
    String? rfc,
    String? razonSocial,
    TipoPersona? tipoPersona,
    DateTime? creadoEn,
  }) => Contribuyente(
    rfc: rfc ?? this.rfc,
    razonSocial: razonSocial ?? this.razonSocial,
    tipoPersona: tipoPersona ?? this.tipoPersona,
    creadoEn: creadoEn ?? this.creadoEn,
  );
  Contribuyente copyWithCompanion(ContribuyentesCompanion data) {
    return Contribuyente(
      rfc: data.rfc.present ? data.rfc.value : this.rfc,
      razonSocial: data.razonSocial.present
          ? data.razonSocial.value
          : this.razonSocial,
      tipoPersona: data.tipoPersona.present
          ? data.tipoPersona.value
          : this.tipoPersona,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Contribuyente(')
          ..write('rfc: $rfc, ')
          ..write('razonSocial: $razonSocial, ')
          ..write('tipoPersona: $tipoPersona, ')
          ..write('creadoEn: $creadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(rfc, razonSocial, tipoPersona, creadoEn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Contribuyente &&
          other.rfc == this.rfc &&
          other.razonSocial == this.razonSocial &&
          other.tipoPersona == this.tipoPersona &&
          other.creadoEn == this.creadoEn);
}

class ContribuyentesCompanion extends UpdateCompanion<Contribuyente> {
  final Value<String> rfc;
  final Value<String> razonSocial;
  final Value<TipoPersona> tipoPersona;
  final Value<DateTime> creadoEn;
  final Value<int> rowid;
  const ContribuyentesCompanion({
    this.rfc = const Value.absent(),
    this.razonSocial = const Value.absent(),
    this.tipoPersona = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContribuyentesCompanion.insert({
    required String rfc,
    required String razonSocial,
    required TipoPersona tipoPersona,
    this.creadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : rfc = Value(rfc),
       razonSocial = Value(razonSocial),
       tipoPersona = Value(tipoPersona);
  static Insertable<Contribuyente> custom({
    Expression<String>? rfc,
    Expression<String>? razonSocial,
    Expression<int>? tipoPersona,
    Expression<DateTime>? creadoEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (rfc != null) 'rfc': rfc,
      if (razonSocial != null) 'razon_social': razonSocial,
      if (tipoPersona != null) 'tipo_persona': tipoPersona,
      if (creadoEn != null) 'creado_en': creadoEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContribuyentesCompanion copyWith({
    Value<String>? rfc,
    Value<String>? razonSocial,
    Value<TipoPersona>? tipoPersona,
    Value<DateTime>? creadoEn,
    Value<int>? rowid,
  }) {
    return ContribuyentesCompanion(
      rfc: rfc ?? this.rfc,
      razonSocial: razonSocial ?? this.razonSocial,
      tipoPersona: tipoPersona ?? this.tipoPersona,
      creadoEn: creadoEn ?? this.creadoEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rfc.present) {
      map['rfc'] = Variable<String>(rfc.value);
    }
    if (razonSocial.present) {
      map['razon_social'] = Variable<String>(razonSocial.value);
    }
    if (tipoPersona.present) {
      map['tipo_persona'] = Variable<int>(
        $ContribuyentesTable.$convertertipoPersona.toSql(tipoPersona.value),
      );
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<DateTime>(creadoEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContribuyentesCompanion(')
          ..write('rfc: $rfc, ')
          ..write('razonSocial: $razonSocial, ')
          ..write('tipoPersona: $tipoPersona, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FacturasTable extends Facturas with TableInfo<$FacturasTable, Factura> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FacturasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _folioInternoMeta = const VerificationMeta(
    'folioInterno',
  );
  @override
  late final GeneratedColumn<String> folioInterno = GeneratedColumn<String>(
    'folio_interno',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fechaEmisionMeta = const VerificationMeta(
    'fechaEmision',
  );
  @override
  late final GeneratedColumn<DateTime> fechaEmision = GeneratedColumn<DateTime>(
    'fecha_emision',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaPagoEfectivoMeta = const VerificationMeta(
    'fechaPagoEfectivo',
  );
  @override
  late final GeneratedColumn<DateTime> fechaPagoEfectivo =
      GeneratedColumn<DateTime>(
        'fecha_pago_efectivo',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _rfcEmisorMeta = const VerificationMeta(
    'rfcEmisor',
  );
  @override
  late final GeneratedColumn<String> rfcEmisor = GeneratedColumn<String>(
    'rfc_emisor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES contribuyentes (rfc)',
    ),
  );
  static const VerificationMeta _rfcReceptorMeta = const VerificationMeta(
    'rfcReceptor',
  );
  @override
  late final GeneratedColumn<String> rfcReceptor = GeneratedColumn<String>(
    'rfc_receptor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES contribuyentes (rfc)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<TipoCfdi, int> tipoCfdi =
      GeneratedColumn<int>(
        'tipo_cfdi',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<TipoCfdi>($FacturasTable.$convertertipoCfdi);
  static const VerificationMeta _subtotalMeta = const VerificationMeta(
    'subtotal',
  );
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
    'subtotal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tasaIvaMeta = const VerificationMeta(
    'tasaIva',
  );
  @override
  late final GeneratedColumn<double> tasaIva = GeneratedColumn<double>(
    'tasa_iva',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(16.0),
  );
  static const VerificationMeta _ivaTrasladadoMeta = const VerificationMeta(
    'ivaTrasladado',
  );
  @override
  late final GeneratedColumn<double> ivaTrasladado = GeneratedColumn<double>(
    'iva_trasladado',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _ivaRetenidoMeta = const VerificationMeta(
    'ivaRetenido',
  );
  @override
  late final GeneratedColumn<double> ivaRetenido = GeneratedColumn<double>(
    'iva_retenido',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _isrRetenidoMeta = const VerificationMeta(
    'isrRetenido',
  );
  @override
  late final GeneratedColumn<double> isrRetenido = GeneratedColumn<double>(
    'isr_retenido',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<MetodoPagoCfdi, int> metodoPago =
      GeneratedColumn<int>(
        'metodo_pago',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<MetodoPagoCfdi>($FacturasTable.$convertermetodoPago);
  static const VerificationMeta _formaPagoMeta = const VerificationMeta(
    'formaPago',
  );
  @override
  late final GeneratedColumn<String> formaPago = GeneratedColumn<String>(
    'forma_pago',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _esDeducibleMeta = const VerificationMeta(
    'esDeducible',
  );
  @override
  late final GeneratedColumn<bool> esDeducible = GeneratedColumn<bool>(
    'es_deducible',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("es_deducible" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  late final GeneratedColumnWithTypeConverter<EstatusPago, int> estatusPago =
      GeneratedColumn<int>(
        'estatus_pago',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<EstatusPago>($FacturasTable.$converterestatusPago);
  @override
  List<GeneratedColumn> get $columns => [
    uuid,
    folioInterno,
    fechaEmision,
    fechaPagoEfectivo,
    rfcEmisor,
    rfcReceptor,
    tipoCfdi,
    subtotal,
    tasaIva,
    ivaTrasladado,
    ivaRetenido,
    isrRetenido,
    total,
    metodoPago,
    formaPago,
    esDeducible,
    estatusPago,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'facturas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Factura> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('folio_interno')) {
      context.handle(
        _folioInternoMeta,
        folioInterno.isAcceptableOrUnknown(
          data['folio_interno']!,
          _folioInternoMeta,
        ),
      );
    }
    if (data.containsKey('fecha_emision')) {
      context.handle(
        _fechaEmisionMeta,
        fechaEmision.isAcceptableOrUnknown(
          data['fecha_emision']!,
          _fechaEmisionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fechaEmisionMeta);
    }
    if (data.containsKey('fecha_pago_efectivo')) {
      context.handle(
        _fechaPagoEfectivoMeta,
        fechaPagoEfectivo.isAcceptableOrUnknown(
          data['fecha_pago_efectivo']!,
          _fechaPagoEfectivoMeta,
        ),
      );
    }
    if (data.containsKey('rfc_emisor')) {
      context.handle(
        _rfcEmisorMeta,
        rfcEmisor.isAcceptableOrUnknown(data['rfc_emisor']!, _rfcEmisorMeta),
      );
    } else if (isInserting) {
      context.missing(_rfcEmisorMeta);
    }
    if (data.containsKey('rfc_receptor')) {
      context.handle(
        _rfcReceptorMeta,
        rfcReceptor.isAcceptableOrUnknown(
          data['rfc_receptor']!,
          _rfcReceptorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rfcReceptorMeta);
    }
    if (data.containsKey('subtotal')) {
      context.handle(
        _subtotalMeta,
        subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta),
      );
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    if (data.containsKey('tasa_iva')) {
      context.handle(
        _tasaIvaMeta,
        tasaIva.isAcceptableOrUnknown(data['tasa_iva']!, _tasaIvaMeta),
      );
    }
    if (data.containsKey('iva_trasladado')) {
      context.handle(
        _ivaTrasladadoMeta,
        ivaTrasladado.isAcceptableOrUnknown(
          data['iva_trasladado']!,
          _ivaTrasladadoMeta,
        ),
      );
    }
    if (data.containsKey('iva_retenido')) {
      context.handle(
        _ivaRetenidoMeta,
        ivaRetenido.isAcceptableOrUnknown(
          data['iva_retenido']!,
          _ivaRetenidoMeta,
        ),
      );
    }
    if (data.containsKey('isr_retenido')) {
      context.handle(
        _isrRetenidoMeta,
        isrRetenido.isAcceptableOrUnknown(
          data['isr_retenido']!,
          _isrRetenidoMeta,
        ),
      );
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('forma_pago')) {
      context.handle(
        _formaPagoMeta,
        formaPago.isAcceptableOrUnknown(data['forma_pago']!, _formaPagoMeta),
      );
    } else if (isInserting) {
      context.missing(_formaPagoMeta);
    }
    if (data.containsKey('es_deducible')) {
      context.handle(
        _esDeducibleMeta,
        esDeducible.isAcceptableOrUnknown(
          data['es_deducible']!,
          _esDeducibleMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  Factura map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Factura(
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      folioInterno: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folio_interno'],
      ),
      fechaEmision: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_emision'],
      )!,
      fechaPagoEfectivo: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_pago_efectivo'],
      ),
      rfcEmisor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rfc_emisor'],
      )!,
      rfcReceptor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rfc_receptor'],
      )!,
      tipoCfdi: $FacturasTable.$convertertipoCfdi.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}tipo_cfdi'],
        )!,
      ),
      subtotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}subtotal'],
      )!,
      tasaIva: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tasa_iva'],
      )!,
      ivaTrasladado: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}iva_trasladado'],
      )!,
      ivaRetenido: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}iva_retenido'],
      )!,
      isrRetenido: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}isr_retenido'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total'],
      )!,
      metodoPago: $FacturasTable.$convertermetodoPago.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}metodo_pago'],
        )!,
      ),
      formaPago: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}forma_pago'],
      )!,
      esDeducible: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}es_deducible'],
      )!,
      estatusPago: $FacturasTable.$converterestatusPago.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}estatus_pago'],
        )!,
      ),
    );
  }

  @override
  $FacturasTable createAlias(String alias) {
    return $FacturasTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TipoCfdi, int, int> $convertertipoCfdi =
      const EnumIndexConverter<TipoCfdi>(TipoCfdi.values);
  static JsonTypeConverter2<MetodoPagoCfdi, int, int> $convertermetodoPago =
      const EnumIndexConverter<MetodoPagoCfdi>(MetodoPagoCfdi.values);
  static JsonTypeConverter2<EstatusPago, int, int> $converterestatusPago =
      const EnumIndexConverter<EstatusPago>(EstatusPago.values);
}

class Factura extends DataClass implements Insertable<Factura> {
  final String uuid;
  final String? folioInterno;
  final DateTime fechaEmision;
  final DateTime? fechaPagoEfectivo;
  final String rfcEmisor;
  final String rfcReceptor;
  final TipoCfdi tipoCfdi;
  final double subtotal;
  final double tasaIva;
  final double ivaTrasladado;
  final double ivaRetenido;
  final double isrRetenido;
  final double total;
  final MetodoPagoCfdi metodoPago;
  final String formaPago;
  final bool esDeducible;
  final EstatusPago estatusPago;
  const Factura({
    required this.uuid,
    this.folioInterno,
    required this.fechaEmision,
    this.fechaPagoEfectivo,
    required this.rfcEmisor,
    required this.rfcReceptor,
    required this.tipoCfdi,
    required this.subtotal,
    required this.tasaIva,
    required this.ivaTrasladado,
    required this.ivaRetenido,
    required this.isrRetenido,
    required this.total,
    required this.metodoPago,
    required this.formaPago,
    required this.esDeducible,
    required this.estatusPago,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    if (!nullToAbsent || folioInterno != null) {
      map['folio_interno'] = Variable<String>(folioInterno);
    }
    map['fecha_emision'] = Variable<DateTime>(fechaEmision);
    if (!nullToAbsent || fechaPagoEfectivo != null) {
      map['fecha_pago_efectivo'] = Variable<DateTime>(fechaPagoEfectivo);
    }
    map['rfc_emisor'] = Variable<String>(rfcEmisor);
    map['rfc_receptor'] = Variable<String>(rfcReceptor);
    {
      map['tipo_cfdi'] = Variable<int>(
        $FacturasTable.$convertertipoCfdi.toSql(tipoCfdi),
      );
    }
    map['subtotal'] = Variable<double>(subtotal);
    map['tasa_iva'] = Variable<double>(tasaIva);
    map['iva_trasladado'] = Variable<double>(ivaTrasladado);
    map['iva_retenido'] = Variable<double>(ivaRetenido);
    map['isr_retenido'] = Variable<double>(isrRetenido);
    map['total'] = Variable<double>(total);
    {
      map['metodo_pago'] = Variable<int>(
        $FacturasTable.$convertermetodoPago.toSql(metodoPago),
      );
    }
    map['forma_pago'] = Variable<String>(formaPago);
    map['es_deducible'] = Variable<bool>(esDeducible);
    {
      map['estatus_pago'] = Variable<int>(
        $FacturasTable.$converterestatusPago.toSql(estatusPago),
      );
    }
    return map;
  }

  FacturasCompanion toCompanion(bool nullToAbsent) {
    return FacturasCompanion(
      uuid: Value(uuid),
      folioInterno: folioInterno == null && nullToAbsent
          ? const Value.absent()
          : Value(folioInterno),
      fechaEmision: Value(fechaEmision),
      fechaPagoEfectivo: fechaPagoEfectivo == null && nullToAbsent
          ? const Value.absent()
          : Value(fechaPagoEfectivo),
      rfcEmisor: Value(rfcEmisor),
      rfcReceptor: Value(rfcReceptor),
      tipoCfdi: Value(tipoCfdi),
      subtotal: Value(subtotal),
      tasaIva: Value(tasaIva),
      ivaTrasladado: Value(ivaTrasladado),
      ivaRetenido: Value(ivaRetenido),
      isrRetenido: Value(isrRetenido),
      total: Value(total),
      metodoPago: Value(metodoPago),
      formaPago: Value(formaPago),
      esDeducible: Value(esDeducible),
      estatusPago: Value(estatusPago),
    );
  }

  factory Factura.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Factura(
      uuid: serializer.fromJson<String>(json['uuid']),
      folioInterno: serializer.fromJson<String?>(json['folioInterno']),
      fechaEmision: serializer.fromJson<DateTime>(json['fechaEmision']),
      fechaPagoEfectivo: serializer.fromJson<DateTime?>(
        json['fechaPagoEfectivo'],
      ),
      rfcEmisor: serializer.fromJson<String>(json['rfcEmisor']),
      rfcReceptor: serializer.fromJson<String>(json['rfcReceptor']),
      tipoCfdi: $FacturasTable.$convertertipoCfdi.fromJson(
        serializer.fromJson<int>(json['tipoCfdi']),
      ),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      tasaIva: serializer.fromJson<double>(json['tasaIva']),
      ivaTrasladado: serializer.fromJson<double>(json['ivaTrasladado']),
      ivaRetenido: serializer.fromJson<double>(json['ivaRetenido']),
      isrRetenido: serializer.fromJson<double>(json['isrRetenido']),
      total: serializer.fromJson<double>(json['total']),
      metodoPago: $FacturasTable.$convertermetodoPago.fromJson(
        serializer.fromJson<int>(json['metodoPago']),
      ),
      formaPago: serializer.fromJson<String>(json['formaPago']),
      esDeducible: serializer.fromJson<bool>(json['esDeducible']),
      estatusPago: $FacturasTable.$converterestatusPago.fromJson(
        serializer.fromJson<int>(json['estatusPago']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'folioInterno': serializer.toJson<String?>(folioInterno),
      'fechaEmision': serializer.toJson<DateTime>(fechaEmision),
      'fechaPagoEfectivo': serializer.toJson<DateTime?>(fechaPagoEfectivo),
      'rfcEmisor': serializer.toJson<String>(rfcEmisor),
      'rfcReceptor': serializer.toJson<String>(rfcReceptor),
      'tipoCfdi': serializer.toJson<int>(
        $FacturasTable.$convertertipoCfdi.toJson(tipoCfdi),
      ),
      'subtotal': serializer.toJson<double>(subtotal),
      'tasaIva': serializer.toJson<double>(tasaIva),
      'ivaTrasladado': serializer.toJson<double>(ivaTrasladado),
      'ivaRetenido': serializer.toJson<double>(ivaRetenido),
      'isrRetenido': serializer.toJson<double>(isrRetenido),
      'total': serializer.toJson<double>(total),
      'metodoPago': serializer.toJson<int>(
        $FacturasTable.$convertermetodoPago.toJson(metodoPago),
      ),
      'formaPago': serializer.toJson<String>(formaPago),
      'esDeducible': serializer.toJson<bool>(esDeducible),
      'estatusPago': serializer.toJson<int>(
        $FacturasTable.$converterestatusPago.toJson(estatusPago),
      ),
    };
  }

  Factura copyWith({
    String? uuid,
    Value<String?> folioInterno = const Value.absent(),
    DateTime? fechaEmision,
    Value<DateTime?> fechaPagoEfectivo = const Value.absent(),
    String? rfcEmisor,
    String? rfcReceptor,
    TipoCfdi? tipoCfdi,
    double? subtotal,
    double? tasaIva,
    double? ivaTrasladado,
    double? ivaRetenido,
    double? isrRetenido,
    double? total,
    MetodoPagoCfdi? metodoPago,
    String? formaPago,
    bool? esDeducible,
    EstatusPago? estatusPago,
  }) => Factura(
    uuid: uuid ?? this.uuid,
    folioInterno: folioInterno.present ? folioInterno.value : this.folioInterno,
    fechaEmision: fechaEmision ?? this.fechaEmision,
    fechaPagoEfectivo: fechaPagoEfectivo.present
        ? fechaPagoEfectivo.value
        : this.fechaPagoEfectivo,
    rfcEmisor: rfcEmisor ?? this.rfcEmisor,
    rfcReceptor: rfcReceptor ?? this.rfcReceptor,
    tipoCfdi: tipoCfdi ?? this.tipoCfdi,
    subtotal: subtotal ?? this.subtotal,
    tasaIva: tasaIva ?? this.tasaIva,
    ivaTrasladado: ivaTrasladado ?? this.ivaTrasladado,
    ivaRetenido: ivaRetenido ?? this.ivaRetenido,
    isrRetenido: isrRetenido ?? this.isrRetenido,
    total: total ?? this.total,
    metodoPago: metodoPago ?? this.metodoPago,
    formaPago: formaPago ?? this.formaPago,
    esDeducible: esDeducible ?? this.esDeducible,
    estatusPago: estatusPago ?? this.estatusPago,
  );
  Factura copyWithCompanion(FacturasCompanion data) {
    return Factura(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      folioInterno: data.folioInterno.present
          ? data.folioInterno.value
          : this.folioInterno,
      fechaEmision: data.fechaEmision.present
          ? data.fechaEmision.value
          : this.fechaEmision,
      fechaPagoEfectivo: data.fechaPagoEfectivo.present
          ? data.fechaPagoEfectivo.value
          : this.fechaPagoEfectivo,
      rfcEmisor: data.rfcEmisor.present ? data.rfcEmisor.value : this.rfcEmisor,
      rfcReceptor: data.rfcReceptor.present
          ? data.rfcReceptor.value
          : this.rfcReceptor,
      tipoCfdi: data.tipoCfdi.present ? data.tipoCfdi.value : this.tipoCfdi,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      tasaIva: data.tasaIva.present ? data.tasaIva.value : this.tasaIva,
      ivaTrasladado: data.ivaTrasladado.present
          ? data.ivaTrasladado.value
          : this.ivaTrasladado,
      ivaRetenido: data.ivaRetenido.present
          ? data.ivaRetenido.value
          : this.ivaRetenido,
      isrRetenido: data.isrRetenido.present
          ? data.isrRetenido.value
          : this.isrRetenido,
      total: data.total.present ? data.total.value : this.total,
      metodoPago: data.metodoPago.present
          ? data.metodoPago.value
          : this.metodoPago,
      formaPago: data.formaPago.present ? data.formaPago.value : this.formaPago,
      esDeducible: data.esDeducible.present
          ? data.esDeducible.value
          : this.esDeducible,
      estatusPago: data.estatusPago.present
          ? data.estatusPago.value
          : this.estatusPago,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Factura(')
          ..write('uuid: $uuid, ')
          ..write('folioInterno: $folioInterno, ')
          ..write('fechaEmision: $fechaEmision, ')
          ..write('fechaPagoEfectivo: $fechaPagoEfectivo, ')
          ..write('rfcEmisor: $rfcEmisor, ')
          ..write('rfcReceptor: $rfcReceptor, ')
          ..write('tipoCfdi: $tipoCfdi, ')
          ..write('subtotal: $subtotal, ')
          ..write('tasaIva: $tasaIva, ')
          ..write('ivaTrasladado: $ivaTrasladado, ')
          ..write('ivaRetenido: $ivaRetenido, ')
          ..write('isrRetenido: $isrRetenido, ')
          ..write('total: $total, ')
          ..write('metodoPago: $metodoPago, ')
          ..write('formaPago: $formaPago, ')
          ..write('esDeducible: $esDeducible, ')
          ..write('estatusPago: $estatusPago')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    uuid,
    folioInterno,
    fechaEmision,
    fechaPagoEfectivo,
    rfcEmisor,
    rfcReceptor,
    tipoCfdi,
    subtotal,
    tasaIva,
    ivaTrasladado,
    ivaRetenido,
    isrRetenido,
    total,
    metodoPago,
    formaPago,
    esDeducible,
    estatusPago,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Factura &&
          other.uuid == this.uuid &&
          other.folioInterno == this.folioInterno &&
          other.fechaEmision == this.fechaEmision &&
          other.fechaPagoEfectivo == this.fechaPagoEfectivo &&
          other.rfcEmisor == this.rfcEmisor &&
          other.rfcReceptor == this.rfcReceptor &&
          other.tipoCfdi == this.tipoCfdi &&
          other.subtotal == this.subtotal &&
          other.tasaIva == this.tasaIva &&
          other.ivaTrasladado == this.ivaTrasladado &&
          other.ivaRetenido == this.ivaRetenido &&
          other.isrRetenido == this.isrRetenido &&
          other.total == this.total &&
          other.metodoPago == this.metodoPago &&
          other.formaPago == this.formaPago &&
          other.esDeducible == this.esDeducible &&
          other.estatusPago == this.estatusPago);
}

class FacturasCompanion extends UpdateCompanion<Factura> {
  final Value<String> uuid;
  final Value<String?> folioInterno;
  final Value<DateTime> fechaEmision;
  final Value<DateTime?> fechaPagoEfectivo;
  final Value<String> rfcEmisor;
  final Value<String> rfcReceptor;
  final Value<TipoCfdi> tipoCfdi;
  final Value<double> subtotal;
  final Value<double> tasaIva;
  final Value<double> ivaTrasladado;
  final Value<double> ivaRetenido;
  final Value<double> isrRetenido;
  final Value<double> total;
  final Value<MetodoPagoCfdi> metodoPago;
  final Value<String> formaPago;
  final Value<bool> esDeducible;
  final Value<EstatusPago> estatusPago;
  final Value<int> rowid;
  const FacturasCompanion({
    this.uuid = const Value.absent(),
    this.folioInterno = const Value.absent(),
    this.fechaEmision = const Value.absent(),
    this.fechaPagoEfectivo = const Value.absent(),
    this.rfcEmisor = const Value.absent(),
    this.rfcReceptor = const Value.absent(),
    this.tipoCfdi = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.tasaIva = const Value.absent(),
    this.ivaTrasladado = const Value.absent(),
    this.ivaRetenido = const Value.absent(),
    this.isrRetenido = const Value.absent(),
    this.total = const Value.absent(),
    this.metodoPago = const Value.absent(),
    this.formaPago = const Value.absent(),
    this.esDeducible = const Value.absent(),
    this.estatusPago = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FacturasCompanion.insert({
    required String uuid,
    this.folioInterno = const Value.absent(),
    required DateTime fechaEmision,
    this.fechaPagoEfectivo = const Value.absent(),
    required String rfcEmisor,
    required String rfcReceptor,
    required TipoCfdi tipoCfdi,
    required double subtotal,
    this.tasaIva = const Value.absent(),
    this.ivaTrasladado = const Value.absent(),
    this.ivaRetenido = const Value.absent(),
    this.isrRetenido = const Value.absent(),
    required double total,
    required MetodoPagoCfdi metodoPago,
    required String formaPago,
    this.esDeducible = const Value.absent(),
    required EstatusPago estatusPago,
    this.rowid = const Value.absent(),
  }) : uuid = Value(uuid),
       fechaEmision = Value(fechaEmision),
       rfcEmisor = Value(rfcEmisor),
       rfcReceptor = Value(rfcReceptor),
       tipoCfdi = Value(tipoCfdi),
       subtotal = Value(subtotal),
       total = Value(total),
       metodoPago = Value(metodoPago),
       formaPago = Value(formaPago),
       estatusPago = Value(estatusPago);
  static Insertable<Factura> custom({
    Expression<String>? uuid,
    Expression<String>? folioInterno,
    Expression<DateTime>? fechaEmision,
    Expression<DateTime>? fechaPagoEfectivo,
    Expression<String>? rfcEmisor,
    Expression<String>? rfcReceptor,
    Expression<int>? tipoCfdi,
    Expression<double>? subtotal,
    Expression<double>? tasaIva,
    Expression<double>? ivaTrasladado,
    Expression<double>? ivaRetenido,
    Expression<double>? isrRetenido,
    Expression<double>? total,
    Expression<int>? metodoPago,
    Expression<String>? formaPago,
    Expression<bool>? esDeducible,
    Expression<int>? estatusPago,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (folioInterno != null) 'folio_interno': folioInterno,
      if (fechaEmision != null) 'fecha_emision': fechaEmision,
      if (fechaPagoEfectivo != null) 'fecha_pago_efectivo': fechaPagoEfectivo,
      if (rfcEmisor != null) 'rfc_emisor': rfcEmisor,
      if (rfcReceptor != null) 'rfc_receptor': rfcReceptor,
      if (tipoCfdi != null) 'tipo_cfdi': tipoCfdi,
      if (subtotal != null) 'subtotal': subtotal,
      if (tasaIva != null) 'tasa_iva': tasaIva,
      if (ivaTrasladado != null) 'iva_trasladado': ivaTrasladado,
      if (ivaRetenido != null) 'iva_retenido': ivaRetenido,
      if (isrRetenido != null) 'isr_retenido': isrRetenido,
      if (total != null) 'total': total,
      if (metodoPago != null) 'metodo_pago': metodoPago,
      if (formaPago != null) 'forma_pago': formaPago,
      if (esDeducible != null) 'es_deducible': esDeducible,
      if (estatusPago != null) 'estatus_pago': estatusPago,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FacturasCompanion copyWith({
    Value<String>? uuid,
    Value<String?>? folioInterno,
    Value<DateTime>? fechaEmision,
    Value<DateTime?>? fechaPagoEfectivo,
    Value<String>? rfcEmisor,
    Value<String>? rfcReceptor,
    Value<TipoCfdi>? tipoCfdi,
    Value<double>? subtotal,
    Value<double>? tasaIva,
    Value<double>? ivaTrasladado,
    Value<double>? ivaRetenido,
    Value<double>? isrRetenido,
    Value<double>? total,
    Value<MetodoPagoCfdi>? metodoPago,
    Value<String>? formaPago,
    Value<bool>? esDeducible,
    Value<EstatusPago>? estatusPago,
    Value<int>? rowid,
  }) {
    return FacturasCompanion(
      uuid: uuid ?? this.uuid,
      folioInterno: folioInterno ?? this.folioInterno,
      fechaEmision: fechaEmision ?? this.fechaEmision,
      fechaPagoEfectivo: fechaPagoEfectivo ?? this.fechaPagoEfectivo,
      rfcEmisor: rfcEmisor ?? this.rfcEmisor,
      rfcReceptor: rfcReceptor ?? this.rfcReceptor,
      tipoCfdi: tipoCfdi ?? this.tipoCfdi,
      subtotal: subtotal ?? this.subtotal,
      tasaIva: tasaIva ?? this.tasaIva,
      ivaTrasladado: ivaTrasladado ?? this.ivaTrasladado,
      ivaRetenido: ivaRetenido ?? this.ivaRetenido,
      isrRetenido: isrRetenido ?? this.isrRetenido,
      total: total ?? this.total,
      metodoPago: metodoPago ?? this.metodoPago,
      formaPago: formaPago ?? this.formaPago,
      esDeducible: esDeducible ?? this.esDeducible,
      estatusPago: estatusPago ?? this.estatusPago,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (folioInterno.present) {
      map['folio_interno'] = Variable<String>(folioInterno.value);
    }
    if (fechaEmision.present) {
      map['fecha_emision'] = Variable<DateTime>(fechaEmision.value);
    }
    if (fechaPagoEfectivo.present) {
      map['fecha_pago_efectivo'] = Variable<DateTime>(fechaPagoEfectivo.value);
    }
    if (rfcEmisor.present) {
      map['rfc_emisor'] = Variable<String>(rfcEmisor.value);
    }
    if (rfcReceptor.present) {
      map['rfc_receptor'] = Variable<String>(rfcReceptor.value);
    }
    if (tipoCfdi.present) {
      map['tipo_cfdi'] = Variable<int>(
        $FacturasTable.$convertertipoCfdi.toSql(tipoCfdi.value),
      );
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (tasaIva.present) {
      map['tasa_iva'] = Variable<double>(tasaIva.value);
    }
    if (ivaTrasladado.present) {
      map['iva_trasladado'] = Variable<double>(ivaTrasladado.value);
    }
    if (ivaRetenido.present) {
      map['iva_retenido'] = Variable<double>(ivaRetenido.value);
    }
    if (isrRetenido.present) {
      map['isr_retenido'] = Variable<double>(isrRetenido.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (metodoPago.present) {
      map['metodo_pago'] = Variable<int>(
        $FacturasTable.$convertermetodoPago.toSql(metodoPago.value),
      );
    }
    if (formaPago.present) {
      map['forma_pago'] = Variable<String>(formaPago.value);
    }
    if (esDeducible.present) {
      map['es_deducible'] = Variable<bool>(esDeducible.value);
    }
    if (estatusPago.present) {
      map['estatus_pago'] = Variable<int>(
        $FacturasTable.$converterestatusPago.toSql(estatusPago.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FacturasCompanion(')
          ..write('uuid: $uuid, ')
          ..write('folioInterno: $folioInterno, ')
          ..write('fechaEmision: $fechaEmision, ')
          ..write('fechaPagoEfectivo: $fechaPagoEfectivo, ')
          ..write('rfcEmisor: $rfcEmisor, ')
          ..write('rfcReceptor: $rfcReceptor, ')
          ..write('tipoCfdi: $tipoCfdi, ')
          ..write('subtotal: $subtotal, ')
          ..write('tasaIva: $tasaIva, ')
          ..write('ivaTrasladado: $ivaTrasladado, ')
          ..write('ivaRetenido: $ivaRetenido, ')
          ..write('isrRetenido: $isrRetenido, ')
          ..write('total: $total, ')
          ..write('metodoPago: $metodoPago, ')
          ..write('formaPago: $formaPago, ')
          ..write('esDeducible: $esDeducible, ')
          ..write('estatusPago: $estatusPago, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InversionesTable extends Inversiones
    with TableInfo<$InversionesTable, Inversione> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InversionesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _uuidFacturaMeta = const VerificationMeta(
    'uuidFactura',
  );
  @override
  late final GeneratedColumn<String> uuidFactura = GeneratedColumn<String>(
    'uuid_factura',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES facturas (uuid)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<TipoActivo, int> tipoActivo =
      GeneratedColumn<int>(
        'tipo_activo',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<TipoActivo>($InversionesTable.$convertertipoActivo);
  static const VerificationMeta _montoOriginalMeta = const VerificationMeta(
    'montoOriginal',
  );
  @override
  late final GeneratedColumn<double> montoOriginal = GeneratedColumn<double>(
    'monto_original',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pctDepreciacionMeta = const VerificationMeta(
    'pctDepreciacion',
  );
  @override
  late final GeneratedColumn<double> pctDepreciacion = GeneratedColumn<double>(
    'pct_depreciacion',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaAdquisicionMeta = const VerificationMeta(
    'fechaAdquisicion',
  );
  @override
  late final GeneratedColumn<DateTime> fechaAdquisicion =
      GeneratedColumn<DateTime>(
        'fecha_adquisicion',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uuidFactura,
    tipoActivo,
    montoOriginal,
    pctDepreciacion,
    fechaAdquisicion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inversiones';
  @override
  VerificationContext validateIntegrity(
    Insertable<Inversione> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid_factura')) {
      context.handle(
        _uuidFacturaMeta,
        uuidFactura.isAcceptableOrUnknown(
          data['uuid_factura']!,
          _uuidFacturaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_uuidFacturaMeta);
    }
    if (data.containsKey('monto_original')) {
      context.handle(
        _montoOriginalMeta,
        montoOriginal.isAcceptableOrUnknown(
          data['monto_original']!,
          _montoOriginalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_montoOriginalMeta);
    }
    if (data.containsKey('pct_depreciacion')) {
      context.handle(
        _pctDepreciacionMeta,
        pctDepreciacion.isAcceptableOrUnknown(
          data['pct_depreciacion']!,
          _pctDepreciacionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pctDepreciacionMeta);
    }
    if (data.containsKey('fecha_adquisicion')) {
      context.handle(
        _fechaAdquisicionMeta,
        fechaAdquisicion.isAcceptableOrUnknown(
          data['fecha_adquisicion']!,
          _fechaAdquisicionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fechaAdquisicionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Inversione map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Inversione(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uuidFactura: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid_factura'],
      )!,
      tipoActivo: $InversionesTable.$convertertipoActivo.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}tipo_activo'],
        )!,
      ),
      montoOriginal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monto_original'],
      )!,
      pctDepreciacion: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pct_depreciacion'],
      )!,
      fechaAdquisicion: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_adquisicion'],
      )!,
    );
  }

  @override
  $InversionesTable createAlias(String alias) {
    return $InversionesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TipoActivo, int, int> $convertertipoActivo =
      const EnumIndexConverter<TipoActivo>(TipoActivo.values);
}

class Inversione extends DataClass implements Insertable<Inversione> {
  final int id;
  final String uuidFactura;
  final TipoActivo tipoActivo;
  final double montoOriginal;
  final double pctDepreciacion;
  final DateTime fechaAdquisicion;
  const Inversione({
    required this.id,
    required this.uuidFactura,
    required this.tipoActivo,
    required this.montoOriginal,
    required this.pctDepreciacion,
    required this.fechaAdquisicion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid_factura'] = Variable<String>(uuidFactura);
    {
      map['tipo_activo'] = Variable<int>(
        $InversionesTable.$convertertipoActivo.toSql(tipoActivo),
      );
    }
    map['monto_original'] = Variable<double>(montoOriginal);
    map['pct_depreciacion'] = Variable<double>(pctDepreciacion);
    map['fecha_adquisicion'] = Variable<DateTime>(fechaAdquisicion);
    return map;
  }

  InversionesCompanion toCompanion(bool nullToAbsent) {
    return InversionesCompanion(
      id: Value(id),
      uuidFactura: Value(uuidFactura),
      tipoActivo: Value(tipoActivo),
      montoOriginal: Value(montoOriginal),
      pctDepreciacion: Value(pctDepreciacion),
      fechaAdquisicion: Value(fechaAdquisicion),
    );
  }

  factory Inversione.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Inversione(
      id: serializer.fromJson<int>(json['id']),
      uuidFactura: serializer.fromJson<String>(json['uuidFactura']),
      tipoActivo: $InversionesTable.$convertertipoActivo.fromJson(
        serializer.fromJson<int>(json['tipoActivo']),
      ),
      montoOriginal: serializer.fromJson<double>(json['montoOriginal']),
      pctDepreciacion: serializer.fromJson<double>(json['pctDepreciacion']),
      fechaAdquisicion: serializer.fromJson<DateTime>(json['fechaAdquisicion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuidFactura': serializer.toJson<String>(uuidFactura),
      'tipoActivo': serializer.toJson<int>(
        $InversionesTable.$convertertipoActivo.toJson(tipoActivo),
      ),
      'montoOriginal': serializer.toJson<double>(montoOriginal),
      'pctDepreciacion': serializer.toJson<double>(pctDepreciacion),
      'fechaAdquisicion': serializer.toJson<DateTime>(fechaAdquisicion),
    };
  }

  Inversione copyWith({
    int? id,
    String? uuidFactura,
    TipoActivo? tipoActivo,
    double? montoOriginal,
    double? pctDepreciacion,
    DateTime? fechaAdquisicion,
  }) => Inversione(
    id: id ?? this.id,
    uuidFactura: uuidFactura ?? this.uuidFactura,
    tipoActivo: tipoActivo ?? this.tipoActivo,
    montoOriginal: montoOriginal ?? this.montoOriginal,
    pctDepreciacion: pctDepreciacion ?? this.pctDepreciacion,
    fechaAdquisicion: fechaAdquisicion ?? this.fechaAdquisicion,
  );
  Inversione copyWithCompanion(InversionesCompanion data) {
    return Inversione(
      id: data.id.present ? data.id.value : this.id,
      uuidFactura: data.uuidFactura.present
          ? data.uuidFactura.value
          : this.uuidFactura,
      tipoActivo: data.tipoActivo.present
          ? data.tipoActivo.value
          : this.tipoActivo,
      montoOriginal: data.montoOriginal.present
          ? data.montoOriginal.value
          : this.montoOriginal,
      pctDepreciacion: data.pctDepreciacion.present
          ? data.pctDepreciacion.value
          : this.pctDepreciacion,
      fechaAdquisicion: data.fechaAdquisicion.present
          ? data.fechaAdquisicion.value
          : this.fechaAdquisicion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Inversione(')
          ..write('id: $id, ')
          ..write('uuidFactura: $uuidFactura, ')
          ..write('tipoActivo: $tipoActivo, ')
          ..write('montoOriginal: $montoOriginal, ')
          ..write('pctDepreciacion: $pctDepreciacion, ')
          ..write('fechaAdquisicion: $fechaAdquisicion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    uuidFactura,
    tipoActivo,
    montoOriginal,
    pctDepreciacion,
    fechaAdquisicion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Inversione &&
          other.id == this.id &&
          other.uuidFactura == this.uuidFactura &&
          other.tipoActivo == this.tipoActivo &&
          other.montoOriginal == this.montoOriginal &&
          other.pctDepreciacion == this.pctDepreciacion &&
          other.fechaAdquisicion == this.fechaAdquisicion);
}

class InversionesCompanion extends UpdateCompanion<Inversione> {
  final Value<int> id;
  final Value<String> uuidFactura;
  final Value<TipoActivo> tipoActivo;
  final Value<double> montoOriginal;
  final Value<double> pctDepreciacion;
  final Value<DateTime> fechaAdquisicion;
  const InversionesCompanion({
    this.id = const Value.absent(),
    this.uuidFactura = const Value.absent(),
    this.tipoActivo = const Value.absent(),
    this.montoOriginal = const Value.absent(),
    this.pctDepreciacion = const Value.absent(),
    this.fechaAdquisicion = const Value.absent(),
  });
  InversionesCompanion.insert({
    this.id = const Value.absent(),
    required String uuidFactura,
    required TipoActivo tipoActivo,
    required double montoOriginal,
    required double pctDepreciacion,
    required DateTime fechaAdquisicion,
  }) : uuidFactura = Value(uuidFactura),
       tipoActivo = Value(tipoActivo),
       montoOriginal = Value(montoOriginal),
       pctDepreciacion = Value(pctDepreciacion),
       fechaAdquisicion = Value(fechaAdquisicion);
  static Insertable<Inversione> custom({
    Expression<int>? id,
    Expression<String>? uuidFactura,
    Expression<int>? tipoActivo,
    Expression<double>? montoOriginal,
    Expression<double>? pctDepreciacion,
    Expression<DateTime>? fechaAdquisicion,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuidFactura != null) 'uuid_factura': uuidFactura,
      if (tipoActivo != null) 'tipo_activo': tipoActivo,
      if (montoOriginal != null) 'monto_original': montoOriginal,
      if (pctDepreciacion != null) 'pct_depreciacion': pctDepreciacion,
      if (fechaAdquisicion != null) 'fecha_adquisicion': fechaAdquisicion,
    });
  }

  InversionesCompanion copyWith({
    Value<int>? id,
    Value<String>? uuidFactura,
    Value<TipoActivo>? tipoActivo,
    Value<double>? montoOriginal,
    Value<double>? pctDepreciacion,
    Value<DateTime>? fechaAdquisicion,
  }) {
    return InversionesCompanion(
      id: id ?? this.id,
      uuidFactura: uuidFactura ?? this.uuidFactura,
      tipoActivo: tipoActivo ?? this.tipoActivo,
      montoOriginal: montoOriginal ?? this.montoOriginal,
      pctDepreciacion: pctDepreciacion ?? this.pctDepreciacion,
      fechaAdquisicion: fechaAdquisicion ?? this.fechaAdquisicion,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuidFactura.present) {
      map['uuid_factura'] = Variable<String>(uuidFactura.value);
    }
    if (tipoActivo.present) {
      map['tipo_activo'] = Variable<int>(
        $InversionesTable.$convertertipoActivo.toSql(tipoActivo.value),
      );
    }
    if (montoOriginal.present) {
      map['monto_original'] = Variable<double>(montoOriginal.value);
    }
    if (pctDepreciacion.present) {
      map['pct_depreciacion'] = Variable<double>(pctDepreciacion.value);
    }
    if (fechaAdquisicion.present) {
      map['fecha_adquisicion'] = Variable<DateTime>(fechaAdquisicion.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InversionesCompanion(')
          ..write('id: $id, ')
          ..write('uuidFactura: $uuidFactura, ')
          ..write('tipoActivo: $tipoActivo, ')
          ..write('montoOriginal: $montoOriginal, ')
          ..write('pctDepreciacion: $pctDepreciacion, ')
          ..write('fechaAdquisicion: $fechaAdquisicion')
          ..write(')'))
        .toString();
  }
}

class $CapturasEspejoTable extends CapturasEspejo
    with TableInfo<$CapturasEspejoTable, CapturasEspejoData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CapturasEspejoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _anioMeta = const VerificationMeta('anio');
  @override
  late final GeneratedColumn<int> anio = GeneratedColumn<int>(
    'anio',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mesMeta = const VerificationMeta('mes');
  @override
  late final GeneratedColumn<int> mes = GeneratedColumn<int>(
    'mes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ptuPagadaMeta = const VerificationMeta(
    'ptuPagada',
  );
  @override
  late final GeneratedColumn<double> ptuPagada = GeneratedColumn<double>(
    'ptu_pagada',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _perdidasFiscalesMeta = const VerificationMeta(
    'perdidasFiscales',
  );
  @override
  late final GeneratedColumn<double> perdidasFiscales = GeneratedColumn<double>(
    'perdidas_fiscales',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _pagosProvisionalesAnterioresMeta =
      const VerificationMeta('pagosProvisionalesAnteriores');
  @override
  late final GeneratedColumn<double> pagosProvisionalesAnteriores =
      GeneratedColumn<double>(
        'pagos_provisionales_anteriores',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  static const VerificationMeta _saldoFavorIvaAnteriorMeta =
      const VerificationMeta('saldoFavorIvaAnterior');
  @override
  late final GeneratedColumn<double> saldoFavorIvaAnterior =
      GeneratedColumn<double>(
        'saldo_favor_iva_anterior',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  @override
  late final GeneratedColumnWithTypeConverter<TipoDeclaracion, int>
  tipoDeclaracion =
      GeneratedColumn<int>(
        'tipo_declaracion',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: Constant(TipoDeclaracion.normal.index),
      ).withConverter<TipoDeclaracion>(
        $CapturasEspejoTable.$convertertipoDeclaracion,
      );
  static const VerificationMeta _copropiedadMeta = const VerificationMeta(
    'copropiedad',
  );
  @override
  late final GeneratedColumn<bool> copropiedad = GeneratedColumn<bool>(
    'copropiedad',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("copropiedad" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    anio,
    mes,
    ptuPagada,
    perdidasFiscales,
    pagosProvisionalesAnteriores,
    saldoFavorIvaAnterior,
    tipoDeclaracion,
    copropiedad,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'capturas_espejo';
  @override
  VerificationContext validateIntegrity(
    Insertable<CapturasEspejoData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('anio')) {
      context.handle(
        _anioMeta,
        anio.isAcceptableOrUnknown(data['anio']!, _anioMeta),
      );
    } else if (isInserting) {
      context.missing(_anioMeta);
    }
    if (data.containsKey('mes')) {
      context.handle(
        _mesMeta,
        mes.isAcceptableOrUnknown(data['mes']!, _mesMeta),
      );
    } else if (isInserting) {
      context.missing(_mesMeta);
    }
    if (data.containsKey('ptu_pagada')) {
      context.handle(
        _ptuPagadaMeta,
        ptuPagada.isAcceptableOrUnknown(data['ptu_pagada']!, _ptuPagadaMeta),
      );
    }
    if (data.containsKey('perdidas_fiscales')) {
      context.handle(
        _perdidasFiscalesMeta,
        perdidasFiscales.isAcceptableOrUnknown(
          data['perdidas_fiscales']!,
          _perdidasFiscalesMeta,
        ),
      );
    }
    if (data.containsKey('pagos_provisionales_anteriores')) {
      context.handle(
        _pagosProvisionalesAnterioresMeta,
        pagosProvisionalesAnteriores.isAcceptableOrUnknown(
          data['pagos_provisionales_anteriores']!,
          _pagosProvisionalesAnterioresMeta,
        ),
      );
    }
    if (data.containsKey('saldo_favor_iva_anterior')) {
      context.handle(
        _saldoFavorIvaAnteriorMeta,
        saldoFavorIvaAnterior.isAcceptableOrUnknown(
          data['saldo_favor_iva_anterior']!,
          _saldoFavorIvaAnteriorMeta,
        ),
      );
    }
    if (data.containsKey('copropiedad')) {
      context.handle(
        _copropiedadMeta,
        copropiedad.isAcceptableOrUnknown(
          data['copropiedad']!,
          _copropiedadMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {anio, mes};
  @override
  CapturasEspejoData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CapturasEspejoData(
      anio: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}anio'],
      )!,
      mes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mes'],
      )!,
      ptuPagada: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ptu_pagada'],
      )!,
      perdidasFiscales: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}perdidas_fiscales'],
      )!,
      pagosProvisionalesAnteriores: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pagos_provisionales_anteriores'],
      )!,
      saldoFavorIvaAnterior: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}saldo_favor_iva_anterior'],
      )!,
      tipoDeclaracion: $CapturasEspejoTable.$convertertipoDeclaracion.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}tipo_declaracion'],
        )!,
      ),
      copropiedad: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}copropiedad'],
      )!,
    );
  }

  @override
  $CapturasEspejoTable createAlias(String alias) {
    return $CapturasEspejoTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TipoDeclaracion, int, int>
  $convertertipoDeclaracion = const EnumIndexConverter<TipoDeclaracion>(
    TipoDeclaracion.values,
  );
}

class CapturasEspejoData extends DataClass
    implements Insertable<CapturasEspejoData> {
  final int anio;
  final int mes;
  final double ptuPagada;
  final double perdidasFiscales;
  final double pagosProvisionalesAnteriores;
  final double saldoFavorIvaAnterior;
  final TipoDeclaracion tipoDeclaracion;
  final bool copropiedad;
  const CapturasEspejoData({
    required this.anio,
    required this.mes,
    required this.ptuPagada,
    required this.perdidasFiscales,
    required this.pagosProvisionalesAnteriores,
    required this.saldoFavorIvaAnterior,
    required this.tipoDeclaracion,
    required this.copropiedad,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['anio'] = Variable<int>(anio);
    map['mes'] = Variable<int>(mes);
    map['ptu_pagada'] = Variable<double>(ptuPagada);
    map['perdidas_fiscales'] = Variable<double>(perdidasFiscales);
    map['pagos_provisionales_anteriores'] = Variable<double>(
      pagosProvisionalesAnteriores,
    );
    map['saldo_favor_iva_anterior'] = Variable<double>(saldoFavorIvaAnterior);
    {
      map['tipo_declaracion'] = Variable<int>(
        $CapturasEspejoTable.$convertertipoDeclaracion.toSql(tipoDeclaracion),
      );
    }
    map['copropiedad'] = Variable<bool>(copropiedad);
    return map;
  }

  CapturasEspejoCompanion toCompanion(bool nullToAbsent) {
    return CapturasEspejoCompanion(
      anio: Value(anio),
      mes: Value(mes),
      ptuPagada: Value(ptuPagada),
      perdidasFiscales: Value(perdidasFiscales),
      pagosProvisionalesAnteriores: Value(pagosProvisionalesAnteriores),
      saldoFavorIvaAnterior: Value(saldoFavorIvaAnterior),
      tipoDeclaracion: Value(tipoDeclaracion),
      copropiedad: Value(copropiedad),
    );
  }

  factory CapturasEspejoData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CapturasEspejoData(
      anio: serializer.fromJson<int>(json['anio']),
      mes: serializer.fromJson<int>(json['mes']),
      ptuPagada: serializer.fromJson<double>(json['ptuPagada']),
      perdidasFiscales: serializer.fromJson<double>(json['perdidasFiscales']),
      pagosProvisionalesAnteriores: serializer.fromJson<double>(
        json['pagosProvisionalesAnteriores'],
      ),
      saldoFavorIvaAnterior: serializer.fromJson<double>(
        json['saldoFavorIvaAnterior'],
      ),
      tipoDeclaracion: $CapturasEspejoTable.$convertertipoDeclaracion.fromJson(
        serializer.fromJson<int>(json['tipoDeclaracion']),
      ),
      copropiedad: serializer.fromJson<bool>(json['copropiedad']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'anio': serializer.toJson<int>(anio),
      'mes': serializer.toJson<int>(mes),
      'ptuPagada': serializer.toJson<double>(ptuPagada),
      'perdidasFiscales': serializer.toJson<double>(perdidasFiscales),
      'pagosProvisionalesAnteriores': serializer.toJson<double>(
        pagosProvisionalesAnteriores,
      ),
      'saldoFavorIvaAnterior': serializer.toJson<double>(saldoFavorIvaAnterior),
      'tipoDeclaracion': serializer.toJson<int>(
        $CapturasEspejoTable.$convertertipoDeclaracion.toJson(tipoDeclaracion),
      ),
      'copropiedad': serializer.toJson<bool>(copropiedad),
    };
  }

  CapturasEspejoData copyWith({
    int? anio,
    int? mes,
    double? ptuPagada,
    double? perdidasFiscales,
    double? pagosProvisionalesAnteriores,
    double? saldoFavorIvaAnterior,
    TipoDeclaracion? tipoDeclaracion,
    bool? copropiedad,
  }) => CapturasEspejoData(
    anio: anio ?? this.anio,
    mes: mes ?? this.mes,
    ptuPagada: ptuPagada ?? this.ptuPagada,
    perdidasFiscales: perdidasFiscales ?? this.perdidasFiscales,
    pagosProvisionalesAnteriores:
        pagosProvisionalesAnteriores ?? this.pagosProvisionalesAnteriores,
    saldoFavorIvaAnterior: saldoFavorIvaAnterior ?? this.saldoFavorIvaAnterior,
    tipoDeclaracion: tipoDeclaracion ?? this.tipoDeclaracion,
    copropiedad: copropiedad ?? this.copropiedad,
  );
  CapturasEspejoData copyWithCompanion(CapturasEspejoCompanion data) {
    return CapturasEspejoData(
      anio: data.anio.present ? data.anio.value : this.anio,
      mes: data.mes.present ? data.mes.value : this.mes,
      ptuPagada: data.ptuPagada.present ? data.ptuPagada.value : this.ptuPagada,
      perdidasFiscales: data.perdidasFiscales.present
          ? data.perdidasFiscales.value
          : this.perdidasFiscales,
      pagosProvisionalesAnteriores: data.pagosProvisionalesAnteriores.present
          ? data.pagosProvisionalesAnteriores.value
          : this.pagosProvisionalesAnteriores,
      saldoFavorIvaAnterior: data.saldoFavorIvaAnterior.present
          ? data.saldoFavorIvaAnterior.value
          : this.saldoFavorIvaAnterior,
      tipoDeclaracion: data.tipoDeclaracion.present
          ? data.tipoDeclaracion.value
          : this.tipoDeclaracion,
      copropiedad: data.copropiedad.present
          ? data.copropiedad.value
          : this.copropiedad,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CapturasEspejoData(')
          ..write('anio: $anio, ')
          ..write('mes: $mes, ')
          ..write('ptuPagada: $ptuPagada, ')
          ..write('perdidasFiscales: $perdidasFiscales, ')
          ..write(
            'pagosProvisionalesAnteriores: $pagosProvisionalesAnteriores, ',
          )
          ..write('saldoFavorIvaAnterior: $saldoFavorIvaAnterior, ')
          ..write('tipoDeclaracion: $tipoDeclaracion, ')
          ..write('copropiedad: $copropiedad')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    anio,
    mes,
    ptuPagada,
    perdidasFiscales,
    pagosProvisionalesAnteriores,
    saldoFavorIvaAnterior,
    tipoDeclaracion,
    copropiedad,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CapturasEspejoData &&
          other.anio == this.anio &&
          other.mes == this.mes &&
          other.ptuPagada == this.ptuPagada &&
          other.perdidasFiscales == this.perdidasFiscales &&
          other.pagosProvisionalesAnteriores ==
              this.pagosProvisionalesAnteriores &&
          other.saldoFavorIvaAnterior == this.saldoFavorIvaAnterior &&
          other.tipoDeclaracion == this.tipoDeclaracion &&
          other.copropiedad == this.copropiedad);
}

class CapturasEspejoCompanion extends UpdateCompanion<CapturasEspejoData> {
  final Value<int> anio;
  final Value<int> mes;
  final Value<double> ptuPagada;
  final Value<double> perdidasFiscales;
  final Value<double> pagosProvisionalesAnteriores;
  final Value<double> saldoFavorIvaAnterior;
  final Value<TipoDeclaracion> tipoDeclaracion;
  final Value<bool> copropiedad;
  final Value<int> rowid;
  const CapturasEspejoCompanion({
    this.anio = const Value.absent(),
    this.mes = const Value.absent(),
    this.ptuPagada = const Value.absent(),
    this.perdidasFiscales = const Value.absent(),
    this.pagosProvisionalesAnteriores = const Value.absent(),
    this.saldoFavorIvaAnterior = const Value.absent(),
    this.tipoDeclaracion = const Value.absent(),
    this.copropiedad = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CapturasEspejoCompanion.insert({
    required int anio,
    required int mes,
    this.ptuPagada = const Value.absent(),
    this.perdidasFiscales = const Value.absent(),
    this.pagosProvisionalesAnteriores = const Value.absent(),
    this.saldoFavorIvaAnterior = const Value.absent(),
    this.tipoDeclaracion = const Value.absent(),
    this.copropiedad = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : anio = Value(anio),
       mes = Value(mes);
  static Insertable<CapturasEspejoData> custom({
    Expression<int>? anio,
    Expression<int>? mes,
    Expression<double>? ptuPagada,
    Expression<double>? perdidasFiscales,
    Expression<double>? pagosProvisionalesAnteriores,
    Expression<double>? saldoFavorIvaAnterior,
    Expression<int>? tipoDeclaracion,
    Expression<bool>? copropiedad,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (anio != null) 'anio': anio,
      if (mes != null) 'mes': mes,
      if (ptuPagada != null) 'ptu_pagada': ptuPagada,
      if (perdidasFiscales != null) 'perdidas_fiscales': perdidasFiscales,
      if (pagosProvisionalesAnteriores != null)
        'pagos_provisionales_anteriores': pagosProvisionalesAnteriores,
      if (saldoFavorIvaAnterior != null)
        'saldo_favor_iva_anterior': saldoFavorIvaAnterior,
      if (tipoDeclaracion != null) 'tipo_declaracion': tipoDeclaracion,
      if (copropiedad != null) 'copropiedad': copropiedad,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CapturasEspejoCompanion copyWith({
    Value<int>? anio,
    Value<int>? mes,
    Value<double>? ptuPagada,
    Value<double>? perdidasFiscales,
    Value<double>? pagosProvisionalesAnteriores,
    Value<double>? saldoFavorIvaAnterior,
    Value<TipoDeclaracion>? tipoDeclaracion,
    Value<bool>? copropiedad,
    Value<int>? rowid,
  }) {
    return CapturasEspejoCompanion(
      anio: anio ?? this.anio,
      mes: mes ?? this.mes,
      ptuPagada: ptuPagada ?? this.ptuPagada,
      perdidasFiscales: perdidasFiscales ?? this.perdidasFiscales,
      pagosProvisionalesAnteriores:
          pagosProvisionalesAnteriores ?? this.pagosProvisionalesAnteriores,
      saldoFavorIvaAnterior:
          saldoFavorIvaAnterior ?? this.saldoFavorIvaAnterior,
      tipoDeclaracion: tipoDeclaracion ?? this.tipoDeclaracion,
      copropiedad: copropiedad ?? this.copropiedad,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (anio.present) {
      map['anio'] = Variable<int>(anio.value);
    }
    if (mes.present) {
      map['mes'] = Variable<int>(mes.value);
    }
    if (ptuPagada.present) {
      map['ptu_pagada'] = Variable<double>(ptuPagada.value);
    }
    if (perdidasFiscales.present) {
      map['perdidas_fiscales'] = Variable<double>(perdidasFiscales.value);
    }
    if (pagosProvisionalesAnteriores.present) {
      map['pagos_provisionales_anteriores'] = Variable<double>(
        pagosProvisionalesAnteriores.value,
      );
    }
    if (saldoFavorIvaAnterior.present) {
      map['saldo_favor_iva_anterior'] = Variable<double>(
        saldoFavorIvaAnterior.value,
      );
    }
    if (tipoDeclaracion.present) {
      map['tipo_declaracion'] = Variable<int>(
        $CapturasEspejoTable.$convertertipoDeclaracion.toSql(
          tipoDeclaracion.value,
        ),
      );
    }
    if (copropiedad.present) {
      map['copropiedad'] = Variable<bool>(copropiedad.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CapturasEspejoCompanion(')
          ..write('anio: $anio, ')
          ..write('mes: $mes, ')
          ..write('ptuPagada: $ptuPagada, ')
          ..write('perdidasFiscales: $perdidasFiscales, ')
          ..write(
            'pagosProvisionalesAnteriores: $pagosProvisionalesAnteriores, ',
          )
          ..write('saldoFavorIvaAnterior: $saldoFavorIvaAnterior, ')
          ..write('tipoDeclaracion: $tipoDeclaracion, ')
          ..write('copropiedad: $copropiedad, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ContribuyentesTable contribuyentes = $ContribuyentesTable(this);
  late final $FacturasTable facturas = $FacturasTable(this);
  late final $InversionesTable inversiones = $InversionesTable(this);
  late final $CapturasEspejoTable capturasEspejo = $CapturasEspejoTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    contribuyentes,
    facturas,
    inversiones,
    capturasEspejo,
  ];
}

typedef $$ContribuyentesTableCreateCompanionBuilder =
    ContribuyentesCompanion Function({
      required String rfc,
      required String razonSocial,
      required TipoPersona tipoPersona,
      Value<DateTime> creadoEn,
      Value<int> rowid,
    });
typedef $$ContribuyentesTableUpdateCompanionBuilder =
    ContribuyentesCompanion Function({
      Value<String> rfc,
      Value<String> razonSocial,
      Value<TipoPersona> tipoPersona,
      Value<DateTime> creadoEn,
      Value<int> rowid,
    });

class $$ContribuyentesTableFilterComposer
    extends Composer<_$AppDatabase, $ContribuyentesTable> {
  $$ContribuyentesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get rfc => $composableBuilder(
    column: $table.rfc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get razonSocial => $composableBuilder(
    column: $table.razonSocial,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TipoPersona, TipoPersona, int>
  get tipoPersona => $composableBuilder(
    column: $table.tipoPersona,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContribuyentesTableOrderingComposer
    extends Composer<_$AppDatabase, $ContribuyentesTable> {
  $$ContribuyentesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get rfc => $composableBuilder(
    column: $table.rfc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get razonSocial => $composableBuilder(
    column: $table.razonSocial,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tipoPersona => $composableBuilder(
    column: $table.tipoPersona,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContribuyentesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContribuyentesTable> {
  $$ContribuyentesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get rfc =>
      $composableBuilder(column: $table.rfc, builder: (column) => column);

  GeneratedColumn<String> get razonSocial => $composableBuilder(
    column: $table.razonSocial,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<TipoPersona, int> get tipoPersona =>
      $composableBuilder(
        column: $table.tipoPersona,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);
}

class $$ContribuyentesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContribuyentesTable,
          Contribuyente,
          $$ContribuyentesTableFilterComposer,
          $$ContribuyentesTableOrderingComposer,
          $$ContribuyentesTableAnnotationComposer,
          $$ContribuyentesTableCreateCompanionBuilder,
          $$ContribuyentesTableUpdateCompanionBuilder,
          (
            Contribuyente,
            BaseReferences<_$AppDatabase, $ContribuyentesTable, Contribuyente>,
          ),
          Contribuyente,
          PrefetchHooks Function()
        > {
  $$ContribuyentesTableTableManager(
    _$AppDatabase db,
    $ContribuyentesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContribuyentesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContribuyentesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContribuyentesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> rfc = const Value.absent(),
                Value<String> razonSocial = const Value.absent(),
                Value<TipoPersona> tipoPersona = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContribuyentesCompanion(
                rfc: rfc,
                razonSocial: razonSocial,
                tipoPersona: tipoPersona,
                creadoEn: creadoEn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String rfc,
                required String razonSocial,
                required TipoPersona tipoPersona,
                Value<DateTime> creadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContribuyentesCompanion.insert(
                rfc: rfc,
                razonSocial: razonSocial,
                tipoPersona: tipoPersona,
                creadoEn: creadoEn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContribuyentesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContribuyentesTable,
      Contribuyente,
      $$ContribuyentesTableFilterComposer,
      $$ContribuyentesTableOrderingComposer,
      $$ContribuyentesTableAnnotationComposer,
      $$ContribuyentesTableCreateCompanionBuilder,
      $$ContribuyentesTableUpdateCompanionBuilder,
      (
        Contribuyente,
        BaseReferences<_$AppDatabase, $ContribuyentesTable, Contribuyente>,
      ),
      Contribuyente,
      PrefetchHooks Function()
    >;
typedef $$FacturasTableCreateCompanionBuilder =
    FacturasCompanion Function({
      required String uuid,
      Value<String?> folioInterno,
      required DateTime fechaEmision,
      Value<DateTime?> fechaPagoEfectivo,
      required String rfcEmisor,
      required String rfcReceptor,
      required TipoCfdi tipoCfdi,
      required double subtotal,
      Value<double> tasaIva,
      Value<double> ivaTrasladado,
      Value<double> ivaRetenido,
      Value<double> isrRetenido,
      required double total,
      required MetodoPagoCfdi metodoPago,
      required String formaPago,
      Value<bool> esDeducible,
      required EstatusPago estatusPago,
      Value<int> rowid,
    });
typedef $$FacturasTableUpdateCompanionBuilder =
    FacturasCompanion Function({
      Value<String> uuid,
      Value<String?> folioInterno,
      Value<DateTime> fechaEmision,
      Value<DateTime?> fechaPagoEfectivo,
      Value<String> rfcEmisor,
      Value<String> rfcReceptor,
      Value<TipoCfdi> tipoCfdi,
      Value<double> subtotal,
      Value<double> tasaIva,
      Value<double> ivaTrasladado,
      Value<double> ivaRetenido,
      Value<double> isrRetenido,
      Value<double> total,
      Value<MetodoPagoCfdi> metodoPago,
      Value<String> formaPago,
      Value<bool> esDeducible,
      Value<EstatusPago> estatusPago,
      Value<int> rowid,
    });

final class $$FacturasTableReferences
    extends BaseReferences<_$AppDatabase, $FacturasTable, Factura> {
  $$FacturasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ContribuyentesTable _rfcEmisorTable(_$AppDatabase db) => db
      .contribuyentes
      .createAlias('facturas__rfc_emisor__contribuyentes__rfc');

  $$ContribuyentesTableProcessedTableManager get rfcEmisor {
    final $_column = $_itemColumn<String>('rfc_emisor')!;

    final manager = $$ContribuyentesTableTableManager(
      $_db,
      $_db.contribuyentes,
    ).filter((f) => f.rfc.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rfcEmisorTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ContribuyentesTable _rfcReceptorTable(_$AppDatabase db) => db
      .contribuyentes
      .createAlias('facturas__rfc_receptor__contribuyentes__rfc');

  $$ContribuyentesTableProcessedTableManager get rfcReceptor {
    final $_column = $_itemColumn<String>('rfc_receptor')!;

    final manager = $$ContribuyentesTableTableManager(
      $_db,
      $_db.contribuyentes,
    ).filter((f) => f.rfc.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rfcReceptorTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$InversionesTable, List<Inversione>>
  _inversionesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.inversiones,
    aliasName: 'facturas__uuid__inversiones__uuid_factura',
  );

  $$InversionesTableProcessedTableManager get inversionesRefs {
    final manager = $$InversionesTableTableManager($_db, $_db.inversiones)
        .filter(
          (f) => f.uuidFactura.uuid.sqlEquals($_itemColumn<String>('uuid')!),
        );

    final cache = $_typedResult.readTableOrNull(_inversionesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FacturasTableFilterComposer
    extends Composer<_$AppDatabase, $FacturasTable> {
  $$FacturasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get folioInterno => $composableBuilder(
    column: $table.folioInterno,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fechaEmision => $composableBuilder(
    column: $table.fechaEmision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fechaPagoEfectivo => $composableBuilder(
    column: $table.fechaPagoEfectivo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TipoCfdi, TipoCfdi, int> get tipoCfdi =>
      $composableBuilder(
        column: $table.tipoCfdi,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tasaIva => $composableBuilder(
    column: $table.tasaIva,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ivaTrasladado => $composableBuilder(
    column: $table.ivaTrasladado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ivaRetenido => $composableBuilder(
    column: $table.ivaRetenido,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get isrRetenido => $composableBuilder(
    column: $table.isrRetenido,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MetodoPagoCfdi, MetodoPagoCfdi, int>
  get metodoPago => $composableBuilder(
    column: $table.metodoPago,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get formaPago => $composableBuilder(
    column: $table.formaPago,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get esDeducible => $composableBuilder(
    column: $table.esDeducible,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<EstatusPago, EstatusPago, int>
  get estatusPago => $composableBuilder(
    column: $table.estatusPago,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$ContribuyentesTableFilterComposer get rfcEmisor {
    final $$ContribuyentesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rfcEmisor,
      referencedTable: $db.contribuyentes,
      getReferencedColumn: (t) => t.rfc,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContribuyentesTableFilterComposer(
            $db: $db,
            $table: $db.contribuyentes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ContribuyentesTableFilterComposer get rfcReceptor {
    final $$ContribuyentesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rfcReceptor,
      referencedTable: $db.contribuyentes,
      getReferencedColumn: (t) => t.rfc,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContribuyentesTableFilterComposer(
            $db: $db,
            $table: $db.contribuyentes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> inversionesRefs(
    Expression<bool> Function($$InversionesTableFilterComposer f) f,
  ) {
    final $$InversionesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuid,
      referencedTable: $db.inversiones,
      getReferencedColumn: (t) => t.uuidFactura,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InversionesTableFilterComposer(
            $db: $db,
            $table: $db.inversiones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FacturasTableOrderingComposer
    extends Composer<_$AppDatabase, $FacturasTable> {
  $$FacturasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get folioInterno => $composableBuilder(
    column: $table.folioInterno,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaEmision => $composableBuilder(
    column: $table.fechaEmision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaPagoEfectivo => $composableBuilder(
    column: $table.fechaPagoEfectivo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tipoCfdi => $composableBuilder(
    column: $table.tipoCfdi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tasaIva => $composableBuilder(
    column: $table.tasaIva,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ivaTrasladado => $composableBuilder(
    column: $table.ivaTrasladado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ivaRetenido => $composableBuilder(
    column: $table.ivaRetenido,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get isrRetenido => $composableBuilder(
    column: $table.isrRetenido,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get metodoPago => $composableBuilder(
    column: $table.metodoPago,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get formaPago => $composableBuilder(
    column: $table.formaPago,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get esDeducible => $composableBuilder(
    column: $table.esDeducible,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estatusPago => $composableBuilder(
    column: $table.estatusPago,
    builder: (column) => ColumnOrderings(column),
  );

  $$ContribuyentesTableOrderingComposer get rfcEmisor {
    final $$ContribuyentesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rfcEmisor,
      referencedTable: $db.contribuyentes,
      getReferencedColumn: (t) => t.rfc,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContribuyentesTableOrderingComposer(
            $db: $db,
            $table: $db.contribuyentes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ContribuyentesTableOrderingComposer get rfcReceptor {
    final $$ContribuyentesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rfcReceptor,
      referencedTable: $db.contribuyentes,
      getReferencedColumn: (t) => t.rfc,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContribuyentesTableOrderingComposer(
            $db: $db,
            $table: $db.contribuyentes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FacturasTableAnnotationComposer
    extends Composer<_$AppDatabase, $FacturasTable> {
  $$FacturasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get folioInterno => $composableBuilder(
    column: $table.folioInterno,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fechaEmision => $composableBuilder(
    column: $table.fechaEmision,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fechaPagoEfectivo => $composableBuilder(
    column: $table.fechaPagoEfectivo,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<TipoCfdi, int> get tipoCfdi =>
      $composableBuilder(column: $table.tipoCfdi, builder: (column) => column);

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<double> get tasaIva =>
      $composableBuilder(column: $table.tasaIva, builder: (column) => column);

  GeneratedColumn<double> get ivaTrasladado => $composableBuilder(
    column: $table.ivaTrasladado,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ivaRetenido => $composableBuilder(
    column: $table.ivaRetenido,
    builder: (column) => column,
  );

  GeneratedColumn<double> get isrRetenido => $composableBuilder(
    column: $table.isrRetenido,
    builder: (column) => column,
  );

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MetodoPagoCfdi, int> get metodoPago =>
      $composableBuilder(
        column: $table.metodoPago,
        builder: (column) => column,
      );

  GeneratedColumn<String> get formaPago =>
      $composableBuilder(column: $table.formaPago, builder: (column) => column);

  GeneratedColumn<bool> get esDeducible => $composableBuilder(
    column: $table.esDeducible,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<EstatusPago, int> get estatusPago =>
      $composableBuilder(
        column: $table.estatusPago,
        builder: (column) => column,
      );

  $$ContribuyentesTableAnnotationComposer get rfcEmisor {
    final $$ContribuyentesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rfcEmisor,
      referencedTable: $db.contribuyentes,
      getReferencedColumn: (t) => t.rfc,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContribuyentesTableAnnotationComposer(
            $db: $db,
            $table: $db.contribuyentes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ContribuyentesTableAnnotationComposer get rfcReceptor {
    final $$ContribuyentesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rfcReceptor,
      referencedTable: $db.contribuyentes,
      getReferencedColumn: (t) => t.rfc,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContribuyentesTableAnnotationComposer(
            $db: $db,
            $table: $db.contribuyentes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> inversionesRefs<T extends Object>(
    Expression<T> Function($$InversionesTableAnnotationComposer a) f,
  ) {
    final $$InversionesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuid,
      referencedTable: $db.inversiones,
      getReferencedColumn: (t) => t.uuidFactura,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InversionesTableAnnotationComposer(
            $db: $db,
            $table: $db.inversiones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FacturasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FacturasTable,
          Factura,
          $$FacturasTableFilterComposer,
          $$FacturasTableOrderingComposer,
          $$FacturasTableAnnotationComposer,
          $$FacturasTableCreateCompanionBuilder,
          $$FacturasTableUpdateCompanionBuilder,
          (Factura, $$FacturasTableReferences),
          Factura,
          PrefetchHooks Function({
            bool rfcEmisor,
            bool rfcReceptor,
            bool inversionesRefs,
          })
        > {
  $$FacturasTableTableManager(_$AppDatabase db, $FacturasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FacturasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FacturasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FacturasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uuid = const Value.absent(),
                Value<String?> folioInterno = const Value.absent(),
                Value<DateTime> fechaEmision = const Value.absent(),
                Value<DateTime?> fechaPagoEfectivo = const Value.absent(),
                Value<String> rfcEmisor = const Value.absent(),
                Value<String> rfcReceptor = const Value.absent(),
                Value<TipoCfdi> tipoCfdi = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
                Value<double> tasaIva = const Value.absent(),
                Value<double> ivaTrasladado = const Value.absent(),
                Value<double> ivaRetenido = const Value.absent(),
                Value<double> isrRetenido = const Value.absent(),
                Value<double> total = const Value.absent(),
                Value<MetodoPagoCfdi> metodoPago = const Value.absent(),
                Value<String> formaPago = const Value.absent(),
                Value<bool> esDeducible = const Value.absent(),
                Value<EstatusPago> estatusPago = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FacturasCompanion(
                uuid: uuid,
                folioInterno: folioInterno,
                fechaEmision: fechaEmision,
                fechaPagoEfectivo: fechaPagoEfectivo,
                rfcEmisor: rfcEmisor,
                rfcReceptor: rfcReceptor,
                tipoCfdi: tipoCfdi,
                subtotal: subtotal,
                tasaIva: tasaIva,
                ivaTrasladado: ivaTrasladado,
                ivaRetenido: ivaRetenido,
                isrRetenido: isrRetenido,
                total: total,
                metodoPago: metodoPago,
                formaPago: formaPago,
                esDeducible: esDeducible,
                estatusPago: estatusPago,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uuid,
                Value<String?> folioInterno = const Value.absent(),
                required DateTime fechaEmision,
                Value<DateTime?> fechaPagoEfectivo = const Value.absent(),
                required String rfcEmisor,
                required String rfcReceptor,
                required TipoCfdi tipoCfdi,
                required double subtotal,
                Value<double> tasaIva = const Value.absent(),
                Value<double> ivaTrasladado = const Value.absent(),
                Value<double> ivaRetenido = const Value.absent(),
                Value<double> isrRetenido = const Value.absent(),
                required double total,
                required MetodoPagoCfdi metodoPago,
                required String formaPago,
                Value<bool> esDeducible = const Value.absent(),
                required EstatusPago estatusPago,
                Value<int> rowid = const Value.absent(),
              }) => FacturasCompanion.insert(
                uuid: uuid,
                folioInterno: folioInterno,
                fechaEmision: fechaEmision,
                fechaPagoEfectivo: fechaPagoEfectivo,
                rfcEmisor: rfcEmisor,
                rfcReceptor: rfcReceptor,
                tipoCfdi: tipoCfdi,
                subtotal: subtotal,
                tasaIva: tasaIva,
                ivaTrasladado: ivaTrasladado,
                ivaRetenido: ivaRetenido,
                isrRetenido: isrRetenido,
                total: total,
                metodoPago: metodoPago,
                formaPago: formaPago,
                esDeducible: esDeducible,
                estatusPago: estatusPago,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FacturasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                rfcEmisor = false,
                rfcReceptor = false,
                inversionesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (inversionesRefs) db.inversiones,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (rfcEmisor) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.rfcEmisor,
                                    referencedTable: $$FacturasTableReferences
                                        ._rfcEmisorTable(db),
                                    referencedColumn: $$FacturasTableReferences
                                        ._rfcEmisorTable(db)
                                        .rfc,
                                  )
                                  as T;
                        }
                        if (rfcReceptor) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.rfcReceptor,
                                    referencedTable: $$FacturasTableReferences
                                        ._rfcReceptorTable(db),
                                    referencedColumn: $$FacturasTableReferences
                                        ._rfcReceptorTable(db)
                                        .rfc,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (inversionesRefs)
                        await $_getPrefetchedData<
                          Factura,
                          $FacturasTable,
                          Inversione
                        >(
                          currentTable: table,
                          referencedTable: $$FacturasTableReferences
                              ._inversionesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FacturasTableReferences(
                                db,
                                table,
                                p0,
                              ).inversionesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.uuidFactura == item.uuid,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$FacturasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FacturasTable,
      Factura,
      $$FacturasTableFilterComposer,
      $$FacturasTableOrderingComposer,
      $$FacturasTableAnnotationComposer,
      $$FacturasTableCreateCompanionBuilder,
      $$FacturasTableUpdateCompanionBuilder,
      (Factura, $$FacturasTableReferences),
      Factura,
      PrefetchHooks Function({
        bool rfcEmisor,
        bool rfcReceptor,
        bool inversionesRefs,
      })
    >;
typedef $$InversionesTableCreateCompanionBuilder =
    InversionesCompanion Function({
      Value<int> id,
      required String uuidFactura,
      required TipoActivo tipoActivo,
      required double montoOriginal,
      required double pctDepreciacion,
      required DateTime fechaAdquisicion,
    });
typedef $$InversionesTableUpdateCompanionBuilder =
    InversionesCompanion Function({
      Value<int> id,
      Value<String> uuidFactura,
      Value<TipoActivo> tipoActivo,
      Value<double> montoOriginal,
      Value<double> pctDepreciacion,
      Value<DateTime> fechaAdquisicion,
    });

final class $$InversionesTableReferences
    extends BaseReferences<_$AppDatabase, $InversionesTable, Inversione> {
  $$InversionesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FacturasTable _uuidFacturaTable(_$AppDatabase db) =>
      db.facturas.createAlias('inversiones__uuid_factura__facturas__uuid');

  $$FacturasTableProcessedTableManager get uuidFactura {
    final $_column = $_itemColumn<String>('uuid_factura')!;

    final manager = $$FacturasTableTableManager(
      $_db,
      $_db.facturas,
    ).filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_uuidFacturaTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InversionesTableFilterComposer
    extends Composer<_$AppDatabase, $InversionesTable> {
  $$InversionesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TipoActivo, TipoActivo, int> get tipoActivo =>
      $composableBuilder(
        column: $table.tipoActivo,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get montoOriginal => $composableBuilder(
    column: $table.montoOriginal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pctDepreciacion => $composableBuilder(
    column: $table.pctDepreciacion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fechaAdquisicion => $composableBuilder(
    column: $table.fechaAdquisicion,
    builder: (column) => ColumnFilters(column),
  );

  $$FacturasTableFilterComposer get uuidFactura {
    final $$FacturasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuidFactura,
      referencedTable: $db.facturas,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FacturasTableFilterComposer(
            $db: $db,
            $table: $db.facturas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InversionesTableOrderingComposer
    extends Composer<_$AppDatabase, $InversionesTable> {
  $$InversionesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tipoActivo => $composableBuilder(
    column: $table.tipoActivo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get montoOriginal => $composableBuilder(
    column: $table.montoOriginal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pctDepreciacion => $composableBuilder(
    column: $table.pctDepreciacion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaAdquisicion => $composableBuilder(
    column: $table.fechaAdquisicion,
    builder: (column) => ColumnOrderings(column),
  );

  $$FacturasTableOrderingComposer get uuidFactura {
    final $$FacturasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuidFactura,
      referencedTable: $db.facturas,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FacturasTableOrderingComposer(
            $db: $db,
            $table: $db.facturas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InversionesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InversionesTable> {
  $$InversionesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TipoActivo, int> get tipoActivo =>
      $composableBuilder(
        column: $table.tipoActivo,
        builder: (column) => column,
      );

  GeneratedColumn<double> get montoOriginal => $composableBuilder(
    column: $table.montoOriginal,
    builder: (column) => column,
  );

  GeneratedColumn<double> get pctDepreciacion => $composableBuilder(
    column: $table.pctDepreciacion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fechaAdquisicion => $composableBuilder(
    column: $table.fechaAdquisicion,
    builder: (column) => column,
  );

  $$FacturasTableAnnotationComposer get uuidFactura {
    final $$FacturasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuidFactura,
      referencedTable: $db.facturas,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FacturasTableAnnotationComposer(
            $db: $db,
            $table: $db.facturas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InversionesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InversionesTable,
          Inversione,
          $$InversionesTableFilterComposer,
          $$InversionesTableOrderingComposer,
          $$InversionesTableAnnotationComposer,
          $$InversionesTableCreateCompanionBuilder,
          $$InversionesTableUpdateCompanionBuilder,
          (Inversione, $$InversionesTableReferences),
          Inversione,
          PrefetchHooks Function({bool uuidFactura})
        > {
  $$InversionesTableTableManager(_$AppDatabase db, $InversionesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InversionesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InversionesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InversionesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuidFactura = const Value.absent(),
                Value<TipoActivo> tipoActivo = const Value.absent(),
                Value<double> montoOriginal = const Value.absent(),
                Value<double> pctDepreciacion = const Value.absent(),
                Value<DateTime> fechaAdquisicion = const Value.absent(),
              }) => InversionesCompanion(
                id: id,
                uuidFactura: uuidFactura,
                tipoActivo: tipoActivo,
                montoOriginal: montoOriginal,
                pctDepreciacion: pctDepreciacion,
                fechaAdquisicion: fechaAdquisicion,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuidFactura,
                required TipoActivo tipoActivo,
                required double montoOriginal,
                required double pctDepreciacion,
                required DateTime fechaAdquisicion,
              }) => InversionesCompanion.insert(
                id: id,
                uuidFactura: uuidFactura,
                tipoActivo: tipoActivo,
                montoOriginal: montoOriginal,
                pctDepreciacion: pctDepreciacion,
                fechaAdquisicion: fechaAdquisicion,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InversionesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({uuidFactura = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (uuidFactura) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.uuidFactura,
                                referencedTable: $$InversionesTableReferences
                                    ._uuidFacturaTable(db),
                                referencedColumn: $$InversionesTableReferences
                                    ._uuidFacturaTable(db)
                                    .uuid,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$InversionesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InversionesTable,
      Inversione,
      $$InversionesTableFilterComposer,
      $$InversionesTableOrderingComposer,
      $$InversionesTableAnnotationComposer,
      $$InversionesTableCreateCompanionBuilder,
      $$InversionesTableUpdateCompanionBuilder,
      (Inversione, $$InversionesTableReferences),
      Inversione,
      PrefetchHooks Function({bool uuidFactura})
    >;
typedef $$CapturasEspejoTableCreateCompanionBuilder =
    CapturasEspejoCompanion Function({
      required int anio,
      required int mes,
      Value<double> ptuPagada,
      Value<double> perdidasFiscales,
      Value<double> pagosProvisionalesAnteriores,
      Value<double> saldoFavorIvaAnterior,
      Value<TipoDeclaracion> tipoDeclaracion,
      Value<bool> copropiedad,
      Value<int> rowid,
    });
typedef $$CapturasEspejoTableUpdateCompanionBuilder =
    CapturasEspejoCompanion Function({
      Value<int> anio,
      Value<int> mes,
      Value<double> ptuPagada,
      Value<double> perdidasFiscales,
      Value<double> pagosProvisionalesAnteriores,
      Value<double> saldoFavorIvaAnterior,
      Value<TipoDeclaracion> tipoDeclaracion,
      Value<bool> copropiedad,
      Value<int> rowid,
    });

class $$CapturasEspejoTableFilterComposer
    extends Composer<_$AppDatabase, $CapturasEspejoTable> {
  $$CapturasEspejoTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get anio => $composableBuilder(
    column: $table.anio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mes => $composableBuilder(
    column: $table.mes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ptuPagada => $composableBuilder(
    column: $table.ptuPagada,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get perdidasFiscales => $composableBuilder(
    column: $table.perdidasFiscales,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pagosProvisionalesAnteriores => $composableBuilder(
    column: $table.pagosProvisionalesAnteriores,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get saldoFavorIvaAnterior => $composableBuilder(
    column: $table.saldoFavorIvaAnterior,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TipoDeclaracion, TipoDeclaracion, int>
  get tipoDeclaracion => $composableBuilder(
    column: $table.tipoDeclaracion,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get copropiedad => $composableBuilder(
    column: $table.copropiedad,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CapturasEspejoTableOrderingComposer
    extends Composer<_$AppDatabase, $CapturasEspejoTable> {
  $$CapturasEspejoTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get anio => $composableBuilder(
    column: $table.anio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mes => $composableBuilder(
    column: $table.mes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ptuPagada => $composableBuilder(
    column: $table.ptuPagada,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get perdidasFiscales => $composableBuilder(
    column: $table.perdidasFiscales,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pagosProvisionalesAnteriores =>
      $composableBuilder(
        column: $table.pagosProvisionalesAnteriores,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<double> get saldoFavorIvaAnterior => $composableBuilder(
    column: $table.saldoFavorIvaAnterior,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tipoDeclaracion => $composableBuilder(
    column: $table.tipoDeclaracion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get copropiedad => $composableBuilder(
    column: $table.copropiedad,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CapturasEspejoTableAnnotationComposer
    extends Composer<_$AppDatabase, $CapturasEspejoTable> {
  $$CapturasEspejoTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get anio =>
      $composableBuilder(column: $table.anio, builder: (column) => column);

  GeneratedColumn<int> get mes =>
      $composableBuilder(column: $table.mes, builder: (column) => column);

  GeneratedColumn<double> get ptuPagada =>
      $composableBuilder(column: $table.ptuPagada, builder: (column) => column);

  GeneratedColumn<double> get perdidasFiscales => $composableBuilder(
    column: $table.perdidasFiscales,
    builder: (column) => column,
  );

  GeneratedColumn<double> get pagosProvisionalesAnteriores =>
      $composableBuilder(
        column: $table.pagosProvisionalesAnteriores,
        builder: (column) => column,
      );

  GeneratedColumn<double> get saldoFavorIvaAnterior => $composableBuilder(
    column: $table.saldoFavorIvaAnterior,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<TipoDeclaracion, int> get tipoDeclaracion =>
      $composableBuilder(
        column: $table.tipoDeclaracion,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get copropiedad => $composableBuilder(
    column: $table.copropiedad,
    builder: (column) => column,
  );
}

class $$CapturasEspejoTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CapturasEspejoTable,
          CapturasEspejoData,
          $$CapturasEspejoTableFilterComposer,
          $$CapturasEspejoTableOrderingComposer,
          $$CapturasEspejoTableAnnotationComposer,
          $$CapturasEspejoTableCreateCompanionBuilder,
          $$CapturasEspejoTableUpdateCompanionBuilder,
          (
            CapturasEspejoData,
            BaseReferences<
              _$AppDatabase,
              $CapturasEspejoTable,
              CapturasEspejoData
            >,
          ),
          CapturasEspejoData,
          PrefetchHooks Function()
        > {
  $$CapturasEspejoTableTableManager(
    _$AppDatabase db,
    $CapturasEspejoTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CapturasEspejoTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CapturasEspejoTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CapturasEspejoTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> anio = const Value.absent(),
                Value<int> mes = const Value.absent(),
                Value<double> ptuPagada = const Value.absent(),
                Value<double> perdidasFiscales = const Value.absent(),
                Value<double> pagosProvisionalesAnteriores =
                    const Value.absent(),
                Value<double> saldoFavorIvaAnterior = const Value.absent(),
                Value<TipoDeclaracion> tipoDeclaracion = const Value.absent(),
                Value<bool> copropiedad = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CapturasEspejoCompanion(
                anio: anio,
                mes: mes,
                ptuPagada: ptuPagada,
                perdidasFiscales: perdidasFiscales,
                pagosProvisionalesAnteriores: pagosProvisionalesAnteriores,
                saldoFavorIvaAnterior: saldoFavorIvaAnterior,
                tipoDeclaracion: tipoDeclaracion,
                copropiedad: copropiedad,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int anio,
                required int mes,
                Value<double> ptuPagada = const Value.absent(),
                Value<double> perdidasFiscales = const Value.absent(),
                Value<double> pagosProvisionalesAnteriores =
                    const Value.absent(),
                Value<double> saldoFavorIvaAnterior = const Value.absent(),
                Value<TipoDeclaracion> tipoDeclaracion = const Value.absent(),
                Value<bool> copropiedad = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CapturasEspejoCompanion.insert(
                anio: anio,
                mes: mes,
                ptuPagada: ptuPagada,
                perdidasFiscales: perdidasFiscales,
                pagosProvisionalesAnteriores: pagosProvisionalesAnteriores,
                saldoFavorIvaAnterior: saldoFavorIvaAnterior,
                tipoDeclaracion: tipoDeclaracion,
                copropiedad: copropiedad,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CapturasEspejoTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CapturasEspejoTable,
      CapturasEspejoData,
      $$CapturasEspejoTableFilterComposer,
      $$CapturasEspejoTableOrderingComposer,
      $$CapturasEspejoTableAnnotationComposer,
      $$CapturasEspejoTableCreateCompanionBuilder,
      $$CapturasEspejoTableUpdateCompanionBuilder,
      (
        CapturasEspejoData,
        BaseReferences<_$AppDatabase, $CapturasEspejoTable, CapturasEspejoData>,
      ),
      CapturasEspejoData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ContribuyentesTableTableManager get contribuyentes =>
      $$ContribuyentesTableTableManager(_db, _db.contribuyentes);
  $$FacturasTableTableManager get facturas =>
      $$FacturasTableTableManager(_db, _db.facturas);
  $$InversionesTableTableManager get inversiones =>
      $$InversionesTableTableManager(_db, _db.inversiones);
  $$CapturasEspejoTableTableManager get capturasEspejo =>
      $$CapturasEspejoTableTableManager(_db, _db.capturasEspejo);
}
