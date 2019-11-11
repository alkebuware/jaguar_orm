// Copyright (c) 2016, teja. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:jaguar_query_sqljocky/jaguar_query_sqljocky.dart';

/// The adapter
MysqlAdapter _adapter =
    MysqlAdapter('testing', username: 'root', password: 'dart_jaguar');

// The model
class Post {
  Post();

  Post.make(this.id, this.msg, this.author);

  int id;

  String msg;

  String author;

  String toString() => '$id $msg $author';
}

/// The bean
class PostBean {
  /// Field DSL for id column
  final IntField id = new IntField('_id');

  /// Field DSL for msg column
  final StrField msg = new StrField('msg');

  /// Field DSL for author column
  final StrField author = new StrField('author');

  /// Table name for the model this bean manages
  String get tableName => 'posts';

  Future<Null> createTable() async {
    final st = Create(tableName, ifNotExists: true)
        .addInt('_id', isPrimary: true)
        .addStr('msg', notNull: true)
        .addStr('author', notNull: true);
    await _adapter.createTable(st);
  }

  /// Inserts a new post into table
  Future insert(Post post) async {
    Insert inserter = Insert(tableName);

    inserter.set(id, post.id);
    inserter.set(msg, post.msg);
    inserter.set(author, post.author);

    return await _adapter.insert(inserter);
  }

  /// Updates a post
  Future<int> update(int id, String author) async {
    Update updater = Update(tableName);
    updater.where(this.id.eq(id));

    updater.set(this.author, author);

    return await _adapter.update(updater);
  }

  /// Finds one post by [id]
  Future<Post> findOne(int id) async {
    Find updater = Find(tableName);

    updater.where(this.id.eq(id));

    Map map = await _adapter.findOne(updater);

    Post post = Post();
    post.id = map['_id'];
    post.msg = map['msg'];
    post.author = map['author'];

    return post;
  }

  /// Finds all posts
  Future<List<Post>> findAll() async {
    Find finder = Find(tableName);

    List<Map> maps = await (await _adapter.find(finder)).toList();

    List<Post> posts = List<Post>();

    for (Map map in maps) {
      Post post = new Post();

      post.id = map['_id'];
      post.msg = map['msg'];
      post.author = map['author'];

      posts.add(post);
    }

    return posts;
  }

  /// Removes a post by [id]
  Future<int> delete(int id) async {
    Remove deleter = Remove(tableName);

    deleter.where(this.id.eq(id));

    return await _adapter.remove(deleter);
  }

  /// Removes all posts
  Future<int> deleteAll() async {
    Remove deleter = Remove(tableName);

    return await _adapter.remove(deleter);
  }
}

main() async {
  // Connect
  await _adapter.connect();

  final bean = new PostBean();

  await _adapter.dropTable(Sql.drop(bean.tableName, onlyIfExists: true));

  await bean.createTable();

  // Remove all
  await bean.deleteAll();

  // Insert some posts
  await bean.insert(new Post.make(1, 'Whatever 1', 'mark'));
  await bean.insert(new Post.make(2, 'Whatever 2', 'bob'));

  // Find one post
  Post post = await bean.findOne(1);
  print(post);

  print('Fetching all:');
  print('-------------');

  // Find all posts
  List<Post> posts = await bean.findAll();
  print(posts);

  // Update a post
  print(await bean.update(1, 'rowling'));

  // Check that the post is updated
  post = await bean.findOne(1);
  print(post);

  // Remove some posts
  print(await bean.delete(1));
  print(await bean.delete(2));

  // Find a post when none exists
  post = await bean.findOne(1);
  print(post);

  // Close connection
  await _adapter.close();
}
