import { LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getTodaysCallbackList from '@salesforce/apex/TodaysCallbackController.getTodaysCallbackList';

const HIGH = '高';
const columns = [
    { label: 'コールバック履歴名', fieldName: 'nameUrl', type: 'url', typeAttributes: { label: { fieldName: 'Name' } }, target: '_blank', cellAttributes: { class: { fieldName: `format` } } },
    { label: 'ケース', fieldName: 'caseUrl', type: 'url', typeAttributes: { label: { fieldName: 'caseSubject' } }, target: '_blank', cellAttributes: { class: { fieldName: `format` } } },
    { label: 'コールバック日時', fieldName: 'CallbackDatetime__c', type: 'date', typeAttributes: { month: "2-digit", day: "2-digit", hour: "2-digit", minute: "2-digit" }, cellAttributes: { class: { fieldName: `format` } } },
    { label: 'コールバックメモ', fieldName: 'CallbackMemo__c', type: 'datetime', cellAttributes: { class: { fieldName: `format` } } },
];
const displayLimitDataNum = 12;
const displayLimitHeight = '396px';

export default class TodaysCallback extends LightningElement {

    wiredResult;
    callbacks;
    columns = columns;
    height = '';
    cnt = 0;

    @wire (getTodaysCallbackList)
    wiredInformation(result) {
        this.wiredResult = result;
        if(result.data) {
            let nameUrl;
            let caseUrl;
            let caseSubject;
            this.callbacks = result.data.map(row => {
                nameUrl     = `/${row.Id}`;
                caseUrl     = `/${row.Case__c}`;
                caseSubject = row.Case__r.Subject;
                return {...row , nameUrl , caseUrl, caseSubject}
            });
            this.cnt = 0;
            this.callbacks.forEach(ele => {
                ele.format = ele.isWithinHour__c === HIGH ? 'slds-theme_warning' : 'slds-text-color_default';
                this.cnt++;
            });
            this.height = '';
            if (this.cnt > displayLimitDataNum) {
                this.height = displayLimitHeight;
            }
        }
        if(result.error) {
            console.log(result.error);
        }
    }

    handleRefresh() {
        return refreshApex(this.wiredResult)
    }
}