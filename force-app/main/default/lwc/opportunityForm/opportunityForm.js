import { LightningElement, api } from 'lwc';
import { showSuccessToast, showErrorToast } from 'c/toastClass';

export default class OpportunityForm extends LightningElement {
    @api selectedRecordId;
    handleSubmit(event) {
        const fields = { ...event.detail.fields };
        fields.AccountId = this.selectedRecordId;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }
    handleBack() {
        this.dispatchEvent(new CustomEvent('back'));
    }
    handleClear() {
        const fields = this.template.querySelectorAll('.resettable-field');
        fields.forEach((field) => field.reset());
        this.dispatchEvent(new CustomEvent('clear'));
    }
    handleSuccess() {
        showSuccessToast(this, 'Opportunity created successfully.');
        this.dispatchEvent(new CustomEvent('success'));
    }
    handleError(event) {
        showErrorToast(this, event.detail.message);
    }
}