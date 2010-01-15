public class TaskListController {
	
	public List<Task> 	tasks 			;	
	
	public String 	projectId 			{ set; get; }
	
	public String 	url 				{ set; get; }
	
	public Project 	project 			{ set; get; }
	
	public Project 	exceptionMessage 	{ set; get; }
	
	public String filter 				{ set; get; } //param to show all tasks by default
	
	public String orderBy 				{ set; get; }
	
	public Boolean orderAsc 			{ set; get; }
	
	public Paginator paginator 			{ set; get; }
	
	public TaskListController(){
		
		this.tasks = new List<Task>();
		
		this.projectId = System.currentPageReference().getParameters().get('id');
		
		if(this.projectId==null || this.projectId==''){
			throw new CustomException('There is not a project selected');
		}
		
		this.project = new Project(projectId);
		
		this.url = ProjectUtil.getUrl();
		
		this.filter = '1'; 
		
		this.orderBy = 'Name';
		
		this.orderAsc = true;
		
		//this.paginator = new Paginator('Tasks');
		
		this.paginator = new Paginator();
		
		this.paginator.orderBy = this.orderBy;
		
		this.paginator.filter = this.filter;
		
		this.paginator.orderAsc = this.orderAsc;
		
		this.paginator.project.id = this.projectId;
		
		//refreshTasksByProject();
		
		paginator.loadTasksByProject();
		
	}
	
	public List<Task> getTasks(){
		
		return paginator.getTasksByProject();
	}
	
	public void refreshTasksByProject(){
		
		this.paginator.orderBy = this.orderBy;
		
		this.paginator.filter = this.filter;
		
		this.paginator.orderAsc = this.orderAsc;
		
		this.paginator.project.id = this.projectId;
	
		paginator.refreshTasksByProject();
	}
	
	public void refreshPaginator(){
		
		paginator.refreshPaginator();
		
		paginator.setPageNumber(1);
	}
	
	public List<SelectOption> getFilterItems() {
		
		List<SelectOption> options = new List<SelectOption>();
		
		options.add(new SelectOption('1','All tasks'));
		
		options.add(new SelectOption('2','All milestones'));
		
		options.add(new SelectOption('3','My tasks'));
		
		options.add(new SelectOption('4','Completed tasks'));
		
		options.add(new SelectOption('5','Overdue tasks'));
		
		options.add(new SelectOption('6','Overdue milestones'));
		
		return options;
	}
	
	public void generateCSV(){
	
	}
	
	public void orderById(){
		
		this.orderAsc = !this.orderAsc;
		
		this.orderBy = 'Id__c';
		
		refreshTasksByProject();
		
	}
	
	public void orderByPriority(){
		
		this.orderAsc = !this.orderAsc;
		
		this.orderBy = 'Priority__c';
		
		refreshTasksByProject();
	
	}
	
	public void orderByName(){
		
		this.orderAsc = !this.orderAsc;
		
		this.orderBy = 'Name';
		
		refreshTasksByProject();
	
	}
	
	public void orderByCompletedPercentage(){
		
		this.orderAsc = !this.orderAsc;
		
		this.orderBy = 'PercentCompleted__c';
		
		refreshTasksByProject();
	
	}
	
	public void orderByDuration(){
		
		this.orderAsc = !this.orderAsc;
		
		this.orderBy = 'Duration__c';
		
		refreshTasksByProject();
	
	}
	
	public void orderByEndDate(){
		
		this.orderAsc = !this.orderAsc;
		
		this.orderBy = 'EndDate__c';
		
		refreshTasksByProject();
	
	}
	
}