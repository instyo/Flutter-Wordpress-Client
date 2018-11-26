import 'package:sqflite/sqflite.dart';

import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'item-model.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; // Singleton DB helper
  static Database _database;

  String postTable = 'post_table';
  String colId = 'id';
  String colTitle = 'title';
  String colContent = 'content';
  String colDate = 'date';
  String colImgUrl = 'img_url';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initDatabase();
    }
    return _database;
  }

  Future<Database> initDatabase() async {
    //Get the dir
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'posts.db';

    //Open or Create the database using given path
    var postsDataBase = openDatabase(path, version: 1, onCreate: _createDb);
    return postsDataBase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $postTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colContent TEXT, $colDate TEXT, $colImgUrl TEXT )');
  }

  //Fetch : Get all Posts from DB
Future<List<Map<String , dynamic>>>getPostMapList() async {
    Database db = await this.database;
    
    var result = await db.rawQuery('SELECT * FROM $postTable');
    return result;
}


  //Insert: Insert a Post Obj to database
Future<int> insertPost(Post post) async {
    Database db = await this.database ;
    var result = await db.insert(postTable, post.toMap()); //Convert ti map
    return result ;
}

  // Update : Update Post Obj and Save it yo DB
  Future<int> updatePost(Post post) async {
    Database db = await this.database ;
    var result = await db.update(postTable, post.toMap(), where: '$colId = ?', whereArgs: [post.id] ); //Convert ti map then uodate where id  /?
    return result ;
  }

  //Delete: Delete a Post Obj from DB
  Future<int> deletePost(int id) async {
    Database db = await this.database ;
    var result = await db.rawDelete('DELETE FROM $postTable WHERE $colId = $id '); //Convert ti map then uodate where id  /?
    return result ;
  }

  //Get number of Posts in database
  Future<int> getCount() async {
    Database db = await this.database ;
    List<Map<String , dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $postTable');
    int result = Sqflite.firstIntValue(x);
    return result ;
  }


  Future<List<Post>> getPostList() async {
    var postMapList = await getPostMapList() ;
    int count  = postMapList.length;

    List<Post> postList = List<Post>() ;
    for(int i = 0; i < count; i++ ) {
      postList.add(Post.fromMapObject(postMapList[i]));
    }
    return postList; //from here Code has been cloned to Projects
  }


}
