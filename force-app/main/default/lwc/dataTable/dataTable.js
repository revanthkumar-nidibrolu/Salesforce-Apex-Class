import { LightningElement, wire } from 'lwc';
import listOfOppo from '@salesforce/apex/ListOfOpportunities.listOfOppo';

export default class dataTable extends LightningElement {
    data = [];
    columns = [
        { label: 'Opportunity Name', fieldName: 'Name' },
        { label: 'Stage', fieldName: 'StageName' },
        { label: 'Amount', fieldName: 'Amount', type: 'currency' },
        { label: 'Close Date', fieldName: 'CloseDate', type: 'date' }
    ];

    @wire(listOfOppo)
    wiredOpportunities({ error, data }) {
        if (data) {
            this.data = data;
        } else if (error) {
            console.error('Error fetching opportunities:', error);
        }
    }
}