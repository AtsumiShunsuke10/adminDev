({
   
   selectRecord : function(component, event, helper){      
       // 結果のリストを取得  
       var getSelectRecord = component.get("v.oRecord"); 
       var compEvent = component.getEvent("oSelectedRecordEvent");
       // set the Selected sObject Record to the event attribute.  
       compEvent.setParams({"recordByEvent" : getSelectRecord.obj }); 
       compEvent.setParams({"recordIdByEvent" : getSelectRecord.obj.Id }); 
       compEvent.setParams({"recordNameByEvent" : getSelectRecord.obj.Name }); 
       
       // fire the event  
       compEvent.fire();
    },
})