/*******************************************************************************
 *  プロジェクト名 : ○○県新型コロナウイルス感染症拡大防止協力金
 *  クラス         : 申請（感染症拡大防止協力金：第3弾）トリガハンドラクラス
 *  クラス名       : Application4TriggerHandler
 *  概要           : 申請（感染症拡大防止協力金：第3弾）トリガハンドラクラス
 *  作成者         : トランス・コスモス
 *  作成日         : 2021/09/01
 *******************************************************************************/
public class Application4TriggerHandler {
    
    /**
     * doBeforeInsertメソッド
     * 
     * @param List<Application4__c> newApp4List 新申請（感染症拡大防止協力金：第3弾）レコードリスト
     */
    public static void doBeforeInsert(List<Application4__c> newApp4List) {
        
        // 口座名義自動変換
        convertAccountHolder(newApp4List);
        
        // 要件審査結果の設定
        setRequirementScreeningResult(newApp4List,true);
    }
    
    /**
     * doBeforeUpdateメソッド
     * 
     * @param List<Application4__c> newApp4List 新申請（感染症拡大防止協力金：第3弾）レコードリスト
     */
    public static void doBeforeUpdate(List<Application4__c> newApp4List) {
        
        // 口座名義自動変換
        convertAccountHolder(newApp4List);
        
        // 要件審査結果の設定
        setRequirementScreeningResult(newApp4List,false);
        
    }
    
    /**
     * 口座名義自動変換
     * 
     * @param List<Application4__c> newApp4List 新申請（感染症拡大防止協力金：第3弾）レコードリスト
     */
    private static void convertAccountHolder(List<Application4__c> newApp4List) {
        
        for (Application4__c app4 : newApp4List) {
            
            // 「口座名義ｶﾅ★」項目値を半角変換して、「口座名義ｶﾅ（半角）★」項目に設定する
            app4.Account_Holder__c = Application4Utility.convertFullToHalf(app4.Account_Holder_Input__c);
            
        }
        
    }
    
    /**
     * 要件審査結果の設定
     * 
     * @param List<Application4__c> newApp4List 新申請（感染症拡大防止協力金：第3弾）レコードリスト
     */
    private static void setRequirementScreeningResult(List<Application4__c> newApp4List,boolean insertFlg) {
        
        List<String> scrRetListPerApp4 = null;       // 新申請（感染症拡大防止協力金：第3弾）レコード毎に審査結果リスト
        CheckScrRetInfo chkInfo = null;
        for (Application4__c app4 : newApp4List) {
            
            scrRetListPerApp4 = new List<String>();

            // 申請者情報について、審査値取得
            getApplicantScrRetInfo(app4, scrRetListPerApp4);
            // 支払口座振替依頼について、審査値取得
            getFinacialAccountScrRetInfo(app4, scrRetListPerApp4);
            // 営業時間を行った店舗の情報（各店舗）について、審査値取得
            if(!insertFlg){
                getStoresScrRetInfo(app4, scrRetListPerApp4);
            }
            // 制約事項について、審査値取得
            scrRetListPerApp4.add(app4.Pledge_Info_Is_No_Omissions__c);                                 // ⑱チェック漏れがないか
            
            // 新申請（感染症拡大防止協力金：第3弾）レコード毎に審査結果リストの判定
            chkInfo = checkScrRetListPerApp4(scrRetListPerApp4);

            // 要件審査結果を設定
            // すべて「審査OK」、「対象外」→審査OK
            if (chkInfo.isAllOk) {
                app4.Requirement_Screening_Result__c = Application4Const.CONST_APP4_REQ_SCR_RET_OK;
            // 「エスカレーション」が1つ以上存在→エスカレーション
            } else if (chkInfo.hasEscalation) {
                app4.Requirement_Screening_Result__c = Application4Const.CONST_APP4_REQ_SCR_RET_ESCA;
            // 「エスカレーション」がなく、「空欄」または「審査NG」または「４：ファイル再提出」が１つ以上存在→審査NG
            } else if (chkInfo.hasNullOrNg) {
                app4.Requirement_Screening_Result__c = Application4Const.CONST_APP4_REQ_SCR_RET_NG;
            }

        }
        
    }

    /**
     * 申請者情報について、審査値取得
     * 
     * @param Application4__c app4 新申請（感染症拡大防止協力金：第3弾）レコード
     * @param List<String> scrRetListPerApp4 新申請（感染症拡大防止協力金：第3弾）レコード毎に審査結果リスト
     */
    private static void getApplicantScrRetInfo(Application4__c app4, List<String> scrRetListPerApp4) {

        scrRetListPerApp4.add(app4.Filled_App_Info_Is_No_Omissions__c);                  // ①記入漏れがないか
        // 個人事業主の場合
        if (app4.Applicant_Division__c == Application4Const.CONST_APP4_APP_DIV_SOLE) {
            scrRetListPerApp4.add(app4.Identification_Document__c);                      // ➁本人確認書類の写しがある
            scrRetListPerApp4.add(app4.Document_And_App_Name_Info_Is_Same__c);           // ③本人確認書類と一致しているか
        }
        scrRetListPerApp4.add(app4.Business_Permit_Info_Is_Same__c);                     // ④営業許可書と一致しているか
        scrRetListPerApp4.add(app4.Store_Num_And_Store_Info_Is_Same__c);                 // ⑤店舗数が申請店舗数と一致しているか
        // 法人の場合
        if (app4.Applicant_Division__c == Application4Const.CONST_APP4_APP_DIV_CORP) {
            scrRetListPerApp4.add(app4.Com_Number_And_Com_Info_Is_Same__c);              // ⑥法人番号と会社名が一致しているか
        }

    }

    /**
     * 営業時間を行った店舗の情報（各店舗）について、審査値取得
     * 
     * @param Application4__c app4 新申請（感染症拡大防止協力金：第3弾）レコード
     * @param List<String> scrRetListPerApp4 新申請（感染症拡大防止協力金：第3弾）レコード毎に審査結果リスト
     */
    private static void getStoresScrRetInfo(Application4__c app4, List<String> scrRetListPerApp4) {
        List<String> fieldsList = Application4Utility.getAllColumnsList('Store__c');
        String query = Application4Utility.makeSoql(fieldsList, 'Store__c', 'Application4__c = \''+ app4.Id +'\'', '', '', '');
        List<Store__c> storeList = Database.query(query);
        
        for (Store__c s : storeList) {

            // 申請金額がnullの場合、対象外
            if (s.Application_Store_Apply_Amount__c == null) {
                continue;
            }
            
            scrRetListPerApp4.add((String)s.Store_Appearance_Document__c);                               // ⑩各店舗の外観が分かる写真がある
            scrRetListPerApp4.add((String)s.Store_Business_Permit_Document__c);                          // ⑪飲食店の営業許可書の写しがある
            scrRetListPerApp4.add((String)s.Store_Alcohol_Document__c);                                  // ⑫酒類を提供していることがわかる書面等の写しがある
            scrRetListPerApp4.add((String)s.Store_Time_Saving_Document__c);                              // ⑬対象店舗において「時短営業の案内」を掲示したことがわかるものがある
            scrRetListPerApp4.add((String)s.Store_Time_Saving_Document_Old__c);                          // ⑭従来の営業時間がわかる写真等がある
            scrRetListPerApp4.add((String)s.Store_Business_Permit_And_Name_Is_Same__c);                  // ⑮名称が営業許可書と一致しているか
            scrRetListPerApp4.add((String)s.Store_Business_Permit_Info_Is_Correct__c);                   // ⑯許可番号・年月日が許可書の記載と一致し、日付が有効期限内である
            scrRetListPerApp4.add((String)s.Store_Business_Permit_And_Add_Is_Same__c);                   // ⑰営業許可書の「１営業所の所在地」と一致し、対象エリアである

        }
    }

    /**
     * 支払い口座情報について、審査値取得
     * 
     * @param Application4__c app4 新申請（感染症拡大防止協力金：第3弾）レコード
     * @param List<String> scrRetListPerApp4 新申請（感染症拡大防止協力金：第3弾）レコード毎に審査結果リスト
     */
    private static void getFinacialAccountScrRetInfo(Application4__c app4, List<String> scrRetListPerApp4) {

        scrRetListPerApp4.add(app4.Banking_Account_Document__c);                             // ⑦振込先口座情報が分かる書類の写しがある
        scrRetListPerApp4.add(app4.Document_And_Info_Is_Same__c);                            // ⑧通帳等の写しと口座情報が一致しているか
        scrRetListPerApp4.add(app4.Applicant_Acc_Holder_Is_Same__c);                         // ⑨申請者と口座名義人が一致しているか

    }
    
    /**
     * 新申請（感染症拡大防止協力金：第3弾）レコード毎に審査結果リストの判定
     * 
     * @param List<String> scrRetListPerApp4 新申請（感染症拡大防止協力金：第3弾）レコード毎に審査結果リスト
     */
    private static CheckScrRetInfo checkScrRetListPerApp4(List<String> scrRetListPerApp4) {
        
        CheckScrRetInfo checkInfo = new CheckScrRetInfo();
        for (String scrRet : scrRetListPerApp4) {

            // 「エスカレーション」が1つ以上存在
            if (scrRet == Application4Const.CONST_APP4_SCR_RET_2_ESCA) {
                checkInfo.hasEscalation = true;
                checkInfo.isAllOk = false;
            // 「空欄」または「審査NG」または「４：ファイル再提出」が１つ以上存在
            } else if (String.isBlank(scrRet) || 
                       scrRet == Application4Const.CONST_APP4_SCR_RET_1_NG ||
                       scrRet == Application4Const.CONST_APP4_SCR_RET_4_RESUB) {
                checkInfo.hasNullOrNg = true;
                checkInfo.isAllOk = false;
            }
            
        }

        return checkInfo;
        
    }

    /**
     * 新申請（感染症拡大防止協力金：第3弾）レコード毎に審査結果リストの判定結果
     * 
     */
    public class CheckScrRetInfo {
        
        /** すべて「審査OK」 */
        public Boolean isAllOk = true;

        /** 「エスカレーション」が1つ以上存在 */
        public Boolean hasEscalation = false;

        /** 「空欄」または「審査NG」が１つ以上存在 */
        public Boolean hasNullOrNg = false;
      
    }

}