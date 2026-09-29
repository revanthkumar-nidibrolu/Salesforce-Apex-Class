import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AccountLightningCompound extends LightningElement {
    selectedRecordId = null;
    isOpportunityStep = false;
    showPicker = true;
    get isAccountStep() {
        return !this.isOpportunityStep;
    }
    get isNextDisabled() {
        return !this.selectedRecordId;
    }
    handleRecordChange(event) {
        this.selectedRecordId = event.detail.recordId;
    }
    handleNext() {
        if(this.selectedRecordId) {
            this.isOpportunityStep = true;
        }
    }
    handleBack() {
        this.isOpportunityStep = false;
    }
    handleAccountClear() {
        this.selectedRecordId = null;
        this.showPicker = false;
        Promise.resolve().then(() => {
            this.showPicker = true;
        });
    }
    handleSuccess(event) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Opportunity created successfully.',
                variant: 'success'
            })
        );
        this.selectedRecordId = null;
        this.isOpportunityStep = false;
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