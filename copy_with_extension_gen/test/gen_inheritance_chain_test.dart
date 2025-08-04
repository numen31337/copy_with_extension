import 'dart:typed_data' as ns;

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:test/test.dart' show expect, isA, test, isNull;

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

  test('Nullable generic type arguments are preserved in inheritance chain',
      () {
    final result = ChildWithNullable(1).copyWith.b(null);
    expect(result, isA<ChildWithNullable>());
    expect(result.b, isNull);
  });

  test('Superclass field methods return subclass type when subclass skips fields', () {
    final child = ChildWithSkip(1, extra: 'foo');

    final result = child.copyWith.value(2);
    expect(result, isA<ChildWithSkip>());
    expect(result.value, 2);
    expect(result.extra, 'foo');
  });
}
