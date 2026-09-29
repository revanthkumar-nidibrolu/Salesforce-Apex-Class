import { LightningElement } from 'lwc';

export default class ParentCompound extends LightningElement {
    parentChild;
    submitclickhandler(event) {
        this.parentChild = this.refs.userName.value;
    }
}