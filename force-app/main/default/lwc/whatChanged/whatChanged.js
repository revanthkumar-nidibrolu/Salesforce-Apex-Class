import { LightningElement, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getRecentHistory from '@salesforce/apex/RecordHistory24HoursController.getRecentHistory';
import NoFieldChangesMessage from '@salesforce/label/c.NoFieldChangesMessage'

const COLUMNS = [
    { label: 'Field', fieldName: 'fieldLabel' },
    { label: 'Old Value', fieldName: 'oldValue' },
    { label: 'New Value', fieldName: 'newValue' },
    { label: 'Changed By', fieldName: 'changedByName' },
    { label: 'Date/Time', fieldName: 'changedDate',
        typeAttributes: { year: 'numeric', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit'}
    }
];

export default class WhatChanged extends LightningElement {
    @api recordId;
    columns = COLUMNS;
    history = [];
    errorMessage;
    wiredResult;
    label={NoFieldChangesMessage};

    @wire(getRecentHistory, { recordId: '$recordId' })
    wiredHistory(result) {
        this.wiredResult = result;
        if(result.data) {
            this.history = result.data;
            this.errorMessage = undefined;
        }else if(result.error) {
            this.history = [];
            this.errorMessage = this.extractErrorMessage(result.error);
        }
    }

    get hasHistory() {
        return this.history && this.history.length > 0;
    }

    get isEmpty() {
        return !this.errorMessage && !this.hasHistory;
    }

    handleRefresh() {
        refreshApex(this.wiredResult);
    }

    extractErrorMessage(error) {
        if(error && error.body && error.body.message) {
            return error.body.message;
        }
        if(error && error.message) {
            return error.message;
        }
        return 'An unknown error occurred while loading record history.';
    }
}