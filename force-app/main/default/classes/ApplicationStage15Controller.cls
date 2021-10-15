/*******************************************************************************
 *  プロジェクト名 : ○○県新型コロナウイルス感染症拡大防止協力金
 *  クラス         : 申請（感染症拡大防止協力金：第15弾）ステージコントローラ
 *  クラス名       : ApplicationStage15Controller
 *  概要           : 申請（感染症拡大防止協力金：第15弾）ステージコントローラ
 *  作成者         : トランス・コスモス
 *  作成日         : 2021/10/01
 *******************************************************************************/
global with sharing class ApplicationStage15Controller{

    // 申請番号
    public String applyNum  { get;set; }

    // 申請（感染症拡大防止協力金：第15弾）レコード
    public Application15__c apply15      { get;set; }
    public Application15__c apply15tmp   { get;set; }
    
    // 申請（感染症拡大防止協力金：第15弾）店舗情報
    public List<Store15__c> storesList   { get;set; }
    public List<Store15__c> storeDisplayList   { get;set; }
    public Store15__c store   { get;set; }
    public Integer storeIdx   { get;set; }
    
    // for test
    public Boolean testStr   { get;set; }
    public static String tempStr { get;set; }
    public Boolean normalFlag   { get;set; }
    public Boolean kojinFlag   { get;set; }
    // 簡易申請
    public ApplicationHistory__c applyh    { get;set; }
    public String applicationYear { get;set; }
    public String applicationMonth { get;set; }
    public String applicationDay { get;set; }
    
    //生年月日
    public String year { get;set; }
    public String month { get;set; }
    public String day { get;set; }
    // 申請番号
    public String application15Name { get;set; }
    
    public String JSONString   { get;set; }

    // 営業許可書-許可年月日
    public CustomDate storePerDate  { get;set; }
    // 時短営業開始日
    public CustomDate storeTsbStartDate  { get;set; }
    //時短営業終了日
    public String CONST_SHORTER_BUSI_END_DATE      { get;set; }
    
    // 時短営業表示ラベル
    public String startDateLbl { get;set; }
    public String startYearLbl { get;set; }
    public String endDateLbl { get;set; }
    public Integer endDay { get;set; }
    public Integer endMonth { get;set; }
    
    //合計金額
    public Integer totalAmount { get;set; }
    
    //金融機関名
    public String financialInstitutionName { get;set; }
    
    public Integer pageNum { get;set; }
    public Integer maxPageNum { get;set; }
    public Boolean displayPopup {get;set;}
    public Boolean checkAllStore   { get;set; }    
    private Id conId;
    
    public ApplicationStage15Controller(){
        if(conId == null) conId = [select contactid from User where Id = :Userinfo.getUserId()].contactid;
        //未提出申請者
        if(apply15 == null) {
            apply15 = new Application15__c(Contact__c=conId,SessionRadom__c=String.valueof((Math.random() * 10)));
        }
        applyh = new ApplicationHistory__c();
        pageNum = 1;
        maxPageNum = 1;
        storeIdx = 0;

        //時短営業終了日
        CONST_SHORTER_BUSI_END_DATE = Application15Utility.fmtDate(Application15Const.CONST_APP15_SHORTER_BUSI_END_DATE, Application15Const.CONST_DATE_FMT);

    }
    
    private String getSelectSoqlString(String table, String cond, String options, boolean recordTypeFlg) {
        String rtName;
        if(recordTypeFlg){
            rtName= ',RecordType.Name';
        }
        String query = 'SELECT ' + getAllColumnsString(table) + rtName + ' FROM ' + table;
        if (cond != '') {
            query += ' WHERE ' + cond;
            if (options != '') {
                query += ' ' + options;
            }
        }
        return query;
    }

    private String getAllColumnsString(String tableName) {
        Map<String, Schema.SObjectField> fieldsMap = getFieldsMap(tableName);
        List<String> fields = new List<String>();
        for (String fieldName : fieldsMap.keySet()) {
            fields.add(fieldName);
        }
        return String.join(fields, ',');
    }

    private Map<String, Schema.SObjectField> getFieldsMap(String tableName) {
        Map<String, Schema.SObjectType> m = Schema.getGlobalDescribe();
        Schema.SObjectType s = m.get(tableName);
        Schema.DescribeSObjectResult r = s.getDescribe();
        return r.fields.getMap();
    }
    
    public void initInputPage(){
        storeIdx = 0;
        if(apply15.Status__c == Application15Const.CONST_APP15_STATUS_NOT_PROPOSED){
            deleteFile();
        }
        store = new Store15__c();
        if(storesList==null){
            storesList  = new List<Store15__c>();
        }

        // 許可年月日の年、月、日、と時短営業開始日を設定
        setAllCustomDate();
    }
    public void initComfirmPage(){
        if(apply15.Status__c == Application15Const.CONST_APP15_STATUS_NOT_PROPOSED){
            //deleteFile();

            kojinFlag=false;
            normalFlag=false;
            //本人確認書類:個人通常申請のみ表示
            kojinFlag = apply15.Applicant_Division__c == Application15Const.CONST_APP15_APP_DIV_SOLE;
            
            if(apply15.id != null){
                apply15 = Database.query(getSelectSoqlString('Application15__c', 'id=\''+apply15.id+'\'', '',true));
                application15Name = apply15.Name;
                List<String> fieldsList = Application15Utility.getAllColumnsList('Store15__c');
                String query = Application15Utility.makeSoql(fieldsList, 'Store15__c', 'Application15__c = \''+ apply15.Id +'\'', '', '', '');
                storesList = Database.query(query);
                // 店舗の時間短縮営業等実施期間の表示メッセージを設定
                if (store.Application_Store_Days__c != null) {
                    storeTsbStartDate.tsbDisplayMsg = String.format(Application15Const.CONST_APP15_SHORTER_BUSI_PERIOD_MSG, 
                                                                                new List<String>{String.valueOf(store.Application_Store_Start_Date__c),
                                                                                    String.valueOf(store.Application_Store_End_Date__c),
                                                                                    String.valueOf(store.Application_Store_Days__c)});
                }
                
            }
        }

    }
    
    public void initStorePage(){
        for(Store15__c s :storesList){
            if(s.StoreIndex__c == storeIdx){
                store = s;
                break;
            }
        }
        setAllCustomDate();

    }
    
    public void initStoreUploadPage(){
        Integer idx = storesList.indexOf(store);
        
        List<String> fieldsList = Application15Utility.getAllColumnsList('Store15__c');
        String query = Application15Utility.makeSoql(fieldsList, 'Store15__c', 'Id = \''+ store.Id +'\'', '', '', '');
        store = Database.query(query);
        
        storeTsbStartDate.tsbDisplayMsg = String.format(Application15Const.CONST_APP15_SHORTER_BUSI_PERIOD_MSG, 
                                                                    new List<String>{String.valueOf(store.Application_Store_Start_Date__c),
                                                                        String.valueOf(store.Application_Store_End_Date__c),
                                                                        String.valueOf(store.Application_Store_Days__c)});

        if(idx == - 1){
            storesList.add(store);
            pageNum = maxPageNum;
        }else{
            storesList.remove(idx);
            if(idx == storesList.size()){
                storesList.add(store);
            }else{
                storesList.add(idx,store);
            }
        }
    }
    
    public List<SelectOption> getSelectYear(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('',''));
        for (Integer i = 2010; i >= 1900; i--){
            options.add(new SelectOption(String.valueOf(i),String.valueOf(i)));
        }
        return options;
    }
    public List<SelectOption> getSelectMonth(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('',''));
        for (Integer i = 1; i <= 12; i++){
            options.add(new SelectOption(String.valueOf(i),String.valueOf(i)));
        }
        return options;
    }
    public List<SelectOption> getSelectDay(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('',''));
        for (Integer i = 1; i <= 31; i++){
            options.add(new SelectOption(String.valueOf(i),String.valueOf(i)));
        }
        return options;
    }
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

        return Application15Utility.getSelectTsbDate(sDate,eDate);
    }
    
    public void calculateAmount(){
        Integer amount = 0;
        for(Store15__c s:storesList){
            if(s.Application_Store_Apply_Amount__c!=null){
                amount = amount + Integer.valueOf(s.Application_Store_Apply_Amount__c);
            }
        }
        apply15.Application_Sum_Amount_Screen__c = amount;
    }
    
    // 「和暦年（yyyy年）」ような年分選択オプションを作成
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

    public List<SelectOption> getSelectApplication() {
        
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--なし--'));
        options.add(new SelectOption(Application15Const.CONST_APP_SELECT_LIST_VALUE1, Application15Const.CONST_APP_SELECT_LIST_LABEL1));
        options.add(new SelectOption(Application15Const.CONST_APP_SELECT_LIST_VALUE2, Application15Const.CONST_APP_SELECT_LIST_LABEL2));
        return options;
        
    }
    
    public PageReference goBackFromStore() {
        storeIdx = 0;
        PageReference pr =  new PageReference(page.Application15Input.getUrl());
        pr.getParameters().put('backflag','true');
        pr.setRedirect(false);
        return pr;
    }
    
    public PageReference completeFromStore() {
        calculateAmount();
        Integer maxNum = Integer.valueOf(System.Label.STORE_LIST_PAGE_NUM);
        maxPageNum=storesList.size()/maxNum+1;
        storeDisplayList = (List<Store15__c>)Application15Utility.getPageRecordList(storesList,pageNum);
        PageReference pr =  new PageReference(page.Application15Input.getUrl());
        pr.getParameters().put('backflag','true');
        pr.setRedirect(false);
        return pr;
    }
    
    public PageReference toInputPage() {
        deleteFile();
        PageReference pr = new PageReference(page.Application15Input.getUrl());
        pr.getParameters().put('backflag','true');
        pr.setRedirect(false);
        return pr;
    }
    
    public PageReference toUploadFileForStore(){
        PageReference pr =  new PageReference(page.Store15UploadFile.getUrl());
        pr.setRedirect(false);
        return pr;
    }
    
    public PageReference toConfirm(){
        PageReference pr =  new PageReference(page.Application15Confirm.getUrl());
        pr.setRedirect(false);
        return pr;
    }
    
    public PageReference toStoreDetail(){
        PageReference pr =  new PageReference(page.Application15StoreInput.getUrl());
        pr.setRedirect(false);
        return pr;
    }
    
    public PageReference backToStoreModify(){
        deleteStoreFile();
        PageReference pr =  new PageReference(page.Application15StoreInput.getUrl());
        pr.setRedirect(false);
        return pr;
    }
    
    public void toUploadFileForStorePage(){
        Savepoint sp = Database.setSavepoint();
        // 仮申請 作成
        setTempApplication();
        store.Application15__c = apply15tmp.Id;
        // 許可証年月日
        store.Application_Store_Per_Date__c=storePerDate.customDate;
        //時間短縮営業等実施期間
        if (store.Application_Store_Name__c!= null) {
            store.Application_Store_Start_Date__c= 
                Date.newInstance(Application15Const.CONST_APP15_SHORTER_BUSI_START_DATE.year(),
                                 Integer.valueOf(storeTsbStartDate.customMonth),
                                 Integer.valueOf(storeTsbStartDate.customDay));
            store.Application_Store_End_Date__c=Application15Const.CONST_APP15_SHORTER_BUSI_END_DATE;
        }

        if(storesList.size() == 0){
            store.StoreIndex__c = 1;
        }else if( store.StoreIndex__c == null){
            store.StoreIndex__c = storesList[storesList.size()-1].StoreIndex__c +1;
        }
        
        Database.upsertResult ur = Database.upsert(store, false);
        if (!ur.isSuccess()) {
            for (Database.Error err : ur.getErrors()) {
                JSONString = JSONString + '</br>' + err.getMessage(); 
            }
            Database.rollback(sp);
            return;
        }
    }

    public void toConfirmPage(){
        //店舗数チェック
        if(storesList.size()==0){
            JSONString = JSONString + '</br>'+System.Label.NO_STORE_IN_APPLICATION_MSG+'<br/>'; 
            return;
        }
        if(storesList.size()!=Integer.valueOf(apply15.Applicant_Store_Count__c)){
            JSONString = JSONString + '</br>'+System.Label.STORE_COUNT_MSG+'<br/>'; 
            return;
        }
 
        //店舗情報が不完全な場合
        for(Store15__c s:storesList){
            if(s.Application_For_Parent_Amount__c == null){
                JSONString = JSONString + '</br>'+System.Label.STORE_INFO_INCOMPLETE_MSG+'<br/>';
                return;
            }
        }
        
        // 代表者又は申請者の生年月日
        Date birthday = Date.valueOf(year+'-'+month+'-'+day);
        apply15.Applicant_Birthday__c = birthday;
        // ステータス
        apply15.Status__c = Application15Const.CONST_APP15_STATUS_NOT_PROPOSED;
        //※項目変更未反映、改修の可能性がある
		//企業規模
		apply15.Company_Scale__c = '中小事業者';
       	//東京都用申請タイプ
		apply15.Tokyo_Application_Type__c = Application15Const.CONST_APP15_TOKYO_TYPE_WEB;
        //レーコドタイプ
        apply15.RecordTypeId = [SELECT id from RecordType where SobjectType ='Application15__c' and DeveloperName ='RecordType_readwrite'].Id;
        //1ユーザが複数の申請できない
        List<String> fieldsList = new List<String>();
        fieldsList.add('Id');
        String condition;
        if(apply15.Applicant_Division__c == Application15Const.CONST_APP15_APP_DIV_CORP){
            condition = ' Corporate_Number__c = \''+apply15.Corporate_Number__c+'\'';
        }else{
            Datetime dt = Datetime.newInstance(birthday.year(), birthday.month(), birthday.day());
            condition = ' Applicant_Business_Name__c = \''+apply15.Applicant_Business_Name__c+'\''
                +' AND Applicant_Birthday__c =' +dt.format('yyyy-MM-dd');
        }
        String query = Application15Utility.makeSoql(fieldsList, 'Application15__c', condition, '', '', '');
        System.debug('***************query*******************'+query);
        List<Application15__c> appList  = Database.query(query);
        if(appList.size() != 0){
            JSONString = JSONString + '</br>'+System.Label.APPLICATION_CANT_APPLY_FOR_MORE_THAN_ONE+'<br/>'; 
            return;
        }
        
        Savepoint sp = Database.setSavepoint();
      
        Database.UpsertResult sr = Database.upsert(apply15, false);
        if (!sr.isSuccess()) {
            for (Database.Error err : sr.getErrors()) {
                JSONString = JSONString + '</br>' + err.getMessage(); 
            }
            Database.rollback(sp);
            return;
        }
        
        //店舗の時短営業開始日、時短営業終了日を設定
        for (Store15__c s:storesList) {
            //申請ID
            s.Application15__c=sr.getId();
        }
        
        List<Database.upsertResult> uResults = Database.upsert(storesList, false);
        for(Database.upsertResult ur:uResults){
            if (!ur.isSuccess()) {
                for (Database.Error err : ur.getErrors()) {
                    JSONString = JSONString + '</br>' + err.getMessage(); 
                }
                Database.rollback(sp);
                return;
            }
        }
    }

    
    private void setTempApplication(){
        String condition='Status__c=\'' 
            + Application15Const.CONST_APP15_STATUS_DUMMY
            + '\' and RecordType.name=\'' 
            + Application15Const.CONST_APP15_STATUS_DUMMY
            + '\' and Contact__c =\''
            +conId+'\'';
        
        List<String> fieldsList = new List<String>();
        fieldsList.add('Id');
        String query = Application15Utility.makeSoql(fieldsList, 'Application15__c', condition, '', '1', '');
        List<Application15__c> appList  = Database.query(query);
        if(appList.size() == 0){
            apply15tmp = new Application15__c(Contact__c=conId,
                                              Status__c=Application15Const.CONST_APP15_STATUS_DUMMY,
                                              Tokyo_Application_Type__c=Application15Const.CONST_APP15_TOKYO_TYPE_WEB,
                                              Company_Scale__c=Application15Const.CONST_APP15_COMPANY_SCALE_S,
                                              Finacial_Account_Number__c='0000000',
                                              Pledge1__c=true);
            insert apply15tmp;
        }else{
            apply15tmp = appList[0];
        }
    }
    
    /**
     * 許可年月日の年、月、日、と時短営業開始日を設定
     */
    private void setAllCustomDate() {
        storePerDate = new CustomDate();
        storeTsbStartDate = new CustomDate();
        Map<Integer, Date> changeYearMap = Application15Utility.createWarekiChangeYear();
        
        Date perDate = (Date)store.Application_Store_Per_Date__c;
        // 許可年月日の年、月、日を設定
        if (perDate != null) {
            storePerDate.customYear = String.valueOf(perDate.year());
            // 年号変更識別子を追加
            if (changeYearMap.containsKey(perDate.year())) {
                storePerDate.customYear += perDate > changeYearMap.get(perDate.year()) ? '' : '#';
            }
            storePerDate.customMonth = String.valueOf(perDate.month());
            storePerDate.customDay = String.valueOf(perDate.day());
        }

        Date stDate = (Date)store.Application_Store_Start_Date__c;

        // 時短営業開始日を設定
        if (stDate != null) {
            storeTsbStartDate.customYear = String.valueOf(stDate.year());
            storeTsbStartDate.customMonth = String.valueOf(stDate.month());
            storeTsbStartDate.customDay = String.valueOf(stDate.day());
            storeTsbStartDate.customDateStr = String.valueOf(stDate);
        }

        //和暦設定
        startDateLbl=Application15Utility.changeWarekiYear(System.Label.STORE_START_DATE,0);
        startYearLbl=Application15Utility.changeWarekiYear(System.Label.STORE_START_DATE,2);
        endDateLbl=Application15Utility.changeWarekiYear(System.Label.STORE_END_DATE,0);
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
            cv =[SELECT ContentDocumentId,title,Description,FileExtension,ReasonForChange,ContentBodyId FROM ContentVersion WHERE Id = :cv.Id];
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
        Application15__c app15 = [Select id From Application15__c Where SessionRadom__c=:tempStr];
        rId = app15.Id;

        return rId;

    }

    webService static String deleteDocument(String filename,String tempStr,String store){
        try{
            List<ContentVersion> ContentVersionList=new List<ContentVersion>();
            set<Id> cvIds= new set<Id>();
            ContentVersionList =[SELECT ContentDocumentId,Description FROM ContentVersion WHERE Description like :filename+'%'];
            for(ContentVersion cv : contentVersionlist){
                cvIds.add(cv.ContentDocumentId);
            }
            set<Id> linkIds;
            
            if(store == null){
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
    
    public PageReference toCompletePage() {

        apply15.Individual_Duplication_Check_Flag__c=true;
        apply15.Corporation_Duplication_Check_Flag__c=true;
        apply15.Status__c = Application15Const.CONST_APP15_STATUS_EXAMINATION;
        apply15.SubStatus__c = Application15Const.CONST_APP15_SUB_STATUS_NEW;
        //未提出申請者
        apply15.SessionRadom__c='';
        //申請回数累計
        apply15.Application_Count__c = 1;
        RecordType retype=[Select id from  RecordType where DeveloperName='RecordType_readonly' and SobjectType='Application15__c'];
        apply15.RecordTypeId=retype.id;
        upsert apply15;
        
        PageReference pr = new PageReference (page.Application15Complete.getUrl());
        pr.setRedirect(false);
        return pr;
        
    }
    
    // 添付ファイルはクリアされます
    public void deleteFile(){
        List<String> fieldsList = new List<String>();
        fieldsList.add('Id');
        String query = Application15Utility.makeSoql(fieldsList, 'Store15__c', 'Application15__c = \''+ apply15.Id +'\'', '', '', '');
        List<String> idList = new List<String>();
        for(Store15__c s:Database.query(query)){
            idList.add(s.Id);
        }
        idList.add(apply15.id);
        List<ContentDocumentLink> links = [SELECT Id,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId in: idList];
        set<Id> linkIds= new set<Id>();
        for(ContentDocumentLink link : links){
            linkIds.add(link.ContentDocumentId);
        }
        List<ContentDocument> delatt = [SELECT Id FROM ContentDocument WHERE Id =: linkIds];
        if ( delatt.size() > 0 ) {
            delete delatt;
        }
    }

    // 店舗添付ファイルはクリアされます
    public void deleteStoreFile(){
        List<String> fieldsList = new List<String>();
        fieldsList.add('Id');
        String query = Application15Utility.makeSoql(fieldsList, 'Store15__c', 'Id = \''+ store.Id +'\'', '', '', '');
        List<String> idList = new List<String>();
        for(Store15__c s:Database.query(query)){
            idList.add(s.Id);
        }
        List<ContentDocumentLink> links = [SELECT Id,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId in: idList];
        set<Id> linkIds= new set<Id>();
        for(ContentDocumentLink link : links){
            linkIds.add(link.ContentDocumentId);
        }
        List<ContentDocument> delatt = [SELECT Id FROM ContentDocument WHERE Id =: linkIds];
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
        
        // 申請（感染症拡大防止協力金：第15弾）共通処理.郵便番号で住所マスタから住所を取得
        String address = Application15Utility.getAddressByPostCode(postcode);
        
        return address;
        
    }
    
    webService static String putHistoryInfo(String corporateDiv,String applicationNo,String corporateNumber,String birthDate) {
        
        Map<String, Object> infoMap = new Map<String, String>();
        List<Sobject> slist = null;
        String condition='Application_No__c = \''+ applicationNo +'\'';
        
        if (corporateDiv == Application15Const.CONST_APP15_APP_DIV_CORP){
            condition += ' and Corporate_Number__c = \''+ corporateNumber +'\' ';
        }else{
            condition += ' and Birthdate__c =' + birthDate;
            condition += ' and Corporate_Number__c = null';
        }

        List<String> fieldsList = Application15Utility.getAllColumnsList('ApplicationHistory__c');
        String query = Application15Utility.makeSoql(fieldsList, 'ApplicationHistory__c', condition, '', '', '');
        slist = Database.query(query);
        if (slist.size() > 0) {
            Sobject sobj = slist[0];
            infoMap.put('applicantNo',sobj.get('Application_No__c'));
            //infoMap.put('userId',sobj.get('UserId__c'));
            infoMap.put('email',sobj.get('Email__c'));
            //infoMap.put('firstNameKana',sobj.get('FirstNameKana__c'));//
            //infoMap.put('firstName',sobj.get('FirstName__c'));//
            //infoMap.put('lastName',sobj.get('LastName__c'));//
            //infoMap.put('lastNameKana',sobj.get('LastNameKana__c'));//
            infoMap.put('accountHolder',sobj.get('Account_Holder__c'));
            //infoMap.put('applicantAddress',sobj.get('Applicant_Address__c'));//
            infoMap.put('applicantBusinessName',sobj.get('Applicant_Business_Name__c'));
            infoMap.put('applicantDivision',sobj.get('Applicant_Division__c'));
            infoMap.put('applicantName',sobj.get('Applicant_Name__c'));
            infoMap.put('applicantPhone',sobj.get('Applicant_Phone__c'));
            //infoMap.put('applicantZip',sobj.get('Applicant_Postal_Code__c'));//
            infoMap.put('applicantTitle',sobj.get('Applicant_Title__c'));
            if(sobj.get('Birthdate__c')!=null){
                Date birth = Date.valueOf(sobj.get('Birthdate__c'));
                infoMap.put('birthYear',String.valueOf(birth.year()));
                infoMap.put('birthMonth',String.valueOf(birth.month()));
                infoMap.put('birthDay',String.valueOf(birth.day()));

            }

            infoMap.put('corporateNum',sobj.get('Corporate_Number__c'));
            infoMap.put('accountNumber',sobj.get('Finacial_Account_Number__c'));
            infoMap.put('accountType',sobj.get('Finacial_Account_Type__c'));
            infoMap.put('branchCode',sobj.get('Finacial_Branch_Code__c'));
            infoMap.put('branchName',sobj.get('Finacial_Branch_Name__c'));
            infoMap.put('financialInstitutionName',sobj.get('FinancialName__c'));
            infoMap.put('financialInstitutionId',sobj.get('Financial_Institution_Lookup__c'));
        }
        return JSON.serialize( infoMap );
    }

    public void setStoreHistory() {
        try {
            String ApplicationNo = applyh.Application_No__c;

            if(String.isEmpty(ApplicationNo)){
                return;
            }
            // 申請番号より過去店舗情報を取得
            List<StoreHistory__c> hList = null;
            String condition='Application_No__c = \''+ ApplicationNo +'\'';
            List<String> fieldsList = Application15Utility.getAllColumnsList('StoreHistory__c');
            String query = Application15Utility.makeSoql(fieldsList, 'StoreHistory__c', condition, '', '', '');
            System.debug('*********************query************************'+query);
            hList = Database.query(query);
            storeDisplayList = new List<Store15__c>();
            storesList = new List<Store15__c>();
            Integer index = 0;
            for(StoreHistory__c h:hList){
                Store15__c s = new Store15__c();
                s.STORE_HISTORY_ID__c = h.Id;
                s.Application_Store_Name__c=h.Store_Name__c;
                s.Application_Store_Postal_Code__c=h.Zip_Code__c;
                s.Application_Store_Address__c=h.Address__c;
                s.Application_Store_Per_Date__c=h.Business_Permit_Date__c;
                //※フォマード未指定、改修の可能性がある
                s.Application_Store_Per_Number_Com__c=h.Store_Per_Number_Com__c;
                s.Application_Store_Per_Number_Issue__c=h.Store_Per_Number_Issue__c;
                s.Application_Store_Kbn__c=h.Store_Category__c;
                s.Application_Store_Address_Type__c=h.Store_Address_Type__c;
                s.StoreIndex__c=++index;
                storesList.add(s);
            }
            Integer maxNum = Integer.valueOf(System.Label.STORE_LIST_PAGE_NUM);
            maxPageNum=storesList.size()/maxNum+1;
            storeDisplayList = (List<Store15__c>)Application15Utility.getPageRecordList(storesList,pageNum);
        }catch (Exception e) {
            System.debug('*********'+e.getMessage()+'*********');
        }
    }
    
    public void previous() {
        if(pageNum==1){
            return;
        }
        pageNum=pageNum-1;
        storeDisplayList = (List<Store15__c>)Application15Utility.getPageRecordList(storesList,pageNum);
 	}

    public void next() {
        Integer maxNum = Integer.valueOf(System.Label.STORE_LIST_PAGE_NUM);
        Integer eIdx= maxNum*pageNum;
        if(storesList.size()+maxNum > maxNum*(pageNum+1)){
            pageNum=pageNum+1;
        }
        
        storeDisplayList = (List<Store15__c>)Application15Utility.getPageRecordList(storesList,pageNum);
    }
    
    public void goFirst() {
        pageNum=1;
        storeDisplayList = (List<Store15__c>)Application15Utility.getPageRecordList(storesList,pageNum);
    }
    
    public void goLast() {
        pageNum=maxPageNum;
        storeDisplayList = (List<Store15__c>)Application15Utility.getPageRecordList(storesList,pageNum);
    }
    
    public void deleteDisplayStore() {
        try {
            Integer maxNum = Integer.valueOf(System.Label.STORE_LIST_PAGE_NUM);
            
            if(storesList==null){
                return;
            }

            for(Integer index=storesList.size() -1;index >=0 ;index--){
                if(storesList[index].Correction_Flag__c){
                    storesList.remove(index);
                }
            }
            
            Integer divider = storesList.size()/maxNum;
            if(divider*maxNum == storesList.size()){
                maxPageNum=divider;
            }else{
                maxPageNum=divider+1;
            }

            if(maxPageNum < pageNum){
                pageNum = pageNum -1;
            }
            
            storeDisplayList = (List<Store15__c>)Application15Utility.getPageRecordList(storesList,pageNum);

        }catch (Exception e) {
            System.debug('****deleteDisplayStore*****');
            System.debug(e.getMessage());
            System.debug('****deleteDisplayStore*****');
        }
    }
}