import { LightningElement, wire } from 'lwc';
import { getListUi } from 'lightning/uiListApi';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { updateRecord, deleteRecord } from 'lightning/uiRecordApi';
import { showToast } from 'c/toastClass';
import { NavigationMixin } from 'lightning/navigation';
import LightningConfirm from 'lightning/confirm';
import OPPORTUNITY_OBJECT from '@salesforce/schema/Opportunity';
import NAME_FIELD from '@salesforce/schema/Opportunity.Name';
import AMOUNT_FIELD from '@salesforce/schema/Opportunity.Amount';
import STAGENAME_FIELD from '@salesforce/schema/Opportunity.StageName';
import CLOSEDATE_FIELD from '@salesforce/schema/Opportunity.CloseDate';
import ACCOUNTNAME_FIELD from '@salesforce/schema/Opportunity.Account.Name';
import OWNERNAME_FIELD from '@salesforce/schema/Opportunity.Owner.Name';

const FIELDS = [NAME_FIELD, AMOUNT_FIELD, STAGENAME_FIELD, CLOSEDATE_FIELD, ACCOUNTNAME_FIELD, OWNERNAME_FIELD];
const RECORDS_PER_PAGE = 10;
const MAX_PAGE_BUTTONS = 5;

const ROW_ACTIONS = [
    { label: 'View', name: 'view' },
    { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' }
];

const COLUMNS = [
    { label: 'Opportunity Name', fieldName: 'Name', editable: true },
    { label: 'Amount', fieldName: 'Amount', sortable: true },
    { label: 'Stage', fieldName: 'StageName', type: 'picklist', editable: true,
        typeAttributes: { options: { fieldName: 'stageOptions' } } },
    { label: 'Close Date', fieldName: 'CloseDate' },
    { label: 'Account Name', fieldName: 'AccountName' },
    { label: 'Owner Name', fieldName: 'OwnerName' },
    { type: 'action', typeAttributes: { rowActions: ROW_ACTIONS, menuAlignment: 'auto' } }
];

export default class OpportunityDataTable extends NavigationMixin(LightningElement) {
    columns = COLUMNS;
    data = [];
    pageToken = null;
    rows = new Map();
    currentPage = 1;
    sortedBy;
    sortDirection = 'asc';
    searchTerm = '';
    stageOptions = [];
    draftValues = [];

    @wire(getListUi, {
        objectApiName: OPPORTUNITY_OBJECT,
        listViewApiName: 'AllOpportunities',
        fields: FIELDS,
        pageSize: 2000,
        pageToken: '$pageToken'
    })
    wiredList({ data, error }) {
        if(data) {
            data.records.records.forEach(rec => {
                this.rows.set(rec.id, {
                    Id: rec.id,
                    Name: rec.fields.Name.value,
                    Amount: rec.fields.Amount.value,
                    StageName: rec.fields.StageName.value,
                    CloseDate: rec.fields.CloseDate.value,
                    AccountName: rec.fields.Account?.value?.fields?.Name?.value ?? '',
                    OwnerName: rec.fields.Owner?.value?.fields?.Name?.value ?? ''
                });
            });
            this.data = Array.from(this.rows.values());
            const next = data.records.nextPageToken;
            if (next && next != this.pageToken) {
                this.pageToken = next;
            }
        } else if(error) {
            console.error(error);
        }
    }

    @wire(getObjectInfo, { objectApiName: OPPORTUNITY_OBJECT })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: STAGENAME_FIELD })
    wiredStageOptions({ data }) {
        if(data) {
            this.stageOptions = data.values.map(v => ({ label: v.label, value: v.value }));
        }
    }

    get filteredData() {
        const term = this.searchTerm.toLowerCase().trim();
        if (!term) {
            return this.data;
        }
        return this.data.filter(row =>
            [row.Name, row.Amount, row.StageName, row.CloseDate, row.AccountName, row.OwnerName]
                .some(value => String(value ?? '').trim().toLowerCase() == term)
        );
    }

    handleSearch(event) {
        this.searchTerm = event.target.value;
        this.currentPage = 1;
    }

    get sortedData() {
        if(!this.sortedBy) {
            return this.filteredData;
        }
        const dir = this.sortDirection == 'asc' ? 1 : -1;
        return [...this.filteredData].sort(
            (a, b) => ((a[this.sortedBy] ?? 0) - (b[this.sortedBy] ?? 0)) * dir
        );
    }

    handleSort(event) {
        this.sortedBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.currentPage = 1;
    }

    get totalPages() {
        return Math.max(1, Math.ceil(this.filteredData.length / RECORDS_PER_PAGE));
    }

    get pagedData() {
        const start = (this.currentPage - 1) * RECORDS_PER_PAGE;
        return this.sortedData
            .slice(start, start + RECORDS_PER_PAGE)
            .map(row => ({ ...row, stageOptions: this.stageOptions }));
    }

    get pageNumbers() {
        const total = this.totalPages;
        let start = Math.max(1, this.currentPage - Math.floor(MAX_PAGE_BUTTONS / 2));
        const end = Math.min(total, start + MAX_PAGE_BUTTONS - 1);
        start = Math.max(1, end - MAX_PAGE_BUTTONS + 1);
        const pages = [];
        for(let i = start; i <= end; i++) {
            pages.push({
                number: i,
                label: String(i),
                variant: i == this.currentPage ? 'brand' : 'neutral'
            });
        }
        return pages;
    }

    get isFirstPage() { return this.currentPage == 1; }
    get isLastPage() { return this.currentPage >= this.totalPages; }

    handlePrevious() {
        if(!this.isFirstPage) {
            this.currentPage -= 1;
        }
    }

    handleNext() {
        if(!this.isLastPage) {
            this.currentPage += 1;
        }
    }

    handlePageClick(event) {
        this.currentPage = Number(event.currentTarget.dataset.page);
    }

    handleRowAction(event) {
        const { action, row } = event.detail;
        switch (action.name) {
            case 'view':
                this.openRecord(row.Id, 'view');
                break;
            case 'edit':
                this.openRecord(row.Id, 'edit');
                break;
            case 'delete':
                this.deleteRow(row);
                break;
            default:
        }
    }

    openRecord(recordId, actionName) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: { recordId, objectApiName: 'Opportunity', actionName }
        });
    }

    async deleteRow(row) {
        const confirmed = await LightningConfirm.open({
            message: `Delete ${row.Name} opportunity record`,
            label: 'Delete Opportunity',
            theme: 'error'
        });
        if(!confirmed) {
            return;
        }

        try {
            await deleteRecord(row.Id);
            this.rows.delete(row.Id);
            this.data = Array.from(this.rows.values());
            this.draftValues = this.draftValues.filter(d => d.Id != row.Id);
            if(this.currentPage > this.totalPages) {
                this.currentPage = this.totalPages;
            }
            showToast(this, 'Success', 'Opportunity deleted', 'success');
        } catch(error) {
            showToast(this, 'Error', error.body?.message, 'error');
        }
    }

    async handleSave(event) {
        const snapshot = event.detail.draftValues.map(draft => ({ ...draft }));
        if(!snapshot.length) {
            return;
        }
        const results = await Promise.allSettled(
            snapshot.map(draft => updateRecord({ fields: { ...draft } }))
        );
        let savedCount = 0;
        let firstError;
        const remainingDrafts = [];
        results.forEach((result, index) => {
            const draft = snapshot[index];
            if(result.status == 'fulfilled') {
                const row = this.rows.get(draft.Id);
                if(row) {
                    Object.assign(row, draft);
                }
                savedCount += 1;
            } else {
                remainingDrafts.push(draft);
                if (!firstError) {
                    firstError = result.reason;
                }
            }
        });
        this.data = Array.from(this.rows.values());
        this.draftValues = remainingDrafts;
        if(savedCount) {
            showToast(this, 'Success', 'opportunities updated', 'success');
        }
        if(firstError) {
            showToast(this, 'Error', firstError.body?.message, 'error');
        }
    }
    handleCancel() {
        this.draftValues = [];
    }
}