/*******************************************************************************
 *  プロジェクト名 : ○○県新型コロナウイルス感染症拡大防止協力金
 *  クラス         : Communityのユーザを一括登録ツール
 *  クラス名       : UploadCommunityUserFromCsv
 *  概要           : Communityのユーザを一括登録ツール
 *  作成者         : トランス・コスモス
 *  作成日         : 2021/09/22
 *******************************************************************************/
public class UploadCommunityUserFromCsv {
    
    @AuraEnabled
    public static string insertData(String strfromlex)
    {
        String returnresponse ='ERROR';
        List<Contact> contactListtoInsert = new List<Contact>();
        List<fieldWrapper> datalist = (List<fieldWrapper>) JSON.deserialize(strfromlex, List<fieldWrapper>.class);
        for(fieldWrapper wrapper: datalist)
        {
            Contact c =new  Contact();
            c.LastName = wrapper.name;
            c.Email = wrapper.Mail;
            c.AccountId = '0010l00001M3LS0AAN';//環境より
            contactListtoInsert.add(c);
        }
        if(contactListtoInsert.size() > 0)
        {
            try {
                List<Database.SaveResult> cResults = Database.insert(contactListtoInsert, false);
                for(Database.SaveResult ur:cResults){
                    if (!ur.isSuccess()) {
                        for (Database.Error err : ur.getErrors()) {
                            system.debug('Create contact err.getMessage:::: ' + err.getMessage());
                            return 'Create contact err.getMessage:::: ' + err.getMessage();
                        }
                    }
                }
                
                List<User> userList = new List<User>();
                system.debug('contactListtoInsert:::: ' + contactListtoInsert);
                system.debug('SaveResult:::: ' + cResults);
                for(Contact c:contactListtoInsert){
                    system.debug('Contact:::: ' + c);
                    User u = New User();
                    u.ContactId = c.Id;
                    u.CommunityNickname = c.LastName+generateRandomString(10);
                    u.Alias = c.LastName;
                    u.Email = c.Email;
                    u.IsActive = true;
                    u.EmailPreferencesAutoBcc = true;
                    u.LanguageLocaleKey = 'ja';
                    u.LocaleSidKey = 'ja_JP';
                    u.LastName = c.LastName;
                    u.ProfileId = '00e5h000002iRkFAAU';
                    u.Username = c.Email+generateRandomString(10);
                    //u.UserPreferencesContentEmailAsAndWhen = true;
                    //u.UserPreferencesContentNoEmail = true;
                    u.UserPreferencesShowTitleToExternalUsers = true;
                    u.TimeZoneSidKey = 'GMT';
                    u.EmailEncodingKey = 'ISO-2022-JP';
                    system.debug('User:::: ' + u);
                    userList.add(u);
                }
                system.debug('userList:::: ' + userList);
                List<Database.SaveResult> uResults = Database.insert(userList, false);
                for(Database.SaveResult ur:uResults){
                    if (!ur.isSuccess()) {
                        for (Database.Error err : ur.getErrors()) {
                            system.debug('Create User err.getMessage:::: ' + err.getMessage());
                            return 'Create User err.getMessage:::: ' + err.getMessage();
                        }
                    }
                }
                returnresponse = 'SUCCESS';
            }
            catch(Exception ex)
            {
                system.debug('Exception:::: ' + ex.getMessage());
                returnresponse = ex.getMessage();
            }
        }
        return returnresponse;
    }
    
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
    
    public class fieldWrapper {
        
        public String Name;
        
        public String Mail;
        
    } 
}