public with sharing class UserController {
    @AuraEnabled(cacheable=true)
    public static String userDepartment() {
        return [SELECT Departments__c
                FROM User 
                WHERE Id = :UserInfo.getUserId()].Departments__c;
    }
}