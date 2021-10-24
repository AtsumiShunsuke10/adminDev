public without sharing class SurveyController {
    //登録用
    public Survey__c surveyObj {get;set;}
    public SurveyController() {
        surveyObj = new Survey__c();
    }

    //保存処理
    public PageReference submit(){
        Savepoint sp = Database.setSavepoint();
        try{
            insert this.surveyObj;
            PageReference pr = null;
            pr = Page.SurveyComplete;
            pr.setRedirect(false);
            return pr;
        } catch (Exception e) {
            Database.rollback(sp);
            system.debug('System Insert Error');
            return null;
        }
    }
}