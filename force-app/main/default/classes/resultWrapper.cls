public class resultWrapper{
    @AuraEnabled public String conImageUrl{get;set;}
    public resultWrapper(String conImage)          {
       
        this.conImageUrl = conImage;
    }
}