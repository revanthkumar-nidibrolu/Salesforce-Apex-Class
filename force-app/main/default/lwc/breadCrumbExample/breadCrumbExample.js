import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import ACCOUNT_NAME from '@salesforce/schema/Account.Name';
import PARENT_ID from '@salesforce/schema/Account.ParentId';
import PARENT_NAME from '@salesforce/schema/Account.Parent.Name';

export default class BreadcrumbExample extends NavigationMixin(LightningElement) {
    @api recordId;
    crumbs = [];

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [ACCOUNT_NAME],
        optionalFields: [PARENT_ID, PARENT_NAME]
    })
    wiredAccount({ data, error }) {
        if(data) {
            const list = [];
            list.push({ id: this.recordId, label: getFieldValue(data, ACCOUNT_NAME) });
            const parentId = getFieldValue(data, PARENT_ID);
            if(parentId) {
                list.push({ id: parentId, label: getFieldValue(data, PARENT_NAME) });
            }
            this.crumbs = list;
        } else if(error) {
            this.crumbs = [];
        }
    }

    handleNavigate(event) {
        event.preventDefault();
        const {id} = event.currentTarget.dataset;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: id,
                objectApiName: 'Account',
                actionName: 'view'
            }
        });
    }
}