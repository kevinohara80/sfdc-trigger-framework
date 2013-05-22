public class OpportunityTriggerHandler extends TriggerHandler {

  /****************************************
   * context method overrides
   ****************************************/

  protected override void beforeInsert() {
    runValidations();
  } 

  protected override void afterInsert() {
    //
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