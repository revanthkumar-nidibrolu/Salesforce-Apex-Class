public class ClosedWonOpportunityBatchClass implements Database.Batchable<SObject>{
    public List<Id> listOfOppIds = new List<Id>();
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT 
                                         Id, 
                                         StageName 
                                         FROM Opportunity 
                                         WHERE 
                                         StageName != 'Closed Won']);
    }
    public void execute(Database.BatchableContext bc, List<Opportunity> oppList){  
        List<Opportunity> oppUpdate = new List<Opportunity>();
            for(Opportunity opp : oppList){
            opp.StageName = 'Closed Won';
            oppUpdate.add(opp);
            listOfOppIds.add(opp.Id);
        }	
        if(!oppUpdate.isEmpty()){
            try{
                update oppUpdate;
            }catch(dmlException e){
                system.debug('A dml error occurs '+e.getMessage());
            }
        }
    }
    public void finish (Database.BatchableContext bc){   
        system.debug('Opportunity batch complated');
        system.debug('list Of opportunity Ids: '+listOfOppIds);
    }
}