public class TargetsHandler {
    public static void existingSameUserRecords(List<Target__c> trgList){
        set<Id> priAcc = new set<Id>();
        set<Id> secAcc = new set<Id>();
        for(Target__c trg : trgList){
            if(trg.Account_Primary__c != Null){
                priAcc.add(trg.Account_Primary__c);
            }
            if(trg.Secondary_Account__c != Null){
                secAcc.add(trg.Secondary_Account__c);
            }
        }
        List<Target__c> existingRecords = getTargetList(priAcc, secAcc);
        if(existingRecords.isEmpty()){
            return;
        }
        for(Target__c nT : trgList){
            for(Target__c oT : existingRecords){
                if(nT.Account_Primary__c == oT.Account_Primary__c &&
                   nT.Secondary_Account__c == oT.Secondary_Account__c &&
                   nT.Id != oT.Id){
                       nT.addError(system.label.ExistingAccounts);
                }
            }
        }
    }
    
    private static List<Target__c> getTargetList (set<Id> priAcc, set<Id> secAcc){
        return [SELECT
                Id,
                Account_Primary__c,
                Secondary_Account__c
                FROM Target__c
                WHERE
                Account_Primary__c IN : priAcc
                AND
                Secondary_Account__c In : secAcc];
    }
    
    public static void amountChange(List<Target__c> trgList){
        set<Id> priAccId = new set<Id>();
        set<Id> secAccId = new set<Id>();
        Map<String, List<Opportunity>> oppMap = new Map<String, List<Opportunity>>();
        for(Target__c trg : trgList){
            if(trg.Account_Primary__c != Null){
                priAccId.add(trg.Account_Primary__c);
            }
            if(trg.Secondary_Account__c != Null){
                secAccId.add(trg.Secondary_Account__c);
            }
        }
        List<Opportunity> oppList = getoppoList(priAccId, secAccId);
        if(oppList.isEmpty()){
            return;
        }
        for(Opportunity opp : oppList){
            String key = opp.AccountId +'-'+ opp.Secondary_Account__c;
            if(!oppMap.containsKey(key)){
                oppMap.put(key, new List<Opportunity>());
            }
            oppMap.get(key).add(opp);
        }
        List<Opportunity> oppAmount = new List<Opportunity>();
        for(Target__c trg : trgList){
            String key = trg.Account_Primary__c +'-'+ trg.Secondary_Account__c;
            if(oppMap.containsKey(key)){
                for(Opportunity opp : oppMap.get(key)){
                    opp.Amount = trg.Amount__c;
                    oppAmount.add(opp);
                }
            }
        }
        if(!oppAmount.isEmpty()){
            try{
                Update oppAmount;
            }catch(dmlException e){
                system.debug('A dml error occurs: ' + e.getMessage());
            }
        }
    }
    
    private static List<Opportunity> getoppoList (set<Id> priAccId, set<Id> secAccId){
        return [SELECT
               Id,
               RecordTypeId,
               AccountId,
               Secondary_Account__c,
               Amount
               FROM Opportunity
               WHERE
               AccountId IN : priAccId
               AND
               Secondary_Account__c IN : secAccId];
    }
    
    private static List<OpportunityTeamMember> getOppTeamMembers (set<Id> priAccId, set<Id> oppoIds){
        return [SELECT
                Id,
                OpportunityId,
                TeamMemberRole
                FROM OpportunityTeamMember
                WHERE
                OpportunityId IN : oppoIds
                AND
                TeamMemberRole IN ('Account Manager','Sales Manager')];
    }
    
    public static void userChanged(List<Target__c> newList, Map<Id, Target__c>oldMap){
        set<Id> priAccId = new set<Id>();
        set<Id> secAccId = new set<Id>();
        for(Target__c trg : newList){
            if((trg.Account_Manager__c != oldMap.get(trg.Id).Account_Manager__c || trg.Sales_Manager__c != oldMap.get(trg.Id).Sales_Manager__c) ||
               (trg.Account_Manager__c != oldMap.get(trg.Id).Account_Manager__c && trg.Sales_Manager__c != oldMap.get(trg.Id).Sales_Manager__c)){
                priAccId.add(trg.Account_Primary__c);
                secAccId.add(trg.Secondary_Account__c);
            }
        }
        List<Opportunity> oppList = getoppoList(priAccId, secAccId);
        if(oppList.isEmpty()){
            return;
        }
        set<Id> oppoIds = new set<Id>();
        for(Opportunity opp : oppList){
            oppoIds.add(opp.Id);
        }
        List<OpportunityTeamMember> oldTeamMembers = getOppTeamMembers(priAccId, oppoIds);
        if(oldTeamMembers.isEmpty()){
            return;
        }
        if(!oldTeamMembers.isEmpty()){
            try{
                delete oldTeamMembers;
            }catch(dmlException e){
                system.debug('A dml error occurs: '+e.getMessage());
            }
        }
        OpportunityHandler.OpportunityTeamCreation(oppList);
    }
}