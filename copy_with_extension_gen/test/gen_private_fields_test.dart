import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:test/test.dart' show expect, test;

part 'gen_private_fields_test.g.dart';

@CopyWith()
class PrivateFields {
  const PrivateFields(this._hidden, this._hidden2, {required this.id});

  final int _hidden;
  final int? _hidden2;
  final int id;
}

void main() {
  test('copyWith ignores private constructor parameters', () {
    const instance = PrivateFields(1, null, id: 1);
    final result = instance.copyWith(id: 2);
    expect(result._hidden, 1);
    expect(result._hidden2, null);
    expect(result.id, 2);
  });
}
