<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Account_External_Id</fullName>
        <field>External_ID__c</field>
        <formula>Id</formula>
        <name>Account External Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Account_ExtID</fullName>
        <actions>
            <name>Account_External_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>IF(
External_ID__c != Id,TRUE,FALSE)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
