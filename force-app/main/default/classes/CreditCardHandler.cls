public class CreditCardHandler {
    public static void BankActiveCreateCreditCard(List<Credit_Card__c> newCard){
        set<Id> bankIds = new set<Id>();
        for(Credit_Card__c card : newCard){
            if(card.Bank__c != Null){
                bankIds.add(card.Bank__c);
            }
        }
        Map<Id, Bank__c> bankList = new Map<Id, Bank__c>([SELECT 
                                                          Id,
                                                          Status__c
                                                          FROM Bank__c
                                                          WHERE Id IN : bankIds]);
        for(Credit_Card__c card : newCard){
            Bank__c bank = bankList.get(card.Bank__c);
            if(bank.Status__c != 'Active' && card.Status__c == 'Active'){
                card.addError(system.label.bankInActiveNotCreateCard);
            }
        }
    }
}