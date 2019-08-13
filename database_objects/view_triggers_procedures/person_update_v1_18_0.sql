#################
#
# This lists all the triggers we use to 
# update a person
# via the Unee-T Enterprise Interface
#
#################
#
#
# This script creates the follwoing objects:
#	- `ut_update_external_person_not_ut_user_type`
#	- `ut_update_external_person_ut_user_type`
#	- ``
#


# We create a trigger when we udpate the `external_persons` table
# AND this is NOT an update of the field `unee_t_user_type_id`

	DROP TRIGGER IF EXISTS `ut_update_external_person_not_ut_user_type`;

DELIMITER $$
CREATE TRIGGER `ut_update_external_person_not_ut_user_type`
AFTER UPDATE ON `external_persons`
FOR EACH ROW
BEGIN

# We only do this if we have 
#	- We need to create the record in Unee-T
#	- We havea valid MEFE user ID for the system that updated this record
# 	- We have an email address
#	- We have an external id
#	- We have an external table
#	- We have an external sytem
#	- This is NOT an update of the field `unee_t_user_type_id`
#	- This is a valid update method:
#		- 'imported_from_hmlet_ipi'
#		- 'Manage_Unee_T_Users_Add_Page'
#		- 'Manage_Unee_T_Users_Edit_Page'
#		- 'Manage_Unee_T_Users_Import_Page'
#		- 'Export_and_Import_Users_Import_Page'
#		- ''

	SET @is_creation_needed_in_unee_t := NEW.`is_unee_t_account_needed` ;

	SET @source_system_creator := NEW.`created_by_id` ;
	SET @source_system_updater := NEW.`updated_by_id`;

	SET @updater_mefe_user_id_person_update_1 := (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_updater
		)
		;

	SET @upstream_create_method := NEW.`creation_method` ;
	SET @upstream_update_method := NEW.`update_method` ;
	
	SET @email := NEW.`email` ;
	SET @external_id := NEW.`external_id` ;
	SET @external_system := NEW.`external_system` ; 
	SET @external_table := NEW.`external_table` ;

	SET @old_unee_t_user_type_id := (IFNULL (OLD.`unee_t_user_type_id` 
			, 0
			)
		);
	SET @unee_t_user_type_id := NEW.`unee_t_user_type_id` ;

	SET @new_person_status_id := NEW.`person_status_id` ;

	IF @is_creation_needed_in_unee_t = 1
		AND @updater_mefe_user_id_person_update_1 IS NOT NULL
		AND @email IS NOT NULL
		AND @external_id IS NOT NULL
		AND @external_system IS NOT NULL
		AND @external_table IS NOT NULL
		AND @old_unee_t_user_type_id = @unee_t_user_type_id
		AND (@upstream_update_method = 'imported_from_hmlet_ipi'
			OR @upstream_update_method = 'Manage_Unee_T_Users_Add_Page'
			OR @upstream_update_method = 'Manage_Unee_T_Users_Edit_Page'
			OR @upstream_update_method = 'Manage_Unee_T_Users_Import_Page'
			OR @upstream_update_method = 'Export_and_Import_Users_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate:

		SET @this_trigger := 'ut_update_external_person_not_ut_user_type' ;

		SET @syst_created_datetime := NOW();
		SET @creation_system_id := (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator
			)
			;
		SET @created_by_id := @updater_mefe_user_id_person_update_1 ;
		SET @downstream_creation_method := @this_trigger ;

		SET @syst_updated_datetime := NOW();
		SET @update_system_id :=  (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater
			)
			;
		SET @updated_by_id := @updater_mefe_user_id_person_update_1 ;
		SET @downstream_update_method := @this_trigger ;

		SET @organization_id_create := @source_system_creator ;
		SET @organization_id_update := @source_system_updater ;

		SET @person_status_id := NEW.`person_status_id` ;
		SET @dupe_id := NEW.`dupe_id` ;
		SET @handler_id := NEW.`handler_id` ;

		SET @is_unee_t_account_needed := @is_creation_needed_in_unee_t ;

		SET @country_code := NEW.`country_code` ;
		SET @gender := NEW.`gender` ;
		SET @given_name := NEW.`given_name` ;
		SET @middle_name := NEW.`middle_name` ;
		SET @family_name := NEW.`family_name` ;
		SET @date_of_birth := NEW.`date_of_birth` ;
		SET @alias := NEW.`alias` ;
		SET @job_title := NEW.`job_title` ;
		SET @organization := NEW.`organization` ;
		SET @email := NEW.`email` ;
		SET @tel_1 := NEW.`tel_1` ;
		SET @tel_2 := NEW.`tel_2` ;
		SET @whatsapp := NEW.`whatsapp` ;
		SET @linkedin := NEW.`linkedin` ;
		SET @facebook := NEW.`facebook` ;
		SET @adr1 := NEW.`adr1` ;
		SET @adr2 := NEW.`adr2` ;
		SET @adr3 := NEW.`adr3` ;
		SET @City := NEW.`City` ;
		SET @zip_postcode := NEW.`zip_postcode` ;
		SET @region_or_state := NEW.`region_or_state` ;
		SET @country := NEW.`country` ;
		
		# We Update the record in the table `persons`

			INSERT INTO `persons`
				(`external_id`
				, `external_system` 
				, `external_table`
				, `syst_created_datetime`
				, `creation_system_id`
				, `created_by_id`
				, `creation_method`
				, `organization_id`
				, `person_status_id`
				, `dupe_id`
				, `handler_id`
				, `is_unee_t_account_needed`
				, `unee_t_user_type_id`
				, `country_code`
				, `gender`
				, `given_name`
				, `middle_name`
				, `family_name`
				, `date_of_birth`
				, `alias`
				, `job_title`
				, `organization`
				, `email`
				, `tel_1`
				, `tel_2`
				, `whatsapp`
				, `linkedin`
				, `facebook`
				, `adr1`
				, `adr2`
				, `adr3`
				, `City`
				, `zip_postcode`
				, `region_or_state`
				, `country`
				)
				VALUES
					(@external_id
					, @external_system
					, @external_table
					, @syst_created_datetime
					, @creation_system_id
					, @created_by_id
					, 'person_update_method_1'
					, @organization_id_update
					, @person_status_id
					, @dupe_id
					, @handler_id
					, @is_unee_t_account_needed
					, @unee_t_user_type_id
					, @country_code
					, @gender
					, @given_name
					, @middle_name
					, @family_name
					, @date_of_birth
					, @alias
					, @job_title
					, @organization
					, @email
					, @tel_1
					, @tel_2
					, @whatsapp
					, @linkedin
					, @facebook
					, @adr1
					, @adr2
					, @adr3
					, @City
					, @zip_postcode
					, @region_or_state
					, @country
					)
				ON DUPLICATE KEY UPDATE
					`syst_updated_datetime` := @syst_updated_datetime
					, `update_system_id` := @update_system_id
					, `updated_by_id` := @updated_by_id
					, `update_method` := 'person_update_method_2'
					, `organization_id` := @organization_id_update
					, `person_status_id` := @person_status_id
					, `dupe_id` := @dupe_id
					, `handler_id` := @handler_id
					, `is_unee_t_account_needed` := @is_unee_t_account_needed
					, `unee_t_user_type_id` := @unee_t_user_type_id
					, `country_code` := @country_code
					, `gender` := @gender
					, `given_name` := @given_name
					, `middle_name` := @middle_name
					, `family_name` := @family_name
					, `date_of_birth` := @date_of_birth
					, `alias` := @alias
					, `job_title` := @job_title
					, `organization` := @organization
					, `email` := @email
					, `tel_1` := @tel_1
					, `tel_2` := @tel_2
					, `whatsapp` := @whatsapp
					, `linkedin` := @linkedin
					, `facebook` := @facebook
					, `adr1` := @adr1
					, `adr2` := @adr2
					, `adr3` := @adr3
					, `City` := @City
					, `zip_postcode` := @zip_postcode
					, `region_or_state` := @region_or_state
					, `country` := @country
				;

		# We check if we need to create this user in the table `ut_map_external_source_users`
		
			SET @new_is_unee_t_account_needed_up_1 := NEW.`is_unee_t_account_needed`;
			SET @old_is_unee_t_account_needed_up_1 := OLD.`is_unee_t_account_needed`;

			SET @uneet_login_name := @email ;
	
			SET @is_update_needed_up_1 := 1 ;

			SET @person_id_up_1 := (SELECT `id_person` 
				FROM `persons`
				WHERE `external_id` = @external_id
					AND `external_system` = @external_system
					AND `external_table` = @external_table
					AND `organization_id` = @organization_id_update
				)
				;

			SET @mefe_user_id := (SELECT `unee_t_mefe_user_id`
				FROM `ut_map_external_source_users`
				WHERE `external_person_id` = @external_id
					AND `external_system` = @external_system
					AND `table_in_external_system` = @external_table
					AND `organization_id` = @organization_id_update
				)
				;

			SET @record_in_table = (SELECT `id_map` 
				FROM `ut_map_external_source_users`
				WHERE `external_person_id` = @external_id
					AND `external_system` = @external_system
					AND `table_in_external_system` = @external_table
					AND `organization_id` = @organization_id_update
				)
				;

			IF (@mefe_user_id IS NULL
				AND @is_unee_t_account_needed = 1
				AND @email IS NOT NULL
				)
			THEN 

			# We insert a new record in the table `ut_map_external_source_users`

				INSERT INTO `ut_map_external_source_users`
					( `syst_created_datetime`
					, `creation_system_id`
					, `created_by_id`
					, `creation_method`
					, `organization_id`
					, `is_update_needed`
					, `person_id`
					, `uneet_login_name`
					, `external_person_id`
					, `external_system`
					, `table_in_external_system`
					)
					VALUES
						(@syst_created_datetime
						, @creation_system_id
						, @created_by_id
						, 'person_update_method_3'
						, @organization_id_update
						, @is_update_needed
						, @person_id_up_1
						, @uneet_login_name
						, @external_id
						, @external_system
						, @external_table
						)
						ON DUPLICATE KEY UPDATE
							`syst_updated_datetime` := @syst_created_datetime
							, `update_system_id` := @creation_system_id
							, `updated_by_id` := @created_by_id
							, `update_method` := 'person_update_method_4'
							, `organization_id` := @organization_id_update
							, `uneet_login_name` := @uneet_login_name
							, `is_update_needed` := @is_update_needed_up_1
					;

			ELSEIF (@mefe_user_id IS NOT NULL
				AND @is_unee_t_account_needed = 1
				AND @record_in_table IS NOT NULL
				AND @email IS NOT NULL
				)
			THEN 

			SET @requestor_id := @updated_by_id ;

			SET @person_id := (SELECT `id_person` 
				FROM `persons`
				WHERE `external_id` = @external_id
					AND `external_system` = @external_system
					AND `external_table` = @external_table
					AND `organization_id` = @organization_id_update
				)
				;

			# We update the existing record in the table `ut_map_external_source_users`

				UPDATE `ut_map_external_source_users`
					SET
						`syst_updated_datetime` := @syst_updated_datetime
						, `update_system_id` := @update_system_id
						, `updated_by_id` := @updated_by_id
						, `update_method` := 'update method 3'
						# @downstream_update_method
						, `organization_id` := @organization_id_update
						, `is_update_needed` := @is_update_needed_up_1
						, `uneet_login_name` := @uneet_login_name
					WHERE `unee_t_mefe_user_id` = @mefe_user_id
					;

			# We call the procedure that calls the lambda to update the user record in Unee-T
			# This procedure needs to following variables:
			#	- @requestor_id : the MEFE user Id for the generic user for the organization
			#	- @person_id : Id for the person we are updating.

				CALL `ut_update_user`;

			# We check if the new status of the user is active or not.

				SET @check_if_active_person_status := (SELECT `is_active`
					FROM `person_statuses`
					WHERE `id_person_status` = @new_person_status_id
					);

			# IF this is an INACTIVE status, THEN we remove the user from all the units.

				IF @check_if_active_person_status = 0
				THEN

					# A user might exist in different organization, we do this ONLY for untis in this organization!
					# We remove the user from all the Level 1 properties:

						DELETE `external_map_user_unit_role_permissions_level_1` 
						FROM `external_map_user_unit_role_permissions_level_1`
						WHERE 
							`external_map_user_unit_role_permissions_level_1`.`unee_t_mefe_user_id` = @mefe_user_id
							AND `organization_id` = @organization_id_update
							;

					# We remove the user from all the Level 2 properties:
						DELETE `external_map_user_unit_role_permissions_level_2` 
						FROM `external_map_user_unit_role_permissions_level_2`
						WHERE 
							`external_map_user_unit_role_permissions_level_2`.`unee_t_mefe_user_id` = @mefe_user_id
							AND `organization_id` = @organization_id_update
							;

					# We remove the user from all the Level 3 properties:

						DELETE `external_map_user_unit_role_permissions_level_3`
						FROM `external_map_user_unit_role_permissions_level_3`
						WHERE 
							`external_map_user_unit_role_permissions_level_3`.`unee_t_mefe_user_id` = @mefe_user_id
							AND `organization_id` = @organization_id_update
							;

				END IF;

			END IF;

	END IF;
END;
$$
DELIMITER ;

# We create a trigger when we udpate the `external_persons` table
# AND this IS an update of the field `unee_t_user_type_id`

		DROP TRIGGER IF EXISTS `ut_update_external_person_ut_user_type`;

DELIMITER $$
CREATE TRIGGER `ut_update_external_person_ut_user_type`
AFTER UPDATE ON `external_persons`
FOR EACH ROW
BEGIN

# We only do this if we have 
#	- We need to create the record in Unee-T
#	- We havea valid MEFE user ID for the system that updated this record
# 	- We have an email address
#	- We have an external id
#	- We have an external table
#	- We have an external sytem
#	- This IS an update of the field `unee_t_user_type_id`
#	- This is a valid update method:
#		- 'imported_from_hmlet_ipi'
#		- 'Manage_Unee_T_Users_Add_Page'
#		- 'Manage_Unee_T_Users_Edit_Page'
#		- 'Manage_Unee_T_Users_Import_Page'
#		- 'Export_and_Import_Users_Import_Page'
#		- ''

	SET @is_creation_needed_in_unee_t := NEW.`is_unee_t_account_needed` ;

	SET @source_system_creator := NEW.`created_by_id` ;
	SET @source_system_updater := NEW.`updated_by_id`;

	SET @updater_mefe_user_id_person_update_2 := (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_updater
		)
		;

	SET @upstream_create_method := NEW.`creation_method` ;
	SET @upstream_update_method := NEW.`update_method` ;
	
	SET @email := NEW.`email` ;
	SET @external_id := NEW.`external_id` ;
	SET @external_system := NEW.`external_system` ; 
	SET @external_table := NEW.`external_table` ;

	SET @old_unee_t_user_type_id := (IFNULL (OLD.`unee_t_user_type_id` 
			, 0
			)
		);
	SET @unee_t_user_type_id := NEW.`unee_t_user_type_id` ;

	SET @new_person_status_id := NEW.`person_status_id` ;

	IF @updater_mefe_user_id_person_update_2 IS NOT NULL
		AND @email IS NOT NULL
		AND @external_id IS NOT NULL
		AND @external_system IS NOT NULL
		AND @external_table IS NOT NULL
		AND @old_unee_t_user_type_id != @unee_t_user_type_id
		AND (@upstream_update_method = 'imported_from_hmlet_ipi'
			OR @upstream_update_method = 'Manage_Unee_T_Users_Add_Page'
			OR @upstream_update_method = 'Manage_Unee_T_Users_Edit_Page'
			OR @upstream_update_method = 'Manage_Unee_T_Users_Import_Page'
			OR @upstream_update_method = 'Export_and_Import_Users_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate:

		SET @this_trigger := 'ut_update_external_person_ut_user_type' ;

		SET @syst_created_datetime := NOW();
		SET @creation_system_id := (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator
			)
			;
		SET @created_by_id := @updater_mefe_user_id_person_update_2 ;
		SET @downstream_creation_method := @this_trigger ;

		SET @syst_updated_datetime := NOW();
		SET @update_system_id :=  (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater
			)
			;
		SET @updated_by_id := @updater_mefe_user_id_person_update_2 ;
		SET @downstream_update_method := @this_trigger ;

		SET @organization_id_create := @source_system_creator ;
		SET @organization_id_update := @source_system_updater ;

		SET @person_status_id := NEW.`person_status_id` ;
		SET @dupe_id := NEW.`dupe_id` ;
		SET @handler_id := NEW.`handler_id` ;

		SET @is_unee_t_account_needed := @is_creation_needed_in_unee_t ;

		SET @country_code := NEW.`country_code` ;
		SET @gender := NEW.`gender` ;
		SET @given_name := NEW.`given_name` ;
		SET @middle_name := NEW.`middle_name` ;
		SET @family_name := NEW.`family_name` ;
		SET @date_of_birth := NEW.`date_of_birth` ;
		SET @alias := NEW.`alias` ;
		SET @job_title := NEW.`job_title` ;
		SET @organization := NEW.`organization` ;
		SET @email := NEW.`email` ;
		SET @tel_1 := NEW.`tel_1` ;
		SET @tel_2 := NEW.`tel_2` ;
		SET @whatsapp := NEW.`whatsapp` ;
		SET @linkedin := NEW.`linkedin` ;
		SET @facebook := NEW.`facebook` ;
		SET @adr1 := NEW.`adr1` ;
		SET @adr2 := NEW.`adr2` ;
		SET @adr3 := NEW.`adr3` ;
		SET @City := NEW.`City` ;
		SET @zip_postcode := NEW.`zip_postcode` ;
		SET @region_or_state := NEW.`region_or_state` ;
		SET @country := NEW.`country` ;
		
		# We Update the record in the table `persons`

			INSERT INTO `persons`
				(`external_id`
				, `external_system` 
				, `external_table`
				, `syst_created_datetime`
				, `creation_system_id`
				, `created_by_id`
				, `creation_method`
				, `organization_id`
				, `person_status_id`
				, `dupe_id`
				, `handler_id`
				, `is_unee_t_account_needed`
				, `unee_t_user_type_id`
				, `country_code`
				, `gender`
				, `given_name`
				, `middle_name`
				, `family_name`
				, `date_of_birth`
				, `alias`
				, `job_title`
				, `organization`
				, `email`
				, `tel_1`
				, `tel_2`
				, `whatsapp`
				, `linkedin`
				, `facebook`
				, `adr1`
				, `adr2`
				, `adr3`
				, `City`
				, `zip_postcode`
				, `region_or_state`
				, `country`
				)
				VALUES
					(@external_id
					, @external_system
					, @external_table
					, @syst_created_datetime
					, @creation_system_id
					, @created_by_id
					, 'person_update_method_5'
					, @organization_id_update
					, @person_status_id
					, @dupe_id
					, @handler_id
					, @is_unee_t_account_needed
					, @unee_t_user_type_id
					, @country_code
					, @gender
					, @given_name
					, @middle_name
					, @family_name
					, @date_of_birth
					, @alias
					, @job_title
					, @organization
					, @email
					, @tel_1
					, @tel_2
					, @whatsapp
					, @linkedin
					, @facebook
					, @adr1
					, @adr2
					, @adr3
					, @City
					, @zip_postcode
					, @region_or_state
					, @country
					)
				ON DUPLICATE KEY UPDATE
					`syst_updated_datetime` := @syst_updated_datetime
					, `update_system_id` := @update_system_id
					, `updated_by_id` := @updated_by_id
					, `update_method` := 'person_update_method_6'
					, `organization_id` := @organization_id_update
					, `person_status_id` := @person_status_id
					, `dupe_id` := @dupe_id
					, `handler_id` := @handler_id
					, `is_unee_t_account_needed` := @is_unee_t_account_needed
					, `unee_t_user_type_id` := @unee_t_user_type_id
					, `country_code` := @country_code
					, `gender` := @gender
					, `given_name` := @given_name
					, `middle_name` := @middle_name
					, `family_name` := @family_name
					, `date_of_birth` := @date_of_birth
					, `alias` := @alias
					, `job_title` := @job_title
					, `organization` := @organization
					, `email` := @email
					, `tel_1` := @tel_1
					, `tel_2` := @tel_2
					, `whatsapp` := @whatsapp
					, `linkedin` := @linkedin
					, `facebook` := @facebook
					, `adr1` := @adr1
					, `adr2` := @adr2
					, `adr3` := @adr3
					, `City` := @City
					, `zip_postcode` := @zip_postcode
					, `region_or_state` := @region_or_state
					, `country` := @country
				;

		# We check if we need to create this user in the table `ut_map_external_source_users`
		
			SET @new_is_unee_t_account_needed_up_2 := NEW.`is_unee_t_account_needed`;
			SET @old_is_unee_t_account_needed_up_2 := OLD.`is_unee_t_account_needed`;

			SET @uneet_login_name := @email ;
	
			SET @is_update_needed_up_2 := 1 ;

			SET @person_id_up_2 := (SELECT `id_person` 
				FROM `persons`
				WHERE `external_id` = @external_id
					AND `external_system` = @external_system
					AND `external_table` = @external_table
					AND `organization_id` = @organization_id_update
				)
				;

			SET @mefe_user_id := (SELECT `unee_t_mefe_user_id`
				FROM `ut_map_external_source_users`
				WHERE `external_person_id` = @external_id
					AND `external_system` = @external_system
					AND `table_in_external_system` = @external_table
					AND `organization_id` = @organization_id_update
				)
				;

		SET @record_in_table = (SELECT `id_map` 
			FROM `ut_map_external_source_users`
			WHERE `external_person_id` = @external_id
				AND `external_system` = @external_system
				AND `table_in_external_system` = @external_table
				AND `organization_id` = @organization_id_update
			)
			;

			IF @is_unee_t_account_needed = 1 
				AND @mefe_user_id IS NULL
				AND @email IS NOT NULL
			THEN 

			# We insert a new record in the table `ut_map_external_source_users`

				INSERT INTO `ut_map_external_source_users`
					( `syst_created_datetime`
					, `creation_system_id`
					, `created_by_id`
					, `creation_method`
					, `organization_id`
					, `is_update_needed`
					, `person_id`
					, `uneet_login_name`
					, `external_person_id`
					, `external_system`
					, `table_in_external_system`
					)
					VALUES
						(@syst_created_datetime
						, @creation_system_id
						, @created_by_id
						, 'person_update_method_7'
						, @organization_id_update
						, @is_update_needed
						, @person_id_up_2
						, @uneet_login_name
						, @external_id
						, @external_system
						, @external_table
						)
						ON DUPLICATE KEY UPDATE
							`syst_updated_datetime` := @syst_created_datetime
							, `update_system_id` := @creation_system_id
							, `updated_by_id` := @created_by_id
							, `update_method` := 'person_update_method_8'
							, `organization_id` := @organization_id_update
							, `uneet_login_name` := @uneet_login_name
							, `is_update_needed` := @is_update_needed_up_2
					;

			ELSEIF @is_unee_t_account_needed = 1
				AND @mefe_user_id IS NOT NULL
				AND @record_in_table IS NOT NULL
				AND @email IS NOT NULL
			THEN 

			SET @requestor_id := @updated_by_id ;

			SET @person_id := (SELECT `id_person` 
				FROM `persons`
				WHERE `external_id` = @external_id
					AND `external_system` = @external_system
					AND `external_table` = @external_table
					AND `organization_id` = @organization_id_update
				)
				;

			# We update the existing record in the table `ut_map_external_source_users`

				UPDATE `ut_map_external_source_users`
					SET
						`syst_updated_datetime` := @syst_updated_datetime
						, `update_system_id` := @update_system_id
						, `updated_by_id` := @updated_by_id
						, `update_method` := 'person_update_method_9'
						, `organization_id` := @organization_id_update
						, `is_update_needed` := @is_update_needed_up_2
						, `uneet_login_name` := @uneet_login_name
					WHERE `person_id` = @person_id
					;

			# We call the procedure that calls the lambda to update the user record in Unee-T
			# This procedure needs to following variables:
			#	- @requestor_id : the MEFE user Id for the generic user for the organization
			#	- @person_id : Id for the person we are updating.

				CALL `ut_update_user`;

			# We check if the new status of the user is active or not.

				SET @check_if_active_person_status := (SELECT `is_active`
					FROM `person_statuses`
					WHERE `id_person_status` = @new_person_status_id
					);

			# IF this is an INACTIVE status, THEN we remove the user from all the units.

				IF @check_if_active_person_status = 0
				THEN

					# A user might exist in different organization, we do this ONLY for untis in this organization!
					# We remove the user from all the Level 1 properties:

						DELETE `external_map_user_unit_role_permissions_level_1` 
						FROM `external_map_user_unit_role_permissions_level_1`
						WHERE 
							`external_map_user_unit_role_permissions_level_1`.`unee_t_mefe_user_id` = @mefe_user_id
							AND `organization_id` = @organization_id_update
							;

					# We remove the user from all the Level 2 properties:
						DELETE `external_map_user_unit_role_permissions_level_2` 
						FROM `external_map_user_unit_role_permissions_level_2`
						WHERE 
							`external_map_user_unit_role_permissions_level_2`.`unee_t_mefe_user_id` = @mefe_user_id
							AND `organization_id` = @organization_id_update
							;

					# We remove the user from all the Level 3 properties:

						DELETE `external_map_user_unit_role_permissions_level_3`
						FROM `external_map_user_unit_role_permissions_level_3`
						WHERE 
							`external_map_user_unit_role_permissions_level_3`.`unee_t_mefe_user_id` = @mefe_user_id
							AND `organization_id` = @organization_id_update
							;
			# IF this is an ACTIVE status, THEN we add the user to all the unit he/she belongs to.

				ELSEIF @check_if_active_person_status = 1
				THEN

					# We call the procedure to check and assign all properties to this user if needed
					# This procedure needs the following variables:
					#	- @requestor_id : the MEFE user Id for the generic user for the organization
					#	- @person_id : Id for the person we are updating.
					#
					# The procedure will check if the new user_type for this user 
					# grants access to all the units in the organization
					# if this is true then we will assign this user to all the units in the organization

						SET @person_id = (SELECT `id_person` 
							FROM `persons`
							WHERE `external_id` = @external_id
								AND `external_system` = @external_system
								AND `external_table` = @external_table
								AND `organization_id` = @organization_id_update
							)
							;
						SET @requestor_id = @updater_mefe_user_id_person_update_1;

						CALL `ut_bulk_assign_units_to_a_user` ;

				END IF;

			END IF;

	END IF;
END;
$$
DELIMITER ;

