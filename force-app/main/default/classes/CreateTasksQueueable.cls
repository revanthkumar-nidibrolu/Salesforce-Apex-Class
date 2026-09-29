public class CreateTasksQueueable implements Queueable{
    set<Id> oppIds;
    public CreateTasksQueueable (set<Id> oppIds){
        this.oppIds = oppIds;
    }
    public void execute(QueueableContext qc){
        List<Task> newTask = new List<Task>();
        for(Id oppId : oppIds){
            newTask.add(
                new Task(
                    Subject = 'Follow Up',
                    Status = 'Not Started',
                    Priority = 'Normal',
                    WhatId = oppId));
        }
        if(!newTask.isEmpty()){
            insert newTask;
        }
        system.enqueueJob(new SendEmailQueueable(oppIds));
    }
}