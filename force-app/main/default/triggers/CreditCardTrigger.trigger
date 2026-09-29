trigger CreditCardTrigger on Credit_Card__c (before insert, before update, after insert, after update) {
    if(Trigger.isInsert && Trigger.isBefore){
        CreditCardHandler.BankActiveCreateCreditCard(Trigger.New);
    }
    if(Trigger.isUpdate && Trigger.isBefore){
        CreditCardHandler.BankActiveCreateCreditCard(Trigger.New);
    }
    if(Trigger.isInsert && Trigger.isAfter){
        DailyRecordsHandler.todayRecords(Trigger.New);
    }
}