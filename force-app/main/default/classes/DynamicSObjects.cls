public class DynamicSObjects {

    @AuraEnabled(cacheable=true)
    public static List<SObject> getDynamicRecords(
        Id parentId,
        String childObjectApiName,
        String childFieldApiNames
    ) {
        Schema.SObjectType childType =
            Schema.getGlobalDescribe().get(childObjectApiName);

        if (childType == null) {
            return new List<SObject>();
        }

        Schema.DescribeSObjectResult describe = childType.getDescribe();

        Map<String, Schema.SObjectField> fields =
            describe.fields.getMap();

        List<String> requestedFields =
            parseFields(childFieldApiNames);

        List<String> validFields =
            new List<String>();

        for (String fieldName : requestedFields) {
            if (fields.containsKey(fieldName)) {
                validFields.add(fieldName);
            }
        }

        if (!validFields.contains('Id')) {
            validFields.add('Id');
        }

        String parentField =
            findParentLookupField(describe, parentId);

        if (String.isBlank(parentField)) {
            return new List<SObject>();
        }

        String childObject =
            'SELECT ' +
            String.join(validFields, ',') +
            ' FROM ' +
            childObjectApiName +
            ' WHERE ' +
            parentField +
            ' = :parentId';

        return Database.query(childObject);
    }


    @AuraEnabled(cacheable=true)
    public static List<SObject> getDynamicGrandchildRecords(
        Id parentId,
        String grandchildObjectApiName,
        String grandchildFieldApiNames
    ) {

        Schema.SObjectType childType =
            Schema.getGlobalDescribe().get(grandchildObjectApiName);

        if (childType == null) {
            return new List<SObject>();
        }

        Schema.DescribeSObjectResult describe =
            childType.getDescribe();

        Map<String, Schema.SObjectField> fields =
            describe.fields.getMap();

        List<String> requestedFields =
            parseFields(grandchildFieldApiNames);

        List<String> validFields =
            new List<String>();

        for (String fieldName : requestedFields) {

            if (fields.containsKey(fieldName)) {
                validFields.add(fieldName);
            }
        }

        if (!validFields.contains('Id')) {
            validFields.add('Id');
        }

        String parentField =
            findParentLookupField(describe, parentId);

        if (String.isBlank(parentField)) {
            return new List<SObject>();
        }

        String grandChild =
            'SELECT ' +
            String.join(validFields, ',') +
            ' FROM ' +
            grandchildObjectApiName +
            ' WHERE ' +
            parentField +
            ' = :parentId';

        return Database.query(grandChild);
    }


    /*
     * Returns metadata for the fields configured in
     * "Records Create Fields".
     */
    @AuraEnabled(cacheable=true)
    public static List<FieldDetail> getFieldDataType(
        String childObjectApiName
    ) {

        List<FieldDetail> fieldData =
            new List<FieldDetail>();

        if (String.isBlank(childObjectApiName)) {
            return fieldData;
        }

        Schema.SObjectType convertType =
            Schema.getGlobalDescribe().get(childObjectApiName);

        if (convertType == null) {
            return fieldData;
        }

        Map<String, Schema.SObjectField> fieldMap =
            convertType.getDescribe().fields.getMap();

        for (Schema.SObjectField fieldType : fieldMap.values()) {

            Schema.DescribeFieldResult fieldDescribe =
                fieldType.getDescribe();

            FieldDetail detail =
                new FieldDetail();

            detail.apiName =
                fieldDescribe.getName();

            detail.label =
                fieldDescribe.getLabel();

            detail.type =
                fieldDescribe.getType().name();

            if (fieldDescribe.getType() == Schema.DisplayType.BOOLEAN) {
                detail.required = false;
            } else {
                detail.required =
                    fieldDescribe.isCreateable() &&
                    !fieldDescribe.isNillable();
            }

            detail.picklistOptions =
                new List<PicklistOption>();


            /*
             * PICKLIST
             */
            if (
                detail.type == 'PICKLIST' ||
                detail.type == 'MULTIPICKLIST'
            ) {

                for (
                    Schema.PicklistEntry entry :
                    fieldDescribe.getPicklistValues()
                ) {

                    if (entry.isActive()) {

                        PicklistOption option =
                            new PicklistOption();

                        option.label =
                            entry.getLabel();

                        option.value =
                            entry.getValue();

                        detail.picklistOptions.add(option);
                    }
                }
            }


            /*
             * LOOKUP / MASTER DETAIL
             */
            if (detail.type == 'REFERENCE') {

                List<Schema.SObjectType> referenceObjects =
                    fieldDescribe.getReferenceTo();

                if (
                    referenceObjects != null &&
                    !referenceObjects.isEmpty()
                ) {

                    detail.lookupObjectApiName =
                        referenceObjects[0]
                            .getDescribe()
                            .getName();
                }
            }

            fieldData.add(detail);
        }

        return fieldData;
    }


    /*
     * Create dynamic child record.
     */
    @AuraEnabled
    public static Id createDynamicRecord(
        String objectApiName,
        String fieldValues,
        Id parentId,
        String parentFieldApiName
    ) {

        if (String.isBlank(objectApiName)) {
            throw new AuraHandledException(
                'Child Object API Name is required.'
            );
        }

        Schema.SObjectType objectType =
            Schema.getGlobalDescribe().get(objectApiName);

        if (objectType == null) {
            throw new AuraHandledException(
                'Invalid object: ' + objectApiName
            );
        }

        SObject newRecord =
            objectType.newSObject();

        Map<String, Object> values =
            (Map<String, Object>)
            JSON.deserializeUntyped(fieldValues);


        /*
         * Set parent Account automatically.
         */
        if (
            parentId != null &&
            !String.isBlank(parentFieldApiName)
        ) {

            Map<String, Schema.SObjectField> fields =
                objectType.getDescribe().fields.getMap();

            if (fields.containsKey(parentFieldApiName)) {

                Schema.DescribeFieldResult parentField =
                    fields
                        .get(parentFieldApiName)
                        .getDescribe();

                if (parentField.isCreateable()) {
                    newRecord.put(
                        parentFieldApiName,
                        parentId
                    );
                }
            }
        }


        /*
         * Set configured field values.
         */
        Map<String, Schema.SObjectField> fieldMap =
            objectType.getDescribe().fields.getMap();

        for (String fieldName : values.keySet()) {

            if (
                !fieldMap.containsKey(fieldName) ||
                fieldName == 'Id'
            ) {
                continue;
            }

            Schema.DescribeFieldResult fieldDescribe =
                fieldMap
                    .get(fieldName)
                    .getDescribe();

            if (!fieldDescribe.isCreateable()) {
                continue;
            }

            Object value =
                values.get(fieldName);

            if (value == null) {
                continue;
            }

            String fieldType =
                fieldDescribe.getType().name();


            /*
             * MULTIPICKLIST
             *
             * LWC dual-listbox sends an Array.
             * Salesforce stores it as:
             *
             * Value1;Value2;Value3
             */
            if (
                fieldType == 'MULTIPICKLIST' &&
                value instanceof List<Object>
            ) {

                List<Object> selectedValues =
                    (List<Object>) value;

                List<String> stringValues =
                    new List<String>();

                for (Object selectedValue :
                    selectedValues
                ) {

                    stringValues.add(
                        String.valueOf(selectedValue)
                    );
                }

                newRecord.put(
                    fieldName,
                    String.join(
                        stringValues,
                        ';'
                    )
                );

            } else {

                newRecord.put(
                    fieldName,
                    value
                );
            }
        }

        insert newRecord;

        return newRecord.Id;
    }


    private static List<String> parseFields(
        String fieldString
    ) {

        List<String> result =
            new List<String>();

        if (String.isBlank(fieldString)) {
            return result;
        }

        for (
            String fieldName :
            fieldString.split(',')
        ) {

            String trimmed =
                fieldName.trim();

            if (!String.isBlank(trimmed)) {
                result.add(trimmed);
            }
        }

        return result;
    }


    private static String findParentLookupField(
        Schema.DescribeSObjectResult describe,
        Id parentId
    ) {

        if (parentId == null) {
            return null;
        }

        Map<String, Schema.SObjectField> fields =
            describe.fields.getMap();

        String parentPrefix =
            String.valueOf(parentId).substring(0, 3);

        for (String fieldName : fields.keySet()) {

            Schema.DescribeFieldResult fieldDescribe =
                fields
                    .get(fieldName)
                    .getDescribe();

            if (
                fieldDescribe.getType() ==
                Schema.DisplayType.REFERENCE
            ) {

                List<Schema.SObjectType> references =
                    fieldDescribe.getReferenceTo();

                for (
                    Schema.SObjectType reference :
                    references
                ) {

                    if (
                        reference
                            .getDescribe()
                            .getKeyPrefix() ==
                        parentPrefix
                    ) {

                        return fieldName;
                    }
                }
            }
        }

        return null;
    }


    public class FieldDetail {

        @AuraEnabled
        public String apiName;

        @AuraEnabled
        public String label;

        @AuraEnabled
        public String type;

        @AuraEnabled
        public Boolean required;

        @AuraEnabled
        public String lookupObjectApiName;

        @AuraEnabled
        public List<PicklistOption> picklistOptions;
    }


    public class PicklistOption {

        @AuraEnabled
        public String label;

        @AuraEnabled
        public String value;
    }
}