public class sectionTriggerHandler{
    
    //Syncs group fields across other versions (as dictated in relevant field set)
    public Void syncSectionFields(){
        //Check if the trigger is on or off
        if(Label.GRP_SyncFields.toUpperCase() == 'TRUE'){
        
            guUtil utility = new guUtil();
			utility.syncFields('Section__c', 'SharedKey__c, Version__c', 'Version__c', 'SharedKey__c');
            
        }
    }
    
    //WHICS Fields validation
    public Void whicsValidation(){

        //exclude records if they have come from the publish wizard
        list<Section__c> newSectLst = (List<Section__c>)Trigger.NEW;
        Boolean isPublishWizard = newSectLst[0].IsPublishWizard__c;
        

        if(Label.WHICS_Val.toUpperCase() == 'TRUE' && isPublishWizard == false){
            guUtil utility = new guUtil();
			utility.lockedFields('Section__c', 'Status__c');
        }else{
            //reset the publish wizard token for all records
            for(Section__c s :(List<Section__c>)Trigger.NEW){
                s.IsPublishWizard__c = false;
            }
        }
    }
    
    public void UpdateOMSActivationDtOMSDisableDtOMSStatus(){
        list<Section__c> newSectLst = (List<Section__c>)Trigger.NEW;
        // list<Section__c> oldSectMap = (List<Section__c>)Trigger.oldMap ;
        // 
        list<id> GrpIDLst = new list<id>();
        for(Section__c secGrp : newSectLst){
            GrpIDLst.add(secGrp.group__c);
        }
        
        list<group__c> secGrpLst = [select id, Is_Active__c,Start_Date__c ,RecordType.Name, Renewal_Date__c,Closed_on__c from group__c where id in :GrpIDLst ];
        map<id,group__c> secGrpMap= new map<id,group__c>();
        for(group__c grpidSec : secGrpLst ){
            secGrpMap.put(grpidSec.id,grpidSec);
        }
        //boolean bUpdtVal ;
        for(Section__c Sect:  newSectLst){
            if(!(Sect.Section_Number__c == '0' || 	Sect.Section_Number__c == '300')){
              	Sect.OMS_status__c = Sect.OMS_Activation_Date__c == null && Sect.OMS_Disabled_Date__c == null ? 'Disabled' : Sect.OMS_status__c; 
           	 	Sect.OMS_status__c = Sect.OMS_Activation_Date__c <= date.today() && Sect.OMS_Disabled_Date__c == null ? 'Active' : Sect.OMS_status__c; 
             	Sect.OMS_status__c = Sect.OMS_Activation_Date__c <= date.today() && Sect.OMS_Disabled_Date__c >  date.today() ? 'Active'  : Sect.OMS_status__c;
             	Sect.OMS_status__c = Sect.OMS_Activation_Date__c > date.today() && Sect.OMS_Disabled_Date__c == null ? 'Disabled' : Sect.OMS_status__c;  
             	Sect.OMS_status__c = Sect.OMS_Activation_Date__c > date.today() && Sect.OMS_Disabled_Date__c  > date.today() ? 'Disabled' : Sect.OMS_status__c;
            
             	Sect.OMS_status__c = Sect.OMS_Disabled_Date__c <= date.today()  ? 'Disabled' : Sect.OMS_status__c;  
            }
            
            
        }          
    }
    
    
	public  void UpdateOMSAvailableFieldInGrp(){
		set<Id> GrpIdActiveSet = new Set<Id>(); 
		set<Id> GrpIdDisabledSet = new Set<Id>(); 
       // system.debug('$(List<Section__c>)Trigger.NEW count=' + (List<Section__c>)Trigger.NEW.size());
		 for(Section__c s :(List<Section__c>)Trigger.NEW){
             if(!(s.Section_Number__c == '0' || 	s.Section_Number__c == '300') ){
             	if(s.OMS_status__c == 'Active' && s.group__c != null ){
                    GrpIdActiveSet.add(s.group__c);
                    if(GrpIdDisabledSet.contains(s.group__c)){
                        GrpIdDisabledSet.remove(s.group__c);
                    }
                } else {
                    if(!GrpIdActiveSet.contains(s.group__c)){
                        GrpIdDisabledSet.Add(s.group__c);
                    }
                }    
             }
             
		 }
        
		system.debug('$GrpIdActiveSet = ' + GrpIdActiveSet  ); 
		 LIST<group__c> updGrpLst = [select id, Join_Online_available__c from group__c where id in :GrpIdActiveSet or id in :GrpIdDisabledSet]; 
		 LIST<group__c> updChangeGrpLst = new LIST<group__c>();
        
		 for(Group__c ugrp : updGrpLst){
		 	if(GrpIdActiveSet.contains(ugrp.id)){
				if(ugrp.Join_Online_available__c != true){
					ugrp.Join_Online_available__c = true;
					updChangeGrpLst.add(ugrp);
				}
			} else {
				if(ugrp.Join_Online_available__c != false){
					ugrp.Join_Online_available__c = false;
					updChangeGrpLst.add(ugrp);
				}
			}
		 }
         system.debug('$updChangeGrpLst count=' + updChangeGrpLst.size());
		 update updChangeGrpLst;
	}
	
	//Set External Id
	public void setExternalId(){
		for(Section__c s :(List<Section__c>)Trigger.NEW){
			if(s.Group_Number__c != null && s.Version__c != null && s.Section_Number__c != null){
				s.External_ID__c = guUtil.getSectionExtId(s.Group_Number__c, s.Section_Number__c, String.valueOf(s.Version__c.setScale(0)));
			}	
		}
	}
}