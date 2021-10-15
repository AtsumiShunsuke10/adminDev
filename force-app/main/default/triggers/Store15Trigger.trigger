/*******************************************************************************
 *  プロジェクト名 : 東京都新型コロナウイルス感染症拡大防止協力金
 *  クラス         : 店舗（感染症拡大防止協力金：第15弾）トリガ
 *  クラス名       : StoreTrigger
 *  概要           : 店舗（感染症拡大防止協力金：第15弾）トリガ
 *  作成者         : トランス・コスモス
 *  作成日         : 2021/10/01
 *******************************************************************************/
trigger Store15Trigger on Store15__c (before insert, before update, after insert, after update) {
    
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            Store15Handler.doBeforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            Store15Handler.doBeforeUpdate(Trigger.new);
        }
        
    }else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            Store15Handler.doAfterInsert(Trigger.new, Trigger.oldMap);
        } else if (Trigger.isUpdate) {
            Store15Handler.doAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
    
}