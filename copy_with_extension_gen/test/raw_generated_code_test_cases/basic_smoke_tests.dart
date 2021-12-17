part of 'source_gen_tests.dart';

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
