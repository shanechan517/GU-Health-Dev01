trigger caseTrigger on Case (before update, after update) {
    
    caseTriggerHandler handler = new caseTriggerHandler();
    
    if(Trigger.isUpdate && Trigger.isBefore){
        handler.actualSLADays();
    }else if(Trigger.isUpdate && Trigger.isAfter){
        handler.caseSequencer();
    }
    
}