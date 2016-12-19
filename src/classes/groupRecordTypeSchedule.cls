global class groupRecordTypeSchedule Implements Schedulable{
    
    global void execute(SchedulableContext sc){
        List<Group__c> groupList = [select Id, 
                                    Name, 
                                    IsPublishWizard__c,
                                    Closed_on__c,
                                    Start_Date__c,
                                    Group_Number__c 
                                    from Group__c 
                                    where 
                                    (Start_Date__c = TODAY) 
                                    or (Start_Date__c = TODAY and Closed_on__c <= TODAY)
                                    or (Renewal_Date__c = TODAY)];
        if(!groupList.isEmpty()){
            for (Group__c groupRec : groupList){
                groupRec.IsPublishWizard__c = true;//Set the flag so that these records are picked up by the Group trigger and correct record type is set.                
            }
            update groupList;
        }
    }
    
}