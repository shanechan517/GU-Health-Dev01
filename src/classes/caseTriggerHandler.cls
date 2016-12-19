public class caseTriggerHandler{
    
    public Void caseSequencer(){
        
        //Store eligible cases
        List<Case> eligibleCases = new List<Case>();
        //A list of all the parent IDs for querying
        Set<Id> parentIDs = new Set<Id>();
        //parent records for updating
        List<Case> parentList = new List<Case>();
        //all sibling values in a list with the parent id as the key
        Map<String, List<Case>> siblingMap = new Map<String, List<Case>>();
        //All new cases to be updated
        List<Case> updateList = new list<Case>();
        
        for(Case c :(List<Case>)Trigger.NEW){
            if(c.ParentId != null && (c.Status == 'Task completed' || c.Status == 'Task aborted')){
                eligibleCases.add(c);
                parentIDs.add(c.ParentId);
            }
        }
    
        //Ensure there is at least one eligible case before we continue
        if(!eligibleCases.isEmpty()){
            //get Sibling Cases
            List<Case> cList = new List<Case>([SELECT Id, ParentId, Code__c, Status, Dependancy__c FROM Case WHERE ParentId IN:parentIDs and Code__c > 0]);
            if(!cList.isEmpty()){
                for(Case c :cList){
                    if(siblingMap.containsKey(c.ParentId)){
                        siblingMap.get(c.ParentId).add(c);
                    }else{
                        siblingMap.put(c.ParentId, new List<Case>());
                        siblingMap.get(c.ParentId).add(c);
                    }
                }
            }
            
            Integer howMany = 0;
            for(Case c :eligibleCases){
                if(siblingMap.containsKey(c.parentId)){
                    system.debug(siblingMap.get(c.parentId));
                    for(Case sc:siblingMap.get(c.parentId)){
                        if(c.Status == 'Task aborted' && sc.Status != 'Task completed' && sc.Status != 'Task aborted' && sc.Status != 'Not Required'){
                            sc.Status = 'Task blocked';
                            updateList.add(sc);
                        }else if(sc.Dependancy__c != null && c.Code__c != null && (Integer.valueOf(sc.Dependancy__c) <= Integer.valueOf(c.Code__c + howMany) && Integer.valueOf(sc.Dependancy__c) >= Integer.valueOf(c.Code__c)) && sc.Status == 'Awaiting previous task'){
                            sc.Status = 'Task ready to start';
                            updateList.add(sc);
                        }else if(sc.Dependancy__c != null && c.Code__c != null && Integer.valueOf(sc.Dependancy__c) <= Integer.valueOf(c.Code__c + howMany) && sc.Status == 'Not Required'){
                            howMany = howmany + 1;
                        }
                    }
                }
            }
            
            if(!updateList.isEmpty()){
                try{
                    update updateList;
                }catch(Exception e){
                    system.debug('Update Failed ' + updateList);
                }
            }
            
            //Update the parent records - Tasks Completed
            List<Case> parentCases = new List<Case>([SELECT Id, Status, (SELECT Id, Status FROM Cases WHERE Status != 'Task completed' AND Status != 'Not Required') FROM Case WHERE Id IN:parentIDs AND ClosedDate = null]);
            if(!parentCases.isEmpty()){
                for(Case pc:parentCases){
                    if(pc.Cases.size() == 0){
                        pc.Status = 'Tasks Completed';
                        parentList.add(pc);
                    }
                }
            }
            
            //Update the parent records - Tasks Aborted/Blocked
            List<Case> parentCasesBlocked = new List<Case>([SELECT Id, Status, (SELECT Id, Status FROM Cases WHERE Status = 'Task aborted') FROM Case WHERE Id IN:parentIDs AND ClosedDate = null]);
            if(!parentCasesBlocked.isEmpty()){
                for(Case pc:parentCasesBlocked){
                    if(pc.Cases.size() == 1){
                        pc.Status = 'A task is blocked';
                        parentList.add(pc);
                    }
                }
            }
                
            if(!parentList.isEmpty()){
                try{
                    update parentList;
                }catch(Exception e){
                    system.debug('Parent Cases List ' + parentList);
                }
            }
            
        }
    }
    
    public Void actualSLADays(){
        BusinessHours bh;
        List<BusinessHours> bhList = new List<BusinessHours>([SELECT Id FROM BusinessHours WHERE Name = 'GU Default']);
        if(!bhList.isEmpty()){
            bh = bhList[0];
        }
        
        for(Case c :(List<Case>)Trigger.NEW){
            if((c.Status.toLowerCase().contains('complete') || c.Status.toLowerCase().contains('abort') || c.Status.toLowerCase().contains('close') || c.Status.toLowerCase().contains('not required'))  && bh != null && c.Duration__c == null){
                Long diffBetween = BusinessHours.diff(bh.Id, c.CreatedDate__c, system.NOW());
                c.Duration__c = (((diffBetween / 1000) / 60) / 60) /24;
            }
        }
    }
    
}