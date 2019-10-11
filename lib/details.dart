import 'package:flutter/material.dart';


class DetailsPage extends StatelessWidget{

  final String name;
  final String statement;
  final Function deleteFunction;
  DetailsPage({this.name, this.statement, this.deleteFunction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete), 
            onPressed: ()=>deleteFunction(context, name),
              )
        ],
      ),
      body: Center(
        child: Text(statement),
      ),
    );
  }
}