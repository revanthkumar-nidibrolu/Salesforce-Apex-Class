public class DynamicRelatedRecordsController {
    @AuraEnabled(cacheable=true)
    public static List<SObject> getDynamicRecords(Id parentId, String childObjectApiName, String childFieldApiNames){
        Schema.SObjectType childType = Schema.getGlobalDescribe().get(childObjectApiName);
        Schema.DescribeSObjectResult describe = childType.getDescribe();
        Map<String, Schema.SObjectField> fields = describe.fields.getMap();
        List<String> requestedFields = parseFields(childFieldApiNames);
        List<String> validFields = new List<String>();
        for (String fieldName : requestedFields) {
            if (fields.containsKey(fieldName)) {
                validFields.add(fieldName);
            }
        }
        if (!validFields.contains('Id')) {
            validFields.add('Id');
        }
        String parentField = findParentLookupField(describe, parentId);
        String childObject = 'SELECT ' + String.join(validFields, ',') +
                             ' FROM ' + childObjectApiName +
                             ' WHERE ' + parentField + ' = :parentId';
        return Database.query(childObject);
    }
    
    @AuraEnabled(cacheable=true)
    public static List<SObject> getDynamicGrandchildRecords( Id parentId, String grandchildObjectApiName, String grandchildFieldApiNames){
        Schema.SObjectType childType = Schema.getGlobalDescribe().get(grandchildObjectApiName);
        Schema.DescribeSObjectResult describe = childType.getDescribe();
        Map<String, Schema.SObjectField> fields = describe.fields.getMap();
        List<String> requestedFields = parseFields(grandchildFieldApiNames);
        List<String> validFields = new List<String>();
        for(String fieldName : requestedFields) {
            if(fields.containsKey(fieldName)) {
                validFields.add(fieldName);
            }
        }
        if(!validFields.contains('Id')) {
            validFields.add('Id');
        }
        String parentField = findParentLookupField(describe, parentId);
        String grandChild = 'SELECT ' + String.join(validFields, ',') +
                            ' FROM ' + grandchildObjectApiName +
                            ' WHERE ' + parentField + ' = :parentId';
        return Database.query(grandChild);
    }
    
    private static List<String> parseFields(String fieldString){
        List<String> result = new List<String>();
        if (String.isBlank(fieldString)){
            return result;
        }
        for (String fieldName : fieldString.split(',')){
            String trimmed = fieldName.trim();
            if (!String.isBlank(trimmed)) {
                result.add(trimmed);
            }
        }
        return result;
    } 
    
    private static String findParentLookupField(Schema.DescribeSObjectResult describe, Id parentId){
        Map<String, Schema.SObjectField> fields = describe.fields.getMap();
        for(String fieldName : fields.keySet()){
            Schema.DescribeFieldResult fieldDescribe = fields.get(fieldName).getDescribe();
            if (fieldDescribe.getType() == Schema.DisplayType.REFERENCE) {
                List<Schema.SObjectType> references = fieldDescribe.getReferenceTo();
                for (Schema.SObjectType reference : references) {
                    if (reference.getDescribe().getKeyPrefix() == String.valueOf(parentId).substring(0, 3)){
                        return fieldName;
                    }
                }
            }
        }
        return null;
    }
}