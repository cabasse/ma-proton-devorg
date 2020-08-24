trigger AccountTrigger on Account (after insert, after update) {

    map<string, boolean> triggerControlMap = new map<string, boolean>();

    for (Trigger_Controls__mdt tControl : [
        select Method_Name__c, Is_Enabled__c
        from Trigger_Controls__mdt 
        where Object_Name__c='Account']) {
            triggerControlMap.put(tControl.Method_Name__c, tControl.Is_Enabled__c);
        }

    if (trigger.isInsert) {
        if (triggerControlMap.get('createOpportunities') != null && triggerControlMap.get('createOpportunities')) AccountTriggerHandler.createOpportunities(trigger.new);
    }
    if (trigger.isUpdate) {
        if (triggerControlMap.get('checkOpportunities') != null &&  triggerControlMap.get('checkOpportunities')) AccountTriggerHandler.checkOpportunities(trigger.new, trigger.oldMap);
    }

}