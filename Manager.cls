public with sharing class Manager implements Service {

    private final SfUtilsLib.IFlsService flsService = SfUtilsLib.getFlsService();
    private final String DEFAULT_STATUS = DMLManager.returnDefaultPicklistValue(new Lead(),'status') != null?
                                          DMLManager.returnDefaultPicklistValue(new Lead(),'status'):'Open';
    
    // SettingsController settingsCtrl = new SettingsController();
    // boolean fetchVisits;
    public interface Service {
        void getCompanies(Datetime dateFrom, Datetime dateTo, Integer startpos, Integer length);
        void persistCompanies(List<Dto.Company> companies);
    }

    public interface IVisit {
        Visit__c getVisit();
        Company__c getCompany();
        List<PageHit__c> getPageHits();
        List<Referrer__c> getReferrers();
        // List<Campaign__c> getCampaigns();
        List<Milestone__c> getMilestones();
    }

    private final Logger.IService log = Logger.getPrettyDefault(Manager.class);
    private final RestClient.Service restClient;
    private final LeadManager leadManager = new LeadManager();
    private final Setting__c settings;

    public Manager() {
        this(new RestClient(), Setting__c.getInstance(Constants.CUSTOM_SETTING_NAME));
    }

    public Manager(RestClient.Service restService, Setting__c settings) {
        this.restClient = restService;
        this.settings = settings;
    }


    public void getCompanies(Datetime dateFrom, Datetime dateTo, Integer startpos, Integer length) {
        final List<Dto.Company> companies = restClient.getCompanies(dateFrom, dateTo, startpos, length);
        persistCompanies(companies);
    }
    
    public void persistCompanies(List<Dto.Company> companiesDtos) {
        RunOnlyFromManager.executeTrigger();
        final Map<String, SObject> modeObjectByExtId = new Map<String, SObject>();
        final Map<String, Map<String, VisitDetail>> visitsByCompany =
            new Map<String, Map<String, VisitDetail>>();

        final List<VisitDetail> matchedVisits = new List<VisitDetail>();

        final Matcher matcher = new Matcher();
        final Mode mode = new Mode();
        
        List<String> companyIdsPerBatch = new List<String>();
        for(Dto.Company companyDto : companiesDtos){
            companyIdsPerBatch.add(companyDto.id);
        }
        
        List<Visit__c> updateMergedVisits = new List<Visit__c>();
        List<WMLL__PageHit__c> hitsUnderMergedVisits = new List<WMLL__PageHit__c>();
        Map<string,List<Visit__c>> visitAsPerCompany = new Map<string,List<Visit__c>>();
        
        groupVisitsAsPerCompanyId(visitAsPerCompany,companyIdsPerBatch);
        
        
        for(Dto.Company companyDto : companiesDtos) {
            
            if(visitMatchedAsPerVisitDate(visitAsPerCompany,companyDto,hitsUnderMergedVisits)){
                final VisitDetail visitInfo = convertVisit(companyDto);
            
                convertCompany(companyDto, visitInfo, mode);
    
                if(matcher.match(visitInfo)) {
                    matchedVisits.add(visitInfo); continue;
                }
    
                final Company__c company = visitInfo.company;
                modeObjectByExtId.put(company.Id__c, createNewModeObject(mode, visitInfo));
    
                if(!visitsByCompany.containsKey(company.Id__c))
                    visitsByCompany.put(company.Id__c, new Map<String, VisitDetail>());
    
                if(!visitsByCompany.get(company.Id__c).containsKey(visitInfo.visit.Id__c))
                    visitsByCompany.get(company.Id__c).put(visitInfo.visit.Id__c, visitInfo);
            }
        }
        
        if(mode.account) {
                final List<Account> accounts = new List<Account>();
                accounts.addAll((List<Account>) modeObjectByExtId.values());
                DMLManager.upsertByFieldAsSystem(accounts, 'Id__c');
        } else if(mode.lead) {
                final List<Lead> leads = new List<Lead>();
                leads.addAll((List<Lead>) modeObjectByExtId.values());
                DMLManager.upsertByFieldAsSystem(leads, 'Id__c');
                //Assigning leads to the selected Campaigns from setUp page.
                if(leads!=null && leads.size()>0){
                    addLeadsToCampaign(leads);
                }
        } else { //if(mode.company)
            final List<Company__c> companies = new List<Company__c>();
            companies.addAll((List<Company__c>) modeObjectByExtId.values());
            DMLManager.upsertByFieldAsSystem(companies, 'Id__c');
        }

        matchVisitsToModeObjects(visitsByCompany, modeObjectByExtId, mode , modeObjectByExtId);

        final DetailFacade details = new DetailFacade();
        matchDetailsToParentVisit(visitsByCompany, details);

        updateMatchedVisits(matchedVisits, details);
        details.persist();
        
        
        
        for(string str :visitAsPerCompany.keySet()){
            updateMergedVisits.addAll(visitAsPerCompany.get(str));
            
        }
        update updateMergedVisits;
        upsert hitsUnderMergedVisits WMLL__Id__c;
        
    }
    
    //http://teamwork.concret.io/#tasks/16939331
    // Task 5th one.
    public void groupVisitsAsPerCompanyId(Map<string,List<Visit__c>> groupedVisits,List<String> companyIds){
            if(companyIds!=null  && companyIds.size()>0){
                List<Visit__c> lstOfVisits = [select Id,Id__c,Name,WMLL__PIs__c, WMLL__Datetime__c,WMLL__Duration__c from Visit__c where ((WMLL__Lead__r.Id__c!=null AND  WMLL__Lead__r.Id__c IN: companyIds) OR (WMLL__Account__r.Id__c!=null AND WMLL__Account__r.Id__c IN: companyIds) OR (WMLL__Company__r.Id__c!=null AND WMLL__Company__r.Id__c IN: companyIds)) limit 500000];
                
                if(lstOfVisits!=null){
                    for(Visit__c visits : lstOfVisits){
                        string compId = visits.Id__c.substring(0,visits.Id__c.length()-10);
                        if(groupedVisits.containsKey(compId)){
                            groupedVisits.get(compId).add(visits);
                        }else{
                            groupedVisits.put(compId,new list<Visit__c>{visits});
                        }
                    }
                }
            }
    }
    
    public Boolean visitMatchedAsPerVisitDate(Map<string,List<Visit__c>> mapOfVisits,Dto.Company allData,List<PageHit__c> listOfPageHits){
        DateTime dt  = Datetime.newInstance(allData.ddate * 1000);
        TimeZone tz = UserInfo.getTimeZone();
        if(mapOfVisits!=null && mapOfVisits.containsKey(allData.id)){
            for(Visit__c vst : mapOfVisits.get(allData.id)){
                if(sumVisitDateAndDuration(vst) == dt.AddSeconds(-(tz.getOffset(dt)/1000)) && vst.Id__c!=(allData.id+allData.ddate)){
                    if(returnCompleteDateTime(vst.WMLL__Datetime__c,vst.WMLL__Duration__c) < returnCompleteDateTime(dt.AddSeconds(-(tz.getOffset(dt)/1000)),convertDuration(allData.duration))){
                        migrateSameTimeSpanVisitData(vst,allData,listOfPageHits);
                    }
                    return false;
                }
            }
        }
        return true;
    }
    
    public DateTime sumVisitDateAndDuration(Visit__c existingVisit){
        List<String> lstOfDurationComponents = existingVisit.WMLL__Duration__c.split(':');
        return existingVisit.WMLL__Datetime__c.addMinutes(Integer.valueof(lstOfDurationComponents[1]));
    }
    // public DateTime sumVisitDateAndDurationTillSeconds(Visit__c existingVisitRecord){
    //     List<String> lstOfDurationComponents = existingVisitRecord.WMLL__Duration__c.split(':');
    //     return existingVisitRecord.WMLL__Datetime__c.addMinutes(Integer.valueof(lstOfDurationComponents[1])).addSeconds(Integer.valueof(lstOfDurationComponents[2]));
    // }
    
    public DateTime returnCompleteDateTime(DateTime dtm, String visitDuration){
        List<String> lstOfDurationComponents = visitDuration.split(':');
        return dtm.addMinutes(Integer.valueof(lstOfDurationComponents[1])).addSeconds(Integer.valueof(lstOfDurationComponents[2]));
    }
    
    public void migrateSameTimeSpanVisitData(Visit__c primaryVisit,Dto.Company dataToMigrateFromNewVisit,List<PageHit__c> listOfHits){
        
        String duration = convertDuration(dataToMigrateFromNewVisit.duration);
        
        List<string> durationForVisitToBeMerged = duration.split(':');
        List<string> durationForPrimaryVisit  = primaryVisit.WMLL__Duration__c.split(':');
        
        Integer hours = Integer.valueof(durationForPrimaryVisit[0])+Integer.valueof(durationForVisitToBeMerged[0]);
                
        Integer minutes = Integer.valueof(durationForPrimaryVisit[1])+Integer.valueof(durationForVisitToBeMerged[1]);
        
        Integer seconds = Integer.valueof(durationForPrimaryVisit[2])+Integer.valueof(durationForVisitToBeMerged[2]);
        
        Time tm = Time.newInstance(hours,minutes,seconds,0);
        
        
        primaryVisit.WMLL__Duration__c = String.valueof(tm).substring(0,String.valueof(tm).length()-5);
        primaryVisit.WMLL__PIs__c += dataToMigrateFromNewVisit.pis;
        
        updatePageHitsUnderMergedVisits(primaryVisit,dataToMigrateFromNewVisit,listOfHits);
        
        
        
    }
    
    public void updatePageHitsUnderMergedVisits(Visit__c originalVisit,Dto.Company dataToMigratePageHIts,List<PageHit__c> migrateHitsToOriginalVisit){
        //migrateHitsToOriginalVisit.add();
        Map<string,PageHit__c> mapOfViewedPages = new Map<string,PageHit__c>();
        for(Dto.WebPage pageDto : dataToMigratePageHIts.pages) {
            final PageHit__c pageHit = convertPage(pageDto);
            
            pageHit.WMLL__Id__c = pageDto.name+originalVisit.Id__c;
            pageHit.WMLL__Visit__c = originalVisit.Id;
            mapOfViewedPages.put(pageHit.WMLL__Id__c,pageHit);
            migrateHitsToOriginalVisit.add(pageHit);
        }

    }
    
    
    
    //Assigning leads to the selected Campaigns from setUp page
    public Boolean addLeadsToCampaign(List<Lead> leads) {
        if(String.isEmpty(this.settings.SelectedCampaign__c))
            return false;
        
        List<CampaignMember> membersToUpdate = new List<CampaignMember>();
        List<CampaignMember> membersToInsert = new List<CampaignMember>();
        Map<Id,Id> mapForCampaignMemberLeadId = new Map<Id,Id>(); 
        for(CampaignMember cm : [select LeadId,Id from CampaignMember Where Id=:settings.SelectedCampaign__c]){
           mapForCampaignMemberLeadId.put(cm.LeadId,cm.Id);
        }
        
        //For each lead, create a junction object between the campaign and the lead
        for(Lead lead : leads) {
            if(mapForCampaignMemberLeadId!=null && mapForCampaignMemberLeadId.containsKey(lead.Id)){
                CampaignMember member = new CampaignMember(
                CampaignId = this.settings.SelectedCampaign__c,
                LeadId = lead.Id);
                membersToUpdate.add(member);
            }else if(mapForCampaignMemberLeadId!=null){
                CampaignMember member = new CampaignMember(
                CampaignId = this.settings.SelectedCampaign__c,
                LeadId = lead.Id);
                membersToInsert.add(member);
            }
        }
        
        // upsert members Id;
        DMLManager.insertAsSystem(membersToInsert);
        DMLManager.updateAsSystem(membersToUpdate);
        return true;
    }
    // public void createErrorLog(DMLException ee,String systemMode){
    //     LeadLab_Error_Log__c errorLog = new LeadLab_Error_Log__c();
    //     errorLog.ExtendedStatus__c = ee.getMessage();
    //     errorLog.System_Mode__c = systemMode;
    //     errorLog.Apex_Class__c = 'Fetcher';
    //     insert errorLog;
    // }
    
    private SObject createNewModeObject(Mode mode, IVisit visitInfo) {
        if(mode.company) return visitInfo.getCompany();
        if(mode.account) return createAccount(visitInfo);
        if(mode.lead) return createLead(visitInfo);

        return visitInfo.getCompany();
    }

    private SObject createAccount(IVisit visitInfo) {
        final Company__c company = visitInfo.getCompany();
        
        final Account account = new Account();
        
        if(this.settings!=null && !String.isEmpty(this.settings.StandardTaskUser__c)){
            account.OwnerId = this.settings.StandardTaskUser__c;
        }
        account.Id__c = company.Id__c;
        account.Name = company.Name;
        account.Rating = DMLManager.returnDefaultPicklistValue(new Account(),'Rating') != null?
                         DMLManager.returnDefaultPicklistValue(new Account(),'Rating'):'Warm';
        //account.Branch__c = company.Branch__c;
        //account.BranchWz2008__c = company.BranchWz2008__c;
        account.BillingCity = company.City__c;
        account.ShippingCity = company.City__c;
        //account.CountryCode2__c = company.CountryCode2__c;
        account.BillingCountry = company.CountryName__c;
        account.ShippingCountry = company.CountryName__c;
        account.Website = company.Domain__c;
        
        //Below three fields added for release 2.0 on 05 april 17.
        account.LeadLab4SF_Annual_Revenue__c = company.AnnualRevenue__c;
        account.LeadLab4SF_No_of_Employees__c = company.Size__c;
        account.LeadLab4SF_Industry__c = company.Branch__c;
        //account.Email__c = company.Email__c;
        account.Fax = company.Fax__c;
        account.BillingStreet = company.Street__c;
        if(String.isNotEmpty(company.HouseNumber__c))
            account.BillingStreet += ' ' + company.HouseNumber__c;

        account.ShippingStreet = company.Street__c;
        if(String.isNotEmpty(company.HouseNumber__c))
            account.ShippingStreet += ' ' + company.HouseNumber__c;

        account.Phone = company.Phone__c;
        account.BillingState = company.Region__c;
        account.ShippingState = company.Region__c;
        //account.Size__c = company.Size__c;
        account.BillingPostalCode = company.Zip__c;
        account.ShippingPostalCode = company.Zip__c;
        return (SObject) account;
    }
    
    private SObject createLead(IVisit visitInfo)  {
        final Company__c company = visitInfo.getCompany();
        //Adding lead status in company record , because these leads coming from api call.
        company.Lead_Status__c = setting__c.getInstance(Constants.CUSTOM_SETTING_NAME).LeadStatus__c!=null?
                             setting__c.getInstance(Constants.CUSTOM_SETTING_NAME).LeadStatus__c:DEFAULT_STATUS;
        company.Rating__c = DMLManager.returnDefaultPicklistValue(new Lead(),'Rating') != null?
                            DMLManager.returnDefaultPicklistValue(new Lead(),'Rating'):'Warm';
        return leadManager.createNewLead(company);
    }

    private void matchVisitsToModeObjects(Map<String, Map<String, VisitDetail>> visitsByCompany,
                                          Map<String, SObject> modeObjectByExtId, Mode mode,Map<String, SObject> modeObjectByExtrnlId) {

        final List<Visit__c> allVisits = new List<Visit__c>();
        
        for(String companyId : visitsByCompany.keySet()) {
            for(String visitId : visitsByCompany.get(companyId).keySet()) {
                final Visit__c visit = visitsByCompany.get(companyId).get(visitId).visit;

                final SObject modeObject = modeObjectByExtId.get(companyId);
                if(mode.account) visit.Account__c = modeObject.Id;
                if(mode.lead) visit.Lead__c = modeObject.Id;
                if(mode.company) visit.Company__c = modeObject.Id;
 
                allVisits.add(visit);
                
                
            }
        }
        DMLManager.upsertByFieldAsSystem(allVisits, 'Id__c');
    }
    
    
    private void matchDetailsToParentVisit(Map<String, Map<String, VisitDetail>> visitsByCompany,
                                           DetailFacade details) {

        for(String companyId : visitsByCompany.keySet()) {

            for(String visitExtId : visitsByCompany.get(companyId).keySet()) {

                final VisitDetail visitInfo = visitsByCompany.get(companyId).get(visitExtId);
                updateDetails(visitInfo, details);
            }
        }
    }

    private void updateMatchedVisits(List<IVisit> visitInfos, DetailFacade details) {
        final List<Visit__c> visits = new List<Visit__c>();
        for(IVisit visitInfo : visitInfos)
            visits.add(visitInfo.getVisit());
		
        
        flsService.checkWithException(visits);
        DMLManager.upsertByFieldAsSystem(visits, 'Id__c');
		
        
        
        for(IVisit visitInfo : visitInfos)
            updateDetails(visitInfo, details);
    }

    private void updateDetails(IVisit visitInfo, DetailFacade details) {
        final Id visitId = visitInfo.getVisit().Id;



        for(PageHit__c pageHit : visitInfo.getPageHits()) {
            pageHit.Visit__c = visitId;
            details.pageHits.add(pageHit);
        }

        for(Referrer__c referrer : visitInfo.getReferrers()) {
            referrer.Visit__c = visitId;
            details.referrers.add(referrer);
        }

        // for(Campaign__c campaign : visitInfo.getCampaigns()) {
        //     campaign.Visit__c = visitId;
        //     details.campaigns.add(campaign);
        // }

        for(Milestone__c milestone : visitInfo.getMilestones()) {
            milestone.Visit__c = visitId;
            details.milestones.add(milestone);
        }

    }

    private class DetailFacade {

        private final SfUtilsLib.IFlsService flsService = SfUtilsLib.getFlsService();
        
        private final List<PageHit__c> pageHits = new List<PageHit__c>();
        private final List<Referrer__c> referrers = new List<Referrer__c>();
        // private final List<Campaign__c> campaigns = new List<Campaign__c>();
        private final List<Milestone__c> milestones = new List<Milestone__c>();


        private void persist() {

            flsService.checkWithException(pageHits);
            flsService.checkWithException(referrers);
            // flsService.checkWithException(campaigns);
            flsService.checkWithException(milestones);

            // The below cannot be done with a single SObject list since this leads to an error in case the single
            // list grows large
            // http://stackoverflow.com/questions/22194740/system-typeexception-cannot-have-more-than-10-chunks-in-a-single-operation
            // Number of Elements > 2000 && number if object types > 1 --> System.TypeException
            
            //DMLManager.insertAsSystem(pageHits);
            upsert pageHits WMLL__Id__c;
            
            
            DMLManager.insertAsSystem(referrers);
            // DMLManager.insertAsSystem(campaigns);
            // DMLManager.insertAsSystem(milestones);
            
            upsert milestones WMLL__Id__c;
        }
    }

    private void convertCompany(Dto.Company companyDto, VisitDetail visitInfo, Mode mode) {
        visitInfo.company.Name = trim(companyDto.name, Company__c.Name.getDescribe());
        visitInfo.company.Branch__c = companyDto.branch;
        visitInfo.company.BranchWz2008__c = (String.isNotEmpty(companyDto.branchWz2008)) ?
                                            Integer.valueOf(companyDto.branchWz2008) : null;
        visitInfo.company.City__c = companyDto.city;
        visitInfo.company.CountryCode2__c = companyDto.countryCode2;
        visitInfo.company.CountryName__c = companyDto.countryName;
        visitInfo.company.Domain__c = companyDto.domain;
        visitInfo.company.AnnualRevenue__c = companyDto.revenue; // mapped new field with Response.
        visitInfo.company.Email__c = companyDto.email;
        visitInfo.company.Fax__c = companyDto.fax;
        visitInfo.company.HouseNumber__c = companyDto.houseNumber;
        visitInfo.company.Id__c = companyDto.id;
        visitInfo.company.Phone__c = companyDto.phone;
        visitInfo.company.Region__c = companyDto.region;
        visitInfo.company.Size__c = companyDto.size;
        visitInfo.company.Street__c = companyDto.street;
        visitInfo.company.Zip__c = companyDto.zip;

        setCompanyOwnership(visitInfo, mode);
    }

    private void setCompanyOwnership(VisitDetail visitInfo, Mode mode) {

        if(!mode.company) return;
		if(String.isNotEmpty(settings.SelectedQueue__c))
            visitInfo.getCompany().OwnerId = settings.SelectedQueue__c;
        
        if(String.isNotEmpty(settings.StandardCompanyUser__c))
            visitInfo.getCompany().OwnerId = settings.StandardCompanyUser__c;

        
    }
    private string convertDuration(Integer duration){
        // if(duration>0.00){
        //     return duration.divide(60,2);
        // }else{
        //     return 0.00;
        // }
        if(duration>0){
            string hour = (duration/3600)<=9?'0'+(duration/3600):string.valueof(duration/3600);
            string minute = (math.mod(duration,3600)/60)<=9?'0'+math.mod(duration,3600)/60:string.valueof(math.mod(duration,3600)/60);
            string second = (math.mod(math.mod(duration,3600),60))<=9?'0'+math.mod(math.mod(duration,3600),60):string.valueof(math.mod(math.mod(duration,3600),60));
          return  hour+':'+minute+':'+second;
        }else{
            return '00:00:00';
        }
    }
    
    private VisitDetail convertVisit(Dto.Company companyDto) {

        final Company__c company = new Company__c();
        final VisitDetail detail = new VisitDetail();
        final Datetime visitDate = Datetime.newInstance(companyDto.ddate * 1000);
        final String visitName = visitDate.date().format() + ' (' + companyDto.name + ')';
        
        TimeZone tz = UserInfo.getTimeZone();// need to subtract the offset value from visitDate to get the actual visit date logged in wiredminds server.
        
        detail.visit.Name = trim(visitName, Visit__c.Name.getDescribe());
        detail.visit.PIs__c = companyDto.pis;
        detail.visit.Id__c = companyDto.id + companyDto.ddate;
        // detail.visit.Duration__c = string.valueOf(companyDto.duration); // added new field..
        detail.visit.Duration__c = convertDuration(companyDto.duration);
        detail.visit.Datetime__c = visitDate.AddSeconds(-(tz.getOffset(visitDate)/1000));
       
        final List<PageHit__c> pageHits = new List<PageHit__c>();
        Map<string,PageHit__c> mapOfViewedPages = new Map<string,PageHit__c>();
        for(Dto.WebPage pageDto : companyDto.pages) {
            final PageHit__c pageHit = convertPage(pageDto);
            //detail.visit.PIs__c += pageHit.Hits__c;
            pageHit.WMLL__Id__c = pageDto.name+detail.visit.Id__c;
            mapOfViewedPages.put(pageHit.WMLL__Id__c,pageHit);
            
            //detail.pageHits.add(pageHit);
        }
        
        if(mapOfViewedPages!=null && mapOfViewedPages.size()>0){
            for(PageHit__c hits : mapOfViewedPages.values()){
                detail.pageHits.add(hits);
            }
        }
        
        if(!Test.isRunningTest()){
            for(Dto.Referrer referrer : companyDto.referrers)
            detail.referrers.add(convertReferrer(referrer));
        }

        // for(Dto.Campaign campaign : companyDto.campaigns)
        //     detail.campaigns.add(convertCampaign(campaign));

        for(Dto.Milestone milestone : companyDto.milestones){
            Milestone__c newMilestone = convertMilestone(milestone);
            newMilestone.WMLL__Id__c = milestone.name+detail.visit.Id__c;
            detail.milestones.add(newMilestone);
        }
        return detail;
    }

    private PageHit__c convertPage(Dto.Webpage page) {
        final PageHit__c pageHit = new PageHit__c();
        pageHit.Hits__c = page.pis;
        // pageHit.Page__c = trim(page.name, PageHit__c.Page__c.getDescribe());
        pageHit.Name = trim(page.name, PageHit__c.Name.getDescribe());

        return pageHit;
    }

    private Referrer__c convertReferrer(Dto.Referrer referrerDto) {
        final Referrer__c referrer = new Referrer__c();
        referrer.Url__c = trim(referrerDto.url, Referrer__c.Url__c.getDescribe());
        referrer.Name = trim(referrerDto.url, Referrer__c.Name.getDescribe());
        referrer.Count__c = referrerDto.count;
        return referrer;
    }

    // private Campaign__c convertCampaign(Dto.Campaign campaignDto) {
    //     final Campaign__c campaign = new Campaign__c();
    //     campaign.Name__c = trim(campaignDto.name, Campaign__c.Name__c.getDescribe());
    //     campaign.Name = trim(campaignDto.name, Campaign__c.Name.getDescribe());
    //     campaign.Count__c = campaignDto.count;
    //     return campaign;
    // }

    private Milestone__c convertMilestone(Dto.Milestone milestoneDto) {
        final Milestone__c milestone = new Milestone__c();
        milestone.Name__c = trim(milestoneDto.name, Milestone__c.Name__c.getDescribe());
        milestone.Name = trim(milestoneDto.name, Milestone__c.Name.getDescribe());
        milestone.Count__c = milestoneDto.count;
        return milestone;
    }

    private String trim(String str, Schema.DescribeFieldResult fieldInfo) {
        if(String.isEmpty(str) || fieldInfo.getLength() >= str.length())
            return str;

        return str.subString(0, fieldInfo.getLength());
    }

    private class VisitDetail implements IVisit {
        private final Visit__c visit = new Visit__c();
        private final Company__c company = new Company__c();
        private final List<PageHit__c> pageHits = new List<PageHit__c>();
        private final List<Referrer__c> referrers = new List<Referrer__c>();
        // private final List<Campaign__c> campaigns = new List<Campaign__c>();
        private final List<Milestone__c> milestones = new List<Milestone__c>();

        public Visit__c getVisit() {
            return this.visit;
        }
        public Company__c getCompany() {
            return this.company;
        }
        public List<PageHit__c> getPageHits() {
            return this.pageHits;
        }
        public List<Referrer__c> getReferrers() {
            return this.referrers;
        }
        // public List<Campaign__c> getCampaigns() {
        //     return this.campaigns;
        // }
        public List<Milestone__c> getMilestones() {
            return this.milestones;
        }
    }
}