import { LightningElement } from 'lwc';

export default class recordSaveButton extends LightningElement {
    inputValue ;
    handleInputChange(event) {
        this.inputValue = event.target.value;
    }
    get isButtonVisible() {
        return this.inputValue && this.inputValue.trim().length > 3
    }
}