public class AccountContact {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getRelatedContacts(Id accountId) {
        return [SELECT Id, 
                       LastName, 
                       AccountId 
                FROM Contact 
                WHERE AccountId = :accountId];
    }
}