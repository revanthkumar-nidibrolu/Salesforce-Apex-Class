import { LightningElement, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import ACCOUNT_NAME from '@salesforce/schema/Account.Name';
import PHONE from '@salesforce/schema/Account.Phone';
import ANNUAL_REVENUE from '@salesforce/schema/Account.AnnualRevenue';
import PARENT_ID from '@salesforce/schema/Account.ParentId';
import PARENT_NAME from '@salesforce/schema/Account.Parent.Name';

const COLUMNS = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Phone', fieldName: 'Phone' },
    { label: 'Annual Revenue', fieldName: 'AnnualRevenue' }
];

export default class BreadCrumbInHomepage extends LightningElement {
    columns = COLUMNS;
    currentId;
    account = {};
    history = []; 

    @wire(getRecord, {
        recordId: '$currentId',
        fields: [ACCOUNT_NAME],
        optionalFields: [PHONE, ANNUAL_REVENUE, PARENT_ID, PARENT_NAME]
    })
    wiredAccount({ data, error }) {
        if(data) {
            this.account = {
                Id: data.id,
                Name: getFieldValue(data, ACCOUNT_NAME),
                Phone: getFieldValue(data, PHONE),
                AnnualRevenue: getFieldValue(data, ANNUAL_REVENUE),
                ParentId: getFieldValue(data, PARENT_ID),
                ParentName: getFieldValue(data, PARENT_NAME)
            };
        } else if(error) {
            this.account = {};
        }
    }

    get hasAccount() {
        return Boolean(this.currentId && this.account.Name);
    }

    get rows() {
        return this.hasAccount ? [this.account] : [];
    }

    get hasParent() {
        return Boolean(this.account.ParentId);
    }

    get parentLabel() {
        return this.account.ParentName;
    }

    get crumbs() {
        if(!this.hasAccount) {
            return [];
        }
        const list = this.history.slice(-1).map((item) => ({ id: item.id, label: item.name, type: 'history' }));
        list.push({ id: this.currentId, label: this.account.Name, type: 'current' });
        return list;
    }

    handleAccountChange(event) {
        this.history = [];
        this.currentId = event.detail.recordId;
        if(!this.currentId) {
            this.account = {};
        }
    }

    handleParentClick() {
        if(!this.hasParent) {
            return;
        }
        this.history = [ ...this.history, { id: this.currentId, name: this.account.Name} ];
        this.currentId = this.account.ParentId;
    }

    handleCrumbClick(event) {
        event.preventDefault();
        const { id, type } = event.currentTarget.dataset;
        if(type != 'history') {
            return;
        }
        const index = this.history.findIndex((item) => item.id == id);
        if(index != -1) {
            this.history = this.history.slice(0, index);
            this.currentId = id;
        }
    }
}