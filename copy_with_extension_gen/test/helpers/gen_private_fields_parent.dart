import 'package:copy_with_extension/copy_with_extension.dart';

part 'gen_private_fields_parent.g.dart';

@CopyWith()
class PrivateParent {
  const PrivateParent(this._secret, {this.id = 0});

  final int _secret;
  final int id;
}
