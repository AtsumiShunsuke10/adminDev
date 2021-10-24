/*******************************************************************************
 *  プロジェクト名 : 東京都型コロナウイルス感染症拡大防止協力金
 *  クラス         : カスタム日付クラス
 *  クラス名       : CustomDate
 *  概要           : カスタム日付クラス
 *******************************************************************************/
public without sharing class CustomDate {
    public String customYear    { get;set; }
    public String customMonth   { get;set; }
    public String customDay     { get;set; }
    public String tsbDisplayMsg { get;set; }
    public Date customDate {
        get {
            Date d;
            try {
                d = Date.newInstance(Integer.valueOf(this.customYear.substring(0, 4)), Integer.valueOf(this.customMonth), Integer.valueOf(this.customDay));
            } catch (Exception e) {
                return null;
            }
            return d;
        }
        private set;
    }
    public String customDateStr { 
        get;
        set {
            customDateStr = value;
            if (String.isBlank(value)) {
                this.customYear = '';
                this.customMonth = '';
                this.customDay = '';
                return;
            }
            List<String> ymd = value.split('-');
            if (ymd.size() != 3) { 
                this.customYear = '';
                this.customMonth = '';
                this.customDay = '';
                return;
            } else {
                this.customYear = ymd[0];
                this.customMonth = ymd[1];
                this.customDay = ymd[2];
            }
        } 
    }

    public CustomDate() {
        this.customYear = '';
        this.customMonth = '';
        this.customDay = '';
    }      
}