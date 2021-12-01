import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import 'products.dart';

class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  var titleController = TextEditingController();
  var descController = TextEditingController();
  var priceController = TextEditingController();
  var imageUrlCont = TextEditingController();
  var _loading = false;
  double price = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                        labelText: "Title", hintText: "Add title"),
                    controller: titleController,
                  ),
                  TextField(
                    decoration: const InputDecoration(
                        labelText: "Description", hintText: "Add description"),
                    controller: descController,
                  ),
                  TextField(
                    decoration: const InputDecoration(
                        labelText: "Price", hintText: "Add price"),
                    controller: priceController,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: const InputDecoration(
                        labelText: "Image Url",
                        hintText: "Paste your image url here"),
                    controller: imageUrlCont,
                  ),
                  const SizedBox(height: 30),
                  Consumer<Products>(
                    builder: (ctx, value, _) => RaisedButton(
                      color: Colors.orangeAccent,
                      textColor: Colors.black,
                      child: const Text("Add Product"),
                      onPressed: () {
                        if (titleController.text.isEmpty ||
                            descController.text.isEmpty ||
                            priceController.text.isEmpty ||
                            imageUrlCont.text.isEmpty) {
                          Fluttertoast.showToast(
                              toastLength: Toast.LENGTH_LONG,
                              msg: 'Please enter all Fields');
                        } else {
                          try {
                            setState(() {
                              price = double.parse(priceController.text);
                              setState(() {
                                _loading = true;
                              });
                              value
                                  .add(
                                id: DateTime.now().toString(),
                                title: titleController.text,
                                description: descController.text,
                                price: double.parse(priceController.text),
                                imageUrl: imageUrlCont.text,
                              )
                                  .catchError((_) {
                               return  showDialog<Null>(
                                  context: context,
                                  builder: (innContext) => AlertDialog(
                                    title: const Text("An error curred !"),
                                    content: const Text('Something went wrong'),
                                    actions: [
                                      FlatButton(
                                        child: const Text("okay"),
                                        onPressed: () =>
                                            Navigator.of(innContext).pop(),
                                      )
                                    ],
                                  ),
                                );
                              }).then((_) {
                                setState(() {
                                  _loading = false;
                                });
                                Navigator.pop(context);
                              });
                            });
                          } catch (e) {
                            Fluttertoast.showToast(
                                toastLength: Toast.LENGTH_LONG,
                                msg: 'Please enter a valid price');
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
