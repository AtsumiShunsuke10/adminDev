public with sharing class EscalationHistoryTriggerHandler {
    public void OnBeforeInsert(List<EscalationHistory__c> escalationHistory) {
        Map<Id, Case> c = new Map<Id, Case>([SELECT Id, Status FROM Case]);
        for(EscalationHistory__c e : escalationHistory) {
            if(c.get(e.Case__c).Status.equals('エスカレーション')) {
                e.addError(System.Label.msg001);
            }
        }
    }
}