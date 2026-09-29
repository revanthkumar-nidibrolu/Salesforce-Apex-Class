public class DailyRecordEmailScheduler implements schedulable{
    public void execute(schedulableContext sc){
        List<Daily_Record__c> todayRecords = [SELECT
                                             Id,
                                             Name,
                                             Owner_Id__c,
                                             Owner_Id__r.Email,
                                             Record_Id__c,
                                             Object_Name__c
                                             FROM Daily_Record__c
                                             WHERE
                                             Created_Date__c = Today];
        Map<Id, List<Daily_Record__c>> ownerRecordsMap = new Map<Id, List<Daily_Record__c>>();
        for(Daily_Record__c dr : todayRecords){
            if(!ownerRecordsMap.containsKey(dr.Owner_Id__c)){
                ownerRecordsMap.put(dr.Owner_Id__c, new List<Daily_Record__c>());
            }
            ownerRecordsMap.get(dr.Owner_Id__c).add(dr);
        }
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for(Id ownerId : ownerRecordsMap.keySet()){
            List<Daily_Record__c> ownerRecords = ownerRecordsMap.get(ownerId);
            String body = 'Hello\n\n';
            body += 'Below records created today:\n\n';
            for(Daily_Record__c dr : ownerRecords){
                body += 'Record Name: '+dr.Name + '\n';
                body += 'Object Name: '+dr.Object_Name__c + '\n';
                body += 'Record Id: '+dr.Record_Id__c + '\n\n';
            }
            List<String> managerMail = new List<String>{'sruthigujjula07@gmail.com'};
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{ownerRecords[0].Owner_Id__r.Email});
            mail.setCcAddresses(managerMail);
            mail.setSubject('Daily Records Summary');
            mail.setPlainTextBody(body);
            emails.add(mail);
        }
        if(!emails.isEmpty()){
            Messaging.SendEmail(emails);
        }
    }
}