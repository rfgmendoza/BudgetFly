import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'dart:io' show Directory;
import 'package:path_provider/path_provider.dart';


enum budgetItemType { creditCard, bill, subscription }

class DBCommon {
    static Database db;
        

    Future openDBConnection() async{
      if(db == null){
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String dbPath = join(dirname(appDocDir.path), "sample.db");
        DatabaseFactory dbFactory = databaseFactoryIo;
      
      // We use the database factory to open the database
        db = await dbFactory.openDatabase(dbPath);
      }
    }
    
    Future<Store> getStore(String store) async {
      await openDBConnection();
      if(db !=null)
        return db.getStore(store);
      else
        return null;
    }

    BudgetItem mapToBudgetItem(Record record){
      BudgetItem _budgetItem = BudgetItem();
      Map recordValue = record.value[0];
      _budgetItem.name = recordValue["name"].trim();
      _budgetItem.amount = int.parse(recordValue["amount"]);
      _budgetItem.dayDue = int.parse(recordValue["dayDue"]);
      
      if(recordValue["itemType"].toString().contains("credit")){
        _budgetItem.itemType = budgetItemType.creditCard;
      }
      else if(recordValue["itemType"].toString().contains("bill")){
        _budgetItem.itemType = budgetItemType.bill;
      }
      else if(recordValue["itemType"].toString().contains("subscription")){
        _budgetItem.itemType = budgetItemType.subscription;
      }
      else{//default
        _budgetItem.itemType = budgetItemType.creditCard;
      }
      return _budgetItem;
    }

    Record maptoRecord(Store store, BudgetItem _budgetItem){
      Record budgetItemRecord = new Record(store, [
      {
        "name": _budgetItem.name,
        "amount": _budgetItem.amount.toString(),
        "dayDue": _budgetItem.dayDue.toString(),
        "itemType": _budgetItem.itemType.toString().split('.')[1]
      }
      ]);
      return budgetItemRecord;
    }

}

class BudgetItem {
  String name = "";
  num amount = 0;
  num dayDue = 1;
  budgetItemType itemType = budgetItemType.creditCard;
}