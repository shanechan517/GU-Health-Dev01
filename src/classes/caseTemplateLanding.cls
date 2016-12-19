public class caseTemplateLanding{
    
    //Error messages
    public Boolean error {get;set;}
    public String errorMsg {get;set;}
    //END Error messages
    
    public string objectName {get;set;}
    
    //Search elements
    public String searchCriteria {get;set;}
    public List<Group__c> searchGroup {get;set;}
    public List<Section__c> searchSection {get;set;}
    public List<Opportunity> searchOpportunity {get;set;}
    public List<Account> searchClient {get;set;}
    public List<Section_Product__c> searchProduct {get;set;}
    public Integer resultSize {get;set;}
    //END Search elements
    
    public caseTemplateLanding(ApexPages.StandardController stdController){
        
        searchCriteria = '';
        resultSize = 0;
        
    }
    
    public PageReference searchSF(){
        
        system.debug('Made it');
        error = false;
        
        if(searchCriteria != null && searchCriteria != '' && objectName != null && objectName != '' && objectName != 'None'){
            String searchVariable = '%' + searchCriteria + '%';
            if(objectName == 'Opportunity' || objectName == 'Renewal' || objectName == 'Client Maintenance'){                
                searchOpportunity = new List<Opportunity>([SELECT Id, Name, AccountId, Account.Name, RecordType.Name, CloseDate, CreatedDate, Owner.Alias FROM Opportunity WHERE Account.Name LIKE:searchVariable AND RecordType.Name =:objectName ]);
                resultSize = searchOpportunity.size();
                searchClient = null;
                searchGroup = null;
                searchSection = null;
                searchProduct = null;
            }else if(objectName == 'Client'){
                searchClient = new List<Account>([SELECT Id, Name, Phone, RecordType.Name, BillingState, Owner.Alias, Default_Broker__r.Name FROM Account WHERE Name LIKE:searchVariable]);
                resultSize = searchClient.size();
                searchOpportunity = null;
                searchGroup = null;
                searchSection = null;
                searchProduct = null;
            }else if(objectName == 'Group'){
                searchGroup = new List<Group__c>([SELECT Id, Name, Client_Id__c, Client_Name__c, Group_Number__c, Rate_Code__c, Start_Date__c, Is_Active__c FROM Group__c WHERE Client_Name__c LIKE:searchVariable]);
                resultSize = searchGroup.size();
                searchOpportunity = null;
                searchClient = null;
                searchSection = null;
                searchProduct = null;
            }else if(objectName == 'Section'){
                searchSection = new List<Section__c>([SELECT Id, Name, Client_Id__c, Client_Name__c, Associated_System_Section__r.Name, Broker_Name__c, Date_Closed__c, Group__r.Name, Member__c FROM Section__c WHERE Client_Name__c LIKE:searchVariable]);
                resultSize = searchSection.size();
                searchOpportunity = null;
                searchClient = null;
                searchGroup = null;
                searchProduct = null;
            }else{
                error = true;
                errorMsg = 'There was an error understanding which object you wish to create cases for. Please ensure an object is specified and try again. If the error persists please contact an administrator.';
                return null;
            }
        }else{
            error = true;
            errorMsg = 'This search requires that both the Object be specified as we  as the search criteria box have a value. Please ensure these fields are populated and try again.';
            return null;
        }
        
        return null;
        
    }
    
    public List<SelectOption> getListOfObjects() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--Please Select an Object--'));
        Schema.DescribeFieldResult fieldResult = Case_Template_Group__c.Object__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
          options.add(new SelectOption(f.getLabel(), f.getValue()));
        } 
        
        return options;
    }
    
}