trigger sectionTrigger on Section__c (before insert, before update, after update, after insert) {
    
    sectionTriggerHandler handler = new sectionTriggerhandler();
    
    if(Trigger.isAfter){
         
        //Syncronise the changes across versions where applicable
        
        handler.syncSectionFields();
        handler.UpdateOMSAvailableFieldInGrp();
         
    }else if(Trigger.isBefore){
        // update only
        if(Trigger.isUpdate){
            //WHICS field validation
            handler.whicsValidation();
        }
        //set external id
        handler.setExternalId();
        //update or insert
        if(Trigger.isUpdate || Trigger.isInsert ){
           //handler.syncSectionFields();
           handler.UpdateOMSActivationDtOMSDisableDtOMSStatus();
           
        }
    }
    
}