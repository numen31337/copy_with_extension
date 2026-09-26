import 'dart:async' as async;

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:test/test.dart';

part 'gen_generic_nullability_test.g.dart';

@CopyWith(copyWithNull: true)
class Box<T> {
  const Box(this.value);
  final T value;
}

@CopyWith(copyWithNull: true)
class AsyncBox<T> {
  const AsyncBox(this.value, this.sibling);
  final async.FutureOr<T?> value;
  final List<int> sibling;
}

@CopyWith(copyWithNull: true)
class FutureBox<T> {
  const FutureBox(this.value);
  final async.FutureOr<T> value;
}

@CopyWith()
class ConcreteFutureBox extends FutureBox<int?> {
  const ConcreteFutureBox(super.value);
}

@CopyWith(constructor: '_')
class BoundedBox<T extends num?> {
  const BoundedBox._(this.value);
  factory BoundedBox(T value) => BoundedBox<T>._(value);
  final T value;
}

@CopyWith(copyWithNull: true)
class InheritedBox<T> extends Box<T> {
  const InheritedBox(super.value, this.sibling);
  final List<int> sibling;
}

@CopyWith(copyWithNull: true)
class NullableBox extends Box<String?> {
  const NullableBox(super.value);
}

@CopyWith(copyWithNull: true)
class NarrowedBox extends Box<num?> {
  const NarrowedBox(this.value) : super(null);
  @override
  // ignore: overridden_fields
  final int value;
}

@CopyWith(copyWithNull: true)
class InheritedAsync<T> extends AsyncBox<T> {
  const InheritedAsync(super.value, super.sibling, this.extra);
  final int extra;
}

typedef MaybeLater<T> = async.FutureOr<T?>;

@CopyWith(copyWithNull: true, skipFields: true)
class SkippedBox<T> {
  const SkippedBox(this.value, this.later);
  final T value;
  final MaybeLater<T> later;
}

@CopyWith(copyWithNull: true)
class MixedPolicy<T> {
  const MixedPolicy(this.value, this.locked);
  final T value;
  @CopyWithField(immutable: true)
  final async.FutureOr<T?> locked;
}

extension type MaybeText(String? representation) {}

@CopyWith()
class ExtensionValues {
  const ExtensionValues(this.direct, this.later);
  final MaybeText direct;
  final async.FutureOr<MaybeText> later;
}

void main() {
  test('extension types retain direct dynamic null handling', () {
    final original = ExtensionValues(MaybeText('old'), MaybeText('later'));
    final dynamic proxy = original.copyWith;
    final unchanged = proxy(direct: null, later: null) as ExtensionValues;
    expect(unchanged.direct.representation, 'old');
    expect(unchanged.later, 'later');
    final Box<MaybeText?> nullable = Box<MaybeText?>(
      MaybeText('old'),
    ).copyWith(value: null);
    expect(nullable.value, isNull);
  });

  test('nullable generic class values distinguish null from omission', () {
    const original = Box<String?>('old');
    final Box<String?> omitted = original.copyWith();
    final Box<String?> cleared = original.copyWith(value: null);
    final Box<String?> Function(String?) setter = original.copyWith.value;
    expect(omitted.value, 'old');
    expect(cleared.value, isNull);
    expect(setter(null).value, isNull);
    expect(original.value, 'old');
  });

  test('FutureOr with a nullable argument accepts explicit null', () {
    final future = Future<int?>.value(1);
    final sibling = [2];
    final original = AsyncBox<int>(future, sibling);
    final AsyncBox<int> cleared = original.copyWith(value: null);
    expect(cleared.value, isNull);
    expect(original.copyWith.value(null).value, isNull);
    expect(identical(original.copyWith().value, future), isTrue);
    expect(identical(cleared.sibling, sibling), isTrue);
    expect(identical(original.value, future), isTrue);
    expect(original.copyWithNull(value: true).value, isNull);
    expect(identical(original.copyWithNull().value, future), isTrue);
    expect(
      identical(original.copyWithNull(value: false).value, future),
      isTrue,
    );
    expect(
      identical(original.copyWithNull(value: true).sibling, sibling),
      isTrue,
    );
  });

  test(
    'non-nullable generic calls retain the legacy dynamic null fallback',
    () {
      const original = Box<int>(1);
      final Box<int> updated = original.copyWith(value: 2);
      expect(updated.value, 2);
      final dynamic proxy = original.copyWith;
      expect((proxy(value: null) as Box<int>).value, 1);
      expect(() => proxy(value: 'wrong'), throwsA(isA<TypeError>()));
      expect(() => proxy.value(null), throwsA(isA<TypeError>()));
      expect(original.value, 1);
    },
  );

  test('FutureOr of a bare type parameter checks its instantiated type', () {
    const original = FutureBox<String?>('old');
    final FutureBox<String?> cleared = original.copyWith(value: null);
    expect(cleared.value, isNull);
    expect(original.copyWith.value(null).value, isNull);
    expect(original.copyWith().value, 'old');
    final dynamic nullableProxy = original.copyWith;
    expect((nullableProxy(value: null) as FutureBox<String?>).value, isNull);
    const nonNullable = FutureBox<int>(1);
    final dynamic nonNullableProxy = nonNullable.copyWith;
    expect((nonNullableProxy(value: null) as FutureBox<int>).value, 1);
    expect(() => nonNullableProxy.value(null), throwsA(isA<TypeError>()));
    final future = Future<int>.value(2);
    final replacement = nonNullable.copyWith(value: future);
    expect(identical(replacement.value, future), isTrue);
    expect(identical(replacement.copyWith().value, future), isTrue);
    final ConcreteFutureBox concrete = const ConcreteFutureBox(
      1,
    ).copyWith(value: null);
    expect(concrete.value, isNull);
  });

  test(
    'nullable bounds and private constructors retain instantiated types',
    () {
      final original = BoundedBox<int?>(1);
      final BoundedBox<int?> cleared = original.copyWith(value: null);
      expect(cleared.value, isNull);
      expect(original.copyWith.value(null).value, isNull);
      expect(original.copyWith().value, 1);
      final dynamic nonNullableProxy = BoundedBox<int>(1).copyWith;
      expect((nonNullableProxy(value: null) as BoundedBox<int>).value, 1);
    },
  );

  test('generic inheritance preserves root types and unrelated references', () {
    final sibling = [2];
    final original = InheritedBox<String?>('old', sibling);
    final InheritedBox<String?> cleared = original.copyWith(value: null);
    expect(cleared.value, isNull);
    expect(original.copyWith.value(null).value, isNull);
    expect(identical(cleared.sibling, sibling), isTrue);
    expect(original.value, 'old');
    final NullableBox concrete = const NullableBox(
      'old',
    ).copyWithNull(value: true);
    expect(concrete.value, isNull);
    const narrowed = NarrowedBox(1);
    expect(narrowed.copyWith(value: 2).value, 2);
    final dynamic narrowedProxy = narrowed.copyWith;
    expect((narrowedProxy(value: null) as NarrowedBox).value, 1);
    final inheritedAsync = InheritedAsync<int>(1, sibling, 3);
    final InheritedAsync<int> asyncCleared = inheritedAsync.copyWithNull(
      value: true,
    );
    expect(asyncCleared.value, isNull);
    expect(asyncCleared.extra, 3);
    expect(identical(asyncCleared.sibling, sibling), isTrue);
  });

  test(
    'skipFields and immutable fields keep their policies for nullable types',
    () {
      const original = SkippedBox<String?>('old', 'later');
      final SkippedBox<String?> cleared = original.copyWith(
        value: null,
        later: null,
      );
      expect(cleared.value, isNull);
      expect(cleared.later, isNull);
      expect(original.copyWithNull(later: true).value, 'old');
      expect(original.copyWithNull(later: true).later, isNull);
      final future = Future<int?>.value(1);
      final mixed = MixedPolicy<int?>(1, future);
      final MixedPolicy<int?> changed = mixed.copyWith(value: null);
      expect(changed.value, isNull);
      expect(identical(changed.locked, future), isTrue);
      expect(mixed.value, 1);
    },
  );
}
