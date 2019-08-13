# For any question about this script, ask Franck
# This script:
#	- Needs to be run in the Unee-T Enterprise database.
#	- Replays the lambda to remove a user from a role in a unit
#	

#########
#
# IMPORTANT WARNING:
#	- make sure to update the lambda key for the relevant environment
#	  https://github.com/unee-t/lambda2sns/blob/master/tests/call-lambda-as-root.sh#L5
#		- DEV/Staging: 812644853088
#		- Prod: 192458993663
#		- Demo: 915001051872
#
##########

# Set the variables you need

	SET @mefe_api_request_id = '91007' ; 
	SET @requestor_mefe_user_id = 'NXnKGEdEwEvMgWQtG' ; 
	SET @invited_mefe_user_id = 'bHsAcN2X5NnRnCLuY' ; 
	SET @mefe_unit_id = 'o0ISgd8mVRc558K7J' ; 
	SET @role_type = 'Tenant' ; 
	SET @is_occupant = 1 ; 
	SET @is_visible = 1 ; 
	SET @is_default_assignee = 1 ; 
	SET @is_default_invited = 1 ; 
	SET @can_see_role_agent = 0 ; 
	SET @can_see_role_tenant = 1 ; 
	SET @can_see_role_landlord = 0 ; 
	SET @can_see_role_mgt_cny = 1 ; 
	SET @can_see_role_contractor = 0 ; 
	SET @can_see_occupant = 0 ; 

# We can now call the lambda to assign the user to the unit.

	CALL mysql.lambda_async (CONCAT('arn:aws:lambda:ap-southeast-1:812644853088:function:alambda_simple')
		, JSON_OBJECT('mefeAPIRequestId' , @mefe_api_request_id
			, 'actionType', 'ASSIGN_ROLE'
			, 'requestorUserId', @requestor_mefe_user_id
			, 'addedUserId', @invited_mefe_user_id
			, 'unitId', @mefe_unit_id
			, 'roleType', @role_type
			, 'isOccupant', @is_occupant
			, 'isVisible', @is_visible
			, 'isDefaultAssignee', @is_default_assignee
			, 'isDefaultInvited', @is_default_invited
			, 'roleVisibility' , JSON_OBJECT('Agent', @can_see_role_agent
				, 'Tenant', @can_see_role_tenant
				, 'Owner/Landlord', @can_see_role_landlord
				, 'Management Company', @can_see_role_mgt_cny
				, 'Contractor', @can_see_role_contractor
				, 'Occupant', @can_see_occupant
				)
			)
		)
		;
