# Forta ny question about this script, ask Franck
# This script:
#	- Needs to be run in the Unee-T Enterprise database.
#	- triggers the lambda to make sure we get a mefe_user_api_key 
#	

#########
#
# IMPORTANT WARNING:
#	- user email MUST exist
#	- make sure to update the lambda key for the relevant environment
#	  https://github.com/unee-t/lambda2sns/blob/master/tests/call-lambda-as-root.sh#L5
#		- DEV/Staging: 812644853088
#		- Prod: 192458993663
#		- Demo: 915001051872
#
##########

# Set the variables you need

	SET @emailAddress = 'kathylee@cbm.com.sg' ; 
	SET @userCreationRequestId = 33 ; 
	SET @creator_id = 'NXnKGEdEwEvMgWQtG' ;

# We can now call the lambda to get the api key.

	CALL mysql.lambda_async (CONCAT('arn:aws:lambda:ap-southeast-1:192458993663:function:alambda_simple')
				, JSON_OBJECT(
					'userCreationRequestId' , @userCreationRequestId
					, 'actionType', 'CREATE_USER'
					, 'creatorId', @creator_id
					, 'emailAddress', @emailAddress
					, 'firstName', ''
					, 'lastName', ''
					, 'phoneNumber', ''
					)
				)
				;
