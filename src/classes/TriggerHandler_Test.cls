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
        Account acc = new Account(Name = 'Account');
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

/*
	@isTest static void test_Triggers() {

        System.debug('Begin TriggerHandler_Test.test_Triggers()');
		//create object
        //activate trigger
	    //confirm run    
        
        Account acc = TestUtilities.generateAccount();
		System.debug('Account: ' + acc);
        Insert acc;
        System.assert(acc.Id <> null);
        
        Mode__c mod = TestUtilities.generateMode(acc,'parcel');
		System.debug('Mode: ' + acc);
		Insert mod;
        System.assert(mod.Id <> null);
        
        Asset ast = TestUtilities.generateAsset(acc);
        System.debug('Asset: ' + ast);
        Insert ast;
        System.assert(ast.Id <> null);
        
        Opportunity opp = TestUtilities.generateOpportunity(acc);
        System.debug('Opportunity: ' + opp);
        Insert opp;
        System.assert(opp.Id <> null);
        
        OpportunityTeamMember otm = TestUtilities.generateOpportunityTeamMember(opp);
        System.debug('OpportunityTeamMember: ' + otm);
        Insert otm;
        System.assert(otm.Id <> null);

        Product2 pd2 = TestUtilities.generateProduct2();
        System.debug('Product2: ' + pd2);
		Insert pd2;
        System.assert(pd2.Id <> null);

        PriceBookEntry pbe = TestUtilities.generatePriceBookEntry(pd2);
        System.debug('PriceBookEntry: ' + pbe);
		Insert pbe;
        System.assert(pbe.Id <> null);

        OpportunityLineItem oli = TestUtilities.generateOpportunityLineItem(opp,pbe);
        System.debug('OpportunityLineItem: ' + oli);
        Insert otm;
        System.assert(otm.Id <> null);
        
	}

	@isTest static void test_run() {
		// Implement test code
	}
	
	@isTest static void test_setMaxLoopCount() {
		// Implement test code
	}

	@isTest static void test_clearMaxLoopCount() {
		// Implement test code
	}
    
	@isTest static void test_clearBypass() {
		// Implement test code
	}
    
	@isTest static void test_isByPassed() {
		// Implement test code
	}

    @isTest static void tes_cleaAllBypasses() {
		// Implement test code
	}

*/
