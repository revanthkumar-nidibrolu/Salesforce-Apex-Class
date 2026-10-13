import { LightningElement, api } from 'lwc';
import { showToast } from 'c/toastClass';

export default class FlowLauncher extends LightningElement {
    @api recordId;
    showFlow = true;

    get inputVariables() {
        return [{ name: 'recordId', type: 'String', value: this.recordId }];
    }

    handleStatusChange(event) {
        const { status } = event.detail;
        if(status == 'FINISHED') {
            this.showFlow = false;
            showToast(this, 'Success', 'Contact created', 'success');
        } else if(status == 'ERROR') {
            showToast(this, 'Error', error.body?.message, 'error');
        }
    }
}