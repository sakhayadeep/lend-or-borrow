import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_admob/firebase_admob.dart';
//import 'package:path/path.dart';
//import 'package:sqflite/sqflite.dart';

import './details.dart';
//import './dataModel.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Map<String, double> users = Map();
  List<String> userNames = List();

  _readSavedUserData() async {
        final prefs = await SharedPreferences.getInstance();
        
        final userDataKeys = prefs.getKeys()??new List();

      setState(() {
        for(var key in userDataKeys)
        {
          userNames.add(key);
          users[key] = prefs.getDouble(key);
        }
      });
      }

  _saveUserData() async {
        final prefs = await SharedPreferences.getInstance();
        String nKey;
        double nValue;
        users.forEach((name, amount){
          nKey = name;
          nValue = amount;
          prefs.setDouble(nKey, nValue);
        });
        
      }

  _deleteUserData(String key) async{
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);

  }

  @override
  void initState(){
    super.initState();
    _readSavedUserData();
  }

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
        content: Text("Are you sure you want to delete entry for $name"),
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

    _saveUserData();
  }

  void deleteUser(String name){

    if(users.containsKey(name)){
      
      setState(() {
        users.remove(name);
        userNames.remove(name);
        _deleteUserData(name);
      });
    }else{
      print("$name does not exist.");
    }

    _saveUserData();
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

    _saveUserData();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAdMob.instance.initialize(appId: "").then((response){
      myBanner
      ..load()
      ..show(
        anchorType: AnchorType.bottom,
      ); 
    });
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: ()=>createUserPopupDialog(context),
            ),
          ],
        ),
        body: Scrollbar(child: getListView()),
       bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Container(height: 50.0,),
      ),
    );
  }

  Widget getListView(){
  var listView = ListView.builder(
        itemCount: userNames.length,
        itemBuilder: (context, index){

          double amount = users[userNames[index]];
          String name = userNames[index];
          String statement = "You have " + (amount > 0 ? "given " : "taken ") + (amount > 0 ? amount.toString() : (-amount).toString()) + (amount > 0 ? " to " : " from ") + name;
          return Card(
            margin: const EdgeInsets.only(right: 5,bottom: 5,left: 5),
            child:ListTile(
                        
            title: Text(
              statement,
              style: TextStyle(color: amount > 0 ? Colors.green : amount < 0 ? Colors.red : Colors.black),              
              ),

            onLongPress: () => updateUserPopupDialog(context, name),
            onTap: ()=>Navigator.push(context,
                            new MaterialPageRoute(
                              builder: (context){
                                return DetailsPage(name: name, statement: statement, deleteFunction: deleteUserPopupDialog,);
                              }
                            )
                          ),
          ),);
        },);
    return listView;
  }
}
MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
  keywords: <String>['money', 'business', 'games', 'pubg'],
  contentUrl: 'https://flutter.io',
  childDirected: false,
  testDevices: <String>[], // Android emulators are considered test devices
);
BannerAd myBanner = BannerAd(
  // Replace the testAdUnitId with an ad unit id from the AdMob dash.
  // https://developers.google.com/admob/android/test-ads
  // https://developers.google.com/admob/ios/test-ads
  adUnitId: "",
  size: AdSize.smartBanner,
  targetingInfo: targetingInfo,
  listener: (MobileAdEvent event) {
    print("BannerAd event is $event");
  },
);
