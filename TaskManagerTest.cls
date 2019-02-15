@IsTest
public class TaskManagerTest {

    @isTest
    private static void createTaskTest() {
        prepare();
        final Account acc = new Account(Name = 'test');
        insert acc;

        final Visit__c visit = new Visit__c(
            Account__c = acc.Id,
            Datetime__c = Datetime.now());
        System.assert(new TaskManager().createTask(new list<Visit__c>{visit}) != null);
    }

    @isTest
    private static void createTaskForBatchTest() {
        prepare();
        System.assert(new TaskManager().createTaskForMatchForBatch(
                          new Visit__c(Datetime__c = Datetime.now()), new Account()) != null);
    }

    @isTest
    private static void writeTasksBatchTest() {
        prepare();
        final TaskManager manager = new TaskManager();
        System.assert(manager.writeTasksBatch());
    }

    private static void prepare() {
        final Setting__c settings = new Setting__c();
        settings.Name  = Constants.CUSTOM_SETTING_NAME;
        settings.EndpointURI__c = 'www.test.de';
        settings.TimeUntilDuedate__c = 1;
        insert settings;
        System.assertEquals('www.test.de',settings.EndpointURI__c);
    }
}