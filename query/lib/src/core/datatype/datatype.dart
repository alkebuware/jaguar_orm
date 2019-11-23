export 'property.dart';

abstract class DataType<T> {
  bool get auto;
}

Map<Type, DataType> sqlTypeMap = const {
  int: Int(),
  double: Double(),
  bool: Bool(),
  DateTime: Timestamp(),
  String: Str(),
  Duration: Interval(),
  List: Json(),
  Map: Json(),
};

/// Integer datatype.
class Int implements DataType<int> {
  final bool auto;
  final bool unsigned;
  final bool big;

  const Int({this.auto = false, this.unsigned = false, this.big = false});
}

class Json implements DataType {
  @override
  bool get auto => false;

  const Json();
}

const foreignKey = Int(big: true, unsigned: true);

const auto = Int(auto: true);

/// Integer datatype.
class Double implements DataType<double> {
  bool get auto => false;

  const Double();
}

/// Integer datatype.
class Bool implements DataType<bool> {
  bool get auto => false;

  const Bool();
}

/// Integer datatype.
class Timestamp implements DataType<DateTime> {
  bool get auto => false;

  const Timestamp();
}

/// Integer datatype.
class Str implements DataType<String> {
  final int length;

  bool get auto => false;

  const Str({this.length});
}

class Interval implements DataType<Duration> {
  bool get auto => false;

  const Interval();
}

// TODO needed?
class UserDefinedType implements DataType<dynamic> {
  final String name;

  bool get auto => false;

  const UserDefinedType(this.name);
}
