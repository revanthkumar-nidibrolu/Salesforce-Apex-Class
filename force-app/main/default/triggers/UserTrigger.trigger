trigger UserTrigger on User (after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        userHandler.updateOpportunityOwner(Trigger.new, Trigger.oldMap);
    }
}