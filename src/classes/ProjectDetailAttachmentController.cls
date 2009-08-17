/**
*@author Nicolas Gunther - 03/23/2009
*/
public class ProjectDetailAttachmentController {

	private String project = null;
	private List<AttachmentInfo> attachments = new List<AttachmentInfo>();
	public UserPermissions userPermissions = ProjectDetailController.userPermission.clone();
	public ProjectDetailAttachmentController (){}

	/**
	*@param String project id
	*@return void
	*/
	public void setProject(String id){
		project = id;
		readAttachments();
	}
	
	/**
	*@return String project id
	*/
	public String getProject(){
		return project;
	}
	
	/**
	*@return List<AttachmentInfo> formated attachment list
	*/
	public List<AttachmentInfo> getAttachments(){
		return attachments;
	}
	/*
	*@return Boolean
	*/
	public Boolean getAttachmentCount(){
		return attachments.size() > 0;
	}
	
	
	
	/**
	* Read user permissions
	*@return void
	*/
	public void genPermissions() {
		userPermissions.setId(UserInfo.getUserId());
		userPermissions.setProject(project);
		userPermissions.setObjectType('Project');
		userPermissions.setPermissions();		
	}
	
	/**
	*@return UserPermissions
	*/
	public UserPermissions getUserPermissions () {
		//Refresh user permissions
		genPermissions();
		return userPermissions;
	}	

	/**
	*
	*@return void
	*/
	public void readAttachments(){
		List<Attachment> attachmentsList = new List<Attachment>();
		if(project != null){
			attachmentsList = [select name, id, parentid, ContentType, BodyLength, 
								LastModifiedDate, LastModifiedBy.Name, CreatedById
								from attachment 
								where parentid =: project
								order by name];
		}
		loadAttachmentList(attachmentsList);
	}
	
	
	/**
	* Load attachment list
	*@param List<Attachment> attachment list
	*@return void
	*/
	public void loadAttachmentList(List<Attachment> attachs){
		List<AttachmentInfo> attachList = new List<AttachmentInfo>();
		String avatarId;
		
		//Get current Avatar
		avatarId = [ select Picture__c from Project2__c where Id =: project limit 1 ].Picture__c ;
		
		for (Attachment item: attachs){	
			
			if(item.id != avatarId  && item.Name != 'pf__export.csv'){
	            
	            AttachmentInfo info = new AttachmentInfo();
	            
	            info.setId(item.Id);
	            info.setName(item.Name);
	            info.setAttachment(item);
	            info.setIsOwner(item.CreatedById == UserInfo.getUserId());
	            
	            String ContentType = item.ContentType;
	            String image = '';
	            
	            if (ContentType == null ) {
	            	
	            	// Using extension
	            	Integer extPos = item.Name.lastIndexOf('.') + 1;
	            	String extension = item.Name.substring(extPos);
	            	
	            	// containsKey does a case sensitive comparison
	            	extension = extension.toLowerCase();
	           		Map<String, String> typesExt = new Map<String, String>{
	           			'rar' => 'rar.gif', 
	           			'xls' => 'xls.gif', 
	           			'ppt' => 'ppt.gif', 
	           			'avi' => 'video.gif', 
	           			'mpg' => 'video.gif', 
	           			'mpeg' => 'video.gif', 
	           			'flv' => 'video.gif', 
	           			'mp3' => 'audio.gif', 
	           			'doc' => 'doc.gif'
	       			};
	           		
	           		if(typesExt.containsKey(extension)) {
	           			image = typesExt.get(extension);
	           		}else {
	           			image = 'generic.gif';
	           		}
	            
	            }else{
	           		
	           		// Using mime type
	           		Map<String, String> typesMime = new Map<String, String>{
	           			'image/jpeg' => 'images.gif', 
	           			'image/pjpeg' => 'images.gif', 
	           			'image/png' => 'images.gif', 
	           			'image/x-png' => 'images.gif', 
	           			'image/gif' => 'images.gif', 
	           			'image/bmp' => 'images.gif', 
	           			'text/plain' => 'txt.gif', 
	           			'application/pdf' => 'pdf.gif', 
	           			'application/msword' => 'doc.gif', 
	           			'application/x-zip-compressed' => 'zip.gif', 
	           			'audio/wav' => 'audio.gif', 
	           			'audio/mpeg' => 'audio.gif', 
	           			'video/mpeg' => 'video.gif', 
	           			'video/avi' => 'video.gif'
	       			};	
	           		
	           		if(typesMime.containsKey(ContentType)) {
	           			image = typesMime.get(ContentType);
	           		}else {
	           			image = 'generic.gif';
	           		}
	            
	            }
	            
	            info.setAttachImage(image);
	            attachList.add(info);
			}
        }
		
		attachments = attachList;
	
	}
	

	/**
	* Delete Attachment
	*@return void
	*/
	public void deleteAttach (){
		String attachId = System.currentPageReference().getParameters().get('idAttach');
		if(attachId != null && attachId != ''){
			Attachment attach = [select Id from Attachment where Id =: attachId];
			delete attach;
			readAttachments();
		}		
	}
	
	
	/**
	* Inner Class AttachmentInfo
	*/ 
	public class AttachmentInfo {
        
        String name;
        String attachImage;
		String id;
		Attachment attach;
		Boolean isOwner = false;
		      
        /**
        *@return String Attach id
        */
        public String getId () {
        	return id;
        }
        
        /**
        *@param String Attach id
        *@return void
        */
        public void setId (String id) {
        	this.id = id;
        }
        
        /**
        *@return String Attach name
        */        
        public String getName() {
                return name;
        }

        /**
        *@param String Attach name
        *@return void
        */
        public void setName(String name) {
                this.name = name;
        }  
        
		/**
		*@return String attach type icon
		*/       
        public String getAttachImage() {
                return attachImage;
        }

        /**
        *@param String attach type icon
        *@return void
        */
        public void setAttachImage (String attachImage) {
                this.attachImage = attachImage;
        }          

        /**
        *@param Attachment attach
        *@return void
        */
        public void setAttachment (Attachment attach) {
                this.attach = attach;
        }
        
        /**
        *@return Attachment
        */
        public Attachment getAttachment() {
                return attach;
        }
        
        /**
        *@param boolean b is owner
        *@return void
        */
        public void setIsOwner(Boolean b){
        	this.isOwner = b;
        }
        
        /**
        *@retrun boolean is owner
        */
        public Boolean getIsOwner(){
        	return isOwner;
        }                       
	}
}