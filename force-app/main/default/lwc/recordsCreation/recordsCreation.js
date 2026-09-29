import { LightningElement, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { createRecord, getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { showSuccessToast, showErrorToast } from 'c/toastClass';
import ACCOUNT_NAME from '@salesforce/schema/Account.Name';

const STEPS = [
    {
        value: 'bank',
        label: 'Bank',
        objectApiName: 'Bank__c',
        parentField: 'Account__c',
        multiple: true,
        fields: [
            { apiName: 'Name', label: 'Bank Name', required: true },
            { apiName: 'Account_Holder_Name__c', label: 'Account Holder Name', required: true },
            { apiName: 'Account_Number__c', label: 'Account Number', required: true },
            { apiName: 'IFSC__c', label: 'IFSC', required: true },
            { apiName: 'Branch__c', label: 'Branch', required: true }
        ]
    },
    {
        value: 'card',
        label: 'Credit Card',
        objectApiName: 'Credit_Card__c',
        parentField: 'Bank__c',
        parentStep: 'bank',
        parentLabel: 'Bank',
        multiple: true,
        fields: [
            { apiName: 'Name', label: 'Card Name', required: true },
            { apiName: 'Card_Number__c', label: 'Card Number', required: true },
            { apiName: 'Total_Limit__c', label: 'Total Limit', required: true },
            { apiName: 'Available_Limit__c', label: 'Available Limit', required: true }
        ]
    },
    {
        value: 'transaction',
        label: 'Transaction',
        objectApiName: 'Credit_Card_Transaction__c',
        parentField: 'Credit_Card__c',
        parentStep: 'card',
        parentLabel: 'Card',
        multiple: true,
        fields: [
            { apiName: 'Name', label: 'Card Name', required: true },
            { apiName: 'Card_Number__c', label: 'Card Number', required: true },
            { apiName: 'Amount__c', label: 'Amount', type: 'number', required: true },
            { apiName: 'Payment_Status__c', label: 'Payment Status', required: true },
            { apiName: 'Transaction_Date__c', label: 'Transaction Date', type: 'date', required: true }
        ]
    }
];
const FIELDS_VISIBLE = 5;
const GAP_REM = 0.75;

export default class RecordsCreation extends LightningElement {
    @api recordId;

    steps = STEPS;
    currentStep = STEPS[0].value;
    rowCounter = 0;
    isSaving = false;
    rows = this.buildInitialRows();

    buildInitialRows() {
        const rows = {};
        STEPS.forEach((s) => {
            rows[s.value] = [{ key: ++this.rowCounter, parentKey: null, values: {} }];
        });
        return rows;
    }

    @wire(getRecord, { recordId: '$recordId', fields: [ACCOUNT_NAME] })
    account;

    get accountName() {
        return getFieldValue(this.account.data, ACCOUNT_NAME);
    }

    get currentIndex() {
        return this.steps.findIndex((s) => s.value == this.currentStep);
    }

    get currentStepConfig() {
        return this.steps[this.currentIndex];
    }

    get isMultiple() {
        return this.currentStepConfig.multiple;
    }

    get isFirstStep() {
        return this.currentIndex == 0;
    }

    get showBack() {
        return !this.isFirstStep;
    }

    get isLastStep() {
        return this.currentIndex == this.steps.length - 1;
    }

    get hasParent() {
        return !!this.currentStepConfig.parentStep;
    }

    get parentLabel() {
        return this.currentStepConfig.parentLabel;
    }

    get parentOptions() {
        const cfg = this.currentStepConfig;
        if (!cfg.parentStep) return [];
        return this.rows[cfg.parentStep].map((r, i) => ({
            label: `${r.values.Name}`,
            value: String(r.key)
        }));
    }

    get currentRows() {
        const stepRows = this.rows[this.currentStep];
        return stepRows.map((row) => ({
            key: row.key,
            parentValue: row.parentKey ? String(row.parentKey) : '',
            disableRemove: stepRows.length == 1,
            fields: this.currentStepConfig.fields.map((f) => ({
                ...f, 
                isPicklist: f.type == 'picklist',
                options: f.type == 'picklist' ? this.picklistOptions[f.apiName] || [] : [],
                value: row.values[f.name] ?? ''
            }))
        }));
    }

    get gridStyle() {
        const totalGaps = (FIELDS_VISIBLE - 1) * GAP_REM;
        return (
            'display:grid;grid-auto-flow:column;' +
            `grid-auto-columns:calc((100% - ${totalGaps}rem) / ${FIELDS_VISIBLE});` +
            `column-gap:${GAP_REM}rem;align-items:end;overflow-x:auto;min-width:0;padding-bottom:0.25rem;`
        );
    }

    handleScroll(event) {
        const left = event.currentTarget.scrollLeft;
        this.template.querySelectorAll('.fields-scroll').forEach((el) => {
            if (el.scrollLeft != left) el.scrollLeft = left;
        });
    }

    setCurrentRows(newRows) {
        this.rows = { ...this.rows, [this.currentStep]: newRows };
    }

    handleChange(event) {
        const rowKey = Number(event.target.dataset.rowKey);
        const field = event.target.dataset.field;
        this.setCurrentRows(
            this.rows[this.currentStep].map((row) =>
                row.key == rowKey ? { ...row, values: { ...row.values, [field]: event.target.value } } : row
            )
        );
    }

    handleParentChange(event) {
        const rowKey = Number(event.target.dataset.rowKey);
        const parentKey = Number(event.detail.value);
        this.setCurrentRows(
            this.rows[this.currentStep].map((row) => (row.key == rowKey ? { ...row, parentKey } : row))
        );
    }

    handleAddRow(event) {
        const rowKey = Number(event.currentTarget.dataset.rowKey);
        const stepRows = [...this.rows[this.currentStep]];
        const index = stepRows.findIndex((r) => r.key == rowKey);
        stepRows.splice(index + 1, 0, {
            key: ++this.rowCounter,
            parentKey: stepRows[index].parentKey,
            values: { ...stepRows[index].values }
        });
        this.setCurrentRows(stepRows);
    }

    handleRemoveRow(event) {
        const rowKey = Number(event.currentTarget.dataset.rowKey);
        const stepRows = this.rows[this.currentStep];
        if (stepRows.length > 1) {
            this.setCurrentRows(stepRows.filter((r) => r.key != rowKey));
        }
    }

    syncParents(stepValue) {
        const cfg = this.steps.find((s) => s.value == stepValue);
        if (!cfg.parentStep) return;
        const parentKeys = this.rows[cfg.parentStep].map((r) => r.key);
        this.rows = {
            ...this.rows,
            [stepValue]: this.rows[stepValue].map((r) =>
                parentKeys.includes(r.parentKey) ? r : { ...r, parentKey: parentKeys[0] }
            )
        };
    }

    isStepValid() {
        return [...this.template.querySelectorAll('lightning-input, lightning-combobox')].reduce(
            (ok, input) => input.reportValidity() && ok, true
        );
    }

    handleNext() {
        if (this.isStepValid() && !this.isLastStep) {
            const next = this.steps[this.currentIndex + 1].value;
            this.syncParents(next);
            this.currentStep = next;
        }
    }

    handleBack() {
        if (!this.isFirstStep) {
            const prev = this.steps[this.currentIndex - 1].value;
            this.syncParents(prev);
            this.currentStep = prev;
        }
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    async handleFinish() {
        if (!this.isStepValid()) return;
        this.isSaving = true;
        try {
            const idMap = {};
            for (const step of this.steps) {
                idMap[step.value] = {};
                await Promise.all(
                    this.rows[step.value].map(async (row) => {
                        const fields = {};
                        step.fields.forEach((f) => {
                            const v = row.values[f.apiName];
                            if (v == undefined || v == '') return;
                            fields[f.apiName] = f.type == 'number' ? Number(v) : v;
                        });
                        fields[step.parentField] = step.parentStep ? idMap[step.parentStep][row.parentKey] : this.recordId;
                        const rec = await createRecord({ apiName: step.objectApiName, fields });
                        idMap[step.value][row.key] = rec.id;
                    })
                );
            }
            showSuccessToast(this, 'Compound action completed successfully!');
            this.dispatchEvent(new CloseActionScreenEvent());
        } catch (event) {
            showErrorToast(this, event.body?.message)
        } finally {
            this.isSaving = false;
        }
    }
}