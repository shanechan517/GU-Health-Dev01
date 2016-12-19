public class accountExtension {

    private final Account acct;
    public List<Opportunity> renewalList {get;set;}
    public List<Opportunity> newList {get;set;}
    public List<Opportunity> cmList {get;set;}
    public List<Opportunity> brokerList {get;set;}
    public List<Group__c> gList {get;set;}
    public List<Group__c> allgList {get;set;}
    
    public Id renewalId {get;set;}
    public Id opportunityId {get;set;}
    
    public String recordId {get;set;}

    public accountExtension(ApexPages.StandardController stdController) {
        if(!test.isRunningTest()){
            stdController.AddFields(new List<String>{'RecordType.Name'});
        }
        this.acct = (Account)stdController.getRecord();
        
        recordId = apexpages.currentpage().getparameters().get('id');
        
        List<RecordType> rtList = new List<RecordType>([SELECT Id, Name FROM RecordType WHERE sObjectType = 'Opportunity' AND (Name = 'Opportunity' OR Name = 'Renewal')]);
        if(!rtList.isEmpty()){
            for(RecordType rt:rtList){
                if(rt.Name == 'Opportunity'){
                    opportunityId = rt.Id;
                }else if(rt.Name == 'Renewal'){
                    renewalId = rt.Id;
                }
            }
        }
        
        if(acct.RecordType.Name != 'Broker'){
            renewalList = new List<Opportunity>([SELECT Id, Name, Amount, StageName, CloseDate, Opportunity_Number__c, CreatedBy.Alias FROM Opportunity WHERE RecordTypeId IN (SELECT Id FROM RecordType WHERE sObjectType = 'Opportunity' AND Name = 'Renewal') AND AccountId=:acct.Id]);
            newList = new List<Opportunity>([SELECT Id, Name, Amount, StageName, CloseDate, Opportunity_Number__c, CreatedBy.Alias FROM Opportunity WHERE RecordTypeID IN (SELECT Id FROM RecordType WHERE sObjectType = 'Opportunity' AND Name = 'Opportunity') AND AccountId=:acct.Id]);
            cmList = new List<Opportunity>([SELECT Id, Name, Amount, StageName, CloseDate, Opportunity_Number__c, CreatedBy.Alias FROM Opportunity WHERE RecordTypeId IN (SELECT Id FROM RecordType WHERE sObjectType = 'Opportunity' AND Name = 'Client Maintenance') AND AccountId=:acct.Id]);
        }else{
            brokerList = new List<Opportunity>([SELECT Id, Name, Amount, StageName, CloseDate, Opportunity_Number__c, CreatedBy.Alias, Account.Name, AccountId FROM Opportunity WHERE RecordTypeId IN (SELECT Id FROM RecordType WHERE sObjectType = 'Opportunity' AND Name = 'Opportunity') AND Broker__c=:acct.Id ORDER BY Account.Name]);
        }
        
        gList = new List<Group__c>([SELECT Id, Name, Group_Number__c, Start_Date__c, Rate_Code__c, Is_Active__c, Version__c FROM Group__c WHERE Client_Id__c =:recordId AND (Is_Active__c = 'Active' OR Is_Active__c = 'Pending') ORDER BY Name, Version__c DESC]);
        allgList = new List<Group__c>([SELECT Id, Name, Group_Number__c, Start_Date__c, Rate_Code__c, Is_Active__c, Version__c FROM Group__c WHERE Client_Id__c =:recordId ORDER BY Group_Number__c, Version__c DESC]);
    }
}