part of query.compose;

String composeAlter(final Alter alter) {
  final sb = StringBuffer();

  sb.write('ALTER TABLE');

  sb.write(' ${alter.table} ');

  sb.write(composeColumnDefinitions(
      alter.adds.values.map((AddColumn a) => a.column),
      clausePrefix: "ADD "));

  List<DropColumn> drops = alter.drops.values.toList();
  for (int i = 0; i < drops.length; i++) {
    bool last = i == drops.length - 1;
    sb.write(" DROP COLUMN ${drops[i].name}${last ? "" : ","}");
  }

  return sb.toString();
}
