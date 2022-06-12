import 'dart:ffi';

class Post {
  late String hotel_Id;
  late String nome;
  late var estrelas;
  late var diaria;
  late String cidade;

  Post(this.hotel_Id, this.nome, this.estrelas, this.diaria, this.cidade);
}
