import { LightningElement, api } from 'lwc';
import { showSuccessToast, showErrorToast } from 'c/toastClass';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class DynamicRecordAction extends LightningElement {
    @api recordId;

    get leftfields() {
        return [
            { apiName: 'Name', required: true },
            { apiName: 'Floor__c', required: true },
            { apiName: 'Unit_type__c', required: true },
            { apiName: 'Area_Sq_Ft__c', required: true }
        ];
    }

    get rightfields() {
        return [
            { apiName: 'Price__c', required: true },
            { apiName: 'Status__c', required: true },
            { apiName: 'Facing__c', required: true },
            { apiName: 'Property__c', value: this.recordId, disabled: true }
        ];
    }

    handleSuccess(event) {
        showSuccessToast(this, 'Property Unit created successfully.');
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