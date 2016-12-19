public class caseTemplateBuilder{
    
    public List<Case_Template_Group__c> ctgList {get;set;}
    public Map<Integer, Case> newCases {get;set;}
    
    public Integer newCasesSize {get;set;}
    public Integer ctgListSize {get;set;}
    
    public Id objectId {get;set;}
    public string objectName {get;set;}
    public Integer NumberOfEmployees {get;set;}
    
    public BusinessHours bh {get;set;}
    
    public Id accountId {get;set;}
    public Account acc {get;set;}
    public Id selectedTemplate {get;set;}
    public Map<String, Id> assignTo {get;set;}
    public Map<String, Id> recordTypes {get;set;}
    
    public Boolean error {get;set;}
    public String errorMsg {get;set;}
    
    public DateTime startingDate {get;set;}
    
    //objects for information
    public List<Group__c> searchGroup {get;set;}
    public List<Section__c> searchSection {get;set;}
    public List<Opportunity> searchOpportunity {get;set;}
    public List<Account> searchClient {get;set;}
    public List<Section_Product__c> searchProduct {get;set;}
    //END objects for information
    
    public caseTemplateBuilder(){
        
        ctgList = new List<Case_Template_Group__c>();
        assignTo = new Map<String, Id>();
        newCases = new Map<Integer, Case>();
        
        startingDate = system.NOW();
        
        objectId = ApexPages.CurrentPage().getParameters().get('oid');
        objectName = ApexPages.CurrentPage().getParameters().get('sObjectType');
        if(objectName == 'ClientMaintenance'){
            objectName = 'Client Maintenance';
        }
        if(objectName != null){
            populateCTG();
        }
        accountId = ApexPages.CurrentPage().getParameters().get('aid');
        if(accountId != null){
            List<Account> acList = new list<Account>([SELECT Name FROM Account WHERE Id=:accountId]);
            if(!acList.isEmpty()){
                acc = acList[0];
            }
        }
        
        system.debug('Object Id = ' + objectId + ' || Object Name = ' + objectName);
        
        if(objectId != null && objectName != null){
            if(objectName == 'Opportunity' || objectName == 'Renewal' || objectName == 'Client Maintenance'){                
                searchOpportunity = new List<Opportunity>([SELECT Id, Name, AccountId, Account.Name, RecordType.Name, CloseDate, CreatedDate, Owner.Alias FROM Opportunity WHERE Id=:objectId ]);
            }else if(objectName == 'Client'){
                searchClient = new List<Account>([SELECT Id, Name, Phone, RecordType.Name, BillingState, Owner.Alias, Default_Broker__r.Name FROM Account WHERE Id=:objectId]);
            }else if(objectName == 'Group'){
                searchGroup = new List<Group__c>([SELECT Id, Name, Client_Name__c, Group_Number__c, Rate_Code__c, Start_Date__c, Is_Active__c FROM Group__c WHERE Id=:objectId]);
            }else if(objectName == 'Section'){
                searchSection = new List<Section__c>([SELECT Id, Name, Client_Name__c, Associated_System_Section__r.Name, Broker_Name__c, Date_Closed__c, Group__r.Name, Member__c FROM Section__c WHERE Id=:objectId]);
            }else if(objectName == 'Product'){
                searchProduct = new List<Section_Product__c>([SELECT Id, Name, Product_Code__c, Product_Name_System__c, Product_Type__c, Rate_Code__c, Start_Date__c FROM Section_Product__c WHERE Id=:objectId]);
            }
        }
        
        List<BusinessHours> bhList = new List<BusinessHours>([SELECT Id FROM BusinessHours WHERE Name = 'GU Default']);
        if(!bhList.isEmpty()){
            bh = bhList[0];
        }
        
        checkSize();
        
        error = false;
        
        List<Group> qList = new List<Group>([SELECT Id, Name FROM Group WHERE Type = 'Queue']);
        if(!qList.isEmpty()){
            for(Group q:qList){
                assignTo.put(q.Name, q.Id);
            }
        }
        
        recordTypes = new Map<String, Id>();
        List<RecordType> rtList = new List<RecordType>([SELECT Id, Name FROM RecordType WHERE sObjectType = 'Case' AND (Name = 'Parent' OR Name = 'Child') LIMIT 2]);
        if(!rtList.isEmpty()){
            for(RecordType rt:rtList){
                recordTypes.put(rt.Name, rt.Id);
            }
        }
        
    }
    
    public Void populateCTG(){
        
        error = false;
        
        if(objectName == null || objectName == ''){
            error = true;
            errorMsg = 'An object type has not been selected. Please select an object type before proceeding.';
            ctgList = new List<Case_Template_Group__c>();
            newCases = new Map<Integer, Case>();
        }else{
            ctgList = new List<Case_Template_Group__c>([SELECT Id, Name FROM Case_Template_Group__c WHERE IsActive__c = true AND Object__c INCLUDES(:objectName) ORDER BY Name]);
        }
        
        checkSize();
    }
    
    public Void checkSize(){
        newCasesSize = newCases.size();
        ctgListSize = ctgList.size();
    }
    
    public PageReference findCaseTemplates(){
        
        newCases = new Map<Integer, Case>();
        error = false;
        
        if(accountId != null){
            List<Account> acList = new List<Account>([SELECT Id, Name, OwnerId, NumberOfEmployees FROM Account WHERE Id=:accountId LIMIT 1]);
            if(!acList.isEmpty()){
                for(Account a:acList){
                    assignTo.put('AM', a.OwnerId);
                    NumberOfEmployees = a.NumberOfEmployees;
                }
            }
        }
        
        List<Case_Template__c> ctList = new List<Case_Template__c>([SELECT Fixed_SLA__c, SLA1__c, SLA2__c, Id, Name, Code__c, Dependency__c, Description__c, Assigned_To__c, Type__c, Organisation_Size__c FROM Case_Template__c WHERE Group__c =:selectedTemplate ORDER BY Code__c ASC]);
        if(!ctList.isEmpty()){
            
            for(Case_Template__c ct:ctList){
                Case c = new Case();
                if(acc != null && acc.Name != null){
                    c.Subject = acc.Name + ' - ' + ct.Name;
                }else{
                    c.Subject = ct.Name;
                }
                c.Type = ct.Type__c;
                c.Code__c = ct.Code__c;
                c.Dependancy__c = ct.Dependency__c;
                c.Description = ct.Description__c;
                c.Skip_Case__c = false;
                c.Team__c = ct.Assigned_To__c;
                
                if(bh != null){
                    c.BusinessHoursId = bh.Id;
                }
                
                if(c.Code__c == 0 && recordTypes.containsKey('Parent')){
                    c.RecordTypeId = recordTypes.get('Parent');
                    if(objectName == 'Opportunity' || objectName == 'Renewal' || objectName == 'Client Maintenance'){
                        c.Opportunity_Renewal__c = objectId;
                    }else if(objectName == 'Client'){
                        c.AccountId = objectId;
                    }else if(objectName == 'Group'){
                        c.Group__c = objectId;
                    }else if(objectName == 'Section'){
                        c.Section__c = objectId;
                    }else{
                        error = true;
                        errorMsg = 'Could not associate the parent case with an object. Please ensure the object name and the selected record match up before proceeding.';
                        return null;
                    }
                }else if(recordTypes.containsKey('Child')){
                    c.RecordTypeId = recordTypes.get('Child');
                }
                
                if(c.Code__c > 0){
                    if(NumberOfEmployees != null && NumberOfEmployees > 0 && !ct.Fixed_SLA__c && ct.SLA2__c != null){
                        if(NumberOfEmployees >= ct.Organisation_Size__c){
                            c.SLA_Days__c = ct.SLA2__c;
                        }else{
                            c.SLA_Days__c = ct.SLA1__c;
                        }
                    }else{
                        c.SLA_Days__c = ct.SLA1__c;
                    }
                    
                    if(assignTo.containsKey(ct.Assigned_To__c)){
                        c.OwnerId = assignTo.get(ct.Assigned_To__c);
                    }
                }
                
                newCases.put(Integer.valueOf(c.Code__c), c);
            }
            
            //Recalculate the SLAs
            recalcSLAs();
            
        }
        
        system.debug('Cases List ' + newCases);
        
        checkSize();
        return null;
        
    }
    
    public Void recalcSLAs(){
        //Calculate the SLAs
        if(!newCases.isEmpty() && newCases.containsKey(0) && newCases.get(0).Estimated_Start_Date__c != null){
            startingDate = newCases.get(0).Estimated_Start_Date__c;
        }else{
            startingDate = system.NOW();
        }
        
        guUtil slap = new guUtil();
        newCases = slap.recalcSLA(newCases, bh, startingDate);
    }
    
    public PageReference submit(){
        
        error = false;
        List<Case> insertList = new List<Case>();
        Case parentCase;
        
        for(Case c:newCases.values()){
            if(c.Code__c == 0){
                parentCase = c;
            }else{
                insertList.add(c);
            }
        }
        
        try{
            insert parentCase;
        }catch(Exception e){
            system.debug('Parent Case insert failed ' + parentCase);
            error = true;
            errorMsg = 'There was an error trying to insert the parent case. Please try again, and if the error persists please contact a system administrator to check the data.';
            return null;
        }
        
        for(Case c:insertList){
            c.ParentId = parentCase.Id;
            if(c.Skip_Case__c){
                c.Status = 'Not Required';
            }
        }
        
        try{
            insert insertList;
        }catch(Exception e){
            system.debug('Child Cases insert failed ' + insertList);
            error = true;
            errorMsg = 'There was an error trying to insert the child cases. Please try again, and if the error persists please contact a system administrator to check the data.';
            return null;
        }
        
        PageReference returnRecord = new PageReference('/' + objectId);
        return returnRecord;
        
    }
    
    public List<SelectOption> getGroups() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--Please Select a Group--'));
        for(Case_Template_Group__c g:ctgList){
            options.add(new SelectOption(g.Id,g.Name));
        }

        return options;
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