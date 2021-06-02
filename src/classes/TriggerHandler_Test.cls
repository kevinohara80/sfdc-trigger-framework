public virtual class TriggerHandler {
    @TestVisible
    private Boolean testMode = false;
    private System.TriggerOperation triggerEvent;
    private static Map<String, LoopCount> loopCountByTrigerHandlerName = new Map<String, LoopCount>();
    private static Set<String> bypassedHandlers = new Set<String>();
    
    public TriggerHandler(System.TriggerOperation triggerEvent) {
        this.triggerEvent = triggerEvent;
    }
    
    // main method that will be called during execution
    public void run() {
        if(!validateRun()) {
            return;
        }
        addToLoopCount();
        switchOnTriggerEvent();
    }

    @TestVisible
    private Boolean validateRun() {
        if(!Trigger.isExecuting && !testMode) {
            throw new TriggerHandlerException('Trigger handler called outside of Trigger execution');
        }
        return !TriggerHandler.bypassedHandlers.contains(getHandlerName());
    }

    @TestVisible
    private void addToLoopCount() {
        String handlerName = getHandlerName();
        if(TriggerHandler.loopCountByTrigerHandlerName.containsKey(handlerName)) {
            Boolean exceeded = TriggerHandler.loopCountByTrigerHandlerName.get(handlerName).increment();
            if(exceeded) {
                Integer max = TriggerHandler.loopCountByTrigerHandlerName.get(handlerName).max;
                throw new TriggerHandlerException('Maximum loop count of ' + String.valueOf(max) + ' reached in ' + handlerName);
            }
        }
    }
    
    @TestVisible
    private String getHandlerName() {
        return String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
    }
    
    public void switchOnTriggerEvent() {
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
    }
    
    public void setMaxLoopCount(Integer max) {
        String handlerName = getHandlerName();
        if(!TriggerHandler.loopCountByTrigerHandlerName.containsKey(handlerName)) {
            TriggerHandler.loopCountByTrigerHandlerName.put(handlerName, new LoopCount(max));
        } else {
            TriggerHandler.loopCountByTrigerHandlerName.get(handlerName).setMax(max);
        }
    }
    
    public void clearMaxLoopCount() {
        this.setMaxLoopCount(-1);
    }
    
    //public static methods
    public static void bypass(String handlerName) {
        TriggerHandler.bypassedHandlers.add(handlerName);
    }
    
    public static void clearBypass(String handlerName) {
        TriggerHandler.bypassedHandlers.remove(handlerName);
    }
    
    public static Boolean isBypassed(String handlerName) {
        return TriggerHandler.bypassedHandlers.contains(handlerName);
    }
    
    public static void clearAllBypasses() {
        TriggerHandler.bypassedHandlers.clear();
    }
    
    // context-specific methods for override
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
    
}
