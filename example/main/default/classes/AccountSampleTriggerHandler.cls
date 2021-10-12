public without sharing class AccountSampleTriggerHandler extends TriggerHandler {

	private List<Account> newRecords;
	private List<Account> oldRecords;
	private Map<Id, Account> newRecordsMap;
	private Map<Id, Account> oldRecordsMap;

    public AccountSampleTriggerHandler() {
		super('AccountSampleTriggerHandler');
		this.newRecords = (List<Account>)Trigger.new;
		this.oldRecords = (List<Account>)Trigger.old;
		this.newRecordsMap = (Map<Id, Account>)Trigger.newMap;
		this.oldRecordsMap = (Map<Id, Account>)Trigger.oldMap;
    }

	public override void beforeInsert(){
		method1();
	}

	public override void beforeUpdate(){
		method2();
	}

	//public override void beforeDelete(){}

	public override void afterInsert(){
		method3();
	}

	//public override void afterUpdate(){}

	//public override void afterDelete(){}

	//public override void afterUndelete(){}

	private void method1(){
		for(Account a : newRecords){
			a.Name = a.Name.toUpperCase();
		}
	}

	private void method2(){
		for(Account a : newRecords){
			a.Name = a.Name.toLowerCase();
		}
	}

	private void method3(){
		List<Contact> acctContacts = [SELECT Id FROM Contact WHERE AccountId IN :newRecordsMap.keyset()];
		// do things here
	}
}
