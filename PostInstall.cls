//Requires without sharing in order to work.
global class PostInstall implements InstallHandler  {

    // private final static Logger.IService log = 
    //     Logger.getPrettyDefault(PostInstall.class);

    // private final RestClient.Service restService;
    // private final Setting__c settings;
    // private final SfQueueHandler lwQueueHandler;

    global PostInstall() {
        // this(new RestClient(), Setting__c.getInstance(Constants.CUSTOM_SETTING_NAME), new LeadWebQueueHandler());
    }
    
//     @future
//     global static void ldWebQueueHandler(){
//         SfQueueHandler lwQueueHandler = new LeadWebQueueHandler();
// 		lwQueueHandler.checkAndCreateSfQueues();
//     }
    
    global void onInstall(InstallContext context) {
        SfQueueHandler lwQueueHandler = new LeadWebQueueHandler();
		lwQueueHandler.checkAndCreateSfQueues();
		
// 		ldWebQueueHandler();
        // System.enqueueJob(new ConfigureQueue());
        
        // Only create and insert custom setting if it is a new installation
        // if (context == null  || context.previousVersion() == null) {
        //     final Setting__c settings = new CredentialsManager().getSettings();
        //     DMLManager.insertAsSystem(settings);
        // }
        // createObjects();
        //initTenantCreation();
        //initiateSchedulers();
    }
    
    // public class ConfigureQueue implements Queueable {
    //     public void execute(QueueableContext context) {

    //         final Setting__c settings = Setting__c.getInstance(Constants.CUSTOM_SETTING_NAME);
    //         final Group queue = [Select Id From Group Where Name =: Constants.CompanyQueue And Type =: 'Queue'];
    //         settings.SelectedQueue__c = queue.Id;
    //         DMLManager.updateAsSystem(settings);

    //     }
    // }

    // public PostInstall(RestClient.Service restService, Setting__c settings, SfQueueHandler lwQueueHandler) {
    //     this.restService = restService;
    //     this.settings = settings;
    //     this.lwQueueHandler = lwQueueHandler;
    // }

    // public void onInstall(InstallContext context) {
    //     // Only create and insert custom setting if it is a new installation
    //     // if (context == null  || context.previousVersion() == null) {
    //     //     final Setting__c settings = new CredentialsManager().getSettings();
    //     //     DMLManager.insertAsSystem(settings);
    //     // }
    //     // createObjects();
    //     //initTenantCreation();
    //     //initiateSchedulers();
    // }

    // @Future
    // public static void createObjects() {
    //     new PostInstall().createRequiredObjects();
    // }

    // @Future(callout = true)
    // public static void initTenantCreation() {
    //     new PostInstall().createTenant();
    // }

    // public static void initiateSchedulers() {
    //     FetchLegalFormsScheduler.schedule();
    //     new FetchVisitsScheduler().scheduleDaily();
    // }

    // public void createTenant() {

    //     log.debug('Creating tenant');

    //     final Dto.LoginInformation logInfoDto = restService.createTenant();
    //     log.debug('logInfoDto: ', logInfoDto);
    //     final CredentialsManager credentialsManager = new CredentialsManager();
    //     credentialsManager.setSettings(logInfoDto.publicCustnum, logInfoDto.token);

    //     DMLManager.updateAsSystem(credentialsManager.getSettings());
    // }

    // public void createRequiredObjects() {

    //     log.debug('Creating required objects');

    //     lwQueueHandler.checkAndCreateSfQueues();

    //     System.enqueueJob(new ConfigureQueue());
    // }

}