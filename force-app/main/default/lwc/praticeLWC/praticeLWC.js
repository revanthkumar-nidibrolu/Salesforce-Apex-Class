import { LightningElement} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord } from 'lightning/uiRecordApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import NAME_FIELD from '@salesforce/schema/Account.Name';

export default class PraticeLWC extends LightningElement {
    accountName = '';
    handleAccountName(event){
        this.accountName = event.target.value;
    }
    createAccount(){
        if(!this.accountName){
            this.showToast('Error', 'Account Name is blank', 'error');
            return;
        }
        const fields = {};
        fields[NAME_FIELD.fieldApiName] = this.accountName;
        const recordInput = {apiName: ACCOUNT_OBJECT.objectApiName, fields};
        createRecord(recordInput)
        .then(account => {
            this.showToast('Success', 'Account created successfully', 'success');
            this.accountName = '';
        })
        .catch(error => {
            this.showToast('Error', 'Error creating account', 'error');
        });
    }
    showToast(title, message, variant){
        const event = new ShowToastEvent({title, message, variant});
        this.dispatchEvent(event);
    }
}