import {
    LightningElement,
    api,
    wire
} from 'lwc';

import getDynamicRecords
    from '@salesforce/apex/DynamicSObjects.getDynamicRecords';

import getDynamicGrandchildRecords
    from '@salesforce/apex/DynamicSObjects.getDynamicGrandchildRecords';

import getFieldDataType
    from '@salesforce/apex/DynamicSObjects.getFieldDataType';

import createDynamicRecord
    from '@salesforce/apex/DynamicSObjects.createDynamicRecord';

import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';


export default class DynamicCompoundRelatedObjects
    extends LightningElement {


    @api recordId;

    @api objectApiName;

    @api childObjectApiName;

    @api childObjectFieldApiNames;

    @api childParentFieldApiName;

    @api grandchildObjectApiName;

    @api grandchildObjectFieldApiNames;

    @api grandchildParentFieldApiName;

    @api childCreateFieldApiNames;


    deals = [];

    showNewDealForm = false;

    newRecordValues = {};

    fieldMetadata = [];


    // =========================================================
    // CHILD TABLE
    // =========================================================

    get childFields() {

        if (!this.childObjectFieldApiNames) {
            return [];
        }

        return this.childObjectFieldApiNames
            .split(',')
            .map(field => field.trim())
            .filter(field => field)
            .map(field => ({
                apiName: field,
                label: this.getFieldLabel(field)
            }));
    }


    // =========================================================
    // GRANDCHILD TABLE
    // =========================================================

    get grandchildFields() {

        if (!this.grandchildObjectFieldApiNames) {
            return [];
        }

        return this.grandchildObjectFieldApiNames
            .split(',')
            .map(field => field.trim())
            .filter(field => field)
            .map(field => ({
                apiName: field,
                label: this.getFieldLabel(field)
            }));
    }


    // =========================================================
    // OBJECT LABELS
    // =========================================================

    get childObjectLabel() {

        return this.formatObjectName(
            this.childObjectApiName
        );
    }


    get grandchildObjectLabel() {

        return this.formatObjectName(
            this.grandchildObjectApiName
        );
    }


    // =========================================================
    // FIELD LABEL
    // =========================================================

    getFieldLabel(apiName) {

        if (!apiName) {
            return '';
        }

        return apiName
            .replace('__c', '')
            .replace(/_/g, ' ')
            .replace(/([a-z])([A-Z])/g, '$1 $2')
            .replace(/\b\w/g, letter =>
                letter.toUpperCase()
            );
    }


    formatObjectName(apiName) {

        if (!apiName) {
            return '';
        }

        return apiName
            .replace('__c', '')
            .replace(/_/g, ' ')
            .replace(/\b\w/g, letter =>
                letter.toUpperCase()
            );
    }
    @wire(getDynamicRecords, {
        parentId: '$recordId',
        childObjectApiName: '$childObjectApiName',
        childFieldApiNames: '$childObjectFieldApiNames'
    })
    wiredDeals({ error, data }) {

        if (data) {

            this.deals = data.map(record => {

                return {
                    ...record,

                    isExpanded: false,

                    dealItems: [],

                    hasItems: false,

                    iconName: 'utility:chevronright',

                    rowClass: 'deal-row',

                    cells: this.createCells(
                        record,
                        this.childFields
                    )
                };
            });

        } else if (error) {

            this.deals = [];

            console.error(
                'Error fetching records:',
                error
            );
        }
    }


    get hasDeals() {

        return this.deals.length > 0;
    }


    get dealRows() {

        return this.deals;
    }


    createCells(record, fields) {

        return fields.map(field => {

            const value =
                record[field.apiName];

            return {

                key:
                    `${record.Id}-${field.apiName}`,

                apiName:
                    field.apiName,

                value:
                    value,

                displayValue:
                    this.formatValue(value),

                isBoolean:
                    typeof value === 'boolean'
            };
        });
    }


    formatValue(value) {

        if (
            value === null ||
            value === undefined
        ) {
            return '';
        }

        return value;
    }


    // =========================================================
    // EXPAND / COLLAPSE
    // =========================================================

    handleDealClick(event) {

        const dealId =
            event.currentTarget.dataset.id;

        const selectedDeal =
            this.deals.find(
                deal => deal.Id === dealId
            );

        if (!selectedDeal) {
            return;
        }


        if (selectedDeal.isExpanded) {

            this.deals =
                this.deals.map(deal => {

                    if (deal.Id === dealId) {

                        return {
                            ...deal,

                            isExpanded: false,

                            iconName:
                                'utility:chevronright',

                            rowClass:
                                'deal-row'
                        };
                    }

                    return deal;
                });

            return;
        }


        this.deals =
            this.deals.map(deal => {

                if (deal.Id === dealId) {

                    return {
                        ...deal,

                        isExpanded: true,

                        iconName:
                            'utility:chevrondown',

                        rowClass:
                            'deal-row selected'
                    };
                }

                return {
                    ...deal,

                    isExpanded: false,

                    iconName:
                        'utility:chevronright',

                    rowClass:
                        'deal-row'
                };
            });


        this.loadGrandchildRecords(dealId);
    }


    loadGrandchildRecords(parentId) {

        getDynamicGrandchildRecords({

            parentId: parentId,

            grandchildObjectApiName:
                this.grandchildObjectApiName,

            grandchildFieldApiNames:
                this.grandchildObjectFieldApiNames
        })

        .then(data => {

            this.deals =
                this.deals.map(deal => {

                    if (deal.Id === parentId) {

                        return {

                            ...deal,

                            dealItems:
                                data.map(item => ({

                                    ...item,

                                    cells:
                                        this.createCells(
                                            item,
                                            this.grandchildFields
                                        )
                                })),

                            hasItems:
                                data &&
                                data.length > 0
                        };
                    }

                    return deal;
                });
        })

        .catch(error => {

            console.error(
                'Error fetching grandchild records:',
                error
            );
        });
    }


    // =========================================================
    // CREATE FORM FIELD METADATA
    // =========================================================

    @wire(getFieldDataType, {
        childObjectApiName:
            '$childObjectApiName'
    })
    wiredFieldData({ error, data }) {

        if (data) {

            this.fieldMetadata = data;

            console.log(
                'Field Metadata:',
                JSON.stringify(data)
            );

        } else if (error) {

            this.fieldMetadata = [];

            console.error(
                'Error fetching field metadata:',
                error
            );
        }
    }


    // =========================================================
    // CREATE FIELDS
    // =========================================================

    get createFields() {

        if (
            !this.childCreateFieldApiNames ||
            !this.fieldMetadata.length
        ) {
            return [];
        }


        const configuredFields =
            this.childCreateFieldApiNames
                .split(',')
                .map(field => field.trim())
                .filter(field => field);


        return configuredFields
            .map(fieldApiName => {

                const metadata =
                    this.fieldMetadata.find(
                        field =>
                            field.apiName === fieldApiName
                    );


                if (!metadata) {
                    return null;
                }


                const type =
                    metadata.type;


                const isPicklist =
                    type === 'PICKLIST';


                const isMultiPicklist =
                    type === 'MULTIPICKLIST';


                const isLookup =
                    type === 'REFERENCE';


                const isTextArea =
                    type === 'TEXTAREA' ||
                    type === 'LONGTEXTAREA';


                return {
                    apiName: metadata.apiName,

                    label: metadata.label,

                    type: type,

                    required: metadata.required,

                    value: this.newRecordValues[metadata.apiName] ?? '',

                    isPicklist: isPicklist,

                    isMultiPicklist: isMultiPicklist,

                    isLookup: isLookup,

                    isTextArea: isTextArea,

                    isParentLookup:
                        metadata.apiName === this.childParentFieldApiName,

                    lookupObjectApiName:
                        metadata.lookupObjectApiName,

                    options:
                        metadata.picklistOptions || [],

                    inputType:
                        this.getInputType(type)
                };
            })

            .filter(field => field);
    }


    get hasCreateFields() {

        return this.createFields.length > 0;
    }


    // =========================================================
    // SALESFORCE TYPE -> LIGHTNING INPUT TYPE
    // =========================================================

    getInputType(type) {

        switch (type) {

            case 'BOOLEAN':
                return 'checkbox';

            case 'EMAIL':
                return 'email';

            case 'PHONE':
                return 'tel';

            case 'URL':
                return 'url';

            case 'DATE':
                return 'date';

            case 'DATETIME':
                return 'datetime';

            case 'TIME':
                return 'time';

            case 'DOUBLE':
            case 'INTEGER':
            case 'LONG':
            case 'DECIMAL':
            case 'CURRENCY':
            case 'PERCENT':
                return 'number';

            case 'TEXT':
            case 'STRING':
            case 'ID':
            case 'ENCRYPTEDSTRING':
                return 'text';

            default:
                return 'text';
        }
    }

    handleNewDeal() {
        const initialValues = {};
        if (this.childParentFieldApiName && this.recordId) {

            initialValues[this.childParentFieldApiName] =
                this.recordId;
        }

        this.newRecordValues = initialValues;

        this.showNewDealForm = true;
    }



    handleCancel() {

        this.showNewDealForm = false;

        this.newRecordValues = {};
    }


    // =========================================================
    // FIELD CHANGE
    // =========================================================

    handleFieldChange(event) {

        const fieldName =
            event.target.dataset.field;


        let value;


        // LOOKUP
        if (
            event.target.tagName ===
            'LIGHTNING-RECORD-PICKER'
        ) {

            value =
                event.detail.recordId;

        }


        // MULTIPICKLIST
        else if (
            event.target.tagName ===
            'LIGHTNING-DUAL-LISTBOX'
        ) {

            value =
                event.detail.value;

        }


        // CHECKBOX
        else if (
            event.target.type === 'checkbox'
        ) {

            value =
                event.target.checked;

        }


        // EVERYTHING ELSE
        else {

            value =
                event.target.value;
        }


        this.newRecordValues = {

            ...this.newRecordValues,

            [fieldName]:
                value
        };
    }


    // =========================================================
    // SAVE
    // =========================================================

    handleSave() {

        const inputs =
            this.template.querySelectorAll(
                'lightning-input, lightning-combobox, lightning-dual-listbox, lightning-record-picker, lightning-textarea'
            );


        let isValid = true;


        inputs.forEach(input => {

            if (
                input.required &&
                !input.reportValidity()
            ) {

                isValid = false;
            }
        });


        if (!isValid) {
            return;
        }


        createDynamicRecord({

            objectApiName:
                this.childObjectApiName,

            fieldValues:
                JSON.stringify(
                    this.newRecordValues
                ),

            parentId:
                this.recordId,

            parentFieldApiName:
                this.childParentFieldApiName
        })

        .then(() => {

            this.showNewDealForm = false;

            this.newRecordValues = {};


            this.dispatchEvent(
                new ShowToastEvent({

                    title:
                        'Success',

                    message:
                        `${this.childObjectLabel} created successfully.`,

                    variant:
                        'success'
                })
            );


            /*
             * Refresh the page.
             * You can later replace this with
             * refreshApex if you want.
             */
            window.location.reload();
        })

        .catch(error => {

            console.error(
                'Error creating record:',
                error
            );


            let message =
                'Error creating record.';


            if (
                error &&
                error.body &&
                error.body.message
            ) {

                message =
                    error.body.message;
            }


            this.dispatchEvent(
                new ShowToastEvent({

                    title:
                        'Error',

                    message:
                        message,

                    variant:
                        'error'
                })
            );
        });
    }
}