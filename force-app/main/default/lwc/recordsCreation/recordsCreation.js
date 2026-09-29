import { LightningElement, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { createRecord, getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { showSuccessToast, showErrorToast } from 'c/toastClass';
import TRANSACTION_OBJECT from '@salesforce/schema/Credit_Card_Transaction__c';
import PAYMENT_STATUS from '@salesforce/schema/Credit_Card_Transaction__c.Payment_Status__c';
import ACCOUNT_NAME from '@salesforce/schema/Account.Name';

const f = (apiName, label, type) => ({ apiName, label, type, required: true });

const STEPS = [
    {
        value: 'bank', label: 'Bank', object: 'Bank__c', parentField: 'Account__c',
        fields: [
            f('Name', 'Bank Name'), f('Account_Holder_Name__c', 'Account Holder Name'),
            f('Account_Number__c', 'Account Number'), f('IFSC__c', 'IFSC'), f('Branch__c', 'Branch')]
    },
    {
        value: 'card', label: 'Credit Card', object: 'Credit_Card__c', parentField: 'Bank__c', parentStep: 'bank', 
        parentLabel: 'Bank',
        fields: [
            f('Name', 'Card Name'), f('Card_Number__c', 'Card Number'),
            f('Total_Limit__c', 'Total Limit'), f('Available_Limit__c', 'Available Limit')]
    },
    {
        value: 'transaction', label: 'Transaction', object: 'Credit_Card_Transaction__c', parentField: 'Credit_Card__c',
        parentStep: 'card', parentLabel: 'Card', copyFromParent: ['Card_Number__c'],
        fields: [
            f('Name', 'Card Name'), f('Card_Number__c', 'Card Number'), f('Amount__c', 'Amount', 'number'),
            f('Payment_Status__c', 'Payment Status', 'picklist'), f('Transaction_Date__c', 'Transaction Date', 'date')]
    }
];

export default class RecordsCreation extends LightningElement {
    @api recordId;

    steps = STEPS;
    currentStep = STEPS[0].value;
    isSaving = false;
    counter = 0;
    rows = Object.fromEntries(STEPS.map((s) => [s.value, [this.newRow()]]));

    @wire(getRecord, { recordId: '$recordId', fields: [ACCOUNT_NAME] }) account;
    @wire(getObjectInfo, { objectApiName: TRANSACTION_OBJECT }) info;
    @wire(getPicklistValues, { recordTypeId: '$info.data.defaultRecordTypeId', fieldApiName: PAYMENT_STATUS }) status;

    get accountName() { return getFieldValue(this.account.data, ACCOUNT_NAME); }
    get index() { return this.steps.findIndex((s) => s.value == this.currentStep); }
    get cfg() { return this.steps[this.index]; }
    get hasParent() { return !!this.cfg.parentStep; }
    get parentLabel() { return this.cfg.parentLabel; }
    get showBack() { return this.index > 0; }
    get isLastStep() { return this.index == this.steps.length - 1; }

    get parentOptions() {
        return (this.rows[this.cfg.parentStep] || []).map((r) => ({ label: r.values.Name, value: String(r.key) }));
    }

    get currentRows() {
        const rows = this.rows[this.currentStep];
        return rows.map((r) => ({
            key: r.key,
            parentValue: String(r.parentKey ?? ''),
            disableRemove: rows.length === 1,
            fields: this.cfg.fields.map((fl) => ({
                ...fl,
                isPicklist: fl.type === 'picklist',
                options: this.status?.data?.values || [],
                value: r.values[fl.apiName] ?? ''
            }))
        }));
    }

    newRow(parentKey = null, values = {}) {
        return { key: ++this.counter, parentKey, values };
    }

    setRows(fn, step = this.currentStep) {
        this.rows = { ...this.rows, [step]: fn(this.rows[step]) };
    }

    updateRow(key, fn) {
        this.setRows((rs) => rs.map((r) => (r.key === key ? fn(r) : r)));
    }

    link(step, row, parentKey) {
        const parent = this.rows[step.parentStep].find((p) => p.key == parentKey);
        const values = { ...row.values };
        (step.copyFromParent || []).forEach((k) => parent && (values[k] = parent.values[k]));
        return { ...row, parentKey, values };
    }

    handleChange(e) {
        const { rowKey, field } = e.target.dataset;
        this.updateRow(+rowKey, (r) => ({ ...r, values: { ...r.values, [field]: e.target.value } }));
    }

    handleParentChange(e) {
        this.updateRow(+e.target.dataset.rowKey, (r) => this.link(this.cfg, r, +e.detail.value));
    }

    handleAddRow(e) {
        const key = +e.currentTarget.dataset.rowKey;
        this.setRows((rs) => {
            const i = rs.findIndex((r) => r.key == key);
            return [...rs.slice(0, i + 1), this.newRow(rs[i].parentKey, { ...rs[i].values }), ...rs.slice(i + 1)];
        });
    }

    handleRemoveRow(e) {
        const key = +e.currentTarget.dataset.rowKey;
        this.setRows((rs) => rs.filter((r) => r.key !== key));
    }

    isValid() {
        return [...this.template.querySelectorAll('lightning-input, lightning-combobox')]
            .reduce((ok, el) => el.reportValidity() && ok, true);
    }

    move(delta) {
        const step = this.steps[this.index + delta];
        if (step.parentStep) {
            const keys = this.rows[step.parentStep].map((r) => r.key);
            this.setRows(
                (rs) => rs.map((r) => this.link(step, r, keys.includes(r.parentKey) ? r.parentKey : keys[0])),
                step.value
            );
        }
        this.currentStep = step.value;
    }

    handleNext() { if (this.isValid()) this.move(1); }
    handleBack() { this.move(-1); }
    handleCancel() { this.dispatchEvent(new CloseActionScreenEvent()); }

    async handleFinish() {
        if (!this.isValid()) return;
        this.isSaving = true;
        const ids = {};
        try {
            for (const s of this.steps) {
                await Promise.all(this.rows[s.value].map(async (row) => {
                    const fields = { [s.parentField]: s.parentStep ? ids[row.parentKey] : this.recordId };
                    s.fields.forEach(({ apiName, type }) => {
                        const v = row.values[apiName];
                        if (v !== undefined && v !== '') fields[apiName] = type === 'number' ? Number(v) : v;
                    });
                    ids[row.key] = (await createRecord({ apiName: s.object, fields })).id;
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