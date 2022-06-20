import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as http;
import 'dart:async';

import 'Post.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _urlBase = "https://mysqlhotel.herokuapp.com/hoteis";
  //String _urlBase = "https://jsonplaceholder.typicode.com/posts";
  List<Post> postagens = [];

  Future<List<Post>> recuperarPostagens() async {
    http.Response response = await http.get(_urlBase);
    var dadosJon = json.decode(response.body);
    var dados = dadosJon['hoteis'];
    postagens.clear();

    for (var post in dados) {
      Post p = Post(post["hotel_id"], post["nome"], post["estrelas"],
          post["diaria"], post["cidade"]);

      postagens.add(p);
    }

    return postagens;
  }

  _recuperarBancoDados() async {
    final caminhoBancoDados = await getDatabasesPath();
    final localBancoDados = join(caminhoBancoDados, "banco.db");

    var bd = await openDatabase(localBancoDados, version: 1,
        onCreate: (db, dbVersaoRecente) {
      String sql =
          "CREATE TABLE usuarios (id INTEGER PRIMARY KEY AUTOINCREMENT, nome VARCHAR, idade INTEGER) ";
      db.execute(sql);
    });

    return bd;
    //print("aberto: " + bd.isOpen.toString());
  }

  _salvar() async {
    Database bd = await _recuperarBancoDados();

    Map<String, dynamic> dadosUsuario = {"nome": "bruno", "idade": 23};
    int id = await bd.insert("usuarios", dadosUsuario);
    print("Salvo: $id ");
  }

  _listarUsuarios() async {
    Database bd = await _recuperarBancoDados();

    //String sql = "SELECT * FROM usuarios WHERE id = 5 ";
    //String sql = "SELECT * FROM usuarios WHERE idade >= 30 AND idade <= 58";
    //String sql = "SELECT * FROM usuarios WHERE idade BETWEEN 18 AND 46 ";
    //String sql = "SELECT * FROM usuarios WHERE idade IN (18,30) ";
    //String filtro = "an";
    //String sql = "SELECT * FROM usuarios WHERE nome LIKE '%" + filtro + "%' ";
    //String sql = "SELECT *, UPPER(nome) as nomeMaiu FROM usuarios WHERE 1=1 ORDER BY UPPER(nome) DESC ";//ASC, DESC
    String sql = "SELECT * FROM usuarios"; //ASC, DESC
    List usuarios = await bd.rawQuery(sql);

    for (var usuario in usuarios) {
      print("item id: " +
          usuario['id'].toString() +
          " nome: " +
          usuario['nome'] +
          " idade: " +
          usuario['idade'].toString());
    }

    //print("usuarios: " + usuarios.toString() );
  }

  post() async {
    var corpo = json.encode({
      "nome": "marcos Hotel",
      "estrelas": 4.7,
      "diaria": 800,
      "cidade": "curitiba"
    });
    http.Response response = await http.post(_urlBase + "/marcos",
        headers: {"Content-type": "application/json; charset=UTF-8"},
        body: (corpo));
    print("resposta: ${response.statusCode}");
    print("resposta: ${response.body}");
  }

  @override
  Widget build(BuildContext context) {
    //_recuperarBancoDados();
    //_listarUsuarios();
    //_salvar();

    return Scaffold(
      appBar: AppBar(
        title: Text('Consumo de serviço avançado'),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    post();
                  },
                  child: Text("Post"),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      recuperarPostagens();
                    });
                  },
                  child: Text('Get'),
                ),
              ],
            ),
            Expanded(
              child: FutureBuilder<List<Post>>(
                  future: recuperarPostagens(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        return widget;

                      case ConnectionState.waiting:
                        return Center(
                          child: CircularProgressIndicator(),
                        );

                      case ConnectionState.active:
                        return widget;
                      case ConnectionState.done:
                        if (snapshot.hasError) {
                          print("lista: Erro ao carregar");
                        } else {
                          return ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                List<Post>? lista = snapshot.data;
                                Post post = lista![index];

                                return ListTile(
                                  title: Text(post.hotel_Id),
                                  subtitle: Text(post.cidade.toString()),
                                );
                              });
                        }
                        return widget;
                        break;
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
