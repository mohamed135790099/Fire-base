import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
  });
}

class Products with ChangeNotifier {
  List<Product> productsList = [];
  final String token;

  Products(this.token,this.productsList);


  Future<void> fetchDate() async {
    try {
      var url = Uri.parse(
          'https://flutter-app-d5c1f-default-rtdb.firebaseio.com/product.json?auth=$token');
      final http.Response res = await http.get(url);
      final extractedDate = json.decode(res.body) as Map<String, dynamic>;
      extractedDate.forEach((proId, proData) async {
        final proIndex = productsList.indexWhere((element) => element.id == proId);
        if(proIndex>=0){
          productsList[proIndex] = Product(
            id: proId,
            title: proData['title'],
            description: proData['description'],
            price: proData['price'],
            imageUrl:proData['imageUrl'],
          );
        }
        else{
          productsList.add(
            Product(
                id: proId,
                title: proData['title'],
                description: proData['description'],
                price: proData['price'],
                imageUrl: proData['imageUrl']),
          );
        }
        notifyListeners();
      });
    } catch (Error) {
      throw Error;
    }
  }

  Future<void> updateData(String id) async {
    var url = Uri.parse(
        'https://flutter-app-d5c1f-default-rtdb.firebaseio.com/product/$id.json?auth=$token');
    final proIndex = productsList.indexWhere((element) => element.id == id);
    if (proIndex >= 0) {
      await http.patch(url,
          body: json.encode({
            'id': 'id',
            'title': 'new title',
            'description': 'new description',
            'price': 999.99,
            'imageUrl':
                'https://img.freepik.com/free-photo/wide-angle-shot-single-tree-growing-clouded-sky-during-sunset-surrounded-by-grass_181624-22807.jpg?size=626&ext=jpg&ga=GA1.2.864507418.1615593600',
          }));
    } else {
      print('..........');
    }
    productsList[proIndex] = Product(
      id: id,
      title: 'new title',
      description: 'new description',
      price: 150.99,
      imageUrl: 'https://img.freepik.com/free-photo/wide-angle-shot-single-tree-growing-clouded-sky-during-sunset-surrounded-by-grass_181624-22807.jpg?size=626&ext=jpg&ga=GA1.2.864507418.1615593600',
    );

    notifyListeners();
  }

  Future<void> add(
      {required String id,
      required String title,
      required String description,
      required double price,
      required String imageUrl}) async {
    try {
      var url = Uri.parse(
          'https://flutter-app-d5c1f-default-rtdb.firebaseio.com/product.json?auth=$token');
      http.Response res = await http.post(url,
          body: json.encode({
            'id': id,
            'title': title,
            'description': description,
            'price': price,
            'imageUrl': imageUrl,
          }));

      productsList.add(Product(
        id: '${json.decode(res.body)['name']}',
        title: title,
        description: description,
        price: price,
        imageUrl: imageUrl,
      ));
      notifyListeners();
    } catch (error) {
      throw error;
    }

    //print(imageUrl);
  }

  void delete(String id)async{
    var url = Uri.parse('https://flutter-app-d5c1f-default-rtdb.firebaseio.com/product/$id.json?auth=$token');
    final proIndex = productsList.indexWhere((element) => element.id == id);
    var proItem=productsList[proIndex];
    productsList.removeAt(proIndex);
    //productsList.removeWhere((element) => element.id == id);
    var res=await http.delete(url);
    if(res.statusCode>=400){
      productsList.insert(proIndex,proItem);
      notifyListeners();
      print('code not deleted Item');

    }
    else{
      productsList!='';
      print('Item deleted');

    }
    notifyListeners();

  }
}
