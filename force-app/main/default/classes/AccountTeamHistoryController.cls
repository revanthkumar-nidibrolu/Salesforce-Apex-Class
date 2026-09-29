public class AccountTeamHistoryController {
    @AuraEnabled(cacheable = true)
    public static List<Account_Team_History__c> getAccountTeamHistories(Id accountId){
        return [SELECT Id,
                       Name,
                       Account__c,
                       Account_Team_Member_Id__c,
                       Changed_User__c,
                       Changed_User__r.Name,
                       Closed_Date__c,
                       User__c,
                       User__r.Name,	
                       Role__c,
                       Quarter__c,
                       Delete__c
                FROM Account_Team_History__c
                WHERE Account__c = :accountId
                ORDER BY Name DESC
                LIMIT 5];
    }
}