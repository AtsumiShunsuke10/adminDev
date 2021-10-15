import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { publish, MessageContext } from 'lightning/messageService';
import getStoreRecords from '@salesforce/apex/Application4StoreInfo.getStoreRecords';
import MC from "@salesforce/messageChannel/storeInfoMessageChannel__c";
import STORE_ID from '@salesforce/schema/Store__c.Id';
import NAME from '@salesforce/schema/Store__c.Name';
import INDEX from '@salesforce/schema/Store__c.StoreIndex__c';
import STORE_NAME from '@salesforce/schema/Store__c.Application_Store_Name__c';
import STORE_APPLY_AMOUNT from '@salesforce/schema/Store__c.Application_Store_Apply_Amount__c';
import STORE_POSTAL_CODE from '@salesforce/schema/Store__c.Application_Store_Postal_Code__c';
import STORE_ADDRESS from '@salesforce/schema/Store__c.Application_Store_Address__c';
import STORE_ADDRESS_TYPE from '@salesforce/schema/Store__c.Application_Store_Address_Type__c';
import STORE_START_DATE from '@salesforce/schema/Store__c.Application_Store_Start_Date__c';
import STORE_END_DATE from '@salesforce/schema/Store__c.Application_Store_End_Date__c';
import STORE_DAYS from '@salesforce/schema/Store__c.Application_Store_Days__c';
import STORE_PER_DATE from '@salesforce/schema/Store__c.Application_Store_Per_Date__c';
import STORE_EFFORT_DETAILSA from '@salesforce/schema/Store__c.Application_Store_Effort_DetailsA__c';
import STORE_ADDRESS_CHECK from '@salesforce/schema/Store__c.Application_Store_Address_Check__c';
import STORE_APPEARANCE_DOCUMENT from '@salesforce/schema/Store__c.Store_Appearance_Document__c';
import STORE_BUSINESS_PERMIT_DOCUMENT from '@salesforce/schema/Store__c.Store_Business_Permit_Document__c';

const fields = [STORE_ID, NAME, INDEX, STORE_NAME, STORE_APPLY_AMOUNT, STORE_POSTAL_CODE, STORE_ADDRESS, STORE_ADDRESS_TYPE,
                STORE_START_DATE, STORE_END_DATE, STORE_DAYS, STORE_PER_DATE, STORE_EFFORT_DETAILSA, STORE_ADDRESS_CHECK];

export default class Store4Info extends LightningElement {
    // 申請のレコードIDを取得
    @api recordId;
    // 申請に関連する店舗情報
    @track storeInfos = [];
    // 店舗数
    storeCount;
    // 10ごとに店舗を情報を管理する配列
    @track storeIndexArray = [];
    // 店舗ボタンメニューで選択された値を格納
    selectedStoreIndex = -1;
    // タブに表示する店舗配列
    @track showingStoreInfos = [];
    // 更新ボタンの無効化フラグ
    isDisabled = true;
    // 変更された項目名
    // changedFieldName;
    // 項目が変更されたレコードID
    changedRecordId;
    // 変更されたレコードの配列
    changedRecords = [];
    // 店舗のレコードIDを店舗No.昇順に管理する配列
    listStoreRecordId = [];
    // 審査状況を管理する配列（検証用）
    listScreeningStatus = [];
    // 審査結果を管理する配列（検証用）
    listScreeningResult = [];
    // 審査結果に関わらず、審査が完了した申請数
    endScreeningAppCount;
    // 審査の進捗率を保管
    progressRate = 0;

    connectedCallback() {
        this.showTenStores(0)
        .then(() => {
            this.setListStoreRecordId();
            this.handleTabActive(1);
            this.setTabBackgroundColor();
            this.setScreeningProgress();
        });
    }

    renderedCallback() {
        const tabset = this.template.querySelector('lightning-tabset');
        console.log('tabset');
        console.log(tabset);
        const tabs = tabset.childNodes;
        console.log('tabs');
        console.log(tabs);
    }

    @wire(MessageContext)
    messageContext;

    // @wire(getRecord, { recordId: '$recordId', field: fields })
    // result;

    // @wire(getStoreRecords, { app4RecordId: '$recordId' })
    // setStoreInfos(result) {
    //     this.storeInfos = result.data;
    // };

    @wire(getStoreRecords, { app4RecordId: '$recordId' })
    setMenuItem(result) {
        this.storeInfos = result.data;
        this.storeIndexArray = [];
        if(this.storeInfos != null) {
            this.storeCount = Object.keys(this.storeInfos).length;
        }
        if(this.storeCount > 0) {
            for(let i = 0; i < this.storeCount; i+=10) {
                this.storeIndexArray.push({ value: Number(i), label: Number(i+1) + '～' + Number(i+10) });
            }
        }
    }

    setListStoreRecordId() {
        this.listStoreRecordId = [];
        this.storeInfos.forEach(storeInfo => {
            this.listStoreRecordId.push(storeInfo.Id);
        });
    }

    setScreeningProgress() {
        this.listScreeningResult = [];
        this.storeInfos.forEach(storeInfo => {
            this.listScreeningResult.push(storeInfo.Store_Appearance_Document__c);
        });
        const endScreeningApps = this.listScreeningResult.filter(result => result != undefined );
        this.endScreeningAppCount = endScreeningApps.length;
        this.progressRate = Math.floor(this.endScreeningAppCount / this.storeCount * 1000) / 10;
    }

    setTabBackgroundColor() {
        this.listScreeningStatus = [];
        this.showingStoreInfos.forEach(showingStoreInfo => {
            this.listScreeningStatus.push(showingStoreInfo.Application_Store_Effort_DetailsA__c);
        });

        const tabSet = this.template.querySelector('lightning-tabset');
        const childNodes = tabSet.childNodes;
        childNodes.forEach((childNode, index) => {
            if(this.listScreeningStatus[index]) {
                childNode.style.backgroundColor = '#f0fff0';
            } else {
                childNode.style.backgroundColor = '#ffffff';
            }
        });
    }

    handleOnSelectStoreMenu(event) {
        if(this.isDisabled) {
            this.selectedStoreIndex = event.detail.value;
            this.showTenStores(this.selectedStoreIndex)
            .then(() => {
                this.activeTab(String(Number(this.selectedStoreIndex+1)));
                this.setTabBackgroundColor();
            })
            .catch(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: '情報の読み込みに失敗しました。ページを更新して、もう一度お試しください。',
                        variant: 'error'
                    })
                );
                console.log(error);
            });
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Warning',
                    message: '変更中は移動できません。',
                    variant: 'warning'
                })
            );
        }
    }

    handleTabActive(event) {
        let tabIndex;
        if (isNaN(event)) {
            tabIndex = event.target.value;
        } else {
            tabIndex = event;
        }
        const storeRecordId = this.listStoreRecordId[tabIndex-1];
        this.sendMessageService(storeRecordId);
    }

    handleOnChangeField(event) {
        event.target.style.backgroundColor = '#faffbd';
        // this.changedFieldName = event.target.fieldName;
        this.changedRecordId = event.target.parentNode.recordId;

        if(!this.changedRecords.includes(this.changedRecordId)) {
            this.changedRecords.push(this.changedRecordId);
        }
        this.isDisabled = false;
    }

    // testHandler(event) {
    //     const parent = event.target.parentElement;
    //     const childNodes = parent.childNodes;
    //     childNodes.forEach(childNode => {
    //         childNode.classList.remove('slds-is-active');
    //         // childNode.tabIndex = -1;
    //     });
    //     event.target.classList.add('slds-is-active');
    //     // event.tabIndex = 0;
    // }

    activeTab(activeTabValue) {
        this.template.querySelector('lightning-tabset').activeTabValue = activeTabValue;
    }

    showTenStores(storeIndex) {
        this.showingStoreInfos = [];
        this.storeInfos = [];
        return new Promise((resolve, reject) => {
            getStoreRecords( { app4RecordId: this.recordId } )
            .then((result) => {
                this.storeInfos = result;
                if(this.storeInfos != null) {
                    this.storeCount = Object.keys(this.storeInfos).length;
                }
                if(this.storeCount > 0) {
                    for(let i = storeIndex; i < (storeIndex+10) && i < this.storeCount; i++) {
                        this.showingStoreInfos.push(this.storeInfos[i]);
                    }
                }
                resolve();
            })
            .catch((error) => {
                reject();
                console.log(error);
            });
        });
    }

    sendMessageService(storeRecordId) {
        const payload = { recordId: storeRecordId };
        publish(this.messageContext, MC, payload);
    }

    updateStoreInfo() {
        this.changedRecords.forEach(changedRecord => {
            const selector = 'lightning-record-edit-form[data-id=\'' + changedRecord + '\']';
            const childNodes = this.template.querySelector(selector).childNodes;

            const fields = {};
            fields[STORE_ID.fieldApiName] = changedRecord;
            fields[STORE_NAME.fieldApiName] = childNodes.item(0).value;
            // fields[STORE_APPLY_AMOUNT.fieldApiName] = childNodes.item(1).value;
            fields[STORE_POSTAL_CODE.fieldApiName] = childNodes.item(2).value;
            fields[STORE_ADDRESS.fieldApiName] = childNodes.item(3).value;
            fields[STORE_ADDRESS_TYPE.fieldApiName] = childNodes.item(4).value;
            fields[STORE_START_DATE.fieldApiName] = childNodes.item(5).value;
            fields[STORE_END_DATE.fieldApiName] = childNodes.item(6).value;
            // fields[STORE_DAYS.fieldApiName] = childNodes.item(7).value;
            fields[STORE_PER_DATE.fieldApiName] = childNodes.item(8).value;
            fields[STORE_EFFORT_DETAILSA.fieldApiName] = childNodes.item(9).value;
            // fields[STORE_ADDRESS_CHECK.fieldApiName] = childNodes.item(10).value;
            fields[STORE_APPEARANCE_DOCUMENT.fieldApiName] = childNodes.item(11).value;
            fields[STORE_BUSINESS_PERMIT_DOCUMENT.fieldApiName] = childNodes.item(12).value;

            const recordInput = { fields };

            updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: changedRecord + 'の更新が出来ました',
                        variant: 'success'
                    })
                );
                childNodes.forEach(childNode => {
                    childNode.style.backgroundColor = '#ffffff';
                });
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: changedRecord + 'の更新は出来ませんでした。ページを更新して、もう一度お試しください。',
                        variant: 'error'
                    })
                );
                console.log(error);
            });
        });
        this.isDisabled = true;
        this.changedRecords = [];
    }
}