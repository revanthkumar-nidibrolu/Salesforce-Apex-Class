import { LightningElement, api } from 'lwc';
import { showToast } from 'c/toastClass';
import AccountUpdateModal from 'c/modelComponent';

export default class AccountUpdateModalLauncher extends LightningElement {
    @api recordId;

    @api async invoke() {
        const result = await AccountUpdateModal.open({ size: 'small', recordId: this.recordId });
        if(result == 'success') {
            showToast(this, 'Success', 'Account updated successfully', 'success');
        }
    }
}