trigger AccountTrigger on Account (before insert, before update, after insert, after update, after delete) {
    if(Trigger.isInsert && Trigger.isBefore){
       // AccountHandler.accountindustry(Trigger.New);
        AccountHandler.copyAddress(Trigger.New, Null);
       // AccountHandler.beforeInsert(Trigger.New);
       // AccountHandler.updatingDates(Trigger.New);
    }
    if(Trigger.isUpdate && Trigger.isBefore){
       // AccountHandler.copyAddress(Trigger.New, Trigger.oldMap);
       // AccountHandler.updateDescription(Trigger.New, Trigger.oldMap);
    }
    if(Trigger.isInsert && Trigger.isAfter){
       // AccountHandler.createContact(Trigger.New);
       // AccountHandler.createOpportunity(Trigger.New);
       // AccountHandler.oppoContCreation(Trigger.New);
       // AccountHandler.annualRevenueApproval(Trigger.New, Null);
        DailyRecordsHandler.todayRecords(Trigger.New);
        
    }
    if(Trigger.isUpdate && Trigger.isAfter){
       // AccountHandler.annualRevenueApproval(Trigger.New, Trigger.oldMap);
       // AccountHandler.sendEmailOwnerAndManager(Trigger.New, Trigger.oldMap);
       // AccountHandler.accOppDelDelprodDelitem(Trigger.New, Trigger.oldMap);
       // AccountHandler.accInActiveDeactiveBothBankAndCreditCard(Trigger.New, Trigger.oldMap);

    }
    if(Trigger.isDelete && Trigger.isAfter){
       // AccountHandler.deleteMatchingOppTeamMembers(Trigger.old);
    }
}