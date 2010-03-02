@isTest private  class ProjectSetupControllerTest {
	
	/**
    * Test customException
    */
    static testMethod void myUnitTest(){
    	
		GenerateEnvironmentTest.gen();
		ProjectUtil.setIsTest( true );
    	Test.startTest();
    	
		ProjectSetupController ps = new ProjectSetupController();
		
		ps.listProfiles();
		ps.saveSetup();
		
    	Test.stopTest();
		ProjectUtil.setIsTest( false );    	
    	
    }
}