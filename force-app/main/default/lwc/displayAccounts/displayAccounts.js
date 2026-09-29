import { LightningElement } from 'lwc';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class displayAccounts extends LightningElement {
    selectedAccountId = '';
    get buttonDisable(){
        return !! this.selectedAccountId;
    }
    accountChange(event) {
        this.selectedAccountId = event.detail.recordId;
    }
    async deleteAccount() {
        try {
            await deleteRecord(this.selectedAccountId);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Account deleted successfully',
                    variant: 'success'
                })
            );         
        } catch (error) {
            console.log(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error deleting record',
                    message: error.body.output.errors[0].message,
                    variant: 'error'
                })
            );
        }
    }
}