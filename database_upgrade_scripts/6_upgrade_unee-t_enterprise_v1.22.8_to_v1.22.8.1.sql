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
	SET @new_schema_version := 'v1.22.8.1';

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
#
#WIP	- When we create a new organization, we make sure that
#		- we automatically create the MEFE user.
#		  The script is `organization_creation_v1_22_8_1.sql`
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
		ADD COLUMN `default_role_type_id` mediumint(9) unsigned   NULL COMMENT 'A FK to the table `ut_user_role_types` - what is the default role type for this organization' after `country_code` , 
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

#	- When we create a new organization, we make sure that
#	  we automatically create the MEFE user.
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
				(CONCAT (0
					, '-'
					, @organization_id
					)
				, 'Setup'
				, 'Setup'
				, NOW()
				, 0
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

	END;
	$$
	DELIMITER ;

# We update the trigger to create a new person to make sure it can handle the creation of SuperAdmins



















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