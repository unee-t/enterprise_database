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

	SET @old_schema_version := 'v1.22.8';
	SET @new_schema_version := 'v1.22.8.1_alpha_2';

# What is the name of this script?

	SET @this_script := CONCAT ('upgrade_unee-t_entreprise', @old_schema_version, '_to_', @new_schema_version, '.sql');

# In this update
#
#WIP	- Fix issue `sub-query returns more than one result`
#
#OK	- Alter the table `ut_user_types` to add a new boolean `super_admin`
#OK	- Alter the table `uneet_enterprise_organizations` to
#OK		- Add the default role type 
#OK		- Add the country code record the default role type for that organization.
#OK		- Add the information to find the master MEFE user for that organization
#
#OK - Add the view to facilitate selection of default users for each role
#
#OK	- When we create a new organization, we make sure that
#		  We automatically create 
#OK			- The MEFE user type 'super admin' for this organization
#OK			- the MEFE user.
#OK		- The Default Unee-T user type for this role type
#OK		- The UNTE API key for that organizations
#
#OK	- Re-write the view `ut_organization_mefe_user_id` 
#	  this is to make it easier to get the MEFE information for MEFE Master user
#	  WARNING - this new methid will need us to manually update the hmlet UNTE account
#			We need to create the Master MEFE user for that account in UNTE.
#
#OK	- Udpdate the lambda calls: it's not necessary to have a creator to create a new user.
#	  this WILL create a problem if we need to update one of the master user via MEFE API
#	  this is OK as we should NEVER update one of the master user via MEFE API
#
###############################
#
# We have everything we need - Do it!
#
###############################

# When are we doing this?

	SET @the_timestamp := NOW();

# Do the changes:

#	The change is done by running the script `person_creation_v1_22_8_1.sql`

# We need to alter the table ut_user_types`

	/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;

	/* Foreign Keys must be dropped in the target to ensure that requires changes can be done*/

	ALTER TABLE `ut_user_types` 
		DROP FOREIGN KEY `user_type_created_by`  , 
		DROP FOREIGN KEY `user_type_organization_id`  , 
		DROP FOREIGN KEY `user_type_updated_by`  , 
		DROP FOREIGN KEY `user_type_user_role_id`  ;


	/* Alter table in target */
	ALTER TABLE `ut_user_types` 
		ADD COLUMN `is_super_admin` tinyint(4)   NULL DEFAULT 0 COMMENT '1 if this is a SuperAdmin user for that organization.' after `ut_user_role_type_id` , 
		CHANGE `is_all_unit` `is_all_unit` tinyint(1)   NULL DEFAULT 0 COMMENT '1 if we want to assign all units in the organization to this role. All properties in all the countries and all the Areas will be automatically added.' after `is_super_admin` ; 

	/* The foreign keys that were dropped are now re-created*/

	ALTER TABLE `ut_user_types` 
		ADD CONSTRAINT `user_type_created_by` 
		FOREIGN KEY (`organization_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `user_type_organization_id` 
		FOREIGN KEY (`organization_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `user_type_updated_by` 
		FOREIGN KEY (`organization_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `user_type_user_role_id` 
		FOREIGN KEY (`ut_user_role_type_id`) REFERENCES `ut_user_role_types` (`id_role_type`) ON UPDATE CASCADE ;

	/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;

# For an organization
#	- Add the default role type 
#	- Add the country code

	/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;

	/* Foreign Keys must be dropped in the target to ensure that requires changes can be done*/

	ALTER TABLE `uneet_enterprise_organizations` 
		DROP FOREIGN KEY `organization_default_area_must_exist`  , 
		DROP FOREIGN KEY `organization_default_building_must_exist`  , 
		DROP FOREIGN KEY `organization_default_unit_must_exist`  ;


	/* Alter table in target */
	ALTER TABLE `uneet_enterprise_organizations` 
		ADD COLUMN `country_code` varchar(10)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The 2 letter version of the country code' after `description` , 
		ADD COLUMN `mefe_master_user_external_person_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The external ID of the person in table `external_persons`' after `country_code` , 
		ADD COLUMN `mefe_master_user_external_person_table` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The external table where this person record is coming from' after `mefe_master_user_external_person_id` , 
		ADD COLUMN `mefe_master_user_external_person_system` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The external system this person record is coming from' after `mefe_master_user_external_person_table` , 
		ADD COLUMN `default_role_type_id` mediumint(9) unsigned   NULL COMMENT 'A FK to the table `ut_user_role_types` - what is the default role type for this organization' after `mefe_master_user_external_person_system` , 
		CHANGE `default_sot_system` `default_sot_system` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL DEFAULT 'system' COMMENT 'The Default source of truth for that organization' after `default_role_type_id` , 
		ADD KEY `organization_default_role_type_must_exist`(`default_role_type_id`) ;
	ALTER TABLE `uneet_enterprise_organizations`
		ADD CONSTRAINT `organization_default_role_type_must_exist` 
		FOREIGN KEY (`default_role_type_id`) REFERENCES `ut_user_role_types` (`id_role_type`) ON UPDATE CASCADE ;
	

	/* The foreign keys that were dropped are now re-created*/

	ALTER TABLE `uneet_enterprise_organizations` 
		ADD CONSTRAINT `organization_default_area_must_exist` 
		FOREIGN KEY (`default_area`) REFERENCES `ut_map_external_source_units` (`unee_t_mefe_unit_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `organization_default_building_must_exist` 
		FOREIGN KEY (`default_building`) REFERENCES `ut_map_external_source_units` (`unee_t_mefe_unit_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `organization_default_unit_must_exist` 
		FOREIGN KEY (`default_unit`) REFERENCES `ut_map_external_source_units` (`unee_t_mefe_unit_id`) ON UPDATE CASCADE ;

	/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;

# Add the view to facilitate selection of default users for each role

	DROP VIEW IF EXISTS `ut_list_possible_assignees` ;

	CREATE VIEW `ut_list_possible_assignees`
	AS 
	SELECT
	    `a`.`unee_t_mefe_user_id`
	    , `a`.`is_obsolete`
	    , `a`.`organization_id`
	    , `a`.`person_id`
	    , `b`.`given_name`
	    , `b`.`family_name`
	    , `b`.`alias`
	    , `b`.`email`
	    , CONCAT( `b`.`given_name`
		, IF(`b`.`alias` IS NULL
			, ' '
			, IF(`b`.`alias` = ''
				, ' ' 
				, CONCAT(' ('
					, `b`.`alias`
					, ') '
					)
				)
			)
		, `b`.`family_name`
		) AS `person_designation`
	FROM
	    `ut_map_external_source_users` AS `a`
	    INNER JOIN `persons` AS `b`
		ON (`a`.`person_id` = `b`.`id_person`)
	WHERE (`a`.`is_obsolete` = 0
		AND `a`.`unee_t_mefe_user_id` IS NOT NULL)
	;

# re-write the view `ut_organization_mefe_user_id` 
# this is to make it easir to get the MEFE information for MEFE Master user
# We create a view to list the ACTIVE MEFE User Id by organization

	DROP VIEW IF EXISTS `ut_organization_mefe_user_id` ;

	CREATE VIEW `ut_organization_mefe_user_id`
	AS
	SELECT
	    `b`.`id_organization` AS `organization_id`
	    , `b`.`designation`
	    , `a`.`unee_t_mefe_user_id` AS `mefe_user_id`
	    , `a`.`unee_t_mefe_user_api_key`
	FROM
	    `ut_map_external_source_users` AS `a`
	    INNER JOIN `uneet_enterprise_organizations` AS `b`
		ON (`a`.`organization_id` = `b`.`id_organization`) 
		AND (`a`.`external_person_id` = `b`.`mefe_master_user_external_person_id`) 
		AND (`a`.`table_in_external_system` = `b`.`mefe_master_user_external_person_table`) 
		AND (`a`.`external_system` = `b`.`mefe_master_user_external_person_system`)
	;

#	- When we create a new organization, we make sure that
#	  we automatically
#		- The MEFE user type 'super admin' for this organization
#		- the MEFE user.
#		- The Default Area
#	  The script is `organization_creation_v1_22_8_1.sql`

	#################
	#
	# This lists all the triggers we use to 
	# create all the objects we need when we create a new organization
	# via the Unee-T Enterprise Interface
	#
	#################

	# We create a trigger when a record is added to the `external_persons` table

		DROP TRIGGER IF EXISTS `ut_after_insert_new_organization`;

DELIMITER $$
CREATE TRIGGER `ut_after_insert_new_organization`
AFTER INSERT ON `uneet_enterprise_organizations`
FOR EACH ROW
BEGIN

	# We always do this:

		# we get the id of the organization that was just created

			SET @organization_id = NEW.`id_organization` ;

		# We get the role type that we will use:

			SET @default_ut_user_role_type_id_new_organization = NEW.`default_role_type_id` ;

		# The designation for the role type

			SET @role_type_designation := (SELECT `role_type`
				FROM `ut_user_role_types`
				WHERE `id_role_type` = @default_ut_user_role_type_id_new_organization
				)
				;

		# What is the default coutry for this organization:

			SET @default_country_code_new_organization = NEW.`country_code` ;

		# What is the name of the new organization

			SET @new_organization_name = NEW.`designation` ;

	# First we need to create a new user type for the SuperAdmin for this organization

		INSERT INTO `ut_user_types`(
			`id_unee_t_user_type`
			,`syst_created_datetime`
			,`creation_system_id`
			,`created_by_id`
			,`creation_method`
			,`organization_id`
			,`order`
			,`is_obsolete`
			,`designation`
			,`description`
			,`ut_user_role_type_id`
			, `is_super_admin`
			) 
			VALUES
				(0
				, NOW()
				,'Setup'
				,0
				,'trigger_ut_after_insert_new_organization'
				, @organization_id
				,NULL
				,0
				,'Super Admin'
				,'The main MEFE Unee-T user associated to this UNTE account'
				, @default_ut_user_role_type_id_new_organization
				, 1
				)
			;

		# We capture the ID of this new user type we just created
		
			SET @last_inserted_user_type_id = LAST_INSERT_ID();

	# we need to generate an API key for the organization

		INSERT INTO `ut_api_keys`
			(`syst_created_datetime`
			,`creation_system_id`
			,`created_by_id`
			,`creation_method`
			,`is_obsolete`
			,`api_key`
			,`organization_id`
			) 
			VALUES
				(NOW()
				, 'Setup'
				, @organization_id
				,'trigger_ut_after_insert_new_organization'
				, 0
				, UUID()
				, @organization_id
				)
			;

	# Add a new record in the table `external_persons` so we can create a MEFE user for that organization.
	# This will automatically create a new MEFE user id.

		INSERT INTO `external_persons`
			(`external_id`
			,`external_system`
			,`external_table`
			,`syst_created_datetime`
			,`creation_system_id`
			,`created_by_id`
			,`creation_method`
			,`person_status_id`
			,`is_unee_t_account_needed`
			,`unee_t_user_type_id`
			,`country_code`
			,`given_name`
			,`family_name`
			,`email`
			) 
			VALUES
				# IF YOU CHANGE THE BELOW LINE YOU NEED TO UPDATE THE
				# PHPR EVENT Add Page >> After record added
				# FOR THE PHPR VIEW `Super Admin - Manage Organization`
				(CONCAT (0
					, '-'
					, @organization_id
					)
				# IF YOU CHANGE THE BELOW LINE YOU NEED TO UPDATE THE
				# PHPR EVENT Add Page >> After record added
				# FOR THE PHPR VIEW `Super Admin - Manage Organization
				, 'Setup'
				# IF YOU CHANGE THE BELOW LINE YOU NEED TO UPDATE THE
				# PHPR EVENT Add Page >> After record added
				# FOR THE PHPR VIEW `Super Admin - Manage Organization
				, 'Setup'
				, NOW()
				, 'Setup'
				, @organization_id
				, 'trigger_ut_after_insert_new_organization'
				, 2
				, 1
				, @last_inserted_user_type_id
				, @default_country_code_new_organization
				, 'Master User MEFE'
				, @new_organization_name
				, CONCAT ('superadmin.unte'
					, '+'
					, @organization_id
					, '@unee-t.com'
					)
				)
			;

		# WIP - We need to record the id of that person so we can access the 
		# MEFE user ID for that person
		# This is a key information to create unee-t objects as this organization


	# We need to create a default Unee-T user type for this organization:

		INSERT INTO `ut_user_types`
			(`syst_created_datetime`
			,`creation_system_id`
			,`created_by_id`
			,`creation_method`
			,`organization_id`
			,`order`
			,`is_obsolete`
			,`designation`
			,`description`
			,`ut_user_role_type_id`
			,`is_super_admin`
			,`is_public`
			,`is_default_assignee`
			,`is_default_invited`
			, `is_dashboard_access`
			, `can_see_role_mgt_cny`
			, `can_see_occupant`
			, `can_see_role_landlord`
			, `can_see_role_agent`
			, `can_see_role_tenant`
			) 
			VALUES
				(NOW()
				, 'Setup'
				, @organization_id
				, 'trigger_ut_after_insert_new_organization'
				, @organization_id
				, 0
				, 0
				, CONCAT ('Default Public User - '
					, @role_type_designation
					)
				, CONCAT ('Use this for the public account for the role '
					, @role_type_designation
					, '. This is the user people will report issue to by default'
					)
				, @default_ut_user_role_type_id_new_organization
				, 0
				, 1
				, 1
				, 1
				, 1
				, 1
				, 1
				, 1
				, 1
				, 1
				)
				;

END;
$$
DELIMITER ;

# We update the trigger to create a new person to make sure it can handle 
# the creation of Master MEFE user for a given organization

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
			AND @email IS NOT NULL
			AND @external_id IS NOT NULL
			AND @external_system IS NOT NULL
			AND @external_table IS NOT NULL
			AND (@upstream_create_method = 'imported_from_hmlet_ipi'
				OR @upstream_create_method = 'Manage_Unee_T_Users_Add_Page'
				OR @upstream_create_method = 'Manage_Unee_T_Users_Edit_Page'
				OR @upstream_create_method = 'Manage_Unee_T_Users_Import_Page'
				OR @upstream_create_method = 'trigger_ut_after_insert_new_organization'
				OR @upstream_update_method = 'imported_from_hmlet_ipi'
				OR @upstream_update_method = 'Manage_Unee_T_Users_Add_Page'
				OR @upstream_update_method = 'Manage_Unee_T_Users_Edit_Page'
				OR @upstream_update_method = 'Manage_Unee_T_Users_Import_Page'
				)
		THEN 

		# We are in the main scenario, we are NOT creating a SuperAdmin for UNTE
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

# We update the trigger to create a new area to make sure it can handle 
# the creation of the default Area for a given organization
# The script is `properties_areas_creation_update_v1_22_8_1`

	#################
	#
	# This lists all the triggers we use to create 
	# an area
	# via the Unee-T Enterprise Interface
	#
	#################

	# We create a trigger when a record is added to the `external_property_groups_areas` table

		DROP TRIGGER IF EXISTS `ut_insert_external_area`;

DELIMITER $$
CREATE TRIGGER `ut_insert_external_area`
AFTER INSERT ON `external_property_groups_areas`
FOR EACH ROW
BEGIN

	# We only do this if 
	#	- We need to create the area in Unee-T
	#	  by default we should create ALL areas but we want maximum flexibility here...
	#	- This is a valid insert method:
	#		- 'imported_from_hmlet_ipi'
	#		- `Manage_Areas_Add_Page`
	#		- `Manage_Areas_Edit_Page`
	#		- 'Manage_Areas_Import_Page'
	#		- 'Export_and_Import_Areas_Import_Page'
	#		- 'trigger_ut_after_insert_new_organization'
	#		- ''

		SET @is_creation_needed_in_unee_t_insert_ext_area_1 = NEW.`is_creation_needed_in_unee_t` ;

		SET @source_system_creator_insert_ext_area_1 = NEW.`created_by_id` ;
		SET @source_system_updater_insert_ext_area_1 = NEW.`updated_by_id`;

		SET @creator_mefe_user_id_insert_ext_area_1 = (SELECT `mefe_user_id` 
			FROM `ut_organization_mefe_user_id`
			WHERE `organization_id` = @source_system_creator_insert_ext_area_1
			)
			;

		SET @upstream_create_method_insert_ext_area_1 = NEW.`creation_method` ;
		SET @upstream_update_method_insert_ext_area_1 = NEW.`update_method` ;

		SET @external_id_insert_ext_area_1 = NEW.`external_id` ;
		SET @external_system_id_insert_ext_area_1 = NEW.`external_system_id` ; 
		SET @external_table_insert_ext_area_1 = NEW.`external_table` ;

		IF @is_creation_needed_in_unee_t_insert_ext_area_1 = 1
			AND @external_id_insert_ext_area_1 IS NOT NULL
			AND @external_system_id_insert_ext_area_1 IS NOT NULL
			AND @external_table_insert_ext_area_1 IS NOT NULL
			AND (@upstream_create_method_insert_ext_area_1 = 'imported_from_hmlet_ipi'
				OR @upstream_create_method_insert_ext_area_1 = 'Manage_Areas_Add_Page'
				OR @upstream_create_method_insert_ext_area_1 = 'Manage_Areas_Edit_Page'
				OR @upstream_create_method_insert_ext_area_1 = 'Manage_Areas_Import_Page'
				OR @upstream_create_method_insert_ext_area_1 = 'Export_and_Import_Areas_Import_Page'
				OR @upstream_create_method_insert_ext_area_1 = 'trigger_ut_after_insert_new_organization'
				OR @upstream_update_method_insert_ext_area_1 = 'imported_from_hmlet_ipi'
				OR @upstream_update_method_insert_ext_area_1 = 'Manage_Areas_Add_Page'
				OR @upstream_update_method_insert_ext_area_1 = 'Manage_Areas_Edit_Page'
				OR @upstream_update_method_insert_ext_area_1 = 'Manage_Areas_Import_Page'
				OR @upstream_update_method_insert_ext_area_1 = 'Export_and_Import_Areas_Import_Page'
				)
		THEN 

		# We capture the values we need for the insert/udpate to the `property_groups_areas` table:

			SET @this_trigger_insert_ext_area_1 = 'ut_insert_external_area' ;

			SET @syst_created_datetime_insert_ext_area_1 = NOW();
			SET @creation_system_id_insert_ext_area_1 = (SELECT `id_external_sot_for_unee_t` 
				FROM `ut_external_sot_for_unee_t_objects`
				WHERE `organization_id` = @source_system_creator_insert_ext_area_1
				)
				;
			SET @created_by_id_insert_ext_area_1 = @creator_mefe_user_id_insert_ext_area_1 ;
			SET @downstream_creation_method_insert_ext_area_1 = @this_trigger_insert_ext_area_1 ;

			SET @syst_updated_datetime_insert_ext_area_1 = NOW();

			SET @source_system_updater_insert_ext_area_1 = NEW.`updated_by_id` ; 

			SET @update_system_id_insert_ext_area_1 = (SELECT `id_external_sot_for_unee_t` 
				FROM `ut_external_sot_for_unee_t_objects`
				WHERE `organization_id` = @source_system_updater_insert_ext_area_1
				)
				;
			SET @updated_by_id_insert_ext_area_1 = @creator_mefe_user_id_insert_ext_area_1 ;
			SET @downstream_update_method_insert_ext_area_1 = @this_trigger_insert_ext_area_1 ;

			SET @organization_id_create_insert_ext_area_1 = @source_system_creator_insert_ext_area_1 ;
			SET @organization_id_update_insert_ext_area_1 = @source_system_updater_insert_ext_area_1 ;

			SET @country_code_insert_ext_area_1 = NEW.`country_code` ;
			SET @is_obsolete_insert_ext_area_1 = NEW.`is_obsolete` ;
			SET @is_default_insert_ext_area_1 = NEW.`is_default` ;
			SET @order_insert_ext_area_1 = NEW.`order` ;
			SET @area_name_insert_ext_area_1 = NEW.`area_name` ;
			SET @area_definition_insert_ext_area_1 = NEW.`area_definition` ;

		# We insert the record in the table `property_groups_areas`

				INSERT INTO `property_groups_areas`
					(`external_id`
					, `external_system_id` 
					, `external_table`
					, `syst_created_datetime`
					, `creation_system_id`
					, `created_by_id`
					, `creation_method`
					, `organization_id`
					, `country_code`
					, `is_obsolete`
					, `is_default`
					, `order`
					, `area_name`
					, `area_definition`
					)
					VALUES
						(@external_id_insert_ext_area_1
						, @external_system_id_insert_ext_area_1
						, @external_table_insert_ext_area_1
						, @syst_created_datetime_insert_ext_area_1
						, @creation_system_id_insert_ext_area_1
						, @created_by_id_insert_ext_area_1
						, @downstream_creation_method_insert_ext_area_1
						, @organization_id_create_insert_ext_area_1
						, @country_code_insert_ext_area_1
						, @is_obsolete_insert_ext_area_1
						, @is_default_insert_ext_area_1
						, @order_insert_ext_area_1
						, @area_name_insert_ext_area_1
						, @area_definition_insert_ext_area_1
						)
					ON DUPLICATE KEY UPDATE
						`syst_updated_datetime` = @syst_updated_datetime_insert_ext_area_1
						, `update_system_id` = @update_system_id_insert_ext_area_1
						, `updated_by_id` = @updated_by_id_insert_ext_area_1
						, `update_method` = @downstream_update_method_insert_ext_area_1
						, `country_code` = @country_code_insert_ext_area_1
						, `is_obsolete` = @is_obsolete_insert_ext_area_1
						, `is_default` = @is_default_insert_ext_area_1
						, `order` = @order_insert_ext_area_1
						, `area_definition` = @area_definition_insert_ext_area_1
						, `area_name` = @area_name_insert_ext_area_1
					;

		END IF;

END;
$$
DELIMITER ;

	# We create a trigger when a record is updated in the `external_property_groups_areas` table
	# The area DOES exist in the table `property_groups_areas`

		DROP TRIGGER IF EXISTS `ut_update_external_area`;

DELIMITER $$
CREATE TRIGGER `ut_update_external_area`
AFTER UPDATE ON `external_property_groups_areas`
FOR EACH ROW
BEGIN

	# We only do this if 
	#	- We need to create the area in Unee-T
	#	  by default we should create ALL areas but we want maximum flexibility here...
	#	- This is a valid update method:
	#		- 'imported_from_hmlet_ipi'
	#		- `Manage_Areas_Add_Page`
	#		- `Manage_Areas_Edit_Page`
	#		- 'Manage_Areas_Import_Page'
	#		- 'Export_and_Import_Areas_Import_Page'
	#		- ''

		SET @is_creation_needed_in_unee_t_update_ext_area_1 = NEW.`is_creation_needed_in_unee_t` ;

		SET @source_system_creator_update_ext_area_1 = NEW.`created_by_id` ;
		SET @source_system_updater_update_ext_area_1 = NEW.`updated_by_id`;

		SET @creator_mefe_user_id_update_ext_area_1 = (SELECT `mefe_user_id` 
			FROM `ut_organization_mefe_user_id`
			WHERE `organization_id` = @source_system_creator_update_ext_area_1
			)
			;

		SET @upstream_create_method_update_ext_area_1 = NEW.`creation_method` ;
		SET @upstream_update_method_update_ext_area_1 = NEW.`update_method` ;
		
		SET @organization_id_update_ext_area_1 = @source_system_creator_update_ext_area_1 ;

		SET @external_id_update_ext_area_1 = NEW.`external_id` ;
		SET @external_system_id_update_ext_area_1 = NEW.`external_system_id` ; 
		SET @external_table_update_ext_area_1 = NEW.`external_table` ;

		SET @new_is_creation_needed_in_unee_t_update_ext_area_1 = NEW.`is_creation_needed_in_unee_t` ;
		SET @old_is_creation_needed_in_unee_t_update_ext_area_1 = OLD.`is_creation_needed_in_unee_t` ;

		IF @is_creation_needed_in_unee_t_update_ext_area_1 = 1
			AND @new_is_creation_needed_in_unee_t_update_ext_area_1 = @old_is_creation_needed_in_unee_t_update_ext_area_1
			AND @external_id_update_ext_area_1 IS NOT NULL
			AND @external_system_id_update_ext_area_1 IS NOT NULL
			AND @external_table_update_ext_area_1 IS NOT NULL
			AND @organization_id_update_ext_area_1 IS NOT NULL
			AND (@upstream_update_method_update_ext_area_1 = 'imported_from_hmlet_ipi'
				OR @upstream_update_method_update_ext_area_1 = 'Manage_Areas_Add_Page'
				OR @upstream_update_method_update_ext_area_1 = 'Manage_Areas_Edit_Page'
				OR @upstream_update_method_update_ext_area_1 = 'Manage_Areas_Import_Page'
				OR @upstream_update_method_update_ext_area_1 = 'Export_and_Import_Areas_Import_Page'
				)
		THEN 

		# We capture the values we need for the insert/udpate to the `property_groups_areas` table:

			SET @this_trigger_update_ext_area_1 = 'ut_update_external_area' ;

			SET @record_to_update_update_ext_area_1 = (SELECT `id_area`
				FROM `property_groups_areas`
				WHERE `external_id` = @external_id_update_ext_area_1
					AND `external_system_id` = @external_system_id_update_ext_area_1
					AND `external_table` = @external_table_update_ext_area_1
					AND `organization_id` = @organization_id_update_ext_area_1
				);

			SET @syst_updated_datetime_update_ext_area_1 = NOW();

			SET @source_system_updater_update_ext_area_1 = NEW.`updated_by_id` ; 

			SET @update_system_id_update_ext_area_1 = (SELECT `id_external_sot_for_unee_t` 
				FROM `ut_external_sot_for_unee_t_objects`
				WHERE `organization_id` = @source_system_updater_update_ext_area_1
				)
				;
			SET @updated_by_id_update_ext_area_1 = @creator_mefe_user_id_update_ext_area_1 ;
			SET @downstream_update_method_update_ext_area_1 = @this_trigger_update_ext_area_1 ;

			SET @organization_id_create_update_ext_area_1 = @source_system_creator_update_ext_area_1 ;
			SET @organization_id_update_update_ext_area_1 = @source_system_updater_update_ext_area_1 ;

			SET @country_code_update_ext_area_1 = NEW.`country_code` ;
			SET @is_obsolete_update_ext_area_1 = NEW.`is_obsolete` ;
			SET @is_default_update_ext_area_1 = NEW.`is_default` ;
			SET @order_update_ext_area_1 = NEW.`order` ;
			SET @area_name_update_ext_area_1 = NEW.`area_name` ;
			SET @area_definition_update_ext_area_1 = NEW.`area_definition` ;

		# We update the record in the table `property_groups_areas`
		
			UPDATE `property_groups_areas`
			SET
				`syst_updated_datetime` = @syst_updated_datetime_update_ext_area_1
				, `update_system_id` = @update_system_id_update_ext_area_1
				, `updated_by_id` = @updated_by_id_update_ext_area_1
				, `update_method` = @downstream_update_method_update_ext_area_1
				, `country_code` = @country_code_update_ext_area_1
				, `is_obsolete` = @is_obsolete_update_ext_area_1
				, `is_default` = @is_default_update_ext_area_1
				, `order` = @order_update_ext_area_1
				, `area_definition` = @area_definition_update_ext_area_1
				, `area_name` = @area_name_update_ext_area_1
				WHERE `id_area` = @record_to_update_update_ext_area_1
				;

		END IF;

END;
$$
DELIMITER ;

	# We create a trigger when a record is updated in the `external_property_groups_areas` table
	# AND the area is marked as needed to be created in Unee-T
	# The area does NOT exists in the table `property_groups_areas`

		DROP TRIGGER IF EXISTS `ut_created_external_area_after_insert`;

DELIMITER $$
CREATE TRIGGER `ut_created_external_area_after_insert`
AFTER UPDATE ON `external_property_groups_areas`
FOR EACH ROW
BEGIN

	# We only do this if:
	#	- We need to create the area in Unee-T
	#	  by default we should create ALL areas but we want maximum flexibility here...
	#	- This is a valid update method:
	#		- 'imported_from_hmlet_ipi'
	#		- `Manage_Areas_Add_Page`
	#		- `Manage_Areas_Edit_Page`
	#		- 'Manage_Areas_Import_Page'
	#		- 'Export_and_Import_Areas_Import_Page'
	#		- ''

		SET @is_creation_needed_in_unee_t_update_ext_area_2 = NEW.`is_creation_needed_in_unee_t` ;

		SET @source_system_creator_update_ext_area_2 = NEW.`created_by_id` ;
		SET @source_system_updater_update_ext_area_2 = NEW.`updated_by_id`;

		SET @creator_mefe_user_id_update_ext_area_2 = (SELECT `mefe_user_id` 
			FROM `ut_organization_mefe_user_id`
			WHERE `organization_id` = @source_system_creator_update_ext_area_2
			)
			;

		SET @upstream_create_method_update_ext_area_2 = NEW.`creation_method` ;
		SET @upstream_update_method_update_ext_area_2 = NEW.`update_method` ;
		
		SET @organization_id_update_ext_area_2 = @source_system_creator_update_ext_area_2 ;

		SET @external_id_update_ext_area_2 = NEW.`external_id` ;
		SET @external_system_id_update_ext_area_2 = NEW.`external_system_id` ; 
		SET @external_table_update_ext_area_2 = NEW.`external_table` ;

		SET @new_is_creation_needed_in_unee_t_update_ext_area_2 = NEW.`is_creation_needed_in_unee_t` ;
		SET @old_is_creation_needed_in_unee_t_update_ext_area_2 = OLD.`is_creation_needed_in_unee_t` ;

		IF @is_creation_needed_in_unee_t_update_ext_area_2 = 1
			AND @new_is_creation_needed_in_unee_t_update_ext_area_2 != @old_is_creation_needed_in_unee_t_update_ext_area_2
			AND @external_id_update_ext_area_2 IS NOT NULL
			AND @external_system_id_update_ext_area_2 IS NOT NULL
			AND @external_table_update_ext_area_2 IS NOT NULL
			AND @organization_id_update_ext_area_2 IS NOT NULL
			AND (@upstream_update_method_update_ext_area_2 = 'imported_from_hmlet_ipi'
				OR @upstream_update_method_update_ext_area_2 = 'Manage_Areas_Add_Page'
				OR @upstream_update_method_update_ext_area_2 = 'Manage_Areas_Edit_Page'
				OR @upstream_update_method_update_ext_area_2 = 'Manage_Areas_Import_Page'
				OR @upstream_update_method_update_ext_area_2 = 'Export_and_Import_Areas_Import_Page'
				)
		THEN 

		# We capture the values we need for the insert/udpate to the `property_groups_areas` table:

			SET @this_trigger_update_ext_area_2 = 'ut_created_external_area_after_insert' ;

			SET @syst_created_datetime_update_ext_area_2 = NOW();
			SET @creation_system_id_update_ext_area_2 = (SELECT `id_external_sot_for_unee_t` 
				FROM `ut_external_sot_for_unee_t_objects`
				WHERE `organization_id` = @source_system_creator_update_ext_area_2
				)
				;
			SET @created_by_id_update_ext_area_2 = @creator_mefe_user_id_update_ext_area_2 ;
			SET @downstream_creation_method_update_ext_area_2 = @this_trigger_update_ext_area_2 ;

			SET @syst_updated_datetime_update_ext_area_2 = NOW();

			SET @source_system_updater_update_ext_area_2 = NEW.`updated_by_id` ; 

			SET @update_system_id_update_ext_area_2 = (SELECT `id_external_sot_for_unee_t` 
				FROM `ut_external_sot_for_unee_t_objects`
				WHERE `organization_id` = @source_system_updater_update_ext_area_2
				)
				;
			SET @updated_by_id_update_ext_area_2 = @creator_mefe_user_id_update_ext_area_2 ;
			SET @downstream_update_method_update_ext_area_2 = @this_trigger_update_ext_area_2 ;

			SET @organization_id_create_update_ext_area_2 = @source_system_creator_update_ext_area_2 ;
			SET @organization_id_update_update_ext_area_2 = @source_system_updater_update_ext_area_2 ;

			SET @country_code_update_ext_area_2 = NEW.`country_code` ;
			SET @is_obsolete_update_ext_area_2 = NEW.`is_obsolete` ;
			SET @is_default_update_ext_area_2 = NEW.`is_default` ;
			SET @order_update_ext_area_2 = NEW.`order` ;
			SET @area_name_update_ext_area_2 = NEW.`area_name` ;
			SET @area_definition_update_ext_area_2 = NEW.`area_definition` ;

		# We insert the record in the table `property_groups_areas`

				INSERT INTO `property_groups_areas`
					(`external_id`
					, `external_system_id` 
					, `external_table`
					, `syst_created_datetime`
					, `creation_system_id`
					, `created_by_id`
					, `creation_method`
					, `is_creation_needed_in_unee_t`
					, `organization_id`
					, `country_code`
					, `is_obsolete`
					, `is_default`
					, `order`
					, `area_name`
					, `area_definition`
					)
					VALUES
						(@external_id_update_ext_area_2
						, @external_system_id_update_ext_area_2
						, @external_table_update_ext_area_2
						, @syst_created_datetime_update_ext_area_2
						, @creation_system_id_update_ext_area_2
						, @created_by_id_update_ext_area_2
						, @downstream_creation_method_update_ext_area_2
						, @is_creation_needed_in_unee_t_update_ext_area_2
						, @organization_id_create_update_ext_area_2
						, @country_code_update_ext_area_2
						, @is_obsolete_update_ext_area_2
						, @is_default_update_ext_area_2
						, @order_update_ext_area_2
						, @area_name_update_ext_area_2
						, @area_definition_update_ext_area_2
						)
					ON DUPLICATE KEY UPDATE
						`syst_updated_datetime` = @syst_updated_datetime_update_ext_area_2
						, `update_system_id` = @update_system_id_update_ext_area_2
						, `updated_by_id` = @updated_by_id_update_ext_area_2
						, `update_method` = @downstream_update_method_update_ext_area_2
						, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t_update_ext_area_2
						, `organization_id` = @organization_id_update_update_ext_area_2
						, `country_code` = @country_code_update_ext_area_2
						, `is_obsolete` = @is_obsolete_update_ext_area_2
						, `is_default` = @is_default_update_ext_area_2
						, `order` = @order_update_ext_area_2
						, `area_definition` = @area_definition_update_ext_area_2
						, `area_name` = @area_name_update_ext_area_2
					;

		END IF;

END;
$$
DELIMITER ;














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