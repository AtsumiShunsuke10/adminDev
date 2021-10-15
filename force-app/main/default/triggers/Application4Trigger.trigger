/*******************************************************************************
 *  プロジェクト名 : ○○県新型コロナウイルス感染症拡大防止協力金
 *  クラス         : 申請（第4弾）トリガ
 *  クラス名       : Application4Trigger
 *  概要           : 申請（第4弾）トリガ
 *  作成者         : トランス・コスモス
 *  作成日         : 2021/09/01
 *******************************************************************************/
trigger Application4Trigger on Application4__c (before insert, before update) {
    
    if (Trigger.isBefore) {
        
        if (Trigger.isInsert) {
            
            Application4TriggerHandler.doBeforeInsert(Trigger.new);
            
        } else if (Trigger.isUpdate) {
            
            Application4TriggerHandler.doBeforeUpdate(Trigger.new);
            
        }
        
    }
    
}