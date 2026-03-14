import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:test/test.dart';

part 'gen_type_alias_test.g.dart';

typedef MyInt = int;
typedef MyList<T> = List<T>;
typedef DeepTypeDef<T> = MyList<MyList<MyInt>>; // ignore: unused_type_parameter

@CopyWith()
class AliasField {
  const AliasField({
    required this.value,
    required this.list,
    required this.deep,
    required this.nested,
  });

  final MyInt value;
  final MyList<int> list;
  final DeepTypeDef<String> deep;
  final MyList<MyList<MyInt>> nested;
}

@CopyWith()
class RealBase {
  const RealBase({required this.a});

  final int a;
}

typedef BaseAlias = RealBase;

@CopyWith()
class SubViaAlias extends BaseAlias {
  const SubViaAlias({required super.a, this.b});

  final String? b;
}

@CopyWith()
class GenericAliasParent<T, U> {
  const GenericAliasParent({required this.first, required this.second});

  final T first;
  final U second;
}

typedef GenericAlias<T, U, V> = GenericAliasParent<T, U>;

@CopyWith()
class SubViaGenericAlias extends GenericAlias<int, String, bool> {
  const SubViaGenericAlias({
    required super.first,
    required super.second,
    required this.extra,
  });

  final double extra;
}

void main() {
  test('copyWith recognizes annotated superclass referenced via typedef', () {
    final result = SubViaAlias(a: 1, b: 'x').copyWith(a: 2);
    expect(result, isA<SubViaAlias>());
    expect(result.a, 2);
    expect(result.b, 'x');
  });

  test('field proxy works with superclass typedef', () {
    final result = SubViaAlias(a: 1, b: 'x').copyWith.a(3);
    expect(result, isA<SubViaAlias>());
    expect(result.a, 3);
    expect(result.b, 'x');
  });

  test('field proxy works with alias that has extra type parameters', () {
    final source = SubViaGenericAlias(first: 1, second: 'x', extra: 1.5);

    final firstUpdated = source.copyWith.first(2);
    expect(firstUpdated, isA<SubViaGenericAlias>());
    expect(firstUpdated.first, 2);
    expect(firstUpdated.second, 'x');
    expect(firstUpdated.extra, 1.5);

    final secondUpdated = source.copyWith(second: 'y');
    expect(secondUpdated, isA<SubViaGenericAlias>());
    expect(secondUpdated.first, 1);
    expect(secondUpdated.second, 'y');
    expect(secondUpdated.extra, 1.5);
  });
}
