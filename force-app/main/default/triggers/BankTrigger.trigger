trigger BankTrigger on Bank__c (before insert, before update, after insert, after update) {
    if(Trigger.isInsert && Trigger.isBefore){
        BankHandler.accountActiveCreateBank(Trigger.New);
    }
    if(Trigger.isUpdate && Trigger.isBefore){
        BankHandler.accountActiveCreateBank(Trigger.New);
    }
    if(Trigger.isInsert && Trigger.isAfter){
        DailyRecordsHandler.todayRecords(Trigger.New);
    }
}