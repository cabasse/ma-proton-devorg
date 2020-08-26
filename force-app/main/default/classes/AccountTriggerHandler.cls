public with sharing class AccountTriggerHandler {
    public static void createOpportunities(list<account> accounts) {

        list<opportunity> newRelatedOpps = new list<opportunity>();

        for (account a : accounts) {

            opportunity resOpp = new opportunity(
                name = a.Name + ' Residential Opp', 
                AccountId = a.Id, 
                CloseDate = Date.Today().AddMonths(1),
                StageName = 'Prospecting'
                );

            opportunity commOpp  = new opportunity(
                name = a.Name + ' Commercial Opp',
                AccountId = a.Id,
                CloseDate = Date.Today().AddMonths(1),
                StageName = 'Prospecting'
            );
            
            newRelatedOpps.add(resOpp);
            newRelatedOpps.add(commOpp);
        }

        insert newRelatedOpps;
    }

    public static void checkOpportunities(list<account> accounts, map<id, account> oldAccountMap) {

        list<id> prospectAccountIds = new list<id>();
        map<id, list<opportunity>> relatedOppMap = new map<id, list<opportunity>>();

        list<id> accId_ResOppsToRecreate = new list<id>();
        list<id> accId_CommOppsToRecreate = new list<id>();


        //build list of prospect account Ids
        for (account a: accounts) {
            if (a.Type == 'Prospect') prospectAccountIds.add(a.Id);
        }

        
        // query for related opportunities, build a map with related accountID as key, associated with list of found opps
        for (opportunity o : [select id, accountId, Name from opportunity where accountId in: prospectAccountIds]) {

            if (relatedOppMap.get(o.accountId) == null) {
                list<opportunity> opps = new opportunity[] { o };
                relatedOppMap.put(o.accountId, opps);
            } else {
                List<Opportunity> opps = relatedOppMap.get(o.AccountId);
                opps.add(o);
                relatedOppMap.put(o.accountId, opps);
            }
        }

        //iterate over maps, check that an opp exists of each account type

        for (id accountId : prospectAccountIds) {
            
            if (! lookForRelatedOpp('Residential Opp', relatedOppMap.get(accountId))) {
                accId_ResOppsToRecreate.add(accountId);
            }
            if (! lookForRelatedOpp('Commercial Opp', relatedOppMap.get(accountId))) {
                accId_CommOppsToRecreate.add(accountId);
            }          
        }

    }

    public static boolean lookForRelatedOpp(string oppName, list<opportunity> relatedOppList) {

        boolean oppFound = false;

        for (opportunity o : relatedOppList) {
            if (o.Name.toLowerCase().contains(oppName.toLowerCase())) oppFound = true;
        }

        return oppFound;

    }

}