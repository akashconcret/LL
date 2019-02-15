public with sharing class Mode {

    public enum Type {
        Lead, Company, Account
    }

    public static Map<Type, String> TypeLabel = new Map<Type, String> {
        Type.Company => Label.CompanyMode,
        Type.Lead => Label.AutomaticLeads,
        Type.Account => Label.AutomaticAccount
    };

    public static Map<Type, String> ObjectName = new Map<Type, String> {
        Type.Company => Company__c.SObjectType.getDescribe().getName(),
        Type.Lead => Lead.SObjectType.getDescribe().getName(),
        Type.Account => Account.SObjectType.getDescribe().getName()
    };

    public Boolean lead {get; private set;}
    public Boolean account {get; private set;}
    public Boolean company {get; private set;}

    private final Setting__c settings;

    public Mode() {
        this(Setting__c.getInstance(Constants.CUSTOM_SETTING_NAME));
    }

    public Mode(Setting__c settings) {
        this.settings = settings;
        checkModes();
    }

    public void checkModes() {
        this.lead = settings.SelectedMode__c == Type.Lead.name();
        this.account = settings.SelectedMode__c == Type.Account.name();
        this.company = settings.SelectedMode__c == Type.Company.name();
    }

    public void setMode(String value) {
        this.settings.SelectedMode__c = value;
        checkModes();
    }

    public Type getModeType() {
        if(this.lead) return Type.Lead;
        if(this.account) return Type.Account;
        if(this.company) return Type.Company;
        return null;
    }

    public String getMode() {
        return settings.SelectedMode__c;
    }
}