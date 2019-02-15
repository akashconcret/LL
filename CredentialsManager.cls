public with sharing class CredentialsManager {

    private final static Logger.IService log = 
        Logger.getPrettyDefault(CredentialsManager.class);

	private Setting__c settings;
	
	public Setting__c getSettings() {
		if (this.settings != null) {
			return this.settings;
		}
		this.settings = Setting__c.getInstance(Constants.CUSTOM_SETTING_NAME);
		if(this.settings == null) {
			this.settings = new Setting__c(Name = Constants.CUSTOM_SETTING_NAME);
			this.settings.EndpointURI__c = Constants.DEFAULT_ENDPOINT;
        	this.settings.SelectedScoringProfileId__c = Constants.DEFAULT_PARAM_SCORE_PROFILE_ID;
        	this.settings.SelectedMode__c = Mode.Type.Company.name();
        	this.settings.TimeUntilDuedate__c = 7;
		}
		return this.settings;
	}
	
	public void setSettings(String publicCustomNumber, String token) {

		log.debug('publicCustomNumber', publicCustomNumber);
		log.debug('token', token);
		
		this.settings = getSettings();
		this.settings.PublicCustomNumber__c = publicCustomNumber;
		this.settings.Token__c = token;

		log.debug('Set settings: ', this.settings);

		DMLManager.upsertAsUser(this.settings);
	}	
	public void setSettingsTechnicalUser(String username, String password, String endpointURI) {
		this.settings = getSettings();
		this.settings.EndpointURI__c = endpointURI;
	}	
}