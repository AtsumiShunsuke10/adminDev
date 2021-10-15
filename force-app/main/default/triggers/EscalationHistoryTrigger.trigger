trigger EscalationHistoryTrigger on EscalationHistory__c (before insert) {
    if(trigger.isBefore) {
        if(trigger.isInsert) {
            EscalationHistoryTriggerHandler handler = new EscalationHistoryTriggerHandler();
            handler.OnBeforeInsert(Trigger.new);
        }
    }
}