import { api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class ModelComponent extends LightningModal {
    @api recordId;

    fields = ['Name', 'Industry', 'Phone', 'Region__c', 'AnnualRevenue'];
    options = [
        { id: 'cancel', label: 'Cancel', variant: 'neutral' },
        { id: 'save', label: 'Save', variant: 'brand' }
    ];

    handleOptionClick(event) {
        if(event.target.dataset.id == 'save') {
            this.template.querySelector('lightning-record-edit-form').submit();
        } else {
            this.close('cancel');
        }
    }

    handleSuccess() {
        this.close('success');
    }
}