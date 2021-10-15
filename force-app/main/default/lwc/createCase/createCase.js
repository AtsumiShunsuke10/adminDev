import { LightningElement } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CASE_OBJECT from '@salesforce/schema/Case';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import SUBJECT_FIELD from '@salesforce/schema/Case.Subject';
import DESCRIPTION_FIELD from '@salesforce/schema/Case.Description';
import { NavigationMixin } from 'lightning/navigation';

export default class CreateCase extends NavigationMixin(LightningElement) {

    status = '新規';
    subject = '';
    description = '';

    handleSubjectChange(event) {
        this.subject = event.target.value;
    }

    handleDescriptionChange(event) {
        this.description = event.target.value;
    }

    handleSave() {
        const fields = {};
        fields[STATUS_FIELD.fieldApiName] = this.status;
        fields[SUBJECT_FIELD.fieldApiName] = this.subject;
        fields[DESCRIPTION_FIELD.fieldApiName] = this.description;
        const recordInput = { apiName: CASE_OBJECT.objectApiName, fields };

        createRecord(recordInput)
        .then((record) => {
            console.log(record.id);
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: record.id,
                    objectApiName: 'Case',
                    actionName: 'view'
                }
            })
            this.dispatchEvent(
                new ShowToastEvent({
                    message: 'ケースを作成しました。',
                    variant: 'success'
                })
            );
            this.close();
        })
        .catch((error) => {
            this.dispatchEvent(
                new ShowToastEvent({
                    message: error.body.message,
                    variant: 'error'
                })
            );
            this.close();
        })
    }

    close() {
        const closeEvent = new CustomEvent('close');
        this.dispatchEvent(closeEvent);
    }
}