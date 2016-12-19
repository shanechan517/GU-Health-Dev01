public class groupExtension {

    private Group__c grp;
    public List<Group__c> gList {get;set;}
    //public List<Case> cList {get;set;}
     
    //public String recordId {get;set;}
    public String errorLevel {get; set;}
    public String messageName {get; set;}
    
    //Map initially created for the Sections to allow any manipulations before transfered to final list
    public Map<String, Section__c> sMap {get;set;}
    //List created to be viewed in custom related list on view page
    public List<Section__c> sList {get;set;}
    //String to show on Colsed Section related list
    public String sMapMessage {get;set;}
    //Lists to store the locked fields and the synced fields
    public String lockedFields {get;set;}
    public String syncFields {get;set;}

    public groupExtension (ApexPages.StandardController stdController) {
        if(!test.isRunningTest()){
            stdController.AddFields(new List<String>{'Version__c'});
            stdController.AddFields(new List<String>{'Group_Number__c'});
            stdController.AddFields(new List<String>{'Clone_Of__c'});
            stdController.AddFields(new List<String>{'Clone_Of__r.Is_Active__c'});
            stdController.AddFields(new List<String>{'RecordType.Name'});
        }
        this.grp = (Group__c)stdController.getRecord();
        
        if(!test.isRunningTest()){
            if(grp.RecordType.Name == 'Draft' && grp.Clone_Of__c != null && grp.Clone_Of__r.Is_Active__c != 'Active'){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'The Group has been amended since this version was created. Changes can be viewed and merged into the draft in the Publishing Wizard.'));
            }
        }
        
        gList = new List<Group__c>();
        
        sList = new List<Section__c>();
        sMap = new Map<String, Section__c>();
        
        populateTables();
        
        //populate the locked fields list to pass to Javascript array
        List<String> lockTemp = new List<String>();
        List<Schema.FieldSetMember> LockedFieldSetMemberList =  Util.readFieldSet('WHICSFields','Group__c');
        for(Schema.FieldSetMember fieldSetMemberObj : LockedFieldSetMemberList){
            //lockedFields.add(fieldSetMemberObj.getFieldPath()); //api name
            lockTemp.add(fieldSetMemberObj.getLabel()); //label name
        }
        lockedFields = JSON.serialize(lockTemp);
        
        //populate the sync fields list to pass to Javascript array
        List<String> syncTemp = new List<String>();
        List<Schema.FieldSetMember> syncFieldSetMemberList =  Util.readFieldSet('SyncFields','Group__c');
        for(Schema.FieldSetMember fieldSetMemberObj : syncFieldSetMemberList){
            //syncFields.add(fieldSetMemberObj.getFieldPath()); //api name
            syncTemp.add(fieldSetMemberObj.getLabel()); //label name
        }
        syncFields = JSON.serialize(syncTemp);
        
    }
    
    public Void populateTables(){
        if(!test.isRunningTest() && grp.Group_Number__c != null){
            gList = new List<Group__c>([SELECT Opportunity_Type__c, Id, Name, Renewal_Date__c, Group_Number__c, Start_Date__c, Rate_Code__c, Is_Active__c,Version__c, Closed_On__c FROM Group__c WHERE Group_Number__c =:grp.Group_Number__c ORDER BY Version__c]);
        }
        
        //We can only go through this process if the following fields are not null, otherwise the soql will fail
        if(grp.Version__c != null && grp.Group_Number__c != null){
            
             //Build a set of product codes related to this record so that we can ensure these are not in the history related list
            Set<String> sectionNumbers = new Set<String>();
            List<Section__c> secCheck = new List<Section__c>([SELECT Id, Section_Number__c FROM Section__c WHERE Group__c =:grp.Id]);
            for(Section__c s:secCheck){
                sectionNumbers.add(s.Section_Number__c);
            }
            
            //Get all section product links that were related to this psection in the past, and exclude any product codes that are currently active (done through SOQL)
            List<Section__c> oldSections = new List<Section__c>([SELECT Id,Name,Section_Number__c, Date_On__c, Date_Closed__c, Status__c, Group_Number__c, Group_Version__c, Group__c, Group__r.Is_Active__c FROM Section__c WHERE Group_Number__c =:grp.Group_Number__c AND Group_Version__c <:grp.Version__c AND Section_Number__c NOT IN:sectionNumbers AND Status__c = 'Inactive' ORDER BY Group_Version__c DESC ]);
            if(!oldSections.isEmpty()){
                sMapMessage = 'No records to display';
                for(Section__c s:oldSections){
                    //The SOQL orders by Version number descending, so we only need the latest version
                    if(!sMap.containsKey(s.Section_Number__c)){
                        sMap.put(s.Section_Number__c, s);
                    }
                }
                
                //After manipulation, add the final values to the list to be displayed on the page
                if(!sMap.isEmpty()){
                    for(Section__c s:sMap.values()){
                        sList.add(s);
                    }
                }
            }else{
                sMapMessage = 'No records to display';
            }
        }else{
            //If the fields are not all populated, let the user know that the data is not accessible
            sMapMessage = 'Data not accessible due to incomplete group number and/or version.';
        }
    }
    
    public void showMessage() {
      if(errorLevel == 'WARNING') {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, messageName));
      }
    }
}