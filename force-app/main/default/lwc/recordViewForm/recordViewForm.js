import { LightningElement, wire, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

export default class RecordViewForm extends LightningElement {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: ['StageName', 'CloseDate', 'Amount'] })
    opportunity;  

    get opportunityFields() {
        return ['StageName', 'CloseDate', 'Amount'];
    }
}