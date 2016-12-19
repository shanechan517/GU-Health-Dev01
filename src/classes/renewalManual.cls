global class renewalManual { 

    webService Static Id processManually(String recordId, String include, string rt, String objType) { 
        renewalProcess rP = new renewalProcess();
        rp.processSchedule(recordId, include, rt, objType);

        return rP.newId;
    }
    
    /*webService Static Id processSection(String sectionId) { 
        renewalProcess rP = new renewalProcess();
        rp.processSection(sectionId);

        return rP.newSectionId;
    }*/
    
    webService Static String retireGroup(Group__c pgroup, Date publishDate) { 
        renewalProcess rP = new renewalProcess();
        String message = rp.closeActiveGroup(pgroup, publishDate);

        return message;
    }

    webservice static String discardGroupVersion(Id groupId){
        renewalProcess rP = new renewalProcess();
        String message = rp.discardGroup(groupId);

        return message;
    }
}