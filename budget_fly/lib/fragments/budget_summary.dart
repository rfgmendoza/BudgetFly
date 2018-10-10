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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _chartCard(),
            Expanded(child:Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child:_totalDueCard()),
                Expanded(child:_paidSoFarCard()),
              ]
            )),
            Expanded(child:Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [              
              Expanded(child:_spendPerDayCard()),
              Expanded(child:_amountAvailableCard()),
            ]))
            
            
            
            
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

  

  

  

  Future<String> _getTotalDue() async {
    await DBCommon().openDBConnection();
    BudgetSettingsModel bsModel = await DBCommon().getBudgetSettings(null);
    
    if(bsModel.lastPayDay == null || bsModel.nextPayDay == null)
      return "0 Pay days not set";
    
    Store store = await DBCommon().getStore("budget");
    List<Record> recordList = await store.records.toList();
    num totalDue = calculateTotalDueInPayPeriod(getBillsInPayPeriod(recordList, bsModel));
    return totalDue.toStringAsFixed(2);
  }

  

  Future<String> _getPaidSoFar() async {
    await DBCommon().openDBConnection();
    BudgetSettingsModel bsModel = await DBCommon().getBudgetSettings(null);
    
    if(bsModel.lastPayDay == null || bsModel.nextPayDay == null)
      return "0 Pay days not set";
    
    Store store = await DBCommon().getStore("budget");
    List<Record> recordList = await store.records.toList();
    num totalDue = calculateAmountDueSoFar(getBillsInPayPeriod(recordList,bsModel),bsModel);
    return totalDue.toStringAsFixed(2);
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

  Future<List<CircularStackEntry>> _getChartData() async {
    List<num> numList = new List<num>();
    var amountAvailable = await _getAmountAvailable();
    numList.add(num.tryParse(amountAvailable)??0.00);
    var totalDue = await _getTotalDue();
    numList.add(num.tryParse(totalDue)??0.00);

    List<CircularStackEntry> outList = <CircularStackEntry>[
  new CircularStackEntry(
    <CircularSegmentEntry>[
      
      new CircularSegmentEntry(numList[1].toDouble(), Colors.red[200], rankKey: 'b1'),
      new CircularSegmentEntry(numList[0].toDouble(), Colors.green[200], rankKey: 'b2'),
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
                  return Column(
                    children: <Widget>[
                      AnimatedCircularChart(
                        labelStyle: new TextStyle(fontSize: 24.0, color: Colors.green),
                        holeRadius: 50.0,
                        holeLabel: "\$"+snapshot.data[0].entries[1].value.toStringAsFixed(2)+"\nAvailable ",
                        key: _chartKey,
                        initialChartData: snapshot.data,
                        chartType: CircularChartType.Radial,
                        edgeStyle: SegmentEdgeStyle.round,
                        size: Size.square(400.0)
                        ),
                    ],
                  );

                }
              }
              else if(snapshot.hasError)
                return Text("${snapshot.error}");
          }
        }
      );
    
  }

  Card _buildSummaryCard(Future future, String title, Color color){
    return Card(
      color: color,
        child: 
      FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          switch (snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return new CircularProgressIndicator();
            default:
              if(snapshot.hasData) {
                if(snapshot.data !=null){
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("\$${snapshot.data}", style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.white),),
                      ),
                    Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 16.0, ),),
                    
                    ]
                  );

                }
              }
              else if(snapshot.hasError)
                return Text("${snapshot.error}");
          }
        }
      )
    );
  }
  _amountAvailableCard() {
    return _buildSummaryCard(_getAmountAvailable(), "Total Amount Available", Colors.green[200]);
    
  }
  _paidSoFarCard() {
    return _buildSummaryCard(_getPaidSoFar(), "Amount Paid So Far", Colors.red[300]);
    
  }

  _totalDueCard() {
    return _buildSummaryCard(_getTotalDue(), "Total Amount Due", Colors.red[200]);
    
  }

  _spendPerDayCard() {
    return _buildSummaryCard(_getPerDiem(), "Amount Available Per Day", Colors.green[100]);
    
  }
}
