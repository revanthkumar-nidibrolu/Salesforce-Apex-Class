trigger AccountTeamTrigger on AccountTeamMember (after insert, after update, after delete, before insert, before update) {
    if(Trigger.isInsert && Trigger.isAfter){
        //AccountTeamHandler.opportunityOwnerAccountManager(Trigger.New, null);
        AccountTeamHandler.createAndUpdateAccountTeamHistory(Trigger.New, null);
    }
    if(Trigger.isUpdate && Trigger.isAfter){
        //AccountTeamHandler.opportunityOwnerAccountManager(Trigger.New, Trigger.oldMap);
        AccountTeamHandler.createAndUpdateAccountTeamHistory(Trigger.New, Trigger.oldMap);
    }
    if(Trigger.isDelete && Trigger.isAfter){
        //AccountTeamHandler.opportunityOwnerAccountManager(null, Trigger.oldMap);
        AccountTeamHandler.deleteAccountTeamHistory(Trigger.old);
    }
    if(Trigger.isInsert && Trigger.isBefore){
        //AccountTeamHandler.userDepartment(Trigger.New, null);
        AccountTeamHandler.dupicatesTeamsNotAlloweds(Trigger.New, null);
    }
    if(Trigger.isUpdate && Trigger.isBefore){
        //AccountTeamHandler.userDepartment(Trigger.New, Trigger.oldMap);
        AccountTeamHandler.dupicatesTeamsNotAlloweds(Trigger.New, Trigger.oldMap);
    }
}