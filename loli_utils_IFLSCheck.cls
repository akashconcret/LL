public interface loli_utils_IFLSCheck {

    /**
     * Checks the provided sObject for the provided flsType
     * Throws an exception in case flsType is not fulfilled
     */
    void checkWithException(loli_utils_Enum.FlsType flsType);

    /**
     * Checks the provided sObject for the provided flsType
     * Returns true when fulfilled, false otherwise
     */
    Boolean check(loli_utils_Enum.FlsType flsType);


    /**
     * Replaces all fields that do not fulfill the provided flsType with null
     */
    void replaceWithNull(loli_utils_Enum.FlsType flsType);

}