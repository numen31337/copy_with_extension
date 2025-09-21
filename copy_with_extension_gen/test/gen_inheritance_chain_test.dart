import 'dart:typed_data' as ns;

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:test/test.dart';

import 'helpers/gen_cross_library_parent.dart' as cross_lib;

part 'gen_inheritance_chain_test.g.dart';

@CopyWith()
class CopyA {
  const CopyA({required this.a});

  final String a;
}

@CopyWith()
class CopyB<T> extends CopyA {
  const CopyB({required super.a, this.b});

  final T? b;
}

class NoCopyC extends CopyB<int> {
  const NoCopyC(this._secret, {required super.a, super.b, required this.c});

  final double c;
  final int _secret;
}

@CopyWith()
class CopyD extends NoCopyC {
  const CopyD(
    super._secret, {
    required super.a,
    super.b,
    required super.c,
    required this.d,
    this.data,
  });

  final bool d;
  final ns.Uint16List? data;
}

@CopyWith()
class Parent<T> {
  Parent(this.value);
  final T value;
}

@CopyWith()
class Child extends Parent<int?> {
  Child(super.value);
}

@CopyWith()
class ChildWithNullable extends CopyB<int?> {
  ChildWithNullable(int? value) : super(a: '', b: value);
}

@CopyWith(skipFields: true)
class ChildWithSkip extends Parent<int> {
  ChildWithSkip(super.value, {this.extra});

  final String? extra;
}

@CopyWith()
class GrandGeneric<T> {
  const GrandGeneric(this.value);

  final T value;
}

@CopyWith()
class ParentGeneric<U> extends GrandGeneric<List<U>> {
  const ParentGeneric(super.value);
}

@CopyWith()
class ChildGeneric<V> extends ParentGeneric<Set<V>> {
  const ChildGeneric(super.value);
}

@CopyWith()
class BaseBound<T> {
  const BaseBound({required this.value});

  final T value;
}

@CopyWith()
class BoundedChild<S extends int> extends BaseBound<List<S>> {
  const BoundedChild({required super.value, required this.extra});

  final S extra;
}

@CopyWith()
class ReorderParent<TFirst, TSecond> {
  ReorderParent(this.a, this.b);
  final TFirst a;
  final TSecond b;
}

@CopyWith()
class ReorderChild<X, Y> extends ReorderParent<Y, X> {
  ReorderChild(super.a, super.b);
}

@CopyWith()
class CrossLibraryChild extends cross_lib.CrossLibraryParent {
  const CrossLibraryChild({required super.value, required this.child});

  final int child;
}

@CopyWith()
class A {
  A({this.a});

  final int? a;
}

@CopyWith()
class B extends A {
  B({required this.b}) : super();

  final int b;
}

void main() {
  test(
    'Deep chain preserves subclass fields, generics, namespaces and private constructor params',
    () {
      final leaf = CopyD(
        0,
        a: 'a',
        b: 1,
        c: 2.0,
        d: true,
        data: ns.Uint16List(1),
      );
      expect(leaf.data, isA<ns.Uint16List>());
      expect(leaf._secret, 0);

      // Field methods handle namespaced, generic and unannotated fields.
      final withValues =
          leaf.copyWith.data(ns.Uint16List(2)).copyWith.b(2).copyWith.c(3.0);
      expect(withValues.data, isA<ns.Uint16List>());
      expect(withValues.b, 2);
      expect(withValues.c, 3.0);
      expect(withValues._secret, 0);

      // Call method with base-typed instance updates fields and allows nulls.
      CopyA base = withValues;
      final called = (base as CopyD).copyWith(
        a: 'a2',
        data: null,
        b: null,
        c: 4.0,
      );
      expect(called.runtimeType, leaf.runtimeType);
      expect(called.a, 'a2');
      expect(called.b, null);
      expect(called.c, 4.0);
      expect(called.d, true);
      expect(called.data, null);
      expect(called._secret, 0);

      // Field methods allow single-field updates with null while retaining other values.
      final fielded = withValues.copyWith.a('a3').copyWith.data(null);
      expect(fielded.runtimeType, leaf.runtimeType);
      expect(fielded.a, 'a3');
      expect(fielded.b, 2);
      expect(fielded.c, 3.0);
      expect(fielded.d, true);
      expect(fielded.data, null);
      expect(fielded._secret, 0);
    },
  );

  test('Nullable generic type arguments are preserved in inheritance', () {
    final result = Child(1).copyWith.value(null);
    expect(result, isA<Child>());
    expect(result.value, isNull);
  });

  test(
    'Nullable generic type arguments are preserved in inheritance chain',
    () {
      final result = ChildWithNullable(1).copyWith.b(null);
      expect(result, isA<ChildWithNullable>());
      expect(result.b, isNull);
    },
  );

  test(
    'Superclass field methods return subclass type when subclass skips fields',
    () {
      final child = ChildWithSkip(1, extra: 'foo');

      final result = child.copyWith.value(2);
      expect(result, isA<ChildWithSkip>());
      expect(result.value, 2);
      expect(result.extra, 'foo');
    },
  );

  test(
    'Subclass omitting optional super field does not inherit parent proxy',
    () {
      final b = B(b: 0);

      final dynamic proxy = b.copyWith;
      expect(() => proxy.a(1), throwsNoSuchMethodError);

      final result = b.copyWith.b(1);
      expect(result, isA<B>());
      expect(result.b, 1);
    },
  );

  test('copyWith handles deep generic inheritance chains', () {
    final leaf = ChildGeneric<int>([
      {1},
    ]);

    final leafCopy = leaf.copyWith.value([
      {2},
    ]);
    expect(leafCopy, isA<ChildGeneric<int>>());
    expect(leafCopy.value.single.contains(2), true);

    ParentGeneric<Set<int>> parent = leaf;
    final parentCopy = parent.copyWith(
      value: [
        {3},
      ],
    );
    expect(parentCopy, isA<ParentGeneric<Set<int>>>());
    expect(parentCopy.value.single.contains(3), true);

    GrandGeneric<List<Set<int>>> grand = leaf;
    final grandCopy = grand.copyWith.value([
      {4},
    ]);
    expect(grandCopy, isA<GrandGeneric<List<Set<int>>>>());
    expect(grandCopy.value.single.contains(4), true);
  });

  test('Nested generics with bounds propagate through inheritance', () {
    final child = BoundedChild<int>(value: const [1], extra: 2);

    final valueCopy = child.copyWith.value(const [3]);
    expect(valueCopy, isA<BoundedChild<int>>());
    expect(valueCopy.value, [3]);
    expect(valueCopy.extra, 2);

    final extraCopy = child.copyWith.extra(3);
    expect(extraCopy.extra, 3);
    expect(extraCopy.value, [1]);

    BaseBound<List<int>> base = child;
    final baseCopy = base.copyWith(value: const [4]);
    expect(baseCopy, isA<BaseBound<List<int>>>());
    expect(baseCopy.value, [4]);
  });

  test('copyWith inlines cross-library super proxies', () {
    final child = CrossLibraryChild(value: 1, child: 2);

    final delegated = child.copyWith.value(3);
    expect(delegated, isA<CrossLibraryChild>());
    expect(delegated.value, 3);
    expect(delegated.child, 2);

    final updated = child.copyWith(value: 4, child: 5);
    expect(updated, isA<CrossLibraryChild>());
    expect(updated.value, 4);
    expect(updated.child, 5);
  });

  test('copyWith preserves subclass type with reordered generics', () {
    final child = ReorderChild<int, String>('s', 1);
    final copy = child.copyWith.a('t');
    expect(copy, isA<ReorderChild<int, String>>());
  });
}
