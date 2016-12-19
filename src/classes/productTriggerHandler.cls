/////////////////////////////////
// Handler Class for Product Object
// Created by Clint D'Silva
// if Cover code is set in Product,  create related list Product Section Cover Code for each space separated code in Cover Code field. 
// Delete value in related list if not in Produt code  cover field
/////////////////////////////////
public class productTriggerHandler {
    private list<Section_Product__c> NewSectPrdLst;
    public void productTriggerHandler(){
        NewSectPrdLst = new list<Section_Product__c>();
        NewSectPrdLst =  (list<Section_Product__c>)trigger.new;
    }

    public  void CreateUpdateSectionProductCoverCode(){
        NewSectPrdLst =  (list<Section_Product__c>)trigger.new;
        map<id,Section_Product__c> NewSectPrdMap = new map<id,Section_Product__c>(); 
        boolean bValError = false;
        if(NewSectPrdLst != null) { 
            for( Section_Product__c SectPrd : NewSectPrdLst  ) {
                NewSectPrdMap.put(SectPrd.id,SectPrd);
                if(SectPrd.Cover_Code__c != null){
                    string reg = '^([0-9]{3}|[0-9]{3} [0-9]{3}|[0-9]{3} [0-9]{3} [0-9]{3})$';
                    pattern p = pattern.compile(reg);
                    matcher m = p.matcher(SectPrd.Cover_Code__c);
                    if(!m.matches()){
                        bValError = true;
                        system.debug('Cover Codes are of 3 digits. There can be upto 3 cover codes separated by a space: SectPrd.Cover_Code__c=' + SectPrd.Cover_Code__c );
                        SectPrd.addError('<span>Cover Codes are of 3 digits. There can be upto 3 cover codes separated by a space. </br><b>Cover Codes can be in any one of the following formats</b></br>XXX</br>XXX XXX</br>XXX XXX XXX</span>',false);    
                    }    
                }
                
                
            } 
            
            if (!bValError){
                list<id> DelSPLst = new list<id>();
                list<Section_Product_Cover_Code__c> InsNewSPLstObj = new list<Section_Product_Cover_Code__c>();   
                Map<id,Section_Product_Cover_Code__c> InsDelSPLstObj = new map<id,Section_Product_Cover_Code__c>();    
                list<string> InsSPLst  = new list<string>();
                Map<string,list<Section_Product__c>> SPNewCvrMap = new Map<string,list<Section_Product__c>>() ;     
                Map<string,id> SPCvrCdMap ;
                   
                set<string> cvrCdSpit ;
                    
                List<Section_Product__c> secPrdLst = [select id ,(select id,CoverCode__c,CoverCode__r.name,   Products__c from  Section_Product_Cover_Codes__r  order by Sort_Order__c) from  Section_Product__c where  id in :NewSectPrdMap.keySet() ];    
                
                for(Section_Product__c secPrd : secPrdLst){
                    Section_Product__c SPOrigObj = NewSectPrdMap.get(secPrd.id); 
                     SPCvrCdMap = new Map<string,id>();
                     cvrCdSpit = SPOrigObj.Cover_Code__c == null ? new set<string>() :  new set<string>(SPOrigObj.Cover_Code__c.split(' ')) ;
                     for(Section_Product_Cover_Code__c secPrdCvr : secPrd.Section_Product_Cover_Codes__r){
                         if(SPOrigObj.Cover_Code__c == null || SPOrigObj.Cover_Code__c == '' ){DelSPLst.add(secPrdCvr.id); InsDelSPLstObj.put(secPrdCvr.id,secPrdCvr);}
                         if(!(cvrCdSpit.contains(secPrdCvr.CoverCode__r.name))){
                             //remove from section product cover code related list if not in field Cover_Code__c at product level
                             DelSPLst.add(secPrdCvr.id);
                             InsDelSPLstObj.put(secPrdCvr.id,secPrdCvr);
                         }else if(SPCvrCdMap.containskey(secPrdCvr.CoverCode__r.name) && SPCvrCdMap.get(secPrdCvr.CoverCode__r.name) != secPrdCvr.id  ){
                             // delete duplicate cover code from section product cover code related list
                             DelSPLst.add(secPrdCvr.id);
                             InsDelSPLstObj.put(secPrdCvr.id,secPrdCvr);
                             
                         } else {
                             SPCvrCdMap.put(secPrdCvr.CoverCode__r.name,secPrdCvr.id);
                        }   
                     }
                    // Check if cove code in section product field exist in related list if not add new value                        
                     for(string sCd : cvrCdSpit){
                         if(SPCvrCdMap.containskey(sCd)){
                             // do nothing cover code at related list level  exists for product level cover code field
                         } else {
                             InsSPLst.add(sCd); 
                             if(SPNewCvrMap.containsKey(sCd)){
                                  SPNewCvrMap.get(sCd).add(SPOrigObj);
                             } else {
                                 list<Section_Product__c> sLst = new list<Section_Product__c>();
                                 sLst.add(SPOrigObj);
                                 SPNewCvrMap.put(sCd,sLst);
                             }
                            
                         }
                     }
                 }   
                    
                    // get ids for these codes and add related list to section product
                     
                    string sExp = '';
                    set<string> CvrCodeRtn = new  set<string>();
                    list<CoverCode__c> CoverCodeNewLst = [select id ,name,Type_Description__c from CoverCode__c where name in : InsSPLst ];
                    for(CoverCode__c cc :CoverCodeNewLst ){
                        CvrCodeRtn.add(cc.name);
                        for(Section_Product__c sIdObj :  SPNewCvrMap.get(cc.name)){
                            if(sIdObj.Product_Type__c != null){
                                if(sIdObj.Product_Type__c.contains(cc.Type_Description__c)){
                                   Section_Product_Cover_Code__c SPCCNew = new Section_Product_Cover_Code__c(Products__c = sIdObj.id, CoverCode__c = cc.id ); 
                                   InsNewSPLstObj.add(SPCCNew);  
                                }else {
                                    //raise error :  cover code type description  not within product type in product 
                                   sExp =   'Cover Code ' + cc.name  + ' of type ' + cc.Type_Description__c + ' cannot be set for ' + sIdObj.name + ' with Product Type of ' +  sIdObj.Product_Type__c ;
                                   system.debug('Error sExp=' + sExp + ' , ID=' + sIdObj.id );

                                  sIdObj.addError(sExp); 
                                }    
                            } ELSE {
                                sExp = 'Product Type cannot be null for' + sIdObj.name + ' when Cover Code is set' ; 
                                system.debug('Error sExp=' + sExp + ' , ID=' + sIdObj.id);
                                sIdObj.addError(sExp); 
                            }
                        }                       
                    }
                
                for(string sCd :SPNewCvrMap.keySet()){
                    if(!CvrCodeRtn.contains(sCd)){
                        list<Section_Product__c> sLst = new list<Section_Product__c>();
                        sLst = SPNewCvrMap.get(sCd);
                        if(sLst != null){
                            for(Section_Product__c spObj : sLst ){ 
                                system.debug('Error: Cover Code ' + sCd + ' in ' +  spObj.Cover_Code__c + ' does not exist in Cove Code Table');
                                spObj.addError('Cover Code ' + sCd + ' in ' +  spObj.Cover_Code__c + ' does not exist in Cove Code Table' ); 
                            }  
                        }
                    }
                }
                    insert InsNewSPLstObj;
                    delete InsDelSPLstObj.values();    
            }  // if !bValError    
        }   // --> if NewSectPrdLst is not null
    }       
}