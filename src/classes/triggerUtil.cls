/*
    Created by: Greg Hacic
    Last Update: 17 August 2015 by Greg Hacic
    Questions?: greg@interactiveties.com
    
    Notes:
        - tests located at triggerUtilTest.class
*/
public class triggerUtil {
    
    //determines whether or not the trigger logic is okay to run
    public static Boolean isTriggerOkayToRun(String triggerName) {
        Boolean returnBoolean = true;
        Trigger_Status__c t = Trigger_Status__c.getInstance(triggerName); //grab the Trigger_Status__c custom setting object record named triggerName
        if (t != null) { //if the result is not null
            returnBoolean = t.Status__c; //set the returnBoolean value to the Status__c Boolean value for the found record
        }
        return returnBoolean; //return returnBoolean
    }

}