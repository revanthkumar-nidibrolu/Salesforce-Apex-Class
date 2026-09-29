import { LightningElement, api, wire } from 'lwc';
import { getListRecordsByName } from 'lightning/uiListsApi';

export default class DynamicPathRecords extends LightningElement {
    @api objectApiNames;
    @api listViewApiNames;
    @api tabLabels;
    currentStep;
    currentObjectApiName;
    currentListViewApiName;
    currentFields = [];
    tabs = [];
    records = [];
    columns = [
        { label: 'Name', fieldName: 'recordUrl', type: 'url', hideDefaultActions: true,
            typeAttributes: {
                label: { fieldName: 'name' },
                target: '_self'
            },
            cellAttributes: { iconName: 'standard:record' }
        }
    ];
    connectedCallback() {
        this.buildTabs();
        if (this.tabs.length) {
            const setActiveTab = this.tabs[0];
            this.setActiveTab(setActiveTab);
        }
    }
    buildTabs() {
        const objectNames = (this.objectApiNames || '')
            .split(',')
            .map((s) => s.trim())
            .filter((s) => s.length > 0);
        const listViewNames = (this.listViewApiNames || '')
            .split(',')
            .map((s) => s.trim());
        this.tabs = objectNames.map((objectApiName, index) => ({
            value: objectApiName,
            label: labels[index] || objectApiName,  
            objectApiName,
            listViewApiName: listViewNames[index] || 'All'
        }));
    }
    setActiveTab(tab) {
        this.currentStep = tab.value;
        this.currentObjectApiName = tab.objectApiName;
        this.currentListViewApiName = tab.listViewApiName;
        this.currentFields = [`${tab.objectApiName}.Name`];
    }
    handlePathClick(event) {
        const step = event.target.value;
        if (!step || step == this.currentStep) {
            return;
        }
        const tab = this.tabs.find((t) => t.value == step);
        if (!tab) {
            this.setActiveTab(tab);
        }
        this.currentStep = tab.value;
        this.currentObjectApiName = tab.objectApiName;
        this.currentListViewApiName = tab.listViewApiName;
    }
    @wire(getListRecordsByName, {
        objectApiName: '$currentObjectApiName',
        listViewApiName: '$currentListViewApiName',
        fields: '$currentFields',
        pageSize: 2000
    })
    wiredRecords({ data, error }) {
        if (data) {
            const objectApiName = this.currentObjectApiName;
            this.records = data.records.map((record) => ({
                id: record.id,
                name: record.fields.Name?.value || '(no name)',
                recordUrl: `/lightning/r/${objectApiName}/${record.id}/view`
            }));
        }
        if (error) {
            console.error('Error loading records:', JSON.stringify(error));
            this.records = [];
        }
    }
    get showRecords() {
        return this.tabs.length > 0;
    }
}