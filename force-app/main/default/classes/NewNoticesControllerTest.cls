@istest
private class NewNoticesControllerTest {
    @istest static void test1() {
        Test.startTest();
        NoticesMaster__c sobj = new NoticesMaster__c(
            NoticeType__c = '重要なお知らせ'

        );
        insert sobj;
        NewNoticesController controller= new NewNoticesController();

        Test.stopTest();
        system.assert(controller.NoticeList.isEmpty() );
    }

    @istest static void test2() {
        Test.startTest();
        NoticesMaster__c sobj = new NoticesMaster__c(
            NoticeType__c = '新着のお知らせ'

        );
        insert sobj;
        NewNoticesController controller= new NewNoticesController();

        Test.stopTest();
        
        system.assert(!controller.NoticeList.isEmpty());
    }
}