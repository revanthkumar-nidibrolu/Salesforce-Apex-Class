import { LightningElement } from 'lwc';
import USER_OBJECT from '@salesforce/schema/User';
import USER_ID from '@salesforce/user/Id';

export default class UserInformation extends LightningElement {
    userId = USER_ID;
    objectApiName = USER_OBJECT;
}