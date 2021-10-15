import { LightningElement, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getInformationBrowsingHistories from '@salesforce/apex/InformationBrowsingHistoryController.getInformationBrowsingHistories';

const columns = [
    { label: 'ユーザ', fieldName: 'userName', type: 'text', sortable: true },
    { label: '既読', fieldName: 'isRead', type: 'boolean', sortable: true, hideDefaultActions: true, actions: [
            { label: 'すべて', checked: true, name: 'all' },
            { label: '既読', checked: false, name: 'read' },
            { label: '未読', checked: false, name: 'unread' }
        ]
    }
];
//const sortFieldNameMap = {nameUrl: 'User__c'};
//const displayLimitDataNum = 12;
//const displayLimitHeight = '381px';

export default class InformationReadUnread extends LightningElement {

    @api recordId;
    wiredResult;
    all_Histories;
    informationBrowsingHistories;
    columns = columns;
    readRate;
    readCount;
    unreadCount;
//    height = '';
//    sortFieldNameMap = sortFieldNameMap;
//    cnt = 0;

    @wire (getInformationBrowsingHistories, { informationId: '$recordId'})
    wiredInformation(result) {
        this.wiredResult = result;
        if(result.data) {
            let userName;
            this.all_Histories = result.data.map(row => {
                userName = row.name;
                return {...row, userName};
            });
            this.informationBrowsingHistories = this.all_Histories;
            this.readCount = 0;
            this.informationBrowsingHistories.forEach(ele => {
                if(ele.isRead) {
                    this.readCount++;
                }
            });
            this.readRate = Math.floor((this.readCount/this.all_Histories.length)*100);
            this.unreadCount = this.all_Histories.length-this.readCount;
            
//            this.cnt = 0;
//            this.informationBrowsingHistories.forEach(() => {
//                this.cnt++;
//            });
//            this.height = '';
//            if (this.cnt > displayLimitDataNum) {
//                this.height = displayLimitHeight;
//            }
        }
        if(result.error) {
            this.informationBrowsingHistories = undefined;
            console.log(result.error);
        }
    }

    handleHeaderAction(event) {
        const actionName = event.detail.action.name;
        const colDef = event.detail.columnDefinition;
        const cols = this.columns;
        if (actionName !== undefined && actionName !== 'all') {            
            this.informationBrowsingHistories = this.all_Histories.filter(_histories => _histories[colDef.fieldName] === (actionName === 'read' ? true : false));
        } else if (actionName === 'all') {
            this.informationBrowsingHistories = this.all_Histories;
        }
        cols.find(col => col.label === colDef.label).actions.forEach(action => (action.checked = action.name === actionName));
        this.columns = [...cols];
    }

    handleRefresh() {
        return refreshApex(this.wiredResult)
    }
}