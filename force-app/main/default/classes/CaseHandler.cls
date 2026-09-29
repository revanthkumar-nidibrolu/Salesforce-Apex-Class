public class CaseHandler {
    public static void accountFiledUpdate(List<Case> newCase){
        List<Account> accList = new List<Account>();
        for(Case cas : newCase){
            Account acc = new Account();
            acc.Id = cas.AccountId;
            acc.Latest_Case_Number__c = cas.CaseNumber;
            accList.add(acc);
        }
        if(!accList.isEmpty()){
            Update accList;
        }
    }
    public static void casesLessThenFive(List<Case> casesList){
        Map<Id, Integer> caseList = new Map<Id, Integer>();
        set<Id> oppoIds = new Set<Id>();
        for(Case cas : casesList){
            if(cas.Opportunity__c != Null){
               oppoIds.add(cas.Opportunity__c);
            }
        }
        List<Case> caseCount = [SELECT Id, Opportunity__c FROM Case WHERE Opportunity__c IN : oppoIds];
        for(Case cass : caseCount){
            if(!caseList.containsKey(cass.Opportunity__c)){
                caseList.put(cass.Opportunity__c, 1);
            }
            caseList.put(cass.Opportunity__c, caseList.get(cass.Opportunity__c)+1);
        }
        for(Case cas : casesList){
            If(cas.Opportunity__c != Null){
                Integer Count = caseList.containsKey(cas.Opportunity__c) ? caseList.get(cas.Opportunity__c):0;
                if (count > 5){
                     cas.addError('You cannot create more than 5 cases.');
                }
            }
        } 
    }
    public static void caseOpportunityUpdate(List<Case> casesList, Map<id, Case> oldMap){
        Map<Id, Integer> caseList = new Map<Id, Integer>();
        set<Id> oppoIds = new Set<Id>();
        for(Case cas : casesList){
            if(cas.Opportunity__c != Null){
                oppoIds.add(cas.Opportunity__c);
                }
            if(oldMap != Null && oldMap.get(cas.Id).Opportunity__c != Null){
                oppoIds.add(oldMap.get(cas.Id).Opportunity__c);
                }
            }
        List<Case> caseCount = [SELECT Id, Opportunity__c FROM Case WHERE Opportunity__c IN : oppoIds];
        For(Case cass : caseCount){
            if(caseList.containsKey(cass.Opportunity__c)){
                caseList.put(cass.Opportunity__c, 0);
            }
            caseList.put(cass.Opportunity__c, caseList.get(cass.Opportunity__c)+1);
        }
        for(Case cas : casesList){
            Case oldCase = oldMap.get(cas.Id);
            if(cas.Opportunity__c != Null){
                Integer Count = caseList.containsKey(cas.Opportunity__c) ? caseList.get(cas.Opportunity__c):0;
                if(count > 5){
                    cas.addError(system.label.less_Then_5_Cases);
                }
            }	
        }
    }
    public static void copyOppoTeamToCaseTeam(List<Case> caseList){
        set<Id> oppoIds = new set<Id>();
        for(Case cas : caseList){
            if(cas.Opportunity__c != Null){
                oppoIds.add(cas.Opportunity__c);
            }
        }
        Map<Id, List<OpportunityTeamMember>> oppoTeamMemb = new Map<id, List<OpportunityTeamMember>>();
        List<OpportunityTeamMember> oppoTeam = [SELECT OpportunityId, UserId, TeamMemberRole FROM OpportunityTeamMember 
                                                WHERE OpportunityId IN : oppoIds];
        for(OpportunityTeamMember otm : oppoTeam){
            if(!oppoTeamMemb.containsKey(otm.OpportunityId)){
                oppoTeamMemb.put(otm.OpportunityId, new List<OpportunityTeamMember>());
            }
            oppoTeamMemb.get(otm.OpportunityId).add(otm);
        }
        Map<String, Id> caseTeamMap = new Map<String, Id>();
        List<CaseTeamRole> caseRoles = [SELECT Id, Name FROM CaseTeamRole];
        for(CaseTeamRole ctr : caseRoles){
            caseTeamMap.put(ctr.Name, ctr.Id);
        }
        List<CaseTeamMember> caseTeam = new LIst<CaseTeamMember>();
        for(Case cas : caseList){
            if(oppoTeamMemb.containsKey(cas.Opportunity__c)){
                for(OpportunityTeamMember otm : oppoTeamMemb.get(cas.Opportunity__c)){
                    CaseTeamMember ctm = new CaseTeamMember();
                    ctm.ParentId = cas.Id;
                    ctm.MemberId = otm.UserId;
                    ctm.TeamRoleId = caseTeamMap.get(otm.TeamMemberRole);
                    caseTeam.add(ctm);
                }
            }	
        }
        if(!caseTeam.isEmpty()){
            insert caseTeam;
        }
    }
    public static void accountCaseMoreThenTen(List<Case> newCase){
        set<Id> accIds = new set<Id>();
        for(Case cas : newCase){
            if(cas.AccountId != Null){
                accIds.add(cas.AccountId);
            }
        }
        Map<Id, Integer> caseCount = new Map<Id, Integer>();
        List<Case> caseList = [SELECT 
                               Id, 
                               AccountId 	
                               FROM Case
                               WHERE AccountId IN : accIds];
        for(Case c : caseList){
            caseCount.put(c.AccountId, (caseCount.containsKey(c.AccountId) ? caseCount.get(c.AccountId) : 0)+1);
        }
        List<Account> accList = new List<Account>();
        for(Case c : newCase){
            Integer count = caseCount.containsKey(c.AccountId) ? caseCount.get(c.AccountId) : 0;
            if(count >= 10){
                c.addError(system.label.lessThen10Cases);
            }
            else{
                caseCount.put(c.AccountId, ++count);
                if(count == 10){
                    accList.add(new Account(Active__c = False, Id = c.AccountId));
                }
            }
        }
        if(!accList.isEmpty()){
            Update accList;
        }
    }
    
    public static void caseClosedOpportunitySalesManagerPresent(List<Case> caseList, Map<Id, Case>oldMap){
        set<Id> oppIds = getOpportunityCaseIds(caseList, oldMap);
        Set<Id> oppWithSalesManager = new Set<Id>();
        List<OpportunityTeamMember> oppoTeamMemb = getoppoTeamMemb(oppIds);
        for(OpportunityTeamMember otm : oppoTeamMemb){
            oppWithSalesManager.add(otm.OpportunityId);
        }
        for(Case c : caseList){
            if(c.Status == ConstantsClass.Case_Status_Closed &&
               oldMap.get(c.Id).Status != ConstantsClass.Case_Status_Closed &&
               c.Opportunity__c != Null &&
               c.Opportunity_related_case__c &&
               !oppWithSalesManager.contains(c.Opportunity__c)){
                c.addError(system.label.StstusClosedOpportunitySalesManagerPresent);                  
            }
        }
    }
    private static set<Id> getOpportunityCaseIds(List<Case> caseList, Map<Id, Case>oldMap){
        set<Id> oppIds = new set<Id>();
        for(Case c : caseList){
            if(c.Status == ConstantsClass.Case_Status_Closed &&
               oldMap.get(c.Id).Status != ConstantsClass.Case_Status_Closed &&
               c.Opportunity__c != Null && 
               c.Opportunity_related_case__c){
                oppIds.add(c.Opportunity__c);  
            }
        }
        return oppIds;
    }
    private static List<OpportunityTeamMember> getoppoTeamMemb(set<Id> oppIds){
        return [SELECT Id,
                       OpportunityId
                FROM   OpportunityTeamMember
                WHERE
                     OpportunityId IN : oppIds
                AND
                   TeamMemberRole = 'Sales Manager'];
    }
}