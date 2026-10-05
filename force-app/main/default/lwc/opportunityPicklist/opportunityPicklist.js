import LightningDatatable from 'lightning/datatable';
import picklist from './picklist.html';
import picklistEdit from './picklistEdit.html';

export default class OpportunityPicklist extends LightningDatatable {
    static customTypes = {
        picklist: {
            template: picklist,
            editTemplate: picklistEdit,
            standardCellLayout: true,
            typeAttributes: ['options']
        }
    };
}