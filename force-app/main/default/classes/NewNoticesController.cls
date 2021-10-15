public without sharing class NewNoticesController {
    public List<NoticesMaster__c> NoticeList {get; set;}

	public NewNoticesController(){
	
		NoticeList = [SELECT Id, Title__c, Content__c,SortOrder__c FROM NoticesMaster__c WHERE NoticeType__c = '新着のお知らせ' ORDER BY SortOrder__c DESC];
    }

}