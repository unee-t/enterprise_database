#################
#	
# This is part 7
# Procedures to update the Db after downstream system calls back
#
#################

####################################################################
#
# The below Procedures are used so that we can update the database
# after an action from a downstream system was done
#	- `create a user`
#	- ``
#
# We are creating the following procedures:
#	- `ut_creation_unit_mefe_api_reply` (was previously `ut_creation_success_mefe_unit_id`)
#	- `ut_creation_user_mefe_api_reply` (was previously `ut_creation_success_mefe_user_id`)
#	- `ut_creation_user_role_association_mefe_api_reply` (was previously `ut_creation_success_add_user_to_role_in_unit_with_visibility`)
#	- `ut_update_unit_mefe_api_reply` (was previously `ut_update_success_mefe_unit`)
#	- `ut_update_user_mefe_api_reply` (was previously `ut_update_success_mefe_user`)
#	- `ut_remove_user_role_association_mefe_api_reply` (was previously `ut_update_success_remove_user_from_unit`)
#
#
####################################################################
#
#################
# WARNING!!!
#################
#
######################################################################################
#
# you also need to run all the other scripts so the Unee-T Enterprise Db is properly configured
#	- 1_Triggers_and_procedure_unee-t_enterprise_v1_8_0_updates_FROM_Unee-T_Enterprise_excl_assignment.sql
#	- 2_
#	- 4_Triggers_and_procedure_unee-t_enterprise_v1_8_0_lambda_related_objects_for_[ENVIRONMENT].sql
#
######################################################################################
#


# Create the procedure so that the Golang Script can update the record each time a unit is successfully created.

		DROP PROCEDURE IF EXISTS `ut_creation_unit_mefe_api_reply`;
	
DELIMITER $$
CREATE PROCEDURE `ut_creation_unit_mefe_api_reply`()
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN

# This procedure needs the following variables:
#	- @unit_creation_request_id
#	- @mefe_unit_id
#	- @creation_datetime
#	- @is_created_by_me
#	- @mefe_api_error_message

	# We need to capture the MEFE user ID of the updater

		SET @updated_by_id := (SELECT `created_by_id`
			FROM `ut_map_external_source_units` 
			WHERE `id_map` = @unit_creation_request_id
			);

	# Is it a success or an error?

		SET @is_mefe_api_success := (IF (@mefe_api_error_message = ''
				, 1
				, 0
				)
			);

	# Now we can do the update

		UPDATE `ut_map_external_source_units`
		SET 
			`unee_t_mefe_unit_id` := @mefe_unit_id
			, `uneet_created_datetime` := @creation_datetime
			, `is_unee_t_created_by_me` := @is_created_by_me
			, `is_update_needed` := 0
			, `syst_updated_datetime` := NOW()
			, `update_system_id` := 2
			, `updated_by_id` := @updated_by_id
			, `update_method` := 'ut_creation_unit_mefe_api_reply'
			, `is_mefe_api_success` := @is_mefe_api_success
			, `mefe_api_error_message` := @mefe_api_error_message
			WHERE `id_map` = @unit_creation_request_id
		;

END $$
DELIMITER ;

# Create the procedure so that the Golang Script can update the record each time a user is successfully created.

		DROP PROCEDURE IF EXISTS `ut_creation_user_mefe_api_reply`;
	
DELIMITER $$
CREATE PROCEDURE `ut_creation_user_mefe_api_reply`()
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN

# This procedure needs the following variables:
#	- @user_creation_request_id
#	- @mefe_user_id
#	- @mefe_user_api_key
#	- @creation_datetime
#	- @is_created_by_me
#	- @mefe_api_error_message

	# We need to capture the MEFE user ID of the updater

		SET @updated_by_id = (SELECT `created_by_id`
			FROM `ut_map_external_source_users` 
			WHERE `id_map` = @user_creation_request_id
			);

	# Is it a success or an error?

		SET @is_mefe_api_success := (IF (@mefe_api_error_message = ''
				, 1
				, 0
				)
			);

	# Now we can do the update

		UPDATE `ut_map_external_source_users`
		SET 
			`unee_t_mefe_user_id` := @mefe_user_id
			, `unee_t_mefe_user_api_key` = @mefe_user_api_key
			, `uneet_created_datetime` := @creation_datetime
			, `is_unee_t_created_by_me` := @is_created_by_me
			, `is_update_needed` := 0
			, `syst_updated_datetime` := NOW()
			, `update_system_id` := 2
			, `updated_by_id` := @updated_by_id
			, `update_method` = 'ut_creation_user_mefe_api_reply'
			, `is_mefe_api_success` := @is_mefe_api_success
			, `mefe_api_error_message` := @mefe_api_error_message
			WHERE `id_map` = @user_creation_request_id
		;

END $$
DELIMITER ;

# Create the procedure so that the Golang Script can update the record each time a mapping user/role/visibility/unit is successfully created.

		DROP PROCEDURE IF EXISTS `ut_creation_user_role_association_mefe_api_reply`;
	
DELIMITER $$
CREATE PROCEDURE `ut_creation_user_role_association_mefe_api_reply`()
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN

# This procedure needs the following variables:
#	- @mefe_api_request_id
#	- @creation_datetime 
#	- @mefe_api_error_message

	# We need to capture the MEFE user ID of the updater

		SET @updated_by_id := (SELECT `created_by_id`
			FROM `ut_map_user_permissions_unit_all` 
			WHERE `id_map_user_unit_permissions` = @unit_creation_request_id
			);

	# Is it a success or an error?

		SET @is_mefe_api_success := (IF (@mefe_api_error_message = ''
				, 1
				, 0
				)
			);

	# Now we can do the update

		UPDATE `ut_map_user_permissions_unit_all`
		SET 
			`is_update_needed` := 0
			, `syst_updated_datetime` := NOW()
			, `update_system_id` := 2
			, `updated_by_id` := @updated_by_id
			, `update_method` := 'ut_creation_user_role_association_mefe_api_reply'
			, `unee_t_update_ts` := @creation_datetime
			, `is_mefe_api_success` := @is_mefe_api_success
			, `mefe_api_error_message` := @mefe_api_error_message
			WHERE `id_map_user_unit_permissions` = @mefe_api_request_id
		;

END $$
DELIMITER ;

# Create the procedure so that the Golang Script can update the record each time a user is successfully updated.

		DROP PROCEDURE IF EXISTS `ut_update_unit_mefe_api_reply`;
	
DELIMITER $$
CREATE PROCEDURE `ut_update_unit_mefe_api_reply`()
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN

# This procedure needs the following variables:
#	- @update_unit_request_id
#	- @updated_datetime (a TIMESTAMP)

	# We need to capture the MEFE user ID of the updater

		SET @updated_by_id := (SELECT `updated_by_id`
			FROM `ut_map_external_source_units` 
			WHERE `id_map` = @update_unit_request_id
			);

	# Is it a success or an error?

		SET @is_mefe_api_success := (IF (@mefe_api_error_message = ''
				, 1
				, 0
				)
			);

	# Now we can do the update

		UPDATE `ut_map_external_source_units`
		SET 
			`is_update_needed` := 0
			, `syst_updated_datetime` := @updated_datetime
			, `update_system_id` := 2
			, `updated_by_id` := @updated_by_id
			, `update_method` := 'ut_update_unit_mefe_api_reply'
			, `is_mefe_api_success` := @is_mefe_api_success
			, `mefe_api_error_message` := @mefe_api_error_message
			WHERE `id_map` = @update_unit_request_id
		;

END $$
DELIMITER ;

# Create the procedure so that the Golang Script can update the record each time a user is successfully updated.

		DROP PROCEDURE IF EXISTS `ut_update_user_mefe_api_reply`;
	
DELIMITER $$
CREATE PROCEDURE `ut_update_user_mefe_api_reply`()
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN

# This procedure needs the following variables:
#	- @update_user_request_id
#	- @updated_datetime (a TIMESTAMP)
#	- @mefe_api_error_message


	# We need to capture the MEFE user ID of the updater

		SET @updated_by_id := (SELECT `updated_by_id`
			FROM `ut_map_external_source_users` 
			WHERE `id_map` = @update_user_request_id
			);

	# Is it a success or an error?

		SET @is_mefe_api_success := (IF (@mefe_api_error_message = ''
				, 1
				, 0
				)
			);

	# Now we can do the update

		UPDATE `ut_map_external_source_users`
		SET 
			`is_update_needed` := 0
			, `syst_updated_datetime` := @updated_datetime
			, `update_system_id` := 2
			, `updated_by_id` := @updated_by_id
			, `update_method` := 'ut_update_user_mefe_api_reply'
			, `is_mefe_api_success` := @is_mefe_api_success
			, `mefe_api_error_message` := @mefe_api_error_message
			WHERE `id_map` = @update_user_request_id
		;

END $$
DELIMITER ;

    # Create the procedure so that the Golang Script can update the record each time a user is successfully updated.

		DROP PROCEDURE IF EXISTS `ut_remove_user_role_association_mefe_api_reply`;
	
DELIMITER $$
CREATE PROCEDURE `ut_remove_user_role_association_mefe_api_reply`()
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN

# This procedure needs the following variables:
#	- @remove_user_from_unit_request_id 
#	- @updated_datetime (a TIMESTAMP)
#	- @mefe_api_error_message

	# We need to capture the MEFE user ID of the updater

		SET @updated_by_id := (SELECT `updated_by_id`
			FROM `ut_map_user_permissions_unit_all` 
			WHERE `id_map_user_unit_permissions` = @remove_user_from_unit_request_id
			);

	# Is it a success or an error?

		SET @is_mefe_api_success := (IF (@mefe_api_error_message = ''
				, 1
				, 0
				)
			);

	# Now we can do the update

		UPDATE `ut_map_user_permissions_unit_all`
		SET 
			`is_update_needed` := 0
			, `syst_updated_datetime` := @updated_datetime
			, `update_system_id` := 2
			, `updated_by_id` := @updated_by_id
			, `unee_t_update_ts` := @updated_datetime
			, `update_method` := 'ut_remove_user_role_association_mefe_api_reply'
			, `is_mefe_api_success` := @is_mefe_api_success
			, `mefe_api_error_message` := @mefe_api_error_message
			WHERE `id_map_user_unit_permissions` = @remove_user_from_unit_request_id
		;

END $$
DELIMITER ;

#####################
#
# Ad hoc procedures
#
#####################

	# Edge case - the lambda has failed and we need to trigger it one more time

		DROP PROCEDURE IF EXISTS `retry_create_user`;
	
DELIMITER $$
CREATE PROCEDURE `retry_create_user`()
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN

# This procedure 
#	- checks all the users with no MEFE ID in the table `ut_map_external_source_users`
#	- Delete these users in the table `ut_map_external_source_users`
#	- 

		# Create a table with all the records with no MEFE user_id in the table `ut_map_external_source_users`

			DROP TABLE IF EXISTS `temp_table_retry_mefe_user_creation`;

			CREATE TABLE `temp_table_retry_mefe_user_creation`
			AS 
			SELECT * 
				FROM `ut_map_external_source_users`
				WHERE `unee_t_mefe_user_id` IS NULL
			;

		# We delete all the record in the table `ut_map_external_source_users` where we have no MEFE_user_id

			DELETE FROM `ut_map_external_source_users`
			WHERE `unee_t_mefe_user_id` IS NULL
			;

		# We insert the failed record again in the table `Condominium` - this re-fires the lambdas to create these users

			INSERT INTO `ut_map_external_source_users`
			SELECT * 
			FROM 
			`temp_table_retry_mefe_user_creation`
			;

		# Clean up - Remove the temp table

			DROP TABLE IF EXISTS `temp_table_retry_mefe_user_creation`;

END $$
DELIMITER ;
