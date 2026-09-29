import { LightningElement, wire, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import ACCOUNT_ID_FIELD from '@salesforce/schema/Contact.AccountId';
import ACCOUNT_NAME_FIELD from '@salesforce/schema/Account.Name';

export default class ChainedWires extends LightningElement {
    @api recordId;
    accountId;
    @wire(getRecord, { recordId: '$recordId', fields: [ACCOUNT_ID_FIELD] })
    wiredContact({ error, data }) {
        if (data) {
            this.accountId = getFieldValue(data, ACCOUNT_ID_FIELD);
        } else if (error) {
            console.error('Error fetching Contact record:', error);
        }
    }
    @wire(getRecord, { recordId: '$accountId', fields: [ACCOUNT_NAME_FIELD] })
    wiredAccount;
    get accountName() {
        return this.wiredAccount && this.wiredAccount.data
            ? getFieldValue(this.wiredAccount.data, ACCOUNT_NAME_FIELD)
            : null;
    }
}