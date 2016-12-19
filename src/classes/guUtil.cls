global class guUtil{
    
    global Boolean result {get;set;}
    global String resultMsg {get;set;}
    
    global Map<Integer,Case> recalcSLA(Map<Integer,Case> caseList, BusinessHours bhs, DateTime counter){
        
        Integer slaCounter = 0;
        
        if(!caseList.isEmpty()){
            
            for(Case c:caseList.values()){
                if(c.Code__c == 0){
                    c.Estimated_Start_Date__c = counter;
                }else if(c.Skip_Case__c == false && c.SLA_Days__c != null){
                    c.Estimated_Start_Date__c = counter;
                    Integer hours = (Integer.valueOf(c.SLA_Days__c) * 10) * 3600000;
                    slaCounter = Integer.valueOf(c.SLA_Days__c) + slaCounter;
                    counter = BusinessHours.add(bhs.Id, c.Estimated_Start_Date__c, hours);
                    c.Estimated_Close_Date__c = counter;
                }else{
                    c.Estimated_Start_Date__c = null;
                    c.Estimated_Close_Date__c = null;
                }
            }
            
            Boolean markedAsStarted = false;
            for(Case c:caseList.values()){
                if(c.Code__c == 0){
                    c.Estimated_Close_Date__c = counter;
                    //c.SLA_Days__c = date.newinstance(c.Estimated_Start_Date__c.year(), c.Estimated_Start_Date__c.month(), c.Estimated_Start_Date__c.day()).daysBetween(date.newinstance(c.Estimated_Close_Date__c.year(), c.Estimated_Close_Date__c.month(), c.Estimated_Close_Date__c.day()));
                    c.SLA_Days__c = slaCounter;
                    c.Status = 'Tasks in progress';
                }else if(markedAsStarted == false && c.Skip_Case__c == false){
                    c.Status = 'Task ready to start';
                    markedAsStarted = true;
                }else  if(c.Skip_Case__c){
                    c.Status = 'Not Required';
                }else{
                    c.Status = 'Awaiting previous task';
                }
            }
            
        }else{
            result = false;
            resultMsg = 'The provided list of cases was empty';
        }
        
        result = true;
        resultMsg = 'Operation was a success';
        return caseList;
        
    }
	
	
	global Void syncFields(String sObjectDecl, String additionalFields, String keyField, String sharedField){
    	
		//reference Map for values to sync
        Map<String, sObject> recordMap = new Map<String, sObject>();
		//group numbers in trigger
        Set<String> keySet = new Set<String>();
		//Excluded group numbers
		Set<String> excludedKeys = new Set<String>();
		//List to update after processing
        List<sObject> updateList = new List<sObject>();
		//Ids inside the trigger
		Set<Id> triggerIds = new Set<Id>();
        
        //Get field set using UTIL class
        Boolean isDirty = false;
        List<Schema.FieldSetMember> fieldSetMemberList =  Util.readFieldSet('SyncFields',sObjectDecl);
        List<String> recordFields = new List<String>();
        
        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList){
            recordFields.add(String.valueOf(fieldSetMemberObj.getFieldPath()));
        }
        
        //iterate through trigger.new and build a map and set for querying and sync later
        for(sObject rcrd :(List<sObject>)Trigger.NEW){
            //create an exclusion set
			triggerIds.add(rcrd.Id);
			//check if a group of the same number has already been inserted. If so return with an error
            if(excludedKeys.contains(String.valueOf(rcrd.get(sharedField)))){
				//do nothing
			}else if(keySet.contains(String.valueOf(rcrd.get(sharedField))) && !excludedKeys.contains(String.valueOf(rcrd.get(sharedField)))){
				excludedKeys.add(String.valueOf(rcrd.get(sharedField)));
			}else{
				keySet.add(String.valueOf(rcrd.get(sharedField)));
				recordMap.put(String.valueOf(rcrd.get(sharedField)), rcrd);
			}
        }
        
        //Get all other versions of groups included in trigger.new
        //List<Section_Product_Link__c> syncList = new List<Section_Product_Link__c>([SELECT Id, Group_Number__c, Base_or_Upgrade__c FROM Section_Product_Link__c WHERE Group_Number__c IN :keySet AND Id NOT IN :splMap.values()]);
		String soql = Util.getCreatableFieldsSOQL(sObjectDecl,'Id NOT IN :triggerIds AND ' + sharedField + ' NOT IN :excludedKeys AND ' + sharedField + ' IN :keySet', additionalFields);

        List<sObject> rcrdList = (List<sObject>)Database.query(soql);
        for(sObject rcrd :rcrdList){
            //reset isDirty at the beginning of each loop
            isDirty = false;
            
            //loop through field set and compare value from this record with value in recordMap (use group number as map key)
            for(String fieldName :recordFields){
                if(recordMap.containsKey(String.valueOf(rcrd.get(sharedField))) && rcrd.get(fieldName) != recordMap.get(String.valueOf(rcrd.get(sharedField))).get(fieldName)){
                    rcrd.put(fieldName, recordMap.get(String.valueOf(rcrd.get(sharedField))).get(fieldName));
                    isDirty = true;
                }
            }
            
            //if the record is dirty, add to update list
            if(isDirty){
                updateList.add(rcrd);
            }
        }
		
        //if updateList is not empty, run an update ina  try catch
        if(!updateList.isEmpty()){
            update updateList;
        }
        
    }
	
	
	//WHICS Fields validation
    global Void lockedFields(String sObjectDecl, String statusField){
        
        if(Label.WHICS_Val.toUpperCase() == 'TRUE'){
            List<Schema.FieldSetMember> fieldSetMemberList =  Util.readFieldSet('WHICSFields',sObjectDecl);
            
            for(sObject rcrd :(List<sObject>)Trigger.NEW){            
                if(rcrd.get(statusField) != 'Draft' && rcrd.get('IsPublishWizard__c') != TRUE){
                    for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList){
                        if(rcrd.get(String.valueOf(fieldSetMemberObj.getFieldPath())) != Trigger.oldMap.get(rcrd.Id).get(String.valueOf(fieldSetMemberObj.getFieldPath()))){
                            rcrd.addError('Fields that are maintained in WHICS can only be modified in Draft records (' + String.valueOf(fieldSetMemberObj.getLabel()) + ')');
                        }
                    }
                }
            }
			
			System.debug('locked fields; Trigger.new ' + (List<sObject>)Trigger.NEW);
        }
        
    }
	
	//External Ids (so it is acceissble from APEX too
	global static String getSectionExtId(String groupNumber, String sectionNumber, String versionNumber){
        String externalId = groupNumber + 'v' + versionNumber + 'S' + sectionNumber;
        return externalId;
    }
    
}