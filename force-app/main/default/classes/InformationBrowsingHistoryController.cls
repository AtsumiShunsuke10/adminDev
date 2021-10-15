public with sharing class InformationBrowsingHistoryController {
    @AuraEnabled(cacheable=true)
    public static List<Result> getInformationBrowsingHistories(Id informationId) {

        Information__c information = [SELECT CCHub__c FROM Information__c WHERE Id = :informationId];
        List<User> users = new List<User>();
        if(String.isEmpty(information.CChub__c) || information.CChub__c.equals('すべて')) {
            users = [SELECT Name, CCHub__c FROM User];
        } else {
            users = [SELECT Name, CCHub__c FROM User WHERE CCHub__c = :information.CCHub__c];
        }

        List<InformationBrowsingHistory__c> informationBrowsingHistories = [SELECT User__r.Name, isRead__c FROM InformationBrowsingHistory__c WHERE Information__c = :informationId];

        Map<String, Result> temp = new Map<String, Result>();
        for(InformationBrowsingHistory__c i : informationBrowsingHistories) {
            temp.put(i.User__r.Name, new Result(i.User__r.Name, i.isRead__c));
        }

        List<Result> results = new List<Result>();
        results.addAll(temp.values());

        for(User u : users) {
            if(temp.get(u.Name) == null) {
                results.add(new Result(u.Name, false));
            }
        }

        if(results.isEmpty()) {
            return null;
        }
        return results;
    }

    public class Result {
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public Boolean isRead {get;set;}

        public result(String name, Boolean isRead) {
            this.name = name;
            this.isRead = isRead;
        }
    }
}