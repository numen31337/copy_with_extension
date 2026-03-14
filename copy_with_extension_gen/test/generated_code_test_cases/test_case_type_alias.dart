part of 'source_gen_entrypoint.dart';

typedef GoldenInt = int;
typedef GoldenList<T> = List<T>;

@CopyWith()
class GoldenAliasNames {
  const GoldenAliasNames({required this.value});

  final GoldenList<GoldenInt> value;
}
