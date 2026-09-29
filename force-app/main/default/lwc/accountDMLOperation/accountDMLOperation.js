import { LightningElement, api } from 'lwc'; 
import { createRecord, updateRecord } from 'lightning/uiRecordApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import ACCOUNT_ID_FIELD from '@salesforce/schema/Account.Id';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class accountDMLOperation extends LightningElement {
    @api recordId;
    name;
    get isHomePage() {
        return !this.recordId;
    }
    get isRecordPage() {
        return this.recordId;
    }
    handleNameChange(event) {
        this.name = event.target.value;
    }
    handleCreateAccount() {
        const fields = {[NAME_FIELD.fieldApiName]: this.name};
        const recordInput = {apiName: ACCOUNT_OBJECT.objectApiName, fields};
        createRecord(recordInput)
            .then(account => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Account created: ' + account.fields.Name.value,
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body?.message || 'Error creating account',
                        variant: 'error'
                    })
                );
            }
        );
    }
    handleUpdateAccount() {
        const fields = {
            [ACCOUNT_ID_FIELD.fieldApiName]: this.recordId,
            [NAME_FIELD.fieldApiName]: this.name};
        const recordInput = {fields};
        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Account updated: ' + this.name,
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating record',
                        message: error.body?.message || 'Error updating account',
                        variant: 'error'
                    })
                );
            }
        );
    }
}