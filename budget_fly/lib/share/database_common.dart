import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'dart:io' show Directory;
import 'package:path_provider/path_provider.dart';

enum BudgetItemType { creditCard, bill, subscription }

enum PayPeriodType { weekly, biweekly, monthly, firstAndFifteen }

class DBCommon {
  static Database db;

  String paycheck = "paycheck";
  String payPeriodType = "payperiodtype";
  String frequency = "frequency";
  String lastPayDay = "lastpayday";
  String nextPayDay = "nextpayday";
  String testData = "testData";
  bool testDataValue;

  Future openDBConnection() async {
    if (db == null) {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String dbPath = join(dirname(appDocDir.path), "sample.db");
      DatabaseFactory dbFactory = databaseFactoryIo;

      // We use the database factory to open the database
      db = await dbFactory.openDatabase(dbPath);
    }
  }

  Future<Store> getStore(String store) async {
    
    await openDBConnection();
    if (db != null)
    if(testDataValue ?? false)
      return db.getStore(store+"test");
    else
      return db.getStore(store);
    else
      return null;
  }

  BudgetItem mapToBudgetItem(Record record) {
    BudgetItem _budgetItem = BudgetItem();
    Map recordValue = record.value[0];
    _budgetItem.name = recordValue["name"].trim();
    _budgetItem.amount = num.parse(recordValue["amount"]);
  
    _budgetItem.dayDue = parseDayDue(recordValue["dayDue"]);
    
    _budgetItem.dayDue = setDateToNextMonth(_budgetItem.dayDue);

    if (recordValue["itemType"].toString().contains("credit")) {
      _budgetItem.itemType = BudgetItemType.creditCard;
    } else if (recordValue["itemType"].toString().contains("bill")) {
      _budgetItem.itemType = BudgetItemType.bill;
    } else if (recordValue["itemType"].toString().contains("subscription")) {
      _budgetItem.itemType = BudgetItemType.subscription;
    } else {
      //default
      _budgetItem.itemType = BudgetItemType.creditCard;
    }
    _budgetItem.record = record;
    return _budgetItem;
  }

  Record maptoRecord(Store store, BudgetItem _budgetItem) {
    Record budgetItemRecord;
    if (_budgetItem.record == null) {
      budgetItemRecord = new Record(store, [
        {
          "name": _budgetItem.name,
          "amount": _budgetItem.amount.toString(),
          "dayDue": _budgetItem.dayDue.toString(),
          "itemType": _budgetItem.itemType.toString().split('.')[1]
        }
      ]);
    } else {
      budgetItemRecord = _budgetItem.record;
      budgetItemRecord.value[0] = {
        "name": _budgetItem.name,
        "amount": _budgetItem.amount.toString(),
        "dayDue": _budgetItem.dayDue.toString(),
        "itemType": _budgetItem.itemType.toString().split('.')[1]
      };
    }
    return budgetItemRecord;
  }

  deleteBudgetItem(Record record) async {
    if (db == null) {
      openDBConnection();
    }
    await DBCommon.db.deleteRecord(record);
  }

  Future<BudgetSettingsModel> getBudgetSettings(bsModel) async {
    if (bsModel != null && bsModel) return bsModel;

    await openDBConnection();
    BudgetSettingsModel bsm = new BudgetSettingsModel();
    String testDataString = await db.get(testData) ?? "false";
    bsm.testData = testDataString.toLowerCase() == "true";
    this.testDataValue = bsm.testData;
    String suffix = "";
    if(this.testDataValue){
        suffix = "test";
    }
    bsm.paycheck = await db.get(paycheck+suffix) as num ?? 0;

    String ppt = await db.get(payPeriodType+suffix);
    switch (ppt != null ? ppt.split('.')[1] : null) {
      case "weekly":
        bsm.payPeriodType = PayPeriodType.weekly;
        break;
      case "biweekly":
        bsm.payPeriodType = PayPeriodType.biweekly;
        break;
      case "monthly":
        bsm.payPeriodType = PayPeriodType.monthly;
        break;
      case "firstandfifteen":
        bsm.payPeriodType = PayPeriodType.firstAndFifteen;
        break;
      default:
        bsm.payPeriodType = PayPeriodType.weekly;
    }

    bsm.monthlyFrequency = await db.get(frequency+suffix) as num ?? 1;
    var lpd = await db.get(lastPayDay+suffix);
    bsm.lastPayDay = lpd != "null" && lpd != null ? DateTime.parse(lpd) : null;
    var npd = await db.get(nextPayDay+suffix);
    bsm.nextPayDay = npd != "null" && npd != null ? DateTime.parse(npd) : null;
       
    bsm = updatePayDays(bsm);
    return bsm;
  }

  BudgetSettingsModel updatePayDays(BudgetSettingsModel bsm) {
    bool payDaysUpdated = false;
    while (!payDaysUpdated) {
      if(bsm.nextPayDay !=null){
        Duration npdDiff = bsm.nextPayDay.difference(DateTime.now());
      
      if (npdDiff.isNegative) {
        //negative means nextPayDay is the past and needs updating
        bsm.lastPayDay = bsm.nextPayDay;
        bsm = setNextPayDay(bsm);
        
      }
      npdDiff = bsm.nextPayDay.difference(DateTime.now());
      Duration lpdDiff = bsm. lastPayDay.difference(DateTime.now());
      if(lpdDiff.isNegative && !npdDiff.isNegative){
        payDaysUpdated = true;
      }
      }
      else
        payDaysUpdated = true;      
    }
    saveBudgetSettings(bsm);
    return bsm;
  }

  BudgetSettingsModel setNextPayDay(BudgetSettingsModel bsModel) {
    if (bsModel.lastPayDay == null) {
      return bsModel;
    }
    DateTime lpd = bsModel.lastPayDay;
    DateTime npd = lpd;
    int day = lpd.day;
    switch (bsModel.payPeriodType) {
      case PayPeriodType.monthly:
        npd = lpd = new DateTime(lpd.year, lpd.month + 1, lpd.day);
        break;

      case PayPeriodType.biweekly:
        npd = lpd.add(Duration(days: 14));
        break;
      case PayPeriodType.weekly:
        npd = lpd.add(Duration(days: 7));
        break;
      case PayPeriodType.firstAndFifteen:
        if (day < 15) {
          npd = lpd.add(Duration(days: 15 - day));
          if (npd.weekday == DateTime.sunday)
            npd = npd.subtract(Duration(days: 2));
          else if (npd.weekday == DateTime.saturday) {
            npd = npd.subtract(Duration(days: 1));
          }
        } else if (day >= 15) {
          npd = new DateTime(lpd.year, lpd.month + 1, 1);
          if (npd.weekday == DateTime.sunday)
            npd = npd.subtract(Duration(days: 2));
          else if (npd.weekday == DateTime.saturday) {
            npd = npd.subtract(Duration(days: 1));
          }
        }
        break;
    }
    if (bsModel.nextPayDay != npd) 
      bsModel.nextPayDay = npd;

    return bsModel;
    
  }

  DateTime parseDayOnlyFormat(String day){
    DateTime now = DateTime.now();
    DateTime outDate = DateTime(now.year, now.month, int.parse(day));
    return outDate;
  }

  DateTime setDateToNextMonth(DateTime date){
    if(date.difference(DateTime.now()).isNegative){
      date = DateTime(date.year, date.month+1, date.day);
    }
    return date;
  }

  DateTime parseDayDue(String dayDue){
    return DateTime.tryParse(dayDue) ?? parseDayOnlyFormat(dayDue);
    
  }

  bool dayDueInPayPeriod(DateTime dayDue, BudgetSettingsModel settings){
    if(dayDue.difference(settings.nextPayDay).isNegative){
      if(!dayDue.difference(settings.lastPayDay).isNegative){
        print(dayDue.toString() + "in PayPeriod");
        return true;
      }
    }
    else{
      DateTime minusMonth = DateTime(dayDue.year, dayDue.month - 1, dayDue.day);
      if(minusMonth.difference(settings.nextPayDay).isNegative && !minusMonth.difference(settings.lastPayDay).isNegative){
        print(dayDue.toString() + "in PayPeriod");
        return true;
      }
    }
    print(dayDue.toString() + "not in PayPeriod");
    return false; 
  }

  saveBudgetSettings(BudgetSettingsModel bsm) async {
    String suffix = "";
    if(bsm.testData){
      suffix = "test";
    }
    await db.put(bsm.paycheck, paycheck+suffix);
    await db.put(bsm.payPeriodType.toString(), payPeriodType+suffix);
    await db.put(bsm.monthlyFrequency, frequency+suffix);
    await db.put(bsm.lastPayDay.toString(), lastPayDay+suffix);
    await db.put(bsm.nextPayDay.toString(), nextPayDay+suffix);
    await db.put(bsm.testData.toString(), testData);
  }
}

class BudgetSettingsModel {
  num paycheck;
  PayPeriodType payPeriodType;
  int monthlyFrequency;
  DateTime lastPayDay;
  DateTime nextPayDay;
  bool testData;

  BudgetSettingsModel() {
    paycheck = null;
    payPeriodType = null;
    monthlyFrequency = null;
    lastPayDay = null;
    nextPayDay = null;
    testData = false;
  }
}

class BudgetItem {
  String name;
  num amount;
  DateTime dayDue;
  BudgetItemType itemType;
  Record record;

  BudgetItem() {
    record = null;
    name = null;
    amount = null;
    dayDue = null;
    itemType = BudgetItemType.creditCard;
  }
}


