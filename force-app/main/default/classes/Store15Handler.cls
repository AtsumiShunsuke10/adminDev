/*******************************************************************************
 *  プロジェクト名 : 神奈川県新型コロナウイルス感染症拡大防止協力金
 *  クラス         : 店舗トリガハンドラクラス
 *  クラス名       : Store15Handler
 *  概要           : 店舗トリガハンドラクラス
 *  作成者         : トランス・コスモス
 *  作成日         : 2021/10/01
 *******************************************************************************/
public class Store15Handler {
    //二次起動防止
    public static boolean firstRun = true;
    
    /**
     * doBeforeInsertメソッド
     * 
     * @param List<Store15__c> store 店舗レコードリスト
     */
    public static void doBeforeInsert(List<Store15__c> newStoreList) {
        calculateSumAmount(newStoreList);
        ensureApplicationStorePerNumber(newStoreList);
    }
    
    /**
     * doBeforeUpdateメソッド
     * 
     * @param List<Store15__c> store 店舗レコードリスト
     */
    public static void doBeforeUpdate(List<Store15__c> newStoreList) {
        calculateSumAmount(newStoreList);
        ensureApplicationStorePerNumber(newStoreList);
        for(Store15__c s:newStoreList){
            //店舗修正条件が満たされた場合、店舗の修正フラグがtrueに変更
            if(s.Store_Appearance_Document__c == Application15Const.CONST_APP15_SCR_RET_4_RESUB 
               || s.Store_Business_Permit_Document__c == Application15Const.CONST_APP15_SCR_RET_4_RESUB 
               || s.Store_Alcohol_Document__c == Application15Const.CONST_APP15_SCR_RET_4_RESUB 
               || s.Store_Time_Saving_Document__c == Application15Const.CONST_APP15_SCR_RET_4_RESUB 
               || s.Store_Time_Saving_Document_Old__c == Application15Const.CONST_APP15_SCR_RET_4_RESUB 
               || s.Store_Business_Permit_And_Name_Is_Same__c == Application15Const.CONST_APP15_SCR_RET_1_NG 
               || s.Store_Business_Permit_Info_Is_Correct__c == Application15Const.CONST_APP15_SCR_RET_1_NG 
               || s.Store_Business_Permit_And_Add_Is_Same__c == Application15Const.CONST_APP15_SCR_RET_1_NG
              ){
                  s.Correction_Flag__c = true; 
              }
        }
    }
    
    /**
     * doAfterUpdateメソッド
     * 
     * @param List<Store15__c> store 店舗レコードリスト
     */
    public static void doAfterInsert(List<Store15__c> newStoreList, Map<Id, Store15__c> oldStoreMap) {
    }
    
    /**
     * doAfterUpdateメソッド
     * 
     * @param List<Store15__c> store 店舗レコードリスト
     */
    public static void doAfterUpdate(List<Store15__c> newStoreList, Map<Id, Store15__c> oldStoreMap) {
        //親申請レコードリフレッシュ
        reUpdateApplication(newStoreList);
    }
    
    /**
     * 申請（感染症拡大防止協力金：第3弾）: 合計金額計算
     * 
     * @param List<Store15__c> store 店舗レコードリスト
     */
    private static void calculateSumAmount(List<Store15__c> storeList) {
        try {
            for (Store15__c s : storeList){
                List<String> dayZone = System.Label.CONST_DAILY_ZONE_REQ.split(',');
                List<String> amountZone = System.Label.CONST_DAILY_AMOUNT_REQ.split(',');
                Integer unitPricePerDay = Integer.valueOf(System.Label.APPLICATION15_PAYMENT_UNIT_PRICE);
                Date tsbEndDay = s.Application_Store_End_Date__c;
                Date startDate = s.Application_Store_Start_Date__c;
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
                
                s.Application_For_Parent_Amount__c = storeAmount;
            }
        } catch (Exception e) {
            System.debug('*********Exception:********'+e.getMessage());
        }
    }
    
    /**
     * 親申請レコードリフレッシュ
     * 
     * @param List<Store15__c> store 店舗レコードリスト
     */
    private static void reUpdateApplication(List<Store15__c> storeList) {
        try {
            Application15__c app = new Application15__c();
            for (Store15__c s : storeList){
                if(app.id == null){
                    app.id = s.Application15__c;
                    break;
                }
            }
            update app;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }
    /**
     * 申請（感染症拡大防止協力金：第15弾）: 営業許可番号の検証
     * 
     * @param List<Store15__c> store 店舗レコードリスト
     */
    private static void ensureApplicationStorePerNumber(List<Store15__c> storeList) {
        List<BusinessPermit__c> businessPermit = [SELECT BusinessPermitNo__c, ExpaireCheckStart__c, ExpaireCheckEnd__c FROM BusinessPermit__c];
        Map<String, BusinessPermit__c> businessPermitMap = new Map<String, BusinessPermit__c>();
        
        for(BusinessPermit__c b : businessPermit) {
            businessPermitMap.put(b.BusinessPermitNo__c, b);
        }


        for(Store15__c s : storeList) {
            BusinessPermit__c b = businessPermitMap.get(s.Application_Store_Per_Number__c);

            String resultMessage = System.Label.APPLICATION_STORE_PER_NUMBER_OK;
            if(b != null) {
                Integer cnt = [SELECT COUNT() FROM Store15__c WHERE Application_Store_Per_Number__c = :b.BusinessPermitNo__c];
                if(cnt > 1) {
                    resultMessage = System.Label.APPLICATION_STORE_PER_NUMBER_DUPLICATE;
                } else if(b.ExpaireCheckStart__c.equals(System.Label.APPLICATION_STORE_PER_NUMBER_EXPIRED) || 
                            b.ExpaireCheckEnd__c.equals(System.Label.APPLICATION_STORE_PER_NUMBER_EXPIRED)) {
                    resultMessage = System.Label.APPLICATION_STORE_PER_NUMBER_EXPIRED;
                }
            } else {
                resultMessage = System.Label.APPLICATION_STORE_PER_NUMBER_NOT_FOUND;
            }

            s.ResultEnsureApplicationStorePerNumber__c = resultMessage;
        }
    }
}