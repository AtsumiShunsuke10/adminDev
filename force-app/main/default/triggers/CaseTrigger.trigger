trigger CaseTrigger on Case (before update) {
    if(trigger.isBefore) {
        if(trigger.isUpdate) {
            CaseTriggerHandler handler = new CaseTriggerHandler();
            handler.OnBeforeUpdate(Trigger.new);
        }
    }
}