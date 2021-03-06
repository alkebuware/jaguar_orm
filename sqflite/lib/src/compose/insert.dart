part of query.compose;

String composeInsert(final Insert st) {
  final ImInsert info = st.asImmutable;
  final sb = new StringBuffer();

  sb.write('INSERT INTO ');
  sb.write(info.table);
  sb.write('(');

  sb.write(info.values.keys.join(', '));

  sb.write(') VALUES (');
  sb.write(info.values.values.map(composeExpression).join(', '));
  sb.write(')');

  return sb.toString();
}
