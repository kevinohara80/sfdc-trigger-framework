@IsTest
private class AccountSampleTriggerHandler_Test {

	@TestSetup
	static void makeData(){

	}

	@IsTest
	static void insertUpdateAccount(){
		Account a = new Account(Name = 'TestAcct');

		Test.startTest();
		insert a;

		a = [SELECT Id, Name FROM Account WHERE Id = :a.Id LIMIT 1];
		System.assert(a.Name.isAllUpperCase());
		a.Name = 'TestAcct';
		update a;
		Test.stopTest();

		a = [SELECT Id, Name FROM Account WHERE Id = :a.Id LIMIT 1];
		System.assert(a.Name.isAllLowerCase());


	}
}
