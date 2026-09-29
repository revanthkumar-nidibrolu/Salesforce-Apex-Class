public class AccountController {
    @AuraEnabled(cacheable = true)
    public static List<Account> accountList(){
        return [SELECT Id,
                       Name
                FROM Account];
    }
    @AuraEnabled
    public static List<Contact> accountRelatedContacts(Id accountId){
        return [SELECT Id,
                       LastName,
                       Phone,
                       Email,
                       accountId
                FROM Contact
                WHERE AccountId = :accountId];
    }
}