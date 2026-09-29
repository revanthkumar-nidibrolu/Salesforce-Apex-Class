public class OpportunityHandler {
    public static void updatefield(List<Opportunity> oppolist){
        for(Opportunity oppo : oppolist){
            if(oppo.StageName == ConstantsClass.Stage_Closed_Won || oppo.StageName == ConstantsClass.Stage_Closed_Won){
                oppo.Country__c = 'India';
              	System.debug(oppo.Country__c);
                System.debug('This Line Execute Upto Here');
            }
        }
    }
    
    public static void discUpdate(List<Opportunity> listoppo){
        for(Opportunity opp : listoppo){
            if(opp.Amount == null || opp.Amount >= 100000){
                opp.Description = 'Hot Opportunity';
                system.debug(opp.Description);
            }
        }
    }
    
    public static void caseCreation(List<Opportunity> oppoList){
        List<Case> caseAssg = new List<Case>();
        for(Opportunity oppt : oppoList){
            if(oppt.Amount >= 10000){
                Case cas = new Case();
                cas.Priority = 'High';
                cas.Opportunity__c = oppt.Id;
                cas.Status = ConstantsClass.Case_Status_New ;
                cas.Origin = 'Email';
                caseAssg.add(cas);
            }
        }
        if(!caseAssg.isEmpty()){
            insert caseAssg;
        }
    }
    
    public static void recentOpportunityAmount(List<Opportunity> oppoList){
        List<Account> accList = new List<Account>();
        for(Opportunity opp : oppoList){
            Account acc = new Account();
            acc.Id = opp.AccountId;
            acc.Recent_Opportunity_Amount__c = opp.Amount;
            accList.add(acc);
        }
        if(!accList.isEmpty()){
            Update accList;
        }
    }
    
    public static void oppoAmountUpdateOnAnnualRevenue(List<Opportunity> oppoList){
        Map<Id, Decimal> oppoAmount = new Map<Id, Decimal>();
        set<Id> accId = new set<Id>();
        for(Opportunity oppo : oppoList){
            if(oppo.Amount != Null && oppo.AccountId != Null){
                accId.add(oppo.AccountId);
            }
        }
        List<Opportunity> oppList = [SELECT 
                                     Id, 
                                     AccountId, 
                                     Amount 
                                     FROM Opportunity 
                                     WHERE AccountId IN : accId];
        Map<Id, Decimal> oppAmounts = new Map<Id, decimal>();
        for(Opportunity opp : oppList){
            if(!oppoAmount.containsKey(opp.AccountId)){
                oppoAmount.put(opp.AccountId,1);
            }
            Decimal currAmount = oppoAmount.get(opp.AccountId);
            Decimal opptAmount = (opp.Amount != Null) ? opp.Amount : 0;
            oppoAmount.put(opp.AccountId, currAmount + opptAmount);
            
        }
        List<Account> accList = [SELECT 
                                 Id, 
                                 AnnualRevenue 
                                 From Account 
                                 WHERE Id IN : accId];
        for(Account acc : accList){
            Decimal existingRevenue=(acc.AnnualRevenue != Null) ? acc.AnnualRevenue : 0;
            Decimal totalAmount = (oppoAmount.containsKey(acc.Id)) ? oppoAmount.get(acc.Id):0;
            acc.AnnualRevenue = existingRevenue + totalAmount;
            }
        try{
            update accList;
            system.debug(accList);
        }catch(dmlException e){
            system.debug(e.getmessage());
        }
    }
    
    public static void oppoClosedDate(List<Opportunity> oppoList){
        for (Opportunity oppo : oppoList){
            if(oppo.StageName == ConstantsClass.Stage_Closed_Won){
                oppo.CloseDate = system.today();
                system.debug(oppo);
            }
        }
    }
    
    public static void OppoClosedWonCreateDeal(List<Opportunity> oppoLists, Map<Id, Opportunity> oldMap) {
        List<Deal__c> dealList = new List<Deal__c>();
        for(Opportunity oppo : oppoLists) {
            Opportunity oldOppo = oldMap.get(oppo.Id);
            if(oldMap == null && oppo.StageName == ConstantsClass.Stage_Closed_Won && oldOppo.StageName != ConstantsClass.Stage_Closed_Won &&
                oppo.Start_Date__c != null && oppo.End_Date__c != null && oppo.Amount != null) {
                    createDeals(dealList,
                                oppo.Id,
                                oppo.Name,
                                oppo.Start_Date__c,
                                oppo.End_Date__c,
                                oppo.Amount);
            }
       }
       if(!dealList.isEmpty()) {
           insert dealList;
       }
    }
    
    public static void createDeals(List<Deal__c> dealList, Id opportunityId, String opportunityName, 
                                   Date startDate, Date endDate, Decimal amount){
        Integer totalDays = startDate.daysBetween(endDate) + 1;
        Decimal daysAmount = amount / totalDays;
        Date currEndDate;
        for(Date currStartDate = startDate; currStartDate <= endDate; currStartDate = currEndDate.addDays(1)) {
            Date lastDate = currStartDate.toStartOfMonth().addMonths(1).addDays(-1);	
            if(lastDate > endDate){
                currEndDate = endDate;
            }
            else{
                currEndDate = lastDate;
            }
            Integer daysDeal = currStartDate.daysBetween(currEndDate) + 1;
            Decimal dealAmount = (daysAmount * daysDeal);
            dealList.add(new Deal__c(Name = opportunityName + ' Deal ', 
                                     Opportunity__c = opportunityId, 
                                     Start_Date__c = currStartDate, 
                                     End_Date__c = currEndDate,
                                     Amount__c = dealAmount));
                                     currStartDate = currEndDate.addDays(1);
        }
    }
    
    public static void caseClosedOppoClosedWon(List<Opportunity> oppoList, Map<Id, Opportunity>oldMap){
        Map<Id, Integer> caseRecords = new Map<Id, Integer>();
        set<Id> oppoIds = new set<Id>();
        for(Opportunity oppo : oppoList){
            Opportunity oldOppo = oldMap.get(oppo.Id);
            if(oppo.StageName == 'C ' && oldOppo.StageName != ConstantsClass.Stage_Closed_Won){
                oppoIds.add(oppo.Id);
            }
        }
        List<Case> caseList = [SELECT
                               Id, 
                               Opportunity__c 
                               FROM Case 
                               WHERE Opportunity__c IN : oppoIds 
                               AND Status != 'Closed'];
        for(Case cas : caseList){
            if(!caseRecords.containsKey(cas.Opportunity__c)){
                caseRecords.put(cas.Opportunity__c, 0);
            }
            caseRecords.put(cas.Opportunity__c, caseRecords.get(cas.Opportunity__c)+1);
        }
        for(Opportunity oppo : oppoList){
            if(caseRecords.containsKey(oppo.Id)){
                oppo.addError(system.label.opporelatedcases);
            }
        }  	
    }
    
    public static void accountTeamToOppoTeam(List<Opportunity> oppoList){
        set<Id> accIds = new set<Id>();
        for(Opportunity oppo : oppoList){
            if(oppo.AccountId != Null){
                accIds.add(oppo.AccountId);
            }
        }
        Map<Id, List<AccountTeamMember>> accTeamMemb = new Map<Id, List<AccountTeamMember>>();
        List<AccountTeamMember> accTeams = [SELECT 
                                            AccountId, 
                                            UserId, 
                                            TeamMemberRole 
                                            FROM AccountTeamMember 
                                            WHERE AccountId IN : accIds];	
        for(AccountTeamMember atm : accTeams){
            if(!accTeamMemb.containsKey(atm.AccountId)){
                accTeamMemb.put(atm.AccountId, new List<AccountTeamMember>());
            }
            accTeamMemb.get(atm.AccountId).add(atm);
        }
        List<OpportunityTeamMember> oppoTeam = new List<OpportunityTeamMember>();
        for(Opportunity oppo : oppoList){
            if(accTeamMemb.ContainsKey(oppo.AccountId)){
                for(AccountTeamMember atm : accTeamMemb.get(oppo.AccountId)){
                    OpportunityTeamMember otm = new OpportunityTeamMember();
                    otm.OpportunityId = oppo.Id;
                    otm.TeamMemberRole = atm.TeamMemberRole;
                    otm.UserId = atm.UserId;
                    oppoTeam.add(otm);
                }
            }
        }
        if(!oppoTeam.isEmpty()){
            insert oppoTeam;
        }
    }
    
    public static void oppoStartAndEndDatesDealCreation(List<Opportunity> oppoList){
        List<Deal__c> dealList = New List<Deal__c>();
        for(Opportunity oppo : oppoList){
            if(oppo.Start_Date__c != Null && oppo.End_Date__c != Null && oppo.Amount != Null){
                Date firstMonth = oppo.Start_Date__c.toStartOfMonth();
                Date lastMonth = oppo.End_Date__c.toStartOfMonth();
                Integer totalMonths = firstMonth.monthsBetween(lastMonth)+1;
                Decimal totalAmount = oppo.Amount/totalMonths;
                for(Integer i=0; i<totalMonths; i++){
                    Date startDate = firstMonth.addMonths(i);
                    Date endDate = startDate.addMonths(1).addDays(-1);
                    Deal__c del = new Deal__c();
                    del.Name = oppo.Name;
                    del.Opportunity__c = oppo.Id;
                    del.Amount__c = totalAmount;
                    del.Start_Date__c = startDate;
                    del.End_Date__c = endDate;
                    dealList.add(del);
                }
            }
        }
        if(!dealList.isEmpty()){
            insert dealList;
        }
    }
    
    public static void OpportunityTeamCreation(List<Opportunity> newList){
        set<Id> priAccId = new set<Id>();
        set<Id> secAccId = new set<Id>();
        List<Opportunity> businessOpps = getBusinessOpportunites(newList, priAccId, secAccId);
        if(businessOpps.isEmpty()){
            return;
        }
        Map<Id, Map<Id, Target__c>> targetMap = new Map<Id, Map<Id, Target__c>>();
        List<Target__c> tarList = getTargetList(priAccId, secAccId);
        for(Target__c trg : tarList){
            if(!targetMap.containsKey(trg.Account_Primary__c)){
                targetMap.put(trg.Account_Primary__c, new Map<Id, Target__c>());
            }
            targetMap.get(trg.Account_Primary__c).put(trg.Secondary_Account__c, trg);
        }
        Map<Id, List<AccountTeamMember>> accTeamMemb = new Map<Id, List<AccountTeamMember>>();
        List<AccountTeamMember> accTeams = getAccountTeam(priAccId);
        for(AccountTeamMember atm : accTeams){
            if(!accTeamMemb.containsKey(atm.AccountId)){
                accTeamMemb.put(atm.AccountId, new List<AccountTeamMember>());
            }
            accTeamMemb.get(atm.AccountId).add(atm);
        }
        List<OpportunityTeamMember> oppTeamMember = createOpportunityTeams (businessOpps, targetMap, accTeamMemb);
        if(!oppTeamMember.isEmpty()){
            try{
                insert oppTeamMember;
            }catch(dmlException e){
                system.debug('A dml error occurs: ' + e.getMessage());
            }
        }
    }
    
    private static List<Opportunity> getBusinessOpportunites (List<Opportunity> newList, set<Id> priAccId, set<Id> secAccId){
        List<Opportunity> businessOpps = new List<Opportunity>();
        Id recordTypeId = Schema.SObjectType.Opportunity
            .getRecordTypeInfosByDeveloperName()
            .get(ConstantsClass.Opportunity_Business_Record_Type)
            .getRecordTypeId();
        for(Opportunity oppo : newList){
            if(oppo.RecordTypeId == recordTypeId){
                businessOpps.add(oppo);
                if(oppo.AccountId != Null){
                    priAccId.add(oppo.AccountId);
                }
                if(oppo.Secondary_Account__c != Null){
                    secAccId.add(oppo.Secondary_Account__c);
                }
            }
        }
        return businessOpps;
    }
    
    private static List<Target__c> getTargetList (set<Id> priAccId, set<Id> secAccId){
        return [SELECT
                Id,
                Account_Manager__c,
                Sales_Manager__c,
                Account_Primary__c,
                Secondary_Account__c,
                Amount__c
                FROM Target__c
                WHERE
                Account_Primary__c IN : priAccId
                AND
                Secondary_Account__c IN : secAccId];
    }
    
    private static List<AccountTeamMember> getAccountTeam (set<Id> priAccId){
        return [SELECT 
                AccountId, 
                UserId, 
                TeamMemberRole 
                FROM AccountTeamMember 
                WHERE AccountId IN : priAccId];
    }
    
    private static List<OpportunityTeamMember> createOpportunityTeams (List<Opportunity> oppList, 
                                                                      Map<Id, Map<Id, Target__c>> targetMap,
                                                                      Map<Id, List<AccountTeamMember>> accTeamMemb){
        List<OpportunityTeamMember> oppTeamMember = new List<OpportunityTeamMember>();
        for(Opportunity oppo : oppList){
            if(targetMap.containsKey(oppo.AccountId) &&
              targetMap.get(oppo.AccountId).containsKey(oppo.Secondary_Account__c)){
                Target__c tgr = targetMap.get(oppo.AccountId).get(oppo.Secondary_Account__c);
                if(tgr.Account_Manager__c != Null || tgr.Sales_Manager__c != null){
                    List<OpportunityTeamMember> teamMembers = createOpportunityTeamBasedOnTarget(oppo, tgr);
                    oppTeamMember.addAll(teamMembers); 
                }
                else{
                    List<OpportunityTeamMember> teamMembers = CreateOpportunityTeamBasedOnPriAccId(oppo, accTeamMemb);
                    oppTeamMember.addAll(teamMembers); 
                }
            }
        }
        return oppTeamMember;
    }
    
    private static List<OpportunityTeamMember> createOpportunityTeamBasedOnTarget (Opportunity oppo, Target__c tgr){
        List<OpportunityTeamMember> oppTeamMember = new List<OpportunityTeamMember>();
        if(tgr.Account_Manager__c != Null &&
           tgr.Sales_Manager__c != Null){
               oppTeamMember.add(new OpportunityTeamMember(
               OpportunityId = oppo.Id,
               userId = tgr.Account_Manager__c,
               TeamMemberRole = 'Account Manager'));
               oppTeamMember.add(new OpportunityTeamMember(
               OpportunityId = oppo.Id,
               userId = tgr.Sales_manager__c,
               TeamMemberRole = 'Sales Manager'));
        }
        return oppTeamMember;
    }
    
    private static List<OpportunityTeamMember> CreateOpportunityTeamBasedOnPriAccId(Opportunity oppo, 
                                                                                    Map<Id, List<AccountTeamMember>> accTeamMemb){
        List<OpportunityTeamMember> oppTeamMember = new List<OpportunityTeamMember>();
        if(accTeamMemb.containsKey(oppo.AccountId)){
            for(AccountTeamMember atm : accTeamMemb.get(oppo.AccountId)){
                oppTeamMember.add(new OpportunityTeamMember(
                    OpportunityId = oppo.Id,
                    UserId = atm.UserId,
                    TeamMemberRole = atm.TeamMemberRole));
            }	
        }
        return oppTeamMember;
    }
    
    public static void targetAmountToOppoAmount(List<Opportunity> oppList){
        set<Id> priAccId = new set<Id>();
        set<Id> secAccId = new set<Id>();
        List<Opportunity> businessOpps = getBusinessOpportunites(oppList, priAccId, secAccId);
        if(businessOpps.isEmpty()){
            return;
        }
        Map<Id, Map<Id, Target__c>> targetMap = new Map<Id, Map<Id, Target__c>>();
        List<Target__c> tarList = getTargetList(priAccId, secAccId);
        for(Target__c trg : tarList){
            if(!targetMap.containsKey(trg.Account_Primary__c)){
                targetMap.put(trg.Account_Primary__c, new Map<Id, Target__c>());
            }
            targetMap.get(trg.Account_Primary__c).put(trg.Secondary_Account__c, trg);
        }
        for(Opportunity oppo : oppList){
            Target__c trg = targetMap.get(oppo.AccountId) != null ? targetMap.get(oppo.AccountId).get(oppo.Secondary_Account__c) : null;
            if(trg != null){
                oppo.Amount = trg.Amount__c;
            }
        }
    }
    
    public static void opportunityCaseCreation(List<Opportunity> oppList, Map<Id, Opportunity>oldMap){
        set<Id> accIds = new set<Id>();
        set<Id> accountWithCases = new set<Id>();
        for(Opportunity opp : oppList){
            if( opp.AccountId != null &&  opp.StageName == 'Closed Won' && 
               (oldMap == Null || oldMap.get(opp.Id).StageName != 'Closed Won')){
                accIds.add(opp.AccountId);
            }
        }
        List<Case> caseList = getOpenCases (accIds);
        for(Case cs : caseList){
            accountWithCases.add(cs.AccountId);
        }
        List<Case> newCases = createCases(oppList, oldMap, accountWithCases);
        if(!newCases.isEmpty()){
            try{
                insert newCases;
            }catch(dmlException e){
                system.debug('A dml error occurs: '+e.getMessage());
            }
        }
    }
    private static List<Case> getOpenCases (set<Id> accIds){
        return [SELECT
                Id,
                AccountId,
                Status
                FROM Case
                WHERE
                Status != 'Closed'
                AND
                AccountId IN : accIds];
    }
    private static List<Case> createCases (List<Opportunity> oppList, Map<Id, Opportunity>oldMap, set<Id> accountWithCases){
        List<Case> newCases = new List<Case>();
        for(Opportunity opp : oppList){
            if(opp.AccountId != Null && !accountWithCases.contains(opp.AccountId) &&
               opp.StageName == 'Closed Won' && (oldMap == null || oldMap.get(opp.Id).StageName != 'Closed Won')){
                newCases.add(new Case(
                AccountId = opp.AccountId,
                Opportunity__c = opp.Id,
                Subject = 'Case create from Opportunity',
                Status = 'New',
                Origin = 'Internal'));
                accountWithCases.add(opp.AccountId);
            }
        }
        return newcases;
    }
    
    public static void handleAfterUpdate(List<Opportunity> newList, Map<Id, Opportunity>oldMap){ 
        set<Id> oppIds = new set<Id>();
        for(Opportunity opp : newList){
            if(opp.StageName == 'Closed Won' && (oldMap == null || oldMap.get(opp.Id).StageName != 'Closed Won')){
                oppIds.add(opp.Id);
            }
        }
        if(!oppIds.isEmpty()){
            system.enqueueJob(new UpdateAccountQueueable(oppIds));
        }
    }
    
    public static void updateAccountAnnualRevenue(List<Opportunity> newList, Map<Id, Opportunity>oldMap){
        set<Id> accountIds = new set<Id>();
        if(newList != null){
            for(Opportunity opp : newList){
                if(opp.AccountId != null){
                    accountIds.add(opp.AccountId);
                }
            }
        }
        if(oldMap != null){
            for(Opportunity oldOpp : oldMap.values()){
                if(oldOpp.AccountId != null){
                    accountIds.add(oldOpp.AccountId);
                }
            }
        }
        List<Account> accList = getAccountList(accountIds);
        if(!accList.isEmpty()){
            try{
                update accList;
            }catch(Exception e){
                system.debug('Error: '+e.getMessage());
            }
        }
    }
    
    private static List<Account> getAccountList (set<Id> accountIds){
        List<Opportunity> oppList = [SELECT
                                    Id,
                                    Amount,
                                    AccountId
                                    FROM Opportunity
                                    WHERE
                                    AccountId IN : accountIds];
        Map<Id, Decimal> accAmount = new Map<Id, Decimal>();
        for(Opportunity opp : oppList){
            if(!accAmount.containsKey(opp.AccountId)){
                accAmount.put(opp.AccountId, 0);
            }
            accAmount.put(opp.AccountId, accAmount.get(opp.AccountId)+(opp.Amount == null ? 0 : opp.Amount));
        }
        List<Account> acclist = new List<Account>();
        for(Id accId : accountIds){
            Account acc = new Account(
            Id = accId,
            AnnualRevenue = accAmount.containsKey(accId) ? accAmount.get(accId) : 0);
            accList.add(acc);
        }	
        return accList;
    }
    
    public static void accountTeamToOpportunityTeam(List<Opportunity> oppoList){
        set<Id> accIds = new set<Id>();
        for(Opportunity oppo : oppoList){
            if(oppo.AccountId != Null){
                accIds.add(oppo.AccountId);
            }
        }
        Map<Id, List<AccountTeamMember>> accTeamMemb = new Map<Id, List<AccountTeamMember>>();
        List<AccountTeamMember> accTeams = teamList (accIds);	
        for(AccountTeamMember atm : accTeams){
            if(!accTeamMemb.containsKey(atm.AccountId)){
                accTeamMemb.put(atm.AccountId, new List<AccountTeamMember>());
            }
            accTeamMemb.get(atm.AccountId).add(atm);
        }
        List<OpportunityTeamMember> oppoTeam = oppoTeamMember(oppoList, accTeamMemb);
        if(!oppoTeam.isEmpty()){
            insert oppoTeam;
        }
    }
    private static List<AccountTeamMember> teamList (set<Id> accIds){
        return [SELECT 
                AccountId, 
                UserId, 
                TeamMemberRole 
                FROM AccountTeamMember 
                WHERE AccountId IN : accIds];
    }
    private static List<OpportunityTeamMember> oppoTeamMember (List<Opportunity> oppoList, 
                                                               Map<Id, List<AccountTeamMember>> accTeamMemb ){
        List<OpportunityTeamMember> oppTeam = new List<OpportunityTeamMember>();
        for(Opportunity oppo : oppoList){
            if(accTeamMemb.ContainsKey(oppo.AccountId)){
                for(AccountTeamMember atm : accTeamMemb.get(oppo.AccountId)){
                    OpportunityTeamMember otm = new OpportunityTeamMember();
                    otm.OpportunityId = oppo.Id;
                    otm.TeamMemberRole = atm.TeamMemberRole;
                    otm.UserId = atm.UserId;
                    oppTeam.add(otm);
                }   
            }
        }
        return oppTeam;
    }
    
    public static void accountAssignBasedOnRegion(List<Opportunity> newOpportunity, Map<Id, Opportunity>oldMap){
        set<String> region = new set<String>();
        for(Opportunity oppo : newOpportunity){
            if(oppo.Region__c != null && (oldMap == null || oppo.Region__c != oldMap.get(oppo.Id).Region__c)){
                region.add(oppo.Region__c);
            }
        }
        Map<String, Id> accountRegions = new Map<String, Id>();
        List<Account> accList = [SELECT
                                Id,
                                Region__c
                                FROM Account
                                WHERE
                                Region__c IN : region 
                                ORDER BY CreatedDate DESC];
        for(Account acc : accList){
            if(!accountRegions.containsKey(acc.Region__c)){
                accountRegions.put(acc.Region__c, acc.Id);
            }
        }
        
        for(Opportunity oppo : newOpportunity){
            if(accountRegions.containsKey(oppo.Region__c)){
                oppo.Secondary_Account__c = accountRegions.get(oppo.Region__c);
            }
            else{
                oppo.Secondary_Account__c = null;
            }
        }    
    }
    
    public static void opportunityValuePropositionApproval(List<Opportunity> oppList, Map<Id, Opportunity> oldMap){
        for(Opportunity opp : oppList){
            if(opp.Account_Manager_Opportunity__c &&
               opp.StageName == ConstantsClass.Stage_Value_Proposition &&
               oldMap.get(opp.Id).StageName != ConstantsClass.Stage_Value_Proposition){
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                   req.setObjectId(opp.Id);
                   req.setComments('Opportunity submitted for approval.');
                   Approval.Process(req);
            }
        }
    }
    
    public static void opportunityValueProposition(List<Opportunity> oppoList, Map<Id, Opportunity> oldMap){
        for(Opportunity opp : oppoList){
            if(!opp.Account_Manager_Opportunity__c){
                continue;
            }
            if((opp.Probability > 50 || opp.Probability == 0) && opp.Account_Manager_Approval__c != 'Approval'){
                opp.addError('This Opportunity cannot move Value Proposition next stages until Value Proposition approved.');
            }
            if(oldMap.get(opp.Id).StageName == ConstantsClass.Stage_Value_Proposition &&
               oldMap.get(opp.Id).StageName != opp.StageName &&
               opp.Account_Manager_Approval__c != 'Approval'){
                   opp.addError('cannot move backword and forword.');
               }
            if(oldMap.get(opp.Id).Account_Manager_Approval__c == 'Approval' &&
               opp.StageName != oldMap.get(opp.Id).StageName){ 
                if(opp.Probability < oldMap.get(opp.Id).Probability){
                    opp.addError('Cannot move Stage back.');   
                }
            }
            if(opp.Account_Manager_Approval__c == 'Pending Approval' && 
               opp.Account_Manager_Approval__c == oldMap.get(opp.Id).Account_Manager_Approval__c ){
                opp.addError('You Can not Edit This Record When appoval is pending');
            }
        }
    }
    
    public static void opportunityClosedCaseCreation(List<Opportunity> oppoList, Map<Id, Opportunity>oldMap){
        set<Id> oppoIds = getClosedWonOpportunityIds(oppoList, oldMap);
        set<Id> existingCaseOppoIds = new set<Id>();
        List<Case> caseList = getExistingCaseOppoIds(oppoIds);
        for(Case c : caseList){
            existingCaseOppoIds.add(c.Opportunity__c);
        }
        List<Case> caseAssg = newCaseAssign(oppoIds, existingCaseOppoIds);
        if(!caseAssg.isEmpty()){
            try{
                insert caseAssg;
            }catch(Exception e){
                system.debug('Error: '+e.getMessage());
            }
        }
    }
    private static set<Id> getClosedWonOpportunityIds(List<Opportunity> oppoList, Map<Id, Opportunity>oldMap){
        set<Id> oppoIds = new set<Id>();
        for(Opportunity opp : oppoList){
            if(opp.Account_Manager_Opportunity__c &&
               opp.StageName == ConstantsClass.Stage_Closed_Won &&
               oldMap.get(opp.Id).StageName != ConstantsClass.Stage_Closed_Won){
                oppoIds.add(opp.Id);
            }
        }
        return oppoIds;
    }
    private static List<Case> getExistingCaseOppoIds(set<Id> oppoIds){
        return [SELECT Id,
                       Opportunity__c
                  FROM Case
                 WHERE
                       Opportunity__c IN : oppoIds];
        
    }
    
    private static List<Case> newCaseAssign (set<Id> oppoIds, set<Id> existingCaseOppoIds){
        List<Case> caseAssg = new List<Case>();
        for(Id oppoId : oppoIds){
            if(!existingCaseOppoIds.contains(oppoId)){
                Case cas = new Case();
                cas.Priority = ConstantsClass.Case_Priority;
                cas.Opportunity__c = oppoId;
                cas.Status = ConstantsClass.Case_Status_New ;
                cas.Origin = ConstantsClass.Case_Origin;
                cas.Opportunity_related_case__c = True;
                caseAssg.add(cas);
            }   
        }
        return caseAssg;
    }
    
    public static void createOpportunityTeams(List<Opportunity> newOpportunity){
        set<Id> accountIds = gettingAccountId(newOpportunity);
        if(accountIds.isEmpty()){
            return;
        }
        List<AccountTeamMember> gettingAccountTeams = getAccountTeams(accountIds);
        Map<Id, List<AccountTeamMember>> gettingAccTeamMemberMap = getAccountTeamsMap(gettingAccountTeams);	
        List<OpportunityTeamMember> opportunityTeamMembers = createOpportunityTeam(newOpportunity, gettingAccTeamMemberMap);
        if(!opportunityTeamMembers.isEmpty()){
            try{
                insert opportunityTeamMembers;
            }catch(Exception e){
                system.debug('Error: '+e.getMessage());
            }
        }
    }
    
    private static set<Id> gettingAccountId(List<Opportunity> newOpportunity){
        set<Id> accountId = new set<Id>();
        for(Opportunity opp : newOpportunity){
            if(opp.AccountId != null){
                accountId.add(opp.AccountId);
            }
        }
        return accountId;
    }
    
    private static List<AccountTeamMember> getAccountTeams(set<Id> accountIds){
        return [SELECT AccountId, 
                       UserId, 
                       TeamMemberRole 
                FROM AccountTeamMember 
                WHERE AccountId IN : accountIds];
    }
    
    private static Map<Id, List<AccountTeamMember>> getAccountTeamsMap(List<AccountTeamMember> gettingAccountTeams){
        Map<Id, List<AccountTeamMember>> accTeamMember = new Map<Id, List<AccountTeamMember>>();
        for(AccountTeamMember atm : gettingAccountTeams){
            if(!accTeamMember.containsKey(atm.AccountId)){
                accTeamMember.put(atm.AccountId, new List<AccountTeamMember>());
            }
            accTeamMember.get(atm.AccountId).add(atm);
        }
        return accTeamMember;
    }
    
    private static List<OpportunityTeamMember> createOpportunityTeam(List<Opportunity> newOpportunity, 
                                                                     Map<Id, List<AccountTeamMember>> gettingAccTeamMemberMap){ 
        List<OpportunityTeamMember> opportunityTeams = new List<OpportunityTeamMember>(); 
        for(Opportunity opp : newOpportunity){ 
            opportunityTeams.addAll(teamMembersForOpportunity(opp, gettingAccTeamMemberMap));
        } 
        return opportunityTeams; 
    }
    
    private static List<OpportunityTeamMember> teamMembersForOpportunity(Opportunity opp, 
                                                                         Map<Id, List<AccountTeamMember>> gettingAccTeamMemberMap){
        List<OpportunityTeamMember> oppTeamMembers = new List<OpportunityTeamMember>();
        if(gettingAccTeamMemberMap.containsKey(opp.AccountId)){ 
            for(AccountTeamMember atm : gettingAccTeamMemberMap.get(opp.AccountId)){ 
                OpportunityTeamMember otm = new OpportunityTeamMember(); 
                otm.OpportunityId = opp.Id; 
                otm.TeamMemberRole = atm.TeamMemberRole; 
                otm.UserId = atm.UserId; 
                oppTeamMembers.add(otm); 
            } 
        } 
        return oppTeamMembers;
    }

    public static void validateAccountTeams(List<Opportunity> newOpportunity){
        Set<Id> accountIds = gettingAccountId(newOpportunity);
        if(accountIds.isEmpty()){
            return;
        }
        List<AccountTeamMember> gettingAccountTeams = getAccountTeams(accountIds);
        Set<Id> gettingAccountsTeamId = getAccountsTeamIds(gettingAccountTeams);
        validAccountTeam(newOpportunity, gettingAccountsTeamId);
    }
    
    private static Set<Id> getAccountsTeamIds(List<AccountTeamMember> gettingAccountTeams){
        Set<Id> gettingAccountsTeamId = new Set<Id>();	
        for(AccountTeamMember teamMember : gettingAccountTeams){
            gettingAccountsTeamId.add(teamMember.AccountId);
        }
        return gettingAccountsTeamId;
    }
    
    public static void validAccountTeam(List<Opportunity> newOpportunity, Set<Id> gettingAccountsTeamId){
        for(Opportunity opp : newOpportunity){
            if(opp.AccountId == Null){
                return;
            }
            if(!gettingAccountsTeamId.contains(opp.AccountId)){
                opp.addError(system.label.ValideAccountTeam);
            }
        }
    }
    
    public static void createCase(List<Opportunity> newOpportunity, Map<Id, Opportunity> oldMap){
        Set<Id> opportunityIds = new Set<Id>();
        for(Opportunity opp : newOpportunity){
            if(opp.StageName == ConstantsClass.Stage_Closed_Won && 
               opp.Closed_won_Reason__c == ConstantsClass.Technical_Issue_Reason &&
               (oldMap == null || oldMap.get(opp.Id).StageName != ConstantsClass.Stage_Closed_Won)){
                opportunityIds.add(opp.Id);
            }
        }
        if(opportunityIds.isEmpty()){
            return;
        }
        createTechnicalCase(opportunityIds);
    }
    
    private static void createTechnicalCase(Set<Id> opportunityIds){
        List<OpportunityTeamMember> getOpportunityTeamsList = getOpportunityTeams(opportunityIds);
        Map<Id, Id> oppTeamUserIds = new Map<Id, Id>();
        for(OpportunityTeamMember oppTeam : getOpportunityTeamsList){
            oppTeamUserIds.put(oppTeam.OpportunityId, oppTeam.UserId);
        }
        Set<Id> getTeamUserIds  = new Set<Id>(oppTeamUserIds.values());
        Map<Id, User> getUserIdsMap = getUserIds(getTeamUserIds);
        Id fetchTechnicalRecordTypeId = getTechnicalRecordTypeId();
        caseCreation(opportunityIds, oppTeamUserIds, getUserIdsMap, fetchTechnicalRecordTypeId);
    }
    
    private static List<OpportunityTeamMember> getOpportunityTeams(Set<Id> opportunityIds){
        return [SELECT OpportunityId,
                       UserId,
                       TeamMemberRole
                FROM OpportunityTeamMember
                WHERE OpportunityId IN :opportunityIds
                AND TeamMemberRole = :ConstantsClass.Technical_Engineer_Role];
    }
    
    private static Map<Id, User> getUserIds(Set<Id> getTeamUserIds){
        return new Map<Id, User>([SELECT Id, 
                                         IsActive
                                  FROM User
                                  WHERE Id IN :getTeamUserIds]);
    }
    
    private static Id getTechnicalRecordTypeId(){
        Schema.RecordTypeInfo recordTypeInfo = Schema.SObjectType.Case
                                               .getRecordTypeInfosByDeveloperName()
                                               .get(ConstantsClass.Technical_Issue_RecordType);
        return recordTypeInfo.getRecordTypeId();
    }
    
    private static void caseCreation(Set<Id> opportunityIds,
                                     Map<Id, Id> oppTeamUserIds,
                                     Map<Id, User> getUserIdsMap,
                                     Id fetchTechnicalRecordTypeId){
        List<Case> caseToCreate = new List<Case>();
        for(Id oppId : opportunityIds){
            Case technicalCase = new Case();
            technicalCase.RecordTypeId = fetchTechnicalRecordTypeId;
            technicalCase.Opportunity__c = oppId;
            technicalCase.Subject = System.Label.Technicalissue;
            technicalCase.Technical_User__c = false;
            setTechnicalEngineer(technicalCase, oppId, oppTeamUserIds, getUserIdsMap);
            caseToCreate.add(technicalCase);
        }
        insertCases(caseToCreate);
    }
    
    private static void setTechnicalEngineer(Case technicalCase,
                                             Id oppId,
                                             Map<Id, Id> oppTeamUserIds,
                                             Map<Id, User> getUserIdsMap){
        if(oppTeamUserIds.containsKey(oppId)){
            Id technicalEngineerUserId = oppTeamUserIds.get(oppId);
            if(getUserIdsMap.containsKey(technicalEngineerUserId) &&
               getUserIdsMap.get(technicalEngineerUserId).IsActive){
                technicalCase.OwnerId = technicalEngineerUserId;
                technicalCase.Technical_User__c = true;
            }
        }
    }
    
    private static void insertCases(List<Case> caseToCreate){
        List<Case> casesWithTechnicalUser  = new List<Case>();
        List<Case> casesForAssignmentRules  = new List<Case>();
        for(Case technicalCase : caseToCreate){
            if(technicalCase.Technical_User__c){
                casesWithTechnicalUser .add(technicalCase);
            }else{
                casesForAssignmentRules .add(technicalCase);
            }
        }
        try{
            if(!casesWithTechnicalUser .isEmpty()){
                Database.insert(casesWithTechnicalUser , false);
            }
            if(!casesForAssignmentRules .isEmpty()){
                Database.DMLOptions dmlOpts = new Database.DMLOptions();
                dmlOpts.assignmentRuleHeader.useDefaultRule = true; 
                Database.insert(casesForAssignmentRules , dmlOpts);
            }
        }
        catch(Exception ex){
            System.debug('Error: '+ex.getMessage());
        }
    }
}