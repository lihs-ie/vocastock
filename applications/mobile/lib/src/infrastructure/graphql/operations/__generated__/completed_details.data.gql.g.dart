// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'completed_details.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GExplanationDetailQueryData>
_$gExplanationDetailQueryDataSerializer =
    _$GExplanationDetailQueryDataSerializer();
Serializer<GExplanationDetailQueryData_explanationDetail>
_$gExplanationDetailQueryDataExplanationDetailSerializer =
    _$GExplanationDetailQueryData_explanationDetailSerializer();
Serializer<GExplanationDetailQueryData_explanationDetail_pronunciation>
_$gExplanationDetailQueryDataExplanationDetailPronunciationSerializer =
    _$GExplanationDetailQueryData_explanationDetail_pronunciationSerializer();
Serializer<GExplanationDetailQueryData_explanationDetail_similarities>
_$gExplanationDetailQueryDataExplanationDetailSimilaritiesSerializer =
    _$GExplanationDetailQueryData_explanationDetail_similaritiesSerializer();
Serializer<GExplanationDetailQueryData_explanationDetail_senses>
_$gExplanationDetailQueryDataExplanationDetailSensesSerializer =
    _$GExplanationDetailQueryData_explanationDetail_sensesSerializer();
Serializer<GExplanationDetailQueryData_explanationDetail_senses_examples>
_$gExplanationDetailQueryDataExplanationDetailSensesExamplesSerializer =
    _$GExplanationDetailQueryData_explanationDetail_senses_examplesSerializer();
Serializer<GExplanationDetailQueryData_explanationDetail_senses_collocations>
_$gExplanationDetailQueryDataExplanationDetailSensesCollocationsSerializer =
    _$GExplanationDetailQueryData_explanationDetail_senses_collocationsSerializer();
Serializer<GImageDetailQueryData> _$gImageDetailQueryDataSerializer =
    _$GImageDetailQueryDataSerializer();
Serializer<GImageDetailQueryData_imageDetail>
_$gImageDetailQueryDataImageDetailSerializer =
    _$GImageDetailQueryData_imageDetailSerializer();

class _$GExplanationDetailQueryDataSerializer
    implements StructuredSerializer<GExplanationDetailQueryData> {
  @override
  final Iterable<Type> types = const [
    GExplanationDetailQueryData,
    _$GExplanationDetailQueryData,
  ];
  @override
  final String wireName = 'GExplanationDetailQueryData';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GExplanationDetailQueryData object, {
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
    value = object.explanationDetail;
    if (value != null) {
      result
        ..add('explanationDetail')
        ..add(
          serializers.serialize(
            value,
            specifiedType: const FullType(
              GExplanationDetailQueryData_explanationDetail,
            ),
          ),
        );
    }
    return result;
  }

  @override
  GExplanationDetailQueryData deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GExplanationDetailQueryDataBuilder();

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
        case 'explanationDetail':
          result.explanationDetail.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(
                    GExplanationDetailQueryData_explanationDetail,
                  ),
                )!
                as GExplanationDetailQueryData_explanationDetail,
          );
          break;
      }
    }

    return result.build();
  }
}

class _$GExplanationDetailQueryData_explanationDetailSerializer
    implements
        StructuredSerializer<GExplanationDetailQueryData_explanationDetail> {
  @override
  final Iterable<Type> types = const [
    GExplanationDetailQueryData_explanationDetail,
    _$GExplanationDetailQueryData_explanationDetail,
  ];
  @override
  final String wireName = 'GExplanationDetailQueryData_explanationDetail';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GExplanationDetailQueryData_explanationDetail object, {
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
      'vocabularyExpression',
      serializers.serialize(
        object.vocabularyExpression,
        specifiedType: const FullType(String),
      ),
      'text',
      serializers.serialize(object.text, specifiedType: const FullType(String)),
      'pronunciation',
      serializers.serialize(
        object.pronunciation,
        specifiedType: const FullType(
          GExplanationDetailQueryData_explanationDetail_pronunciation,
        ),
      ),
      'frequency',
      serializers.serialize(
        object.frequency,
        specifiedType: const FullType(_i2.GFrequencyLevel),
      ),
      'sophistication',
      serializers.serialize(
        object.sophistication,
        specifiedType: const FullType(_i2.GSophisticationLevel),
      ),
      'etymology',
      serializers.serialize(
        object.etymology,
        specifiedType: const FullType(String),
      ),
      'similarities',
      serializers.serialize(
        object.similarities,
        specifiedType: const FullType(BuiltList, const [
          const FullType(
            GExplanationDetailQueryData_explanationDetail_similarities,
          ),
        ]),
      ),
      'senses',
      serializers.serialize(
        object.senses,
        specifiedType: const FullType(BuiltList, const [
          const FullType(GExplanationDetailQueryData_explanationDetail_senses),
        ]),
      ),
    ];

    return result;
  }

  @override
  GExplanationDetailQueryData_explanationDetail deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GExplanationDetailQueryData_explanationDetailBuilder();

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
        case 'vocabularyExpression':
          result.vocabularyExpression =
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
        case 'pronunciation':
          result.pronunciation.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(
                    GExplanationDetailQueryData_explanationDetail_pronunciation,
                  ),
                )!
                as GExplanationDetailQueryData_explanationDetail_pronunciation,
          );
          break;
        case 'frequency':
          result.frequency =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(_i2.GFrequencyLevel),
                  )!
                  as _i2.GFrequencyLevel;
          break;
        case 'sophistication':
          result.sophistication =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(_i2.GSophisticationLevel),
                  )!
                  as _i2.GSophisticationLevel;
          break;
        case 'etymology':
          result.etymology =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'similarities':
          result.similarities.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(BuiltList, const [
                    const FullType(
                      GExplanationDetailQueryData_explanationDetail_similarities,
                    ),
                  ]),
                )!
                as BuiltList<Object?>,
          );
          break;
        case 'senses':
          result.senses.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(BuiltList, const [
                    const FullType(
                      GExplanationDetailQueryData_explanationDetail_senses,
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

class _$GExplanationDetailQueryData_explanationDetail_pronunciationSerializer
    implements
        StructuredSerializer<
          GExplanationDetailQueryData_explanationDetail_pronunciation
        > {
  @override
  final Iterable<Type> types = const [
    GExplanationDetailQueryData_explanationDetail_pronunciation,
    _$GExplanationDetailQueryData_explanationDetail_pronunciation,
  ];
  @override
  final String wireName =
      'GExplanationDetailQueryData_explanationDetail_pronunciation';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GExplanationDetailQueryData_explanationDetail_pronunciation object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(
        object.G__typename,
        specifiedType: const FullType(String),
      ),
      'weak',
      serializers.serialize(object.weak, specifiedType: const FullType(String)),
      'strong',
      serializers.serialize(
        object.strong,
        specifiedType: const FullType(String),
      ),
    ];

    return result;
  }

  @override
  GExplanationDetailQueryData_explanationDetail_pronunciation deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GExplanationDetailQueryData_explanationDetail_pronunciationBuilder();

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
        case 'weak':
          result.weak =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'strong':
          result.strong =
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

class _$GExplanationDetailQueryData_explanationDetail_similaritiesSerializer
    implements
        StructuredSerializer<
          GExplanationDetailQueryData_explanationDetail_similarities
        > {
  @override
  final Iterable<Type> types = const [
    GExplanationDetailQueryData_explanationDetail_similarities,
    _$GExplanationDetailQueryData_explanationDetail_similarities,
  ];
  @override
  final String wireName =
      'GExplanationDetailQueryData_explanationDetail_similarities';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GExplanationDetailQueryData_explanationDetail_similarities object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(
        object.G__typename,
        specifiedType: const FullType(String),
      ),
      'value',
      serializers.serialize(
        object.value,
        specifiedType: const FullType(String),
      ),
      'meaning',
      serializers.serialize(
        object.meaning,
        specifiedType: const FullType(String),
      ),
      'comparison',
      serializers.serialize(
        object.comparison,
        specifiedType: const FullType(String),
      ),
    ];

    return result;
  }

  @override
  GExplanationDetailQueryData_explanationDetail_similarities deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GExplanationDetailQueryData_explanationDetail_similaritiesBuilder();

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
        case 'value':
          result.value =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'meaning':
          result.meaning =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'comparison':
          result.comparison =
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

class _$GExplanationDetailQueryData_explanationDetail_sensesSerializer
    implements
        StructuredSerializer<
          GExplanationDetailQueryData_explanationDetail_senses
        > {
  @override
  final Iterable<Type> types = const [
    GExplanationDetailQueryData_explanationDetail_senses,
    _$GExplanationDetailQueryData_explanationDetail_senses,
  ];
  @override
  final String wireName =
      'GExplanationDetailQueryData_explanationDetail_senses';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GExplanationDetailQueryData_explanationDetail_senses object, {
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
      'order',
      serializers.serialize(object.order, specifiedType: const FullType(int)),
      'label',
      serializers.serialize(
        object.label,
        specifiedType: const FullType(String),
      ),
      'situation',
      serializers.serialize(
        object.situation,
        specifiedType: const FullType(String),
      ),
      'nuance',
      serializers.serialize(
        object.nuance,
        specifiedType: const FullType(String),
      ),
      'examples',
      serializers.serialize(
        object.examples,
        specifiedType: const FullType(BuiltList, const [
          const FullType(
            GExplanationDetailQueryData_explanationDetail_senses_examples,
          ),
        ]),
      ),
      'collocations',
      serializers.serialize(
        object.collocations,
        specifiedType: const FullType(BuiltList, const [
          const FullType(
            GExplanationDetailQueryData_explanationDetail_senses_collocations,
          ),
        ]),
      ),
    ];

    return result;
  }

  @override
  GExplanationDetailQueryData_explanationDetail_senses deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GExplanationDetailQueryData_explanationDetail_sensesBuilder();

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
        case 'order':
          result.order =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(int),
                  )!
                  as int;
          break;
        case 'label':
          result.label =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'situation':
          result.situation =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'nuance':
          result.nuance =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'examples':
          result.examples.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(BuiltList, const [
                    const FullType(
                      GExplanationDetailQueryData_explanationDetail_senses_examples,
                    ),
                  ]),
                )!
                as BuiltList<Object?>,
          );
          break;
        case 'collocations':
          result.collocations.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(BuiltList, const [
                    const FullType(
                      GExplanationDetailQueryData_explanationDetail_senses_collocations,
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

class _$GExplanationDetailQueryData_explanationDetail_senses_examplesSerializer
    implements
        StructuredSerializer<
          GExplanationDetailQueryData_explanationDetail_senses_examples
        > {
  @override
  final Iterable<Type> types = const [
    GExplanationDetailQueryData_explanationDetail_senses_examples,
    _$GExplanationDetailQueryData_explanationDetail_senses_examples,
  ];
  @override
  final String wireName =
      'GExplanationDetailQueryData_explanationDetail_senses_examples';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GExplanationDetailQueryData_explanationDetail_senses_examples object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(
        object.G__typename,
        specifiedType: const FullType(String),
      ),
      'value',
      serializers.serialize(
        object.value,
        specifiedType: const FullType(String),
      ),
      'meaning',
      serializers.serialize(
        object.meaning,
        specifiedType: const FullType(String),
      ),
    ];
    Object? value;
    value = object.pronunciation;
    if (value != null) {
      result
        ..add('pronunciation')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(String)),
        );
    }
    return result;
  }

  @override
  GExplanationDetailQueryData_explanationDetail_senses_examples deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GExplanationDetailQueryData_explanationDetail_senses_examplesBuilder();

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
        case 'value':
          result.value =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'meaning':
          result.meaning =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'pronunciation':
          result.pronunciation =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String?;
          break;
      }
    }

    return result.build();
  }
}

class _$GExplanationDetailQueryData_explanationDetail_senses_collocationsSerializer
    implements
        StructuredSerializer<
          GExplanationDetailQueryData_explanationDetail_senses_collocations
        > {
  @override
  final Iterable<Type> types = const [
    GExplanationDetailQueryData_explanationDetail_senses_collocations,
    _$GExplanationDetailQueryData_explanationDetail_senses_collocations,
  ];
  @override
  final String wireName =
      'GExplanationDetailQueryData_explanationDetail_senses_collocations';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GExplanationDetailQueryData_explanationDetail_senses_collocations object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(
        object.G__typename,
        specifiedType: const FullType(String),
      ),
      'value',
      serializers.serialize(
        object.value,
        specifiedType: const FullType(String),
      ),
      'meaning',
      serializers.serialize(
        object.meaning,
        specifiedType: const FullType(String),
      ),
    ];

    return result;
  }

  @override
  GExplanationDetailQueryData_explanationDetail_senses_collocations deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GExplanationDetailQueryData_explanationDetail_senses_collocationsBuilder();

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
        case 'value':
          result.value =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'meaning':
          result.meaning =
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

class _$GImageDetailQueryDataSerializer
    implements StructuredSerializer<GImageDetailQueryData> {
  @override
  final Iterable<Type> types = const [
    GImageDetailQueryData,
    _$GImageDetailQueryData,
  ];
  @override
  final String wireName = 'GImageDetailQueryData';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GImageDetailQueryData object, {
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
    value = object.imageDetail;
    if (value != null) {
      result
        ..add('imageDetail')
        ..add(
          serializers.serialize(
            value,
            specifiedType: const FullType(GImageDetailQueryData_imageDetail),
          ),
        );
    }
    return result;
  }

  @override
  GImageDetailQueryData deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GImageDetailQueryDataBuilder();

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
        case 'imageDetail':
          result.imageDetail.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(
                    GImageDetailQueryData_imageDetail,
                  ),
                )!
                as GImageDetailQueryData_imageDetail,
          );
          break;
      }
    }

    return result.build();
  }
}

class _$GImageDetailQueryData_imageDetailSerializer
    implements StructuredSerializer<GImageDetailQueryData_imageDetail> {
  @override
  final Iterable<Type> types = const [
    GImageDetailQueryData_imageDetail,
    _$GImageDetailQueryData_imageDetail,
  ];
  @override
  final String wireName = 'GImageDetailQueryData_imageDetail';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    GImageDetailQueryData_imageDetail object, {
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
      'explanation',
      serializers.serialize(
        object.explanation,
        specifiedType: const FullType(String),
      ),
      'assetReference',
      serializers.serialize(
        object.assetReference,
        specifiedType: const FullType(String),
      ),
      'description',
      serializers.serialize(
        object.description,
        specifiedType: const FullType(String),
      ),
    ];
    Object? value;
    value = object.senseIdentifier;
    if (value != null) {
      result
        ..add('senseIdentifier')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(String)),
        );
    }
    value = object.senseLabel;
    if (value != null) {
      result
        ..add('senseLabel')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(String)),
        );
    }
    return result;
  }

  @override
  GImageDetailQueryData_imageDetail deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GImageDetailQueryData_imageDetailBuilder();

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
        case 'explanation':
          result.explanation =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'assetReference':
          result.assetReference =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'description':
          result.description =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'senseIdentifier':
          result.senseIdentifier =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String?;
          break;
        case 'senseLabel':
          result.senseLabel =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String?;
          break;
      }
    }

    return result.build();
  }
}

class _$GExplanationDetailQueryData extends GExplanationDetailQueryData {
  @override
  final String G__typename;
  @override
  final GExplanationDetailQueryData_explanationDetail? explanationDetail;

  factory _$GExplanationDetailQueryData([
    void Function(GExplanationDetailQueryDataBuilder)? updates,
  ]) => (GExplanationDetailQueryDataBuilder()..update(updates))._build();

  _$GExplanationDetailQueryData._({
    required this.G__typename,
    this.explanationDetail,
  }) : super._();
  @override
  GExplanationDetailQueryData rebuild(
    void Function(GExplanationDetailQueryDataBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GExplanationDetailQueryDataBuilder toBuilder() =>
      GExplanationDetailQueryDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GExplanationDetailQueryData &&
        G__typename == other.G__typename &&
        explanationDetail == other.explanationDetail;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, explanationDetail.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GExplanationDetailQueryData')
          ..add('G__typename', G__typename)
          ..add('explanationDetail', explanationDetail))
        .toString();
  }
}

class GExplanationDetailQueryDataBuilder
    implements
        Builder<
          GExplanationDetailQueryData,
          GExplanationDetailQueryDataBuilder
        > {
  _$GExplanationDetailQueryData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GExplanationDetailQueryData_explanationDetailBuilder? _explanationDetail;
  GExplanationDetailQueryData_explanationDetailBuilder get explanationDetail =>
      _$this._explanationDetail ??=
          GExplanationDetailQueryData_explanationDetailBuilder();
  set explanationDetail(
    GExplanationDetailQueryData_explanationDetailBuilder? explanationDetail,
  ) => _$this._explanationDetail = explanationDetail;

  GExplanationDetailQueryDataBuilder() {
    GExplanationDetailQueryData._initializeBuilder(this);
  }

  GExplanationDetailQueryDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _explanationDetail = $v.explanationDetail?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GExplanationDetailQueryData other) {
    _$v = other as _$GExplanationDetailQueryData;
  }

  @override
  void update(void Function(GExplanationDetailQueryDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GExplanationDetailQueryData build() => _build();

  _$GExplanationDetailQueryData _build() {
    _$GExplanationDetailQueryData _$result;
    try {
      _$result =
          _$v ??
          _$GExplanationDetailQueryData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GExplanationDetailQueryData',
              'G__typename',
            ),
            explanationDetail: _explanationDetail?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'explanationDetail';
        _explanationDetail?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GExplanationDetailQueryData',
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

class _$GExplanationDetailQueryData_explanationDetail
    extends GExplanationDetailQueryData_explanationDetail {
  @override
  final String G__typename;
  @override
  final String identifier;
  @override
  final String vocabularyExpression;
  @override
  final String text;
  @override
  final GExplanationDetailQueryData_explanationDetail_pronunciation
  pronunciation;
  @override
  final _i2.GFrequencyLevel frequency;
  @override
  final _i2.GSophisticationLevel sophistication;
  @override
  final String etymology;
  @override
  final BuiltList<GExplanationDetailQueryData_explanationDetail_similarities>
  similarities;
  @override
  final BuiltList<GExplanationDetailQueryData_explanationDetail_senses> senses;

  factory _$GExplanationDetailQueryData_explanationDetail([
    void Function(GExplanationDetailQueryData_explanationDetailBuilder)?
    updates,
  ]) =>
      (GExplanationDetailQueryData_explanationDetailBuilder()..update(updates))
          ._build();

  _$GExplanationDetailQueryData_explanationDetail._({
    required this.G__typename,
    required this.identifier,
    required this.vocabularyExpression,
    required this.text,
    required this.pronunciation,
    required this.frequency,
    required this.sophistication,
    required this.etymology,
    required this.similarities,
    required this.senses,
  }) : super._();
  @override
  GExplanationDetailQueryData_explanationDetail rebuild(
    void Function(GExplanationDetailQueryData_explanationDetailBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GExplanationDetailQueryData_explanationDetailBuilder toBuilder() =>
      GExplanationDetailQueryData_explanationDetailBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GExplanationDetailQueryData_explanationDetail &&
        G__typename == other.G__typename &&
        identifier == other.identifier &&
        vocabularyExpression == other.vocabularyExpression &&
        text == other.text &&
        pronunciation == other.pronunciation &&
        frequency == other.frequency &&
        sophistication == other.sophistication &&
        etymology == other.etymology &&
        similarities == other.similarities &&
        senses == other.senses;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, identifier.hashCode);
    _$hash = $jc(_$hash, vocabularyExpression.hashCode);
    _$hash = $jc(_$hash, text.hashCode);
    _$hash = $jc(_$hash, pronunciation.hashCode);
    _$hash = $jc(_$hash, frequency.hashCode);
    _$hash = $jc(_$hash, sophistication.hashCode);
    _$hash = $jc(_$hash, etymology.hashCode);
    _$hash = $jc(_$hash, similarities.hashCode);
    _$hash = $jc(_$hash, senses.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GExplanationDetailQueryData_explanationDetail',
          )
          ..add('G__typename', G__typename)
          ..add('identifier', identifier)
          ..add('vocabularyExpression', vocabularyExpression)
          ..add('text', text)
          ..add('pronunciation', pronunciation)
          ..add('frequency', frequency)
          ..add('sophistication', sophistication)
          ..add('etymology', etymology)
          ..add('similarities', similarities)
          ..add('senses', senses))
        .toString();
  }
}

class GExplanationDetailQueryData_explanationDetailBuilder
    implements
        Builder<
          GExplanationDetailQueryData_explanationDetail,
          GExplanationDetailQueryData_explanationDetailBuilder
        > {
  _$GExplanationDetailQueryData_explanationDetail? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _identifier;
  String? get identifier => _$this._identifier;
  set identifier(String? identifier) => _$this._identifier = identifier;

  String? _vocabularyExpression;
  String? get vocabularyExpression => _$this._vocabularyExpression;
  set vocabularyExpression(String? vocabularyExpression) =>
      _$this._vocabularyExpression = vocabularyExpression;

  String? _text;
  String? get text => _$this._text;
  set text(String? text) => _$this._text = text;

  GExplanationDetailQueryData_explanationDetail_pronunciationBuilder?
  _pronunciation;
  GExplanationDetailQueryData_explanationDetail_pronunciationBuilder
  get pronunciation => _$this._pronunciation ??=
      GExplanationDetailQueryData_explanationDetail_pronunciationBuilder();
  set pronunciation(
    GExplanationDetailQueryData_explanationDetail_pronunciationBuilder?
    pronunciation,
  ) => _$this._pronunciation = pronunciation;

  _i2.GFrequencyLevel? _frequency;
  _i2.GFrequencyLevel? get frequency => _$this._frequency;
  set frequency(_i2.GFrequencyLevel? frequency) =>
      _$this._frequency = frequency;

  _i2.GSophisticationLevel? _sophistication;
  _i2.GSophisticationLevel? get sophistication => _$this._sophistication;
  set sophistication(_i2.GSophisticationLevel? sophistication) =>
      _$this._sophistication = sophistication;

  String? _etymology;
  String? get etymology => _$this._etymology;
  set etymology(String? etymology) => _$this._etymology = etymology;

  ListBuilder<GExplanationDetailQueryData_explanationDetail_similarities>?
  _similarities;
  ListBuilder<GExplanationDetailQueryData_explanationDetail_similarities>
  get similarities => _$this._similarities ??=
      ListBuilder<GExplanationDetailQueryData_explanationDetail_similarities>();
  set similarities(
    ListBuilder<GExplanationDetailQueryData_explanationDetail_similarities>?
    similarities,
  ) => _$this._similarities = similarities;

  ListBuilder<GExplanationDetailQueryData_explanationDetail_senses>? _senses;
  ListBuilder<GExplanationDetailQueryData_explanationDetail_senses>
  get senses => _$this._senses ??=
      ListBuilder<GExplanationDetailQueryData_explanationDetail_senses>();
  set senses(
    ListBuilder<GExplanationDetailQueryData_explanationDetail_senses>? senses,
  ) => _$this._senses = senses;

  GExplanationDetailQueryData_explanationDetailBuilder() {
    GExplanationDetailQueryData_explanationDetail._initializeBuilder(this);
  }

  GExplanationDetailQueryData_explanationDetailBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _identifier = $v.identifier;
      _vocabularyExpression = $v.vocabularyExpression;
      _text = $v.text;
      _pronunciation = $v.pronunciation.toBuilder();
      _frequency = $v.frequency;
      _sophistication = $v.sophistication;
      _etymology = $v.etymology;
      _similarities = $v.similarities.toBuilder();
      _senses = $v.senses.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GExplanationDetailQueryData_explanationDetail other) {
    _$v = other as _$GExplanationDetailQueryData_explanationDetail;
  }

  @override
  void update(
    void Function(GExplanationDetailQueryData_explanationDetailBuilder)?
    updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GExplanationDetailQueryData_explanationDetail build() => _build();

  _$GExplanationDetailQueryData_explanationDetail _build() {
    _$GExplanationDetailQueryData_explanationDetail _$result;
    try {
      _$result =
          _$v ??
          _$GExplanationDetailQueryData_explanationDetail._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GExplanationDetailQueryData_explanationDetail',
              'G__typename',
            ),
            identifier: BuiltValueNullFieldError.checkNotNull(
              identifier,
              r'GExplanationDetailQueryData_explanationDetail',
              'identifier',
            ),
            vocabularyExpression: BuiltValueNullFieldError.checkNotNull(
              vocabularyExpression,
              r'GExplanationDetailQueryData_explanationDetail',
              'vocabularyExpression',
            ),
            text: BuiltValueNullFieldError.checkNotNull(
              text,
              r'GExplanationDetailQueryData_explanationDetail',
              'text',
            ),
            pronunciation: pronunciation.build(),
            frequency: BuiltValueNullFieldError.checkNotNull(
              frequency,
              r'GExplanationDetailQueryData_explanationDetail',
              'frequency',
            ),
            sophistication: BuiltValueNullFieldError.checkNotNull(
              sophistication,
              r'GExplanationDetailQueryData_explanationDetail',
              'sophistication',
            ),
            etymology: BuiltValueNullFieldError.checkNotNull(
              etymology,
              r'GExplanationDetailQueryData_explanationDetail',
              'etymology',
            ),
            similarities: similarities.build(),
            senses: senses.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'pronunciation';
        pronunciation.build();

        _$failedField = 'similarities';
        similarities.build();
        _$failedField = 'senses';
        senses.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GExplanationDetailQueryData_explanationDetail',
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

class _$GExplanationDetailQueryData_explanationDetail_pronunciation
    extends GExplanationDetailQueryData_explanationDetail_pronunciation {
  @override
  final String G__typename;
  @override
  final String weak;
  @override
  final String strong;

  factory _$GExplanationDetailQueryData_explanationDetail_pronunciation([
    void Function(
      GExplanationDetailQueryData_explanationDetail_pronunciationBuilder,
    )?
    updates,
  ]) =>
      (GExplanationDetailQueryData_explanationDetail_pronunciationBuilder()
            ..update(updates))
          ._build();

  _$GExplanationDetailQueryData_explanationDetail_pronunciation._({
    required this.G__typename,
    required this.weak,
    required this.strong,
  }) : super._();
  @override
  GExplanationDetailQueryData_explanationDetail_pronunciation rebuild(
    void Function(
      GExplanationDetailQueryData_explanationDetail_pronunciationBuilder,
    )
    updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GExplanationDetailQueryData_explanationDetail_pronunciationBuilder
  toBuilder() =>
      GExplanationDetailQueryData_explanationDetail_pronunciationBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GExplanationDetailQueryData_explanationDetail_pronunciation &&
        G__typename == other.G__typename &&
        weak == other.weak &&
        strong == other.strong;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, weak.hashCode);
    _$hash = $jc(_$hash, strong.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GExplanationDetailQueryData_explanationDetail_pronunciation',
          )
          ..add('G__typename', G__typename)
          ..add('weak', weak)
          ..add('strong', strong))
        .toString();
  }
}

class GExplanationDetailQueryData_explanationDetail_pronunciationBuilder
    implements
        Builder<
          GExplanationDetailQueryData_explanationDetail_pronunciation,
          GExplanationDetailQueryData_explanationDetail_pronunciationBuilder
        > {
  _$GExplanationDetailQueryData_explanationDetail_pronunciation? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _weak;
  String? get weak => _$this._weak;
  set weak(String? weak) => _$this._weak = weak;

  String? _strong;
  String? get strong => _$this._strong;
  set strong(String? strong) => _$this._strong = strong;

  GExplanationDetailQueryData_explanationDetail_pronunciationBuilder() {
    GExplanationDetailQueryData_explanationDetail_pronunciation._initializeBuilder(
      this,
    );
  }

  GExplanationDetailQueryData_explanationDetail_pronunciationBuilder
  get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _weak = $v.weak;
      _strong = $v.strong;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
    GExplanationDetailQueryData_explanationDetail_pronunciation other,
  ) {
    _$v =
        other as _$GExplanationDetailQueryData_explanationDetail_pronunciation;
  }

  @override
  void update(
    void Function(
      GExplanationDetailQueryData_explanationDetail_pronunciationBuilder,
    )?
    updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GExplanationDetailQueryData_explanationDetail_pronunciation build() =>
      _build();

  _$GExplanationDetailQueryData_explanationDetail_pronunciation _build() {
    final _$result =
        _$v ??
        _$GExplanationDetailQueryData_explanationDetail_pronunciation._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
            G__typename,
            r'GExplanationDetailQueryData_explanationDetail_pronunciation',
            'G__typename',
          ),
          weak: BuiltValueNullFieldError.checkNotNull(
            weak,
            r'GExplanationDetailQueryData_explanationDetail_pronunciation',
            'weak',
          ),
          strong: BuiltValueNullFieldError.checkNotNull(
            strong,
            r'GExplanationDetailQueryData_explanationDetail_pronunciation',
            'strong',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GExplanationDetailQueryData_explanationDetail_similarities
    extends GExplanationDetailQueryData_explanationDetail_similarities {
  @override
  final String G__typename;
  @override
  final String value;
  @override
  final String meaning;
  @override
  final String comparison;

  factory _$GExplanationDetailQueryData_explanationDetail_similarities([
    void Function(
      GExplanationDetailQueryData_explanationDetail_similaritiesBuilder,
    )?
    updates,
  ]) =>
      (GExplanationDetailQueryData_explanationDetail_similaritiesBuilder()
            ..update(updates))
          ._build();

  _$GExplanationDetailQueryData_explanationDetail_similarities._({
    required this.G__typename,
    required this.value,
    required this.meaning,
    required this.comparison,
  }) : super._();
  @override
  GExplanationDetailQueryData_explanationDetail_similarities rebuild(
    void Function(
      GExplanationDetailQueryData_explanationDetail_similaritiesBuilder,
    )
    updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GExplanationDetailQueryData_explanationDetail_similaritiesBuilder
  toBuilder() =>
      GExplanationDetailQueryData_explanationDetail_similaritiesBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GExplanationDetailQueryData_explanationDetail_similarities &&
        G__typename == other.G__typename &&
        value == other.value &&
        meaning == other.meaning &&
        comparison == other.comparison;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, value.hashCode);
    _$hash = $jc(_$hash, meaning.hashCode);
    _$hash = $jc(_$hash, comparison.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GExplanationDetailQueryData_explanationDetail_similarities',
          )
          ..add('G__typename', G__typename)
          ..add('value', value)
          ..add('meaning', meaning)
          ..add('comparison', comparison))
        .toString();
  }
}

class GExplanationDetailQueryData_explanationDetail_similaritiesBuilder
    implements
        Builder<
          GExplanationDetailQueryData_explanationDetail_similarities,
          GExplanationDetailQueryData_explanationDetail_similaritiesBuilder
        > {
  _$GExplanationDetailQueryData_explanationDetail_similarities? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _value;
  String? get value => _$this._value;
  set value(String? value) => _$this._value = value;

  String? _meaning;
  String? get meaning => _$this._meaning;
  set meaning(String? meaning) => _$this._meaning = meaning;

  String? _comparison;
  String? get comparison => _$this._comparison;
  set comparison(String? comparison) => _$this._comparison = comparison;

  GExplanationDetailQueryData_explanationDetail_similaritiesBuilder() {
    GExplanationDetailQueryData_explanationDetail_similarities._initializeBuilder(
      this,
    );
  }

  GExplanationDetailQueryData_explanationDetail_similaritiesBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _value = $v.value;
      _meaning = $v.meaning;
      _comparison = $v.comparison;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
    GExplanationDetailQueryData_explanationDetail_similarities other,
  ) {
    _$v = other as _$GExplanationDetailQueryData_explanationDetail_similarities;
  }

  @override
  void update(
    void Function(
      GExplanationDetailQueryData_explanationDetail_similaritiesBuilder,
    )?
    updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GExplanationDetailQueryData_explanationDetail_similarities build() =>
      _build();

  _$GExplanationDetailQueryData_explanationDetail_similarities _build() {
    final _$result =
        _$v ??
        _$GExplanationDetailQueryData_explanationDetail_similarities._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
            G__typename,
            r'GExplanationDetailQueryData_explanationDetail_similarities',
            'G__typename',
          ),
          value: BuiltValueNullFieldError.checkNotNull(
            value,
            r'GExplanationDetailQueryData_explanationDetail_similarities',
            'value',
          ),
          meaning: BuiltValueNullFieldError.checkNotNull(
            meaning,
            r'GExplanationDetailQueryData_explanationDetail_similarities',
            'meaning',
          ),
          comparison: BuiltValueNullFieldError.checkNotNull(
            comparison,
            r'GExplanationDetailQueryData_explanationDetail_similarities',
            'comparison',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GExplanationDetailQueryData_explanationDetail_senses
    extends GExplanationDetailQueryData_explanationDetail_senses {
  @override
  final String G__typename;
  @override
  final String identifier;
  @override
  final int order;
  @override
  final String label;
  @override
  final String situation;
  @override
  final String nuance;
  @override
  final BuiltList<GExplanationDetailQueryData_explanationDetail_senses_examples>
  examples;
  @override
  final BuiltList<
    GExplanationDetailQueryData_explanationDetail_senses_collocations
  >
  collocations;

  factory _$GExplanationDetailQueryData_explanationDetail_senses([
    void Function(GExplanationDetailQueryData_explanationDetail_sensesBuilder)?
    updates,
  ]) =>
      (GExplanationDetailQueryData_explanationDetail_sensesBuilder()
            ..update(updates))
          ._build();

  _$GExplanationDetailQueryData_explanationDetail_senses._({
    required this.G__typename,
    required this.identifier,
    required this.order,
    required this.label,
    required this.situation,
    required this.nuance,
    required this.examples,
    required this.collocations,
  }) : super._();
  @override
  GExplanationDetailQueryData_explanationDetail_senses rebuild(
    void Function(GExplanationDetailQueryData_explanationDetail_sensesBuilder)
    updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GExplanationDetailQueryData_explanationDetail_sensesBuilder toBuilder() =>
      GExplanationDetailQueryData_explanationDetail_sensesBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GExplanationDetailQueryData_explanationDetail_senses &&
        G__typename == other.G__typename &&
        identifier == other.identifier &&
        order == other.order &&
        label == other.label &&
        situation == other.situation &&
        nuance == other.nuance &&
        examples == other.examples &&
        collocations == other.collocations;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, identifier.hashCode);
    _$hash = $jc(_$hash, order.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jc(_$hash, situation.hashCode);
    _$hash = $jc(_$hash, nuance.hashCode);
    _$hash = $jc(_$hash, examples.hashCode);
    _$hash = $jc(_$hash, collocations.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GExplanationDetailQueryData_explanationDetail_senses',
          )
          ..add('G__typename', G__typename)
          ..add('identifier', identifier)
          ..add('order', order)
          ..add('label', label)
          ..add('situation', situation)
          ..add('nuance', nuance)
          ..add('examples', examples)
          ..add('collocations', collocations))
        .toString();
  }
}

class GExplanationDetailQueryData_explanationDetail_sensesBuilder
    implements
        Builder<
          GExplanationDetailQueryData_explanationDetail_senses,
          GExplanationDetailQueryData_explanationDetail_sensesBuilder
        > {
  _$GExplanationDetailQueryData_explanationDetail_senses? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _identifier;
  String? get identifier => _$this._identifier;
  set identifier(String? identifier) => _$this._identifier = identifier;

  int? _order;
  int? get order => _$this._order;
  set order(int? order) => _$this._order = order;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  String? _situation;
  String? get situation => _$this._situation;
  set situation(String? situation) => _$this._situation = situation;

  String? _nuance;
  String? get nuance => _$this._nuance;
  set nuance(String? nuance) => _$this._nuance = nuance;

  ListBuilder<GExplanationDetailQueryData_explanationDetail_senses_examples>?
  _examples;
  ListBuilder<GExplanationDetailQueryData_explanationDetail_senses_examples>
  get examples => _$this._examples ??=
      ListBuilder<
        GExplanationDetailQueryData_explanationDetail_senses_examples
      >();
  set examples(
    ListBuilder<GExplanationDetailQueryData_explanationDetail_senses_examples>?
    examples,
  ) => _$this._examples = examples;

  ListBuilder<
    GExplanationDetailQueryData_explanationDetail_senses_collocations
  >?
  _collocations;
  ListBuilder<GExplanationDetailQueryData_explanationDetail_senses_collocations>
  get collocations => _$this._collocations ??=
      ListBuilder<
        GExplanationDetailQueryData_explanationDetail_senses_collocations
      >();
  set collocations(
    ListBuilder<
      GExplanationDetailQueryData_explanationDetail_senses_collocations
    >?
    collocations,
  ) => _$this._collocations = collocations;

  GExplanationDetailQueryData_explanationDetail_sensesBuilder() {
    GExplanationDetailQueryData_explanationDetail_senses._initializeBuilder(
      this,
    );
  }

  GExplanationDetailQueryData_explanationDetail_sensesBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _identifier = $v.identifier;
      _order = $v.order;
      _label = $v.label;
      _situation = $v.situation;
      _nuance = $v.nuance;
      _examples = $v.examples.toBuilder();
      _collocations = $v.collocations.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GExplanationDetailQueryData_explanationDetail_senses other) {
    _$v = other as _$GExplanationDetailQueryData_explanationDetail_senses;
  }

  @override
  void update(
    void Function(GExplanationDetailQueryData_explanationDetail_sensesBuilder)?
    updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GExplanationDetailQueryData_explanationDetail_senses build() => _build();

  _$GExplanationDetailQueryData_explanationDetail_senses _build() {
    _$GExplanationDetailQueryData_explanationDetail_senses _$result;
    try {
      _$result =
          _$v ??
          _$GExplanationDetailQueryData_explanationDetail_senses._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GExplanationDetailQueryData_explanationDetail_senses',
              'G__typename',
            ),
            identifier: BuiltValueNullFieldError.checkNotNull(
              identifier,
              r'GExplanationDetailQueryData_explanationDetail_senses',
              'identifier',
            ),
            order: BuiltValueNullFieldError.checkNotNull(
              order,
              r'GExplanationDetailQueryData_explanationDetail_senses',
              'order',
            ),
            label: BuiltValueNullFieldError.checkNotNull(
              label,
              r'GExplanationDetailQueryData_explanationDetail_senses',
              'label',
            ),
            situation: BuiltValueNullFieldError.checkNotNull(
              situation,
              r'GExplanationDetailQueryData_explanationDetail_senses',
              'situation',
            ),
            nuance: BuiltValueNullFieldError.checkNotNull(
              nuance,
              r'GExplanationDetailQueryData_explanationDetail_senses',
              'nuance',
            ),
            examples: examples.build(),
            collocations: collocations.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'examples';
        examples.build();
        _$failedField = 'collocations';
        collocations.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GExplanationDetailQueryData_explanationDetail_senses',
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

class _$GExplanationDetailQueryData_explanationDetail_senses_examples
    extends GExplanationDetailQueryData_explanationDetail_senses_examples {
  @override
  final String G__typename;
  @override
  final String value;
  @override
  final String meaning;
  @override
  final String? pronunciation;

  factory _$GExplanationDetailQueryData_explanationDetail_senses_examples([
    void Function(
      GExplanationDetailQueryData_explanationDetail_senses_examplesBuilder,
    )?
    updates,
  ]) =>
      (GExplanationDetailQueryData_explanationDetail_senses_examplesBuilder()
            ..update(updates))
          ._build();

  _$GExplanationDetailQueryData_explanationDetail_senses_examples._({
    required this.G__typename,
    required this.value,
    required this.meaning,
    this.pronunciation,
  }) : super._();
  @override
  GExplanationDetailQueryData_explanationDetail_senses_examples rebuild(
    void Function(
      GExplanationDetailQueryData_explanationDetail_senses_examplesBuilder,
    )
    updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GExplanationDetailQueryData_explanationDetail_senses_examplesBuilder
  toBuilder() =>
      GExplanationDetailQueryData_explanationDetail_senses_examplesBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GExplanationDetailQueryData_explanationDetail_senses_examples &&
        G__typename == other.G__typename &&
        value == other.value &&
        meaning == other.meaning &&
        pronunciation == other.pronunciation;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, value.hashCode);
    _$hash = $jc(_$hash, meaning.hashCode);
    _$hash = $jc(_$hash, pronunciation.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GExplanationDetailQueryData_explanationDetail_senses_examples',
          )
          ..add('G__typename', G__typename)
          ..add('value', value)
          ..add('meaning', meaning)
          ..add('pronunciation', pronunciation))
        .toString();
  }
}

class GExplanationDetailQueryData_explanationDetail_senses_examplesBuilder
    implements
        Builder<
          GExplanationDetailQueryData_explanationDetail_senses_examples,
          GExplanationDetailQueryData_explanationDetail_senses_examplesBuilder
        > {
  _$GExplanationDetailQueryData_explanationDetail_senses_examples? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _value;
  String? get value => _$this._value;
  set value(String? value) => _$this._value = value;

  String? _meaning;
  String? get meaning => _$this._meaning;
  set meaning(String? meaning) => _$this._meaning = meaning;

  String? _pronunciation;
  String? get pronunciation => _$this._pronunciation;
  set pronunciation(String? pronunciation) =>
      _$this._pronunciation = pronunciation;

  GExplanationDetailQueryData_explanationDetail_senses_examplesBuilder() {
    GExplanationDetailQueryData_explanationDetail_senses_examples._initializeBuilder(
      this,
    );
  }

  GExplanationDetailQueryData_explanationDetail_senses_examplesBuilder
  get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _value = $v.value;
      _meaning = $v.meaning;
      _pronunciation = $v.pronunciation;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
    GExplanationDetailQueryData_explanationDetail_senses_examples other,
  ) {
    _$v =
        other
            as _$GExplanationDetailQueryData_explanationDetail_senses_examples;
  }

  @override
  void update(
    void Function(
      GExplanationDetailQueryData_explanationDetail_senses_examplesBuilder,
    )?
    updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GExplanationDetailQueryData_explanationDetail_senses_examples build() =>
      _build();

  _$GExplanationDetailQueryData_explanationDetail_senses_examples _build() {
    final _$result =
        _$v ??
        _$GExplanationDetailQueryData_explanationDetail_senses_examples._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
            G__typename,
            r'GExplanationDetailQueryData_explanationDetail_senses_examples',
            'G__typename',
          ),
          value: BuiltValueNullFieldError.checkNotNull(
            value,
            r'GExplanationDetailQueryData_explanationDetail_senses_examples',
            'value',
          ),
          meaning: BuiltValueNullFieldError.checkNotNull(
            meaning,
            r'GExplanationDetailQueryData_explanationDetail_senses_examples',
            'meaning',
          ),
          pronunciation: pronunciation,
        );
    replace(_$result);
    return _$result;
  }
}

class _$GExplanationDetailQueryData_explanationDetail_senses_collocations
    extends GExplanationDetailQueryData_explanationDetail_senses_collocations {
  @override
  final String G__typename;
  @override
  final String value;
  @override
  final String meaning;

  factory _$GExplanationDetailQueryData_explanationDetail_senses_collocations([
    void Function(
      GExplanationDetailQueryData_explanationDetail_senses_collocationsBuilder,
    )?
    updates,
  ]) =>
      (GExplanationDetailQueryData_explanationDetail_senses_collocationsBuilder()
            ..update(updates))
          ._build();

  _$GExplanationDetailQueryData_explanationDetail_senses_collocations._({
    required this.G__typename,
    required this.value,
    required this.meaning,
  }) : super._();
  @override
  GExplanationDetailQueryData_explanationDetail_senses_collocations rebuild(
    void Function(
      GExplanationDetailQueryData_explanationDetail_senses_collocationsBuilder,
    )
    updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GExplanationDetailQueryData_explanationDetail_senses_collocationsBuilder
  toBuilder() =>
      GExplanationDetailQueryData_explanationDetail_senses_collocationsBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GExplanationDetailQueryData_explanationDetail_senses_collocations &&
        G__typename == other.G__typename &&
        value == other.value &&
        meaning == other.meaning;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, value.hashCode);
    _$hash = $jc(_$hash, meaning.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GExplanationDetailQueryData_explanationDetail_senses_collocations',
          )
          ..add('G__typename', G__typename)
          ..add('value', value)
          ..add('meaning', meaning))
        .toString();
  }
}

class GExplanationDetailQueryData_explanationDetail_senses_collocationsBuilder
    implements
        Builder<
          GExplanationDetailQueryData_explanationDetail_senses_collocations,
          GExplanationDetailQueryData_explanationDetail_senses_collocationsBuilder
        > {
  _$GExplanationDetailQueryData_explanationDetail_senses_collocations? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _value;
  String? get value => _$this._value;
  set value(String? value) => _$this._value = value;

  String? _meaning;
  String? get meaning => _$this._meaning;
  set meaning(String? meaning) => _$this._meaning = meaning;

  GExplanationDetailQueryData_explanationDetail_senses_collocationsBuilder() {
    GExplanationDetailQueryData_explanationDetail_senses_collocations._initializeBuilder(
      this,
    );
  }

  GExplanationDetailQueryData_explanationDetail_senses_collocationsBuilder
  get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _value = $v.value;
      _meaning = $v.meaning;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
    GExplanationDetailQueryData_explanationDetail_senses_collocations other,
  ) {
    _$v =
        other
            as _$GExplanationDetailQueryData_explanationDetail_senses_collocations;
  }

  @override
  void update(
    void Function(
      GExplanationDetailQueryData_explanationDetail_senses_collocationsBuilder,
    )?
    updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GExplanationDetailQueryData_explanationDetail_senses_collocations build() =>
      _build();

  _$GExplanationDetailQueryData_explanationDetail_senses_collocations _build() {
    final _$result =
        _$v ??
        _$GExplanationDetailQueryData_explanationDetail_senses_collocations._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
            G__typename,
            r'GExplanationDetailQueryData_explanationDetail_senses_collocations',
            'G__typename',
          ),
          value: BuiltValueNullFieldError.checkNotNull(
            value,
            r'GExplanationDetailQueryData_explanationDetail_senses_collocations',
            'value',
          ),
          meaning: BuiltValueNullFieldError.checkNotNull(
            meaning,
            r'GExplanationDetailQueryData_explanationDetail_senses_collocations',
            'meaning',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GImageDetailQueryData extends GImageDetailQueryData {
  @override
  final String G__typename;
  @override
  final GImageDetailQueryData_imageDetail? imageDetail;

  factory _$GImageDetailQueryData([
    void Function(GImageDetailQueryDataBuilder)? updates,
  ]) => (GImageDetailQueryDataBuilder()..update(updates))._build();

  _$GImageDetailQueryData._({required this.G__typename, this.imageDetail})
    : super._();
  @override
  GImageDetailQueryData rebuild(
    void Function(GImageDetailQueryDataBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GImageDetailQueryDataBuilder toBuilder() =>
      GImageDetailQueryDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GImageDetailQueryData &&
        G__typename == other.G__typename &&
        imageDetail == other.imageDetail;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, imageDetail.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GImageDetailQueryData')
          ..add('G__typename', G__typename)
          ..add('imageDetail', imageDetail))
        .toString();
  }
}

class GImageDetailQueryDataBuilder
    implements Builder<GImageDetailQueryData, GImageDetailQueryDataBuilder> {
  _$GImageDetailQueryData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GImageDetailQueryData_imageDetailBuilder? _imageDetail;
  GImageDetailQueryData_imageDetailBuilder get imageDetail =>
      _$this._imageDetail ??= GImageDetailQueryData_imageDetailBuilder();
  set imageDetail(GImageDetailQueryData_imageDetailBuilder? imageDetail) =>
      _$this._imageDetail = imageDetail;

  GImageDetailQueryDataBuilder() {
    GImageDetailQueryData._initializeBuilder(this);
  }

  GImageDetailQueryDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _imageDetail = $v.imageDetail?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GImageDetailQueryData other) {
    _$v = other as _$GImageDetailQueryData;
  }

  @override
  void update(void Function(GImageDetailQueryDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GImageDetailQueryData build() => _build();

  _$GImageDetailQueryData _build() {
    _$GImageDetailQueryData _$result;
    try {
      _$result =
          _$v ??
          _$GImageDetailQueryData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GImageDetailQueryData',
              'G__typename',
            ),
            imageDetail: _imageDetail?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'imageDetail';
        _imageDetail?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GImageDetailQueryData',
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

class _$GImageDetailQueryData_imageDetail
    extends GImageDetailQueryData_imageDetail {
  @override
  final String G__typename;
  @override
  final String identifier;
  @override
  final String explanation;
  @override
  final String assetReference;
  @override
  final String description;
  @override
  final String? senseIdentifier;
  @override
  final String? senseLabel;

  factory _$GImageDetailQueryData_imageDetail([
    void Function(GImageDetailQueryData_imageDetailBuilder)? updates,
  ]) => (GImageDetailQueryData_imageDetailBuilder()..update(updates))._build();

  _$GImageDetailQueryData_imageDetail._({
    required this.G__typename,
    required this.identifier,
    required this.explanation,
    required this.assetReference,
    required this.description,
    this.senseIdentifier,
    this.senseLabel,
  }) : super._();
  @override
  GImageDetailQueryData_imageDetail rebuild(
    void Function(GImageDetailQueryData_imageDetailBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GImageDetailQueryData_imageDetailBuilder toBuilder() =>
      GImageDetailQueryData_imageDetailBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GImageDetailQueryData_imageDetail &&
        G__typename == other.G__typename &&
        identifier == other.identifier &&
        explanation == other.explanation &&
        assetReference == other.assetReference &&
        description == other.description &&
        senseIdentifier == other.senseIdentifier &&
        senseLabel == other.senseLabel;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, identifier.hashCode);
    _$hash = $jc(_$hash, explanation.hashCode);
    _$hash = $jc(_$hash, assetReference.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, senseIdentifier.hashCode);
    _$hash = $jc(_$hash, senseLabel.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GImageDetailQueryData_imageDetail')
          ..add('G__typename', G__typename)
          ..add('identifier', identifier)
          ..add('explanation', explanation)
          ..add('assetReference', assetReference)
          ..add('description', description)
          ..add('senseIdentifier', senseIdentifier)
          ..add('senseLabel', senseLabel))
        .toString();
  }
}

class GImageDetailQueryData_imageDetailBuilder
    implements
        Builder<
          GImageDetailQueryData_imageDetail,
          GImageDetailQueryData_imageDetailBuilder
        > {
  _$GImageDetailQueryData_imageDetail? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _identifier;
  String? get identifier => _$this._identifier;
  set identifier(String? identifier) => _$this._identifier = identifier;

  String? _explanation;
  String? get explanation => _$this._explanation;
  set explanation(String? explanation) => _$this._explanation = explanation;

  String? _assetReference;
  String? get assetReference => _$this._assetReference;
  set assetReference(String? assetReference) =>
      _$this._assetReference = assetReference;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  String? _senseIdentifier;
  String? get senseIdentifier => _$this._senseIdentifier;
  set senseIdentifier(String? senseIdentifier) =>
      _$this._senseIdentifier = senseIdentifier;

  String? _senseLabel;
  String? get senseLabel => _$this._senseLabel;
  set senseLabel(String? senseLabel) => _$this._senseLabel = senseLabel;

  GImageDetailQueryData_imageDetailBuilder() {
    GImageDetailQueryData_imageDetail._initializeBuilder(this);
  }

  GImageDetailQueryData_imageDetailBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _identifier = $v.identifier;
      _explanation = $v.explanation;
      _assetReference = $v.assetReference;
      _description = $v.description;
      _senseIdentifier = $v.senseIdentifier;
      _senseLabel = $v.senseLabel;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GImageDetailQueryData_imageDetail other) {
    _$v = other as _$GImageDetailQueryData_imageDetail;
  }

  @override
  void update(
    void Function(GImageDetailQueryData_imageDetailBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  GImageDetailQueryData_imageDetail build() => _build();

  _$GImageDetailQueryData_imageDetail _build() {
    final _$result =
        _$v ??
        _$GImageDetailQueryData_imageDetail._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
            G__typename,
            r'GImageDetailQueryData_imageDetail',
            'G__typename',
          ),
          identifier: BuiltValueNullFieldError.checkNotNull(
            identifier,
            r'GImageDetailQueryData_imageDetail',
            'identifier',
          ),
          explanation: BuiltValueNullFieldError.checkNotNull(
            explanation,
            r'GImageDetailQueryData_imageDetail',
            'explanation',
          ),
          assetReference: BuiltValueNullFieldError.checkNotNull(
            assetReference,
            r'GImageDetailQueryData_imageDetail',
            'assetReference',
          ),
          description: BuiltValueNullFieldError.checkNotNull(
            description,
            r'GImageDetailQueryData_imageDetail',
            'description',
          ),
          senseIdentifier: senseIdentifier,
          senseLabel: senseLabel,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
