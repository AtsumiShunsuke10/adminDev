public with sharing class EscalationHistoryController {
    @AuraEnabled(cacheable=true)
    public static List<EscalationHistory__c> getEscalations() {
        List<EscalationHistory__c> escalations = [
            SELECT Id, Name, Case__c, Case__r.Subject, EscalationDescription__c
            FROM EscalationHistory__c 
            WHERE IsComplited__c = false
            ORDER BY Name desc
        ];
        if(escalations.isEmpty()) {
            return null;
        }
        return escalations;
    }
}