public class AccountWrapperInvocable {
    public class Input{
        @InvocableVariable(required=true)
        public Id accountId;
        @InvocableVariable
        public Decimal annualRevenue;
    }
    @InvocableMethod(label='Update Opportunity Amount')
    public static void processAccounts(List<Input> inputs){
        Set<Id> accIds = new Set<Id>();
        for(Input inp : inputs){
            if(inp.annualRevenue > 10000){
                accIds.add(inp.accountId);
            }
        }
        List<Opportunity> oppList = [
            SELECT Id, Amount
            FROM Opportunity
            WHERE AccountId IN :accIds];
        for(Opportunity opp : oppList){
            opp.Amount = 2000000;
        }
        update oppList;
    }
}