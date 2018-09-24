import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sembast/sembast.dart';
import 'package:budget_fly/pages/home_page.dart';
import 'package:budget_fly/share/database_common.dart'
    show DBCommon, BudgetSettingsModel, BudgetItem;
import 'package:flutter_circular_chart/flutter_circular_chart.dart';

class BudgetSummary extends StatelessWidget {

  final GlobalKey<AnimatedCircularChartState> _chartKey = new GlobalKey<AnimatedCircularChartState>();

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
            _chartCard(),
          ],
        ));
  }
  
  num calculateTotalDueInPayPeriod(List<BudgetItem> recordList){
    num total = 0;
    recordList.forEach((item){
      total+=item.amount;
    });
    return total;
  }

  int calculateDaysInPayPeriod(BudgetSettingsModel bsModel){
    int days = 0;
    days = bsModel.nextPayDay.difference(bsModel.lastPayDay).inDays;
    return days;
  }
  
  num calculateAmountDueSoFar(List<BudgetItem> recordList, BudgetSettingsModel bsModel){
    num totalSoFar = 0;
    recordList.forEach((item){
      DateTime minusMonth = DateTime(item.dayDue.year, item.dayDue.month -1, item.dayDue.day);
      if(DBCommon().dayDueInPayPeriod(minusMonth, bsModel)){
        totalSoFar += item.amount;
      }
    }); 
    return totalSoFar;
  }

  List<BudgetItem> getBillsInPayPeriod(List<Record> recordList, BudgetSettingsModel bsModel){
    List<BudgetItem> listOut = new List<BudgetItem>();
    recordList.forEach((record){
      DateTime dayDue = DBCommon().parseDayDue(record.value[0]["dayDue"]);
      if(DBCommon().dayDueInPayPeriod(dayDue, bsModel)){
        listOut.add(DBCommon().mapToBudgetItem(record));
      }
    });
    return listOut;
  }

  Future<String> _getPerDiem() async {
    await DBCommon().openDBConnection();
    BudgetSettingsModel bsModel = await DBCommon().getBudgetSettings(null);
    
    if(bsModel.lastPayDay == null || bsModel.nextPayDay == null)
      return "0 Pay days not set";
    
    Store store = await DBCommon().getStore("budget");
    List<Record> recordList = await store.records.toList();
    num totalDue = calculateTotalDueInPayPeriod(getBillsInPayPeriod(recordList, bsModel));
    
    num totalDays = calculateDaysInPayPeriod(bsModel);
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
    num totalDue = calculateTotalDueInPayPeriod(getBillsInPayPeriod(recordList, bsModel));
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
    num totalDue = calculateAmountDueSoFar(getBillsInPayPeriod(recordList,bsModel),bsModel);
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
    num totalDue = calculateTotalDueInPayPeriod(getBillsInPayPeriod(recordList, bsModel));
    num netBudget = bsModel.paycheck - totalDue;
    return netBudget.toStringAsFixed(2);
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

  Future<List<CircularStackEntry>> _getChartData() async {
    List<num> numList = new List<num>();
    var amountAvailable = await _getAmountAvailable();
    numList.add(num.parse(amountAvailable));
    var totalDue = await _getTotalDue();
    numList.add(num.parse(totalDue));

    List<CircularStackEntry> outList = <CircularStackEntry>[
  new CircularStackEntry(
    <CircularSegmentEntry>[
      new CircularSegmentEntry(numList[0], Colors.green[200], rankKey: 'b1'),
      new CircularSegmentEntry(numList[1], Colors.red[200], rankKey: 'b2'),
  ],
    rankKey: 'Budget',
  ),
];
  
    return outList;
  }

  _chartCard() {
    return 
      FutureBuilder(
        future: _getChartData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return new CircularProgressIndicator();
            default:
              if(snapshot.hasData) {
                if(snapshot.data !=null){
                  return AnimatedCircularChart(
                    holeRadius: 50.0,
                    holeLabel: "Totals:\n\$"+snapshot.data[0].entries[0].value.toString()+" available \n\$"+snapshot.data[0].entries[1].value.toString()+" due",
                    key: _chartKey,
                    initialChartData: snapshot.data,
                    chartType: CircularChartType.Radial,
                    size: Size.square(250.0)
                    );

                }
              }
              else if(snapshot.hasError)
                return Text("${snapshot.error}");
          }
        }
      );
    
  }
}
