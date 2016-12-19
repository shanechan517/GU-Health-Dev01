public class sectionExtension {
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //
    //    Section Extension to permit additional functions on the SectionView page (replace standard UI
    //    The case list has been left here but has been removed from the VF page and a standard list used instead.
    //    We are however still using the custom product (Section_Product_Link__c) related list which gets all products that were linked to this section in the past but are not anymore
    //
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    private final Section__c section;
    //Custom Case list for related list
    public List<Case> cList {get;set;}
    //Map initially created for the Section Product Links to allow any manipulations before transfered to final list
    public Map<String, Section_Product_Link__c> splMap {get;set;}
    //List created to be viewed in custom related list on view page
    public List<Section_Product_Link__c> splList {get;set;}
    //Lists to store the locked fields and the synced fields
    public String lockedFields {get;set;}
    public String syncFields {get;set;}
    
    public String splMapMessage {get;set;}

    public sectionExtension (ApexPages.StandardController stdController) {
        //Add fields to record accessible by apex class (for SOQL query parameters mainly)
        if(!test.isRunningTest()){
            stdController.AddFields(new List<String>{'Group_Version__c'});
            stdController.AddFields(new List<String>{'Group_Number__c'});
            stdController.AddFields(new List<String>{'Section_Number__c'});
        }
        this.section = (Section__c)stdController.getRecord();
        
        //CASE RELATED LIST
        //Build a list of associated Cases
        cList = new List<Case>([SELECT Id, CaseNumber, Subject, Status, CreatedDate, Priority FROM Case WHERE Section__c =:section.Id ORDER BY CreatedDate]);
        
        //SECTION PRODUCT LINK RELATED LIST (PRODUCT HISTORY)
        //Create an instance of the Map and the List now to prevent null errors
        splMap = new Map<String, Section_Product_Link__c>();
        splList = new List<Section_Product_Link__c>();
        
        //We can only go through this process if the following fields are not null, otherwise the soql will fail
        if(section.Group_Version__c != null && section.Group_Number__c != null && section.Section_Number__c != null){
            //Build a set of product codes related to this record so that we can ensure these are not in the history related list
            Set<String> productCodes = new Set<String>();
           
            List<Section_Product_Link__c> splCheck = new List<Section_Product_Link__c>([SELECT Id, Product__r.Product_Code__c FROM Section_Product_Link__c WHERE Section__c =:section.Id]);
            
            for(Section_Product_Link__c spl:splCheck){
                productCodes.add(spl.Product__r.Product_Code__c);
            }
            
            //Get all section product links that were related to this psection in the past, and exclude any product codes that are currently active (done through SOQL)
             List<Section_Product_Link__c> splAR = new List<Section_Product_Link__c>([SELECT Id,Product__c,Product__r.Product_Code__c, Product__r.Rate_Code__c, Product__r.Product_Type__c,Section__c, Section__r.Group_Number__c, Section__r.Group_Version__c,Section__r.Group__c, Date_closed__c, Base_or_Upgrade__c, Section__r.Group_Status__c, Fixed_Amount_Funded__c, Percentage_Funded__c, Product_Broker_Code__c, Start_Date__c, Withdrawn_Date__c, LHC__c, Rebate__c, Product__r.Name FROM Section_Product_Link__c WHERE Section__r.Group_Number__c =:section.Group_Number__c AND Section_Number__c =:section.Section_Number__c AND Section__r.Group_Version__c <:section.Group_Version__c AND Product__r.Product_Code__c NOT IN :productCodes ORDER BY Section__r.Group_Version__c DESC ]);
            
            if(!splAR.isEmpty()){
                splMapMessage = 'No records to display';
                for(Section_Product_Link__c spl:splAR){
                    //The SOQL orders by Version number descending, so we only need the latest version
                    if(!splMap.containsKey(spl.Product__r.Product_Code__c)){
                        splMap.put(spl.Product__r.Product_Code__c, spl);
                    }
                }
                
                //After manipulation, add the final values to the list to be displayed on the page
                if(!splMap.isEmpty()){
                    for(Section_Product_Link__c spl:splMap.values()){
                        splList.add(spl);
                    }
                }
            }else{
                splMapMessage = 'No records to display';
            }
        }else{
            //If the fields are not all populated, let the user know that the data is not accessible
            splMapMessage = 'Data not accessible due to incomplete parent sections/groups';
        }
        
        //populate the locked fields list to pass to Javascript array
        List<String> lockTemp = new List<String>();
        List<Schema.FieldSetMember> LockedFieldSetMemberList =  Util.readFieldSet('WHICSFields','Section__c');
        for(Schema.FieldSetMember fieldSetMemberObj : LockedFieldSetMemberList){
            //lockedFields.add(fieldSetMemberObj.getFieldPath()); //api name
            lockTemp.add(fieldSetMemberObj.getLabel()); //label name
        }
        lockedFields = JSON.serialize(lockTemp);
        
        //populate the sync fields list to pass to Javascript array
        List<String> syncTemp = new List<String>();
        List<Schema.FieldSetMember> syncFieldSetMemberList =  Util.readFieldSet('SyncFields','Section__c');
        for(Schema.FieldSetMember fieldSetMemberObj : syncFieldSetMemberList){
            //syncFields.add(fieldSetMemberObj.getFieldPath()); //api name
            syncTemp.add(fieldSetMemberObj.getLabel()); //label name
        }
        syncFields = JSON.serialize(syncTemp);
        
    }
}