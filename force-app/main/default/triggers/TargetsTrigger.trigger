trigger TargetsTrigger on Target__c (before insert, before update, after insert, after update) {
    if(Trigger.isInsert && Trigger.isBefore){
        TargetsHandler.existingSameUserRecords(Trigger.New);
    }
    if(Trigger.isUpdate && Trigger.isBefore){
        TargetsHandler.existingSameUserRecords(Trigger.New);
    }
    if(Trigger.isUpdate && Trigger.isAfter){
        TargetsHandler.amountChange(Trigger.New);
        TargetsHandler.userChanged(Trigger.New, Trigger.oldMap);
    }
    if(Trigger.isInsert && Trigger.isAfter){
        DailyRecordsHandler.todayRecords(Trigger.New);
    }
}