# Forta ny question about this script, ask Franck
# This script:
#	- Needs to be run in the Unee-T Enterprise database.
#	- Replays the lambda to remove a user from a role in a unit
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

	SET @unitId = '3b27df9seY3pEqYPZ' ; 
	SET @userId = '4Lq3uL8NAZ3ngi4Ae' ; 
	SET @requestorUserId = 'NXnKGEdEwEvMgWQtG' ; 
	SET @removeUserFromUnitRequestId = 61489 ; 

# We can now call the lambda to get the api key.

	CALL mysql.lambda_async (CONCAT('arn:aws:lambda:ap-southeast-1:192458993663:function:alambda_simple')
				, JSON_OBJECT(
					'unitId' , @unitId
					, 'userId', @userId
					, 'actionType', 'DEASSIGN_ROLE'
					, 'requestorUserId', @requestorUserId
					, 'removeUserFromUnitRequestId', @removeUserFromUnitRequestId
					)
				)
				;
