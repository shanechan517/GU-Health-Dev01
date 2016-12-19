trigger opportunityTrigger on Opportunity (before insert, before update) {
    
    opportunityTriggerHandler handler = new opportunityTriggerhandler();
    
    if(Trigger.isBefore){
        handler.populateAccountManager();
    }
    
}