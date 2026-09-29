public with sharing class RecordHistory24HoursController {
    public class HistoryItem {
        @AuraEnabled public String id;
        @AuraEnabled public String fieldLabel;
        @AuraEnabled public String oldValue;
        @AuraEnabled public String newValue;
        @AuraEnabled public String changedByName;
        @AuraEnabled public Datetime changedDate;
    }
    @AuraEnabled(cacheable=true)
    public static List<HistoryItem> getRecentHistory(Id recordId) {
        List<HistoryItem> results = new List<HistoryItem>();
        if(recordId == null){
            return results;
        }
        String objectApiName = recordId.getSObjectType().getDescribe().getName();
        List<String> candidateNames = new List<String>();
        if(objectApiName.endsWith('__c')){
            candidateNames.add(objectApiName.replace('__c', '__History'));
        }else{
            candidateNames.add(objectApiName + 'FieldHistory');
            candidateNames.add(objectApiName + 'History');
        }
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        Set<String> requiredFields = new Set<String>{
            'ParentId', 'Field', 'OldValue', 'NewValue', 'CreatedDate', 'CreatedById'
        };
        String historyObjectApiName;
        for(String candidate : candidateNames){
            if(!globalDescribe.containsKey(candidate)){
                continue;
            }
            Map<String, Schema.SObjectField> candidateFields = globalDescribe.get(candidate).getDescribe().fields.getMap();
            Boolean hasAllFields = true;
            for(String f : requiredFields){
                if(!candidateFields.containsKey(f)){
                    hasAllFields = false;
                    break;
                }
            }
            if(hasAllFields){
                historyObjectApiName = candidate;
                break;
            }
        }
        Datetime cutoff = Datetime.now().addHours(-24);
        String cutoffLiteral = cutoff.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        String query = 'SELECT Field, OldValue, NewValue, CreatedDate, CreatedBy.Name ' +
                       'FROM ' + String.escapeSingleQuotes(historyObjectApiName) + ' ' +
                       'WHERE ParentId = :recordId AND CreatedDate >= ' + cutoffLiteral + ' ' +
                       'ORDER BY CreatedDate DESC ';
        List<SObject> records = Database.query(query);
        Map<String, Schema.SObjectField> parentFields = recordId.getSObjectType().getDescribe().fields.getMap();
        Integer rowIndex = 0;
        for(SObject rec : records){
            HistoryItem item = new HistoryItem();
            item.id = String.valueOf(rowIndex);
            rowIndex++;
            String fieldApiName = (String) rec.get('Field');
            item.fieldLabel = fieldApiName;
            if(fieldApiName != null && parentFields.containsKey(fieldApiName)){
                item.fieldLabel = parentFields.get(fieldApiName).getDescribe().getLabel();
            }
            item.oldValue = formatValue(rec.get('OldValue'));
            item.newValue = formatValue(rec.get('NewValue'));
            item.changedDate = (Datetime) rec.get('CreatedDate');
            SObject createdBy = rec.getSObject('CreatedBy');
            item.changedByName = createdBy != null ? (String) createdBy.get('Name') : null;
            results.add(item);
        }
        return results;
    }
    private static String formatValue(Object val){
        if(val == null){
            return '—';
        }
        return String.valueOf(val);
    }
}