# SFDC trigger framework

I know, I know. There are tons. But this one is mine.

## Overview

Triggers should (IMO) be logicless. Putting logic into your triggers creates un-testable, difficult-to-maintain code. It's widely accepted that a best-practice is to move trigger logic into a handler class.

This trigger framework bundles a single **TriggerHandler** base class that you can inherit from in all of your trigger handlers. The base class includes context-specific methods that are automatically called when a trigger is executed.

## Usage

To use a trigger handler, you only need to construct an instance of your trigger handler and call the `run()` method. Here is an example of an Opportunity trigger.

```java
trigger OpportunityTrigger on Opportunity (before insert, before update) {
  new OpportunityTriggerHandler().run();
}
```

In your trigger handler, to add logic to any of these contexts you only need to override them in your trigger handler. Here is how we would add logic to a `beforeUpdate` trigger.

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

Here are all of the methods that you can override. All of the context possibilities are supported.

* `beforeInsert()`
* `beforeUpdate()`
* `beforeDelete()`
* `afterInsert()`
* `afterUpdate()`
* `afterDelete()`
* `afterUndelete()`



