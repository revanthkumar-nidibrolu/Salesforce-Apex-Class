import { LightningElement, api } from 'lwc';

export default class CreditCard extends LightningElement {

    @api bankId;
    values = {};
    fields = [
        { name: 'Name', label: 'Credit Card Name', required: true },
        { name: 'Card_Number__c', label: 'Card Number', required: true },
        { name: 'Cvv__c', label: 'Cvv', required: true },
        { name: 'Total_Limit__c', label: 'Total Limit', required: true },
        { name: 'Available_Limit__c', label: 'Available Limit', required: true }
    ];

    handleChange(event) {
        this.values[event.target.dataset.field] = event.detail.value;
    }

    handleCreate() {
        const inputs = this.template.querySelectorAll('lightning-input');
        const allValid = [...inputs].reduce(
            (valid, input) => input.reportValidity() && valid, true
        );
        if (!allValid) {
            return;
        }
        this.dispatchEvent(new CustomEvent('cardadded', {
            detail: { ...this.values, Bank__c: this.bankId }
        }));
    }
}