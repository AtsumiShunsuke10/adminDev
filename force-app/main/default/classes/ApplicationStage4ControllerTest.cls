/*******************************************************************************
 *  プロジェクト名 : 神奈川県新型コロナウイルス感染症拡大防止協力金
 *  クラス         : 申請（感染症拡大防止協力金：第3弾）ステージコントローラテストクラス
 *  クラス名       : ApplicationStage4ControllerTest
 *  概要           : 申請（感染症拡大防止協力金：第3弾）ステージコントローラテストクラス
 *  作成者         : 李
 *  作成日         : 2020/12/21
 *******************************************************************************/
@isTest 
public class ApplicationStage4ControllerTest {
    /**
     * テストデータ用構造体
     */
    private class structTestData {
        // public Application2__c app2;
        public Application4__c app4;
        public Account account;
        public Contact con;
        public C_FinancialInstitutiokanji__c financial;
        structTestData(Application4__c app4,Account account,Contact con,C_FinancialInstitutiokanji__c financial) {
        // structTestData(Application2__c app2,Application4__c app4,Account account,Contact con,C_FinancialInstitutiokanji__c financial) {
            // this.app2 = app2;
            this.app4 = app4;
            this.account = account;
            this.con = con;
            this.financial = financial;
        }
    }
    
    /**
     * テストデータ作成
     */
    private static structTestData createData(){
        //レコードタイプ
        // RecordType recObj2 = [SELECT Id FROM RecordType WHERE DeveloperName='RecordType_readonly' and SobjectType='Application2__c' LIMIT 1];
        RecordType recObj3 = [SELECT Id FROM RecordType WHERE DeveloperName='RecordType_readonly' and SobjectType='Application4__c' LIMIT 1];
    
        //会社
        Account account = new Account(
            Name = 'テストクラス用会社'
        );
        insert account;
        
       //会社担当者
        Contact con = new Contact(
            LastName = 'テストクラス用',
            FirstName = '担当者',
            AccountId = account.Id
        );
        insert con;
        
        //金融機関
        C_FinancialInstitutiokanji__c financial = new C_FinancialInstitutiokanji__c(Name = '山形第一信用組合');
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
        
        //申請2  
        /*Application2__c app2 = new Application2__c(
            RecordTypeId = recObj2.Id,
            Account_Holder__c = 'ﾄﾗﾝｽｺｽﾓｽ',
            Applicant_Address__c = '東京都渋谷区渋谷',
            Applicant_Business_Name__c = 'トランスコスモス株式会社',
            Applicant_Division__c = '個人事業主',
            Applicant_Name__c = 'ちょう',
            Applicant_Phone_For_Duplication_Check__c = '0803333333',
            Applicant_Phone__c = '0343631111',
            Applicant_Postal_Code__c = '1111111',
            Applicant_Title__c = '代表取締役',
            Application_Date__c = Date.newInstance(2020, 5, 1),
            Contact__c = con.Id,
            Corporate_Number_For_Duplication_Check__c = '1111111111111',
            Finacial_Account_Number_For_Duplication__c = '1111111',
            Finacial_Account_Number__c = '2222222',
            Finacial_Account_Type__c = '普通',
            Finacial_Branch_Code__c = '000',
            Finacial_Branch_Name__c = '渋谷',
            Financial_Institution_Lookup__c = financial.Id,
            Industry__c = '宿泊業、飲食サービス業',
            Pledge1__c = true,
            Same_As_Head_Office__c = true,
            Situation_On_5_12__c = 'SS2',
            Situation_On_5_13__c = 'SS2',
            Situation_On_5_14__c = 'SS2',
            Situation_On_5_15__c = 'SS2',
            Situation_On_5_16__c = 'SS2',
            Situation_On_5_17__c = 'SS2',
            Situation_On_5_18__c = 'SS2',
            Situation_On_5_19__c = 'SS2',
            Situation_On_5_20__c = 'SS2',
            Situation_On_5_21__c = 'SS2',
            Situation_On_5_22__c = 'SS2',
            Situation_On_5_23__c = 'SS2',
            Situation_On_5_24__c = 'SS2',
            Situation_On_5_25__c = 'SS2',
            Situation_On_5_26__c = 'SS2',
            Situation_On_5_27__c = 'SS2',
            Situation_On_5_28__c = 'SS2',
            Situation_On_5_29__c = 'SS2',
            Situation_On_5_30__c = 'SS2',
            Situation_On_5_31__c = 'SS2',
            Status__c = '未提出',
            Monthly_Average_Sales__c = '200000',
            Individual_Duplication_Check_Flag__c = true,
            Corporation_Duplication_Check_Flag__c = true,
            SessionRadom__c = '1.877574320889737'
        );
        insert app2;*/
        
        //申請（感染症拡大防止協力金：第3弾）
        Application4__c app4 = new Application4__c(
            RecordTypeId = recObj3.Id,
            Applicant_Division__c = '個人事業主',
            Applicant_Postal_Code__c = '1111111',
            Applicant_Address__c = '東京都渋谷区渋谷',
            Applicant_Business_Name__c = 'トランスコスモス株式会社',
            Applicant_Store_Count__c = '11',
            Applicant_Title__c = '代表取締役',
            Applicant_Name__c = 'ちょう',
            Applicant_Phone__c = '08033334444',
            Applicant_Phone_For_Duplication_Check__c = '08033334444',
            Application_Date__c = Date.today(),
            Contact__c = con.Id,
            Application_Store_1_Kbn__c = '酒類の提供を行う飲食店',
            Application_Store_1_Per_Number_Com__c = '指令',
            Application_Store_1_Per_Number_Issue__c = '123456789',
            Application_Store_1_Per_Date__c = Date.today().addYears(-1),
            Application_Store_1_Address_Type__c = '横浜市',
            Application_Store_1_Postal_Code__c = '2318588',
            Application_Store_1_Address__c = '神奈川県横浜市中区日本大通１',
            Application_Store_1_Name__c = '天下一飯店',
            Application_Store_1_Effort_DetailsA__c = true,
            Application_Store_2_Kbn__c = '酒類の提供を行う飲食店',
            Application_Store_2_Per_Number_Com__c = '指令',
            Application_Store_2_Per_Number_Issue__c = '123456789',
            Application_Store_2_Per_Date__c = Date.today().addYears(-1),
            Application_Store_2_Address_Type__c = '横浜市',
            Application_Store_2_Postal_Code__c = '2318588',
            Application_Store_2_Address__c = '神奈川県横浜市中区日本大通１',
            Application_Store_2_Name__c = '天下一飯店',
            Application_Store_2_Effort_DetailsA__c = true,
            Application_Store_3_Kbn__c = '酒類の提供を行う飲食店',
            Application_Store_3_Per_Number_Com__c = '指令',
            Application_Store_3_Per_Number_Issue__c = '123456789',
            Application_Store_3_Per_Date__c = Date.today().addYears(-1),
            Application_Store_3_Address_Type__c = '横浜市',
            Application_Store_3_Postal_Code__c = '2318588',
            Application_Store_3_Address__c = '神奈川県横浜市中区日本大通１',
            Application_Store_3_Name__c = '天下一飯店',
            Application_Store_3_Effort_DetailsA__c = true,
            Application_Store_4_Kbn__c = '酒類の提供を行う飲食店',
            Application_Store_4_Per_Number_Com__c = '指令',
            Application_Store_4_Per_Number_Issue__c = '123456789',
            Application_Store_4_Per_Date__c = Date.today().addYears(-1),
            Application_Store_4_Address_Type__c = '横浜市',
            Application_Store_4_Postal_Code__c = '2318588',
            Application_Store_4_Address__c = '神奈川県横浜市中区日本大通１',
            Application_Store_4_Name__c = '天下一飯店',
            Application_Store_4_Effort_DetailsA__c = true,
            Application_Store_5_Kbn__c = '酒類の提供を行う飲食店',
            Application_Store_5_Per_Number_Com__c = '指令',
            Application_Store_5_Per_Number_Issue__c = '123456789',
            Application_Store_5_Per_Date__c = Date.today().addYears(-1),
            Application_Store_5_Address_Type__c = '横浜市',
            Application_Store_5_Postal_Code__c = '2318588',
            Application_Store_5_Address__c = '神奈川県横浜市中区日本大通１',
            Application_Store_5_Name__c = '天下一飯店',
            Application_Store_5_Effort_DetailsA__c = true,
            Application_Store_6_Kbn__c = '酒類の提供を行う飲食店',
            Application_Store_6_Per_Number_Com__c = '指令',
            Application_Store_6_Per_Number_Issue__c = '123456789',
            Application_Store_6_Per_Date__c = Date.today().addYears(-1),
            Application_Store_6_Address_Type__c = '横浜市',
            Application_Store_6_Postal_Code__c = '2318588',
            Application_Store_6_Address__c = '神奈川県横浜市中区日本大通１',
            Application_Store_6_Name__c = '天下一飯店',
            Application_Store_6_Effort_DetailsA__c = true,
            Application_Store_7_Kbn__c = '酒類の提供を行う飲食店',
            Application_Store_7_Per_Number_Com__c = '指令',
            Application_Store_7_Per_Number_Issue__c = '123456789',
            Application_Store_7_Per_Date__c = Date.today().addYears(-1),
            Application_Store_7_Address_Type__c = '横浜市',
            Application_Store_7_Postal_Code__c = '2318588',
            Application_Store_7_Address__c = '神奈川県横浜市中区日本大通１',
            Application_Store_7_Name__c = '天下一飯店',
            Application_Store_7_Effort_DetailsA__c = true,
            Application_Store_8_Kbn__c = '酒類の提供を行う飲食店',
            Application_Store_8_Per_Number_Com__c = '指令',
            Application_Store_8_Per_Number_Issue__c = '123456789',
            Application_Store_8_Per_Date__c = Date.today().addYears(-1),
            Application_Store_8_Address_Type__c = '横浜市',
            Application_Store_8_Postal_Code__c = '2318588',
            Application_Store_8_Address__c = '神奈川県横浜市中区日本大通１',
            Application_Store_8_Name__c = '天下一飯店',
            Application_Store_8_Effort_DetailsA__c = true,
            Application_Store_9_Kbn__c = '酒類の提供を行う飲食店',
            Application_Store_9_Per_Number_Com__c = '指令',
            Application_Store_9_Per_Number_Issue__c = '123456789',
            Application_Store_9_Per_Date__c = Date.today().addYears(-1),
            Application_Store_9_Address_Type__c = '横浜市',
            Application_Store_9_Postal_Code__c = '2318588',
            Application_Store_9_Address__c = '神奈川県横浜市中区日本大通１',
            Application_Store_9_Name__c = '天下一飯店',
            Application_Store_9_Effort_DetailsA__c = true,
            Application_Store_10_Kbn__c = '酒類の提供を行う飲食店',
            Application_Store_10_Per_Number_Com__c = '指令',
            Application_Store_10_Per_Number_Issue__c = '123456789',
            Application_Store_10_Per_Date__c = Date.today().addYears(-1),
            Application_Store_10_Address_Type__c = '横浜市',
            Application_Store_10_Postal_Code__c = '2318588',
            Application_Store_10_Address__c = '神奈川県横浜市中区日本大通１',
            Application_Store_10_Name__c = '天下一飯店',
            Application_Store_10_Effort_DetailsA__c = true,
            Application_Store_11_Kbn__c = '酒類の提供を行う飲食店',
            Application_Store_11_Per_Number_Com__c = '指令',
            Application_Store_11_Per_Number_Issue__c = '123456789',
            Application_Store_11_Per_Date__c = Date.today().addYears(-1),
            Application_Store_11_Address_Type__c = '横浜市',
            Application_Store_11_Postal_Code__c = '2318588',
            Application_Store_11_Address__c = '神奈川県横浜市中区日本大通１',
            Application_Store_11_Name__c = '天下一飯店',
            Application_Store_11_Effort_DetailsA__c = true,
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
        insert app4;
        
        //return new structTestData(app2, app4, account, con, financial);
        return new structTestData(app4, account, con, financial);
    }
     
    public static testmethod void Test_method1() {
        structTestData sd = createData();
        ApplicationStage4Controller ctrl = new ApplicationStage4Controller();
        Date birthDt = Date.today().addyears(-30);
        ctrl.applyNum = '052202304';
        ctrl.testStr = true;
        ctrl.JSONString = null;
        ctrl.apply4 = sd.app4;
        ctrl.year = String.valueOf(birthDt.year());
        ctrl.month = String.valueOf(birthDt.month());
        ctrl.day = String.valueOf(birthDt.day());
        // ctrl.selectedApplication = Application4Const.CONST_APP_SELECT_LIST_VALUE2;
        // ctrl.selectedApplicationId = sd.app2.Id;

        ctrl.initInputPage();
        ctrl.initComfirmPage();
        // ctrl.getSelectApplication();
        // ctrl.getSelectApplicationNum();
        // 
        Map<Integer, ApplicationStage4Controller.CustomDate> tsbStartDateMap = new Map<Integer, ApplicationStage4Controller.CustomDate>();
		Date testDate = Date.today();
        for (Integer i = 1; i <= 11; i++) {
            ApplicationStage4Controller.CustomDate cusDate = new ApplicationStage4Controller.CustomDate();
            cusDate.customYear = String.valueOf(testDate.year());
            cusDate.customMonth = String.valueOf(testDate.month());
            cusDate.customDay = String.valueOf(testDate.day());
            tsbStartDateMap.put(i, cusDate);
        }
        ctrl.storeTsbStartDateMap = tsbStartDateMap;
        ctrl.toConfirmPage();
        ctrl.toConfirm();
        ApplicationStage4Controller.tempStr = '5.877574320889737';
        String saveToDocument = ApplicationStage4Controller.saveToDocument('abc.xlsx','abc,def','5.877574320889737','');
        String deleteDocument = ApplicationStage4Controller.deleteDocument('abc.xlsx','5.877574320889737','');
        ctrl.toCompletePage();
        ctrl.toInputPage();
        ctrl.deleteFile();
        ctrl.getSelectYear();
        ctrl.getSelectMonth();
        ctrl.getSelectDay();
        ctrl.getSelectWarekiYear();
        
        ApplicationStage4Controller.getAddress(ctrl.apply4.Applicant_Postal_Code__c);
    
    }
    
      public static testmethod void Test_method2() {
        structTestData sd = createData();
        // String app2Name = [select Name from Application2__c where Id =: sd.app2.Id].Name;
        // String putInfo = ApplicationStage4Controller.putInfo(sd.app2.Id);
    }  
}