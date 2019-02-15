@IsTest
private class loli_utils_MocksTest {
    private static TestMethod void loliutilsMock(){
        loli_utils_Mocks utilMock = new loli_utils_Mocks();
        loli_utils_Mocks.PlatformLimitMock platformLimit = new loli_utils_Mocks.PlatformLimitMock();
        platformLimit.getAvailableBatchSlots();
        platformLimit.getAvailableScheduleSlots();
        loli_utils_Mocks.PlatformMock platform = new loli_utils_Mocks.PlatformMock();
        loli_utils_Mocks.FlsCheckMock flsCheck = new loli_utils_Mocks.FlsCheckMock();
    }
}