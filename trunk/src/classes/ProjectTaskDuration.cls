/**
*@author: Nicolas Gunther - July 9, 2009
*/
public class ProjectTaskDuration {

	/**
	* Class constructor
	*/
	public ProjectTaskDuration (){
	}

	/**
	* Calculate task end date
	*@param task instance
	*@return task instance with new end date
	*/
	public ProjectTask__c doCalculateEndDate (ProjectTask__c task){
		
    	if(task.Project__c != null){

			Project2__c project = [select Id, DisplayDuration__c, WorkingHours__c, DaysInWorkWeek__c from Project2__c where Id =: task.Project__c];

			if(project.DisplayDuration__c.equals('Days')){
				task.EndDate__c = this.doCalculateEndDateInDays(task, Integer.valueOf(project.DaysInWorkWeek__c));
			}else{
				task.EndDate__c = this.doCalculateEndDateInHours(task, project);
			}	

    	}
    	return task; 
	}
	
	/**
	* Calulate duration with start and end date
	*@param task start date
	*@param task end data
	*@retrun duration
	*/
	public ProjectTask__c doCalculateDuration (ProjectTask__c task){
		
		Integer days;
		Integer duration;
		
		if(task.Project__c != null){
			
			Project2__c project = [select Id, DisplayDuration__c, WorkingHours__c, DaysInWorkWeek__c from Project2__c where Id =: task.Project__c];		
			
			days = this.doExcludeNonWorkingDays(task.StartDate__c, task.EndDate__c, Integer.valueOf(project.DaysInWorkWeek__c));
			
			if(project.DisplayDuration__c.equals('Days')){
				duration = days;
			}else{
				duration = (Decimal.valueOf(days * project.WorkingHours__c).round(System.Roundingmode.CEILING).intValue());
			}			
 
			System.debug('ROCK> ' + duration);
			task.Duration__c = duration;
		
		}	
		return task;

	}	
	
	/**
	* Calculate EndDate from Duration field in Days
	*@param task instance
	*@param number of work days
	*@retrun task end date
	*/
	public Date doCalculateEndDateInDays (ProjectTask__c task, Integer wdays){
	
		Integer days = task.Duration__c.intValue();
		return this.doExcludeNonWorkingDays(task.StartDate__c, wdays, days);
	
	}
	
	/**
	*@param task instance
	*@param project instance
	*@return task end date
	*/
	public Date doCalculateEndDateInHours(ProjectTask__c task, Project2__c project){
		
		Integer hours = project.WorkingHours__c.intValue();
		Integer wdays = Integer.valueOf(project.DaysInWorkWeek__c);
		Integer days = (Decimal.valueOf(task.Duration__c / hours).round(System.Roundingmode.CEILING).intValue());		
		return this.doExcludeNonWorkingDays(task.StartDate__c, wdays, days);
	
	}
	
	/**
	* Get work week days
	*@param number of workdays
	*@return work days names
	*/
	public Set<String> getWorkDays(Integer days){
		List<String> weekdays = new List<String>{'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'};
		Set<String> workdays = new Set<String>();
		
		for(Integer i = 0; i < days; i++){
			workdays.add(weekdays[i]);	
		}
		
		return workdays;
	}
	
	/**
	* Exclude non working days and retrun end date
	*@param task start date
	*@param working days
	*@param duration in days
	*@return task end date
	*/
	public Date doExcludeNonWorkingDays (Date startDate, Integer wdays, Integer days){
		
		Set<String> workdays = this.getWorkDays(wdays);
		Datetime myDate = Datetime.valueOf(startDate + '00:00:00');
		String weekday = '';		
		
		for(Integer i = 0; i < days; i++){
			weekday = myDate.format('EEE');
			if(!workdays.contains(weekday))
				days++;
			myDate = myDate.addDays(1);
		}
		return Date.newInstance(myDate.year(), myDate.month(), (myDate.day() - 1));	
	}
	
	/**
	* Exclude non working days and retrun duration (in days)
	*@param task start date
	*@param task end date
	*@param working days
	*@return task duration in days
	*/
	public Integer doExcludeNonWorkingDays (Date startDate, Date endDate, Integer wdays){
		
		Set<String> workdays = this.getWorkDays(wdays);
		Datetime myDate = Datetime.valueOf(startDate + '00:00:00');
		Integer days = 1;
		String weekday = '';
		
		while(!myDate.isSameDay(Datetime.valueOf(endDate + '00:00:00'))){
			weekday = myDate.format('EEE');
			if(workdays.contains(weekday))
				days++;
			myDate = myDate.addDays(1);
		}
		return days;	
	
	}
	
}