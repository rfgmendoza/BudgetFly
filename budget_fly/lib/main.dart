
import 'package:budget_fly/pages/home_page.dart';
import 'package:budget_fly/fragments/budget_list.dart';
import 'package:budget_fly/fragments/add_budget_item.dart';
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'NavigationDrawer Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new BudgetList(),
      routes: <String, WidgetBuilder> {
        '/list': (BuildContext context) => new BudgetList(),
        '/add': (BuildContext context) => new AddBudgetItem(),
      
      }
    );
  }
}