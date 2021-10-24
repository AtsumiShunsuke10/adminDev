/*******************************************************************************
 *  プロジェクト名 : 東京都新型コロナウイルス感染症拡大防止協力金
 *  クラス         : ゴミ申請削除バッチ
 *  クラス名       : Application15DeleteBatch
 *  概要           : ゴミ申請削除バッチ
 *  作成者         : トランス・コスモス
 *  作成日         : 2021/10/01
 *******************************************************************************/
global class Application15DeleteBatch implements Database.Batchable<sObject>, Database.Stateful {

    /**
     * ゴミ申請削除バッチコンストラクタ
     * 
     */
    global Application15DeleteBatch(){
    }
    
    /**
     * startメソッド
     * 
     * @param Database.BatchableContext bc バッチコンテキスト
     */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        // ゴミ申請の削除期限日時
        DateTime delObjDate = Datetime.now().addHours(-24);
        String paraStatus = Application15Const.CONST_APP15_STATUS_NOT_PROPOSED;
        String strSql = 'SELECT ' + 
                        '    Id ' +                                 // Id
                        'FROM ' +
                        '    Application15__c ' +                    // 申請（感染症拡大防止協力金：第3弾）
                        'WHERE CreatedDate < :delObjDate ' +        // 作成日が24時間過ぎた
                        '    AND Status__c = :paraStatus';          // ステータスが未提出
        return Database.getQueryLocator(strSql);

    }
    
    /**
     * executeメソッド
     * 
     * @param Database.BatchableContext bc バッチコンテキスト
     * @param List<sObject> scope 処理対象リスト
     */
    global void execute(Database.BatchableContext bc, List<sObject> scope) {

        String ErrorMsg = '';
        if(scope.size() == 0){
            return;
        }
        
        Set<Id> entityIdSet = (new Map<Id, sObject>(scope)).keySet();
        
        //関連店舗を取得
        List<Store15__c> storeList =getStoreList(entityIdSet);
        Set<Id> storeIdSet = (new Map<Id, Store15__c>(storeList)).keySet();
        Set<Id> idSet = new Set<Id>();
        idSet.addAll(entityIdSet);
        idSet.addAll(storeIdSet);
        
        List<ContentDocumentLink> docLinkList = [SELECT 
                                               Id,
                                               ContentDocumentId 
                                           FROM 
                                               ContentDocumentLink 
                                           WHERE LinkedEntityId IN :idSet];
        Set<Id> docIdSet= new Set<Id>();
        for(ContentDocumentLink link : docLinkList){
            docIdSet.add(link.ContentDocumentId);
        }
        List<ContentDocument> delatt = [SELECT 
                                            Id 
                                        FROM 
                                            ContentDocument 
                                        WHERE Id IN :docIdSet];
        // 関連ファイルを削除
        if (delatt.size() > 0) {
            delete delatt;
        }
        
        // 関連店舗を削除
        if (storeList.size() > 0) {
            delete storeList;
        }
        
        // ゴミ申請を削除
        delete scope;
    }
    
    /**
     * 関連店舗を取得
     * 
     * @param Set<Id> entityIdSet 申請ID
     * 
     * return 関連店舗リスト
     */
    private List<Store15__c> getStoreList(Set<Id> entityIdSet) {
        String strSql = 'SELECT Id FROM Store15__c WHERE Application15__r.Status__c = \'仮申請\' OR ' + 
            'Application15__c in :entityIdSet';
        System.debug('************************strSql*****************************'+strSql);
        List<Store15__c> storeList = Database.query(strSql);
        return storeList;
    }
    
    /**
     * finishメソッド
     * 
     * @param Database.BatchableContext bc バッチコンテキスト
     */
    global void finish(Database.BatchableContext bc) {
    }
    
}