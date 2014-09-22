//https://developer.salesforce.com/page/Virtual_Callout_Testing
//http://salesforce.stackexchange.com/questions/46107/trigger-context-system-trigger-class
//http://developer.force.com/cookbook/recipe/trigger-pattern-for-tidy-streamlined-bulkified-triggers
//https://www.salesforce.com/us/developer/docs/apexcode/index_Left.htm#CSHID=apex_classes_example.htm|StartTopic=Content%2Fapex_classes_example.htm|SkinName=webhelp
//http://www.salesforce.com/us/developer/docs/apexcode/Content/apex_classes_defining.htm
//http://jessealtman.com/2014/06/apexmocks-how-does-it-work/
//http://carvingintheclouds.blogspot.com/2013/10/forcecom-tested-standard-pattern-for.html
//http://salesforce.stackexchange.com/questions/24218/how-to-perform-mock-testing-on-apex-classes
//https://www.salesforce.com/us/developer/docs/apexcode/Content/apex_testing_testvisible.htm
@isTest (SeeAllData=true)
public class TriggerHandler_Test{

    public class TriggerHandlerMock extends TriggerHandler{

        protected override void beforeInsert(){}
        protected override void beforeUpdate(){}
        protected override void beforeDelete(){}
        protected override void afterInsert(){}
        protected override void afterUpdate(){}
        protected override void afterDelete(){}
        protected override void afterUndelete(){}
        
    }    
    
    @isTest static void test_Run(){
        Account acc = TestUtilities.generateAccount();
        Insert acc;
        Update acc;
        Delete acc;
        Undelete acc;        
    }
    @isTest static void test_ValidateRun(){
        //Try to run TriggerHandler without a Trigger
        TriggerHandlerMock t = new TriggerHandlerMock();
        try{
            t.run();
        }
        catch(Exception e){
			System.assertEquals(TRUE,e.getMessage().contains('Trigger handler called outside of Trigger execution'));
        }
    }
    @isTest static void test_LoopCount(){

        TriggerHandler.LoopCount l = new TriggerHandler.LoopCount();

        System.assertEquals(5,l.getMax());
        l.setMax(1);
		System.assertEquals(1,l.getMax());

        System.assertEquals(0,l.getCount());
        l.increment();
		System.assertEquals(1,l.getCount());
        System.assertEquals(FALSE,l.exceeded());
        l.increment();
		System.assertEquals(2,l.getCount());
        System.assertEquals(TRUE,l.exceeded());
        
		//Test Alternate Constructor
        TriggerHandler.LoopCount l_Max = new TriggerHandler.LoopCount(10);
		System.assertEquals(10,l_Max.getMax());
        
    }
    @isTest static void test_addToLoopCount() {

        TriggerHandlerMock t = new TriggerHandlerMock();
        t.setMaxLoopCount(2);

        Triggerhandler.LoopCount tl = TriggerHandler.loopCountMap.get('TriggerHandlerMock');
        System.assertEquals(2, tl.getMax());
        System.assertEquals(0, tl.getCount());

        t.setMaxLoopCount(1);
        System.assertEquals(1, tl.getMax());
        System.assertEquals(0, tl.getCount());
        
        t.addToLoopCount();
        System.assertEquals(1, tl.getCount());

        try{
	        t.addToLoopCount();
        }
        catch (Exception e){
			System.assertEquals(TRUE,e.getMessage().contains('Maximum loop count'));
        }

        t.clearMaxLoopCount();
        System.assertEquals(-1, tl.getMax());
        
    }
    @isTest static void test_Bypass(){
        TriggerHandlerMock t = new TriggerHandlerMock();

        TriggerHandler.bypass('TriggerHandlerMock');
        System.assertEquals(TRUE,TriggerHandler.isBypassed('TriggerHandlerMock'));
        TriggerHandler.clearBypass('TriggerHandlerMock');
        System.assertEquals(FALSE,TriggerHandler.isBypassed('TriggerHandlerMock'));

        TriggerHandler.bypass('TriggerHandlerMock');
        System.assertEquals(TRUE,TriggerHandler.isBypassed('TriggerHandlerMock'));
        TriggerHandler.clearAllBypasses();
        System.assertEquals(FALSE,TriggerHandler.isBypassed('TriggerHandlerMock'));
        
    }
    
}
