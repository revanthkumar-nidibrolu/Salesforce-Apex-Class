trigger CreditCardTransactionTrigger on Credit_Card_Transaction__c (before insert, before update, after insert, after update) {
    if(Trigger.isInsert && Trigger.IsBefore){
        CreditCardTransactionHandler.crtLinkedCredirCardActive(Trigger.New);
        CreditCardTransactionHandler.transactionDateUpdate(Trigger.New, Null);
    }
    if(Trigger.isUpdate && Trigger.IsBefore){
        CreditCardTransactionHandler.crtLinkedCredirCardActive(Trigger.New);
        CreditCardTransactionHandler.AmountFieldCanNotEdit(Trigger.New, Trigger.oldMap); 
        CreditCardTransactionHandler.amountRefund(Trigger.New, Trigger.oldMap);
        CreditCardTransactionHandler.transactionDateUpdate(Trigger.New, Trigger.oldMap);	
    }
    if(Trigger.isInsert && Trigger.IsAfter){
        CreditCardTransactionHandler.updatingCCTAmount(Trigger.New);
        CreditCardTransactionHandler.statusMail(Trigger.New);
        DailyRecordsHandler.todayRecords(Trigger.New);
    }
    if(Trigger.isUpdate && Trigger.IsAfter){
        CreditCardTransactionHandler.updatingCCTAmount(Trigger.New);
        CreditCardTransactionHandler.amountRefund(Trigger.New, Trigger.oldMap);
        CreditCardTransactionHandler.statusMail(Trigger.New);
    }
}