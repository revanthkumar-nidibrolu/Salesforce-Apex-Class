public class DailyRecordDeleteScheduler implements Schedulable{
    public void execute(SchedulableContext sc){
        List<Daily_Record__c> recordsList = [SELECT
                                             Id
                                             FROM Daily_Record__c
                                             WHERE
                                             Created_Date__c = TODAY];
        if(!recordsList.isEmpty()){
            delete recordsList;
        }
    }
}