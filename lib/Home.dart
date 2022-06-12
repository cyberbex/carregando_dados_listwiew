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
  String _urlBase = "https://appbluemusic.herokuapp.com/hoteis";
  //String _urlBase = "https://jsonplaceholder.typicode.com";
  List<Post> postagens = [];

  Future<List<Post>> recuperarPostagens() async {
    http.Response response = await http.get(_urlBase);
    var dadosJon = json.decode(response.body);
    var dados = dadosJon['hoteis'];

    for (var post in dados) {
      Post p = Post(post["hotel_id"], post["nome"], post["estrelas"],
          post["diaria"], post["cidade"]);
      postagens.add(p);
    }
    return postagens;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consumo de serviço avançado'),
      ),
      body: FutureBuilder<List<Post>>(
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
    );
  }
}
