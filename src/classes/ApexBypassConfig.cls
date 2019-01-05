/*@Description: This class is used to retrive and apply the bypass configuration 
 *              as defined in the custom settings "Apex Bypass Configuration"
 *================================================================================
 * Author					Date						Description
 * -------------------------------------------------------------------------------
 * Saikat Deshmukh			1/5/2019				Initial Implmentation.
 * ===============================================================================
 * */
public without Sharing class ApexBypassConfig {

    public static Map<String,Boolean> bypassConfigMap;
    public static Map<String,Boolean> getInstance(){
        
        if(bypassConfigMap == null){
            bypassConfigMap = new Map<String,Boolean>();
            for(ApexBypass__c csRecord : ApexBypass__c.getAll().values()){
                bypassConfigMap.put(csRecord.Name, csRecord.isBypassed__c);
            }
        }
        
        return bypassConfigMap;
    }
    
    public static Boolean isBypassed(String sectionName){
        return ApexBypassConfig.getInstance().containsKey(sectionName) ? ApexBypassConfig.getInstance().get(sectionName) : false;   
    }
}