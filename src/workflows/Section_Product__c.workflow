<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Product_External_Id</fullName>
        <field>External_ID__c</field>
        <formula>Product_Code__c</formula>
        <name>Product External Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Product_ExtID</fullName>
        <actions>
            <name>Product_External_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>IF(
External_ID__c != Product_Code__c, TRUE, FALSE)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
