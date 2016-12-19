public class CaseExtension {
    
    private Case thisCase;
    
    public CaseExtension(ApexPages.StandardController controller) {
      this.thisCase = (Case)controller.getRecord();
    }

}