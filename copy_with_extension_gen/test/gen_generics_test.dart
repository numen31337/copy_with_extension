import 'package:meta/meta.dart' show immutable;
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:test/test.dart';

part 'gen_generics_test.g.dart';

@immutable
@CopyWith(copyWithNull: true)
class Generics<G, T extends Iterable<G>> {
  final List<int> basicGeneric;
  final List<T> genericFromClass;
  final List<String?> nullableGeneric;
  final List<List<List<int?>?>>? deepNestedGeneric;

  const Generics({
    required this.basicGeneric,
    required this.genericFromClass,
    this.deepNestedGeneric,
    required this.nullableGeneric,
  });
}

void main() {
  test('Generics', () {
    final generic = const Generics<bool, List<bool>>(
        basicGeneric: [],
        genericFromClass: [],
        nullableGeneric: [],
        deepNestedGeneric: []).copyWith().copyWithNull();

    expect(
      generic.basicGeneric.runtimeType,
      <int>[].runtimeType,
    );

    expect(
      generic.genericFromClass.runtimeType,
      <List<bool>>[].runtimeType,
    );

    expect(
      generic.nullableGeneric.runtimeType,
      <String?>[].runtimeType,
    );

    expect(
      generic.deepNestedGeneric.runtimeType,
      <List<List<int?>?>>[].runtimeType,
    );
  });
}
