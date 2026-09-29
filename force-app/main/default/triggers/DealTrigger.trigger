trigger DealTrigger on Deal__c (before insert, before update, after insert, after update) {
    if(Trigger.isInsert && Trigger.isAfter){
       // DealHandler.oppoTaskCreation(Trigger.New);
       // DailyRecordsHandler.todayRecords(Trigger.New);
        DynamicTaskCreation.taskCreation(Trigger.New);
    }
    if(Trigger.isInsert && Trigger.IsBefore){
        DealHandler.dealOverLapingDates(Trigger.New);
    }
    if(Trigger.isUpdate && Trigger.IsBefore){
        DealHandler.dealOverLapingDates(Trigger.New);
    }
}