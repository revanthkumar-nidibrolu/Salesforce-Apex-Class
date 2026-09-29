import { LightningElement, api } from 'lwc';

export default class ContactItem extends LightningElement {
    @api contact;
    timerId;
    constructor() {
        super();
        console.log('[CHILD] 1. Constructor');
    }
    connectedCallback() {
        console.log(`[CHILD] 2. ConnectedCallback mounted for: ${this.contact.Name}`);
        this.timerId = setInterval(() => {
            console.log(`  [CHILD] Active timer ping for: ${this.contact.Name}`);
        }, 5000);
    }
    renderedCallback() {
        console.log(`[CHILD] 3. RenderedCallback for: ${this.contact.Name}`);
    }
    disconnectedCallback() {
        console.log(`[CHILD] 4. DisconnectedCallback unmounted for: ${this.contact.Name}`);
        clearInterval(this.timerId);
    }
}