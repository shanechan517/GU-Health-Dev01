global class renewalProcess {
    
    //Maps/Lists for populating with new data
    public Map<Id, Opportunity> opMapNew {get;set;}
    public Map<Id, Group__c> grpMapNew {get;set;}
    public Map<Id, Section__c> secMapNew {get;set;}
    public Map<Id, Section_Product_Link__c> splMapNew {get;set;}
    public Map<Id, Group_Contact__c> grpConMapNew {get;set;}
    public Map<Id, Section_Contact__c> secConMapNew {get;set;}
    
    //ref objects
    public Map<String, Id> rtMap {get;set;}
    public String soql {get;set;}
    public List<Group__c> grpList {get;set;}
    global Id newId {get;set;}
    public Set<Id> opIds {get;set;}
    
    //Main process for Scheduler
    global void processSchedule(String requirement, String inclusion, String recordType, String obj){
        
        //create instances of all the maps
        opMapNew = new Map<Id, Opportunity>();
        grpMapNew = new Map<Id, Group__c>();
        secMapNew = new Map<Id, Section__c>();
        splMapNew = new Map<Id, Section_Product_Link__c>();
        grpConMapNew = new Map<Id, Group_Contact__c>();
        secConMapNew = new Map<Id, Section_Contact__c>();
        opIds = new Set<id>();
        rtMap = new Map<String, Id>();
        
        if(obj == 'Group__c'){

            if(requirement == 'batch'){
                //grpList = new List<Group__c>([SELECT Id FROM Group__c WHERE Is_Active__c = 'Active' AND Renewal_Trigger_Date__c <= TODAY AND Renewal_Processed_Time__c = null ORDER BY Renewal_Trigger_Date__c ASC]);
                soql = Util.getCreatableFieldsSOQL('group__c','Is_Active__c =\'Active\' AND Renewal_Trigger_Date__c <= TODAY AND Renewal_Processed_Time__c = null ORDER BY Renewal_Trigger_Date__c ASC', null);
                
            }else{
                //grpList = new List<Group__c>([SELECT Id FROM Group__c WHERE Id=:requirement]);
                soql = Util.getCreatableFieldsSOQL('group__c','id=\'' + requirement + '\'', null);
            }
            grpList = (List<Group__c>)Database.query(soql);
            
            //-----Record Types
                List<RecordType> rtList = new List<RecordType>([SELECT id, Name, sObjectType FROM RecordType WHERE ((Name = 'Renewal' OR Name = 'Client Maintenance') AND sObjectType = 'Opportunity') OR ((Name = 'Group' OR Name = 'Draft') AND sObjectType = 'Group__c')]);
                for(RecordType rt:rtList){
                    rtMap.put(rt.Name, rt.Id);
                }
            
            //-----Opportunity
                //Build a list of opportunity IDs to clone
                for(Group__c g:grpList){
                    opIds.add(g.Opportunity__c);
                }
                
                if(inclusion == 'with'){
                    //List<Opportunity> opList = new List<Opportunity>([SELECT Id, Account.Name FROM Opportunity WHERE Id IN:opIds]);
                    soql = Util.getCreatableFieldsSOQL('opportunity','id IN :opIds', 'Account.Name');
                    List<Opportunity> opList = (List<Opportunity>)Database.query(soql);
                    for(Opportunity op:opList){
                        //perform clone
                        Opportunity oNew = op.clone(false, true);
                        
                        oNew.Clone_Of__c = op.Id;
                        oNew.RecordTypeId = rtMap.get(recordType);
                        oNew.StageName = 'New';
                        if(recordType == 'Client Maintenance'){
                            oNew.Name = recordType + ' - ' + getLongDate() + ' - ' + oNew.Account.Name;
                            oNew.CloseDate = system.Today().addMonths(2);
                        }else if(recordType == 'Renewal'){
                            oNew.Name = recordType + ' - ' + system.Today().Year() + ' - ' + op.Account.Name;
                            oNew.CloseDate = system.Today().addMonths(4);
                        }
                        
                        opMapNew.put(op.Id, oNew);
                    }
                }
                
                //insert opportunities
                    insert opMapNew.values();
            
            //-----Group
                for(Group__c g :grpList){
                    Group__c gNew = g.clone(false, true);
                    
                    gNew.Clone_of__c = g.Id;
                    if(recordType == 'Renewal'){
                        gNew.Do_Not_Calculate_Renewal_Date__c = false;
                    }else{
                        gNew.Do_Not_Calculate_Renewal_Date__c = true;
                    }
                    gNew.Renewal_Processed_Time__c = null;
                    if(inclusion == 'without'){
                        gNew.Group_Number__c = null;
                    }
                    if((recordType == 'Client Maintenance' || recordType == 'Renewal') && rtMap.containsKey('Draft') && inclusion != 'without'){
                        gNew.RecordTypeId = rtMap.get('Draft');
                    }
                    if(inclusion == 'with' && gNew.Opportunity__c != null){
                        gNew.Opportunity__c = opMapNew.get(g.Opportunity__c).Id;
                    }else if(inclusion == 'without' && gNew.Opportunity__c != null){
                        gNew.Opportunity__c = g.Opportunity__c;
                    }
                    //change any other Group fields that require manipulation
                    gNew.Start_Date__c = null;
                    gNew.Renewal_Date__c = null;
                    gNew.Version__c = null;
                    
                    grpMapNew.put(g.Id, gNew);
                }
                
                //insert grpMapNew
                insert grpMapNew.values();
        }
        
        //-----Sections
            if(obj == 'Section__c'){
                //secList = [SELECT Id FROM Section__c WHERE Id=:requirement];
                soql = Util.getCreatableFieldsSOQL('Section__c','id=\'' + requirement + '\' AND Status__c != \'Closed\'', null); 
            }else{
                //secList = [SELECT Id FROM Section__c WHERE Group__c IN :grpList];
                soql = Util.getCreatableFieldsSOQL('Section__c','Group__c IN :grpList AND Status__c != \'Closed\'', null);
            }
            List<Section__c> secList = (List<Section__c>)Database.query(soql);
            
            for(Section__c s:secList){
                Section__c sNew = s.clone(false, true);
                
                //Any manual removals between versions
                if(obj == 'Group__c'){
                    sNew.Group__c = grpMapNew.get(s.Group__c).Id;
                }else{
                    sNew.Group__c = s.Group__c;
                }
                sNew.Clone_of__c = s.Id;
                
                //add to map with sOg as key (for child clone ref)
                secMapNew.put(s.Id, sNew);
            }
            
            //insert sections
            insert secMapNew.values();
            
        //-----Section Products Link
            //secProLinkList = [SELECT Id FROM Section_Product_Link__c WHERE Product__r.Section__c IN :secList];
            soql = Util.getCreatableFieldsSOQL('Section_Product_Link__c','Section__c IN :secList AND Status__c != \'Closed\'', null);
            List<Section_Product_Link__c> secProLinkList = (List<Section_Product_Link__c>)Database.query(soql);
            
            for(Section_Product_Link__c spl:secProLinkList){
                Section_Product_Link__c splNew = spl.clone(false, true);
                
                //Any manual removals between versions
                splNew.Section__c = secMapNew.get(spl.Section__c).Id;
                splNew.Product__c = spl.Product__c;
                
                //add to map with sOg as key (for child clone ref)
                splMapNew.put(spl.Id, splNew);
            }
            
            //insert section product links
            insert splMapNew.values();
       
       if(obj == 'Group__c'){     
            //-----Group Contacts
                //grpContacts = [SELECT Id FROM Group_Contact__c WHERE Group IN :groList];
                soql = Util.getCreatableFieldsSOQL('Group_Contact__c','Group__c IN :grpList', null);
                List<Group_Contact__c> grpConList = (List<Group_Contact__c>)Database.query(soql);
                
                for(Group_Contact__c grpCon:grpConList){
                    Group_Contact__c grpConNew = grpCon.clone(false, true);
                    
                    //Any manual removals between versions
                    grpConNew.Contact__c = grpCon.Contact__c;
                    grpConNew.Group__c = grpMapNew.get(grpCon.Group__c).Id;
                    
                    //add to map with sOg as key (for child clone ref)
                    grpConMapNew.put(grpCon.Id, grpConNew);
                }
                
                //insert group contacts
                insert grpConMapNew.values();
            }
        
        //-----Section Contacts
            
            if(!secList.isEmpty()){
                //secConList = [SELECT Id FROM Section_Contact__c WHERE Section__c IN :secList];
                soql = Util.getCreatableFieldsSOQL('Section_Contact__c','Section__c IN :secList', null);
                List<Section_Contact__c> secConList = (List<Section_Contact__c>)Database.query(soql);
            
            
                for(Section_Contact__c secCon:secConList){
                    Section_Contact__c secConNew = secCon.clone(false, true);
                    
                    //Any manual removals between versions
                    secConNew.Contact__c = secCon.Contact__c;
                    secConNew.Section__c = secMapNew.get(secCon.Section__c).Id;
                    
                    //add to map with sOg as key (for child clone ref)
                    secConMapNew.put(secCon.Id, secConNew);
                }
                
                //insert section contacts
                insert secConMapNew.values();
            }
            
        //Update original group records
            if(obj == 'Group__c' && recordType == 'Renewal'){
                for(Group__c og:grpList){
                    og.Renewal_Processed_Time__c = system.NOW();
                }
                update grpList;
            }
            
         //Set the newGroupId/newSecId if it is a single clone
             if(requirement != 'batch' && obj == 'Group__c'){
                 newId = grpMapNew.get(requirement).Id;
             }else if(obj == 'Section__c'){
                 newId = secMapNew.get(requirement).Id;
             }
    }
    
    
    global String closeActiveGroup(Group__c g, Date publishDate){
        
        Id recordType;
        List<RecordType> rtList = new List<RecordType>([SELECT Id FROM RecordType WHERE sObjectType = 'Group__c' AND Name = 'Replaced']);
        if(!rtList.isEmpty()){
            recordType = rtList[0].Id;
            List<Group__c> gList = new List<Group__c>([SELECT Id FROM Group__c WHERE Id=:g.Id]);
            if(!gList.isEmpty()){
                Group__c updateG = gList[0];
                if(system.TODAY() >= publishDate){
                    updateG.RecordTypeId = recordType;
                }
                updateG.Renewal_Date__c = publishDate;
                updateG.IsPublishWizard__c = true;
                system.debug(updateG);
                try{
                    update updateG;
                }catch(Exception e){
                    system.debug('Could not update group record ' + updateG);
                    String msg = 'Could not process the closing of the active group. Please perform the action manually before proceeding to publish.';
                    return msg;
                }
            }else{
                String msg = 'Could not process the closing of the active group. Please perform the action manually before proceeding to publish.';
                return msg;
            }
        }else{
            String msg = 'The record type does not exist.';
            return msg;
        }
        
        String msg = 'success';
        return msg;
    }
    
    public String getLongDate() {
        Datetime cDT = System.now();
        String LongDate = cDT.format('MMMM d, yyyy');
        return LongDate;
    }

    global String discardGroup(Id groupId){
        String returnMessage = '';
        Group__c updateGroup = new Group__c(Id = groupId, Start_Date__c = system.Today(), Renewal_Date__c = system.Today(), IsPublishWizard__c = true);

        try{
            update updateGroup;
        }catch(Exception e){
            returnMessage = e.getMessage();
            return returnMessage;
        }

        return returnMessage;
    }
  
}