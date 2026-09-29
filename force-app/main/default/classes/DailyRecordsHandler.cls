public class DailyRecordsHandler {
    public static void todayRecords(List<SObject> records){
        List<Daily_Record__c> dailyRecords = new List<Daily_Record__c>();
        List<Task> taskList = new List<Task>();
        for(SObject sobj : records){
            Id ownerId = (Id)sobj.get('OwnerId');
            Daily_Record__c dr = new Daily_Record__c();
           /* String recordName;
            if(sobj instanceOf Contact){
                Contact con = (Contact)sobj;
                recordName = con.LastName;
            }
            else if(sobj instanceOf Lead){
                Lead led = (Lead)sobj;
                recordName = led.LastName;
            }
            else{
                recordName = String.ValueOf(sobj.get('Name'));
            } */
            dr.Name = String.ValueOf(sobj.get('Name'));
            dr.Record_Id__c = String.ValueOf(sobj.Id);
            dr.Object_Name__c = String.ValueOf(sobj.getSObjectType());
            dr.Created_Date__c = Date.Today();
            dr.Owner_Id__c = ownerId;
            dailyRecords.add(dr);
            Task nt = new Task();
            nt.Subject = 'New Record Created';
            nt.OwnerId = ownerId;
            nt.Status = 'Not Started';	
            nt.Priority = 'Normal';
            String objectName = String.ValueOf(sobj.getSObjectType());
            if(objectName == 'Contact' || objectName == 'Lead'){
                nt.WhoId = sobj.Id;
            }else{
                nt.WhatId = sobj.Id;
            }
            taskList.add(nt);
        }
        if(!dailyRecords.isEmpty()){
            insert dailyRecords;
        }
        if(!taskList.isEmpty()){
            insert taskList;
        }
    }
}