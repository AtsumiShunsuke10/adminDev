({
  searchHelper: function(component, event, getInputkeyWord) {
    // APEXを呼び出す
    var action = component.get("c.fetchLookUpValues");
    // パラメータを渡す
    action.setParams({
        searchKeyWord: getInputkeyWord,
        ObjectName: component.get("v.objectAPIName"),
        filedName: component.get("v.searchFieldName"),
        relatedFiledname: component.get("v.relatedFiledname"),
        relatedFiledId: component.get("v.relatedFiledId"),
        addWhereCondtions: component.get("v.addWhereCondtions"),
        orderByName: component.get("v.orderByName"),
        limitStr: component.get("v.limitStr"),
        splitSearchKeyWord : component.get("v.splitSearchKeyWord"),
        andOrStr : component.get("v.searchAndOR"),
        showFieldName:component.get("v.showFieldName")
    });
    // コールバック
    action.setCallback(this, function(response) {
      $A.util.removeClass(component.find("mySpinner"), "slds-show");
      var state = response.getState();
      if (state === "SUCCESS") {
        var storeResponse = response.getReturnValue();
        // 結果が見つからない時の表示
        if (storeResponse.length == 0) {
          component.set("v.Message", "結果がありません。");
        } else {
          component.set("v.Message", "");
        }
        // 戻る値をリストに設定する
        component.set("v.listOfSearchRecords", storeResponse);
      }
    });
    $A.enqueueAction(action);
  },
    setPillHelper: function(component, event) {
         var forclose = component.find("lookup-pill");
           $A.util.addClass(forclose, 'slds-show');
           $A.util.removeClass(forclose, 'slds-hide');
  
        var forclose = component.find("searchRes");
           $A.util.addClass(forclose, 'slds-is-close');
           $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show'); 
    }
});