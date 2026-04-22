// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commands.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GRegisterVocabularyExpressionMutationData>
_$gRegisterVocabularyExpressionMutationDataSerializer =
    _$GRegisterVocabularyExpressionMutationDataSerializer();
Serializer<
  GRegisterVocabularyExpressionMutationData_registerVocabularyExpression
>
_$gRegisterVocabularyExpressionMutationDataRegisterVocabularyExpressionSerializer =
    _$GRegisterVocabularyExpressionMutationData_registerVocabularyExpressionSerializer();
Serializer<
  GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message
>
_$gRegisterVocabularyExpressionMutationDataRegisterVocabularyExpressionMessageSerializer =
    _$GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_messageSerializer();
Serializer<GRequestExplanationGenerationMutationData>
_$gRequestExplanationGenerationMutationDataSerializer =
    _$GRequestExplanationGenerationMutationDataSerializer();
Serializer<
  GRequestExplanationGenerationMutationData_requestExplanationGeneration
>
_$gRequestExplanationGenerationMutationDataRequestExplanationGenerationSerializer =
    _$GRequestExplanationGenerationMutationData_requestExplanationGenerationSerializer();
Serializer<
  GRequestExplanationGenerationMutationData_requestExplanationGeneration_message
>
_$gRequestExplanationGenerationMutationDataRequestExplanationGenerationMessageSerializer =
    _$GRequestExplanationGenerationMutationData_requestExplanationGeneration_messageSerializer();
Serializer<GRequestImageGenerationMutationData>
_$gRequestImageGenerationMutationDataSerializer =
    _$GRequestImageGenerationMutationDataSerializer();
Serializer<GRequestImageGenerationMutationData_requestImageGeneration>
_$gRequestImageGenerationMutationDataRequestImageGenerationSerializer =
    _$GRequestImageGenerationMutationData_requestImageGenerationSerializer();
Serializer<GRequestImageGenerationMutationData_requestImageGeneration_message>
_$gRequestImageGenerationMutationDataRequestImageGenerationMessageSerializer =
    _$GRequestImageGenerationMutationData_requestImageGeneration_messageSerializer();
Serializer<GRetryGenerationMutationData>
_$gRetryGenerationMutationDataSerializer =
    _$GRetryGenerationMutationDataSerializer();
Serializer<GRetryGenerationMutationData_retryGeneration>
_$gRetryGenerationMutationDataRetryGenerationSerializer =
    _$GRetryGenerationMutationData_retryGenerationSerializer();
Serializer<GRetryGenerationMutationData_retryGeneration_message>
_$gRetryGenerationMutationDataRetryGenerationMessageSerializer =
    _$GRetryGenerationMutationData_retryGeneration_messageSerializer();

class _$GRegisterVocabularyExpressionMutationDataSerializer
    implements StructuredSerializer<GRegisterVocabularyExpressionMutationData> {
  @override
  final Iterable<Type> types = const [
    GRegisterVocabularyExpressionMutationData,
    _$GRegisterVocabularyExpressionMutationData,
  ];
  @override
  final String wireName = 'GRegisterVocabularyExpressionMutationData';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GRegisterVocabularyExpressionMutationData object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(
        object.G__typename,
        specifiedType: const FullType(String),
      ),
      'registerVocabularyExpression',
      serializers.serialize(
        object.registerVocabularyExpression,
        specifiedType: const FullType(
          GRegisterVocabularyExpressionMutationData_registerVocabularyExpression,
        ),
      ),
    ];

    return result;
  }

  @override
  GRegisterVocabularyExpressionMutationData deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GRegisterVocabularyExpressionMutationDataBuilder();

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
        case 'registerVocabularyExpression':
          result.registerVocabularyExpression.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(
                    GRegisterVocabularyExpressionMutationData_registerVocabularyExpression,
                  ),
                )!
                as GRegisterVocabularyExpressionMutationData_registerVocabularyExpression,
          );
          break;
      }
    }

    return result.build();
  }
}

class _$GRegisterVocabularyExpressionMutationData_registerVocabularyExpressionSerializer
    implements
        StructuredSerializer<
          GRegisterVocabularyExpressionMutationData_registerVocabularyExpression
        > {
  @override
  final Iterable<Type> types = const [
    GRegisterVocabularyExpressionMutationData_registerVocabularyExpression,
    _$GRegisterVocabularyExpressionMutationData_registerVocabularyExpression,
  ];
  @override
  final String wireName =
      'GRegisterVocabularyExpressionMutationData_registerVocabularyExpression';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GRegisterVocabularyExpressionMutationData_registerVocabularyExpression
    object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(
        object.G__typename,
        specifiedType: const FullType(String),
      ),
      'accepted',
      serializers.serialize(
        object.accepted,
        specifiedType: const FullType(bool),
      ),
      'message',
      serializers.serialize(
        object.message,
        specifiedType: const FullType(
          GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message,
        ),
      ),
    ];
    Object? value;
    value = object.outcome;
    if (value != null) {
      result
        ..add('outcome')
        ..add(
          serializers.serialize(
            value,
            specifiedType: const FullType(_i2.GAcceptanceOutcome),
          ),
        );
    }
    value = object.errorCategory;
    if (value != null) {
      result
        ..add('errorCategory')
        ..add(
          serializers.serialize(
            value,
            specifiedType: const FullType(_i2.GCommandErrorCategory),
          ),
        );
    }
    return result;
  }

  @override
  GRegisterVocabularyExpressionMutationData_registerVocabularyExpression
  deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GRegisterVocabularyExpressionMutationData_registerVocabularyExpressionBuilder();

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
        case 'accepted':
          result.accepted =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )!
                  as bool;
          break;
        case 'outcome':
          result.outcome =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(_i2.GAcceptanceOutcome),
                  )
                  as _i2.GAcceptanceOutcome?;
          break;
        case 'errorCategory':
          result.errorCategory =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(_i2.GCommandErrorCategory),
                  )
                  as _i2.GCommandErrorCategory?;
          break;
        case 'message':
          result.message.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(
                    GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message,
                  ),
                )!
                as GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message,
          );
          break;
      }
    }

    return result.build();
  }
}

class _$GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_messageSerializer
    implements
        StructuredSerializer<
          GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message
        > {
  @override
  final Iterable<Type> types = const [
    GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message,
    _$GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message,
  ];
  @override
  final String wireName =
      'GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message
    object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(
        object.G__typename,
        specifiedType: const FullType(String),
      ),
      'key',
      serializers.serialize(object.key, specifiedType: const FullType(String)),
      'text',
      serializers.serialize(object.text, specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message
  deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_messageBuilder();

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
        case 'key':
          result.key =
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
      }
    }

    return result.build();
  }
}

class _$GRequestExplanationGenerationMutationDataSerializer
    implements StructuredSerializer<GRequestExplanationGenerationMutationData> {
  @override
  final Iterable<Type> types = const [
    GRequestExplanationGenerationMutationData,
    _$GRequestExplanationGenerationMutationData,
  ];
  @override
  final String wireName = 'GRequestExplanationGenerationMutationData';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GRequestExplanationGenerationMutationData object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(
        object.G__typename,
        specifiedType: const FullType(String),
      ),
      'requestExplanationGeneration',
      serializers.serialize(
        object.requestExplanationGeneration,
        specifiedType: const FullType(
          GRequestExplanationGenerationMutationData_requestExplanationGeneration,
        ),
      ),
    ];

    return result;
  }

  @override
  GRequestExplanationGenerationMutationData deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GRequestExplanationGenerationMutationDataBuilder();

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
        case 'requestExplanationGeneration':
          result.requestExplanationGeneration.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(
                    GRequestExplanationGenerationMutationData_requestExplanationGeneration,
                  ),
                )!
                as GRequestExplanationGenerationMutationData_requestExplanationGeneration,
          );
          break;
      }
    }

    return result.build();
  }
}

class _$GRequestExplanationGenerationMutationData_requestExplanationGenerationSerializer
    implements
        StructuredSerializer<
          GRequestExplanationGenerationMutationData_requestExplanationGeneration
        > {
  @override
  final Iterable<Type> types = const [
    GRequestExplanationGenerationMutationData_requestExplanationGeneration,
    _$GRequestExplanationGenerationMutationData_requestExplanationGeneration,
  ];
  @override
  final String wireName =
      'GRequestExplanationGenerationMutationData_requestExplanationGeneration';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GRequestExplanationGenerationMutationData_requestExplanationGeneration
    object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(
        object.G__typename,
        specifiedType: const FullType(String),
      ),
      'accepted',
      serializers.serialize(
        object.accepted,
        specifiedType: const FullType(bool),
      ),
      'message',
      serializers.serialize(
        object.message,
        specifiedType: const FullType(
          GRequestExplanationGenerationMutationData_requestExplanationGeneration_message,
        ),
      ),
    ];
    Object? value;
    value = object.outcome;
    if (value != null) {
      result
        ..add('outcome')
        ..add(
          serializers.serialize(
            value,
            specifiedType: const FullType(_i2.GAcceptanceOutcome),
          ),
        );
    }
    value = object.errorCategory;
    if (value != null) {
      result
        ..add('errorCategory')
        ..add(
          serializers.serialize(
            value,
            specifiedType: const FullType(_i2.GCommandErrorCategory),
          ),
        );
    }
    return result;
  }

  @override
  GRequestExplanationGenerationMutationData_requestExplanationGeneration
  deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GRequestExplanationGenerationMutationData_requestExplanationGenerationBuilder();

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
        case 'accepted':
          result.accepted =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )!
                  as bool;
          break;
        case 'outcome':
          result.outcome =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(_i2.GAcceptanceOutcome),
                  )
                  as _i2.GAcceptanceOutcome?;
          break;
        case 'errorCategory':
          result.errorCategory =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(_i2.GCommandErrorCategory),
                  )
                  as _i2.GCommandErrorCategory?;
          break;
        case 'message':
          result.message.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(
                    GRequestExplanationGenerationMutationData_requestExplanationGeneration_message,
                  ),
                )!
                as GRequestExplanationGenerationMutationData_requestExplanationGeneration_message,
          );
          break;
      }
    }

    return result.build();
  }
}

class _$GRequestExplanationGenerationMutationData_requestExplanationGeneration_messageSerializer
    implements
        StructuredSerializer<
          GRequestExplanationGenerationMutationData_requestExplanationGeneration_message
        > {
  @override
  final Iterable<Type> types = const [
    GRequestExplanationGenerationMutationData_requestExplanationGeneration_message,
    _$GRequestExplanationGenerationMutationData_requestExplanationGeneration_message,
  ];
  @override
  final String wireName =
      'GRequestExplanationGenerationMutationData_requestExplanationGeneration_message';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GRequestExplanationGenerationMutationData_requestExplanationGeneration_message
    object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(
        object.G__typename,
        specifiedType: const FullType(String),
      ),
      'key',
      serializers.serialize(object.key, specifiedType: const FullType(String)),
      'text',
      serializers.serialize(object.text, specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GRequestExplanationGenerationMutationData_requestExplanationGeneration_message
  deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GRequestExplanationGenerationMutationData_requestExplanationGeneration_messageBuilder();

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
        case 'key':
          result.key =
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
      }
    }

    return result.build();
  }
}

class _$GRequestImageGenerationMutationDataSerializer
    implements StructuredSerializer<GRequestImageGenerationMutationData> {
  @override
  final Iterable<Type> types = const [
    GRequestImageGenerationMutationData,
    _$GRequestImageGenerationMutationData,
  ];
  @override
  final String wireName = 'GRequestImageGenerationMutationData';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GRequestImageGenerationMutationData object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(
        object.G__typename,
        specifiedType: const FullType(String),
      ),
      'requestImageGeneration',
      serializers.serialize(
        object.requestImageGeneration,
        specifiedType: const FullType(
          GRequestImageGenerationMutationData_requestImageGeneration,
        ),
      ),
    ];

    return result;
  }

  @override
  GRequestImageGenerationMutationData deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GRequestImageGenerationMutationDataBuilder();

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
        case 'requestImageGeneration':
          result.requestImageGeneration.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(
                    GRequestImageGenerationMutationData_requestImageGeneration,
                  ),
                )!
                as GRequestImageGenerationMutationData_requestImageGeneration,
          );
          break;
      }
    }

    return result.build();
  }
}

class _$GRequestImageGenerationMutationData_requestImageGenerationSerializer
    implements
        StructuredSerializer<
          GRequestImageGenerationMutationData_requestImageGeneration
        > {
  @override
  final Iterable<Type> types = const [
    GRequestImageGenerationMutationData_requestImageGeneration,
    _$GRequestImageGenerationMutationData_requestImageGeneration,
  ];
  @override
  final String wireName =
      'GRequestImageGenerationMutationData_requestImageGeneration';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GRequestImageGenerationMutationData_requestImageGeneration object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(
        object.G__typename,
        specifiedType: const FullType(String),
      ),
      'accepted',
      serializers.serialize(
        object.accepted,
        specifiedType: const FullType(bool),
      ),
      'message',
      serializers.serialize(
        object.message,
        specifiedType: const FullType(
          GRequestImageGenerationMutationData_requestImageGeneration_message,
        ),
      ),
    ];
    Object? value;
    value = object.outcome;
    if (value != null) {
      result
        ..add('outcome')
        ..add(
          serializers.serialize(
            value,
            specifiedType: const FullType(_i2.GAcceptanceOutcome),
          ),
        );
    }
    value = object.errorCategory;
    if (value != null) {
      result
        ..add('errorCategory')
        ..add(
          serializers.serialize(
            value,
            specifiedType: const FullType(_i2.GCommandErrorCategory),
          ),
        );
    }
    return result;
  }

  @override
  GRequestImageGenerationMutationData_requestImageGeneration deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GRequestImageGenerationMutationData_requestImageGenerationBuilder();

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
        case 'accepted':
          result.accepted =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )!
                  as bool;
          break;
        case 'outcome':
          result.outcome =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(_i2.GAcceptanceOutcome),
                  )
                  as _i2.GAcceptanceOutcome?;
          break;
        case 'errorCategory':
          result.errorCategory =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(_i2.GCommandErrorCategory),
                  )
                  as _i2.GCommandErrorCategory?;
          break;
        case 'message':
          result.message.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(
                    GRequestImageGenerationMutationData_requestImageGeneration_message,
                  ),
                )!
                as GRequestImageGenerationMutationData_requestImageGeneration_message,
          );
          break;
      }
    }

    return result.build();
  }
}

class _$GRequestImageGenerationMutationData_requestImageGeneration_messageSerializer
    implements
        StructuredSerializer<
          GRequestImageGenerationMutationData_requestImageGeneration_message
        > {
  @override
  final Iterable<Type> types = const [
    GRequestImageGenerationMutationData_requestImageGeneration_message,
    _$GRequestImageGenerationMutationData_requestImageGeneration_message,
  ];
  @override
  final String wireName =
      'GRequestImageGenerationMutationData_requestImageGeneration_message';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GRequestImageGenerationMutationData_requestImageGeneration_message object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(
        object.G__typename,
        specifiedType: const FullType(String),
      ),
      'key',
      serializers.serialize(object.key, specifiedType: const FullType(String)),
      'text',
      serializers.serialize(object.text, specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GRequestImageGenerationMutationData_requestImageGeneration_message
  deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GRequestImageGenerationMutationData_requestImageGeneration_messageBuilder();

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
        case 'key':
          result.key =
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
      }
    }

    return result.build();
  }
}

class _$GRetryGenerationMutationDataSerializer
    implements StructuredSerializer<GRetryGenerationMutationData> {
  @override
  final Iterable<Type> types = const [
    GRetryGenerationMutationData,
    _$GRetryGenerationMutationData,
  ];
  @override
  final String wireName = 'GRetryGenerationMutationData';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GRetryGenerationMutationData object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(
        object.G__typename,
        specifiedType: const FullType(String),
      ),
      'retryGeneration',
      serializers.serialize(
        object.retryGeneration,
        specifiedType: const FullType(
          GRetryGenerationMutationData_retryGeneration,
        ),
      ),
    ];

    return result;
  }

  @override
  GRetryGenerationMutationData deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GRetryGenerationMutationDataBuilder();

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
        case 'retryGeneration':
          result.retryGeneration.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(
                    GRetryGenerationMutationData_retryGeneration,
                  ),
                )!
                as GRetryGenerationMutationData_retryGeneration,
          );
          break;
      }
    }

    return result.build();
  }
}

class _$GRetryGenerationMutationData_retryGenerationSerializer
    implements
        StructuredSerializer<GRetryGenerationMutationData_retryGeneration> {
  @override
  final Iterable<Type> types = const [
    GRetryGenerationMutationData_retryGeneration,
    _$GRetryGenerationMutationData_retryGeneration,
  ];
  @override
  final String wireName = 'GRetryGenerationMutationData_retryGeneration';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GRetryGenerationMutationData_retryGeneration object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(
        object.G__typename,
        specifiedType: const FullType(String),
      ),
      'accepted',
      serializers.serialize(
        object.accepted,
        specifiedType: const FullType(bool),
      ),
      'message',
      serializers.serialize(
        object.message,
        specifiedType: const FullType(
          GRetryGenerationMutationData_retryGeneration_message,
        ),
      ),
    ];
    Object? value;
    value = object.outcome;
    if (value != null) {
      result
        ..add('outcome')
        ..add(
          serializers.serialize(
            value,
            specifiedType: const FullType(_i2.GAcceptanceOutcome),
          ),
        );
    }
    value = object.errorCategory;
    if (value != null) {
      result
        ..add('errorCategory')
        ..add(
          serializers.serialize(
            value,
            specifiedType: const FullType(_i2.GCommandErrorCategory),
          ),
        );
    }
    return result;
  }

  @override
  GRetryGenerationMutationData_retryGeneration deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GRetryGenerationMutationData_retryGenerationBuilder();

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
        case 'accepted':
          result.accepted =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )!
                  as bool;
          break;
        case 'outcome':
          result.outcome =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(_i2.GAcceptanceOutcome),
                  )
                  as _i2.GAcceptanceOutcome?;
          break;
        case 'errorCategory':
          result.errorCategory =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(_i2.GCommandErrorCategory),
                  )
                  as _i2.GCommandErrorCategory?;
          break;
        case 'message':
          result.message.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(
                    GRetryGenerationMutationData_retryGeneration_message,
                  ),
                )!
                as GRetryGenerationMutationData_retryGeneration_message,
          );
          break;
      }
    }

    return result.build();
  }
}

class _$GRetryGenerationMutationData_retryGeneration_messageSerializer
    implements
        StructuredSerializer<
          GRetryGenerationMutationData_retryGeneration_message
        > {
  @override
  final Iterable<Type> types = const [
    GRetryGenerationMutationData_retryGeneration_message,
    _$GRetryGenerationMutationData_retryGeneration_message,
  ];
  @override
  final String wireName =
      'GRetryGenerationMutationData_retryGeneration_message';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GRetryGenerationMutationData_retryGeneration_message object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(
        object.G__typename,
        specifiedType: const FullType(String),
      ),
      'key',
      serializers.serialize(object.key, specifiedType: const FullType(String)),
      'text',
      serializers.serialize(object.text, specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GRetryGenerationMutationData_retryGeneration_message deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GRetryGenerationMutationData_retryGeneration_messageBuilder();

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
        case 'key':
          result.key =
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
      }
    }

    return result.build();
  }
}

class _$GRegisterVocabularyExpressionMutationData
    extends GRegisterVocabularyExpressionMutationData {
  @override
  final String G__typename;
  @override
  final GRegisterVocabularyExpressionMutationData_registerVocabularyExpression
  registerVocabularyExpression;

  factory _$GRegisterVocabularyExpressionMutationData([
    void Function(GRegisterVocabularyExpressionMutationDataBuilder)? updates,
  ]) => (GRegisterVocabularyExpressionMutationDataBuilder()..update(updates))
      ._build();

  _$GRegisterVocabularyExpressionMutationData._({
    required this.G__typename,
    required this.registerVocabularyExpression,
  }) : super._();
  @override
  GRegisterVocabularyExpressionMutationData rebuild(
    void Function(GRegisterVocabularyExpressionMutationDataBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GRegisterVocabularyExpressionMutationDataBuilder toBuilder() =>
      GRegisterVocabularyExpressionMutationDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GRegisterVocabularyExpressionMutationData &&
        G__typename == other.G__typename &&
        registerVocabularyExpression == other.registerVocabularyExpression;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, registerVocabularyExpression.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GRegisterVocabularyExpressionMutationData',
          )
          ..add('G__typename', G__typename)
          ..add('registerVocabularyExpression', registerVocabularyExpression))
        .toString();
  }
}

class GRegisterVocabularyExpressionMutationDataBuilder
    implements
        Builder<
          GRegisterVocabularyExpressionMutationData,
          GRegisterVocabularyExpressionMutationDataBuilder
        > {
  _$GRegisterVocabularyExpressionMutationData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GRegisterVocabularyExpressionMutationData_registerVocabularyExpressionBuilder?
  _registerVocabularyExpression;
  GRegisterVocabularyExpressionMutationData_registerVocabularyExpressionBuilder
  get registerVocabularyExpression => _$this._registerVocabularyExpression ??=
      GRegisterVocabularyExpressionMutationData_registerVocabularyExpressionBuilder();
  set registerVocabularyExpression(
    GRegisterVocabularyExpressionMutationData_registerVocabularyExpressionBuilder?
    registerVocabularyExpression,
  ) => _$this._registerVocabularyExpression = registerVocabularyExpression;

  GRegisterVocabularyExpressionMutationDataBuilder() {
    GRegisterVocabularyExpressionMutationData._initializeBuilder(this);
  }

  GRegisterVocabularyExpressionMutationDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _registerVocabularyExpression = $v.registerVocabularyExpression
          .toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GRegisterVocabularyExpressionMutationData other) {
    _$v = other as _$GRegisterVocabularyExpressionMutationData;
  }

  @override
  void update(
    void Function(GRegisterVocabularyExpressionMutationDataBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GRegisterVocabularyExpressionMutationData build() => _build();

  _$GRegisterVocabularyExpressionMutationData _build() {
    _$GRegisterVocabularyExpressionMutationData _$result;
    try {
      _$result =
          _$v ??
          _$GRegisterVocabularyExpressionMutationData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GRegisterVocabularyExpressionMutationData',
              'G__typename',
            ),
            registerVocabularyExpression: registerVocabularyExpression.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'registerVocabularyExpression';
        registerVocabularyExpression.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GRegisterVocabularyExpressionMutationData',
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

class _$GRegisterVocabularyExpressionMutationData_registerVocabularyExpression
    extends
        GRegisterVocabularyExpressionMutationData_registerVocabularyExpression {
  @override
  final String G__typename;
  @override
  final bool accepted;
  @override
  final _i2.GAcceptanceOutcome? outcome;
  @override
  final _i2.GCommandErrorCategory? errorCategory;
  @override
  final GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message
  message;

  factory _$GRegisterVocabularyExpressionMutationData_registerVocabularyExpression([
    void Function(
      GRegisterVocabularyExpressionMutationData_registerVocabularyExpressionBuilder,
    )?
    updates,
  ]) =>
      (GRegisterVocabularyExpressionMutationData_registerVocabularyExpressionBuilder()
            ..update(updates))
          ._build();

  _$GRegisterVocabularyExpressionMutationData_registerVocabularyExpression._({
    required this.G__typename,
    required this.accepted,
    this.outcome,
    this.errorCategory,
    required this.message,
  }) : super._();
  @override
  GRegisterVocabularyExpressionMutationData_registerVocabularyExpression
  rebuild(
    void Function(
      GRegisterVocabularyExpressionMutationData_registerVocabularyExpressionBuilder,
    )
    updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GRegisterVocabularyExpressionMutationData_registerVocabularyExpressionBuilder
  toBuilder() =>
      GRegisterVocabularyExpressionMutationData_registerVocabularyExpressionBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GRegisterVocabularyExpressionMutationData_registerVocabularyExpression &&
        G__typename == other.G__typename &&
        accepted == other.accepted &&
        outcome == other.outcome &&
        errorCategory == other.errorCategory &&
        message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, accepted.hashCode);
    _$hash = $jc(_$hash, outcome.hashCode);
    _$hash = $jc(_$hash, errorCategory.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GRegisterVocabularyExpressionMutationData_registerVocabularyExpression',
          )
          ..add('G__typename', G__typename)
          ..add('accepted', accepted)
          ..add('outcome', outcome)
          ..add('errorCategory', errorCategory)
          ..add('message', message))
        .toString();
  }
}

class GRegisterVocabularyExpressionMutationData_registerVocabularyExpressionBuilder
    implements
        Builder<
          GRegisterVocabularyExpressionMutationData_registerVocabularyExpression,
          GRegisterVocabularyExpressionMutationData_registerVocabularyExpressionBuilder
        > {
  _$GRegisterVocabularyExpressionMutationData_registerVocabularyExpression? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  bool? _accepted;
  bool? get accepted => _$this._accepted;
  set accepted(bool? accepted) => _$this._accepted = accepted;

  _i2.GAcceptanceOutcome? _outcome;
  _i2.GAcceptanceOutcome? get outcome => _$this._outcome;
  set outcome(_i2.GAcceptanceOutcome? outcome) => _$this._outcome = outcome;

  _i2.GCommandErrorCategory? _errorCategory;
  _i2.GCommandErrorCategory? get errorCategory => _$this._errorCategory;
  set errorCategory(_i2.GCommandErrorCategory? errorCategory) =>
      _$this._errorCategory = errorCategory;

  GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_messageBuilder?
  _message;
  GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_messageBuilder
  get message => _$this._message ??=
      GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_messageBuilder();
  set message(
    GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_messageBuilder?
    message,
  ) => _$this._message = message;

  GRegisterVocabularyExpressionMutationData_registerVocabularyExpressionBuilder() {
    GRegisterVocabularyExpressionMutationData_registerVocabularyExpression._initializeBuilder(
      this,
    );
  }

  GRegisterVocabularyExpressionMutationData_registerVocabularyExpressionBuilder
  get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _accepted = $v.accepted;
      _outcome = $v.outcome;
      _errorCategory = $v.errorCategory;
      _message = $v.message.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
    GRegisterVocabularyExpressionMutationData_registerVocabularyExpression
    other,
  ) {
    _$v =
        other
            as _$GRegisterVocabularyExpressionMutationData_registerVocabularyExpression;
  }

  @override
  void update(
    void Function(
      GRegisterVocabularyExpressionMutationData_registerVocabularyExpressionBuilder,
    )?
    updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GRegisterVocabularyExpressionMutationData_registerVocabularyExpression
  build() => _build();

  _$GRegisterVocabularyExpressionMutationData_registerVocabularyExpression
  _build() {
    _$GRegisterVocabularyExpressionMutationData_registerVocabularyExpression
    _$result;
    try {
      _$result =
          _$v ??
          _$GRegisterVocabularyExpressionMutationData_registerVocabularyExpression._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GRegisterVocabularyExpressionMutationData_registerVocabularyExpression',
              'G__typename',
            ),
            accepted: BuiltValueNullFieldError.checkNotNull(
              accepted,
              r'GRegisterVocabularyExpressionMutationData_registerVocabularyExpression',
              'accepted',
            ),
            outcome: outcome,
            errorCategory: errorCategory,
            message: message.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'message';
        message.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GRegisterVocabularyExpressionMutationData_registerVocabularyExpression',
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

class _$GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message
    extends
        GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message {
  @override
  final String G__typename;
  @override
  final String key;
  @override
  final String text;

  factory _$GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message([
    void Function(
      GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_messageBuilder,
    )?
    updates,
  ]) =>
      (GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_messageBuilder()
            ..update(updates))
          ._build();

  _$GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message._({
    required this.G__typename,
    required this.key,
    required this.text,
  }) : super._();
  @override
  GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message
  rebuild(
    void Function(
      GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_messageBuilder,
    )
    updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_messageBuilder
  toBuilder() =>
      GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_messageBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message &&
        G__typename == other.G__typename &&
        key == other.key &&
        text == other.text;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jc(_$hash, text.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message',
          )
          ..add('G__typename', G__typename)
          ..add('key', key)
          ..add('text', text))
        .toString();
  }
}

class GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_messageBuilder
    implements
        Builder<
          GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message,
          GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_messageBuilder
        > {
  _$GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message?
  _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

  String? _text;
  String? get text => _$this._text;
  set text(String? text) => _$this._text = text;

  GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_messageBuilder() {
    GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message._initializeBuilder(
      this,
    );
  }

  GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_messageBuilder
  get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _key = $v.key;
      _text = $v.text;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
    GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message
    other,
  ) {
    _$v =
        other
            as _$GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message;
  }

  @override
  void update(
    void Function(
      GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_messageBuilder,
    )?
    updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message
  build() => _build();

  _$GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message
  _build() {
    final _$result =
        _$v ??
        _$GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
            G__typename,
            r'GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message',
            'G__typename',
          ),
          key: BuiltValueNullFieldError.checkNotNull(
            key,
            r'GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message',
            'key',
          ),
          text: BuiltValueNullFieldError.checkNotNull(
            text,
            r'GRegisterVocabularyExpressionMutationData_registerVocabularyExpression_message',
            'text',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GRequestExplanationGenerationMutationData
    extends GRequestExplanationGenerationMutationData {
  @override
  final String G__typename;
  @override
  final GRequestExplanationGenerationMutationData_requestExplanationGeneration
  requestExplanationGeneration;

  factory _$GRequestExplanationGenerationMutationData([
    void Function(GRequestExplanationGenerationMutationDataBuilder)? updates,
  ]) => (GRequestExplanationGenerationMutationDataBuilder()..update(updates))
      ._build();

  _$GRequestExplanationGenerationMutationData._({
    required this.G__typename,
    required this.requestExplanationGeneration,
  }) : super._();
  @override
  GRequestExplanationGenerationMutationData rebuild(
    void Function(GRequestExplanationGenerationMutationDataBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GRequestExplanationGenerationMutationDataBuilder toBuilder() =>
      GRequestExplanationGenerationMutationDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GRequestExplanationGenerationMutationData &&
        G__typename == other.G__typename &&
        requestExplanationGeneration == other.requestExplanationGeneration;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, requestExplanationGeneration.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GRequestExplanationGenerationMutationData',
          )
          ..add('G__typename', G__typename)
          ..add('requestExplanationGeneration', requestExplanationGeneration))
        .toString();
  }
}

class GRequestExplanationGenerationMutationDataBuilder
    implements
        Builder<
          GRequestExplanationGenerationMutationData,
          GRequestExplanationGenerationMutationDataBuilder
        > {
  _$GRequestExplanationGenerationMutationData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GRequestExplanationGenerationMutationData_requestExplanationGenerationBuilder?
  _requestExplanationGeneration;
  GRequestExplanationGenerationMutationData_requestExplanationGenerationBuilder
  get requestExplanationGeneration => _$this._requestExplanationGeneration ??=
      GRequestExplanationGenerationMutationData_requestExplanationGenerationBuilder();
  set requestExplanationGeneration(
    GRequestExplanationGenerationMutationData_requestExplanationGenerationBuilder?
    requestExplanationGeneration,
  ) => _$this._requestExplanationGeneration = requestExplanationGeneration;

  GRequestExplanationGenerationMutationDataBuilder() {
    GRequestExplanationGenerationMutationData._initializeBuilder(this);
  }

  GRequestExplanationGenerationMutationDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _requestExplanationGeneration = $v.requestExplanationGeneration
          .toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GRequestExplanationGenerationMutationData other) {
    _$v = other as _$GRequestExplanationGenerationMutationData;
  }

  @override
  void update(
    void Function(GRequestExplanationGenerationMutationDataBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GRequestExplanationGenerationMutationData build() => _build();

  _$GRequestExplanationGenerationMutationData _build() {
    _$GRequestExplanationGenerationMutationData _$result;
    try {
      _$result =
          _$v ??
          _$GRequestExplanationGenerationMutationData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GRequestExplanationGenerationMutationData',
              'G__typename',
            ),
            requestExplanationGeneration: requestExplanationGeneration.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'requestExplanationGeneration';
        requestExplanationGeneration.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GRequestExplanationGenerationMutationData',
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

class _$GRequestExplanationGenerationMutationData_requestExplanationGeneration
    extends
        GRequestExplanationGenerationMutationData_requestExplanationGeneration {
  @override
  final String G__typename;
  @override
  final bool accepted;
  @override
  final _i2.GAcceptanceOutcome? outcome;
  @override
  final _i2.GCommandErrorCategory? errorCategory;
  @override
  final GRequestExplanationGenerationMutationData_requestExplanationGeneration_message
  message;

  factory _$GRequestExplanationGenerationMutationData_requestExplanationGeneration([
    void Function(
      GRequestExplanationGenerationMutationData_requestExplanationGenerationBuilder,
    )?
    updates,
  ]) =>
      (GRequestExplanationGenerationMutationData_requestExplanationGenerationBuilder()
            ..update(updates))
          ._build();

  _$GRequestExplanationGenerationMutationData_requestExplanationGeneration._({
    required this.G__typename,
    required this.accepted,
    this.outcome,
    this.errorCategory,
    required this.message,
  }) : super._();
  @override
  GRequestExplanationGenerationMutationData_requestExplanationGeneration
  rebuild(
    void Function(
      GRequestExplanationGenerationMutationData_requestExplanationGenerationBuilder,
    )
    updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GRequestExplanationGenerationMutationData_requestExplanationGenerationBuilder
  toBuilder() =>
      GRequestExplanationGenerationMutationData_requestExplanationGenerationBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GRequestExplanationGenerationMutationData_requestExplanationGeneration &&
        G__typename == other.G__typename &&
        accepted == other.accepted &&
        outcome == other.outcome &&
        errorCategory == other.errorCategory &&
        message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, accepted.hashCode);
    _$hash = $jc(_$hash, outcome.hashCode);
    _$hash = $jc(_$hash, errorCategory.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GRequestExplanationGenerationMutationData_requestExplanationGeneration',
          )
          ..add('G__typename', G__typename)
          ..add('accepted', accepted)
          ..add('outcome', outcome)
          ..add('errorCategory', errorCategory)
          ..add('message', message))
        .toString();
  }
}

class GRequestExplanationGenerationMutationData_requestExplanationGenerationBuilder
    implements
        Builder<
          GRequestExplanationGenerationMutationData_requestExplanationGeneration,
          GRequestExplanationGenerationMutationData_requestExplanationGenerationBuilder
        > {
  _$GRequestExplanationGenerationMutationData_requestExplanationGeneration? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  bool? _accepted;
  bool? get accepted => _$this._accepted;
  set accepted(bool? accepted) => _$this._accepted = accepted;

  _i2.GAcceptanceOutcome? _outcome;
  _i2.GAcceptanceOutcome? get outcome => _$this._outcome;
  set outcome(_i2.GAcceptanceOutcome? outcome) => _$this._outcome = outcome;

  _i2.GCommandErrorCategory? _errorCategory;
  _i2.GCommandErrorCategory? get errorCategory => _$this._errorCategory;
  set errorCategory(_i2.GCommandErrorCategory? errorCategory) =>
      _$this._errorCategory = errorCategory;

  GRequestExplanationGenerationMutationData_requestExplanationGeneration_messageBuilder?
  _message;
  GRequestExplanationGenerationMutationData_requestExplanationGeneration_messageBuilder
  get message => _$this._message ??=
      GRequestExplanationGenerationMutationData_requestExplanationGeneration_messageBuilder();
  set message(
    GRequestExplanationGenerationMutationData_requestExplanationGeneration_messageBuilder?
    message,
  ) => _$this._message = message;

  GRequestExplanationGenerationMutationData_requestExplanationGenerationBuilder() {
    GRequestExplanationGenerationMutationData_requestExplanationGeneration._initializeBuilder(
      this,
    );
  }

  GRequestExplanationGenerationMutationData_requestExplanationGenerationBuilder
  get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _accepted = $v.accepted;
      _outcome = $v.outcome;
      _errorCategory = $v.errorCategory;
      _message = $v.message.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
    GRequestExplanationGenerationMutationData_requestExplanationGeneration
    other,
  ) {
    _$v =
        other
            as _$GRequestExplanationGenerationMutationData_requestExplanationGeneration;
  }

  @override
  void update(
    void Function(
      GRequestExplanationGenerationMutationData_requestExplanationGenerationBuilder,
    )?
    updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GRequestExplanationGenerationMutationData_requestExplanationGeneration
  build() => _build();

  _$GRequestExplanationGenerationMutationData_requestExplanationGeneration
  _build() {
    _$GRequestExplanationGenerationMutationData_requestExplanationGeneration
    _$result;
    try {
      _$result =
          _$v ??
          _$GRequestExplanationGenerationMutationData_requestExplanationGeneration._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GRequestExplanationGenerationMutationData_requestExplanationGeneration',
              'G__typename',
            ),
            accepted: BuiltValueNullFieldError.checkNotNull(
              accepted,
              r'GRequestExplanationGenerationMutationData_requestExplanationGeneration',
              'accepted',
            ),
            outcome: outcome,
            errorCategory: errorCategory,
            message: message.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'message';
        message.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GRequestExplanationGenerationMutationData_requestExplanationGeneration',
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

class _$GRequestExplanationGenerationMutationData_requestExplanationGeneration_message
    extends
        GRequestExplanationGenerationMutationData_requestExplanationGeneration_message {
  @override
  final String G__typename;
  @override
  final String key;
  @override
  final String text;

  factory _$GRequestExplanationGenerationMutationData_requestExplanationGeneration_message([
    void Function(
      GRequestExplanationGenerationMutationData_requestExplanationGeneration_messageBuilder,
    )?
    updates,
  ]) =>
      (GRequestExplanationGenerationMutationData_requestExplanationGeneration_messageBuilder()
            ..update(updates))
          ._build();

  _$GRequestExplanationGenerationMutationData_requestExplanationGeneration_message._({
    required this.G__typename,
    required this.key,
    required this.text,
  }) : super._();
  @override
  GRequestExplanationGenerationMutationData_requestExplanationGeneration_message
  rebuild(
    void Function(
      GRequestExplanationGenerationMutationData_requestExplanationGeneration_messageBuilder,
    )
    updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GRequestExplanationGenerationMutationData_requestExplanationGeneration_messageBuilder
  toBuilder() =>
      GRequestExplanationGenerationMutationData_requestExplanationGeneration_messageBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GRequestExplanationGenerationMutationData_requestExplanationGeneration_message &&
        G__typename == other.G__typename &&
        key == other.key &&
        text == other.text;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jc(_$hash, text.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GRequestExplanationGenerationMutationData_requestExplanationGeneration_message',
          )
          ..add('G__typename', G__typename)
          ..add('key', key)
          ..add('text', text))
        .toString();
  }
}

class GRequestExplanationGenerationMutationData_requestExplanationGeneration_messageBuilder
    implements
        Builder<
          GRequestExplanationGenerationMutationData_requestExplanationGeneration_message,
          GRequestExplanationGenerationMutationData_requestExplanationGeneration_messageBuilder
        > {
  _$GRequestExplanationGenerationMutationData_requestExplanationGeneration_message?
  _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

  String? _text;
  String? get text => _$this._text;
  set text(String? text) => _$this._text = text;

  GRequestExplanationGenerationMutationData_requestExplanationGeneration_messageBuilder() {
    GRequestExplanationGenerationMutationData_requestExplanationGeneration_message._initializeBuilder(
      this,
    );
  }

  GRequestExplanationGenerationMutationData_requestExplanationGeneration_messageBuilder
  get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _key = $v.key;
      _text = $v.text;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
    GRequestExplanationGenerationMutationData_requestExplanationGeneration_message
    other,
  ) {
    _$v =
        other
            as _$GRequestExplanationGenerationMutationData_requestExplanationGeneration_message;
  }

  @override
  void update(
    void Function(
      GRequestExplanationGenerationMutationData_requestExplanationGeneration_messageBuilder,
    )?
    updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GRequestExplanationGenerationMutationData_requestExplanationGeneration_message
  build() => _build();

  _$GRequestExplanationGenerationMutationData_requestExplanationGeneration_message
  _build() {
    final _$result =
        _$v ??
        _$GRequestExplanationGenerationMutationData_requestExplanationGeneration_message._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
            G__typename,
            r'GRequestExplanationGenerationMutationData_requestExplanationGeneration_message',
            'G__typename',
          ),
          key: BuiltValueNullFieldError.checkNotNull(
            key,
            r'GRequestExplanationGenerationMutationData_requestExplanationGeneration_message',
            'key',
          ),
          text: BuiltValueNullFieldError.checkNotNull(
            text,
            r'GRequestExplanationGenerationMutationData_requestExplanationGeneration_message',
            'text',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GRequestImageGenerationMutationData
    extends GRequestImageGenerationMutationData {
  @override
  final String G__typename;
  @override
  final GRequestImageGenerationMutationData_requestImageGeneration
  requestImageGeneration;

  factory _$GRequestImageGenerationMutationData([
    void Function(GRequestImageGenerationMutationDataBuilder)? updates,
  ]) =>
      (GRequestImageGenerationMutationDataBuilder()..update(updates))._build();

  _$GRequestImageGenerationMutationData._({
    required this.G__typename,
    required this.requestImageGeneration,
  }) : super._();
  @override
  GRequestImageGenerationMutationData rebuild(
    void Function(GRequestImageGenerationMutationDataBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GRequestImageGenerationMutationDataBuilder toBuilder() =>
      GRequestImageGenerationMutationDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GRequestImageGenerationMutationData &&
        G__typename == other.G__typename &&
        requestImageGeneration == other.requestImageGeneration;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, requestImageGeneration.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GRequestImageGenerationMutationData')
          ..add('G__typename', G__typename)
          ..add('requestImageGeneration', requestImageGeneration))
        .toString();
  }
}

class GRequestImageGenerationMutationDataBuilder
    implements
        Builder<
          GRequestImageGenerationMutationData,
          GRequestImageGenerationMutationDataBuilder
        > {
  _$GRequestImageGenerationMutationData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GRequestImageGenerationMutationData_requestImageGenerationBuilder?
  _requestImageGeneration;
  GRequestImageGenerationMutationData_requestImageGenerationBuilder
  get requestImageGeneration => _$this._requestImageGeneration ??=
      GRequestImageGenerationMutationData_requestImageGenerationBuilder();
  set requestImageGeneration(
    GRequestImageGenerationMutationData_requestImageGenerationBuilder?
    requestImageGeneration,
  ) => _$this._requestImageGeneration = requestImageGeneration;

  GRequestImageGenerationMutationDataBuilder() {
    GRequestImageGenerationMutationData._initializeBuilder(this);
  }

  GRequestImageGenerationMutationDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _requestImageGeneration = $v.requestImageGeneration.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GRequestImageGenerationMutationData other) {
    _$v = other as _$GRequestImageGenerationMutationData;
  }

  @override
  void update(
    void Function(GRequestImageGenerationMutationDataBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GRequestImageGenerationMutationData build() => _build();

  _$GRequestImageGenerationMutationData _build() {
    _$GRequestImageGenerationMutationData _$result;
    try {
      _$result =
          _$v ??
          _$GRequestImageGenerationMutationData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GRequestImageGenerationMutationData',
              'G__typename',
            ),
            requestImageGeneration: requestImageGeneration.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'requestImageGeneration';
        requestImageGeneration.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GRequestImageGenerationMutationData',
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

class _$GRequestImageGenerationMutationData_requestImageGeneration
    extends GRequestImageGenerationMutationData_requestImageGeneration {
  @override
  final String G__typename;
  @override
  final bool accepted;
  @override
  final _i2.GAcceptanceOutcome? outcome;
  @override
  final _i2.GCommandErrorCategory? errorCategory;
  @override
  final GRequestImageGenerationMutationData_requestImageGeneration_message
  message;

  factory _$GRequestImageGenerationMutationData_requestImageGeneration([
    void Function(
      GRequestImageGenerationMutationData_requestImageGenerationBuilder,
    )?
    updates,
  ]) =>
      (GRequestImageGenerationMutationData_requestImageGenerationBuilder()
            ..update(updates))
          ._build();

  _$GRequestImageGenerationMutationData_requestImageGeneration._({
    required this.G__typename,
    required this.accepted,
    this.outcome,
    this.errorCategory,
    required this.message,
  }) : super._();
  @override
  GRequestImageGenerationMutationData_requestImageGeneration rebuild(
    void Function(
      GRequestImageGenerationMutationData_requestImageGenerationBuilder,
    )
    updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GRequestImageGenerationMutationData_requestImageGenerationBuilder
  toBuilder() =>
      GRequestImageGenerationMutationData_requestImageGenerationBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GRequestImageGenerationMutationData_requestImageGeneration &&
        G__typename == other.G__typename &&
        accepted == other.accepted &&
        outcome == other.outcome &&
        errorCategory == other.errorCategory &&
        message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, accepted.hashCode);
    _$hash = $jc(_$hash, outcome.hashCode);
    _$hash = $jc(_$hash, errorCategory.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GRequestImageGenerationMutationData_requestImageGeneration',
          )
          ..add('G__typename', G__typename)
          ..add('accepted', accepted)
          ..add('outcome', outcome)
          ..add('errorCategory', errorCategory)
          ..add('message', message))
        .toString();
  }
}

class GRequestImageGenerationMutationData_requestImageGenerationBuilder
    implements
        Builder<
          GRequestImageGenerationMutationData_requestImageGeneration,
          GRequestImageGenerationMutationData_requestImageGenerationBuilder
        > {
  _$GRequestImageGenerationMutationData_requestImageGeneration? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  bool? _accepted;
  bool? get accepted => _$this._accepted;
  set accepted(bool? accepted) => _$this._accepted = accepted;

  _i2.GAcceptanceOutcome? _outcome;
  _i2.GAcceptanceOutcome? get outcome => _$this._outcome;
  set outcome(_i2.GAcceptanceOutcome? outcome) => _$this._outcome = outcome;

  _i2.GCommandErrorCategory? _errorCategory;
  _i2.GCommandErrorCategory? get errorCategory => _$this._errorCategory;
  set errorCategory(_i2.GCommandErrorCategory? errorCategory) =>
      _$this._errorCategory = errorCategory;

  GRequestImageGenerationMutationData_requestImageGeneration_messageBuilder?
  _message;
  GRequestImageGenerationMutationData_requestImageGeneration_messageBuilder
  get message => _$this._message ??=
      GRequestImageGenerationMutationData_requestImageGeneration_messageBuilder();
  set message(
    GRequestImageGenerationMutationData_requestImageGeneration_messageBuilder?
    message,
  ) => _$this._message = message;

  GRequestImageGenerationMutationData_requestImageGenerationBuilder() {
    GRequestImageGenerationMutationData_requestImageGeneration._initializeBuilder(
      this,
    );
  }

  GRequestImageGenerationMutationData_requestImageGenerationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _accepted = $v.accepted;
      _outcome = $v.outcome;
      _errorCategory = $v.errorCategory;
      _message = $v.message.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
    GRequestImageGenerationMutationData_requestImageGeneration other,
  ) {
    _$v = other as _$GRequestImageGenerationMutationData_requestImageGeneration;
  }

  @override
  void update(
    void Function(
      GRequestImageGenerationMutationData_requestImageGenerationBuilder,
    )?
    updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GRequestImageGenerationMutationData_requestImageGeneration build() =>
      _build();

  _$GRequestImageGenerationMutationData_requestImageGeneration _build() {
    _$GRequestImageGenerationMutationData_requestImageGeneration _$result;
    try {
      _$result =
          _$v ??
          _$GRequestImageGenerationMutationData_requestImageGeneration._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GRequestImageGenerationMutationData_requestImageGeneration',
              'G__typename',
            ),
            accepted: BuiltValueNullFieldError.checkNotNull(
              accepted,
              r'GRequestImageGenerationMutationData_requestImageGeneration',
              'accepted',
            ),
            outcome: outcome,
            errorCategory: errorCategory,
            message: message.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'message';
        message.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GRequestImageGenerationMutationData_requestImageGeneration',
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

class _$GRequestImageGenerationMutationData_requestImageGeneration_message
    extends GRequestImageGenerationMutationData_requestImageGeneration_message {
  @override
  final String G__typename;
  @override
  final String key;
  @override
  final String text;

  factory _$GRequestImageGenerationMutationData_requestImageGeneration_message([
    void Function(
      GRequestImageGenerationMutationData_requestImageGeneration_messageBuilder,
    )?
    updates,
  ]) =>
      (GRequestImageGenerationMutationData_requestImageGeneration_messageBuilder()
            ..update(updates))
          ._build();

  _$GRequestImageGenerationMutationData_requestImageGeneration_message._({
    required this.G__typename,
    required this.key,
    required this.text,
  }) : super._();
  @override
  GRequestImageGenerationMutationData_requestImageGeneration_message rebuild(
    void Function(
      GRequestImageGenerationMutationData_requestImageGeneration_messageBuilder,
    )
    updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GRequestImageGenerationMutationData_requestImageGeneration_messageBuilder
  toBuilder() =>
      GRequestImageGenerationMutationData_requestImageGeneration_messageBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GRequestImageGenerationMutationData_requestImageGeneration_message &&
        G__typename == other.G__typename &&
        key == other.key &&
        text == other.text;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jc(_$hash, text.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GRequestImageGenerationMutationData_requestImageGeneration_message',
          )
          ..add('G__typename', G__typename)
          ..add('key', key)
          ..add('text', text))
        .toString();
  }
}

class GRequestImageGenerationMutationData_requestImageGeneration_messageBuilder
    implements
        Builder<
          GRequestImageGenerationMutationData_requestImageGeneration_message,
          GRequestImageGenerationMutationData_requestImageGeneration_messageBuilder
        > {
  _$GRequestImageGenerationMutationData_requestImageGeneration_message? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

  String? _text;
  String? get text => _$this._text;
  set text(String? text) => _$this._text = text;

  GRequestImageGenerationMutationData_requestImageGeneration_messageBuilder() {
    GRequestImageGenerationMutationData_requestImageGeneration_message._initializeBuilder(
      this,
    );
  }

  GRequestImageGenerationMutationData_requestImageGeneration_messageBuilder
  get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _key = $v.key;
      _text = $v.text;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
    GRequestImageGenerationMutationData_requestImageGeneration_message other,
  ) {
    _$v =
        other
            as _$GRequestImageGenerationMutationData_requestImageGeneration_message;
  }

  @override
  void update(
    void Function(
      GRequestImageGenerationMutationData_requestImageGeneration_messageBuilder,
    )?
    updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GRequestImageGenerationMutationData_requestImageGeneration_message build() =>
      _build();

  _$GRequestImageGenerationMutationData_requestImageGeneration_message
  _build() {
    final _$result =
        _$v ??
        _$GRequestImageGenerationMutationData_requestImageGeneration_message._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
            G__typename,
            r'GRequestImageGenerationMutationData_requestImageGeneration_message',
            'G__typename',
          ),
          key: BuiltValueNullFieldError.checkNotNull(
            key,
            r'GRequestImageGenerationMutationData_requestImageGeneration_message',
            'key',
          ),
          text: BuiltValueNullFieldError.checkNotNull(
            text,
            r'GRequestImageGenerationMutationData_requestImageGeneration_message',
            'text',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GRetryGenerationMutationData extends GRetryGenerationMutationData {
  @override
  final String G__typename;
  @override
  final GRetryGenerationMutationData_retryGeneration retryGeneration;

  factory _$GRetryGenerationMutationData([
    void Function(GRetryGenerationMutationDataBuilder)? updates,
  ]) => (GRetryGenerationMutationDataBuilder()..update(updates))._build();

  _$GRetryGenerationMutationData._({
    required this.G__typename,
    required this.retryGeneration,
  }) : super._();
  @override
  GRetryGenerationMutationData rebuild(
    void Function(GRetryGenerationMutationDataBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GRetryGenerationMutationDataBuilder toBuilder() =>
      GRetryGenerationMutationDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GRetryGenerationMutationData &&
        G__typename == other.G__typename &&
        retryGeneration == other.retryGeneration;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, retryGeneration.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GRetryGenerationMutationData')
          ..add('G__typename', G__typename)
          ..add('retryGeneration', retryGeneration))
        .toString();
  }
}

class GRetryGenerationMutationDataBuilder
    implements
        Builder<
          GRetryGenerationMutationData,
          GRetryGenerationMutationDataBuilder
        > {
  _$GRetryGenerationMutationData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GRetryGenerationMutationData_retryGenerationBuilder? _retryGeneration;
  GRetryGenerationMutationData_retryGenerationBuilder get retryGeneration =>
      _$this._retryGeneration ??=
          GRetryGenerationMutationData_retryGenerationBuilder();
  set retryGeneration(
    GRetryGenerationMutationData_retryGenerationBuilder? retryGeneration,
  ) => _$this._retryGeneration = retryGeneration;

  GRetryGenerationMutationDataBuilder() {
    GRetryGenerationMutationData._initializeBuilder(this);
  }

  GRetryGenerationMutationDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _retryGeneration = $v.retryGeneration.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GRetryGenerationMutationData other) {
    _$v = other as _$GRetryGenerationMutationData;
  }

  @override
  void update(void Function(GRetryGenerationMutationDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GRetryGenerationMutationData build() => _build();

  _$GRetryGenerationMutationData _build() {
    _$GRetryGenerationMutationData _$result;
    try {
      _$result =
          _$v ??
          _$GRetryGenerationMutationData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GRetryGenerationMutationData',
              'G__typename',
            ),
            retryGeneration: retryGeneration.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'retryGeneration';
        retryGeneration.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GRetryGenerationMutationData',
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

class _$GRetryGenerationMutationData_retryGeneration
    extends GRetryGenerationMutationData_retryGeneration {
  @override
  final String G__typename;
  @override
  final bool accepted;
  @override
  final _i2.GAcceptanceOutcome? outcome;
  @override
  final _i2.GCommandErrorCategory? errorCategory;
  @override
  final GRetryGenerationMutationData_retryGeneration_message message;

  factory _$GRetryGenerationMutationData_retryGeneration([
    void Function(GRetryGenerationMutationData_retryGenerationBuilder)? updates,
  ]) => (GRetryGenerationMutationData_retryGenerationBuilder()..update(updates))
      ._build();

  _$GRetryGenerationMutationData_retryGeneration._({
    required this.G__typename,
    required this.accepted,
    this.outcome,
    this.errorCategory,
    required this.message,
  }) : super._();
  @override
  GRetryGenerationMutationData_retryGeneration rebuild(
    void Function(GRetryGenerationMutationData_retryGenerationBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GRetryGenerationMutationData_retryGenerationBuilder toBuilder() =>
      GRetryGenerationMutationData_retryGenerationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GRetryGenerationMutationData_retryGeneration &&
        G__typename == other.G__typename &&
        accepted == other.accepted &&
        outcome == other.outcome &&
        errorCategory == other.errorCategory &&
        message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, accepted.hashCode);
    _$hash = $jc(_$hash, outcome.hashCode);
    _$hash = $jc(_$hash, errorCategory.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GRetryGenerationMutationData_retryGeneration',
          )
          ..add('G__typename', G__typename)
          ..add('accepted', accepted)
          ..add('outcome', outcome)
          ..add('errorCategory', errorCategory)
          ..add('message', message))
        .toString();
  }
}

class GRetryGenerationMutationData_retryGenerationBuilder
    implements
        Builder<
          GRetryGenerationMutationData_retryGeneration,
          GRetryGenerationMutationData_retryGenerationBuilder
        > {
  _$GRetryGenerationMutationData_retryGeneration? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  bool? _accepted;
  bool? get accepted => _$this._accepted;
  set accepted(bool? accepted) => _$this._accepted = accepted;

  _i2.GAcceptanceOutcome? _outcome;
  _i2.GAcceptanceOutcome? get outcome => _$this._outcome;
  set outcome(_i2.GAcceptanceOutcome? outcome) => _$this._outcome = outcome;

  _i2.GCommandErrorCategory? _errorCategory;
  _i2.GCommandErrorCategory? get errorCategory => _$this._errorCategory;
  set errorCategory(_i2.GCommandErrorCategory? errorCategory) =>
      _$this._errorCategory = errorCategory;

  GRetryGenerationMutationData_retryGeneration_messageBuilder? _message;
  GRetryGenerationMutationData_retryGeneration_messageBuilder get message =>
      _$this._message ??=
          GRetryGenerationMutationData_retryGeneration_messageBuilder();
  set message(
    GRetryGenerationMutationData_retryGeneration_messageBuilder? message,
  ) => _$this._message = message;

  GRetryGenerationMutationData_retryGenerationBuilder() {
    GRetryGenerationMutationData_retryGeneration._initializeBuilder(this);
  }

  GRetryGenerationMutationData_retryGenerationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _accepted = $v.accepted;
      _outcome = $v.outcome;
      _errorCategory = $v.errorCategory;
      _message = $v.message.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GRetryGenerationMutationData_retryGeneration other) {
    _$v = other as _$GRetryGenerationMutationData_retryGeneration;
  }

  @override
  void update(
    void Function(GRetryGenerationMutationData_retryGenerationBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GRetryGenerationMutationData_retryGeneration build() => _build();

  _$GRetryGenerationMutationData_retryGeneration _build() {
    _$GRetryGenerationMutationData_retryGeneration _$result;
    try {
      _$result =
          _$v ??
          _$GRetryGenerationMutationData_retryGeneration._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GRetryGenerationMutationData_retryGeneration',
              'G__typename',
            ),
            accepted: BuiltValueNullFieldError.checkNotNull(
              accepted,
              r'GRetryGenerationMutationData_retryGeneration',
              'accepted',
            ),
            outcome: outcome,
            errorCategory: errorCategory,
            message: message.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'message';
        message.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GRetryGenerationMutationData_retryGeneration',
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

class _$GRetryGenerationMutationData_retryGeneration_message
    extends GRetryGenerationMutationData_retryGeneration_message {
  @override
  final String G__typename;
  @override
  final String key;
  @override
  final String text;

  factory _$GRetryGenerationMutationData_retryGeneration_message([
    void Function(GRetryGenerationMutationData_retryGeneration_messageBuilder)?
    updates,
  ]) =>
      (GRetryGenerationMutationData_retryGeneration_messageBuilder()
            ..update(updates))
          ._build();

  _$GRetryGenerationMutationData_retryGeneration_message._({
    required this.G__typename,
    required this.key,
    required this.text,
  }) : super._();
  @override
  GRetryGenerationMutationData_retryGeneration_message rebuild(
    void Function(GRetryGenerationMutationData_retryGeneration_messageBuilder)
    updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GRetryGenerationMutationData_retryGeneration_messageBuilder toBuilder() =>
      GRetryGenerationMutationData_retryGeneration_messageBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GRetryGenerationMutationData_retryGeneration_message &&
        G__typename == other.G__typename &&
        key == other.key &&
        text == other.text;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jc(_$hash, text.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GRetryGenerationMutationData_retryGeneration_message',
          )
          ..add('G__typename', G__typename)
          ..add('key', key)
          ..add('text', text))
        .toString();
  }
}

class GRetryGenerationMutationData_retryGeneration_messageBuilder
    implements
        Builder<
          GRetryGenerationMutationData_retryGeneration_message,
          GRetryGenerationMutationData_retryGeneration_messageBuilder
        > {
  _$GRetryGenerationMutationData_retryGeneration_message? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

  String? _text;
  String? get text => _$this._text;
  set text(String? text) => _$this._text = text;

  GRetryGenerationMutationData_retryGeneration_messageBuilder() {
    GRetryGenerationMutationData_retryGeneration_message._initializeBuilder(
      this,
    );
  }

  GRetryGenerationMutationData_retryGeneration_messageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _key = $v.key;
      _text = $v.text;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GRetryGenerationMutationData_retryGeneration_message other) {
    _$v = other as _$GRetryGenerationMutationData_retryGeneration_message;
  }

  @override
  void update(
    void Function(GRetryGenerationMutationData_retryGeneration_messageBuilder)?
    updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GRetryGenerationMutationData_retryGeneration_message build() => _build();

  _$GRetryGenerationMutationData_retryGeneration_message _build() {
    final _$result =
        _$v ??
        _$GRetryGenerationMutationData_retryGeneration_message._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
            G__typename,
            r'GRetryGenerationMutationData_retryGeneration_message',
            'G__typename',
          ),
          key: BuiltValueNullFieldError.checkNotNull(
            key,
            r'GRetryGenerationMutationData_retryGeneration_message',
            'key',
          ),
          text: BuiltValueNullFieldError.checkNotNull(
            text,
            r'GRetryGenerationMutationData_retryGeneration_message',
            'text',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
