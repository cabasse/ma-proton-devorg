@isTest
public class OpportunityTriggerTest {
    

    @TestSetup
    static void makeData(){
        
        //could move this into a separate TestDataFactory class to be reused by additional tests

        list<String> oppStageNamePicklistVals = new list<String>();

        for (Schema.PicklistEntry ple : Opportunity.StageName.getDescribe().getPicklistValues()) {
            oppStageNamePicklistVals.add(ple.getValue());
        }

        Account a = new Account(Name='ApexTest Acct', Phone='404-404-1234');
        insert a;

        Opportunity o = new Opportunity(name='ApexTest Opp', AccountId = a.Id, CloseDate = Date.today(), StageName=oppStageNamePicklistVals[0]);
        insert o;

        id pricebookID = Test.getStandardPricebookId();

        Product2 prod1 = new Product2(name='ApexTest Prod 1', isActive=true);
        Product2 prod2 = new Product2(name='ApexTest Prod 2', isActive=true);
        Product2 prod3 = new Product2(name='ApexTest Prod 3', isActive=true);
        

        insert new Product2[] { prod1, prod2, prod3 };

        PricebookEntry pbe1 = new PricebookEntry(pricebook2id= pricebookID, product2id = prod1.id, unitPrice=100, isActive=true);
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id= pricebookID, product2id = prod2.id, unitPrice=50, isActive=true);
        PricebookEntry pbe3 = new PricebookEntry(pricebook2id= pricebookID, product2id = prod3.id, unitPrice=300, isActive=true);

        insert new PricebookEntry[] { pbe1, pbe2, pbe3 }; 


        OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId = o.Id, Quantity=1, PricebookEntryId = pbe1.Id, Product2Id = prod1.Id, UnitPrice=100, ServiceDate=Date.Today());
        OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId = o.Id, Quantity=3, PricebookEntryId = pbe2.Id, Product2Id = prod2.Id, UnitPrice=200, ServiceDate=Date.Today());
        OpportunityLineItem oli3 = new OpportunityLineItem(OpportunityId = o.Id, Quantity=5, PricebookEntryId = pbe3.Id, Product2Id = prod3.Id, UnitPrice=300, ServiceDate=Date.Today());

        insert new OpportunityLineItem[] { oli1, oli2, oli3 };
        
    }

    @isTest
    public static void testAutoCreateRenewalOpps() {

        Opportunity oppToBeCloned = [select id from opportunity where name='ApexTest Opp'];

        list<String> oppStageNamePicklistVals = new list<String>();

        for (Schema.PicklistEntry ple : Opportunity.StageName.getDescribe().getPicklistValues()) {
            if (ple.getValue() !='Closed Lost') oppStageNamePicklistVals.add(ple.getValue());
        }

        Test.startTest();

        for (Integer i = 1; i < oppStageNamePicklistVals.size(); i++) {
            //moving the opp through each stage, as can sometimes be required, would otherwise never put an update inside a loop!
            oppToBeCloned.StageName = oppStageNamePicklistVals[i];
            system.debug(oppStageNamePicklistVals[i]);
            update oppToBeCloned;

        }

        Test.StopTest();

        List<Id> bothOppIds = new List<Id>();
        for (Opportunity o : [select id from opportunity where name='ApexTest Opp']) {
            bothOppIds.add(o.Id);
        }

        List<OpportunityLineItem> allOppProducts = [select id from OpportunityLineItem where OpportunityId in: bothOppIds];

        System.AssertEquals(bothOppIds.size(), 2);
        System.AssertEquals(allOppProducts.size(), 6);

    }



}
