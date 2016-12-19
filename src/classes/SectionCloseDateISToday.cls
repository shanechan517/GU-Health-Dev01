// Scheduler to set oms status if OMS dates are today 
global class SectionCloseDateISToday implements Schedulable {
    global void execute(SchedulableContext sc){
        //OMS status activation does not depend on Date_Closed__c any more
        list<section__c> secLst = [select id , Date_Closed__c , OMS_Disabled_Date__c, OMS_Activation_Date__c from section__c where  OMS_Disabled_Date__c = today or OMS_Activation_Date__c = today  ];
        system.debug('Count of Section Objects=' + secLst.size());
         try{
            update secLst;
            }catch(Exception e)
            {
                system.debug('Failed to update SectionLst ' + secLst);
            }
    }
    
}