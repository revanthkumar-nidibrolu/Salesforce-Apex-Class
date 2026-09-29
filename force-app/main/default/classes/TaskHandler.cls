public class TaskHandler {
    public static void updatePriorityaccToOpportunityAmount(List<Task> taskList, Map<Id, Task> oldMap){
        set<Id> oppoIds = new set<Id>();
        for(Task ts : taskList){
            if(ts.WhatId != Null && String.valueOf(ts.WhatId).startsWith('006') && 
               (oldMap == Null || ts.WhatId != oldMap.get(ts.Id).WhatId)){
                oppoIds.add(ts.WhatId);
            }
        }
        if(oppoIds.isEmpty()){
            return;
        }
        Map<Id, Opportunity> oppoMap = new Map<Id, Opportunity>([SELECT
                                                                Id,
                                                                Amount
                                                                FROM Opportunity
                                                                WHERE Id IN : oppoIds]);
        if(oppoMap.isEmpty()){
            return;
        }
        for(Task ts : taskList){
            Opportunity oppo = oppoMap.get(ts.WhatId);
            if(oppo != Null && oppo.Amount != Null){
                if(oppo.Amount < 10000){
                    ts.Priority = 'Low';
                }
                else if(oppo.Amount <= 100000){
                    ts.Priority = 'Normal';
                }
                else{
                    ts.Priority = 'High';
                }
            }
        }
    }
}