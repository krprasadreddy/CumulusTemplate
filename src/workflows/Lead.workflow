<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>GW_Volunteers__Volunteer_Signup_Notification_Email_Alert_Lead</fullName>
        <description>Volunteer Signup Notification Email Alert - Lead</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GW_Volunteers__Volunteers_Email_Templates/GW_Volunteers__Volunteer_Signup_Notification</template>
    </alerts>
    <alerts>
        <fullName>GW_Volunteers__Volunteer_Signup_Thank_You_Email_Alert_Lead</fullName>
        <description>Volunteer Signup Thank You Email Alert - Lead</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GW_Volunteers__Volunteers_Email_Templates/GW_Volunteers__Volunteer_Signup_Thank_You</template>
    </alerts>
    <rules>
        <fullName>GW_Volunteers__Volunteer Signup - Lead</fullName>
        <actions>
            <name>GW_Volunteers__Volunteer_Signup_Notification_Email_Alert_Lead</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>GW_Volunteers__Volunteer_Signup_Thank_You_Email_Alert_Lead</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>GW_Volunteers__Volunteer_Signup_Thank_You_Sent_Lead</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.GW_Volunteers__Volunteer_Status__c</field>
            <operation>equals</operation>
            <value>New Sign Up</value>
        </criteriaItems>
        <description>When a new lead is created from a volunteer signup, send a thank you and notify the volunteer manager</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <tasks>
        <fullName>GW_Volunteers__Volunteer_Signup_Thank_You_Sent_Lead</fullName>
        <assignedToType>owner</assignedToType>
        <description>An automatic email has been sent to the lead thanking them for signing up to be a volunteer.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Volunteer Signup Thank You Sent - Lead</subject>
    </tasks>
</Workflow>
