public with sharing class OpportunityTriggerHandler {
    
    public static void CreateRenewalOpps(Map<Id, Opportunity> oppMap, Map<Id, Opportunity> pvOppMap) {
 
        list<String> oppStageNamePicklistVals = new list<String>();

        list<id> closedOppIds = new list<id>();
        map<id, list<OpportunityLineItem>> oProdByOppMap = new map<id, list<OpportunityLineItem>>();


        list<Opportunity> newOpportunities = new List<Opportunity>();
        list<OpportunityLineItem> newOppLineItems = new list<OpportunityLineItem>();

        //build a list of ordered stageName values so we know which is first
        for (Schema.PicklistEntry ple : Opportunity.StageName.getDescribe().getPicklistValues()) {
            oppStageNamePicklistVals.add(ple.getValue());
        }

        //get list of closed opp Ids in context
        for (Opportunity opp : oppMap.values()) {

            if (opp.StageName=='Closed Won' && pvOppMap.get(opp.Id).StageName != 'Closed Won') {
                closedOppIds.add(opp.Id);
            }
        }

        //grab all existing Opp Products related to just closed opps, and put into a map with opp id as the key
        for (OpportunityLineItem oli : [Select Id, OpportunityId, 
                    Product2Id, ProductCode, Name, Quantity, UnitPrice 
                    FROM OpportunityLineItem where OpportunityId in: closedOppIds]) 
        {

            if (oProdByOppMap.get(oli.OpportunityId) == null) {
                List<OpportunityLineItem> opList = new OpportunityLineItem[] { oli };
                oProdByOppMap.put(oli.OpportunityId, opList);
            } else {
                List<OpportunityLineItem> opList = oProdByOppMap.get(oli.OpportunityId);
                opList.add(oli);
                oProdByOppMap.put(oli.OpportunityId, opList);
            }
        }

        //create the duplicate opps (first)
        for (Id oppId : closedOppIds) {

            Opportunity opp = oppMap.get(oppId);
            Opportunity clone = opp.clone(false);

            clone.CloseDate = opp.CloseDate.addYears(1);
            clone.StageName = oppStageNamePicklistVals[0];
            clone.Type = 'Renewal';
            newOpportunities.add(clone);

        }

        insert newOpportunities;

        //iterate over (ordered) list of inserted new opps, querying the original list of products from the same array element of original opp ids
        for (Integer i = 0; i < newOpportunities.size(); i++) {
            
            id origOppId = closedOppIds[i];

            list<OpportunityLineItem> oProductsToClone = oProdByOppMap.get(origOppId);
            if (oProductsToClone != null) {
                for (OpportunityLineItem oProd : oProductsToClone) {
                    OpportunityLineItem clonedOppProd = oProd.clone(false);
                    clonedOppProd.Discount = 0;
                    clonedOppProd.OpportunityId = newOpportunities[i].Id;
                    newOppLineItems.add(clonedOppProd);
                }
            }
        }

        insert newOppLineItems;

    }
}
