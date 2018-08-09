
import '../fragments/budget_list.dart';
import '../fragments/add_budget_item.dart';
import 'package:budget_fly/fragments/budget_config.dart';

import 'package:flutter/material.dart';

class DrawerItem {
  String title;
  IconData icon;
  DrawerItem(this.title, this.icon);
}

class HomePage extends StatefulWidget {
  

  @override
  State<StatefulWidget> createState() {
    return new HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  int _selectedDrawerIndex = 0;
  GlobalKey _homepagekey=  new GlobalKey<ScaffoldState>();
  
  _getDrawerItemWidget(int pos, GlobalKey<ScaffoldState> key) {
    switch (pos) {
      case 0:
        return new BudgetList(homepagekey: _homepagekey);
      case 1:
        return new AddBudgetItem();
      case 2:
        return new ThirdFragment();

      default:
        return new Text("Error");
    }
  }
  
  _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
    Navigator.of(context).pop(); // close the drawer
  }

  _loadPage(int index) {
    setState(() {
          _selectedDrawerIndex = index;
        });
  }

  @override
  Widget build(BuildContext context) {
    

    return new Scaffold(
      key: _homepagekey,
      appBar: new AppBar(
        // here we display the title corresponding to the fragment
        // you can instead choose to have a static title
        title: new Text("test"),
      ),
      drawer: getDrawer(context),
      body: _getDrawerItemWidget(_selectedDrawerIndex, _homepagekey),
      
    );
  }
}

_getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return new BudgetList();
      case 1:
        return new AddBudgetItem();
      case 2:
        return new ThirdFragment();

      default:
        return new Text("Error");
    }
  }

Drawer getDrawer(BuildContext context){

  final drawerItems = [
    new DrawerItem("Budget List", Icons.list),
    new DrawerItem("Add Budget Item", Icons.add),
    new DrawerItem("Fragment 3", Icons.info)
  ];
  var drawerOptions = <Widget>[];
    for (var i = 0; i < drawerItems.length; i++) {
      var d = drawerItems[i];
      drawerOptions.add(
        new ListTile(
          leading: new Icon(d.icon),
          title: new Text(d.title),          
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=>_getDrawerItemWidget(i)));
          },
        )
      );
    }

  return new Drawer(
        child: new Column(
          children: <Widget>[
            new UserAccountsDrawerHeader(
                accountName: new Text("John Doe"), accountEmail: null),
            new Column(children: drawerOptions)
          ],
        ),
      );
}


