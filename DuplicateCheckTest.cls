@isTest
private class DuplicateCheckTest {
	private static testMethod void leadDuplicateCheck() {
	    Company__c comp = new Company__c();
	    comp.Name = 'test';
	    comp.City__c = 'GZB';
	    comp.id__c = 'hdbfv';
	    insert comp;
	    
	    Visit__c vis = new Visit__c	();
        vis.Name = 'Text2016AS02';
        vis.Id__c = 'dhbch1udddfss';
        vis.company__c = comp.id;
        vis.PIs__c = 5;
        DateTime visitDate  = Datetime.newInstance(2016, 08, 14, 12, 30, 2);
        vis.Datetime__c = visitDate;
        insert vis;
	    
        lead ld = new lead();
        ld.lastname= 'test';
        ld.company = 'ccc';
        ld.City = 'GZB';
        ld.id__c = '459904fd3b302d156bbbc7ca6asdab62fc0';
        ld.status = 'working - contacted';
        ld.leadsource = 'LeadLab';
        insert ld;
        
        ApexPages.standardController controller = new ApexPages.standardController(comp);
        
        DuplicateCheck dupCheck = new DuplicateCheck(controller);
        
        ApexPages.currentPage().getParameters().put('companyId',comp.id);
        ApexPages.currentPage().getParameters().put('sObjId',ld.id);
        DuplicateCheck dupCheck1 = new DuplicateCheck();
        
        dupCheck1.mergeDuplicate();
        
        dupCheck1.selectedMode = 'Lead';
        dupCheck1.mergeDuplicate();
        dupCheck1.cancelMerge();
        system.assertEquals(1,dupCheck.dupLeadAccount.lstOfLead.size());
	}
	private static testMethod void accountDuplicateCheck(){
	    Company__c comp = new Company__c();
	    comp.Name = 'test';
	    comp.City__c = 'GZB';
	    comp.id__c = 'hdbfv';
	    insert comp;
	    
	    Visit__c vis = new Visit__c	();
        vis.Name = 'Text2016AS02';
        vis.Id__c = 'dhbch1udddfsds';
        vis.company__c = comp.id;
        vis.PIs__c = 5;
        DateTime visitDate  = Datetime.newInstance(2016, 08, 14, 12, 30, 2);
        vis.Datetime__c = visitDate;
        insert vis;
	    
	    account acc = new account();
	    acc.Name = 'test';
	    acc.BillingCity = 'GZB';
	    
	    insert acc;
	    ApexPages.standardController controller = new ApexPages.standardController(comp);
        
        DuplicateCheck dupCheck = new DuplicateCheck(controller);
        
        ApexPages.currentPage().getParameters().put('companyId',comp.id);
        ApexPages.currentPage().getParameters().put('sObjId',acc.id);
        DuplicateCheck dupCheck1 = new DuplicateCheck();
        
        dupCheck1.mergeDuplicate();
        
        dupCheck1.selectedMode = 'Account';
        dupCheck1.mergeDuplicate();
        dupCheck1.cancelMerge();
        system.assertEquals(1,dupCheck.dupLeadAccount.lstOfAcc.size());
	}
}