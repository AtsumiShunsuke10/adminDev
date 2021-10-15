/*******************************************************************************
 *  プロジェクト名 : 新型コロナウイルス感染症拡大防止協力金
 *  クラス         : 店舗（感染症拡大防止協力金：第15弾）ステージコントローラ
 *  クラス名       : Stores15Controller
 *  概要           : 店舗（感染症拡大防止協力金：第15弾）ステージコントローラ
 *  作成者         : トランス・コスモス
 *  作成日         : 2021/10/08
 *******************************************************************************/
global with sharing class Stores15Controller{
    // 申請（感染症拡大防止協力金：第15弾）レコード
    public Application15__c apply15   { get;set; }
    
    // 申請番号
    public String applyNum  { get;set; }
    
    public String JSONString   { get;set; }

    // 申請（感染症拡大防止協力金：第15弾）店舗リスト
    public Store15__c store   { get;set; }
    
    // 営業許可書-許可年月日
    public CustomDate storePerDate  { get;set; }
    // 時短営業開始日のマップ
    public CustomDate storeTsbStartDate  { get;set; }
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
    
    public Stores15Controller(){
        if(conId == null) conId = [select contactid from User where Id = :Userinfo.getUserId()].contactid;
        //未提出申請者
        if(apply15 == null) {
            apply15 = new Application15__c(Contact__c=conId,SessionRadom__c=String.valueof((Math.random() * 10)));
        }
        
        //時短営業終了日
        CONST_SHORTER_BUSI_END_DATE = Application15Utility.fmtDate(Application15Const.CONST_APP15_SHORTER_BUSI_END_DATE, Application15Const.CONST_DATE_FMT);
        
    }
    
    public void initInputPage(){

        if(apply15.Status__c == Application15Const.CONST_APP15_STATUS_NOT_PROPOSED){
            deleteFile();
        }

        store = new Store15__c();

        // 許可年月日の年、月、日、と時短営業開始日を設定
        setAllCustomDate();
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
    
    public PageReference toConfirm(){
        PageReference pr =  new PageReference(page.Application15Confirm.getUrl());
        pr.setRedirect(false);
        return pr;
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

        //Date stDate = (Date)apply15.get('Application_Store_' + i + '_Start_Date__c');
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
        apply15.Individual_Duplication_Check_Flag__c=true;
        apply15.Corporation_Duplication_Check_Flag__c=true;
        apply15.Status__c = Application15Const.CONST_APP15_STATUS_EXAMINATION;
        apply15.SubStatus__c = Application15Const.CONST_APP15_SUB_STATUS_NEW;
        //未提出申請者
        apply15.SessionRadom__c='';
        RecordType retype=[Select id from  RecordType where DeveloperName='RecordType_readonly' and SobjectType='Application15__c'];
        apply15.RecordTypeId=retype.id;
        upsert apply15;
        
        PageReference pr = new PageReference (page.Application15Complete.getUrl());
        pr.setRedirect(false);
        return pr;
        
    }
    public PageReference toInputPage() {
        //前画面に戻る都選択された添付ファイルはクリアされます
        deleteFile();
        PageReference pr = new PageReference(page.Application15Input.getUrl());
        pr.getParameters().put('backflag','true');
        pr.setRedirect(false);
        return pr;
    }
    
    // 添付ファイルはクリアされます
    public void deleteFile(){
        List<String> fieldsList = new List<String>();
        fieldsList.add('Id');
        String query = Application15Utility.makeSoql(fieldsList, 'Store__c', 'Application15__c = \''+ apply15.Id +'\'', '', '', '');
        List<String> idList = new List<String>();
        for(Store__c s:Database.query(query)){
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

    /**
     * 郵便番号で住所を取得
     *
     * @param String postcode 郵便番号
     * @return String 住所
     */
    @RemoteAction
    public static String getAddress(String postcode) {
        
        // 申請（感染症拡大防止協力金：第3弾）共通処理.郵便番号で住所マスタから住所を取得
        String address = Application15Utility.getAddressByPostCode(postcode);
        
        return address;
        
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


}