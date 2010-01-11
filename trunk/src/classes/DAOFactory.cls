//singleton class
public class DAOFactory {
	
	private static DAOFactory instance;
	private DAOTask DAOTask;
	private DAOMember DAOMember;
	private DAOProject DAOProject;
	private DAOSubscription DAOSubscription;
	private DAOTaskPredecessor DAOTaskPredecessor;
	private DAOTaskComment DAOTaskComment;
	private DAOAttachment DAOAttachment;
	private DAOAssignee DAOAssignee;
	private DAOActivity DAOActivity;
	
	public static DAOFactory getInstance(){
		
		if(instance == null){
			
			instance = new DAOFactory();
		}
		
		return instance;
	}
	
	private DAOFactory(){
		this.DAOTask = new DAOTask();
		this.DAOMember = new DAOMember();
		this.DAOProject = new DAOProject();
		this.DAOSubscription = new DAOSubscription();
		this.DAOTaskPredecessor = new DAOTaskPredecessor();
		this.DAOTaskComment = new DAOTaskComment();
		this.DAOAttachment = new DAOAttachment();
		this.DAOAssignee = new DAOAssignee();
		this.DAOActivity = new DAOActivity();
	}
	
	/*-------------------------------------------------- Task operations ---------------------------------------------------------*/
	
	public void insertTask(String name, String startDate, String dueDate, String duration, String assignTo, String projectId, Boolean isMilestone){
		
		DAOTask.insertTask(name, startDate, dueDate, duration, assignTo, projectId, isMilestone);
	}
	
	public void updateTask(ProjectTask__c task){
		
		DAOTask.updateTask(task);
	}
	
	public void deleteTasks(String tasks){
		
		DAOTask.deleteTasks(tasks);
	}
	
	public ProjectTask__c getTask(String id){
		
		return DAOTask.get(id);
	}

	public List<Task> getTasksByProject(String projectId, String filter, String orderBy, Boolean orderAsc, Integer listIndex, Integer quantity){
		
		return DAOTask.getByProject(projectId, filter, orderBy, orderAsc, listIndex, quantity);
	}
	
	public List<ProjectTask__c> getTasks(String tasksIds){ 
		
		return DAOTask.getTasks(tasksIds);
	}
	
	/* End of Task operations */
	
	/*--------------------------------------------------- Member operations -------------------------------------------------------*/
	
	public List<ProjectMember__c> getProjectMembers(String projectId){
		return DAOProject.getMembers(projectId);
	}
	
	public Boolean isCRMAdministrator(){ return DAOMember.isCRMAdministrator(); }
	
	/* End of Member operations */
	
	/*--------------------------------------------------- Assignee operation ------------------------------------------------------*/
	
	public void insertAssignee(String taskId, String assignTo, String projectId){
		DAOAssignee.insertAssignee(taskId, assignTo, projectId);
	}
	
	public Boolean isTaskAssigned(ProjectTask__c task){return DAOAssignee.isTaskAssigned(task); }
	
	public List<ProjectMember> getAssignees(String taskId){return DAOAssignee.getAssignees(taskId); }
	
	/* End Assignee operation */
	
	/*--------------------------------------------------- Project operations ------------------------------------------------------*/
	
	public Project2__c getProjectInfo(String projectid){
		return DAOProject.getInfo(projectId);
	}
	
	public Boolean isProjectAdministrator(String projectId){return DAOProject.isProjectAdministrator(projectId); }
	
	/* End of Project operations */
	
	/*--------------------------------------------------- Activity Log operations ------------------------------------------------------*/
	
	public void logProjectActivity(String projectId, DateTime timeStamp, String modifiedBy, String action, String name, String access){
		DAOActivity.logProjectActivity(projectId, timeStamp, modifiedBy, action, name, access);
	}
	
	public void logMemberActivity(String projectId, DateTime timeStamp, String modifiedBy, String action){
	}
	
	public void logTaskCommentActivity(String projectId, DateTime timeStamp, String modifiedBy, String action){
	}
	
	public void logTaskAssigneeActivity(String projectId, DateTime timeStamp, String modifiedBy, String action){
	}
	
	public void logTaskActivity(String projectId, DateTime timeStamp, String modifiedBy, String action){
	}
	
	public void logAttachmentActivity(String projectId, DateTime timeStamp, String modifiedBy, String action){
	}
	
	/* End of Activity operations */
}