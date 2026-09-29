import { ShowToastEvent } from 'lightning/platformShowToastEvent';

function showToast(component, title, message, variant = 'info', mode = 'dismissible') {
    component.dispatchEvent(
        new ShowToastEvent({
            title,
            message,
            variant,
            mode
        })
    );
}
function showSuccessToast(component, message, title = 'Success') {
    showToast(component, title, message, 'success');
}
function showErrorToast(component, message, title = 'Error') {
    showToast(component, title, message, 'error');
}
export { showToast, showSuccessToast, showErrorToast };