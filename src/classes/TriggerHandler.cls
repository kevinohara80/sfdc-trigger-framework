public virtual class TriggerHandler {

  // static map of handlername, times run() was invoked
  public static Map<String, LoopCount> loopCountMap;

  static {
    loopCountMap = new Map<String, LoopCount>();
  }
	
  public TriggerHandler() {

  }

  // main method that will be called during execution
  public void run() {

    validateRun();

    addToLoopCount();

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

  public void setMaxLoopCount(Integer max) {
    String handlerName = getHandlerName();
    if(!TriggerHandler.loopCountMap.containsKey(handlerName)) {
      TriggerHandler.loopCountMap.put(handlerName, new LoopCount(max));
    } else {
      TriggerHandler.loopCountMap.get(handlerName).setMax(max);
    }
  }

  private void addToLoopCount() {
    String handlerName = getHandlerName();
    if(TriggerHandler.loopCountMap.containsKey(handlerName)) {
      Boolean exceeded = TriggerHandler.loopCountMap.get(handlerName).inc();
      if(exceeded) {
        Integer max = TriggerHandler.loopCountMap.get(handlerName).max;
        throw new TriggerHandlerException('Maximum loop count of ' + String.valueOf(max) + ' reached in ' + handlerName);
      }
    }
  }

  // make sure this trigger should continue to run
  private void validateRun() {
    if(!Trigger.isExecuting) {
      throw new TriggerHandlerException('Trigger handler called outside of Trigger execution');
    }
  }

  private String getHandlerName() {
    return String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
  }

  // context-specific methods for override
  protected virtual void beforeInsert(){}
  protected virtual void beforeUpdate(){}
  protected virtual void beforeDelete(){}
  protected virtual void afterInsert(){}
  protected virtual void afterUpdate(){}
  protected virtual void afterDelete(){}
  protected virtual void afterUndelete(){}

  // inner class for managing the loop count per handler
  private class LoopCount {
    private Integer max;
    private Integer count;

    public LoopCount() {
      this.max = 5;
      this.count = 0;
    }

    public LoopCount(Integer max) {
      this.max = max;
      this.count = 0;
    }

    public Boolean inc() {
      this.count++;
      if(this.count <= max) return false;
      return true; 
    }

    public Integer getMax() {
      return this.max;
    }

    public Integer getCount() {
      return this.count;
    }

    public void setMax(Integer max) {
      this.max = max;
    }
  }

  // exception class
  public class TriggerHandlerException extends Exception {}

}