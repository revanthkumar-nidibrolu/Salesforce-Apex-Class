import { LightningElement, wire, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/Opportunity.Name';
import AMOUNT_FIELD from '@salesforce/schema/Opportunity.Amount';
import STAGENAME_FIELD from '@salesforce/schema/Opportunity.StageName';
import CLOSEDDATE_FIELD from '@salesforce/schema/Opportunity.CloseDate';
import ACCOUNTNAME_FIELD from '@salesforce/schema/Opportunity.Account.Name';
import OWNERNAME_FIELD from '@salesforce/schema/Opportunity.Owner.Name';

const FIELDS = [NAME_FIELD, AMOUNT_FIELD, STAGENAME_FIELD,CLOSEDDATE_FIELD, ACCOUNTNAME_FIELD, OWNERNAME_FIELD];

const COLUMNS = [
    { label: 'Opportunity Name', fieldName: 'Name' },
    { label: 'Amount', fieldName: 'Amount' },
    { label: 'Stage', fieldName: 'StageName' },
    { label: 'Close Date', fieldName: 'CloseDate' },
    { label: 'Account Name', fieldName: 'AccountName' },
    { label: 'Owner Name', fieldName: 'OwnerName' }
];

export default class AccountColorHighLate extends LightningElement {
    @api recordId;
    columns = COLUMNS;
    datatable = [];

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wireOpportunity({ data, error }) {
        if (data) {
            this.datatable = [{
                Id: this.recordId,
                Name: getFieldValue(data, NAME_FIELD),
                Amount: getFieldValue(data, AMOUNT_FIELD),
                StageName: getFieldValue(data, STAGENAME_FIELD),
                CloseDate: getFieldValue(data, CLOSEDDATE_FIELD),
                AccountName: getFieldValue(data, ACCOUNTNAME_FIELD),
                OwnerName: getFieldValue(data, OWNERNAME_FIELD)
            }];
        } else if (error) {
            this.datatable = [];
        }
    }
}