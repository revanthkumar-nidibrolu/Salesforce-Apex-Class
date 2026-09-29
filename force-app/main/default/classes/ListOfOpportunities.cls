public class ListOfOpportunities {
    @AuraEnabled(cacheable = true)
    public static List<Opportunity> listOfOppo(List<Opportunity> oppList) {
        return [SELECT Id, 
                       Name, 
                       StageName, 
                       CloseDate 
                  FROM Opportunity
                 LIMIT 10];
    }
    @AuraEnabled(cacheable=true)
    public static List<Deal__c> getDeals(Id opportunityId) {
        return [SELECT Id,
                       Name,
                       Amount__c,
                       Active__c,
                       End_Date__c,
                       Start_Date__c,
                       Opportunity__c
                FROM Deal__c
                WHERE Opportunity__c = :opportunityId
                ORDER BY CreatedDate DESC];
    }
}