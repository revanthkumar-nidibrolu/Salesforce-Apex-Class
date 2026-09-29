import { LightningElement } from 'lwc';

export default class parentCompoundAccount extends LightningElement {
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
    handleSuccess() {
        this.selectedRecordId = null;
        this.isOpportunityStep = false;
    }
}