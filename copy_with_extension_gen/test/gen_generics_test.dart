import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:test/test.dart';

part 'gen_generics_test.g.dart';

@CopyWith(copyWithNull: true)
class Generics<G, T extends Iterable<G>> {
  const Generics({
    required this.basicGeneric,
    required this.genericFromClass,
    this.deepNestedGeneric,
    required this.nullableGeneric,
  });

  final List<int> basicGeneric;
  final List<T> genericFromClass;
  final List<String?> nullableGeneric;
  final List<List<List<int?>?>>? deepNestedGeneric;
}

@CopyWith()
class Node<T extends Node<T>> {
  Node(this.next);
  final T? next;
}

@CopyWith()
class IntNode extends Node<IntNode> {
  IntNode(super.next);
}

void main() {
  group('Generics', () {
    late Generics<bool, List<bool>> generic;

    setUp(() {
      generic = const Generics<bool, List<bool>>(
        basicGeneric: [],
        genericFromClass: [],
        nullableGeneric: [],
        deepNestedGeneric: [],
      ).copyWith().copyWithNull();
    });

    test('basicGeneric type', () {
      expect(generic.basicGeneric.runtimeType, <int>[].runtimeType);
    });

    test('genericFromClass type', () {
      expect(generic.genericFromClass.runtimeType, <List<bool>>[].runtimeType);
    });

    test('genericFromClass copy retains type', () {
      expect(
        generic.copyWith.genericFromClass([]).genericFromClass.runtimeType,
        <List<bool>>[].runtimeType,
      );
    });

    test('genericFromClass value access', () {
      expect(
        generic.copyWith
            .genericFromClass([
              [true],
            ])
            .genericFromClass
            .first
            .first,
        true,
      );
    });

    test('nullableGeneric type', () {
      expect(generic.nullableGeneric.runtimeType, <String?>[].runtimeType);
    });

    test('copyWith.nullableGeneric type', () {
      expect(
        generic.copyWith.nullableGeneric([]).nullableGeneric.runtimeType,
        <String?>[].runtimeType,
      );
    });

    test('copyWith.nullableGeneric preserves values', () {
      expect(
        generic.copyWith.nullableGeneric(['1', null, '2']).nullableGeneric,
        ['1', null, '2'],
      );
    });

    test('deepNestedGeneric type', () {
      expect(
        generic.deepNestedGeneric.runtimeType,
        <List<List<int?>?>>[].runtimeType,
      );
    });

    test('copyWith.deepNestedGeneric type', () {
      expect(
        generic.copyWith.deepNestedGeneric([]).deepNestedGeneric.runtimeType,
        <List<List<int?>?>>[].runtimeType,
      );
    });
  });

  test('F-bounded generics', () {
    final copy = IntNode(null).copyWith.next(IntNode(null));
    expect(copy, isA<IntNode>());
  });
}
