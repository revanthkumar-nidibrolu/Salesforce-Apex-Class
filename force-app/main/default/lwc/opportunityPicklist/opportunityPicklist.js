import LightningDatatable from 'lightning/datatable';
import picklist from './picklist.html';
import picklistEdit from './picklistEdit.html';
import nameLinkTemplate from './nameLink.html';
import nameLinkEditTemplate from './nameLinkEdit.html';

export default class OpportunityPicklist extends LightningDatatable {
    static customTypes = {
        picklist: {
            template: picklist,
            editTemplate: picklistEdit,
            standardCellLayout: true,
            typeAttributes: ['options']
        },
        nameLink: {
            template: nameLinkTemplate,
            editTemplate: nameLinkEditTemplate,
            standardCellLayout: true,
            typeAttributes: ['url']
        }
    };
}