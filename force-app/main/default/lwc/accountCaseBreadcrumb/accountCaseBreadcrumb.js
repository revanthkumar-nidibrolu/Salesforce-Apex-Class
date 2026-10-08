import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import ACCOUNT_NAME from '@salesforce/schema/Account.Name';

export default class AccountCaseBreadcrumb extends NavigationMixin(LightningElement) {
    @api recordId;
    accountName;    
    caseOptions = [];
    selectedCaseId;

    @wire(getRecord, { recordId: '$recordId', fields: [ACCOUNT_NAME] })
    wiredAccount({ data, error }) {
        if(data) {
            this.accountName = getFieldValue(data, ACCOUNT_NAME);
        } else if(error) {
            console.error(error.body?.message);
        }
    }

    @wire(getRelatedListRecords, {
        parentRecordId: '$recordId',
        relatedListId: 'Cases',
        fields: ['Case.Id', 'Case.CaseNumber', 'Case.Subject'],
        pageSize: 10
    })
    wiredCases({ data, error }) {
        if(data) {
            this.caseOptions = data.records.map((record) => {
                const number = record.fields.CaseNumber.value;
                return {
                    label: number,
                    value: record.id,
                    number
                };
            });
        } else if(error) {
            this.caseOptions = [];
            console.error(error.body?.message);
        }
    }

    get noCases() {
        return this.caseOptions.length == 0;
    }

    get crumbs() {
        const list = [];
        if(this.accountName) {
            list.push({ id: 'account', label: this.accountName, type: 'account' });
        }
        list.push({ id: 'cases', label: 'Cases', type: 'cases' });
        const selected = this.caseOptions.find((option) => option.value == this.selectedCaseId);
        if(selected) {
            list.push({ id: selected.value, label: selected.number, type: 'case' });
        }
        return list;
    }

    handleCaseChange(event) {
        this.selectedCaseId = event.detail.value;
    }

    handleCrumbClick(event) {
        event.preventDefault();
        const { id, type } = event.currentTarget.dataset;

        if(type == 'account') {
            this.selectedCaseId = undefined;
        } else if(type == 'cases') {
            this.selectedCaseId = undefined;
            this.template.querySelector('lightning-combobox').focus();
        } else if(type == 'case') {                                    
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: id,
                    objectApiName: 'Case',
                    actionName: 'view'
                }
            });
        }
    }
}