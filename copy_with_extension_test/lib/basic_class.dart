import 'package:meta/meta.dart' show immutable;
import 'package:copy_with_extension/copy_with_extension.dart';

//Don't work without it!
part 'basic_class.g.dart';

@immutable
@CopyWith()
class BasicClass {
  final String id;

  BasicClass({this.id});
}