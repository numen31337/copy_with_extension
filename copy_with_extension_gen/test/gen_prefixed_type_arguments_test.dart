import 'dart:typed_data' as typed;

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:test/test.dart';

part 'gen_prefixed_type_arguments_test.g.dart';

@CopyWith()
class ExternalGeneric<T> {
  const ExternalGeneric({required this.field});

  final T field;
}

@CopyWith()
class PrefixedChild extends ExternalGeneric<typed.Uint8List> {
  const PrefixedChild({required super.field});
}

@CopyWith()
class PrefixedFunctionField {
  const PrefixedFunctionField({required this.callback});

  final void Function(typed.Uint8List) callback;
}

@CopyWith()
class PrefixedBound<T extends typed.Uint8List> {
  const PrefixedBound({required this.field});

  final T field;
}

void main() {
  test('Generic type argument retains prefix', () {
    final result = PrefixedChild(
      field: typed.Uint8List(1),
    ).copyWith(field: typed.Uint8List(2));
    expect(result.field, isA<typed.Uint8List>());
  });

  test('Function type argument retains prefix', () {
    final result = PrefixedFunctionField(
      callback: (_) {},
    ).copyWith(callback: (_) {});
    expect(result.callback, isA<void Function(typed.Uint8List)>());
  });

  test('Type-parameter bound retains prefix', () {
    final result = PrefixedBound<typed.Uint8List>(
      field: typed.Uint8List(1),
    ).copyWith(field: typed.Uint8List(2));
    expect(result.field, isA<typed.Uint8List>());
  });
}
