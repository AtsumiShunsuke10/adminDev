/*******************************************************************************
 *  プロジェクト名 : ○○県新型コロナウイルス感染症拡大防止協力金
 *  クラス         : 申請（感染症拡大防止協力金：第3弾）一覧コントローラ
 *  クラス名       : Application4ListController
 *  概要           : 申請（感染症拡大防止協力金：第3弾）一覧コントローラ
 *  作成者         : トランス・コスモス
 *  作成日         : 2021/09/01
 *******************************************************************************/
global with sharing class Application4ListController {
    
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
    public Map<Integer, CustomDate> storePerDateMap     { get;set; }
    // 時短営業開始日のマップ
    public Map<Integer, CustomDate> storeTsbStartDateMap{ get;set; }
    // 時短営業表示ラベル
    public String startDateLbl { get;set; }
    public String startMonthLbl { get;set; }
    public String endDateLbl { get;set; }
    public Integer endDay { get;set; }
    
    public String JSONString                            { get;set; }

    public Boolean normalFlag                           { get;set; }
    public Boolean kojinFlag                            { get;set; }

    // 一覧画面表示レコードリスト
    public List<Application4__c> apply4List             { get;set; }
    // 申請（感染症拡大防止協力金：第3弾）店舗リスト
    public List<Store__c> storeList                     { get;set; }
    // 申請者ID
    private Id conId;
    // 申請（感染症拡大防止協力金：第3弾）レコードID
    public String applyId                               { get;set; }
    // 申請（感染症拡大防止協力金：第3弾）レコード
    public Application4__c apply4                       { get;set; }
    public static String tempStr                        { get;set; }

    /** 1店舗の感染防止対策協力金 */
    public Integer storeAmount  { get;set; }
    
    //店舗申請最大軒数
    Integer maxStore=Integer.valueOf(System.Label.STORE_CNT);
    
    //時短営業終了日
    public String CONST_SHORTER_BUSI_END_DATE      { get;set; }
    
    public Application4ListController() {
        if(conId == null) conId = [select contactid from User where Id = :Userinfo.getUserId()].contactid;
        String conditionStr='';
        if(conId!=null){
            conditionStr='Contact__c=\'' + conId + '\' and Status__c!=\'' + Application4Const.CONST_APP4_STATUS_NOT_PROPOSED + '\'';
        }
        apply4List = Database.query(Application4Utility.getAllColumnSoql('Application4__c', conditionStr, 'Name desc', '1000'));
        
        //時短営業終了日
        CONST_SHORTER_BUSI_END_DATE = Application4Utility.fmtDate(Application4Const.CONST_APP4_SHORTER_BUSI_END_DATE, Application4Const.CONST_DATE_FMT);
    }

    // 新規画面に遷移
    public PageReference toInputPage() {
        PageReference pr = new PageReference(Site.getBaseSecureUrl() + '/s/Application4Input');
        pr.setRedirect(false);
        return pr;
    }

    // 申請詳細画面に遷移
    public PageReference toDetailPage() {
        rentFlagList = new List<Boolean>();
        PageReference pr = new PageReference(page.Application4Detail.getUrl());
        pr.setRedirect(false);
        return pr;
    }

    // 申請詳細画面を初期
    public void initDetailPage() {
        
        if(applyId != null) {
            apply4 = Database.query(Application4Utility.getAllColumnSoql('Application4__c', applyId));
            
            List<String> fieldsList = Application4Utility.getAllColumnsList('Store__c');
            String query = Application4Utility.makeSoql(fieldsList, 'Store__c', 'Application4__c = \''+ apply4.Id +'\'', '', '', '');
            storeList = Database.query(query);
        }
        bShowReviseBtn = Application4Const.CONST_APP4_STATUS_WAIT_ANSWER.equals(apply4.Status__c) ? true : false;
        kojinFlag = false;
        normalFlag = true;
        /* normalFlag = false;
        //事業活動に必要な許可事，「支払口座」に記載した振込先口座情報：通常申請のみ表示
        if(apply4.Application__c == null && apply4.Application2__c == null){
            normalFlag=true;
        }*/
        //本人確認書類:個人通常申請のみ表示
        // if(normalFlag && apply4.Applicant_Division__c==Application4Const.CONST_APP4_APP_DIV_SOLE){
        //     kojinFlag=true;
        // }
        kojinFlag = apply4.Applicant_Division__c == Application4Const.CONST_APP4_APP_DIV_SOLE;

        List<ContentVersion> issAttachment = Application4Utility.initIssAttachment(applyId);
        List<ContentVersion> attachmentList = new List<ContentVersion>();
        attachmentList.addAll(issAttachment);
        
        attachStoreMap = new Map<Integer,List<ContentVersion>>();
        for(Integer idx = 0;idx < storeList.size(); idx++){
            attachStoreMap.put(idx,new List<ContentVersion>());
            attachmentList.addAll(Application4Utility.initIssAttachment(storeList.get(idx).Id));
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
        
        // 許可年月日の年、月、日、と時短営業開始日を設定
        setTsbStartDate();
        
        // 店舗の時間短縮営業等実施期間の表示メッセージを設定
        doFormatDaysMsg();
    }

    // 拡張子によって、レビュータイプを決定
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
    // 訂正＆提出画面に遷移
    public PageReference toRevisePage() {
        // 申請者情報審査結果のセット
        Set<String> infoCheckSet = new Set<String>();
        infoCheckSet.add(apply4.Filled_App_Info_Is_No_Omissions__c);    // ①記入漏れがないか
        infoCheckSet.add(apply4.Document_And_App_Name_Info_Is_Same__c); // ③本人確認書類と一致しているか
        infoCheckSet.add(apply4.Business_Permit_Info_Is_Same__c);       // ④営業許可書と一致しているか
        infoCheckSet.add(apply4.Store_Num_And_Store_Info_Is_Same__c);   // ⑤店舗数が申請店舗数と一致しているか
        infoCheckSet.add(apply4.Com_Number_And_Com_Info_Is_Same__c);    // ⑥法人番号と会社名が一致しているか     
        
        storeReviceMap = new Map<Integer, Boolean>();
        storeResubmitMap = new Map<Integer, Boolean>();

        // 時短短縮を行った店舗情報審査結果のセット
        // Set<String> storeCheckSet = new Set<String>();
        List<String> fieldsList = Application4Utility.getAllColumnsList('Store__c');
        String query = Application4Utility.makeSoql(fieldsList, 'Store__c', 'Application4__c = \''+ apply4.Id +'\'', '', '', '');
        storeList = Database.query(query);
        for(Integer i = 0;i< storeList.size(); i++){
            Store__c s = storeList.get(i);
            Set<String> storeReviceCheckSet = new Set<String>();
            // ⑮店舗「i」の名称が営業許可書と一致しているか
            storeReviceCheckSet.add(String.valueOf(s.Store_Business_Permit_And_Name_Is_Same__c));
            // ⑯店舗「i」の許可番号・年月日が許可書の記載と一致し、日付が有効期限内である
            storeReviceCheckSet.add(String.valueOf(s.Store_Business_Permit_Info_Is_Correct__c));
            // ⑰店舗「i」の営業許可書の「１営業所の所在地」と一致し、対象エリアである
            storeReviceCheckSet.add(String.valueOf(s.Store_Business_Permit_And_Add_Is_Same__c));

            storeReviceMap.put(i, storeReviceCheckSet.contains(Application4Const.CONST_APP4_SCR_RET_1_NG));


            Set<String> storeFileCheckSet = new Set<String>();
            // ⑩店舗「i」の外観が分かる写真がある
            storeFileCheckSet.add(String.valueOf(s.Store_Appearance_Document__c));
            // ⑪店舗「i」の飲食店の営業許可書の写しがある
            storeFileCheckSet.add(String.valueOf(s.Store_Business_Permit_Document__c));
            // ⑫店舗「i」の酒類を提供していることがわかる書面等の写しがある
            storeFileCheckSet.add(String.valueOf(s.Store_Alcohol_Document__c));
            // ⑬店舗「i」において「時短営業の案内」を掲示したことがわかるものがある
            storeFileCheckSet.add(String.valueOf(s.Store_Time_Saving_Document__c));
            // ⑭店舗「i」の従来の営業時間がわかる写真等がある
            storeFileCheckSet.add(String.valueOf(s.Store_Time_Saving_Document_Old__c));

            storeResubmitMap.put(i, storeFileCheckSet.contains(Application4Const.CONST_APP4_SCR_RET_4_RESUB));
        }

        bInfoRevise = infoCheckSet.contains(Application4Const.CONST_APP4_SCR_RET_1_NG);
        bBankRevise = apply4.Document_And_Info_Is_Same__c == Application4Const.CONST_APP4_SCR_RET_1_NG       // ⑧通帳等の写しと口座情報が一致しているか
                   || apply4.Applicant_Acc_Holder_Is_Same__c == Application4Const.CONST_APP4_SCR_RET_1_NG;   // ⑨申請者と口座名義人が一致しているか
        bStoreRevise = storeReviceMap.values().contains(true);

        // データ不備ありのフラッグ
        incompleteFlag = bInfoRevise || bStoreRevise || bBankRevise;
        // ファイル不備ありのフラッグ
        resubmitFlag = storeResubmitMap.values().contains(true)
                    || apply4.Identification_Document__c == Application4Const.CONST_APP4_SCR_RET_4_RESUB    // ②本人確認書類の写しがある
                    || apply4.Banking_Account_Document__c == Application4Const.CONST_APP4_SCR_RET_4_RESUB;  // ⑦振込先口座情報が分かる書類の写しがある
        

        // データ不備ある場合
        if (incompleteFlag) {
            PageReference pr = new PageReference(page.Application4Revise.getUrl());
            pr.setRedirect(false);
            return pr;
        }
        // ファイルのみ不備ある場合

        if(resubmitFlag){
            PageReference pr = new PageReference(page.Application4ChangeFile.getUrl());
            pr.getParameters().put('FromPage', 'Application4Detail');
            pr.setRedirect(false);
            return pr;
        }

        return null;
    }
    // 訂正＆提出画面を初期
    public void initRevisePage() {
        // 生年月日を設定
        if(apply4.Applicant_Birthday__c != null){
            year = String.valueOf(apply4.Applicant_Birthday__c.year());
            month = String.valueOf(apply4.Applicant_Birthday__c.month());
            day = String.valueOf(apply4.Applicant_Birthday__c.day());
        }

        // 許可年月日の年、月、日を設定
        setPerDate();
    }
    

    /**
     * 時短営業開始日を設定
     */
    private void setTsbStartDate() {

        storeTsbStartDateMap = new Map<Integer, CustomDate>();
        for (Integer i = 0; i < storeList.size(); i++) {

            Date stDate = storeList[i].Application_Store_Start_Date__c;
            CustomDate cusDate = new CustomDate();
            // 時短営業開始日を設定
            if (stDate != null) {
                cusDate.customYear = String.valueOf(stDate.year());
                cusDate.customMonth = String.valueOf(stDate.month());
                cusDate.customDay = String.valueOf(stDate.day());
                cusDate.customDateStr = String.valueOf(stDate);
            } else {
                cusDate.customYear = String.valueOf(Application4Const.CONST_APP4_SHORTER_BUSI_START_DATE.year());
                cusDate.customMonth = String.valueOf(Application4Const.CONST_APP4_SHORTER_BUSI_START_DATE.month());
            }
            storeTsbStartDateMap.put(i, cusDate);
        }
    }
    
    /**
     * 許可年月日の年、月、日を設定
     */
    private void setPerDate() {
        
        storePerDateMap = new Map<Integer, CustomDate>();
        Map<Integer, Date> changeYearMap = Application4Utility.createWarekiChangeYear();
        for (Integer i = 1; i <= storeList.size(); i++) {
            store__c s= storeList.get(i-1);
            Date perDate = (Date)s.Application_Store_Per_Date__c;
            CustomDate cusDate = new CustomDate();

            if (perDate != null) {
                cusDate.customYear = String.valueOf(perDate.year());
                // 年号変更識別子を追加
                if (changeYearMap.containsKey(perDate.year())) {
                    cusDate.customYear += perDate > changeYearMap.get(perDate.year()) || perDate.year() == 1989 ? '' : '#';
                }
                cusDate.customMonth = String.valueOf(perDate.month());
                cusDate.customDay = String.valueOf(perDate.day());
            }
            storePerDateMap.put(i, cusDate);
        }
    }
    
    // 「年」選択オプションを作成
    public List<SelectOption> getSelectYear(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('',''));
        for (Integer i = 2010; i >= 1900; i--){
            options.add(new SelectOption(String.valueOf(i),String.valueOf(i)));
        }
        return options;
    }
    // 「月」選択オプションを作成
    public List<SelectOption> getSelectMonth(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('',''));
        for (Integer i = 1; i <= 12; i++){
            options.add(new SelectOption(String.valueOf(i),String.valueOf(i)));
        }
        return options;
    }
    // 「日」選択オプションを作成
    public List<SelectOption> getSelectDay(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('',''));
        for (Integer i = 1; i <= 31; i++){
            options.add(new SelectOption(String.valueOf(i),String.valueOf(i)));
        }
        return options;
    }
    // 時間短縮営業等実施期間開始日選択オプションを作成
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

    public List<SelectOption> getSelectTsbDate(){
        Date sDate=Date.valueOf(System.Label.STORE_START_DATE);
        Date eDate=Date.valueOf(System.Label.STORE_END_DATE);
        
        return Application4Utility.getSelectTsbDate(sDate,eDate);
    }
    
    // 「和暦年（yyyy年）」ような年分選択オプションを作成
    public List<SelectOption> getSelectWarekiYear() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('',''));

        // SelectOptionに追加したインデックスのセット
        Set<Integer> addedYearSet = new Set<Integer>();

        List<Integer> valueList = new List<Integer>();
        List<String> labelList = new List<String>();
        Application4Utility.createWarekiYear(valueList, labelList);
        Integer nowYear = Date.today().year();
        for (Integer i = 0; i <= (nowYear - 1989 + 1); i++){
            String yStr = addedYearSet.contains(valueList[i]) ? String.valueOf(valueList[i]) + '#' : String.valueOf(valueList[i]);
            options.add(new SelectOption(yStr, labelList[i])); 
            addedYearSet.add(valueList[i]);
        }
        return options;
    }

    // 改訂された内容を更新
    public void doReviseUpdate() {
        // 生年月日
        apply4.Applicant_Birthday__c = Date.valueOf(year + '-' + month + '-' + day);
        
        // 店舗の許可証年月日、時短営業開始日、時短営業終了日を設定
        for (Integer i = 1; i <= storeList.size(); i++) {
            store__c s= storeList.get(i-1);
            // 許可証年月日
            s.Application_Store_Per_Date__c=storePerDateMap.get(i).customDate;

            // 時短営業開始日、時短営業終了日
            if (s.Application_Store_Name__c!= null) {
                s.Application_Store_Start_Date__c= 
                    Date.newInstance(Application4Const.CONST_APP4_SHORTER_BUSI_START_DATE.year(),
                                     Integer.valueOf(storeTsbStartDateMap.get(i-1).customMonth),
                                     Integer.valueOf(storeTsbStartDateMap.get(i-1).customDay));
                s.Application_Store_End_Date__c=Application4Const.CONST_APP4_SHORTER_BUSI_END_DATE;
            }
            /*else {
                apply4.put('Application_Store_' + i +'_Start_Date__c', null);
                apply4.put('Application_Store_' + i +'_End_Date__c', null);
            }*/
        }

        Savepoint sp = Database.setSavepoint();
        Database.SaveResult sr = Database.update(apply4, false);
        if (!sr.isSuccess()) {
            for (Database.Error err : sr.getErrors()) {
                JSONString = JSONString + '</br>' + err.getMessage(); 
            }
            Database.rollback(sp);
            return;
        }

        List<Database.SaveResult> uResults = Database.update(storeList, false);
        for(Database.SaveResult ur:uResults){
            if (!ur.isSuccess()) {
                for (Database.Error err : ur.getErrors()) {
                    JSONString = JSONString + '</br>' + err.getMessage(); 
                    System.debug('JSONString:::::'+JSONString);
                }
                Database.rollback(sp);
                return;
            }
        }
    }

    // 申請詳細画面に戻る
    public PageReference returnDetailPage() {
        PageReference pr = new PageReference(page.Application4Detail.getUrl());
        pr.setRedirect(false);
        return pr;
    }

    // 前のページに戻る
    public PageReference returnPrevPage() {
        //前画面に戻る選択された添付ファイルはクリアされます
        deleteFile();

        PageReference pr;
        // 前のページを取得
        String prevPage = ApexPages.currentPage().getParameters().get('FromPage');

        if (prevPage == 'Application4Detail') {
            pr = new PageReference(page.Application4Detail.getUrl());
        }else {
            pr = new PageReference(page.Application4Revise.getUrl());
        }

        pr.setRedirect(false);
        return pr;
    }
    
    // 添付資料再提出画面に遷移(訂正画面から)
    public PageReference toChangeFile(){
        PageReference pr =  new PageReference(page.Application4ChangeFile.getUrl());
        pr.getParameters().put('FromPage', 'Application4Revise');
        pr.setRedirect(false);
        return pr;
    }
    
    public void initChangeFilePage(){
        
        apply4 = Database.query(Application4Utility.getAllColumnSoql('Application4__c', applyId));
        List<String> fieldsList = Application4Utility.getAllColumnsList('Store__c');
        String query = Application4Utility.makeSoql(fieldsList, 'Store__c', 'Application4__c = \''+ apply4.Id +'\'', '', '', '');
        storeList = Database.query(query);
        // 店舗の時間短縮営業等実施期間の表示メッセージを設定
        doFormatDaysMsg();
        // 個人事業主フラッグ
        kojinFlag = apply4.Applicant_Division__c == Application4Const.CONST_APP4_APP_DIV_SOLE;
        
        apply4.SessionRadom__c = String.valueof((Math.random() * 10));
        apply4.Number_FileReUpload__c = apply4.Number_FileReUpload__c == null ? 1 : apply4.Number_FileReUpload__c;
        upsert apply4;

    }

    // 店舗の時間短縮営業等実施期間の表示メッセージを設定
    private void doFormatDaysMsg() {
        for (Integer i = 0; i < storeList.size(); i++) {
            Store__c s = storeList[i];
            // 時短営業日数        
            if (s.Application_Store_Days__c != null) {
                String startDate = Application4Utility.changeWarekiYear(String.valueOf(s.Application_Store_Start_Date__c),0);
                String endDate = Application4Utility.changeWarekiYear(String.valueOf(s.Application_Store_End_Date__c),0);
                storeTsbStartDateMap.get(i).tsbDisplayMsg = String.format(Application4Const.CONST_APP4_SHORTER_BUSI_PERIOD_MSG, 
                                                                          new List<String>{startDate,endDate,String.valueOf(s.Application_Store_Days__c)});
            } else {
                storeTsbStartDateMap.get(i).tsbDisplayMsg = '';
            }
        }
        startDateLbl=Application4Utility.changeWarekiYear(System.Label.STORE_START_DATE,0);
        startMonthLbl=Application4Utility.changeWarekiYear(System.Label.STORE_START_DATE,1);
        endDateLbl=Application4Utility.changeWarekiYear(System.Label.STORE_END_DATE,0);
        
    }
    
    // 一覧画面に戻る
    public PageReference toListPage() {
        //前画面に戻る選択された添付ファイルはクリアされます
        deleteFile();
        PageReference pr = new PageReference(page.Application4List.getUrl());
        pr.setRedirect(false);
        return pr;
    }
    
    // 完了画面に遷移
    public PageReference toCompletePage() {

        apply4.Number_FileReUpload__c = apply4.Number_FileReUpload__c == null ? 1 : apply4.Number_FileReUpload__c + 1;
        apply4.Document_Reupload__c = Application4Const.CONST_APP4_DOCUMENT_REUPLOAD_REUPLOADED;
        apply4.Status__c = Application4Const.CONST_APP4_STATUS_EXAMINATION;
        apply4.SubStatus__c = Application4Const.CONST_APP4_SUB_STATUS_REAPPLY;
        apply4.SessionRadom__c = '';
        upsert apply4;
        
        PageReference pr = new PageReference (page.Application4Complete2.getUrl());
        pr.setRedirect(false);
        return pr;
        
    }
    
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
    public static String getParentId(String tempStr){

        String rId='';
        Application4__c app3=[Select id From Application4__c Where SessionRadom__c =:tempStr];
        rId=app3.Id;

        return rId;

    }

    webService static String deleteDocument(String filename,String tempStr,String store){
        try{
            Id appid = (Id)getParentId(tempStr);
            List<ContentVersion> ContentVersionList=new List<ContentVersion>();
            set<Id> cvIds= new set<Id>();
            ContentVersionList =[SELECT ContentDocumentId,Description FROM ContentVersion WHERE Description like :filename+'%'];
            for(ContentVersion cv : contentVersionlist){
                cvIds.add(cv.ContentDocumentId);
            }

            List<ContentDocumentLink> links = [SELECT Id,ContentDocumentId FROM ContentDocumentLink WHERE (LinkedEntityId =: appid or LinkedEntityId =: store) and ContentDocumentId in:cvIds];
            set<Id> linkIds= new set<Id>();
            for(ContentDocumentLink link : links){
                linkIds.add(link.ContentDocumentId);
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
    
    //添付ファイルはクリアされます
    public void deleteFile(){
        List<ContentDocumentLink> links = [SELECT Id,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: apply4.id];
        set<Id> linkIds= new set<Id>();
        for(ContentDocumentLink link : links){
            linkIds.add(link.ContentDocumentId);
        }
        List<ContentDocument> delatt = [SELECT Id FROM ContentDocument WHERE Id =: linkIds AND (Description like :'%' + 'type_re' + apply4.Number_FileReUpload__c + '%' OR Description like :'%' + 'store_re' + apply4.Number_FileReUpload__c + '%')];
        if ( delatt.size() > 0 ) {
            delete delatt;
        }
    }

    /**
     * 郵便番号で住所を取得
     *
     * @param String postcode 郵便番号
     * @return String 住所
     */
    @RemoteAction
    public static String getAddress(String postcode) {
        
        // 申請（感染症拡大防止協力金：第3弾）共通処理.郵便番号で住所マスタから住所を取得
        String address = Application4Utility.getAddressByPostCode(postcode);
        
        return address;
        
    }

}