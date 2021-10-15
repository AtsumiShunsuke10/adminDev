/*******************************************************************************
 *  プロジェクト名 : ○○県新型コロナウイルス感染症拡大防止協力金
 *  クラス         : 申請（感染症拡大防止協力金：第3弾）ステージコントローラ
 *  クラス名       : ApplicationStage4Controller
 *  概要           : 申請（感染症拡大防止協力金：第3弾）ステージコントローラ
 *  作成者         : トランス・コスモス
 *  作成日         : 2021/09/01
 *******************************************************************************/
global with sharing class ApplicationStage4Controller{

    // 申請番号
    public String applyNum  { get;set; }

    // 申請（感染症拡大防止協力金：第3弾）レコード
    public Application4__c apply4   { get;set; }
    // 申請（感染症拡大防止協力金：第3弾）店舗リスト
    public List<Store__c> storeList   { get;set; }
    // for test
    public Boolean testStr   { get;set; }
    public static String tempStr { get;set; }
    public Boolean normalFlag   { get;set; }
    public Boolean kojinFlag   { get;set; }
    // 簡易申請
    public String selectedApplication  { get;set; }
    public Id selectedApplicationId    { get;set; }
    // 申請番号
    public String application4Name { get;set; }
    
    public String JSONString   { get;set; }

    // 生年月日
    public String year { get;set; }
    public String month { get;set; }
    public String day { get;set; }

    // 営業許可書-許可年月日のマップ
    public Map<Integer, CustomDate> storePerDateMap  { get;set; }
    // 時短営業開始日のマップ
    public Map<Integer, CustomDate> storeTsbStartDateMap  { get;set; }
    //時短営業終了日
    public String CONST_SHORTER_BUSI_END_DATE      { get;set; }
    
    // 時短営業表示ラベル
    public String startDateLbl { get;set; }
    public String startYearLbl { get;set; }
    public String endDateLbl { get;set; }
    public Integer endDay { get;set; }
    public Integer endMonth { get;set; }
    

    
    private Id conId;
    
    //店舗申請最大軒数
    Integer maxStore=Integer.valueOf(System.Label.STORE_CNT);
    
    public ApplicationStage4Controller(){
        if(conId == null) conId = [select contactid from User where Id = :Userinfo.getUserId()].contactid;
        //未提出申請者
        if(apply4 == null) {
            apply4 = new Application4__c(Contact__c=conId,SessionRadom__c=String.valueof((Math.random() * 10)));
        }
        
        //時短営業終了日
        CONST_SHORTER_BUSI_END_DATE = Application4Utility.fmtDate(Application4Const.CONST_APP4_SHORTER_BUSI_END_DATE, Application4Const.CONST_DATE_FMT);
        
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

        if(apply4.Status__c == Application4Const.CONST_APP4_STATUS_NOT_PROPOSED){
            deleteFile();
        }

        if(storeList==null){
            storeList = new List<Store__c>();
            for(Integer i=1;i<=maxStore;i++){
                String storeDisplay;
                if(i>1){
                    storeDisplay='none';
                }
                Store__c s = new Store__c(StoreIndex__c=i,StoreDisplay__c=storeDisplay);
                storeList.add(s);
            }
        }else{
            List<Store__c> mergeList = new List<Store__c>();
            Decimal lastIdx=storeList.get(storeList.size()-1).StoreIndex__c;
            for(Integer i=1;i<=maxStore;i++){
                Store__c ms;
                boolean flg=true;
                for(Store__c s: storeList){
                    if(s.StoreIndex__c==i){
                        ms = s;
                        ms.StoreDisplay__c='';
                        flg = false;
                        break;
                    }
                }
                if(flg){
                    String storeDisplay;
                    if(i>lastIdx+1){
                        storeDisplay='none';
                    }
                    ms = new Store__c(StoreIndex__c=i,StoreDisplay__c=storeDisplay);
                }
                mergeList.add(ms);
            }
            storeList=mergeList;
        }

        // 許可年月日の年、月、日、と時短営業開始日を設定
        setAllCustomDate();
    }
    public void initComfirmPage(){
        if(apply4.Status__c == Application4Const.CONST_APP4_STATUS_NOT_PROPOSED){
            deleteFile();

            kojinFlag=false;
            normalFlag=false;
            //本人確認書類:個人通常申請のみ表示
            kojinFlag = apply4.Applicant_Division__c == Application4Const.CONST_APP4_APP_DIV_SOLE;
            
            if(apply4.id != null){
                apply4 = Database.query(getSelectSoqlString('Application4__c', 'id=\''+apply4.id+'\'', '',true));
                application4Name = apply4.Name;
                
                List<String> fieldsList = Application4Utility.getAllColumnsList('Store__c');
                String query = Application4Utility.makeSoql(fieldsList, 'Store__c', 'Application4__c = \''+ apply4.Id +'\'', '', '', '');
                storeList = Database.query(query);
                // 店舗の時間短縮営業等実施期間の表示メッセージを設定
                for (Integer i = 0; i < storeList.size(); i++) {
                    Store__c s = storeList.get(i);
                    // 時短営業日数        
                    if (s.Application_Store_Days__c != null) {
                        storeTsbStartDateMap.get(i+1).tsbDisplayMsg = String.format(Application4Const.CONST_APP4_SHORTER_BUSI_PERIOD_MSG, 
                                                                                    new List<String>{String.valueOf(s.Application_Store_Start_Date__c),
                                                                                        String.valueOf(s.Application_Store_End_Date__c),
                                                                                        String.valueOf(s.Application_Store_Days__c)});
                    }
                }
            }
        }

    }


    webService static String putInfo(String applicationName) {

        Map<String, Object> infoMap = new Map<String, String>();
        Sobject sobj = null;
        // 第1弾申請の場合
        if (Id.valueOf(applicationName).getSObjectType().getDescribe().getName() == 'Application__c') {
            sobj = Application4Utility.getApplicationInfo(applicationName);
        // 第2弾申請の場合
        } else if(Id.valueOf(applicationName).getSObjectType().getDescribe().getName() == 'Application2__c') {
            sobj = Application4Utility.getApplication2Info(applicationName);
        }

        if (sobj != null) {
            infoMap.put('applicantDivision',sobj.get('Applicant_Division__c'));
            infoMap.put('applicantZip',sobj.get('Applicant_Postal_Code__c'));
            infoMap.put('applicantAddress',sobj.get('Applicant_Address__c'));
            infoMap.put('applicantBusinessName',sobj.get('Applicant_Business_Name__c'));
            infoMap.put('applicantTitle',sobj.get('Applicant_Title__c'));
            infoMap.put('applicantName',sobj.get('Applicant_Name__c'));
            infoMap.put('applicantPhone',sobj.get('Applicant_Phone__c'));
            infoMap.put('corporateNum',sobj.get('Corporate_Number__c'));
            infoMap.put('financialInstitution',sobj.get('Financial_Institution_Lookup__c'));
            infoMap.put('financialInstitutionName',sobj.getSobject('Financial_Institution_Lookup__r').get('Name'));
            infoMap.put('branchName',sobj.get('Finacial_Branch_Name__c'));
            infoMap.put('branchCode',sobj.get('Finacial_Branch_Code__c'));
            infoMap.put('accountType',sobj.get('Finacial_Account_Type__c'));
            infoMap.put('accountNumber',sobj.get('Finacial_Account_Number__c'));
            infoMap.put('accountHolder',sobj.get('Account_Holder__c'));
                
        }
        return JSON.serialize( infoMap );
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

    public List<SelectOption> getSelectApplication() {
        
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--なし--'));
        options.add(new SelectOption(Application4Const.CONST_APP_SELECT_LIST_VALUE1, Application4Const.CONST_APP_SELECT_LIST_LABEL1));
        options.add(new SelectOption(Application4Const.CONST_APP_SELECT_LIST_VALUE2, Application4Const.CONST_APP_SELECT_LIST_LABEL2));
        return options;
        
    }
    
    public List<SelectOption> getSelectApplicationNum() {
        
        List<SelectOption> options = new List<SelectOption>();
        List<SObject> sobjList = new List<SObject>();
        // 第1弾申請の場合
        if (selectedApplication == Application4Const.CONST_APP_SELECT_LIST_VALUE1) {
            sobjList = [Select id,Name From Application__c Where Contact__c = :conId And Status__c = :Application4Const.CONST_APP1_STATUS_PAYMENT_DECISION limit 999];
        // 第2弾申請の場合
        } else if(selectedApplication == Application4Const.CONST_APP_SELECT_LIST_VALUE2) {
            sobjList = [Select id,Name From Application2__c Where Contact__c = :conId And Status__c = :Application4Const.CONST_APP2_STATUS_PAYMENT_DECISION limit 999];
        }
        options.add(new SelectOption('','--なし--'));
        for (Integer i = 0; i < sobjList.size(); i++) {
            options.add(new SelectOption((Id)sobjList[i].get('id'), (String)sobjList[i].get('Name')));
        }

        return options;
    }
    
    public PageReference toConfirm(){
        PageReference pr =  new PageReference(page.Application4Confirm.getUrl());
        pr.setRedirect(false);
        return pr;
    }

    public void toConfirmPage(){
        
        // 代表者又は申請者の生年月日
        apply4.Applicant_Birthday__c = Date.valueOf(year+'-'+month+'-'+day);
        // ステータス
        apply4.Status__c = Application4Const.CONST_APP4_STATUS_NOT_PROPOSED;

        // 第1弾申請の場合
        /*if (selectedApplication == Application4Const.CONST_APP_SELECT_LIST_VALUE1) {
            apply4.Application__c = selectedApplicationId;
            apply4.Application2__c = null;
        // 第2弾申請の場合
        } else if(selectedApplication == Application4Const.CONST_APP_SELECT_LIST_VALUE2) {
            apply4.Application__c = null;
            apply4.Application2__c = selectedApplicationId;
        } else {
            apply4.Application__c = null;
            apply4.Application2__c = null;
        }*/

        Savepoint sp = Database.setSavepoint();
      
        Database.UpsertResult sr = Database.upsert(apply4, false);
        if (!sr.isSuccess()) {
            for (Database.Error err : sr.getErrors()) {
                JSONString = JSONString + '</br>' + err.getMessage(); 
            }
            Database.rollback(sp);
            return;
        }
        
        // 店舗の時短営業開始日、時短営業終了日を設定
        List<store__c> insertStoreList= new List<store__c>();
        Integer storeCnt=0;
        for (Integer i = 1; i <= maxStore; i++) {
            store__c s= storeList.get(i-1);
            System.debug('Application_Store_Apply_Amount__c::::::'+s.Application_Store_Apply_Amount__c);
            //申請ID
            s.Application4__c=sr.getId();
            // 許可証年月日
            s.Application_Store_Per_Date__c=storePerDateMap.get(i).customDate;

            if (s.Application_Store_Name__c!= null) {
                s.Application_Store_Start_Date__c= 
                            Date.newInstance(Application4Const.CONST_APP4_SHORTER_BUSI_START_DATE.year(),
                                            Integer.valueOf(storeTsbStartDateMap.get(i).customMonth),
                                             Integer.valueOf(storeTsbStartDateMap.get(i).customDay));
                s.Application_Store_End_Date__c=Application4Const.CONST_APP4_SHORTER_BUSI_END_DATE;
                storeCnt = storeCnt + 1;
                s.StoreIndex__c=storeCnt;
                insertStoreList.add(s);

            } 
            /*else {
                s.Application_Store_Start_Date__c=null;
                s.Application_Store_End_Date__c=null;
            }*/
        }
        
        List<Database.upsertResult> uResults = Database.upsert(insertStoreList, false);
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

    /**
     * 許可年月日の年、月、日、と時短営業開始日を設定
     */
    private void setAllCustomDate() {
        storePerDateMap = new Map<Integer, CustomDate>();
        storeTsbStartDateMap = new Map<Integer, CustomDate>();
        Map<Integer, Date> changeYearMap = Application4Utility.createWarekiChangeYear();
        for (Integer i = 1; i <= maxStore; i++) {
			store__c s;
            //add
            if(maxStore == storeList.size()){
                s= storeList.get(i-1);
            }else{
                break;
            }
            //add
            //Date perDate = (Date)apply4.get('Application_Store_' + i + '_Per_Date__c');
            Date perDate = (Date)s.Application_Store_Per_Date__c;
            CustomDate cusDate = new CustomDate();
            // 許可年月日の年、月、日を設定
            if (perDate != null) {
                cusDate.customYear = String.valueOf(perDate.year());
                // 年号変更識別子を追加
                if (changeYearMap.containsKey(perDate.year())) {
                    cusDate.customYear += perDate > changeYearMap.get(perDate.year()) ? '' : '#';
                }
                cusDate.customMonth = String.valueOf(perDate.month());
                cusDate.customDay = String.valueOf(perDate.day());
            }
            storePerDateMap.put(i, cusDate);

            //Date stDate = (Date)apply4.get('Application_Store_' + i + '_Start_Date__c');
            Date stDate = (Date)s.Application_Store_Start_Date__c;
            cusDate = new CustomDate();
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
        
        //和暦設定
        startDateLbl=Application4Utility.changeWarekiYear(System.Label.STORE_START_DATE,0);
        startYearLbl=Application4Utility.changeWarekiYear(System.Label.STORE_START_DATE,2);
        endDateLbl=Application4Utility.changeWarekiYear(System.Label.STORE_END_DATE,0);
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
        Application4__c app4 = [Select id From Application4__c Where SessionRadom__c=:tempStr];
        rId = app4.Id;

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
    
    public PageReference toCompletePage() {

        // ApplicatuionValueSet(selectedApplicationId);
        apply4.Individual_Duplication_Check_Flag__c=true;
        apply4.Corporation_Duplication_Check_Flag__c=true;
        apply4.Status__c = Application4Const.CONST_APP4_STATUS_EXAMINATION;
        apply4.SubStatus__c = Application4Const.CONST_APP4_SUB_STATUS_NEW;
        //未提出申請者
        apply4.SessionRadom__c='';
        RecordType retype=[Select id from  RecordType where DeveloperName='RecordType_readonly' and SobjectType='Application4__c'];
        apply4.RecordTypeId=retype.id;
        upsert apply4;
        
        PageReference pr = new PageReference (page.Application4Complete.getUrl());
        pr.setRedirect(false);
        return pr;
        
    }
    public PageReference toInputPage() {
        //前画面に戻る都選択された添付ファイルはクリアされます
        deleteFile();
        PageReference pr = new PageReference(page.Application4Input.getUrl());
        pr.getParameters().put('backflag','true');
        pr.setRedirect(false);
        return pr;
    }
    // 添付ファイルはクリアされます
    public void deleteFile(){
        List<String> fieldsList = new List<String>();
        fieldsList.add('Id');
        String query = Application4Utility.makeSoql(fieldsList, 'Store__c', 'Application4__c = \''+ apply4.Id +'\'', '', '', '');
        List<String> idList = new List<String>();
        for(Store__c s:Database.query(query)){
            idList.add(s.Id);
        }
        idList.add(apply4.id);
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
    // 申請番号にっよて、値の設定
    private void ApplicatuionValueSet(Id appid){
        if(appid != null) {
            
            Sobject sobj = null;
            // 第1弾申請の場合
            if (selectedApplication == Application4Const.CONST_APP_SELECT_LIST_VALUE1) {
                sobj = Application4Utility.getApplicationInfo(appId);
            // 第2弾申請の場合
            } else if(selectedApplication == Application4Const.CONST_APP_SELECT_LIST_VALUE2) {
                sobj = Application4Utility.getApplication2Info(appId);
            }

            if (sobj != null) {
                apply4.Applicant_Division__c= (String)sobj.get('Applicant_Division__c');
                apply4.Applicant_Postal_Code__c= (String)sobj.get('Applicant_Postal_Code__c');
                apply4.Applicant_Address__c= (String)sobj.get('Applicant_Address__c');                    
                apply4.Applicant_Business_Name__c= (String)sobj.get('Applicant_Business_Name__c');
                apply4.Applicant_Title__c= (String)sobj.get('Applicant_Title__c');
                apply4.Applicant_Name__c= (String)sobj.get('Applicant_Name__c');
                apply4.Applicant_Phone__c= (String)sobj.get('Applicant_Phone__c');
                apply4.Corporate_Number__c= (String)sobj.get('Corporate_Number__c');
                apply4.Financial_Institution_Lookup__c= (Id)sobj.get('Financial_Institution_Lookup__c');
                apply4.Finacial_Branch_Name__c= (String)sobj.get('Finacial_Branch_Name__c');
                apply4.Finacial_Branch_Code__c= (String)sobj.get('Finacial_Branch_Code__c');
                apply4.Finacial_Account_Type__c= (String)sobj.get('Finacial_Account_Type__c');
                apply4.Finacial_Account_Number__c= (String)sobj.get('Finacial_Account_Number__c');
                apply4.Account_Holder__c= (String)sobj.get('Account_Holder__c');
            }

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