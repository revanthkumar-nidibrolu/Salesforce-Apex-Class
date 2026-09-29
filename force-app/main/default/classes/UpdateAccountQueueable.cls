public class UpdateAccountQueueable implements Queueable{
    set<Id> oppIds;
    public UpdateAccountQueueable(set<Id> oppIds){
        this.oppIds = oppIds;
    }
    public void execute (Queueablecontext qc){
        List<Opportunity> oppList = [SELECT
                                    Id,
                                    Amount,
                                    AccountId
                                    FROM Opportunity
                                    WHERE
                                    Id IN : oppIds];
        set<Id> accIds = new set<Id>();
        for(Opportunity opp : oppList){
            if(opp.AccountId != Null){
                accIds.add(opp.AccountId);
            }
        }
        List<Account> accList = [SELECT
                                Id,
                                Name,
                                AnnualRevenue
                                FROM Account
                                WHERE
                                Id IN : accIds];
        for(Account acc : accList){
            acc.AnnualRevenue = 100000;
        }
        if(!accList.isEmpty()){
            try{
                update accList;
            }catch(dmlException e){
                system.debug('A dml error Occurs: '+e.getMessage());
            }
        }
        system.enqueueJob(new CreateDealQueueable(oppIds));
        system.debug('Queueable account update successfuly');
    }
}