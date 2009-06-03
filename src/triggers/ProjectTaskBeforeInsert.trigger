trigger ProjectTaskBeforeInsert on ProjectTask__c (before insert) {
    if (!ProjectUtil.currentlyExeTrigger) {
    	ProjectUtil.currentlyExeTrigger = true;
		try {		
			
			List<String> projectSharingGroupNames = new List<String>();		
			for(ProjectTask__c p : Trigger.new) {
				projectSharingGroupNames.add('Project' + p.Project__c);
			}
			
			Map<String, Id> projectMap = new Map<String, Id>();			
			for(Group g: [select Id, name from Group where Name in: projectSharingGroupNames]) {
				projectMap.put(g.Name, g.Id);
			}

			for(ProjectTask__c nTask : Trigger.new) {
				String queueId = projectMap.get('Project' + nTask.Project__c);
				if(nTask.Milestone__c){
		 			
		 			if(nTask.EndDate__c != null)
		 			{
		 				nTask.EndDate__c.addError( 'The Milestones can not have End Date.');
		 			}
		 			if(nTask.ParentTask__c != null)
		 			{
		 				nTask.ParentTask__c.addError( 'The Milestones can not have Parent Task.');
		 			}
		 			
		 		} 
				if(queueId != null){
                    nTask.OwnerId = queueId;
				}			
			}
		}
		finally{
			ProjectUtil.currentlyExeTrigger = false;
		}
    }
}