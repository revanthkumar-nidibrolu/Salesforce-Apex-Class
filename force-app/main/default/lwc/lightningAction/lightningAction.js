import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class OpportunityCardAction extends LightningElement {
    @api recordId;
    leftFields = [
        { apiName: 'Name', required: true },
        { apiName: 'Tier__c', required: false },
        { apiName: 'Type__c', required: false }
    ];
    rightFields = [
        { apiName: 'Actice__c', required: false },
        { apiName: 'Compare_Field__c', required: false },
        { apiName: 'Opportunity__c', required: false }
    ];
    handleSuccess(event) {
        const cardId = event.detail.id;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Card created successfully.',
                variant: 'success'
            })
        );
        this.dispatchEvent(
            new CloseActionScreenEvent()
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
    handleCancel() {
        this.dispatchEvent(
            new CloseActionScreenEvent()
        );
    }
}