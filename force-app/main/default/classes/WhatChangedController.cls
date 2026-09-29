public with sharing class WhatChangedController {

    /*
     * Wrapper returned to LWC
     */
    public class ChangeWrapper {
        @AuraEnabled public String historyId;
        @AuraEnabled public String fieldApiName;
        @AuraEnabled public String fieldLabel;
        @AuraEnabled public String oldValue;
        @AuraEnabled public String newValue;
        @AuraEnabled public String changedBy;
        @AuraEnabled public Id changedById;
        @AuraEnabled public Datetime changedDate;
    }

    /*
     * Information returned when history is not available
     */
    public class HistoryInfo {
        @AuraEnabled public Boolean supported;
        @AuraEnabled public Boolean trackingAvailable;
        @AuraEnabled public String objectLabel;
        @AuraEnabled public String historyObjectName;
        @AuraEnabled public String message;
    }

    /*
     * Main method
     */
    @AuraEnabled(cacheable=true)
    public static List<ChangeWrapper> getChanges(
        Id recordId,
        String objectApiName,
        Integer days
    ) {

        if (recordId == null) {
            throw new AuraHandledException('Record Id is required.');
        }

        if (String.isBlank(objectApiName)) {
            throw new AuraHandledException('Object API name is required.');
        }

        if (days == null || days <= 0) {
            days = 30;
        }

        /*
         * Validate object
         */
        Map<String, Schema.SObjectType> globalDescribe =
            Schema.getGlobalDescribe();

        if (!globalDescribe.containsKey(objectApiName)) {
            throw new AuraHandledException(
                'Invalid Salesforce object: ' + objectApiName
            );
        }

        Schema.SObjectType sourceType =
            globalDescribe.get(objectApiName);

        Schema.DescribeSObjectResult sourceDescribe =
            sourceType.getDescribe();

        /*
         * Make sure record actually belongs to this object.
         */
        if (!recordId.getSObjectType().getDescribe().getName()
            .equals(objectApiName)) {

            throw new AuraHandledException(
                'Record does not belong to ' + objectApiName
            );
        }

        /*
         * Find the History object.
         */
        String historyObjectName =
            getHistoryObjectName(objectApiName);

        if (String.isBlank(historyObjectName)) {
            return new List<ChangeWrapper>();
        }

        /*
         * Check that History object exists.
         */
        if (!globalDescribe.containsKey(historyObjectName)) {
            return new List<ChangeWrapper>();
        }

        Schema.SObjectType historyType =
            globalDescribe.get(historyObjectName);

        Schema.DescribeSObjectResult historyDescribe =
            historyType.getDescribe();

        /*
         * Make sure history object can be queried.
         */
        if (!historyDescribe.isQueryable()) {
            return new List<ChangeWrapper>();
        }

        /*
         * Find the field on the History object that references
         * the original object.
         *
         * Examples:
         *
         * AccountHistory      -> AccountId
         * OpportunityHistory  -> OpportunityId
         * Project__History    -> ParentId
         */
        String parentFieldName =
            findParentReferenceField(
                historyDescribe,
                objectApiName
            );

        if (String.isBlank(parentFieldName)) {
            throw new AuraHandledException(
                'Unable to find the parent reference field for ' +
                historyObjectName
            );
        }

        /*
         * Build date filter.
         */
        Datetime startDate =
            System.now().addDays(-days);

        /*
         * Dynamic SOQL.
         *
         * Object name and field name come from Salesforce metadata,
         * not directly from user-entered SOQL.
         */
        String soql =
            'SELECT Id, Field, OldValue, NewValue, ' +
            'CreatedDate, CreatedById ' +
            'FROM ' + historyObjectName +
            ' WHERE ' + parentFieldName + ' = :recordId' +
            ' AND CreatedDate >= :startDate' +
            ' ORDER BY CreatedDate DESC';

        List<SObject> historyRecords =
            Database.query(soql);

        /*
         * Collect User Ids.
         */
        Set<Id> userIds = new Set<Id>();

        for (SObject historyRecord : historyRecords) {

            Id createdById =
                (Id) historyRecord.get('CreatedById');

            if (createdById != null) {
                userIds.add(createdById);
            }
        }

        /*
         * Query users once.
         */
        Map<Id, User> usersById =
            new Map<Id, User>();

        if (!userIds.isEmpty()) {

            for (User userRecord : [
                SELECT Id, Name
                FROM User
                WHERE Id IN :userIds
            ]) {
                usersById.put(
                    userRecord.Id,
                    userRecord
                );
            }
        }

        /*
         * Get fields from source object.
         */
        Map<String, Schema.SObjectField> sourceFields =
            sourceDescribe.fields.getMap();

        List<ChangeWrapper> results =
            new List<ChangeWrapper>();

        /*
         * Convert History records into generic wrappers.
         */
        for (SObject historyRecord : historyRecords) {

            ChangeWrapper wrapper =
                new ChangeWrapper();

            wrapper.historyId =
                String.valueOf(historyRecord.get('Id'));

            String fieldValue =
                String.valueOf(historyRecord.get('Field'));

            wrapper.fieldApiName =
                normalizeHistoryFieldName(
                    fieldValue,
                    sourceFields
                );

            /*
             * Get field label dynamically.
             */
            wrapper.fieldLabel =
                getFieldLabel(
                    wrapper.fieldApiName,
                    sourceFields
                );

            /*
             * Old and New values can be different Apex types,
             * therefore convert them safely to String.
             */
            Object oldValue =
                historyRecord.get('OldValue');

            Object newValue =
                historyRecord.get('NewValue');

            wrapper.oldValue =
                convertValueToString(oldValue);

            wrapper.newValue =
                convertValueToString(newValue);

            wrapper.changedById =
                (Id) historyRecord.get('CreatedById');

            if (wrapper.changedById != null &&
                usersById.containsKey(wrapper.changedById)) {

                wrapper.changedBy =
                    usersById.get(wrapper.changedById).Name;
            }
            else {
                wrapper.changedBy =
                    'Unknown User';
            }

            wrapper.changedDate =
                (Datetime) historyRecord.get('CreatedDate');

            results.add(wrapper);
        }

        return results;
    }


    /*
     * Determine History object name.
     *
     * Custom:
     * Project__c -> Project__History
     *
     * Standard:
     * Account -> AccountHistory
     */
    private static String getHistoryObjectName(
        String objectApiName
    ) {

        if (objectApiName.endsWith('__c')) {

            return objectApiName.substring(
                0,
                objectApiName.length() - 3
            ) + '__History';
        }

        return objectApiName + 'History';
    }


    /*
     * Dynamically find the reference field from History object
     * back to the source object.
     */
    private static String findParentReferenceField(
        Schema.DescribeSObjectResult historyDescribe,
        String sourceObjectApiName
    ) {

        Map<String, Schema.SObjectField> fields =
            historyDescribe.fields.getMap();

        for (String fieldName : fields.keySet()) {

            Schema.DescribeFieldResult fieldDescribe =
                fields.get(fieldName).getDescribe();

            if (fieldDescribe.getType() !=
                Schema.DisplayType.REFERENCE) {
                continue;
            }

            List<Schema.SObjectType> referenceObjects =
                fieldDescribe.getReferenceTo();

            for (Schema.SObjectType referenceType :
                 referenceObjects) {

                if (referenceType.getDescribe().getName()
                    .equals(sourceObjectApiName)) {

                    return fieldName;
                }
            }
        }

        return null;
    }


    /*
     * Some History objects can return field names in forms such as:
     *
     * Owner
     * OwnerId
     * Custom_Field__c
     *
     * Try to resolve the actual source field.
     */
    private static String normalizeHistoryFieldName(
        String historyFieldName,
        Map<String, Schema.SObjectField> sourceFields
    ) {

        if (String.isBlank(historyFieldName)) {
            return historyFieldName;
        }

        /*
         * Direct match.
         */
        if (sourceFields.containsKey(historyFieldName)) {
            return historyFieldName;
        }

        /*
         * Owner is commonly represented as Owner.
         */
        if (historyFieldName == 'Owner' &&
            sourceFields.containsKey('OwnerId')) {

            return 'OwnerId';
        }

        /*
         * Some relationship fields may come back without Id.
         */
        String possibleIdField =
            historyFieldName + 'Id';

        if (sourceFields.containsKey(possibleIdField)) {
            return possibleIdField;
        }

        return historyFieldName;
    }


    /*
     * Dynamically get field label.
     */
    private static String getFieldLabel(
        String fieldApiName,
        Map<String, Schema.SObjectField> sourceFields
    ) {

        if (String.isBlank(fieldApiName)) {
            return 'Unknown Field';
        }

        if (sourceFields.containsKey(fieldApiName)) {

            return sourceFields
                .get(fieldApiName)
                .getDescribe()
                .getLabel();
        }

        /*
         * Special handling for Owner.
         */
        if (fieldApiName == 'OwnerId') {
            return 'Owner';
        }

        return fieldApiName;
    }


    /*
     * Safely convert History OldValue/NewValue to String.
     */
    private static String convertValueToString(
        Object value
    ) {

        if (value == null) {
            return '';
        }

        return String.valueOf(value);
    }


    /*
     * Get information about history tracking.
     *
     * This can be called separately by the LWC.
     */
    @AuraEnabled(cacheable=true)
    public static HistoryInfo getHistoryInfo(
        String objectApiName
    ) {

        HistoryInfo result =
            new HistoryInfo();

        result.supported = false;
        result.trackingAvailable = false;

        if (String.isBlank(objectApiName)) {
            result.message =
                'Object API name is required.';
            return result;
        }

        Map<String, Schema.SObjectType> globalDescribe =
            Schema.getGlobalDescribe();

        if (!globalDescribe.containsKey(objectApiName)) {
            result.message =
                'Object does not exist.';
            return result;
        }

        Schema.DescribeSObjectResult objectDescribe =
            globalDescribe
                .get(objectApiName)
                .getDescribe();

        result.objectLabel =
            objectDescribe.getLabel();

        String historyObjectName =
            getHistoryObjectName(objectApiName);

        result.historyObjectName =
            historyObjectName;

        if (!globalDescribe.containsKey(historyObjectName)) {

            result.message =
                'Field History Tracking is not available for this object.';

            return result;
        }

        Schema.DescribeSObjectResult historyDescribe =
            globalDescribe
                .get(historyObjectName)
                .getDescribe();

        if (!historyDescribe.isQueryable()) {

            result.message =
                'The history object cannot be queried.';

            return result;
        }

        result.supported = true;

        String parentField =
            findParentReferenceField(
                historyDescribe,
                objectApiName
            );
        if (String.isBlank(parentField)) {
            result.message = 'History object was found, but its parent relationship ' + 'could not be determined.';
            return result;
        }
        result.trackingAvailable = true;
        result.message = 'Field History Tracking is available.';
        return result;
    }
}