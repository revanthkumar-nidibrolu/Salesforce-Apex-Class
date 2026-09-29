trigger TaskTrigger on Task (before insert, before update, after insert, after update) {
    if(Trigger.isInsert && Trigger.isBefore){
        TaskHandler.updatePriorityaccToOpportunityAmount(Trigger.New, Null);
    }
    if(Trigger.isUpdate && Trigger.isBefore){
        TaskHandler.updatePriorityaccToOpportunityAmount(Trigger.New, Trigger.oldMap);
    }
}