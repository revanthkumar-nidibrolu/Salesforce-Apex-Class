public class OpportunityClosedWonScheduleClass implements schedulable{
    public void execute(schedulablecontext sc){
        ClosedWonOpportunityBatchClass opportunityBatch = new ClosedWonOpportunityBatchClass();
        Database.executeBatch(opportunityBatch);
        OpportunityRelatedCasesClosedBatchClass caseBatch = new OpportunityRelatedCasesClosedBatchClass();
        Database.executeBatch(caseBatch);
    }
    public static void scheduleJob(){
        String conTime = '0 00 19 * * ?';
        system.schedule('Daily opportunity and cases update at 07:00 PM', conTime, new OpportunityClosedWonScheduleClass());
    }
}