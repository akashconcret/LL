/**
 * Matchers for parameters
 */

public with sharing class loli_mock_ParameterMatcher {

    /**
     * Any string matcher
     */
    public class AnyStringMatcher implements loli_mock_IMatcher {

        public Boolean matches(Object compare) {
            if ((compare instanceof String)) {
                return true;
            } else {
                return false;
            }
        }

    }

    /**
     * Any integer matcher
     */
    public class AnyIntegerMatcher implements loli_mock_IMatcher {

        public Boolean matches(Object compare) {
            if ((compare instanceof Integer)) {
                return true;
            } else {
                return false;
            }
        }

    }

    /**
     * Any boolean matcher
     */
    public class AnyBooleanMatcher implements loli_mock_IMatcher {

        public Boolean matches(Object compare) {
            if ((compare instanceof Boolean)) {
                return true;
            } else {
                return false;
            }
        }

    }

    /**
     * Any date matcher
     */
    public class AnyDateMatcher implements loli_mock_IMatcher {

        public Boolean matches(Object compare) {
            if ((compare instanceof Date)) {
                return true;
            } else {
                return false;
            }
        }

    }

    /**
     * Any datetime matcher
     */
    public class AnyDateTimeMatcher implements loli_mock_IMatcher {

        public Boolean matches(Object compare) {
            if ((compare instanceof DateTime)) {
                return true;
            } else {
                return false;
            }
        }

    }

    /**
     * Any decimal matcher
     */
    public class AnyDecimalMatcher implements loli_mock_IMatcher {

        public Boolean matches(Object compare) {
            if ((compare instanceof Decimal)) {
                return true;
            } else {
                return false;
            }
        }

    }

    /**
     * Any double matcher
     */
    public class AnyDoubleMatcher implements loli_mock_IMatcher {

        public Boolean matches(Object compare) {
            if ((compare instanceof Double)) {
                return true;
            } else {
                return false;
            }
        }

    }

    /**
     * Any id matcher
     */
    public class AnyIdMatcher implements loli_mock_IMatcher {

        public Boolean matches(Object compare) {
            if ((compare instanceof ID)) {
                return true;
            } else {
                return false;
            }
        }

    }

    /**
     * Any long matcher
     */
    public class AnyLongMatcher implements loli_mock_IMatcher {

        public Boolean matches(Object compare) {
            if ((compare instanceof Long)) {
                return true;
            } else {
                return false;
            }
        }

    }

    /**
     * Any time matcher
     */
    public class AnyTimeMatcher implements loli_mock_IMatcher {

        public Boolean matches(Object compare) {
            if ((compare instanceof Time)) {
                return true;
            } else {
                return false;
            }
        }

    }

    /**
     * Any iterable matcher
     */
    public class AnyIterableMatcher implements loli_mock_IMatcher {

        public Boolean matches(Object compare) {
            if ((compare instanceof Iterable<Object>)) {
                return true;
            } else {
                return false;
            }
        }

    }

    /**
     * Any object matcher
     */
    public class AnyObjectMatcher implements loli_mock_IMatcher {

        public Boolean matches(Object compare) {
            return true;
        }

    }

    /**
     * Any sobject matcher
     */
    public class AnySObjectMatcher implements loli_mock_IMatcher {

        public Boolean matches(Object compare) {
            if ((compare instanceof sObject)) {
                return true;
            } else {
                return false;
            }
        }

    }

    /**
     * Soql list matcher
     */
    public class SoqlListMatcher implements loli_mock_IMatcher {

        private List<sObject> soqlListBase;

        public SoqlListMatcher(List<sObject> soqlListBase) {
            this.soqlListBase = soqlListBase;
        }

        public Boolean matches(Object compare) {
            if ((compare instanceof List<sObject>)) {
                List<sObject> soqlListCompare = (List<sObject>) compare;
                return areSObjectTypesMatching(soqlListBase, soqlListCompare) && areSoqlListsMatching(soqlListBase, soqlListCompare);
            } else {
                return false;
            }
        }

        /**
         * Checks if sObjects are of same type
         */
        private Boolean areSObjectTypesMatching(List<sObject> soqlListBase, List<sObject> soqlListCompare) {
            if (soqlListBase != null && soqlListCompare != null && !soqlListBase.isEmpty() && !soqlListCompare.isEmpty()) {
                sObject sObjectBase = soqlListBase.get(0);
                sObject sObjectCompare = soqlListCompare.get(0);
                return soqlListBase.getSObjectType() == soqlListCompare.getSObjectType();
            }
            return true;
        }

        /**
         * Checks if sObjects have same ids
         */
        private Boolean areSoqlListsMatching(List<sObject> soqlListBase, List<sObject> soqlListCompare) {
            Map<Id, sObject> soqlIdMapBase = new Map<Id, sObject>(soqlListBase);
            Map<Id, sObject> soqlIdMapCompare = new Map<Id, sObject>(soqlListCompare);
            if (soqlIdMapBase != null) {
                if (soqlIdMapCompare != null && soqlIdMapBase.size() == soqlIdMapCompare.size()) {
                    for (Id idLoop : soqlIdMapBase.keySet()) {
                        if (!soqlIdMapCompare.containsKey(idLoop)) {
                            return false;
                        }
                    }
                    return true;
                }
            } else if (soqlIdMapCompare != null) {
                return false;
            }
            return true;
        }

    }

    /**
     * Any value matcher
     */
    public class AnyValueMatcher implements loli_mock_IMatcher {

        private Object valueBase;

        public AnyValueMatcher(Object valueBase) {
            this.valueBase = valueBase;
        }

        public Boolean matches(Object compare) {
            return valueBase == compare;
        }

    }

}