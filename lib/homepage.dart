import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_admob/firebase_admob.dart';

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
        //anchorOffset: 60.0,
        // Positions the banner ad 10 pixels from the center of the screen to the right
        //horizontalCenterOffset: 10.0,
        // Banner Position
        anchorType: AnchorType.bottom,
      ); 
    });
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Scrollbar(child: getListView()),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blueAccent,
          child: Icon(Icons.add),
          onPressed: ()=>createUserPopupDialog(context),
        ),
       bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Container(height: 50.0,),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget getListView(){
  var listView = ListView.builder(
        itemCount: userNames.length,
        itemBuilder: (context, index){
          return Card(
            margin: const EdgeInsets.only(right: 5,bottom: 5,left: 5),
            child:ListTile(
            title: Text(userNames[index]),
            trailing: Text(
              users[userNames[index]].toString(),
              style: TextStyle(color: users[userNames[index]] > 0 ? Colors.green : users[userNames[index]] == 0 ? Colors.blue : Colors.redAccent),
              ),
            onTap: () => updateUserPopupDialog(context, userNames[index]),
            onLongPress: () => deleteUserPopupDialog(context, userNames[index]),
          ),);
        },);
    return listView;
  }
}
MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
  keywords: <String>['grocery', 'insurance'],
  contentUrl: 'https://flutter.io',
  childDirected: false,
  testDevices: <String>[], // Android emulators are considered test devices
);
BannerAd myBanner = BannerAd(
  // Replace the testAdUnitId with an ad unit id from the AdMob dash.
  // https://developers.google.com/admob/android/test-ads
  // https://developers.google.com/admob/ios/test-ads
  adUnitId: BannerAd.testAdUnitId,
  size: AdSize.smartBanner,
  targetingInfo: targetingInfo,
  listener: (MobileAdEvent event) {
    print("BannerAd event is $event");
  },
);
