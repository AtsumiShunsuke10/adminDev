import { LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getEscalations from '@salesforce/apex/ProgressHistoryController.getEscalations';

const columns = [
    { label: 'エスカレーション名', fieldName: 'nameUrl', type: 'url', typeAttributes: { label: { fieldName: 'Name' } }, target: '_blank' },
    { label: '問合せ', fieldName: 'caseUrl', type: 'url', typeAttributes: { label: { fieldName: 'caseSubject' } }, target: '_blank' },
    { label: '概要', fieldName: 'Comment__c', type: 'text' }
];
const displayLimitDataNum = 12;
const displayLimitHeight = '396px';

export default class Escalation extends LightningElement {

    wiredResult;
    escalations;
    columns = columns;
    height = '';
    cnt = 0;

    @wire (getEscalations)
    wiredEscalation(result) {
        this.wiredResult = result;
        if(result.data) {
            let nameUrl;
            let caseUrl;
            let caseSubject;
            this.escalations = result.data.map(row => {
                nameUrl     = `/${row.Id}`;
                caseUrl     = `/${row.Inquiry__c}`;
                caseSubject = row.Inquiry__r.Subject__c;
                return {...row , nameUrl , caseUrl, caseSubject}
            });
            this.cnt = 0;
            this.escalations.forEach(() => {
                this.cnt++;
            });
            this.height = '';
            if (this.cnt > displayLimitDataNum) {
                this.height = displayLimitHeight;
            }
        }
        if(result.error) {
            this.informations = undefined;
            console.log(result.error);
        }
    }

    handleRefresh() {
        return refreshApex(this.wiredResult)
    }
}