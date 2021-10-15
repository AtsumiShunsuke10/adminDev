import { LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getInformationList from '@salesforce/apex/InformationController.getInformationList';

const HIGH = '高';
const columns = [
    { label: '周知事項', fieldName: 'Name', type: 'text', sortable: true, cellAttributes: { class: { fieldName: `format` } } },
    { label: '重要度', fieldName: 'Importance__c', type: 'text', sortable: true, cellAttributes: { class: { fieldName: `format` } } },
    { label: 'カテゴリ', fieldName: 'Category__c', type: 'text', sortable: true, cellAttributes: { class: { fieldName: `format` } } },
    { label: 'タイトル', fieldName: 'nameUrl', type: 'url', sortable: true, typeAttributes: {label: { fieldName: 'Title__c'} }, target: '_blank', cellAttributes: { class: { fieldName: `format` } }  },
    { label: '詳細', fieldName: 'Detail__c', type: 'richText', sortable: true, cellAttributes: { class: { fieldName: `format` } } },
    { label: '通知期間(開始)', fieldName: 'NoticePeriodStart__c', type: 'date', sortable: true, cellAttributes: { class: { fieldName: `format` } } },
    { label: '通知期間(終了)', fieldName: 'NoticePeriodEnd__c', type: 'date', sortable: true, cellAttributes: { class: { fieldName: `format` } } },
];
const sortFieldNameMap = {nameUrl: 'Title__c'};
const displayLimitDataNum = 12;
const displayLimitHeight = '381px';

export default class informationDatatable extends LightningElement {

    wiredResult;
    informations;
    columns = columns;
    height = '';
    sortFieldNameMap = sortFieldNameMap;
    cnt = 0;

    @wire (getInformationList)
    wiredInformation(result) {
        this.wiredResult = result;
        if(result.data) {
            let nameUrl;
            this.informations = result.data.map(row => {
                nameUrl = `/${row.Id}`;
                return {...row, nameUrl}
            });
            this.cnt = 0;
            this.informations.forEach(ele => {
                ele.format = ele.Importance__c === HIGH ? 'slds-theme_warning' : 'slds-text-color_default';
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