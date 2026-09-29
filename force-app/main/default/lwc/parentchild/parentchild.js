import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Parentchild extends LightningElement {
    @api recordId;

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