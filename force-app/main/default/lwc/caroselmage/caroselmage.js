import { LightningElement, api,wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { subscribe, unsubscribe, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import jQuery from '@salesforce/resourceUrl/jQuery';
import zoomer from '@salesforce/resourceUrl/jqueryFsZoomer';
import MC from "@salesforce/messageChannel/storeInfoMessageChannel__c";
import getRelatedFilesByRecordId from '@salesforce/apex/filePreviewController.getRelatedFilesByRecordId'
import getImagFilesOnlyByRecordId from '@salesforce/apex/filePreviewController.getImagFilesOnlyByRecordId'

const CARD_VISIBLE_CLASSES = 'slds-show'
const CARD_HIDDEN_CLASSES = 'slds-hide'

const DOT_VISIBLE_CLASSES = 'dot active'
const DOT_HIDDEN_CLASSES = 'dot'
export default class caroselmage  extends NavigationMixin( LightningElement ) {

    @api objectApiName;
    @api recordId
    slideIndex = 1
    filesList
    filesId
    subscription;
    applicationRecordId;
    isLoading = true;
    isApplicationPage = false;

    connectedCallback() {
        // 追従機能
        this.css = document.body.style;
        this.css.setProperty('--margintop', '0px');
        window.addEventListener('scroll', this.trackShowing);
        // 申請の画像表示ボタンの制御
        this.applicationRecordId = this.recordId;
        switch (this.objectApiName) {
            case 'Application4__c':
            case 'Application15__c':
                this.isApplicationPage = true;
                break;
            default:
                this.isApplicationPage = false;
                break;
        }
        // メッセージチャネルに登録
        this.subscribeToMessageChannel();
    }

    renderedCallback() {
        // 画像を拡大／縮小させるjQueryの読み込み
        Promise.all([
            loadScript(this, jQuery),
            loadScript(this, zoomer)
        ])
        .then(() => {
            console.log('読み込み完了');
            this.template.querySelector('.zoomerBasic').zoomer();
        })
        .catch(error => {
            console.log('error');
            console.log(error);
        });
    }

    trackShowing() {
        let margintop = document.documentElement.scrollTop;
        this.css = document.body.style;
        margintop *= 0.85;
        this.css.setProperty('--margintop', `${margintop}px`);
    }

    finishLoading() {
        this.isLoading = false;
    }

    @wire(MessageContext)
    messageContext;

    @wire(getImagFilesOnlyByRecordId, {recordId: '$recordId'})
    wiredResult({data, error}){
        if(data){
            this.isLoading = true;
            if(Object.keys(data).length){
                this.filesList = Object.keys(data).map(item=>({"label":data[item],
                "value": item,
                "url":`/sfc/servlet.shepherd/document/download/${item}`
                })).map((item,index) =>{
                    return index === 0 ? {
                        ...item,
                        slideIndex:index+1,
                        cardClasses:CARD_VISIBLE_CLASSES,
                        dotClasses:DOT_VISIBLE_CLASSES
                    }:{
                        ...item,
                        slideIndex:index+1,
                        cardClasses:CARD_HIDDEN_CLASSES,
                        dotClasses:DOT_HIDDEN_CLASSES
                    }
                });
            } else {
                this.isLoading = false;
                this.filesList = null;
            }
        }

        if(error){
            console.log(error)
        }

    }

    @wire(getRelatedFilesByRecordId, {recordId: '$recordId'}) allresult

    currentSilde(event){
        let slideIndex = Number(event.target.dataset.id)
        this.slideSelectionHandler(slideIndex)
    }

    backSilde(){
        let slideIndex = this.slideIndex - 1
        this.slideSelectionHandler(slideIndex)
    }

    forwardSilde(){
        let slideIndex = this.slideIndex + 1
        this.slideSelectionHandler(slideIndex)
    }

    slideSelectionHandler(id){
        if(id > this.filesList.length){
            this.slideIndex = 1;
        }else if(id < 1){
            this.slideIndex = this.filesList.length
        }else{
            this.slideIndex = id
        }
        console.log(this.filesList.length);
        console.log(this.slideIndex);
        this.filesList= this.filesList.map(item =>{
            return this.slideIndex === item.slideIndex ? {
                ...item,
                cardClasses:CARD_VISIBLE_CLASSES,
                dotClasses:DOT_VISIBLE_CLASSES
            }:{
                ...item,
                cardClasses:CARD_HIDDEN_CLASSES,
                dotClasses:DOT_HIDDEN_CLASSES
            }

        })
    }

    navigateToVFPage() {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: '/apex/imagePreviewList?recordId=' + this.recordId
            }
        }).then(generatedUrl => {
            window.open(generatedUrl);
        });
    }

    downloadFiles() {
        getRelatedFilesByRecordId({ recordId: this.recordId })
            .then((result) => {
                if(Object.keys(result).length>0){
                    for(let item of Object.keys(result)) {
                        this.download(item);
                    }
                }
            })
            .catch((error) => {
               console.log(error);
            });

    }

    download(fileId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: window.location.origin + '/sfc/servlet.shepherd/document/download/' + fileId
            }
        }, false);
    }

    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            MC,
            // ↓メッセージを受信したときのコールバック関数です。
            (message) => { this.recordId = message.recordId },
            // ↓非必須の引数です。APPLICATION_SCOPEにすることで、LWCが非アクティブでもメッセージを受信できます。
            {scope: APPLICATION_SCOPE}
        );
    }

    handleShowingApplicationImage() {
        if(this.recordId != this.applicationRecordId) {
            this.recordId = this.applicationRecordId;
        } else {
            alert('既に申請の画像を表示しています。');
        }
    }

    zoomInImg() {
        if(!this.isLoading) {
            const imgElement = this.template.querySelector('img');
            console.log(imgElement.width);
            imgElement.width = imgElement.width * 1.42;
            // imgElement.height = imgElement.height * 1.42;
            console.log(imgElement.width);
        }
    }

    zoomOutImg() {
        if(!this.isLoading) {
            const imgElement = this.template.querySelector('img');
            console.log(imgElement.width);
            imgElement.width = imgElement.width * 0.7;
            // imgElement.height = imgElement.height * 0.7;
            console.log(imgElement.width);
        }
    }
}