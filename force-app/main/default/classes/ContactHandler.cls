public class ContactHandler {
    public static void contactsInsert(List<Contact> conList){
        map<Id, Integer> countContacts = new map<Id, Integer>();
        for(Contact con : conList){
            if(con.AccountId != Null && !countContacts.Containskey(con.AccountId)){
                countContacts.put(con.AccountId, 1);
            }
            else if(con.AccountId != Null && countContacts.Containskey(con.AccountId))
            countContacts.put(con.AccountId, countContacts.get(con.AccountId)+1);
        }
        List<Account> accList = [SELECT 
                                 Id, 
                                 Number_of_Contacts__c 
                                 FROM Account 
                                 WHERE Id IN : countContacts.keySet()];
        for(Account acc : accList){
            Decimal Count = acc.Number_of_Contacts__c == Null ? 0:acc.Number_of_Contacts__c;
            acc.Number_of_Contacts__c = Count + countContacts.get(acc.Id);
        }
        try{
            update accList;
        } Catch(dmlException e){
            system.debug('A DMl error occur: '+e.getmessage());
        }
    }
    public static void contactsDelete(List<Contact> conList){
        map<Id, Integer> countContacts = new map<Id, Integer>();
        for(Contact con : conList){
            if(con.AccountId != Null && !countContacts.Containskey(con.AccountId)){
                countContacts.put(con.AccountId, 1);
            }
            else if(con.AccountId != Null && countContacts.Containskey(con.AccountId))
            countContacts.put(con.AccountId, countContacts.get(con.AccountId)+1);
        }
        List<Account> accList = [SELECT 
                                 Id, 
                                 Number_of_Contacts__c 
                                 FROM Account 
                                 WHERE Id IN : countContacts.keySet()];
        for(Account acc : accList){
            Decimal Count = acc.Number_of_Contacts__c == Null ? 0:acc.Number_of_Contacts__c;
            acc.Number_of_Contacts__c = Count - countContacts.get(acc.Id);
        }
        try{
            update accList;
        } Catch(dmlException e){
            system.debug('A DMl error occur: '+e.getmessage());
        }
    }
    public static void contactsUpdate(List<Contact> newList, Map<Id, Contact> oldMap){
        map<Id, Integer> accountChange = new Map<Id, Integer>();
        for(Contact con : newList){
            Contact oldCont = oldMap.get(con.Id);
            if(con.AccountId != oldCont.AccountId){
                if(oldCont.AccountId != Null){
                    if(!accountChange.containsKey(oldCont.AccountId)){
                        accountChange.put(oldCont.AccountId,-1);
                    }
                    else{
                        accountChange.put(oldCont.AccountId, accountChange.get(oldCont.AccountId)-1);
                    }
                }
                if(con.AccountId != Null){
                    if(!accountChange.containsKey(con.AccountId)){
                        accountChange.put(con.AccountId, 1);
                    }
                    else{
                        accountChange.put(con.AccountId, accountChange.get(con.AccountId)+1);
                    }
                }
            }
        }
        List<Account> accList = [SELECT 
                                 Id, 
                                 Number_of_Contacts__c 
                                 FROM Account 
                                 WHERE Id IN : accountChange.keySet()];
        for(Account acc : accList){
            Decimal Count = acc.Number_of_Contacts__c == Null ? 0:acc.Number_of_Contacts__c;
            acc.Number_of_Contacts__c = Count + accountChange.get(acc.Id);
        }
        try{
            update accList;
        } Catch(dmlException e){
            system.debug('A DMl error occur: '+e.getmessage());
        }	
    }
    public static void updateContact(List<Contact> conList){
        List<Account> accList = [SELECT
                                 Id, 
                                 Phone, 
                                 Industry 
                                 FROM Account
                                 WHERE Id IN 
                                 (SELECT AccountId 
                                  FROM Contact
                                  WHERE Id IN : conList)];
        AccountHandler.setDefaultIndustry(accList);
    }
}