public class DynamicRelatedRecords {
    @AuraEnabled(cacheable=true)
    public static List<SObject> getRelatedRecords(Id parentId, String childObjectApiName, 
                                                  String childObjectFieldApiNames,
                                                  String childParentFieldApiName){
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        Schema.SObjectType childObjectType = globalDescribe.get(childObjectApiName);
        Schema.DescribeSObjectResult childDescribe = childObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = childDescribe.fields.getMap();
        Schema.DescribeFieldResult parentFieldDescribe = fieldMap.get(childParentFieldApiName).getDescribe();
        List<String> requestedFields = new List<String>();
        for(String fieldName : childObjectFieldApiNames.split(',')) {
            fieldName = fieldName.trim();
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
            requestedFields.add(fieldName);
        }
        if (!requestedFields.contains('Id')) {
            requestedFields.add('Id');
        }
        String query = 'SELECT '+ String.join(requestedFields, ', ') +
                       ' FROM ' + childObjectApiName +
                       ' WHERE ' + childParentFieldApiName +' = :parentId';
        return Database.query(query);
    }
}