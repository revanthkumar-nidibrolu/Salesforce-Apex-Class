public class InvocableMethodOnAccount {
    @InvocableMethod(label = 'Update Opportunity Amount')
    public static void updateOpportunityAmount(List<Id> accountIds){
        List<Opportunity> oppList = [SELECT
                                    Id,
                                    Name,
                                    AccountId,
                                    Amount
                                    FROM Opportunity
                                    WHERE
                                    AccountId IN : accountIds];
        for(Opportunity opp : oppList){
            opp.Amount = 100000;
        }
        if(!oppList.isEmpty()){
            update oppList;
        }
    }
}