part of 'source_gen_tests.dart';

@ShouldGenerate(r'''
class _BasicClassCopyWithProxy<T extends Iterable<int>> {
  final BasicClass<T> _value;

  const _BasicClassCopyWithProxy(this._value);

  BasicClass optional(T? optional) => optional == null
      ? _value._copyWithNull(optional: true)
      : _value._copyWithValues(optional: optional);

  BasicClass id(String id) => _value._copyWithValues(id: id);
}

extension BasicClassCopyWith<T extends Iterable<int>> on BasicClass<T> {
  _BasicClassCopyWithProxy get copyWith => _BasicClassCopyWithProxy<T>(this);

  BasicClass<T> _copyWithValues({
    String? id,
    T? optional,
  }) {
    return BasicClass<T>(
      id: id ?? this.id,
      immutable: immutable,
      nullableImmutable: nullableImmutable,
      optional: optional ?? this.optional,
    );
  }

  BasicClass<T> _copyWithNull({
    bool optional = false,
  }) {
    return BasicClass<T>(
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
class BasicClass<T extends Iterable<int>> {
  final String id;
  final T? optional;
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
