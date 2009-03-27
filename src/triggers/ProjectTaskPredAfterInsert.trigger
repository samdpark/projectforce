trigger ProjectTaskPredAfterInsert on ProjectTaskPred__c (after insert) {
	
	try {
        
        List<String> teamSharingGroupNames = new List<String>();		
		for(ProjectTaskPred__c p : Trigger.new) {
			teamSharingGroupNames.add('projectSharing' + p.Project__c);
		}
		
		Map<String, Id> teamMap = new Map<String, Id>();					
		for(Group g: [select id, name from Group where Name in: teamSharingGroupNames]) {
			teamMap.put(g.Name, g.Id);
		}
		
		
		List<ProjectTaskPred__Share> taskpred = new List<ProjectTaskPred__Share>();
		for(ProjectTaskPred__c m : Trigger.new) {
			
			ProjectTaskPred__Share p = new ProjectTaskPred__Share();
			p.ParentId = m.Id;							
			p.UserOrGroupId = teamMap.get('projectSharing' + m.Project__c);
		    p.AccessLevel = 'Read';
		    p.RowCause = 'Manual';
		    taskpred.add(p);
		}
		
		insert taskpred;
		
	} finally {
    }  
}