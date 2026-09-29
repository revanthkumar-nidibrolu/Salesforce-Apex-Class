trigger DailyRecordsTrigger on Daily_Record__c (before insert, after insert) {
    if(Trigger.isInsert && Trigger.isAfter){
       // DailyRecordsHandler.todayRecords(Trigger.New);
        
    }
}