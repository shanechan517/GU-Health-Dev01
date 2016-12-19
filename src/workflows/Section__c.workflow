<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Section_External_Id</fullName>
        <field>External_ID__c</field>
        <formula>Group_Number__c &amp; &quot;v&quot; &amp; TEXT(Group_Version__c) &amp; &quot;S&quot; &amp; Section_Number__c</formula>
        <name>Section External Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Section_ExtID</fullName>
        <actions>
            <name>Section_External_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Section__c.Group_Number__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Section__c.Group_Version__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Section__c.Section_Number__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
