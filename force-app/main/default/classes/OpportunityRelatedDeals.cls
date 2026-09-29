public class OpportunityRelatedDeals {
    @AuraEnabled(cacheable=true)
    public static List<Deal__c> getRelatedDeals(Id opportunityId){
        return [SELECT Id,
                       Name,
                       Active__c,
                       Amount__c,
                       Start_Date__c,
                       End_Date__c,
                       Opportunity__c
                FROM Deal__c 
                WHERE Opportunity__c = :opportunityId];
    }
}