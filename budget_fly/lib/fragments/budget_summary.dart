import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sembast/sembast.dart';
import 'package:budget_fly/pages/home_page.dart';
import 'package:budget_fly/share/database_common.dart'
    show DBCommon, BudgetSettingsModel;

class BudgetSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          // here we display the title corresponding to the fragment
          // you can instead choose to have a static title
          title: new Text("Summary"),
        ),
        drawer: getDrawer(context),
        body: Column(
          children: <Widget>[
            _spendPerDayCard(),
            _totalDueCard(),
            _paidSoFarCard(),
            _amountAvailableCard(),
          ],
        ));
  }

  Future<String> _getPerDiem() async {
    await DBCommon().openDBConnection();
    BudgetSettingsModel bsModel = await DBCommon().getBudgetSettings(null);
    
    if(bsModel.lastPayDay == null || bsModel.nextPayDay == null)
      return "0 Pay days not set";
    
    Store store = await DBCommon().getStore("budget");
    List<Record> recordList = await store.records.toList();
    num totalDue = 0;
    recordList.forEach((record){
      DateTime dayDue = DBCommon().parseDayDue(record.value[0]["dayDue"]);
      dayDue = DBCommon().setDateToNextMonth(dayDue);

      if(dayDue.day > bsModel.lastPayDay.day && dayDue.day <= bsModel.nextPayDay.day){
        totalDue += num.parse(record.value[0]["amount"]);
      }
    });
    num totalDays = (bsModel.nextPayDay.difference(bsModel.lastPayDay).inDays);
    num returnValue = (bsModel.paycheck - totalDue) / totalDays;
    return returnValue.toStringAsFixed(2);
  }

  

  

  _spendPerDayCard() {
    return Card(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      FutureBuilder(
        future: _getPerDiem(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return new CircularProgressIndicator();
            default:
              if(snapshot.hasData) {
                if(snapshot.data !=null){
                  return ListTile(
                    title: Text("Daily Free Budget"),
                    subtitle: Text("\$${snapshot.data}"),
                  );

                }
              }
              else if(snapshot.hasError)
                return Text("${snapshot.error}");
          }
        }
      )
    ]));
  }

  Future<String> _getTotalDue() async {
    await DBCommon().openDBConnection();
    BudgetSettingsModel bsModel = await DBCommon().getBudgetSettings(null);
    
    if(bsModel.lastPayDay == null || bsModel.nextPayDay == null)
      return "0 Pay days not set";
    
    Store store = await DBCommon().getStore("budget");
    List<Record> recordList = await store.records.toList();
    num totalDue = 0;
    recordList.forEach((record){
      DateTime dayDue = DBCommon().parseDayDue(record.value[0]["dayDue"]);

      if(DBCommon().dayDueInPayPeriod(dayDue, bsModel)){
        totalDue += num.parse(record.value[0]["amount"]);
      }
    });
    return totalDue.toString();
  }

  _totalDueCard() {
    return Card(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      FutureBuilder(
        future: _getTotalDue(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return new CircularProgressIndicator();
            default:
              if(snapshot.hasData) {
                if(snapshot.data !=null){
                  return ListTile(
                    title: Text("Total Due For Bills"),
                    subtitle: Text("\$${snapshot.data}"),
                  );

                }
              }
              else if(snapshot.hasError)
                return Text("${snapshot.error}");
          }
        }
      )
    ]));
  }

  Future<String> _getPaidSoFar() async {
    await DBCommon().openDBConnection();
    BudgetSettingsModel bsModel = await DBCommon().getBudgetSettings(null);
    
    if(bsModel.lastPayDay == null || bsModel.nextPayDay == null)
      return "0 Pay days not set";
    
    Store store = await DBCommon().getStore("budget");
    List<Record> recordList = await store.records.toList();
    num totalDue = 0;
    recordList.forEach((record){
      DateTime dayDue = DBCommon().parseDayDue(record.value[0]["dayDue"]);

      if(DBCommon().dayDueInPayPeriod(dayDue, bsModel) && dayDue.difference(DateTime.now()).isNegative){
        totalDue += num.parse(record.value[0]["amount"]);
      }
    });
    return totalDue.toString();
  }

  _paidSoFarCard() {
    return Card(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      FutureBuilder(
        future: _getPaidSoFar(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return new CircularProgressIndicator();
            default:
              if(snapshot.hasData) {
                if(snapshot.data !=null){
                  return ListTile(
                    title: Text("Amount Paid So Far"),
                    subtitle: Text("\$${snapshot.data}"),
                  );

                }
              }
              else if(snapshot.hasError)
                return Text("${snapshot.error}");
          }
        }
      )
    ]));
  }

  Future<String> _getAmountAvailable() async {
    await DBCommon().openDBConnection();
    BudgetSettingsModel bsModel = await DBCommon().getBudgetSettings(null);
    
    if(bsModel.lastPayDay == null || bsModel.nextPayDay == null)
      return "0 Pay days not set";
    
    Store store = await DBCommon().getStore("budget");
    List<Record> recordList = await store.records.toList();
    num totalDue = 0;
    recordList.forEach((record){
      DateTime dayDue = DBCommon().parseDayDue(record.value[0]["dayDue"]);

      if(DBCommon().dayDueInPayPeriod(dayDue, bsModel)){
        totalDue += num.parse(record.value[0]["amount"]);
      }
    });
    num netBudget = bsModel.paycheck - totalDue;
    return netBudget.toString();
  }

  _amountAvailableCard() {
    return Card(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      FutureBuilder(
        future: _getAmountAvailable(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return new CircularProgressIndicator();
            default:
              if(snapshot.hasData) {
                if(snapshot.data !=null){
                  return ListTile(
                    title: Text("Total Amount Available"),
                    subtitle: Text("\$${snapshot.data}"),
                  );

                }
              }
              else if(snapshot.hasError)
                return Text("${snapshot.error}");
          }
        }
      )
    ]));
  }
}
