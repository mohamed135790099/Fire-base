import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:st/auth.dart';
import 'package:st/auth_screen.dart';
import 'package:st/splashscreen.dart';

import 'add_products.dart';
import 'product_details.dart';
import 'products.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  /*
 try{
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: "bbs.allen@example.com",
        password: "SuperSecretPassword!"
    );
    UserCredential userCredentialsign = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: "barry.allen@example.com",
        password: "SuperSecretPassword!"
    );
  }catch(e){print(e);}
 * */

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<Auth>(
        create: (_) => Auth(),
      ),
      ChangeNotifierProxyProvider<Auth, Products>(
        create: (_) => Products('', []),
        update: (context, value, perviousProducts) => Products(value.token!,
            perviousProducts == null ? [] : perviousProducts.productsList),
      )
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<Auth>(
      builder: (BuildContext context, value, _) => MaterialApp(
        theme: ThemeData(
            primaryColor: Colors.orange,
            canvasColor: const Color.fromRGBO(255, 238, 219, 1)),
        debugShowCheckedModeBanner: false,
        home: value.isAuth
            ? const MyHomePage()
            : FutureBuilder(
                future: value.tryAutoLogin(),
                builder: (context, snapshot) =>
                    snapshot.connectionState == ConnectionState.waiting
                        ? const SplashScreen()
                        : AuthScreen()),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoading = true;

  @override
  void initState() {
    Provider.of<Products>(context, listen: false)
        .fetchDate()
        .then((_) => isLoading = false);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Product> prodList =
        Provider.of<Products>(context, listen: true).productsList;

    Widget detailCard(id, tile, desc, price, imageUrl, ctx) {
      return FlatButton(
        onPressed: () {
          Navigator.push(
            ctx,
            MaterialPageRoute(builder: (_) => ProductDetails(id)),
          ).then(
              (id) => Provider.of<Products>(context, listen: false).delete(id));
        },
        child: Column(
          children: [
            const SizedBox(height: 5),
            Card(
              elevation: 10,
              color: const Color.fromRGBO(115, 138, 119, 1),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.only(right: 10),
                      width: 130,
                      child: Hero(
                        tag: id,
                        child: Image.network(imageUrl, fit: BoxFit.fill),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 10),
                        Text(
                          tile,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        const Divider(color: Colors.white),
                        Container(
                          width: 200,
                          child: Text(
                            desc,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                            softWrap: true,
                            overflow: TextOverflow.fade,
                            textAlign: TextAlign.justify,
                            maxLines: 3,
                          ),
                        ),
                        const Divider(color: Colors.white),
                        Text(
                          "\$$price",
                          style: const TextStyle(
                              color: Colors.black, fontSize: 18),
                        ),
                        const SizedBox(height: 13),
                      ],
                    ),
                  ),
                  const Expanded(flex: 1, child: Icon(Icons.arrow_forward_ios)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products'),
        actions: [
          FlatButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => AuthScreen()));
                // Provider.of<Auth>(context,listen:false).logout();
              },
              child: const Text('LogOut')),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (prodList.isEmpty
              ? const Center(
                  child: Text('No Products Added.',
                      style: TextStyle(fontSize: 22)))
              : RefreshIndicator(
                  onRefresh: () async =>
                      await Provider.of<Products>(context, listen: false)
                          .fetchDate()
                          .then((_) => isLoading = false),
                  child: ListView(
                    children: prodList
                        .map(
                          (item) => Builder(
                              builder: (ctx) => detailCard(
                                  item.id,
                                  item.title,
                                  item.description,
                                  item.price,
                                  item.imageUrl,
                                  ctx)),
                        )
                        .toList(),
                  ),
                )),
      floatingActionButton: Container(
        width: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Theme.of(context).primaryColor,
        ),
        child: FlatButton.icon(
          label: const Text("Add Product",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
          icon: const Icon(Icons.add),
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => AddProduct())),
        ),
      ),
    );
  }
}
