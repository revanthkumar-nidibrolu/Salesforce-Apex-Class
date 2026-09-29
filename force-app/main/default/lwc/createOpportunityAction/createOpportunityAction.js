import { LightningElement, api } from 'lwc';
import { showSuccessToast, showErrorToast } from 'c/toastClass';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class CreateOpportunityAction extends LightningElement {
    @api recordId;

    get leftfields() {
        return [
            { apiName: 'Name', required: true },
            { apiName: 'StageName', required: true },
            { apiName: 'Start_Date__c', required: false },
            { apiName: 'End_Date__c', required: false }
        ];
    }

    get rightfields() {
        return [
            { apiName: 'Amount', required: true },
            { apiName: 'CloseDate', required: true },
            { apiName: 'Type', required: true },
            { apiName: 'AccountId', value: this.recordId, disabled: true }
        ];
    }

    handleSuccess(event) {
        showSuccessToast(this, 'Opportunity created successfully.');
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleError(event) {
        showErrorToast(this, event.detail.message);
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleSave() {
        const fields = this.template.querySelectorAll('lightning-input-field');
        let isValid = true;
        fields.forEach(field => {
            if (!field.reportValidity()) {
                isValid = false;
            }
        });
        if (isValid) {
            this.refs.editForm.submit();
        }
    }
}