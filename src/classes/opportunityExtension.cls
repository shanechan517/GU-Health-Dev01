public class opportunityExtension {

    private final Opportunity op;
    public List<Case> cList {get;set;}

    public opportunityExtension (ApexPages.StandardController stdController) {
        this.op = (Opportunity)stdController.getRecord();
        
        cList = new List<Case>([SELECT Id, CaseNumber, Subject, Status, CreatedDate, Priority FROM Case WHERE Opportunity_Renewal__c =:op.Id ORDER BY CreatedDate]);
    }
}