trigger groupTrigger on Group__c (before insert, before update, after insert, after update) {
    
    groupTriggerHandler handler = new groupTriggerhandler();
    
    if(Trigger.isBefore){
        if(Trigger.isUpdate){
            //WHICS field validation
            handler.whicsValidation();
        }
        
        //Ensure Renewal Dates are calculated correctly
        handler.renewalDates();
        
        //Ensure the record has the correct record type delegated to match the data
        handler.recordTypeCheck();
        
        //Ensure the records version logic is correct
        handler.versioningGroups();
        
       
        
    }else if(Trigger.isAfter){
        //Syncronise the changes across versions where applicable
        handler.syncGroupFields();
        handler.MassDeactivateSectionOnGrpClose();
        System.debug(Trigger.New);
    }
    
}