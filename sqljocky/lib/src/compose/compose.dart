library query.compose;

import 'package:jaguar_query/jaguar_query.dart';

part 'create.dart';
part 'delete.dart';
part 'expression.dart';

part 'find.dart';

part 'insert.dart';

part 'row_source.dart';
part 'update.dart';

final mysqlDialect = "mysql";

class MysqlComposer implements Composer {
  String find(Find st) => composeFind(st);

  String expression(Expression expr) => composeExpression(expr);
}

final composer = MysqlComposer();