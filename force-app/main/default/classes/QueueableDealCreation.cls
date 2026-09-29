public class QueueableDealCreation implements Queueable{
    Id dealId;
    public QueueableDealCreation(Id dealId){
        this.dealId = dealId;
    }
    public static void createDeal(List<Opportunity> oppList){
        List<Deal__c> deals = new List<Deal__c>();
        for(Opportunity opp : oppList){
            Deal__c del = new Deal__c();
            del.Name = opp.Name;
            del.Amount__c = opp.Amount;
            del.Opportunity__c = opp.Id;
            deals.add(del);
        }
        if(!deals.isEmpty()){
            try{
                insert deals;
                for(Deal__c del : deals){
                    system.enqueueJob(new QueueableDealCreation(del.Id));
                }
            }catch(Exception e){
                system.debug('Error: '+e.getMessage());
            }
        }
    }
    public void execute(QueueableContext qc){
        Deal_Item__c dt = new Deal_Item__c();
        dt.Name = 'Deal Item';
        dt.Deal__c = dealId;
        insert dt;
    }
}