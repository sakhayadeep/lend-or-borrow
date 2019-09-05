import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  Map<String, double> users = Map();
  List<String> userNames = List();

  createUserPopupDialog(BuildContext context){

    TextEditingController nameController = TextEditingController();
    TextEditingController amountController = TextEditingController();

    return showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text("Add new entry..."),
        content: ListView(
          shrinkWrap: true,
          children: <Widget>[
            ListTile(
                          leading: TextField(
                decoration: InputDecoration(
                  labelText: "Name",
                ),
                controller: nameController,
              ),
            ),
            ListTile(
                          leading: TextField(
                decoration: InputDecoration(
                  labelText: "Amount",
                ),
                controller: amountController,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          MaterialButton(
            elevation: 5.0,
            child: Text("Give"),
            onPressed: (){
              String name = nameController.text.toString();
              double amount = double.tryParse(amountController.text.toString()) ?? double.infinity;
              if(name != "" && amount != double.infinity){
                  createUser(name, amount);
                  Navigator.of(context).pop();   
              }
            },
          ),
          MaterialButton(
            elevation: 5.0,
            child: Text("Take"),
            onPressed: (){
              String name = nameController.text.toString();
              double amount = double.tryParse(amountController.text.toString()) ?? double.infinity;
              if(name != "" && amount != double.infinity){
                  createUser(name, -amount);
                  Navigator.of(context).pop();   
              }
            },
          ),

        ],
      );
    });

  }

  updateUserPopupDialog(BuildContext context, String name){

    TextEditingController amountController = TextEditingController();
    
    return showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text("Update entry..."),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(name),
            TextField(
              decoration: InputDecoration(
                labelText: "Amount",
              ),
              controller: amountController,
            ),
          ],
        ),
        actions: <Widget>[
          MaterialButton(
            elevation: 5.0,
            child: Text("Give"),
            onPressed: (){
              double amount = double.tryParse(amountController.text.toString()) ?? double.infinity;
              if(amount != double.infinity){
                  updateAmount(name, amount);
                  Navigator.of(context).pop();
              }
            },
          ),
          MaterialButton(
            elevation: 5.0,
            child: Text("Take"),
            onPressed: (){
              double amount = double.tryParse(amountController.text.toString()) ?? double.infinity;
              if(amount != double.infinity){
                  updateAmount(name, -amount);
                  Navigator.of(context).pop();  
              }
            },
          ),

        ],
      );
    });
  }

  deleteUserPopupDialog(BuildContext context, String name){
    return showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text("Delete?"),
        content: Text("Are you sure you want to delte entry for $name"),
        actions: <Widget>[
          MaterialButton(
            elevation: 5.0,
            child: Text("No"),
            onPressed: (){
                  Navigator.of(context).pop();
            },
          ),
          MaterialButton(
            elevation: 5.0,
            child: Text("Yes"),
            onPressed: (){
                  deleteUser(name);
                  Navigator.of(context).pop();  
            },
          ),

        ],
      );
    });

  }

  void createUser(String name, double amount){
    try{
      if(!users.containsKey(name)){
        setState(() {
          users[name] = amount;
          userNames.add(name);
        }); 
      }else{
        updateAmount(name, amount);
      }
    }
    catch(e){
      print(e.toString());
    }
  }

  void deleteUser(String name){

    if(users.containsKey(name)){
      
      setState(() {
        users.remove(name);
        userNames.remove(name);
      });
    }else{
      print("$name does not exist.");
    }

  }

  void updateAmount(String name, double amount){
    try{
      setState(() {
        users[name] += amount;
      });
    }
    catch(e){
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: getListView(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: ()=>createUserPopupDialog(context),
         ),
    );
  }

  Widget getListView(){
  var listView = ListView.builder(
        itemCount: userNames.length,
        itemBuilder: (context, index){
          return Card(
            child:ListTile(
            title: Text(userNames[index]),
            trailing: Text(
              users[userNames[index]].toString(),
              style: TextStyle(color: users[userNames[index]] > 0 ? Colors.green : users[userNames[index]] == 0 ? Colors.yellowAccent : Colors.redAccent),
              ),
            onTap: () => updateUserPopupDialog(context, userNames[index]),
            onLongPress: () => deleteUserPopupDialog(context, userNames[index]),
          ),);
        },);

    return listView;
  }
}