public class splTriggerHandler{
    
    //Syncs group fields across other versions (as dictated in relevant field set)
    public Void syncSPLFields(){
		//Check if the trigger is on or off
        if(Label.GRP_SyncFields.toUpperCase() == 'TRUE'){

			guUtil utility = new guUtil();
			utility.syncFields('Section_Product_Link__c', 'SharedKey__c, Version__c', 'Version__c', 'SharedKey__c');
			
        }
    }
	
	
	//WHICS Fields validation
    public Void whicsValidation(){
        
        //exclude records if they have come from the publish wizard
        list<Section_Product_Link__c> newSplLst = (List<Section_Product_Link__c>)Trigger.NEW;
        Boolean isPublishWizard = newSplLst[0].IsPublishWizard__c;

        if(Label.WHICS_Val.toUpperCase() == 'TRUE' && isPublishWizard == false){
            guUtil utility = new guUtil();
			utility.lockedFields('Section_Product_Link__c', 'Status__c');
        }else{
            //reset the publish wizard token for all records
            for(Section_Product_Link__c spl :(List<Section_Product_Link__c>)Trigger.NEW){
                spl.IsPublishWizard__c = false;
            }
        }
        
    }
    
}