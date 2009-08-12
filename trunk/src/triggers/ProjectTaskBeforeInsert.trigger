trigger ProjectTaskBeforeInsert on ProjectTask__c (before insert) {
    if (!ProjectUtil.currentlyExeTrigger) {
    	ProjectUtil.currentlyExeTrigger = true;
		try {		
		 	List<Id> tasksInTrrNewIds = new List<Id>();
			List<ProjectTask__c> parentTasks = new List<ProjectTask__c>();			
			List<String> projectSharingGroupNames = new List<String>();		
			
			for(ProjectTask__c p : Trigger.new) {
		 		tasksInTrrNewIds.add( p.ParentTask__c );
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
 		 			nTask.EndDate__c.addError( 'The Milestones can not have End Date.');
 		 			
 		 			if(nTask.ParentTask__c != null)
 		 			nTask.ParentTask__c.addError( 'The Milestones can not have Parent Task.');
 		 			
		 		} 
				if(queueId != null)
                    nTask.OwnerId = queueId;
			}
			
			parentTasks = [ select id, Project__c from ProjectTask__c where id in: tasksInTrrNewIds limit 1000];
			
		    ProjectTask__c tempPTOld = new ProjectTask__c();
		    ProjectTask__c tempPTNew = new ProjectTask__c();
		    for( Integer k = 0; k < Trigger.new.size(); k++ ){
		    	tempPTNew = Trigger.new.get( k );
	
				if( parentTasks.size() > 0 )
			    	if( tempPTNew.Project__c != parentTasks.get( k ).Project__c )
			    		tempPTNew.addError( 'Invalid parent task value.-');

		    } 	
		    
		    //TODO testing
			ProjectTaskDuration duration = new ProjectTaskDuration();
		    for( Integer j = 0; j < Trigger.new.size(); j++ ){
		
		    	tempPTNew = Trigger.new.get( j );		
		 		tempPTNew = duration.parseDuration(tempPTNew);
		 		System.debug('!!!----- valores : ' + tempPTNew.Duration__c);
		 		if(tempPTNew.Project__c != null){
		 			Project2__c project = [select Id, DisplayDuration__c, WorkingHours__c, DaysInWorkWeek__c 
								from Project2__c 
								where Id =: tempPTNew.Project__c];
								
					if(project.DisplayDuration__c.equals('Days')){
						tempPTNew.EndDate__c = duration.doCalculateEndDateInDays(tempPTNew, Integer.valueOf(project.DaysInWorkWeek__c));
					}
					else{
						tempPTNew.EndDate__c = duration.doCalculateEndDateInHours(tempPTNew, project);
					}	
    			}
		    } 
		    //TODO finish testing	
		    
		}
		finally{
			ProjectUtil.currentlyExeTrigger = false;
		}
    }
}