@isTest
private class VisitListCtrlTest {
   private static testMethod void testVisitList() {
        VisitListCtrl ctrl =new VisitListCtrl();
        // pagereference  ref = ctrl.ListViewURL();
        system.assertEquals(false, ctrl.isLightningExperience);
        
	}
}