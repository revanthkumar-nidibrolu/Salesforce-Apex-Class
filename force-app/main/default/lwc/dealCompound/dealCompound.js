import { LightningElement, api, wire } from 'lwc';
import getRelatedDeals from '@salesforce/apex/OpportunityDealController.getDeals';
import getDealItems from '@salesforce/apex/OpportunityDealController.getDealItems';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DealCompound extends LightningElement {
    @api recordId;
    deals = [];
    showNewDealForm = false;
    leftFields = [
        { apiName: 'Name', required: true },
        { apiName: 'Active__c', required: false },
        { apiName: 'Amount__c', required: false }
    ];
    rightFields = [
        { apiName: 'Start_Date__c', required: false },
        { apiName: 'End_Date__c', required: false },
        { apiName: 'Opportunity__c', required: false }
    ];

    @wire(getRelatedDeals, { opportunityId: '$recordId' })
    wiredDeals({ error, data }) {
        if (data) {
            this.deals = data.map(deal => ({
                ...deal,
                isExpanded: false,
                dealItems: [],
                hasItems: false,
                iconName: 'utility:chevronright',
                rowClass: 'deal-row'
            }));
        } else if (error) {
            this.deals = [];
            console.error('Error fetching deals:', error);
        }
    }
    get hasDeals() {
        return this.deals.length > 0;
    }
    get dealRows() {
        return this.deals;
    }
    handleDealClick(event) {
        const dealId = event.currentTarget.dataset.id;
        const selectedDeal = this.deals.find( deal => deal.Id == dealId );
        if (!selectedDeal) {
            return;
        }
        if (selectedDeal.isExpanded) {
            this.deals = this.deals.map(deal => {
                if (deal.Id == dealId) {
                    return {
                        ...deal,
                        isExpanded: false,
                        iconName: 'utility:chevronright',
                        rowClass: 'deal-row'
                    };
                }
                return deal;
            });
            return;
        }
        this.deals = this.deals.map(deal => {
            if (deal.Id == dealId) {
                return {
                    ...deal,
                    isExpanded: true,
                    iconName: 'utility:chevrondown',
                    rowClass: 'deal-row selected'
                };
            }
            return {
                ...deal,
                isExpanded: false,
                iconName: 'utility:chevronright',
                rowClass: 'deal-row'
            };
        });
        this.loadDealItems(dealId);
    }
    loadDealItems(dealId) {
        getDealItems({ dealId: dealId })
        .then(data => {
            this.deals = this.deals.map(deal => {
                if (deal.Id == dealId) {
                    return {
                        ...deal,
                        dealItems: data,
                        hasItems: data && data.length > 0,
                    };
                }
                return deal;
            });
        })
        .catch(error => {
            console.error( 'Error fetching deal items:', error );
            this.deals = this.deals.map(deal => {
                if (deal.Id == dealId) {
                    return {
                        ...deal,
                        dealItems: [],
                        hasItems: false,
                    };
                }
                return deal;
            });
        });
    }
    get rightFieldsValue() {
        return this.rightFields.map(field => ({
            ...field,
            value: field.apiName == 'Opportunity__c' ? this.recordId : null
        }));
    }
    handleNewDeal() {
        this.showNewDealForm = true;
    }
    handleCancel() {
        this.showNewDealForm = false;
    }
    handleSave(event) {
        const fields = this.template.querySelectorAll('lightning-input-field');
        let isValid = true;
        fields.forEach(field => {
            if (!field.reportValidity()) {
                isValid = false;
            }
        });
        if (!isValid) {
            return;
        }
        const form = this.template.querySelector('lightning-record-edit-form');
        if (form) {
            form.submit();
        }
    }
    handleSaveSuccess(event) {
        this.showNewDealForm = false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Deal created successfully.',
                variant: 'success'
            })
        );
        window.location.reload();
    }
    handleSaveError(event) {
        console.error('Error creating deal:', event.detail);
    }
}