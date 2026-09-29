public without sharing class AccountTeamHandler {
    public static void opportunityOwnerAccountManager(List<AccountTeamMember> newList, Map<Id, AccountTeamMember> oldMap){
        Set<Id> accountIds = getAccountIds(newList, oldMap);
        Map<Id, Opportunity> accountOppMap = getAccountOpportunityMap(accountIds);
        Map<Id, Id> accountManagerMap = getAccountManagerMap(accountIds);
        createOpportunities(accountIds, accountOppMap, accountManagerMap);
    }
    
    private static set<Id> getAccountIds(List<AccountTeamMember> newList, Map<Id, AccountTeamMember> oldMap){
        Set<Id> accountIds = new Set<Id>();
        If(newList != null){
            for(AccountTeamMember atm : newList){
                if(oldMap == null && atm.TeamMemberRole == ConstantsClass.Account_Manager_Role){
                    accountIds.add(atm.AccountId);
                }
                else if(oldMap != null && 
                        (atm.TeamMemberRole == ConstantsClass.Account_Manager_Role || 
                         oldMap.get(atm.Id).TeamMemberRole == ConstantsClass.Account_Manager_Role)){
                    accountIds.add(atm.AccountId);      
                }
            }
        }
        else if(oldMap != null){
            for(AccountTeamMember atm : oldMap.values()){
                if(atm.TeamMemberRole == ConstantsClass.Account_Manager_Role){
                    accountIds.add(atm.AccountId);
                }
            }
        }
        return accountIds;
    }
    
    private static Map<Id, Opportunity> getAccountOpportunityMap(set<Id> accountIds){
        Map<Id, Opportunity> accountOppMap = new Map<Id, Opportunity>();
        List<Opportunity> oppList = oppoLists(accountIds);
        for(Opportunity opp : oppList){
            accountOppMap.put(opp.AccountId, opp);
        }
        return accountOppMap;
    }
    
    private static List<Opportunity> oppoLists (set<Id> accountIds){
        return [SELECT Id,
                       AccountID,
                       OwnerId,
                       Account_Manager_Opportunity__c
               FROM Opportunity
               WHERE
                    AccountId IN : accountIds
               AND
                    Account_Manager_Opportunity__c = True];
    }
    
    private static Map<Id, Id> getAccountManagerMap (set<Id> accountIds){
        Map<Id, Id> accountManagerMap = new Map<Id, Id>();
        List<AccountTeamMember> accTeam = accTeamMemb(accountIds);
        for(AccountTeamMember atm : accTeam){
            if(!accountManagerMap.containsKey(atm.AccountId)){
                accountManagerMap.put(atm.AccountId, atm.UserId);
            }
        }
        return accountManagerMap;
    }
    
    private static List<AccountTeamMember> accTeamMemb (set<Id> accountIds){
        return [SELECT Id,
                       AccountId,
                       UserId,
                       TeamMemberRole,
                       CreatedDate
               FROM AccountTeamMember
               WHERE
                    AccountId IN :accountIds
               AND 
                    TeamMemberRole = :ConstantsClass.Account_Manager_Role
               ORDER BY CreatedDate ASC];
    }
    
    private static void createOpportunities(set<Id> accountIds, Map<Id, Opportunity> accountOppMap, Map<Id, Id> accountManagerMap){
        List<Opportunity> oppInsert = new List<Opportunity>();
        List<Opportunity> oppUpdate = new List<Opportunity>();
        for(Id accId : accountIds){
            if(accountManagerMap.containsKey(accId)){
                Id accountManagerId = accountManagerMap.get(accId);
                if(accountOppMap.containsKey(accId)){
                    Opportunity opp = accountOppMap.get(accId);
                    if(opp.OwnerId != accountManagerId){
                        opp.OwnerId = accountManagerId;
                        oppUpdate.add(opp);
                    }
                }
                else{
                    Opportunity opp = new Opportunity();
                    opp.Name = 'Account Manager Opportunity';
                    opp.AccountId = accId;
                    opp.OwnerId = accountManagerId;
                    opp.StageName = ConstantsClass.Stage_Qualification;
                    opp.CloseDate = Date.today().addDays(30);
                    opp.Account_Manager_Opportunity__c = true;
                    opp.Amount = 5628;
                    opp.Type = 'Existing Customer - Replacement';
                    oppInsert.add(opp);
                }
            }
        }
        if(!oppInsert.isEmpty()){
            try{
                insert oppInsert;
            }catch(Exception e){
                system.debug('Error: '+e.getMessage());
            }
        }
        if(!oppUpdate.isEmpty()) {
            try{
                update oppUpdate;
            }catch(Exception e){
                system.debug('Error: '+e.getMessage());
            }
        }
    }
    
    public static void createAndUpdateAccountTeamHistory(List<AccountTeamMember> newMember, Map<Id, AccountTeamMember>oldMap){
        List<AccountTeamMember> teamRecords = new List<AccountTeamMember>();
        Set<Id> teamMemberIds = new Set<Id>();
        for(AccountTeamMember atm : newMember){
            if(oldMap == null){
                teamRecords.add(atm);
            }
            else if(atm.UserId != oldMap.get(atm.Id).UserId || 
                atm.TeamMemberRole != oldMap.get(atm.Id).TeamMemberRole){
                teamRecords.add(atm);
                teamMemberIds.add(atm.Id);
            }
        }
        if(teamRecords.isEmpty()){
            return;
        }
        List<Account_Team_History__c> historiesToUpdate = new List<Account_Team_History__c>();
        String currentQuarter = getCurrentQuarter();
        if(oldMap != null && !teamMemberIds.isEmpty()) {
            List<Account_Team_History__c> existingHistories = existingRecords(teamMemberIds);
            Map<String, Account_Team_History__c> historyByTeamMemberId = new Map<String, Account_Team_History__c>();
            for (Account_Team_History__c history : existingHistories) {
                historyByTeamMemberId.put(history.Account_Team_Member_Id__c, history);
            }
            historiesToUpdate = historiesToUpdate(teamRecords, historyByTeamMemberId);
        }
        List<Account_Team_History__c> historiesToInsert = historiesToInsert(teamRecords, currentQuarter);
        if (!historiesToUpdate.isEmpty()) {
            update historiesToUpdate;
        }
        if (!historiesToInsert.isEmpty()) {
            insert historiesToInsert;
        }
    }
    
    private static List<Account_Team_History__c> historiesToInsert(List<AccountTeamMember> teamRecords,
                                                                          String currentQuarter) {
        List<Account_Team_History__c> insertHistory = new List<Account_Team_History__c>();
        for (AccountTeamMember atm : teamRecords) {
            insertHistory.add(new Account_Team_History__c(
                Account__c = atm.AccountId,
                User__c = atm.UserId,
                Role__c = atm.TeamMemberRole,
                Current_Quarter__c = currentQuarter,
                Account_Team_Member_Id__c = String.valueOf(atm.Id)
            ));
        }
        return insertHistory;
    }
    
    private static List<Account_Team_History__c> historiesToUpdate(List<AccountTeamMember> teamRecords,
                                                                          Map<String, Account_Team_History__c> historyByTeamMemberId){
        List<Account_Team_History__c> updateHistory = new List<Account_Team_History__c>();
        for (AccountTeamMember atm : teamRecords) {
            String teamMemberId = String.valueOf(atm.Id);
            if (historyByTeamMemberId.containsKey(teamMemberId)) {
                Account_Team_History__c oldHistory = historyByTeamMemberId.get(teamMemberId);
                oldHistory.Delete__c = true;
                oldHistory.Changed_User__c = UserInfo.getUserId();
                oldHistory.Closed_Date__c = Date.today();
                updateHistory.add(oldHistory);
            }
        }
        return updateHistory;
    }
    
    public static void deleteAccountTeamHistory(List<AccountTeamMember> oldMembers){
        Set<Id> teamMemberIds = new set<Id>();
        for(AccountTeamMember atm : oldMembers){
            teamMemberIds.add(atm.Id);
        }
        if(teamMemberIds.isEmpty()){
            return;
        }
        List<Account_Team_History__c> existingHistory = existingRecords(teamMemberIds);
        for(Account_Team_History__c history : existingHistory){
            history.Delete__c = true;
            history.Changed_User__c = UserInfo.getUserId();
            history.Closed_Date__c = Date.Today();
        }
        if(!existingHistory.isEmpty()){
            update existingHistory;
        }
    }
        
    private static List<Account_Team_History__c> existingRecords (Set<Id> teamMemberIds){
        return [SELECT Id,
                       Account__c,
                       Account_Team_Member_Id__c,
                       Changed_User__c,
                       Closed_Date__c,
                       User__c,
                       Role__c,
                       Quarter__c,
                       Delete__c
                FROM Account_Team_History__c
                WHERE Account_Team_Member_Id__c IN : teamMemberIds
                AND Delete__c = false];
    }
    
    private static String getCurrentQuarter(){
        Date todayDate = Date.today();
        integer year = todayDate.year();
        integer month = todayDate.month();
        Integer Quarter = ((month-1)/3) + 1;
        return 'Q' + Quarter + ' - ' + year;      
    }
    
    public static void userDepartment(List<AccountTeamMember> newMember, Map<Id, AccountTeamMember>oldMap){
        set<Id> userIds = new set<Id>();
        for(AccountTeamMember atm : newMember){
            if(atm.UserId != null){
                if((oldMap == null) || atm.TeamMemberRole != oldMap.get(atm.Id).TeamMemberRole){
                    userIds.add(atm.UserId);
                }
            }
        }
        if(userIds.isEmpty()){
            return;
        }
        Map<Id, User> usersMap = usersMap(userIds);
        List<ATR_user_department__mdt> atmMdt = userMdt();
        Map<String, set<String>> departmentRoles = new Map<String, set<String>>();
        for(ATR_user_department__mdt atmMdts : atmMdt){
            if(!departmentRoles.containsKey(atmMdts.Department__c)){
                departmentRoles.put(atmMdts.Department__c, new set<String>());
            }
            departmentRoles.get(atmMdts.Department__c).add(atmMdts.Team_Role__c);
        }
        for(AccountTeamMember atm : newMember){
            User currentUser = usersMap.get(atm.UserId);
            if(!departmentRoles.get(currentUser.Departments__c).contains(atm.TeamMemberRole)){
                atm.addError(system.label.userDepartmentAndAtmRolesNotMatched);
            }
        }
    }
    
    private static Map<Id, User> usersMap(Set<Id> userIds) {
        return new Map<Id, User>([SELECT Id, 
                                         Departments__c 
                                  FROM User 
                                  WHERE Id IN :userIds]);
    }
    
    private static List<ATR_user_department__mdt> userMdt(){
        return [SELECT Department__c,
                       Team_Role__c
                FROM ATR_user_department__mdt];
    }
    
    public static void dupicatesTeamsNotAlloweds(List<AccountTeamMember> newMember, Map<Id, AccountTeamMember> oldMap) {
        Set<Id> accountIds = new Set<Id>();
        Set<String> teamRoles = new Set<String>();
        accountIdsAndteamRoles(newMember, oldMap, accountIds, teamRoles);
        Map<String, Integer> existingRoleCount = new Map<String, Integer>();
        List<AccountTeamMember> atrMember = atmList (accountIds, teamRoles);
        for (AccountTeamMember atm : atrMember) {
            String key = atm.AccountId + '_' + atm.TeamMemberRole;
            if (!existingRoleCount.containsKey(key)) {
                existingRoleCount.put(key, 0);
            }
            existingRoleCount.put(key, existingRoleCount.get(key) + 1);
        }
        for (AccountTeamMember atm : newMember) {
            String key = atm.AccountId + '_' + atm.TeamMemberRole;
            if (existingRoleCount.containsKey(key) && existingRoleCount.get(key) > 0) {
                atm.addError('Duplicate ' + atm.TeamMemberRole + ' is not allowed for this Account.');
            }
        }
    }
    
    private static void accountIdsAndteamRoles(List<AccountTeamMember> newMember, Map<Id, AccountTeamMember> oldMap,
                                                  Set<Id> accountIds, Set<String> teamRoles){
        for (AccountTeamMember atm : newMember) {
            if (isDuplicateAllowedRole(atm.TeamMemberRole)) {
                continue;
            }
            if (oldMap == null || atm.TeamMemberRole != oldMap.get(atm.Id).TeamMemberRole){
                accountIds.add(atm.AccountId);
                teamRoles.add(atm.TeamMemberRole);
            }
        }
    }
    
    private static Boolean isDuplicateAllowedRole(String teamRole) {
        return ConstantsClass.Account_Manager_Role == teamRole ||
               ConstantsClass.Channel_Manager_Role == teamRole ||
               ConstantsClass.Executive_Sponsor_Role == teamRole;
    }
    
    private static List<AccountTeamMember> atmList (Set<Id> accountIds, Set<String> teamRoles){
        return [SELECT Id,
                       AccountId,
                       TeamMemberRole
                FROM AccountTeamMember
                WHERE AccountId IN :accountIds
                AND TeamMemberRole IN :teamRoles];
    }
}