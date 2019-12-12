part of query.compose;

String composeExpression(final Expression exp) {
  if (exp is ToDialect) {
    final ret = (exp as ToDialect).toDialect(mysqlDialect, composer);
    if (ret is String) return ret;
    if (ret is Expression) return composeExpression(ret);
    throw UnsupportedError(
        "${exp.runtimeType}.toDialect returned invalid literal: $ret");
  }

  if (exp is I) return exp.name;
  if (exp is L) return composeLiteral(exp);
  if (exp is Func) return composeFunc(exp);
  if (exp is E) return exp.expr;
  if (exp is Not) return 'NOT ${composeExpression(exp.expr)}';
  if (exp is Exists) return 'EXISTS (${composeExpression(exp.expr)})';
  if (exp is Func) return composeFunc(exp);
  if (exp is RowSourceExpr) return composeRowSource(exp.expr);
  if (exp is MakeExpr) return composeExpression(exp.maker());

  if (exp is Or) {
    final sb = StringBuffer();
    if (exp.length != 1) sb.write('(');
    sb.write(exp.expressions
        .map((Expression exp) => composeExpression(exp))
        .join(' OR '));
    if (exp.length != 1) sb.write(')');
    return sb.toString();
  }

  if (exp is And) {
    final sb = StringBuffer();
    if (exp.length != 1) sb.write('(');
    sb.write(exp.expressions
        .map((Expression exp) => composeExpression(exp))
        .join(' AND '));
    if (exp.length != 1) sb.write(')');
    return sb.toString();
  }

  if (exp is Cond) {
    return '${composeExpression(exp.lhs)} ${exp.op.string} ${composeExpression(
        exp.rhs)}';
  }

  if (exp is Between) {
    return '(${composeExpression(exp.lhs)} BETWEEN ${composeExpression(
        exp.low)} AND ${composeExpression(exp.high)})';
  }

  if (exp is Row) {
    StringBuffer sb = StringBuffer();
    sb.write("'[");
    sb.write(exp.items.map(composeExpression)
        .map((String s) =>
        s.replaceRange(0, 1, "\"").replaceRange(s.length - 1, s.length, "\""))
        .join(","));
    sb.write("]'");
    return sb.toString();
  }

  throw Exception('Unknown expression ${exp.runtimeType}!');
}

String composeField(final Field field) => field.name;

String composeLiteral(L literal) {
  if (literal is ToDialect) {
    final val = (literal as ToDialect).toDialect(mysqlDialect, composer);
    if (val is String) return val;
    if (val is Expression) return composeExpression(val);
    throw UnsupportedError(
        "${literal.runtimeType}.toDialect returned invalid literal: $val");
  }

  if (literal is NilLiteral) return "NULL";

  final val = literal.value;

  if (val is num) return "$val";
  if (val is String) return "'${sqlStringEscape(val)}'";
  if (val is DateTime)
    return "'${val.year.toString().padLeft(4, "0")}-${val.month.toString()
        .padLeft(2, "0")}-${val.day.toString().padLeft(2, "0")} ${val.hour
        .toString().padLeft(2, "0")}:${val.minute.toString().padLeft(
        2, "0")}:${val.second.toString().padLeft(2, "0")}.${(val.millisecond *
        1000 + val.microsecond).toString().padRight(6, "0")}'";
  if (val is bool) return val ? 'TRUE' : 'FALSE';
  if (val is Duration) return "$val"; //TODO
  if (val is Map || val is List) return jsonEncode(val);

  throw Exception("Invalid type ${val.runtimeType}!");
}

String composeFunc(Func func) {
  var sb = StringBuffer();

  sb.write(func.name);

  sb.write('(');

  sb.write(func.args.map((s) => composeExpression(s)).join(', '));

  sb.write(')');

  return sb.toString();
}

String sqlStringEscape(String input) => input.replaceAll("'", "''");
