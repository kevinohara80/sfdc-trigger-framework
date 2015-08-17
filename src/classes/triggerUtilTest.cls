/*
    Created by: Greg Hacic
    Last Update: 17 August 2015 by Greg Hacic
    Questions?: greg@interactiveties.com
    
    Notes:
        - tests triggerUtil.class (100.00% coverage)
*/
@isTest
private class triggerUtilTest {
    
    //tests orgUtil.class
    static testMethod void checkStatus() {
        //create some Trigger_Status__c records
        List<Trigger_Status__c> triggerStatus = new List<Trigger_Status__c>();
        triggerStatus.add(new Trigger_Status__c(Name = 'testing1Trigger', Status__c = true));
        triggerStatus.add(new Trigger_Status__c(Name = 'testing2Trigger', Status__c = false));
        insert triggerStatus;
        Test.startTest();
        Boolean determineStatus = orgUtil.isTriggerOkayToRun('testing1Trigger');
        System.assertEquals(true, determineStatus);
        determineStatus = orgUtil.isTriggerOkayToRun('testing2Trigger');
        System.assertEquals(false, determineStatus);
        determineStatus = orgUtil.isTriggerOkayToRun('aDifferentTrigger');
        System.assertEquals(true, determineStatus);
        Test.stopTest();
    }

}