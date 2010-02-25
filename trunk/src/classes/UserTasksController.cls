/**
* @author Miguel Soares 
*/
public class UserTasksController{

    public Boolean showDetail { set; get; }
    public id currentUser;
    public Project currentProject { set; get; }
    public List<ProjectMember__c> allProjects;
    public Map<id,ProjectMember__c> allProjectsMap;
    public List<SelectOption> selectOpsProject;

    public String opSelected;
    public String attachmentPrjId;
    
    public Paginator paginator  { set; get; }
    
    
    /**
    * Constructor
    */
    public UserTasksController(){
        
        this.currentUser    = UserInfo.getUserId();
        //this.opSelected     = 'none'; 
        this.showDetail     = false;

        this.allProjects        = new List<ProjectMember__c>();
        this.allProjectsMap     = new Map<id,ProjectMember__c>();
        this.selectOpsProject   = new List<SelectOption>(); 
        
        this.paginator = new Paginator();
        
        this.paginator.orderBy      = 'Name';
        this.paginator.orderAsc     = true;
        this.paginator.filter       = '1'; // Show all tasks and milestones
        if( this.opSelected == null || this.opSelected == 'none' )
        	this.paginator.project.id   = '';
       // else 
        	//this.paginator.project.id   = this.opSelected;
        //this.opSelected == 'none' ? '' : this.opSelected; 
        //this.paginator.project.id = 'none';
        
        paginator.loadTasksByUser();
        
        this.selectAllProjectsName();
    }


    /**
    *@return attachmentPrjId
    */
    public String getAttachmentPrjId(){
        
        if( this.allProjects == null )
            selectProjectBasicData();
        
        return this.attachmentPrjId;
    }



    /**
    * @return List<SelectOption>
    */
    public List<SelectOption> getProjectSelectOps(){
        
        this.selectOpsProject.clear();
        ProjectMember__c c = this.allProjects[0].clone();       
        this.selectOpsProject.add( new SelectOption( 'none', 'All projects' ) );

        for( ProjectMember__c p : this.allProjects )
            if( p.Project__c != null )
            this.selectOpsProject.add( new SelectOption( (String)p.Project__c, p.Project__r.name ) );
            
        return this.selectOpsProject;
    }

    /**
    * @return opSelected
    */
    public String getOpSelected(){
        
        this.selectProjectBasicData();
        return this.opSelected;
    }
    
    /**
    * @param option
    */
    public void setOpSelected( String option ){
        
        System.debug( '[>>>] ' + option );
        
        this.opSelected = option;
        this.paginator.project.id = option == 'none' ? '' : option;
        this.showDetail = option != 'none';
                paginator.loadTasksByUser();
        
        this.selectProjectBasicData();
    }
    
    /**
    * 
    */
    public void selectProjectBasicData(){
        
        List<String> days               = new List<String>{'Mon', 'Thu', 'Wen', 'Thu', 'Fri', 'Sat', 'Sun'};
        this.currentProject             = new Project();
        ProjectMember__c tempProject    = new ProjectMember__c(); 
        
        if( this.allProjectsMap.size() > 0 && this.OpSelected != 'none' ){
            tempProject = this.allProjectsMap.get( this.OpSelected );
            
            this.AttachmentPrjId                        = tempProject.Project__r.Picture__c;
            this.currentProject.name                    = ProjectUtil.chopWords( tempProject.Project__r.name );
            this.currentProject.priority                = ProjectUtil.chopWords( tempProject.Project__r.priority__c );
            this.currentProject.displayDuration         = ProjectUtil.chopWords( tempProject.Project__r.DisplayDuration__c );
            this.currentProject.description             = ProjectUtil.chopWords( tempProject.Project__r.Description__c );
            if( tempProject.Project__r.DaysInWorkWeek__c == null )
            	this.currentProject.daysWorkWeekFormated = '-';
            else
            	this.currentProject.daysWorkWeekFormated    = 'Mon - ' + days[ Integer.valueOf( tempProject.Project__r.DaysInWorkWeek__c )-1]; 
        }
    }
    
    /**
    *
    */
    public void selectAllProjectsName(){
         this.allProjects = DAOFactory.getInstance().getProjetsInfoByMember( this.currentUser );   
         
         for( ProjectMember__c p : this.allProjects)
            this.allProjectsMap.put( p.project__c, p );
    }
}