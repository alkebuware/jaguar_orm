// Copyright (c) 2016, teja. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library jaguar_orm_sqljocky.src;

import 'dart:async';

import 'package:jaguar_query/jaguar_query.dart';
import 'package:jaguar_query_sqljocky/composer.dart';
import 'package:sqljocky5/sqljocky.dart' as sj;

class MysqlAdapter implements Adapter<sj.MySqlConnection> {
  sj.MySqlConnection _connection;

  final String host;

  final int port;

  final String databaseName;
  final String username;
  final String password;

  MysqlAdapter(this.databaseName,
      {this.username, this.password, this.host: 'localhost', this.port: 3306});

  MysqlAdapter.FromConnection(sj.MySqlConnection connection)
      : _connection = connection,
        host = null,
        port = null,
        databaseName = null,
        username = null,
        password = null;

  /// Connects to the database
  Future<void> connect() async {
    if (_connection == null) {
      sj.ConnectionSettings connSettings = sj.ConnectionSettings(
          host: host,
          port: port,
          db: databaseName,
          user: username,
          password: password);
      _connection = await sj.MySqlConnection.connect(connSettings);
    }
    //if (_connection.isClosed) await connection.open();
  }

  /// Closes all connections to the database.
  Future<void> close() => _connection.close();

  sj.MySqlConnection get connection => _connection;

  /// Finds one record in the table
  Future<Map> findOne(Find st, {Connection withConn}) async {
    String stStr = composeFind(st);
    sj.MySqlConnection conn = withConn ?? _connection;
    sj.StreamedResults results = await conn.execute(stStr);

    sj.Row rowFound;
    await for (sj.Row row in results) {
      rowFound = row;
      break;
    }

    return rowFound?.asMap()?.map((index, value) =>
        MapEntry<String, dynamic>(results.fields[index].name, value));
  }

  // Finds many records in the table
  Future<List<Map>> find(Find st, {Connection withConn}) async {
    String stStr = composeFind(st);
    sj.MySqlConnection conn = withConn ?? _connection;
    sj.Results results = await (await conn.execute(stStr)).deStream();
    return results.map((sj.Row r) =>
        r.asMap().map((index, value) =>
            MapEntry<String, dynamic>(results.fields[index].name, value)))
        .toList();
  }

  /// Inserts a record into the table
  Future<T> insert<T>(Insert st, {Connection withConn}) async {
    String strSt = composeInsert(st);
    sj.MySqlConnection conn = withConn ?? _connection;
    await conn.execute(strSt);
    Stream<sj.Row> stream = await conn.execute(composeLastInsertId());

    int id;
    await for (sj.Row row in stream) {
      id = row.first;
      break;
    }

    return id as dynamic;
  }

  @override
  Future<void> insertMany<T>(InsertMany statement, {Connection withConn}) {
    throw UnimplementedError('InsertMany is not implemented yet!');
  }

  /// Executes the insert or update statement and returns the primary key of
  /// inserted row
  Future<T> upsert<T>(Upsert statement, {Connection withConn}) {
    throw UnimplementedError();
  }

  /// Executes bulk insert or update statement
  Future<void> upsertMany<T>(UpsertMany statement, {Connection withConn}) {
    throw UnimplementedError();
  }

  /// Updates a record in the table
  Future<int> update(Update st, {Connection withConn}) async {
    sj.MySqlConnection conn = withConn ?? _connection;
    sj.Results results =
    await (await conn.execute(composeUpdate(st))).deStream();
    return results.affectedRows;
  }

  /// Deletes a record from the table
  Future<int> remove(Remove st, {Connection withConn}) async {
    sj.MySqlConnection conn = withConn ?? _connection;
    sj.Results results =
    await (await conn.execute(composeRemove(st))).deStream();
    return results.affectedRows;
  }

  /// Creates the table
  Future<void> createTable(Create statement, {Connection withConn}) async {
    sj.MySqlConnection conn = withConn ?? _connection;
    await conn.execute(composeCreate(statement));
  }

  /// Create the database
  Future<void> createDatabase(CreateDb st, {Connection withConn}) async {
    sj.MySqlConnection conn = withConn ?? _connection;
    await conn.execute(composeCreateDb(st));
  }

  /// Drops tables from database
  Future<void> dropTable(Drop st, {Connection withConn}) async {
    String stStr = composeDrop(st);
    sj.MySqlConnection conn = withConn ?? _connection;
    await conn.execute(stStr);
  }

  Future<void> dropDb(DropDb st, {Connection withConn}) async {
    sj.MySqlConnection conn = withConn ?? _connection;
    await conn.execute(composeDropDb(st));
  }

  @override
  T parseValue<T>(dynamic v) {
    if (T == String) {
      return v?.toString() as T;
    } else if (T == int) {
      return v?.toInt();
    } else if (T == double) {
      return v?.toDouble();
    } else if (T == num) {
      return v;
    } else if (T == DateTime) {
      if (v == null) return null;
      if (v is String) return DateTime.parse(v) as T;
      if (v == int) return DateTime.fromMillisecondsSinceEpoch(v * 1000) as T;
      return null;
    } else if (T == bool) {
      if (v == null) return null;
      return (v == 0 ? false : true) as T;
    } else {
      throw new Exception("Invalid type $T!");
    }
  }

  @override
  Future<void> updateMany(UpdateMany statement, {Connection withConn}) {
    throw UnimplementedError('TODO need to be implemented');
  }

  @override
  Future<void> alter(Alter statement, {Connection withConn}) {
    throw UnimplementedError('TODO need to be implemented');
  }

  @override
  Future<Connection> beginTx({Connection withConn}) {
    throw UnimplementedError('TODO need to be implemented');
  }

  @override
  Future exec(String sql, {Connection withConn}) {
    throw UnimplementedError('TODO need to be implemented');
  }

  @override
  get logger => throw UnimplementedError('TODO need to be implemented');

  @override
  Future<Connection> open() {
    throw UnimplementedError('TODO need to be implemented');
  }

  @override
  Future query(String sql, {Connection withConn}) {
    throw UnimplementedError('TODO need to be implemented');
  }

  @override
  Future<T> run<T>(Future<T> Function(Connection<sj.MySqlConnection> conn) task,
      {Connection<sj.MySqlConnection> withConn}) {
    throw UnimplementedError('TODO need to be implemented');
  }

  @override
  Future<T> transaction<T>(
      Future<T> Function(Connection<sj.MySqlConnection> conn) tx,
      {Connection<sj.MySqlConnection> withConn}) {
    throw UnimplementedError('TODO need to be implemented');
  }
}
