import { LightningElement, api, wire } from 'lwc';
import getRelatedContacts from '@salesforce/apex/AccountContactController.getRelatedContacts';

export default class AccountContactList extends LightningElement {
    _accountId;
    contacts;
    error;

    @api 
    get accountId() {
        return this._accountId;
    }
    set accountId(value) {
        this._accountId = value;
    }

    @wire(getRelatedContacts, { accountId: '$accountId' })
    wiredContacts({ error, data }) {
        if (data) {
            this.contacts = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.contacts = undefined;
        }
    }

    // Safely check length without throwing an error when contacts is undefined
    get contactCount() {
        return this.contacts ? this.contacts.length : 0;
    }

    get hasContacts() {
        return this.contacts && this.contacts.length > 0;
    }
}