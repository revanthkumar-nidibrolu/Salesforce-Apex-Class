public class AccountContactController {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getRelatedContacts(Id accountId) {
        if (accountId == null) {
            return new List<Contact>();
        }
        return [SELECT Id, 
                       Name, 
                       Email, 
                       Phone
                FROM Contact 
                WHERE AccountId = :accountId];
    }
}