/*******************************************************************************
 *  プロジェクト名 : ○○県新型コロナウイルス感染症拡大防止協力金
 *  クラス         : 申請（感染症拡大防止協力金：第3弾）トリガテストクラス
 *  クラス名       : Application4TriggerTest
 *  概要           : 申請（感染症拡大防止協力金：第3弾）トリガテストクラス
 *  作成者         : トランス・コスモス
 *  作成日         : 2021/09/30
 *******************************************************************************/
@isTest
public class StoreTriggerTest {
    
    /**
     * テストデータ用構造体
     */
    private class structTestData {

        public Application4__c app4;
        public Account account;
        public Contact con;
        public C_FinancialInstitutiokanji__c financial;
        structTestData(Application4__c app4,Account account,Contact con,C_FinancialInstitutiokanji__c financial) {
            this.app4 = app4;
            this.account = account;
            this.con = con;
            this.financial = financial;
        }

    }
    
    /**
     * テストデータ作成
     */
    private static structTestData createBaseData(Boolean eFlg){
        
        //レコードタイプ
        RecordType recObj3 = [SELECT Id FROM RecordType WHERE DeveloperName='RecordType_readonly' and SobjectType='Application4__c' LIMIT 1];
    
        //会社
        Account account = new Account(
            Name = 'テストクラス用会社'
        );
        insert account;
        
       //会社担当者
        Contact con = new Contact(
            LastName = '001',
            FirstName = 'Testing',
            AccountId = account.Id
        );
        insert con;
        
        //申請者作成
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@transcosmos.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='申請者プロファイル'];
        User u = new User(Alias = 'standt', Email='standarduser@transcosmos.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='ja',
                          LocaleSidKey='ja_JP', ProfileId = p.Id, ContactID = con.Id,
                          TimeZoneSidKey='GMT',
                          UserName=uniqueUserName);
        
        //金融機関
        C_FinancialInstitutiokanji__c financial = new C_FinancialInstitutiokanji__c(Name = 'トランス信用金庫',FinancialInstitutionCD__c='0039');
        insert financial;
        
        // 住所マスタ
        AddressMaster__c addMst = new AddressMaster__c(
            PostalCode__c = '1111111',
            Prefectures__c = '東京都',
            City__c = '千代田区',
            CommonName__c = '大手町',
            District__c = '１丁目',
            AbolitionDate__c = '0000'
        );
        insert addMst;
        
        //申請（感染症拡大防止協力金：第3弾）
        Application4__c app4 = new Application4__c(
            RecordTypeId = recObj3.Id,
            Applicant_Division__c = '個人事業主',
            Applicant_Postal_Code__c = '1111111',
            Applicant_Address__c = '東京都渋谷区渋谷',
            Applicant_Business_Name__c = 'トランスコスモス株式会社',
            Applicant_Store_Count__c = '3',
            Applicant_Title__c = '代表取締役',
            Applicant_Name__c = 'ちょう',
            Applicant_Phone__c = '08033334444',
            Applicant_Phone_For_Duplication_Check__c = '08033334444',
            Application_Date__c = Date.today(),
            Contact__c = con.Id,
            Finacial_Account_Number_For_Duplication__c = '1111111',
            Finacial_Account_Number__c = '2222222',
            Finacial_Account_Type__c = '普通',
            Finacial_Branch_Code__c = '000',
            Finacial_Branch_Name__c = '渋谷',
            Financial_Institution_Lookup__c = financial.Id,
            Account_Holder_Input__c = 'ﾄﾗﾝｽｺｽﾓｽ',
            Pledge1__c = true,
            Status__c = '未提出',
            Individual_Duplication_Check_Flag__c = true,
            Corporation_Duplication_Check_Flag__c = true,
            // Application2__c = app2.Id,
            SessionRadom__c = '5.877574320889737'
        );
        if(eFlg){
            System.runAs(u){
                insert app4;
            }     
        }else{
            insert app4;
        }
   
        // return new structTestData(app2, app4, account, con, financial);
        return new structTestData(app4, account, con, financial);
    }
    
    private static Integer calculateAmount(List<Store__c> storeList,Map<Id,Date> startDateMap){
        Integer totalAmount = 0;

        for (Store__c s : storeList){
            List<String> dayZone = System.Label.CONST_DAILY_ZONE_REQ.split(',');
            List<String> amountZone = System.Label.CONST_DAILY_AMOUNT_REQ.split(',');
            Integer unitPricePerDay = Integer.valueOf(System.Label.APPLICATION4_PAYMENT_UNIT_PRICE);
            Date tsbEndDay = s.Application_Store_End_Date__c;
            Date startDate = startDateMap.get(s.Id);
            Integer storeAmount = 0;
            if(dayZone.size()+1 !=amountZone.size()){
                Date endDate = tsbEndDay;
                Integer diff = startDate.daysBetween(endDate) + 1;
                storeAmount = unitPricePerDay * diff;
            }else{
                for (Integer i = 0; i < amountZone.size(); i++) {
                    Date subEndDate = tsbEndDay;
                    if(i!=amountZone.size()-1){
                        subEndDate = Date.valueOf(dayZone[i]);
                    }
                    Integer subDiff = startDate.daysBetween(subEndDate) + 1;
                    if(subDiff>=0){
                        storeAmount += Integer.valueOf(amountZone[i]) * subDiff;
                        startDate=subEndDate.addDays(1);
                    }
                }
            }
            
            totalAmount += storeAmount;
        }
        
        return totalAmount;
    }
    
    /**
     * テストケース１
     */
    public static testmethod void Test_Case1() {
        
        Test.startTest();
        
        structTestData baseData = createBaseData(false);
        
        //営業時間短縮を行った店舗
        List<Store__c> storeList = new List<Store__c>();
        Store__c s1 = new Store__c(
            Application4__c  = baseData.app4.Id,
            StoreIndex__c = 1,
            Application_Store_Kbn__c = '飲食店',
            Application_Store_Per_Number_Com__c = '001',
            Application_Store_Per_Number_Issue__c = '456789',
            Application_Store_Per_Date__c = Date.today().addYears(-1),
            Application_Store_Address_Type__c = '板橋区',
            Application_Store_Postal_Code__c = '2318588',
            Application_Store_Address__c = '板橋区日本大通１',
            Application_Store_Name__c = '天下一飯店',
            Application_Store_Effort_DetailsA__c = true,
            Application_Store_Start_Date__c =  Application4Const.CONST_APP4_SHORTER_BUSI_START_DATE.addDays(7),
            Application_Store_End_Date__c =  Application4Const.CONST_APP4_SHORTER_BUSI_END_DATE
        );
        storeList.add(s1);
        
        Store__c s2 = new Store__c(
            Application4__c  = baseData.app4.Id,
            StoreIndex__c = 2,
            Application_Store_Kbn__c = '飲食店',
            Application_Store_Per_Number_Com__c = '002',
            Application_Store_Per_Number_Issue__c = '456789',
            Application_Store_Per_Date__c = Date.today().addYears(-2),
            Application_Store_Address_Type__c = '板橋区',
            Application_Store_Postal_Code__c = '2318688',
            Application_Store_Address__c = '板橋区日本大通２',
            Application_Store_Name__c = '天下二飯店',
            Application_Store_Effort_DetailsA__c = true,
            Application_Store_Start_Date__c =  Application4Const.CONST_APP4_SHORTER_BUSI_END_DATE.addDays(-7),
            Application_Store_End_Date__c =  Application4Const.CONST_APP4_SHORTER_BUSI_END_DATE
        );
        storeList.add(s2);
        insert storeList;
        
        Map<Id,Date> startDateMap = new Map<Id,Date>();
        startDateMap.put(s1.id, s1.Application_Store_Start_Date__c);
        startDateMap.put(s2.id, s2.Application_Store_Start_Date__c);
        
        Application4__c app4 =[select id,Application_Amount__c from Application4__c where id = :baseData.app4.Id];
        System.assertEquals(calculateAmount(storeList,startDateMap), app4.Application_Amount__c);
        //System.assertEquals(calculateAmount(storeList,startDateMap), app4.Store_Total_Advance_Sub_Payment__c);
        Test.stopTest();
    
    }
    
    /**
     * テストケース２
     */
    public static testmethod void Test_Case2() {
        
        Test.startTest();
        
        structTestData baseData = createBaseData(false);
        
        //営業時間短縮を行った店舗
        List<Store__c> storeList = new List<Store__c>();
        Store__c s1 = new Store__c(
            Application4__c  = baseData.app4.Id,
            StoreIndex__c = 1,
            Application_Store_Kbn__c = '飲食店',
            Application_Store_Per_Number_Com__c = '001',
            Application_Store_Per_Number_Issue__c = '456789',
            Application_Store_Per_Date__c = Date.today().addYears(-1),
            Application_Store_Address_Type__c = '板橋区',
            Application_Store_Postal_Code__c = '2318588',
            Application_Store_Address__c = '板橋区日本大通１',
            Application_Store_Name__c = '天下一飯店',
            Application_Store_Effort_DetailsA__c = true,
            Application_Store_Start_Date__c =  Application4Const.CONST_APP4_SHORTER_BUSI_START_DATE.addDays(3),
            Application_Store_End_Date__c =  Application4Const.CONST_APP4_SHORTER_BUSI_END_DATE
        );
        storeList.add(s1);
        
        Store__c s2 = new Store__c(
            Application4__c  = baseData.app4.Id,
            StoreIndex__c = 2,
            Application_Store_Kbn__c = '飲食店',
            Application_Store_Per_Number_Com__c = '002',
            Application_Store_Per_Number_Issue__c = '456789',
            Application_Store_Per_Date__c = Date.today().addYears(-2),
            Application_Store_Address_Type__c = '板橋区',
            Application_Store_Postal_Code__c = '2318688',
            Application_Store_Address__c = '板橋区日本大通２',
            Application_Store_Name__c = '天下二飯店',
            Application_Store_Effort_DetailsA__c = true,
            Application_Store_Start_Date__c =  Application4Const.CONST_APP4_SHORTER_BUSI_END_DATE.addDays(-7),
            Application_Store_End_Date__c =  Application4Const.CONST_APP4_SHORTER_BUSI_END_DATE
        );
        storeList.add(s2);
        insert storeList;
        
        s2 = new Store__c(
            Id = s2.id,
            Application_Store_Start_Date__c =  Application4Const.CONST_APP4_SHORTER_BUSI_START_DATE.addDays(7)
        );
        update s2;
        
        Map<Id,Date> startDateMap = new Map<Id,Date>();
        startDateMap.put(s1.id, s1.Application_Store_Start_Date__c);
        startDateMap.put(s2.id, s2.Application_Store_Start_Date__c);
        
        Application4__c app4 =[select id,Application_Amount__c from Application4__c where id = :baseData.app4.Id];
        System.assertEquals(calculateAmount(storeList,startDateMap), app4.Application_Amount__c);

        Test.stopTest();
    
    }
    
    /**
     * テストケース３
     */
    public static testmethod void Test_Case3() {
        
        Test.startTest();

        structTestData baseData = createBaseData(false);
        
        // 審査待ちにする
        Application4__c apply = new Application4__c();
        apply.Id = baseData.app4.Id;
        apply.Individual_Duplication_Check_Flag__c=true;
        apply.Corporation_Duplication_Check_Flag__c=true;
        apply.Status__c = Application4Const.CONST_APP4_STATUS_EXAMINATION;
        apply.SubStatus__c = Application4Const.CONST_APP4_SUB_STATUS_NEW;
        apply.SessionRadom__c='';
        RecordType retype=[Select id from  RecordType where DeveloperName='RecordType_readonly' and SobjectType='Application4__c'];
        apply.RecordTypeId=retype.id;
        upsert apply;
        
        //先行支払い対象店舗
        PrePayStore__c pps = new PrePayStore__c(
            Applicant_Business_Name__c = 'test',
            Applicant_Division__c = '個人事業主',
            Store_Name__c  = '天下一飯店',
            //
            Permission_Number__c  = '888第888888号',
            Permission_Date__c  = '令和3年1月1日',
            PrePay_Store_Number__c  = 1,
            PrePay_Store_TotalAmount__c  = 700000,
            PrePay_Subject__c  = true,
            PrePay_Subject_Date__c  = Date.newInstance(2021, 8, 20),
            Application_Number__c  = '08080000008',
            Organize_Number__c  = '108080000008',
            Application_Type__c  = '電子',
            Application_Data__c  = '2期',
            Application_Id__c  = baseData.app4.Id,
            Applicant_Id__c  = 'test@test.test',
            FinancialInstitution_Name__c  = 'みずほ銀行',
            Finacial_Branch_Name__c = '渋谷',
            Finacial_Account_Number__c  = '2222222',
            Account_Holder__c = 'ﾄﾗﾝｽｺｽﾓｽ',
            FinancialInstitutionCD__c = '0039',
            Finacial_Branch_Code__c  = '000',
            Finacial_Account_Type__c  = '普通'
        );
        insert pps;
        
        //営業時間短縮を行った店舗
        List<Store__c> storeList = new List<Store__c>();
        Store__c s = new Store__c(
            Application4__c  = baseData.app4.Id,
            StoreIndex__c = 1,
            Application_Store_Kbn__c = '飲食店',
            Application_Store_Per_Number_Com__c = '123',
            Application_Store_Per_Number_Issue__c = '456789',
            Application_Store_Per_Date__c = Date.newInstance(2021, 1, 1),
            Application_Store_Address_Type__c = '板橋区',
            Application_Store_Postal_Code__c = '2318588',
            Application_Store_Address__c = '板橋区日本大通１',
            Application_Store_Name__c = '天下一飯店',
            Application_Store_Effort_DetailsA__c = true,
            Application_Store_Start_Date__c =  Application4Const.CONST_APP4_SHORTER_BUSI_START_DATE.addDays(7),
            Application_Store_End_Date__c =  Application4Const.CONST_APP4_SHORTER_BUSI_END_DATE,
            Store_Application_Early_Benefit__c = true
        );
        storeList.add(s);
        insert storeList;
        
        Map<Id,Date> startDateMap = new Map<Id,Date>();
        startDateMap.put(s.id, s.Application_Store_Start_Date__c);
        
        //結果検証
        Store__c sr =[select id,Store_Total_Advance_Sub_Payment__c,PrePayStore__c,PerPay_Store_Basic_Check__c,PerPay_Store_Double_Check__c from Store__c where id = :s.Id];
        System.assertEquals(null, sr.PrePayStore__c);
        System.assertEquals(false, sr.PerPay_Store_Basic_Check__c);
        System.assertEquals(false, sr.PerPay_Store_Double_Check__c);
        System.assertEquals(null, sr.Store_Total_Advance_Sub_Payment__c);
        
        Test.stopTest();
    
    }

    /**
     * テストケース４
     */
    public static testmethod void Test_Case4() {
        
        Test.startTest();

        structTestData baseData = createBaseData(false);
        
        // 審査待ちにする
        Application4__c apply = new Application4__c();
        apply.Id = baseData.app4.Id;
        apply.Individual_Duplication_Check_Flag__c=true;
        apply.Corporation_Duplication_Check_Flag__c=true;
        apply.Status__c = Application4Const.CONST_APP4_STATUS_EXAMINATION;
        apply.SubStatus__c = Application4Const.CONST_APP4_SUB_STATUS_NEW;
        apply.SessionRadom__c='';
        RecordType retype=[Select id from  RecordType where DeveloperName='RecordType_readonly' and SobjectType='Application4__c'];
        apply.RecordTypeId=retype.id;
        upsert apply;
        
        //先行支払い対象店舗
        PrePayStore__c pps = new PrePayStore__c(
            Applicant_Business_Name__c = 'test',
            Applicant_Division__c = '個人事業主',
            Store_Name__c  = '天下一飯店',
            Permission_Number__c  = '123第456789号',
            Permission_Date__c  = '令和3年1月1日',
            PrePay_Store_Number__c  = 1,
            PrePay_Store_TotalAmount__c  = 700000,
            PrePay_Subject__c  = true,
            PrePay_Subject_Date__c  = Date.newInstance(2021, 8, 20),
            Application_Number__c  = '08080000008',
            Organize_Number__c  = '108080000008',
            Application_Type__c  = '電子',
            Application_Data__c  = '2期',
            Application_Id__c  = baseData.app4.Id,
            Applicant_Id__c  = 'test@test.test',
            //銀行違う
            FinancialInstitution_Name__c  = 'みずほ銀行',
            Finacial_Branch_Name__c = '渋谷',
            Finacial_Account_Number__c  = '2222222',
            Account_Holder__c = 'ﾄﾗﾝｽｺｽﾓｽ',
            FinancialInstitutionCD__c = '0039',
            Finacial_Branch_Code__c  = '000',
            Finacial_Account_Type__c  = '普通'
        );
        insert pps;
        
        //営業時間短縮を行った店舗
        List<Store__c> storeList = new List<Store__c>();
        Store__c s = new Store__c(
            Application4__c  = baseData.app4.Id,
            StoreIndex__c = 1,
            Application_Store_Kbn__c = '飲食店',
            Application_Store_Per_Number_Com__c = '123',
            Application_Store_Per_Number_Issue__c = '456789',
            Application_Store_Per_Date__c = Date.newInstance(2021, 1, 1),
            Application_Store_Address_Type__c = '板橋区',
            Application_Store_Postal_Code__c = '2318588',
            Application_Store_Address__c = '板橋区日本大通１',
            Application_Store_Name__c = '天下一飯店',
            Application_Store_Effort_DetailsA__c = true,
            Application_Store_Start_Date__c =  Application4Const.CONST_APP4_SHORTER_BUSI_START_DATE.addDays(7),
            Application_Store_End_Date__c =  Application4Const.CONST_APP4_SHORTER_BUSI_END_DATE,
            Store_Application_Early_Benefit__c = true
        );
        storeList.add(s);
        insert storeList;
        
        Map<Id,Date> startDateMap = new Map<Id,Date>();
        startDateMap.put(s.id, s.Application_Store_Start_Date__c);
        //結果検証
        Store__c sr =[select id,Store_Total_Advance_Sub_Payment__c,PrePayStore__c,PerPay_Store_Basic_Check__c,PerPay_Store_Double_Check__c from Store__c where id = :s.Id];
        System.assertEquals(pps.Id, sr.PrePayStore__c);
        System.assertEquals(true, sr.PerPay_Store_Basic_Check__c);
        System.assertEquals(false, sr.PerPay_Store_Double_Check__c);
        System.assertEquals(calculateAmount(storeList,startDateMap)- Integer.valueOf(System.Label.ADVANCE_SUB_PAYMENT), sr.Store_Total_Advance_Sub_Payment__c);
        Test.stopTest();
    
    }
    
    /**
     * テストケース５
     */
    public static testmethod void Test_Case5() {
        
        Test.startTest();

        structTestData baseData = createBaseData(true);
        
        // 審査待ちにする
        Application4__c apply = new Application4__c();
        apply.Id = baseData.app4.Id;
        apply.Individual_Duplication_Check_Flag__c=true;
        apply.Corporation_Duplication_Check_Flag__c=true;
        apply.Status__c = Application4Const.CONST_APP4_STATUS_EXAMINATION;
        apply.SubStatus__c = Application4Const.CONST_APP4_SUB_STATUS_NEW;
        apply.SessionRadom__c='';
        RecordType retype=[Select id from  RecordType where DeveloperName='RecordType_readonly' and SobjectType='Application4__c'];
        apply.RecordTypeId=retype.id;
        upsert apply;
        
        //先行支払い対象店舗
        PrePayStore__c pps = new PrePayStore__c(
            Applicant_Business_Name__c = 'test',
            Applicant_Division__c = '個人事業主',
            Store_Name__c  = '天下一飯店',
            Permission_Number__c  = '123第456789号',
            Permission_Date__c  = '令和3年1月1日',
            PrePay_Store_Number__c  = 1,
            PrePay_Store_TotalAmount__c  = 700000,
            PrePay_Subject__c  = true,
            PrePay_Subject_Date__c  = Date.newInstance(2021, 8, 20),
            Application_Number__c  = '08080000008',
            Organize_Number__c  = '108080000008',
            Application_Type__c  = '電子',
            Application_Data__c  = '2期',
            //Application_Id__c  = baseData.app4.Id,
            Applicant_Id__c  = 'test@test.test',
            FinancialInstitution_Name__c  = 'トランス信用金庫',
            Finacial_Branch_Name__c = '渋谷',
            Finacial_Account_Number__c  = '2222222',
            Account_Holder__c = 'ﾄﾗﾝｽｺｽﾓｽ',
            FinancialInstitutionCD__c = '0039',
            Finacial_Branch_Code__c  = '000',
            Finacial_Account_Type__c  = '普通'
        );
        insert pps;
        
        //営業時間短縮を行った店舗
        List<Store__c> storeList = new List<Store__c>();
        Store__c s = new Store__c(
            Application4__c  = baseData.app4.Id,
            StoreIndex__c = 1,
            Application_Store_Kbn__c = '飲食店',
            Application_Store_Per_Number_Com__c = '123',
            Application_Store_Per_Number_Issue__c = '456789',
            Application_Store_Per_Date__c = Date.newInstance(2021, 1, 1),
            Application_Store_Address_Type__c = '板橋区',
            Application_Store_Postal_Code__c = '2318588',
            Application_Store_Address__c = '板橋区日本大通１',
            Application_Store_Name__c = '天下一飯店',
            Application_Store_Effort_DetailsA__c = true,
            Application_Store_Start_Date__c =  Application4Const.CONST_APP4_SHORTER_BUSI_START_DATE.addDays(7),
            Application_Store_End_Date__c =  Application4Const.CONST_APP4_SHORTER_BUSI_END_DATE,
            Store_Application_Early_Benefit__c = true
        );
        storeList.add(s);
        insert storeList;
        
        Map<Id,Date> startDateMap = new Map<Id,Date>();
        startDateMap.put(s.id, s.Application_Store_Start_Date__c);
        
        //結果検証
        Store__c sr =[select id,Store_Total_Advance_Sub_Payment__c,PrePayStore__c,PerPay_Store_Basic_Check__c,PerPay_Store_Double_Check__c from Store__c where id = :s.Id];
        System.assertEquals(pps.Id, sr.PrePayStore__c);
        System.assertEquals(true, sr.PerPay_Store_Basic_Check__c);
        System.assertEquals(false, sr.PerPay_Store_Double_Check__c);
        System.assertEquals(calculateAmount(storeList,startDateMap)- Integer.valueOf(System.Label.ADVANCE_SUB_PAYMENT), sr.Store_Total_Advance_Sub_Payment__c);
        Test.stopTest();
    
    }
    
    /**
     * テストケース６
     */
    public static testmethod void Test_Case6() {
        
        Test.startTest();

        structTestData baseData = createBaseData(true);
        
        // 審査待ちにする
        Application4__c apply = new Application4__c();
        apply.Id = baseData.app4.Id;
        apply.Individual_Duplication_Check_Flag__c=true;
        apply.Corporation_Duplication_Check_Flag__c=true;
        apply.Status__c = Application4Const.CONST_APP4_STATUS_EXAMINATION;
        apply.SubStatus__c = Application4Const.CONST_APP4_SUB_STATUS_NEW;
        apply.SessionRadom__c='';
        RecordType retype=[Select id from  RecordType where DeveloperName='RecordType_readonly' and SobjectType='Application4__c'];
        apply.RecordTypeId=retype.id;
        upsert apply;
        
        //先行支払い対象店舗
        PrePayStore__c pps = new PrePayStore__c(
            Applicant_Business_Name__c = 'test',
            Applicant_Division__c = '個人事業主',
            Store_Name__c  = '天下一飯店',
            Permission_Number__c  = '123第456789号',
            Permission_Date__c  = '令和3年1月1日',
            PrePay_Store_Number__c  = 1,
            PrePay_Store_TotalAmount__c  = 700000,
            PrePay_Subject__c  = true,
            PrePay_Subject_Date__c  = Date.newInstance(2021, 8, 20),
            Application_Number__c  = '08080000008',
            Organize_Number__c  = '108080000008',
            Application_Type__c  = '電子',
            Application_Data__c  = '2期',
            Application_Id__c  = baseData.app4.Id,
            Applicant_Id__c  = 'test@test.test',
            FinancialInstitution_Name__c  = 'トランス信用金庫',
            Finacial_Branch_Name__c = '渋谷',
            Finacial_Account_Number__c  = '2222222',
            Account_Holder__c = 'ﾄﾗﾝｽｺｽﾓｽ',
            FinancialInstitutionCD__c = '0039',
            Finacial_Branch_Code__c  = '000',
            Finacial_Account_Type__c  = '普通'
        );
        insert pps;
        
        //営業時間短縮を行った店舗
        List<Store__c> storeList = new List<Store__c>();
        Store__c s = new Store__c(
            Application4__c  = baseData.app4.Id,
            StoreIndex__c = 1,
            Application_Store_Kbn__c = '飲食店',
            Application_Store_Per_Number_Com__c = '123',
            Application_Store_Per_Number_Issue__c = '456789',
            Application_Store_Per_Date__c = Date.newInstance(2021, 1, 1),
            Application_Store_Address_Type__c = '板橋区',
            Application_Store_Postal_Code__c = '2318588',
            Application_Store_Address__c = '板橋区日本大通１',
            Application_Store_Name__c = '天下一飯店',
            Application_Store_Effort_DetailsA__c = true,
            Application_Store_Start_Date__c =  Application4Const.CONST_APP4_SHORTER_BUSI_START_DATE.addDays(7),
            Application_Store_End_Date__c =  Application4Const.CONST_APP4_SHORTER_BUSI_END_DATE,
            Store_Application_Early_Benefit__c = true
        );
        storeList.add(s);
        insert storeList;
        
        Map<Id,Date> startDateMap = new Map<Id,Date>();
        startDateMap.put(s.id, s.Application_Store_Start_Date__c);
        
        //結果検証
        Store__c sr =[select id,Store_Total_Advance_Sub_Payment__c,PrePayStore__c,PerPay_Store_Basic_Check__c,PerPay_Store_Double_Check__c from Store__c where id = :s.Id];
        System.assertEquals(pps.Id, sr.PrePayStore__c);
        System.assertEquals(true, sr.PerPay_Store_Basic_Check__c);
        System.assertEquals(true, sr.PerPay_Store_Double_Check__c);
        System.assertEquals(calculateAmount(storeList,startDateMap)- Integer.valueOf(System.Label.ADVANCE_SUB_PAYMENT), sr.Store_Total_Advance_Sub_Payment__c);
        
        Application4__c app4 =[select id,Store_Total_Advance_Sub_Payment__c,Application_Amount__c from Application4__c where id = :baseData.app4.Id];
        System.assertEquals(sr.Store_Total_Advance_Sub_Payment__c, app4.Store_Total_Advance_Sub_Payment__c);
        Test.stopTest();
    
    }
    
    /**
     * テストケース７
     */
    public static testmethod void Test_Case7() {
        
        Test.startTest();

        structTestData baseData = createBaseData(true);
        
        // 審査待ちにする
        Application4__c apply = new Application4__c();
        apply.Id = baseData.app4.Id;
        apply.Individual_Duplication_Check_Flag__c=true;
        apply.Corporation_Duplication_Check_Flag__c=true;
        apply.Status__c = Application4Const.CONST_APP4_STATUS_EXAMINATION;
        apply.SubStatus__c = Application4Const.CONST_APP4_SUB_STATUS_NEW;
        apply.SessionRadom__c='';
        RecordType retype=[Select id from  RecordType where DeveloperName='RecordType_readonly' and SobjectType='Application4__c'];
        apply.RecordTypeId=retype.id;
        upsert apply;
        
        //先行支払い対象店舗
        List<PrePayStore__c> ppsList = new List<PrePayStore__c>();
        PrePayStore__c pps1 = new PrePayStore__c(
            Applicant_Business_Name__c = 'test',
            Applicant_Division__c = '個人事業主',
            Store_Name__c  = '天下一飯店',
            Permission_Number__c  = '123第456789号',
            Permission_Date__c  = '令和3年1月1日',
            PrePay_Store_Number__c  = 1,
            PrePay_Store_TotalAmount__c  = 700000,
            PrePay_Subject__c  = true,
            PrePay_Subject_Date__c  = Date.newInstance(2021, 8, 20),
            Application_Number__c  = '08080000008',
            Organize_Number__c  = '108080000008',
            Application_Type__c  = '電子',
            Application_Data__c  = '2期',
            Application_Id__c  = baseData.app4.Id,
            Applicant_Id__c  = 'test@test.test',
            FinancialInstitution_Name__c  = 'トランス信用金庫',
            Finacial_Branch_Name__c = '渋谷',
            Finacial_Account_Number__c  = '2222222',
            Account_Holder__c = 'ﾄﾗﾝｽｺｽﾓｽ',
            FinancialInstitutionCD__c = '0039',
            Finacial_Branch_Code__c  = '000',
            Finacial_Account_Type__c  = '普通'
        );
        ppsList.add(pps1);
        
        PrePayStore__c pps2 = new PrePayStore__c(
            Applicant_Business_Name__c = 'test',
            Applicant_Division__c = '個人事業主',
            Store_Name__c  = '大神カラオケ',
            Permission_Number__c  = '888第888888号',
            Permission_Date__c  = '令和1年8月8日',
            PrePay_Store_Number__c  = 1,
            PrePay_Store_TotalAmount__c  = 700000,
            PrePay_Subject__c  = true,
            PrePay_Subject_Date__c  = Date.newInstance(2021, 8, 20),
            Application_Number__c  = '08080000008',
            Organize_Number__c  = '108080000008',
            Application_Type__c  = '電子',
            Application_Data__c  = '2期',
            Application_Id__c  = baseData.app4.Id,
            Applicant_Id__c  = 'test@test.test',
            FinancialInstitution_Name__c  = 'トランス信用金庫',
            Finacial_Branch_Name__c = '渋谷',
            Finacial_Account_Number__c  = '2222222',
            Account_Holder__c = 'ﾄﾗﾝｽｺｽﾓｽ',
            FinancialInstitutionCD__c = '0039',
            Finacial_Branch_Code__c  = '000',
            Finacial_Account_Type__c  = '普通'
        );
        ppsList.add(pps2);
        insert ppsList;
        
        //営業時間短縮を行った店舗
        List<Store__c> storeList = new List<Store__c>();
        Store__c s1 = new Store__c(
            Application4__c  = baseData.app4.Id,
            StoreIndex__c = 1,
            Application_Store_Kbn__c = 'カラオケ店',
            Application_Store_Per_Number_Com__c = '888',
            Application_Store_Per_Number_Issue__c = '888888',
            Application_Store_Per_Date__c = Date.newInstance(2019, 8, 8),
            Application_Store_Address_Type__c = '板橋区',
            Application_Store_Postal_Code__c = '2318588',
            Application_Store_Address__c = '板橋区日本大通１',
            Application_Store_Name__c = '大神カラオケ',
            Application_Store_Effort_DetailsA__c = true,
            Application_Store_Start_Date__c =  Application4Const.CONST_APP4_SHORTER_BUSI_START_DATE.addDays(7),
            Application_Store_End_Date__c =  Application4Const.CONST_APP4_SHORTER_BUSI_END_DATE,
            Store_Application_Early_Benefit__c = true
        );
        storeList.add(s1);
        
        Store__c s2 = new Store__c(
            Application4__c  = baseData.app4.Id,
            StoreIndex__c = 2,
            Application_Store_Kbn__c = '飲食店',
            Application_Store_Per_Number_Com__c = '123',
            Application_Store_Per_Number_Issue__c = '456789',
            Application_Store_Per_Date__c = Date.newInstance(2021, 1, 1),
            Application_Store_Address_Type__c = '板橋区',
            Application_Store_Postal_Code__c = '2318588',
            Application_Store_Address__c = '板橋区日本大通１',
            Application_Store_Name__c = '天下一飯店',
            Application_Store_Effort_DetailsA__c = true,
            Application_Store_Start_Date__c =  Application4Const.CONST_APP4_SHORTER_BUSI_END_DATE.addDays(-7),
            Application_Store_End_Date__c =  Application4Const.CONST_APP4_SHORTER_BUSI_END_DATE,
            Store_Application_Early_Benefit__c = true
        );
        storeList.add(s2);
        insert storeList;
        
        Map<Id,Date> startDateMap = new Map<Id,Date>();
        startDateMap.put(s1.id, s1.Application_Store_Start_Date__c);
        startDateMap.put(s2.id, s2.Application_Store_Start_Date__c);
        
        //結果検証
        Store__c sr =[select id,Store_Total_Advance_Sub_Payment__c,PrePayStore__c,PerPay_Store_Basic_Check__c,PerPay_Store_Double_Check__c from Store__c where id = :s1.Id];
        System.assertEquals(pps2.Id, sr.PrePayStore__c);
        System.assertEquals(true, sr.PerPay_Store_Basic_Check__c);
        System.assertEquals(true, sr.PerPay_Store_Double_Check__c);
        
        Store__c sr2 =[select id,Store_Total_Advance_Sub_Payment__c,PrePayStore__c,PerPay_Store_Basic_Check__c,PerPay_Store_Double_Check__c from Store__c where id = :s2.Id];
        System.assertEquals(pps1.Id, sr2.PrePayStore__c);
        System.assertEquals(true, sr2.PerPay_Store_Basic_Check__c);
        System.assertEquals(true, sr2.PerPay_Store_Double_Check__c);

        Application4__c app4 =[select id,Store_Total_Advance_Sub_Payment__c,Application_Amount__c from Application4__c where id = :baseData.app4.Id];
        
        System.assertEquals(app4.Store_Total_Advance_Sub_Payment__c,sr.Store_Total_Advance_Sub_Payment__c + sr2.Store_Total_Advance_Sub_Payment__c);
        System.assertEquals(calculateAmount(storeList,startDateMap)- Integer.valueOf(System.Label.ADVANCE_SUB_PAYMENT)*2, app4.Store_Total_Advance_Sub_Payment__c);
        Test.stopTest();
    
    }

}