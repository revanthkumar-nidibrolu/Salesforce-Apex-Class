import { LightningElement, wire } from 'lwc';
import getAccounts from '@salesforce/apex/AccountController.accountList';
import getContactsByAccountId from '@salesforce/apex/AccountController.accountRelatedContacts';

export default class AccountSelector extends LightningElement {
    accountOptions = [];
    selectedAccountId = '';
    contacts = [];
    constructor() {
        super();
        console.log('[PARENT] 1. Constructor');
    }
    connectedCallback() {
        console.log('[PARENT] 2. ConnectedCallback');
    }
    @wire(getAccounts)
    wiredAccounts({ data, error }) {
        if (data) {
            this.accountOptions = data.map(acc => ({
                label: acc.Name,
                value: acc.Id
            }));
        } else if (error) {
            console.error('[PARENT] Wire error:', error);
        }
    }
    async handleAccountChange(event) {
        this.selectedAccountId = event.detail.value;
        console.log(`[PARENT] Selected Account ID changed to: ${this.selectedAccountId}`);
        try {
            this.contacts = await getContactsByAccountId({ accountId: this.selectedAccountId });
        } catch (err) {
            console.error('[PARENT] Error loading contacts:', err);
        }
    }
    renderedCallback() {
        console.log('[PARENT] 3. RenderedCallback');
    }
    disconnectedCallback() {
        console.log('[PARENT] 4. DisconnectedCallback');
    }
    get hasContacts() {
        return this.contacts && this.contacts.length > 0;
    }
}