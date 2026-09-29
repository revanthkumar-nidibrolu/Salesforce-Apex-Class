public class SendingEmailOpportunityOwnerRelatedCases implements Database.Batchable<SObject>, Database.Stateful{
    Map<Id, List<Case>> opportunityCases = new Map<Id, List<Case>>();
    Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
    Public Database.QueryLocator Start (Database.BatchableContext bc){
        return Database.getQueryLocator ([SELECT
                                         Id,
                                         CaseNumber,
                                         Opportunity__c
                                         FROM Case
                                         WHERE
                                         Opportunity__c != Null]);
    }
    Public void execute(Database.BatchableContext bc, List<Case> caseList){
        system.debug(caseList);
        set<Id> opportunityIds = new set<Id>();
        for(Case c : caseList){
            opportunityIds.add(c.Opportunity__c);
            if(!opportunityCases.containsKey(c.Opportunity__c)){
                system.debug(c.Opportunity__r.Owner.Email);
                opportunityCases.put(c.Opportunity__c, new List<Case>());
            }
            opportunityCases.get(c.Opportunity__c).add(c);
        }
        List<Opportunity> opportunityList = [SELECT
                                            Id,
                                            Name,
                                            Owner.Email
                                            FROM Opportunity
                                            WHERE
                                            Id IN : opportunityIds];
        for(Opportunity opp : opportunityList){
            opportunityMap.put(opp.Id, opp);
        }
    }
    Public void finish(Database.BatchableContext bc){
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for(Opportunity opp : opportunityMap.Values()){
            List<Case> caseList = opportunityCases.get(opp.Id);
            if(caseList == Null || caseList.isEmpty()){
                continue;
            }
            String body = 'Dear Opportunity Owner,\n\n';
            body += 'Below are the Case Numbers related to your Opportunity:\n\n';
            for(Case cs : caseList){
                body += 'caseNumbers: ' + cs.CaseNumber + '\n';
            }
            body += '\nRegards,\nSalesforce Team.';
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{opp.Owner.Email});
            mail.setSubject('Linked Case of Opportunity -' + opp.Name);
            mail.setPlainTextBody(body);
            emails.add(mail);
        }
        if(!emails.isEmpty()){
            try{
                Messaging.sendEmail(emails);
            }catch(dmlException e){
                system.debug('A dml error occurs: '+e.getMessage());
            }
        }
        System.debug('Batch Completed Successfully');
    }
}