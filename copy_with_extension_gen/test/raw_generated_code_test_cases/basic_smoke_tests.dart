part of 'source_gen_tests.dart';

@ShouldThrow(
  'Only classes can be annotated with "CopyWith". "int? wrongAnnotation" is not a ClassElement.',
)
@CopyWith()
int? wrongAnnotation;

@ShouldThrow(
  'Only classes can be annotated with "CopyWith". "Object wrongAnnotation1" is not a ClassElement.',
)
@CopyWith()
Object wrongAnnotation1 = Object();

//TODO: Correct, there is no constructor at all. There is no constructor message here.
@ShouldThrow('Unnamed constructor for NoConstructor has no parameters.')
@CopyWith()
class NoConstructor {}

@ShouldThrow('Named Constructor "test" constructor is missing.')
@CopyWith(namedConstructor: "test")
class WrongConstructor {}

@ShouldGenerate(r'''
class _BasicClassCopyWithProxy {
  final BasicClass _value;

  _BasicClassCopyWithProxy(this._value);

  BasicClass optional(String? optional) => optional == null
      ? _value._copyWithNull(optional: true)
      : _value._copyWithValues(optional: optional);

  BasicClass id(String id) => _value._copyWithValues(id: id);
}

extension BasicClassCopyWith on BasicClass {
  _BasicClassCopyWithProxy get copyWith => _BasicClassCopyWithProxy(this);

  BasicClass _copyWithValues({
    String? id,
    String? optional,
  }) {
    return BasicClass(
      id: id ?? this.id,
      immutable: immutable,
      nullableImmutable: nullableImmutable,
      optional: optional ?? this.optional,
    );
  }

  BasicClass _copyWithNull({
    bool optional = false,
  }) {
    return BasicClass(
      id: id,
      immutable: immutable,
      nullableImmutable: nullableImmutable,
      optional: optional == true ? null : this.optional,
    );
  }
}
''')
@immutable
@CopyWith()
class BasicClass {
  final String id;
  final String? optional;
  @CopyWithField(immutable: true)
  final int immutable;
  @CopyWithField(immutable: true)
  final int nullableImmutable;

  const BasicClass({
    required this.id,
    this.optional,
    required this.immutable,
    required this.nullableImmutable,
  });
}
