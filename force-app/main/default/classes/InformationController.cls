public with sharing class InformationController {
    @AuraEnabled(cacheable=true)
    public static List<Information__c> getInformationList() {

        User user = [SELECT CCHub__c FROM User WHERE Id = :UserInfo.getUserId()];
        String ccHub = user.CCHub__c;
        
        PermissionSet permissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'CallCenterOP_Information'];
        List<PermissionSetAssignment> permissionSetAssignment = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId = :permissionSet.Id AND AssigneeId = :UserInfo.getUserId()];
        
        String query = '(NoticePeriodStart__c<=TODAY AND ( NoticePeriodEnd__c=null OR NoticePeriodEnd__c>=TODAY))';
        if(!permissionSetAssignment.isEmpty()) {
            if(!String.isBlank(ccHub)) {
                query = query + ' AND CCHub__c IN (\'' + ccHub + '\', \'すべて\')';
            }
        }

        System.debug(query);
        List<information__c> informations = 
            Database.query('SELECT Id, Name, Importance__c, Category__c, Title__c, Detail__c, NoticePeriodStart__c, NoticePeriodEnd__c FROM Information__c WHERE ' + query + ' ORDER BY Name desc');

        if(informations.isEmpty()) {
            return null;
        }
        return informations;
    }
}