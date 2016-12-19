/////////////////////////////////
// Handler Class for Group Object
// Created by David Dawson
/////////////////////////////////

public class groupTriggerHandler{
    
    //Ensures all groups being saves are given the correct record type
    public void recordTypeCheck(){
        
        Map<String, RecordType> rtMap = new Map<String, RecordType>();
        List<RecordType> rtList = new List<RecordType>([SELECT Id, Name FROM RecordType WHERE sObjectType = 'Group__c' AND (Name = 'Group' OR Name = 'Replaced' OR Name = 'Draft')]);
        if(!rtList.isEmpty()){
            
            for(RecordType rt:rtList){
                rtMap.put(rt.Name, rt);
            }
            
            for(Group__c g :(List<Group__c>)Trigger.NEW){
				System.debug(g.Start_Date__c);
				if(g.IsPublishWizard__c && ((g.Renewal_Date__c != null && g.Renewal_Date__c <= system.TODAY()) || (g.Closed_On__c != null && g.Closed_On__c <= system.TODAY()))){
                    g.RecordTypeId = rtMap.get('Replaced').Id;
                }else if(g.Start_Date__c <= System.today() && g.IsPublishWizard__c){
					g.RecordTypeId = rtMap.get('Group').Id;
				}else if((g.Start_Date__c == null || g.Start_Date__c > system.TODAY()) && g.RecordTypeId != rtMap.get('Draft').Id){
                    g.RecordTypeId = rtMap.get('Draft').Id;
                }
            }

            publishWizard();  
        }
    }
    
    /**
     * @author         
     * @description     Ensures all of the groups have correct renewal dates calculated for them.
     * @history         Updated - 30/11/2016 - K.Vegerano (kristian.vegerano@australianunity.com)
     *                  - GVT-303: Renewal Date Calculation - new condition - enable auto renewal calculation on pending and active groups
     */
    public Void renewalDates(){
        //Collect group Ids
        Set<Id> renewalDates = new Set<Id>();
        for(Group__c g :(List<Group__c>)Trigger.NEW){
            if(g.Id != null){
                renewalDates.add(g.Id);
            }
        }
        
        //Retrieve Opportunity Record Type Name
        Map<Id, Group__c> groupMap = new Map<Id, Group__c>();
        for(Group__c loopGroup : [SELECT Id, Opportunity__r.RecordType.Name, Opportunity__r.RecordType.DeveloperName FROM Group__c WHERE Id IN :renewalDates]){
            groupMap.put(loopGroup.Id, loopGroup);
        }
        
        //Calculation of Renewal Date process
        for(Group__c g :(List<Group__c>)Trigger.NEW){
            //Check if the group has Id (trigger is on update)
            if(groupMap.containsKey(g.Id)){
                if(groupMap.get(g.Id).Opportunity__r.RecordType.DeveloperName != 'Client_Maintenance' && g.Start_Date__c != null && g.Do_Not_Calculate_Renewal_Date__c == false){
                    //GVT-303 - 25/11/2016 - recalculation based with renewal frequency
                    if(g.Renewal_Frequency__c != null){
                        g.Real_Renewal_Date__c = g.Start_Date__c.addMonths(Integer.valueOf(g.Renewal_Frequency__c));
                    }else{
                        g.Real_Renewal_Date__c = g.Start_Date__c.addYears(1);
                    }
                    g.Renewal_Trigger_Date__c = g.Real_Renewal_Date__c.addMonths(-4);
                }   
                
                //Calculate Renewal Trigger Date 4 months prior to the renewal date
                if(Trigger.OLDMAP != null){
                    if(Trigger.OLDMAP.containsKey(g.Id)){
                        if(((Group__c)Trigger.OLDMAP.get(g.Id)).Real_Renewal_Date__c != g.Real_Renewal_Date__c){
                            if(g.Real_Renewal_Date__c != null){
                                g.Renewal_Trigger_Date__c = g.Real_Renewal_Date__c.addMonths(-4);
                            }else{
                                g.Renewal_Trigger_Date__c = null;
                            }
                        }
                    }
                }
            }
        }
    }

    /**
     * @author          K.Vegerano (kristian.vegerano@australianunity.com)
     * @description     Reset the Renewal_Processed_Time__c field on active group when there are no draft or pending groups.
     * @history         Created - 14/12/2016 - K.Vegerano (kristian.vegerano@australianunity.com)
     *                  - GVT-303: Renewal Date Calculation - Enabled the renewal scheduler to pick up active group with created renewal but later on discarded
     */
    public void resetRenewalProcessTime(List<Group__c> groupList){
        
    }
    
    //Syncs group fields across other versions (as dictated in relevant field set)
    public Void syncGroupFields(){
        //Check if the trigger is on or off
        if(Label.GRP_SyncFields.toUpperCase() == 'TRUE'){
        	
			guUtil utility = new guUtil();
			utility.syncFields('Group__c', null, 'Version__c', 'Group_Number__c');

        }
    }
    
    //group versioning
    public Void versioningGroups(){
        Set<String> versionNumbers = new Set<String>();
        Map<String, Group_Version_Number__c> gvnMap = new Map<String, Group_Version_Number__c>();

        for(Group__c g :(List<Group__c>)Trigger.NEW){
            if(g.Group_Number__c != null && g.Version__c == null){
                versionNumbers.add(g.Group_Number__c);
            }
        }
        
        if(!versionNumbers.isEmpty()){
    
            List<Group_Version_Number__c> gvnList = new List<Group_Version_Number__c>([SELECT Id, Version_Number__c, Group_Number__c FROM Group_Version_Number__c WHERE Group_Number__c IN:versionNumbers]);
            if(!gvnList.isEmpty()){
                for(Group_Version_Number__c gvn:gvnList){
                    gvnMap.put(gvn.Group_Number__c, gvn);
                }
            }
            
            for(String vn:versionNumbers){
                if(!gvnMap.containsKey(vn)){
                    gvnMap.put(vn, new Group_Version_Number__c(Group_Number__c = vn, Version_Number__c = 0));
                }
            }
            
            for(Group__c g :(List<Group__c>)Trigger.NEW){
                if(gvnMap.containsKey(g.Group_Number__c)){
                    gvnMap.get(g.Group_Number__c).Version_Number__c = gvnMap.get(g.Group_Number__c).Version_Number__c + 1;
                    g.Version__c = gvnMap.get(g.Group_Number__c).Version_Number__c;
                }
            }
            
            try{
                upsert gvnMap.values();
            }catch(Exception e){
                system.debug('Could not update version map ' + gvnMap);
            }
            
        }
    }
    
    //WHICS Fields validation
    public Void whicsValidation(){
        
        if(Label.WHICS_Val.toUpperCase() == 'TRUE'){
        	guUtil utility = new guUtil();
			utility.lockedFields('Group__c', 'Is_Active__c');
        }
        
    }
    
    //Change record type of records published through the publish wizard
    public Void publishWizard(){

        for(Group__c g :(List<Group__c>)Trigger.NEW){
            if(g.IsPublishWizard__c){
                g.IsPublishWizard__c = FALSE;
            }
        }
        
    }
    
    //Join Online Mass deactivation when group is closed 
    public void MassDeactivateSectionOnGrpClose(){
        map<id,Group__c> mGrpCls = new map<id,Group__c>();
        for(Group__c g :(List<Group__c>)Trigger.NEW){
            if(g.Is_Active__c == 'Closed'){
                mGrpCls.put(g.id, g);
            }
        }
        list<section__c> SecLst = [select id ,OMS_status__c,OMS_Disabled_Date__c from section__c where 	Group__c in : mGrpCls.keySet()  and  Section_Number__c not in ('0','300') and OMS_status__c != 'Disabled'    ];
        for(section__c sec : SecLst ){
            sec.OMS_status__c = 'Disabled';
            sec.OMS_Disabled_Date__c = date.today();
        }
        update SecLst;
    }
    
}