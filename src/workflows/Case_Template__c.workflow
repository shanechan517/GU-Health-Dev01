<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Case_Template_Unique_Field</fullName>
        <field>Dup_Checker__c</field>
        <formula>Group__c &amp; TEXT(Code__c)</formula>
        <name>Case Template Unique Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CT_Dup_Checker</fullName>
        <actions>
            <name>Case_Template_Unique_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Check the case template object and make sure there is not two cases with the same parent and code</description>
        <formula>ISNEW() || ISCHANGED(Code__c) || ISCHANGED(Group__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
