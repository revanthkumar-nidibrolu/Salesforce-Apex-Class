public class TestUtilityClass {
    public static Account accountClass(){
        Account acc = new Account(
            Name = 'Test Account Class');
        insert acc;
        return acc;
    }
    public static Opportunity oppoCreation(Account acc){
        Opportunity opp = new Opportunity(
            Name = 'Opportunity Test',
            StageName = ConstantsClass.Stage_Qualification,
            closeDate = Date.today().addMonths(2),
            Amount = 10000,
            Type = ConstantsClass.Opportunity_Type_Upgrade,
            AccountId = acc.Id);     
        insert opp;
        return opp;
    }
    public static Contact accountContact(Account acc){
        Contact con = new Contact(
            LastName = acc.Name,
            Phone = acc.Phone);
        insert con;
        return con;
    }
    public static Case caseCreation(Account acc, Opportunity opp){
        Case cas = new Case(
            AccountId = acc.Id,
            Opportunity__c = opp.Id,
            Status = ConstantsClass.Case_Status_New,
            Priority = ConstantsClass.Case_Priority,
            Origin = ConstantsClass.Case_Origin);
        insert cas;
        return cas;
    }
    public static Deal__c dealCreation(Opportunity opp){
        Deal__c del = new Deal__c(
            Name = 'Transaction',
            Opportunity__c = opp.Id,
            Amount__c = opp.Amount,
            Start_Date__c = opp.Create_Date__c,
            End_Date__c = opp.CloseDate,
            Active__c = True);
        insert del;
        return del;
    }
}