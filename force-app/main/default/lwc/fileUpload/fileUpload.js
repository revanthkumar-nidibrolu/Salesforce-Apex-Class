import { LightningElement, api } from 'lwc';
import { showToast } from 'c/toastClass';

export default class FileUploader extends LightningElement {
    @api recordId;

    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg', '.jpeg', '.xlsx', '.csv'];
    }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        let uploadedFileNames = '';
        for (let i = 0; i < uploadedFiles.length; i++) {
            uploadedFileNames += uploadedFiles[i].name + ', ';
        }
        uploadedFileNames = uploadedFileNames.slice(0, -2);
        showToast(this, 'Success', `Files uploaded: ${uploadedFileNames}`, 'success');
    }
}