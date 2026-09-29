import { LightningElement, api } from 'lwc';

export default class ParentAccountDashboard extends LightningElement {
    @api recordId; 
    accountName = '';
    accountIndustry = '';

    handleFieldChange(event) {
        const fieldName = event.target.fieldName;
        const fieldValue = event.target.value;
        console.log(`[Parent Form Action] User modified field [${fieldName}] to: "${fieldValue}"`);
        if (fieldName == 'Name') {
            this.accountName = fieldValue;
        } else if (fieldName == 'Industry') {
            this.accountIndustry = fieldValue;
        }
        console.log('[Parent State Pushed] Streaming data directly to Child Component attributes.');
    }
}