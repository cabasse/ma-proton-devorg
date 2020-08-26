trigger OpportunityTrigger on Opportunity (after insert, after update) {

    map<string, boolean> triggerControlMap = new map<string, boolean>();

    for (Trigger_Controls__mdt tControl : [
        select Method_Name__c, Is_Enabled__c
        from Trigger_Controls__mdt 
        where Object_Name__c='Opportunity']) {
            triggerControlMap.put(tControl.Method_Name__c, tControl.Is_Enabled__c);
        }


    if (Trigger.isUpdate && Trigger.isAfter) {
        if ( triggerControlMap.get('createRenewalOpps') ) OpportunityTriggerHandler.createRenewalOpps(Trigger.newMap, Trigger.oldMap);

    }

}