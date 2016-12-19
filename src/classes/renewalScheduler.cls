global class renewalScheduler Implements Schedulable{
    
    global void execute(SchedulableContext sc){
        renewalProcess rP = new renewalProcess();
        rp.processSchedule('batch', 'with', 'Renewal', 'Group__c');
    }
    
}