import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'dart:io' show Directory, sleep;
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
      return db.getStore(store);
    else
      return null;
  }

  BudgetItem mapToBudgetItem(Record record) {
    BudgetItem _budgetItem = BudgetItem();
    Map recordValue = record.value[0];
    _budgetItem.name = recordValue["name"].trim();
    _budgetItem.amount = int.parse(recordValue["amount"]);

    _budgetItem.dayDue = int.parse(recordValue["dayDue"]);

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

  deleteBudgetItem(Record record) async{
    if(db == null){
      openDBConnection();
      
    }
    await DBCommon.db.deleteRecord(record);
  }

  Future<BudgetSettingsModel> getBudgetSettings(bsModel) async{
    if(bsModel !=null)
      return bsModel;
      
    await openDBConnection();
    BudgetSettingsModel bsm = new BudgetSettingsModel();

    bsm.paycheck = await db.get(paycheck) as num ?? 0;

    String ppt = await db.get(payPeriodType);
    switch(ppt !=null ? ppt.split('.')[1]: null ){
      case "weekly": bsm.payPeriodType = PayPeriodType.weekly; break;
      case "biweekly": bsm.payPeriodType = PayPeriodType.biweekly; break;
      case "monthly" : bsm.payPeriodType = PayPeriodType.monthly; break;
      case "firstandfifteen" : bsm.payPeriodType = PayPeriodType.firstAndFifteen; break;
      default:bsm.payPeriodType=PayPeriodType.weekly;
    }

    
    bsm.monthlyFrequency = await db.get(frequency) as num ?? 1;
    var lpd = await db.get(lastPayDay);
    bsm.lastPayDay = lpd != "null" && lpd != null ? DateTime.parse(lpd) : null;
    var npd = await db.get(nextPayDay);
    bsm.nextPayDay =  npd !="null" && npd!=null ? DateTime.parse(npd) : null;
    
    return bsm;
  }

  saveBudgetSettings(BudgetSettingsModel bsm ) async{
    await db.put(bsm.paycheck, paycheck);
    await db.put(bsm.payPeriodType.toString(), payPeriodType);
    await db.put(bsm.monthlyFrequency, frequency);
    await db.put(bsm.lastPayDay.toString(), lastPayDay);
    await db.put(bsm.nextPayDay.toString(), nextPayDay);
    
    

  }
}

class BudgetSettingsModel {
  num paycheck;
  PayPeriodType payPeriodType;
  int monthlyFrequency;
  DateTime lastPayDay;
  DateTime nextPayDay;
  

  BudgetSettingsModel() {
    paycheck = null;
    payPeriodType = null;
    monthlyFrequency = null;
    lastPayDay = null;
    nextPayDay = null;
    
  }
}

class BudgetItem {
  String name;
  num amount;
  num dayDue;
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
