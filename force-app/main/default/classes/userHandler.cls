public class userHandler {
    public static void updateOpportunityOwner(List<User> userList, Map<Id, User> oldMap) {
        Map<Id, Id> userToManagerMap = new Map<Id, Id>();
        for (User u : userList) {
            if (u.IsActive == false && oldMap.get(u.Id).IsActive == true) {
                if (u.ManagerId != null) {
                    userToManagerMap.put(u.Id, u.ManagerId);
                }
            }
        }
        if (!userToManagerMap.isEmpty()) {
            reassignOpportunitiesAsync(userToManagerMap);
        }
    }
    @future
    private static void reassignOpportunitiesAsync(Map<Id, Id> userToManagerMap) {
        List <Opportunity> oppsToUpdate = [SELECT Id, 
                                                  OwnerId 
                                           FROM Opportunity 
                                           WHERE OwnerId IN :userToManagerMap.keySet()];
        for (Opportunity opp : oppsToUpdate) {
            opp.OwnerId = userToManagerMap.get(opp.OwnerId);
        }
        if (!oppsToUpdate.isEmpty()) {
            update oppsToUpdate;
        }
    }
}