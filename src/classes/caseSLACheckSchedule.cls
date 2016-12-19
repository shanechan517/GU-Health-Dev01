global class caseSLACheckSchedule Implements Schedulable{
    
    global void execute(SchedulableContext sc){
        List<Case> cList = new List<Case>([SELECT Id, Due_Yesterday__c, Due_Tomorrow__c, Due_Today__c, Estimated_Close_Date__c, RecordType.Name FROM Case WHERE ((Estimated_Close_Date__c <= YESTERDAY AND Due_Yesterday__c = false) OR (Estimated_Close_Date__c = TODAY AND Due_Today__c = false) OR (Estimated_Close_Date__c = TOMORROW AND Due_Tomorrow__c = false)) AND ClosedDate = null AND Status != 'Awaiting previous task']);
        if(!cList.isEmpty()){
            for(Case c:cList){
                Date eCloseDate = date.newinstance(c.Estimated_Close_Date__c.year(), c.Estimated_Close_Date__c.month(), c.Estimated_Close_Date__c.day());
                if(eCloseDate < system.TODAY() && c.Due_Yesterday__c == false){
                    c.Due_Yesterday__c = true;
                }else if(c.RecordType.Name != 'Parent' && eCloseDate == system.TODAY()){
                    c.Due_Today__c = true;
                }else if(c.RecordType.Name != 'Parent' && eCloseDate == system.TODAY().addDays(+1)){
                    c.Due_Tomorrow__c = true;
                }
            }
            
            try{
                update cList;
            }catch(Exception e){
                system.debug('Updating the Cases failed ' + cList);
            }
        }
    }
    
}