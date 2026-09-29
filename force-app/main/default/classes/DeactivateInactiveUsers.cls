public class DeactivateInactiveUsers implements Schedulable {
    public void execute(SchedulableContext sc) {
        DateTime twoDaysAgo = DateTime.now().addDays(-2);
        List<User> Deactivate = [SELECT Id, 
                                               Name, 
                                               IsActive
                                          FROM User
                                         WHERE 
                                               IsActive = true
                                           AND 
                                               LastLoginDate < :twoDaysAgo];
        for (User u : Deactivate) {
            u.IsActive = false;
        }
        if(!Deactivate.isEmpty()) {
            Database.update(Deactivate, false);
        }
    }
}