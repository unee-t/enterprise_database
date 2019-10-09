#################
#
# This lists all the triggers we use to 
# create a person
# via the Unee-T Enterprise Interface
#
#################

# We create a trigger when a record is added to the `external_persons` table

	DROP TRIGGER IF EXISTS `ut_insert_external_person`;

DELIMITER $$
CREATE TRIGGER `ut_insert_external_person`
AFTER INSERT ON `external_persons`
FOR EACH ROW
BEGIN

# We only do this if:
#	- We need to create the record in Unee-T
#	- We havea valid MEFE user ID for the system that created this record
# 	- We have an email address
#	- We have an external id
#	- We have an external table
#	- We have an external sytem
#	- This is a valid insert method:
#		- 'imported_from_hmlet_ipi'
#		- 'Manage_Unee_T_Users_Add_Page'
#		- 'Manage_Unee_T_Users_Edit_Page'
#		- 'Manage_Unee_T_Users_Import_Page'
#		- 'Super Admin - Manage MEFE Master User'
#		- ''

	SET @is_unee_t_account_needed = NEW.`is_unee_t_account_needed` ;

	SET @source_system_creator = NEW.`created_by_id` ;
	SET @source_system_updater = NEW.`updated_by_id`;

	SET @creator_mefe_user_id = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator
		)
		;

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;
	
	SET @email = NEW.`email` ;
	SET @external_id = NEW.`external_id` ;
	SET @external_system = NEW.`external_system` ; 
	SET @external_table = NEW.`external_table` ;

	IF @is_unee_t_account_needed = 1
		AND @creator_mefe_user_id IS NOT NULL
		AND @email IS NOT NULL
		AND @external_id IS NOT NULL
		AND @external_system IS NOT NULL
		AND @external_table IS NOT NULL
		AND (@upstream_create_method = 'imported_from_hmlet_ipi'
			OR @upstream_create_method = 'Manage_Unee_T_Users_Add_Page'
			OR @upstream_create_method = 'Manage_Unee_T_Users_Edit_Page'
			OR @upstream_create_method = 'Manage_Unee_T_Users_Import_Page'
			OR @upstream_create_method = 'Super Admin - Manage MEFE Master User'
			OR @upstream_update_method = 'imported_from_hmlet_ipi'
			OR @upstream_update_method = 'Manage_Unee_T_Users_Add_Page'
			OR @upstream_update_method = 'Manage_Unee_T_Users_Edit_Page'
			OR @upstream_update_method = 'Manage_Unee_T_Users_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `persons` table:

		SET @this_trigger = 'ut_insert_external_person' ;

		SET @syst_created_datetime = NOW();
		SET @creation_system_id = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator
			)
			;
		SET @created_by_id = @creator_mefe_user_id ;
		SET @downstream_creation_method = @this_trigger ;

		SET @syst_updated_datetime = NOW();

		SET @source_system_updater = NEW.`updated_by_id` ; 

		SET @update_system_id = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater
			)
			;
		SET @updated_by_id = @creator_mefe_user_id ;
		SET @downstream_update_method = @this_trigger ;

		SET @organization_id_create = @source_system_creator;
		SET @organization_id_update = @source_system_creator;

		SET @person_status_id = NEW.`person_status_id` ;
		SET @dupe_id = NEW.`dupe_id` ;
		SET @handler_id = NEW.`handler_id` ;

		SET @unee_t_user_type_id = NEW.`unee_t_user_type_id` ;
		SET @country_code = NEW.`country_code` ;
		SET @gender = NEW.`gender` ;
		SET @given_name = NEW.`given_name` ;
		SET @middle_name = NEW.`middle_name` ;
		SET @family_name = NEW.`family_name` ;
		SET @date_of_birth = NEW.`date_of_birth` ;
		SET @alias = NEW.`alias` ;
		SET @job_title = NEW.`job_title` ;
		SET @organization = NEW.`organization` ;
		SET @email = NEW.`email` ;
		SET @tel_1 = NEW.`tel_1` ;
		SET @tel_2 = NEW.`tel_2` ;
		SET @whatsapp = NEW.`whatsapp` ;
		SET @linkedin = NEW.`linkedin` ;
		SET @facebook = NEW.`facebook` ;
		SET @adr1 = NEW.`adr1` ;
		SET @adr2 = NEW.`adr2` ;
		SET @adr3 = NEW.`adr3` ;
		SET @City = NEW.`City` ;
		SET @zip_postcode = NEW.`zip_postcode` ;
		SET @region_or_state = NEW.`region_or_state` ;
		SET @country = NEW.`country` ;
		
		# We insert a new record in the table `persons`

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
					, 'person_create_method_1'
					, @organization_id_create
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
					`syst_updated_datetime` = @syst_updated_datetime
					, `update_system_id` = @update_system_id
					, `updated_by_id` = @updated_by_id
					, `update_method` = 'person_create_method_2'
					, `organization_id` = @organization_id_update
					, `person_status_id` = @person_status_id
					, `dupe_id` = @dupe_id
					, `handler_id` = @handler_id
					, `is_unee_t_account_needed` = @is_unee_t_account_needed
					, `unee_t_user_type_id` = @unee_t_user_type_id
					, `country_code` = @country_code
					, `gender` = @gender
					, `given_name` = @given_name
					, `middle_name` = @middle_name
					, `family_name` = @family_name
					, `date_of_birth` = @date_of_birth
					, `alias` = @alias
					, `job_title` = @job_title
					, `organization` = @organization
					, `email` = @email
					, `tel_1` = @tel_1
					, `tel_2` = @tel_2
					, `whatsapp` = @whatsapp
					, `linkedin` = @linkedin
					, `facebook` = @facebook
					, `adr1` = @adr1
					, `adr2` = @adr2
					, `adr3` = @adr3
					, `City` = @City
					, `zip_postcode` = @zip_postcode
					, `region_or_state` = @region_or_state
					, `country` = @country
				;

		# We insert a new record in the table `ut_map_external_source_users`
		# This is the table that triggers the lambda to create the user in Unee-T

			# We get the additional variables we need:

				SET @is_update_needed = NULL;

				SET @person_id = (SELECT `id_person` 
					FROM `persons`
					WHERE `external_id` = @external_id
						AND `external_system` = @external_system
						AND `external_table` = @external_table
						AND `organization_id` = @organization_id_create
					)
					;

			# We do the insert now

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
						, 'person_create_method_3'
						, @organization_id_create
						, @is_update_needed
						, @person_id
						, @email
						, @external_id
						, @external_system
						, @external_table
						)
						ON DUPLICATE KEY UPDATE
							`syst_updated_datetime` = @syst_updated_datetime
							, `update_system_id` = @update_system_id
							, `updated_by_id` = @updated_by_id
							, `update_method` = 'person_create_method_4'
							, `organization_id` = @organization_id_update
							, `uneet_login_name` = @email
							, `is_update_needed` = 1
					;

	END IF;
END;
$$
DELIMITER ;

# Once we have a reply from the MEFE API with a MEFE user ID for that user we can
# assign this user to all the units in the organization
# We do this ONLY if
#	- This is an authorized method
#	- The field `is_all_unit` in the table `ut_user_types` for the user type selected for this user is = 1

	DROP TRIGGER IF EXISTS `ut_after_mefe_user_id_is_created_bulk_assign_user_unit`;

DELIMITER $$
CREATE TRIGGER `ut_after_mefe_user_id_is_created_bulk_assign_user_unit`
AFTER UPDATE ON `ut_map_external_source_users`
FOR EACH ROW
BEGIN

# We do this ONLY if
#	- We have a MEFE user ID for that user
#	- This is an authorized method:
#		- `ut_creation_user_mefe_api_reply`
#		- ``

	SET @unee_t_mefe_user_id := NEW.`unee_t_mefe_user_id` ;

	SET @person_id := NEW.`person_id` ;

	SET @requestor_id = NEW.`updated_by_id` ;

	SET @upstream_update_method := NEW.`update_method` ;

	IF @unee_t_mefe_user_id IS NOT NULL
		AND (@upstream_update_method = 'ut_creation_user_mefe_api_reply'
		)
	THEN 

		# We call the procedure to bulk assign a user to several units.
		# This procedure needs the following variables:
		#	- @requestor_id
		#	- @person_id

		CALL `ut_bulk_assign_units_to_a_user` ;

	END IF;
END;
$$
DELIMITER ;