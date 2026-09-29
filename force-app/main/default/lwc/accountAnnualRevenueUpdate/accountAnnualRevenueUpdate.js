import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class accountAnnualRevenueUpdate extends LightningElement {
    @api recordId;
    isEditing = false;
    handleEdit() {
        this.isEditing = true;
    }
    handleCancel() {
        this.isEditing = false;
    }
    handleSuccess(event) {
        this.isEditing = false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Account Annual Revenue updated successfully',
                variant: 'success'
            })
        );
    }
    handleError(event) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: event.detail.message,
                variant: 'error'
            })
        );
    }
}