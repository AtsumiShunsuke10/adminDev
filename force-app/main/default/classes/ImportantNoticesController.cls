public without sharing class ImportantNoticesController {
    public List<NoticesMaster__c> NoticeList {get; set;}

	public ImportantNoticesController(){
	
		NoticeList = [SELECT Id, Title__c, Content__c,SortOrder__c FROM NoticesMaster__c WHERE NoticeType__c = '重要なお知らせ' ORDER BY SortOrder__c DESC];
    }

}