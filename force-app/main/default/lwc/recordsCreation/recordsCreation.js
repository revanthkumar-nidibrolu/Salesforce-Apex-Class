import { LightningElement, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { createRecord, getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { showSuccessToast, showErrorToast } from 'c/toastClass';
import ACCOUNT_NAME from '@salesforce/schema/Account.Name';

const createField = (apiName, label, type) => ({ apiName, label, type, required: true });

const STEPS = [
    {
        value: 'bank', label: 'Bank', object: 'Bank__c', parentField: 'Account__c',
        fields: [
            createField('Name', 'Bank Name'), createField('Account_Holder_Name__c', 'Account Holder Name'),
            createField('Account_Number__c', 'Account Number'), createField('IFSC__c', 'IFSC'),
            createField('Branch__c', 'Branch')
        ]
    },
    {
        value: 'card', label: 'Credit Card', object: 'Credit_Card__c', parentField: 'Bank__c', parentStep: 'bank',
        parentLabel: 'Bank',
        fields: [
            createField('Name', 'Card Name'), createField('Card_Number__c', 'Card Number'), createField('Cvv__c', 'Cvv'),
            createField('Total_Limit__c', 'Total Limit'), createField('Available_Limit__c', 'Available Limit')
        ]
    },
    {
        value: 'transaction', label: 'Transaction', object: 'Credit_Card_Transaction__c',
        parentField: 'Credit_Card__c', parentStep: 'card', parentLabel: 'Card', copyFromParent: ['Card_Number__c'],
        fields: [
            createField('Name', 'Card Name'), createField('Card_Number__c', 'Card Number'),
            createField('Amount__c', 'Amount', 'number'), createField('Transaction_Date__c', 'Transaction Date', 'date')
        ]
    }
];

export default class RecordsCreation extends LightningElement {
    @api recordId;

    steps = STEPS;
    currentStep = STEPS[0].value;
    isSaving = false;
    data = { bank: {}, card: {}, transaction: {} };

    @wire(getRecord, { recordId: '$recordId', fields: [ACCOUNT_NAME] }) account;

    get accountName() { return getFieldValue(this.account.data, ACCOUNT_NAME); }
    get currentIndex() { return this.steps.findIndex((step) => step.value === this.currentStep); }
    get currentStepConfig() { return this.steps[this.currentIndex]; }
    get hasParent() { return !!this.currentStepConfig.parentStep; }
    get parentLabel() { return this.currentStepConfig.parentLabel; }
    get parentName() { return this.hasParent ? this.data[this.currentStepConfig.parentStep].Name : ''; }
    get showBack() { return this.currentIndex > 0; }
    get isLastStep() { return this.currentIndex == this.steps.length - 1; }

    get currentFields() {
        const values = this.data[this.currentStep];
        return this.currentStepConfig.fields.map((field) => ({
            ...field,
            isPicklist: field.type == 'picklist',
            options: this.paymentStatusPicklist?.data?.values || [],
            value: values[field.apiName] ?? ''
        }));
    }

    handleChange(event) {
        const fieldApiName = event.target.dataset.field;
        this.data = {
            ...this.data,
            [this.currentStep]: { ...this.data[this.currentStep], [fieldApiName]: event.target.value }
        };
    }

    isValid() {
        const inputElements = this.template.querySelectorAll('lightning-input, lightning-combobox');
        return [...inputElements].reduce(
            (allValid, inputElement) => inputElement.reportValidity() && allValid,
            true
        );
    }

    handleNext() {
        if (!this.isValid()) return;
        const nextStep = this.steps[this.currentIndex + 1];
        (nextStep.copyFromParent || []).forEach((fieldApiName) => {
            if (!this.data[nextStep.value][fieldApiName]) {
                this.data = {
                    ...this.data,
                    [nextStep.value]: {
                        ...this.data[nextStep.value],
                        [fieldApiName]: this.data[nextStep.parentStep][fieldApiName]
                    }
                };
            }
        });
        this.currentStep = nextStep.value;
    }

    handleBack() { this.currentStep = this.steps[this.currentIndex - 1].value; }
    handleCancel() { this.dispatchEvent(new CloseActionScreenEvent()); }

    async handleFinish() {
        if (!this.isValid()) return;
        this.isSaving = true;
        const createdIds = {};
        try {
            for (const step of this.steps) {
                const recordFields = {
                    [step.parentField]: step.parentStep ? createdIds[step.parentStep] : this.recordId
                };
                step.fields.forEach(({ apiName, type }) => {
                    const fieldValue = this.data[step.value][apiName];
                    if (fieldValue != undefined && fieldValue != '') {
                        recordFields[apiName] = type == 'number' ? Number(fieldValue) : fieldValue;
                    }
                });
                const createdRecord = await createRecord({ apiName: step.object, fields: recordFields });
                createdIds[step.value] = createdRecord.id;
            }
            showSuccessToast(this, 'Compound action completed successfully!');
            this.dispatchEvent(new CloseActionScreenEvent());
        } catch (error) {
            showErrorToast(this, error.body?.message);
        } finally {
            this.isSaving = false;
        }
    }
}