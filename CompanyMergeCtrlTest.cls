@IsTest
public class CompanyMergeCtrlTest {

    @isTest
    private static void mergeControllerTestLead() {
        final Account acc = new Account(Name = 'test'); insert acc;
        final Lead lead = new Lead(LastName = 'test', Company = 'Test'); insert lead;
        final Company__c company = new Company__c(id__c = 'hdvcmmnau'); insert company;
        
        
        Visit__c newVisit = new Visit__c();
        newVisit.Name = 'test345';
        newVisit.Id__c = '77dhhdssddhjd673erf';
        newVisit.PIs__c = 7;
        newVisit.Datetime__c = system.now();
        newVisit.Company__c = company.id;
        insert newVisit;

        final MetaObject__c metaObj = new MetaObject__c();
        metaObj.Lead__c = lead.Id;
        insert metaObj;

        final ApexPages.StandardController stdCtrl = new ApexPages.StandardController(company);
        final CompanyMergeCtrl mergeCtrl = new CompanyMergeCtrl(stdCtrl);
        mergeCtrl.metaObj = metaObj;
        System.assert(mergeCtrl.doCancel() != null);


        mergeCtrl.selectedType = Lead.getSObjectType().getDescribe().getName();
        mergeCtrl.getAccountSelected();
        SYstem.assert(mergeCtrl.doMerge() != null);
    }

    @isTest
    private static void mergeControllerTestAccount() {
        final Account acc = new Account(Name = 'test'); insert acc;
        final Lead lead = new Lead(LastName = 'test', Company = 'Test'); insert lead;
        final Company__c company = new Company__c(id__c = 'dbdnjdhvvfd'); insert company;
        Visit__c newVisit = new Visit__c();
        newVisit.Name = 'test345';
        newVisit.Id__c = '77dhhdssddhrtjd673erf';
        newVisit.PIs__c = 7;
        newVisit.Datetime__c = system.now();
        newVisit.Company__c = company.id;
        insert newVisit;
        final MetaObject__c metaObj = new MetaObject__c();
        metaObj.Account__c = acc.Id;
        insert metaObj;

        final ApexPages.StandardController stdCtrl = new ApexPages.StandardController(company);
        final CompanyMergeCtrl mergeCtrl = new CompanyMergeCtrl(stdCtrl);
        mergeCtrl.metaObj = metaObj;
        System.assert(mergeCtrl.doCancel() != null);

        mergeCtrl.selectedType = Account.getSObjectType().getDescribe().getName();
        mergeCtrl.getLeadSelected();
        SYstem.assert(mergeCtrl.doMerge() != null);
    }

}