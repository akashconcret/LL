public with sharing class SfUtilsLib {

	/**
	 * Service factories
	 */
	public static IFlsService getFlsService() { 
		if(Test.isRunningTest()) return new FlsServiceMock();
	
		return new FlsServiceImpl(); 
	}

	/**
	 * API wrapperes
	 */
	public interface IFlsService {
		void checkWithException(SObject sObj);
		Boolean checkWithMessage(SObject sObj);
		Boolean check(SObject sObj);
		void replaceWithNull(SObject sObj);

		void checkWithException(List<SObject> sObjs);
		Boolean checkWithMessage(List<SObject> sObj);
		Boolean check(List<SObject> sObjs);
		void replaceWithNull(List<SObject> sObjs);
	}

	public abstract class GenericException extends Exception {}
	public class AccessVoilationException extends GenericException {}

	public virtual class FlsServiceImpl implements IFlsService {

		private final loli_utils_Enum.FlsType flsAccess = loli_utils_Enum.FlsType.access;
		private final String errorMessage;

		public FlsServiceImpl() { this(Label.NotEnoughAccess); }

		public FlsServiceImpl(String errorMessage) { this.errorMessage = errorMessage; }

		public void checkWithException(List<SObject> sObjs) {
			try{
				getFlsChecker(sObjs).checkWithException(flsAccess);
			} catch(loli_utils_Exceptions.AccessTypeViolatedException ex) {
				throw new AccessVoilationException(ex);
			}
		}
		public Boolean checkWithMessage(List<SObject> sObjs) {
			final Boolean accessible = getFlsChecker(sObjs).check(flsAccess);
			if(!accessible) 
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.NotEnoughAccess));

			return accessible;
		}

		public Boolean check(List<SObject> sObjs) {
			return getFlsChecker(sObjs).check(flsAccess);
		}
		public void replaceWithNull(List<SObject> sObjs) {
			getFlsChecker(sObjs).replaceWithNull(flsAccess);
		}

		public void checkWithException(SObject sObj) { checkWithException(asList(sObj)); }
		public Boolean checkWithMessage(SObject sObj) { return checkWithMessage(asList(sObj)); }
		public Boolean check(SObject sObj) { return check(asList(sObj)); }
		public void replaceWithNull(SObject sObj) { replaceWithNull(asList(sObj)); }

		protected loli_utils_IFLSCheck getFlsChecker(List<SObject> sObjs) {
			return new loli_utils_SFObjectListFLSCheck(sObjs);
		}

		private List<SObject> asList(SObject sObj) { return new List<SObject>{ sObj }; }
	}

	//Mocks
	public class FlsServiceMock implements IFlsService {
		public void checkWithException(SObject sObj) {}
		public Boolean checkWithMessage(SObject sObj) {return true;}
		public Boolean check(SObject sObj) {return true;}
		public void replaceWithNull(SObject sObj) {}
		public void checkWithException(List<SObject> sObjs) {}
		public Boolean checkWithMessage(List<SObject> sObj) {return true;}
		public Boolean check(List<SObject> sObjs) {return true;}
		public void replaceWithNull(List<SObject> sObjs) {}
	}
}