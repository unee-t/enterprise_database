#
# For any question about this script, ask Franck
#
####################################################################################
#
# We MUST use at least Aurora MySQl 5.7.22+ if you want 
# to be able to use the Lambda function Unee-T depends on to work as intended
#
# Alternativey if you do NOT need to use the Lambda function, it is possible to use
#	- MySQL 5.7.22 +
#	- MariaDb 10.2.3 +
#
####################################################################################
#
####################################################
#
# Make sure to 
#	- update the below variable(s)
#
# For easier readability and maintenance, we use dedicated scripts to 
# Create or update:
#	- Views
#	- Procedures
#	- Triggers
#	- Lambda related objects for the relevant environments
#
# Make sure to run all these scripts too!!!
#
# 
####################################################
#
# What are the version of the Unee-T BZ Database schema BEFORE and AFTER this update?

	SET @old_schema_version := 'v1.22.7';
	SET @new_schema_version := 'v1.22.8_alpha_2';

# What is the name of this script?

	SET @this_script := CONCAT ('upgrade_unee-t_entreprise', @old_schema_version, '_to_', @new_schema_version, '.sql');

# In this update
#
#WIP	- Fix issue `sub-query returns more than one result`
#
#OK	- Update the table `log_lambdas` to make room for error message
#OK	- Add the capability to handle the mefeAPIRequestId as an additional field in the replies from the downstream systems.
#
#OK - Fix bug - Missing mandatory information in the payload for `lambda_update_unit`
#	  You need need to run the upgrade script `8_lambda_related_objects_for_[environment]_v22.8` for the relevant environment to fix that.
#
# - Drop tables we do not need anymore
#	- ``
#	- ``
#
# - Create new tables
#	- ``
#	- ``
#
# - Drop tables we do not need anymore
#	- ``
#	- ``
#
# - Alter a existing tables
#	- Add indexes for improved performances 
#		- ``
#		- ``
#	- Rebuild index for better performances
#		- ``
#		- ``
#	- Remove unnecessary columns
#		- ``
#		- ``
#	- Add a new column
#		- ``
#		- ``
#
# - Drop Views:
#	- ``
#	- ``
#
# - Drop procedures :
#	- ``
#	- ``
#	- ``
#
# - Re-create triggers:
#	- ``
#	- ``
#
#
###############################
#
# We have everything we need - Do it!
#
###############################

# When are we doing this?

	SET @the_timestamp := NOW();

# Do the changes:

	/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;

	/* Alter table in target */
	ALTER TABLE `log_lambdas` 
		ADD COLUMN `error_message` mediumtext  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The error message if we were not able to send a lambda call for this (if applicable)' after `payload` ;

	/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;



#################
#	
# This is part 7
# Procedures to update the Db after downstream system calls back
#
#################

####################################################################
#
#############
#
# CONTEXT
#
#############
#
# The following triggers are used so that we can update the database
# after an action from a downstream system was done
#	- `ut_create_user`
#	- `ut_create_unit`
#	- `ut_add_user_to_role_in_unit_with_visibility`
#	- `ut_after_update_ut_map_external_source_units`
#	- `ut_retry_create_unit`
#	- `ut_retry_assign_user_to_unit`
#
# These triggers are using the following procedures:
#	- `lambda_create_user`
#	- `lambda_create_unit`
#	- `lambda_add_user_to_role_in_unit_with_visibility`
#	- `ut_update_user`
#	- `lambda_update_user_profile` <--- WHY DO WE NEED THAT?
#	- `lambda_update_unit`
#	- `ut_remove_user_from_unit` <--- WHY DO WE NEED THAT?
#	- `lambda_remove_user_from_unit`
#	- `lambda_update_unit_name_type` <--- WHY DO WE NEED THAT?
#
#############
#
# END - CONTEXT
#
#############
#
# With this script We are creating the following procedures:
#	- `ut_creation_user_mefe_api_reply` for `lambda_create_user`
#	- `ut_creation_unit_mefe_api_reply` for `lambda_create_unit`
#	- `ut_creation_user_role_association_mefe_api_reply` for `lambda_add_user_to_role_in_unit_with_visibility`
#	- `ut_update_unit_mefe_api_reply` for `lambda_update_unit`
#	- `ut_update_user_mefe_api_reply` for `lambda_update_user_profile`
#	- `ut_remove_user_role_association_mefe_api_reply` for `lambda_remove_user_from_unit`
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
#	- @mefe_api_request_id

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
			, `create_api_request_id` := @mefe_api_request_id
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
#	- @mefe_api_request_id

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
			, `create_api_request_id` := @mefe_api_request_id
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
#	- @id_map_user_unit_permissions
#	- @creation_datetime 
#	- @mefe_api_error_message
#	- @mefe_api_request_id

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
			, `create_api_request_id` := @mefe_api_request_id
			WHERE `id_map_user_unit_permissions` = @id_map_user_unit_permissions
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
#	- @mefe_api_request_id

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
			, `edit_api_request_id` := @mefe_api_request_id
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
#	- @mefe_api_request_id


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
			, `edit_api_request_id` := @mefe_api_request_id
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
#	- @mefe_api_request_id

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
			, `edit_api_request_id` := @mefe_api_request_id
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




















#
#
#
#
#
#
#
#
#
#
#
#

# We can now update the version of the database schema
	# A comment for the update
		SET @comment_update_schema_version := CONCAT (
			'Database updated from '
			, @old_schema_version
			, ' to '
			, @new_schema_version
		)
		;
	
	# We record that the table has been updated to the new version.
	INSERT INTO `db_schema_version`
		(`schema_version`
		, `update_datetime`
		, `update_script`
		, `comment`
		)
		VALUES
		(@new_schema_version
		, @the_timestamp
		, @this_script
		, @comment_update_schema_version
		)
		;