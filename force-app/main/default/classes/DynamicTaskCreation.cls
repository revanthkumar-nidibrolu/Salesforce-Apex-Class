public class DynamicTaskCreation {
    public static void taskCreation(List<SObject> records){
        List<Task> newTask = new List<Task>();
        for(SObject rec : records){
            Task t = new Task();
            t.Subject = 'Follow up created record';
            t.Status = 'Not Started';
            t.Priority = 'Normal';
            Id recordId = (Id)rec.get('Id');
            Schema.SObjectType objType = recordId.getSObjectType();
            if(objType == Contact.SObjectType || objType == Lead.SObjectType){
                t.WhoId = recordId;
            }else{
                t.WhatId = recordId;
            }
            newTask.add(t);
        }
        if(!newtask.isEmpty()){
            insert newTask;
        }
    }
}