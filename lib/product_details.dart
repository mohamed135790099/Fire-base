import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'products.dart';

class ProductDetails extends StatelessWidget {
  final String id;

  ProductDetails(this.id);

  @override
  Widget build(BuildContext context) {
    List<Product> prodList = Provider.of<Products>(context, listen: true).productsList;

    var filteredItem = prodList.firstWhere((element) => element.id == id);

    return Scaffold(
      appBar: AppBar(
          actions: [
            FlatButton(onPressed: (){ Provider.of<Products>(context, listen:false).updateData(id);}, child:const Text('Update Date'),)
          ],
          backgroundColor: Colors.amber,
          title: filteredItem == null ? null : Text(filteredItem.title)),
      body: filteredItem == null
          ? null
          : ListView(
              children: [
                const SizedBox(height: 10),
                buildContainer(filteredItem.imageUrl, filteredItem.id),
                const SizedBox(height: 10),
                buildCard(filteredItem.title, filteredItem.description,
                    filteredItem.price),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () {
          Navigator.pop(context, filteredItem.id);
        },
        child:const Icon(Icons.delete, color: Colors.black),
      ),
    );
  }

  Container buildContainer(String image, String id) {
    return  Container(
      width: double.infinity,
      child: Center(
        child: Hero(
          tag: id,
          child: Image.network(image),
        ),
      ),
    );
  }

  Card buildCard(String title, String desc, double price) {
    return Card(
      elevation: 10,
      margin:const EdgeInsets.all(7),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(color: Colors.black),
            Text(desc,
                style: const TextStyle(fontSize: 16), textAlign: TextAlign.justify),
            const Divider(color: Colors.black),
            Text(
              "\$$price",
              style:const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
