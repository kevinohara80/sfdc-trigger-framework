public virtual class TriggerHandler {

  // static map of handlername, times run() was invoked
  @TestVisible private static Map<String, LoopCount> loopCountMap;
  @TestVisible private static Set<String> bypassedHandlers;
  @TestVisible private static Boolean globalBypass;
  @TestVisible private static Boolean showLimits;

  // the current triggerEvent of the trigger, overridable in tests
  @TestVisible
  private System.TriggerOperation triggerEvent;

  // the current triggerEvent of the trigger, overridable in tests
  @TestVisible
  private Boolean isTriggerExecuting;

  // static initialization
  static {
    loopCountMap = new Map<String, LoopCount>();
    bypassedHandlers = new Set<String>();
    globalBypass = false;
    showLimits = false;
  }

  // constructor
  public TriggerHandler() {
    this.setTriggerContext();
  }

  public TriggerHandler(String handlerName) {
    this.handlerName = handlerName;
    this.setTriggerContext();
  }


  /***************************************
  * public instance methods
  ***************************************/

  // main method that will be called during execution
  public void run() {

    if(!validateRun()) {
      return;
    }

    addToLoopCount();

    // dispatch to the correct handler method
    switch on this.triggerEvent {
      when BEFORE_INSERT {
        this.beforeInsert();
      }
      when BEFORE_UPDATE {
        this.beforeUpdate();
      }
      when BEFORE_DELETE {
        this.beforeDelete();
      }
      when AFTER_INSERT {
        this.afterInsert();
      }
      when AFTER_UPDATE {
        this.afterUpdate();
      }
      when AFTER_DELETE {
        this.afterDelete();
      }
      when AFTER_UNDELETE {
        this.afterUndelete();
      }
    }

    if(showLimits) {
      System.debug(LoggingLevel.DEBUG, String.format('{0} on {1} ({2}/{3})', new List<String>{
        this.triggerEvent+'',
        getHandlerName(),
        Limits.getQueries()+'',
        Limits.getLimitQueries()+''
      }));
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

  public void clearMaxLoopCount() {
    this.setMaxLoopCount(-1);
  }

  /***************************************
  * public static methods
  ***************************************/

  // bypass by string, e.g. TriggerHandler.bypass('AccountTriggerHandler')
  public static void bypass(String handlerName) {
    TriggerHandler.bypassedHandlers.add(handlerName);
  }

  // bypass by list, e.g. TriggerHandler.bypass(listOfHandlerStrings)
  public static void bypass(List<String> handlersNames) {
    TriggerHandler.bypassedHandlers.addAll(handlersNames);
  }

  // bypass all handlers (clear bypassedHandlers to prevent confusion)
  public static void bypassAll() {
    TriggerHandler.bypassedHandlers.clear();
    globalBypass = true;
  }

  public static void clearBypass(String handlerName) {
    TriggerHandler.bypassedHandlers.remove(handlerName);
  }

  public static void clearBypass(List<String> handlersNames) {
    TriggerHandler.bypassedHandlers.removeAll(handlersNames);
  }

  // a handler is considered bypassed if it was bypassed, or all handlers have been
  public static Boolean isBypassed(String handlerName) {
    return (globalBypass || TriggerHandler.bypassedHandlers.contains(handlerName));
  }

  // return a list of the bypassed handlers
  public static List<String> bypassList() {
    List<String> bypasses = new List<String>(TriggerHandler.bypassedHandlers);

    // bypassAll clears bypassedHandlers, so bypasses is empty here
    if(globalBypass) {
      bypasses.add('bypassAll');
    }

    return bypasses;
  }

  public static void clearAllBypasses() {
    if(globalBypass) {
      globalBypass = false;
    } else {
      TriggerHandler.bypassedHandlers.clear();
    }
  }

  // handle limits
  public static void showLimits() {
    showLimits(true);
  }

  public static void showLimits(Boolean enabled) {
    showLimits = enabled;
  }

  public static Integer getLoopCount(String handlerName) {
    if(TriggerHandler.loopCountMap.containsKey(handlerName)) {
      return TriggerHandler.loopCountMap.get(handlerName).getCount();
    }
    return 0;
  }

  /***************************************
  * private instancemethods
  ***************************************/

  /**
   * @description Base method called by constructor
   */
  @TestVisible
  private void setTriggerContext() {
    this.setTriggerContext(Trigger.operationType, false);
  }

  @TestVisible
  private void setTriggerContext(System.TriggerOperation opType, Boolean testMode) {

    if(!Trigger.isExecuting && !testMode) {
      this.isTriggerExecuting = false;
      return;
    } else {
      this.isTriggerExecuting = true;
    }

    if(Trigger.isExecuting && !testMode){
      this.triggerEvent = Trigger.operationType;
    }
    if(opType == null){
      opType = Trigger.operationType;
    }
    String context = opType.name();

    switch on context {
      when 'BEFORE_INSERT'{
        this.triggerEvent = System.TriggerOperation.BEFORE_INSERT;
      }
      when 'BEFORE_UPDATE'{
        this.triggerEvent = System.TriggerOperation.BEFORE_UPDATE;
      }
      when 'BEFORE_DELETE'{
        this.triggerEvent = System.TriggerOperation.BEFORE_DELETE;
      }
      when 'AFTER_INSERT'{
        this.triggerEvent = System.TriggerOperation.AFTER_INSERT;
      }
      when 'AFTER_UPDATE'{
        this.triggerEvent = System.TriggerOperation.AFTER_UPDATE;
      }
      when 'AFTER_DELETE'{
        this.triggerEvent = System.TriggerOperation.AFTER_DELETE;
      }
      when 'AFTER_UNDELETE'{
        this.triggerEvent = System.TriggerOperation.AFTER_UNDELETE;
      }
    }
  }

  // increment the loop count
  @TestVisible
  private void addToLoopCount() {
    String handlerName = getHandlerName();
    if(TriggerHandler.loopCountMap.containsKey(handlerName)) {
      Boolean exceeded = TriggerHandler.loopCountMap.get(handlerName).increment();
      if(exceeded) {
        Integer max = TriggerHandler.loopCountMap.get(handlerName).max;
        throw new TriggerHandlerException('Maximum loop count of ' + String.valueOf(max) + ' reached in ' + handlerName);
      }
    }
  }

  // make sure this trigger should continue to run
  @TestVisible
  private Boolean validateRun() {
    if(!this.isTriggerExecuting || this.triggerEvent == null) {
      throw new TriggerHandlerException(errorOutsideTriggerContext);
    }
    return (!globalBypass && !TriggerHandler.bypassedHandlers.contains(getHandlerName()));
  }

  @TestVisible
  private String getHandlerName() {
    if(String.isBlank(this.handlerName)) {
      this.handlerName = String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
    }
    return this.handlerName;
  }

  private String handlerName;

  /***************************************
  * triggerEvent methods
  ***************************************/

  // triggerEvent-specific methods for override
  @TestVisible
  protected virtual void beforeInsert(){}
  @TestVisible
  protected virtual void beforeUpdate(){}
  @TestVisible
  protected virtual void beforeDelete(){}
  @TestVisible
  protected virtual void afterInsert(){}
  @TestVisible
  protected virtual void afterUpdate(){}
  @TestVisible
  protected virtual void afterDelete(){}
  @TestVisible
  protected virtual void afterUndelete(){}

  /***************************************
  * inner classes
  ***************************************/

  // inner class for managing the loop count per handler
  @TestVisible
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

    public Boolean increment() {
      this.count++;
      return this.exceeded();
    }

    public Boolean exceeded() {
      return this.max >= 0 && this.count > this.max;
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

  // Error text
  @TestVisible
  private static String errorOutsideTriggerContext = 'Trigger handler called outside of Trigger execution';
}