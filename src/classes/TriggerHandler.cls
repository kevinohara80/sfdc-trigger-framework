public virtual class TriggerHandler {
	
  public TriggerHandler() {

  }

  public void run() {

    // throw an exception if the trigger handler is called when a trigger 
    // is not executing
    if(!Trigger.isExecuting) {
      throw new TriggerHandlerException('Trigger handler called outside of Trigger execution');
    }

    // dispatch to the correct handler method
    if(Trigger.isBefore && Trigger.isInsert) {
      this.beforeInsert();
    } else if(Trigger.isBefore && Trigger.isUpdate) {
      this.beforeUpdate();
    } else if(Trigger.isBefore && Trigger.isDelete) {
      this.beforeDelete();
    } else if(Trigger.isAfter && Trigger.isInsert) {
      this.afterInsert();
    } else if(Trigger.isAfter && Trigger.isUpdate) {
      this.afterUpdate();
    } else if(Trigger.isAfter && Trigger.isDelete) {
      this.afterDelete();
    } else if(Trigger.isAfter && Trigger.isUndelete) {
      this.afterUndelete();
    }
  }

  // context-specific methods for override
  protected virtual void beforeInsert(){}
  protected virtual void beforeUpdate(){}
  protected virtual void beforeDelete(){}
  protected virtual void afterInsert(){}
  protected virtual void afterUpdate(){}
  protected virtual void afterDelete(){}
  protected virtual void afterUndelete(){}

  // utility exception class
  public class TriggerHandlerException extends Exception {}

}