@isTest
private class CompanyListCtrlTest {
    
	private static testMethod void testCompanyList() {
        CompanyListCtrl ctrl =new CompanyListCtrl();
        system.assertEquals(false, ctrl.isLightningExperience);
        
	}
	

}