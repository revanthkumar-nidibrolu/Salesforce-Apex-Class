import { LightningElement, api, track } from 'lwc';

export default class ChildOpportunityList extends LightningElement {
    @track _accountName = ''; 
    @api 
    get parentAccountName() {
        return this._accountName;
    }
    set parentAccountName(value) {
        console.log(' [Child Setter Triggered] Data just arrived from Parent!');
        console.log('[Child Received Value] Old: "${this._accountName}"  New: "${value}"');
        this._accountName = value;
        this.executeChildInternalWorkflow(value);
    }
    executeChildInternalWorkflow(currentAccountName) {
        console.log('[Child Action] Processing custom workflow using: "${currentAccountName}"');
    }
}
