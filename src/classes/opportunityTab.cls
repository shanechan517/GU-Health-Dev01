public class opportunityTab{
    
    public String selectedView {get;set;}
    public String pageName {get;set;}
    
    public opportunityTab(){
        //Find out if this is being called from the Opportunity tab or the Renewal tab
        String strurl = ApexPages.currentPage().getUrl();
        if(strurl != null && strurl.contains('apex/')){
            strurl = strurl.split('apex/')[1];
            if(strurl.contains('opportunity')){
                pageName = 'Opportunity';
            }else if(strurl.contains('renewal')){
                pageName = 'Renewal';
            }else if(strurl.contains('maintenance')){
                pageName = 'Client Maintenance';
            }
        }
        
        selectedView = 'All';
    }
    
    public List<SelectOption> getViews() {
        List<SelectOption> options = new List<SelectOption>();
        if(pagename == 'Opportunity'){
            options.add(new SelectOption('All','All Opportunities'));
            options.add(new SelectOption('My','My Opportunities'));
            options.add(new SelectOption('Open','Open Opportunities'));
            //options.add(new SelectOption('Active','Active Opportunities'));
        }else if(pagename == 'Renewal'){
            options.add(new SelectOption('All','All Renewals'));
            options.add(new SelectOption('My','My Renewals'));
            options.add(new SelectOption('Open','Open Renewals'));
            //options.add(new SelectOption('Active','Active Renewals'));
        }else if(pagename == 'Client Maintenance'){
            options.add(new SelectOption('All','All Client Maintenance Records'));
            options.add(new SelectOption('My','My Client Maintenance Records'));
            options.add(new SelectOption('Open','Open Client Maintenance Records'));
            //options.add(new SelectOption('Active','Active Client Maintenance Records'));
        }
        return options;
    }
    
}