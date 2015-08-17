# SFDC trigger framework

I know, I know...another trigger framework. Bear with me. ;)

## Overview

Triggers should (IMO) be logicless. Putting logic into your triggers creates un-testable, difficult-to-maintain code. It's widely accepted that a best-practice is to move trigger logic into a handler class.

This trigger framework bundles a single **TriggerHandler** base class that you can inherit from in all of your trigger handlers. The base class includes context-specific methods that are automatically called when a trigger is executed.

The base class also provides a secondary role as a supervisor for Trigger execution. It acts like a watchdog, monitoring trigger activity and providing an api for controlling certain aspects of execution and control flow.

But the most important part of this framework is that it's minimal and simple to use. 

## Usage

To create a trigger handler, you simply need to create a class that inherits from **TriggerHandler.cls**. Here is an example for creating an Opportunity trigger handler.

```java
public class OpportunityTriggerHandler extends TriggerHandler {
```

In your trigger handler, to add logic to any of the trigger contexts, you only need to override them in your trigger handler. Here is how we would add logic to a `beforeUpdate` trigger.

```java
public class OpportunityTriggerHandler extends TriggerHandler {
  
  public override void beforeUpdate() {
    for(Opportunity o : (List<Opportunity>) Trigger.new) {
      // do something
    }
  }

  // add overrides for other contexts

}
```

**Note:** When referencing the Trigger statics within a class, SObjects are returned versus SObject subclasses like Opportunity, Account, etc. This means that you must cast when you reference them in your trigger handler. You could do this in your constructor if you wanted. 

```java
public class OpportunityTriggerHandler extends TriggerHandler {

  private Map<Id, Opportunity> newOppMap;

  public OpportunityTriggerHandler() {
    this.newOppMap = (Map<Id, Opportunity>) Trigger.newMap;
  }
  
  public override void afterUpdate() {
    //
  }

}
```

To use the trigger handler, you only need to construct an instance of your trigger handler within the trigger handler itself and call the `run()` method. Here is an example of the Opportunity trigger.

```java
trigger OpportunityTrigger on Opportunity (before insert, before update) {
  new OpportunityTriggerHandler().run();
}
```

## Cool Stuff

### Max Loop Count

To prevent recursion, you can set a max loop count for Trigger Handler. If this max is exceeded, and exception will be thrown. A great use case is when you want to ensure that your trigger runs once and only once within a single execution. Example:

```java
public class OpportunityTriggerHandler extends TriggerHandler {

  public OpportunityTriggerHandler() {
    this.setMaxLoopCount(1);
  }
  
  public override void afterUpdate() {
    List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE Id IN :Trigger.newMap.keySet()];
    update opps; // this will throw after this update
  }

}
```

### Bypass API

What if you want to tell other trigger handlers to halt execution? That's easy with the bypass api. Example.

```java
public class OpportunityTriggerHandler extends TriggerHandler {
  
  public override void afterUpdate() {
    List<Opportunity> opps = [SELECT Id, AccountId FROM Opportunity WHERE Id IN :Trigger.newMap.keySet()];
    
    Account acc = [SELECT Id, Name FROM Account WHERE Id = :opps.get(0).AccountId];

    TriggerHandler.bypass('AccountTriggerHandler');

    acc.Name = 'No Trigger';
    update acc; // won't invoke the AccountTriggerHandler

    TriggerHandler.clearBypass('AccountTriggerHandler');

    acc.Name = 'With Trigger';
    update acc; // will invoke the AccountTriggerHandler

  }

}
```

## Overridable Methods

Here are all of the methods that you can override. All of the context possibilities are supported.

* `beforeInsert()`
* `beforeUpdate()`
* `beforeDelete()`
* `afterInsert()`
* `afterUpdate()`
* `afterDelete()`
* `afterUndelete()`

## Modifications by Greg Hacic

These modificatiosn were introduced on 17 August 2015

### New Items
- Trigger_Status__c.object
- triggerUtil.cls
- triggerUtilTest.cls

Created the Trigger_Status__c Custom Setting object so that administrators / developers have the option of turning a trigger on or off without having to deploy any code.

In an effort to keep things clear to other developers, I created a new class for the logic that checks the trigger status as defined in the new Custom Setting object. That class is labeled `triggerUtil` and the tests for it are located in `triggerUtilTest.cls`.

### How to Use

#### Create a record for the Trigger

Create a new record in the Trigger_Status__c Custom Setting object.

1. Navigate to **Setup** > **Develop** > **Custom Settings**.
2. Click the **Manage** link located on the left-hand side of the Custom Setting reading **Trigger Status**.
3. Click the **New** button.
4. Provide a Name for the trigger, which should match the name you will use in the handler class, and check the box reading **Status**.

#### Modify the Trigger Handler Class

You will need to check the status of the trigger by calling the isTriggerOkayToRun method in the handler class. See below for an example

```java
public class opportunityTriggerHandler extends TriggerHandler {
	
	private Boolean isOkayToRun; //boolean denoting whether or not we should run the trigger logic
	private Map<Id, Opportunity> newRecordMap; //map of new records
	private Map<Id, Opportunity> oldRecordMap; //map of old records
	private List<Opportunity> newRecords; //list of new records
	private List<Opportunity> oldRecords; //list of old records
	
	//constructor
	public opportunityTriggerHandler() {
		isOkayToRun = triggerUtil.isTriggerOkayToRun('OpportunityTrigger'); //determine whether or not the trigger logic is okay to run > there should be a record with the Name = 'OpportunityTrigger' in the Trigger_Status__c Custom Setting
		newRecordMap = (Map<Id, Opportunity>)Trigger.newMap; //cast the map of new records
		newRecords = (List<Opportunity>)Trigger.new;  //cast the list of new records
		oldRecordMap = (Map<Id, Opportunity>)Trigger.oldMap; //cast the map of old records
		oldRecords = (List<Opportunity>)Trigger.old; //cast the list of old records
	}
	
	//override the afterInsert trigger context
	public override void afterInsert(){
		if (isOkayToRun) { //if it is okay to run the trigger
			for (Opportunity o : newRecords) { //for each new Opportunity record
				//do something...
			}
		}
	}

}
```

If there is no matching record in the Trigger_Status__c Custom Setting object corresponding to the trigger name then the trigger will fire.
