public with sharing class TaskDependencies {

	BigListOfTask bL = new BigListOfTask('SELECT Id, name, StartDate__c, EndDate__c FROM ProjectTask__c');
	BigListOfTaskPredecessors bLP;// = new BigListOfTaskPredecessors();

	List<ProjectTaskPred__c> relsList = new List<ProjectTaskPred__c>();
	BigListOfTask taskList = new BigListOfTask();

	ProjectTask__c task = new ProjectTask__c();
	ProjectTaskPred__c pred = new ProjectTaskPred__c();
	ProjectTask__c predTask = new ProjectTask__c();

	public TaskDependencies(){}
	
	public void setProps( Id projectId ){
		this.bLP = new BigListOfTaskPredecessors( projectId );
		System.debug('[3>>> bL' + this.bL.size() + 'bLP' + this.bLP.size() + '-' + this.bLP.get(0).Predecessor__c);
	}

	BigListOfTaskPredecessors relsToModify = new BigListOfTaskPredecessors();
	BigListOfTask tasksToModify = new BigListOfTask();	
	List<ProjectTaskPred__c> rListAux = new List<ProjectTaskPred__c>();
	Integer daysBt = 0;
	
	// Aux method
	public Boolean taskAndRelsToModify( ProjectTask__c oldTask ){
		Boolean someTasksMustBeModify = false;
		for( ProjectTaskPred__c p : this.rListAux ){
			if( p.Lag_Time__c < daysBt ){
				p.Lag_Time__c = 0;
				someTasksMustBeModify = true;
				this.tasksToModify.add(this.bL.getById(p.Parent__c));
			}else
				p.Lag_Time__c = p.Lag_Time__c - this.daysBt;
			this.relsToModify.add( p );
		}		
		return someTasksMustBeModify;
	}
	
	public void modifyStartOrEndDate( ProjectTask__c oldTask, ProjectTask__c newTask ){

		this.task = oldTask;
		this.pred = bLP.getByParentId( oldTask.id );
		this.predTask = bL.getById( pred.Predecessor__c );		
		this.daysBt = newTask.StartDate__c.daysBetween( oldTask.StartDate__c );

		// Start to atart
		if( this.pred.Lag_Type__c == 'Start-to-Start'  && oldTask.StartDate__c != newTask.StartDate__c ){
			if( this.canModifySToS( newTask.StartDate__c )){
				this.rListAux = this.bLP.getListPred( newTask.id, 'Start-to-Start' ); 
				Integer daysBt = newTask.StartDate__c.daysBetween( oldTask.StartDate__c );
				//this.daysBt = Math.abs(Date.valueOf('2009-09-21 00:00:00').daysBetween( oldTask.StartDate__c ));
				Integer ind = 0;
				Boolean fu = this.taskAndRelsToModify( this.task ); 
				while(fu){
					this.rListAux.clear(); 
					this.task = tasksToModify.get( ind );
					this.rListAux = this.bLP.getListPred( tasksToModify.get( ind ).id, 'Start-to-Start' );
					ind++;
					fu = this.taskAndRelsToModify( this.task ); 
				}
			}else{
				throw new CustomException('We have a problem Hustonforce');
			}   
		}
		
		System.debug( '[>] ' + this.tasksToModify.size());
		this.relsToModify.updateNow();
		this.tasksToModify.updateNow();
		
	}
	
	public Boolean canModifySToS( Date newStartDate ){
		System.debug('1>> ' + this.predTask.name + '=' + this.predTask.StartDate__c +' :: '+ newStartDate);
		return this.predTask.StartDate__c <= newStartDate;
	} 

	public void genTaskWithRels(){
		for( ProjectTaskPred__c ptp : this.relsList)
			this.taskList.add( bL.getById( ptp.Parent__c ));
	}
	
	public void gentRelList( Id taskId ){
		Integer ind = 0;
		relsList = this.bLP.getListPred( taskId, 'Start-to-Start' );
		
		while( ind < relsList.size()){
			relsList.addAll( this.bLP.getListPred( relsList[ ind ].Parent__c, 'Start-to-Start' ));
			ind++;
		}
	}

	public class BigListOfTask{
		List<ProjectTask__c> bList = new List<ProjectTask__c>();
		Map<Id, ProjectTask__c>  bMap = new Map<Id, ProjectTask__c>();
		public bigListOfTask(){}
		 
		public bigListOfTask( String soql ){
			for( ProjectTask__c pT : Database.query( soql ))
				if( this.bList.size() < 1000 ){
					this.bList.add( pT );
					this.bMap.put( pT.id, pT);
				}
		}		
		
		public ProjectTask__c get( Integer i){
			return this.bList.get( i );
		}
		
		public ProjectTask__c getById( Id i){
			return this.bMap.get( i );
		}
		
		public void add( ProjectTask__c pT ){	
			this.bList.add( pT );
			this.bMap.put( pT.Id, pT );
		}
		
		public Integer size(){
			return this.bList.size();
		}

		public void updateNow(){
			ProjectUtil.setTaskDependenciesFlag( true );
			update this.bList;
		}
		public void debugg( String token ){
			System.debug('\n\n' + token + '\n\n');
			System.debug('Size -->' + this.size() + '\n\n');
			System.debug('List --> ' + this.bList );
		}
	}

	public class BigListOfTaskPredecessors{

		List<ProjectTaskPred__c> bList = new List<ProjectTaskPred__c>();
		Map<id, ProjectTaskPred__c> bMap   = new Map<id, ProjectTaskPred__c>();

		public BigListOfTaskPredecessors(){}
		
		public BigListOfTaskPredecessors( Id projectId ){
			for( ProjectTaskPred__c pT : [ SELECT Id, Project__c, Parent__c, Predecessor__c, Lag_Time__c, Lag_Type__c, Lag_Unit__c FROM ProjectTaskPred__c WHERE Project__c =: projectId ])
				if( this.bList.size() < 1000 )
				this.bList.add( pT );
		}		
		
		public ProjectTaskPred__c get( Integer i ){
			ProjectTaskPred__c rPred = new ProjectTaskPred__c();
			
			if(this.size() > 0)
			rPred = this.bList.get( i );
			
			return rPred;
		}
		
		public ProjectTaskPred__c getByParentId( Id parentId ){
			Integer k = 0;
			ProjectTaskPred__c rTask = new ProjectTaskPred__c();
			while( k < this.size()){
				if(this.bList[ k ].Parent__c == parentId){
					rTask = this.get(k);
					break;
				}
				k++;
			}
			return rTask;
		}
		
		public List<ProjectTaskPred__c> getListPred( Id predecessor, String typeRel ){
			List<ProjectTaskPred__c> rList = new List<ProjectTaskPred__c>();
			for(ProjectTaskPred__c ptp : this.bList)
				if( ptp.Predecessor__c == predecessor && ptp.Lag_Type__c == typeRel )
				rList.add( ptp );
				
			return rList;
		}
		
		public void add( ProjectTaskPred__c pT ){	
			this.bList.add( pT );
		}

		public void addAll( List<ProjectTaskPred__c> pTList ){	
			this.bList.addAll( pTList );
		}
		
		public Integer size(){
			return this.bList.size();
		}
		
		public void clear(){
			this.bList.clear();
		}
		
		public void updateNow(){
			ProjectUtil.setTaskDependenciesFlag( true );
			update this.bList;
		}

		public void debugg( String token ){
			System.debug('\n\n' + token + '\n\n');
			System.debug('Size -->' + this.size() + '\n\n');
			System.debug('List --> ' + this.bList );
		}
	}
}