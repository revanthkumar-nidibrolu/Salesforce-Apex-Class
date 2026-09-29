public class AccountHandler {
    public static void accountindustry(List<Account> accountlist){
        for(Account acct : accountlist){
            if(acct.Industry == null || acct.Industry == 'Media'){
                acct.Rating = 'Hot';
            }
        }
    }
    
    public static void copyAddress(List<Account> shippingAddress,Map<Id, Account>oldMap){
        for(Account addr : shippingAddress){
            if(oldMap == Null || oldMap != Null &&
               addr.Same_as_Billing_Address__c == true &&
               oldMap.get(addr.Id).Same_as_Billing_Address__c == False){
                   addr.ShippingCity = addr.BillingCity;
                   system.debug('City: '+addr.BillingCity);
                   addr.ShippingCountryCode = addr.BillingCountryCode;
                   system.debug('Country: '+addr.BillingCountryCode);
                   addr.ShippingStateCode = addr.BillingStateCode;
                   system.debug('State: '+addr.BillingStateCode);
                   addr.ShippingStreet = addr.BillingStreet;
                   system.debug('Street: '+addr.BillingStreet);
                   addr.ShippingPostalCode = addr.BillingPostalCode;
                   system.debug('PinCode: '+addr.BillingPostalCode);
            }
        }
    }
    
    public static void createContact(List<Account> newAccount){
        List<Contact> conList = new List<Contact>();
        for(Account acc : newAccount){
            Contact con = new Contact();
            con.LastName = acc.Name;
            con.AccountId = acc.Id;
            conList.add(con);
        }
        if(!ConList.isEmpty()){
            insert conList;
        }
    }
    
    public static void createOpportunity(List<Account> newAccount){
        List<Opportunity> oppoList = new List<Opportunity>();
        for(Account acct : newAccount){
            Opportunity opps = new Opportunity();
            opps.Name = acct.Name;
            opps.AccountId = acct.Id;
            opps.StageName = 'Value Proposition';
            opps.CloseDate = System.today();
            opps.Amount = 1253;
            opps.Type = 'Existing Customer - Upgrade';
            oppoList.add(opps);
        }
        if(!OppoList.isEmpty()){
            insert oppoList;
        }
    }
    
    public static void oppoContCreation(List<Account> accList){
        List<Opportunity> oppoList = new List<Opportunity>();
        List<Contact> conList = new List<Contact>();
        for(Account acc : accList){
            if(acc.Opportunity__c == True){
                Opportunity oppo = new Opportunity();
                oppo.AccountId = acc.Id;
                oppo.Name = acc.Name;
                oppo.StageName = 'Needs Analysis';
                oppo.CloseDate = system.today();
                oppo.Amount = 12455;
                oppo.Type = 'Existing Customer - Replacement';
                oppoList.add(oppo);
            }
            if(acc.Contact__c == True){
                Contact con = new Contact();
                con.AccountId = acc.Id;
                con.LastName = acc.Name;
                conList.add(con);
            }
            if(!conList.isEmpty()){ 
                insert conList;
            }
            if(!oppoList.isEmpty()){
                insert oppoList;
            }
        }
    }
    
    public static void updateDescription(List<Account> accList, map<Id, Account> oldMap){
        for(Account acc : accList){
            if(acc.Phone != oldMap.get(acc.Id).Phone){
                acc.Description = 'Phone Number is Update Old value is: '+oldMap.get(acc.Id).Phone+' and new value is: '+acc.Phone;
            }
        }
    }
    
    public static void annualRevenueApproval(List<Account> newAccount, map<Id, Account> oldMap){
        for(Account acc : newAccount){
            if(oldMap == Null || oldMap != Null && acc.AnnualRevenue != Null && acc.AnnualRevenue <= 10000 && acc.AnnualRevenue != oldMap.get(acc.Id).AnnualRevenue){
                Approval.processSubmitRequest req = new Approval.processSubmitRequest();
                req.setObjectId(acc.Id);
                req.setComments('Automatically submittted for Approval process.');
                Approval.Process(req);	
            }
        }
    }
    
    public static void sendEmailOwnerAndManager(List<Account> accList, Map<Id, Account> oldMap){
        List<Account> appAccount = new List<Account>();
        set<Id> ownerIds = new set<Id>();
        for(Account acc : accList){
            Account oldAcc = oldMap.get(acc.Id);
            if(acc.Manager_Approval__c != Null && acc.Manager_Approval__c == 'Approved' && oldAcc.Manager_Approval__c != 'Approved'){  
                ownerIds.add(acc.OwnerId);
                appAccount.add(acc);
            }
        }
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate eT = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Annual_Revenue_Approvel_Email'];
        Map<Id, User> newMap = new Map<Id, User>([SELECT 
                                                  Id, 
                                                  Email, 
                                                  Manager.Email 
                                                  FROM User 
                                                  WHERE Id IN :ownerIds]);
        List<String> sendTo = new List<String>();
        for(Account acc : appAccount){
            User owner = newMap.get(acc.OwnerId); 
            sendTo.add(owner.Email);
            sendTo.add(owner.Manager.Email);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(sendTo);
            mail.setTemplateId(eT.Id);
            mail.setTargetObjectId(owner.Id); 
            mail.setSaveAsActivity(false);
            mails.add(mail);
        }
        if(!mails.isEmpty()){
            Messaging.sendEmail(mails);
        }
    }
    
    public static void accOppDelDelprodDelitem(List<Account> newAccounts, Map<Id, Account>oldMap){
        set<Id> accIds = new set<Id>();
        for(Account acc : newAccounts){
            if(acc.Active__c && acc.Phone != oldMap.get(acc.Id).Phone){
                accIds.add(acc.Id);
            }
        }
        Map<Id, Opportunity> accountOpp = getLatestClosedWonOpportunity(accIds);
        if(accountOpp.isEmpty()){
            return;
        }
        Map<Id, Deal__c> oppDeal = getDeal(accountOpp);
        if(oppDeal.isEmpty()){
            return;
        }
        Map<Id, Deal_Product__c> dealProd = getDealProd(oppDeal);
        if(dealProd.isEmpty()){
            return;
        }
        List<Deal_Item__c> newDealItem = createDealItem(newAccounts, accountOpp, oppDeal, dealProd);
        if(!newDealItem.isEmpty()){
            insert newDealItem;
        }
    }
    
    private static Map<Id, Opportunity> getLatestClosedWonOpportunity (Set<Id> accIds){
        List<Opportunity> oppList = [SELECT 
                                     Id, 
                                     AccountId, 
                                     Amount, 
                                     CloseDate
                                     FROM Opportunity
                                     WHERE AccountId IN :accIds
                                     AND StageName = 'Closed Won'
                                     ORDER BY 
                                     CloseDate DESC 
                                     LIMIT 1];
        Map<Id, Opportunity> accountOpp = new Map<Id, Opportunity>();
        for(Opportunity opp : oppList){
            if(!accountOpp.containsKey(opp.AccountId)){
                accountOpp.put(opp.AccountId, opp);
            }
        }
        return accountOpp;
    }
    
    private static Map<Id, Deal__c> getDeal (Map<Id, Opportunity> accountOpp){
        List<Deal__c> dealList = [SELECT 
                                  Id,
                                  Opportunity__c, 
                                  Amount__c 
                                  FROM Deal__c
                                  WHERE Opportunity__c IN : accountOpp.values()
                                  AND Amount__c >= 10000];
        Map<Id, Deal__c> oppDeal = new Map<Id, Deal__c>();
        for(Deal__c del : dealList){
            if(!oppDeal.containsKey(del.Opportunity__c)){
                oppDeal.put(del.Opportunity__c, del);
            }
        }
        return oppDeal;
    }
    
    private static Map<Id, Deal_Product__c> getDealProd (Map<Id, Deal__c> oppDeal){
        List<Deal_Product__c> delProdList = [SELECT 
                                             Id,
                                             Deal__c 
                                             FROM Deal_Product__c
                                             WHERE Deal__c IN : oppDeal.values()];
        Map<Id, Deal_Product__c> dealProd = new Map<Id, Deal_Product__c>();
        for(Deal_Product__c dP : delProdList){
            If(!dealProd.containsKey(dP.Deal__c)){
                dealProd.put(dP.Deal__c, dP);
            }
        }
        return dealProd;
    }
    
    private static List<Deal_Item__c> createDealItem (List<Account> newAccounts, 
                                                      Map<Id, Opportunity> accountOpp,
                                                      Map<Id, Deal__c> oppDeal, 
                                                      Map<Id, Deal_Product__c> dealProd){
        List<Deal_Item__c> newDealItem = new List<Deal_Item__c>();
        for(Account acc : newAccounts){
            Opportunity opp = accountOpp.get(acc.Id);
            Deal__c del = oppDeal.get(opp.Id);
            Deal_Product__c prodId = dealProd.get(del.Id);
            Deal_Item__c dT = new Deal_Item__c();
            dT.Name = acc.Name;
            dT.Amount__c = opp.Amount;
            dT.Phone__c = acc.Phone;
            dT.Deal_Product__c = prodId.Id;
            newDealItem.add(dT);
        }
        return newDealItem;	
    }
    
    public static void beforeInsert(List<Account> newAccounts) {
        validateAccounts(newAccounts);
        setDefaultIndustry(newAccounts);
    }
    
    private static void validateAccounts(List<Account> accounts) {
        for(Account acc : accounts){
            if(acc.Phone == null){
                acc.addError('Account Phone is required.');
            }
        }
    }
    
    public static void setDefaultIndustry(List<Account> accounts) {
        for(Account acc : accounts){
            if(acc.Industry == null){
                acc.Industry = 'Technology';
            }
        }
    }
    
    public static void accInActiveDeactiveBothBankAndCreditCard(List<Account> accList, Map<Id, Account>oldMap){
        set<Id> accIds = new set<Id>();
        for(Account acc : accList){
            Account oldAcc = oldMap.get(acc.Id);
            if(!acc.Active__c && oldAcc.Active__c){
                accIds.add(acc.Id);
            }
        }
        List<Bank__c> bankList = getBanks(accIds);
        set<Id> bankIds = new set<Id>();
        for(Bank__c bank : bankList){
            bank.Status__c = 'InActive';
            bankIds.add(bank.Id);
        }
        if(!bankList.isEmpty()){
            Update bankList;
        }
        List<Credit_Card__c> cardList = getCreditCard(bankIds);
        for(Credit_Card__c card : cardList){
            card.Status__c = 'InActive';
        }
        if(!cardList.isEmpty()){
            Update cardList;
        }
    }
    private static List<Bank__c> getBanks(Set<Id> accIds){
        return [SELECT 
                Id,
                Account__c,
                Status__c
                FROM Bank__c
                WHERE Account__c IN :accIds
                AND Status__c = 'Active'];
    }
    private static List<Credit_Card__c> getCreditCard(set<Id> bankIds){
        return [SELECT
               Id,
               Bank__c,
               Status__c
               FROM Credit_Card__c
               WHERE Bank__c IN : bankIds
               AND Status__c = 'Active'];
    }
    public static void updatingDates(List<Account> newAccounts){
        for(Account acc : newAccounts){
            acc.system_date__c = system.today();
            acc.User_Date__c = Date.Today();
        }
    }
    
    public static void welcomeAccountTask(List<Account> newAccount){
        List<Task> welcomeTask = new List<Task>();
        for(Account acc : newAccount){
            Task t = new Task();
            t.Subject = 'Welcome to Account';
            t.Status = 'New';
            t.Priority = 'Normal';
            t.WhatId = acc.Id;
            welcomeTask.add(t);
        }
        if(!welcomeTask.isEmpty()){
            insert welcomeTask;
        }
    }    
    
    public static void deleteMatchingOppTeamMembers(List<Account> oldAccounts){
        Set<Id> accountIds = new Set<Id>();
        for(Account acc : oldAccounts){
            accountIds.add(acc.Id);
        }
        Map<Id, Set<Id>> accountTeamUsers = new Map<Id, Set<Id>>();
        List<AccountTeamMember> accTeamMemb = accountTeamMemb(accountIds);
        for(AccountTeamMember atm : accTeamMemb){
            if(!accountTeamUsers.containsKey(atm.AccountId)){
                accountTeamUsers.put(atm.AccountId, new Set<Id>());
            }
            accountTeamUsers.get(atm.AccountId).add(atm.UserId);
        }
        List<OpportunityTeamMember> oppTeamMembersToDelete = new List<OpportunityTeamMember>();
        List<OpportunityTeamMember> otmToDelete = opportunityTeamMemb(accountIds);
        for(OpportunityTeamMember otm : otmToDelete) {
            Set<Id> accountUsers = accountTeamUsers.get(otm.Opportunity.AccountId);
            if(accountUsers != null && accountUsers.contains(otm.UserId)){
                oppTeamMembersToDelete.add(otm);
            }
        }
        if(!oppTeamMembersToDelete.isEmpty()){
            delete oppTeamMembersToDelete;
        }
    }
    private static List<AccountTeamMember> accountTeamMemb (set<Id> accountIds){
        return [SELECT
                AccountId,
                UserId,
                TeamMemberRole
                FROM AccountTeamMember
                WHERE
                AccountId IN : accountIds];
    }
    private static List<OpportunityTeamMember> opportunityTeamMemb (set<Id> accountIds){
        return [SELECT
               Id,
               UserId,
               TeamMemberRole,
               OpportunityId,	
               Opportunity.AccountId
               FROM OpportunityTeamMember
               WHERE
               Opportunity.AccountId IN : accountIds];
    }
    
    public static void accountTypeUpdate(List<Account> accList){
        List<Account> updateList = new List<Account>();
        for(Account acc : accList){
            acc.Type = 'Installation Partner';
            acc.Description = 'Account Type update as Installation Partner.';
            updateList.add(acc);
        }
        if(!updateList.isEmpty()){
            try{
                update updateList;
            }catch(Exception e){
                system.debug('Error: '+e.getMessage());
            }
        }
    }
}