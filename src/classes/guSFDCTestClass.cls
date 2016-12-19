/////////////////////////////////////////////////////////////////
// Test class constructed for end-to-end process (go live r1)
// David Dawson
/////////////////////////////////////////////////////////////////
@isTest
private class guSFDCTestClass {
    
    static testMethod void opportunityProcess() {
        
        //generate data
        guTestUtil.generateTestData();
        
        Account client = [SELECT Id, Name, RecordTypeId, RecordType.Name, NumberOfEmployees FROM Account WHERE Name = 'Test Client' LIMIT 1];
        Opportunity newOp = [SELECT Start_Date__c, StageName, CloseDate, Name, AccountId, Commercial_Analyst__c, RecordTypeId FROM Opportunity WHERE Name = 'Test Company Opportunity' LIMIT 1];
        Group__c newGroup = [SELECT Group_Number__c, Opportunity__c, Name, RecordTypeId, Version__c,Clone_Of__c, Clone_Of__r.Is_Active__c, RecordType.Name FROM Group__c WHERE Group_Number__c = '11111' LIMIT 1];
        Section__c newSec = [SELECT Group__c, Name, Section_Number__c, Date_On__c, Date_Closed__c, Group_Version__c, Group_Number__c FROM Section__c WHERE Group_Number__c = :newGroup.Group_Number__c AND Section_Number__c = '0' LIMIT 1];
        Section_Product_Link__c newSPL = [SELECT Section__c, Product__c FROM Section_Product_Link__c LIMIT 1];
        
        List<Case_Template_Group__c> ctgList = new List<Case_Template_Group__c>([SELECT Name, Subject__c, Object__c, ExternalId__c FROM Case_Template_Group__c]);
        Case_Template_Group__c ctg = ctgList[0];
        
        List<Case_Template__c> ctList = new List<Case_Template__c>([SELECT Name, RecordTypeId, Group__c, Subject__c, Assigned_To__c, Code__c, Fixed_Sla__c, Dependency__c, SLA1__c, SLA2__c, Organisation_Size__c FROM Case_Template__c]);
        Case_Template__c ct0 = ctList[0];
        Case_Template__c ct1 = ctList[1];
        Case_Template__c ct2 = ctList[2];
        
        Map<String, RecordType> rtMap = new Map<String, RecordType>();
        List<RecordType> rtList = new List<RecordType>([SELECT Id, sObjectType, Name FROM RecordType]);
        if(!rtList.isEmpty()){
            for(RecordType rt:rtList){
                rtMap.put(rt.Name + ' ' + rt.sObjectType, rt);
            }
        }
        
        Test.Starttest();
        
            //View Account
            ApexPages.StandardController stdaController = new ApexPages.StandardController(client);
            accountExtension aE = new accountExtension(stdaController);
            
            //View Opportunity
            ApexPages.StandardController stdopController = new ApexPages.StandardController(newOp);
            opportunityExtension oE = new opportunityExtension(stdopController);
            
            //View Group (only gets 69% coverage, need to fire again post Client Maintenance or Renewal process test)
            ApexPages.StandardController stdgController = new ApexPages.StandardController(newGroup);
            groupExtension gE = new groupExtension(stdgController);
        	gE.showMessage();
            
            //View Section
            ApexPages.StandardController stdsecController = new ApexPages.StandardController(newSec);
            sectionExtension secE = new sectionExtension(stdsecController);
        
        //Edit a field in Section that will fire WHICS calidation (locked fields)
        //Section
        newSec.Member__c = 200;
        update newSec;
		
        //Section Product Link
        newSPL.LHC__c = TRUE;
        update newSPL;
        
        //Go to case landing page and select the insert opportunity above
        Case c = new Case();
        ApexPages.StandardController caseController = new ApexPages.StandardController(c);  
        caseTemplateLanding ctl = new caseTemplateLanding(caseController);
        //call picklist items
        ctl.getListOfObjects();
        
        //Search for each object
            //Search for Opportunity
            ctl.objectName = 'Opportunity';
            ctl.searchCriteria = 'test';
            ctl.searchSF();
        
            //Search for Group
            ctl.objectName = 'Group';
            ctl.searchCriteria = 'test';
            ctl.searchSF();
        
            //Search for Section
            ctl.objectName = 'Section';
            ctl.searchCriteria = 'test';
            ctl.searchSF();
        
            //Search for Client
            ctl.objectName = 'Client';
            ctl.searchCriteria = 'test';
            ctl.searchSF();
        
        //Lets open the Case Builder page
            //Open an opportunity record
            Test.setCurrentPageReference(new PageReference('Page.caseTemplateBuilder'));
            System.currentPageReference().getParameters().put('oid', newOp.Id);
            System.currentPageReference().getParameters().put('aid', client.Id);
            System.currentPageReference().getParameters().put('sObjectType', 'Opportunity');
            caseTemplateBuilder ctbOp = new caseTemplateBuilder();
        
            ctbOp.selectedTemplate = ctg.Id;
            ctbOp.findCaseTemplates();
            ctbOp.submit();
        
            //Open an account record
            Test.setCurrentPageReference(new PageReference('Page.caseTemplateBuilder'));
            System.currentPageReference().getParameters().put('oid', client.Id);
            System.currentPageReference().getParameters().put('aid', client.Id);
            System.currentPageReference().getParameters().put('sObjectType', 'Client');
            caseTemplateBuilder ctbAc = new caseTemplateBuilder();
        
            ctbAc.selectedTemplate = ctg.Id;
            ctbAc.findCaseTemplates();
            ctbAc.submit();
        
            //Open a group record
            Test.setCurrentPageReference(new PageReference('Page.caseTemplateBuilder'));
            System.currentPageReference().getParameters().put('oid', newGroup.Id);
            System.currentPageReference().getParameters().put('aid', client.Id);
            System.currentPageReference().getParameters().put('sObjectType', 'Group');
            caseTemplateBuilder ctbGr = new caseTemplateBuilder();
        
            ctbGr.selectedTemplate = ctg.Id;
            ctbGr.findCaseTemplates();
            ctbGr.submit();
        
            //Open a section record
            Test.setCurrentPageReference(new PageReference('Page.caseTemplateBuilder'));
            System.currentPageReference().getParameters().put('oid', newSec.Id);
            System.currentPageReference().getParameters().put('aid', client.Id);
            System.currentPageReference().getParameters().put('sObjectType', 'Section');
            caseTemplateBuilder ctbSec = new caseTemplateBuilder();
        
            ctbSec.selectedTemplate = ctg.Id;
            ctbSec.findCaseTemplates();
            ctbSec.submit();
            ctbSec.getGroups();
            ctbSec.getListOfObjects();
        
        //insert some cases that meet the case scheduler requirements
        List<Case> caseList = new List<Case>();
        caseList.add(new Case(Estimated_Close_Date__c = system.Today().addDays(-1)));
        caseList.add(new Case(Estimated_Close_Date__c = system.Today()));
        caseList.add(new Case(Estimated_Close_Date__c = system.Today().addDays(1)));
        insert caseList;
        
        //Run the case scheduler
        Datetime dtcase = Datetime.now().addMinutes(1);
        String CRON_EXPcase = '0 '+ dtcase.minute() + ' * ' + dtcase.day() + ' ' + dtcase.month() + ' ? ' + dtcase.year();
        String jobIdcase = System.schedule('Case_Heading', CRON_EXPcase, new caseSLACheckSchedule() ); 
        
        //Close some cases to check that the job trigger is working
        List<Case> cList = new List<Case>([SELECT Id, Status, ClosedDate FROM Case WHERE Status = 'Task ready to start']);
        for(Case ca:cList){
            ca.Status = 'Task completed';
        }
        update cList;
        
        List<Case> c2List = new List<Case>([SELECT Id, Status, ClosedDate FROM Case WHERE Status = 'Task ready to start']);
        for(Case ca2:c2List){
            ca2.Status = 'Task completed';
        }
        update c2List;
    
        Test.Stoptest();

    }
    
    static testMethod void  SectionCloseDateISTodayTest(){
        //generate data
        guTestUtil.generateTestData();
        SectionCloseDateISToday sobj = new SectionCloseDateISToday();
        Test.Starttest();
        	sobj.execute(null);
        Test.Stoptest();   
    }
    
    static testMethod void  ProductHandlerTest(){
        //generate data
        boolean bErroGenCvrCode = false;
        boolean bErroGenCvrCode2 = false;
        boolean bErroGenCvrCode3 = false;
        guTestUtil.generateTestData();
        list<Section_Product__c> newSPLst = [select id , Cover_Code__c from Section_Product__c limit 200 ];
        Test.Starttest();
        Section_Product__c newSP = newSPLst[0];
        newSP.Cover_Code__c = '123 124 125';
        update newSP;
        
        newSP.Cover_Code__c = '123 124 125 3dffsafa';
        try {
          update newSP;  
        }catch(system.DmlException DMLe){
            bErroGenCvrCode = true;
        }
        
        newSP.Cover_Code__c = '123 124 999';
        try {
          update newSP;  
        }catch(system.DmlException DMLe){
            bErroGenCvrCode2 = true;
        }
        
        
        newSP.Cover_Code__c = '';
        try {
          update newSP;  
        }catch(system.DmlException DMLe){
            bErroGenCvrCode3 = true;
        }
        Test.Stoptest(); 
        
        system.assertEquals(bErroGenCvrCode , true);
        system.assertEquals(bErroGenCvrCode2 , true);
        system.assertEquals(bErroGenCvrCode3 , false); 
        
    }
    
    static testMethod void cloningProcess() {
        
        //generate data
        guTestUtil.generateTestData();
        
        Account client = [SELECT Id, Name, RecordTypeId, RecordType.Name, NumberOfEmployees FROM Account WHERE Name = 'Test Client' LIMIT 1];
        Opportunity newOp = [SELECT Start_Date__c, StageName, CloseDate, Name, AccountId, Commercial_Analyst__c, RecordTypeId FROM Opportunity WHERE Name = 'Test Company Opportunity' LIMIT 1];
        Group__c newGroup = [SELECT Group_Number__c, Opportunity__c, Name, RecordTypeId FROM Group__c WHERE Group_Number__c = '11111' LIMIT 1];
        Section__c newSec = [SELECT Group__c, Name, Section_Number__c, Date_On__c, Date_Closed__c, Group_Version__c, Group_Number__c FROM Section__c WHERE Group_Number__c = :newGroup.Group_Number__c AND Section_Number__c = '0' LIMIT 1];
        
        List<Case_Template_Group__c> ctgList = new List<Case_Template_Group__c>([SELECT Name, Subject__c, Object__c, ExternalId__c FROM Case_Template_Group__c]);
        Case_Template_Group__c ctg = ctgList[0];
        
        List<Case_Template__c> ctList = new List<Case_Template__c>([SELECT Name, RecordTypeId, Group__c, Subject__c, Assigned_To__c, Code__c, Fixed_Sla__c, Dependency__c, SLA1__c, SLA2__c, Organisation_Size__c FROM Case_Template__c]);
        Case_Template__c ct0 = ctList[0];
        Case_Template__c ct1 = ctList[1];
        Case_Template__c ct2 = ctList[2];
        
        Map<String, RecordType> rtMap = new Map<String, RecordType>();
        List<RecordType> rtList = new List<RecordType>([SELECT Id, sObjectType, Name FROM RecordType]);
        if(!rtList.isEmpty()){
            for(RecordType rt:rtList){
                rtMap.put(rt.Name + ' ' + rt.sObjectType, rt);
            }
        }
        
        Test.Starttest();
        
        
        //Lets update the opportunity record with the final values required and publish it
        //Update the Opportunity record 
        newOp.StageName = 'Closed Won';
        newOp.CloseDate = system.Today();
        newOp.Confirmed_funding_model__c = 'Some text goes here';
        newOp.Confirmed_Launch_plans__c = 'Some text goes here';
        newOp.Result_Comments__c = 'Some text goes here';
        update newOp;
        
        //Update the group record
        newGroup.Start_Date__c = system.Today();
        newGroup.RecordTypeId = rtMap.get('Group Group__c').Id;
        update newGroup;
        
        //Call the publish function for Group (not in opportunity, needs to be in Client Maintenance publish)
        //String retireResult = renewalManual.retireGroup(newGroup, newGroup.Start_Date__c);    
    
    	//Create a Client Maintenance record
        Id cmID = renewalManual.processManually(String.valueOf(newGroup.Id), 'with', 'Client Maintenance', 'Group__c');
    
    	//Clone Section
        Id nsID = renewalManual.processManually(String.valueOf(newSec.Id), 'with', 'Client Maintenance', 'Section__c');
    
    	//Lets get the new CM group
        Group__c CMGroup = [SELECT Id, Name, Group_Number__c, Version__c FROM Group__c WHERE Id=:cmID];
    
    	//View Group
        ApexPages.StandardController stdg2Controller = new ApexPages.StandardController(CMGroup);
        Test.setCurrentPageReference(new PageReference('Page.groupView'));
        System.currentPageReference().getParameters().put('id', CMGroup.Id);
        groupExtension gE2 = new groupExtension(stdg2Controller);
    
    	//Dummy publish initiation
    	publishWizardExtension pWE = new publishWizardExtension(stdg2Controller);
        //Activate date null rule
        pWE.publishGroup();
        //add date and fire again
        pWE.publishDate = system.TODAY();
        pWE.publishGroup();
    
    	//Lets publish this new Group
        //Discard old groups first
        String closeResult = renewalManual.retireGroup(newGroup, system.Today().addDays(-2));
    
        //publish new record
        CMGroup.RecordTypeId = rtMap.get('Group Group__c').Id;
        CMGroup.Start_Date__c = system.Today().addDays(-2);
        update CMGroup;
    
    	//Call the opportunity Tab from the 3 different perspectives
        //Opportunity
        Test.setCurrentPageReference(new PageReference('Page.opportunityTab'));
        opportunityTab oTabO = new opportunityTab();
        otabO.pageName = 'Opportunity';
        otabO.getViews();
    
        //Client Maintenance
        Test.setCurrentPageReference(new PageReference('Page.maintenanceTab'));
        opportunityTab oTabCM = new opportunityTab();
        otabCM.pageName = 'Client Maintenance';
        otabCM.getViews();
    
        //Renewal
        Test.setCurrentPageReference(new PageReference('Page.renewalTab'));
        opportunityTab oTabR = new opportunityTab();
        otabR.pageName = 'Renewal';
        otabR.getViews();
    
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        String jobId = System.schedule('Sample_Heading', CRON_EXP, new groupRecordTypeSchedule() ); 
    
        //Run the renewal scheduler
        Datetime dtren = Datetime.now().addMinutes(1);
        String CRON_EXPren = '0 '+ dtren.minute() + ' * ' + dtren.day() + ' ' + dtren.month() + ' ? ' + dtren.year();
        String jobIdren = System.schedule('Renewal_Heading', CRON_EXPren, new renewalScheduler() ); 
        
        Test.Stoptest();
        
    }
  
}