public with sharing class SettingsController {

    private final Logger.IService log = Logger.getDefault(SettingsController.class);

    private final SelectOption SELECT_NONE = new SelectOption('', '');

    public Boolean fetchJobExists {get; private set;}
    public Boolean userPermission{get;set;}
    public Map<String,String> modeSettingsMap;
    public Date startDateToDeleteVisit{get;set;}
    public Date endDateToDeleteVisit{get;set;}
    // using this map to show the exact same string as available in PickList on Set Up Page.
    public Map<String, String> limits{get;set;}
    public Map<String, String> RetrievalPeriodMap{get;set;}
    
    public final Mode currentMode {get; private set;}
    public final Setting__c settings{get;set;}
    public String selectedLeadStatus{get;set;}
    private CredentialsManager credentialsManager = new CredentialsManager();

    public final List<SelectOption> leadSourceOptions = new List<SelectOption>();
    public final List<SelectOption> leadStatusOptions {get;set;}
    public final List<SelectOption> campaignOptions = new List<SelectOption>();
    public final List<SelectOption> processingOptions = new List<SelectOption>();
    public final List<SelectOption> retrievalPeriods = new List<SelectOption>();
    public final List<SelectOption> visitLimits = new List<SelectOption>();
    public  String selectedQueueLabel{get;set;}
    public Map<Id,User> userMap {get;set;}
    public String companyStandardUser{get;set;}
    public String LeadStandardUser{get;set;}
    public String AccountStandardUser{get;set;}
    public String successInformation{get;set;} 
    public String setUPSuccessMessage{get;set;} 
    public String errorInformation{get;set;} 
    
    public List<SelectOption> lstOfCampaign{get;set;}
    
    //Combining CustomMandatoryFieldConfigController class ....
    private final SfUtilsLib.IFlsService flsService = SfUtilsLib.getFlsService();

    public List<ObjectForParsing> allData {get; set;}
    public Boolean isMandatoryFieldExists {get; set;}
    public Boolean isCustomMandatoryFieldsHaveDefaultValues;
    public Boolean editMode {get; set;}
    public String oldSystemMode;
    
    public MetaObject__c visitDeleteStartDate{get;set;}
    public MetaObject__c visitDeleteEndDate{get;set;}
    
    public MetaObject__c visitFetchStartDate{get;set;}
    public MetaObject__c visitFetchEndDate{get;set;}
    
    public Boolean leadMapping { get {
            return settings.EnableLeadMapping__c;
        } set {
            settings.EnableLeadMapping__c = value;
        }
    }
    public String selectedQueue { get {
            return settings.SelectedQueue__c;
        } set {
            settings.SelectedQueue__c = value;
            leadwebGroup = getApplicationQueue();
        }
    }
    public String selectedMode {get {
            return currentMode.getMode();
        } set {
            currentMode.setMode(value);
        }
    }

    public Boolean connectionNeeded { get {
        return settings == null || String.isEmpty(settings.PublicCustomNumber__c);
    } private set; }

    private Boolean connectionStarted = false;

    public Boolean getConnectionStarted() { 
        return this.connectionStarted; 
    }

    public Date fromDate {get; set;}
    public Date toDate {get; set;}

    public List<SelectOption> queueOptions {get; private set;}
    public List<SelectOption> leadModeOptions {get; private set;}

    public List<SelectOption> modeSettings {get; set;}
    public String selectedVisitLimit {get; set;}

    public String selectedProcessing {get; set;}
    public String selectedLeadSource {get; set;}

    public List<String> trackingPixelCode {get; set;}
    public String trackingPixelCode2 {get; set;}
    public List<String> optOutCode {get; set;}
    public String optOutCode2DE {get; set;}
    public String optOutCode2EN {get; set;}
    public Boolean standardUserIsAccountOwner {get; set;}
    public Boolean autoTaskPerAccountAssignment {get; set;}

    public Boolean enablePoller {get; set;}

    public String leadName {get; set;}
    public String selectedCampaign {get; set;}

    public String selectedCompanyUser {get; set;}
    public List<SelectOption> companyUserOptions {get; set;}
    public String selectedLeadUser {get; set;}
    public List<SelectOption> leadUserOptions {get; set;}

    public Visit__c standardTaskUser {get; set;}
    public Visit__c selectCompanyUser {get; set;}
    public Visit__c selectLeadUser {get; set;}

    public String selectedRetrievalPeriod {get; set;}
    public Boolean retrievalEnable {get; set {
            retrievalEnable = value;

            if(retrievalEnable && String.isEmpty(selectedRetrievalPeriod))
                selectedRetrievalPeriod = retrievalPeriods.get(retrievalPeriods.size() - 1).getValue();
        }
    }

    private final String LEAD_WEB_GROUP = 'Leadweb Group';


    public Dto.Customer customer { get; set; }

    public Group leadWebGroup {get; set;}

    public Boolean mandatoryFieldsConfigured {get; set;}

    // public Boolean isSearchPhrasesEnabled { get {
    //         return customer.searchPhrases;
    //     } set;
    // }

    // public Boolean isReferrersEnabled { get {
    //         return customer.referrers;
    //     } set;
    // }

    public Boolean isAccountActive { get {
            return customer.enabled;
        } set;
    }

    public Boolean isPixelCodeActive { get {
            return customer.pisCurrent != null && customer.pisCurrent > 2 ? true : false;
        } set;
    }

    // public Boolean isPagesEnabled { get {
    //         return customer.enabled;
    //     } set;
    // }

    // public Boolean isMilestonesEnabled { get {
    //         return customer.milestones;
    //     } set;
    // }

    // public Boolean isCampaignsEnabled { get {
    //         return customer.campaigns;
    //     } set;
    // }

    public String packageName { get {
            return customer.packageName;
        } set;
    }

    public String detectedCompanies { get {
            return String.valueOf(customer.detectedCompanies);
        } set;
    }

    public final String pisUsage {get; private set;}

    public Integer pisCurrent { get; set; }
    public Integer pisLimit { get; set; }

    public final String lastFetchDate { get; private set; }

    public Boolean autoLeadProcessing { get {
            return selectedMode == Mode.Type.Lead.name() &&
            selectedProcessing == Constants.PROCESSING_AUTOMATIC;
        } set;
    }

    public Visit__c selectUser {get; set;}

    private Group getApplicationQueue() {
        log.debug('Gettings application queue', currentMode);

        final Map<Id, Group> groups = new Map<Id, Group>();

        if(currentMode.lead) {
            groups.putAll([Select Id, Name From Group Where Id In 
                (Select QueueId From QueueSObject Where SObjectType =: Lead.getSObjectType().getDescribe().getName())
                And Type = : 'Queue']);
        } else if(currentMode.company) {
            groups.putAll([Select Id, Name From Group Where Id In
                (Select QueueId From QueueSObject Where SObjectType =: Company__c.getSObjectType().getDescribe().getName())
                And Type = : 'Queue']);
        }

        if(groups.containsKey(settings.SelectedQueue__c))
            return groups.get(settings.SelectedQueue__c);

        return null;
    }

    private final RestClient.Service restService;
    public string userLang{get;set;}
    public SettingsController() {
        this(new RestClient());
        system.debug('getVFPageName::'+getVFPageName());
    }
    
    public SettingsController(RestClient.Service restService) {
        userLang = userInfo.getLanguage();
        if(userLang.contains('en')){
           userLang = 'en'; 
        }
        lstOfCampaign = new List<SelectOption>();
        showAllCampaign();
        visitDeleteStartDate = new MetaObject__c();
        visitDeleteEndDate  = new MetaObject__c();
        
        visitFetchStartDate = new MetaObject__c();
        visitFetchEndDate = new MetaObject__c();
        userMap = new Map<Id,User>([select id,Name from User limit 10000]);
        leadStatusOptions = new List<SelectOption>();
        userPermission = false;
        User user = [select Id, Profile.Name from User where Id =:UserInfo.getUserId()];
        Set<Id> setPermissionSetUserIds = new Set<Id>();
        for(List<PermissionSetAssignment> lstPSA :  [Select Assignee.Id, Assignee.Name, PermissionSet.Name from PermissionSetAssignment Where PermissionSet.Name = 'leadwebStandardPermission']){
            for(PermissionSetAssignment PSA : lstPSA){
                setPermissionSetUserIds.add(PSA.Assignee.Id);
            }
        }
        if(setPermissionSetUserIds.contains(user.Id) || user.profile.name.equalsIgnoreCase('System Administrator') || user.profile.name.equalsIgnoreCase('Systemadministrator')){
            userPermission = true;
        }
        if(userPermission==false){
            // to avoid Apexpage message related error if this class not called from Settings Page. 
            string currentPage = getVFPageName();
            if(ApexPages.currentPage() != null && currentPage!=null &&  currentPage.equalsIgnoreCase('wmll__Settings')) {
              Apexpages.addmessage(new ApexPages.message(ApexPages.severity.INFO,Label.Current_User_Permission));  
            }
        }
        this.restService = restService;
        settings = credentialsManager.getSettings();

        currentMode = new Mode(settings);

        //Reset on page refresh to prevent formatting
        toDate = null; fromDate = null;

        populateModeSettings();
        populateLeadSources();
        
        populateActiveCampaigns();
        populateQueues(Mode.ObjectName.get(currentMode.getModeType()),'WhenPageLoads');
        populateProcessing();
        populateRetrievalPeriod();
        populateVisitLimits();

        selectCompanyUser = new Visit__c();
        selectLeadUser = new Visit__c();
        standardTaskUser = new Visit__c();

        if(settings != null)
            mapSettingsToController();
        mandatoryFieldsConfigured = CustomMandatoryFieldManager.allDefaultFieldsConfigured();
        //changeMode();
        
        getStatisticsInfo();
        customer = getCustomerInfo();
        leadWebGroup = getApplicationQueue();
        
        pisUsage = String.valueOf(customer.pisCurrent) + ' / ' + String.valueOf(
                       customer.pisLimit);

        lastFetchDate = settings.LastFetchDate__c != null ?
                        settings.LastFetchDate__c.format() : '';
        
        //checkSchedulers();
        
        //  Combining CustomMandatoryFieldConfigController class.......
        isCustomMandatoryFieldsHaveDefaultValues = true;
        try {
            checkFieldAccessibility();
        } catch(Exception e) {
            Apexpages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                 Label.DefaultMandatoryFieldObjectIsNotAccessible));
        }

        editMode = false;

        //Get all custom mandatory fields
        allData = new List<ObjectForParsing>();
        allData.add(new ObjectForParsing(new Account()));
        allData.add(new ObjectForParsing(new Lead()));
        allData.add(new ObjectForParsing(new Task()));
        allData.add(new ObjectForParsing(new CampaignMember()));
        allData.add(new ObjectForParsing(new Company__c()));

        //If custom fields don't exist a message should be shown to the user
        isMandatoryFieldExists = false;
        for(ObjectForParsing eachObject : allData) {
            if(!eachObject.mandatoryFields.isEmpty())
                isMandatoryFieldExists = true;
            for(MandatoryFieldWrapper mandatoryField : eachObject.mandatoryFields) {
                if(String.isEmpty(mandatoryField.defaultValue))
                    isCustomMandatoryFieldsHaveDefaultValues = false;
            }
        }
        if(!isMandatoryFieldExists) {
            if(ApexPages.currentPage() != null) {
                //Apexpages.addmessage(new ApexPages.Message(ApexPages.Severity.INFO,Label.CustomMandatoryFieldsNotFound));
            }
        }
        populateLeadStatus();
        if(setting__c.getInstance(Constants.CUSTOM_SETTING_NAME) != null && setting__c.getInstance(Constants.CUSTOM_SETTING_NAME).LeadStatus__c!=null){
            selectedLeadStatus = setting__c.getInstance(Constants.CUSTOM_SETTING_NAME).LeadStatus__c;
        }else if(leadStatusOptions.size() > 0 && leadStatusOptions.get(0) != null ){
            string leadStatusDefaultValue = DMLManager.returnDefaultPicklistValue(new Lead(),'Status');
			selectedLeadStatus = leadStatusDefaultValue!=null?leadStatusDefaultValue:leadStatusOptions.get(0).getValue();
        } 
    }
    // checking for current page to avoid ApexPages.addmessage related  error.
    // because this class is also called from DMLMANAGER . in that case ApexPages.addmessage will show error.
    public void showAllCampaign(){
        List<Campaign> lstOfAllCampaign = [select Name,Id from Campaign limit 10000];
        lstOfCampaign.add(new SelectOption('None','None'));
       if(lstOfAllCampaign!=null && lstOfAllCampaign.size()>0){
            for(Campaign cm : lstOfAllCampaign){
                lstOfCampaign.add(new SelectOption(cm.id,cm.Name));
            }
       }
    }
    public string getVFPageName() {
         // THIS IS THE CLOSEST YOU CAN GET SO FAR
         if(ApexPages.CurrentPage()!=null  && ApexPages.CurrentPage().getUrl()!=null){
             String pageName = ApexPages.CurrentPage().getUrl();
             // IT ALWAYS STARTS WITH /APEX/ SO REMOVE IT
             pageName = pageName.replaceFirst('/apex/', '');
             system.debug('pageName::'+pageName);
             pageName = EncodingUtil.urlEncode(pageName, 'UTF-8');
             // %3F IS THE VALUE OF THE QUESTION MARK IN UTF-8 
             string[] pageNameExtra = pageName.split('%3F', 0);
             // SO YOU MAY SPLIT THE STRING AT THAT POINT
             // FOR THIS PURPOSE YOU ONLY NEED THE FIRST
             // IN THE RESULTING ARRAY
             pageName = pageNameExtra[0];
             // HERE IS YOUR PRODUCT  
             system.debug('pageName-->' + pageName);
             return pageName;
         }else{
             return null;
         }
    }
    
    
    public PageReference initConnection() {
        final PageReference pageRef = makeConnection();
        return pageRef;
    }

    public List<SelectOption> getLeadSourceOptions() {
        return this.leadSourceOptions;
    }

    public List<SelectOption> getCampaignOptions() {
        return this.campaignOptions;
    }

    public List<SelectOption> getProcessingOptions() {
        return this.processingOptions;
    }

    public List<SelectOption> getRetrievalPeriods() {
        return this.retrievalPeriods;
    }

    public List<SelectOption> getVisitLimits() {
        return this.visitLimits;
    }

    private void checkSchedulers() {
        FetchLegalFormsScheduler.schedule();
        BatchRemoveVisits.scheduleHourly();
    }


    public PageReference fetchVisits() {
        successInformation = null;
        setUPSuccessMessage = null;
        toDate = visitFetchEndDate.End_Date__c;
        fromDate = visitFetchStartDate.Start_Date__c;
        if(!readyToFetch())
        return null;
        
        try {
            if(mandatoryFieldsConfigured){
                
                final Fetcher fetcher = new Fetcher(fromDate, toDate, true);
                // Apexpages.addmessage(new ApexPages.Message(ApexPages.Severity.INFO,
                //                  Label.FetchVisitsInProgress));
                successInformation = Label.FetchVisitsInProgress;
            }
            return null;
        } catch(TypeException typeEx) {
            //Incorrect dates
            Apexpages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING,
                                 Label.PleaseEnterAValidTimerange));

            log.error('Issue with date values during fetch',
                      new List<Date> {fromDate, toDate});

            return null;
        } catch(CalloutException ex) {
            //Incorrect connection settings
            Apexpages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                 Label.CommunicationError));

            log.error('Issue with communication during fetch.', ex);
            return null;
        } catch(Exception ex) {
            //Unexpected exception, show message to the user
            Apexpages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                 Label.InternalError));

            log.error('General failure on fetch', ex);
            return null;
        }

        log.info('Finished fetch');

        settings.LastFetchDate__c = Datetime.now();
        DMLManager.updateAsSystem(settings);
        
        return null;
    }

    public Boolean readyToFetch() {
        errorInformation = null;
        ApexPages.getMessages().clear();

        if(![Select Id, ApexClass.Name, Status From AsyncApexJob
             Where ApexClass.Name = : Fetcher.class.getName() And(Status = 'Queued'
                                    Or Status = 'Processing')].isEmpty()) {

            // Apexpages.addmessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,
            //                      Label.FetchVisitsInProgress));
            errorInformation = Label.FetchVisitsInProgress;
        }
        
        else if(settings.PublicCustomNumber__c == null) {
            // Apexpages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,
            //                      Label.CommunicationError));
            errorInformation = Label.CommunicationError;
        }
        // If pisCurrent Reached to pisLimit then It will prevent to make manual fetch.
        else if(customer.pisCurrent>=customer.pisLimit){
            // Apexpages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,
            //                      Label.Pis_Limit_Reached_Validation));
            // errorInformation = Label.Pis_Limit_Reached_Validation;
            errorInformation = Label.Pis_Limit_Reached_Validation;
        }
        else if(!CustomMandatoryFieldManager.allDefaultFieldsConfigured()) {
            // Apexpages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,
            //                      Label.PleaseFillInAllMandatoryFields));
            // errorInformation = Label.PleaseFillInAllMandatoryFields;
            errorInformation = Label.PleaseFillInAllMandatoryFields;
        }
        else if(fromDate != null && (System.today().daysBetween(fromDate) > 0)){
            errorInformation = Label.ManualFetchFutureDate;
        }
        //start date must be earlier than the end date..
        else if(fromDate == null || toDate == null || fromDate.daysBetween(toDate) < 0) {
            if(fromDate == null || toDate == null){
                // Apexpages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                //                  Label.PleaseFillInDataRange));
                // errorInformation = Label.PleaseFillInDataRange;
                errorInformation = Label.PleaseFillInDataRange.replace('[field1]',Label.EndDate).replace('[field2]',Label.StartDate);
            }else if(fromDate.daysBetween(toDate) < 0){
                // Apexpages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                //                  Label.StartDate_Earlier_Than_EndDate));
                // errorInformation = Label.StartDate_Earlier_Than_EndDate;
                errorInformation = Label.StartDate_Earlier_Than_EndDate;
            }
        }

        log.debug('Fetching precheck complete.');

        if(ApexPages.getMessages().isEmpty())
            System.purgeOldAsyncJobs(Date.today());

        return !(errorInformation!=null);
    }

    public PageReference deleteAllVisits() {
        successInformation = null;
        setUPSuccessMessage = null;
        errorInformation  = null;
        startDateToDeleteVisit = visitDeleteStartDate.Start_Date__c;
        endDateToDeleteVisit = visitDeleteEndDate.End_Date__c;
        if(endDateToDeleteVisit!=null && startDateToDeleteVisit!=null && startDateToDeleteVisit.daysBetween(endDateToDeleteVisit) >= 0){
            Database.executeBatch(new BatchDeleteVisits(startDateToDeleteVisit,endDateToDeleteVisit));
            successInformation = Label.VisitsDeletedSuccessfully;
        }else if(startDateToDeleteVisit == null || endDateToDeleteVisit == null || startDateToDeleteVisit.daysBetween(endDateToDeleteVisit) < 0){
            if(startDateToDeleteVisit == null || endDateToDeleteVisit == null){
                errorInformation = Label.PleaseFillInDataRange.replace('[field1]',Label.EndDate).replace('[field2]',Label.StartDate);
            }else if(startDateToDeleteVisit.daysBetween(endDateToDeleteVisit) < 0){
                errorInformation  = Label.DateValidationForVisitDeletion;
            }
        }
        visitDeleteStartDate.Start_Date__c = null;
        visitDeleteEndDate.End_Date__c = null;
        return null;
    }
    public void cancelDelete(){
        visitDeleteStartDate.Start_Date__c = null;
        visitDeleteEndDate.End_Date__c = null;
        visitFetchEndDate.End_Date__c = null;
        visitFetchStartDate.Start_Date__c = null;
        errorInformation = null;
        system.debug('@1::'+selectedMode);
        // selectedMode = Setting__c.getInstance('LeadLabSettings').SelectedMode__c;
        system.debug('@2::'+settings.SelectedMode__c);
    }

    private Dto.Customer getCustomerInfo() {
        if(settings.Token__c == null)
            return new Dto.Customer();

        try {
            return restService.getCustomer();
        } catch(CalloutException e) {
            if(ApexPages.currentPage() != null){
                Apexpages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                 Label.CommunicationError));
            }
        }

        return new Dto.Customer();
    }

    public void getStatisticsInfo() {
        Dto.Customer dto;

        if(settings.Token__c != null) {
            try {
                dto = restService.getCustomer();
            } catch(CalloutException e) {
                if(ApexPages.currentPage() != null){
                    Apexpages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                     Label.CommunicationError));
                }
            }
        } else
            dto = new Dto.Customer();

        //trackingPixelCode = dto != null ? dto.trackingCode.split('\n') : new List<String>();
        trackingPixelCode2 = dto != null ? dto.trackingCode : '';
        //optOutCode = dto != null ? dto.optOutCode.split('\n') : new List<String>();
        optOutCode2DE = dto != null ? getOptOutCodeDE(dto.optOutCodes) : ''; 
        optOutCode2EN = dto != null ? getOptOutCodeEN(dto.optOutCodes) : ''; 
    }
    
    private String getOptOutCodeDE(Dto.clsOptOutCodes optOutCode){
        String optOutCodeVal = '';
        if(optOutCode != null){
            if(optOutCode.de != null){
                optOutCodeVal += optOutCode.de;
            }
            /*if(optOutCode.en != null){
                optOutCodeVal += '\r\n'+'EN: '+optOutCode.en;
            }*/
        }
        return optOutCodeVal;
    }
    
    private String getOptOutCodeEN(Dto.clsOptOutCodes optOutCode){
        String optOutCodeVal = '';
        if(optOutCode != null){
            // if(optOutCode.de != null){
            //     optOutCodeVal += 'DE: '+optOutCode.de;
            // }
            if(optOutCode.en != null){
                optOutCodeVal += optOutCode.en;
            }
        }
        return optOutCodeVal;
    }

    private void populateRetrievalPeriod() {
        retrievalPeriods.clear();
        
         RetrievalPeriodMap = new Map<String, String>{
                             Constants.FETCH_INTERVAL_6AM => Label.Daily,
                             Constants.FETCH_INTERVAL_12H => Label.TwiceDaily,
                             Constants.FETCH_INTERVAL_4H =>  Label.EveryFourHours,
                             Constants.FETCH_INTERVAL_1H => Label.EveryHour
         };
         for(String autoRetrievalPeriod : RetrievalPeriodMap.keySet())
            retrievalPeriods.add(new SelectOption(autoRetrievalPeriod, RetrievalPeriodMap.get(autoRetrievalPeriod)));
        // retrievalPeriods.add(new SelectOption(Constants.FETCH_INTERVAL_6AM, Label.Daily));
        // retrievalPeriods.add(new SelectOption(Constants.FETCH_INTERVAL_12H, Label.TwiceDaily));
        // retrievalPeriods.add(new SelectOption(Constants.FETCH_INTERVAL_4H, Label.EveryFourHours));
        // retrievalPeriods.add(new SelectOption(Constants.FETCH_INTERVAL_1H, Label.EveryHour));
        selectedRetrievalPeriod = String.isNotEmpty(settings.Retrieval_Period__c) ?
                                  settings.Retrieval_Period__c :
                                  retrievalPeriods.get(retrievalPeriods.size() - 1).getValue();
    }

    private void populateVisitLimits() {
         limits = new Map<String, String> {
            'NoLimit' => Label.VisitLimit_None,
            '5' => Label.VisitLimit_5,
            '10' =>  Label.VisitLimit_10,
            '50' => Label.VisitLimit_50
        };
        visitLimits.clear();

        for(String visitLimit : limits.keySet())
            visitLimits.add(new SelectOption(visitLimit, limits.get(visitLimit)));
        
        selectedVisitLimit = settings.DeleteOldVisitsThreshold__c != null ?
                             String.valueOf(integer.valueof(settings.DeleteOldVisitsThreshold__c)) : 'NoLimit';
    }


    private void populateLeadSources() {
        leadSourceOptions.clear();
        Schema.DescribeFieldResult sourcePicklist = Lead.LeadSource.getDescribe();

        for(Schema.PicklistEntry source : sourcePicklist.getPicklistValues())
            leadSourceOptions.add(new SelectOption(source.getValue(), source.getLabel()));

        selectedLeadSource = leadSourceOptions.get(0).getValue();
    }
    // public List<selectoption> getleadStatusOptions(){
        
    // }
    private void populateLeadStatus(){
        Schema.DescribeFieldResult fieldResult =lead.Status.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
           {
              leadStatusOptions.add(new SelectOption(f.getValue(),f.getLabel()));
           } 
        //   selectedLeadStatus = leadStatusOptions.get(0).getValue();
    }


    public void changeMode() {
        system.debug('selectedQueue changeMode :: '+selectedQueue);
            populateQueues(Mode.ObjectName.get(currentMode.getModeType()),'WhenModeChanges');
    }
    public void changeQueue() {
        system.debug('selectedQueue changeMode :: '+selectedQueue);
            populateQueues(Mode.ObjectName.get(currentMode.getModeType()),'WhenQueueChanges');
    }

    private void populateModeSettings() {
        modeSettingsMap = new Map<String,String>();
        modeSettings = new List<SelectOption>();
        for(Mode.Type modeType : Mode.TypeLabel.keySet()){
            modeSettings.add(new SelectOption(modeType.name(), Mode.TypeLabel.get(modeType)));
            modeSettingsMap.put(modeType.name(),Mode.TypeLabel.get(modeType));
        }
    }

    private void populateActiveCampaigns() {
        campaignOptions.clear();
        campaignOptions.add(SELECT_NONE);

        final List<Campaign> campaigns = [SELECT Name, IsActive FROM Campaign WHERE IsActive = :true];
        for(Campaign campaign : campaigns)
            campaignOptions.add(new SelectOption(campaign.Id, campaign.Name));
    }

    private void populateQueues(String queueType,String callingOrigin) {
        system.debug('selectedMode  :: '+Mode.ObjectName.get(currentMode.getModeType()));
        log.info('Queue: ', queueType);
        queueOptions = new List<SelectOption>();

        //Get Queue IDs that support Leads
        final List<QueueSobject> leadQueues = [SELECT QueueId, SObjectType FROM
                                               QueueSobject WHERE SObjectType = :queueType];

        final List<String> queueIds = new List<String>();
        for(QueueSobject queueobject : leadQueues)
            queueIds.add(queueobject.QueueId);

        //Get IDs and Names of Groups that are Queues which support Leads
        final Map<Id, Group> groups = new Map<Id, Group>([SELECT Id, Name FROM Group WHERE Id in :queueIds]);
        for(Group aGroup : groups.values())
            queueOptions.add(new SelectOption(aGroup.Id, aGroup.Name));

        if((true && queueType != 'Account')){// groups.containsKey(settings.SelectedQueue__c
            if(callingOrigin == 'WhenPageLoads'){
                selectedQueue = settings.SelectedQueue__c;
            }else if(callingOrigin == 'WhenModeChanges'){
                List<Id> lstUser = new List<Id>();
                lstUser.addAll(groups.keyset());
                selectedQueue = lstUser[0];
            }
            for (SelectOption so : queueOptions){
                if (so.getValue() == selectedQueue){
                    selectedQueueLabel = so.getLabel();
                }
            }
            system.debug('selectedQueueLabel :: '+selectedQueueLabel);
        }else{
            selectedQueueLabel = '';
        }
    }

    private void populateProcessing() {
        processingOptions.clear();
        processingOptions.add(new SelectOption(Constants.PROCESSING_AUTOMATIC, Label.Automatic));
        processingOptions.add(new SelectOption(Constants.PROCESSING_MANUAL, Label.Manual));

        selectedProcessing = String.isNotEmpty(settings.Processing__c) ? settings.Processing__c :
                             processingOptions.get(0).getValue();
    }

    private void mapSettingsToController() {
        standardTaskUser.AssignedUser__c = settings.StandardTaskUser__c;

        standardUserIsAccountOwner = settings.AccountOwnerIsTaskOwner__c;
        autoTaskPerAccountAssignment = settings.AutoTaskPerAccountAssignment__c;

        
        selectedMode = settings.SelectedMode__c;
        oldSystemMode = settings.SelectedMode__c;
        selectedQueue = settings.SelectedQueue__c;
        selectedProcessing = settings.Processing__c;
        leadName = settings.LeadName__c;
        selectedLeadSource = settings.LeadSource__c;
        // selectedLeadStatus = settings.LeadStatus__c;
        selectedCampaign = settings.SelectedCampaign__c==null?'None':settings.SelectedCampaign__c;
        standardTaskUser.AssignedUser__c = settings.StandardTaskUser__c;
        standardUserIsAccountOwner = settings.AccountOwnerIsTaskOwner__c;
        autoTaskPerAccountAssignment = settings.AutoTaskPerAccountAssignment__c;
        // selectedRetrievalPeriod = settings.Retrieval_Period__c;
        retrievalEnable = !String.isEmpty(selectedRetrievalPeriod) ? true : false;
        // selectedVisitLimit = settings.DeleteOldVisitsThreshold__c != null ?
        //                      String.valueOf(settings.DeleteOldVisitsThreshold__c.round(
        //                                         System.RoundingMode.FLOOR)) :
        //                      '';

        if(selectedMode == Constants.COMPANY_MODE){
            selectCompanyUser.AssignedUser__c = settings.StandardLeadUser__c;
            if(String.isEmpty(String.valueof(settings.StandardCompanyUser__c))){
                companyStandardUser = null;
            }else{
                  companyStandardUser = userMap.get(String.valueof(settings.StandardCompanyUser__c)).Name;
            }
        }      
        else if(selectedMode == Constants.LEAD_MODE){
            selectLeadUser.AssignedUser__c = settings.StandardLeadUser__c;
            if(String.isEmpty(String.valueof(settings.StandardLeadUser__c))){
                LeadStandardUser = null;
            }else{
                  LeadStandardUser = userMap.get(String.valueof(settings.StandardLeadUser__c)).Name;
            }
        }else if(selectedMode == Constants.ACCOUNT_MODE){
            standardTaskUser.AssignedUser__c = settings.StandardTaskUser__c;
            if(String.isEmpty(String.valueof(settings.StandardTaskUser__c))){
                AccountStandardUser = null;
            }else{
                AccountStandardUser = userMap.get(String.valueof(settings.StandardTaskUser__c)).Name;
            }
        }

    }

    // public PageReference getCustomFieldConfigReference() {
    //     return Page.CustomMandatoryFieldConfiguration;
    // }

    private void scheduleFetching() {

        if(!retrievalEnable) {
            new FetchVisitsScheduler().abort();
            return;
        }

        if(selectedRetrievalPeriod == Constants.FETCH_INTERVAL_12H)
            new FetchVisitsScheduler().scheduleTwiceDaily();
        else if(selectedRetrievalPeriod == Constants.FETCH_INTERVAL_4H)
            new FetchVisitsScheduler().scheduleEveryFourHours();
        else if(selectedRetrievalPeriod == Constants.FETCH_INTERVAL_1H)
            new FetchVisitsScheduler().scheduleHourly();
        else
            new FetchVisitsScheduler().scheduleDaily();
    }

    private PageReference makeConnection() {
        final PageReference pageRef = makeConnection(new RestClient(HttpClient.getInstance(), this.settings));
        if(pageRef != null){
            pageRef.setRedirect(true);
        }
        return pageRef;
    }
    
    private PageReference makeConnection(RestClient.Service restClient) {
        if(String.isEmpty(settings.PublicCustomNumber__c)) {
            Dto.LoginInformation logInfoDto = new Dto.LoginInformation();
            credentialsManager.setSettingsTechnicalUser('','', Constants.DEFAULT_ENDPOINT);
            try {
                
                logInfoDto = restClient.createTenant();
                credentialsManager.setSettings(logInfoDto.publicCustnum, logInfoDto.token);
                
                PageReference p = ApexPages.Currentpage();
                return p;
            } catch(CalloutException e) {
                Apexpages.addmessage(new ApexPages.Message(ApexPages.Severity.Error,
                                     Label.IssueWithTheRemoteServer));
            } catch(Exceptions.Http403Exception e) {
                Apexpages.addmessage(new ApexPages.Message(ApexPages.Severity.Error, Label.WrongToken));
            } catch(Exceptions.Http405Exception e) {
                Apexpages.addmessage(new ApexPages.Message(ApexPages.Severity.Error, Label.CustomerNotFound));
            } catch(Exceptions.Http429Exception e) {
                Apexpages.addmessage(new ApexPages.Message(ApexPages.Severity.Error, Label.TooManyRequests));
            } catch(Exceptions.Http509Exception e) {
                Apexpages.addmessage(new ApexPages.Message(ApexPages.Severity.Error, Label.PILimit));
            } catch(Exceptions.HttpException e) {
                Apexpages.addmessage(new ApexPages.Message(ApexPages.Severity.Error, Label.CantAuthorizeToServer));
            }
        }
        return null;
    }
    
    public void testGroupQueue(){
        SfQueueHandler lwQueueHandler = new LeadWebQueueHandler();
		lwQueueHandler.checkAndCreateSfQueues();
    }
    
    public PageReference saveSetting() {
        system.debug('selectedVisitLimit :: '+selectedVisitLimit);
        
        companyStandardUser = userMap.containsKey(selectCompanyUser.AssignedUser__c)?userMap.get(String.valueof(selectCompanyUser.AssignedUser__c)).Name:null;// selectCompanyUser.AssignedUser__c;
        LeadStandardUser    = userMap.containsKey(selectLeadUser.AssignedUser__c)?userMap.get(String.valueof(selectLeadUser.AssignedUser__c)).Name:null;//selectLeadUser.AssignedUser__c;
        AccountStandardUser = userMap.containsKey(standardTaskUser.AssignedUser__c)?userMap.get(String.valueof(standardTaskUser.AssignedUser__c)).Name:null;//standardTaskUser.AssignedUser__c; 
        
        setUPSuccessMessage = null;
        successInformation = null;
        //before save: check is user and password changed
        //if changed try to get new public number and token
        makeConnection();

        //Reset on page refresh to prevent formatting
        toDate = null; fromDate = null;
        
        
        try{
            // this method saves the default values for custom mandatory fields....
            // save();
        }catch(Exception exp){
            // Apexpages.addmessage(new ApexPages.Message(ApexPages.Severity.Error, 'Save not working:: '+exp.getMessage()));
        }
        //Here, we checking for system mode change, if all Mandatory fields not configured
        if((selectedMode!=null && selectedMode.equals(oldSystemMode)) || CustomMandatoryFieldManager.allDefaultFieldsConfigured()){
            mapControllerToSettings();
            // if retrievalEnable will be false then  visits will not be fetched any longer.
            if(retrievalEnable==false){
                settings.Retrieval_Period__c = '';
            }
            DMLManager.upsertAsUser(settings);
            scheduleFetching();
        }else{
            errorInformation = label.All_Mandatory_Fields_Not_Configured;
            // Apexpages.addmessage(new ApexPages.Message(ApexPages.Severity.Error, String.valueof(label.All_Mandatory_Fields_Not_Configured)));
        }
        
        checkSchedulers();
        
        //BatchRemoveVisits.scheduleHourly();
        
        if(!CustomMandatoryFieldManager.allDefaultFieldsConfigured()){
                if(selectedMode!=null && selectedMode.equals(oldSystemMode)){
                    setUPSuccessMessage = Label.SetUpSuccessInfo;
                    // return new PageReference('/apex/settings').setRedirect(true);
                    return null;
                }else{
                    return null;
                }
        }else{
            setUPSuccessMessage = Label.SetUpSuccessInfo;
            return null;
            // return new PageReference('/apex/settings').setRedirect(true);
        }
    }

    public PageReference cancel() {
        return new PageReference('/apex/settings').setRedirect(true);
        // return null;
    }

    private Boolean mapControllerToSettings() {
        system.debug('selectedQueue in mapControllerToSettings:: '+selectedQueue);
        settings.StandardTaskUser__c = standardTaskUser.AssignedUser__c;
        settings.SelectedMode__c = selectedMode;
        settings.Retrieval_Period__c = selectedRetrievalPeriod;


        // settings.DeleteOldVisitsThreshold__c = !String.isEmpty(selectedVisitLimit) ?
        //                                       Integer.valueOf(selectedVisitLimit) :
        //                                       null;
        settings.DeleteOldVisitsThreshold__c = selectedVisitLimit != 'NoLimit' ?
                                               Integer.valueOf(selectedVisitLimit) :
                                               null;
        
        if(selectedMode == Constants.COMPANY_MODE) {
            system.debug('compUser::'+selectCompanyUser.AssignedUser__c);
            settings.SelectedQueue__c = selectedQueue;
            settings.StandardCompanyUser__c = selectCompanyUser.AssignedUser__c;
        } else if(selectedMode == Constants.LEAD_MODE) {
            settings.SelectedQueue__c = selectedQueue;
            settings.Processing__c = selectedProcessing;
            settings.LeadName__c = leadName;
            settings.LeadSource__c = selectedLeadSource;
            settings.LeadStatus__c = selectedLeadStatus;
            settings.SelectedCampaign__c = selectedCampaign=='None'?null:selectedCampaign;
            settings.StandardLeadUser__c = selectLeadUser.AssignedUser__c;
        } else if(selectedMode == Constants.ACCOUNT_MODE) {
            settings.StandardTaskUser__c = standardTaskUser.AssignedUser__c;
            settings.AccountOwnerIsTaskOwner__c = standardUserIsAccountOwner;
            settings.AutoTaskPerAccountAssignment__c = autoTaskPerAccountAssignment;
        }

        return true;
    }
    
    //
    private void checkFieldAccessibility() {
        final List<String> fieldsForCheck = new List<String>();
        fieldsForCheck.add('DefaultValue__c');
        fieldsForCheck.add('Type__c');
        final List<String> issuesAccessible = Utils.isAccessible(
                new DefaultMandatoryField__c(),
                fieldsForCheck
                                              );

        if(!issuesAccessible.isEmpty())
            throw new Exceptions.CustomMandatoryFieldsException(issuesAccessible[0]);
    }

    /**
    *	Enable writable version of the detail page.
    */
    public void edit() {
        editMode = true;
    }

    /**
    *	Save all data
    */
    public PageReference save() {
        editMode = false;
        setUPSuccessMessage = null;
        successInformation = null;
        Boolean allowSave = true;
        //Remove all previous values
        final List<DefaultMandatoryField__c> records = [Select Id From DefaultMandatoryField__c LIMIT 10000];
        if(!flsService.checkWithMessage(records)) return null;
        DMLManager.deleteAsSystem(records);

        //save all new values
        final List<DefaultMandatoryField__c> allRecords = new
        List<DefaultMandatoryField__c>();
        for(ObjectForParsing objectData : allData) {

            for(MandatoryFieldWrapper field : objectData.mandatoryFields) {
                if(String.isEmpty(String.valueOf(objectData.standardObject.get(
                                           field.mandatoryFieldAPIName)))){
                    allowSave = false;
                }
                allRecords.add(new DefaultMandatoryField__c(
                                   Name = field.mandatoryFieldAPIName,
                                   DefaultValue__c = String.valueOf(objectData.standardObject.get(
                                           field.mandatoryFieldAPIName)),
                                   Type__c = objectData.objectLabel)
                              );
                field.defaultValue = String.valueOf(objectData.standardObject.get(
                                                        field.mandatoryFieldAPIName));
            }
        }
       if(allowSave){
           DMLManager.insertAsUser(allRecords);
           setUPSuccessMessage = Label.SetUpSuccessInfo;
           mandatoryFieldsConfigured = CustomMandatoryFieldManager.allDefaultFieldsConfigured();
        //   return new PageReference('/apex/settings').setRedirect(true);
        return null;
       }else{
           return null;
       }
    }

    /**
    *	parse object: determine mandatory non standard fields and set default values
    */
    public with sharing class ObjectForParsing {
        
        private final SfUtilsLib.IFlsService flsService = SfUtilsLib.getFlsService();

        private final Map<String, Map<String, String>> objectType_FieldApiName_DefaultValue 
            = new Map<String, Map<String, String>>();

        public String objectLabel {get; private set;}
        public sObject standardObject {get; private set;}
        public Boolean isContainsCustomMandatoryFields {get; private set;}
        public List<MandatoryFieldWrapper> mandatoryFields {get; private set;}

        public ObjectForParsing(sObject objectName) {
            standardObject = objectName;
            Schema.sObjectType sobjectType = objectName.getSObjectType();
            Schema.DescribeSObjectResult schemaResult = sobjectType.getDescribe();
            objectLabel = schemaResult.getLabel();

            //Get all records with default values for mandatory fields
            fillMapWithDefaultValues();

            //If an object contains mandatory fields it will be shown up on the page
            isContainsCustomMandatoryFields = true;

            //Found all custom mandatory fields, fill default values if there are any
            mandatoryFields = new List<MandatoryFieldWrapper>();
            setAllMandatoryFields(schemaResult, standardObject);

            if(mandatoryFields.isEmpty())
                isContainsCustomMandatoryFields = false;
        }

        private void fillMapWithDefaultValues() {
            final List<DefaultMandatoryField__c> records = [Select Id, DefaultValue__c, Name, Type__c 
                From DefaultMandatoryField__c Where Type__c = :objectLabel LIMIT 10000];

            if(!flsService.checkWithMessage(records)) return;

            for(DefaultMandatoryField__c record : records) {

                if(objectType_FieldApiName_DefaultValue.containsKey(record.Type__c) == false)
                    objectType_FieldApiName_DefaultValue.put(record.Type__c,
                            new Map<String, String>());
                objectType_FieldApiName_DefaultValue.get(record.Type__c).put(record.Name,
                        record.DefaultValue__c);
            }
        }

        private MandatoryFieldWrapper setDefaultValueForMandatoryField(
            String mandatoryFieldAPIName,
            String mandatoryFieldLabel,String fieldType) {
            MandatoryFieldWrapper valueForField = new MandatoryFieldWrapper();
            valueForField.mandatoryFieldAPIName = mandatoryFieldAPIName;
            valueForField.mandatoryFieldLabel = mandatoryFieldLabel;
            valueForField.defaultValue = '';
            valueForField.fieldType = fieldType;

            if(objectType_FieldApiName_DefaultValue.containsKey(objectLabel)) {
                if(objectType_FieldApiName_DefaultValue.get(objectLabel).containsKey(
                            mandatoryFieldAPIName)) {
                    valueForField.defaultValue =
                        objectType_FieldApiName_DefaultValue.get(objectLabel).get(
                            mandatoryFieldAPIName);
                }
            }
            return valueForField;
        }

        private Boolean myIsCustom(Schema.DescribeFieldResult fieldResult) {
            if(test.isRunningTest() && fieldResult.getName() == 'Name')
                return true;
            else
                return fieldResult.isCustom();
        }

        private void setAllMandatoryFields(Schema.DescribeSObjectResult schemaResult,
                                           sObject standardObject) {
            final Map<String, Schema.SObjectField> mapFieldName_sObjectField =
                schemaResult.fields.getMap();
            for(String fieldName : mapFieldName_sObjectField.keySet()) {
                Schema.SObjectField field = mapFieldName_sObjectField.get(fieldName);
                Schema.DescribeFieldResult fieldResult = field.getDescribe();
                //if isNillable == false, field is mandatory. isDefaultedOnCreate remove fileds. Like checkbox
                if(!fieldResult.isNillable() && myIsCustom(fieldResult) &&
                        !fieldResult.isDefaultedOnCreate()) {
                    MandatoryFieldWrapper valueForField = new MandatoryFieldWrapper();
                    valueForField = setDefaultValueForMandatoryField(fieldResult.getName(),
                                    fieldResult.getLabel(),String.valueof(fieldResult.getType()));

                    Schema.DisplayType FldType = field.getDescribe().getType();
                    if(!String.isEmpty(valueForField.defaultValue)) {
                        if(FldType == Schema.Displaytype.DATE)
                            standardObject.put(fieldResult.getName(),
                                               Date.valueOf(valueForField.defaultValue));
                        else if(FldType == Schema.Displaytype.Percent ||
                                FldType == Schema.Displaytype.Currency || FldType == Schema.Displaytype.Double)
                            standardObject.put(fieldResult.getName(),
                                               Decimal.valueOf(valueForField.defaultValue));
                        else if(FldType == Schema.Displaytype.DateTime)
                            standardObject.put(fieldResult.getName(),
                                               DateTime.valueOf(valueForField.defaultValue));
                        else
                            standardObject.put(fieldResult.getName(), valueForField.defaultValue);
                    }
                    mandatoryFields.add(
                        valueForField
                    );
                }
            }
        }
    }

    public with sharing class MandatoryFieldWrapper {
        public String mandatoryFieldAPIName {get; set;}
        public String mandatoryFieldLabel {get; set;}
        public String defaultValue {get; set;}
        public String fieldType{get;set;}
    }
    
    
}