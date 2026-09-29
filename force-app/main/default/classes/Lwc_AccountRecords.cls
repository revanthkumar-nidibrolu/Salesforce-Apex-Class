public class Lwc_AccountRecords {
    @AuraEnabled(cacheable = true)
    public static void accounts(Id recordId){
        if(recordId != null){
            delete [SELECT Id
                    FROM Account
                    WHERE Id = :recordId];
        }
    }
}