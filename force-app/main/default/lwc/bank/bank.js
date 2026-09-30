import { LightningElement, api, wire } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import { refreshApex } from '@salesforce/apex';
import { showSuccessToast, showErrorToast } from 'c/toastClass';

export default class Bank extends LightningElement {
    @api recordId;
    cardCreated = false; 

    columns = [
        { label: 'Credit Card Name', fieldName: 'name', type: 'text' },
        { label: 'Card Number', fieldName: 'cardNumber', type: 'text', wrapText: true },
        { label: 'Total Limit', fieldName: 'totalLimit', type: 'currency',
          typeAttributes: { currencyCode: 'INR' }, cellAttributes: { alignment: 'left' } },
        { label: 'Available Limit', fieldName: 'availableLimit', type: 'currency',
          typeAttributes: { currencyCode: 'INR' }, cellAttributes: { alignment: 'left' } }
    ];

    @wire(getRelatedListRecords, {
        parentRecordId: '$recordId',
        relatedListId: 'Credit_Cards__r',
        fields: [
            'Credit_Card__c.Id',
            'Credit_Card__c.Name',
            'Credit_Card__c.Card_Number__c',
            'Credit_Card__c.Total_Limit__c',
            'Credit_Card__c.Available_Limit__c'
        ]
    })
    wiredCards;

    get cards() {
        return this.wiredCards.data
            ? this.wiredCards.data.records.map((r) => ({
                  id: r.id,
                  name: r.fields.Name.value,
                  cardNumber: r.fields.Card_Number__c.value,
                  totalLimit: r.fields.Total_Limit__c.value,
                  availableLimit: r.fields.Available_Limit__c.value
              }))
            : [];
    }

    get showForm() {
        return !this.cardCreated;
    }

    async handleCardAdded(event) {
        const numberFields = ['Card_Number__c', 'Cvv__c', 'Total_Limit__c', 'Available_Limit__c'];
        const fields = { ...event.detail };

        numberFields.forEach((f) => {
            fields[f] = fields[f] ? Number(fields[f]) : null;
        });

        try {
            await createRecord({ apiName: 'Credit_Card__c', fields });
            showSuccessToast(this, 'Card Created Successfully.');

            await refreshApex(this.wiredCards); 
            this.cardCreated = true;   
        } catch (error) {
            showErrorToast(this, error.body?.message); 
        }
    }

    handleAddAnother() {
        this.cardCreated = false;
    }
}