<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_AM_that_op_renewal_is_complete</fullName>
        <description>Notify AM that op/renewal is complete</description>
        <protected>false</protected>
        <recipients>
            <field>Account_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Client_Renewal_Approval_Process/Complete_to_AM</template>
    </alerts>
    <alerts>
        <fullName>Opportunity_ClosedWon_AM_alerted</fullName>
        <description>Opportunity ClosedWon/AM alerted</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Client_Renewal_Approval_Process/Opportunity_ClosedWon_AM_alert</template>
    </alerts>
    <alerts>
        <fullName>Rejection_Email_Notification_to_Previous_Step_Owner</fullName>
        <description>Rejection Email Notification to Previous Step Owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Client_Renewal_Approval_Process/Approval_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Renewal_Creation_Notification</fullName>
        <description>Renewal Creation Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Account_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Client_Renewal_Approval_Process/Renewal_Creation</template>
    </alerts>
    <alerts>
        <fullName>Renewal_Rejected_to_AM</fullName>
        <description>Renewal Rejected to AM</description>
        <protected>false</protected>
        <recipients>
            <field>Account_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Client_Renewal_Approval_Process/Rejected_to_AM</template>
    </alerts>
    <alerts>
        <fullName>Send_Notification_Email_to_AM_Step_1</fullName>
        <description>Send Notification Email to AM (Step 1)</description>
        <protected>false</protected>
        <recipients>
            <field>Account_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Client_Renewal_Approval_Process/Step_1_1</template>
    </alerts>
    <alerts>
        <fullName>Send_Notification_Email_to_AM_Step_2</fullName>
        <description>Send Notification Email to AM (Step 2)</description>
        <protected>false</protected>
        <recipients>
            <field>Account_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Client_Renewal_Approval_Process/Step_2_2</template>
    </alerts>
    <alerts>
        <fullName>Send_Notification_Email_to_AM_Step_3</fullName>
        <description>Send Notification Email to AM (Step 3)</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Account_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Client_Renewal_Approval_Process/Step_3_3</template>
    </alerts>
    <fieldUpdates>
        <fullName>AM_Approved</fullName>
        <field>Approval_Stage__c</field>
        <literalValue>Approved by Account Manager</literalValue>
        <name>AM Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AM_Rejected</fullName>
        <field>Approval_Stage__c</field>
        <literalValue>Declined by Account Manager</literalValue>
        <name>AM Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Process_2_Update_StageName</fullName>
        <field>StageName</field>
        <literalValue>Negotiation with Client/Broker</literalValue>
        <name>Approval Process 2 Update StageName</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approved_by_Client_Broker</fullName>
        <field>StageName</field>
        <literalValue>Approved by Broker/Client</literalValue>
        <name>Approved by Client/Broker</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approved_throughout_approval_process</fullName>
        <field>StageName</field>
        <literalValue>Ready for Finalise Docs</literalValue>
        <name>Approved throughout approval process</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Broker_Approved</fullName>
        <field>Approval_Stage__c</field>
        <literalValue>Approved by Broker</literalValue>
        <name>Broker Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Broker_Rejected</fullName>
        <field>Approval_Stage__c</field>
        <literalValue>Declined by Broker</literalValue>
        <name>Broker Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Client_Approved</fullName>
        <field>Approval_Stage__c</field>
        <literalValue>Approved by Client</literalValue>
        <name>Client Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Client_Broker_Rejected</fullName>
        <field>StageName</field>
        <literalValue>In Revision</literalValue>
        <name>Client/Broker Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Client_Rejected</fullName>
        <field>Approval_Stage__c</field>
        <literalValue>Declined by Client</literalValue>
        <name>Client Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>HOC_Approved</fullName>
        <field>Approval_Stage__c</field>
        <literalValue>Approved by Head of Commercial</literalValue>
        <name>HOC Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>HOC_Rejected</fullName>
        <field>Approval_Stage__c</field>
        <literalValue>Declined by Head of Commercial</literalValue>
        <name>HOC Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>HOS_Approved</fullName>
        <field>Approval_Stage__c</field>
        <literalValue>Approved by Head of Sales</literalValue>
        <name>HOS Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>HOS_Rejected</fullName>
        <field>Approval_Stage__c</field>
        <literalValue>Declined by Head of Sales</literalValue>
        <name>HOS Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Opportunity_External_Id</fullName>
        <field>External_ID__c</field>
        <formula>Id</formula>
        <name>Opportunity External Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Ready_for_Approval</fullName>
        <field>StageName</field>
        <literalValue>Awaiting Approval</literalValue>
        <name>Ready for Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Rejected_from_Approval_process</fullName>
        <field>StageName</field>
        <literalValue>In Preparation</literalValue>
        <name>Rejected from Approval process</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Retrieve_from_Approval_Process</fullName>
        <field>StageName</field>
        <literalValue>In Preparation</literalValue>
        <name>Retrieve from Approval Process</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Close_Date</fullName>
        <field>CloseDate</field>
        <formula>TODAY()</formula>
        <name>Update Close Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>COMM_OP_Complete_Update</fullName>
        <actions>
            <name>Notify_AM_that_op_renewal_is_complete</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Complete</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>COMM_OP_Owner_ClosedWon</fullName>
        <actions>
            <name>Opportunity_ClosedWon_AM_alerted</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Opportunity_Won_Start_new_group_process</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Opportunity</value>
        </criteriaItems>
        <description>send email notification and reminder to Account Manager. Copy opportunity owner</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>COMM_RWNL_Creation_Notification</fullName>
        <actions>
            <name>A_new_renewal_has_been_created</name>
            <type>Task</type>
        </actions>
        <actions>
            <name>A_new_renewal_has_been_created_AM</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Renewal</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity_ExtID</fullName>
        <actions>
            <name>Opportunity_External_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>IF(
External_ID__c != Id, TRUE, FALSE)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <tasks>
        <fullName>A_new_renewal_has_been_created</fullName>
        <assignedToType>owner</assignedToType>
        <description>A new renewal has been created and is awaiting action.</description>
        <dueDateOffset>1</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>A new renewal has been created</subject>
    </tasks>
    <tasks>
        <fullName>A_new_renewal_has_been_created_AM</fullName>
        <assignedToType>accountOwner</assignedToType>
        <description>A new renewal has been created and is awaiting action.</description>
        <dueDateOffset>1</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>A new renewal has been created</subject>
    </tasks>
    <tasks>
        <fullName>Opportunity_Won_Start_new_group_process</fullName>
        <assignedToType>accountOwner</assignedToType>
        <description>A new won opportunity has now been assigned to you. Please initiate the “New Group” process.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Opportunity.CloseDate</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Opportunity Won - Start new group process</subject>
    </tasks>
</Workflow>
