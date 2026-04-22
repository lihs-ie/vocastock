// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'actor_handoff.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GActorHandoffStatusQueryData>
_$gActorHandoffStatusQueryDataSerializer =
    _$GActorHandoffStatusQueryDataSerializer();
Serializer<GActorHandoffStatusQueryData_actorHandoffStatus>
_$gActorHandoffStatusQueryDataActorHandoffStatusSerializer =
    _$GActorHandoffStatusQueryData_actorHandoffStatusSerializer();
Serializer<GLearningStateQueryData> _$gLearningStateQueryDataSerializer =
    _$GLearningStateQueryDataSerializer();
Serializer<GLearningStateQueryData_learningState>
_$gLearningStateQueryDataLearningStateSerializer =
    _$GLearningStateQueryData_learningStateSerializer();

class _$GActorHandoffStatusQueryDataSerializer
    implements StructuredSerializer<GActorHandoffStatusQueryData> {
  @override
  final Iterable<Type> types = const [
    GActorHandoffStatusQueryData,
    _$GActorHandoffStatusQueryData,
  ];
  @override
  final String wireName = 'GActorHandoffStatusQueryData';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GActorHandoffStatusQueryData object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(
        object.G__typename,
        specifiedType: const FullType(String),
      ),
      'actorHandoffStatus',
      serializers.serialize(
        object.actorHandoffStatus,
        specifiedType: const FullType(
          GActorHandoffStatusQueryData_actorHandoffStatus,
        ),
      ),
    ];

    return result;
  }

  @override
  GActorHandoffStatusQueryData deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GActorHandoffStatusQueryDataBuilder();

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
        case 'actorHandoffStatus':
          result.actorHandoffStatus.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(
                    GActorHandoffStatusQueryData_actorHandoffStatus,
                  ),
                )!
                as GActorHandoffStatusQueryData_actorHandoffStatus,
          );
          break;
      }
    }

    return result.build();
  }
}

class _$GActorHandoffStatusQueryData_actorHandoffStatusSerializer
    implements
        StructuredSerializer<GActorHandoffStatusQueryData_actorHandoffStatus> {
  @override
  final Iterable<Type> types = const [
    GActorHandoffStatusQueryData_actorHandoffStatus,
    _$GActorHandoffStatusQueryData_actorHandoffStatus,
  ];
  @override
  final String wireName = 'GActorHandoffStatusQueryData_actorHandoffStatus';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GActorHandoffStatusQueryData_actorHandoffStatus object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(
        object.G__typename,
        specifiedType: const FullType(String),
      ),
      'sessionState',
      serializers.serialize(
        object.sessionState,
        specifiedType: const FullType(_i2.GSessionStateCode),
      ),
    ];
    Object? value;
    value = object.actor;
    if (value != null) {
      result
        ..add('actor')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(String)),
        );
    }
    value = object.session;
    if (value != null) {
      result
        ..add('session')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(String)),
        );
    }
    value = object.authAccount;
    if (value != null) {
      result
        ..add('authAccount')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(String)),
        );
    }
    return result;
  }

  @override
  GActorHandoffStatusQueryData_actorHandoffStatus deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GActorHandoffStatusQueryData_actorHandoffStatusBuilder();

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
        case 'actor':
          result.actor =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String?;
          break;
        case 'session':
          result.session =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String?;
          break;
        case 'authAccount':
          result.authAccount =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String?;
          break;
        case 'sessionState':
          result.sessionState =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(_i2.GSessionStateCode),
                  )!
                  as _i2.GSessionStateCode;
          break;
      }
    }

    return result.build();
  }
}

class _$GLearningStateQueryDataSerializer
    implements StructuredSerializer<GLearningStateQueryData> {
  @override
  final Iterable<Type> types = const [
    GLearningStateQueryData,
    _$GLearningStateQueryData,
  ];
  @override
  final String wireName = 'GLearningStateQueryData';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GLearningStateQueryData object, {
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
    value = object.learningState;
    if (value != null) {
      result
        ..add('learningState')
        ..add(
          serializers.serialize(
            value,
            specifiedType: const FullType(
              GLearningStateQueryData_learningState,
            ),
          ),
        );
    }
    return result;
  }

  @override
  GLearningStateQueryData deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GLearningStateQueryDataBuilder();

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
        case 'learningState':
          result.learningState.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(
                    GLearningStateQueryData_learningState,
                  ),
                )!
                as GLearningStateQueryData_learningState,
          );
          break;
      }
    }

    return result.build();
  }
}

class _$GLearningStateQueryData_learningStateSerializer
    implements StructuredSerializer<GLearningStateQueryData_learningState> {
  @override
  final Iterable<Type> types = const [
    GLearningStateQueryData_learningState,
    _$GLearningStateQueryData_learningState,
  ];
  @override
  final String wireName = 'GLearningStateQueryData_learningState';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GLearningStateQueryData_learningState object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(
        object.G__typename,
        specifiedType: const FullType(String),
      ),
      'vocabularyExpression',
      serializers.serialize(
        object.vocabularyExpression,
        specifiedType: const FullType(String),
      ),
      'proficiency',
      serializers.serialize(
        object.proficiency,
        specifiedType: const FullType(_i2.GProficiencyLevel),
      ),
    ];

    return result;
  }

  @override
  GLearningStateQueryData_learningState deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GLearningStateQueryData_learningStateBuilder();

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
        case 'vocabularyExpression':
          result.vocabularyExpression =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'proficiency':
          result.proficiency =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(_i2.GProficiencyLevel),
                  )!
                  as _i2.GProficiencyLevel;
          break;
      }
    }

    return result.build();
  }
}

class _$GActorHandoffStatusQueryData extends GActorHandoffStatusQueryData {
  @override
  final String G__typename;
  @override
  final GActorHandoffStatusQueryData_actorHandoffStatus actorHandoffStatus;

  factory _$GActorHandoffStatusQueryData([
    void Function(GActorHandoffStatusQueryDataBuilder)? updates,
  ]) => (GActorHandoffStatusQueryDataBuilder()..update(updates))._build();

  _$GActorHandoffStatusQueryData._({
    required this.G__typename,
    required this.actorHandoffStatus,
  }) : super._();
  @override
  GActorHandoffStatusQueryData rebuild(
    void Function(GActorHandoffStatusQueryDataBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GActorHandoffStatusQueryDataBuilder toBuilder() =>
      GActorHandoffStatusQueryDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GActorHandoffStatusQueryData &&
        G__typename == other.G__typename &&
        actorHandoffStatus == other.actorHandoffStatus;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, actorHandoffStatus.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GActorHandoffStatusQueryData')
          ..add('G__typename', G__typename)
          ..add('actorHandoffStatus', actorHandoffStatus))
        .toString();
  }
}

class GActorHandoffStatusQueryDataBuilder
    implements
        Builder<
          GActorHandoffStatusQueryData,
          GActorHandoffStatusQueryDataBuilder
        > {
  _$GActorHandoffStatusQueryData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GActorHandoffStatusQueryData_actorHandoffStatusBuilder? _actorHandoffStatus;
  GActorHandoffStatusQueryData_actorHandoffStatusBuilder
  get actorHandoffStatus => _$this._actorHandoffStatus ??=
      GActorHandoffStatusQueryData_actorHandoffStatusBuilder();
  set actorHandoffStatus(
    GActorHandoffStatusQueryData_actorHandoffStatusBuilder? actorHandoffStatus,
  ) => _$this._actorHandoffStatus = actorHandoffStatus;

  GActorHandoffStatusQueryDataBuilder() {
    GActorHandoffStatusQueryData._initializeBuilder(this);
  }

  GActorHandoffStatusQueryDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _actorHandoffStatus = $v.actorHandoffStatus.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GActorHandoffStatusQueryData other) {
    _$v = other as _$GActorHandoffStatusQueryData;
  }

  @override
  void update(void Function(GActorHandoffStatusQueryDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GActorHandoffStatusQueryData build() => _build();

  _$GActorHandoffStatusQueryData _build() {
    _$GActorHandoffStatusQueryData _$result;
    try {
      _$result =
          _$v ??
          _$GActorHandoffStatusQueryData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GActorHandoffStatusQueryData',
              'G__typename',
            ),
            actorHandoffStatus: actorHandoffStatus.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'actorHandoffStatus';
        actorHandoffStatus.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GActorHandoffStatusQueryData',
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

class _$GActorHandoffStatusQueryData_actorHandoffStatus
    extends GActorHandoffStatusQueryData_actorHandoffStatus {
  @override
  final String G__typename;
  @override
  final String? actor;
  @override
  final String? session;
  @override
  final String? authAccount;
  @override
  final _i2.GSessionStateCode sessionState;

  factory _$GActorHandoffStatusQueryData_actorHandoffStatus([
    void Function(GActorHandoffStatusQueryData_actorHandoffStatusBuilder)?
    updates,
  ]) =>
      (GActorHandoffStatusQueryData_actorHandoffStatusBuilder()
            ..update(updates))
          ._build();

  _$GActorHandoffStatusQueryData_actorHandoffStatus._({
    required this.G__typename,
    this.actor,
    this.session,
    this.authAccount,
    required this.sessionState,
  }) : super._();
  @override
  GActorHandoffStatusQueryData_actorHandoffStatus rebuild(
    void Function(GActorHandoffStatusQueryData_actorHandoffStatusBuilder)
    updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GActorHandoffStatusQueryData_actorHandoffStatusBuilder toBuilder() =>
      GActorHandoffStatusQueryData_actorHandoffStatusBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GActorHandoffStatusQueryData_actorHandoffStatus &&
        G__typename == other.G__typename &&
        actor == other.actor &&
        session == other.session &&
        authAccount == other.authAccount &&
        sessionState == other.sessionState;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, actor.hashCode);
    _$hash = $jc(_$hash, session.hashCode);
    _$hash = $jc(_$hash, authAccount.hashCode);
    _$hash = $jc(_$hash, sessionState.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GActorHandoffStatusQueryData_actorHandoffStatus',
          )
          ..add('G__typename', G__typename)
          ..add('actor', actor)
          ..add('session', session)
          ..add('authAccount', authAccount)
          ..add('sessionState', sessionState))
        .toString();
  }
}

class GActorHandoffStatusQueryData_actorHandoffStatusBuilder
    implements
        Builder<
          GActorHandoffStatusQueryData_actorHandoffStatus,
          GActorHandoffStatusQueryData_actorHandoffStatusBuilder
        > {
  _$GActorHandoffStatusQueryData_actorHandoffStatus? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _actor;
  String? get actor => _$this._actor;
  set actor(String? actor) => _$this._actor = actor;

  String? _session;
  String? get session => _$this._session;
  set session(String? session) => _$this._session = session;

  String? _authAccount;
  String? get authAccount => _$this._authAccount;
  set authAccount(String? authAccount) => _$this._authAccount = authAccount;

  _i2.GSessionStateCode? _sessionState;
  _i2.GSessionStateCode? get sessionState => _$this._sessionState;
  set sessionState(_i2.GSessionStateCode? sessionState) =>
      _$this._sessionState = sessionState;

  GActorHandoffStatusQueryData_actorHandoffStatusBuilder() {
    GActorHandoffStatusQueryData_actorHandoffStatus._initializeBuilder(this);
  }

  GActorHandoffStatusQueryData_actorHandoffStatusBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _actor = $v.actor;
      _session = $v.session;
      _authAccount = $v.authAccount;
      _sessionState = $v.sessionState;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GActorHandoffStatusQueryData_actorHandoffStatus other) {
    _$v = other as _$GActorHandoffStatusQueryData_actorHandoffStatus;
  }

  @override
  void update(
    void Function(GActorHandoffStatusQueryData_actorHandoffStatusBuilder)?
    updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GActorHandoffStatusQueryData_actorHandoffStatus build() => _build();

  _$GActorHandoffStatusQueryData_actorHandoffStatus _build() {
    final _$result =
        _$v ??
        _$GActorHandoffStatusQueryData_actorHandoffStatus._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
            G__typename,
            r'GActorHandoffStatusQueryData_actorHandoffStatus',
            'G__typename',
          ),
          actor: actor,
          session: session,
          authAccount: authAccount,
          sessionState: BuiltValueNullFieldError.checkNotNull(
            sessionState,
            r'GActorHandoffStatusQueryData_actorHandoffStatus',
            'sessionState',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GLearningStateQueryData extends GLearningStateQueryData {
  @override
  final String G__typename;
  @override
  final GLearningStateQueryData_learningState? learningState;

  factory _$GLearningStateQueryData([
    void Function(GLearningStateQueryDataBuilder)? updates,
  ]) => (GLearningStateQueryDataBuilder()..update(updates))._build();

  _$GLearningStateQueryData._({required this.G__typename, this.learningState})
    : super._();
  @override
  GLearningStateQueryData rebuild(
    void Function(GLearningStateQueryDataBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GLearningStateQueryDataBuilder toBuilder() =>
      GLearningStateQueryDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GLearningStateQueryData &&
        G__typename == other.G__typename &&
        learningState == other.learningState;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, learningState.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GLearningStateQueryData')
          ..add('G__typename', G__typename)
          ..add('learningState', learningState))
        .toString();
  }
}

class GLearningStateQueryDataBuilder
    implements
        Builder<GLearningStateQueryData, GLearningStateQueryDataBuilder> {
  _$GLearningStateQueryData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GLearningStateQueryData_learningStateBuilder? _learningState;
  GLearningStateQueryData_learningStateBuilder get learningState =>
      _$this._learningState ??= GLearningStateQueryData_learningStateBuilder();
  set learningState(
    GLearningStateQueryData_learningStateBuilder? learningState,
  ) => _$this._learningState = learningState;

  GLearningStateQueryDataBuilder() {
    GLearningStateQueryData._initializeBuilder(this);
  }

  GLearningStateQueryDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _learningState = $v.learningState?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GLearningStateQueryData other) {
    _$v = other as _$GLearningStateQueryData;
  }

  @override
  void update(void Function(GLearningStateQueryDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GLearningStateQueryData build() => _build();

  _$GLearningStateQueryData _build() {
    _$GLearningStateQueryData _$result;
    try {
      _$result =
          _$v ??
          _$GLearningStateQueryData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GLearningStateQueryData',
              'G__typename',
            ),
            learningState: _learningState?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'learningState';
        _learningState?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GLearningStateQueryData',
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

class _$GLearningStateQueryData_learningState
    extends GLearningStateQueryData_learningState {
  @override
  final String G__typename;
  @override
  final String vocabularyExpression;
  @override
  final _i2.GProficiencyLevel proficiency;

  factory _$GLearningStateQueryData_learningState([
    void Function(GLearningStateQueryData_learningStateBuilder)? updates,
  ]) => (GLearningStateQueryData_learningStateBuilder()..update(updates))
      ._build();

  _$GLearningStateQueryData_learningState._({
    required this.G__typename,
    required this.vocabularyExpression,
    required this.proficiency,
  }) : super._();
  @override
  GLearningStateQueryData_learningState rebuild(
    void Function(GLearningStateQueryData_learningStateBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GLearningStateQueryData_learningStateBuilder toBuilder() =>
      GLearningStateQueryData_learningStateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GLearningStateQueryData_learningState &&
        G__typename == other.G__typename &&
        vocabularyExpression == other.vocabularyExpression &&
        proficiency == other.proficiency;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, vocabularyExpression.hashCode);
    _$hash = $jc(_$hash, proficiency.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GLearningStateQueryData_learningState',
          )
          ..add('G__typename', G__typename)
          ..add('vocabularyExpression', vocabularyExpression)
          ..add('proficiency', proficiency))
        .toString();
  }
}

class GLearningStateQueryData_learningStateBuilder
    implements
        Builder<
          GLearningStateQueryData_learningState,
          GLearningStateQueryData_learningStateBuilder
        > {
  _$GLearningStateQueryData_learningState? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _vocabularyExpression;
  String? get vocabularyExpression => _$this._vocabularyExpression;
  set vocabularyExpression(String? vocabularyExpression) =>
      _$this._vocabularyExpression = vocabularyExpression;

  _i2.GProficiencyLevel? _proficiency;
  _i2.GProficiencyLevel? get proficiency => _$this._proficiency;
  set proficiency(_i2.GProficiencyLevel? proficiency) =>
      _$this._proficiency = proficiency;

  GLearningStateQueryData_learningStateBuilder() {
    GLearningStateQueryData_learningState._initializeBuilder(this);
  }

  GLearningStateQueryData_learningStateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _vocabularyExpression = $v.vocabularyExpression;
      _proficiency = $v.proficiency;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GLearningStateQueryData_learningState other) {
    _$v = other as _$GLearningStateQueryData_learningState;
  }

  @override
  void update(
    void Function(GLearningStateQueryData_learningStateBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GLearningStateQueryData_learningState build() => _build();

  _$GLearningStateQueryData_learningState _build() {
    final _$result =
        _$v ??
        _$GLearningStateQueryData_learningState._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
            G__typename,
            r'GLearningStateQueryData_learningState',
            'G__typename',
          ),
          vocabularyExpression: BuiltValueNullFieldError.checkNotNull(
            vocabularyExpression,
            r'GLearningStateQueryData_learningState',
            'vocabularyExpression',
          ),
          proficiency: BuiltValueNullFieldError.checkNotNull(
            proficiency,
            r'GLearningStateQueryData_learningState',
            'proficiency',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
