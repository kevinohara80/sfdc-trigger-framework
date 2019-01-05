@isTest
private class ApexBypassConfigTests {

    @testSetup static void factory(){
        ApexBypass__c ab = new ApexBypass__c();
        ab.Name = 'SectionA_bypass';
        ab.isBypassed__c = true;
        ab.Description__c = 'This record creates a configuration to bypass any block of Code denoted SectionA_bypass';
        insert ab;
    }
    
    @isTest static void isBypassedTest(){
		
        Integer a = 1;
        Integer b = 2;
        Integer c = 3;
        
        If(!ApexBypassConfig.isBypassed('SectionA_bypass')){
            c = a + b + c; 
        }
		        
        If(!ApexBypassConfig.isBypassed('SectionB_bypass')){
            c = c + 1;
        }   
        
        System.assertEquals(c, 4);
    }
}