public without sharing class GoikenController {
    //登録用
    public Case form {get;set;}
    //コンストラクタ
    public GoikenController() {
        this.form = new case();
    }

    //登録画面へ遷移処理
    public PageReference input(){
        PageReference pr = null;
        pr = Page.Goiken;
        pr.setRedirect(false);
        return (pr);
    }

    //確認画面へ遷移処理
    public PageReference confirm(){
        PageReference pr = null;
        pr = Page.Goiken;
        pr.setRedirect(false);
        return (pr);
    }

    //完了画面へ遷移処理
    public PageReference complete(){
        PageReference pr = null;
        pr = Page.GoikenComplete;
        pr.setRedirect(false);
        return (pr);
    }

    //保存処理
    public PageReference submit(){
        Savepoint sp = Database.setSavepoint();
        try{
            insert this.form;
            PageReference pr = null;
            pr = Page.GoikenComplete;
            pr.setRedirect(false);
            return pr;
        } catch (Exception e) {
            Database.rollback(sp);
            system.debug('System Insert Error');
            return null;
        }
    }
}