import 'package:flutter/material.dart';

class Listfav extends StatefulWidget {
  const Listfav({super.key});

  @override
  State<Listfav> createState() => _ListfavState();
}

class _ListfavState extends State<Listfav> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Favoris',style: TextStyle(color: Colors.white),),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('List of favorites'),
      ),
    );
  }
}