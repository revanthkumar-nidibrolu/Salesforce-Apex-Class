import { LightningElement, api, wire } from 'lwc';
import getDynamicRecords from '@salesforce/apex/DynamicRelatedRecordsController.getDynamicRecords';
import getDynamicGrandchildRecords from '@salesforce/apex/DynamicRelatedRecordsController.getDynamicGrandchildRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class dynamicCompoundRelatedObjects extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api childObjectApiName;
    @api childObjectFieldApiNames;
    @api childParentFieldApiName;
    @api grandchildObjectApiName;
    @api grandchildObjectFieldApiNames;
    @api grandchildParentFieldApiName;
    deals = [];
    createFields = [];
    createObjectApiName = '';
    createParentFieldApiName = '';
    showNewDealForm = false;
    connectedCallback() {

        if (this.objectApiName === 'Opportunity') {
            this.createObjectApiName = 'Deal__c';
            this.createParentFieldApiName = 'Opportunity__c';
            this.createFields = [
                { apiName: 'Name', required: true },
                { apiName: 'Active__c', required: false },
                { apiName: 'Amount__c', required: false },
                { apiName: 'Start_Date__c', required: false },
                { apiName: 'End_Date__c', required: false },
                { apiName: 'Opportunity__c', required: false, value: this.recordId }
            ];
        } else if (this.objectApiName === 'Account') {
            this.createObjectApiName = 'Bank__c';
            this.createParentFieldApiName = 'Account__c';
            this.createFields = [
                { apiName: 'Name', required: true },
                { apiName: 'Account_Holder_Name__c', required: false },
                { apiName: 'Branch__c', required: false },
                { apiName: 'Account_Number__c', required: false },
                { apiName: 'IFSC__c', required: false },
                { apiName: 'Status__c', required: false },
                { apiName: 'Account__c', required: false, value: this.recordId }
            ];
        }
    }
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
    get childObjectLabel() {
        return this.formatObjectName(this.childObjectApiName);
    }
    get grandchildObjectLabel() {
        return this.formatObjectName(this.grandchildObjectApiName);
    }
    getFieldLabel(apiName) {
        if (!apiName) {
            return '';
        }
        return apiName
            .replace('__c', '')
            .replace(/_/g, ' ')
            .replace(/([a-z])([A-Z])/g, '$1 $2')
            .replace(/\b\w/g, letter => letter.toUpperCase());
    }
    formatObjectName(apiName) {
        if (!apiName) {
            return '';
        }
        return apiName
            .replace('__c', '')
            .replace(/_/g, ' ')
            .replace(/\b\w/g, letter => letter.toUpperCase());
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
                    cells: this.createCells( record, this.childFields)
                };
            });
        } else if (error) {
            this.deals = [];
            console.error('Error fetching records:', error);
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
            const value = record[field.apiName];
            return {
                key: `${record.Id}-${field.apiName}`,
                apiName: field.apiName,
                value: value,
                displayValue: this.formatValue(value),
                isBoolean: typeof value == 'boolean'
            };
        });
    }
    formatValue(value) {
        if (value == null || value == undefined) {
            return '';
        }
        return value;
    }
    handleDealClick(event) {
        const dealId =
            event.currentTarget.dataset.id;
        const selectedDeal =
            this.deals.find(
                deal => deal.Id == dealId
            );
        if (!selectedDeal) {
            return;
        }
        if (selectedDeal.isExpanded) {
            this.deals = this.deals.map(deal => {
                if (deal.Id == dealId) {
                    return {
                        ...deal,
                        isExpanded: false,
                        iconName: 'utility:chevronright',
                        rowClass: 'deal-row'
                    };
                }
                return deal;
            });
            return;
        }
        this.deals = this.deals.map(deal => {
            if (deal.Id == dealId) {
                return {
                    ...deal,
                    isExpanded: true,
                    iconName: 'utility:chevrondown',
                    rowClass: 'deal-row selected'
                };
            }
            return {
                ...deal,
                isExpanded: false,
                iconName: 'utility:chevronright',
                rowClass: 'deal-row'
            };
        });
        this.loadGrandchildRecords(dealId);
    }
    loadGrandchildRecords(parentId) {
        getDynamicGrandchildRecords({
            parentId: parentId,
            grandchildObjectApiName: this.grandchildObjectApiName,
            grandchildFieldApiNames: this.grandchildObjectFieldApiNames
        })
        .then(data => {
            this.deals = this.deals.map(deal => {
                if (deal.Id == parentId) {
                    return {
                        ...deal,
                        dealItems:
                            data.map(item => ({
                                ...item, cells: this.createCells(item, this.grandchildFields)
                            })),
                        hasItems: data && data.length > 0
                    };
                }
                return deal;
            });
        })
        .catch(error => {
            console.error('Error fetching grandchild records:', error);
        });
    }
    handleNewDeal() {
        this.showNewDealForm = true;
    }

    handleCancel() {
        this.showNewDealForm = false;
    }

    handleSave() {
        const fields = this.template.querySelectorAll('lightning-input-field');
        let isValid = true;
        fields.forEach(field => {
            if (!field.reportValidity()) {
                isValid = false;
            }
        });
        if (!isValid) {
            return;
        }
        const form = this.template.querySelector('lightning-record-edit-form');
        if (form) {
            form.submit();
        }
    }
    handleSubmit(event) {
        event.preventDefault();
        const fields = event.detail.fields;
        fields[this.createParentFieldApiName] = this.recordId;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }
    handleSaveSuccess(event) {
        this.showNewDealForm = false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Deal created successfully.',
                variant: 'success'
            })
        );
        window.location.reload();
    }
    handleSaveError(event) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: event.detail.message,
                variant: 'error'
            })
        );
    }
}