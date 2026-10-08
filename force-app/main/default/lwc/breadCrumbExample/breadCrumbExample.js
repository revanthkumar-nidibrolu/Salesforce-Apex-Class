import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import ACCOUNT_NAME from '@salesforce/schema/Account.Name';
import PARENT_ID from '@salesforce/schema/Account.ParentId';
import PARENT_NAME from '@salesforce/schema/Account.Parent.Name';

const STORAGE_KEY = 'breadcrumbAccountTrail';

export default class BreadcrumbExample extends NavigationMixin(LightningElement) {
    @api recordId;
    crumbs = [];
    accountName;
    previous = [];

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [ACCOUNT_NAME],
        optionalFields: [PARENT_ID, PARENT_NAME]
    })
    wiredAccount({ data, error }) {
        if(data) {
            this.accountName = getFieldValue(data, ACCOUNT_NAME);
            this.previous = this.loadPrevious();
            const list = [];
            const lastPrevious = this.previous[this.previous.length - 1];
            if(lastPrevious) {
                list.push({ id: lastPrevious.id, label: lastPrevious.name, type: 'previous' });
            }
            list.push({ id: this.recordId, label: this.accountName, type: 'current' });
            const parentId = getFieldValue(data, PARENT_ID);
            if(parentId) {
                list.push({ id: parentId, label: getFieldValue(data, PARENT_NAME), type: 'parent' });
            }
            this.crumbs = list;
        } else if(error) {
            this.crumbs = [];
        }
    }

    handleNavigate(event) {
        event.preventDefault();
        const { id, type } = event.currentTarget.dataset;
        if(type == 'current') {
            return;
        }
        if(type == 'parent') {
            const trail = [ ...this.previous,
                { id: this.recordId, name: this.accountName }
            ];
            this.saveTrail(trail, id);
        }
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: id,
                objectApiName: 'Account',
                actionName: 'view'
            }
        });
    }

    saveTrail(trail, forId) {
        try {
            sessionStorage.setItem(STORAGE_KEY, JSON.stringify({ trail, forId }));
        } catch(e) {
        }
    }

    loadPrevious() {
        try {
            const saved = JSON.parse(sessionStorage.getItem(STORAGE_KEY));
            if(!saved) {
                return [];
            }
            if(saved.forId == this.recordId) {
                return saved.trail;
            }
            const index = saved.trail.findIndex((p) => p.id == this.recordId);
            if(index != -1) {
                const trimmed = saved.trail.slice(0, index);
                this.saveTrail(trimmed, this.recordId);
                return trimmed;
            }
        } catch(e) {
        }
        return [];
    }
}