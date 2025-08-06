import 'package:copy_with_extension/copy_with_extension.dart';

@CopyWith()
class PrefixedSuper<T> {
  const PrefixedSuper(this.superField);

  final T superField;
}
