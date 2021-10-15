/*******************************************************************************
 *  プロジェクト名 : 神奈川県新型コロナウイルス感染症拡大防止協力金
 *  クラス         : 店舗トリガハンドラクラス
 *  クラス名       : StoreTrigger
 *  概要           : 店舗トリガハンドラクラス
 *  作成者         : トランス・コスモス
 *  作成日         : 2021/09/01
 *******************************************************************************/
public class StoreHandler {
    /** 先行支払い処理用の各期申請の名称とAPI参照名のマップ */
    private static Map<String, String> ALL_APP_API_NAME_MAP {
        get {
            if (ALL_APP_API_NAME_MAP == null) {
                ALL_APP_API_NAME_MAP = new Map<String, String>();
                String[] allAppNames = System.Label.APPLICATION_ALL_PRE_PAY_APP_NAME.split(',');
                String[] allAppApiNames = System.Label.APPLICATION_ALL_PRE_PAY_APP_API_NAME.split(',');
                if (allAppNames.size() == allAppApiNames.size()) {
                    for (Integer idx = 0; idx < allAppNames.size(); idx++) {
                        ALL_APP_API_NAME_MAP.put(allAppNames.get(idx), allAppApiNames.get(idx));
                    }
                }
            }
            return ALL_APP_API_NAME_MAP;
        }
        set;
    }
    
    //二次起動防止
    public static boolean firstRun = true;
    
    /**
     * doBeforeInsertメソッド
     * 
     * @param List<Store__c> store 店舗レコードリスト
     */
    public static void doBeforeInsert(List<Store__c> newStoreList) {
        calculateSumAmount(newStoreList);
    }
    
    /**
     * doBeforeUpdateメソッド
     * 
     * @param List<Store__c> store 店舗レコードリスト
     */
    public static void doBeforeUpdate(List<Store__c> newStoreList) {
        calculateSumAmount(newStoreList);
    }
    
    /**
     * doAfterUpdateメソッド
     * 
     * @param List<Store__c> store 店舗レコードリスト
     */
    public static void doAfterInsert(List<Store__c> newStoreList, Map<Id, Store__c> oldStoreMap) {
        // 先行支払い対象チェック
        checkPrePayInfo(newStoreList,oldStoreMap,true);
    }
    
    /**
     * doAfterUpdateメソッド
     * 
     * @param List<Store__c> store 店舗レコードリスト
     */
    public static void doAfterUpdate(List<Store__c> newStoreList, Map<Id, Store__c> oldStoreMap) {
        //親申請レコードリフレッシュ
        reUpdateApplication(newStoreList);
        // 先行支払い対象チェック
        checkPrePayInfo(newStoreList,oldStoreMap,false);
    }
    
    /**
     * 申請（感染症拡大防止協力金：第3弾）: 合計金額計算
     * 
     * @param List<Store__c> store 店舗レコードリスト
     */
    private static void calculateSumAmount(List<Store__c> storeList) {
        try {
            for (Store__c s : storeList){
                List<String> dayZone = System.Label.CONST_DAILY_ZONE_REQ.split(',');
                List<String> amountZone = System.Label.CONST_DAILY_AMOUNT_REQ.split(',');
                Integer unitPricePerDay = Integer.valueOf(System.Label.APPLICATION4_PAYMENT_UNIT_PRICE);
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
            System.debug(e.getMessage());
        }
    }
    
    /**
     * 親申請レコードリフレッシュ
     * 
     * @param List<Store__c> store 店舗レコードリスト
     */
    private static void reUpdateApplication(List<Store__c> storeList) {
        try {
            Application4__c app = new Application4__c();
            for (Store__c s : storeList){
                if(app.id == null){
                    app.id = s.Application4__c;
                    break;
                }
            }
            update app;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }
    
    /**
     * 先行支払い対象チェック
     * 
     * @param List<Store__c> newStoreList 新店舗レコードリスト
     * @param Map<Id, Store__c> oldStoreMap 店舗レコードoldMap
     * @param boolean isInsert 新規作成フラグ
     */
    private static void checkPrePayInfo(List<Store__c> newStoreList, Map<Id, Store__c> oldStoreMap, boolean isInsert) {

        Map<String, String> prePayMap = new Map<String, String>();          // 先行支払い対象チェックMap
        Map<Id, Store__c> targetStoreMap = new Map<Id, Store__c>();         // 先行支払い対象Map
        // 先行支払い対象をフィルターする
        for (Store__c s : newStoreList) {
            // ステータスが審査待ちに変わる場合
            // 電子申請の場合 、または紙申請、かつ早期給付申請の有無がTrueの場合
            if ((!isInsert && s.Status__c == Application4Const.CONST_APP4_STATUS_EXAMINATION && s.Status__c != oldStoreMap.get(s.Id).Status__c) ||
                 (isInsert && s.Status__c == Application4Const.CONST_APP4_STATUS_EXAMINATION) 
               ) {
                   // 申請金額がnull以外の場合
                   if (s.get('Application_Store_Apply_Amount__c') != null &&
                       (s.Report_Flg__c == Application4Const.CONST_APP4_REP_FLG_ELECTRONIC ||
                        (s.Report_Flg__c == Application4Const.CONST_APP4_REP_FLG_PAPER && ((Boolean)s.get('Store_Application_Early_Benefit__c')) == true)
                       )) {
                           // キー：店舗飲食店営業許可書-許可番号　＋　店舗飲食店営業許可書-許可年月日（和暦）、バリュー：申請（第16期）のId + '-' + 店舗の連番
                           String key = Application4Utility.nullToString((String)s.get('Application_Store_Per_Number__c')) + 
                               Application4Utility.nullToString((String)s.get('Application_Store_Per_Date_Jp__c'));
                           if (String.isBlank(key)) continue; 
                           prePayMap.put(key, s.Id);
                           targetStoreMap.put(s.Id, s);
                       }
               }

        }
        System.debug('isInsert::::::'+isInsert);
        // 処理対象が存在しない場合、処理終了
        if (prePayMap.size() == 0) return;

        // 先行支払い対象店舗を検索する
        List<PrePayStore__c> prePayStoreList = [Select Id, Permission_Number_And_Date__c, Application_Id__c, Application_Data__c, FinancialInstitution_Name__c,
                                                       FinancialInstitutionCD__c, Finacial_Branch_Name__c, Finacial_Branch_Code__c,
                                                       Finacial_Account_Number__c, Account_Holder__c, Finacial_Account_Type__c
                                                From PrePayStore__c
                                                Where Permission_Number_And_Date__c In : prePayMap.keySet() And IsDisabled__c = false];
        Map<String, PrePayStore__c> prePayStoreMap = new Map<String, PrePayStore__c>();                          // 先行支払い対象店舗Map
        Map<String, List<String>> appIdListPerAppMap = new Map<String, List<String>>();                          // 各期の申請IDのMap
        for (PrePayStore__c store : prePayStoreList) {
            
            prePayStoreMap.put(store.Permission_Number_And_Date__c, store);
            
            if (String.isBlank(store.Application_Data__c)) continue; 
            // 申請データ（期）がappIdListPerAppMapのketSetに存在しない場合
            if (!appIdListPerAppMap.containsKey(store.Application_Data__c)) {
                appIdListPerAppMap.put(store.Application_Data__c, new List<String>());
            }
            appIdListPerAppMap.get(store.Application_Data__c).add(store.Application_Id__c);
            
        }
        
        List<Id> allAppIdList = new List<Id>();
        // 関連の各期申請のIDを検索する
        for(String appData : appIdListPerAppMap.keySet()) {
            List<String> appIdList = appIdListPerAppMap.get(appData);
            allAppIdList.addAll((new Map<Id, sObject>(Database.query('Select Id From ' + ALL_APP_API_NAME_MAP.get(appData) +' Where Id In :appIdList'))).keySet());
        }
        
        Map<Id, Store__c> updateMap = new Map<Id, Store__c>();
        // 先行支払い対象チェックMapのKeySetをループする
        for (String key : prePayMap.keySet()) {
        
            Id appId = null;
            String appIdNo = null;
            boolean doubleCheck = false;
            Store__c updateStore = null;
            
            // 申請ID-連番を取得
            appId = Id.valueOf(prePayMap.get(key));
            
            Store__c s = targetStoreMap.get(appId);
            if (!updateMap.containsKey(appId)) {
                updateMap.put(appId, new Store__c(Id = appId));
            }
            updateStore = updateMap.get(appId);
            // 営業許可番号＋許可年月日　にて店舗特定し先払い確認
            if (prePayStoreMap.containsKey(key)) {
                
                updateStore.put('PerPay_Store_Basic_Check__c', true);
                updateStore.put('PrePayStore__c', prePayStoreMap.get(key).Id);
                Decimal subPayment  = 0;
                if(s.Application_Store_Apply_Amount__c !=null){
                    subPayment = s.Application_Store_Apply_Amount__c - Integer.valueOf(System.Label.ADVANCE_SUB_PAYMENT);
                    /*if(subPayment<0){
                        subPayment  = 0;
                    }*/
                }
                
                updateStore.put('Store_Total_Advance_Sub_Payment__c', subPayment);
                
            } else {
            
                updateStore.put('PerPay_Store_Basic_Check__c', false);
                
            }
            // 基本チェックがfalseの場合
            if (updateStore.get('PerPay_Store_Basic_Check__c') != true) {

                updateStore.put('PerPay_Store_Double_Check__c', false);
            
            // 基本チェックがtrueの場合
            } else {
                // 振込先口座が先払い先として存在しているか
                PrePayStore__c store = prePayStoreMap.get(key);
                if (store.FinancialInstitution_Name__c == s.FinancialName__c &&                     // 金融機関名
                    store.FinancialInstitutionCD__c    == s.Financial_Institution_Code__c &&        // 金融機関コード
                    store.Finacial_Branch_Name__c      == s.Finacial_Branch_Name__c &&              // 支店名
                    store.Finacial_Branch_Code__c      == s.Finacial_Branch_Code__c &&              // 支店コード
                    store.Finacial_Account_Number__c   == s.Finacial_Account_Number__c &&           // 口座番号
                    store.Account_Holder__c            == s.Account_Holder__c &&                    // 口座名義ｶﾅ（半角）
                    store.Finacial_Account_Type__c     == s.Finacial_Account_Type__c) {             // 預金種別
                    
                    doubleCheck = true;
                    
                }
 
                // 電子申請者の場合は同一申請IDが先払い先として存在しているか
                if (doubleCheck == true && s.Report_Flg__c == Application4Const.CONST_APP4_REP_FLG_ELECTRONIC) {
                    if (String.isNotBlank(store.Application_Id__c) && allAppIdList.contains(Id.valueOf(store.Application_Id__c))) {
                        doubleCheck = true;
                    } else {
                        doubleCheck = false;
                    }
                }
                // ダブルチェックフラグがTrueの場合
                if (doubleCheck) {
                
                    updateStore.put('PerPay_Store_Double_Check__c', true);
                    
                } else {
                    
                    updateStore.put('PerPay_Store_Double_Check__c', false);
                    
                }
            }
        }
        
        update updateMap.values();
        firstRun= false;
    }
}