public class AccountUserClass {
    public static void processAccount(){
        Account acc = new Account(Name= 'Future Account');
        try{
            insert acc;
        }catch(dmlException e){
            system.debug('A dml error occurs: '+e.getMessage());
        }
        updateUserDepartment('nidibrolurevanth@agentforce.com');
    }
    @future
    public static void updateUserDepartment(String username){
        List<User> userList = [SELECT
                              Id,
                              IsActive,
                              Username,
                              Department
                              FROM User
                              WHERE
                              UserName = :username];
        for(User ur : userList){
            ur.Department = 'Account Owner';
        }
        try{
            update userList;
        }catch(dmlException e){
            system.debug('A dml error Occurs: '+e.getMessage());
        }
    }
}