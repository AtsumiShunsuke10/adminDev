public with sharing class TodaysCallbackController {
    @AuraEnabled(cacheable=true)
    public static List<CallbackHistory__c> getTodaysCallbackList() {
        List<CallbackHistory__c> callbackHistories =  [
            SELECT Id, Name, Case__c, Case__r.Subject, CallbackDatetime__c, CallbackMemo__c
            FROM CallbackHistory__c
            WHERE CallbackDatetime__c = TODAY AND IsComplited__c = false 
            ORDER BY CallbackDatetime__c ASC 
        ];
        if(callbackHistories.isEmpty()) {
            return null;
        }
        return callbackHistories;
    }
}