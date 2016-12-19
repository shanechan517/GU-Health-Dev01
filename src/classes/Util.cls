global class Util{
    
    public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName){
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();

        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);

        return fieldSetObj.getFields(); 
    }  
    
    // Returns a dynamic SOQL statement for the whole object, includes only creatable fields since we will be inserting a cloned result of this query
    public static string getCreatableFieldsSOQL(String objectName, String whereClause, String additionalFields){
         
        String selects = '';
         
        if (whereClause == null || whereClause == ''){ return null; }
         
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
			if(additionalFields != null){
				selects += additionalFields;
			}
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
        }
         
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;
         
    }
    
}