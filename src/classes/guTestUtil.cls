/////////////////////////////////////////////////////////////////
// Can be called by any test class to generate a usable cluster of data
// David Dawson
/////////////////////////////////////////////////////////////////
public class guTestUtil {
    
    public static void generateTestData(){
        
        Map<String, RecordType> rtMap = new Map<String, RecordType>();
        List<RecordType> rtList = new List<RecordType>([SELECT Id, sObjectType, Name FROM RecordType]);
        if(!rtList.isEmpty()){
            for(RecordType rt:rtList){
                rtMap.put(rt.Name + ' ' + rt.sObjectType, rt);
            }
        }
        
        Account broker = new Account(Name = 'Test Company', RecordTypeId = rtMap.get('Broker Account').Id);
        insert broker;
        
        Account client = new Account(Name = 'Test Client', RecordTypeId = rtMap.get('Prospect Account').Id, NumberOfEmployees = 200);
        insert client;
        
        Opportunity newOp = new Opportunity(Start_Date__c = system.Today(),StageName = 'New', CloseDate = system.Today().addDays(60), Name = 'Test Company Opportunity', AccountId = client.Id, Commercial_Analyst__c = UserInfo.getUserId(), RecordTypeId = rtMap.get('Opportunity Opportunity').Id);
        insert newOp;
        
        Group__c newGroup = new Group__c(Group_Number__c = '11111',Opportunity__c = newOp.Id, Name = 'Test Company Group', RecordTypeId = rtmap.get('Draft Group__c').Id);
        insert newGroup;
        
        Group__c newGroup2 = new Group__c(Group_Number__c = '11112',Opportunity__c = newOp.Id, Renewal_Date__c = system.TODAY(), Name = 'Test Company Group', RecordTypeId = rtmap.get('Group Group__c').Id);
        insert newGroup2;
        
        Section__c newSec = new Section__c(Group__c = newGroup.Id, Name = 'Test Company 0', Section_Number__c = '0', Date_On__c = system.Today().addDays(-10), Date_Closed__c = system.Today().addDays(100));
        insert newSec;
        
        list<CoverCode__c> newCCLst = new list<CoverCode__c>();
        
        CoverCode__c newCC1 = new CoverCode__c(Name='123', Sort_Order__c=1, Thunderhead_Description__c = 'TH desc', Type__c= 'A');
        newCCLst.add(newCC1);
        
        CoverCode__c newCC2 = new CoverCode__c(Name='124', Sort_Order__c=2, Thunderhead_Description__c = 'TH desc', Type__c= 'A');
        newCCLst.add(newCC2);
        
        CoverCode__c newCC3 = new CoverCode__c(Name='125', Sort_Order__c=3, Thunderhead_Description__c = 'TH desc', Type__c= 'A');
        newCCLst.add(newCC3);
        
        insert newCCLst; 
        
        ExcessCodeEmployee__c newEmpC = new ExcessCodeEmployee__c(Name ='1', Ancillary_Excess_Description__c='($250 single/$500 family excess)', System_Description__c='ANC 250/500 XS');
        insert newEmpC;
        
        ExcessCodeEmployer__c newEmprC = new ExcessCodeEmployer__c(name='401',Description__c='GROUP FED - HOSP 100/200',System__c='$100(S)/$200(F) Employer Excess ',Web__c='$100(S)/$200(F) Excess'); 
        insert newEmprC;
        
        Section_Product__c newSP = new Section_Product__c(Name = 'Test product', Cover_Code__c = '123 124', Product_Name_Web__c = 'Test product', Product_Type__c = 'Ancillary', Employee_Excess_Code_lkp__c = newEmpC.id, Employer_Excess_Code_lkp__c =  newEmprC.id );
        insert newSP;
        
        
        Section_Product_Link__c newSPL = new Section_Product_Link__c(Section__c = newSec.Id, Product__c = newSP.Id);
        insert newSPL;
        
        //Create some cases in case builder
        //Create some case templates
        Case_Template_Group__c ctg = new Case_Template_Group__c(Name = 'Groups', Subject__c = 'Group', Object__c = 'Opportunity;Renewal;Group;Section;Client Maintenance', ExternalId__c = 'GRP001');
        insert ctg;
        
        Case_Template__c ct0 = new Case_template__c(Name = 'Step 0', RecordTypeId = rtMap.get('Parent Case_Template__c').Id, Group__c = ctg.Id, Subject__c = 'Step 0', Code__c = 0, Fixed_SLA__c = FALSE);
        insert ct0;
        
        Case_Template__c ct1 = new Case_template__c(Name = 'Step 1', RecordTypeId = rtMap.get('Child Case_Template__c').Id, Group__c = ctg.Id, Subject__c = 'Step 1', Assigned_To__c = 'SSC', Code__c = 1, Fixed_Sla__c = TRUE, SLA1__c = 1);
        insert ct1;
        
        Case_Template__c ct2 = new Case_template__c(Name = 'Step 2', RecordTypeId = rtMap.get('Child Case_Template__c').Id, Group__c = ctg.Id, Subject__c = 'Step 1', Assigned_To__c = 'AM', Code__c = 2, Dependency__c = '1', Fixed_Sla__c = FALSE, SLA1__c = 1, SLA2__c = 3, Organisation_Size__c = 100);
        insert ct2;
        
    }
    
}