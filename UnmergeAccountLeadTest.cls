@isTest
private class UnmergeAccountLeadTest {
	private static testMethod void accountMergeTest() {
	    Account acc = new Account();
	    acc.name = 'Test';
	    acc.Id__c = 'dhbch1dd4dfssfss';
	    acc.WMLL__Unmerge_Available__c = true;
	    insert acc;
	    
	    Visit__c vis = new Visit__c	();
        vis.Name = 'Text2016AS0244523';
        vis.Id__c = 'dhbch1udfdd4dfssfss';
        vis.Account__c= acc.id;
        vis.PIs__c = 5;
        DateTime visitDate  = Datetime.newInstance(2017, 04, 30, 12, 30, 2);
        vis.Datetime__c = visitDate;
        insert vis;
	    
	    Apexpages.currentpage().getparameters().Put('Id',acc.id);
	    UnmergeAccountLead comp = new UnmergeAccountLead();
	    comp.backToSobject();
	    system.assertEquals(true,comp.doMerge()!=null);
	    system.assertEquals(true,[select id__c from Account where Id =:acc.id].id__c==null);
	    
	    delete acc;
	}
	private static testMethod void leadMergeTest() {
	    lead ld = new lead();
	    ld.LastName = 'Test';
	    ld.company = 'Test';
	    ld.Id__c = 'dhbch1dd4';
	    ld.WMLL__Unmerge_Available__c = true;
	    insert ld;
	    
	    Visit__c vis = new Visit__c	();
        vis.Name = 'Text2016AS0244523';
        vis.Id__c = 'dhbch1udfdd4dfssfss';
        vis.Lead__c= ld.id;
        vis.PIs__c = 5;
        DateTime visitDate  = Datetime.newInstance(2017, 04, 30, 12, 30, 2);
        vis.Datetime__c = visitDate;
        insert vis;
	    
	    Apexpages.currentpage().getparameters().Put('Id',ld.id);
	    UnmergeAccountLead comp = new UnmergeAccountLead();
	    system.assertEquals(true,comp.doMerge()!=null);
	    system.assertEquals(true,[select id__c from Lead where Id =:ld.id].id__c==null);
	}
}