public with sharing class Matcher implements Service {

    public interface Service {
        Boolean match(Manager.IVisit visitInfo);

    }

    private final Logger.IService log = Logger.getDefault(Matcher.class);

    private final IFacadeService existingMap;

    public Matcher() {
        this(new AccountLeadFacade());
    }

    public Matcher(IFacadeService facade) {
        this.existingMap = facade;
    }

    public Boolean match(Manager.IVisit visitInfo) {
        return matchOnId(visitInfo) || fuzzyMatch(visitInfo);
    }

    private Boolean matchOnId(Manager.IVisit visitInfo) {
        if(!existingMap.hasKey(visitInfo.getCompany().Id__c)) return false;

        existingMap.convert(visitInfo);
        return true;
    }

    private Boolean fuzzyMatch(Manager.IVisit visitInfo) {
        return existingMap.fuzzyMatch(visitInfo);
    }


    public interface IFacadeService {
        Boolean hasKey(String externalId);
        void convert(Manager.IVisit visitInfo);
        Boolean fuzzyMatch(Manager.IVisit visitInfo);
    }

    public class AccountLeadFacade implements IFacadeService {

        private final Logger.IService log = Logger.getDefault(AccountLeadFacade.class);

        private final Integer queryLimit = 2000;

        private final Map<String, Account> accountsByExtId = new Map<String, Account>();
        private final Map<String, Lead> leadsByExtId = new Map<String, Lead>();
        private final Map<String, LegalForm__c> legalForms = new Map<String, LegalForm__c>();

        public AccountLeadFacade() {
            populateAccounts();
            populateLeads();
            populateLegalForms();
        }

        public AccountLeadFacade(Map<String, Account> accounts,
                                 Map<String, Lead> leads,
                                 Map<String, LegalForm__c> legalForms) {
            this();
            this.accountsByExtId.putAll(accounts);
            this.leadsByExtId.putAll(leads);
            this.legalForms.putAll(legalForms);
        }
        public Boolean hasKey(String externalId) {
            return accountsByExtId.containsKey(externalId) || leadsByExtId.containsKey(externalId);
        }

        public void convert(Manager.IVisit visitInfo) {
            //Account has precedence
            final String externalId = visitInfo.getCompany().Id__c;
            if(accountsByExtId.containsKey(externalId))
                visitInfo.getVisit().Account__c = accountsByExtId.get(externalId).Id;
            else if(leadsByExtId.containsKey(externalId))
                visitInfo.getVisit().Lead__c = leadsByExtId.get(externalId).Id;
            visitInfo.getVisit().Company__c = null;
        }

        private void populateLegalForms() {
            for(LegalForm__c legalForm : [Select Id, LegalForm__c,
                                          FastMatch__c From LegalForm__c Limit : queryLimit])
                this.legalForms.put(legalForm.FastMatch__c, legalForm);
        }

        private void populateAccounts() {
            final List<Account> accounts = [Select Id, Name, BillingPostalCode, ShippingPostalCode,
                                            BillingCountry, ShippingCountry, BillingCity, ShippingCity, Website,
                                            Id__c From Account limit :queryLimit];

            for(Account account : accounts) {
                if(String.isNotEmpty(account.Id__c))
                    accountsByExtId.put(account.Id__c, account);
                else
                    accountsByExtId.put(account.Id, account);
            }

            log.debug('Account external IDs: ', accountsByExtId.keySet());
        }

        private void populateLeads() {
            final List<Lead> leads = [Select Id, Name, PostalCode, Country, City, Website, Company,
                                      Id__c From Lead limit :queryLimit];

            for(Lead lead : leads) {
                if(String.isNotEmpty(lead.Id__c))
                    leadsByExtId.put(lead.Id__c, lead);
                else
                    leadsByExtId.put(lead.Id, lead);
            }

            log.debug('Lead external IDs: ', leadsByExtId.keySet());
        }

        public Boolean fuzzyMatch(Manager.Ivisit visitInfo) {

            final Company__c company = visitInfo.getCompany();
            final String companyName = Utils.asciiFolding(company.Name);

            for(String extId : accountsByExtId.keySet()) {
                final Account account = accountsByExtId.get(extId);

                if(matchNames(company, account))
                    return assignVisitToAccount(visitInfo.getVisit(), account);

                if(matchAddress(company, account) && matchDomain(company, account))
                    return assignVisitToAccount(visitInfo.getVisit(), account);

                // if(matchFuzzyName(company, account))
                //     return assignVisitToAccount(visitInfo.getVisit(), account);
            }

            for(String extId : leadsByExtId.keySet()) {
                final Lead lead = leadsByExtId.get(extId);

                if(matchNames(company, lead))
                    return assignVisitToLead(visitInfo.getVisit(), lead);

                if(matchAddress(company, lead) && matchDomain(company, lead))
                    return assignVisitToLead(visitInfo.getVisit(), lead);

                // if(matchFuzzyName(company, lead))
                //     return assignVisitToLead(visitInfo.getVisit(), lead);
            }

            return false;
        }

        private Boolean matchNames(Company__c company, Account account) {
            return account.Name.equalsIgnoreCase(company.Name) ||
                account.Name.equalsIgnoreCase(Utils.asciiFolding(company.Name)) ||
                Utils.asciiFolding(account.Name).equalsIgnoreCase(company.Name);
        }

        private Boolean matchNames(Company__c company, Lead lead) {
            return lead.Company.equalsIgnoreCase(company.Name) ||
                lead.Company.equalsIgnoreCase(Utils.asciiFolding(company.Name)) ||
                Utils.asciiFolding(lead.Company).equalsIgnoreCase(company.Name);
        }

        private Boolean assignVisitToAccount(Visit__c visit, Account account) {
            visit.Account__c = account.Id; return true;
        }

        private Boolean assignVisitToLead(Visit__c visit, Lead lead) {
            visit.Lead__c = lead.Id; return true;
        }

        // private Boolean matchFuzzyName(Company__c company, Account account) {
        //     for(String legalForm : legalForms.keySet()) {
        //         if(!company.Name.toLowerCase().trim().endsWith(legalForm))
        //             continue;

        //         return account.Name.toLowerCase().trim().replace(legalForm, '').equals(
        //                   company.Name.toLowerCase().trim().replace(legalForm, ''));
        //     }

        //     return false;
        // }

        // private Boolean matchFuzzyName(Company__c company, Lead lead) {
        //     for(String legalForm : legalForms.keySet()) {
        //         if(!company.Name.toLowerCase().trim().endsWith(legalForm))
        //             continue;

        //         return lead.Company.toLowerCase().trim().replace(legalForm, '').equals(
        //                   company.Name.toLowerCase().trim().replace(legalForm, ''));
        //     }

        //     return false;
        // }

        private Boolean matchAddress(Company__c company, Account account) {

            final Boolean zipMatch = match(company.Zip__c, account.BillingPostalCode) ||
                                     match(company.Zip__c, account.ShippingPostalCode);
            final Boolean countryMatch = match(company.CountryName__c, account.BillingCountry) ||
                                         match(company.CountryName__c, account.ShippingCountry);
            final Boolean cityMatch = match(company.City__c, account.BillingCity) ||
                                      match(company.City__c, account.ShippingCity);

            return zipMatch && countryMatch && cityMatch;
        }

        private Boolean matchAddress(Company__c company, Lead lead) {

            final Boolean zipMatch = match(company.Zip__c, lead.PostalCode);
            final Boolean countryMatch = match(company.CountryName__c, lead.Country);
            final Boolean cityMatch = match(company.City__c, lead.City);

            return zipMatch && countryMatch && cityMatch;
        }

        private Boolean matchDomain(Company__c company, Account account) {
            return matchPartial(company.Domain__c, account.Website);
        }

        private Boolean matchDomain(Company__c company, Lead lead) {
            return matchPartial(company.Domain__c, lead.Website);
        }

        private Boolean match(String s1, String s2) {
            return notEmpty(s1, s2) && s1.equalsIgnoreCase(s2);
        }

        private Boolean matchPartial(String s1, String s2) {
            return notEmpty(s1, s2) && (s1.containsIgnoreCase(s2) || s2.containsIgnoreCase(s1));
        }

        private Boolean notEmpty(String s1, String s2) {
            return String.isNotEmpty(s1) && String.isNotEmpty(s2);
        }
    }
}