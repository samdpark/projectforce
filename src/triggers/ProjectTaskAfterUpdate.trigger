trigger ProjectTaskAfterUpdate on ProjectTask__c (after update) 
{
	// Send email to subscribers members
	ProjectSubscribersEmailServices pEmail = new ProjectSubscribersEmailServices();
	List<String> lstPTId = new List<String>();
    for ( ProjectTask__c pT : Trigger.new ){
    	lstPTId.add(pT.id);
    }
    pEmail.sendMailForTaskChanged( lstPTId );
}