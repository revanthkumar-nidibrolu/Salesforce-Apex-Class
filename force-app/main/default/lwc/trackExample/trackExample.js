import { LightningElement, api, track } from 'lwc';

export default class TrackExample extends LightningElement {
    @api recordId;
    @api objectApiName;

    @track opportunity = {
        fields: [
            { key: 'Name' },
            { key: 'StageName' },
            { key: 'Amount' },
            { key: 'CloseDate' },
            { key: 'Type' }
        ]
    };
}