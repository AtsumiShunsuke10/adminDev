({
     doInit : function(component,event,helper){
         var myRecordId = component.get("v.defaultRecordId");
         var myRecordName = component.get("v.defaultRecordName");
         if(myRecordId!=null && myRecordId!="" && myRecordName!=null && myRecordName!=""){
             var setRecord = component.get("v.selectedRecord");
             setRecord.Id = myRecordId;
             setRecord.Name = myRecordName;
             
             component.set("v.selectedRecord" , setRecord);
             component.set("v.recordId" , setRecord.Id); 
             helper.setPillHelper(component,event);
         }
    },
   onfocus : function(component,event,helper){
       //検索結果の表示と非表示
       $A.util.addClass(component.find("mySpinner"), "slds-show");
        var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
        // 5レコードが表示する（order by createdDate DESC）
         var getInputkeyWord = component.get("v.SearchKeyWord");
         helper.searchHelper(component,event,getInputkeyWord);
    },
    onblur : function(component,event,helper){       
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    keyPressController : function(component, event, helper) {
        // キーボードを押すと検索する  
        var getInputkeyWord = component.get("v.SearchKeyWord");
        // 入力値が空ではない場合、再検索する
        if( getInputkeyWord.length > 0 ){
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        // 入力値が空の場合
        else{  
            component.set("v.listOfSearchRecords", null ); 
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
	},
    
    // コンポーネントのリセット
    clear :function(component,event,heplper){
         var pillTarget = component.find("lookup-pill");
         var lookUpTarget = component.find("lookupField"); 
        
         $A.util.addClass(pillTarget, 'slds-hide');
         $A.util.removeClass(pillTarget, 'slds-show');
        
         $A.util.addClass(lookUpTarget, 'slds-show');
         $A.util.removeClass(lookUpTarget, 'slds-hide');
      
         component.set("v.SearchKeyWord",null);
         component.set("v.listOfSearchRecords", null );
         component.set("v.selectedRecord", {} );
         component.set("v.recordId", null );
    },
    
  	// 内容を選択した後
    handleComponentEvent : function(component, event, helper) {	 
       var selectedAccountGetFromEvent = event.getParam("recordByEvent");

	   component.set("v.selectedRecord" , selectedAccountGetFromEvent);
       component.set("v.recordId" , selectedAccountGetFromEvent.Id); 
        
        var myRecordName = event.getParam("recordNameByEvent");
        var myRecordId=selectedAccountGetFromEvent.Id;
        
        component.set("v.defaultRecordName" , myRecordName); 
        component.set("v.defaultRecordId" , myRecordId); 
		
        
        //send data to vf start
        var myEvent = $A.get("e.c:SendDataToVFPage");
        myEvent.setParams({
            currentRecDetails: selectedAccountGetFromEvent
        });
        myEvent.fire();
        //send data to vf end
        
       helper.setPillHelper(component,event);

	},
   
})