@isTest
public class customLookUpCtrlTest {
    @isTest static void testfetchLookUpValues1() {
        test.startTest();
        Account acc= new Account(name='test1');
        insert acc;
        String searchKeyWord='test1　t';
        String ObjectName='Account';
        String filedName='name,Type';
        String relatedFiledname='';
        String relatedFiledId='';
        String addWhereCondtions=' and name!=null';
        String orderByName='name';
        String limitStr='5';
        String splitSearchKeyWord=' ';
        String andOrStr='and';
        String showFieldName='name,Type';
        customLookUpCtrl.fetchLookUpValues(searchKeyWord, ObjectName,filedName,relatedFiledname,relatedFiledId,addWhereCondtions,orderByName,limitStr,splitSearchKeyWord,andOrStr,showFieldName);
        test.stopTest();
    }
      @isTest static void testfetchLookUpValues2() {
        test.startTest();
          Account acc= new Account(name='test1');
        insert acc;
        String searchKeyWord='test１　tt';
        String ObjectName='Account';
        String filedName='name,Type';
        String relatedFiledname='';
        String relatedFiledId='';
        String addWhereCondtions=' and name!=null';
        String orderByName='name';
        String limitStr='5';
        String splitSearchKeyWord='　';
        String andOrStr='or';
        String showFieldName='name,Type';
        customLookUpCtrl.fetchLookUpValues(searchKeyWord, ObjectName,filedName,relatedFiledname,relatedFiledId,addWhereCondtions,orderByName,limitStr,splitSearchKeyWord,andOrStr,showFieldName);
        test.stopTest();
    }
    @isTest static void testfetchLookUpValues3() {
        test.startTest();
          Account acc= new Account(name='test1');
        insert acc;
        String searchKeyWord='';
        String ObjectName='Account';
        String filedName='name,Type';
        String relatedFiledname='';
        String relatedFiledId='';
        String addWhereCondtions=' and name!=null';
        String orderByName='name';
        String limitStr='5';
        String splitSearchKeyWord='';
        String andOrStr='or';
        String showFieldName='name,Type';
        customLookUpCtrl.fetchLookUpValues(searchKeyWord, ObjectName,filedName,relatedFiledname,relatedFiledId,addWhereCondtions,orderByName,limitStr,splitSearchKeyWord,andOrStr,showFieldName);
        test.stopTest();
    }
    @isTest static void testfetchLookUpValues4() {
        test.startTest();
          Account acc= new Account(name='test1');
        insert acc;
        String searchKeyWord='';
        String ObjectName='Account';
        String filedName='accname__c';
        String relatedFiledname='';
        String relatedFiledId='';
        String addWhereCondtions=' and name!=null';
        String orderByName='name';
        String limitStr='5';
        String splitSearchKeyWord='';
        String andOrStr='or';
        String showFieldName='accname__c';
        try{
            customLookUpCtrl.fetchLookUpValues(searchKeyWord, ObjectName,filedName,relatedFiledname,relatedFiledId,addWhereCondtions,orderByName,limitStr,splitSearchKeyWord,andOrStr,showFieldName);
        }catch(Exception e){
            
        }
        test.stopTest();
    }
}