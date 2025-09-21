import 'package:copy_with_extension/copy_with_extension.dart';

part 'gen_cross_library_parent.g.dart';

@CopyWith()
class CrossLibraryParent {
  const CrossLibraryParent({required this.value});

  final int value;
}
