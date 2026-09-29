import { LightningElement, api, wire } from 'lwc';
import listOfAccount from '@salesforce/apex/AccountContactController.getRelatedContacts';

export default class AccountDetailCard extends LightningElement {
    @api recordId;
    selectedAccountId;
    accountOptions = [];
    connectedCallback() {
        if (this.recordId) {
            this.selectedAccountId = this.recordId;
        }
    }
    @wire(listOfAccount)
    wiredAccounts({ error, data }) {
        if (data) {
            this.accountOptions = data.map(acc => ({
                label: acc.Name,
                value: acc.Id
            }));
            if (!this.selectedAccountId && this.accountOptions.length > 0) {
                this.selectedAccountId = this.accountOptions[0].value;
            }
        }
    }
    handleAccountChange(event) {
        this.selectedAccountId = event.detail.value;
        console.log('[PARENT] Selected Account changed to:', this.selectedAccountId);
    }
}