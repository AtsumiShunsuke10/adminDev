@isTest
public with sharing class filePreviewControllerTest {

    @isTest static void  filePreviewControllerTest(){
        Account acct = new Account(Name='TEST_ACCT');
        insert acct;

        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
            );
        insert contentVersion;    
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ];

        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = acct.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;

        
        Test.setCurrentPageReference(new PageReference('Page.myPage'));
        System.currentPageReference().getParameters().put('recordId', acct.id);

        filePreviewController PA_Inquiry = new filePreviewController();
        PA_Inquiry.init();
    }
}