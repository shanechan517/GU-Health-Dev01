trigger productTrigger on Section_Product__c (before insert, before update) {
productTriggerHandler handler = new productTriggerHandler();
if(trigger.isBefore){
    if(trigger.isUpdate || trigger.isInsert){
        handler.CreateUpdateSectionProductCoverCode();
    }
}

}