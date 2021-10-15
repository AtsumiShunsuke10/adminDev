/*******************************************************************************
 *  プロジェクト名 : 神奈川県新型コロナウイルス感染症拡大防止協力金
 *  クラス         : ゴミ申請削除バッチテストクラス
 *  クラス名       : Application4DeleteBatchTest
 *  概要           : ゴミ申請削除バッチテストクラス
 *  作成者         : 李
 *  作成日         : 2020/12/21
 *******************************************************************************/
@isTest
public class Application4DeleteBatchTest {

    static testMethod void testScheduledJob() {
        // テスト用金融機関作成
        C_FinancialInstitutiokanji__c FI = new C_FinancialInstitutiokanji__c(
            Name = 'テスト銀行',
            FinancialInstitutionCD__c = '999',
            T_FinancialInstitutiokana_c__c = 'テストギンコウ',
            SearchWord__c = 'テスト'
        );
        insert FI;

        // テスト用会社作成
        Account account = new Account(
            Name = 'テストクラス用会社'
        );
        insert account;

        // テスト用担当者作成
        Contact con = new Contact(
            LastName = 'テストクラス用',
            FirstName = '担当者',
            AccountId = account.Id
        );
        insert con;
        
        // 申請（感染症拡大防止協力金：第3弾）リスト
        List<Application4__c> app4List = new List<Application4__c>(createApplication4(con.Id, FI.Id));
        insert app4List;

        Application4DeleteBatch deleteBatch = new Application4DeleteBatch();

        Test.startTest();
        
        // データバッチを開始
        Database.QueryLocator ql = deleteBatch.start(null);
        // データバッチを実行
        deleteBatch.execute(null, app4List);
        // データバッチを終了
        deleteBatch.Finish(null);

        Test.stopTest();
    
    }

    // テスト用申請（感染症拡大防止協力金：第3弾）を一括作成
    private static List<Application4__c> createApplication4(Id conId, Id financialInstitutionId) {

        List<Application4__c> appList = new List<Application4__c> ();
        for (Integer i=0; i<10; i++) {
        //申請（感染症拡大防止協力金：第3弾）
        Application4__c app4 = new Application4__c(
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
            Contact__c = conId,
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
            Financial_Institution_Lookup__c = financialInstitutionId,
            Account_Holder_Input__c = 'ﾄﾗﾝｽｺｽﾓｽ',
            Pledge1__c = true,
            Status__c = '未提出',
            Individual_Duplication_Check_Flag__c = true,
            Corporation_Duplication_Check_Flag__c = true,
            SessionRadom__c = '5.877574320889737'
        );
            appList.add(app4);
        }
        return appList;
        
    }
}