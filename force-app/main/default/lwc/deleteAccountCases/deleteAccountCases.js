import { LightningElement, wire } from 'lwc';
import { showSuccessToast, showErrorToast } from 'c/toastClass';
import { deleteRecord } from 'lightning/uiRecordApi';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';

export default class DeleteAccountCases extends LightningElement {
    selectedAccountId = '';
    selectedCases = [];
    caseLookup = {};
    showPicker = true;

    get isCasePickerDisabled() {
        return !this.selectedAccountId;
    }
    get isDeleteDisabled() {
        return !this.selectedCases.length;
    }
    get hasSelectedCases() {
        return !!this.selectedCases.length;
    }
    get caseFilter() {
        const criteria = [
            { fieldPath: 'AccountId', operator: 'eq', value: this.selectedAccountId }
        ];
        this.selectedCases.forEach(c => criteria.push({ fieldPath: 'Id', operator: 'ne', value: c.name }));
        return { criteria };
    }

    @wire(getRelatedListRecords, {
        parentRecordId: '$selectedAccountId',
        relatedListId: 'Cases',
        fields: ['Case.Id', 'Case.CaseNumber']
    })
    
    wiredCases({ data }) {
        this.caseLookup = data ? Object.fromEntries(data.records.map(r =>
            [r.fields.Id.value, r.fields.CaseNumber.value])) : {};
    }

    resetPicker() {
        this.showPicker = false;
        Promise.resolve().then(() => { this.showPicker = true; });
    }

    handleAccountChange(event) {
        this.selectedAccountId = event.detail.recordId;
        this.selectedCases = [];
        this.caseLookup = {};
    }

    handleCaseChange(event) {
        const caseId = event.detail.recordId;
        if(!caseId || this.selectedCases.some(c => c.name == caseId)) return;
        this.selectedCases = [...this.selectedCases,
            { label: this.caseLookup[caseId] || caseId, name: caseId, iconName: 'standard:case' }
        ];
        this.resetPicker();
    }

    handlePillRemove(event) {
        event.stopPropagation();
        this.selectedCases = this.selectedCases.filter(c => c.name != event.detail.item.name);
    }

    handleCancel() {
        this.selectedAccountId = null;
        this.selectedCases = [];
        this.resetPicker();
    }
    
    async handleDelete() {
        for(const c of this.selectedCases) {
            try {
                await deleteRecord(c.name);
            } catch (error) {
                showErrorToast(this, `Failed to delete case ${c.label}: ${error?.body?.message}`);
                return;
            }
        }
        if(this.selectedAccountId) {
            try {
                await deleteRecord(this.selectedAccountId);
            } catch (error) {
                showErrorToast(this, `Case deleted, but account deletion failed: ${error.body.output.errors[0].message}`);
                this.selectedCases = [];
                this.resetPicker();
                return;
            }
        }
        showSuccessToast(this, 'Records deleted successfully!');
        this.handleCancel();
    }
}