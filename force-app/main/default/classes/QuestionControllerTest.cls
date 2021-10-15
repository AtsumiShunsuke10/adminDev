@isTest
private class QuestionControllerTest {

    @isTest
    static void testgetList1(){
        QuestionController qc = new QuestionController();
        Question__c qstn = new Question__c();
        qstn.Category__c = '対象者';
        qstn.Title__c = '対象者タイトル';        
        qstn.Text__c = '対象者本文';
        insert qstn;

        Test.startTest();
        qc.getList();
        Test.stopTest();
        System.assertEquals('対象者', qstn.Category__c);
        System.assertEquals('対象者タイトル', qstn.Title__c);        
        System.assertEquals('対象者本文', qstn.Text__c);
    }
    
    @isTest
    static void testgetList2(){
        QuestionController qc = new QuestionController();
        Question__c qstn = new Question__c();
        qstn.Category__c = 'オンライン申請の住所について';
        qstn.Title__c = 'オンライン申請の住所タイトル';        
        qstn.Text__c = 'オンライン申請の住所本文';
        insert qstn;

        Test.startTest();
        qc.getList();
        Test.stopTest();
        System.assertEquals('オンライン申請の住所について', qstn.Category__c);
        System.assertEquals('オンライン申請の住所タイトル', qstn.Title__c);
        System.assertEquals('オンライン申請の住所本文', qstn.Text__c);
    }
    
    @isTest
    static void testgetList3(){
        QuestionController qc = new QuestionController();
        Question__c qstn = new Question__c();
        qstn.Category__c = '営業許可書について';
        qstn.Title__c = '営業許可書タイトル';
        qstn.Text__c = '営業許可書本文';
        insert qstn;

        Test.startTest();
        qc.getList();
        Test.stopTest();
        System.assertEquals('営業許可書について', qstn.Category__c);
        System.assertEquals('営業許可書タイトル', qstn.Title__c);
        System.assertEquals('営業許可書本文', qstn.Text__c);
    }
    
    @isTest
    static void testgetList4(){
        QuestionController qc = new QuestionController();
        Question__c qstn = new Question__c();
        qstn = new Question__c();
        qstn.Category__c = '申請手続き';
        qstn.Title__c = '申請手続きタイトル';
        qstn.Text__c = '申請手続き本文';
        insert qstn;

        Test.startTest();
        qc.getList();
        Test.stopTest();
        System.assertEquals('申請手続き', qstn.Category__c);
        System.assertEquals('申請手続きタイトル', qstn.Title__c);
        System.assertEquals('申請手続き本文', qstn.Text__c);
    }
    
    @isTest
    static void testgetList5(){
        QuestionController qc = new QuestionController();
        Question__c qstn = new Question__c();
        qstn.Category__c = '支給額の算定';
        qstn.Title__c = '支給額の算定タイトル';
        qstn.Text__c = '支給額の算定本文';
        insert qstn;

        Test.startTest();
        qc.getList();
        Test.stopTest();
        System.assertEquals('支給額の算定', qstn.Category__c);
        System.assertEquals('支給額の算定タイトル', qstn.Title__c);
        System.assertEquals('支給額の算定本文', qstn.Text__c);
    }
}