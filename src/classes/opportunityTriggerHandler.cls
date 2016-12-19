public class opportunityTriggerHandler{
    
    public Void populateAccountManager(){
        
        Set<Id> aIds = new Set<Id>();
        Map<Id, Account> accMap = new Map<Id, Account>();
        
        for(Opportunity o :(List<Opportunity>)Trigger.NEW){
            if(o.AccountId != null && o.Account_Manager__c == null){
                aIds.add(o.AccountId);
            }
        }
        
        if(!aIds.isEmpty()){
            accMap = new Map<Id, Account>([SELECT Id, OwnerId FROM Account WHERE Id IN:aIds]);
            for(Opportunity o :(List<Opportunity>)Trigger.NEW){
                if(o.AccountId != null && o.Account_Manager__c == null && accMap.containsKey(o.AccountId)){
                    o.Account_Manager__c = accMap.get(o.AccountId).OwnerId;
                }
            }
        }
        
    }
    
}