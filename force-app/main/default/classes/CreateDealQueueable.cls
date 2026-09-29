public class CreateDealQueueable implements Queueable{
    set<Id> oppIds;
    public CreateDealQueueable(set<Id> oppIds){
        this.oppIds = oppIds;
    }
    public void execute(QueueableContext qc){
        List<Opportunity> oppList = [SELECT
                                    Id,
                                    Name,
                                    Amount
                                    FROM Opportunity
                                    WHERE
                                    Id IN : oppIds];
        List<Deal__c> newDeal = new List<Deal__c>();
        for(Opportunity opp : oppList){
            newDeal.add(new Deal__c(
            Name = opp.Name + ' Deal',
            Opportunity__c = opp.Id,
            Amount__c = opp.Amount));
        }
        if(!newDeal.isEmpty()){
            insert newDeal;
        }
        system.enqueueJob(new CreateTasksQueueable(oppIds));
    }
}