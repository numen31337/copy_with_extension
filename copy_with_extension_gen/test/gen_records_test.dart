import 'dart:async';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:test/test.dart';

part 'gen_records_test.g.dart';

@CopyWith(copyWithNull: true)
typedef Person = ({String name, int? age});

@CopyWith(copyWithNull: true)
typedef Box<T> = ({T value});

@CopyWith(copyWithNull: true)
typedef Optional<T> = ({T? optional});

@CopyWith(copyWithNull: true)
typedef Bounded<T extends num?> = ({T bounded});

@CopyWith(copyWithNull: true)
typedef Later<T> = ({FutureOr<T> later});

@CopyWith(copyWithNull: true, constructor: null)
typedef OptionalLater<T> = ({FutureOr<T?> optionalLater});

@CopyWith()
typedef Pair<T extends num> = (T first, T second);

@CopyWith()
typedef Single<T> = (T,);

@CopyWith()
typedef Empty = ();

@CopyWith(immutableFields: true, copyWithNull: true)
typedef Frozen<T> = ({T T});

@CopyWith(skipFields: true)
typedef Callable = ({int call});

@CopyWith(immutableFields: true)
typedef FrozenEmpty = ();

@CopyWith(immutableFields: false)
typedef Mixed = (int, {String label, int $3});

@CopyWith()
typedef NamedDollar = ({int $1});

@CopyWith(copyWithNull: true)
typedef Shadowed = ({int copyWith, String? copyWithNull});

@CopyWith()
typedef Holding = ({List<int> items, (String, {int count}) inner, Cycle child});

class Cycle {
  Holding? parent;
}

@CopyWith(copyWithNull: true)
typedef Special = ({Null nil, Never? bottom, dynamic any, Object? object});

@CopyWith()
typedef Impossible = ({Never impossible, int count});

@CopyWith()
typedef Functions<T> =
    ({T Function<U extends num>(U) convert, void Function() done});

@CopyWith()
typedef MutableShape = ({int policy, String tag});

@CopyWith(immutableFields: true)
typedef FrozenShape = ({String tag, int policy});

@CopyWith()
typedef Broad = ({num specificity});

@CopyWith()
typedef Specific = ({int specificity});

@CopyWith()
typedef Left = ({int left, num right});

@CopyWith()
typedef Right = ({num left, int right});

@CopyWith()
typedef _Private = ({int privateValue});

class ThrowsEquality {
  @override
  bool operator ==(Object other) =>
      throw StateError('Must not compare the value');

  @override
  int get hashCode => 0;
}

void main() {
  test('positional, mixed, singleton, named-dollar and empty forms', () {
    const Pair<int> pair = (1, 2);
    final Pair<int> changed = pair.copyWith($1: 3, $2: 4);
    expect(changed, (3, 4));
    expect(pair.copyWith.$2(5), (1, 5));
    expect($SingleCopyWith<String>(('a',)).copyWith.$1('b'), ('b',));
    expect($EmptyCopyWith(()).copyWith(), ());
    expect($FrozenEmptyCopyWith(()).copyWith(), ());
    const Mixed mixed = (1, label: 'old', $3: 3);
    expect(mixed.copyWith($1: 2, label: 'new', $3: 4), (
      2,
      label: 'new',
      $3: 4,
    ));
    expect(($1: 1).copyWith.$1(2), ($1: 2));
  });

  test('nullable generic instantiations distinguish omission from null', () {
    const Box<String?> nullable = (value: 'old');
    final Box<String?> copy = nullable.copyWith(value: null);
    final Box<String?> Function(String?) setter = nullable.copyWith.value;
    expect(copy.value, isNull);
    expect(setter(null).value, isNull);
    expect(nullable.copyWith().value, 'old');
    const Box<int> nonNullable = (value: 1);
    final Box<int> changed = nonNullable.copyWith(value: 2);
    expect(changed.value, 2);
    const Optional<int> optional = (optional: 1);
    expect(optional.copyWithNull(optional: true).optional, isNull);
    expect(optional.copyWithNull(optional: false), optional);
    const Bounded<int?> bounded = (bounded: 1);
    expect(bounded.copyWith(bounded: null).bounded, isNull);
    const Later<String?> later = (later: 'old');
    expect(later.copyWith(later: null).later, isNull);
    final Future<int?> future = Future.value(1);
    final OptionalLater<int> optionalLater = (optionalLater: future);
    expect(
      identical(optionalLater.copyWithNull().optionalLater, future),
      isTrue,
    );
    expect(
      optionalLater.copyWithNull(optionalLater: true).optionalLater,
      isNull,
    );
    Person? nullablePerson(bool present) =>
        present ? (name: 'Ada', age: 36) : null;
    expect(nullablePerson(false)?.copyWith(name: 'unused'), isNull);
    expect(nullablePerson(true)?.copyWith(name: 'Grace'), (
      name: 'Grace',
      age: 36,
    ));
  });

  test(
    'record fields and equal shapes can use explicit extension selection',
    () {
      const Shadowed value = (copyWith: 1, copyWithNull: 'old');
      expect($ShadowedCopyWith(value).copyWith(copyWith: 2).copyWith, 2);
      expect($ShadowedCopyWith(value).copyWithNull(copyWithNull: true), (
        copyWith: 1,
        copyWithNull: null,
      ));
      const MutableShape shape = (policy: 1, tag: 'fixed');
      expect($MutableShapeCopyWith(shape).copyWith.policy(2).policy, 2);
      expect($FrozenShapeCopyWith(shape).copyWith(), shape);
      expect($FrozenCopyWith<String?>((T: 'fixed')).copyWith().T, 'fixed');
      expect((call: 1).copyWith(call: 2).call, 2);
      const Specific specific = (specificity: 1);
      final Specific copy = specific.copyWith(specificity: 2);
      expect(copy.specificity, 2);
      const overlap = (left: 1, right: 2);
      final Left left = $LeftCopyWith(overlap).copyWith(right: 3.5);
      final Right right = $RightCopyWith(overlap).copyWith(left: 4.5);
      expect(left, (left: 1, right: 3.5));
      expect(right, (left: 4.5, right: 2));
      const _Private private = (privateValue: 1);
      expect(private.copyWith.privateValue(2).privateValue, 2);
    },
  );

  test('copies are shallow, including class-mediated cycles', () {
    final items = [1];
    final child = Cycle();
    final Holding original = (
      items: items,
      inner: ('old', count: 1),
      child: child,
    );
    child.parent = original;
    final changed = original.copyWith(inner: ('new', count: 2));
    expect(changed.inner, ('new', count: 2));
    expect(original.inner, ('old', count: 1));
    expect(identical(changed.items, items), isTrue);
    expect(identical(changed.child, child), isTrue);
    expect(child.parent, original);
  });

  test('top types, clear flags and equality-safe omission', () {
    const Special value = (nil: null, bottom: null, any: 'a', object: 'o');
    final replacement = ThrowsEquality();
    expect(
      identical(value.copyWith(object: replacement).object, replacement),
      isTrue,
    );
    expect(value.copyWithNull(), value);
    expect(value.copyWithNull(any: true, object: true), (
      nil: null,
      bottom: null,
      any: null,
      object: null,
    ));
    // Exercise the private implementation through its public callable proxy.
    final dynamic copier = value.copyWith;
    expect(identical(copier(any: replacement).any, replacement), isTrue);
  });

  test('generic function components keep their own binders', () {
    String convert<U extends num>(U value) => '$value';
    var called = false;
    void done() => called = true;
    final Functions<String> value = (convert: convert, done: done);
    final Functions<String> copy = value.copyWith(convert: convert);
    expect(copy.convert<int>(3), '3');
    copy.done();
    expect(called, isTrue);
  });

  test(
    'record copies retain omitted values and clear explicit nullable values',
    () {
      const Person original = (name: 'Ada', age: 36);
      final Person renamed = original.copyWith(name: 'Grace');
      expect(renamed, (name: 'Grace', age: 36));
      expect(original, (name: 'Ada', age: 36));
      expect(original.copyWith(age: null), (name: 'Ada', age: null));
      expect(original.copyWith.age(null), (name: 'Ada', age: null));
      expect(original.copyWithNull(age: true), (name: 'Ada', age: null));
    },
  );
}
