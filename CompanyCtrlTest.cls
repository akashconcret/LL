@IsTest
public class CompanyCtrlTest {
        @testSetup static void dataSetup(){
            
             Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
  
            User usr = new User(LastName = 'LIVESTON',
                                 FirstName='JASON',
                                 Alias = 'jliv',
                                 Email = 'jason.liveston92167@asdf.com',
                                 Username = 'jason.liveston92176@asdf.com',
                                 ProfileId = profileId.id,
                                 TimeZoneSidKey = 'GMT',
                                 LanguageLocaleKey = 'en_US',
                                 EmailEncodingKey = 'UTF-8',
                                 LocaleSidKey = 'en_US'
                                 );
                                 insert usr;
            
            campaign cam = new campaign();
            cam.name = 'test';
            insert cam;
            
            final Setting__c settings = new Setting__c(
            Name = Constants.CUSTOM_SETTING_NAME,
            EndpointURI__c = 'www.test.de',SelectedCampaign__c =cam.Id,StandardLeadUser__c = usr.id);
            insert settings;
            system.assertEquals(usr.id,Setting__c.getInstance(Constants.CUSTOM_SETTING_NAME).StandardLeadUser__c);
        }
   
    private static testMethod void testForMassAccountCreation(){
        Company__c companyForMassAccCreation = new Company__c(name='test',id__c='test4'); insert companyForMassAccCreation;
        Visit__c newvisit = new Visit__c();
        newvisit.Datetime__c = Datetime.now();
        newvisit.PIs__c = 5;
        newvisit.Company__c = companyForMassAccCreation.Id;
        insert newvisit;
        Company__c companyForMassAccCreation1 = new Company__c(name='test',id__c='test2'); insert companyForMassAccCreation1;
        
        
        ApexPages.StandardSetController ctrl = new ApexPages.StandardSetController([select id,Name from Company__c limit 10]);
        ctrl.setSelected([select id,Name from Company__c limit 10]);
        CompanyCtrl comp = new CompanyCtrl(ctrl);
        comp.createSobjects();
        comp.cancel();
        system.assertEquals(1,[select count() from Company__c]);
    }
    
    private static testMethod void testForMassleadCreation(){
        Company__c companyForMassAccCreation = new Company__c(name='test',id__c='test1'); insert companyForMassAccCreation;
        Visit__c newvisit = new Visit__c();
        newvisit.Datetime__c = Datetime.now();
        newvisit.PIs__c = 5;
        newvisit.Company__c = companyForMassAccCreation.Id;
        insert newvisit;
        Company__c companyForMassAccCreation1 = new Company__c(name='test',id__c='test2'); insert companyForMassAccCreation1;
        
        
        ApexPages.StandardSetController ctrl = new ApexPages.StandardSetController([select id,Name from Company__c limit 10]);
        ctrl.setSelected([select id,Name from Company__c limit 10]);
        MassLeadCtrl leadCtrl = new MassLeadCtrl(ctrl);
        leadCtrl.createMassLead();
        leadCtrl.cancel();
        system.assertEquals(1,[select count() from Company__c]);
    }
   
    private static testMethod void testForSingleAccountCreation(){
        Company__c companyForMassAccCreation = new Company__c(name='test',id__c='test2'); insert companyForMassAccCreation;
        Visit__c newvisit = new Visit__c();
        newvisit.Datetime__c = Datetime.now();
        newvisit.PIs__c = 5;
        newvisit.Company__c = companyForMassAccCreation.Id;
        insert newvisit;
        ApexPages.currentPage().getParameters().put('createSobject','account');
        ApexPages.currentPage().getParameters().put('id',companyForMassAccCreation.id);
        ApexPages.StandardSetController ctrl = new ApexPages.StandardSetController([select Id,Name From Company__c limit 1000]);
        CompanyCtrl comp = new CompanyCtrl(ctrl);
        comp.createSobjects();
        system.assertEquals(0,[select count() from Company__c]);
    }
    
    private static testMethod void testForSingleLeadCreation(){
        Company__c companyForMassAccCreation = new Company__c(name='test',id__c='test3'); insert companyForMassAccCreation;
        Visit__c newvisit = new Visit__c();
        newvisit.Datetime__c = Datetime.now();
        newvisit.PIs__c = 5;
        newvisit.Company__c = companyForMassAccCreation.Id;
        insert newvisit;
        ApexPages.currentPage().getParameters().put('id',companyForMassAccCreation.id);
        ApexPages.currentPage().getParameters().put('createSobject','lead');
        ApexPages.StandardSetController ctrl = new ApexPages.StandardSetController([select Id,Name From Company__c limit 1000]);
        CompanyCtrl comp = new CompanyCtrl(ctrl);
        comp.createSobjects();
        system.assertEquals(0,[select count() from Company__c]);
    }
    private static testMethod void testForNoVisits(){
        Company__c companyForMassAccCreation = new Company__c(name='test',id__c='test3'); insert companyForMassAccCreation;
        ApexPages.currentPage().getParameters().put('id',companyForMassAccCreation.id);
        ApexPages.currentPage().getParameters().put('createSobject','lead');
        ApexPages.StandardSetController ctrl = new ApexPages.StandardSetController([select Id,Name From Company__c limit 1000]);
        CompanyCtrl comp = new CompanyCtrl(ctrl);
        comp.createSobjects();
        system.assertEquals(1,[select count() from Company__c]);
        
        ApexPages.currentPage().getParameters().put('id',companyForMassAccCreation.id);
        ApexPages.currentPage().getParameters().put('createSobject','account');
        ApexPages.StandardSetController ctrl1 = new ApexPages.StandardSetController([select Id,Name From Company__c limit 1000]);
        CompanyCtrl comp1 = new CompanyCtrl(ctrl1);
        comp1.createSobjects();
        system.assertEquals(1,[select count() from Company__c]);
    }
}