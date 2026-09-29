import { LightningElement, wire, api } from 'lwc';
    import { getListRecordsByName } from 'lightning/uiListsApi';

    const nameColumn = (iconName) => [
        { label: 'Name', fieldName: 'recordUrl', type: 'url', hideDefaultActions: true,
            typeAttributes: {
                label: { fieldName: 'name' },
                target: '_self'
            },
            cellAttributes: { iconName }
        }
    ];
    export default class HomePath extends LightningElement {
        @api opportunityListView = 'AllOpportunities';
        @api dealItemListView = 'All';
        @api cardListView = 'All';
        currentStep = 'opportunities';
        opportunities = [];
        dealItems = [];
        cards = [];
        opportunityColumns = nameColumn('standard:opportunity');
        dealItemColumns = nameColumn('standard:record');
        cardColumns = nameColumn('standard:record');
        @wire(getListRecordsByName, {
            objectApiName: 'Opportunity',
            listViewApiName: '$opportunityListView',
            fields: ['Opportunity.Name'],
            pageSize: 2000,
        })
        wiredOpportunities({ data, error }) {
            if (data) {
                this.opportunities = this.mapRecords(data.records, 'Opportunity');
            }
            if (error) {
                console.error('Opportunity Error:', JSON.stringify(error));
                this.opportunities = [];
            }
        }
        @wire(getListRecordsByName, {
            objectApiName: 'Deal_Item__c',
            listViewApiName: '$dealItemListView',
            fields: ['Deal_Item__c.Name'],
            pageSize: 2000
        })
        wiredDealItems({ data, error }) {
            if (data) {
                this.dealItems = this.mapRecords(data.records, 'Deal_Item__c');
            }
            if (error) {
                console.error('Deal Item Error:', JSON.stringify(error));
                this.dealItems = [];
            }
        }
        @wire(getListRecordsByName, {
            objectApiName: 'Card__c',
            listViewApiName: '$cardListView',
            fields: ['Card__c.Name'],
            pageSize: 2000
        })
        wiredCards({ data, error }) {
            if (data) {
                this.cards = this.mapRecords(data.records, 'Card__c');
            }
            if (error) {
                console.error('Card Error:', JSON.stringify(error));
                this.cards = [];
            }
        }
        mapRecords(records, objectApiName) {
            return records.map((record) => ({
                id: record.id,
                name: record.fields.Name?.value || '',
                recordUrl: `/lightning/r/${objectApiName}/${record.id}/view`
            }));
        }
        handlePathClick(event) {
            const step = event.target.value;
            if (!step) {
                return;
            }
            this.currentStep = step;
        }
        get showOpportunities() {
            return this.currentStep == 'opportunities';
        }
        get showDealItems() {
            return this.currentStep == 'dealitems';
        }
        get showCards() {
            return this.currentStep == 'cards';
        }
    }