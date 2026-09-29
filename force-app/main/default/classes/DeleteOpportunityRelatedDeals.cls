public class DeleteOpportunityRelatedDeals implements Database.Batchable<SObject>{
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT
                                        Id,
                                        Opportunity__c
                                        FROM Deal__c
                                        WHERE
                                        Opportunity__c != Null]);
    }
    public void execute(Database.BatchableContext bc, List<Deal__c> dealList){
        if(!dealList.isEmpty()){
            try{
                delete dealList;
            }catch(dmlException e){
                system.debug('A dml error occurs: '+e.getMessage());
            }
        }
    }
    public void finish(Database.BatchableContext bc){
        system.debug('Opportunity related deal records delated.');
    }
}