public class OpportunityRelatedCasesClosedBatchClass implements Database.Batchable<SObject>, Database.Stateful{
    set<Id> ownerIds = new set<Id>();
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator ([SELECT
                                          Id,
                                          Status,
                                          Opportunity__c,
                                          Opportunity__r.OwnerId,
                                          Opportunity__r.StageName
                                          FROM Case
                                          WHERE
                                          Status != 'Closed'
                                          AND
                                          Opportunity__c != Null]);
    }
    public void execute(Database.BatchableContext bc, List<Case> caseList){
        List<Case> updateCases = new List<Case>();
        for(Case cs : caseList){
            if(cs.Opportunity__r.StageName == 'Closed Won'){
                cs.Status = 'Closed';
                updateCases.add(cs);
                if(cs.Opportunity__r.OwnerId != Null){
                    ownerIds.add(cs.Opportunity__r.OwnerId);
                }
            }
        }
        if(!updateCases.isEmpty()){
            try{
                update updateCases;
            }catch(dmlException e){
                system.debug('A dml error occurs: '+e.getMessage());
            }
        }
    }
    public void finish(Database.BatchableContext bc){
        EmailTemplate et = [SELECT 
                            Id
                            FROM EmailTemplate
                            WHERE 
                            DeveloperName = 'case_closed'];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();      
        for(Id oppOwnerId : ownerIds){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(oppOwnerId);
            mail.setTemplateId(et.Id);
            mail.setSaveAsActivity(false);
            emails.add(mail);
        }
        if(!emails.isEmpty()){
            try{
                Messaging.sendEmail(emails);
            }catch(dmlException e){
            system.debug('case status complated: ' + e.getMessage());
            }
        }
    }
}