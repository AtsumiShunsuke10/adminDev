/*

- 審査項目の値が正常に取得できていない
- setTabLabelにおいて、店舗情報を正常に取得できていない

*/


import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { publish, MessageContext } from 'lightning/messageService';
import getStoreRecords from '@salesforce/apex/Application15StoreInfo.getStoreRecords';
import MC from "@salesforce/messageChannel/storeInfoMessageChannel__c";
import STORE_SFID from '@salesforce/schema/Store15__c.Id';
import NAME from '@salesforce/schema/Store15__c.Name';
import INDEX from '@salesforce/schema/Store15__c.StoreIndex__c';
import STORE_NAME from '@salesforce/schema/Store15__c.Application_Store_Name__c';
import STORE_APPLY_AMOUNT from '@salesforce/schema/Store15__c.Application_Store_Apply_Amount__c';
import STORE_POSTAL_CODE from '@salesforce/schema/Store15__c.Application_Store_Postal_Code__c';
import STORE_ADDRESS from '@salesforce/schema/Store15__c.Application_Store_Address__c';
import STORE_ADDRESS_TYPE from '@salesforce/schema/Store15__c.Application_Store_Address_Type__c';
import STORE_START_DATE from '@salesforce/schema/Store15__c.Application_Store_Start_Date__c';
import STORE_END_DATE from '@salesforce/schema/Store15__c.Application_Store_End_Date__c';
import STORE_DAYS from '@salesforce/schema/Store15__c.Application_Store_Days__c';
import STORE_PER_NUMBER from '@salesforce/schema/Store15__c.Application_Store_Per_Number__c';
import STORE_PER_DATE from '@salesforce/schema/Store15__c.Application_Store_Per_Date__c';
import STORE_EFFORT_DETAILSA from '@salesforce/schema/Store15__c.Application_Store_Effort_DetailsA__c';
import STORE_BUSINESS_PERMIT_DOCUMENT from '@salesforce/schema/Store15__c.Store_Business_Permit_Document__c';
import STORE_APPEARANCE_DOCUMENT from '@salesforce/schema/Store15__c.Store_Appearance_Document__c';
import STORE_TIME_SAVING_DOCUMENT_OLD from '@salesforce/schema/Store15__c.Store_Time_Saving_Document_Old__c';
import FINISHED_PRICE_PAPER from '@salesforce/schema/Store15__c.FinishedPrice_Paper__c';
import FINALINCOME_TAX_RETURN_DOCUMENT from '@salesforce/schema/Store15__c.FinalincomeTaxReturnDocument__c';
import AMOUNT_OF_SOLD_DOCUMENT from '@salesforce/schema/Store15__c.AmountOfSoldDocument__c';
import CERTIFICATE_OF_INFECTION_PREVENTION from '@salesforce/schema/Store15__c.CertificateOfInfectionPrevention__c';
import STORE_BUSINESS_PERMIT_AND_ADD_IS_SAME from '@salesforce/schema/Store15__c.Store_Business_Permit_And_Add_Is_Same__c';
import STACKER from '@salesforce/schema/Store15__c.Stacker__c';
import WRITTEN_OATH from '@salesforce/schema/Store15__c.WrittenOath__c';
import METERINSPECTION_OR_RECEIPT from '@salesforce/schema/Store15__c.MeterinspectionOrReceipt__c';
// import CONDITIONS_AND_SIGNATURE from '@salesforce/schema/Store15__c.ConditionsAndSignature__c';
import OL_CORRESPONDING_APPLICANT from '@salesforce/schema/Store15__c.OLCorrespondingApplicant__c';
import OL_CORRESPONDING_BRANCHNAME_AND_LOCATION from '@salesforce/schema/Store15__c.OLCorrespondingBranchnameAndLocation__c';
import STORE_BUSINESS_PERMIT_INFO_IS_CORRECT from '@salesforce/schema/Store15__c.Store_Business_Permit_Info_Is_Correct__c';
import BUSINESS_CONTENTS_NO_OMISSION from '@salesforce/schema/Store15__c.BusinessContents_NoOmission__c';

const fields = [STORE_SFID, NAME, INDEX, STORE_NAME, STORE_APPLY_AMOUNT, STORE_POSTAL_CODE, STORE_ADDRESS, STORE_ADDRESS_TYPE,
                STORE_START_DATE, STORE_END_DATE, STORE_DAYS, STORE_PER_NUMBER, STORE_PER_DATE, STORE_EFFORT_DETAILSA];

export default class Store15Info extends LightningElement {
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
    // セクションのアクティブ化
    activeSections = [ 'basicInfo', 'screeningInfo' ];
    // 審査が完了してるかを管理する配列
    // isNotEndScreening = [];

    connectedCallback() {
        this.showTenStores(0)
        .then(() => {
            this.setListStoreRecordId();
            this.handleTabActive(1);
            this.setListScreeningResult();
            this.setScreeningProgress();
            // this.setTabLabel();
        });
    }

    renderedCallback() {
        const tabset = this.template.querySelector('lightning-tabset');
        // console.log('tabset');
        // console.log(tabset);
        const tabs = tabset.childNodes;
        // console.log('tabs');
        // console.log(tabs);
    }

    @wire(MessageContext)
    messageContext;

    // @wire(getRecord, { recordId: '$recordId', field: fields })
    // result;

    // @wire(getStoreRecords, { app15RecordId: '$recordId' })
    // setStoreInfos(result) {
    //     this.storeInfos = result.data;
    // };

    @wire(getStoreRecords, { app15RecordId: '$recordId' })
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
        this.isNotEndScreening = [];
        this.listScreeningResult.forEach(screeningResult => {
            this.isNotEndScreening.push(Object.values(screeningResult).includes(undefined));
        });
        console.log(this.isNotEndScreening);
        const endScreeningApps = this.isNotEndScreening.filter(result => result == false );
        this.endScreeningAppCount = endScreeningApps.length;
        this.progressRate = Math.floor(this.endScreeningAppCount / this.storeCount * 1000) / 10;
    }

    setListScreeningResult() {
        this.listScreeningResult = [];
        this.storeInfos.forEach(storeInfo => {
            this.listScreeningResult.push({
                id: storeInfo.Id,
                permitDocument: storeInfo.Store_Business_Permit_Document__c,
                appearanceDocument: storeInfo.Store_Appearance_Document__c,
                savingDocumentOld: storeInfo.Store_Time_Saving_Document_Old__c,
                finishedPricePaper: storeInfo.FinishedPrice_Paper__c,
                finalincomeTaxReturnDocument: storeInfo.FinalincomeTaxReturnDocument__c,
                amountOfSoldDocument: storeInfo.AmountOfSoldDocument__c,
                certificateOfInfectionPrevention: storeInfo.CertificateOfInfectionPrevention__c,
                storeBusinessPermitAndAddIsSame: storeInfo.Store_Business_Permit_And_Add_Is_Same__c,
                stacker: storeInfo.Stacker__c,
                writtenOath: storeInfo.WrittenOath__c,
                meterinspectionOrReceipt: storeInfo.MeterinspectionOrReceipt__c,
                ConditionsAndSignature: storeInfo.ConditionsAndSignature__c,
                OLCorrespondingApplicant: storeInfo.OLCorrespondingApplicant__c,
                OLCorrespondingBranchnameAndLocation: storeInfo.OLCorrespondingBranchnameAndLocation__c,
                StoreBusinessPermitInfoIsCorrect: storeInfo.Store_Business_Permit_Info_Is_Correct__c,
                BusinessContentsNoOmission: storeInfo.BusinessContents_NoOmission__c
            });
        });
        console.log(this.listScreeningResult);
    }

    setTabLabel() {
        this.showingStoreInfos.forEach(showingStoreInfo => {
            console.log(this.listScreeningResult);
            const scResult = this.listScreeningResult.forEach(screeningResult => {
                if(screeningResult.id == showingStoreInfo.id) {
                    return screeningResult;
                }
            });
            console.log(scResult);
            // const scResult = this.listScreeningResult.forEach(screeningResult => {
            //     if(screeningResult.id == showingStoreInfo.id) {
            //         return screeningResult;
            //     }
            // });
            // const isNotEndScreening = scResult.values().includes(undefined);
            // if(!isNotEndScreening) {
            //     showingStoreInfo.label = '【' + showingStoreInfo.label + '】';
            // }
        });
    }

    // setTabBackgroundColor() {
    //     this.listScreeningStatus = [];
    //     this.showingStoreInfos.forEach(showingStoreInfo => {
    //         this.listScreeningStatus.push(showingStoreInfo.Application_Store_Effort_DetailsA__c);
    //     });

    //     const tabSet = this.template.querySelector('lightning-tabset');
    //     const childNodes = tabSet.childNodes;
    //     childNodes.forEach((childNode, index) => {
    //         if(this.listScreeningStatus[index]) {
    //             childNode.style.backgroundColor = '#f0fff0';
    //         } else {
    //             childNode.style.backgroundColor = '#ffffff';
    //         }
    //     });
    // }

    handleOnSelectStoreMenu(event) {
        if(this.isDisabled) {
            this.selectedStoreIndex = event.detail.value;
            this.showTenStores(this.selectedStoreIndex)
            .then(() => {
                this.activeTab(String(Number(this.selectedStoreIndex+1)));
                this.setTabLabel();
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
        this.changedRecordId = event.target.parentNode.parentNode.parentNode.recordId;

        if(!this.changedRecords.includes(this.changedRecordId)) {
            this.changedRecords.push(this.changedRecordId);
        }
        this.isDisabled = false;
    }

    activeTab(activeTabValue) {
        this.template.querySelector('lightning-tabset').activeTabValue = activeTabValue;
    }

    showTenStores(storeIndex) {
        this.showingStoreInfos = [];
        this.storeInfos = [];
        return new Promise((resolve, reject) => {
            getStoreRecords( { app15RecordId: this.recordId } )
            .then((result) => {
                this.storeInfos = result;
                if(this.storeInfos != null) {
                    this.storeCount = Object.keys(this.storeInfos).length;
                }
                if(this.storeCount > 0) {
                    for(let i = storeIndex; i < (storeIndex+10) && i < this.storeCount; i++) {
                        this.showingStoreInfos.push({
                            id: this.storeInfos[i].Id,
                            storeIndex: this.storeInfos[i].StoreIndex__c,
                            label: this.storeInfos[i].StoreIndex__c
                        });
                    }
                    console.log(this.showingStoreInfos);
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
            console.log(changedRecord);
            const selector = 'lightning-accordion-section[data-name=\'screeningInfo\']';
            const childNodes = this.template.querySelector(selector).childNodes;

            const fields = {};
            fields[STORE_SFID.fieldApiName] = changedRecord;
            fields[STORE_BUSINESS_PERMIT_DOCUMENT.fieldApiName] = childNodes.item(0).value;
            fields[STORE_APPEARANCE_DOCUMENT.fieldApiName] = childNodes.item(1).value;
            fields[STORE_TIME_SAVING_DOCUMENT_OLD.fieldApiName] = childNodes.item(2).value;
            fields[FINISHED_PRICE_PAPER.fieldApiName] = childNodes.item(3).value;
            fields[FINALINCOME_TAX_RETURN_DOCUMENT.fieldApiName] = childNodes.item(4).value;
            fields[AMOUNT_OF_SOLD_DOCUMENT.fieldApiName] = childNodes.item(5).value;
            fields[CERTIFICATE_OF_INFECTION_PREVENTION.fieldApiName] = childNodes.item(6).value;
            fields[STORE_BUSINESS_PERMIT_AND_ADD_IS_SAME.fieldApiName] = childNodes.item(7).value;
            fields[STACKER.fieldApiName] = childNodes.item(8).value;
            fields[WRITTEN_OATH.fieldApiName] = childNodes.item(9).value;
            fields[METERINSPECTION_OR_RECEIPT.fieldApiName] = childNodes.item(10).value;
            // fields[CONDITIONS_AND_SIGNATURE.fieldApiName] = childNodes.item(11).value;
            fields[OL_CORRESPONDING_APPLICANT.fieldApiName] = childNodes.item(11).value;
            fields[OL_CORRESPONDING_BRANCHNAME_AND_LOCATION.fieldApiName] = childNodes.item(12).value;
            fields[STORE_BUSINESS_PERMIT_INFO_IS_CORRECT.fieldApiName] = childNodes.item(13).value;
            fields[BUSINESS_CONTENTS_NO_OMISSION.fieldApiName] = childNodes.item(14).value;

            console.log(fields);

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