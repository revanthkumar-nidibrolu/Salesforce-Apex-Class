trigger CaseTrigger on Case (before insert, before update, after insert, after update) {
    if(Trigger.isInsert && Trigger.isAfter){
       // CaseHandler.accountFiledUpdate(Trigger.New);
       // CaseHandler.copyOppoTeamToCaseTeam(Trigger.New);
       // DailyRecordsHandler.todayRecords(Trigger.New);
    }
    if(Trigger.isInsert && Trigger.isBefore){
       // CaseHandler.casesLessThenFive(Trigger.New);
       // CaseHandler.accountCaseMoreThenTen(Trigger.New);
    }
    if(Trigger.isUpdate && Trigger.isBefore){
       // CaseHandler.caseOpportunityUpdate(Trigger.New, Trigger.oldMap);
       // CaseHandler.caseClosedOpportunitySalesManagerPresent(Trigger.New, Trigger.oldMap);
    }
}