({
    CSV2JSON: function (component,csv) {
        console.log('@@@ Incoming csv = ' + csv);
        
        //var array = [];
        var arr = []; 
        
        arr =  csv.split('\n');;
        console.log('@@@ arr = '+arr);
        arr.pop();
        var jsonObj = [];
        var headers = arr[0].split(',');
        for(var i = 1; i < arr.length; i++) {
            var data = arr[i].split(',');
            var obj = {};
            for(var j = 0; j < data.length; j++) {
                obj[headers[j].trim()] = data[j].trim();
            }
            jsonObj.push(obj);
        }
        var json = JSON.stringify(jsonObj);
        console.log('@@@ json = '+ json);
        return json;
        
        
    },
    
    CreateCommunityUser : function (component,jsonstr){
        console.log('@@@ jsonstr' + jsonstr);
        var action = component.get("c.insertData");
        action.setParams({
            "strfromlex" : jsonstr
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                var returnValue = response.getReturnValue();
                if (returnValue === "SUCCESS") { 
                    alert("Communityのユーザを一括登録しました。");  
                }else{
                    alert(returnValue);  
                }
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                    alert('Unknown');
                }
            }
        }); 
        
        $A.enqueueAction(action);    
        
    }
})