@IsTest
private with sharing class loli_utils_PlatformManagerTest {

    private static loli_utils_IPlatform platformService = new loli_utils_PlatformManager();

    private static Boolean isBatchCalled = false;

    //----------------------------- Classes/Interfaces ----------------------------------//

    //---- BatchStubTestCallback ----//

    private class BatchCallback implements loli_utils_BatchStubCallback.BatchStubTestCallback {

        public void onExecute(List<Integer> scope) {
            isBatchCalled = true;
        }

        public void onFinish() {

        }

    }

    //----------------------------- newInstance ----------------------------------//

    //---- Happy Path ----//

    private static TestMethod void newInstance_Existing() {

        Http newHttp = (Http) platformService.newInstance('Http');
        System.assert(newHttp != null);

    }

    private static TestMethod void newInstance_NotExisting() {

        Object newInstance = platformService.newInstance('DoesNotExist');
        System.assert(newInstance == null);

    }

    private static TestMethod void newInstance_PrimitiveType() {

        Integer newInteger = (Integer) platformService.newInstance('Integer');
        System.assert(newInteger == null);

    }

    //----------------------------- executeBatch ----------------------------------//

    //---- Happy Path ----//

    private static TestMethod void executeBatch() {
        loli_utils_BatchStubCallback.BatchStubTestCallback callback = new BatchCallback();
        Database.Batchable<Integer> testBatch = new loli_utils_BatchStubCallback(new List<Integer>{1, 2, 3, 4, 5, 6}, callback);

        Test.startTest();
        Id batchJobId = platformService.executeBatch(testBatch, 200);
        System.assert(batchJobId != null);
        Test.stopTest();

        System.assert(isBatchCalled);
    }

    //----------------------------- schedule ----------------------------------//

    //---- Happy Path ----//

    private static TestMethod void schedule() {
        Schedulable testSchedule = new loli_utils_ScheduleStub();
        String name = 'testScheduler';
        String croneDefinition = '0 0 * * * ? *';

        Test.startTest();
        Id scheduleId = platformService.schedule(name, croneDefinition, testSchedule);
        Test.stopTest();
        System.assert(scheduleId != null);
    }

    //----------------------------- abortJob ----------------------------------//

    //---- Happy Path ----//

    private static TestMethod void abortJob() {
        Schedulable testSchedule = new loli_utils_ScheduleStub();
        String name = 'testScheduler';
        String croneDefinition = '0 0 * * * ? *';

        Test.startTest();
        Id scheduledId = platformService.schedule(name, croneDefinition, testSchedule);
        platformService.abortJob(scheduledId);
        Test.stopTest();
        System.assertEquals(0, [SELECT Count() FROM CronTrigger where cronjobdetail.Name =:name]);
    }

    //----------------------------- query ----------------------------------//

    //---- Happy Path ----//

    private static TestMethod void query() {
        Account testAccount = new Account(Name = 'logicline');
        insert testAccount;
        String queryString = 'SELECT Id FROM Account WHERE Id = \'' + testAccount.Id + '\'';

        List<Account> accountList = platformService.query(queryString);

        System.assert(accountList != null);
        System.assertEquals(1, accountList.size());
    }
}