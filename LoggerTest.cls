@IsTest
public with sharing class LoggerTest {

	@isTest
	private static void loggerTest() {
		Logger.getPrettyDefault(LoggerTest.class);

		Logger.IService log = Logger.getBuilder(LoggerTest.class)
			.setErrorLogLevel()
			.setWarnLogLevel()
			.setInfoLogLevel()
			.setDebugLogLevel()
			.setFineLogLevel()
			.setFinerLogLevel()
			.setFinestLogLevel()
			.setStandardPrinting()
			.setJSONPrinting()
			.setJSONPrettyPrinting().build();

		log.error('message');
		log.error('message', new Account());
		log.error('message', new List<Account>{ new Account() });
		log.warn('message');
		log.warn('message', new Account());
		log.warn('message', new List<Account>{ new Account() });
		log.info('message');
		log.info('message', new Account());
		log.info('message', new List<Account>{ new Account() });
		log.debug('message');
		log.debug('message', new Account());
		log.debug('message', new List<Account>{ new Account() });
		log.fine('message');
		log.fine('message', new Account());
		log.fine('message', new List<Account>{ new Account() });
		log.finer('message');
		log.finer('message', new Account());
		log.finer('message', new List<Account>{ new Account() });
		log.finest('message');
		log.finest('message', new Account());
		log.finest('message', new List<Account>{ new Account() });		
	}
}