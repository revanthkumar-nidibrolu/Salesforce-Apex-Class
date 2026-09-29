import { LightningElement, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import PHONE_FIELD from '@salesforce/schema/Account.Phone';
import INDUSTRY_FIELD from '@salesforce/schema/Account.Industry';
import TYPE_FIELD from '@salesforce/schema/Account.Type';
import ANNUALREVENUE_FIELD from '@salesforce/schema/Account.AnnualRevenue';
import RATING_FIELD from '@salesforce/schema/Account.Rating';

const FIELDS = [NAME_FIELD, PHONE_FIELD, INDUSTRY_FIELD, TYPE_FIELD, ANNUALREVENUE_FIELD, RATING_FIELD];

const COLUMNS = [
    { label: 'Account Name', fieldName: 'Name', cellAttributes: {style: { fieldName: 'rowStyle' }}},
    { label: 'Phone', fieldName: 'Phone', cellAttributes: {style: { fieldName: 'rowStyle' }} },
    { label: 'Industry', fieldName: 'Industry', cellAttributes: {style: { fieldName: 'rowStyle' }} },
    { label: 'Type', fieldName: 'Type', cellAttributes: {style: { fieldName: 'rowStyle' }} },
    { label: 'Annual Revenue', fieldName: 'AnnualRevenue', cellAttributes: {style: { fieldName: 'rowStyle' }} },
    { label: 'Rating', fieldName: 'Rating', cellAttributes: {style: { fieldName: 'rowStyle' }} }
];

export default class accountColorHighLate extends LightningElement {
    columns = COLUMNS;
    selectedAccountId = '';
    datatable = [];
    @wire(getRecord, {recordId: '$selectedAccountId', fields: FIELDS})
    wireAccount({data, error}){
        if(data){
            this.datatable = [{
                Id: this.selectedAccountId,
                Name: getFieldValue(data, NAME_FIELD),
                Phone: getFieldValue(data, PHONE_FIELD),
                Industry: getFieldValue(data, INDUSTRY_FIELD),
                Type: getFieldValue(data, TYPE_FIELD),
                AnnualRevenue: getFieldValue(data, ANNUALREVENUE_FIELD),
                Rating: getFieldValue(data, RATING_FIELD),
                rowStyle: 'background-color: #b7eadf'
            }];
        }else if(error){
            this.datatable=[];
        }
    }
    accountChange(event){
        this.selectedAccountId = event.detail.recordId;
        if(!this.selectedAccountId){
            this.datatable=[];
        }
    }
}