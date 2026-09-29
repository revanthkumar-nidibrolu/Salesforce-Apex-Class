trigger ContactTrigger on Contact (before insert, before update, after insert, after update, after delete, after undelete) {
    if(Trigger.isInsert && Trigger.isAfter){
        ContactHandler.contactsInsert(Trigger.New);
        ContactHandler.updateContact(Trigger.New);
        // DailyRecordsHandler.todayRecords(Trigger.New);
        DynamicTaskCreation.taskCreation(Trigger.New);
    }
    if(Trigger.isDelete && Trigger.isAfter){
        ContactHandler.contactsDelete(Trigger.old);
    }
    if(Trigger.isUpdate && Trigger.isAfter){
        ContactHandler.updateContact(Trigger.New);
        ContactHandler.contactsUpdate(Trigger.New, Trigger.oldMap);
    }
    if(Trigger.isUndelete && Trigger.isAfter){
        ContactHandler.contactsInsert(Trigger.New);
    }
}