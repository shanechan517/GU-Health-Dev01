trigger splTrigger on Section_Product_Link__c (after insert, after update, before update) {
    
    splTriggerHandler handler = new splTriggerHandler();
    
    if(Trigger.isAfter){
        handler.syncSPLFields();
    }else if(Trigger.isBefore){
        if(Trigger.isUpdate){
            //WHICS field validation
            handler.whicsValidation();
        }
    }
    
}