public class DealHandler {
    public static void oppoTaskCreation(List<Deal__c> dealList){
        map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        for(Deal__c deal : dealList){
            if(Deal__c.Opportunity__c != Null){
                oppMap.put(deal.Opportunity__c, null);
            }
        }
        List<Task> newTasks = new List<Task>();
        for(Id oppoId : oppMap.keyset()){
            Task newt = new Task();
            newt.Subject = 'Follow up new oppo task ';
            newt.WhatId = oppoId;
            newt.Status = 'In Progress';
            newt.ActivityDate = Date.today().addDays(7);
            newTasks.add(newt);         
        }
        if(!newTasks.isEmpty()){
            insert newTasks;
        }
    }
    public static void dealOverLapingDates(List<Deal__c> newDeals){
        set<Id> dealIds = new set<Id>();
        List<Deal__c> dealCheck = new List<Deal__c>();
        for(Deal__c del : newDeals){
            if(del.Start_Date__c != Null && del.End_Date__c != Null && del.Active__c == True){
                dealCheck.add(del);
                dealIds.add(del.Id);
            }
        }
        List<Deal__c> dealList = [SELECT Id, Start_Date__c, End_Date__c FROM Deal__c
                                 WHERE Active__c = True
                                 AND Id NOT IN : dealIds];
        if(dealList.isEmpty()){
            return;	
        }
        for(Deal__c nD : dealCheck){
            for(Deal__c eD : dealList){
                if(nD.Start_Date__c <= eD.End_Date__c &&
                   nD.End_Date__c >= eD.Start_Date__c){
                       nD.addError('An active deal already exists between these dates.');
                }
            }
        }
    } 
    public static void dealOverLapingDatess(List<Deal__c> newDeals){
        Set<Id> dealIds = new Set<Id>();
        List<Deal__c> dealCheck = new List<Deal__c>();
        Date startDate;
        Date endDate;
        for(Deal__c del : newDeals){
            if(del.Start_Date__c != null && del.End_Date__c != null && del.Active__c == true){
                dealCheck.add(del);
                dealIds.add(del.Id);
                if(startDate == Null || del.Start_Date__c <= startDate){
                    startDate = del.Start_Date__c;
                }
                if(endDate == Null || del.End_Date__c >= endDate){
                    	endDate = del.End_Date__c;
                }
            }
        }
        List<Deal__c> dealList = [SELECT Id, Start_Date__c, End_Date__c FROM Deal__c
                                  WHERE Active__c = true
                                  AND Id NOT IN :dealIds
                                  AND Start_Date__c <= :endDate
                                  AND End_Date__c >= :startDate];                  
        if(dealList.isEmpty()){
            return;
        }
        for(Deal__c nD : dealCheck){
            nD.addError('An active deal already exists between these dates.');
        }
    } 
}