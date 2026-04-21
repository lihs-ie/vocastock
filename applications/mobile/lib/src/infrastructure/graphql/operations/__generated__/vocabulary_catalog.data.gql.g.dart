// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocabulary_catalog.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GVocabularyCatalogQueryData>
_$gVocabularyCatalogQueryDataSerializer =
    _$GVocabularyCatalogQueryDataSerializer();
Serializer<GVocabularyCatalogQueryData_vocabularyCatalog>
_$gVocabularyCatalogQueryDataVocabularyCatalogSerializer =
    _$GVocabularyCatalogQueryData_vocabularyCatalogSerializer();
Serializer<GVocabularyCatalogQueryData_vocabularyCatalog_entries>
_$gVocabularyCatalogQueryDataVocabularyCatalogEntriesSerializer =
    _$GVocabularyCatalogQueryData_vocabularyCatalog_entriesSerializer();
Serializer<GVocabularyExpressionDetailQueryData>
_$gVocabularyExpressionDetailQueryDataSerializer =
    _$GVocabularyExpressionDetailQueryDataSerializer();
Serializer<GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail>
_$gVocabularyExpressionDetailQueryDataVocabularyExpressionDetailSerializer =
    _$GVocabularyExpressionDetailQueryData_vocabularyExpressionDetailSerializer();

class _$GVocabularyCatalogQueryDataSerializer
    implements StructuredSerializer<GVocabularyCatalogQueryData> {
  @override
  final Iterable<Type> types = const [
    GVocabularyCatalogQueryData,
    _$GVocabularyCatalogQueryData,
  ];
  @override
  final String wireName = 'GVocabularyCatalogQueryData';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GVocabularyCatalogQueryData object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(
        object.G__typename,
        specifiedType: const FullType(String),
      ),
      'vocabularyCatalog',
      serializers.serialize(
        object.vocabularyCatalog,
        specifiedType: const FullType(
          GVocabularyCatalogQueryData_vocabularyCatalog,
        ),
      ),
    ];

    return result;
  }

  @override
  GVocabularyCatalogQueryData deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GVocabularyCatalogQueryDataBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'vocabularyCatalog':
          result.vocabularyCatalog.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(
                    GVocabularyCatalogQueryData_vocabularyCatalog,
                  ),
                )!
                as GVocabularyCatalogQueryData_vocabularyCatalog,
          );
          break;
      }
    }

    return result.build();
  }
}

class _$GVocabularyCatalogQueryData_vocabularyCatalogSerializer
    implements
        StructuredSerializer<GVocabularyCatalogQueryData_vocabularyCatalog> {
  @override
  final Iterable<Type> types = const [
    GVocabularyCatalogQueryData_vocabularyCatalog,
    _$GVocabularyCatalogQueryData_vocabularyCatalog,
  ];
  @override
  final String wireName = 'GVocabularyCatalogQueryData_vocabularyCatalog';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GVocabularyCatalogQueryData_vocabularyCatalog object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(
        object.G__typename,
        specifiedType: const FullType(String),
      ),
      'entries',
      serializers.serialize(
        object.entries,
        specifiedType: const FullType(BuiltList, const [
          const FullType(GVocabularyCatalogQueryData_vocabularyCatalog_entries),
        ]),
      ),
    ];

    return result;
  }

  @override
  GVocabularyCatalogQueryData_vocabularyCatalog deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GVocabularyCatalogQueryData_vocabularyCatalogBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'entries':
          result.entries.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(BuiltList, const [
                    const FullType(
                      GVocabularyCatalogQueryData_vocabularyCatalog_entries,
                    ),
                  ]),
                )!
                as BuiltList<Object?>,
          );
          break;
      }
    }

    return result.build();
  }
}

class _$GVocabularyCatalogQueryData_vocabularyCatalog_entriesSerializer
    implements
        StructuredSerializer<
          GVocabularyCatalogQueryData_vocabularyCatalog_entries
        > {
  @override
  final Iterable<Type> types = const [
    GVocabularyCatalogQueryData_vocabularyCatalog_entries,
    _$GVocabularyCatalogQueryData_vocabularyCatalog_entries,
  ];
  @override
  final String wireName =
      'GVocabularyCatalogQueryData_vocabularyCatalog_entries';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GVocabularyCatalogQueryData_vocabularyCatalog_entries object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(
        object.G__typename,
        specifiedType: const FullType(String),
      ),
      'identifier',
      serializers.serialize(
        object.identifier,
        specifiedType: const FullType(String),
      ),
      'text',
      serializers.serialize(object.text, specifiedType: const FullType(String)),
      'registrationStatus',
      serializers.serialize(
        object.registrationStatus,
        specifiedType: const FullType(_i2.GRegistrationStatus),
      ),
      'explanationStatus',
      serializers.serialize(
        object.explanationStatus,
        specifiedType: const FullType(_i2.GExplanationGenerationStatus),
      ),
      'imageStatus',
      serializers.serialize(
        object.imageStatus,
        specifiedType: const FullType(_i2.GImageGenerationStatus),
      ),
      'registeredAt',
      serializers.serialize(
        object.registeredAt,
        specifiedType: const FullType(_i2.GDateTime),
      ),
    ];
    Object? value;
    value = object.currentExplanation;
    if (value != null) {
      result
        ..add('currentExplanation')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(String)),
        );
    }
    value = object.currentImage;
    if (value != null) {
      result
        ..add('currentImage')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(String)),
        );
    }
    return result;
  }

  @override
  GVocabularyCatalogQueryData_vocabularyCatalog_entries deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GVocabularyCatalogQueryData_vocabularyCatalog_entriesBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'identifier':
          result.identifier =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'text':
          result.text =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'registrationStatus':
          result.registrationStatus =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(_i2.GRegistrationStatus),
                  )!
                  as _i2.GRegistrationStatus;
          break;
        case 'explanationStatus':
          result.explanationStatus =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(
                      _i2.GExplanationGenerationStatus,
                    ),
                  )!
                  as _i2.GExplanationGenerationStatus;
          break;
        case 'imageStatus':
          result.imageStatus =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(_i2.GImageGenerationStatus),
                  )!
                  as _i2.GImageGenerationStatus;
          break;
        case 'currentExplanation':
          result.currentExplanation =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String?;
          break;
        case 'currentImage':
          result.currentImage =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String?;
          break;
        case 'registeredAt':
          result.registeredAt.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(_i2.GDateTime),
                )!
                as _i2.GDateTime,
          );
          break;
      }
    }

    return result.build();
  }
}

class _$GVocabularyExpressionDetailQueryDataSerializer
    implements StructuredSerializer<GVocabularyExpressionDetailQueryData> {
  @override
  final Iterable<Type> types = const [
    GVocabularyExpressionDetailQueryData,
    _$GVocabularyExpressionDetailQueryData,
  ];
  @override
  final String wireName = 'GVocabularyExpressionDetailQueryData';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GVocabularyExpressionDetailQueryData object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(
        object.G__typename,
        specifiedType: const FullType(String),
      ),
    ];
    Object? value;
    value = object.vocabularyExpressionDetail;
    if (value != null) {
      result
        ..add('vocabularyExpressionDetail')
        ..add(
          serializers.serialize(
            value,
            specifiedType: const FullType(
              GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail,
            ),
          ),
        );
    }
    return result;
  }

  @override
  GVocabularyExpressionDetailQueryData deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GVocabularyExpressionDetailQueryDataBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'vocabularyExpressionDetail':
          result.vocabularyExpressionDetail.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(
                    GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail,
                  ),
                )!
                as GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail,
          );
          break;
      }
    }

    return result.build();
  }
}

class _$GVocabularyExpressionDetailQueryData_vocabularyExpressionDetailSerializer
    implements
        StructuredSerializer<
          GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail
        > {
  @override
  final Iterable<Type> types = const [
    GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail,
    _$GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail,
  ];
  @override
  final String wireName =
      'GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(
        object.G__typename,
        specifiedType: const FullType(String),
      ),
      'identifier',
      serializers.serialize(
        object.identifier,
        specifiedType: const FullType(String),
      ),
      'text',
      serializers.serialize(object.text, specifiedType: const FullType(String)),
      'registrationStatus',
      serializers.serialize(
        object.registrationStatus,
        specifiedType: const FullType(_i2.GRegistrationStatus),
      ),
      'explanationStatus',
      serializers.serialize(
        object.explanationStatus,
        specifiedType: const FullType(_i2.GExplanationGenerationStatus),
      ),
      'imageStatus',
      serializers.serialize(
        object.imageStatus,
        specifiedType: const FullType(_i2.GImageGenerationStatus),
      ),
      'registeredAt',
      serializers.serialize(
        object.registeredAt,
        specifiedType: const FullType(_i2.GDateTime),
      ),
    ];
    Object? value;
    value = object.currentExplanation;
    if (value != null) {
      result
        ..add('currentExplanation')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(String)),
        );
    }
    value = object.currentImage;
    if (value != null) {
      result
        ..add('currentImage')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(String)),
        );
    }
    return result;
  }

  @override
  GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GVocabularyExpressionDetailQueryData_vocabularyExpressionDetailBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'identifier':
          result.identifier =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'text':
          result.text =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'registrationStatus':
          result.registrationStatus =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(_i2.GRegistrationStatus),
                  )!
                  as _i2.GRegistrationStatus;
          break;
        case 'explanationStatus':
          result.explanationStatus =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(
                      _i2.GExplanationGenerationStatus,
                    ),
                  )!
                  as _i2.GExplanationGenerationStatus;
          break;
        case 'imageStatus':
          result.imageStatus =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(_i2.GImageGenerationStatus),
                  )!
                  as _i2.GImageGenerationStatus;
          break;
        case 'currentExplanation':
          result.currentExplanation =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String?;
          break;
        case 'currentImage':
          result.currentImage =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String?;
          break;
        case 'registeredAt':
          result.registeredAt.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(_i2.GDateTime),
                )!
                as _i2.GDateTime,
          );
          break;
      }
    }

    return result.build();
  }
}

class _$GVocabularyCatalogQueryData extends GVocabularyCatalogQueryData {
  @override
  final String G__typename;
  @override
  final GVocabularyCatalogQueryData_vocabularyCatalog vocabularyCatalog;

  factory _$GVocabularyCatalogQueryData([
    void Function(GVocabularyCatalogQueryDataBuilder)? updates,
  ]) => (GVocabularyCatalogQueryDataBuilder()..update(updates))._build();

  _$GVocabularyCatalogQueryData._({
    required this.G__typename,
    required this.vocabularyCatalog,
  }) : super._();
  @override
  GVocabularyCatalogQueryData rebuild(
    void Function(GVocabularyCatalogQueryDataBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GVocabularyCatalogQueryDataBuilder toBuilder() =>
      GVocabularyCatalogQueryDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GVocabularyCatalogQueryData &&
        G__typename == other.G__typename &&
        vocabularyCatalog == other.vocabularyCatalog;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, vocabularyCatalog.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GVocabularyCatalogQueryData')
          ..add('G__typename', G__typename)
          ..add('vocabularyCatalog', vocabularyCatalog))
        .toString();
  }
}

class GVocabularyCatalogQueryDataBuilder
    implements
        Builder<
          GVocabularyCatalogQueryData,
          GVocabularyCatalogQueryDataBuilder
        > {
  _$GVocabularyCatalogQueryData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GVocabularyCatalogQueryData_vocabularyCatalogBuilder? _vocabularyCatalog;
  GVocabularyCatalogQueryData_vocabularyCatalogBuilder get vocabularyCatalog =>
      _$this._vocabularyCatalog ??=
          GVocabularyCatalogQueryData_vocabularyCatalogBuilder();
  set vocabularyCatalog(
    GVocabularyCatalogQueryData_vocabularyCatalogBuilder? vocabularyCatalog,
  ) => _$this._vocabularyCatalog = vocabularyCatalog;

  GVocabularyCatalogQueryDataBuilder() {
    GVocabularyCatalogQueryData._initializeBuilder(this);
  }

  GVocabularyCatalogQueryDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _vocabularyCatalog = $v.vocabularyCatalog.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GVocabularyCatalogQueryData other) {
    _$v = other as _$GVocabularyCatalogQueryData;
  }

  @override
  void update(void Function(GVocabularyCatalogQueryDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GVocabularyCatalogQueryData build() => _build();

  _$GVocabularyCatalogQueryData _build() {
    _$GVocabularyCatalogQueryData _$result;
    try {
      _$result =
          _$v ??
          _$GVocabularyCatalogQueryData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GVocabularyCatalogQueryData',
              'G__typename',
            ),
            vocabularyCatalog: vocabularyCatalog.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'vocabularyCatalog';
        vocabularyCatalog.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GVocabularyCatalogQueryData',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GVocabularyCatalogQueryData_vocabularyCatalog
    extends GVocabularyCatalogQueryData_vocabularyCatalog {
  @override
  final String G__typename;
  @override
  final BuiltList<GVocabularyCatalogQueryData_vocabularyCatalog_entries>
  entries;

  factory _$GVocabularyCatalogQueryData_vocabularyCatalog([
    void Function(GVocabularyCatalogQueryData_vocabularyCatalogBuilder)?
    updates,
  ]) =>
      (GVocabularyCatalogQueryData_vocabularyCatalogBuilder()..update(updates))
          ._build();

  _$GVocabularyCatalogQueryData_vocabularyCatalog._({
    required this.G__typename,
    required this.entries,
  }) : super._();
  @override
  GVocabularyCatalogQueryData_vocabularyCatalog rebuild(
    void Function(GVocabularyCatalogQueryData_vocabularyCatalogBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GVocabularyCatalogQueryData_vocabularyCatalogBuilder toBuilder() =>
      GVocabularyCatalogQueryData_vocabularyCatalogBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GVocabularyCatalogQueryData_vocabularyCatalog &&
        G__typename == other.G__typename &&
        entries == other.entries;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, entries.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GVocabularyCatalogQueryData_vocabularyCatalog',
          )
          ..add('G__typename', G__typename)
          ..add('entries', entries))
        .toString();
  }
}

class GVocabularyCatalogQueryData_vocabularyCatalogBuilder
    implements
        Builder<
          GVocabularyCatalogQueryData_vocabularyCatalog,
          GVocabularyCatalogQueryData_vocabularyCatalogBuilder
        > {
  _$GVocabularyCatalogQueryData_vocabularyCatalog? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  ListBuilder<GVocabularyCatalogQueryData_vocabularyCatalog_entries>? _entries;
  ListBuilder<GVocabularyCatalogQueryData_vocabularyCatalog_entries>
  get entries => _$this._entries ??=
      ListBuilder<GVocabularyCatalogQueryData_vocabularyCatalog_entries>();
  set entries(
    ListBuilder<GVocabularyCatalogQueryData_vocabularyCatalog_entries>? entries,
  ) => _$this._entries = entries;

  GVocabularyCatalogQueryData_vocabularyCatalogBuilder() {
    GVocabularyCatalogQueryData_vocabularyCatalog._initializeBuilder(this);
  }

  GVocabularyCatalogQueryData_vocabularyCatalogBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _entries = $v.entries.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GVocabularyCatalogQueryData_vocabularyCatalog other) {
    _$v = other as _$GVocabularyCatalogQueryData_vocabularyCatalog;
  }

  @override
  void update(
    void Function(GVocabularyCatalogQueryData_vocabularyCatalogBuilder)?
    updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GVocabularyCatalogQueryData_vocabularyCatalog build() => _build();

  _$GVocabularyCatalogQueryData_vocabularyCatalog _build() {
    _$GVocabularyCatalogQueryData_vocabularyCatalog _$result;
    try {
      _$result =
          _$v ??
          _$GVocabularyCatalogQueryData_vocabularyCatalog._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GVocabularyCatalogQueryData_vocabularyCatalog',
              'G__typename',
            ),
            entries: entries.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'entries';
        entries.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GVocabularyCatalogQueryData_vocabularyCatalog',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GVocabularyCatalogQueryData_vocabularyCatalog_entries
    extends GVocabularyCatalogQueryData_vocabularyCatalog_entries {
  @override
  final String G__typename;
  @override
  final String identifier;
  @override
  final String text;
  @override
  final _i2.GRegistrationStatus registrationStatus;
  @override
  final _i2.GExplanationGenerationStatus explanationStatus;
  @override
  final _i2.GImageGenerationStatus imageStatus;
  @override
  final String? currentExplanation;
  @override
  final String? currentImage;
  @override
  final _i2.GDateTime registeredAt;

  factory _$GVocabularyCatalogQueryData_vocabularyCatalog_entries([
    void Function(GVocabularyCatalogQueryData_vocabularyCatalog_entriesBuilder)?
    updates,
  ]) =>
      (GVocabularyCatalogQueryData_vocabularyCatalog_entriesBuilder()
            ..update(updates))
          ._build();

  _$GVocabularyCatalogQueryData_vocabularyCatalog_entries._({
    required this.G__typename,
    required this.identifier,
    required this.text,
    required this.registrationStatus,
    required this.explanationStatus,
    required this.imageStatus,
    this.currentExplanation,
    this.currentImage,
    required this.registeredAt,
  }) : super._();
  @override
  GVocabularyCatalogQueryData_vocabularyCatalog_entries rebuild(
    void Function(GVocabularyCatalogQueryData_vocabularyCatalog_entriesBuilder)
    updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GVocabularyCatalogQueryData_vocabularyCatalog_entriesBuilder toBuilder() =>
      GVocabularyCatalogQueryData_vocabularyCatalog_entriesBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GVocabularyCatalogQueryData_vocabularyCatalog_entries &&
        G__typename == other.G__typename &&
        identifier == other.identifier &&
        text == other.text &&
        registrationStatus == other.registrationStatus &&
        explanationStatus == other.explanationStatus &&
        imageStatus == other.imageStatus &&
        currentExplanation == other.currentExplanation &&
        currentImage == other.currentImage &&
        registeredAt == other.registeredAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, identifier.hashCode);
    _$hash = $jc(_$hash, text.hashCode);
    _$hash = $jc(_$hash, registrationStatus.hashCode);
    _$hash = $jc(_$hash, explanationStatus.hashCode);
    _$hash = $jc(_$hash, imageStatus.hashCode);
    _$hash = $jc(_$hash, currentExplanation.hashCode);
    _$hash = $jc(_$hash, currentImage.hashCode);
    _$hash = $jc(_$hash, registeredAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GVocabularyCatalogQueryData_vocabularyCatalog_entries',
          )
          ..add('G__typename', G__typename)
          ..add('identifier', identifier)
          ..add('text', text)
          ..add('registrationStatus', registrationStatus)
          ..add('explanationStatus', explanationStatus)
          ..add('imageStatus', imageStatus)
          ..add('currentExplanation', currentExplanation)
          ..add('currentImage', currentImage)
          ..add('registeredAt', registeredAt))
        .toString();
  }
}

class GVocabularyCatalogQueryData_vocabularyCatalog_entriesBuilder
    implements
        Builder<
          GVocabularyCatalogQueryData_vocabularyCatalog_entries,
          GVocabularyCatalogQueryData_vocabularyCatalog_entriesBuilder
        > {
  _$GVocabularyCatalogQueryData_vocabularyCatalog_entries? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _identifier;
  String? get identifier => _$this._identifier;
  set identifier(String? identifier) => _$this._identifier = identifier;

  String? _text;
  String? get text => _$this._text;
  set text(String? text) => _$this._text = text;

  _i2.GRegistrationStatus? _registrationStatus;
  _i2.GRegistrationStatus? get registrationStatus => _$this._registrationStatus;
  set registrationStatus(_i2.GRegistrationStatus? registrationStatus) =>
      _$this._registrationStatus = registrationStatus;

  _i2.GExplanationGenerationStatus? _explanationStatus;
  _i2.GExplanationGenerationStatus? get explanationStatus =>
      _$this._explanationStatus;
  set explanationStatus(_i2.GExplanationGenerationStatus? explanationStatus) =>
      _$this._explanationStatus = explanationStatus;

  _i2.GImageGenerationStatus? _imageStatus;
  _i2.GImageGenerationStatus? get imageStatus => _$this._imageStatus;
  set imageStatus(_i2.GImageGenerationStatus? imageStatus) =>
      _$this._imageStatus = imageStatus;

  String? _currentExplanation;
  String? get currentExplanation => _$this._currentExplanation;
  set currentExplanation(String? currentExplanation) =>
      _$this._currentExplanation = currentExplanation;

  String? _currentImage;
  String? get currentImage => _$this._currentImage;
  set currentImage(String? currentImage) => _$this._currentImage = currentImage;

  _i2.GDateTimeBuilder? _registeredAt;
  _i2.GDateTimeBuilder get registeredAt =>
      _$this._registeredAt ??= _i2.GDateTimeBuilder();
  set registeredAt(_i2.GDateTimeBuilder? registeredAt) =>
      _$this._registeredAt = registeredAt;

  GVocabularyCatalogQueryData_vocabularyCatalog_entriesBuilder() {
    GVocabularyCatalogQueryData_vocabularyCatalog_entries._initializeBuilder(
      this,
    );
  }

  GVocabularyCatalogQueryData_vocabularyCatalog_entriesBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _identifier = $v.identifier;
      _text = $v.text;
      _registrationStatus = $v.registrationStatus;
      _explanationStatus = $v.explanationStatus;
      _imageStatus = $v.imageStatus;
      _currentExplanation = $v.currentExplanation;
      _currentImage = $v.currentImage;
      _registeredAt = $v.registeredAt.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GVocabularyCatalogQueryData_vocabularyCatalog_entries other) {
    _$v = other as _$GVocabularyCatalogQueryData_vocabularyCatalog_entries;
  }

  @override
  void update(
    void Function(GVocabularyCatalogQueryData_vocabularyCatalog_entriesBuilder)?
    updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GVocabularyCatalogQueryData_vocabularyCatalog_entries build() => _build();

  _$GVocabularyCatalogQueryData_vocabularyCatalog_entries _build() {
    _$GVocabularyCatalogQueryData_vocabularyCatalog_entries _$result;
    try {
      _$result =
          _$v ??
          _$GVocabularyCatalogQueryData_vocabularyCatalog_entries._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GVocabularyCatalogQueryData_vocabularyCatalog_entries',
              'G__typename',
            ),
            identifier: BuiltValueNullFieldError.checkNotNull(
              identifier,
              r'GVocabularyCatalogQueryData_vocabularyCatalog_entries',
              'identifier',
            ),
            text: BuiltValueNullFieldError.checkNotNull(
              text,
              r'GVocabularyCatalogQueryData_vocabularyCatalog_entries',
              'text',
            ),
            registrationStatus: BuiltValueNullFieldError.checkNotNull(
              registrationStatus,
              r'GVocabularyCatalogQueryData_vocabularyCatalog_entries',
              'registrationStatus',
            ),
            explanationStatus: BuiltValueNullFieldError.checkNotNull(
              explanationStatus,
              r'GVocabularyCatalogQueryData_vocabularyCatalog_entries',
              'explanationStatus',
            ),
            imageStatus: BuiltValueNullFieldError.checkNotNull(
              imageStatus,
              r'GVocabularyCatalogQueryData_vocabularyCatalog_entries',
              'imageStatus',
            ),
            currentExplanation: currentExplanation,
            currentImage: currentImage,
            registeredAt: registeredAt.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'registeredAt';
        registeredAt.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GVocabularyCatalogQueryData_vocabularyCatalog_entries',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GVocabularyExpressionDetailQueryData
    extends GVocabularyExpressionDetailQueryData {
  @override
  final String G__typename;
  @override
  final GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail?
  vocabularyExpressionDetail;

  factory _$GVocabularyExpressionDetailQueryData([
    void Function(GVocabularyExpressionDetailQueryDataBuilder)? updates,
  ]) =>
      (GVocabularyExpressionDetailQueryDataBuilder()..update(updates))._build();

  _$GVocabularyExpressionDetailQueryData._({
    required this.G__typename,
    this.vocabularyExpressionDetail,
  }) : super._();
  @override
  GVocabularyExpressionDetailQueryData rebuild(
    void Function(GVocabularyExpressionDetailQueryDataBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GVocabularyExpressionDetailQueryDataBuilder toBuilder() =>
      GVocabularyExpressionDetailQueryDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GVocabularyExpressionDetailQueryData &&
        G__typename == other.G__typename &&
        vocabularyExpressionDetail == other.vocabularyExpressionDetail;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, vocabularyExpressionDetail.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GVocabularyExpressionDetailQueryData')
          ..add('G__typename', G__typename)
          ..add('vocabularyExpressionDetail', vocabularyExpressionDetail))
        .toString();
  }
}

class GVocabularyExpressionDetailQueryDataBuilder
    implements
        Builder<
          GVocabularyExpressionDetailQueryData,
          GVocabularyExpressionDetailQueryDataBuilder
        > {
  _$GVocabularyExpressionDetailQueryData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GVocabularyExpressionDetailQueryData_vocabularyExpressionDetailBuilder?
  _vocabularyExpressionDetail;
  GVocabularyExpressionDetailQueryData_vocabularyExpressionDetailBuilder
  get vocabularyExpressionDetail => _$this._vocabularyExpressionDetail ??=
      GVocabularyExpressionDetailQueryData_vocabularyExpressionDetailBuilder();
  set vocabularyExpressionDetail(
    GVocabularyExpressionDetailQueryData_vocabularyExpressionDetailBuilder?
    vocabularyExpressionDetail,
  ) => _$this._vocabularyExpressionDetail = vocabularyExpressionDetail;

  GVocabularyExpressionDetailQueryDataBuilder() {
    GVocabularyExpressionDetailQueryData._initializeBuilder(this);
  }

  GVocabularyExpressionDetailQueryDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _vocabularyExpressionDetail = $v.vocabularyExpressionDetail?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GVocabularyExpressionDetailQueryData other) {
    _$v = other as _$GVocabularyExpressionDetailQueryData;
  }

  @override
  void update(
    void Function(GVocabularyExpressionDetailQueryDataBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GVocabularyExpressionDetailQueryData build() => _build();

  _$GVocabularyExpressionDetailQueryData _build() {
    _$GVocabularyExpressionDetailQueryData _$result;
    try {
      _$result =
          _$v ??
          _$GVocabularyExpressionDetailQueryData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GVocabularyExpressionDetailQueryData',
              'G__typename',
            ),
            vocabularyExpressionDetail: _vocabularyExpressionDetail?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'vocabularyExpressionDetail';
        _vocabularyExpressionDetail?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GVocabularyExpressionDetailQueryData',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail
    extends GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail {
  @override
  final String G__typename;
  @override
  final String identifier;
  @override
  final String text;
  @override
  final _i2.GRegistrationStatus registrationStatus;
  @override
  final _i2.GExplanationGenerationStatus explanationStatus;
  @override
  final _i2.GImageGenerationStatus imageStatus;
  @override
  final String? currentExplanation;
  @override
  final String? currentImage;
  @override
  final _i2.GDateTime registeredAt;

  factory _$GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail([
    void Function(
      GVocabularyExpressionDetailQueryData_vocabularyExpressionDetailBuilder,
    )?
    updates,
  ]) =>
      (GVocabularyExpressionDetailQueryData_vocabularyExpressionDetailBuilder()
            ..update(updates))
          ._build();

  _$GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail._({
    required this.G__typename,
    required this.identifier,
    required this.text,
    required this.registrationStatus,
    required this.explanationStatus,
    required this.imageStatus,
    this.currentExplanation,
    this.currentImage,
    required this.registeredAt,
  }) : super._();
  @override
  GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail rebuild(
    void Function(
      GVocabularyExpressionDetailQueryData_vocabularyExpressionDetailBuilder,
    )
    updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GVocabularyExpressionDetailQueryData_vocabularyExpressionDetailBuilder
  toBuilder() =>
      GVocabularyExpressionDetailQueryData_vocabularyExpressionDetailBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail &&
        G__typename == other.G__typename &&
        identifier == other.identifier &&
        text == other.text &&
        registrationStatus == other.registrationStatus &&
        explanationStatus == other.explanationStatus &&
        imageStatus == other.imageStatus &&
        currentExplanation == other.currentExplanation &&
        currentImage == other.currentImage &&
        registeredAt == other.registeredAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, identifier.hashCode);
    _$hash = $jc(_$hash, text.hashCode);
    _$hash = $jc(_$hash, registrationStatus.hashCode);
    _$hash = $jc(_$hash, explanationStatus.hashCode);
    _$hash = $jc(_$hash, imageStatus.hashCode);
    _$hash = $jc(_$hash, currentExplanation.hashCode);
    _$hash = $jc(_$hash, currentImage.hashCode);
    _$hash = $jc(_$hash, registeredAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail',
          )
          ..add('G__typename', G__typename)
          ..add('identifier', identifier)
          ..add('text', text)
          ..add('registrationStatus', registrationStatus)
          ..add('explanationStatus', explanationStatus)
          ..add('imageStatus', imageStatus)
          ..add('currentExplanation', currentExplanation)
          ..add('currentImage', currentImage)
          ..add('registeredAt', registeredAt))
        .toString();
  }
}

class GVocabularyExpressionDetailQueryData_vocabularyExpressionDetailBuilder
    implements
        Builder<
          GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail,
          GVocabularyExpressionDetailQueryData_vocabularyExpressionDetailBuilder
        > {
  _$GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _identifier;
  String? get identifier => _$this._identifier;
  set identifier(String? identifier) => _$this._identifier = identifier;

  String? _text;
  String? get text => _$this._text;
  set text(String? text) => _$this._text = text;

  _i2.GRegistrationStatus? _registrationStatus;
  _i2.GRegistrationStatus? get registrationStatus => _$this._registrationStatus;
  set registrationStatus(_i2.GRegistrationStatus? registrationStatus) =>
      _$this._registrationStatus = registrationStatus;

  _i2.GExplanationGenerationStatus? _explanationStatus;
  _i2.GExplanationGenerationStatus? get explanationStatus =>
      _$this._explanationStatus;
  set explanationStatus(_i2.GExplanationGenerationStatus? explanationStatus) =>
      _$this._explanationStatus = explanationStatus;

  _i2.GImageGenerationStatus? _imageStatus;
  _i2.GImageGenerationStatus? get imageStatus => _$this._imageStatus;
  set imageStatus(_i2.GImageGenerationStatus? imageStatus) =>
      _$this._imageStatus = imageStatus;

  String? _currentExplanation;
  String? get currentExplanation => _$this._currentExplanation;
  set currentExplanation(String? currentExplanation) =>
      _$this._currentExplanation = currentExplanation;

  String? _currentImage;
  String? get currentImage => _$this._currentImage;
  set currentImage(String? currentImage) => _$this._currentImage = currentImage;

  _i2.GDateTimeBuilder? _registeredAt;
  _i2.GDateTimeBuilder get registeredAt =>
      _$this._registeredAt ??= _i2.GDateTimeBuilder();
  set registeredAt(_i2.GDateTimeBuilder? registeredAt) =>
      _$this._registeredAt = registeredAt;

  GVocabularyExpressionDetailQueryData_vocabularyExpressionDetailBuilder() {
    GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail._initializeBuilder(
      this,
    );
  }

  GVocabularyExpressionDetailQueryData_vocabularyExpressionDetailBuilder
  get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _identifier = $v.identifier;
      _text = $v.text;
      _registrationStatus = $v.registrationStatus;
      _explanationStatus = $v.explanationStatus;
      _imageStatus = $v.imageStatus;
      _currentExplanation = $v.currentExplanation;
      _currentImage = $v.currentImage;
      _registeredAt = $v.registeredAt.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
    GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail other,
  ) {
    _$v =
        other
            as _$GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail;
  }

  @override
  void update(
    void Function(
      GVocabularyExpressionDetailQueryData_vocabularyExpressionDetailBuilder,
    )?
    updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail build() =>
      _build();

  _$GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail _build() {
    _$GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail _$result;
    try {
      _$result =
          _$v ??
          _$GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail',
              'G__typename',
            ),
            identifier: BuiltValueNullFieldError.checkNotNull(
              identifier,
              r'GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail',
              'identifier',
            ),
            text: BuiltValueNullFieldError.checkNotNull(
              text,
              r'GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail',
              'text',
            ),
            registrationStatus: BuiltValueNullFieldError.checkNotNull(
              registrationStatus,
              r'GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail',
              'registrationStatus',
            ),
            explanationStatus: BuiltValueNullFieldError.checkNotNull(
              explanationStatus,
              r'GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail',
              'explanationStatus',
            ),
            imageStatus: BuiltValueNullFieldError.checkNotNull(
              imageStatus,
              r'GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail',
              'imageStatus',
            ),
            currentExplanation: currentExplanation,
            currentImage: currentImage,
            registeredAt: registeredAt.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'registeredAt';
        registeredAt.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GVocabularyExpressionDetailQueryData_vocabularyExpressionDetail',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
