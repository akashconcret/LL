public with sharing class Fetcher implements Database.Batchable<CalloutChunk>,
    Database.AllowsCallouts, Database.Stateful {
	
   
    private final Logger.IService log = Logger.getDefault(Fetcher.class);
    
    final Mode mode = new Mode();
    // SettingsController settingsCtrl = new SettingsController();
    // boolean fetchVisits;
    boolean sendEmailToUser;
    public Setting__c settings = Setting__c.getInstance(Constants.CUSTOM_SETTING_NAME);
    Boolean isManualBatch = false;
    
    public enum JobType {
        GetCompanies, GetLegalForms
    }

    private final Map<JobType, Type> jobMap = new Map<JobType, Type> {
        JobType.GetCompanies => Fetcher.Company.class
    };


    private final Integer chunkSize = !String.isBlank(Label.ChunkSize) && Label.ChunkSize.isNumeric()?Integer.valueof(Label.ChunkSize):1;
    private final IRange range;
    private final JobType type;
    
    
    private final RestClient.Service restService;
    private final CalloutChunkGenerator chunkGenerator = new CalloutChunkFactory();

    public Fetcher(Date start, Date finish, Boolean isManualFetch) {
        this(new DateRange(start, finish),isManualFetch);
        
    }

    public Fetcher(IRange range,Boolean isManualBatch) {
        this(range, new RestClient(),isManualBatch);
    }

    public Fetcher(IRange dateRange, RestClient.Service restService,Boolean  isManualBatchActive) {
        this.range = dateRange;
        this.restService = restService;
        this.type = JobType.GetCompanies;
        
        if(settings!=null && settings.AutoRetreivalEmailNotificationDate__c==null){
            settings.AutoRetreivalEmailNotificationDate__c = system.Today();
        }
        log.debug('Range: ' + this.range);
        isManualBatch = isManualBatchActive;
        Database.executeBatch(this,1);
        
    }
    
    
    public Iterable<CalloutChunk> start(Database.BatchableContext context) {
        //maintainVisitIds = new Fetcher.MaintainState(null);
        Dto.Customer customer;
        sendEmailToUser = true;
        String plainText;
        // inside try block checking for pls Limit.
        try{
    		RestClient.Service restService2 = new RestClient();
    		customer = restService2.getCustomer();
    	}catch(Exception ee){}
    	//If pls Limit reaches at max, Noitify user and Stop batch class execution
        if(customer != null && customer.pisCurrent > customer.pisLimit && !isManualBatch){
            sendEmailToUser = false;
            notifyUserWhenPlsLimitExceeds();
            return new List<Fetcher.CalloutChunk>();
        }else if(isAllMandatoryFieldsConfigured() ){
            //Run Batch Class If All Required Fields are Configured and Pis Limit Does't exceeds.
            final List<CalloutChunk> chunks = new List<CalloutChunk>();
            Integer numberOfVisits = restService.getCompaniesCount(range.getStart(), range.getFinish());
            
            system.debug('numberOfVisits :: '+numberOfVisits);
            plainText = String.valueof(Label.ManualFetchUser).replace('User',UserInfo.getName())+'\n'+Label.NoVisitsAvailableByManualFetch;
            if(numberOfVisits!=null && numberOfVisits<1 && isManualBatch){
                //this email will be sent , If No Visits fetched for a given time span.
                sendEmailToUser = false;
                DMLManager.sendEmail(Label.LeadLabVisitStatus,plainText,UserInfo.getUserEmail());
            }
           
            return chunkGenerator.createChunksFromCompanyVisitsCount(numberOfVisits, chunkSize, range, type);
        }else{
            //Send Mail To User every time Manual Fetch is executed If Mandatory Fields Are Not  configured.
            // Send Mail To User once in a day if automatic leadlab visit Fetch is executed .
            sendEmailToUser = false;
            if(mode.account && ((isManualBatch) || (settings!=null && settings.AutoRetreivalEmailNotificationDate__c<=system.today()))){
                DMLManager.sendEmail(Label.user_notification_subject,Label.user_notification_text,UserInfo.getUserEmail());
                //update the below field to next date if Email sent once in case of auto retrieval.
                settings.AutoRetreivalEmailNotificationDate__c = system.Today().addDays(1);
            }else if(mode.lead && ((isManualBatch) || (settings!=null && settings.AutoRetreivalEmailNotificationDate__c<=system.today()))){
                plainText = String.valueof(Label.user_notification_text).replace('Accounts','Leads');
                DMLManager.sendEmail(Label.user_notification_subject,plainText,UserInfo.getUserEmail());
                //update the below field to next date if Email sent once in case of auto retrieval.
                settings.AutoRetreivalEmailNotificationDate__c = system.Today().addDays(1);
            }
            return new List<Fetcher.CalloutChunk>();
        }
    }
    // This method sends Email to user when Pls limit reached at max.
    // This method also ensure that message must be sent once a month to user.
    public void notifyUserWhenPlsLimitExceeds(){
        Integer numberOfDays = Date.daysInMonth(system.today().year(), system.today().month());
        Date lastDayOfMonth = Date.newInstance(system.today().year(), system.today().month(), numberOfDays);
        if(settings !=null && (settings.PLS_LIMIT_EXCEED__c == null || settings.PLS_LIMIT_EXCEED__c < system.today())){
            String plainText = String.valueof(Label.ManualFetchUser).replace('User',UserInfo.getName())+'\n'+Label.Pls_Limit_Notification_Plain_Text;
            DMLManager.sendEmail(Label.PIS_LIMIT_EXCEED,plainText,UserInfo.getUserEmail());
            settings.PLS_LIMIT_EXCEED__c = lastDayOfMonth;
        }
    }
    public void execute(Database.BatchableContext context, List<CalloutChunk> chunks) {
        //maintainVisitIds.lstInteger.add(1);
        system.debug('chunks :: '+chunks.size());
        if(chunks.isEmpty()) return;

        final Map<CalloutChunk, IRunnable> chunkRunners = new Map<CalloutChunk, IRunnable>();
        for(CalloutChunk chunk : chunks)
            chunkRunners.put(chunk, getRunnerInstance(chunk));

        for(CalloutChunk chunk : chunks)
            chunkRunners.get(chunk).run(chunk);

        for(CalloutChunk chunk : chunks){
            
            if((settings.SelectedMode__c!=null && String.valueof(settings.SelectedMode__c).equals('Account') && DMLManager.isScheduledVisitFetchAllowed(new Account())) || mode.company){
                chunkRunners.get(chunk).finish();
            }else if((settings.SelectedMode__c!=null && String.valueof(settings.SelectedMode__c).equals('Lead') && DMLManager.isScheduledVisitFetchAllowed(new Lead())) || mode.company){
                chunkRunners.get(chunk).finish();
            }
        }
    }

    private IRunnable getRunnerInstance(CalloutChunk chunk) {
        return (IRunnable) this.jobMap.get(chunk.jobType).newInstance();
    }

    public void finish(Database.BatchableContext context) {
        AsyncApexJob a = [SELECT Id, Status,JobType,ExtendedStatus,ApexClass.Name, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, CreatedBy.FirstName, CreatedBy.LastName FROM AsyncApexJob WHERE Id = :context.getJobId()];
        String plainText = String.valueof(Label.ManualFetchUser).replace('User',UserInfo.getName())+'\n'+Label.ManualFetchStaus;
        // system.debug(LoggingLevel.INFO,'setCompIds : '+setCompIds.size());
        // system.debug(LoggingLevel.INFO,' setCompIds : '+setCompIds);
        settings.LastFetchDate__c = Datetime.now();
        if(sendEmailToUser && isManualBatch){
            //sending email if manual fetch will be successfull.
            DMLManager.sendEmail(Label.Manual_Fetch_Subject,plainText,UserInfo.getUserEmail());
        }
        if(settings!=null && settings.getSobjectType().getDescribe().isupdateable()){
            update settings;
        }
        if(a!=null && a.NumberOfErrors>0){
            DMLManager.createErrorLog(a);
        }
    }
    public boolean isAllMandatoryFieldsConfigured(){
        boolean allowFetch = false;
        if((settings.SelectedMode__c!=null && String.valueof(settings.SelectedMode__c).equals('Account') && DMLManager.isScheduledVisitFetchAllowed(new Account())) || mode.company){
             allowFetch = true;
        }else if((settings.SelectedMode__c!=null && String.valueof(settings.SelectedMode__c).equals('Lead') && DMLManager.isScheduledVisitFetchAllowed(new Lead())) || mode.company){
             allowFetch = true;
        }
        return allowFetch;
    }
    public interface IRunnable {
        void run(CalloutChunk chunk);
        void finish();
    }

    public class Company implements IRunnable {

        private final Logger.IService log = Logger.getPrettyDefault(Company.class);

        private final List<Dto.Company> companies = new List<Dto.Company>();

        private final RestClient.Service restService;
        private final Manager.Service management;

        public Company() {
            this(new RestClient(), new Manager());
        } 

        public Company(RestClient.Service restService, Manager.Service management) {
            this.restService = restService;
            this.management = management;
        }

        public void run(CalloutChunk chunk) {

            log.info('Chunk info: ', chunk);
            companies.addAll(restService.getCompanies(chunk.startTime, chunk.finishTime,
                             chunk.start, chunk.finish));
        }

        public void finish() {
            log.fine('On finish', this.companies);
            this.management.persistCompanies(this.companies);
        }
    }


    public interface IChunk {
        String getStartTime();
        String getFinishTime();
        Integer getStart();
        Integer getFinish();
    }

    public class CalloutChunk implements IChunk {
        private final JobType jobType;

        private final String startTime;
        private final String finishTime;

        private final Integer start;
        private final Integer finish;

        public CalloutChunk(JobType jobType, String startTime, String finishTime, Integer start,
                            Integer finish) {

            this.jobType = jobType;
            this.startTime = startTime; this.finishTime = finishTime;
            this.start = start; this.finish = finish;
        }

        public String getStartTime() {
            return this.startTime;
        }
        public String getFinishTime() {
            return this.finishTime;
        }
        public Integer getStart() {
            return this.start;
        }
        public Integer getFinish() {
            return this.finish;
        }


        public Boolean equals(Object compare) {
            if (!(compare instanceof CalloutChunk)) {
                return false;
            }

            CalloutChunk chunkCompare = (CalloutChunk) compare;
            return jobType == chunkCompare.jobType &&
                    startTime == chunkCompare.startTime &&
                    finishTime == chunkCompare.finishTime &&
                    start == chunkCompare.start &&
                    finish == chunkCompare.finish;
        }

    }

    public interface IRange {
        String getStart();
        String getFinish();
    }

    public class DateRange implements IRange {
        private final String start;
        private final String finish;

        public DateRange(Date start, Date finish) {
            final Time midnight = Time.newInstance(0, 0, 0, 0);

            this.start = unixTime(Datetime.newInstance(start, midnight)); 
            this.finish = unixTime(Datetime.newInstance(finish.addDays(1), midnight));
          
        }
        public DateRange(String start, String finish) {
            this.start = start; this.finish = finish;
        }

        public String getStart() { return this.start; }

        public String getFinish() { return this.finish; }

        private String unixTime(Date d) {
            return String.valueOf(Datetime.newInstance(d.year(), d.month(), d.day()).getTime() / 1000);
        }

        private String unixTime(Datetime dt) {
            final Integer offset = UserInfo.getTimeZone().getOffset(Date.today());
            return String.valueOf((dt.getTime() + offset) / 1000);
        }
    }
}