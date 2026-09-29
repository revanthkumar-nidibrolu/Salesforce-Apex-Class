public class DailyRecordUsingDynamicApex implements Schedulable{
    public void execute(SchedulableContext sc){
        Map<String, Schema.SObjectType> allObjects = Schema.getGlobalDescribe();
        Map<Id, List<String>> ownerRecords = new Map<Id, List<String>>();
        for(String sobjName : allObjects.keySet()){
            Schema.DescribeSObjectResult dsr = allObjects.get(sobjName).getDescribe();
            Map<String, Schema.SObjectField> fields = dsr.fields.getMap();
            if(!fields.containsKey('OwnerId') || !fields.containsKey('CreatedDate')){
                continue;
            }
            try{
                String objects = 'SELECT Id, Name, OwnerId FROM ' + sobjName + ' WHERE CreatedDate = TODAY';
                List<SObject> records = Database.Query(objects);
                for(SObject rec : records){
                    Id ownerId = (Id)rec.get('OwnerId');
                    String recordName;
                    if(fields.containsKey('Name')){
                        recordName = String.ValueOf(rec.get('Name'));
                    }
                    else{
                        recordName = String.ValueOf(rec.get('Id'));
                    }  
                    if(!ownerRecords.containsKey(ownerId)){
                        ownerRecords.put(ownerId, new List<String>());
                    }
                    ownerRecords.get(ownerId).add(sobjName +' '+ recordName);
                }
            }catch(Exception e){
                system.debug('Error: '+e.getMessage());
            }
        }
        Map<Id, User> users = new Map<Id, User>([SELECT
                                                Id,
                                                Email
                                                FROM User
                                                WHERE
                                                Id IN : ownerRecords.keySet()]);
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for(Id ownerId : ownerRecords.keySet()){
            String body = 'Hello\n\n';
            body += 'Below records created today:\n\n';
            body += String.join(ownerRecords.get(ownerId), '\n\n');
            body += '\n\nRegards, \nSalesforce Team';
            //List<String> managerMail = new List<String>{'sruthigujjula07@gmail.com'};
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject('Daily Records Summary');
            mail.setPlainTextBody(body);
            mail.setToAddresses(new List<String>{users.get(ownerId).Email});
           // mail.setCcAddresses(managerMail);
            emails.add(mail);
        }
        if(!emails.isEmpty()){
            Messaging.SendEmail(emails);
        }
    }	
}