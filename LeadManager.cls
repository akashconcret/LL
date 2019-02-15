public with sharing class LeadManager {

    private final Logger.IService log = Logger.getDefault(LeadManager.class);

    private final SfUtilsLib.IFlsService flsService = SfUtilsLib.getFlsService(); 
    
    
    private final String DEFAULT_STATUS = setting__c.getInstance(Constants.CUSTOM_SETTING_NAME).LeadStatus__c!=null?
                                            setting__c.getInstance(Constants.CUSTOM_SETTING_NAME).LeadStatus__c:(
                                            DMLManager.returnDefaultPicklistValue(new Lead(),'Status') != null?
                                            DMLManager.returnDefaultPicklistValue(new Lead(),'Status'):'Open');
    
    private final String DEFAULT_RATING = DMLManager.returnDefaultPicklistValue(new Lead(),'Rating') != null?
                                          DMLManager.returnDefaultPicklistValue(new Lead(),'Rating'):'Warm';
                                          
    private final String DEFAULT_SOURCE_NAME = 'LeadLab';

    private final List<Lead> leads = new List<Lead>();
    private final List<Visit__c> visitsToUpdate = new List<Visit__c>();

    private final Group queue;
    private final String source;
    private final String campaign;
    private final String leadName;
    private final Setting__c settings;
    Id defaultUserId;

    public LeadManager() {
        this(Setting__c.getValues(Constants.CUSTOM_SETTING_NAME));
    }

    public LeadManager(Setting__c settings) {
        this.settings = settings;

        //Get Queue from settings if one is selected
        if(settings.SelectedQueue__c != null) {
            final List<Group> queues = [Select Id, Name, Type From Group
                                        where Id = : settings.SelectedQueue__c and Type = : 'Queue' And Id In
                                       (Select QueueId From QueueSObject Where SObjectType = :
                                               Lead.getSObjectType().getDescribe().getName()) limit 1];

            if(!queues.isEmpty())
                this.queue = queues.get(0);
        }

        this.campaign = settings.SelectedCampaign__c;
        this.source = settings.LeadSource__c == null ? DEFAULT_SOURCE_NAME :
                 settings.LeadSource__c;
        this.leadName = settings.LeadName__c == null ? Constants.DEFAULT_LEAD_NAME :
                   settings.LeadName__c;

        if(String.isNotEmpty(settings.StandardLeadUser__c)) {
            final List<User> users = [select Id from User where Id = :settings.StandardLeadUser__c];
            if(!users.isEmpty())
                defaultUserId = users.get(0).Id;
            //else
                //defaultUserId = UserInfo.getUserId();
        }
    }
    
    public Lead createNewLead(Company__c company) /* throws SfUtilsLib.AccessVoilationException */ {
    
        if(queue != null)
            flsService.checkWithException(queue);

        flsService.checkWithException(company);

        final Lead lead = new Lead();
        // lead.Status = setting__c.getInstance(Constants.CUSTOM_SETTING_NAME).LeadStatus__c!=null?
        //                      setting__c.getInstance(Constants.CUSTOM_SETTING_NAME).LeadStatus__c:DEFAULT_STATUS;
         
        lead.Status = !String.isEmpty(company.Lead_Status__c)?
                             company.Lead_Status__c:DEFAULT_STATUS;
        lead.Rating = !String.isEmpty(company.Rating__c)?
                             company.Rating__c:DEFAULT_RATING;
                          
        lead.LastName = String.isEmpty(settings.LeadName__c) ? company.Name : settings.LeadName__c;
        lead.LeadSource = source;

        if(String.isNotEmpty(defaultUserId)){
            lead.OwnerId = defaultUserId;
        }else if(addLeadToQueue(lead)){
        }else{
            defaultUserId = UserInfo.getUserId();
        }
            

        lead.ID__c = company.Id__c;

        lead.Company = company.Name;
        
        //Below two fields added for release 2.0 on 05 april 17.
        lead.LeadLab4SF_Industry__c = company.Branch__c;
        lead.LeadLab4SF_Annual_Revenue__c = company.AnnualRevenue__c;
        lead.Website = company.Domain__c;
        lead.Email = company.Email__c;
        lead.Phone = company.Phone__c;
        

        lead.City = company.City__c;
        lead.State = company.Region__c;
        lead.Country = company.CountryName__c;
        lead.PostalCode = company.Zip__c;
        lead.Street = company.Street__c;
        lead.LeadLab4SF_No_of_Employees__c = company.Size__c;

        flsService.checkWithException(lead);
        return lead;
    }

    /**
     * Add each lead in leads to campaign defined in settings.
     * Leads must be inserted before usign this method, otherwise there will be no ID associated
     * with the lead.
     */
    public Boolean addLeadsToCampaign(List<Lead> leads) {
        if(String.isEmpty(campaign))
            return false;

        final List<CampaignMember> members = new List<CampaignMember>();
        //For each lead, create a junction object between the campaign and the lead
        for(Lead lead : leads) {
            CampaignMember member = new CampaignMember(
                CampaignId = campaign,
                LeadId = lead.Id);
            members.add(member);
        }

        DMLManager.insertAsSystem(members);
        return true;
    }

    private Boolean addLeadToQueue(Lead lead) {
        if(queue == null) return false;

        final List<QueueSObject> queueMembers = [Select Id, QueueId From QueueSObject 
            Where QueueId =: queue.Id And SObjectType =: Lead.getSobjectType().getDescribe().getName()];

        if(queueMembers.isEmpty()) return false;

        lead.OwnerId = queue.Id;
        return true;
    }
}