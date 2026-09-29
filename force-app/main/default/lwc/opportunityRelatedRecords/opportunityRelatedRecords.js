import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import OPPORTUNITY_AMOUNT from '@salesforce/schema/Opportunity.Amount';
import NoDealsFound from '@salesforce/label/c.NoDealsFound';

const COLUMNS = [
    { label: 'Deal Name', fieldName: 'Name' },
    { label: 'Active', fieldName: 'Active__c' },
    { label: 'Amount', fieldName: 'Amount__c' },
    { label: 'Start Date', fieldName: 'Start_Date__c' },
    { label: 'End Date', fieldName: 'End_Date__c' }
];

export default class OpportunityRelatedRecords extends LightningElement {
    @api recordId;
    columns = COLUMNS;
    datatable = [];
    opportunityAmount;
    label = { NoDealsFound };

    get relatedListFields() {
        return COLUMNS.map(col => `Deal__c.${col.fieldName}`);
    }

    get parentIdForDeals() {
        return (this.opportunityAmount >= 10000) ? this.recordId : null;
    }

    @wire(getRecord, { recordId: '$recordId', fields: [OPPORTUNITY_AMOUNT] })
    wiredOpportunity({ error, data }) {
        if (data) {
            this.opportunityAmount = getFieldValue(data, OPPORTUNITY_AMOUNT);
        } else if (error) {
            console.error('Error fetching Opportunity:', error);
        }
    }

    @wire(getRelatedListRecords, {
        parentRecordId: '$parentIdForDeals',
        relatedListId: 'Deals__r',
        fields: '$relatedListFields'
    })
    wiredRelatedDeals({ error, data }) {
        if (data) {
            this.datatable = data.records.map(record => {
                const row = { Id: record.Id };
                COLUMNS.forEach(col => {
                    const fieldName = col.fieldName;
                    row[fieldName] = record.fields[fieldName]?.value ?? '';
                });
                return row;
            });
        } else if (error) {
            console.error('Error fetching deals:', error);
        }
    }

    get hasDeals() {
        return this.datatable.length > 0;
    }
}