@isTest
private class TestClassOnOpportunity { 
    @isTest
    static void setupData() {
        Opportunity opp = new Opportunity(Name = 'Test class opportunity', StageName = ConstantsClass.Stage_Value_Proposition, CloseDate = Date.Today());
        insert opp;
    } 
    @isTest
    static void testOpportunityUpdate() {
        Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = 'Test class Opportunity' LIMIT 1];     
        Test.startTest();
        opp.StageName = 'Closed Won';
        update opp;
        Test.stopTest();      
        Opportunity updatedOpp = [SELECT StageName FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals('Closed Won', updatedOpp.StageName);
    }
}