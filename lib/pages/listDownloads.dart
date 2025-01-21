import 'package:flutter/material.dart';

class Listdownloads extends StatefulWidget {
  const Listdownloads({super.key});

  @override
  State<Listdownloads> createState() => _ListdownloadsState();
}

class _ListdownloadsState extends State<Listdownloads> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Telechargements',style: TextStyle(color: Colors.white),),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('List of downloads'),
      ),
    );
  }
}