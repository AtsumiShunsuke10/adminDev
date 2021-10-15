public with sharing class ProgressHistoryController {
    public static String callBackRecordType = Schema.SObjectType.ProgressHistory__c.getRecordTypeInfosByDeveloperName().get('CallBackRecordType').getRecordTypeId();
    public static String escalationRecordType = Schema.SObjectType.ProgressHistory__c.getRecordTypeInfosByDeveloperName().get('EscalationRecordType').getRecordTypeId();

    @AuraEnabled(cacheable=true)
    public static List<ProgressHistory__c> getTodaysCallbackList() {
        List<ProgressHistory__c> callbackHistories =  [
            SELECT Id, Name, Inquiry__c, Inquiry__r.Subject__c, CallBackDateAndTime__c, Comment__c
            FROM ProgressHistory__c
            WHERE CallBackDateAndTime__c = TODAY AND Status__c = '未対応' AND RecordTypeId = :callBackRecordType
            ORDER BY CallBackDateAndTime__c ASC 
        ];
        if(callbackHistories.isEmpty()) {
            return null;
        }
        return callbackHistories;
    }

    @AuraEnabled(cacheable=true)
    public static List<ProgressHistory__c> getEscalations() {
        List<ProgressHistory__c> escalations = [
            SELECT Id, Name, Inquiry__c, Inquiry__r.Subject__c, Comment__c
            FROM ProgressHistory__c 
            WHERE Status__c = '対応中' AND RecordTypeId = :escalationRecordType
            ORDER BY Name DESC
        ];
        if(escalations.isEmpty()) {
            return null;
        }
        return escalations;
    }
}