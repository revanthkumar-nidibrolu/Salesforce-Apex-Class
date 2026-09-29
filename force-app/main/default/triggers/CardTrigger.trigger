trigger CardTrigger on Card__c (before insert, before update) {
    if(Trigger.isInsert && Trigger.isBefore){
       // CardHandler.fieldUpdate(Trigger.New);
       // CardHandler.duplicatesCards(Trigger.New);
    }
    if(Trigger.isUpdate && Trigger.isBefore){
       // CardHandler.fieldUpdate(Trigger.New);
       // CardHandler.duplicatesCards(Trigger.New);
    }
}