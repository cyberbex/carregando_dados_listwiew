import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

import 'Post.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _urlBase = "https://appcursoflask.herokuapp.com/hoteis";
  //String _urlBase = "https://jsonplaceholder.typicode.com";
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

  post() async {
    var corpo = json.encode({
      "nome": "cyberbex Hotel",
      "estrelas": 2.4,
      "diaria": 1466.9,
      "cidade": "londrina"
    });
    http.Response response = await http.post(_urlBase + "/cyberbex",
        headers: {"Content-type": "application/json; charset=UTF-8"},
        body: (corpo));
    print("resposta: ${response.statusCode}");
    print("resposta: ${response.body}");
  }

  @override
  Widget build(BuildContext context) {
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
