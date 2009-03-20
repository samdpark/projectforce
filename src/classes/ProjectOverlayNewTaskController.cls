/**
*@author Martin Prado @ 06/24/2008
* refactoring for project force
*/
public class ProjectOverlayNewTaskController {
	
    ProjectTask__c theNewTask = new ProjectTask__c();
   	
   	public String PROJECTID = System.currentPageReference().getParameters().get('id'); 
   	public Project2__c currentProject = null;   
   	
    /**
    * Constructor
    */
    public ProjectOverlayNewTaskController(){
    	getCurrentProject();	
    	genPermissions();
	}

   	/**
   	*@param String project id
   	*/
   	public void setProject (String projectId) {
   		this.PROJECTID = projectID;
   	}
   	
    public ProjectTask__c newProyect = new ProjectTask__c();
   	/**
    *@return ProjectTask__c
    */
    public ProjectTask__c getTask(){
    	return newProyect;
    }
    
	/**
	*@param ProjectTask__c
	*/    
    public void setTask(ProjectTask__c value){
    	newProyect = value;
    }
    

    public ProjectMember__c projectMember = new ProjectMember__c();    
    /**
    *@return ProjectMember__c
    */
    public ProjectMember__c getProjectMember(){
    	return projectMember;
    }
    
    /**
    *@param ProjectMember__c
    */
    public void setProjectMember(ProjectMember__c value){
    	projectMember = value;
    }
    
   	/**
   	*@return String
   	*/
   	public String getCurrentProjectId(){
   		return PROJECTID;
   	}
   	
    
    /**
    * Return members select options
    *@return List<SelectOption>
    */ 
	public List<SelectOption> getProjectMembers() {
    	List<ProjectMember__c> projectMembers = new List<ProjectMember__c>();  
  	 	List<SelectOption> options = new List<SelectOption>();
  	 	if(PROJECTID != null){
	  	 	projectMembers = [Select t.Project__c, t.User__r.Name, t.User__r.IsActive, t.Name, t.User__c, t.Id from ProjectMember__c t where t.Project__c =: PROJECTID and t.User__r.IsActive != false];  
	  	 	options.add(new SelectOption('-1', 'Choose a project Member'));
	  	 	for(ProjectMember__c c: projectMembers) {
    			options.add(new SelectOption(c.User__c, c.User__r.Name)); 
	 		}
  	 	}
  	 	return options;
   	}

	/**
	* Read Project for current project
	*/
	public void getCurrentProject(){   
		if(PROJECTID != null)
			currentProject = [select Id from Project2__c where Id =: PROJECTID limit 1];
	}
	
	/**
	* Refresh method
	*/
	/*
	public void refreshMethod(){
		TeamsWidgetTasksMainController twtmc = new TeamsWidgetTasksMainController();
		twtmc.getAllProjectTasks();
	}
	*/
	
	/**
	* For rerender use
	*/
	public void dummyRefresh (){}   
	
	public UserPermissions userPermissions = ProjectDetailController.userPermission.clone();
	/**
	* Read user permissions
	*/
	
	public void genPermissions () {
		userPermissions.setId(UserInfo.getUserId());
		userPermissions.setProject(PROJECTID);
		userPermissions.setObjectType('Project');
		userPermissions.setPermissions();		
	}
   	
   	/**
   	* Create new task
   	*@throws CustomException message Insufficient Privileges
   	*/
   	public void insertTask (){ 
   		if(!userPermissions.getCanCreate()){
        	throw new CustomException('Insufficient Privileges');
   		}else{	
   			newProyect.Milestone__c = false;
			newProyect.Project__c = PROJECTID;
			newProyect.Project__c = currentProject.Id;
			newProyect.PercentCompleted__c = 0.0;
			newProyect.Priority__c = 'Normal';
			insert newProyect; 

	  		ProjectAssignee__c Assign = new ProjectAssignee__c();
			Assign.User__c = projectMember.User__c;
			Assign.ProjectTask__c = newProyect.Id;
			insert Assign;
			newProyect = new ProjectTask__c();
			Assign = new ProjectAssignee__c();
   		}
   	}
   	class CustomException extends Exception{}
}