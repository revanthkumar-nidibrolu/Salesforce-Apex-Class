trigger OpportunityTrigger on Opportunity (before insert, before update, after insert, after update, after delete) {
    if(Trigger.isInsert && Trigger.isBefore){
       // OpportunityHandler.updatefield(Trigger.New);
       // OpportunityHandler.discUpdate(Trigger.New);
       // OpportunityHandler.oppoClosedDate(Trigger.New);
       // OpportunityHandler.targetAmountToOppoAmount(Trigger.New);
       // OpportunityHandler.accountAssignBasedOnRegion(Trigger.New, Null);
        OpportunityHandler.validateAccountTeams(Trigger.New);
    }
    if(Trigger.isInsert && Trigger.isAfter){
       // OpportunityHandler.caseCreation(Trigger.New);
       // OpportunityHandler.recentOpportunityAmount(Trigger.New);
       // OpportunityHandler.oppoAmountUpdateOnAnnualRevenue(Trigger.New);
       // OpportunityHandler.OppoClosedWonCreateDeal(Trigger.New, Null);
       // OpportunityHandler.AccountToOpportunity(Trigger.New);
       // OpportunityHandler.oppoStartAndEndDatesDealCreation(Trigger.New);
       // OpportunityHandler.OpportunityTeamCreation(Trigger.New);
       // OpportunityHandler.opportunityCaseCreation(Trigger.New, Null);
       // OpportunityClosedWonScheduleClass.scheduleJob();
       // OpportunityHandler.handleAfterUpdate(Trigger.New, Null);
       // OpportunityHandler.updateAccountAnnualRevenue(Trigger.New, Null);
       // DailyRecordsHandler.todayRecords(Trigger.New);
        OpportunityHandler.createOpportunityTeams(Trigger.New);
        OpportunityHandler.createCase(Trigger.New, Null);
    }
    if(Trigger.isUpdate && Trigger.isAfter){
       // OpportunityHandler.OppoClosedWonCreateDeal(Trigger.New, Trigger.oldMap);
       // OpportunityHandler.opportunityCaseCreation(Trigger.New, Trigger.oldMap);
       // OpportunityHandler.handleAfterUpdate(Trigger.New, Trigger.oldMap);
       // OpportunityHandler.updateAccountAnnualRevenue(Trigger.New, Trigger.oldMap);
       // OpportunityHandler.opportunityValuePropositionApproval(Trigger.New, Trigger.oldMap);
       // OpportunityHandler.opportunityClosedCaseCreation(Trigger.New, Trigger.oldMap);
        OpportunityHandler.createCase(Trigger.New, Trigger.oldMap);
    }
    if(Trigger.isUpdate && Trigger.isBefore){
       // OpportunityHandler.caseClosedOppoClosedWon(Trigger.New, Trigger.oldMap);
       // OpportunityHandler.accountAssignBasedOnRegion(Trigger.New, Trigger.oldMap);
       // OpportunityHandler.opportunityValueProposition(Trigger.New, Trigger.oldMap);
        OpportunityHandler.validateAccountTeams(Trigger.New);
    }
    if(Trigger.isDelete && Trigger.isAfter){
       // OpportunityHandler.updateAccountAnnualRevenue(Null, Trigger.oldMap);
    }
}