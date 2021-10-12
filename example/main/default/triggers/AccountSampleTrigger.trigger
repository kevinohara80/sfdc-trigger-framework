trigger AccountSampleTrigger on Account (before insert, after insert, before update, after update, before delete, after delete, after undelete) {

	new AccountSampleTriggerHandler().run();
}


