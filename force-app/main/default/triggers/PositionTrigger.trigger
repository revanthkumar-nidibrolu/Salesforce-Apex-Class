trigger PositionTrigger on Position__c (before insert, after insert) {
    if(Trigger.isInsert && Trigger.isBefore){
        PositionHandler.minMaxDate(Trigger.New);
    }
    if(Trigger.isUpdate && Trigger.isBefore){
        PositionHandler.updateMinMaxDate(Trigger.New, Trigger.oldMap);
    }
    if(Trigger.isInsert && Trigger.isAfter){
        DailyRecordsHandler.todayRecords(Trigger.New);
    }
}