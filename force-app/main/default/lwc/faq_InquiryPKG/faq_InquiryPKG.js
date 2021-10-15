import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import isEnableRecommend from '@salesforce/label/c.isEnableRecommendForFAQ';
import getRecommendFaqs from '@salesforce/apex/FaqController.getRecommendFaqs';
import findFaqs from '@salesforce/apex/FaqController.findFaqs';

import CATEGORY_L_FIELD from '@salesforce/schema/Inquiry__c.CategoryL__c';
import CATEGORY_M_FIELD from '@salesforce/schema/Inquiry__c.CategoryM__c';
import CATEGORY_S_FIELD from '@salesforce/schema/Inquiry__c.CategoryS__c';

const FIELDS = [CATEGORY_L_FIELD, CATEGORY_M_FIELD, CATEGORY_S_FIELD];
const DELAY = 350;

export default class Faq extends LightningElement {
    @api recordId;
    titleLabel;
    searchResults;
    wiredCaseResult;
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredCase(result) {
        this.wiredCaseResult = result;
        this.getRecommendations();
    }

    getRecommendations() {
        if(isEnableRecommend === 'true') {
            this.titleLabel = 'おすすめ記事'
            getRecommendFaqs({ category: this.CategoryL, subCategory: this.CategoryM, subSubCategory: this.CategoryS })
            .then((results) => {
                this.searchResults = results;
            })
            .catch(() => {
                this.searchResults = undefined;
            });
        } else {
            this.titleLabel = '検索結果';
        }
    }

    handleKeyChange(event) {
        window.clearTimeout(this.delayTimeout);
        const key = event.target.value;
        this.delayTimeout = setTimeout(() => {
            findFaqs({ key })
                .then((results) => {
                        this.titleLabel = '検索結果'
                        this.searchResults = results;
                })
                .catch(() => {
                    this.searchResults = undefined;
                    this.getRecommendations();
                });
        }, DELAY);
    }

    get CategoryL() {
        return getFieldValue(this.wiredCaseResult.data, CATEGORY_L_FIELD);
    }

    get CategoryM() {
        return getFieldValue(this.wiredCaseResult.data, CATEGORY_M_FIELD);
    }

    get CategoryS() {
        return getFieldValue(this.wiredCaseResult.data, CATEGORY_S_FIELD);
    }
}