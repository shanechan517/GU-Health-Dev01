/*
 * @Filename: publishWizardExtensionClone.apex
 * @Description: Extension class for the publish wizard page
 * @History
 *      Created - Unknown
 *      Updated - 29/11/2016 - K. Vegerano (OAKTON) - GVT-302 - Added field grouping functionality through field sets
 */

public class publishWizardExtensionClone{
    //used solely to gain access to the group record
    private final Group__c grpRecord;

    //public variables
    public String pendingGroupVersion {get;set;}
    public String backupActiveRecordId {get;set;}
    public String groupNumber {get;set;}
    public String draftVersionNumber {get;Set;}
    public String oppStatusMsg {get;set;}
    public String excludedMessage {get;set;}
    public Boolean needWizard {get;Set;}
    public Boolean isVersionOne {get;Set;}
    public Date publishDate {get;Set;}
    
    //reference map for data values
    public Map<Id, sObject> referenceMap {get;Set;}
    public groupClass groupFamily {get;Set;}
    
    //cObject prefixes
    public String groupPrefix {get;Set;}
    public String sectionPrefix {get;Set;}
    public String splPrefix {get;Set;}
    
    //required field handling
    public Boolean missingField {get;Set;}
    public String missingFieldMsg {get;Set;}
    
    //Fields per Object
    public Map<String, List<String>> objectFieldNamesMap {get;set;}
    
    public publishWizardExtensionClone(ApexPages.StandardController stdController){
        /* --------------------------- Initialize Necessary Records --------------------------- */
        objectFieldNamesMap = new Map<String, List<String>>();
        
        //Retrieve and Process Group, Section and Section Product Link field sets to be shown on Publish Wizard
        retrieveFieldSets();
        
        //Retrieve synced and locked fields
        retrieveSyncedLockedFields();
        
        //get additional fields required
        if(!test.isRunningTest()){
            stdController.AddFields(new List<String>{'Version__c', 'Group_Number__c', 'Clone_Of__c', 'Clone_Of__r.Is_Active__c', 'RecordType.Name', 'Version__c', 'Opportunity_Status__c', 'Source__c'});
        }
        
        //Retrieve standard controller record
        this.grpRecord = (Group__c)stdController.getRecord();
        
        //Check if there is a need to run the publish wizard
        if(!test.isRunningTest()){
            if(grpRecord.RecordType.Name == 'Draft' && grpRecord.Clone_Of__c != null && grpRecord.Clone_Of__r.Is_Active__c != 'Active'){
                needWizard = true;
            }else{
                needWizard = false;
            }
            if(grpRecord.Opportunity_Status__c != 'Complete' && grpRecord.Opportunity_Status__c != 'Expired' && grpRecord.Opportunity_Status__c != 'Closed Won'){
                oppStatusMsg = 'The ' + grpRecord.Source__c + ' record has not been closed. Please remember to open the ' + grpRecord.Source__c + ' record after you have completed the Publish Wizard and update the status.';
            }
        }else{
            //put this catch in for running tests to force the wizard to be required
            needWizard = true;
            oppStatusMsg = '';
        }
        
        //Set the group number variable
        groupNumber = grpRecord.Group_Number__c;
        /*
        if(groupNumber == null){
            apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.error,'Group Number is required','Group Number is required'));  
        }
        */
        
        //Determine if the record to be published is version 1
        isVersionOne = true;
        if(grpRecord.Version__c != null){
            draftVersionNumber = String.valueOf(grpRecord.Version__c.setScale(0));
            if(draftVersionNumber == '1'){
                isVersionOne = true;
            }else{
                isVersionOne = false;
            }
        }
        
        //Initialize publish date and group version number
        publishDate = null;
        pendingGroupVersion = '';
        
        //Initialize blank reference maps for populating
        referenceMap = new Map<Id, sObject>();
        
        //Retrieve the custom object prefixes dynamically
        cObjectPrefixes();
        
        /* --------------------------- Query and Process Group records --------------------------- */
        //Create variables for processing group, section and section product link records
        String queryBody;
        String queryActTail;
        String queryPubTail;
        String orderBy;
        String[] addFields;
        
        //Add Groups
        List<comparisonListObj> includedGrps;
        {
            //Original Line - Include fields for processing
            //queryBody = 'Id, Name, Group_Number__c, Version__c, Is_Active__c, Start_Date__c, Renewal_Date__c FROM Group__c';
            //Updated Line 17/11/2016 - Include all fields for query
            String objectProcessing = 'Group__c';
            Map<String, Schema.SObjectField> fieldSetMemberMap = Schema.getGlobalDescribe().get(objectProcessing).getDescribe().fields.getMap();
            Set<String> groupFieldComparedSet = new Set<String>();
            for(Schema.FieldSetMember loopField : Schema.getGlobalDescribe().get(objectProcessing).getDescribe().FieldSets.getMap().get('CompareFields').getFields()){
                groupFieldComparedSet.add(loopField.getFieldPath());
            }
            //Collect Synced Fields which will be shown on the page
            objectFieldNamesMap.put(objectProcessing, new List<String>());
            for(Schema.FieldSetMember loopField : Schema.getGlobalDescribe().get(objectProcessing).getDescribe().FieldSets.getMap().get('SyncFields').getFields()){
                objectFieldNamesMap.get(objectProcessing).add(loopField.getFieldPath());
            }

            queryBody = '';
            //Include all fields for the Query
            for(Schema.SObjectField loopField : fieldSetMemberMap.values()){
                Schema.DescribeFieldResult fieldDescribe = loopField.getDescribe();
                if(fieldDescribe.getName() != 'Id'){
                    //Add field to the query select clause
                    queryBody += fieldDescribe.getName() + ', ';
                } 
            }
            queryBody += 'Id FROM Group__c';
            queryActTail = '(Group_Number__c=\'' + groupNumber + '\' AND Is_Active__c = \'Active\')';
            queryPubTail = '(id=\'' + grpRecord.Id + '\') OR (Group_Number__c=\'' + groupNumber + '\' AND Is_Active__c = \'Pending\')';
            orderBy = 'ORDER BY Is_Active__c, Version__c ASC';
            addFields = new List<String>();
            Map<String, List<sObject>> groupMap = getReferenceMap(queryBody, queryActTail, queryPubTail, orderBy, 'Group__c', 'Is_Active__c');
            //create two lists (drafts and active)
            List<sObject> groupPubList = new List<sObject>();
            List<sObject> groupActList = new List<sObject>();
            if(groupMap.containsKey('Publish')){
                groupPubList.add(groupMap.get('Publish')[0]);
            }
            if(groupMap.containsKey('Pending')){
                groupActList.add(groupMap.get('Pending')[0]);
                pendingGroupVersion = String.valueOf(groupMap.get('Pending')[0].get('Version__c'));
                if(groupMap.containsKey('Active')){
                    backupActiveRecordId = String.valueOf(groupMap.get('Active')[0].get('Id'));
                }
            }else if(groupMap.containsKey('Active')){
                groupActList.add(groupMap.get('Active')[0]);
            }
    
            //create comparison objects
            includedGrps = getComparisonObjects(groupPubList, groupActList, 'Group__c','Group_Number__c', null, 'Group_Number__c', addFields);
        }
        
        /* --------------------------- Query and Process Section records --------------------------- */
        //Add Sections
        List<comparisonListObj> includedSections;
        {
            //Original Line - Include fields for processing
            //queryBody = 'Id, Name, Group__c, Group_Number__c, Section_Number__c, Version__c, Status__c FROM Section__c';
            //Updated Line 17/11/2016 - field inclusion for the query will now be handled on getRecordQuery method
            String objectProcessing = 'Section__c';
            Map<String, Schema.SObjectField> fieldSetMemberMap = Schema.getGlobalDescribe().get(objectProcessing).getDescribe().fields.getMap();
            Set<String> groupFieldComparedSet = new Set<String>();
            for(Schema.FieldSetMember loopField : Schema.getGlobalDescribe().get(objectProcessing).getDescribe().FieldSets.getMap().get('CompareFields').getFields()){
                groupFieldComparedSet.add(loopField.getFieldPath());
            }
            //Collect Synced Fields which will be shown on the page
            objectFieldNamesMap.put(objectProcessing, new List<String>());
            for(Schema.FieldSetMember loopField : Schema.getGlobalDescribe().get(objectProcessing).getDescribe().FieldSets.getMap().get('SyncFields').getFields()){
                objectFieldNamesMap.get(objectProcessing).add(loopField.getFieldPath());
            }
            
            queryBody = '';
            //Include all fields for the Query
            for(Schema.SObjectField loopField : fieldSetMemberMap.values()){
                Schema.DescribeFieldResult fieldDescribe = loopField.getDescribe();
                if(fieldDescribe.getName() != 'Id'){
                    //Add field to the query select clause
                    queryBody += fieldDescribe.getName() + ', '; 
                } 
            }
            queryBody += 'Id FROM Section__c';
            queryActTail = '(Group_Number__c=\'' + groupNumber + '\' AND Group__r.Is_Active__c = \'Active\') OR (Group_Number__c=\'' + groupNumber + '\' AND Group__r.Is_Active__c = \'Pending\')';
            queryPubTail = '(Group__c=\'' + grpRecord.Id + '\')';
            orderBy = 'ORDER BY Status__c, Section_Number__c';
            addFields = new List<String>();
            Map<String, List<sObject>> sectionMap = getReferenceMap(queryBody, queryActTail, queryPubTail, orderBy, 'Section__c', 'Status__c');
            
            //create two lists (drafts and active)
            List<sObject> sectionPubList = new List<sObject>();
            List<sObject> sectionActList = new List<sObject>();
            if(sectionMap.containsKey('Publish')){
                sectionPubList = sectionMap.get('Publish');
            }
            if(sectionMap.containsKey('Pending')){
                sectionActList = sectionMap.get('Pending');
            }else if(sectionMap.containsKey('Active')){
                sectionActList = sectionMap.get('Active');
            }

            //create comparison objects
            includedSections = getComparisonObjects(sectionPubList, sectionActList, 'Section__c', 'Section_Number__c', 'Group_Number__c', 'Section_Number__c', addFields);
        }
        
        /* --------------------------- Query and Process Section Product Link records --------------------------- */
        //Check and make sure this group has not been excluded from loading section product links
        excludedMessage = '';
        String excludedLabel = Label.ExcludedGroupNumbers;
        List<String> excludedGroupNumbers = excludedLabel.split(';');
        List<comparisonListObj> includedSPLs = new List<comparisonListObj>();
        if(groupNumber != null){
            if(!excludedLabel.contains(groupNumber)){
                //Add Sections Product Links
                {
                    //Original Line - Include fields for processing
                    //queryBody = 'Id, Name, Product_Id__c, Product_Name__c, Section__c, Section__r.Group__r.Group_Number__c, Section_Number__c, Product__c, CoverCode__c, ProductCode__c, Status__c, Group_Status__c FROM Section_Product_Link__c';
                    //Updated Line 17/11/2016 - field inclusion for the query will now be handled on getRecordQuery method
                    String objectProcessing = 'Section_Product_Link__c';
                    Map<String, Schema.SObjectField> fieldSetMemberMap = Schema.getGlobalDescribe().get(objectProcessing).getDescribe().fields.getMap();
                    Set<String> groupFieldComparedSet = new Set<String>();
                    for(Schema.FieldSetMember loopField : Schema.getGlobalDescribe().get(objectProcessing).getDescribe().FieldSets.getMap().get('CompareFields').getFields()){
                        groupFieldComparedSet.add(loopField.getFieldPath());
                    }
                    //Collect Synced Fields which will be shown on the page
                    objectFieldNamesMap.put(objectProcessing, new List<String>());
                    for(Schema.FieldSetMember loopField : Schema.getGlobalDescribe().get(objectProcessing).getDescribe().FieldSets.getMap().get('SyncFields').getFields()){
                        objectFieldNamesMap.get(objectProcessing).add(loopField.getFieldPath());
                    }
                    
                    queryBody = '';
                    //Include all fields for the Query
                    for(Schema.SObjectField loopField : fieldSetMemberMap.values()){
                        Schema.DescribeFieldResult fieldDescribe = loopField.getDescribe();
                        if(fieldDescribe.getName() != 'Id'){
                            //Add field to the query select clause
                            queryBody += fieldDescribe.getName() + ', '; 
                        } 
                    }
                    queryBody += 'Id FROM Section_Product_Link__c';
                    queryActTail = '(Section__r.Group_Number__c=\'' + groupNumber + '\' AND Section__r.Group__r.Is_Active__c = \'Active\') OR (Section__r.Group_Number__c=\'' + groupNumber + '\' AND Section__r.Group__r.Is_Active__c = \'Pending\')';
                    queryPubTail = '(Section__r.Group__c=\'' + grpRecord.Id + '\')';
                    orderBy = 'ORDER BY Status__c, ProductCode__c';
                    addFields = new List<String>{'Product_Name__c', 'ProductCode__c', 'CoverCode__c'};
                    Map<String, List<sObject>> splMap = getReferenceMap(queryBody, queryActTail, queryPubTail, orderBy, 'Section_Product_Link__c', 'Group_Status__c');
                    
                    //create two lists (drafts and active)
                    List<sObject> splPubList = new List<sObject>();
                    List<sObject> splActList = new List<sObject>();
                    if(splMap.containsKey('Publish')){
                        splPubList = splMap.get('Publish');
                    }
                    if(splMap.containsKey('Pending')){
                        splActList = splMap.get('Pending');
                    }else if(splMap.containsKey('Active')){
                        splActList = splMap.get('Active');
                    }
    
                    //create comparison objects
                    includedSPLs = getComparisonObjects(splPubList, splActList, 'Section_Product_Link__c', 'Product_Id__c', 'Section_Number__c', 'ProductCode__c', addFields);
                }
            }else{
                excludedMessage = 'This group has had its Section Product Link records excluded from the Publish Wizard as the data set is too big. You can still compare the Group and Section records but the Section Product Link changes will need to be verified manually before continuing with the publish.';
            }    
        }
        
        /* --------------------------- Associate Group, Sections and Section Product Link records to their respective parents --------------------------- */
        //Create the Group class
        groupFamily = new groupClass(includedGrps[0]);
        
        //Create Section Class
        List<sectionClass> sectionList = new List<sectionClass>();
        for(comparisonListObj clObj :includedSections){
            sectionList.add(new sectionClass(clObj));
            //if there are any new section product links, notify the parent
            if(clObj.hasAct != clObj.hasPub){
                groupFamily.grp.hasNewChild = true;
            }
            if(clObj.containsChange){
                groupFamily.grp.hasChangedChild = true;
            }
        }
        
        //Create Section Product Link Class and add to section records
        for(comparisonListObj clObj :includedSPLs){
            for(sectionClass sC :sectionList){
                if(sC.section.uniqueIdentifier == clObj.parentId){
                    sC.splList.add(new splClass(clObj));
                    //if there are any new section product links, notify the parent
                    if(clObj.hasAct != clObj.hasPub){
                        sC.section.hasNewChild = true;
                    }
                    if(clObj.containsChange){
                        sC.section.hasChangedChild = true;
                    }
                }
            }
        }
        
        //Add the sections to the group class
        for(sectionClass sC :sectionList){
            groupFamily.sectionList.add(sC);
        }
        
        /* --------------------------- Missing fields checking for Group, Section and Section Product Link  --------------------------- */
        //check that the required fields are present
        missingField = false;
        for(Id key :referenceMap.keySet()){
            missingFieldMsg = '';
            //group messages
            if(groupNumber == null){
                missingFieldMsg += '<p style="margin-left:15px;">The group record is missing a Group Number.</p>';
            }
            //section messages
            if(String.valueOf(key).subString(0,3) == sectionPrefix){
                if(referenceMap.get(key).get('Section_Number__c') == null || referenceMap.get(key).get('Section_Number__c') == ''){
                    missingFieldMsg += '<p style="margin-left:15px;">One or more sections are missing a section number.</p>';
                }
            }
            //spl messages
            if(String.valueOf(key).subString(0,3) == splPrefix){
                if(referenceMap.get(key).get('ProductCode__c') == null || referenceMap.get(key).get('ProductCode__c') == ''){
                    missingFieldMsg += '<p style="margin-left:15px;">One or more products do not have a product code assigned.</p>';
                }
                if(referenceMap.get(key).get('Product_Name__c') == null || referenceMap.get(key).get('Product_Name__c') == ''){
                    missingFieldMsg += '<p style="margin-left:15px;">One or more products do not have a product name entered.</p>';
                }
            }
        }
        if(missingFieldMsg != null && missingFieldMsg != ''){
            missingField = true;
            missingFieldMsg += '<p>&nbsp;</p><p>You <strong>cannot</strong> publish the group until the above fields have been populated.</p>';
        }
    }
    
    //Variables for retrieveSectionsFieldSets() method 
    //See retrieveSectionsFieldSets() for reference
    public Map<String, Map<String, String>> fieldSetLabeltoAPIMap {get;set;}
    public Map<String, Map<String, String>> fieldSetAPItoLabelMap {get;set;}
    public Map<String, List<String>> fieldSetListMap {get;set;}
    public Map<String, Map<String, String>> fieldsAPItoLabelMap {get;set;}
    public Map<String, Map<String, List<Schema.FieldSetMember>>> objectFieldSetMap {get;set;}
    
    /**
     * @author          K.Vegerano (kristian.vegerano@australianunity.com)
     * @date            23/11/2016
     * @description     Retrieve and Process Group, Section and Section Product Link field sets to be shown on Publish Wizard
     * @param           None
     * @history         Created - 23/11/2016
     */
    public void retrieveFieldSets(){
        //Initialize variables
        Pattern loopPatern;
        Matcher loopMatcher;
        List<Integer> sortingList;
        Map<Integer, String> sectionOrderMap;
        fieldSetLabeltoAPIMap = new Map<String, Map<String, String>>();
        fieldSetAPItoLabelMap = new Map<String, Map<String, String>>();
        fieldSetListMap = new Map<String, List<String>>();
        fieldsAPItoLabelMap = new Map<String, Map<String, String>>();
        objectFieldSetMap = new Map<String, Map<String, List<Schema.FieldSetMember>>>();
        
        //Objects to process
        Set<String> processObject = new Set<String>();
        processObject.add('Group__c');
        processObject.add('Section__c');
        processObject.add('Section_Product_Link__c');
        
        //Process objects
        for(String loopObject : processObject){
            sortingList = new List<Integer>();
            sectionOrderMap = new Map<Integer, String>();
                
            fieldSetListMap.put(loopObject, new List<String>());
            fieldSetAPItoLabelMap.put(loopObject, new Map<String, String>());
            fieldSetLabeltoAPIMap.put(loopObject, new Map<String, String>());
            Map<String, Schema.FieldSet> fieldSetMap = Schema.getGlobalDescribe().get(loopObject.toLowerCase()).getDescribe().fieldSets.getMap();
            
            //Retrieve and Sort object Field Sets
            for(String loopKey : fieldSetMap.keySet()){
                //Include only fieldsets with prefix 'x'
                if(loopKey.startsWithIgnoreCase('x')){
                    fieldSetListMap.get(loopObject).add(loopKey);
                    
                    //Add fieldset api name to label map
                    fieldSetAPItoLabelMap.get(loopObject).put(loopKey, fieldSetMap.get(loopKey).getLabel());
                    
                    //Add fieldset label to api name map
                    fieldSetLabeltoAPIMap.get(loopObject).put(fieldSetMap.get(loopKey).getLabel(), loopKey);
                }
            }
            fieldSetListMap.get(loopObject).sort();

            //Collect field set members from field sets with the field set label as the map
            fieldsAPItoLabelMap.put(loopObject, new Map<String, String>());
            objectFieldSetMap.put(loopObject, new Map<String, List<Schema.FieldSetMember>>());
            for(String loopKey : fieldSetListMap.get(loopObject)){
                String fieldSetLabel = fieldSetMap.get(loopKey).getLabel();
                objectFieldSetMap.get(loopObject).put(fieldSetLabel, new List<Schema.FieldSetMember>());
                for(Schema.FieldSetMember loopField : fieldSetMap.get(loopKey).getFields()){
                    //Add the field on the map grouped by object and field set
                    objectFieldSetMap.get(loopObject).get(fieldSetLabel).add(loopField);
                    //Add to fieldsAPItoLabelMap to reference field label from field api name
                    fieldsAPItoLabelMap.get(loopObject).put(loopField.getFieldPath(), loopField.getLabel());
                }
            }
        }
    }
    
    //Variables for retrieveSyncedLockedFields() method 
    //See retrieveSyncedLockedFields() for reference
    //Lists to store the locked fields and the synced fields
    public String groupLockedFields {get;set;}
    public String groupSyncFields {get;set;}
    public String sectionLockedFields {get;set;}
    public String sectionSyncFields {get;set;}
    public String splLockedFields {get;set;}
    public String splSyncFields {get;set;}    
    public Map<String, String> forcedReadOnlyFieldsMap {get;set;}
    
    /**
     * @author          K.Vegerano (kristian.vegerano@australianunity.com)
     * @date            29/11/2016
     * @description     Retrieve synced and locked fields
     * @param           None
     * @history         Created - 29/11/2016
     */
    public void retrieveSyncedLockedFields(){
        forcedReadOnlyFieldsMap = new Map<String, String>();
        
        /*-------------- Process Group Fields --------------*/
        Set<String> groupForcedReadOnlySet = new Set<String>();
        Set<String> sectionForcedReadOnlySet = new Set<String>();
        Set<String> splForcedReadOnlySet = new Set<String>();
        
        //Group forced read only fields
        groupForcedReadOnlySet.add(fieldsAPItoLabelMap.get('Group__c').get('Group_Number__c'));
        groupForcedReadOnlySet.add(fieldsAPItoLabelMap.get('Group__c').get('Opportunity__c'));
        groupForcedReadOnlySet.add(fieldsAPItoLabelMap.get('Group__c').get('Real_Renewal_Date__c'));
        groupForcedReadOnlySet.add(fieldsAPItoLabelMap.get('Group__c').get('Version__c'));
        forcedReadOnlyFieldsMap.put('Group__c', JSON.serialize(groupForcedReadOnlySet));
        
        //Section forced read only fields
        sectionForcedReadOnlySet.add(fieldsAPItoLabelMap.get('Section__c').get('OMS_status__c'));
        sectionForcedReadOnlySet.add(fieldsAPItoLabelMap.get('Section__c').get('Section_Number__c'));
        sectionForcedReadOnlySet.add(fieldsAPItoLabelMap.get('Section__c').get('Group_Directory__c'));
        forcedReadOnlyFieldsMap.put('Section__c', JSON.serialize(sectionForcedReadOnlySet));

        //Section Product Link forced read only fields
        splForcedReadOnlySet.add(fieldsAPItoLabelMap.get('Section_Product_Link__c').get('Section__c'));
        forcedReadOnlyFieldsMap.put('Section_Product_Link__c', JSON.serialize(splForcedReadOnlySet));
        
        //populate the locked fields list to pass to Javascript array
        Set<String> lockTemp = new Set<String>();
        Set<String> syncTemp = new Set<String>();
        List<Schema.FieldSetMember> lockedFieldSetMemberList =  Util.readFieldSet('WHICSFields','Group__c');
        List<Schema.FieldSetMember> syncFieldSetMemberList = Util.readFieldSet('SyncFields','Group__c');
        for(Schema.FieldSetMember fieldSetMemberObj : lockedFieldSetMemberList){
            lockTemp.add(fieldSetMemberObj.getLabel());
        }
        groupLockedFields = JSON.serialize(lockTemp);

        //populate the sync fields list to pass to Javascript array
        for(Schema.FieldSetMember fieldSetMemberObj : syncFieldSetMemberList){
            syncTemp.add(fieldSetMemberObj.getLabel());
        }
        groupSyncFields = JSON.serialize(syncTemp);
        
        /*-------------- Process Section Fields --------------*/
        //populate the locked fields list to pass to Javascript array
        lockTemp = new Set<String>();
        syncTemp = new Set<String>();
        lockedFieldSetMemberList =  Util.readFieldSet('WHICSFields','Section__c');
        syncFieldSetMemberList = Util.readFieldSet('SyncFields','Section__c');        
        for(Schema.FieldSetMember fieldSetMemberObj : lockedFieldSetMemberList){
            lockTemp.add(fieldSetMemberObj.getLabel());
        }
        sectionLockedFields = JSON.serialize(lockTemp);
        
        //populate the sync fields list to pass to Javascript array
        for(Schema.FieldSetMember fieldSetMemberObj : syncFieldSetMemberList){
            syncTemp.add(fieldSetMemberObj.getLabel());
        }
        sectionSyncFields = JSON.serialize(syncTemp);
        
        /*-------------- Process Section Product Link Fields --------------*/
        //populate the locked fields list to pass to Javascript array
        lockTemp = new Set<String>();
        syncTemp = new Set<String>();
        lockedFieldSetMemberList =  Util.readFieldSet('WHICSFields','Section_Product_Link__c');
        syncFieldSetMemberList = Util.readFieldSet('SyncFields','Section_Product_Link__c');        
        for(Schema.FieldSetMember fieldSetMemberObj : lockedFieldSetMemberList){
            lockTemp.add(fieldSetMemberObj.getLabel());
        }
        splLockedFields = JSON.serialize(lockTemp);
        
        //populate the sync fields list to pass to Javascript array
        for(Schema.FieldSetMember fieldSetMemberObj : syncFieldSetMemberList){
            syncTemp.add(fieldSetMemberObj.getLabel());
        }
        splSyncFields = JSON.serialize(syncTemp);
    }

    public List<comparisonListObj> getComparisonObjects(List<sObject> pubList, List<sObject> actList, String sObjectDecl, String key, String parentIdField, String nameField, List<String> additionalFields){
        
        //Initialise some variables to store string and boolean values
        String pubVal;
        String actVal;
        Boolean pubBool;
        Boolean actBool;
        String parentId;
        String uniqueIdentifier;
        String pubRecordId;
        String actRecordId;
        String recordName;
        Map<String, String> addFields = new Map<String, String>();
        
        //Maps to simplify creating the comparative objects
        Map<String, sObject> pubMap = new Map<String, sObject>();
        Map<String, sObject> actMap = new Map<String, sObject>();
        Set<String> keyRing = new Set<String>();
        List<comparisonListObj> sObjectList = new List<comparisonListObj>();
        
        //Get group record with fields from field set
        for(sObject s :pubList){
            pubMap.put(String.valueOf(s.get(key)),s);
            keyRing.add(String.valueOf(s.get(key)));
        }
        
        for(sObject s :actList){
            actMap.put(String.valueOf(s.get(key)),s);
            keyRing.add(String.valueOf(s.get(key)));
        }
        
        for(String recIdentifier:keyRing){
            Map<String, List<comparisonObj>> cLObjList = new Map<String, List<comparisonObj>>();
            List<Schema.FieldSetMember> fieldSetMemberList =  Util.readFieldSet('CompareFields',sObjectDecl);
            Boolean containsChange = false;
            
            //Set the id
            if(pubMap.containsKey(recIdentifier) && pubMap.get(recIdentifier).Id != null){
                pubRecordId = pubMap.get(recIdentifier).Id;
            }else{
                pubRecordId = null;
            }
            if(actMap.containsKey(recIdentifier) && actMap.get(recIdentifier).Id != null){
                actRecordId = actMap.get(recIdentifier).Id;
            }else{
                actRecordId = null;
            }

            for(String fieldSetName : objectFieldSetMap.get(sObjectDecl).keySet()){
                cLObjList.put(fieldSetLabeltoAPIMap.get(sObjectDecl).get(fieldSetName), new List<comparisonObj>());
                for(Schema.FieldSetMember f : objectFieldSetMap.get(sObjectDecl).get(fieldSetName)) {
                    //Get the published value
                    if(pubMap.containsKey(recIdentifier) && pubMap.get(recIdentifier).Id != null){
                        pubVal = String.valueOf(pubMap.get(recIdentifier).get(String.valueOf(f.getFieldPath())));
                    }else{
                        pubVal = null;
                    }
                    
                    //get the active value
                    if(actMap.containsKey(recIdentifier) && actMap.get(recIdentifier).Id != null){
                        actVal = String.valueOf(actMap.get(recIdentifier).get(String.valueOf(f.getFieldPath())));
                    }else{
                        actVal = null;
                    }
                    
                    //set the selected value for the map (published or active)
                    if(pubVal != null){
                        pubBool = true;
                        actBool = false;
                    }else if(actVal != null){
                        pubBool = false;
                        actBool = true;
                    }else{
                        pubBool = false;
                        actBool = false;
                    }
                    
                    //check if the values are the same
                    if((pubVal != null || actVal != null) && pubVal != actVal && actMap.containsKey(recIdentifier) && pubMap.containsKey(recIdentifier)){
                        containsChange = true;
                    }
    
                    //populate the additional fields map
                    if(!additionalFields.isEmpty()){
                        for(String fieldName :additionalFields){
                            if(fieldName != null && pubMap.containsKey(recIdentifier)){
                                String fieldValue = String.valueOf(pubMap.get(recIdentifier).get(fieldName));
                                if(fieldValue != null){
                                    addFields.put(fieldName, fieldValue);
                                }
                            }
                        }
                    }
                    
                    cLObjList.get(fieldSetLabeltoAPIMap.get(sObjectDecl).get(fieldSetName)).add(new comparisonObj(pubVal, actVal, String.valueOf(f.getFieldPath()), pubBool, actBool, String.valueOf(f.Label), addFields, String.valueOf(f.getType())));
                }
            }
            
            Boolean pNN;
            Boolean aNN;
            if(pubMap.containsKey(recIdentifier) && pubMap.get(recIdentifier).Id != null){
                pNN = true;
            }else{
                pNN = false;
            }
            if(actMap.containsKey(recIdentifier) && actMap.get(recIdentifier).Id != null){
                aNN = true;
            }else{
                aNN = false;
            }
            
            if(pNN && parentIdField != null && pubMap.get(recIdentifier).get(parentIdField) != null){
                parentId = String.valueOf(pubMap.get(recIdentifier).get(parentIdField));
                uniqueIdentifier = String.valueOf(pubMap.get(recIdentifier).get(key));
                recordName = String.valueOf(pubMap.get(recIdentifier).get(nameField));
            }else if(aNN && parentIdField != null && actMap.get(recIdentifier).get(parentIdField) != null){
                parentId = String.valueOf(actMap.get(recIdentifier).get(parentIdField));
                uniqueIdentifier = String.valueOf(actMap.get(recIdentifier).get(key));
                recordName = String.valueOf(actMap.get(recIdentifier).get(nameField));
            }else{
                parentId = null;
                uniqueIdentifier = null;
                recordName = null;
            }
            
            sObjectList.add(new comparisonListObj(cLObjList, aNN, pNN, containsChange, parentId, uniqueIdentifier, pubRecordId, actRecordId, recordName, forcedReadOnlyFieldsMap));
            
        }
        
        return sObjectList;
    }

    public PageReference publishGroup(){
        //manually check that the date has been filled to give a more user friendly error
        if(publishDate == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Publish Date is a required field. Please enter a Publish Date before continuing.'));
            return null;
        }

        Group__c groupSubmit = new Group__c(Id = groupFamily.grp.pubRecordId, Start_Date__c = publishDate);
        List<Section__c> secSubmitList = new List<Section__c>();
        List<Section_Product_Link__c> splSubmitList = new List<Section_Product_Link__c>();
        List<Group__c> grpSubmitList = new List<Group__c>();
        
        //discard current active/published record if the records start date is less than the publish date of the new draft
        if(pendingGroupVersion != null && pendingGroupVersion != ''){
            Group__c activeGroup = new Group__c(Id = groupFamily.grp.actRecordId);
            if(publishDate > system.Today()){
                activeGroup.Renewal_Date__c = system.Today();
                activeGroup.Start_Date__c = system.Today();
                grpSubmitList.add(activeGroup);
            }else{
                Date curDiscardDate = date.valueOf(referenceMap.get(groupFamily.grp.actRecordId).get('Start_Date__c'));
                groupSubmit.Renewal_Date__c = curDiscardDate;
            }
        }else if(groupFamily.grp.actRecordId != null){
            Date startDate = date.valueOf(referenceMap.get(groupFamily.grp.actRecordId).get('Start_Date__c'));

            Date discardDate = null;
            if(referenceMap.get(groupFamily.grp.actRecordId).get('Renewal_Date__c') != null){
                discardDate = date.valueOf(referenceMap.get(groupFamily.grp.actRecordId).get('Renewal_Date__c'));
            }

            if(startDate <= publishDate && (discardDate == null || discardDate > publishDate)){
                Group__c activeGroup = new Group__c(Id = groupFamily.grp.actRecordId, Renewal_Date__c = publishDate);
                grpSubmitList.add(activeGroup);
            }
        }

        //discard current active record if the records start date is less than the publish date of the new draft, and there is a publish record in the mix
        if(backupActiveRecordId != null){
            Date startDate = date.valueOf(referenceMap.get(backupActiveRecordId).get('Start_Date__c'));

            Date discardDate = null;
            if(referenceMap.get(backupActiveRecordId).get('Renewal_Date__c') != null){
                discardDate = date.valueOf(referenceMap.get(backupActiveRecordId).get('Renewal_Date__c'));
            }

            if(startDate <= publishDate && (discardDate == null || discardDate > publishDate)){
                Group__c trueActiveGroup = new Group__c(Id = backupActiveRecordId, Renewal_Date__c = publishDate);
                grpSubmitList.add(trueActiveGroup);
            }
        }

        //build group record
        /*for(comparisonObj gFields :groupFamily.grp.cObj){
            if(gFields.pubSelect){
                groupSubmit.put(gFields.fieldAPI, referenceMap.get(groupFamily.grp.pubRecordId).get(gFields.fieldAPI));
            }else if(gFields.actSelect){
                groupSubmit.put(gFields.fieldAPI, referenceMap.get(groupFamily.grp.actRecordId).get(gFields.fieldAPI));
            }
        }*/
        
        //build section list
        for(sectionClass s :groupFamily.sectionList){
            Section__c sectionSubmit = new Section__c(Id = s.section.pubRecordId);
            if(s.section.hasAct){
                sectionSubmit.External_ID__c = guUtil.getSectionExtId(String.valueOf(referenceMap.get(s.section.actRecordId).get('Group_Number__c')), String.valueOf(referenceMap.get(s.section.actRecordId).get('Section_Number__c')), String.valueOf(referenceMap.get(groupFamily.grp.pubRecordId).get('Version__c')));
            }else if(s.section.hasPub){
                sectionSubmit.External_ID__c = guUtil.getSectionExtId(String.valueOf(referenceMap.get(s.section.pubRecordId).get('Group_Number__c')), String.valueOf(referenceMap.get(s.section.pubRecordId).get('Section_Number__c')), String.valueOf(referenceMap.get(groupFamily.grp.pubRecordId).get('Version__c')));
            }
            //check first if there is a comparison, or if we are simply importing/removing the record
            System.debug('sectionSubmit ' + sectionSubmit);
            if(s.section.hasAct && s.section.hasPub){
                //build group record
                /*for(comparisonObj sFields :s.section.cObj){
                    if(sFields.pubSelect){
                        sectionSubmit.put(sFields.fieldAPI, referenceMap.get(s.section.pubRecordId).get(sFields.fieldAPI));
                    }else if(sFields.actSelect){
                        sectionSubmit.put(sFields.fieldAPI, referenceMap.get(s.section.actRecordId).get(sFields.fieldAPI));
                    }
                }*/
                secSubmitList.add(sectionSubmit);
            }else if(s.section.hasAct != s.section.hasPub){
                if(s.section.hasPub && s.section.publishWithRec){
                    //do nothing in particular
                    //Add to secSubmitList, this enables the section trigger to fire and update sections as applicable through section trigger code
                    secSubmitList.add(sectionSubmit);    
                }else if(s.section.hasPub && s.section.publishWithRec == false){
                    //close record
                    sectionSubmit.Date_Closed__c = System.today();
                    secSubmitList.add(sectionSubmit);
                }else if(s.section.hasAct && s.section.publishWithRec){
                    //clone
                    String soql = Util.getCreatableFieldsSOQL('Section__c','id=\'' + s.section.actRecordId + '\'', null);
                    Section__c sectionClone = (Section__c)Database.query(soql);
                    sectionSubmit = sectionClone.clone(false, true);
                    sectionSubmit.put('Group__c', String.valueOf(groupFamily.grp.pubRecordId));
                    secSubmitList.add(sectionSubmit);
                }else if(s.section.hasAct && s.section.publishWithRec == false){
                    //do nothing
                }
            }
            
            //build section product link list
            for(splClass splink :s.splList){
                Section_Product_Link__c splSubmit = new Section_Product_Link__c();
                System.debug('iNSIDE LOOP ' + splSubmit);
                if(splink.spl.hasAct && splink.spl.hasPub){
                    //build group record
                    splSubmit.Id = splink.spl.pubRecordId;
                    /*for(comparisonObj splFields :splink.spl.cObj){
                        if(splFields.pubSelect){
                            splSubmit.put(splFields.fieldAPI, referenceMap.get(splink.spl.pubRecordId).get(splFields.fieldAPI));
                        }else if(splFields.actSelect){
                            splSubmit.put(splFields.fieldAPI, referenceMap.get(splink.spl.actRecordId).get(splFields.fieldAPI));
                        }
                    }*/
                    splSubmitList.add(splSubmit);
                }else if(splink.spl.hasPub && splink.spl.publishWithRec){
                    //do nothing
                    splSubmit.Id = splink.spl.pubRecordId;
                }else if(splink.spl.hasPub && splink.spl.publishWithRec == false){
                    //close record
                    splSubmit.Id = splink.spl.pubRecordId;
                    splSubmit.Date_closed__c = System.today();
                    splSubmitList.add(splSubmit);
                }else if(splink.spl.hasAct && splink.spl.publishWithRec){
                    //clone
                    String soql = Util.getCreatableFieldsSOQL('Section_Product_Link__c','id=\'' + splink.spl.actRecordId + '\'', null);
                    String soqlRefined = soql.replace('Section__c,', '');
                    System.debug(soqlRefined);
                    Section_Product_Link__c splClone = (Section_Product_Link__c)Database.query(soqlRefined);
                    splSubmit = splClone.clone(false, true);
                    System.debug(splSubmit);
                    //splSubmit.putSObject('Section_Product_Links__r', sectionSubmit);
                    splSubmit.Section__r = new Section__c(External_Id__c = guUtil.getSectionExtId(String.valueOf(referenceMap.get(s.section.actRecordId).get('Group_Number__c')), String.valueOf(referenceMap.get(s.section.actRecordId).get('Section_Number__c')), String.valueOf(referenceMap.get(groupFamily.grp.pubRecordId).get('Version__c'))));
                    System.debug(sectionSubmit.External_Id__c);
                    splSubmit.put('Product__c', String.valueOf(referenceMap.get(splink.spl.actRecordId).get('Product__c')));
                    splSubmitList.add(splSubmit);
                    System.debug('made it to clone section product link' + splSubmit);
                }else if(splink.spl.hasAct && splink.spl.publishWithRec == false){
                    //do nothing
                    splSubmit.Id = splink.spl.pubRecordId;
                }
            }
        }
        
        grpSubmitList.add(groupSubmit);

        for(Group__c g:grpSubmitList){
            g.IsPublishWizard__c = true;
        }
        
        for(Section__c s:secSubmitList){
            s.IsPublishWizard__c = true;
        }

        for(Section_Product_Link__c spl :splSubmitList){
            spl.IsPublishWizard__c = true;
        }

        update grpSubmitList;
        upsert secSubmitList;
        upsert splSubmitList;
        
        PageReference grpPage = new ApexPages.StandardController(groupSubmit).view();
        grpPage.setRedirect(true);
        return grpPage;
    }
    
    public Map<String, List<sObject>> getReferenceMap(String queryBody, String pubTail, String actTail, String orderBy, String sObjectDecl, String statusApiName){
        List<sObject> recList = getRecordQuery(queryBody, pubTail, actTail, orderBy, sObjectDecl);
        List<sObject> actList = new List<sObject>();
        List<sObject> pubList = new List<sObject>();
        List<sObject> penList = new List<sObject>();
        Map<String, List<sObject>> returnMap = new Map<String, List<sObject>>();
        
        for(sObject rec :recList){
            //populate a vanilla reference map that holds all of the original values
            referenceMap.put(rec.Id, rec);
            if(rec.get(statusApiName) == 'Draft'){
                pubList.add(rec);
            }else if(rec.get(statusApiName) == 'Pending'){
                penList.add(rec);
            }else{
                actList.add(rec);
            }
        }
        
        //need to return two lists, so putting them in a Map so they can be returned in one object (we can check if the map contains keys later)
        if(!pubList.isEmpty()){
            returnMap.put('Publish', pubList);
        }
        if(!actList.isEmpty()){
            returnMap.put('Active', actList);
        }
        if(!penList.isEmpty()){
            returnMap.put('Pending', penList);
        }
        
        return returnMap;
    }
    
    public static List<sObject> getRecordQuery(String queryBody, String whereClauseOne, String WhereClauseTwo, String orderBy, String sObjectDecl) {
        String query = 'SELECT ';
        //Original Line - Retrieving fields are now called from the controller
        /*List<Schema.FieldSetMember> fieldSetMemberList =  Util.readFieldSet('CompareFields',sObjectDecl);
        for(Schema.FieldSetMember f : fieldSetMemberList) {
            //variable queryBody contains 'Name' field , so if added in fieldset do not add to query variable 
            if(f.getFieldPath() != 'Name'){
                query += f.getFieldPath() + ', '; 
            } 
        }*/
        
        query += queryBody;
        if(whereClauseOne != null || whereClauseTwo != null){
            query += ' WHERE';
            if(whereClauseOne != null){
                query += ' ' + whereClauseOne;
            }
            if(whereClauseOne != null && whereClauseTwo != null){
                query += ' OR';
            }
            if(whereClauseTwo != null){
                query += ' ' + whereClauseTwo;
            }
        }
        if(orderBy != null){
            query += '' + orderBy;
        }
        System.debug('this is the query string ' + query);
        return Database.query(query);
    }
    
    public void cObjectPrefixes(){
        
        //Group prefix
        Schema.DescribeSObjectResult groupSchema = Group__c.sObjectType.getDescribe();
        groupPrefix = groupSchema.getKeyPrefix();
        
        //Section prefix
        Schema.DescribeSObjectResult sectionSchema = Section__c.sObjectType.getDescribe();
        sectionPrefix = sectionSchema.getKeyPrefix();
        
        //Section Product Link prefix
        Schema.DescribeSObjectResult splSchema = Section_Product_Link__c.sObjectType.getDescribe();
        splPrefix = splSchema.getKeyPrefix();
        
    }
    
    /* --------------------------- Wrapper Classes --------------------------- */
    
    //custom Group Wrapper to maintain relationship with Sections
    public class groupClass{
        public comparisonListObj grp {get;set;}
        public List<sectionClass> sectionList {get;set;}
        
        public groupClass(comparisonListObj grpC){
            grp = grpC;
            sectionList = new List<sectionClass>();
        } 
    }
    
    //custom Section wrapper to maintain relationship with Section Product Links
    public class sectionClass{
        public comparisonListObj section {get;Set;}
        public List<splClass> splList {get;Set;}
        
        public sectionClass(comparisonListObj sectionC){
            section = sectionC;
            splList = new List<splClass>();
        } 
    }
    
    //custom Section Product Link wrapper
    public class splClass{
        public comparisonListObj spl {get;set;}
        
        public splClass(comparisonListObj splC){
            spl = splC;
        } 
    }
    
    //wrapper for comparison object with identifier as to whether the instance has a version for both publish and active
    public class comparisonListObj{
        
        //GVT-302 - All fields appear in the publish wizard - update start
        //Enabled the fields to be grouped via field sections using maps
        //Comparison wrapper for each field in field set
        public Map<String, List<comparisonObj>> cObj {get;set;}
        //Comparison wrapper for each field in field set
        public Map<String, Boolean> fieldSetContainsChange {get;set;}
        //GVT-302 - All fields appear in the publish wizard - update end
        
        //Does this wrapper contain an active version for comparison?
        public Boolean hasAct {get;set;}
        //Does this version contain a version awaiting publishing for comparison?
        public Boolean hasPub {get;set;}
        //Boolean to store whether this record has any new children
        public Boolean hasNewChild {get;Set;}
        //Boolean to store whether this record has any changed children
        public Boolean hasChangedChild {get;Set;}
        //If the record contains any changes
        public Boolean containsChange {get;set;}
        //Parent Id
        public String parentId {get;Set;}
        //identifier for the record (parent comparison)
        public String uniqueIdentifier {get;Set;}
        //if only one of the records exist, have a select option to chose whether to publish
        public Boolean publishWithRec {get;Set;}
        //grab the record id for the publishing part
        public String pubRecordId {get;Set;}
        public String actRecordId {get;Set;}
        //the record's name
        public String recordName {get;Set;}
        
        public comparisonListObj(Map<String, List<comparisonObj>> c, Boolean aNN, Boolean pNN, Boolean cC, String pId, String uId, String prId, String arId, String rName, Map<String, String> forcedReadOnlyFieldsMap){
            cObj = c;
            //GVT-302 - All fields appear in the publish wizard - update start
            Boolean allSectionsContainsChange = false;
            if(fieldSetContainsChange == null){
                fieldSetContainsChange = new Map<String, Boolean>();  
            }
            
            //Determine field sets with change
            for(String loopKey : c.keySet()){
                fieldSetContainsChange.put(loopKey, false);
                for(comparisonObj loopComparisonObject : c.get(loopKey)){
                    if((loopComparisonObject.pubValue != loopComparisonObject.actValue && !forcedReadOnlyFieldsMap.get(String.valueOf((((Id)prId).getSObjectType()))).containsIgnoreCase(loopComparisonObject.fieldLabel))){
                        fieldSetContainsChange.put(loopKey, true);
                        if(aNN){
                            allSectionsContainsChange = true;
                        }
                    }
                }
            }
            //GVT-302 - All fields appear in the publish wizard - update end
            
            hasAct = aNN;
            hasPub = pNN;
            //GVT-302 - containsChange = cC;
            containsChange = allSectionsContainsChange;
            parentId = pId;
            uniqueIdentifier = uId;
            pubRecordId = prId;
            actRecordId = arId;
            recordName = rName;
            hasNewChild = false;
            hasChangedChild = false;
            
            if(hasPub){
                publishWithRec = true;
            }else{
                publishWithRec = false;
            }
            
        }
        
    }
    
    public class comparisonObj{
        
        //public version value
        public String pubValue {get;set;}
        //active version value
        public String actValue {get;set;}
        //field API name
        public String fieldAPI {get;set;}
        //publish record selected (default)
        public Boolean pubSelect {get;set;}
        //active version selected
        public Boolean actSelect {get;set;}
        //field label for printing on VF page
        public String fieldLabel {get;set;}
        //field type of the field
        public String fieldType {get;set;}
        //A map with API names and values for reference
        public Map<String, String> additionalValues {get;set;}
        
        public comparisonObj(String pV, String aV, String apiN, Boolean pSelect, Boolean aSelect, String fLabel, Map<String, String> addFields, String newFieldType){
            
            if(pV == 'true'){
                pubValue = 'Yes';
            }else if(pV == 'false'){
                pubValue = 'No';
            }else{
                pubValue = pV;
            }
            
            if(aV == 'true'){
                actValue = 'Yes';
            }else if(aV == 'false'){
                actValue = 'No';
            }else{
                actValue = aV;
            }
            
            fieldAPI = apiN;
            pubSelect = pSelect;
            actSelect = aSelect;
            fieldLabel = fLabel;
            fieldType = newFieldType;
            additionalValues = addFields;
            
        }
        
    }
}