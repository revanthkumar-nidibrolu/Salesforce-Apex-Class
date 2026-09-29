public with sharing class OpportunityDealController {
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
    @AuraEnabled(cacheable=true)
    public static List<Deal_Item__c> getDealItems(Id dealId) {
        return [SELECT Id,
                       Name,
                       Amount__c,
                       Phone__c,
                       Deal__c
                FROM Deal_Item__c
                WHERE Deal__c = :dealId
                ORDER BY CreatedDate DESC];
    }
}