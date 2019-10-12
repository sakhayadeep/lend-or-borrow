import 'package:flutter/material.dart';


class DetailsPage extends StatefulWidget{

  final String name;
  final String statement;
  final Function editFunction;
  final Function deleteFunction;
  DetailsPage({@required this.name, @required this.statement, @required this.editFunction, @required this.deleteFunction});

  @override
  State<StatefulWidget> createState() {
    return _DetailsPageState();
  }
}

class _DetailsPageState extends State<DetailsPage>{

  String name;
  String statement;
  Function editFunction;
  Function deleteFunction;
  //bool isChanged = true;

@override
  void initState() {
    name = widget.name;
    statement = widget.statement;
    editFunction = widget.editFunction;
    deleteFunction = widget.deleteFunction;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(name),
          actions: <Widget>[
                IconButton(
              icon: Icon(Icons.edit), 
              onPressed: (){
                Navigator.of(context).pop();
                return editFunction(context, name);
              },
                ),
                IconButton(
              icon: Icon(Icons.delete), 
              onPressed: (){
                  Navigator.of(context).pop();
                  return deleteFunction(context, name);
                },
                ),
          ],
        ),
        body: Center(
          child: Text(statement),
        ),
      );
  }
}