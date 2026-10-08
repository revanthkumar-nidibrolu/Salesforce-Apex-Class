import { LightningElement } from 'lwc';
import MARKETING_LOGO from '@salesforce/resourceUrl/Marketing';

export default class StaticResources extends LightningElement {
    marketing = MARKETING_LOGO;
}