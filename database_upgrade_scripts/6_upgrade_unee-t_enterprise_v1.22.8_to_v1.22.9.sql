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
	SET @new_schema_version := 'v1.22.9_alpha_1';

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
#OK		- Make sure the default Area ID is in the correct format (int)
#OK		- Add a link to the SoT table to get SoT information for a given organization.
#OK		- DEPRECATE the following fields:
#OK			- `default_area`
#OK			- `default_sot_system`
#OK			- `default_sot_persons`
#OK			- `default_sot_areas`
#OK			- `default_sot_properties`
#
#OK - Alter table `ut_map_external_source_areas`: add information about the default assignee for the property
#		- `mgt_cny_default_assignee`
#		- `landlord_default_assignee`
#		- `tenant_default_assignee`
#		- `agent_default_assignee`

#OK - Alter table `ut_map_external_source_units`: add information about the default assignee for the property
#OK		- `mgt_cny_default_assignee`
#OK		- `landlord_default_assignee`
#OK		- `tenant_default_assignee`
#OK		- `agent_default_assignee`
#OK		- `area_id`
#OK		- Make sure the the key building id/property type is unique!
#
######################################################################################
#
# WARNING 1
#
#
# WE NEED TO MANUALLY UPDATE THE RECORD FOR THE HMLET ORGANIZATION
# WE NEED TO MAKE SURE THAT THE HMLET ORGANIZATION HAS THE FOLLOWING INFO CONFIGURED
#	- `country_code`
#	- `mefe_master_user_external_person_id`
#	- `mefe_master_user_external_person_table`
#	- `mefe_master_user_external_person_system`
#	- `default_role_type_id`
#	- `default_sot_id`
#	- `default_area`
#	- `default_building`
#	- `default_unit`
#
# To do this we need to make sure that we also have a MEFE Master User for Hmlet.
# This user does NOT exist yet!
#
######################################################################################
#
# WARNING 2:
#
#
# WE NEED TO MANUALLY UPDATE THE RECORD FOR THE HMLET ORGANIZATION
# WE NEED TO MAKE SURE THAT THE HMLET ORGANIZATION HAS THE FOLLOWING INFO CONFIGURED
#	- Areas (external_areas, areas, mefe_areas): 
#		- `mgt_cny_default_assignee`
#		- `landlord_default_assignee`
#		- `tenant_default_assignee`
#		- `agent_default_assignee`
#	- L1P (external_L1P, L1P, map_units):
#		- `mgt_cny_default_assignee`
#		- `landlord_default_assignee`
#		- `tenant_default_assignee`
#		- `agent_default_assignee`
#	- L2P (external_L2P, L2P, map_units):
#		- `mgt_cny_default_assignee`
#		- `landlord_default_assignee`
#		- `tenant_default_assignee`
#		- `agent_default_assignee`
#	- L3P (external_L3P, L3P, map_units):
#		- `mgt_cny_default_assignee`
#		- `landlord_default_assignee`
#		- `tenant_default_assignee`
#		- `agent_default_assignee`
#
######################################################################################
#
######################################################################################
#
# WARNING 3:
#
#
# 	We need to look at the code and make sure that 
#	the view `ut_organization_associated_mefe_user` is NOT used anywhere
#
#
######################################################################################
#
#
#OK - Rewrite the views to get the default SoT information:
#	  We need to use the information recorded in the table `uneet_enterprise_organizations`
#	  and use this to find the default SoT for the organization.
#	  We need to alter the views:
#OK		- `ut_organization_default_area`
#OK		- `ut_organization_default_external_system`
#OK		- `ut_organization_default_table_areas`
#OK		- `ut_organization_default_table_level_1_properties`
#OK		- `ut_organization_default_table_level_2_properties`
#OK		- `ut_organization_default_table_level_3_properties`
#OK		- `ut_organization_default_table_persons`
#
#OK	- DROP the view `ut_organization_associated_mefe_user`
#	  This view is similar to the view `ut_organization_mefe_user_id`
#	  We are standardizing and want to use the view `ut_organization_mefe_user_id` everywhere.
#
#OK - Add the view to facilitate selection of default users for each role
#OK		- `ut_list_possible_assignees`
#
#OK Add the view to facilitate the selection of default L1P and default L2P
#OK		- `ut_list_possible_properties`
#
#OK	- Add the views to get the default properties for a given organization
#OK			- `ut_organization_default_L1P`
#OK			- `ut_organization_default_L2P`
#
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
#OK	- Update the lambda calls: it's not necessary to have a creator to create a new user.
#	  this WILL create a problem if we need to update one of the master user via MEFE API
#	  this is OK as we should NEVER update one of the master user via MEFE API
#
#WIP	- Update the routine to create new user (persons)
#	  This is a copy of the script `person_creation_v1_22_9`
#OK		- Create a person with no MEFE user information from the creator
#		  This is needed when we create an organization as SuperAdmin
#WIP		- Make sure that we propagate:
#WIP			- MEFE parent ID if applicable

#
#WIP	- Update the routine to create new areas
#OK			- Merge the 2 update triggers into one
#OK			- Drop uncessary triggers
#OK			- Make sure that we propagate Default assignees
#WIP		- Make sure that we propagate to the table `ut_map_external_source_areas`
#
#WIP - Update the routine to create new L1P. 
#		The script is `properties_level_1_creation_update_v1_22_9`
#OK		- Make sure we use the correct trigger names to create the properties in the table `ut_map_external_source_units`
#OK		- Make sure that we propagate the Default assignees
#OK		- Change how we fetch record when we need to update a record in the table
#		  `ut_map_external_source_units`
#OK		- Add a check to make sure we can get the MEFE unit ID if we need to update
#WIP	- IF we do NOT have a default assignee, 
#		  THEN we use the default assignee for the Area
#
#WIP - Update the routine to create new L2P. 
#		The script is `properties_level_2_creation_update_v1_22_9`
#OK		- Make sure we use the correct trigger names to create the properties in the table `ut_map_external_source_units`
#OK		- Make sure that we propagate the Default assignees
#WIP		- Add a check to make sure we can get the MEFE unit ID if we need to update
#WIP			- IF we do NOT have a default assignee, 
#				  THEN we use the default assignee for the L1P
#
#WIP - Update the routine to create new L3P. 
#		The script is `properties_level_3_creation_update_v1_22_9`
#OK		- Make sure we use the correct trigger names to create the properties in the table `ut_map_external_source_units`
#WIP	- Make sure that we propagate the Default assignees
#WIP		- Add a check to make sure we can get the MEFE unit ID if we need to update
#WIP	- IF we do NOT have a default assignee, 
#		  THEN we use the default assignee for the L2P
#
#OK - Update the lambda triggers to 
#OK		- Make sure we log the error message correctly if lambda is not sent
#WIP	- When we create a property make sure that we use the new 'default assignee' information
#		  when we assign the unit to the default user for a given role.
#
#WIP - Update the trigger after the property is created to
#WIP	- Make sure we create the default assignees if we have the information
#	  We should create AT LEAST ONE default assignee for the property so we can create cases
#
###############################
#
# We have everything we need - Do it!
#
###############################

# When are we doing this?

	SET @the_timestamp := NOW();

# Do the changes:

#	The change is done by running the script `person_creation_v1_22_9.sql`

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
#	- Add the country code record the default role type for that organization.
#	- Add the information to find the master MEFE user for that organization
#	- Make sure the default Area ID is in the correct format (int)
#	- Add a link to the SoT table to get SoT information for a given organization.

	/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;

	/* Foreign Keys must be dropped in the target to ensure that requires changes can be done*/

	ALTER TABLE `uneet_enterprise_organizations` 
		DROP FOREIGN KEY `organization_default_building_must_exist`  , 
		DROP FOREIGN KEY `organization_default_unit_must_exist`  ;


	/* Alter table in target */
	ALTER TABLE `uneet_enterprise_organizations` 
		ADD COLUMN `country_code` varchar(10)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The 2 letter version of the country code' after `description` , 
		ADD COLUMN `mefe_master_user_external_person_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The external ID of the person in table `external_persons`' after `country_code` , 
		ADD COLUMN `mefe_master_user_external_person_table` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The external table where this person record is coming from' after `mefe_master_user_external_person_id` , 
		ADD COLUMN `mefe_master_user_external_person_system` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The external system this person record is coming from' after `mefe_master_user_external_person_table` , 
		ADD COLUMN `default_role_type_id` mediumint(9) unsigned   NULL COMMENT 'A FK to the table `ut_user_role_types` - what is the default role type for this organization' after `mefe_master_user_external_person_system` , 
		ADD COLUMN `default_sot_id` int(11)   NULL COMMENT 'A FK to the table `ut_external_sot_for_unee_t_objects`. The default Source of Truth for the organization.' after `default_role_type_id` , 
		CHANGE `default_area` `default_area` int(11)   NULL COMMENT 'The area ID in the table `external_property_groups_areas` - This is the default area for properties created by this organization' after `default_sot_id` , 
		CHANGE `default_sot_system` `default_sot_system` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL DEFAULT 'system' COMMENT 'DEPRECATED - The Default source of truth for that organization' after `default_unit` , 
		CHANGE `default_sot_persons` `default_sot_persons` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL DEFAULT 'persons' COMMENT 'DEPRECATED - The Default source of truth for that organization for the person records' after `default_sot_system` , 
		CHANGE `default_sot_areas` `default_sot_areas` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL DEFAULT 'areas' COMMENT 'DEPRECATED - The Default source of truth for that organization for the area records' after `default_sot_persons` , 
		CHANGE `default_sot_properties` `default_sot_properties` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL DEFAULT 'properties' COMMENT 'DEPRECATED - The Default source of truth for that organization for the properties records' after `default_sot_areas` , 
		ADD KEY `organization_default_role_type_must_exist`(`default_role_type_id`) , 
		ADD KEY `organization_default_sot_must_exist`(`default_sot_id`) , 
		DROP FOREIGN KEY `organization_default_area_must_exist`  ;
	ALTER TABLE `uneet_enterprise_organizations`
		ADD CONSTRAINT `organization_default_area_must_exist` 
		FOREIGN KEY (`default_area`) REFERENCES `external_property_groups_areas` (`id_area`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `organization_default_role_type_must_exist` 
		FOREIGN KEY (`default_role_type_id`) REFERENCES `ut_user_role_types` (`id_role_type`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `organization_default_sot_must_exist` 
		FOREIGN KEY (`default_sot_id`) REFERENCES `ut_external_sot_for_unee_t_objects` (`id_external_sot_for_unee_t`) ON UPDATE CASCADE ;
	

	/* The foreign keys that were dropped are now re-created*/

	ALTER TABLE `uneet_enterprise_organizations` 
		ADD CONSTRAINT `organization_default_building_must_exist` 
		FOREIGN KEY (`default_building`) REFERENCES `ut_map_external_source_units` (`unee_t_mefe_unit_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `organization_default_unit_must_exist` 
		FOREIGN KEY (`default_unit`) REFERENCES `ut_map_external_source_units` (`unee_t_mefe_unit_id`) ON UPDATE CASCADE ;

	/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;


#OK - Alter table `ut_map_external_source_areas`: add information about the default assignee for the property
#		- `mgt_cny_default_assignee`
#		- `landlord_default_assignee`
#		- `tenant_default_assignee`
#		- `agent_default_assignee`

	/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;

	/* Alter table in target */
	ALTER TABLE `ut_map_external_source_areas` 
		ADD COLUMN `mgt_cny_default_assignee` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'Default Assignee for the role \'Management Company\' - A FK to the table `ut_map_external_source_users`' after `table_in_external_system` , 
		ADD COLUMN `landlord_default_assignee` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'Default Assignee for the role \'landlord\' - A FK to the table `ut_map_external_source_users`' after `mgt_cny_default_assignee` , 
		ADD COLUMN `tenant_default_assignee` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'Default Assignee for the role \'tenant\' - A FK to the table `ut_map_external_source_users`' after `landlord_default_assignee` , 
		ADD COLUMN `agent_default_assignee` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'Default Assignee for the role \'Agent\' - A FK to the table `ut_map_external_source_users`' after `tenant_default_assignee` , 
		ADD KEY `area_mefe_user_id_for_default_assignee_for_agent_must_exist`(`agent_default_assignee`) , 
		ADD KEY `area_mefe_user_id_for_default_assignee_for_landlord_must_exist`(`landlord_default_assignee`) , 
		ADD KEY `area_mefe_user_id_for_default_assignee_for_mgt_cny_must_exist`(`mgt_cny_default_assignee`) , 
		ADD KEY `area_mefe_user_id_for_default_assignee_for_tenant_must_exist`(`tenant_default_assignee`) ;
	ALTER TABLE `ut_map_external_source_areas`
		ADD CONSTRAINT `area_mefe_user_id_for_default_assignee_for_agent_must_exist` 
		FOREIGN KEY (`agent_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `area_mefe_user_id_for_default_assignee_for_landlord_must_exist` 
		FOREIGN KEY (`landlord_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `area_mefe_user_id_for_default_assignee_for_mgt_cny_must_exist` 
		FOREIGN KEY (`mgt_cny_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `area_mefe_user_id_for_default_assignee_for_tenant_must_exist` 
		FOREIGN KEY (`tenant_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE ;
		/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;

#OK - Alter table `ut_map_external_source_units`: add information about the default assignee for the property
#OK		- `mgt_cny_default_assignee`
#OK		- `landlord_default_assignee`
#OK		- `tenant_default_assignee`
#OK		- `agent_default_assignee`
#OK		- `area_id`
#OK		- Make sure the the key building id/property type is unique!

	/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;

	/* Foreign Keys must be dropped in the target to ensure that requires changes can be done*/

	ALTER TABLE `ut_map_external_source_units` 
		DROP FOREIGN KEY `mefe_unit_organization_id`  , 
		DROP FOREIGN KEY `property_property_type`  , 
		DROP FOREIGN KEY `unee_t_valid_unit_type_map_units`  , 
		DROP FOREIGN KEY `unit_mefe_area_id_must_exist`  , 
		DROP FOREIGN KEY `unit_mefe_unit_id_parent_must_exist`  ;

	/* Alter table in target */
	ALTER TABLE `ut_map_external_source_units` 
		ADD COLUMN `area_id` int(11)   NULL COMMENT 'The Area ID. This is a FK to the the table `property_groups_areas`' after `is_update_needed` , 
		CHANGE `mefe_area_id` `mefe_area_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The MEFE ID of the area - This is a FK to the table `ut_map_external_source_areas`' after `area_id` , 
		ADD COLUMN `mgt_cny_default_assignee` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'Default Assignee for the role \'Management Company\' - A FK to the table `ut_map_external_source_users`' after `tower` , 
		ADD COLUMN `landlord_default_assignee` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'Default Assignee for the role \'landlord\' - A FK to the table `ut_map_external_source_users`' after `mgt_cny_default_assignee` , 
		ADD COLUMN `tenant_default_assignee` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'Default Assignee for the role \'tenant\' - A FK to the table `ut_map_external_source_users`' after `landlord_default_assignee` , 
		ADD COLUMN `agent_default_assignee` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'Default Assignee for the role \'Agent\' - A FK to the table `ut_map_external_source_users`' after `tenant_default_assignee` , 
		ADD KEY `prop_area_id_must_exist`(`area_id`) , 
		ADD KEY `prop_mefe_user_id_for_default_assignee_for_agent_must_exist`(`agent_default_assignee`) , 
		ADD KEY `prop_mefe_user_id_for_default_assignee_for_landlord_must_exist`(`landlord_default_assignee`) , 
		ADD KEY `prop_mefe_user_id_for_default_assignee_for_mgt_cny_must_exist`(`mgt_cny_default_assignee`) , 
		ADD KEY `prop_mefe_user_id_for_default_assignee_for_tenant_must_exist`(`tenant_default_assignee`) , 
		ADD UNIQUE KEY `unique_id_by_type_of_property`(`new_record_id`,`external_property_type_id`) ;
	ALTER TABLE `ut_map_external_source_units`
		ADD CONSTRAINT `prop_area_id_must_exist` 
		FOREIGN KEY (`area_id`) REFERENCES `property_groups_areas` (`id_area`) , 
		ADD CONSTRAINT `prop_mefe_user_id_for_default_assignee_for_agent_must_exist` 
		FOREIGN KEY (`agent_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `prop_mefe_user_id_for_default_assignee_for_landlord_must_exist` 
		FOREIGN KEY (`landlord_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `prop_mefe_user_id_for_default_assignee_for_mgt_cny_must_exist` 
		FOREIGN KEY (`mgt_cny_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `prop_mefe_user_id_for_default_assignee_for_tenant_must_exist` 
		FOREIGN KEY (`tenant_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE ;
	

	/* The foreign keys that were dropped are now re-created*/

	ALTER TABLE `ut_map_external_source_units` 
		ADD CONSTRAINT `mefe_unit_organization_id` 
		FOREIGN KEY (`organization_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `property_property_type` 
		FOREIGN KEY (`external_property_type_id`) REFERENCES `ut_property_types` (`id_property_type`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `unee_t_valid_unit_type_map_units` 
		FOREIGN KEY (`unee_t_unit_type`) REFERENCES `ut_unit_types` (`designation`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `unit_mefe_area_id_must_exist` 
		FOREIGN KEY (`mefe_area_id`) REFERENCES `ut_map_external_source_areas` (`mefe_area_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `unit_mefe_unit_id_parent_must_exist` 
		FOREIGN KEY (`mefe_unit_id_parent`) REFERENCES `ut_map_external_source_units` (`unee_t_mefe_unit_id`) ON UPDATE CASCADE ;

	/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;

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

# DROP the view `ut_organization_associated_mefe_user`
#	  This view is similar to the view `ut_organization_mefe_user_id`
#	  We are standardizing and want to use the view `ut_organization_mefe_user_id` everywhere.

	DROP VIEW IF EXISTS `ut_organization_associated_mefe_user` ;

	# We create a view to get the associated MEFE user for each organization
	/*
		DROP VIEW IF EXISTS `ut_organization_associated_mefe_user` ;

		CREATE VIEW `ut_organization_associated_mefe_user`
		AS
		SELECT 
			`mefe_user_id` AS `associated_mefe_user`
			, `organization_id`
		FROM `ut_api_keys`
		;
	*/

# Rewrite the views to get the default SoT information:
#	  We need to use the information recorded in the table `uneet_enterprise_organizations`
#	  and use this to find the default SoT for the organization.
#	  We need to alter the views:
#OK		- `ut_organization_default_area`
#OK		- `ut_organization_default_external_system`
#OK		- `ut_organization_default_table_areas`
#OK		- `ut_organization_default_table_level_1_properties`
#OK		- `ut_organization_default_table_level_2_properties`
#OK		- `ut_organization_default_table_level_3_properties`
#OK		- `ut_organization_default_table_persons`

	# We update the view to get the default area for each organization

		DROP VIEW IF EXISTS `ut_organization_default_area` ;

		CREATE VIEW `ut_organization_default_area`
		AS
		SELECT
			`a`.`id_area` AS `default_area_id`
			, `a`.`area_name` AS `default_area_name`
			, `b`.`id_organization` AS `organization_id`
		FROM
			`external_property_groups_areas` AS `a`
			INNER JOIN `uneet_enterprise_organizations` AS `b`
			ON (`a`.`created_by_id` = `b`.`id_organization`) 
			AND (`a`.`id_area` = `b`.`default_area`)
			;

	# We update the view to get the default external system for each organization

		DROP VIEW IF EXISTS `ut_organization_default_external_system` ;

		CREATE VIEW `ut_organization_default_external_system`
		AS
		SELECT
			`a`.`designation`
			, `b`.`id_organization` AS `organization_id`
		FROM
			`ut_external_sot_for_unee_t_objects` AS `a`
			INNER JOIN `uneet_enterprise_organizations` AS `b`
				ON (`a`.`organization_id` = `b`.`id_organization`) 
				AND (`a`.`id_external_sot_for_unee_t` = `b`.`default_sot_id`)
				;

	# We update the view to get the default table for areas for each organization

		DROP VIEW IF EXISTS `ut_organization_default_table_areas` ;

		CREATE VIEW `ut_organization_default_table_areas`
		AS
		SELECT
			`a`.`area_table`
			, `b`.`id_organization` AS `organization_id`
		FROM
			`ut_external_sot_for_unee_t_objects` AS `a`
			INNER JOIN `uneet_enterprise_organizations` AS `b`
				ON (`a`.`organization_id` = `b`.`id_organization`) 
				AND (`a`.`id_external_sot_for_unee_t` = `b`.`default_sot_id`)
			;

	# We update the view to get the default table_level_1_properties for each organization

		DROP VIEW IF EXISTS `ut_organization_default_table_level_1_properties` ;

		CREATE VIEW `ut_organization_default_table_level_1_properties`
		AS
		SELECT
			`a`.`properties_level_1_table`
			, `b`.`id_organization` AS `organization_id`
		FROM
			`ut_external_sot_for_unee_t_objects` AS `a`
			INNER JOIN `uneet_enterprise_organizations` AS `b`
				ON (`a`.`organization_id` = `b`.`id_organization`) 
				AND (`a`.`id_external_sot_for_unee_t` = `b`.`default_sot_id`)
			;

	# We update the view to get the default table_level_2_properties for each organization

		DROP VIEW IF EXISTS `ut_organization_default_table_level_2_properties` ;

		CREATE VIEW `ut_organization_default_table_level_2_properties`
		AS
		SELECT
			`a`.`properties_level_2_table`
			, `b`.`id_organization` AS `organization_id`
		FROM
			`ut_external_sot_for_unee_t_objects` AS `a`
			INNER JOIN `uneet_enterprise_organizations` AS `b`
				ON (`a`.`organization_id` = `b`.`id_organization`) 
				AND (`a`.`id_external_sot_for_unee_t` = `b`.`default_sot_id`)
			;

	# We update the view to get the default table_level_3_properties for each organization

		DROP VIEW IF EXISTS `ut_organization_default_table_level_3_properties` ;

		CREATE VIEW `ut_organization_default_table_level_3_properties`
		AS
		SELECT
			`a`.`properties_level_3_table`
			, `b`.`id_organization` AS `organization_id`
		FROM
			`ut_external_sot_for_unee_t_objects` AS `a`
			INNER JOIN `uneet_enterprise_organizations` AS `b`
				ON (`a`.`organization_id` = `b`.`id_organization`) 
				AND (`a`.`id_external_sot_for_unee_t` = `b`.`default_sot_id`)
			;

	# We update the view to get the default table `persons` for each organization

		DROP VIEW IF EXISTS `ut_organization_default_table_persons` ;

		CREATE VIEW `ut_organization_default_table_persons`
		AS
		SELECT
			`a`.`person_table`
			, `b`.`id_organization` AS `organization_id`
		FROM
			`ut_external_sot_for_unee_t_objects` AS `a`
			INNER JOIN `uneet_enterprise_organizations` AS `b`
				ON (`a`.`organization_id` = `b`.`id_organization`) 
				AND (`a`.`id_external_sot_for_unee_t` = `b`.`default_sot_id`)
			;

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
		AND `a`.`unee_t_mefe_user_id` IS NOT NULL
		AND `a`.`creation_system_id` != 'Setup')
	;
	
# Add the view to facilitate the selection of default L1P and default L2P

	DROP VIEW IF EXISTS `ut_list_possible_properties` ;

	CREATE VIEW `ut_list_possible_properties`
	AS 
	SELECT
		`a`.`organization_id`
		, `b`.`designation` AS `organization`
		, `a`.`external_property_type_id`
		, `a`.`unee_t_mefe_unit_id`
		, `a`.`uneet_name`
		, `a`.`mefe_unit_id_parent`
		, `a`.`is_obsolete`
	FROM
			`ut_map_external_source_units` AS `a`
		INNER JOIN 	`uneet_enterprise_organizations` AS `b`
			ON (`a`.`organization_id` = `b`.`id_organization`)
	WHERE `a`.`unee_t_mefe_unit_id` IS NOT NULL
		;

# We create the view to get the details of the default L1P for a given organization

	DROP VIEW IF EXISTS `ut_organization_default_L1P` ;

	CREATE VIEW `ut_organization_default_L1P`
	AS
	SELECT
		`a`.`organization_id`
		, `b`.`designation` AS `organization`
		, `a`.`unee_t_mefe_unit_id`
		, `a`.`uneet_name`
		, `a`.`mefe_unit_id_parent`
		, `a`.`is_obsolete`
		, `a`.`external_property_id`
		, `a`.`external_system`
		, `a`.`table_in_external_system`
		, `a`.`tower`
	FROM
			`ut_map_external_source_units` AS `a`
		INNER JOIN 	`uneet_enterprise_organizations` AS `b`
			ON (`a`.`organization_id` = `b`.`id_organization`)
	WHERE `a`.`unee_t_mefe_unit_id` IS NOT NULL
		AND `a`.`external_property_type_id` = 1
		;


# We create the view to get the details of the default L2P for a given organization

	DROP VIEW IF EXISTS `ut_organization_default_L2P` ;

	CREATE VIEW `ut_organization_default_L2P`
	AS
	SELECT
		`a`.`organization_id`
		, `b`.`designation` AS `organization`
		, `a`.`unee_t_mefe_unit_id`
		, `a`.`uneet_name`
		, `a`.`mefe_unit_id_parent`
		, `a`.`is_obsolete`
		, `a`.`external_property_id`
		, `a`.`external_system`
		, `a`.`table_in_external_system`
		, `a`.`tower`
	FROM
			`ut_map_external_source_units` AS `a`
		INNER JOIN 	`uneet_enterprise_organizations` AS `b`
			ON (`a`.`organization_id` = `b`.`id_organization`)
	WHERE `a`.`unee_t_mefe_unit_id` IS NOT NULL
		AND `a`.`external_property_type_id` = 2
		;

#	- When we create a new organization, we make sure that
#	  we automatically
#		- The MEFE user type 'super admin' for this organization
#		- the MEFE user.
#		- The Default Area
#	  The script is `organization_creation_v1_22_9.sql`

########################################################################################
#
# This is a copy of the script `organization_creation_v1_22_9`
#
########################################################################################

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

########################################################################################
#
# END - This is a copy of the script `properties_areas_creation_update_v1_22_9`
#
########################################################################################

# We update the trigger to create a new person to make sure it can handle 
# the creation of Master MEFE user for a given organization

########################################################################################
#
# This is a copy of the script `person_creation_v1_22_9`
#
########################################################################################

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

########################################################################################
#
# END - This is a copy of the script `person_creation_v1_22_9`
#
########################################################################################


# We update the trigger to create a new area to make sure it can handle 
# the creation of the default Area for a given organization
# The script is `properties_areas_creation_update_v1_22_9`

	# DROP legacy triggers:
	
		DROP TRIGGER IF EXISTS `ut_insert_external_area`;

		DROP TRIGGER IF EXISTS `ut_update_external_area`;

		DROP TRIGGER IF EXISTS `ut_created_external_area_after_insert`;

########################################################################################
#
# This is a copy of the script `properties_areas_creation_update_v1_22_9`
#
########################################################################################





########################################################################################
#
# END - This is a copy of the script `properties_areas_creation_update_v1_22_9`
#
########################################################################################

########################################################################################
#
# This is a copy of the script `properties_level_1_creation_update_v1_22_9`
#
########################################################################################

#WIP	- Update the routine to create new L1P. 
#		The script is `properties_level_1_creation_update_v1_22_9`
#OK		- Make sure we use the correct trigger names to create the properties in the table `ut_map_external_source_units`
#OK		- Make sure that we propagate the Default assignees
#WIP			- IF we do NOT have a default assignee, 
#				  THEN we use the default assignee for the L1P






########################################################################################
#
# END - This is a copy of the script `properties_level_1_creation_update_v1_22_9`
#
########################################################################################

########################################################################################
#
# This is a copy of the script `properties_level_2_creation_update_v1_22_9`
#
########################################################################################

#WIP	- Update the routine to create new L2P. 
#		The script is `properties_level_2_creation_update_v1_22_9`
#OK		- Make sure we use the correct trigger names to create the properties in the table `ut_map_external_source_units`
#OK		- Make sure that we propagate the Default assignees
#WIP			- IF we do NOT have a default assignee, 
#				  THEN we use the default assignee for the L1P











########################################################################################
#
# END - This is a copy of the script `properties_level_2_creation_update_v1_22_9`
#
########################################################################################



########################################################################################
#
# This is a copy of the script `properties_level_3_creation_update_v1_22_9`
#
########################################################################################

#WIP	- Update the routine to create new L3P. 
#		The script is `properties_level_3_creation_update_v1_22_9`
#OK		- Make sure we use the correct trigger names to create the properties in the table `ut_map_external_source_units`
#WIP		- Make sure that we propagate the Default assignees
#WIP			- IF we do NOT have a default assignee, 
#				  THEN we use the default assignee for the L2P









########################################################################################
#
# END - This is a copy of the script `properties_level_3_creation_update_v1_22_9`
#
########################################################################################





























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