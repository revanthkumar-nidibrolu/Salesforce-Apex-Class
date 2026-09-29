import { LightningElement, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { createRecord, getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { showSuccessToast, showErrorToast } from 'c/toastClass';
import TRANSACTION_OBJECT from '@salesforce/schema/Credit_Card_Transaction__c';
import PAYMENT_STATUS from '@salesforce/schema/Credit_Card_Transaction__c.Payment_Status__c';
import ACCOUNT_NAME from '@salesforce/schema/Account.Name';

const createField = (apiName, label, type) => ({ apiName, label, type, required: true });

const STEPS = [
    {
        value: 'bank', label: 'Bank', object: 'Bank__c', parentField: 'Account__c',
        fields: [
            createField('Name', 'Bank Name'), createField('Account_Holder_Name__c', 'Account Holder Name'),
            createField('Account_Number__c', 'Account Number'), createField('IFSC__c', 'IFSC'),
            createField('Branch__c', 'Branch'), createField('Status__c', 'Status', 'picklist')
        ]
    },
    {
        value: 'card', label: 'Credit Card', object: 'Credit_Card__c', parentField: 'Bank__c',parentStep: 'bank', 
        parentLabel: 'Bank',
        fields: [
            createField('Name', 'Card Name'), createField('Card_Number__c', 'Card Number'), createField('Cvv__c', 'Cvv'),
            createField('Total_Limit__c', 'Total Limit'), createField('Available_Limit__c', 'Available Limit'),
            createField('Status__c', 'Status', 'picklist')
        ]
    },
    {
        value: 'transaction', label: 'Transaction', object: 'Credit_Card_Transaction__c',
        parentField: 'Credit_Card__c', parentStep: 'card', parentLabel: 'Card', copyFromParent: ['Card_Number__c'],
        fields: [
            createField('Name', 'Card Name'), createField('Card_Number__c', 'Card Number'),
            createField('Amount__c', 'Amount', 'number'), createField('Payment_Status__c', 'Payment Status', 'picklist'),
            createField('Transaction_Date__c', 'Transaction Date', 'date')
        ]
    }
];

export default class RecordsCreation extends LightningElement {
    @api recordId;

    steps = STEPS;
    currentStep = STEPS[0].value;
    isSaving = false;
    rowCounter = 0;
    rows = Object.fromEntries(STEPS.map((step) => [step.value, [this.newRow()]]));

    @wire(getRecord, { recordId: '$recordId', fields: [ACCOUNT_NAME] }) account;
    @wire(getObjectInfo, { objectApiName: TRANSACTION_OBJECT }) transactionInfo;
    @wire(getPicklistValues, {
        recordTypeId: '$transactionInfo.data.defaultRecordTypeId',
        fieldApiName: PAYMENT_STATUS
    }) paymentStatusPicklist;

    get accountName() { return getFieldValue(this.account.data, ACCOUNT_NAME); }
    get currentIndex() { return this.steps.findIndex((step) => step.value == this.currentStep); }
    get currentStepConfig() { return this.steps[this.currentIndex]; }
    get hasParent() { return !!this.currentStepConfig.parentStep; }
    get parentLabel() { return this.currentStepConfig.parentLabel; }
    get showBack() { return this.currentIndex > 0; }
    get isLastStep() { return this.currentIndex == this.steps.length - 1; }

    get parentOptions() {
        const parentRows = this.rows[this.currentStepConfig.parentStep] || [];
        return parentRows.map((parentRow) => ({
            label: parentRow.values.Name,
            value: String(parentRow.key)
        }));
    }

    get currentRows() {
        const stepRows = this.rows[this.currentStep];
        return stepRows.map((row) => ({
            key: row.key,
            parentValue: String(row.parentKey ?? ''),
            disableRemove: stepRows.length == 1,
            fields: this.currentStepConfig.fields.map((field) => ({
                ...field,
                isPicklist: field.type == 'picklist',
                options: this.paymentStatusPicklist?.data?.values || [],
                value: row.values[field.apiName] ?? ''
            }))
        }));
    }

    newRow(parentKey = null, values = {}) {
        return { key: ++this.rowCounter, parentKey, values };
    }

    setRows(updateStepRows, stepValue = this.currentStep) {
        this.rows = { ...this.rows, [stepValue]: updateStepRows(this.rows[stepValue]) };
    }

    updateRow(rowKey, updateRowFn) {
        this.setRows((stepRows) => stepRows.map((row) => (row.key == rowKey ? updateRowFn(row) : row)));
    }

    linkToParent(step, row, parentKey) {
        const parentRow = this.rows[step.parentStep].find((candidate) => candidate.key == parentKey);
        const values = { ...row.values };
        (step.copyFromParent || []).forEach((fieldApiName) => {
            if (parentRow) values[fieldApiName] = parentRow.values[fieldApiName];
        });
        return { ...row, parentKey, values };
    }

    handleChange(event) {
        const { rowKey, field: fieldApiName } = event.target.dataset;
        this.updateRow(Number(rowKey), (row) => ({
            ...row,
            values: { ...row.values, [fieldApiName]: event.target.value }
        }));
    }

    handleParentChange(event) {
        const rowKey = Number(event.target.dataset.rowKey);
        const parentKey = Number(event.detail.value);
        this.updateRow(rowKey, (row) => this.linkToParent(this.currentStepConfig, row, parentKey));
    }

    handleAddRow(event) {
        const rowKey = Number(event.currentTarget.dataset.rowKey);
        this.setRows((stepRows) => {
            const rowIndex = stepRows.findIndex((row) => row.key == rowKey);
            const sourceRow = stepRows[rowIndex];
            const copiedRow = this.newRow(sourceRow.parentKey, { ...sourceRow.values });
            return [...stepRows.slice(0, rowIndex + 1), copiedRow, ...stepRows.slice(rowIndex + 1)];
        });
    }

    handleRemoveRow(event) {
        const rowKey = Number(event.currentTarget.dataset.rowKey);
        this.setRows((stepRows) => stepRows.filter((row) => row.key != rowKey));
    }

    isValid() {
        const inputElements = this.template.querySelectorAll('lightning-input, lightning-combobox');
        return [...inputElements].reduce(
            (allValid, inputElement) => inputElement.reportValidity() && allValid,
            true
        );
    }

    move(direction) {
        const targetStep = this.steps[this.currentIndex + direction];
        if (targetStep.parentStep) {
            const parentKeys = this.rows[targetStep.parentStep].map((parentRow) => parentRow.key);
            this.setRows(
                (stepRows) => stepRows.map((row) => {
                    const parentKey = parentKeys.includes(row.parentKey) ? row.parentKey : parentKeys[0];
                    return this.linkToParent(targetStep, row, parentKey);
                }),
                targetStep.value
            );
        }
        this.currentStep = targetStep.value;
    }

    handleNext() { if (this.isValid()) this.move(1); }
    handleBack() { this.move(-1); }
    handleCancel() { this.dispatchEvent(new CloseActionScreenEvent()); }

    async handleFinish() {
        if (!this.isValid()) return;
        this.isSaving = true;
        const createdRecordIds = {};
        try {
            for (const step of this.steps) {
                await Promise.all(this.rows[step.value].map(async (row) => {
                    const recordFields = {
                        [step.parentField]: step.parentStep ? createdRecordIds[row.parentKey] : this.recordId
                    };
                    step.fields.forEach(({ apiName, type }) => {
                        const fieldValue = row.values[apiName];
                        if (fieldValue != undefined && fieldValue != '') {
                            recordFields[apiName] = type == 'number' ? Number(fieldValue) : fieldValue;
                        }
                    });
                    const createdRecord = await createRecord({ apiName: step.object, fields: recordFields });
                    createdRecordIds[row.key] = createdRecord.id;
                }));
            }
            showSuccessToast(this, 'Compound action completed successfully!');
            this.dispatchEvent(new CloseActionScreenEvent());
        } catch (error) {
            showErrorToast(this, error.body?.message || error.message);
        } finally {
            this.isSaving = false;
        }
    }
}