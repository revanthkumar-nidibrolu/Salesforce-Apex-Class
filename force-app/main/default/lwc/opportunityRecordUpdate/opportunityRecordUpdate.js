import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class OpportunityRecordUpdate extends LightningElement {
    @api recordId;

    opportunityFields = ['StageName', 'CloseDate', 'Amount'];

    addTrackingFields() {
        this.opportunityFields = [this.opportunityFields, 'NextStep', 'Description'];
    }

    handleSuccess(event) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Opportunity Stage and ClosedDate updated',
                variant: 'success'
            })
        );
    }
}