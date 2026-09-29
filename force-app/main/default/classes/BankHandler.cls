public class BankHandler {
    public static void accountActiveCreateBank(List<Bank__c> newBank){
        set<Id> accId = new set<Id>();
        for(Bank__c bank : newBank){
            if(bank.Account__c != Null){
                accId.add(bank.Account__c);
            } 
        }
        Map<Id, Account> accList = new Map<Id, Account>([SELECT 
                                                         Id, 
                                                         Active__c
                                                         FROM Account
                                                         WHERE Id IN : accId]);
        for(Bank__c bank : newBank){
            Account acc = accList.get(bank.Account__c);
            if(!acc.Active__c && bank.Status__c == 'Active'){
                bank.addError(system.label.AccInActiveBankNotCreate);
            }
        }
    }
}