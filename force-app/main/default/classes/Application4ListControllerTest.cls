/*******************************************************************************
 *  プロジェクト名 : 神奈川県新型コロナウイルス感染症拡大防止協力金
 *  クラス         : 申請（感染症拡大防止協力金：第3弾）一覧コントローラテストクラス
 *  クラス名       : Application4ListControllerTest
 *  概要           : 申請（感染症拡大防止協力金：第3弾）一覧コントローラテストクラス
 *  作成者         : 李
 *  作成日         : 2020/12/21
 *******************************************************************************/
@isTest
public class Application4ListControllerTest {
    /**
     * テストデータ用構造体
     */
    private class structTestData {
        
        public Account account;
        public Contact con;
        public C_FinancialInstitutiokanji__c financial;
        structTestData(Account account,Contact con,C_FinancialInstitutiokanji__c financial) {
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
        RecordType recObj = [SELECT Id FROM RecordType WHERE DeveloperName='RecordType_readonly' and SobjectType='Application4__c' LIMIT 1];
    
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
        C_FinancialInstitutiokanji__c financial = new C_FinancialInstitutiokanji__c();
        financial = createFI();
        insert financial;
        
        // 住所マスタ
        AddressMaster__c addMst = new AddressMaster__c(
            PostalCode__c = '1111111',
        	Prefectures__c = '東京都',
            City__c = '千代田区',
            CommonName__c = '大手町',
            District__c = '１丁目'
        );
        insert addMst;
        
        return new structTestData(account, con, financial);
    }

    private static C_FinancialInstitutiokanji__c createFI(){
        C_FinancialInstitutiokanji__c FI = new C_FinancialInstitutiokanji__c(
            Name = 'テスト銀行',
            FinancialInstitutionCD__c = '999',
            T_FinancialInstitutiokana_c__c = 'テストギンコウ',
            SearchWord__c = 'テスト'
        );
        return FI;
    }

    // テスト用申請（感染症拡大防止協力金：第3弾）を一括作成
    private static Application4__c createApplication4(Id conId, Id financialInstitutionId) {
            Application4__c app4 = new Application4__c(
            Contact__c = conId,
            // SessionRadom__c = '5.877574320889737',
            Applicant_Business_Name__c = 'テスト株式会社',
            Applicant_Postal_Code__c = '1111111',
            Applicant_Address__c ='テストアドレス1-1-11',
            Applicant_Title__c = '代表取締役',
            Applicant_Name__c = 'テスト　太郎',
            Applicant_Birthday__c = Date.valueOf('1990-1-1'),
            Corporate_Number__c = '1234567890123',
            Financial_Institution_Lookup__c = financialInstitutionId,
            Finacial_Account_Type__c = '普通',
            Finacial_Branch_Name__c = '皆野町支店',
            Finacial_Branch_Code__c = '012',
            Account_Holder__c = 'ﾔﾏﾜｷﾘｻ',
            Finacial_Account_Number__c = '1234567',
            Pledge1__c = true,
            Application_Store_1_Name__c = 'テスト店舗１',
            Application_Store_1_Per_Date__c = Date.valueOf('2019-1-1'),
            Application_Store_1_Start_Date__c = Date.valueOf('2020-12-4'),
            Application_Store_1_End_Date__c = Date.valueOf('2020-12-17'),
            Document_And_App_Name_Info_Is_Same__c = Application4Const.CONST_APP4_SCR_RET_1_NG,
            Banking_Account_Document__c = Application4Const.CONST_APP4_SCR_RET_4_RESUB,
            Status__c = '不備回答待ち',
            SubStatus__c = '不備回答待ち（メール）',
            Document_Reupload__c = '再提出待ち',
            Individual_Duplication_Check_Flag__c = true,
            Corporation_Duplication_Check_Flag__c = true
        );
        return app4;
    }
    private static void creatContentAttachment(Id parentId) {
        ContentVersion cv = new ContentVersion();
        cv.Title = '11store_TestDocument';
        cv.PathOnClient = 'TestDocument.txt';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = parentId;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
    }

    public static testmethod void Test_method1() {
        
        structTestData sd = createData();

        //申請（感染症拡大防止協力金：第3弾）
        List<Application4__c> app4List = new List<Application4__c>();
        Application4__c app4 = createApplication4(sd.con.Id, sd.financial.Id);
        insert app4;
        app4List.add(app4);

        Application4ListController ctrl = new Application4ListController();
        ctrl.apply4List.addAll(app4List);
        ctrl.apply4 = app4List.get(0);
        ctrl.applyId = app4List.get(0).Id;
        creatContentAttachment(ctrl.applyId);
        
        Date nowDt = System.today();
        ctrl.year = String.valueOf(nowDt.year());
        ctrl.month = String.valueOf(nowDt.month());
        ctrl.day = String.valueOf(nowDt.day());

        ctrl.toDetailPage();
        ctrl.initDetailPage();
        ctrl.initRevisePage();
        ctrl.initChangeFilePage();
        ctrl.toChangeFile();
        Application4ListController.tempStr = ctrl.apply4.SessionRadom__c;
        String saveToDocument = Application4ListController.saveToDocument('abc.xlsx','abc,def',ctrl.apply4.SessionRadom__c,'');
        String deleteDocument = Application4ListController.deleteDocument('abc.xlsx',ctrl.apply4.SessionRadom__c,'');
        ctrl.toCompletePage();
        ctrl.toListPage();
        ctrl.toInputPage();
        ctrl.toDetailPage();
        ctrl.toRevisePage();
        ctrl.apply4.Applicant_Store_Count__c = '11';
        ctrl.doReviseUpdate();
        ctrl.apply4.Applicant_Store_Count__c = '1';
        ctrl.doReviseUpdate();
        ctrl.apply4.Document_And_App_Name_Info_Is_Same__c = Application4Const.CONST_APP4_SCR_RET_0_OK;
        ctrl.toRevisePage();
        ctrl.doReviseUpdate();
        ctrl.returnDetailPage();
        ctrl.returnPrevPage();
        ctrl.deleteFile();
    
        ctrl.getSelectYear();
        ctrl.getSelectWarekiYear();
        ctrl.getSelectMonth();
        ctrl.getSelectDay();
        
        Application4ListController.getAddress(app4.Applicant_Postal_Code__c);
        
    }
 
}