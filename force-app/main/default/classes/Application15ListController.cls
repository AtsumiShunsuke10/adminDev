/*******************************************************************************
 *  プロジェクト名 : ○○県新型コロナウイルス感染症拡大防止協力金
 *  クラス         : 申請（感染症拡大防止協力金：第15弾）一覧コントローラ
 *  クラス名       : Application15ListController
 *  概要           : 申請（感染症拡大防止協力金：第15弾）一覧コントローラ
 *  作成者         : トランス・コスモス
 *  作成日         : 2021/10/01
 *******************************************************************************/
global with sharing class Application15ListController {
    
    // ドメイン名
    public String domainURL                             { get;private set; }
    // 添付したファイル
    public transient List<ContentVersion> attachType1   { get;set; }
    public transient List<ContentVersion> attachType2   { get;set; }
    public transient Map<Integer,List<ContentVersion>> attachStoreMap  { get;set; }

    // 「訂正＆提出」ボタン表示フラッグ
    public Boolean bShowReviseBtn                       { get;private set; }
    // データ不備ありのフラッグ
    public Boolean incompleteFlag                       { get;private set; }
    // ファイル不備ありのフラッグ
    public Boolean resubmitFlag                         { get;private set; }

    // 申請者情報改修フラッグ
    public Boolean bInfoRevise                          { get;private set; }
    // 申請金額改修フラッグ
    public Boolean bStoreRevise                         { get;private set; }
    // 口座情報改修フラッグ
    public Boolean bBankRevise                          { get;private set; }
    // 店舗情報不備改修フラッグのマップ
    public Map<Integer, Boolean> storeReviceMap         { get;private set; }
    // 店舗書類再提出フラッグのマップ
    public Map<Integer, Boolean> storeResubmitMap       { get;private set; }
    // 店舗セクションが表示されるかのフラッグのリスト
    public List<Boolean> rentFlagList                   { get;private set; }

    // 生年月日
    public String year                                  { get;set; }
    public String month                                 { get;set; }
    public String day                                   { get;set; }
    // 営業許可書-許可年月日のマップ
    public CustomDate storePerDate                      { get;set; }
    // 時短営業開始日のマップ
    public CustomDate storeTsbStartDate                 { get;set; }
    // 時短営業表示ラベル
    public String startDateLbl { get;set; }
    public String startMonthLbl { get;set; }
    public String endDateLbl { get;set; }
    public Integer endDay { get;set; }
    
    public String JSONString                            { get;set; }

    public Boolean normalFlag                           { get;set; }
    public Boolean kojinFlag                            { get;set; }

    // 一覧画面表示レコードリスト
    public List<Application15__c> apply15List             { get;set; }
    // 申請（感染症拡大防止協力金：第15弾）店舗リスト
    public List<Store15__c> storeList                     { get;set; }
    public List<Store15__c> storeDisplayList              { get;set; }
    public Store15__c store                               { get;set; }
    public Integer storeIdx                               { get;set; }
    
    // 申請者ID
    private Id conId;
    // 申請（感染症拡大防止協力金：第15弾）レコードID
    public String applyId                               { get;set; }
    // 申請（感染症拡大防止協力金：第15弾）レコード
    public Application15__c apply15                       { get;set; }
    public static String tempStr                        { get;set; }

    /** 1店舗の感染防止対策協力金 */
    public Integer storeAmount  { get;set; }
    
    //店舗申請最大軒数
    Integer maxStore=Integer.valueOf(System.Label.STORE_CNT);
    
    //時短営業終了日
    public String CONST_SHORTER_BUSI_END_DATE      { get;set; }
    
    // 営業許可書-許可番号文字列
    public String perNumberSub      { get;set; }
    
    public Integer pageNum { get;set; }
    public Integer maxPageNum { get;set; }
    
    public Application15ListController() {
        if(conId == null) conId = [select contactid from User where Id = :Userinfo.getUserId()].contactid;
        String conditionStr='';
        if(conId!=null){
            conditionStr='Contact__c=\'' + conId + '\' and Status__c!=\'' + Application15Const.CONST_APP15_STATUS_NOT_PROPOSED + '\''
                + ' and RecordType.name!=\'' + Application15Const.CONST_APP15_STATUS_DUMMY + '\'';
        }
        apply15List = Database.query(Application15Utility.getAllColumnSoql('Application15__c', conditionStr, 'Name desc', '1000'));
        
        //時短営業終了日
        CONST_SHORTER_BUSI_END_DATE = Application15Utility.fmtDate(Application15Const.CONST_APP15_SHORTER_BUSI_END_DATE, Application15Const.CONST_DATE_FMT);
        
        maxPageNum = 1;
        pageNum = 1;
        storeIdx = 0;
    }

     /**
     * 新規画面に遷移
     *
     * @return PageReference 申請新規画面
     */
    public PageReference toInputPage() {
        PageReference pr = new PageReference(Site.getBaseSecureUrl() + '/s/Application15Input');
        pr.setRedirect(false);
        return pr;
    }
    
     /**
     * 店舗確認画面に遷移
     *
     * @return PageReference 店舗確認画面
     */
    public PageReference toStoreDetail(){
        PageReference pr =  new PageReference(page.Store15Confirm.getUrl());
        pr.setRedirect(false);
        return pr;
    }
    
     /**
     * 店舗確認画面初期化
     */
    public void initStoreConfirmPage(){
        if(storeList != null && storeList.size() > 0 && storeIdx > 0 ){
            store = storeList[storeIdx-1];
        }
        attachStoreMap = new Map<Integer,List<ContentVersion>>();
        
        List<ContentVersion> attachmentList = new List<ContentVersion>();
        attachStoreMap.put(storeIdx-1,new List<ContentVersion>());
        attachmentList.addAll(Application15Utility.initIssAttachment(store.Id));

        
        fileExtensionPreview(attachmentList);
        // ファイル名の先頭で分類
        for (ContentVersion attach : attachmentList) {
            String startStr = attach.title.substringBefore('_');
            Integer idx = Integer.valueOf(startStr.remove('store'));
            attachStoreMap.get(storeIdx-1).add(attach);
        }
        // 許可年月日の年、月、日、と時短営業開始日を設定
        setTsbStartDate();
        
        // 店舗の時間短縮営業等実施期間の表示メッセージを設定
        doFormatDaysMsg();
        
    }
    
     /**
     * 店舗情報を更新する
     *
     * @return PageReference 店舗更新
     */    
    public PageReference toStoreUpdate(){
        if(storeList != null && storeList.size() > 0 && storeIdx > 0 ){
            store = storeList[storeIdx-1];
        }else{
            return null;
        }
        
        if(getStoreReviceCheckResult()){
            PageReference pr =  new PageReference(page.Store15Revise.getUrl());
            pr.setRedirect(false);
            return pr;
        }else if(getStoreFileCheckResult()){
            PageReference pr =  new PageReference(page.Store15ChangeFile.getUrl());
            pr.setRedirect(false);
            return pr;
        }else{
            PageReference pr =  new PageReference(page.Store15Revise.getUrl());
            pr.setRedirect(false);
            return pr;
        }

    }
     /**
     * 店舗の情報の審査結果を取得
     *
     * @return boolean 審査結果
     */
    private boolean getStoreReviceCheckResult(){
        Set<String> storeReviceCheckSet = new Set<String>();
        // ⑮店舗の名称が営業許可書と一致しているか
        storeReviceCheckSet.add(String.valueOf(store.Store_Business_Permit_And_Name_Is_Same__c));
        // ⑯店舗の許可番号・年月日が許可書の記載と一致し、日付が有効期限内である
        storeReviceCheckSet.add(String.valueOf(store.Store_Business_Permit_Info_Is_Correct__c));
        // ⑰店舗の営業許可書の「１営業所の所在地」と一致し、対象エリアである
        storeReviceCheckSet.add(String.valueOf(store.Store_Business_Permit_And_Add_Is_Same__c));
        
        return storeReviceCheckSet.contains(Application15Const.CONST_APP15_SCR_RET_1_NG);
    }
    
    /**
     * 店舗添付書類の審査結果を取得
     *
     * @return boolean 審査結果
     */
    private boolean getStoreFileCheckResult(){
        Set<String> storeFileCheckSet = new Set<String>();
        // ⑩店舗の外観が分かる写真がある
        storeFileCheckSet.add(String.valueOf(store.Store_Appearance_Document__c));
        // ⑪店舗の飲食店の営業許可書の写しがある
        storeFileCheckSet.add(String.valueOf(store.Store_Business_Permit_Document__c));
        // ⑫店舗の酒類を提供していることがわかる書面等の写しがある
        storeFileCheckSet.add(String.valueOf(store.Store_Alcohol_Document__c));
        // ⑬店舗において「時短営業の案内」を掲示したことがわかるものがある
        storeFileCheckSet.add(String.valueOf(store.Store_Time_Saving_Document__c));
        // ⑭店舗の従来の営業時間がわかる写真等がある
        storeFileCheckSet.add(String.valueOf(store.Store_Time_Saving_Document_Old__c));  
        
        return storeFileCheckSet.contains(Application15Const.CONST_APP15_SCR_RET_4_RESUB);
    }
    
     /**
     * 店舗訂正画面初期化
     */
    public void initStoreModifyPage(){
        // 許可年月日の年、月、日、と時短営業開始日を設定
        setTsbStartDate();
        setPerDate();
        
        // 店舗の時間短縮営業等実施期間の表示メッセージを設定
        doFormatDaysMsg();
    }

     /**
     * 店舗添付資料再提出画面に遷移(訂正画面から)
     *
     * @return PageReference 店舗添付資料再提出画面
     */
    public PageReference toStoreChangeFile(){
        if(getStoreFileCheckResult()){
            PageReference pr =  new PageReference(page.Store15ChangeFile.getUrl());
            pr.getParameters().put('FromPage', 'Store15Revise');
            pr.setRedirect(false);
            return pr;
        }else{
            return toDetailPage();
        }
    }
    
     /**
     * 店舗添付資料再提出画面初期化
     */
    public void initStoreChangePage(){
        List<String> fieldsList = Application15Utility.getAllColumnsList('Store15__c');
        String query = Application15Utility.makeSoql(fieldsList, 'Store15__c', 'Id = \''+ store.Id +'\'', '', '', '');
        store = Database.query(query);  
    }
    
     /**
     * 申請確認画面に遷移
     *
     * @return PageReference 申請確認画面
     */
    public PageReference toDetailPage() {
        rentFlagList = new List<Boolean>();
        PageReference pr = new PageReference(page.Application15Detail.getUrl());
        pr.setRedirect(false);
        return pr;
    }
    
     /**
     * 申請確認画面初期化
     */
    public void initDetailPage() {
        
        if(applyId != null) {
            apply15 = Database.query(Application15Utility.getAllColumnSoql('Application15__c', applyId));
            
            List<String> fieldsList = Application15Utility.getAllColumnsList('Store15__c');
            String query = Application15Utility.makeSoql(fieldsList, 'Store15__c', 'Application15__c = \''+ apply15.Id +'\'', 'StoreIndex__c', '', '');
            storeList = Database.query(query);
        }
        bShowReviseBtn = Application15Const.CONST_APP15_STATUS_WAIT_ANSWER.equals(apply15.Status__c) ? true : false;
        kojinFlag = false;
        normalFlag = true;
        
        storeDisplayList = new List<Store15__c>();
        Integer maxNum = Integer.valueOf(System.Label.STORE_LIST_PAGE_NUM);
        maxPageNum=storeList.size()/maxNum+1;
        storeDisplayList = (List<Store15__c>)Application15Utility.getPageRecordList(storeList,pageNum);
        
        
        /* normalFlag = false;
        //事業活動に必要な許可事，「支払口座」に記載した振込先口座情報：通常申請のみ表示
        if(apply15.Application__c == null && apply15.Application2__c == null){
            normalFlag=true;
        }*/
        //本人確認書類:個人通常申請のみ表示
        // if(normalFlag && apply15.Applicant_Division__c==Application15Const.CONST_APP15_APP_DIV_SOLE){
        //     kojinFlag=true;
        // }
        kojinFlag = apply15.Applicant_Division__c == Application15Const.CONST_APP15_APP_DIV_SOLE;

        List<ContentVersion> issAttachment = Application15Utility.initIssAttachment(applyId);
        List<ContentVersion> attachmentList = new List<ContentVersion>();
        attachmentList.addAll(issAttachment);
        attachStoreMap = new Map<Integer,List<ContentVersion>>();
        for(Integer idx = 0;idx < storeList.size(); idx++){
            attachStoreMap.put(idx,new List<ContentVersion>());
            attachmentList.addAll(Application15Utility.initIssAttachment(storeList.get(idx).Id));
        }
        
        fileExtensionPreview(attachmentList);

        attachType1 = new List<ContentVersion>();
        attachType2 = new List<ContentVersion>();
        // ファイル名の先頭で分類
        for (ContentVersion attach : attachmentList) {
            String startStr = attach.title.substringBefore('_');
            switch on startStr {
                when '1type' {
                    attachType1.add(attach);
                }
                when '2type' {
                    attachType2.add(attach);
                }
                when else {
                    Integer idx = Integer.valueOf(startStr.remove('store'));
                    attachStoreMap.get(idx-1).add(attach);
                    
                }
            }
        }
    }

    /**
     * 訂正＆提出画面に遷移
     *
     * @return PageReference 訂正、提出
     */
    public PageReference toRevisePage() {
        // 申請者情報審査結果のセット
        Set<String> infoCheckSet = new Set<String>();
        infoCheckSet.add(apply15.Filled_App_Info_Is_No_Omissions__c);    // ①記入漏れがないか
        infoCheckSet.add(apply15.Document_And_App_Name_Info_Is_Same__c); // ③本人確認書類と一致しているか
        infoCheckSet.add(apply15.Business_Permit_Info_Is_Same__c);       // ④営業許可書と一致しているか
        infoCheckSet.add(apply15.Store_Num_And_Store_Info_Is_Same__c);   // ⑤店舗数が申請店舗数と一致しているか
        infoCheckSet.add(apply15.Com_Number_And_Com_Info_Is_Same__c);    // ⑥法人番号と会社名が一致しているか     

        bInfoRevise = infoCheckSet.contains(Application15Const.CONST_APP15_SCR_RET_1_NG);
        bBankRevise = apply15.Document_And_Info_Is_Same__c == Application15Const.CONST_APP15_SCR_RET_1_NG       // ⑧通帳等の写しと口座情報が一致しているか
                   || apply15.Applicant_Acc_Holder_Is_Same__c == Application15Const.CONST_APP15_SCR_RET_1_NG;   // ⑨申請者と口座名義人が一致しているか

        // データ不備ありのフラッグ
        incompleteFlag = bInfoRevise || bBankRevise;
        // ファイル不備ありのフラッグ
        resubmitFlag = apply15.Identification_Document__c == Application15Const.CONST_APP15_SCR_RET_4_RESUB    // ②本人確認書類の写しがある
                    || apply15.Banking_Account_Document__c == Application15Const.CONST_APP15_SCR_RET_4_RESUB;  // ⑦振込先口座情報が分かる書類の写しがある
        

        // データ不備ある場合
        if (incompleteFlag) {
            PageReference pr = new PageReference(page.Application15Revise.getUrl());
            pr.getParameters().put('FromPage', 'Application15Revise');
            pr.setRedirect(false);
            return pr;
        }
        // ファイルのみ不備ある場合
        if(resubmitFlag){
            PageReference pr = new PageReference(page.Application15ChangeFile.getUrl());
            pr.getParameters().put('FromPage', 'Application15Detail');
            pr.setRedirect(false);
            return pr;
        }
        
        //申請回数累計
        if(apply15.Application_Count__c == null){
            apply15.Application_Count__c = 2;
        }else{
            apply15.Application_Count__c =apply15.Application_Count__c + 1;
        }
        
        apply15.Number_FileReUpload__c = apply15.Number_FileReUpload__c == null ? 1 : apply15.Number_FileReUpload__c + 1;
        apply15.Document_Reupload__c = Application15Const.CONST_APP15_DOCUMENT_REUPLOAD_REUPLOADED;
        apply15.Status__c = Application15Const.CONST_APP15_STATUS_EXAMINATION;
        apply15.SubStatus__c = Application15Const.CONST_APP15_SUB_STATUS_REAPPLY;
        apply15.SessionRadom__c = '';
        upsert apply15;
        
        PageReference pr = new PageReference (page.Application15Complete2.getUrl());
        pr.setRedirect(false);
        return pr;
    }
    
     /**
     * 申請訂正画面を初期化
     */
    public void initRevisePage() {
        // 生年月日を設定
        if(apply15.Applicant_Birthday__c != null){
            year = String.valueOf(apply15.Applicant_Birthday__c.year());
            month = String.valueOf(apply15.Applicant_Birthday__c.month());
            day = String.valueOf(apply15.Applicant_Birthday__c.day());
        }
    }
    
     /**
     * 添付資料再提出画面を初期化
     */
    public void initChangeFilePage(){
        
        apply15 = Database.query(Application15Utility.getAllColumnSoql('Application15__c', applyId));
        //List<String> fieldsList = Application15Utility.getAllColumnsList('Store15__c');
        //String query = Application15Utility.makeSoql(fieldsList, 'Store15__c', 'Application15__c = \''+ apply15.Id +'\'', '', '', '');
        //storeList = Database.query(query);
        // 店舗の時間短縮営業等実施期間の表示メッセージを設定
        //doFormatDaysMsg();
        // 個人事業主フラッグ
        kojinFlag = apply15.Applicant_Division__c == Application15Const.CONST_APP15_APP_DIV_SOLE;
        
        apply15.SessionRadom__c = String.valueof((Math.random() * 10));
        apply15.Number_FileReUpload__c = apply15.Number_FileReUpload__c == null ? 1 : apply15.Number_FileReUpload__c;
        upsert apply15;
        
    }
    
    
     /**
     * 申請確認画面に戻る
     *
     * @return PageReference 申請確認画面
     */
    public PageReference returnDetailPage() {
        PageReference pr = new PageReference(page.Application15Detail.getUrl());
        pr.setRedirect(false);
        return pr;
    }

     /**
     * 前のページに戻る
     *
     * @return PageReference 前のページ
     */
    public PageReference returnPrevPage() {
        //前画面に戻る選択された添付ファイルはクリアされます
        deleteFile();

        PageReference pr;
        // 前のページを取得
        String prevPage = ApexPages.currentPage().getParameters().get('FromPage');

        if (prevPage == 'Application15Revise') {
            pr = new PageReference(page.Application15Revise.getUrl());
        }else if (prevPage == 'Store15Revise') {
            deleteStoreFile();
            pr = new PageReference(page.Store15Revise.getUrl());
        }else {
            deleteStoreFile();
            pr = new PageReference(page.Application15Detail.getUrl());
        }

        pr.setRedirect(false);
        return pr;
    }
    
     /**
     * 添付資料再提出画面に遷移(訂正画面から)
     *
     * @return PageReference 添付資料再提出画面
     */
    public PageReference toChangeFile(){
        PageReference pr =  new PageReference(page.Application15ChangeFile.getUrl());
        pr.getParameters().put('FromPage', 'Application15Revise');
        pr.setRedirect(false);
        return pr;
    }
        
     /**
     * 一覧画面に戻る
     *
     * @return PageReference 一覧画面に戻る
     */
    public PageReference toListPage() {
        //前画面に戻る選択された添付ファイルはクリアされます
        deleteFile();
        PageReference pr = new PageReference(page.Application15List.getUrl());
        pr.setRedirect(false);
        return pr;
    }
    

     /**
     *  完了画面に遷移
     *
     * @return PageReference  完了画面に遷移
     */
    public PageReference toCompletePage() {

        apply15.Number_FileReUpload__c = apply15.Number_FileReUpload__c == null ? 1 : apply15.Number_FileReUpload__c + 1;
        apply15.Document_Reupload__c = Application15Const.CONST_APP15_DOCUMENT_REUPLOAD_REUPLOADED;
        apply15.Status__c = Application15Const.CONST_APP15_STATUS_EXAMINATION;
        apply15.SubStatus__c = Application15Const.CONST_APP15_SUB_STATUS_REAPPLY;
        apply15.SessionRadom__c = '';
        upsert apply15;
        
        PageReference pr = new PageReference (page.Application15Complete2.getUrl());
        pr.setRedirect(false);
        return pr;
        
    }
    
     /**
     * 添付ファイルを保存
     *
     * @return String  添付ファイル
     */
    webService static String saveToDocument(String filename,String filebody,String tempStr,String store){
        try {

            Blob b = null; 
            String dat = filebody.substringAfterLast(',');
            b = EncodingUtil.base64Decode(dat);
            ContentVersion cv = new ContentVersion();
            cv.versionData = b;
            cv.title = filename;
            cv.Description = filename;
            cv.pathOnClient = '/' + filename;
            insert cv;

            cv =[SELECT id,ContentDocumentId,title,Description,FileExtension,ReasonForChange,ContentBodyId FROM ContentVersion WHERE Id = :cv.Id];
            ContentDocumentLink link = new ContentDocumentLink();
            if(!String.isEmpty(store) && store!='undefined'){
                link.LinkedEntityId = store;
            }else{
                link.LinkedEntityId = getParentId(tempStr);
            }
            link.ContentDocumentId = cv.ContentDocumentId;
            link.ShareType = 'I';
            insert link;

            //idを戻る
            Map<String, Object> response = new Map<String, Object>();
            response.put('status', '200');
            response.put('id', cv.id);
            return JSON.serialize( response );
        } catch (Exception e) {
             //idを戻る
            Map<String, Object> response = new Map<String, Object>();
            response.put('status', '500');
            return JSON.serialize( response );
        }

    }
     /**
     * 添付ファイルを削除
     *
     * @return String  添付ファイル
     */
    webService static String deleteDocument(String filename,String tempStr,String store){
        try{
            List<ContentVersion> ContentVersionList=new List<ContentVersion>();
            set<Id> cvIds= new set<Id>();
            ContentVersionList =[SELECT ContentDocumentId,Description FROM ContentVersion WHERE Description like :filename+'%'];
            for(ContentVersion cv : contentVersionlist){
                cvIds.add(cv.ContentDocumentId);
            }
            set<Id> linkIds;
            if(String.isEmpty(store)){
                String parentId = getParentId(tempStr);
                Id appid = (Id)getParentId(tempStr);
                List<ContentDocumentLink> links = [SELECT Id,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: appid and ContentDocumentId in:cvIds];
                linkIds= new set<Id>();
                for(ContentDocumentLink link : links){
                    linkIds.add(link.ContentDocumentId);
                }
            }else{
                List<ContentDocumentLink> links = [SELECT Id,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: store and ContentDocumentId in:cvIds];
                linkIds= new set<Id>();
                for(ContentDocumentLink link : links){
                    linkIds.add(link.ContentDocumentId);
                }
            }
            
            
            List<ContentDocument> delatt = [SELECT Id FROM ContentDocument WHERE Id =: linkIds];
            if ( delatt.size() > 0 ) {
                delete delatt;
            }
            //idを戻る
            Map<String, Object> response = new Map<String, Object>();
            response.put('status', '200');
            return JSON.serialize( response );
        }catch (Exception e) {
            //idを戻る
            Map<String, Object> response = new Map<String, Object>();
            response.put('status', '500');
            return JSON.serialize( response );
       }
    }
    
     /**
     * 申請の添付ファイルはクリアされます
     */
    public void deleteFile(){
        List<ContentDocumentLink> links = [SELECT Id,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: apply15.id];
        set<Id> linkIds= new set<Id>();
        for(ContentDocumentLink link : links){
            linkIds.add(link.ContentDocumentId);
        }
        List<ContentDocument> delatt = [SELECT Id FROM ContentDocument WHERE Id =: linkIds AND (Description like :'%' + 'type_re' + apply15.Number_FileReUpload__c + '%' OR Description like :'%' + 'store_re' + apply15.Number_FileReUpload__c + '%')];
        if ( delatt.size() > 0 ) {
            delete delatt;
        }
    }
    
     /**
     * 店舗の添付ファイルはクリアされます
     */
    public void deleteStoreFile(){
        if(store==null){
            return;
        }
        List<ContentDocumentLink> links = [SELECT Id,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: store.id];
        set<Id> linkIds= new set<Id>();
        for(ContentDocumentLink link : links){
            linkIds.add(link.ContentDocumentId);
        }
        List<ContentDocument> delatt = [SELECT Id FROM ContentDocument WHERE Id =: linkIds AND (Description like :'%' + 'type_re' + apply15.Number_FileReUpload__c + '%' OR Description like :'%' + 'store_re' + apply15.Number_FileReUpload__c + '%')];
        if ( delatt.size() > 0 ) {
            delete delatt;
        }
    }

    /**
     * 店許可番号文字作成
     */
    public void determinePerNumber(){
        String perNumCom=store.Application_Store_Per_Number_Com__c;
        String perNumIssue=store.Application_Store_Per_Number_Issue__c;
        
        String adressType=store.Application_Store_Address_Type__c;
        String pDependentField1='Application_Store_Per_Number_String__c';
        String pDependentField2='Application_Store_Per_Number_String2__c';
        String perNumberString;
        if(String.isNotEmpty(perNumCom)&&String.isNotEmpty(perNumIssue)&&String.isNotEmpty(adressType)){
            List<String> depentList1=Application15Utility.GetDependentFormat(adressType,pDependentField1);
            List<String> depentList2=Application15Utility.GetDependentFormat(adressType,pDependentField2);
            if(depentList2.size()>0 && String.isNotEmpty(perNumberSub)){
                perNumberString = String.format(depentList1[0],  new List<String>{perNumCom,perNumIssue,perNumberSub});
            }else{
                perNumberString = String.format(depentList1[0],  new List<String>{perNumCom,perNumIssue,''});
            }
        }else{
            perNumberString = '';
        }
        store.Application_Store_Per_Number__c=perNumberString;
    }
    
     /**
     * 拡張子によって、レビュータイプを決定
     */
    private void fileExtensionPreview(List<ContentVersion> cvList){
        domainURL = ApexPages.currentPage().getHeaders().get('Host');
        for(ContentVersion cv : cvList){
            if(cv.FileExtension == null) {
                continue; 
            }
            if(cv.FileExtension.containsIgnoreCase('png') || 
                cv.FileExtension.containsIgnoreCase('jpg') ||
                cv.FileExtension.containsIgnoreCase('jpeg') ||
                cv.FileExtension.containsIgnoreCase('gif') ||
                cv.FileExtension.containsIgnoreCase('bmp')){
                cv.ReasonForChange = 'ORIGINAL_' + cv.FileExtension;
            } 
            else if(cv.FileExtension.containsIgnoreCase('pdf') || 
                (cv.FileExtension.containsIgnoreCase('doc') &&
                !cv.FileExtension.containsIgnoreCase('docm')) ||
                (cv.FileExtension.containsIgnoreCase('xls') &&
                !cv.FileExtension.containsIgnoreCase('xlsx') &&
                !cv.FileExtension.containsIgnoreCase('xlsm')) ||
                (cv.FileExtension.containsIgnoreCase('ppt') &&
                !cv.FileExtension.containsIgnoreCase('pptm')) || 
                cv.FileExtension.containsIgnoreCase('txt')){
                cv.ReasonForChange = 'SVGZ';
            }
            else {
                cv.ReasonForChange = '';
            }
        }
    }
    
     /**
     * 前のページに戻る
     */
    public void previous() {
        if(pageNum==1){
            return;
        }
        pageNum=pageNum-1;
        storeDisplayList = (List<Store15__c>)Application15Utility.getPageRecordList(storeList,pageNum);
    }
    
     /**
     * 次のページへ行く
     */
    public void next() {
        Integer maxNum = Integer.valueOf(System.Label.STORE_LIST_PAGE_NUM);
        Integer eIdx= maxNum*pageNum;
        if(storeList.size()+maxNum > maxNum*(pageNum+1)){
            pageNum=pageNum+1;
        }
        
        storeDisplayList = (List<Store15__c>)Application15Utility.getPageRecordList(storeList,pageNum);
    }
    
     /**
     * 最初のページに戻る
     */
    public void goFirst() {
        pageNum=1;
        storeDisplayList = (List<Store15__c>)Application15Utility.getPageRecordList(storeList,pageNum);
    }
    
     /**
     * 最後のページに行く
     */
    public void goLast() {
        pageNum=maxPageNum;
        storeDisplayList = (List<Store15__c>)Application15Utility.getPageRecordList(storeList,pageNum);
    }
    
     /**
     * 申請IDを取得
     *
     * @param String セッション
     * @return String 申請ID
     */
    public static String getParentId(String tempStr){
        
        String rId='';
        Application15__c app3=[Select id From Application15__c Where SessionRadom__c =:tempStr];
        rId=app3.Id;
        
        return rId;
    }
    
    /**
     * 郵便番号で住所を取得
     *
     * @param String postcode 郵便番号
     * @return String 住所
     */
    @RemoteAction
    public static String getAddress(String postcode) {
        
        // 申請（感染症拡大防止協力金：第15弾）共通処理.郵便番号で住所マスタから住所を取得
        String address = Application15Utility.getAddressByPostCode(postcode);
        
        return address;
        
    }
    
    /**
     * 時短営業開始日を設定
     */
    private void setTsbStartDate() {

        storeTsbStartDate = new CustomDate();

        Date stDate = store.Application_Store_Start_Date__c;
        // 時短営業開始日を設定
        if (stDate != null) {
            storeTsbStartDate.customYear = String.valueOf(stDate.year());
            storeTsbStartDate.customMonth = String.valueOf(stDate.month());
            storeTsbStartDate.customDay = String.valueOf(stDate.day());
            storeTsbStartDate.customDateStr = String.valueOf(stDate);
        } else {
            storeTsbStartDate.customYear = String.valueOf(Application15Const.CONST_APP15_SHORTER_BUSI_START_DATE.year());
            storeTsbStartDate.customMonth = String.valueOf(Application15Const.CONST_APP15_SHORTER_BUSI_START_DATE.month());
        }
    }
    
    /**
     * 許可年月日の年、月、日を設定
     */
    private void setPerDate() {
        
        storePerDate = new CustomDate();
        Map<Integer, Date> changeYearMap = Application15Utility.createWarekiChangeYear();
        Date perDate = (Date)store.Application_Store_Per_Date__c;
        System.debug('******perDate*******'+perDate);
        if (perDate != null) {
            storePerDate.customYear = String.valueOf(perDate.year());
            // 年号変更識別子を追加
            if (changeYearMap.containsKey(perDate.year())) {
                storePerDate.customYear += perDate > changeYearMap.get(perDate.year()) || perDate.year() == 1989 ? '' : '#';
            }
            storePerDate.customMonth = String.valueOf(perDate.month());
            storePerDate.customDay = String.valueOf(perDate.day());
        }
    }
    
     /**
     * 「年」選択オプションを作成
     */
    public List<SelectOption> getSelectYear(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('',''));
        for (Integer i = 2010; i >= 1900; i--){
            options.add(new SelectOption(String.valueOf(i),String.valueOf(i)));
        }
        return options;
    }
    
     /**
     * 「月」選択オプションを作成
     */
    public List<SelectOption> getSelectMonth(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('',''));
        for (Integer i = 1; i <= 12; i++){
            options.add(new SelectOption(String.valueOf(i),String.valueOf(i)));
        }
        return options;
    }

     /**
     * 「日」選択オプションを作成
     */
    public List<SelectOption> getSelectDay(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('',''));
        for (Integer i = 1; i <= 31; i++){
            options.add(new SelectOption(String.valueOf(i),String.valueOf(i)));
        }
        return options;
    }

     /**
     * 時間短縮営業等実施期間開始日選択オプションを作成
     */
    public List<SelectOption> getSelectTsbDay(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('',''));
        Integer startNum=Integer.valueOf(System.Label.STORE_START_DATE.substring(8));
        Integer endNum=Integer.valueOf(System.Label.STORE_END_DATE.substring(8));
        endDay=endNum;
        for (Integer i = startNum; i <= endNum; i++){
            options.add(new SelectOption(String.valueOf(i),String.valueOf(i)));
        }
        return options;
    }
    
     /**
     * 「和暦年（yyyy年）」ような日付選択オプションを作成
     */
    public List<SelectOption> getSelectTsbDate(){
        Date sDate=Date.valueOf(System.Label.STORE_START_DATE);
        Date eDate=Date.valueOf(System.Label.STORE_END_DATE);
        
        return Application15Utility.getSelectTsbDate(sDate,eDate);
    }
    
     /**
     * 「和暦年（yyyy年）」ような年分選択オプションを作成
     */
    public List<SelectOption> getSelectWarekiYear() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('',''));

        // SelectOptionに追加したインデックスのセット
        Set<Integer> addedYearSet = new Set<Integer>();

        List<Integer> valueList = new List<Integer>();
        List<String> labelList = new List<String>();
        Application15Utility.createWarekiYear(valueList, labelList);
        Integer nowYear = Date.today().year();
        for (Integer i = 0; i <= (nowYear - 1989 + 1); i++){
            String yStr = addedYearSet.contains(valueList[i]) ? String.valueOf(valueList[i]) + '#' : String.valueOf(valueList[i]);
            options.add(new SelectOption(yStr, labelList[i])); 
            addedYearSet.add(valueList[i]);
        }
        return options;
    }

    /**
     *　特別選択営業許可証文字オプションを作成
     */
    public List<SelectOption> getSelectPerNumberSub(){
        List<SelectOption> options = new List<SelectOption>();
        String adressType=store.Application_Store_Address_Type__c;
        if(String.isEmpty(adressType)){
            return options;
        }
        String pDependentField='Application_Store_Per_Number_String2__c';
        List<String> depentList=Application15Utility.GetDependentFormat(adressType,pDependentField);
        if(depentList.size() == 0){
            return options;
        }
        if(adressType != '練馬区'){
            options.add(new SelectOption('',''));
        }
        
        for (String value:depentList) {
            options.add(new SelectOption(value, value));
        }
        
        return options;
    }
    
     /**
     * 店舗の時間短縮営業等実施期間の表示メッセージを設定
     */
    private void doFormatDaysMsg() {
        // 時短営業日数        
        if (store.Application_Store_Days__c != null) {
            String startDate = Application15Utility.changeWarekiYear(String.valueOf(store.Application_Store_Start_Date__c),0);
            String endDate = Application15Utility.changeWarekiYear(String.valueOf(store.Application_Store_End_Date__c),0);
            storeTsbStartDate.tsbDisplayMsg = String.format(Application15Const.CONST_APP15_SHORTER_BUSI_PERIOD_MSG, 
                                                            new List<String>{startDate,endDate,String.valueOf(store.Application_Store_Days__c)});
        } else {
            storeTsbStartDate.tsbDisplayMsg = '';
        }

        startDateLbl=Application15Utility.changeWarekiYear(System.Label.STORE_START_DATE,0);
        startMonthLbl=Application15Utility.changeWarekiYear(System.Label.STORE_START_DATE,1);
        endDateLbl=Application15Utility.changeWarekiYear(System.Label.STORE_END_DATE,0);
        
    }
    
     /**
     * 改訂された内容を更新
     */
    public void doReviseUpdate() {
        // 生年月日
        apply15.Applicant_Birthday__c = Date.valueOf(year + '-' + month + '-' + day);
        
        Savepoint sp = Database.setSavepoint();
        Database.SaveResult sr = Database.update(apply15, false);
        if (!sr.isSuccess()) {
            for (Database.Error err : sr.getErrors()) {
                JSONString = JSONString + '</br>' + err.getMessage(); 
            }
            Database.rollback(sp);
            return;
        }
    }
    
     /**
     * 店舗改訂された内容を更新
     */
    public void doStoreReviseUpdate() {
        // 店舗の許可証年月日、時短営業開始日、時短営業終了日を設定
        // 許可証年月日
        store.Application_Store_Per_Date__c=storePerDate.customDate;
        // 承認ステータス変更日時
        store.ChangeStatus__c = Date.today();
        // 時短営業開始日、時短営業終了日
        if (store.Application_Store_Name__c!= null) {
            store.Application_Store_Start_Date__c= 
                Date.newInstance(Application15Const.CONST_APP15_SHORTER_BUSI_START_DATE.year(),
                                 Integer.valueOf(storeTsbStartDate.customMonth),
                                 Integer.valueOf(storeTsbStartDate.customDay));
            store.Application_Store_End_Date__c=Application15Const.CONST_APP15_SHORTER_BUSI_END_DATE;
        }
        
        Savepoint sp = Database.setSavepoint();
        Database.SaveResult uResults = Database.update(store, false);
        if (!uResults.isSuccess()) {
            for (Database.Error err : uResults.getErrors()) {
                JSONString = JSONString + '</br>' + err.getMessage(); 
                System.debug('JSONString:::::'+JSONString);
            }
            Database.rollback(sp);
            return;
        }
    }
   
}