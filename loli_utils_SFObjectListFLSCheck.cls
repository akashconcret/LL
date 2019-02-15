public with sharing class loli_utils_SFObjectListFLSCheck implements loli_utils_IFLSCheck {

    private List<SObject> sobjectsToCheck;

    public loli_utils_SFObjectListFLSCheck(List<SObject> sobjectsToCheck) {
        this.sobjectsToCheck = sobjectsToCheck;
    }

    public void checkWithException(loli_utils_Enum.FlsType flsType) {
        system.debug('sobjectsToCheck : '+sobjectsToCheck);
        for (SObject sObjectLoop : sobjectsToCheck) {
            new loli_utils_SFObjectFLSCheck(sObjectLoop).checkWithException(flsType);
        }
    }

    public Boolean check(loli_utils_Enum.FlsType flsType) {
        for (SObject sObjectLoop : sobjectsToCheck) {
            if (!new loli_utils_SFObjectFLSCheck(sObjectLoop).check(flsType)) {
                return false;
            }
        }
        return true;
    }


    public void replaceWithNull(loli_utils_Enum.FlsType flsType) {
        for (SObject sObjectLoop : sobjectsToCheck) {
            new loli_utils_SFObjectFLSCheck(sObjectLoop).replaceWithNull(flsType);
        }
    }

}