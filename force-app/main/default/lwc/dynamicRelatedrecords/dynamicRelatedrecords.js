import { LightningElement, api } from 'lwc';
import getRelatedRecords from '@salesforce/apex/DynamicRelatedRecords.getRelatedRecords';
import NoRelatedRecords from '@salesforce/label/c.NoRelatedRecords'

export default class OpportunityRelatedRecords extends LightningElement {
    @api recordId;
    @api childObjectApiName;
    @api childObjectFieldApiNames;
    @api childParentFieldApiName;
    datatable = [];
    columns = [];
    label={NoRelatedRecords};
    connectedCallback() {
        this.buildColumns();
        this.loadRelatedRecords();
    }
    buildColumns() {
        if (!this.childObjectFieldApiNames) {
            return;
        }
        const fields = this.childObjectFieldApiNames
            .split(',')
            .map(field => field.trim())
            .filter(field => field);

        this.columns = fields.map(field => ({
            label: this.getFieldLabel(field),
            fieldName: field
        }));
    }
    getFieldLabel(fieldName) {
        return fieldName
            .replace(/__c$/, '')
            .replace(/_/g, ' ');
    }
    loadRelatedRecords() {
        getRelatedRecords({
            parentId: this.recordId,
            childObjectApiName: this.childObjectApiName,
            childObjectFieldApiNames: this.childObjectFieldApiNames,
            childParentFieldApiName: this.childParentFieldApiName
        })
            .then(data => {
                this.datatable = data;
            })
            .catch(error => {
                console.error('Error fetching related records:', error);
            });
    }
    get hasRecords() {
        return this.datatable.length > 0;
    }
}