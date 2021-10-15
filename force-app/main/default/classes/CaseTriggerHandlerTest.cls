@isTest(SeeAllData=false)
private class CaseTriggerHandlerTest {

    @TestSetup
    static void init() {
    }

    @isTest
    static void CaseTriggerHandlerTest() {
        User testUserAG = TestUtil.createUser('AGUSER', 'コールセンターAG');
        User testUserSV = TestUtil.createUser('SVUSER', 'コールセンターSV');
        Case c = TestUtil.createCase(testUserSV.Id);

        System.runAs(testUserAG) {
            Test.startTest();
            try {
                update c;
            } catch(Exception e) {
                Boolean result = e.getMessage().contains('所有者が異なるため更新不可');
                System.assertEquals(true, result);
            }   
            Test.stopTest();    
        }        
    }
}