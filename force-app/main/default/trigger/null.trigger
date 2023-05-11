trigger AdminSurveyControllerTrigger on Survey__c (before insert, before update) {

//Only allow users with appropriate permissions to access AdminSurveyController class 
if(!checkPermission()){
    return;
}

//Retrieve existing survey records if any
Set<Id> surveyIds = new Set<Id>();
for(Survey__c survey : Trigger.new){
    if(survey.Id != null){
        surveyIds.add(survey.Id);
    }
}
Map<Id, Survey__c> existingSurveys = new Map<Id, Survey__c>([SELECT Id, Survey_State__c FROM Survey__c WHERE Id IN :surveyIds]);

//Validate that Survey_State__c on existing records is not set to "Started"
for(Survey__c survey : Trigger.new){
    if(existingSurveys.containsKey(survey.Id)){
        if(existingSurveys.get(survey.Id).Survey_State__c == 'Started'){
            survey.addError('The Survey_State__c field cannot be set to "Started" for existing surveys.');
        }
    }
}

//Initialize all public properties of AdminSurveyController class with empty or default values
AdminSurveyController adminController = new AdminSurveyController();

//Invoke createSurvey and updateSurvey methods of AdminSurveyController class
for(Survey__c survey : trigger.new){
    try{
        if(existingSurveys.containsKey(survey.Id)){
            adminController.updateSurvey(survey);
        }
        else{
            adminController.createSurvey(survey);
        }
    }
    catch(Exception ex){
        survey.addError('Error encountered while processing survey record. Please contact your system administrator.');
    }
}

//Method to check if user has appropriate permissions
private Boolean checkPermission(){
    //TODO: Implement logic to check user permissions
    return true;
}

}