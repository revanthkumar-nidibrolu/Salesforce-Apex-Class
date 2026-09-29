@isTest
public class TestUtilityClassTest {
    @isTest
    static void testUtilityMethods(){
        Test.startTest();
        Account acc = TestUtilityClass.accountClass();
        Opportunity opp = TestUtilityClass.oppoCreation(acc);
        Contact con = TestUtilityClass.accountContact(acc);
        Case cas = TestUtilityClass.caseCreation(acc, opp);
        Deal__c del = TestUtilityClass.dealCreation(opp);
        Test.stopTest();
        
        system.assertNotEquals(null, acc.Id);
        system.assertNotEquals(null, opp.Id);
        system.assertNotEquals(null, con.Id);
        system.assertNotEquals(null, cas.Id);
        system.assertNotEquals(null, del.Id);
    }
}