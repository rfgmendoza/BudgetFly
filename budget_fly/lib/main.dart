
import 'package:budget_fly/fragments/budget_list.dart';
import 'package:budget_fly/fragments/add_budget_item.dart';
import 'package:budget_fly/fragments/budget_config.dart';
import 'package:budget_fly/fragments/budget_summary.dart';
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'NavigationDrawer Demo',
      theme: new ThemeData(
        primarySwatch: Colors.green,
        accentColor: Colors.lightGreen,
        splashColor: Colors.greenAccent,
        buttonColor: Colors.green[300],
        scaffoldBackgroundColor: Colors.white,
        
      ),
      home: new BudgetSummary(),
      routes: <String, WidgetBuilder> {
        '/summary' : (BuildContext context) => new BudgetSummary(), 
        '/list': (BuildContext context) => new BudgetList(),
        '/add': (BuildContext context) => new AddBudgetItem(),
        '/config': (BuildContext context) => new BudgetConfig(),
      }
    );
  }
}