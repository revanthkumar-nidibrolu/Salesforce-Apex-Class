import { LightningElement, wire, api } from 'lwc';
import getUserDepartment from '@salesforce/apex/UserController.userDepartment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class userDepartment extends LightningElement {
    @api recordId;
    userDepartment = '';
    isAdmin = false;
    isViewMode = true;
    accountFields = ['Name', 'AnnualRevenue', 'Industry', 'Phone', 'Rating', 'Type'];
    @wire(getUserDepartment)
    wiredDepartment({ data, error }) {
        if (data) {
            this.userDepartment = data;
            this.isAdmin =
                data.trim().toLowerCase() === 'admin';
        }else if (error) {
            this.isAdmin = false;
            console.error('Department error:', error);
        }
    }
    accountChange(event){
        this.recordId = event.detail.recordId;
        this.isViewMode = true;
    }
    handleEdit(event) {
        if (!this.isAdmin) {
            return;
        }
        this.isViewMode = false;
    }
    handleCancel() {
        this.isViewMode = true;
    }
    handleSuccess() {
        this.isViewMode = true;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Account updated successfully',
                variant: 'success'
            })
        );
    }
    handleError(event) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: event.detail.message,
                variant: 'error'
            })
        );
    }
}