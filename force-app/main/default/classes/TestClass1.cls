@isTest
public class TestClass1 {
    @isTest
    static void accountAddressTest(){
        List<Account> newAccounts = new List<Account>();
        for(integer i=1; i<=10; i++){
            Account acc = new Account();
            acc.Name = 'Test Class Account '+i;
            acc.BillingCountryCode = 'IN';
            acc.BillingCity = 'Kakinada';
            acc.BillingStreet = 'JNTUK Street';
            acc.BillingPostalCode = '523001';
            acc.BillingStateCode = 'AP';
            newAccounts.add(acc);
        }
        Test.StartTest();
        insert newAccounts;
        Test.StopTest();
        List<Account> insertAccount = [SELECT Id,
                                              Name,
                                              ShippingAddress
                                       FROM   Account
                                       WHERE
                                            Id IN : newAccounts];
        system.assertEquals(10,insertAccount.size(), 'there should be 10 accounts created.');
        system.debug(insertAccount);
    } 
}