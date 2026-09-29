import { LightningElement, api, wire } from 'lwc';
import getAccountTeamHistories from '@salesforce/apex/AccountTeamHistoryController.getAccountTeamHistories';

const COLUMNS = [
    { label: 'History Number', fieldName: 'Name'},
    { label: 'User', fieldName: 'UserName'}, 
    { label: 'Role', fieldName: 'Role__c'},
    { label: 'Quarter', fieldName: 'Quarter__c'},
    { label: 'Delete', fieldName: 'Delete__c', type: 'boolean'},
    { label: 'Changed User', fieldName: 'ChangedUserName'},
    { label: 'Closed Date', fieldName: 'Closed_Date__c', type: 'date-local'}];
export default class AccountTeamHistoryTable extends LightningElement {
    @api recordId;
    columns = COLUMNS;
    data = [];
    wiredHistoryResult;
    @wire(getAccountTeamHistories, { accountId: '$recordId' })
    wiredHistories(result) {
        this.wiredHistoryResult = result;
        if (result.data) {
            this.data = result.data.map(row => {
                return {
                    ...row,
                    UserName: row.User__r ? row.User__r.Name : '',
                    ChangedUserName: row.Changed_User__r ? row.Changed_User__r.Name : ''
                };
            });
        } else if (result.error) {
            this.showToast('Error', 'Failed to load records', 'error');
        }
    }
}