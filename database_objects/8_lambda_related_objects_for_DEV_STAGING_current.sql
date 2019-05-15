#################
#
# All lambda related objects
#
#################
#
#################
# WARNING!!!
#################
#
######################################################################################
#
# BEFORE YOUR RUN THIS SCRIPT, MAKE SURE 
# TO UPDATE THE LAMBDA KEY TO USE THE CORRECT ONE FOR EACH ENVO
#
######################################################################################
#
# https://github.com/unee-t/lambda2sns/blob/master/tests/call-lambda-as-root.sh#L5
#	- DEV/Staging: 812644853088
#	- Prod: 192458993663
#	- Demo: 915001051872
#
# BY DEFAULT THIS SCRIPT USES THE LAMBDA FOR THE PROD ENVIRONMENT!!!
#
######################################################################################
#
# MAKE SURE TO UPDATE THE MEFE Creator_id AND USE THE CORRECT ONE FOR EACH ENVO
#
######################################################################################
#
# MEFE Creator_id:
#   - DEV/Staging: E4RFHFCQGsXGPcCb5 (hmlet.enterprise.dev@unee-t.com)
#   - PROD: NXnKGEdEwEvMgWQtG (hmlet.enterprise@unee-t.com)
#   - DEMO: hF4AxDx6r6ue2TgFD (hmlet.enterprise.demo@unee-t.com)
#
# BY DEFAULT THIS SCRIPT USES THE MEFE Creator_id FOR THE PROD ENVIRONMENT!!!
#
#################
# WARNING!!!
#################
#
# This script will create or update the following triggers:
# These triggers are calling lambda procedures.
#	- `ut_create_user`
#	- `ut_create_unit`
#	- `ut_add_user_to_role_in_unit_with_visibility`
#	- `ut_add_user_to_role_in_unit_with_visibility_update`
#	- `ut_update_unit_creation_needed`
#	- `ut_update_unit_already_exists`
#	- `ut_retry_create_unit`
#	- `ut_retry_assign_user_to_unit`
#
# This script will also create or update the following procedures
#	- Procedure that are calling lambda procedures:
#		- `ut_update_user`
#		- `ut_remove_user_from_unit`
#
#	- Procedures that are generating Lambda calls
#		- `lambda_create_user`
#		- `lambda_create_unit`
#		- `lambda_add_user_to_role_in_unit_with_visibility`
#		- `lambda_update_user_profile`
#		- `lambda_update_unit`
#		- `lambda_remove_user_from_unit`
#		- `lambda_update_unit_name_type`
#

# Create the trigger to fire the Lambda to tell the MEFE to create these user each time a user needs to be created in Unee-T

	DROP TRIGGER IF EXISTS `ut_create_user`;

DELIMITER $$
CREATE TRIGGER `ut_create_user`
AFTER INSERT ON `ut_map_external_source_users`
FOR EACH ROW
BEGIN

# We only do this IF:
#	- The variable @disable_lambda != 1
#	- This is done via an authorized create method:
#WIP		- 'ut_update_map_uneet_user_person_ut_account_creation_needed'
#WIP		- 'ut_update_map_uneet_user_person'
#WIP		- 'retry_create_user'
#		- ''
#		- ''
#		- ''

	SET @upstream_create_method_8_1 = NEW.`creation_method` ;
	SET @upstream_update_method_8_1 = NEW.`update_method` ;

	IF (@disable_lambda != 1
			OR @disable_lambda IS NULL)
	/*	AND (@upstream_create_method_8_1 = 'ut_update_map_uneet_user_person_ut_account_creation_needed'
			OR @upstream_update_method_8_1 = 'ut_update_map_uneet_user_person_ut_account_creation_needed'
			OR @upstream_create_method_8_1 = 'ut_update_map_uneet_user_person'
			OR @upstream_update_method_8_1 = 'ut_update_map_uneet_user_person'
			OR @upstream_create_method_8_1 = 'retry_create_user'
			OR @upstream_update_method_8_1 = 'retry_create_user'
		)
	*/
	THEN 

		# The specifics

			# What is this trigger (for log_purposes)
				SET @this_trigger_8_1 = 'ut_create_user';

			# What is the procedure associated with this trigger:
				SET @associated_procedure = 'lambda_create_user';
			
			# lambda:
			# https://github.com/unee-t/lambda2sns/blob/master/tests/call-lambda-as-root.sh#L5
			#	- DEV/Staging: 812644853088
			#	- Prod: 192458993663
			#	- Demo: 915001051872
	
					SET @lambda_key = 812644853088;

			# MEFE API Key:
				SET @key_this_envo = 'ABCDEFG';

	# We define the variables we need now

		SET @lambda_id = @lambda_key;
		SET @mefe_api_key = @key_this_envo;
		SET @person_id = NEW.`person_id`;

	# The variables we need in the Lambda payload:

		SET @user_creation_request_id = (SELECT `id_map` 
			FROM `ut_map_external_source_users`
			WHERE `person_id` = @person_id
			)
			;
		SET @action_type = 'CREATE_USER';
		SET @creator_id = NEW.`created_by_id` ;
		SET @email_address = (SELECT `email_address` 
			FROM `ut_user_information_persons`
			WHERE `id_person` = @person_id
			)
			;
		SET @first_name = (SELECT `first_name` 
			FROM `ut_user_information_persons`
			WHERE `id_person` = @person_id
			)
			;
		SET @last_name = (SELECT `last_name` 
			FROM `ut_user_information_persons`
			WHERE `id_person` = @person_id
			)
			;
		SET @phone_number = (SELECT `phone_number` 
			FROM `ut_user_information_persons`
			WHERE `id_person` = @person_id
			)
			;

	# We insert the event in the relevant log table

		# Simulate what the Procedure `lambda_create_user` does
		# Make sure to update that if you update the procedure `lambda_create_user`

			# The JSON Object:

				SET @json_object = (
						JSON_OBJECT(
							'userCreationRequestId' , @user_creation_request_id
							, 'actionType', @action_type
							, 'creatorId', @creator_id
							, 'emailAddress', @email_address
							, 'firstName', @first_name
							, 'lastName', @last_name
							, 'phoneNumber', @phone_number
						)
					)
					;

			# The specific lambda:

				SET @lambda = CONCAT('arn:aws:lambda:ap-southeast-1:'
					, @lambda_key
					, ':function:alambda_simple')
					;
			
			# The specific Lambda CALL:

				SET @lambda_call = CONCAT('CALL mysql.lambda_async'
					, @lambda
					, @json_object
					)
					;

		# Now that we have simulated what the CALL does, we record that

				INSERT INTO `log_lambdas`
					 (`created_datetime`
					 , `creation_trigger`
					 , `associated_call`
					 , `mefe_unit_id`
					 , `mefe_user_id`
					 , `unee_t_login`
					 , `payload`
					 )
					 VALUES
						(NOW()
						, @this_trigger_8_1
						, @associated_procedure
						, 'n/a'
						, 'n/a'
						, @email_address
						, @lambda_call
						)
						;

	# We call the Lambda procedure to create the user

		CALL `lambda_create_user`(@user_creation_request_id
			, @action_type
			, @creator_id
			, @email_address
			, @first_name
			, @last_name
			, @phone_number
			)
			;
	
	END IF;
END;
$$
DELIMITER ;

# Create the procedure which will call the Lambda to create a user

	DROP PROCEDURE IF EXISTS `lambda_create_user`;

DELIMITER $$
CREATE PROCEDURE `lambda_create_user`(
	IN user_creation_request_id INT(11)
	, IN action_type VARCHAR(255)
	, IN creator_id VARCHAR(255)
	, IN email_address VARCHAR(255)
	, IN first_name VARCHAR(255)
	, IN last_name VARCHAR(255)
	, IN phone_number VARCHAR(255)
	)
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN
		
		# Prepare the CALL argument that was prepared by the trigger
		# https://github.com/unee-t/lambda2sns/blob/master/tests/call-lambda-as-root.sh#L5
		#	- DEV/Staging: 812644853088
		#	- Prod: 192458993663
		#	- Demo: 915001051872

			CALL mysql.lambda_async (CONCAT('arn:aws:lambda:ap-southeast-1:812644853088:function:alambda_simple')
				, JSON_OBJECT(
					'userCreationRequestId' , user_creation_request_id
					, 'actionType', action_type
					, 'creatorId', creator_id
					, 'emailAddress', email_address
					, 'firstName', first_name
					, 'lastName', last_name
					, 'phoneNumber', phone_number
					)
				)
				;

END $$
DELIMITER ;

# Create a trigger to fire the Lambda to tell the MEFE to create these units each time a unit (building, Unit/flat, room) needs to be created in Unee-T

	DROP TRIGGER IF EXISTS `ut_create_unit`;

DELIMITER $$
CREATE TRIGGER `ut_create_unit`
AFTER INSERT ON `ut_map_external_source_units`
FOR EACH ROW
BEGIN

# We only do this IF:
#	- The variable @disable_lambda != 1
#	- We do NOT have a MEFE Unit ID for that unit
#	- This is from a recognized creation method:
#		- `ut_update_map_external_source_unit_add_building`
#		- `ut_update_map_external_source_unit_add_building_creation_needed`
#		- `ut_update_map_external_source_unit_add_unit`
#		- `ut_update_map_external_source_unit_add_unit_creation_needed`
#		- `ut_update_map_external_source_unit_add_room`
#		- `ut_update_map_external_source_unit_add_room_creation_needed`
#		- 'ut_update_map_external_source_unit_edit_level_1'
#		- 'ut_update_map_external_source_unit_edit_level_2'
#		- 'ut_update_map_external_source_unit_edit_level_3'
#		- ''
#		- ''
#		- ''

	SET @mefe_unit_id = NEW.`unee_t_mefe_unit_id` ;

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;

	IF @mefe_unit_id IS NULL
		AND (@upstream_create_method = 'ut_update_map_external_source_unit_add_building'
			OR @upstream_update_method = 'ut_update_map_external_source_unit_add_building'
			OR @upstream_create_method = 'ut_update_map_external_source_unit_add_building_creation_needed'
			OR @upstream_update_method = 'ut_update_map_external_source_unit_add_building_creation_needed'
			OR @upstream_create_method = 'ut_update_map_external_source_unit_add_unit'
			OR @upstream_update_method = 'ut_update_map_external_source_unit_add_unit'
			OR @upstream_create_method = 'ut_update_map_external_source_unit_add_unit_creation_needed'
			OR @upstream_update_method = 'ut_update_map_external_source_unit_add_unit_creation_needed'
			OR @upstream_create_method = 'ut_update_map_external_source_unit_add_room'
			OR @upstream_update_method = 'ut_update_map_external_source_unit_add_room'
			OR @upstream_create_method = 'ut_update_map_external_source_unit_add_room_creation_needed'
			OR @upstream_update_method = 'ut_update_map_external_source_unit_add_room_creation_needed'
			OR @upstream_create_method = 'ut_update_map_external_source_unit_edit_level_1'
			OR @upstream_update_method = 'ut_update_map_external_source_unit_edit_level_1'
			OR @upstream_create_method = 'ut_update_map_external_source_unit_edit_level_2'
			OR @upstream_update_method = 'ut_update_map_external_source_unit_edit_level_2'
			OR @upstream_create_method = 'ut_update_map_external_source_unit_edit_level_3'
			OR @upstream_update_method = 'ut_update_map_external_source_unit_edit_level_3'
			)
		AND (@disable_lambda != 1
			OR @disable_lambda IS NULL)
	THEN

		# The specifics

			# What is this trigger (for log_purposes)
				SET @this_trigger = 'ut_create_unit';

			# What is the procedure associated with this trigger:
				SET @associated_procedure = 'lambda_create_unit';
			
			# lambda:
			# https://github.com/unee-t/lambda2sns/blob/master/tests/call-lambda-as-root.sh#L5
			#	- DEV/Staging: 812644853088
			#	- Prod: 192458993663
			#	- Demo: 915001051872

				SET @lambda_key = 812644853088;

			# MEFE API Key:
				SET @key_this_envo = 'ABCDEFG';

	# We define the variables we need

		SET @lambda_id = @lambda_key;
		SET @mefe_api_key = @key_this_envo;

		SET @new_record_id = NEW.`new_record_id`;		
		SET @external_property_type_id = NEW.`external_property_type_id`;

		SET @unit_creation_request_id = (SELECT `id_map` 
			FROM `ut_map_external_source_units`
			WHERE `new_record_id` = @new_record_id
				AND `external_property_type_id` = @external_property_type_id
			)
			;
		SET @action_type = 'CREATE_UNIT';
		SET @creator_id = NEW.`created_by_id`;
		SET @uneet_name = NEW.`uneet_name`;
		SET @unee_t_unit_type = NEW.`unee_t_unit_type`;

		# More info:

			SET @more_info = (IF(@external_property_type_id = 1
					, (SELECT `more_info`
						FROM `ut_add_information_unit_level_1`
						WHERE `unit_level_1_id` = @new_record_id
						)
					, IF(@external_property_type_id = 2
						, (SELECT `more_info`
							FROM `ut_add_information_unit_level_2`
							WHERE `unit_level_2_id` = @new_record_id
							)
						, IF(@external_property_type_id = 3
							, (SELECT `more_info`
								FROM `ut_add_information_unit_level_3`
								WHERE `unit_level_3_id` = @new_record_id
								)
							, 'ERROR 561'
							) 
						)
					)
				)
				;
			SET @more_info_not_null = (IFNULL(@more_info
					, ''
					)
				)
				;
		# Street Address

			SET @street_address = (IF(@external_property_type_id = 1
					, (SELECT `street_address`
						FROM `ut_add_information_unit_level_1`
						WHERE `unit_level_1_id` = @new_record_id
						)
					, IF(@external_property_type_id = 2
						, (SELECT `street_address`
							FROM `ut_add_information_unit_level_2`
							WHERE `unit_level_2_id` = @new_record_id
							)
						, IF(@external_property_type_id = 3
							, (SELECT `street_address`
								FROM `ut_add_information_unit_level_3`
								WHERE `unit_level_3_id` = @new_record_id
								)
							, 'ERROR 435'
							) 
						)
					)
				)
				;

			SET @street_address_not_null = (IFNULL(@street_address
					, ''
					)
				)
				;
		
		# City

			SET @city = (IF(@external_property_type_id = 1
					, (SELECT `city`
						FROM `ut_add_information_unit_level_1`
						WHERE `unit_level_1_id` = @new_record_id
						)
					, IF(@external_property_type_id = 2
						, (SELECT `city`
							FROM `ut_add_information_unit_level_2`
							WHERE `unit_level_2_id` = @new_record_id
							)
						, IF(@external_property_type_id = 3
							, (SELECT `city`
								FROM `ut_add_information_unit_level_3`
								WHERE `unit_level_3_id` = @new_record_id
								)
							, 'ERROR 457'
							) 
						)
					)
				)
				;

			SET @city_not_null = (IFNULL(@city
					, ''
					)
				)
				;
		# State

			SET @state = (IF(@external_property_type_id = 1
					, (SELECT `state`
						FROM `ut_add_information_unit_level_1`
						WHERE `unit_level_1_id` = @new_record_id
						)
					, IF(@external_property_type_id = 2
						, (SELECT `state`
							FROM `ut_add_information_unit_level_2`
							WHERE `unit_level_2_id` = @new_record_id
							)
						, IF(@external_property_type_id = 3
							, (SELECT `state`
								FROM `ut_add_information_unit_level_3`
								WHERE `unit_level_3_id` = @new_record_id
								)
							, 'ERROR 479'
							) 
						)
					)
				)
				;

			SET @state_not_null = (IFNULL(@state
					, ''
					)
				)
				;
			
		# Zip Code

			SET @zip_code = (IF(@external_property_type_id = 1
					, (SELECT `zip_code`
						FROM `ut_add_information_unit_level_1`
						WHERE `unit_level_1_id` = @new_record_id
						)
					, IF(@external_property_type_id = 2
						, (SELECT `zip_code`
							FROM `ut_add_information_unit_level_2`
							WHERE `unit_level_2_id` = @new_record_id
							)
						, IF(@external_property_type_id = 3
							, (SELECT `zip_code`
								FROM `ut_add_information_unit_level_3`
								WHERE `unit_level_3_id` = @new_record_id
								)
							, 'ERROR 501'
							) 
						)
					)
				)
				;

			SET @zip_code_not_null = (IFNULL(@zip_code
					, ''
					)
				)
				;
		
		# Country

			SET @country = (IF(@external_property_type_id = 1
					, (SELECT `country`
						FROM `ut_add_information_unit_level_1`
						WHERE `unit_level_1_id` = @new_record_id
						)
					, IF(@external_property_type_id = 2
						, (SELECT `country`
							FROM `ut_add_information_unit_level_2`
							WHERE `unit_level_2_id` = @new_record_id
							)
						, IF(@external_property_type_id = 3
							, (SELECT `country`
								FROM `ut_add_information_unit_level_3`
								WHERE `unit_level_3_id` = @new_record_id
								)
							, 'ERROR 522'
							) 
						)
					)
				)
				;

			SET @country_not_null = (IFNULL(@country
					, ''
					)
				)
				;
		
		# Owner Id

			SET @owner_id = @creator_id ;

	# We insert the event in the relevant log table

		# Simulate what the Procedure `lambda_create_unit` does
		# Make sure to update that if you update the procedure `lambda_create_unit`

			# The JSON Object:

				SET @json_object = (
						JSON_OBJECT(
						'unitCreationRequestId' , @unit_creation_request_id
						, 'actionType', @action_type
						, 'creatorId', @creator_id
						, 'name', @uneet_name
						, 'type', @unee_t_unit_type
						, 'moreInfo', @more_info
						, 'streetAddress', @street_address
						, 'city', @city
						, 'state', @state
						, 'zipCode', @zip_code
						, 'country', @country
						, 'ownerId', @owner_id
						)
					)
					;

			# The specific lambda:

				SET @lambda = CONCAT('arn:aws:lambda:ap-southeast-1:'
					, @lambda_key
					, ':function:alambda_simple')
					;
			
			# The specific Lambda CALL:

				SET @lambda_call = CONCAT('CALL mysql.lambda_async'
					, @lambda
					, @json_object
					)
					;

		# Now that we have simulated what the CALL does, we record that

			INSERT INTO `log_lambdas`
				(`created_datetime`
				, `creation_trigger`
				, `associated_call`
				, `mefe_unit_id`
				, `unit_name`
				, `mefe_user_id`
				, `payload`
				)
				VALUES
					(NOW()
					, @this_trigger
					, @associated_procedure
					, 'n/a'
					, @uneet_name
					, 'n/a'
					, @lambda_call
					)
					;

	# We call the Lambda procedure to create a unit

		CALL `lambda_create_unit`(@unit_creation_request_id
			, @action_type
			, @creator_id
			, @uneet_name
			, @unee_t_unit_type
			, @more_info
			, @street_address
			, @city
			, @state
			, @zip_code
			, @country
			, @owner_id
			)
			;

	END IF;

END;
$$
DELIMITER ;

# Create the procedure which will call the Lambda to create a unit

	DROP PROCEDURE IF EXISTS `lambda_create_unit`;

DELIMITER $$
CREATE PROCEDURE `lambda_create_unit`(
	IN unit_creation_request_id INT(11)
	, IN action_type VARCHAR(255)
	, IN creator_id VARCHAR(255)
	, IN uneet_name VARCHAR(255)
	, IN unee_t_unit_type VARCHAR(255)
	, IN more_info VARCHAR(255)
	, IN street_address VARCHAR(255)
	, IN city VARCHAR(255)
	, IN state VARCHAR(255)
	, IN zip_code VARCHAR(255)
	, IN country VARCHAR(255)
	, IN owner_id VARCHAR(255)
	)
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN
		
		# Prepare the CALL argument that was prepared by the trigger
		# https://github.com/unee-t/lambda2sns/blob/master/tests/call-lambda-as-root.sh#L5
		#	- DEV/Staging: 812644853088
		#	- Prod: 192458993663
		#	- Demo: 915001051872

			CALL mysql.lambda_async (CONCAT('arn:aws:lambda:ap-southeast-1:812644853088:function:alambda_simple')
				, JSON_OBJECT(
					'unitCreationRequestId' , unit_creation_request_id
					, 'actionType', action_type
					, 'creatorId', creator_id
					, 'name', uneet_name
					, 'type', unee_t_unit_type
					, 'moreInfo', more_info
					, 'streetAddress', street_address
					, 'city', city
					, 'state', state
					, 'zipCode', zip_code
					, 'country', country
					, 'ownerId', owner_id
					)
				)
				;

END $$
DELIMITER ;

# Create a trigger to fire the lambda to tell the MEFE to create the association

	DROP TRIGGER IF EXISTS `ut_add_user_to_role_in_unit_with_visibility`;

DELIMITER $$
CREATE TRIGGER `ut_add_user_to_role_in_unit_with_visibility`
AFTER INSERT ON `ut_map_user_permissions_unit_all`
FOR EACH ROW
BEGIN

# We only do this IF:
#	- The variable @disable_lambda != 1
#WIP	- This is done via an authorized insert method:
#WIP		- 'ut_add_user_to_role_in_a_level_3_property'
#WIP		- 'ut_add_user_to_role_in_a_level_2_property'
#WIP		- 'ut_add_user_to_role_in_a_level_1_property'
#WIP		- 'ut_update_mefe_unit_id_assign_users_to_property'
#WIP		- ''
#WIP		- ''
#WIP		- ''
#

	SET @upstream_create_method_8_3 = NEW.`creation_method` ;
	SET @upstream_update_method_8_3 = NEW.`update_method` ;

	IF (@disable_lambda != 1
		OR @disable_lambda IS NULL)
	THEN 

		# The specifics

			# What is this trigger (for log_purposes)
				SET @this_trigger_8_3 = 'ut_add_user_to_role_in_unit_with_visibility';

			# What is the procedure associated with this trigger:
				SET @associated_procedure = 'lambda_add_user_to_role_in_unit_with_visibility';
			
			# lambda:
			# https://github.com/unee-t/lambda2sns/blob/master/tests/call-lambda-as-root.sh#L5
			#	- DEV/Staging: 812644853088
			#	- Prod: 192458993663
			#	- Demo: 915001051872

				SET @lambda_key = 812644853088;

			# MEFE API Key:
				SET @key_this_envo = 'ABCDEFG';

	# The variables that we need:

		SET @mefe_api_request_id = NEW.`id_map_user_unit_permissions` ;

		SET @action_type = 'ASSIGN_ROLE' ;

		SET @requestor_mefe_user_id = NEW.`created_by_id` ;
		
		SET @invited_mefe_user_id = NEW.`unee_t_mefe_id` ;
		SET @mefe_unit_id = NEW.`unee_t_unit_id` ;
		SET @role_type = (SELECT `role_type`
			FROM `ut_user_role_types`
			WHERE `id_role_type` = NEW.`unee_t_role_id` 
			)
			;
		
		SET @is_occupant = NEW.`is_occupant`= 1 ;
		SET @is_occupant_not_null = (IFNULL(@is_occupant
				, 0
				)
			)
			;
		SET @is_occupant_json = IF(NEW.`is_occupant`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @is_visible = NEW.`is_public`= 1 ;
		SET @is_visible_not_null = (IFNULL(@is_visible
				, 0
				)
			)
			;
		SET @is_visible_json = IF(NEW.`is_public`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @is_default_assignee = NEW.`is_default_assignee`= 1 ;
		SET @is_default_assignee_not_null = (IFNULL(@is_default_assignee
				, 0
				)
			)
			;
		SET @is_default_assignee_json = IF(NEW.`is_default_assignee`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @is_default_invited = NEW.`is_default_invited` ;
		SET @is_default_invited_not_null = (IFNULL(@is_default_invited
				, 0
				)
			)
			;
		SET @is_default_invited_json = IF(NEW.`is_default_invited`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @can_see_role_agent = NEW.`can_see_role_agent`;
		SET @can_see_role_agent_not_null = (IFNULL(@can_see_role_agent
				, 0
				)
			)
			;
		SET @can_see_role_agent_json = IF(NEW.`can_see_role_agent`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @can_see_role_tenant = NEW.`can_see_role_tenant`;
		SET @can_see_role_tenant_not_null = (IFNULL(@can_see_role_tenant
				, 0
				)
			)
			;
		SET @can_see_role_tenant_json = IF(NEW.`can_see_role_tenant`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @can_see_role_landlord = NEW.`can_see_role_landlord`;
		SET @can_see_role_landlord_not_null = (IFNULL(@can_see_role_landlord
				, 0
				)
			)
			;
		SET @can_see_role_landlord_json = IF(NEW.`can_see_role_landlord`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @can_see_role_mgt_cny = NEW.`can_see_role_mgt_cny`;
		SET @can_see_role_mgt_cny_not_null = (IFNULL(@can_see_role_mgt_cny
				, 0
				)
			)
			;
		SET @can_see_role_mgt_cny_json = IF(NEW.`can_see_role_mgt_cny`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @can_see_role_contractor = NEW.`can_see_role_contractor`;
		SET @can_see_role_contractor_not_null = (IFNULL(@can_see_role_contractor
				, 0
				)
			)
			;
		SET @can_see_role_contractor_json = IF(NEW.`can_see_role_contractor`= 1
			, 'true'
			, 'false'
		 	)
			; 

		SET @can_see_occupant = NEW.`can_see_occupant` ; 
		SET @can_see_occupant_not_null = (IFNULL(@can_see_occupant
				, 0
				)
			)
			;
		SET @can_see_occupant_json = IF(NEW.`can_see_occupant`= 1
			, 'true'
			, 'false'
		 	)
			; 
	
	# We insert the event in the relevant log table

		# Simulate what the Procedure `lambda_add_user_to_role_in_unit_with_visibility` does
		# Make sure to update that if you update the procedure `lambda_add_user_to_role_in_unit_with_visibility`

			# The JSON Object:

				SET @json_object = (
					JSON_OBJECT(
						'mefeAPIRequestId' , @mefe_api_request_id
						, 'actionType', @action_type
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

			# The specific lambda:

				SET @lambda = CONCAT('arn:aws:lambda:ap-southeast-1:'
					, @lambda_key
					, ':function:alambda_simple')
					;
			
			# The specific Lambda CALL:

				SET @lambda_call = CONCAT('CALL mysql.lambda_async'
					, @lambda
					, @json_object
					)
					;

		# Now that we have simulated what the CALL does, we record that

			SET @unit_name := (SELECT `uneet_name`
				FROM `ut_map_external_source_units`
				WHERE `unee_t_mefe_unit_id` = @mefe_unit_id
				);
			SET @unee_t_login := (SELECT `uneet_login_name`
				FROM `ut_map_external_source_users`
				WHERE `unee_t_mefe_user_id` = @invited_mefe_user_id
				);

			INSERT INTO `log_lambdas`
				(`created_datetime`
				, `creation_trigger`
				, `associated_call`
				, `mefe_unit_id`
				, `unit_name`
				, `mefe_user_id`
				, `unee_t_login`
				, `payload`
				)
				VALUES
					(NOW()
					, @this_trigger_8_3
					, @associated_procedure
					, @mefe_unit_id
					, @unit_name
					, @invited_mefe_user_id
					, @unee_t_login
					, @lambda_call
					)
					;

	# We call the Lambda procedure to add a user to a role in a unit

		CALL `lambda_add_user_to_role_in_unit_with_visibility`(@mefe_api_request_id
			, @action_type
			, @requestor_mefe_user_id
			, @invited_mefe_user_id
			, @mefe_unit_id
			, @role_type
			, @is_occupant
			, @is_visible
			, @is_default_assignee
			, @is_default_invited
			, @can_see_role_agent
			, @can_see_role_tenant
			, @can_see_role_landlord
			, @can_see_role_mgt_cny
			, @can_see_role_contractor
			, @can_see_occupant
			)
			;

	END IF;
END;
$$
DELIMITER ;

# Create the procedure which will call the Lambda to create the mapping user/role/visibility/unit

	DROP PROCEDURE IF EXISTS `lambda_add_user_to_role_in_unit_with_visibility`;

DELIMITER $$
CREATE PROCEDURE `lambda_add_user_to_role_in_unit_with_visibility`(
	IN mefe_api_request_id int(11)
	, IN action_type varchar(255)
	, IN requestor_mefe_user_id varchar(255)
	, IN invited_mefe_user_id varchar(255)
	, IN mefe_unit_id varchar(255)
	, IN role_type varchar(255)
	, IN is_occupant boolean
	, IN is_visible boolean
	, IN is_default_assignee boolean
	, IN is_default_invited boolean
	, IN can_see_role_agent boolean
	, IN can_see_role_tenant boolean
	, IN can_see_role_landlord boolean
	, IN can_see_role_mgt_cny boolean
	, IN can_see_role_contractor boolean
	, IN can_see_occupant boolean
	)
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN
		
		# Prepare the CALL argument that was prepared by the trigger
		# https://github.com/unee-t/lambda2sns/blob/master/tests/call-lambda-as-root.sh#L5
		#	- DEV/Staging: 812644853088
		#	- Prod: 192458993663
		#	- Demo: 915001051872

			CALL mysql.lambda_async (CONCAT('arn:aws:lambda:ap-southeast-1:812644853088:function:alambda_simple')
				, JSON_OBJECT(
					'mefeAPIRequestId' , mefe_api_request_id
					, 'actionType', action_type
					, 'requestorUserId', requestor_mefe_user_id
					, 'addedUserId', invited_mefe_user_id
					, 'unitId', mefe_unit_id
					, 'roleType', role_type
					, 'isOccupant', is_occupant
					, 'isVisible', is_visible
					, 'isDefaultAssignee', is_default_assignee
					, 'isDefaultInvited', is_default_invited
					, 'roleVisibility' , JSON_OBJECT('Agent', can_see_role_agent
						, 'Tenant', can_see_role_tenant
						, 'Owner/Landlord', can_see_role_landlord
						, 'Management Company', can_see_role_mgt_cny
						, 'Contractor', can_see_role_contractor
						, 'Occupant', can_see_occupant
						)
					)
				)
				;

END $$
DELIMITER ;

# Create the Procedure that will fire the Lambda to tell the MEFE to update these user each time a user needs to be updated in Unee-T

	DROP PROCEDURE IF EXISTS `ut_update_user`;

DELIMITER $$
CREATE PROCEDURE `ut_update_user`()
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN

# This procedure needs to following variables:
#	- @person_id
#	- @requestor_id
#

# We only do this IF:
#	- The variable @disable_lambda != 1
#	- We have a MEFE user ID
#WIP	- There was NO change to the fact that we need to create a Unee-T account
#	- This is done via an authorized insert method:
#		- `ut_person_has_been_updated_and_ut_account_needed`
#		- ''
#		- ''
#

	SET @mefe_user_id_uu_l_1 = (SELECT `unee_t_mefe_user_id`
		FROM `ut_map_external_source_users`
		WHERE `person_id` = @person_id
		) 
		;

	IF @mefe_user_id_uu_l_1 IS NOT NULL
		AND (@disable_lambda != 1
			OR @disable_lambda IS NULL)
	THEN

			# The specifics

				# What is this trigger (for log_purposes)
					SET @this_procedure = 'ut_update_user';

				# What is the procedure associated with this trigger:
					SET @associated_procedure = 'lambda_update_user_profile';
			
			# lambda:
			# https://github.com/unee-t/lambda2sns/blob/master/tests/call-lambda-as-root.sh#L5
			#	- DEV/Staging: 812644853088
			#	- Prod: 192458993663
			#	- Demo: 915001051872

					SET @lambda_key = 812644853088;

				# MEFE API Key:
					SET @key_this_envo = 'ABCDEFG';

		# Define the variables we need:

			SET @update_user_request_id = (SELECT `id_map`
				FROM `ut_map_external_source_users`
				WHERE `person_id` = @person_id
				) 
				;

			SET @action_type = 'EDIT_USER' ;

			SET @requestor_mefe_user_id = @requestor_id ;

			SET @creator_mefe_user_id =  (SELECT `updated_by_id` 
				FROM `persons`
				WHERE `id_person` = @person_id
				)
				;

			SET @first_name = (SELECT `first_name` 
				FROM `ut_user_information_persons`
				WHERE `id_person` = @person_id
				)
				;

			SET @last_name = (SELECT `last_name` 
				FROM `ut_user_information_persons`
				WHERE `id_person` = @person_id
				)
				;

			SET @phone_number = (SELECT `phone_number` 
				FROM `ut_user_information_persons`
				WHERE `id_person` = @person_id
				)
				;

			SET @mefe_email_address = (SELECT `email_address` 
				FROM `ut_user_information_persons`
				WHERE `id_person` = @person_id
				)
				;

			SET @bzfe_email_address = (SELECT `email_address` 
				FROM `ut_user_information_persons`
				WHERE `id_person` = @person_id
				)
				;

			SET @lambda_id = @lambda_key ;
			SET @mefe_api_key = @key_this_envo ;

		# We insert the event in the relevant log table

			# Simulate what the Procedure `lambda_create_user` does
			# Make sure to update that if you update the procedure `lambda_create_user`

				# The JSON Object:

					SET @json_object = (
						JSON_OBJECT(
							'updateUserRequestId' , @update_user_request_id
							, 'actionType', @action_type
							, 'requestorUserId', @requestor_mefe_user_id
							, 'creatorId', @creator_mefe_user_id
							, 'userId', @mefe_user_id_uu_l_1
							, 'firstName', @first_name
							, 'lastName', @last_name
							, 'phoneNumber', @phone_number
							, 'emailAddress', @mefe_email_address
							, 'bzfeEmailAddress', @bzfe_email_address
							)
						)
						;

				# The specific lambda:

					SET @lambda = CONCAT('arn:aws:lambda:ap-southeast-1:'
						, @lambda_key
						, ':function:alambda_simple')
						;
				
				# The specific Lambda CALL:

					SET @lambda_call = CONCAT('CALL mysql.lambda_async'
						, @lambda
						, @json_object
						)
						;

			# Now that we have simulated what the CALL does, we record that

			SET @unee_t_login := (SELECT `uneet_login_name`
				FROM `ut_map_external_source_users`
				WHERE `unee_t_mefe_user_id` = @mefe_user_id_uu_l_1
				);

				INSERT INTO `log_lambdas`
					(`created_datetime`
					, `creation_trigger`
					, `associated_call`
					, `mefe_unit_id`
					, `mefe_user_id`
					, `unee_t_login`
					, `payload`
					)
					VALUES
						(NOW()
						, @this_procedure
						, @associated_procedure
						, 'n/a'
						, @mefe_user_id_uu_l_1
						, @unee_t_login
						, @lambda_call
						)
						;

		# We call the Lambda procedure to update the user

			CALL `lambda_update_user_profile`(@update_user_request_id
				, @action_type
				, @requestor_mefe_user_id
				, @creator_mefe_user_id
				, @mefe_user_id_uu_l_1
				, @first_name
				, @last_name
				, @phone_number
				, @mefe_email_address
				, @bzfe_email_address
				)
				;

	END IF;
END;
$$
DELIMITER ;

# Create the procedure which will call the Lambda to update the user profile

	DROP PROCEDURE IF EXISTS `lambda_update_user_profile`;

DELIMITER $$
CREATE PROCEDURE `lambda_update_user_profile`(
	IN update_user_request_id int(11)
	, IN action_type varchar(255)
	, IN requestor_mefe_user_id varchar(255)
	, IN creator_mefe_user_id varchar(255)
	, IN mefe_user_id varchar(255)
	, IN first_name varchar(255)
	, IN last_name varchar(255)
	, IN phone_number varchar(255)
	, IN mefe_email_address varchar(255)
	, IN bzfe_email_address varchar(255)
	)
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN
		
		# Prepare the CALL argument that was prepared by the trigger
		# https://github.com/unee-t/lambda2sns/blob/master/tests/call-lambda-as-root.sh#L5
		#	- DEV/Staging: 812644853088
		#	- Prod: 192458993663
		#	- Demo: 915001051872

			CALL mysql.lambda_async (CONCAT('arn:aws:lambda:ap-southeast-1:812644853088:function:alambda_simple')
				, JSON_OBJECT(
					'updateUserRequestId' , update_user_request_id
					, 'actionType', action_type
					, 'requestorUserId', requestor_mefe_user_id
					, 'creatorId', creator_mefe_user_id
					, 'userId', mefe_user_id
					, 'firstName', first_name
					, 'lastName', last_name
					, 'phoneNumber', phone_number
					, 'emailAddress', mefe_email_address
					, 'bzfeEmailAddress', bzfe_email_address
					)
				)
				;

END $$
DELIMITER ;

# Create a trigger to fire the lambda each time we need to update a unit

	DROP TRIGGER IF EXISTS `ut_update_unit_creation_needed`;

DELIMITER $$
CREATE TRIGGER `ut_update_unit_creation_needed`
AFTER UPDATE ON `ut_map_external_source_units`
FOR EACH ROW
BEGIN

# We only do this IF:
#	- The variable @disable_lambda != 1
#	- We do NOT have a MEFE Unit ID
#	- this unit is marked a `is_update_needed` = 1
#	- This is done via an authorized update method:
#		- `ut_update_map_external_source_unit_add_building`
#		- `ut_update_map_external_source_unit_add_building_creation_needed`
#		- `ut_update_map_external_source_unit_add_unit`
#		- `ut_update_map_external_source_unit_add_unit_creation_needed`
#		- `ut_update_map_external_source_unit_add_room`
#		- `ut_update_map_external_source_unit_add_room_creation_needed`
#		- ''
#		- ''
#		- ''

	SET @mefe_unit_id = NEW.`unee_t_mefe_unit_id` ;

	SET @is_update_needed = NEW.`is_update_needed` ;

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;

	IF @mefe_unit_id IS NULL
		AND @is_update_needed = 1
		AND (@upstream_create_method = 'ut_update_map_external_source_unit_add_building'
			OR @upstream_update_method = 'ut_update_map_external_source_unit_add_building'
			OR @upstream_create_method = 'ut_update_map_external_source_unit_add_building_creation_needed'
			OR @upstream_update_method = 'ut_update_map_external_source_unit_add_building_creation_needed'
			OR @upstream_create_method = 'ut_update_map_external_source_unit_add_unit'
			OR @upstream_update_method = 'ut_update_map_external_source_unit_add_unit'
			OR @upstream_create_method = 'ut_update_map_external_source_unit_add_unit_creation_needed'
			OR @upstream_update_method = 'ut_update_map_external_source_unit_add_unit_creation_needed'
			OR @upstream_create_method = 'ut_update_map_external_source_unit_add_room'
			OR @upstream_update_method = 'ut_update_map_external_source_unit_add_room'
			OR @upstream_create_method = 'ut_update_map_external_source_unit_add_room_creation_needed'
			OR @upstream_update_method = 'ut_update_map_external_source_unit_add_room_creation_needed'
			)
		AND (@disable_lambda != 1
			OR @disable_lambda IS NULL)
	THEN

		# The specifics

			# What is this trigger (for log_purposes)
				SET @this_trigger = 'ut_update_unit_creation_needed';

			# What is the procedure associated with this trigger:
				SET @associated_procedure = 'lambda_create_unit';
			
			# lambda:
			# https://github.com/unee-t/lambda2sns/blob/master/tests/call-lambda-as-root.sh#L5
			#	- DEV/Staging: 812644853088
			#	- Prod: 192458993663
			#	- Demo: 915001051872

				SET @lambda_key = 812644853088;

			# MEFE API Key:
				SET @key_this_envo = 'ABCDEFG';

	# We define the variables we need
	# Where can we find the details about that unit?

		SET @lambda_id = @lambda_key;
		SET @mefe_api_key = @key_this_envo;

		SET @new_record_id = NEW.`new_record_id`;		
		SET @external_property_type_id = NEW.`external_property_type_id`;

		SET @unit_creation_request_id = (SELECT `id_map` 
			FROM `ut_map_external_source_units`
			WHERE `new_record_id` = @new_record_id
				AND `external_property_type_id` = @external_property_type_id
			)
			;
		SET @action_type = 'CREATE_UNIT';
		SET @creator_id = NEW.`created_by_id`;
		SET @uneet_name = NEW.`uneet_name`;
		SET @unee_t_unit_type = NEW.`unee_t_unit_type`;

		# More info:

			SET @more_info = (IF(@external_property_type_id = 1
					, (SELECT `more_info`
						FROM `ut_add_information_unit_level_1`
						WHERE `unit_level_1_id` = @new_record_id
						)
					, IF(@external_property_type_id = 2
						, (SELECT `more_info`
							FROM `ut_add_information_unit_level_2`
							WHERE `unit_level_2_id` = @new_record_id
							)
						, IF(@external_property_type_id = 3
							, (SELECT `more_info`
								FROM `ut_add_information_unit_level_3`
								WHERE `unit_level_3_id` = @new_record_id
								)
							, 'ERROR 561'
							) 
						)
					)
				)
				;
			SET @more_info_not_null = (IFNULL(@more_info
					, ''
					)
				)
				;

		# Street Address

			SET @street_address = (IF(@external_property_type_id = 1
					, (SELECT `street_address`
						FROM `ut_add_information_unit_level_1`
						WHERE `unit_level_1_id` = @new_record_id
						)
					, IF(@external_property_type_id = 2
						, (SELECT `street_address`
							FROM `ut_add_information_unit_level_2`
							WHERE `unit_level_2_id` = @new_record_id
							)
						, IF(@external_property_type_id = 3
							, (SELECT `street_address`
								FROM `ut_add_information_unit_level_3`
								WHERE `unit_level_3_id` = @new_record_id
								)
							, 'ERROR 435'
							) 
						)
					)
				)
				;

			SET @street_address_not_null = (IFNULL(@street_address
					, ''
					)
				)
				;
		
		# City

			SET @city = (IF(@external_property_type_id = 1
					, (SELECT `city`
						FROM `ut_add_information_unit_level_1`
						WHERE `unit_level_1_id` = @new_record_id
						)
					, IF(@external_property_type_id = 2
						, (SELECT `city`
							FROM `ut_add_information_unit_level_2`
							WHERE `unit_level_2_id` = @new_record_id
							)
						, IF(@external_property_type_id = 3
							, (SELECT `city`
								FROM `ut_add_information_unit_level_3`
								WHERE `unit_level_3_id` = @new_record_id
								)
							, 'ERROR 457'
							) 
						)
					)
				)
				;

			SET @city_not_null = (IFNULL(@city
					, ''
					)
				)
				;
		# State

			SET @state = (IF(@external_property_type_id = 1
					, (SELECT `state`
						FROM `ut_add_information_unit_level_1`
						WHERE `unit_level_1_id` = @new_record_id
						)
					, IF(@external_property_type_id = 2
						, (SELECT `state`
							FROM `ut_add_information_unit_level_2`
							WHERE `unit_level_2_id` = @new_record_id
							)
						, IF(@external_property_type_id = 3
							, (SELECT `state`
								FROM `ut_add_information_unit_level_3`
								WHERE `unit_level_3_id` = @new_record_id
								)
							, 'ERROR 479'
							) 
						)
					)
				)
				;

			SET @state_not_null = (IFNULL(@state
					, ''
					)
				)
				;
			
		# Zip Code

			SET @zip_code = (IF(@external_property_type_id = 1
					, (SELECT `zip_code`
						FROM `ut_add_information_unit_level_1`
						WHERE `unit_level_1_id` = @new_record_id
						)
					, IF(@external_property_type_id = 2
						, (SELECT `zip_code`
							FROM `ut_add_information_unit_level_2`
							WHERE `unit_level_2_id` = @new_record_id
							)
						, IF(@external_property_type_id = 3
							, (SELECT `zip_code`
								FROM `ut_add_information_unit_level_3`
								WHERE `unit_level_3_id` = @new_record_id
								)
							, 'ERROR 501'
							) 
						)
					)
				)
				;

			SET @zip_code_not_null = (IFNULL(@zip_code
					, ''
					)
				)
				;
		
		# Country

			SET @country = (IF(@external_property_type_id = 1
					, (SELECT `country`
						FROM `ut_add_information_unit_level_1`
						WHERE `unit_level_1_id` = @new_record_id
						)
					, IF(@external_property_type_id = 2
						, (SELECT `country`
							FROM `ut_add_information_unit_level_2`
							WHERE `unit_level_2_id` = @new_record_id
							)
						, IF(@external_property_type_id = 3
							, (SELECT `country`
								FROM `ut_add_information_unit_level_3`
								WHERE `unit_level_3_id` = @new_record_id
								)
							, 'ERROR 522'
							) 
						)
					)
				)
				;

			SET @country_not_null = (IFNULL(@country
					, ''
					)
				)
				;
		
		# Owner Id

			SET @owner_id = @creator_id ;

	# We insert the event in the relevant log table

		# Simulate what the Procedure `lambda_create_unit` does
		# Make sure to update that if you update the procedure `lambda_create_unit`

			# The JSON Object:

				SET @json_object = (
						JSON_OBJECT(
						'unitCreationRequestId' , @unit_creation_request_id
						, 'actionType', @action_type
						, 'creatorId', @creator_id
						, 'name', @uneet_name
						, 'type', @unee_t_unit_type
						, 'moreInfo', @more_info
						, 'streetAddress', @street_address
						, 'city', @city
						, 'state', @state
						, 'zipCode', @zip_code
						, 'country', @country
						, 'ownerId', @owner_id
						)
					)
					;

			# The specific lambda:

				SET @lambda = CONCAT('arn:aws:lambda:ap-southeast-1:'
					, @lambda_key
					, ':function:alambda_simple')
					;
			
			# The specific Lambda CALL:

				SET @lambda_call = CONCAT('CALL mysql.lambda_async'
					, @lambda
					, @json_object
					)
					;

		# Now that we have simulated what the CALL does, we record that

			INSERT INTO `log_lambdas`
				(`created_datetime`
				, `creation_trigger`
				, `associated_call`
				, `mefe_unit_id`
				, `unit_name`
				, `mefe_user_id`
				, `payload`
				)
				VALUES
					(NOW()
					, @this_trigger
					, @associated_procedure
					, 'n/a'
					, @uneet_name
					, 'n/a'
					, @lambda_call
					)
					;

	# We call the Lambda procedure to create a unit

		CALL `lambda_create_unit`(@unit_creation_request_id
			, @action_type
			, @creator_id
			, @uneet_name
			, @unee_t_unit_type
			, @more_info
			, @street_address
			, @city
			, @state
			, @zip_code
			, @country
			, @owner_id
			)
			;

	END IF;
END;
$$
DELIMITER ;

# Create a trigger to fire the lambda each time we need to update a unit

	DROP TRIGGER IF EXISTS `ut_update_unit_already_exists`;

DELIMITER $$
CREATE TRIGGER `ut_update_unit_already_exists`
AFTER UPDATE ON `ut_map_external_source_units`
FOR EACH ROW
BEGIN

# We only do this IF:
#	- The variable @disable_lambda != 1
#	- We have a MEFE Unit ID
#	- this unit is marked a `is_update_needed` = 1
#	- This is done via an authorized update method:
#		- 'ut_update_map_external_source_unit_edit_level_1'
#		- 'ut_update_map_external_source_unit_edit_level_2'
#		- 'ut_update_map_external_source_unit_edit_level_3'
#		- ''
#		- ''
#		- ''

	SET @mefe_unit_id = NEW.`unee_t_mefe_unit_id` ;

	SET @is_update_needed = NEW.`is_update_needed` ;

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;

	IF @mefe_unit_id IS NOT NULL
		AND @is_update_needed = 1
		AND (@upstream_create_method = 'ut_update_map_external_source_unit_edit_level_1'
			OR @upstream_update_method = 'ut_update_map_external_source_unit_edit_level_1'
			OR @upstream_create_method = 'ut_update_map_external_source_unit_edit_level_2'
			OR @upstream_update_method = 'ut_update_map_external_source_unit_edit_level_2'
			OR @upstream_create_method = 'ut_update_map_external_source_unit_edit_level_3'
			OR @upstream_update_method = 'ut_update_map_external_source_unit_edit_level_3'
			)
		AND (@disable_lambda != 1
			OR @disable_lambda IS NULL)
	THEN

		# The specifics

			# What is this trigger (for log_purposes)
				SET @this_trigger = 'ut_update_unit_already_exists';

			# What is the procedure associated with this trigger:
				SET @associated_procedure = 'lambda_update_unit';
			
			# lambda:
			# https://github.com/unee-t/lambda2sns/blob/master/tests/call-lambda-as-root.sh#L5
			#	- DEV/Staging: 812644853088
			#	- Prod: 192458993663
			#	- Demo: 915001051872

				SET @lambda_key = 812644853088;

			# MEFE API Key:
				SET @key_this_envo = 'ABCDEFG';

	# We define the variables we need
	# Where can we find the details about that unit?

		SET @new_record_id = NEW.`new_record_id`;		
		SET @external_property_type_id = NEW.`external_property_type_id`;

		SET @update_unit_request_id = (SELECT `id_map` 
			FROM `ut_map_external_source_units`
			WHERE `unee_t_mefe_unit_id` = @mefe_unit_id
			)
			;
		SET @action_type = 'EDIT_UNIT';
		SET @requestor_user_id = NEW.`updated_by_id`; 

		SET @creator_id = NEW.`created_by_id`;

		SET @unee_t_unit_type = NEW.`unee_t_unit_type`;
		SET @unee_t_unit_name = NEW.`uneet_name`;


		# More info:

			SET @more_info = (IF(@external_property_type_id = 1
					, (SELECT `more_info`
						FROM `ut_add_information_unit_level_1`
						WHERE `unit_level_1_id` = @new_record_id
						)
					, IF(@external_property_type_id = 2
						, (SELECT `more_info`
							FROM `ut_add_information_unit_level_2`
							WHERE `unit_level_2_id` = @new_record_id
							)
						, IF(@external_property_type_id = 3
							, (SELECT `more_info`
								FROM `ut_add_information_unit_level_3`
								WHERE `unit_level_3_id` = @new_record_id
								)
							, 'ERROR 3499'
							) 
						)
					)
				)
				;
			SET @more_info_not_null = (IFNULL(@more_info
					, ''
					)
				)
				;
		# Street Address

			SET @street_address = (IF(@external_property_type_id = 1
					, (SELECT `street_address`
						FROM `ut_add_information_unit_level_1`
						WHERE `unit_level_1_id` = @new_record_id
						)
					, IF(@external_property_type_id = 2
						, (SELECT `street_address`
							FROM `ut_add_information_unit_level_2`
							WHERE `unit_level_2_id` = @new_record_id
							)
						, IF(@external_property_type_id = 3
							, (SELECT `street_address`
								FROM `ut_add_information_unit_level_3`
								WHERE `unit_level_3_id` = @new_record_id
								)
							, 'ERROR 3527'
							) 
						)
					)
				)
				;

			SET @street_address_not_null = (IFNULL(@street_address
					, ''
					)
				)
				;
		
		# City

			SET @city = (IF(@external_property_type_id = 1
					, (SELECT `city`
						FROM `ut_add_information_unit_level_1`
						WHERE `unit_level_1_id` = @new_record_id
						)
					, IF(@external_property_type_id = 2
						, (SELECT `city`
							FROM `ut_add_information_unit_level_2`
							WHERE `unit_level_2_id` = @new_record_id
							)
						, IF(@external_property_type_id = 3
							, (SELECT `city`
								FROM `ut_add_information_unit_level_3`
								WHERE `unit_level_3_id` = @new_record_id
								)
							, 'ERROR 3557'
							) 
						)
					)
				)
				;

			SET @city_not_null = (IFNULL(@city
					, ''
					)
				)
				;
		# State

			SET @state = (IF(@external_property_type_id = 1
					, (SELECT `state`
						FROM `ut_add_information_unit_level_1`
						WHERE `unit_level_1_id` = @new_record_id
						)
					, IF(@external_property_type_id = 2
						, (SELECT `state`
							FROM `ut_add_information_unit_level_2`
							WHERE `unit_level_2_id` = @new_record_id
							)
						, IF(@external_property_type_id = 3
							, (SELECT `state`
								FROM `ut_add_information_unit_level_3`
								WHERE `unit_level_3_id` = @new_record_id
								)
							, 'ERROR 3586'
							) 
						)
					)
				)
				;

			SET @state_not_null = (IFNULL(@state
					, ''
					)
				)
				;
			
		# Zip Code

			SET @zip_code = (IF(@external_property_type_id = 1
					, (SELECT `zip_code`
						FROM `ut_add_information_unit_level_1`
						WHERE `unit_level_1_id` = @new_record_id
						)
					, IF(@external_property_type_id = 2
						, (SELECT `zip_code`
							FROM `ut_add_information_unit_level_2`
							WHERE `unit_level_2_id` = @new_record_id
							)
						, IF(@external_property_type_id = 3
							, (SELECT `zip_code`
								FROM `ut_add_information_unit_level_3`
								WHERE `unit_level_3_id` = @new_record_id
								)
							, 'ERROR 3616'
							) 
						)
					)
				)
				;

			SET @zip_code_not_null = (IFNULL(@zip_code
					, ''
					)
				)
				;
		
		# Country

			SET @country = (IF(@external_property_type_id = 1
					, (SELECT `country`
						FROM `ut_add_information_unit_level_1`
						WHERE `unit_level_1_id` = @new_record_id
						)
					, IF(@external_property_type_id = 2
						, (SELECT `country`
							FROM `ut_add_information_unit_level_2`
							WHERE `unit_level_2_id` = @new_record_id
							)
						, IF(@external_property_type_id = 3
							, (SELECT `country`
								FROM `ut_add_information_unit_level_3`
								WHERE `unit_level_3_id` = @new_record_id
								)
							, 'ERROR 522'
							) 
						)
					)
				)
				;

			SET @country_not_null = (IFNULL(@country
					, ''
					)
				)
				;

	# We insert the event in the relevant log table

		# Simulate what the Procedure `lambda_update_unit` does
		# Make sure to update that if you update the procedure `lambda_update_unit`

			# The JSON Object:

				SET @json_object = (
						JSON_OBJECT(
							'updateUnitRequestId' , @update_unit_request_id
							, 'actionType', @action_type
							, 'requestorUserId', @requestor_user_id
							, 'unitId', @mefe_unit_id
							, 'creatorId', @creator_id
							, 'type', @unee_t_unit_type
							, 'name', @unee_t_unit_name
							, 'moreInfo', @more_info
							, 'streetAddress', @street_address
							, 'city', @city
							, 'state', @state
							, 'zipCode', @zip_code
							, 'country', @country
						)
					)
					;

			# The specific lambda:

				SET @lambda = CONCAT('arn:aws:lambda:ap-southeast-1:'
					, @lambda_key
					, ':function:alambda_simple')
					;
			
			# The specific Lambda CALL:

				SET @lambda_call = CONCAT('CALL mysql.lambda_async'
					, @lambda
					, @json_object
					)
					;

		# Now that we have simulated what the CALL does, we record that

			SET @unit_name := (SELECT `uneet_name`
				FROM `ut_map_external_source_units`
				WHERE `unee_t_mefe_unit_id` = @mefe_unit_id
				);

			INSERT INTO `log_lambdas`
				(`created_datetime`
				, `creation_trigger`
				, `associated_call`
				, `mefe_unit_id`
				, `unit_name`
				, `mefe_user_id`
				, `payload`
				)
				VALUES
					(NOW()
					, @this_trigger
					, @associated_procedure
					, @mefe_unit_id
					, @unit_name
					, 'n/a'
					, @lambda_call
					)
					;

	# We call the Lambda procedure to update the unit

		CALL `lambda_update_unit`(@update_unit_request_id
			, @action_type
			, @requestor_user_id
			, @mefe_unit_id
			, @creator_id
			, @unee_t_unit_type
			, @unee_t_unit_name
			, @more_info
			, @street_address
			, @city
			, @state
			, @zip_code
			, @country
			)
			;

	END IF;
END;
$$
DELIMITER ;

# Create the procedure which will call the Lambda to update the unit

	DROP PROCEDURE IF EXISTS `lambda_update_unit`;

DELIMITER $$
CREATE PROCEDURE `lambda_update_unit`(
	IN update_unit_request_id int(11)
	, IN action_type varchar(255)
	, IN requestor_user_id varchar(255)
	, IN mefe_unit_id varchar(255)
	, IN creator_id varchar(255)
	, IN unee_t_unit_type varchar(255)
	, IN unee_t_unit_name varchar(255)
	, IN more_info varchar(255)
	, IN street_address varchar(255)
	, IN city varchar(255)
	, IN state varchar(255)
	, IN zip_code varchar(255)
	, IN country varchar(255)
	)
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN
		
		# Prepare the CALL argument that was prepared by the trigger
		# https://github.com/unee-t/lambda2sns/blob/master/tests/call-lambda-as-root.sh#L5
		#	- DEV/Staging: 812644853088
		#	- Prod: 192458993663
		#	- Demo: 915001051872

			CALL mysql.lambda_async (CONCAT('arn:aws:lambda:ap-southeast-1:812644853088:function:alambda_simple')
				, JSON_OBJECT(
					'updateUnitRequestId' , update_unit_request_id
					, 'actionType', action_type
					, 'requestorUserId', requestor_user_id
					, 'unitId', mefe_unit_id
					, 'creatorId', creator_id
					, 'type', unee_t_unit_type
					, 'name', unee_t_unit_name
					, 'moreInfo', more_info
					, 'streetAddress', street_address
					, 'city', city
					, 'state', state
					, 'zipCode', zip_code
					, 'country', country
					)
				)
				;

END $$
DELIMITER ;

# Remove an association Unit/User
# There are several scenario when this can happen:
#	- We remove a user from a Level 1 property.
#	- We remove a user from a Level 2 property.
#	- We remove a user from a Level 3 property.
#	- We mark a user as Obsolete
#
#
# We are NOT using a trigger to do that ---> this gives us more granularity
# We will call the procedure `ut_remove_user_from_unit` on a case by case basis

	DROP PROCEDURE IF EXISTS `ut_remove_user_from_unit`;

DELIMITER $$
CREATE PROCEDURE `ut_remove_user_from_unit`()
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN

# We only do this IF:
#	- The variable @disable_lambda != 1
#	- We have a MEFE unit ID
#	- We have a MEFE user ID
#	- The field `is_obsolete` = 1
#	- We have an `update_system_id`
#	- We have an `updated_by_id`
#	- We have an `update_method`
#	- This is done via an authorized update method
#		- 'ut_delete_user_from_role_in_a_level_1_property'
#		- 'ut_delete_user_from_role_in_a_level_2_property'
#		- 'ut_delete_user_from_role_in_a_level_3_property'
#		- ''
#		- ''

# This procedure needs the following variables:
#	- @unee_t_mefe_id
#	- @unee_t_unit_id
#	- @is_obsolete
#	- @update_method
#	- @update_system_id
#	- @updated_by_id
#	- @disable_lambda != 1

	IF @unee_t_mefe_id IS NOT NULL
		AND @unee_t_unit_id IS NOT NULL
		AND @is_obsolete = 1
		AND (@disable_lambda != 1
			OR @disable_lambda IS NULL)
		AND @update_system_id IS NOT NULL
		AND @updated_by_id IS NOT NULL
		AND (@update_method = 'ut_delete_user_from_role_in_a_level_1_property'
			OR @update_method = 'ut_delete_user_from_role_in_a_level_2_property'
			OR @update_method = 'ut_delete_user_from_role_in_a_level_3_property'
			)
	THEN

			# The specifics

				# What is this trigger (for log_purposes)
					SET @this_procedure_8_7 = 'ut_remove_user_from_unit';

				# What is the procedure associated with this trigger:
					SET @associated_procedure = 'lambda_remove_user_from_unit';
			
			# lambda:
			# https://github.com/unee-t/lambda2sns/blob/master/tests/call-lambda-as-root.sh#L5
			#	- DEV/Staging: 812644853088
			#	- Prod: 192458993663
			#	- Demo: 915001051872

					SET @lambda_key = 812644853088;

				# MEFE API Key:
					SET @key_this_envo = 'ABCDEFG';

		# The variables that we need:

			SET @remove_user_from_unit_request_id = (SELECT `id_map_user_unit_permissions`
				FROM `ut_map_user_permissions_unit_all`
				WHERE `unee_t_mefe_id` = @unee_t_mefe_id
					AND `unee_t_unit_id` = @unee_t_unit_id
				) ;

			SET @action_type = 'DEASSIGN_ROLE' ;

			SET @requestor_user_id = @updated_by_id ;
			
			SET @mefe_user_id = @unee_t_mefe_id ;

			SET @mefe_unit_id = @unee_t_unit_id ;
		
		# We insert the event in the relevant log table

			# Simulate what the Procedure `lambda_add_user_to_role_in_unit_with_visibility` does
			# Make sure to update that if you update the procedure `lambda_add_user_to_role_in_unit_with_visibility`

				# The JSON Object:

					SET @json_object = (
						JSON_OBJECT(
							'removeUserFromUnitRequestId' , @remove_user_from_unit_request_id
							, 'actionType', @action_type
							, 'requestorUserId', @requestor_user_id
							, 'userId', @mefe_user_id
							, 'unitId', @mefe_unit_id
							)
						)
						;

				# The specific lambda:

					SET @lambda = CONCAT('arn:aws:lambda:ap-southeast-1:'
						, @lambda_key
						, ':function:alambda_simple')
						;
				
				# The specific Lambda CALL:

					SET @lambda_call = CONCAT('CALL mysql.lambda_async'
						, @lambda
						, @json_object
						)
						;

			# Now that we have simulated what the CALL does, we record that

			SET @unit_name := (SELECT `uneet_name`
				FROM `ut_map_external_source_units`
				WHERE `unee_t_mefe_unit_id` = @mefe_unit_id
				);
			SET @unee_t_login := (SELECT `uneet_login_name`
				FROM `ut_map_external_source_users`
				WHERE `unee_t_mefe_user_id` = @mefe_user_id
				);

				INSERT INTO `log_lambdas`
					(`created_datetime`
					, `creation_trigger`
					, `associated_call`
					, `mefe_unit_id`
					, `unit_name`
					, `mefe_user_id`
					, `unee_t_login`
					, `payload`
					)
					VALUES
						(NOW()
						, @this_procedure_8_7
						, @associated_procedure
						, @mefe_unit_id
						, @unit_name
						, @mefe_user_id
						, @unee_t_login
						, @lambda_call
						)
						;

		# We call the Lambda procedure to remove a user from a role in a unit

			CALL `lambda_remove_user_from_unit`(@remove_user_from_unit_request_id
				, @action_type
				, @requestor_user_id
				, @mefe_user_id
				, @mefe_unit_id
				)
				;

	END IF;
END;
$$
DELIMITER ;

# Create the procedure which will call the Lambda to remove the user from the unit

	DROP PROCEDURE IF EXISTS `lambda_remove_user_from_unit`;

DELIMITER $$
CREATE PROCEDURE `lambda_remove_user_from_unit`(
	IN remove_user_from_unit_request_id int(11)
	, IN action_type varchar(255)
	, IN requestor_user_id varchar(255)
	, IN mefe_user_id varchar(255)
	, IN mefe_unit_id varchar(255)
	)
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN
		
		# Prepare the CALL argument that was prepared by the trigger
		# https://github.com/unee-t/lambda2sns/blob/master/tests/call-lambda-as-root.sh#L5
		#	- DEV/Staging: 812644853088
		#	- Prod: 192458993663
		#	- Demo: 915001051872

			CALL mysql.lambda_async (CONCAT('arn:aws:lambda:ap-southeast-1:812644853088:function:alambda_simple')
				, JSON_OBJECT(
					'removeUserFromUnitRequestId' , remove_user_from_unit_request_id
					, 'actionType', action_type
					, 'requestorUserId', requestor_user_id
					, 'userId', mefe_user_id
					, 'unitId', mefe_unit_id
					)
				)
				;

END $$
DELIMITER ;

# Create the procedure which will call the Lambda to update the unit

	DROP PROCEDURE IF EXISTS `lambda_update_unit_name_type`;

DELIMITER $$
CREATE PROCEDURE `lambda_update_unit_name_type`(
	IN update_unit_request_id int(11)
	, IN action_type varchar(255)
	, IN requestor_user_id varchar(255)
	, IN mefe_unit_id varchar(255)
	, IN creator_id varchar(255)
	, IN unee_t_unit_type varchar(255)
	, IN unee_t_unit_name varchar(255)
	)
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN
		
		# Prepare the CALL argument that was prepared by the trigger
		# https://github.com/unee-t/lambda2sns/blob/master/tests/call-lambda-as-root.sh#L5
		#	- DEV/Staging: 812644853088
		#	- Prod: 192458993663
		#	- Demo: 915001051872

			CALL mysql.lambda_async (CONCAT('arn:aws:lambda:ap-southeast-1:812644853088:function:alambda_simple')
                , JSON_OBJECT(
                	'updateUnitRequestId' , update_unit_request_id
                	, 'actionType', action_type
                	, 'requestorUserId', requestor_user_id
                	, 'unitId', mefe_unit_id
                	, 'creatorId', creator_id
                	, 'type', unee_t_unit_type
                	, 'name', unee_t_unit_name
                	)
                )
                ;

END $$
DELIMITER ;

# Create the trigger that will fire the lambda to re-try the unit creation

	DROP TRIGGER IF EXISTS `ut_retry_create_unit`;

DELIMITER $$
CREATE TRIGGER `ut_retry_create_unit`
AFTER INSERT ON `retry_create_units_list_units`
FOR EACH ROW
BEGIN

# We only do this IF:
#	- The variable @disable_lambda != 1
#	- This is done via an authorized create method:
#		- 'ut_retry_create_unit_level_1'
#		- 'ut_retry_create_unit_level_2'
#		- 'ut_retry_create_unit_level_3'
#		- ''
#		- ''
#		- ''

	SET @upstream_create_method := NEW.`creation_method` ;

	IF (@disable_lambda != 1
			OR @disable_lambda IS NULL)
		AND (@upstream_create_method = 'ut_retry_create_unit_level_1'
			OR @upstream_create_method = 'ut_retry_create_unit_level_2'
			OR @upstream_create_method = 'ut_retry_create_unit_level_3'
		)
	THEN 

		# The specifics

			# What is this trigger (for log_purposes)
				SET @this_trigger := 'ut_retry_create_unit';

			# What is the procedure associated with this trigger:
				SET @associated_procedure := 'lambda_create_unit';
			
			# lambda:
			# https://github.com/unee-t/lambda2sns/blob/master/tests/call-lambda-as-root.sh#L5
			#	- DEV/Staging: 812644853088
			#	- Prod: 192458993663
			#	- Demo: 915001051872

				SET @lambda_key := '192458993663';

			# MEFE API Key:
				SET @key_this_envo := 'omitted';

	# We define the variables we need
	
		SET @lambda_id := @lambda_key ;
		SET @mefe_api_key := @key_this_envo ;

		SET @unit_creation_request_id := NEW.`unit_creation_request_id` ;

		SET @action_type := 'CREATE_UNIT' ;
		SET @creator_id := NEW.`created_by_id` ;
		SET @uneet_name := NEW.`uneet_name` ;
		SET @unee_t_unit_type := NEW.`unee_t_unit_type` ;
	
		SET @more_info := NEW.`more_info` ;	
		SET @street_address := NEW.`street_address` ;	
		SET @city := NEW.`city` ;	
		SET @state := NEW.`state` ;	
		SET @zip_code := NEW.`zip_code` ;
		SET @country := NEW.`country` ;

		SET @owner_id := @creator_id ;
	
	# We insert the event in the relevant log table

		# Simulate what the trigger does

			# The JSON Object:

				SET @json_object := (
						JSON_OBJECT(
						'unitCreationRequestId' , @unit_creation_request_id
						, 'actionType', @action_type
						, 'creatorId', @creator_id
						, 'name', @uneet_name
						, 'type', @unee_t_unit_type
						, 'moreInfo', @more_info
						, 'streetAddress', @street_address
						, 'city', @city
						, 'state', @state
						, 'zipCode', @zip_code
						, 'country', @country
						, 'ownerId', @owner_id
						)
					)
					;

			# The specific lambda:

				SET @lambda := CONCAT('arn:aws:lambda:ap-southeast-1:'
					, @lambda_key
					, ':function:alambda_simple')
					;
			
			# The specific Lambda CALL:

				SET @lambda_call := CONCAT('CALL mysql.lambda_async'
					, @lambda
					, @json_object
					)
					;

		# Now that we have simulated what the CALL does, we record that

			INSERT INTO `log_lambdas`
				(`created_datetime`
				, `creation_trigger`
				, `associated_call`
				, `mefe_unit_id`
				, `unit_name`
				, `mefe_user_id`
				, `payload`
				)
				VALUES
					(NOW()
					, @this_trigger
					, @associated_procedure
					, 'n/a'
					, @uneet_name
					, 'n/a'
					, @lambda_call
					)
					;


	# We call the Lambda procedure to create a unit

		CALL `lambda_create_unit`(@unit_creation_request_id
			, @action_type
			, @creator_id
			, @uneet_name
			, @unee_t_unit_type
			, @more_info
			, @street_address
			, @city
			, @state
			, @zip_code
			, @country
			, @owner_id
			)
			;

	END IF;
END;
$$
DELIMITER ;

# Create the trigger that will fire the lambda to re-try the unit creation

	DROP TRIGGER IF EXISTS `ut_retry_assign_user_to_unit`;

DELIMITER $$
CREATE TRIGGER `ut_retry_assign_user_to_unit`
AFTER INSERT ON `retry_assign_user_to_units_list`
FOR EACH ROW
BEGIN

# We only do this IF:
#	- The variable @disable_lambda != 1
#	- This is done via an authorized create method:
#		- 'ut_retry_assign_user_to_units_error_ownership'
#		- 'ut_retry_assign_user_to_units_error_already_has_role'
#		- ''
#		- ''

	SET @upstream_create_method := NEW.`creation_method` ;

	IF (@disable_lambda != 1
			OR @disable_lambda IS NULL)
		AND (@upstream_create_method = 'ut_retry_assign_user_to_units_error_ownership'
			OR @upstream_create_method = 'ut_retry_assign_user_to_units_error_already_has_role'
		)
	THEN 

		# The specifics

			# What is this trigger (for log_purposes)
				SET @this_trigger := 'ut_retry_assign_user_to_unit';

			# What is the procedure associated with this trigger:
				SET @associated_procedure := 'lambda_add_user_to_role_in_unit_with_visibility';
			
			# lambda:
			# https://github.com/unee-t/lambda2sns/blob/master/tests/call-lambda-as-root.sh#L5
			#	- DEV/Staging: 812644853088
			#	- Prod: 192458993663
			#	- Demo: 915001051872

				SET @lambda_key := '192458993663';

			# MEFE API Key:
				SET @key_this_envo := 'omitted';

	# The variables that we need:

		SET @mefe_api_request_id = NEW.`id_map_user_unit_permissions` ;

		SET @action_type = 'ASSIGN_ROLE' ;

		SET @requestor_mefe_user_id = NEW.`created_by_id` ;
		
		SET @invited_mefe_user_id = NEW.`mefe_user_id` ;
		SET @mefe_unit_id = NEW.`mefe_unit_id` ;
		SET @role_type = (SELECT `role_type`
			FROM `ut_user_role_types`
			WHERE `id_role_type` = NEW.`unee_t_role_id` 
			)
			;
		
		SET @is_occupant = NEW.`is_occupant`= 1 ;
		SET @is_occupant_not_null = (IFNULL(@is_occupant
				, 0
				)
			)
			;
		SET @is_occupant_json = IF(NEW.`is_occupant`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @is_visible = NEW.`is_public`= 1 ;
		SET @is_visible_not_null = (IFNULL(@is_visible
				, 0
				)
			)
			;
		SET @is_visible_json = IF(NEW.`is_public`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @is_default_assignee = NEW.`is_default_assignee`= 1 ;
		SET @is_default_assignee_not_null = (IFNULL(@is_default_assignee
				, 0
				)
			)
			;
		SET @is_default_assignee_json = IF(NEW.`is_default_assignee`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @is_default_invited = NEW.`is_default_invited` ;
		SET @is_default_invited_not_null = (IFNULL(@is_default_invited
				, 0
				)
			)
			;
		SET @is_default_invited_json = IF(NEW.`is_default_invited`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @can_see_role_agent = NEW.`can_see_role_agent`;
		SET @can_see_role_agent_not_null = (IFNULL(@can_see_role_agent
				, 0
				)
			)
			;
		SET @can_see_role_agent_json = IF(NEW.`can_see_role_agent`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @can_see_role_tenant = NEW.`can_see_role_tenant`;
		SET @can_see_role_tenant_not_null = (IFNULL(@can_see_role_tenant
				, 0
				)
			)
			;
		SET @can_see_role_tenant_json = IF(NEW.`can_see_role_tenant`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @can_see_role_landlord = NEW.`can_see_role_landlord`;
		SET @can_see_role_landlord_not_null = (IFNULL(@can_see_role_landlord
				, 0
				)
			)
			;
		SET @can_see_role_landlord_json = IF(NEW.`can_see_role_landlord`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @can_see_role_mgt_cny = NEW.`can_see_role_mgt_cny`;
		SET @can_see_role_mgt_cny_not_null = (IFNULL(@can_see_role_mgt_cny
				, 0
				)
			)
			;
		SET @can_see_role_mgt_cny_json = IF(NEW.`can_see_role_mgt_cny`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @can_see_role_contractor = NEW.`can_see_role_contractor`;
		SET @can_see_role_contractor_not_null = (IFNULL(@can_see_role_contractor
				, 0
				)
			)
			;
		SET @can_see_role_contractor_json = IF(NEW.`can_see_role_contractor`= 1
			, 'true'
			, 'false'
		 	)
			; 

		SET @can_see_occupant = NEW.`can_see_occupant` ; 
		SET @can_see_occupant_not_null = (IFNULL(@can_see_occupant
				, 0
				)
			)
			;
		SET @can_see_occupant_json = IF(NEW.`can_see_occupant`= 1
			, 'true'
			, 'false'
		 	)
			; 
	
	# We insert the event in the relevant log table

		# Simulate what the Procedure `lambda_add_user_to_role_in_unit_with_visibility` does
		# Make sure to update that if you update the procedure `lambda_add_user_to_role_in_unit_with_visibility`

			# The JSON Object:

				SET @json_object = (
					JSON_OBJECT(
						'mefeAPIRequestId' , @mefe_api_request_id
						, 'actionType', @action_type
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

			# The specific lambda:

				SET @lambda = CONCAT('arn:aws:lambda:ap-southeast-1:'
					, @lambda_key
					, ':function:alambda_simple')
					;
			
			# The specific Lambda CALL:

				SET @lambda_call = CONCAT('CALL mysql.lambda_async'
					, @lambda
					, @json_object
					)
					;

		# Now that we have simulated what the CALL does, we record that

			SET @unit_name := (SELECT `uneet_name`
				FROM `ut_map_external_source_units`
				WHERE `unee_t_mefe_unit_id` = @mefe_unit_id
				);
			SET @unee_t_login := (SELECT `uneet_login_name`
				FROM `ut_map_external_source_users`
				WHERE `unee_t_mefe_user_id` = @invited_mefe_user_id
				);

			INSERT INTO `log_lambdas`
				(`created_datetime`
				, `creation_trigger`
				, `associated_call`
				, `mefe_unit_id`
				, `unit_name`
				, `mefe_user_id`
				, `unee_t_login`
				, `payload`
				)
				VALUES
					(NOW()
					, @this_trigger
					, @associated_procedure
					, @mefe_unit_id
					, @unit_name
					, @invited_mefe_user_id
					, @unee_t_login
					, @lambda_call
					)
					;

	# We call the Lambda procedure to add a user to a role in a unit

		CALL `lambda_add_user_to_role_in_unit_with_visibility`(@mefe_api_request_id
			, @action_type
			, @requestor_mefe_user_id
			, @invited_mefe_user_id
			, @mefe_unit_id
			, @role_type
			, @is_occupant
			, @is_visible
			, @is_default_assignee
			, @is_default_invited
			, @can_see_role_agent
			, @can_see_role_tenant
			, @can_see_role_landlord
			, @can_see_role_mgt_cny
			, @can_see_role_contractor
			, @can_see_occupant
			)
			;

	END IF;
END;
$$
DELIMITER ;