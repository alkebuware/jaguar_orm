part of query.compose;

String composeDataType(final DataType type) {
  if (type == null) throw Exception("Data type cannot be null!");
  if (type is Int) {
    if (type.auto) {
      return " SERIAL ";
    } else {
      return " ${type.big == true ? "BIG" : ""}INT ${type.unsigned == true
          ? "UNSIGNED "
          : ""}";
    }
  } else if (type is Bool) {
    return " BOOLEAN ";
  } else if (type is DateTime || type is Timestamp) {
    return " TIMESTAMP ";
  } else if (type is Str) {
    if (type.length == null) return " TEXT ";
    return " VARCHAR(${type.length}) ";
  } else if (type is Double) {
    return " Double ";
  } else if (type is Json) {
    return " JSON ";
  } else {
    throw Exception("Unknown data type ${type.runtimeType}");
  }
}

String composeProperty(final Property col) {
  final sb = StringBuffer();

  sb.write(col.name);
  sb.write(' ');
  sb.write(composeDataType(col.type));

  if (col.notNull) sb.write(' NOT NULL');

  return sb.toString();
}

String composeColumnDefinitions(Iterable<CreateCol> columns,
    {String clausePrefix = ""}) {
  StringBuffer sb = StringBuffer();
  {
    final cols = <String>[];

    for (CreateCol col in columns) {
      final colSpec = StringBuffer();
      colSpec.write("$clausePrefix");
      colSpec.write(composeProperty(col));

      Check check =
      col.constraints.firstWhere((c) => c is Check, orElse: () => null);
      if (check != null) {
        colSpec.write(' CHECK( ${composeExpression(check.expression)} )');
      }

      cols.add(colSpec.toString());
    }

    sb.write(cols.join(','));
  }

  final List<CreateCol> primaries =
  columns.where((CreateCol col) => col.isPrimary).toList();
  if (primaries.length != 0) {
    sb.write(', PRIMARY KEY (');
    sb.write(primaries.map((CreateCol col) => col.name).join(','));
    sb.write(')');
  }

  {
    final uniques = <CreateCol>[];
    final compositeUniques = <String, List<CreateCol>>{};
    final foreigns = <String, Map<String, String>>{};
    for (CreateCol col in columns) {
      if (col.foreign != null) {
        if (!foreigns.containsKey(col.foreign.table)) {
          foreigns[col.foreign.table] = <String, String>{};
        }
        foreigns[col.foreign.table][col.name] = col.foreign.col;
      }

      final Unique uniqueSpec = col.constraints
          .firstWhere((c) => c is Unique, orElse: () => null) as Unique;
      if (uniqueSpec != null) {
        if (uniqueSpec.group == null) {
          uniques.add(col);
        } else {
          compositeUniques[uniqueSpec.group] =
          (compositeUniques[uniqueSpec.group] ?? <CreateCol>[])
            ..add(col);
        }
      }
    }

    for (final String foreignTab in foreigns.keys) {
      final Map<String, String> cols = foreigns[foreignTab];
      sb.write(',${clausePrefix} FOREIGN KEY (');
      sb.write(cols.keys.join(', '));
      sb.write(') REFERENCES ');
      sb.write(foreignTab + '(');
      sb.write(cols.values.join(', '));
      sb.write(')');
    }

    for (CreateCol col in uniques) {
      sb.write(', UNIQUE(${col.name})');
    }

    for (String group in compositeUniques.keys) {
      final String str =
      compositeUniques[group].map((CreateCol col) => col.name).join(', ');
      sb.write(', UNIQUE($str)');
    }
  }

  return sb.toString();
}

String composeCreate(final Create create) {
  final ImCreate info = create.asImmutable;
  final sb = StringBuffer();

  sb.write('CREATE TABLE');

  if (info.ifNotExists) sb.write(' IF NOT EXISTS');

  sb.write(' ${info.name} (');

  // Write col specs
  sb.write(composeColumnDefinitions(info.columns.values));

  sb.write(')');

  return sb.toString();
}

String composeCreateDb(final CreateDb st) => "CREATE DATABASE ${st.name}";
