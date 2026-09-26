import 'dart:typed_data' as typed;

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:test/test.dart';

part 'gen_record_value_class_test.g.dart';

typedef Pair<T> = (T, {T? optional});

@CopyWith(copyWithNull: true, constructor: 'named')
class Legacy<T extends num> {
  const Legacy.named({
    required this.alias,
    required this.direct,
    required this.callback,
    this.note,
  });

  final Pair<T> alias;
  final (typed.Uint8List, {String? label}) direct;
  final T Function<U extends T>(U) callback;
  final String? note;
}

void main() {
  test('class copies retain record types and generic function binders', () {
    int convert<U extends int>(U value) => value + 1;
    final bytes = typed.Uint8List.fromList([1]);
    final original = Legacy<int>.named(
      alias: (1, optional: 2),
      direct: (bytes, label: 'old'),
      callback: convert,
      note: 'note',
    );
    final Legacy<int> omitted = original.copyWith();
    expect(omitted.alias, (1, optional: 2));
    expect(identical(omitted.direct.$1, bytes), isTrue);
    expect(identical(omitted.callback, convert), isTrue);
    final replacement = typed.Uint8List.fromList([2]);
    final Legacy<int> changed = original.copyWith(
      alias: (3, optional: null),
      direct: (replacement, label: null),
    );
    expect(changed.alias, (3, optional: null));
    expect(identical(changed.direct.$1, replacement), isTrue);
    expect(changed.direct.label, isNull);
    expect(original.alias, (1, optional: 2));
    expect(original.direct.label, 'old');
    expect(original.copyWith.alias((4, optional: 5)).alias, (4, optional: 5));
    int doubleValue<U extends int>(U value) => value * 2;
    expect(original.copyWith.callback(doubleValue).callback<int>(3), 6);
    final Legacy<int> cleared = original.copyWithNull(note: true);
    expect(cleared.note, isNull);
    expect(cleared.alias, original.alias);
    expect(identical(cleared.direct.$1, bytes), isTrue);
    expect(cleared.callback<int>(3), 4);
  });
}
