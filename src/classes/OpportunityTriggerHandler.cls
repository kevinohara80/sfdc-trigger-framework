public class OpportunityTriggerHandler extends TriggerHandler {

  public OpportunityTriggerHandler() {
    this.setMaxLoopCount(5);
  }

  /****************************************
   * context method overrides
   ****************************************/

  protected override void beforeInsert() {
    runValidations();
  } 

  protected override void afterUpdate() {
    List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE Id IN :Trigger.newMap.keyset()];
    update opps;
  }

  /****************************************
   * private processing methods
   ****************************************/

  private void runValidations() {
    for(Opportunity o : (List<Opportunity>) Trigger.new) {
      if(o.Amount < 1000) {
        o.Amount.addError('Opportunities must be over $1000!');
      }
    }
  }

}