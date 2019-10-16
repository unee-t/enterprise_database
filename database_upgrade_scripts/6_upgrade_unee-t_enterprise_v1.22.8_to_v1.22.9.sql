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
# WE NEED TO MANUALLY UPDATE THE RECORD FOR THE HMLET ORGANIZATION
# WE NEED TO MAKE SURE THAT THE HMLET ORGANIZATION HAS THE FOLLOWING INFO CONFIGURED
#	- Default user type for each public users:						
#		- Tenant (1)
#		- Owner/Landlord (2)
#		- We have NO default user for the user type contractor (3)
#		- management company (4)
#		- Agent (5)
#
#
######################################################################################
#
######################################################################################
#
# WARNING 4:
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
#OK - Add a view to get the necessary information to assign the default users
#	  `ut_user_person_details`
#
#OK	- When we create a new organization, we make sure that
#		  We automatically create 
#OK			- The MEFE user type 'super admin' for this organization
#OK			- the MEFE user associated to that account.
#OK		- The Default Unee-T user type for this role type
#OK		- All the default permissions for each of the default user types.
#OK			- Tenant (1)
#OK			- Owner/Landlord (2)
#OK			- We have NO default user for the user type contractor (3)
#OK			- management company (4)
#OK			- Agent (5)
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
#OK		- Add a check to make sure we can get the MEFE unit ID if we need to update
#WIP			- IF we do NOT have a default assignee, 
#				  THEN we use the default assignee for the L1P
#
#WIP - Update the routine to create new L3P. 
#		The script is `properties_level_3_creation_update_v1_22_9`
#OK		- Make sure we use the correct trigger names to create the properties in the table `ut_map_external_source_units`
#OK	- Make sure that we propagate the Default assignees
#OK		- Add a check to make sure we can get the MEFE unit ID if we need to update
#WIP	- IF we do NOT have a default assignee, 
#		  THEN we use the default assignee for the L2P
#
#OK - Update the lambda triggers to 
#OK		- Make sure we log the error message correctly if lambda is not sent
#
#OK - Update the trigger after the property is created to
#OK	- When we create a property make sure that we use the new 'default assignee' information
#		  when we assign the unit to the default user for a given role.
#	COMMENT: We should create AT LEAST ONE default assignee for the property so we can create cases.
#  The script is `add_user_to_property_trigger_bulk_assign_to_new_unit_v1_29_0.sql`
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

#
#OK - Add a view to get the necessary information to assign the default users
#	  `ut_user_person_details`

	DROP VIEW IF EXISTS `ut_user_person_details` ;

	CREATE VIEW `ut_user_person_details`
	AS
	SELECT
		`a`.`unee_t_mefe_user_id`
		, `b`.`country_code`
		, `b`.`email`
		, `b`.`organization_id`
		, `b`.`person_status_id`
		, `b`.`gender`
		, `b`.`salutation_id`
		, `b`.`given_name`
		, `b`.`middle_name`
		, `b`.`family_name`
		, `b`.`alias`
		, `b`.`job_title`
		, `b`.`organization`
		, `b`.`tel_1`
	FROM
		`ut_map_external_source_users` AS `a`
		INNER JOIN `persons` AS `b`
			ON (`a`.`person_id` = `b`.`id_person`)
		WHERE  `a`.`unee_t_mefe_user_id` IS NOT NULL
		;

#	- When we create a new organization, we make sure that
#	  we automatically
#		- The MEFE user type 'super admin' for this organization
#		- the MEFE user associated to that account.
#		- All the default permissions for each of the default user types.
#			- Tenant (1)
#			- Owner/Landlord (2)
#			- We have NO default user for the user type contractor (3)
#			- management company (4)
#			- Agent (5)
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

	# The designations for the different role types

		SET @role_type_designation_tenant := (SELECT `role_type`
			FROM `ut_user_role_types`
			WHERE `id_role_type` = 1
			)
			;

		SET @role_type_designation_landlord := (SELECT `role_type`
			FROM `ut_user_role_types`
			WHERE `id_role_type` = 2
			)
			;

		SET @role_type_designation_mgt_cny := (SELECT `role_type`
			FROM `ut_user_role_types`
			WHERE `id_role_type` = 4
			)
			;

		SET @role_type_designation_agent := (SELECT `role_type`
			FROM `ut_user_role_types`
			WHERE `id_role_type` = 5
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
			# FOR THE PHPR VIEW 
			#	- `Super Admin - Manage Organization
			#	  PHPR EVENT Add Page >> After record added
			# FOR THE SQL VIEW
			#	- `ut_list_possible_assignees`
			#	  
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

# We need to create the default Unee-T user type for this organization:
#		- Tenant (1)
#		- Owner/Landlord (2)
#		- We have NO default user for the user type contractor (3)
#		- management company (4)
#		- Agent (5)	

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
		, `can_see_role_contractor`
		) 
		VALUES
			# Tenant (1)
			(NOW()
				, 'Setup'
				, @organization_id
				, 'trigger_ut_after_insert_new_organization'
				, @organization_id
				, 0
				, 0
				, CONCAT ('Default Public User - '
					, @role_type_designation_tenant
					)
				, CONCAT ('Use this for the public account for the role '
					, @role_type_designation_tenant
					, '. This is the user people will report issue to by default'
					)
				# What is the `ut_user_role_type_id`
				#		- Tenant (1)
				#		- Owner/Landlord (2)
				#		- We have NO default user for the user type contractor (3)
				#		- management company (4)
				#		- Agent (5)
				, 1
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
				, 1
				)
			# Owner/Landlord (2)
			, (NOW()
				, 'Setup'
				, @organization_id
				, 'trigger_ut_after_insert_new_organization'
				, @organization_id
				, 0
				, 0
				, CONCAT ('Default Public User - '
					, @role_type_designation_landlord
					)
				, CONCAT ('Use this for the public account for the role '
					, @role_type_designation_landlord
					, '. This is the user people will report issue to by default'
					)
				# What is the `ut_user_role_type_id`
				#		- Tenant (1)
				#		- Owner/Landlord (2)
				#		- We have NO default user for the user type contractor (3)
				#		- management company (4)
				#		- Agent (5)
				, 2
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
				, 1
				) 
			# management company (4)
			, (NOW()
				, 'Setup'
				, @organization_id
				, 'trigger_ut_after_insert_new_organization'
				, @organization_id
				, 0
				, 0
				, CONCAT ('Default Public User - '
					, @role_type_designation_mgt_cny
					)
				, CONCAT ('Use this for the public account for the role '
					, @role_type_designation_mgt_cny
					, '. This is the user people will report issue to by default'
					)
				# What is the `ut_user_role_type_id`
				#		- Tenant (1)
				#		- Owner/Landlord (2)
				#		- We have NO default user for the user type contractor (3)
				#		- management company (4)
				#		- Agent (5)
				, 4
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
				, 1
				) 
			# Agent (5)
			, (NOW()
				, 'Setup'
				, @organization_id
				, 'trigger_ut_after_insert_new_organization'
				, @organization_id
				, 0
				, 0
				, CONCAT ('Default Public User - '
					, @role_type_designation_agent
					)
				, CONCAT ('Use this for the public account for the role '
					, @role_type_designation_agent
					, '. This is the user people will report issue to by default'
					)
				# What is the `ut_user_role_type_id`
				#		- Tenant (1)
				#		- Owner/Landlord (2)
				#		- We have NO default user for the user type contractor (3)
				#		- management company (4)
				#		- Agent (5)
				, 5
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
				, 1
				) 
			;

END;
$$
DELIMITER ;

########################################################################################
#
# END - This is a copy of the script `organization_creation_v1_22_9`
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

########################################################################################
#
# This is a copy of the script `properties_areas_creation_update_v1_22_9`
#
########################################################################################

# We update the trigger to create a new area to make sure it can handle 
# the creation of the default Area for a given organization
# The script is `properties_areas_creation_update_v1_22_9`

	# DROP legacy triggers:
	
		DROP TRIGGER IF EXISTS `ut_insert_external_area`;

		DROP TRIGGER IF EXISTS `ut_update_external_area`;

		DROP TRIGGER IF EXISTS `ut_created_external_area_after_insert`;

#################
#
# This lists all the triggers we use to create 
# an area
# via the Unee-T Enterprise Interface
#
#################

# We create a trigger when a record is added to the `external_property_groups_areas` table

	DROP TRIGGER IF EXISTS `ut_after_insert_external_area`;

DELIMITER $$
CREATE TRIGGER `ut_after_insert_external_area`
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

	SET @is_creation_needed_in_unee_t_insert_ext_area = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator_insert_ext_area = NEW.`created_by_id` ;
	SET @source_system_updater_insert_ext_area = NEW.`updated_by_id`;

	SET @creator_mefe_user_id_insert_ext_area = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator_insert_ext_area
		)
		;

	SET @upstream_create_method_insert_ext_area = NEW.`creation_method` ;
	SET @upstream_update_method_insert_ext_area = NEW.`update_method` ;

	SET @external_id_insert_ext_area = NEW.`external_id` ;
	SET @external_system_id_insert_ext_area = NEW.`external_system_id` ; 
	SET @external_table_insert_ext_area = NEW.`external_table` ;

	IF @is_creation_needed_in_unee_t_insert_ext_area = 1
		AND @external_id_insert_ext_area IS NOT NULL
		AND @external_system_id_insert_ext_area IS NOT NULL
		AND @external_table_insert_ext_area IS NOT NULL
		AND (@upstream_create_method_insert_ext_area = 'imported_from_hmlet_ipi'
			OR @upstream_create_method_insert_ext_area = 'Manage_Areas_Add_Page'
			OR @upstream_create_method_insert_ext_area = 'Manage_Areas_Edit_Page'
			OR @upstream_create_method_insert_ext_area = 'Manage_Areas_Import_Page'
			OR @upstream_create_method_insert_ext_area = 'Export_and_Import_Areas_Import_Page'
			OR @upstream_create_method_insert_ext_area = 'trigger_ut_after_insert_new_organization'
			OR @upstream_update_method_insert_ext_area = 'imported_from_hmlet_ipi'
			OR @upstream_update_method_insert_ext_area = 'Manage_Areas_Add_Page'
			OR @upstream_update_method_insert_ext_area = 'Manage_Areas_Edit_Page'
			OR @upstream_update_method_insert_ext_area = 'Manage_Areas_Import_Page'
			OR @upstream_update_method_insert_ext_area = 'Export_and_Import_Areas_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `property_groups_areas` table:

		SET @this_trigger_insert_ext_area = 'ut_insert_external_area' ;

		SET @creation_system_id_insert_ext_area = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator_insert_ext_area
			)
			;

		SET @created_by_id_insert_ext_area = @creator_mefe_user_id_insert_ext_area ;
		SET @downstream_creation_method_insert_ext_area = @this_trigger_insert_ext_area ;

		SET @syst_updated_datetime_insert_ext_area = NOW();

		SET @source_system_updater_insert_ext_area = NEW.`updated_by_id` ; 

		SET @update_system_id_insert_ext_area = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater_insert_ext_area
			)
			;
		SET @updated_by_id_insert_ext_area = @creator_mefe_user_id_insert_ext_area ;
		SET @downstream_update_method_insert_ext_area = @this_trigger_insert_ext_area ;

		SET @organization_id_create_insert_ext_area = @source_system_creator_insert_ext_area ;
		SET @organization_id_update_insert_ext_area = @source_system_updater_insert_ext_area ;

		SET @country_code_insert_ext_area = NEW.`country_code` ;
		SET @is_obsolete_insert_ext_area = NEW.`is_obsolete` ;
		SET @is_default_insert_ext_area = NEW.`is_default` ;
		SET @order_insert_ext_area = NEW.`order` ;
		SET @area_name_insert_ext_area = NEW.`area_name` ;
		SET @area_definition_insert_ext_area = NEW.`area_definition` ;

		SET @area_default_assignee_mgt_cny := NEW.`mgt_cny_default_assignee` ;
		SET @area_default_assignee_landlord := NEW.`landlord_default_assignee` ;
		SET @area_default_assignee_tenant := NEW.`tenant_default_assignee` ;
		SET @area_default_assignee_agent := NEW.`agent_default_assignee` ;

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
			, `mgt_cny_default_assignee`
			, `landlord_default_assignee`
			, `tenant_default_assignee`
			, `agent_default_assignee`
			)
			VALUES
				(@external_id_insert_ext_area
				, @external_system_id_insert_ext_area
				, @external_table_insert_ext_area
				, @syst_created_datetime_insert_ext_area
				, @creation_system_id_insert_ext_area
				, @created_by_id_insert_ext_area
				, @downstream_creation_method_insert_ext_area
				, @organization_id_create_insert_ext_area
				, @country_code_insert_ext_area
				, @is_obsolete_insert_ext_area
				, @is_default_insert_ext_area
				, @order_insert_ext_area
				, @area_name_insert_ext_area
				, @area_definition_insert_ext_area
				, @area_default_assignee_mgt_cny
				, @area_default_assignee_landlord
				, @area_default_assignee_tenant
				, @area_default_assignee_agent
				)
			ON DUPLICATE KEY UPDATE
				`syst_updated_datetime` = @syst_updated_datetime_insert_ext_area
				, `update_system_id` = @update_system_id_insert_ext_area
				, `updated_by_id` = @updated_by_id_insert_ext_area
				, `update_method` = @downstream_update_method_insert_ext_area
				, `country_code` = @country_code_insert_ext_area
				, `is_obsolete` = @is_obsolete_insert_ext_area
				, `is_default` = @is_default_insert_ext_area
				, `order` = @order_insert_ext_area
				, `area_name` = @area_name_insert_ext_area
				, `area_definition` = @area_definition_insert_ext_area
				, `mgt_cny_default_assignee` = @area_default_assignee_mgt_cny
				, `landlord_default_assignee` = @area_default_assignee_landlord
				, `tenant_default_assignee` = @area_default_assignee_tenant
				, `agent_default_assignee` = @area_default_assignee_agent
			;

	END IF;

END;
$$
DELIMITER ;

# We create a trigger when a record is updated in the `external_property_groups_areas` table
# The area DOES exist in the table `property_groups_areas`

	DROP TRIGGER IF EXISTS `ut_after_update_external_area`;

DELIMITER $$
CREATE TRIGGER `ut_after_update_external_area`
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

# Capture the variables we need to verify if conditions are met:

	SET @is_creation_needed_in_unee_t_update_ext_area = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator_update_ext_area = NEW.`created_by_id` ;
	SET @source_system_updater_update_ext_area = NEW.`updated_by_id`;

	SET @creator_mefe_user_id_update_ext_area = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator_update_ext_area
		)
		;

	SET @upstream_create_method_update_ext_area = NEW.`creation_method` ;
	SET @upstream_update_method_update_ext_area = NEW.`update_method` ;
	
	SET @organization_id_update_ext_area = @source_system_creator_update_ext_area ;

	SET @external_id_update_ext_area = NEW.`external_id` ;
	SET @external_system_id_update_ext_area = NEW.`external_system_id` ; 
	SET @external_table_update_ext_area = NEW.`external_table` ;

	SET @new_is_creation_needed_in_unee_t_update_ext_area = NEW.`is_creation_needed_in_unee_t` ;
	SET @old_is_creation_needed_in_unee_t_update_ext_area = OLD.`is_creation_needed_in_unee_t` ;

# We can now check if the conditions are met:

	IF @is_creation_needed_in_unee_t_update_ext_area = 1
		AND @external_id_update_ext_area IS NOT NULL
		AND @external_system_id_update_ext_area IS NOT NULL
		AND @external_table_update_ext_area IS NOT NULL
		AND @organization_id_update_ext_area IS NOT NULL
		AND (@upstream_update_method_update_ext_area = 'imported_from_hmlet_ipi'
			OR @upstream_update_method_update_ext_area = 'Manage_Areas_Add_Page'
			OR @upstream_update_method_update_ext_area = 'Manage_Areas_Edit_Page'
			OR @upstream_update_method_update_ext_area = 'Manage_Areas_Import_Page'
			OR @upstream_update_method_update_ext_area = 'Export_and_Import_Areas_Import_Page'
			)
	THEN 

	# The conditions are met: we capture the other variables we need

		SET @creation_system_id_update_ext_area = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater_update_ext_area
			)
			;

		SET @record_to_update_update_ext_area = (SELECT `id_area`
			FROM `property_groups_areas`
			WHERE `external_id` = @external_id_update_ext_area
				AND `external_system_id` = @external_system_id_update_ext_area
				AND `external_table` = @external_table_update_ext_area
				AND `organization_id` = @organization_id_update_ext_area
			);

		SET @syst_updated_datetime_update_ext_area = NOW();

		SET @source_system_updater_update_ext_area = NEW.`updated_by_id` ; 

		SET @update_system_id_update_ext_area = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater_update_ext_area
			)
			;
	
		SET @updated_by_id_update_ext_area = @creator_mefe_user_id_update_ext_area ;

		SET @organization_id_create_update_ext_area = @source_system_creator_update_ext_area ;
		SET @organization_id_update_update_ext_area = @source_system_updater_update_ext_area ;

		SET @country_code_update_ext_area = NEW.`country_code` ;
		SET @is_obsolete_update_ext_area = NEW.`is_obsolete` ;
		SET @is_default_update_ext_area = NEW.`is_default` ;
		SET @order_update_ext_area = NEW.`order` ;
		SET @area_name_update_ext_area = NEW.`area_name` ;
		SET @area_definition_update_ext_area = NEW.`area_definition` ;

		SET @area_default_assignee_mgt_cny := NEW.`mgt_cny_default_assignee` ;
		SET @area_default_assignee_landlord := NEW.`landlord_default_assignee` ;
		SET @area_default_assignee_tenant := NEW.`tenant_default_assignee` ;
		SET @area_default_assignee_agent := NEW.`agent_default_assignee` ;


		IF @new_is_creation_needed_in_unee_t_update_ext_area != @old_is_creation_needed_in_unee_t_update_ext_area
		THEN

			# This is option 1 - creation IS needed

				SET @this_trigger_update_area_insert = 'ut_after_update_external_area_insert_creation_needed' ;
				SET @this_trigger_update_area_update = 'ut_after_update_external_area_update_creation_needed' ;

			# We update the record in the table `property_groups_areas`
			# We do this via INSERT INTO ... ON DUPLICATE KEY UPDATE for maximum safety

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
					, `mgt_cny_default_assignee`
					, `landlord_default_assignee`
					, `tenant_default_assignee`
					, `agent_default_assignee`
					)
					VALUES
						(@external_id_update_ext_area
						, @external_system_id_update_ext_area
						, @external_table_update_ext_area
						, NOW()
						, @creation_system_id_update_ext_area
						, @created_by_id_update_ext_area
						, @this_trigger_update_area_insert
						, @is_creation_needed_in_unee_t_update_ext_area
						, @organization_id_create_update_ext_area
						, @country_code_update_ext_area
						, @is_obsolete_update_ext_area
						, @is_default_update_ext_area
						, @order_update_ext_area
						, @area_name_update_ext_area
						, @area_definition_update_ext_area
						, @area_default_assignee_mgt_cny
						, @area_default_assignee_landlord
						, @area_default_assignee_tenant
						, @area_default_assignee_agent
						)
					ON DUPLICATE KEY UPDATE
						`syst_updated_datetime` = NOW()
						, `update_system_id` = @update_system_id_update_ext_area
						, `updated_by_id` = @updated_by_id_update_ext_area
						, `update_method` = @this_trigger_update_area_update
						, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t_update_ext_area
						, `organization_id` = @organization_id_update_update_ext_area
						, `country_code` = @country_code_update_ext_area
						, `is_obsolete` = @is_obsolete_update_ext_area
						, `is_default` = @is_default_update_ext_area
						, `order` = @order_update_ext_area
						, `area_name` = @area_name_update_ext_area
						, `area_definition` = @area_definition_update_ext_area
						, `mgt_cny_default_assignee` = @area_default_assignee_mgt_cny
						, `landlord_default_assignee` = @area_default_assignee_landlord
						, `tenant_default_assignee` = @area_default_assignee_tenant
						, `agent_default_assignee` = @area_default_assignee_agent
					;

		ELSEIF @new_is_creation_needed_in_unee_t_update_ext_area = @old_is_creation_needed_in_unee_t_update_ext_area
		THEN 

			# This is option 2 - creation is NOT needed

				SET @this_trigger_update_area_insert = 'ut_after_update_external_area_insert_update_needed' ;
				SET @this_trigger_update_area_update = 'ut_after_update_external_area_update_update_needed' ;

			# We update the record in the table `property_groups_areas`
			# We do this via INSERT INTO ... ON DUPLICATE KEY UPDATE for maximum safety

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
				, `mgt_cny_default_assignee`
				, `landlord_default_assignee`
				, `tenant_default_assignee`
				, `agent_default_assignee`
				)
				VALUES
					(@external_id_update_ext_area
					, @external_system_id_update_ext_area
					, @external_table_update_ext_area
					, NOW()
					, @creation_system_id_update_ext_area
					, @created_by_id_update_ext_area
					, @this_trigger_update_area_insert
					, @is_creation_needed_in_unee_t_update_ext_area
					, @organization_id_create_update_ext_area
					, @country_code_update_ext_area
					, @is_obsolete_update_ext_area
					, @is_default_update_ext_area
					, @order_update_ext_area
					, @area_name_update_ext_area
					, @area_definition_update_ext_area
					, @area_default_assignee_mgt_cny
					, @area_default_assignee_landlord
					, @area_default_assignee_tenant
					, @area_default_assignee_agent
					)
				ON DUPLICATE KEY UPDATE
					`syst_updated_datetime` = NOW()
					, `update_system_id` = @update_system_id_update_ext_area
					, `updated_by_id` = @updated_by_id_update_ext_area
					, `update_method` = @this_trigger_update_area_update
					, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t_update_ext_area
					, `organization_id` = @organization_id_update_update_ext_area
					, `country_code` = @country_code_update_ext_area
					, `is_obsolete` = @is_obsolete_update_ext_area
					, `is_default` = @is_default_update_ext_area
					, `order` = @order_update_ext_area
					, `area_name` = @area_name_update_ext_area
					, `area_definition` = @area_definition_update_ext_area
					, `mgt_cny_default_assignee` = @area_default_assignee_mgt_cny
					, `landlord_default_assignee` = @area_default_assignee_landlord
					, `tenant_default_assignee` = @area_default_assignee_tenant
					, `agent_default_assignee` = @area_default_assignee_agent
				;

		END IF;

	# The conditions are NOT met <-- we do nothing

	END IF;

END;
$$
DELIMITER ;

# WIP - Propagate to the table `ut_map_external_source_areas` 

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
#OK		- Change how we fetch record when we need to update a record in the table
#		  `ut_map_external_source_units`
#OK		- Add a check to make sure we can get the MEFE unit ID if we need to update
#WIP			- IF we do NOT have a default assignee, 
#				  THEN we use the default assignee for the L1P

#################
#
# This lists all the triggers we use to create 
# a property_level_1
# via the Unee-T Enterprise Interface
#
#################

# This script creates the following objects:
#	- Triggers
#		- `ut_after_insert_in_external_property_level_1`
#		- `ut_after_update_external_property_level_1`
#		- `ut_after_insert_in_property_level_1`
#		- `ut_after_update_property_level_1`
#		- ``
#		- ``

# We create a trigger when a record is added to the `external_property_level_1_buildings` table

	DROP TRIGGER IF EXISTS `ut_after_insert_in_external_property_level_1`;

DELIMITER $$
CREATE TRIGGER `ut_after_insert_in_external_property_level_1`
AFTER INSERT ON `external_property_level_1_buildings`
FOR EACH ROW
BEGIN

# We only do this if 
#	- we need to create the property in Unee-T
#	- The record does NOT exist in in the table `property_level_1_buildings` yet.
#	- We have a `external_id`
#	- We have a `external_system_id`
#	- We have a `external_table`
#	- We have a `organization_id`
#	- We have a `tower`
#	- We have a MEFE user ID for the user who did the update
#	- The unit was already marked as needed to be created in Unee-T
#	- We have a valid area id in the table `external_property_groups_areas`
#	- The `do_not_insert_field` is NOT equal to 1
#	- This is a valid insert method:
#		- 'imported_from_hmlet_ipi'
#		- 'Manage_Buildings_Add_Page'
#		- 'Manage_Buildings_Edit_Page'
#		- 'Manage_Buildings_Import_Page'
#		- 'Export_and_Import_Buildings_Import_Page'
#		- ''

	SET @is_creation_needed_in_unee_t_insert_extl1 = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator_insert_extl1 = NEW.`created_by_id` ;
	SET @source_system_updater_insert_extl1 = (IF(NEW.`updated_by_id` IS NULL
			, @source_system_creator_insert_extl1
			, NEW.`updated_by_id`
			)
		);

	SET @creator_mefe_user_id_insert_extl1 = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator_insert_extl1
		)
		;

	SET @upstream_create_method_insert_extl1 = NEW.`creation_method` ;
	SET @upstream_update_method_insert_extl1 = NEW.`update_method` ;

	SET @external_system_id_insert_extl1 = NEW.`external_system_id` ; 
	SET @external_table_insert_extl1 = NEW.`external_table` ;
	SET @external_id_insert_extl1 = NEW.`external_id` ;
	SET @tower_insert_extl1 = NEW.`tower` ;

	SET @organization_id_insert_extl1 = @source_system_creator_insert_extl1 ;

	SET @id_in_property_level_1_buildings_insert_extl1 = (SELECT `id_building`
		FROM `property_level_1_buildings`
		WHERE `external_system_id` = @external_system_id_insert_extl1
			AND `external_table` = @external_table_insert_extl1
			AND `external_id` = @external_id_insert_extl1
			AND `tower` = @tower_insert_extl1
			AND `organization_id` = @organization_id_insert_extl1
		);

	SET @upstream_do_not_insert_insert_extl1 = NEW.`do_not_insert` ;

	# This is an INSERT - the record should NOT exist already

		SET @do_not_insert_insert_extl1 = (IF (@id_in_property_level_1_buildings_insert_extl1 IS NULL
				, 0
				, @upstream_do_not_insert_insert_extl1
				)
			);

	# Get the information about the area for that building...
	# We need the information from the table `property_groups_areas` (and NOT the table `external_property_groups_areas`)

		SET @area_id_1_insert_extl1 = NEW.`area_id` ;

		SET @area_external_id_insert_extl1 = (SELECT `external_id`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_1_insert_extl1
			);
		SET @area_external_system_id_insert_extl1 = (SELECT `external_system_id`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_1_insert_extl1
			);
		SET @area_external_table_insert_extl1 = (SELECT `external_table`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_1_insert_extl1
			);

		SET @area_id_2_insert_extl1 = (SELECT `id_area`
			FROM `property_groups_areas`
			WHERE `external_id` = @area_external_id_insert_extl1
				AND `external_system_id` = @area_external_system_id_insert_extl1
			   	AND `external_table` = @area_external_table_insert_extl1
			   	AND `organization_id` = @organization_id_insert_extl1
			);

	IF @is_creation_needed_in_unee_t_insert_extl1 = 1
		AND @do_not_insert_insert_extl1 = 0
		AND @external_id_insert_extl1 IS NOT NULL
		AND @external_system_id_insert_extl1 IS NOT NULL
		AND @external_table_insert_extl1 IS NOT NULL
		AND @tower_insert_extl1 IS NOT NULL
		AND @organization_id_insert_extl1 IS NOT NULL
		AND @area_id_2_insert_extl1 IS NOT NULL
		AND 
		(@upstream_create_method_insert_extl1 = 'imported_from_hmlet_ipi'
			OR @upstream_create_method_insert_extl1 = 'Manage_Buildings_Add_Page'
			OR @upstream_create_method_insert_extl1 = 'Manage_Buildings_Edit_Page'
			OR @upstream_create_method_insert_extl1 = 'Manage_Buildings_Import_Page'
			OR @upstream_create_method_insert_extl1 = 'Export_and_Import_Buildings_Import_Page'
			OR @upstream_update_method_insert_extl1 = 'imported_from_hmlet_ipi'
			OR @upstream_update_method_insert_extl1 = 'Manage_Buildings_Add_Page'
			OR @upstream_update_method_insert_extl1 = 'Manage_Buildings_Edit_Page'
			OR @upstream_update_method_insert_extl1 = 'Manage_Buildings_Import_Page'
			OR @upstream_update_method_insert_extl1 = 'Export_and_Import_Buildings_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `property_level_1_buildings` table:

		SET @this_trigger_insert_extl1_insert := 'ut_after_insert_in_external_property_level_1_insert' ;
		SET @this_trigger_insert_extl1_update := 'ut_after_insert_in_external_property_level_1_update' ;

		SET @creation_system_id_insert_extl1 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator_insert_extl1
			)
			;
		SET @created_by_id_insert_extl1 = @creator_mefe_user_id_insert_extl1 ;

		SET @update_system_id_insert_extl1 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater_insert_extl1
			)
			;
		SET @updated_by_id_insert_extl1 = @creator_mefe_user_id_insert_extl1 ;

		SET @organization_id_create_insert_extl1 = @source_system_creator_insert_extl1 ;
		SET @organization_id_update_insert_extl1 = @source_system_updater_insert_extl1;

		SET @is_obsolete_insert_extl1 = NEW.`is_obsolete` ;
		SET @order_insert_extl1 = NEW.`order` ;

		SET @unee_t_unit_type_insert_extl1 = NEW.`unee_t_unit_type` ;
		SET @designation_insert_extl1 = NEW.`designation` ;

		SET @address_1_insert_extl1 = NEW.`address_1` ;
		SET @address_2_insert_extl1 = NEW.`address_2` ;
		SET @zip_postal_code_insert_extl1 = NEW.`zip_postal_code` ;
		SET @state_insert_extl1 = NEW.`state` ;
		SET @city_insert_extl1 = NEW.`city` ;
		SET @country_code_insert_extl1 = NEW.`country_code` ;

		SET @description_insert_extl1 = NEW.`description` ;

		SET @ext_l1_default_assignee_mgt_cny := NEW.`mgt_cny_default_assignee` ;
		SET @ext_l1_default_assignee_landlord := NEW.`landlord_default_assignee` ;
		SET @ext_l1_default_assignee_tenant := NEW.`tenant_default_assignee` ;
		SET @ext_l1_default_assignee_agent := NEW.`agent_default_assignee` ;

	# We insert the record in the table `property_level_1_buildings`

		INSERT INTO `property_level_1_buildings`
			(`external_id`
			, `external_system_id` 
			, `external_table`
			, `syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `creation_method`
			, `organization_id`
			, `is_obsolete`
			, `order`
			, `area_id`
			, `is_creation_needed_in_unee_t`
			, `do_not_insert`
			, `unee_t_unit_type`
			, `designation`
			, `tower`
			, `address_1`
			, `address_2`
			, `zip_postal_code`
			, `state`
			, `city`
			, `country_code`
			, `description`
			, `mgt_cny_default_assignee`
			, `landlord_default_assignee`
			, `tenant_default_assignee`
			, `agent_default_assignee`
			)
			VALUES
				(@external_id_insert_extl1
				, @external_system_id_insert_extl1
				, @external_table_insert_extl1
				, NOW()
				, @creation_system_id_insert_extl1
				, @created_by_id_insert_extl1
				, @this_trigger_insert_extl1_insert
				, @organization_id_create_insert_extl1
				, @is_obsolete_insert_extl1
				, @order_insert_extl1
				, @area_id_2_insert_extl1
				, @is_creation_needed_in_unee_t_insert_extl1
				, @do_not_insert_insert_extl1_insert_extl1
				, @unee_t_unit_type_insert_extl1
				, @designation_insert_extl1
				, @tower_insert_extl1
				, @address_1_insert_extl1
				, @address_2_insert_extl1
				, @zip_postal_code_insert_extl1
				, @state_insert_extl1
				, @city_insert_extl1
				, @country_code_insert_extl1
				, @description_insert_extl1
				, @ext_l1_default_assignee_mgt_cny
				, @ext_l1_default_assignee_landlord
				, @ext_l1_default_assignee_tenant
				, @ext_l1_default_assignee_agent
				)
			ON DUPLICATE KEY UPDATE
				`syst_updated_datetime` = NOW()
				, `update_system_id` = @update_system_id_insert_extl1
				, `updated_by_id` = @updated_by_id_insert_extl1
				, `update_method` = @this_trigger_insert_extl1_update
				, `organization_id` = @organization_id_update_insert_extl1
				, `is_obsolete` = @is_obsolete_insert_extl1
				, `order` = @order_insert_extl1
				, `area_id` = @area_id_2_insert_extl1
				, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t_insert_extl1
				, `do_not_insert` = @do_not_insert_insert_extl1
				, `unee_t_unit_type` = @unee_t_unit_type_insert_extl1
				, `designation` = @designation_insert_extl1
				, `tower` = @tower_insert_extl1
				, `address_1` = @address_1_insert_extl1
				, `address_2` = @address_2_insert_extl1
				, `zip_postal_code` = @zip_postal_code_insert_extl1
				, `state` = @state_insert_extl1
				, `city` = @city_insert_extl1
				, `country_code` = @country_code_insert_extl1
				, `description` = @description_insert_extl1
				, `mgt_cny_default_assignee` = @ext_l1_default_assignee_mgt_cny
				, `landlord_default_assignee` = @ext_l1_default_assignee_landlord
				, `tenant_default_assignee` = @ext_l1_default_assignee_tenant
				, `agent_default_assignee` = @ext_l1_default_assignee_agent
			;

	END IF;

# Housekeeping - we make sure that if a building is obsolete - all units in that building are obsolete too

	SET @building_system_id_insert_extl1 = NEW.`id_building` ;

		UPDATE `external_property_level_2_units` AS `a`
			INNER JOIN `external_property_level_1_buildings` AS `b`
				ON (`a`.`building_system_id` = `b`.`id_building`)
			SET `a`.`is_obsolete` = `b`.`is_obsolete`
			WHERE `a`.`building_system_id` = @building_system_id_insert_extl1
				AND `a`.`tower` = @tower_insert_extl1
			;

END;
$$
DELIMITER ;

# Create the trigger when the extL1P is updated
# This trigger will:
#	- Check if several conditions are met
#	- Capture the value we need in several variables
#	- Do the update.

	DROP TRIGGER IF EXISTS `ut_after_update_external_property_level_1`;

DELIMITER $$
CREATE TRIGGER `ut_after_update_external_property_level_1`
AFTER UPDATE ON `external_property_level_1_buildings`
FOR EACH ROW
BEGIN

# We only do this if 
#	- We have a `external_id`
#	- We have a `external_system_id`
#	- We have a `external_table`
#	- We have a `organization_id`
#	- We have a `tower`
#	- We have a MEFE user ID for the user who did the update
#	- The `do_not_insert_field` is NOT equal to 1
#	- This is a valid update method:
#		- 'imported_from_hmlet_ipi'
#		- 'Manage_Buildings_Add_Page'
#		- 'Manage_Buildings_Edit_Page'
#		- 'Manage_Buildings_Import_Page'
#		- 'Export_and_Import_Buildings_Import_Page'
#		- ''

# Capture the variables we need to verify if conditions are met:

	SET @is_creation_needed_in_unee_t_update_extl1 = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator_update_extl1 = NEW.`created_by_id` ;

	SET @source_system_updated_by_id_update_extl1 = NEW.`updated_by_id` ;

	SET @source_system_updater_update_extl1 = (IF(@source_system_updated_by_id_update_extl1 IS NULL
			, @source_system_creator_update_extl1
			, @source_system_updated_by_id_update_extl1
			)
		) ;

	SET @creator_mefe_user_id_update_extl1 = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator_update_extl1
		)
		;

	SET @upstream_create_method_update_extl1 = NEW.`creation_method` ;
	SET @upstream_update_method_update_extl1 = NEW.`update_method` ;

	SET @organization_id_update_extl1 = @source_system_creator_update_extl1 ;

	SET @external_id_update_extl1 = NEW.`external_id` ;
	SET @external_system_id_update_extl1 = NEW.`external_system_id` ; 
	SET @external_table_update_extl1 = NEW.`external_table` ;
	SET @tower_update_extl1 = NEW.`tower` ;

	SET @new_is_creation_needed_in_unee_t_update_extl1 = NEW.`is_creation_needed_in_unee_t` ;
	SET @old_is_creation_needed_in_unee_t_update_extl1 = OLD.`is_creation_needed_in_unee_t` ;

	SET @id_in_property_level_1_buildings_update_extl1 = (SELECT `id_building`
		FROM `property_level_1_buildings`
		WHERE `external_system_id` = @external_system_id_update_extl1
			AND `external_table` = @external_table_update_extl1
			AND `external_id` = @external_id_update_extl1
			AND `organization_id` = @organization_id_update_extl1
			AND `tower` = @tower_update_extl1
		);

	SET @upstream_do_not_insert_update_extl1 = NEW.`do_not_insert` ;

	# Get the information about the area for that building...
	# We need the information from the table `property_groups_areas` (and NOT the table `external_property_groups_areas`)

		SET @area_id_1_update_extl1 = NEW.`area_id` ;

		SET @area_external_id_update_extl1 = (SELECT `external_id`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_1_update_extl1
			);
		SET @area_external_system_id_update_extl1 = (SELECT `external_system_id`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_1_update_extl1
			);
		SET @area_external_table_update_extl1 = (SELECT `external_table`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_1_update_extl1
			);

		SET @area_id_2_update_extl1 = (SELECT `id_area`
			FROM `property_groups_areas`
			WHERE `external_id` = @area_external_id_update_extl1
				AND `external_system_id` = @area_external_system_id_update_extl1
			   	AND `external_table` = @area_external_table_update_extl1
			   	AND `organization_id` = @organization_id_update_extl1
			);

# We can now check if the conditions are met:

	IF @is_creation_needed_in_unee_t_update_extl1 = 1
		AND @external_id_update_extl1 IS NOT NULL
		AND @external_system_id_update_extl1 IS NOT NULL
		AND @external_table_update_extl1 IS NOT NULL
		AND @tower_update_extl1 IS NOT NULL
		AND @organization_id_update_extl1 IS NOT NULL
		AND @area_id_2_update_extl1 IS NOT NULL
		AND (@upstream_create_method_update_extl1 = 'imported_from_hmlet_ipi'
			OR @upstream_update_method_update_extl1 = 'imported_from_hmlet_ipi'
			OR @upstream_create_method_update_extl1 = 'Manage_Buildings_Add_Page'
			OR @upstream_update_method_update_extl1 = 'Manage_Buildings_Add_Page'
			OR @upstream_create_method_update_extl1 = 'Manage_Buildings_Edit_Page'
			OR @upstream_update_method_update_extl1 = 'Manage_Buildings_Edit_Page'
			OR @upstream_create_method_update_extl1 = 'Manage_Buildings_Import_Page'
			OR @upstream_update_method_update_extl1 = 'Manage_Buildings_Import_Page'
			OR @upstream_create_method_update_extl1 = 'Export_and_Import_Buildings_Import_Page'
			OR @upstream_update_method_update_extl1 = 'Export_and_Import_Buildings_Import_Page'
			)
	THEN 

	# The conditions are met: we capture the other variables we need

		SET @creation_system_id_update_extl1 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator_update_extl1
			)
			;
		SET @created_by_id_update_extl1 = @creator_mefe_user_id_update_extl1 ;

		SET @update_system_id_update_extl1 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater_update_extl1
			)
			;

		SET @updated_by_id_update_extl1 = @creator_mefe_user_id_update_extl1 ;

		SET @organization_id_create_update_extl1 = @source_system_creator_update_extl1 ;
		SET @organization_id_update_update_extl1 = @source_system_updater_update_extl1 ;

		SET @is_obsolete_update_extl1 = NEW.`is_obsolete` ;
		SET @order_update_extl1 = NEW.`order` ;

		SET @unee_t_unit_type_update_extl1 = NEW.`unee_t_unit_type` ;
		SET @designation_update_extl1 = NEW.`designation` ;

		SET @address_1_update_extl1 = NEW.`address_1` ;
		SET @address_2_update_extl1 = NEW.`address_2` ;
		SET @zip_postal_code_update_extl1 = NEW.`zip_postal_code` ;
		SET @state_update_extl1 = NEW.`state` ;
		SET @city_update_extl1 = NEW.`city` ;
		SET @country_code_update_extl1 = NEW.`country_code` ;

		SET @description_update_extl1 = NEW.`description` ;

		SET @building_system_id_update_extl1 = NEW.`id_building` ;

		SET @ext_l1_default_assignee_mgt_cny := NEW.`mgt_cny_default_assignee` ;
		SET @ext_l1_default_assignee_landlord := NEW.`landlord_default_assignee` ;
		SET @ext_l1_default_assignee_tenant := NEW.`tenant_default_assignee` ;
		SET @ext_l1_default_assignee_agent := NEW.`agent_default_assignee` ;

		IF @new_is_creation_needed_in_unee_t_update_extl1 != @old_is_creation_needed_in_unee_t_update_extl1
		THEN 

			# This is option 1 - creation IS needed

				SET @this_trigger_update_extl1_insert = 'ut_after_update_external_property_level_1_insert_creation_needed';
				SET @this_trigger_update_extl1_update = 'ut_after_update_external_property_level_1_update_creation_needed';

			# We update the record in the table `property_level_1_buildings`
			# We do this via INSERT INTO ... ON DUPLICATE KEY UPDATE for maximum safety

				INSERT INTO `property_level_1_buildings`
					(`external_id`
					, `external_system_id` 
					, `external_table`
					, `syst_created_datetime`
					, `creation_system_id`
					, `created_by_id`
					, `creation_method`
					, `organization_id`
					, `is_obsolete`
					, `order`
					, `area_id`
					, `is_creation_needed_in_unee_t`
					, `do_not_insert`
					, `unee_t_unit_type`
					, `designation`
					, `tower`
					, `address_1`
					, `address_2`
					, `zip_postal_code`
					, `state`
					, `city`
					, `country_code`
					, `description`
					, `mgt_cny_default_assignee`
					, `landlord_default_assignee`
					, `tenant_default_assignee`
					, `agent_default_assignee`
					)
					VALUES
						(@external_id_update_extl1
						, @external_system_id_update_extl1
						, @external_table_update_extl1
						, NOW()
						, @creation_system_id_update_extl1
						, @created_by_id_update_extl1
						, @this_trigger_update_extl1_insert
						, @organization_id_create_update_extl1
						, @is_obsolete_update_extl1
						, @order_update_extl1
						, @area_id_2_update_extl1
						, @is_creation_needed_in_unee_t_update_extl1
						, @do_not_insert_update_extl1
						, @unee_t_unit_type_update_extl1
						, @designation_update_extl1
						, @tower_update_extl1
						, @address_1_update_extl1
						, @address_2_update_extl1
						, @zip_postal_code_update_extl1
						, @state_update_extl1
						, @city_update_extl1
						, @country_code_update_extl1
						, @description_update_extl1
						, @ext_l1_default_assignee_mgt_cny
						, @ext_l1_default_assignee_landlord
						, @ext_l1_default_assignee_tenant
						, @ext_l1_default_assignee_agent
						)
					ON DUPLICATE KEY UPDATE
						`syst_updated_datetime` = NOW()
						, `update_system_id` = @update_system_id_update_extl1
						, `updated_by_id` = @updated_by_id_update_extl1
						, `update_method` = @this_trigger_update_extl1_update
						, `organization_id` = @organization_id_update_update_extl1
						, `is_obsolete` = @is_obsolete_update_extl1
						, `order` = @order_update_extl1
						, `area_id` = @area_id_2_update_extl1
						, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t_update_extl1
						, `do_not_insert` = @do_not_insert_update_extl1
						, `unee_t_unit_type` = @unee_t_unit_type_update_extl1
						, `designation` = @designation_update_extl1
						, `tower` = @tower_update_extl1
						, `address_1` = @address_1_update_extl1
						, `address_2` = @address_2_update_extl1
						, `zip_postal_code` = @zip_postal_code_update_extl1
						, `state` = @state_update_extl1
						, `city` = @city_update_extl1
						, `country_code` = @country_code_update_extl1
						, `description` = @description_update_extl1
						, `mgt_cny_default_assignee` = @ext_l1_default_assignee_mgt_cny
						, `landlord_default_assignee` = @ext_l1_default_assignee_landlord
						, `tenant_default_assignee` = @ext_l1_default_assignee_tenant
						, `agent_default_assignee` = @ext_l1_default_assignee_agent
					;

			# Housekeeping - we make sure that if a building is obsolete - all units in that building are obsolete too

				UPDATE `external_property_level_2_units` AS `a`
					INNER JOIN `external_property_level_1_buildings` AS `b`
						ON (`a`.`building_system_id` = `b`.`id_building`)
					SET `a`.`is_obsolete` = `b`.`is_obsolete`
					WHERE `a`.`building_system_id` = @building_system_id_update_extl1
						AND `a`.`tower` = @tower_update_extl1
					;

		ELSEIF @new_is_creation_needed_in_unee_t_update_extl1 = @old_is_creation_needed_in_unee_t_update_extl1
		THEN 
			
			# This is option 2 - creation is NOT needed

				SET @this_trigger_update_extl1_insert = 'ut_after_update_external_property_level_1_insert_update_needed';
				SET @this_trigger_update_extl1_update = 'ut_after_update_external_property_level_1_update_update_needed';

			# We update the record in the table `property_level_1_buildings`
			# We do this via INSERT INTO ... ON DUPLICATE KEY UPDATE for maximum safety

				INSERT INTO `property_level_1_buildings`
					(`external_id`
					, `external_system_id` 
					, `external_table`
					, `syst_created_datetime`
					, `creation_system_id`
					, `created_by_id`
					, `creation_method`
					, `organization_id`
					, `is_obsolete`
					, `order`
					, `area_id`
					, `is_creation_needed_in_unee_t`
					, `do_not_insert`
					, `unee_t_unit_type`
					, `designation`
					, `tower`
					, `address_1`
					, `address_2`
					, `zip_postal_code`
					, `state`
					, `city`
					, `country_code`
					, `description`
					, `mgt_cny_default_assignee`
					, `landlord_default_assignee`
					, `tenant_default_assignee`
					, `agent_default_assignee`
					)
					VALUES
						(@external_id_update_extl1
						, @external_system_id_update_extl1
						, @external_table_update_extl1
						, NOW()
						, @creation_system_id_update_extl1
						, @created_by_id_update_extl1
						, @this_trigger_update_extl1_insert
						, @organization_id_create_update_extl1
						, @is_obsolete_update_extl1
						, @order_update_extl1
						, @area_id_2_update_extl1
						, @is_creation_needed_in_unee_t_update_extl1
						, @do_not_insert_update_extl1
						, @unee_t_unit_type_update_extl1
						, @designation_update_extl1
						, @tower_update_extl1
						, @address_1_update_extl1
						, @address_2_update_extl1
						, @zip_postal_code_update_extl1
						, @state_update_extl1
						, @city_update_extl1
						, @country_code_update_extl1
						, @description_update_extl1
						, @ext_l1_default_assignee_mgt_cny
						, @ext_l1_default_assignee_landlord
						, @ext_l1_default_assignee_tenant
						, @ext_l1_default_assignee_agent
						)
					ON DUPLICATE KEY UPDATE
						`syst_updated_datetime` = NOW()
						, `update_system_id` = @update_system_id_update_extl1
						, `updated_by_id` = @updated_by_id_update_extl1
						, `update_method` = @this_trigger_update_extl1_update
						, `organization_id` = @organization_id_update_update_extl1
						, `is_obsolete` = @is_obsolete_update_extl1
						, `order` = @order_update_extl1
						, `area_id` = @area_id_2_update_extl1
						, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t_update_extl1
						, `do_not_insert` = @do_not_insert_update_extl1
						, `unee_t_unit_type` = @unee_t_unit_type_update_extl1
						, `designation` = @designation_update_extl1
						, `tower` = @tower_update_extl1
						, `address_1` = @address_1_update_extl1
						, `address_2` = @address_2_update_extl1
						, `zip_postal_code` = @zip_postal_code_update_extl1
						, `state` = @state_update_extl1
						, `city` = @city_update_extl1
						, `country_code` = @country_code_update_extl1
						, `description` = @description_update_extl1
						, `mgt_cny_default_assignee` = @ext_l1_default_assignee_mgt_cny
						, `landlord_default_assignee` = @ext_l1_default_assignee_landlord
						, `tenant_default_assignee` = @ext_l1_default_assignee_tenant
						, `agent_default_assignee` = @ext_l1_default_assignee_agent
					;

			# Housekeeping - we make sure that if a building is obsolete - all units in that building are obsolete too

				UPDATE `external_property_level_2_units` AS `a`
					INNER JOIN `external_property_level_1_buildings` AS `b`
						ON (`a`.`building_system_id` = `b`.`id_building`)
					SET `a`.`is_obsolete` = `b`.`is_obsolete`
					WHERE `a`.`building_system_id` = @building_system_id_update_extl1
						AND `a`.`tower` = @tower_update_extl1
					;

		END IF;

	# The conditions are NOT met <-- we do nothing

	END IF;

END;
$$
DELIMITER ;

# Create a trigger to update the table that will fire the lambda each time a new building needs to be created

		DROP TRIGGER IF EXISTS `ut_after_insert_in_property_level_1`;

DELIMITER $$
CREATE TRIGGER `ut_after_insert_in_property_level_1`
AFTER INSERT ON `property_level_1_buildings`
FOR EACH ROW
BEGIN

# We do this ONLY IF 
#	- We have marked the property as an object we need to create in Unee-T
#	- The record does NOT exist in the table `ut_map_external_source_units` yet
#	- The record has NOT been explicitly been marked as `do_not_insert`
#	- This is done via an authorized Insert Method:
#		- 'ut_after_insert_in_external_property_level_1_insert'
#		- 'ut_after_insert_in_external_property_level_1_update'
#		- 'ut_after_update_external_property_level_1_insert_creation_needed'
#		- 'ut_after_update_external_property_level_1_update_creation_needed'
#		- 'ut_after_update_external_property_level_1_insert_update_needed'
#		- 'ut_after_update_external_property_level_1_update_update_needed'
#

	SET @is_creation_needed_in_unee_t_insert_l1 = NEW.`is_creation_needed_in_unee_t` ;

	SET @external_property_id_insert_l1 = NEW.`external_id` ;
	SET @external_system_insert_l1 = NEW.`external_system_id` ;
	SET @table_in_external_system_insert_l1 = NEW.`external_table` ;
	SET @organization_id_insert_l1 = NEW.`organization_id`;
	SET @tower_insert_l1 = NEW.`tower` ; 

	SET @id_building_insert_l1 = NEW.`id_building` ;

	SET @external_property_type_id_insert_l1 = 1 ;

	SET @id_in_ut_map_external_source_units_insert_l1 = (SELECT `id_map`
		FROM `ut_map_external_source_units`
		WHERE `external_property_type_id` = @external_property_type_id_insert_l1
			AND `external_property_id` = @external_property_id_insert_l1
			AND `external_system` = @external_system_insert_l1
			AND `table_in_external_system` = @table_in_external_system_insert_l1
			AND `organization_id` = @organization_id_insert_l1
			AND `tower` = @tower_insert_l1
		);

	SET @existing_mefe_unit_id_insert_l1 = (SELECT `unee_t_mefe_unit_id`
		FROM `ut_map_external_source_units`
		WHERE `external_property_type_id` = @external_property_type_id_insert_l1
			AND `external_property_id` = @external_property_id_insert_l1
			AND `external_system` = @external_system_insert_l1
			AND `table_in_external_system` = @table_in_external_system_insert_l1
			AND `organization_id` = @organization_id_insert_l1
			AND `tower` = @tower_insert_l1
		);

	# This is an insert - if the record does NOT exist, we create the record
	# unless 
	#	- it is specifically specified that we do NOT need to create the record.
	#	- the record is marked as obsolete

		SET @is_obsolete_insert_l1 = NEW.`is_obsolete`;

		SET @do_not_insert_insert_l1_raw = NEW.`do_not_insert` ;

		SET @do_not_insert_insert_l1 = (IF (@id_in_ut_map_external_source_units_insert_l1 IS NULL
				,  IF (@is_obsolete_insert_l1 != 0
					, 1
					, 0
					)
				, IF (@is_obsolete_insert_l1 != 0
					, 1
					, @do_not_insert_insert_l1_raw
					)
				)
			);

	SET @upstream_create_method_insert_l1 = NEW.`creation_method` ;
	SET @upstream_update_method_insert_l1 = NEW.`update_method` ;

	IF @is_creation_needed_in_unee_t_insert_l1 = 1
		AND @do_not_insert_insert_l1 = 0
		AND @existing_mefe_unit_id_insert_l1 IS NULL
		AND (@upstream_create_method_insert_l1 = 'ut_after_insert_in_external_property_level_1_insert'
			OR @upstream_update_method_insert_l1 = 'ut_after_insert_in_external_property_level_1_update'
			OR @upstream_create_method_insert_l1 = 'ut_after_update_external_property_level_1_insert_creation_needed'
			OR @upstream_update_method_insert_l1 = 'ut_after_update_external_property_level_1_update_creation_needed'
			OR @upstream_create_method_insert_l1 = 'ut_after_update_external_property_level_1_insert_update_needed'
			OR @upstream_update_method_insert_l1 = 'ut_after_update_external_property_level_1_update_update_needed'
			)
	THEN 

	# We capture the values we need for the insert/udpate:

		SET @this_trigger_insert_l1_insert = 'ut_after_insert_in_property_level_1_insert' ;
		SET @this_trigger_insert_l1_update = 'ut_after_insert_in_property_level_1_update' ;

		SET @creation_system_id_insert_l1 = NEW.`creation_system_id`;
		SET @created_by_id_insert_l1 = NEW.`created_by_id`;

		SET @update_system_id_insert_l1 = NEW.`creation_system_id` ;
		SET @updated_by_id_insert_l1 = NEW.`created_by_id`;

		SET @is_update_needed_insert_l1 = NULL ;
			
		SET @uneet_name_insert_l1 = NEW.`designation`;

		SET @unee_t_unit_type_insert_l1_raw = NEW.`unee_t_unit_type` ;

		SET @unee_t_unit_type_insert_l1 = (IFNULL(@unee_t_unit_type_insert_l1_raw
				, 'Unknown'
				)
			)
			;
			
		SET @new_record_id_insert_l1 = NEW.`id_building` ;

		SET @l1_default_assignee_mgt_cny := NEW.`mgt_cny_default_assignee` ;
		SET @l1_default_assignee_landlord := NEW.`landlord_default_assignee` ;
		SET @l1_default_assignee_tenant := NEW.`tenant_default_assignee` ;
		SET @l1_default_assignee_agent := NEW.`agent_default_assignee` ;
		
		# We insert/Update a new record in the table `ut_map_external_source_units`

			INSERT INTO `ut_map_external_source_units`
				( `syst_created_datetime`
				, `creation_system_id`
				, `created_by_id`
				, `creation_method`
				, `organization_id`
				, `datetime_latest_trigger`
				, `latest_trigger`
				, `is_obsolete`
				, `is_update_needed`
				, `uneet_name`
				, `unee_t_unit_type`
				, `new_record_id`
				, `external_property_type_id`
				, `external_property_id`
				, `external_system`
				, `table_in_external_system`
				, `tower`
				, `mgt_cny_default_assignee`
				, `landlord_default_assignee`
				, `tenant_default_assignee`
				, `agent_default_assignee`
				)
				VALUES
					(NOW()
					, @creation_system_id_insert_l1
					, @created_by_id_insert_l1
					, @this_trigger_insert_l1_insert
					, @organization_id_insert_l1
					, NOW()
					, @this_trigger_insert_l1_insert
					, @is_obsolete_insert_l1
					, @is_update_needed_insert_l1
					, @uneet_name_insert_l1
					, @unee_t_unit_type_insert_l1
					, @new_record_id_insert_l1
					, @external_property_type_id_insert_l1
					, @external_property_id_insert_l1
					, @external_system_insert_l1
					, @table_in_external_system_insert_l1
					, @tower_insert_l1
					, @l1_default_assignee_mgt_cny
					, @l1_default_assignee_landlord
					, @l1_default_assignee_tenant
					, @l1_default_assignee_agent
					)
				ON DUPLICATE KEY UPDATE 
					`syst_updated_datetime` = NOW()
					, `update_system_id` = @update_system_id_insert_l1
					, `updated_by_id` = @updated_by_id_insert_l1
					, `update_method` = @this_trigger_insert_l1_update
					, `organization_id` = @organization_id_insert_l1
					, `datetime_latest_trigger` = NOW()
					, `latest_trigger` = @this_trigger_insert_l1_update
					, `uneet_name` = @uneet_name_insert_l1
					, `unee_t_unit_type` = @unee_t_unit_type_insert_l1
					, `is_update_needed` = 1
					, `mgt_cny_default_assignee` = @l1_default_assignee_mgt_cny
					, `landlord_default_assignee` = @l1_default_assignee_landlord
					, `tenant_default_assignee` = @l1_default_assignee_tenant
					, `agent_default_assignee` = @l1_default_assignee_agent
				;

	END IF;

END;
$$
DELIMITER ;

# Create the trigger when the L1P is updated
# This trigger will:
#	- Check if several conditions are met
#	- Capture the value we need in several variables
#	- Do the Insert/update if needed

	DROP TRIGGER IF EXISTS `ut_after_update_property_level_1`;

DELIMITER $$
CREATE TRIGGER `ut_after_update_property_level_1`
AFTER UPDATE ON `property_level_1_buildings`
FOR EACH ROW
BEGIN

# We only do this IF:
# 	- We need to create the unit in Unee-T
#	- The record has NOT been explicitly been marked as `do_not_insert`
#	- This is done via an authorized update Method:
#		- `ut_after_insert_in_external_property_level_1_insert`
#		- 'ut_after_insert_in_external_property_level_1_update'
#		- 'ut_after_update_external_property_level_1_insert_creation_needed'
#		- 'ut_after_update_external_property_level_1_update_creation_needed'
#		- 'ut_after_update_external_property_level_1_insert_update_needed'
#		- 'ut_after_update_external_property_level_1_update_update_needed'
#

# Capture the variables we need to verify if conditions are met:

	SET @upstream_create_method_update_l1 = NEW.`creation_method` ;
	SET @upstream_update_method_update_l1 = NEW.`update_method` ;
			
	SET @new_record_id_update_l1 = NEW.`id_building`;

	SET @check_new_record_id_update_l1 = (IF(@new_record_id_update_l1 IS NULL
			, 0
			, IF(@new_record_id_update_l1 = ''
				, 0
				, 1
				)
			)
		)
		;

# We can now check if the conditions are met:

	IF (@upstream_create_method_update_l1 = 'ut_after_insert_in_external_property_level_1_insert'
			OR @upstream_update_method_update_l1 = 'ut_after_insert_in_external_property_level_1_update'
			OR @upstream_create_method_update_l1 = 'ut_after_update_external_property_level_1_insert_creation_needed'
			OR @upstream_update_method_update_l1 = 'ut_after_update_external_property_level_1_update_creation_needed'
			OR @upstream_create_method_update_l1 = 'ut_after_update_external_property_level_1_insert_update_needed'
			OR @upstream_update_method_update_l1 = 'ut_after_update_external_property_level_1_update_update_needed'
			)
		AND @check_new_record_id_update_l1 = 1
	THEN 

	# Clean Slate - Make sure we don't use a legacy MEFE id

		SET @mefe_unit_id_update_l1 = NULL ;

	# The conditions are met: we capture the other variables we need

		SET @is_creation_needed_in_unee_t_update_l1 = NEW.`is_creation_needed_in_unee_t` ;

		SET @tower_update_l1 = NEW.`tower` ; 

		SET @new_is_creation_needed_in_unee_t_update_l1 =  NEW.`is_creation_needed_in_unee_t` ;
		SET @old_is_creation_needed_in_unee_t_update_l1 = OLD.`is_creation_needed_in_unee_t` ; 

		SET @creation_system_id_update_l1 = NEW.`update_system_id` ;
		SET @created_by_id_update_l1 = NEW.`updated_by_id` ;

		SET @update_system_id_update_l1 = NEW.`update_system_id` ;
		SET @updated_by_id_update_l1 = NEW.`updated_by_id` ;

		SET @organization_id_update_l1 = NEW.`organization_id` ;

		SET @tower_update_l1 = NEW.`tower` ; 
			
		SET @is_update_needed_update_l1 = NULL ;
			
		SET @uneet_name_update_l1 = NEW.`designation`;

		SET @unee_t_unit_type_update_l1_raw = NEW.`unee_t_unit_type` ;

		SET @unee_t_unit_type_update_l1 = (IFNULL(@unee_t_unit_type_update_l1_raw
				, 'Unknown'
				)
			)
			;

		SET @external_property_id_update_l1 = NEW.`external_id` ;
		SET @external_system_update_l1 = NEW.`external_system_id` ;
		SET @table_in_external_system_update_l1 = NEW.`external_table` ;
	
		SET @external_property_type_id_update_l1 = 1 ;

		SET @mefe_unit_id_update_l1 = (SELECT `unee_t_mefe_unit_id`
			FROM `ut_map_external_source_units`
			WHERE `new_record_id` = @new_record_id_update_l1
				AND `external_property_type_id` = @external_property_type_id_update_l1
				AND `unee_t_mefe_unit_id` IS NOT NULL
			)
			;

		SET @l1_default_assignee_mgt_cny := NEW.`mgt_cny_default_assignee` ;
		SET @l1_default_assignee_landlord := NEW.`landlord_default_assignee` ;
		SET @l1_default_assignee_tenant := NEW.`tenant_default_assignee` ;
		SET @l1_default_assignee_agent := NEW.`agent_default_assignee` ;
		
		# If the record does NOT exist, we create the record
		# unless 
		#	- it is specifically specified that we do NOT need to create the record.
		#	- the record is marked as obsolete

			SET @do_not_insert_update_l1_raw = NEW.`do_not_insert` ;

			SET @is_obsolete_update_l1 = NEW.`is_obsolete`;

			SET @do_not_insert_update_l1 = (IF (@do_not_insert_update_l1_raw IS NULL
					, IF (@is_obsolete_update_l1 != 0
						, 1
						, 0
						)
					, IF (@is_obsolete_update_l1 != 0
						, 1
						, @do_not_insert_update_l1_raw
						)
					)
				);
	
		IF @is_creation_needed_in_unee_t_update_l1 = 1
			AND (@mefe_unit_id_update_l1 IS NULL
				OR  @mefe_unit_id_update_l1 = ''
				)
			AND @do_not_insert_update_l1 = 0
		THEN 

			# This is option 1 - creation IS needed

				SET @this_trigger_update_l1_insert = 'ut_after_update_property_level_1_insert_creation_needed' ;
				SET @this_trigger_update_l1_update = 'ut_after_update_property_level_1_update_creation_needed' ;
		
			# We insert/Update a new record in the table `ut_map_external_source_units`

				INSERT INTO `ut_map_external_source_units`
					( `syst_created_datetime`
					, `creation_system_id`
					, `created_by_id`
					, `creation_method`
					, `organization_id`
					, `datetime_latest_trigger`
					, `latest_trigger`
					, `is_obsolete`
					, `is_update_needed`
					, `uneet_name`
					, `unee_t_unit_type`
					, `new_record_id`
					, `external_property_type_id`
					, `external_property_id`
					, `external_system`
					, `table_in_external_system`
					, `tower`
					, `mgt_cny_default_assignee`
					, `landlord_default_assignee`
					, `tenant_default_assignee`
					, `agent_default_assignee`
					)
					VALUES
						(NOW()
						, @creation_system_id_update_l1
						, @created_by_id_update_l1
						, @this_trigger_update_l1_insert
						, @organization_id_update_l1
						, NOW()
						, @this_trigger_update_l1_insert
						, @is_obsolete_update_l1
						, @is_update_needed_update_l1
						, @uneet_name_update_l1
						, @unee_t_unit_type_update_l1
						, @new_record_id_update_l1
						, @external_property_type_id_update_l1
						, @external_property_id_update_l1
						, @external_system_update_l1
						, @table_in_external_system_update_l1
						, @tower_update_l1
						, @l1_default_assignee_mgt_cny
						, @l1_default_assignee_landlord
						, @l1_default_assignee_tenant
						, @l1_default_assignee_agent
						)
					ON DUPLICATE KEY UPDATE
						`syst_updated_datetime` = NOW()
						, `update_system_id` = @update_system_id_update_l1
						, `updated_by_id` = @updated_by_id_update_l1
						, `update_method` = @this_trigger_update_l1_update
						, `organization_id` = @organization_id_update_l1
						, `datetime_latest_trigger` = NOW()
						, `latest_trigger` = @this_trigger_update_l1_update
						, `uneet_name` = @uneet_name_update_l1
						, `unee_t_unit_type` = @unee_t_unit_type_update_l1
						, `is_update_needed` = 1
						, `mgt_cny_default_assignee` = @l1_default_assignee_mgt_cny
						, `landlord_default_assignee` = @l1_default_assignee_landlord
						, `tenant_default_assignee` = @l1_default_assignee_tenant
						, `agent_default_assignee` = @l1_default_assignee_agent
					;

###################################################################
#
# THIS IS CREATING SUBQUERY RETURN MORE THAN 1 ROW ERRORS
#
###################################################################

		ELSEIF @mefe_unit_id_update_l1 IS NOT NULL
			OR @mefe_unit_id_update_l1 != ''
		THEN 
			
			# This is option 2 - creation is NOT needed

				SET @this_trigger_update_l1_insert = 'ut_after_update_property_level_1_insert_update_needed' ;
				SET @this_trigger_update_l1_update = 'ut_after_update_property_level_1_update_update_needed' ;

			# We Update the existing new record in the table `ut_map_external_source_units`

				UPDATE `ut_map_external_source_units`
					SET 
						`syst_updated_datetime` = NOW()
						, `update_system_id` = @update_system_id_update_l1
						, `updated_by_id` = @updated_by_id_update_l1
						, `update_method` = @this_trigger_update_l1_update
						, `organization_id` = @organization_id_update_l1
						, `datetime_latest_trigger` = NOW()
						, `latest_trigger` = @this_trigger_update_l1_update
						, `uneet_name` = @uneet_name_update_l1
						, `unee_t_unit_type` = @unee_t_unit_type_update_l1
						, `is_update_needed` = 1
						, `mgt_cny_default_assignee` = @l1_default_assignee_mgt_cny
						, `landlord_default_assignee` = @l1_default_assignee_landlord
						, `tenant_default_assignee` = @l1_default_assignee_tenant
						, `agent_default_assignee` = @l1_default_assignee_agent
					WHERE `unee_t_mefe_unit_id` = @mefe_unit_id_update_l1
					;

###################################################################
#
# END IS CREATING SUBQUERY RETURN MORE THAN 1 ROW ERRORS
#
###################################################################

		END IF;

	END IF;

	# The conditions are NOT met <-- we do nothing

END;
$$
DELIMITER ;

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
#OK		- Add a check to make sure we can get the MEFE unit ID if we need to update
#WIP			- IF we do NOT have a default assignee, 
#				  THEN we use the default assignee for the L1P

#################
#
# This lists all the triggers we use to create 
# a property_level_2
# via the Unee-T Enterprise Interface
#
#################

# This script creates or updates the following 
# 	- Procedures: 
#		- `ut_update_L2P_when_ext_L2P_is_updated`
#		- `ut_update_uneet_when_L2P_is_updated`
#	- triggers:
#		- `ut_insert_external_property_level_2`
#		- `ut_after_update_external_property_level_2`
#		- `ut_after_update_property_level_2`

# We create a trigger when a record is added to the `external_property_level_2_units` table

	DROP TRIGGER IF EXISTS `ut_after_insert_in_external_property_level_2`;

DELIMITER $$
CREATE TRIGGER `ut_after_insert_in_external_property_level_2`
AFTER INSERT ON `external_property_level_2_units`
FOR EACH ROW
BEGIN

# We only do this if 
#	- We need to create the unit in Unee-T
#	- We have a `external_id`
#	- We have a `external_system_id`
#	- We have a `external_table`
#	- We have a `organization_id`
#	- We have a MEFE user ID for the user who did the update
#	- The unit does NOT exists in the table `property_level_2_units`
#   - we have a valid building ID for this unit.
#	- This is a valid insert method:
#		- 'imported_from_hmlet_ipi'
#		- 'Manage_Units_Add_Page'
#		- 'Manage_Units_Edit_Page'
#		- 'Manage_Units_Import_Page'
#		- 'Export_and_Import_Units_Import_Page'
#		- ''

	SET @is_creation_needed_in_unee_t_insert_extl2 = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator_insert_extl2 = NEW.`created_by_id` ;

	SET @source_system_updated_by_id_insert_extl2 = NEW.`updated_by_id` ;

	SET @source_system_updater_insert_extl2 = (IF(@source_system_updated_by_id_insert_extl2 IS NULL
			, @source_system_creator_insert_extl2
			, @source_system_updated_by_id_insert_extl2
			)
		);

	SET @creator_mefe_user_id_insert_extl2 = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator_insert_extl2
		)
		;

	SET @upstream_create_method_insert_extl2 = NEW.`creation_method` ;
	SET @upstream_update_method_insert_extl2 = NEW.`update_method` ;

	SET @external_system_id_insert_extl2 = NEW.`external_system_id` ;
	SET @external_table_insert_extl2 = NEW.`external_table` ;
	SET @external_id_insert_extl2 = NEW.`external_id` ;

	SET @organization_id_insert_extl2 = @source_system_creator_insert_extl2 ;

	SET @id_in_property_level_2_units_insert_extl2 = (SELECT `system_id_unit`
		FROM `property_level_2_units`
		WHERE `external_system_id` = @external_system_id_insert_extl2
			AND `external_table` = @external_table_insert_extl2
			AND `external_id` = @external_id_insert_extl2
			AND `organization_id` = @organization_id_insert_extl2
		);
		
	SET @upstream_do_not_insert_insert_extl2 = NEW.`do_not_insert` ;

	# This is an INSERT - the record should NOT exist already

		SET @do_not_insert_insert_extl2 = (IF (@id_in_property_level_2_units_insert_extl2 IS NULL
				, 0
				, @upstream_do_not_insert_insert_extl2
				)
			
			);

	# Get the information about the building for that unit...
	# We need the information from the table `external_property_level_2_units` (and NOT the table `external_external_property_level_1_buildings`)
	
		SET @building_id_1_insert_extl2 = NEW.`building_system_id` ;

		SET @tower_insert_extl2 = NEW.`tower` ;

		SET @building_external_id_insert_extl2 = (SELECT `external_id`
			FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_1_insert_extl2
				);
		SET @building_external_system_id_insert_extl2 = (SELECT `external_system_id`
			FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_1_insert_extl2
			);
		SET @building_external_table_insert_extl2 = (SELECT `external_table`
		   FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_1_insert_extl2
			);
		SET @building_external_tower_insert_extl2 = (SELECT `tower`
			FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_1_insert_extl2
			);

		SET @building_system_id_insert_extl2 = (SELECT `id_building`
			FROM `property_level_1_buildings`
			WHERE `external_id` = @building_external_id_insert_extl2
				AND `external_system_id` = @building_external_system_id_insert_extl2
				AND `external_table` = @building_external_table_insert_extl2
				AND `organization_id` = @organization_id_insert_extl2
				AND `tower` = @building_external_tower_insert_extl2
				);

		SET @activated_by_id_insert_extl2 = NEW.`activated_by_id` ;
		SET @is_obsolete_insert_extl2 = NEW.`is_obsolete` ;
		SET @is_creation_needed_in_unee_t_insert_extl2 = NEW.`is_creation_needed_in_unee_t` ;
		SET @unee_t_unit_type_insert_extl2 = NEW.`unee_t_unit_type` ;
			
		SET @unit_category_id_insert_extl2 = NEW.`unit_category_id` ;
		SET @designation_insert_extl2 = NEW.`designation` ;
		SET @count_rooms_insert_extl2 = NEW.`count_rooms` ;
		SET @unit_id_insert_extl2 = NEW.`unit_id` ;
		SET @surface_insert_extl2 = NEW.`surface` ;
		SET @surface_measurment_unit_insert_extl2 = NEW.`surface_measurment_unit` ;
		SET @description_insert_extl2 = NEW.`description` ;

		SET @system_id_unit_insert_extl2 = NEW.`system_id_unit` ;

	IF @is_creation_needed_in_unee_t_insert_extl2 = 1
		AND @do_not_insert_insert_extl2 = 0
		AND @external_id_insert_extl2 IS NOT NULL
		AND @external_system_id_insert_extl2 IS NOT NULL
		AND @external_table_insert_extl2 IS NOT NULL
		AND @organization_id_insert_extl2 IS NOT NULL
		AND @building_system_id_insert_extl2 IS NOT NULL
		AND (@upstream_create_method_insert_extl2 = 'imported_from_hmlet_ipi'
			OR @upstream_create_method_insert_extl2 = 'Manage_Units_Add_Page'
			OR @upstream_create_method_insert_extl2 = 'Manage_Units_Edit_Page'
			OR @upstream_create_method_insert_extl2 = 'Manage_Units_Import_Page'
			OR @upstream_update_method_insert_extl2 = 'imported_from_hmlet_ipi'
			OR @upstream_update_method_insert_extl2 = 'Manage_Units_Add_Page'
			OR @upstream_update_method_insert_extl2 = 'Manage_Units_Edit_Page'
			OR @upstream_create_method_insert_extl2 = 'Manage_Units_Import_Page'
			OR @upstream_update_method_insert_extl2 = 'Export_and_Import_Units_Import_Page'
			OR @upstream_create_method_insert_extl2 = 'Export_and_Import_Units_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `external_property_level_2_units` table:

		SET @this_trigger_insert_extl2_insert = 'ut_after_insert_in_external_property_level_2_insert' ;
		SET @this_trigger_insert_extl2_update = 'ut_after_insert_in_external_property_level_2_update' ;

		SET @creation_system_id_insert_extl2 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator_insert_extl2
			)
			;
		SET @created_by_id_insert_extl2 = @creator_mefe_user_id_insert_extl2 ;

		SET @update_system_id_insert_extl2 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater_insert_extl2
			)
			;
		SET @updated_by_id_insert_extl2 = @creator_mefe_user_id_insert_extl2 ;

		SET @organization_id_create_insert_extl2 = @source_system_creator_insert_extl2 ;
		SET @organization_id_update_insert_extl2 = @source_system_updater_insert_extl2 ;

		SET @ext_l2_default_assignee_mgt_cny := NEW.`mgt_cny_default_assignee` ;
		SET @ext_l2_default_assignee_landlord := NEW.`landlord_default_assignee` ;
		SET @ext_l2_default_assignee_tenant := NEW.`tenant_default_assignee` ;
		SET @ext_l2_default_assignee_agent := NEW.`agent_default_assignee` ;


	# We insert the record in the table `property_level_2_units`
	# We do this via INSERT INTO ... ON DUPLICATE KEY UPDATE for maximum safety

		INSERT INTO `property_level_2_units`
			(`external_id`
			, `external_system_id` 
			, `external_table`
			, `syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `creation_method`
			, `organization_id`
			, `activated_by_id`
			, `is_obsolete`
			, `is_creation_needed_in_unee_t`
			, `do_not_insert`
			, `unee_t_unit_type`
			, `building_system_id`
			, `tower`
			, `unit_category_id`
			, `designation`
			, `count_rooms`
			, `unit_id`
			, `surface`
			, `surface_measurment_unit`
			, `description`
			, `mgt_cny_default_assignee`
			, `landlord_default_assignee`
			, `tenant_default_assignee`
			, `agent_default_assignee`
			)
			VALUES
 				(@external_id_insert_extl2
				, @external_system_id_insert_extl2
				, @external_table_insert_extl2
				, NOW()
				, @creation_system_id_insert_extl2
				, @created_by_id_insert_extl2
				, @this_trigger_insert_extl2_insert
				, @organization_id_create_insert_extl2
				, @activated_by_id_insert_extl2
				, @is_obsolete_insert_extl2
				, @is_creation_needed_in_unee_t_insert_extl2
				, @do_not_insert_insert_extl2
				, @unee_t_unit_type_insert_extl2
				, @building_system_id_insert_extl2
				, @tower_insert_extl2
				, @unit_category_id_insert_extl2
				, @designation_insert_extl2
				, @count_rooms_insert_extl2
				, @unit_id_insert_extl2
				, @surface_insert_extl2
				, @surface_measurment_unit_insert_extl2
				, @description_insert_extl2
				, @ext_l2_default_assignee_mgt_cny
				, @ext_l2_default_assignee_landlord
				, @ext_l2_default_assignee_tenant
				, @ext_l2_default_assignee_agent
 			)
			ON DUPLICATE KEY UPDATE
 				`syst_updated_datetime` = NOW()
 				, `update_system_id` = @update_system_id_insert_extl2
 				, `updated_by_id` = @updated_by_id_insert_extl2
				, `update_method` = @this_trigger_insert_extl2_update
				, `activated_by_id` = @activated_by_id_insert_extl2
				, `organization_id` = @organization_id_update_insert_extl2
				, `is_obsolete` = @is_obsolete_insert_extl2
				, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t_insert_extl2
				, `do_not_insert` = @do_not_insert_insert_extl2
				, `unee_t_unit_type` = @unee_t_unit_type_insert_extl2
				, `building_system_id` = @building_system_id_insert_extl2
				, `tower` = @tower_insert_extl2
				, `unit_category_id` = @unit_category_id_insert_extl2
				, `designation` = @designation_insert_extl2
				, `count_rooms` = @count_rooms_insert_extl2_insert_extl2
				, `unit_id` = @unit_id_insert_extl2
				, `surface` = @surface_insert_extl2
				, `surface_measurment_unit` = @surface_measurment_unit_insert_extl2
				, `description` = @description_insert_extl2
				, `mgt_cny_default_assignee` = @ext_l2_default_assignee_mgt_cny
				, `landlord_default_assignee` = @ext_l2_default_assignee_landlord
				, `tenant_default_assignee` = @ext_l2_default_assignee_tenant
				, `agent_default_assignee` = @ext_l2_default_assignee_agent
			;

	# Housekeeping - we make sure that if a unit is obsolete - all rooms in that unit are obsolete too

		UPDATE `external_property_level_3_rooms` AS `a`
			INNER JOIN `external_property_level_2_units` AS `b`
				ON (`a`.`system_id_unit` = `b`.`system_id_unit`)
			SET `a`.`is_obsolete` = `b`.`is_obsolete`
			WHERE `a`.`system_id_unit` = @system_id_unit_insert_extl2
			;

	END IF;

END;
$$
DELIMITER ;

# Create the trigger when the extL2P is updated
# This trigger will:
#	- Check if several conditions are met
#	- Capture the value we need in several variables
#	- Do the update.

	DROP TRIGGER IF EXISTS `ut_after_update_external_property_level_2`;

DELIMITER $$
CREATE TRIGGER `ut_after_update_external_property_level_2`
AFTER UPDATE ON `external_property_level_2_units`
FOR EACH ROW
BEGIN

# We only do this if 
#	- we need to create the property in Unee-T
#	- We have a `external_id`
#	- We have a `external_system_id`
#	- We have a `external_table`
#	- We have a `organization_id`
#	- We have a `tower`
#	- We have a MEFE user ID for the user who did the update
#	- The unit was already marked as needed to be created in Unee-T
#	- The unit already exists in the table `property_level_2_units`
#	- We have a valid building_id for that unit.
#	- The `do_not_insert_field` is NOT equal to 1
#	- This is a valid update method:
#		- `imported_from_hmlet_ipi`
#		- `Manage_Units_Add_Page`
#		- `Manage_Units_Edit_Page`
#		- 'Manage_Units_Import_Page'
#		- 'Export_and_Import_Units_Import_Page'

# Capture the variables we need to verify if conditions are met:

	SET @is_creation_needed_in_unee_t_update_extl2 = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator_update_extl2 = NEW.`created_by_id` ;

	SET @source_system_updated_by_id_update_extl2 = NEW.`updated_by_id` ;

	SET @source_system_updater_update_extl2 = (IF(@source_system_updated_by_id_update_extl2 IS NULL
			, @source_system_creator_update_extl2
			, @source_system_updated_by_id_update_extl2
			)
		);

	SET @creator_mefe_user_id_update_extl2 = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator_update_extl2
		)
		;

	SET @upstream_create_method_update_extl2 = NEW.`creation_method` ;
	SET @upstream_update_method_update_extl2 = NEW.`update_method` ;

	SET @organization_id_update_extl2 = @source_system_creator_update_extl2 ;

	SET @external_id_update_extl2 = NEW.`external_id` ;
	SET @external_system_id_update_extl2 = NEW.`external_system_id` ; 
	SET @external_table_update_extl2 = NEW.`external_table` ;
	SET @tower_update_extl2 = NEW.`tower` ;

	SET @new_is_creation_needed_in_unee_t_update_extl2 = NEW.`is_creation_needed_in_unee_t` ;
	SET @old_is_creation_needed_in_unee_t_update_extl2 = OLD.`is_creation_needed_in_unee_t` ;

	SET @id_in_property_level_2_units_update_extl2 = (SELECT `system_id_unit`
		FROM `property_level_2_units`
		WHERE `external_system_id` = @external_system_id_update_extl2
			AND `external_table` = @external_table_update_extl2
			AND `external_id` = @external_id_update_extl2
			AND `organization_id` = @organization_id_update_extl2
		);

	SET @upstream_do_not_insert_update_extl2 = NEW.`do_not_insert` ;

	# Get the information about the building for that unit...
	# We need the information from the table `external_property_level_2_units` (and NOT the table `external_external_property_level_1_buildings`)
	
		SET @building_id_1_update_extl2 = NEW.`building_system_id` ;

		SET @tower_update_extl2 = NEW.`tower` ;

		SET @building_external_id_update_extl2 = (SELECT `external_id`
			FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_1_update_extl2
				);
		SET @building_external_system_id_update_extl2 = (SELECT `external_system_id`
			FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_1_update_extl2
			);
		SET @building_external_table_update_extl2 = (SELECT `external_table`
		   FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_1_update_extl2
			);
		SET @building_external_tower_update_extl2 = (SELECT `tower`
			FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_1_update_extl2
			);

		SET @building_system_id_update_extl2 = (SELECT `id_building`
			FROM `property_level_1_buildings`
			WHERE `external_id` = @building_external_id_update_extl2
				AND `external_system_id` = @building_external_system_id_update_extl2
				AND `external_table` = @building_external_table_update_extl2
				AND `organization_id` = @organization_id_update_extl2
				AND `tower` = @building_external_tower_update_extl2
				);

		SET @activated_by_id_update_extl2 = NEW.`activated_by_id` ;
		SET @is_obsolete_update_extl2 = NEW.`is_obsolete` ;
		SET @is_creation_needed_in_unee_t_update_extl2 = NEW.`is_creation_needed_in_unee_t` ;
		SET @unee_t_unit_type_update_extl2 = NEW.`unee_t_unit_type` ;
			
		SET @unit_category_id_update_extl2 = NEW.`unit_category_id` ;
		SET @designation_update_extl2 = NEW.`designation` ;
		SET @count_rooms_update_extl2 = NEW.`count_rooms` ;
		SET @unit_id_update_extl2 = NEW.`unit_id` ;
		SET @surface_update_extl2 = NEW.`surface` ;
		SET @surface_measurment_unit_update_extl2 = NEW.`surface_measurment_unit` ;
		SET @description_update_extl2 = NEW.`description` ;

# We can now check if the conditions are met:

	IF @is_creation_needed_in_unee_t_update_extl2 = 1
		AND @upstream_do_not_insert_update_extl2 = 0
		AND @external_id_update_extl2 IS NOT NULL
		AND @external_system_id_update_extl2 IS NOT NULL
		AND @external_table_update_extl2 IS NOT NULL
		AND @tower_update_extl2 IS NOT NULL
		AND @organization_id_update_extl2 IS NOT NULL
		AND @building_system_id_update_extl2 IS NOT NULL
		AND (@upstream_update_method_update_extl2 = 'imported_from_hmlet_ipi'
			OR @upstream_update_method_update_extl2 = 'Manage_Units_Add_Page'
			OR @upstream_update_method_update_extl2 = 'Manage_Units_Edit_Page'
			OR @upstream_update_method_update_extl2 = 'Manage_Units_Import_Page'
			OR @upstream_update_method_update_extl2 = 'Export_and_Import_Units_Import_Page'
			)
	THEN 

	# The conditions are met: we capture the other variables we need

		SET @creation_system_id_update_extl2 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator_update_extl2
			)
			;
		SET @created_by_id_update_extl2 = @creator_mefe_user_id_update_extl2 ;

		SET @update_system_id_update_extl2 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater_update_extl2
			)
			;
		SET @updated_by_id_update_extl2 = @creator_mefe_user_id_update_extl2 ;

		SET @organization_id_create_update_extl2 = @source_system_creator_update_extl2 ;
		SET @organization_id_update_update_extl2 = @source_system_updater_update_extl2 ;

		SET @ext_l2_default_assignee_mgt_cny := NEW.`mgt_cny_default_assignee` ;
		SET @ext_l2_default_assignee_landlord := NEW.`landlord_default_assignee` ;
		SET @ext_l2_default_assignee_tenant := NEW.`tenant_default_assignee` ;
		SET @ext_l2_default_assignee_agent := NEW.`agent_default_assignee` ;

		IF @new_is_creation_needed_in_unee_t_update_extl2 != @old_is_creation_needed_in_unee_t_update_extl2
		THEN 

			# This is option 1 - creation IS needed

				SET @this_trigger_update_extl2_insert = 'ut_after_update_external_property_level_2_insert_creation_needed';
				SET @this_trigger_update_extl2_update = 'ut_after_update_external_property_level_2_update_creation_needed';

			# We update the record in the table `external_property_level_2_units`
			# We do this via INSERT INTO ... ON DUPLICATE KEY UPDATE for maximum safety

				INSERT INTO `property_level_2_units`
					(`external_id`
					, `external_system_id` 
					, `external_table`
					, `syst_created_datetime`
					, `creation_system_id`
					, `created_by_id`
					, `creation_method`
					, `organization_id`
					, `activated_by_id`
					, `is_obsolete`
					, `is_creation_needed_in_unee_t`
					, `do_not_insert`
					, `unee_t_unit_type`
					, `building_system_id`
					, `tower`
					, `unit_category_id`
					, `designation`
					, `count_rooms`
					, `unit_id`
					, `surface`
					, `surface_measurment_unit`
					, `description`
					, `mgt_cny_default_assignee`
					, `landlord_default_assignee`
					, `tenant_default_assignee`
					, `agent_default_assignee`
					)
					VALUES
						(@external_id_update_extl2
						, @external_system_id_update_extl2
						, @external_table_update_extl2
						, NOW()
						, @creation_system_id_update_extl2
						, @created_by_id_update_extl2
						, @this_trigger_update_extl2_insert
						, @organization_id_create_update_extl2
						, @activated_by_id_update_extl2
						, @is_obsolete_update_extl2
						, @is_creation_needed_in_unee_t_update_extl2
						, @do_not_insert_update_extl2
						, @unee_t_unit_type_update_extl2
						, @building_system_id_update_extl2
						, @tower_update_extl2
						, @unit_category_id_update_extl2
						, @designation_update_extl2
						, @count_rooms_update_extl2
						, @unit_id_update_extl2
						, @surface_update_extl2
						, @surface_measurment_unit_update_extl2
						, @description_update_extl2
						, @ext_l2_default_assignee_mgt_cny
						, @ext_l2_default_assignee_landlord
						, @ext_l2_default_assignee_tenant
						, @ext_l2_default_assignee_agent
					)
					ON DUPLICATE KEY UPDATE
						`syst_updated_datetime` = NOW()
						, `update_system_id` = @update_system_id_update_extl2
						, `updated_by_id` = @updated_by_id_update_extl2
						, `update_method` = @this_trigger_update_extl2_update
						, `organization_id` = @organization_id_update_update_extl2
						, `activated_by_id` = @activated_by_id_update_extl2
						, `is_obsolete` = @is_obsolete_update_extl2
						, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t_update_extl2
						, `do_not_insert` = @do_not_insert_update_extl2
						, `unee_t_unit_type` = @unee_t_unit_type_update_extl2
						, `building_system_id` = @building_system_id_update_extl2
						, `tower` = @tower_update_extl2
						, `unit_category_id` = @unit_category_id_update_extl2
						, `designation` = @designation_update_extl2
						, `count_rooms` = @count_rooms_update_extl2
						, `unit_id` = @unit_id_update_extl2
						, `surface` = @surface_update_extl2
						, `surface_measurment_unit` = @surface_measurment_unit_update_extl2
						, `description` = @description_update_extl2
						, `mgt_cny_default_assignee` = @ext_l2_default_assignee_mgt_cny
						, `landlord_default_assignee` = @ext_l2_default_assignee_landlord
						, `tenant_default_assignee` = @ext_l2_default_assignee_tenant
						, `agent_default_assignee` = @ext_l2_default_assignee_agent
					;
							
					# Housekeeping - we make sure that if a unit is obsolete - all rooms in that unit are obsolete too
					# We only do that if the field `is_obsolete` is changed from 0 to 1

						SET @system_id_unit_update_extl2 = NEW.`system_id_unit` ;

						UPDATE `external_property_level_3_rooms` AS `a`
							INNER JOIN `external_property_level_2_units` AS `b`
								ON (`a`.`system_id_unit` = `b`.`system_id_unit`)
							SET `a`.`is_obsolete` = `b`.`is_obsolete`
							WHERE `a`.`system_id_unit` = @system_id_unit_update_extl2
							;

		ELSEIF @new_is_creation_needed_in_unee_t_update_extl2 = @old_is_creation_needed_in_unee_t_update_extl2
		THEN 
			
			# This is option 2 - creation is NOT needed

				SET @this_trigger_update_extl2_insert = 'ut_after_update_external_property_level_2_insert_update_needed' ;
				SET @this_trigger_update_extl2_update = 'ut_after_update_external_property_level_2_update_update_needed' ;

			# We update the record in the table `external_property_level_2_units`
			# We do this via INSERT INTO ... ON DUPLICATE KEY UPDATE for maximum safety

				INSERT INTO `property_level_2_units`
					(`external_id`
					, `external_system_id` 
					, `external_table`
					, `syst_created_datetime`
					, `creation_system_id`
					, `created_by_id`
					, `creation_method`
					, `organization_id`
					, `activated_by_id`
					, `is_obsolete`
					, `is_creation_needed_in_unee_t`
					, `do_not_insert`
					, `unee_t_unit_type`
					, `building_system_id`
					, `tower`
					, `unit_category_id`
					, `designation`
					, `count_rooms`
					, `unit_id`
					, `surface`
					, `surface_measurment_unit`
					, `description`
					, `mgt_cny_default_assignee`
					, `landlord_default_assignee`
					, `tenant_default_assignee`
					, `agent_default_assignee`
					)
					VALUES
						(@external_id_update_extl2
						, @external_system_id_update_extl2
						, @external_table_update_extl2
						, NOW()
						, @creation_system_id_update_extl2
						, @created_by_id_update_extl2
						, @this_trigger_update_extl2_insert
						, @organization_id_create_update_extl2
						, @activated_by_id_update_extl2
						, @is_obsolete_update_extl2
						, @is_creation_needed_in_unee_t_update_extl2
						, @do_not_insert_update_extl2
						, @unee_t_unit_type_update_extl2
						, @building_system_id_update_extl2
						, @tower_update_extl2
						, @unit_category_id_update_extl2
						, @designation_update_extl2
						, @count_rooms_update_extl2
						, @unit_id_update_extl2
						, @surface_update_extl2
						, @surface_measurment_unit_update_extl2
						, @description_update_extl2
						, @ext_l2_default_assignee_mgt_cny
						, @ext_l2_default_assignee_landlord
						, @ext_l2_default_assignee_tenant
						, @ext_l2_default_assignee_agent
					)
					ON DUPLICATE KEY UPDATE
						`syst_updated_datetime` = NOW()
						, `update_system_id` = @update_system_id_update_extl2
						, `updated_by_id` = @updated_by_id_update_extl2
						, `update_method` = @this_trigger_update_extl2_update
						, `organization_id` = @organization_id_update_update_extl2
						, `activated_by_id` = @activated_by_id_update_extl2
						, `is_obsolete` = @is_obsolete_update_extl2
						, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t_update_extl2
						, `do_not_insert` = @do_not_insert_update_extl2
						, `unee_t_unit_type` = @unee_t_unit_type_update_extl2
						, `building_system_id` = @building_system_id_update_extl2
						, `tower` = @tower_update_extl2
						, `unit_category_id` = @unit_category_id_update_extl2
						, `designation` = @designation_update_extl2
						, `count_rooms` = @count_rooms_update_extl2
						, `unit_id` = @unit_id_update_extl2
						, `surface` = @surface_update_extl2
						, `surface_measurment_unit` = @surface_measurment_unit_update_extl2
						, `description` = @description_update_extl2
						, `mgt_cny_default_assignee` = @ext_l2_default_assignee_mgt_cny
						, `landlord_default_assignee` = @ext_l2_default_assignee_landlord
						, `tenant_default_assignee` = @ext_l2_default_assignee_tenant
						, `agent_default_assignee` = @ext_l2_default_assignee_agent
					;
						
					# Housekeeping - we make sure that if a unit is obsolete - all rooms in that unit are obsolete too
					# We only do that if the field `is_obsolete` is changed from 0 to 1

						SET @system_id_unit_update_extl2 = NEW.`system_id_unit` ;

						UPDATE `external_property_level_3_rooms` AS `a`
							INNER JOIN `external_property_level_2_units` AS `b`
								ON (`a`.`system_id_unit` = `b`.`system_id_unit`)
							SET `a`.`is_obsolete` = `b`.`is_obsolete`
							WHERE `a`.`system_id_unit` = @system_id_unit_update_extl2
							;

		END IF;

	# The conditions are NOT met <-- we do nothing

	END IF;

END;
$$
DELIMITER ;

# Create a trigger to update the table that will fire the lambda each time a new Flat/Unit needs to be created

	DROP TRIGGER IF EXISTS `ut_after_insert_in_property_level_2`;

DELIMITER $$
CREATE TRIGGER `ut_after_insert_in_property_level_2`
AFTER INSERT ON `property_level_2_units`
FOR EACH ROW
BEGIN

# We do this ONLY IF 
#	- We have marked the property as an object we need to create in Unee-T
#	- The record does NOT exist in the table `ut_map_external_source_units` yet
#	- This is done via an authorized insert method:
#		- 'ut_after_insert_in_external_property_level_2_insert'
#		- 'ut_after_insert_in_external_property_level_2_update'
#		- 'ut_after_update_external_property_level_2_insert_creation_needed'
#		- 'ut_after_update_external_property_level_2_update_creation_needed'
#		- 'ut_after_update_external_property_level_2_insert_update_needed'
#		- 'ut_after_update_external_property_level_2_update_update_needed'
#		- ''
#
	SET @is_creation_needed_in_unee_t_insert_l2 = NEW.`is_creation_needed_in_unee_t` ;

	SET @external_property_id_insert_l2 = NEW.`external_id` ;
	SET @external_system_insert_l2 = NEW.`external_system_id` ;
	SET @table_in_external_system_insert_l2 = NEW.`external_table` ;
	SET @organization_id_insert_l2 = NEW.`organization_id`;
	SET @tower_insert_l2 = NEW.`tower`;

	SET @external_property_type_id_insert_l2 = 2 ;	

	SET @id_in_ut_map_external_source_units_insert_l2 = (SELECT `id_map`
		FROM `ut_map_external_source_units`
		WHERE `external_system` = @external_system_insert_l2
			AND `table_in_external_system` = @table_in_external_system_insert_l2
			AND `external_property_id` = @external_property_id_insert_l2
			AND `organization_id` = @organization_id_insert_l2
			AND `external_property_type_id` = @external_property_type_id_insert_l2
			AND `tower` = @tower_insert_l2
		);

	SET @do_not_insert_insert_l2_raw = NEW.`do_not_insert` ;

	# This is an insert - if the record does NOT exist, we create the record
	# unless 
	#	- it is specifically specified that we do NOT need to create the record.
	#	- the record is marked as obsolete

		SET @is_obsolete_insert_l2 = NEW.`is_obsolete`;

		SET @do_not_insert_insert_l2 = (IF (@id_in_ut_map_external_source_units_insert_l2 IS NULL
				, IF (@is_obsolete_insert_l2 != 0
					, 1
					, 0
					)
				, IF (@is_obsolete_insert_l2 != 0
					, 1
					, @do_not_insert_insert_l2_raw
					)
				)
			);

	SET @upstream_create_method_insert_l2 = NEW.`creation_method` ;
	SET @upstream_update_method_insert_l2 = NEW.`update_method` ;

	IF @is_creation_needed_in_unee_t_insert_l2 = 1
		AND @do_not_insert_insert_l2 = 0
		AND (@upstream_create_method_insert_l2 = 'ut_after_insert_in_external_property_level_2_insert'
			OR @upstream_update_method_insert_l2 = 'ut_after_insert_in_external_property_level_2_update'
			OR @upstream_create_method_insert_l2 = 'ut_after_update_external_property_level_2_insert_creation_needed'
			OR @upstream_update_method_insert_l2 = 'ut_after_update_external_property_level_2_update_creation_needed'			
			OR @upstream_create_method_insert_l2 = 'ut_after_update_external_property_level_2_insert_update_needed'
			OR @upstream_update_method_insert_l2 = 'ut_after_update_external_property_level_2_update_update_needed'
			)
	THEN 

		# We capture the values we need for the insert/udpate:

			SET @this_trigger_insert_l2_insert = 'ut_after_insert_in_property_level_2_insert' ;
			SET @this_trigger_insert_l2_update = 'ut_after_insert_in_property_level_2_update' ;

			SET @creation_system_id_insert_l2 = NEW.`creation_system_id`;
			SET @created_by_id_insert_l2 = NEW.`created_by_id`;

			SET @update_system_id_insert_l2 = NEW.`creation_system_id`;
			SET @updated_by_id_insert_l2 = NEW.`created_by_id`;
	
			SET @is_update_needed_insert_l2 = NULL;
			
			SET @uneet_name_insert_l2 = NEW.`designation`;

			SET @unee_t_unit_type_insert_l2_raw = NEW.`unee_t_unit_type` ;

			SET @unee_t_unit_type_insert_l2 = (IFNULL(@unee_t_unit_type_insert_l2_raw
					, 'Unknown'
					)
				)
				;
			
			SET @new_record_id_insert_l2 = NEW.`system_id_unit`;
						
			SET @l2_default_assignee_mgt_cny := NEW.`mgt_cny_default_assignee` ;
			SET @l2_default_assignee_landlord := NEW.`landlord_default_assignee` ;
			SET @l2_default_assignee_tenant := NEW.`tenant_default_assignee` ;
			SET @l2_default_assignee_agent := NEW.`agent_default_assignee` ;

		# We insert/Update a new record in the table `ut_map_external_source_units`

			INSERT INTO `ut_map_external_source_units`
				( `syst_created_datetime`
				, `creation_system_id`
				, `created_by_id`
				, `creation_method`
				, `organization_id`
				, `is_obsolete`
				, `is_update_needed`
				, `uneet_name`
				, `unee_t_unit_type`
				, `new_record_id`
				, `external_property_type_id`
				, `external_property_id`
				, `external_system`
				, `table_in_external_system`
				, `mgt_cny_default_assignee`
				, `landlord_default_assignee`
				, `tenant_default_assignee`
				, `agent_default_assignee`
				)
				VALUES
					(NOW()
					, @creation_system_id_insert_l2
					, @created_by_id_insert_l2
					, @this_trigger_insert_l2_insert
					, @organization_id_insert_l2
					, @is_obsolete_insert_l2
					, @is_update_needed_insert_l2
					, @uneet_name_insert_l2
					, @unee_t_unit_type_insert_l2
					, @new_record_id_insert_l2
					, @external_property_type_id_insert_l2
					, @external_property_id_insert_l2
					, @external_system_insert_l2
					, @table_in_external_system_insert_l2
					, @l2_default_assignee_mgt_cny
					, @l2_default_assignee_landlord
					, @l2_default_assignee_tenant
					, @l2_default_assignee_agent
					)
				ON DUPLICATE KEY UPDATE 
					`syst_updated_datetime` = NOW()
					, `update_system_id` = @update_system_id_insert_l2
					, `updated_by_id` = @updated_by_id_insert_l2
					, `update_method` = @this_trigger_insert_l2_update
					, `organization_id` = @organization_id_insert_l2
					, `uneet_name` = @uneet_name_insert_l2
					, `unee_t_unit_type` = @unee_t_unit_type_insert_l2
					, `is_update_needed` = 1
					, `mgt_cny_default_assignee` = @l2_default_assignee_mgt_cny
					, `landlord_default_assignee` = @l2_default_assignee_landlord
					, `tenant_default_assignee` = @l2_default_assignee_tenant
					, `agent_default_assignee` = @l2_default_assignee_agent
				;

	END IF;
END;
$$
DELIMITER ;

# Create the trigger when the L2P is updated
# This trigger will:
#	- Check if several conditions are met
#	- Capture the value we need in several variables
#	- Do the Insert/update if needed

	DROP TRIGGER IF EXISTS `ut_after_update_property_level_2`;

DELIMITER $$
CREATE TRIGGER `ut_after_update_property_level_2`
AFTER UPDATE ON `property_level_2_units`
FOR EACH ROW
BEGIN

# We only do this IF:
# 	- We need to create the unit in Unee-T
#	- The unit is NOT marked as `do_not_insert`
#	- We do NOT have a MEFE unit ID for that unit
#	- This is done via an authorized update method:
#		- 'ut_after_insert_in_external_property_level_2_insert'
#		- 'ut_after_insert_in_external_property_level_2_update'
#		- 'ut_after_update_external_property_level_2_insert_update_needed'
#		- 'ut_after_update_external_property_level_2_update_update_needed'
#		- 'ut_after_update_external_property_level_2_insert_creation_needed'
#		- 'ut_after_update_external_property_level_2_update_creation_needed'

# Capture the variables we need to verify if conditions are met:

	SET @upstream_create_method_update_l2 = NEW.`creation_method` ;
	SET @upstream_update_method_update_l2 = NEW.`update_method` ;
			
	SET @new_record_id_update_l2 = NEW.`system_id_unit`;

	SET @check_new_record_id_update_l2 = (IF(@new_record_id_update_l2 IS NULL
			, 0
			, IF(@new_record_id_update_l2 = ''
				, 0
				, 1
				)
			)
		)
		;

# We can now check if the conditions are met:

	IF (@upstream_create_method_update_l2 = 'ut_after_insert_in_external_property_level_2_insert'
			OR @upstream_update_method_update_l2 = 'ut_after_insert_in_external_property_level_2_update'
			OR @upstream_create_method_update_l2 = 'ut_after_update_external_property_level_2_insert_creation_needed'
			OR @upstream_update_method_update_l2 = 'ut_after_update_external_property_level_2_update_creation_needed'
			OR @upstream_create_method_update_l2 = 'ut_after_update_external_property_level_2_insert_update_needed'
			OR @upstream_update_method_update_l2 = 'ut_after_update_external_property_level_2_update_update_needed'
			)
		AND @check_new_record_id_update_l2 = 1
	THEN 

	# Clean Slate - Make sure we don't use a legacy MEFE id

		SET @mefe_unit_id_update_l2 = NULL ;

	# The conditions are met: we capture the other variables we need

		SET @is_creation_needed_in_unee_t_update_l2 = NEW.`is_creation_needed_in_unee_t`;

		SET @new_is_creation_needed_in_unee_t_update_l2 = NEW.`is_creation_needed_in_unee_t`;
		SET @old_is_creation_needed_in_unee_t_update_l2 = OLD.`is_creation_needed_in_unee_t`;

		SET @creation_system_id_update_l2 = NEW.`update_system_id`;
		SET @created_by_id_update_l2 = NEW.`updated_by_id`;

		SET @update_system_id_update_l2 = NEW.`update_system_id`;
		SET @updated_by_id_update_l2 = NEW.`updated_by_id`;

		SET @organization_id_update_l2 = NEW.`organization_id`;
		
		SET @is_update_needed_update_l2 = NULL;
		
		SET @uneet_name_update_l2 = NEW.`designation`;

		SET @unee_t_unit_type_update_l2_raw = NEW.`unee_t_unit_type` ;

		SET @unee_t_unit_type_update_l2 = (IFNULL(@unee_t_unit_type_update_l2_raw
				, 'Unknown'
				)
			)
			;

		SET @external_property_id_update_l2 = NEW.`external_id`;
		SET @external_system_update_l2 = NEW.`external_system_id`;
		SET @table_in_external_system_update_l2 = NEW.`external_table`;			

		SET @external_property_type_id_update_l2 = 2;

		SET @mefe_unit_id_update_l2 = (SELECT `unee_t_mefe_unit_id`
			FROM `ut_map_external_source_units`
			WHERE `new_record_id` = @new_record_id_update_l2
				AND `external_property_type_id` = @external_property_type_id_update_l2
				AND `unee_t_mefe_unit_id` IS NOT NULL
			);

		SET @l2_default_assignee_mgt_cny := NEW.`mgt_cny_default_assignee` ;
		SET @l2_default_assignee_landlord := NEW.`landlord_default_assignee` ;
		SET @l2_default_assignee_tenant := NEW.`tenant_default_assignee` ;
		SET @l2_default_assignee_agent := NEW.`agent_default_assignee` ;

		# If the record does NOT exist, we create the record
		# unless 
		#	- it is specifically specified that we do NOT need to create the record.
		#	- the record is marked as obsolete

			SET @do_not_insert_update_l2_raw = NEW.`do_not_insert` ;

			SET @is_obsolete_update_l2 = NEW.`is_obsolete`;

			SET @do_not_insert_update_l2 = (IF (@do_not_insert_update_l2_raw IS NULL
					, IF (@is_obsolete_update_l2 != 0
						, 1
						, 0
						)
					, IF (@is_obsolete_update_l2 != 0
						, 1
						, @do_not_insert_update_l2_raw
						)
					)
				);

		IF @is_creation_needed_in_unee_t_update_l2 = 1
			AND (@mefe_unit_id_update_l2 IS NULL
				OR  @mefe_unit_id_update_l2 = ''
				)
			AND @do_not_insert_update_l2 = 0
		THEN 

			# This is option 1 - creation IS needed

				SET @this_trigger_update_l2_insert = 'ut_after_update_property_level_2_insert_unit_creation_needed';
				SET @this_trigger_update_l2_update = 'ut_after_update_property_level_2_update_unit_creation_needed';

		# We insert/Update a new record in the table `ut_map_external_source_units`

				INSERT INTO `ut_map_external_source_units`
					( `syst_created_datetime`
					, `creation_system_id`
					, `created_by_id`
					, `creation_method`
					, `organization_id`
					, `datetime_latest_trigger`
					, `latest_trigger`
					, `is_obsolete`
					, `is_update_needed`
					, `is_mefe_api_success`
					, `mefe_api_error_message`
					, `uneet_name`
					, `unee_t_unit_type`
					, `new_record_id`
					, `external_property_type_id`
					, `external_property_id`
					, `external_system`
					, `table_in_external_system`
					, `mgt_cny_default_assignee`
					, `landlord_default_assignee`
					, `tenant_default_assignee`
					, `agent_default_assignee`
					)
					VALUES
						(NOW()
						, @creation_system_id_update_l2
						, @created_by_id_update_l2
						, @this_trigger_update_l2_insert
						, @organization_id_update_l2
						, NOW()
						, @this_trigger_update_l2_insert
						, @is_obsolete_update_l2
						, @is_update_needed_update_l2
						, @is_mefe_api_success_update_l2
						, @mefe_api_error_message_update_l2
						, @uneet_name_update_l2
						, @unee_t_unit_type_update_l2
						, @new_record_id_update_l2
						, @external_property_type_id_update_l2
						, @external_property_id_update_l2
						, @external_system_update_l2
						, @table_in_external_system_update_l2
						, @l2_default_assignee_mgt_cny
						, @l2_default_assignee_landlord
						, @l2_default_assignee_tenant
						, @l2_default_assignee_agent
						)
					ON DUPLICATE KEY UPDATE
						`syst_updated_datetime` = NOW()
						, `update_system_id` = @update_system_id_update_l2
						, `updated_by_id` = @updated_by_id_update_l2
						, `update_method` = @this_trigger_update_l2_update
						, `organization_id` = @organization_id_update_l2
						, `datetime_latest_trigger` = NOW()
						, `latest_trigger` = @this_trigger_update_l2_update
						, `is_mefe_api_success` = @is_mefe_api_success_update_l2
						, `mefe_api_error_message` = @mefe_api_error_message_update_l2
						, `uneet_name` = @uneet_name_update_l2
						, `unee_t_unit_type` = @unee_t_unit_type_update_l2
						, `is_update_needed` = 1
						, `mgt_cny_default_assignee` = @l2_default_assignee_mgt_cny
						, `landlord_default_assignee` = @l2_default_assignee_landlord
						, `tenant_default_assignee` = @l2_default_assignee_tenant
						, `agent_default_assignee` = @l2_default_assignee_agent
					;
###################################################################
#
# THIS IS CREATING SUBQUERY RETURN MORE THAN 1 ROW ERRORS
#
###################################################################
		ELSEIF @mefe_unit_id_update_l2 IS NOT NULL
			OR @mefe_unit_id_update_l2 != ''
		THEN 
			
			# This is option 2 - creation is NOT needed

				SET @this_trigger_update_l2_insert = 'ut_after_update_property_level_2_insert_unit_update_needed';
				SET @this_trigger_update_l2_update = 'ut_after_update_property_level_2_update_unit_update_needed';

			# We Update the existing new record in the table `ut_map_external_source_units`

				UPDATE `ut_map_external_source_units`
					SET 
						`syst_updated_datetime` = NOW()
						, `update_system_id` = @update_system_id_update_l2
						, `updated_by_id` = @updated_by_id_update_l2
						, `update_method` = @this_trigger_update_l2_update
						, `organization_id` = @organization_id_update_l2
						, `datetime_latest_trigger` = NOW()
						, `latest_trigger` = @this_trigger_update_l2_update
						, `is_mefe_api_success` = @is_mefe_api_success_update_l2
						, `mefe_api_error_message` = @mefe_api_error_message_update_l2
						, `uneet_name` = @uneet_name_update_l2
						, `unee_t_unit_type` = @unee_t_unit_type_update_l2
						, `is_update_needed` = 1
						, `mgt_cny_default_assignee` = @l2_default_assignee_mgt_cny
						, `landlord_default_assignee` = @l2_default_assignee_landlord
						, `tenant_default_assignee` = @l2_default_assignee_tenant
						, `agent_default_assignee` = @l2_default_assignee_agent
					WHERE `unee_t_mefe_unit_id` = @mefe_unit_id_update_l2
					;

###################################################################
#
# END THIS IS CREATING SUBQUERY RETURN MORE THAN 1 ROW ERRORS
#
###################################################################
		END IF;

	END IF;

	# The conditions are NOT met <-- we do nothing
				
END;
$$
DELIMITER ;

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
#OK		- Make sure that we propagate the Default assignees
#OK		- Add a check to make sure we can get the MEFE unit ID if we need to update
#WIP			- IF we do NOT have a default assignee, 
#				  THEN we use the default assignee for the L2P

#################
#
# This lists all the triggers we use to create 
# a property_level_3
# via the Unee-T Enterprise Interface
#
#################
#
# This script creates or updates the following 
# 	- Procedures: 
#		- `ut_update_L3P_when_ext_L3P_is_updated`
#		- `ut_update_uneet_when_L3P_is_updated`
#	- triggers:
#		- `ut_after_insert_external_property_level_3`
#		- `ut_after_update_external_property_level_3`
#		- `ut_after_update_property_level_3`

# We create a trigger when a record is added to the `external_property_level_3_rooms` table

	DROP TRIGGER IF EXISTS `ut_after_insert_external_property_level_3`;

DELIMITER $$
CREATE TRIGGER `ut_after_insert_external_property_level_3`
AFTER INSERT ON `external_property_level_3_rooms`
FOR EACH ROW
BEGIN

# We only do this if 
#	- We need to create the unit in Unee-T
#	- We have a `external_id`
#	- We have a `external_system_id`
#	- We have a `external_table`
#	- We have a `organization_id`
#	- We have a MEFE user ID for the user who did the update
#	- The room does NOT exists in the table `property_level_3_rooms`
#   - we have a valid unit ID for this room.
#	- This is a valid insert method:
#		- 'imported_from_hmlet_ipi'
#		- 'Manage_Rooms_Add_Page'
#		- 'Manage_Rooms_Edit_Page'
#		- 'Manage_Rooms_Import_Page'
#		- 'Export_and_Import_Rooms_Import_Page'
#		- ''

	SET @is_creation_needed_in_unee_t_insert_extl3_1 = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator_insert_extl3_1 = NEW.`created_by_id` ;

	SET @source_updated_by_id_insert_extl3_1 = NEW.`updated_by_id` ;

	SET @source_system_updater_insert_extl3_1 = (IF(@source_updated_by_id_insert_extl3_ IS NULL
			, @source_system_creator_insert_extl3_1
			, @source_updated_by_id_insert_extl3_
			)
		);

	SET @creator_mefe_user_id_insert_extl3_1 = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator_insert_extl3_1
		)
		;

	SET @upstream_create_method_insert_extl3_1 = NEW.`creation_method` ;
	SET @upstream_update_method_insert_extl3_1 = NEW.`update_method` ;

	SET @organization_id_insert_extl3_1 = @source_system_creator_insert_extl3_1 ;

	SET @external_id_insert_extl3_1 = NEW.`external_id` ;
	SET @external_system_id_insert_extl3_1 = NEW.`external_system_id` ;
	SET @external_table_insert_extl3_1 = NEW.`external_table` ;

	SET @id_in_property_level_3_rooms_insert_extl3_1 = (SELECT `system_id_room`
		FROM `property_level_3_rooms`
		WHERE `external_system_id` = @external_system_id_insert_extl3_1
			AND `external_table` = @external_table_insert_extl3_1
			AND `external_id` = @external_id_insert_extl3_1
			AND `organization_id` = @organization_id_insert_extl3_1
		);
		
	SET @upstream_do_not_insert_insert_extl3_1 = NEW.`do_not_insert` ;

	# This is an INSERT - the record should NOT exist already

		SET @do_not_insert_insert_extl3_1 = (IF (@id_in_property_level_3_rooms_insert_extl3_1 IS NULL
				, 0
				, @upstream_do_not_insert_insert_extl3_1
				)
			
			);

	# Get the information about the unit for that room...
	# We need the information from the table `external_property_level_2_units` (and NOT the table `external_property_level_2_units`)
	
		SET @unit_id_1_insert_extl3_1 = NEW.`system_id_unit` ;

		SET @unit_external_id_insert_extl3_1 = (SELECT `external_id`
			FROM `external_property_level_2_units`
			WHERE `system_id_unit` = @unit_id_1_insert_extl3_1
				);
		SET @unit_external_system_id_insert_extl3_1 = (SELECT `external_system_id`
			FROM `external_property_level_2_units`
			WHERE `system_id_unit` = @unit_id_1_insert_extl3_1
			);
		SET @unit_external_table_insert_extl3_1 = (SELECT `external_table`
		   FROM `external_property_level_2_units`
			WHERE `system_id_unit` = @unit_id_1_insert_extl3_1
			);

		SET @system_id_unit_insert_extl3_1 = (SELECT `system_id_unit`
			FROM `property_level_2_units`
			WHERE `external_id` = @unit_external_id_insert_extl3_1
				AND `external_system_id` = @unit_external_system_id_insert_extl3_1
				AND `external_table` = @unit_external_table_insert_extl3_1
				AND `organization_id` = @organization_id_insert_extl3_1
				);

	IF @is_creation_needed_in_unee_t_insert_extl3_1 = 1
		AND @do_not_insert_insert_extl3_1 = 0
		AND @external_id_insert_extl3_1 IS NOT NULL
		AND @external_system_id_insert_extl3_1 IS NOT NULL
		AND @external_table_insert_extl3_1 IS NOT NULL
		AND @organization_id_insert_extl3_1 IS NOT NULL
		AND @system_id_unit_insert_extl3_1 IS NOT NULL
		AND (@upstream_create_method_insert_extl3_1 = 'imported_from_hmlet_ipi'
			OR @upstream_update_method_insert_extl3_1 = 'imported_from_hmlet_ipi'
			OR @upstream_create_method_insert_extl3_1 = 'Manage_Rooms_Add_Page'
			OR @upstream_update_method_insert_extl3_1 = 'Manage_Rooms_Add_Page'
			OR @upstream_create_method_insert_extl3_1 = 'Manage_Rooms_Edit_Page'
			OR @upstream_update_method_insert_extl3_1 = 'Manage_Rooms_Edit_Page'
			OR @upstream_create_method_insert_extl3_1 = 'Manage_Rooms_Import_Page'
			OR @upstream_update_method_insert_extl3_1 = 'Manage_Rooms_Import_Page'
			OR @upstream_create_method_insert_extl3_1 = 'Export_and_Import_Rooms_Import_Page'
			OR @upstream_update_method_insert_extl3_1 = 'Export_and_Import_Rooms_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `external_property_level_2_units` table:

		SET @this_trigger_insert_extl3_1_insert = 'ut_after_insert_external_property_level_3_insert' ;
		SET @this_trigger_insert_extl3_1_update = 'ut_after_insert_external_property_level_3_update' ;

		SET @creation_system_id_insert_extl3_1 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator_insert_extl3_1
			)
			;
		SET @created_by_id_insert_extl3_1 = @creator_mefe_user_id_insert_extl3_1 ;

		SET @update_system_id_insert_extl3_1 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater_insert_extl3_1
			)
			;
		SET @updated_by_id_insert_extl3_1 = @creator_mefe_user_id_insert_extl3_1 ;

		SET @organization_id_create_insert_extl3_1 = @source_system_creator_insert_extl3_1 ;
		SET @organization_id_update_insert_extl3_1 = @source_system_updater_insert_extl3_1 ;
		
		SET @is_obsolete_insert_extl3_1 = NEW.`is_obsolete` ;

		SET @unee_t_unit_type_insert_extl3_1 = NEW.`unee_t_unit_type` ;
		SET @room_designation_insert_extl3_1 = NEW.`room_designation`;
			
		SET @room_type_id_insert_extl3_1 = NEW.`room_type_id` ;
		SET @number_of_beds_insert_extl3_1 = NEW.`number_of_beds` ;
		SET @surface_insert_extl3_1 = NEW.`surface` ;
		SET @surface_measurment_unit_insert_extl3_1 = NEW.`surface_measurment_unit` ;

		SET @room_description_insert_extl3_1 = NEW.`room_description` ;

		SET @ext_l3_default_assignee_mgt_cny := NEW.`mgt_cny_default_assignee` ;
		SET @ext_l3_default_assignee_landlord := NEW.`landlord_default_assignee` ;
		SET @ext_l3_default_assignee_tenant := NEW.`tenant_default_assignee` ;
		SET @ext_l3_default_assignee_agent := NEW.`agent_default_assignee` ;

	# We insert the record in the table `property_level_3_rooms`
	# We do this via INSERT INTO ... ON DUPLICATE KEY UPDATE for maximum safety

		INSERT INTO `property_level_3_rooms`
			(`external_id`
			, `external_system_id` 
			, `external_table`
			, `syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `creation_method`
			, `organization_id`
			, `is_obsolete`
			, `is_creation_needed_in_unee_t`
			, `do_not_insert`
			, `unee_t_unit_type`
			, `system_id_unit`
			, `room_type_id`
			, `surface`
			, `surface_measurment_unit`
			, `room_designation`
			, `room_description`
			, `mgt_cny_default_assignee`
			, `landlord_default_assignee`
			, `tenant_default_assignee`
			, `agent_default_assignee`
			)
			VALUES
 				(@external_id_insert_extl3_1
				, @external_system_id_insert_extl3_1
				, @external_table_insert_extl3_1
				, NOW()
				, @creation_system_id_insert_extl3_1
				, @created_by_id_insert_extl3_1
				, @this_trigger_insert_extl3_1_insert
				, @organization_id_create_insert_extl3_1
				, @is_obsolete_insert_extl3_1
				, @is_creation_needed_in_unee_t_insert_extl3_1
				, @do_not_insert_insert_extl3_1
				, @unee_t_unit_type_insert_extl3_1
				, @system_id_unit_insert_extl3_1
				, @room_type_id_insert_extl3_1
				, @surface_insert_extl3_1
				, @surface_measurment_unit_insert_extl3_1
				, @room_designation_insert_extl3_1
				, @room_description_insert_extl3_1
				, @ext_l3_default_assignee_mgt_cny
				, @ext_l3_default_assignee_landlord
				, @ext_l3_default_assignee_tenant
				, @ext_l3_default_assignee_agent
 			)
			ON DUPLICATE KEY UPDATE
 				`syst_updated_datetime` = NOW()
 				, `update_system_id` = @update_system_id_insert_extl3_1
 				, `updated_by_id` = @updated_by_id_insert_extl3_1
				, `update_method` = @this_trigger_insert_extl3_1_update
				, `organization_id` = @organization_id_update_insert_extl3_1
				, `is_obsolete` = @is_obsolete_insert_extl3_1
				, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t_insert_extl3_1
				, `do_not_insert` = @do_not_insert_insert_extl3_1
				, `unee_t_unit_type` = @unee_t_unit_type_insert_extl3_1
				, `system_id_unit` = @system_id_unit_insert_extl3_1
				, `room_type_id` = @room_type_id_insert_extl3_1
				, `surface` = @surface_insert_extl3_1
				, `surface_measurment_unit` = @surface_measurment_unit_insert_extl3_1
				, `room_designation` = @room_designation_insert_extl3_1
				, `room_description` = @room_description_insert_extl3_1
				, `mgt_cny_default_assignee` = @ext_l3_default_assignee_mgt_cny
				, `landlord_default_assignee` = @ext_l3_default_assignee_landlord
				, `tenant_default_assignee` = @ext_l3_default_assignee_tenant
				, `agent_default_assignee` = @ext_l3_default_assignee_agent
			;

	END IF;

END;
$$
DELIMITER ;

# We create a trigger when a record is updated in the `external_property_level_3_rooms` table
#	- The unit DOES exist in the table `external_property_level_3_rooms`
#	- This is a NOT a new creation request in Unee-T

	DROP TRIGGER IF EXISTS `ut_after_update_external_property_level_3`;

DELIMITER $$
CREATE TRIGGER `ut_after_update_external_property_level_3`
AFTER UPDATE ON `external_property_level_3_rooms`
FOR EACH ROW
BEGIN

# We only do this if 
#	- we need to create the property in Unee-T
#	- We have a `external_id`
#	- We have a `external_system_id`
#	- We have a `external_table`
#	- We have a `organization_id`
#	- We have a MEFE user ID for the user who did the update
#	- The unit already exists in the table `property_level_2_units`
#	- We have a valid building_id for that unit.
#	- The `do_not_insert_field` is NOT equal to 1
#	- This is a valid update method:
#		- `imported_from_hmlet_ipi`
#		- `Manage_Units_Add_Page`
#		- `Manage_Units_Edit_Page`
#		- 'Manage_Units_Import_Page'
#		- 'Export_and_Import_Rooms_Import_Page'

# Capture the variables we need to verify if conditions are met:

	SET @is_creation_needed_in_unee_t_update_extl3 = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator_update_extl3 = NEW.`created_by_id` ;

	SET @source_updated_by_id_update_extl3 = NEW.`updated_by_id` ;

	SET @source_system_updater_update_extl3 = (IF(@source_updated_by_id_update_extl3 IS NULL
			, @source_system_creator_update_extl3
			, @source_updated_by_id_update_extl3
			)
		);

	SET @creator_mefe_user_id_update_extl3 = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator_update_extl3
		)
		;

	SET @upstream_create_method_update_extl3 = NEW.`creation_method` ;
	SET @upstream_update_method_update_extl3 = NEW.`update_method` ;

	SET @organization_id_update_extl3 = @source_system_creator_update_extl3 ;

	SET @external_id_update_extl3 = NEW.`external_id` ;
	SET @external_system_id_update_extl3 = NEW.`external_system_id` ; 
	SET @external_table_update_extl3 = NEW.`external_table` ;

	SET @new_is_creation_needed_in_unee_t_update_extl3 = NEW.`is_creation_needed_in_unee_t` ;
	SET @old_is_creation_needed_in_unee_t_update_extl3 = OLD.`is_creation_needed_in_unee_t` ;

	SET @id_in_property_level_3_rooms_update_extl3 = (SELECT `system_id_room`
		FROM `property_level_3_rooms`
		WHERE `external_system_id` = @external_system_id_update_extl3
			AND `external_table` = @external_table_update_extl3
			AND `external_id` = @external_id_update_extl3
			AND `organization_id` = @organization_id_update_extl3
		);

	SET @upstream_do_not_insert_update_extl3 = NEW.`do_not_insert` ;

	# Get the information about the unit for that room...
	# We need the information from the table `external_property_level_2_units` (and NOT the table `external_property_level_2_units`)
	
		SET @unit_id_1_update_extl3 = NEW.`system_id_unit` ;

		SET @unit_external_id_update_extl3 = (SELECT `external_id`
			FROM `external_property_level_2_units`
			WHERE `system_id_unit` = @unit_id_1_update_extl3
				);
		SET @unit_external_system_id_update_extl3 = (SELECT `external_system_id`
			FROM `external_property_level_2_units`
			WHERE `system_id_unit` = @unit_id_1_update_extl3
			);
		SET @unit_external_table_update_extl3 = (SELECT `external_table`
		   FROM `external_property_level_2_units`
			WHERE `system_id_unit` = @unit_id_1_update_extl3
			);

		SET @system_id_unit_update_extl3 = (SELECT `system_id_unit`
			FROM `property_level_2_units`
			WHERE `external_id` = @unit_external_id_update_extl3
				AND `external_system_id` = @unit_external_system_id_update_extl3
				AND `external_table` = @unit_external_table_update_extl3
				AND `organization_id` = @organization_id_update_extl3
				);

# We can now check if the conditions are met:

	IF @is_creation_needed_in_unee_t_update_extl3 = 1
		AND @upstream_do_not_insert_update_extl3 = 0
		AND @external_id_update_extl3 IS NOT NULL
		AND @external_system_id_update_extl3 IS NOT NULL
		AND @external_table_update_extl3 IS NOT NULL
		AND @organization_id_update_extl3 IS NOT NULL
		AND @system_id_unit_update_extl3 IS NOT NULL
		AND (@upstream_create_method_update_extl3 = 'imported_from_hmlet_ipi'
			OR @upstream_update_method_update_extl3 = 'imported_from_hmlet_ipi'
			OR @upstream_create_method_update_extl3 = 'Manage_Rooms_Add_Page'
			OR @upstream_update_method_update_extl3 = 'Manage_Rooms_Add_Page'
			OR @upstream_create_method_update_extl3 = 'Manage_Rooms_Edit_Page'
			OR @upstream_update_method_update_extl3 = 'Manage_Rooms_Edit_Page'
			OR @upstream_create_method_update_extl3 = 'Manage_Rooms_Import_Page'
			OR @upstream_update_method_update_extl3 = 'Manage_Rooms_Import_Page'
			OR @upstream_create_method_update_extl3 = 'Export_and_Import_Rooms_Import_Page'
			OR @upstream_update_method_update_extl3 = 'Export_and_Import_Rooms_Import_Page'
			)
	THEN 

	# The conditions are met: we capture the other variables we need

		SET @creation_system_id_update_extl3 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator_update_extl3
			)
			;
		SET @created_by_id_update_extl3 = @creator_mefe_user_id_update_extl3 ;

		SET @update_system_id_update_extl3 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater_update_extl3
			)
			;
		SET @updated_by_id_update_extl3 = @creator_mefe_user_id_update_extl3 ;

		SET @organization_id_create_update_extl3 = @source_system_creator_update_extl3 ;
		SET @organization_id_update_update_extl3 = @source_system_updater_update_extl3 ;

		SET @is_obsolete_update_extl3 = NEW.`is_obsolete` ;

		SET @unee_t_unit_type_update_extl3 = NEW.`unee_t_unit_type` ;
		SET @room_designation_update_extl3 = NEW.`room_designation`;
			
		SET @room_type_id_update_extl3 = NEW.`room_type_id` ;
		SET @number_of_beds_update_extl3 = NEW.`number_of_beds` ;
		SET @surface_update_extl3 = NEW.`surface` ;
		SET @surface_measurment_unit_update_extl3 = NEW.`surface_measurment_unit` ;
		SET @room_description_update_extl3 = NEW.`room_description` ;

		SET @ext_l3_default_assignee_mgt_cny := NEW.`mgt_cny_default_assignee` ;
		SET @ext_l3_default_assignee_landlord := NEW.`landlord_default_assignee` ;
		SET @ext_l3_default_assignee_tenant := NEW.`tenant_default_assignee` ;
		SET @ext_l3_default_assignee_agent := NEW.`agent_default_assignee` ;

		IF @new_is_creation_needed_in_unee_t_update_extl3 != @old_is_creation_needed_in_unee_t_update_extl3
		THEN 

			# This is option 1 - creation IS needed

				SET @this_trigger_update_ext_l3_insert = 'ut_after_update_external_property_level_3_creation_needed_insert';
				SET @this_trigger_update_ext_l3_update = 'ut_after_update_external_property_level_3_creation_needed_update';

				# We insert the record in the table `property_level_3_rooms`
				# We do this via INSERT INTO ... ON DUPLICATE KEY UPDATE for maximum safety

					INSERT INTO `property_level_3_rooms`
						(`external_id`
						, `external_system_id` 
						, `external_table`
						, `syst_created_datetime`
						, `creation_system_id`
						, `created_by_id`
						, `creation_method`
						, `organization_id`
						, `is_obsolete`
						, `is_creation_needed_in_unee_t`
						, `do_not_insert`
						, `unee_t_unit_type`
						, `system_id_unit`
						, `room_type_id`
						, `surface`
						, `surface_measurment_unit`
						, `room_designation`
						, `room_description`
						, `mgt_cny_default_assignee`
						, `landlord_default_assignee`
						, `tenant_default_assignee`
						, `agent_default_assignee`
						)
						VALUES
							(@external_id_update_extl3
							, @external_system_id_update_extl3
							, @external_table_update_extl3
							, NOW()
							, @creation_system_id_update_extl3
							, @created_by_id_update_extl3
							, @this_trigger_update_ext_l3_insert
							, @organization_id_create_update_extl3
							, @is_obsolete_update_extl3
							, @is_creation_needed_in_unee_t_update_extl3
							, @do_not_insert_update_extl3
							, @unee_t_unit_type_update_extl3
							, @system_id_unit_update_extl3
							, @room_type_id_update_extl3
							, @surface_update_extl3
							, @surface_measurment_unit_update_extl3
							, @room_designation_update_extl3
							, @room_description_update_extl3
							, @ext_l3_default_assignee_mgt_cny
							, @ext_l3_default_assignee_landlord
							, @ext_l3_default_assignee_tenant
							, @ext_l3_default_assignee_agent
						)
						ON DUPLICATE KEY UPDATE
							`syst_updated_datetime` = NOW()
							, `update_system_id` = @update_system_id_update_extl3
							, `updated_by_id` = @updated_by_id_update_extl3
							, `update_method` = @this_trigger_update_ext_l3_update
							, `organization_id` = @organization_id_update_update_extl3
							, `is_obsolete` = @is_obsolete_update_extl3
							, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t_update_extl3
							, `do_not_insert` = @do_not_insert_update_extl3
							, `unee_t_unit_type` = @unee_t_unit_type_update_extl3
							, `system_id_unit` = @system_id_unit_update_extl3
							, `room_type_id` = @room_type_id_update_extl3
							, `surface` = @surface_update_extl3
							, `surface_measurment_unit` = @surface_measurment_unit_update_extl3
							, `room_designation` = @room_designation_update_extl3
							, `room_description` = @room_description_update_extl3
							, `mgt_cny_default_assignee` = @ext_l3_default_assignee_mgt_cny
							, `landlord_default_assignee` = @ext_l3_default_assignee_landlord
							, `tenant_default_assignee` = @ext_l3_default_assignee_tenant
							, `agent_default_assignee` = @ext_l3_default_assignee_agent
						;

		ELSEIF @new_is_creation_needed_in_unee_t_update_extl3 = @old_is_creation_needed_in_unee_t_update_extl3
		THEN 
			
			# This is option 2 creation is NOT needed

				SET @this_trigger_update_ext_l3_insert = 'ut_after_update_external_property_level_3_insert';
				SET @this_trigger_update_ext_l3_update = 'ut_after_update_external_property_level_3_update';

				# We insert the record in the table `property_level_3_rooms`
				# We do this via INSERT INTO ... ON DUPLICATE KEY UPDATE for maximum safety

					INSERT INTO `property_level_3_rooms`
						(`external_id`
						, `external_system_id` 
						, `external_table`
						, `syst_created_datetime`
						, `creation_system_id`
						, `created_by_id`
						, `creation_method`
						, `organization_id`
						, `is_obsolete`
						, `is_creation_needed_in_unee_t`
						, `do_not_insert`
						, `unee_t_unit_type`
						, `system_id_unit`
						, `room_type_id`
						, `surface`
						, `surface_measurment_unit`
						, `room_designation`
						, `room_description`
						, `mgt_cny_default_assignee`
						, `landlord_default_assignee`
						, `tenant_default_assignee`
						, `agent_default_assignee`
						)
						VALUES
							(@external_id_update_extl3
							, @external_system_id_update_extl3
							, @external_table_update_extl3
							, NOW()
							, @creation_system_id_update_extl3
							, @created_by_id_update_extl3
							, @this_trigger_update_ext_l3_insert
							, @organization_id_create_update_extl3
							, @is_obsolete_update_extl3
							, @is_creation_needed_in_unee_t_update_extl3
							, @do_not_insert_update_extl3
							, @unee_t_unit_type_update_extl3
							, @system_id_unit_update_extl3
							, @room_type_id_update_extl3
							, @surface_update_extl3
							, @surface_measurment_unit_update_extl3
							, @room_designation_update_extl3
							, @room_description_update_extl3
							, @ext_l3_default_assignee_mgt_cny
							, @ext_l3_default_assignee_landlord
							, @ext_l3_default_assignee_tenant
							, @ext_l3_default_assignee_agent
						)
						ON DUPLICATE KEY UPDATE
							`syst_updated_datetime` = NOW()
							, `update_system_id` = @update_system_id_update_extl3
							, `updated_by_id` = @updated_by_id_update_extl3
							, `update_method` = @this_trigger_update_ext_l3_update
							, `organization_id` = @organization_id_update_update_extl3
							, `is_obsolete` = @is_obsolete_update_extl3
							, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t_update_extl3
							, `do_not_insert` = @do_not_insert_update_extl3
							, `unee_t_unit_type` = @unee_t_unit_type_update_extl3
							, `system_id_unit` = @system_id_unit_update_extl3
							, `room_type_id` = @room_type_id_update_extl3
							, `surface` = @surface_update_extl3
							, `surface_measurment_unit` = @surface_measurment_unit_update_extl3
							, `room_designation` = @room_designation_update_extl3
							, `room_description` = @room_description_update_extl3
							, `mgt_cny_default_assignee` = @ext_l3_default_assignee_mgt_cny
							, `landlord_default_assignee` = @ext_l3_default_assignee_landlord
							, `tenant_default_assignee` = @ext_l3_default_assignee_tenant
							, `agent_default_assignee` = @ext_l3_default_assignee_agent
						;

		END IF;

	# The conditions are NOT met <-- we do nothing

	END IF;

END;
$$
DELIMITER ;

# Create a trigger to update the table that will fire the lambda each time a new Room needs to be created

	DROP TRIGGER IF EXISTS `ut_after_insert_property_level_3`;

DELIMITER $$
CREATE TRIGGER `ut_after_insert_property_level_3`
AFTER INSERT ON `property_level_3_rooms`
FOR EACH ROW
BEGIN

# We do this ONLY IF 
#	- We have marked the property as an object we need to create in Unee-T
#	- The record does NOT exist in the table `ut_map_external_source_units` yet
#	- This is done via an authorized insert method:
#		- 'ut_after_insert_external_property_level_3_insert'
#		- 'ut_after_insert_external_property_level_3_update'
#		- 'ut_after_update_external_property_level_3_creation_needed_insert'
#		- 'ut_after_update_external_property_level_3_creation_needed_update'
#		- 'ut_after_update_external_property_level_3_insert'
#		- 'ut_after_update_external_property_level_3_update'
#
	SET @is_creation_needed_in_unee_t_insert_l3 = NEW.`is_creation_needed_in_unee_t` ;

	SET @external_property_id_insert_l3 = NEW.`external_id` ;
	SET @external_system_insert_l3 = NEW.`external_system_id` ;
	SET @table_in_external_system_insert_l3 = NEW.`external_table` ;
	SET @organization_id_insert_l3 = NEW.`organization_id`;

	SET @external_property_type_id_insert_l3 = 3;	

	SET @id_in_ut_map_external_source_units_insert_l3 = (SELECT `id_map`
		FROM `ut_map_external_source_units`
		WHERE `external_system` = @external_system_insert_l3
			AND `table_in_external_system` = @table_in_external_system_insert_l3
			AND `external_property_id` = @external_property_id_insert_l3
			AND `organization_id` = @organization_id_insert_l3
			AND `external_property_type_id` = 3
		);

	# This is an insert - if the record does NOT exist, we create the record
	# unless 
	#	- it is specifically specified that we do NOT need to create the record.
	#	- the record is marked as obsolete

		SET @is_obsolete_insert_l3 = NEW.`is_obsolete`;

		SET @do_not_insert_insert_l3_raw = NEW.`do_not_insert` ;

		SET @do_not_insert_insert_l3 = (IF (@id_in_ut_map_external_source_units_insert_l3 IS NULL
				, IF (@is_obsolete_insert_l3 != 0
					, 1
					, 0
					)
				, IF (@is_obsolete_insert_l3 != 0
					, 1
					, @do_not_insert_insert_l3_raw
					)
				)
			);

	SET @upstream_create_method_insert_l3 = NEW.`creation_method` ;
	SET @upstream_update_method_insert_l3 = NEW.`update_method` ;

	IF @is_creation_needed_in_unee_t_insert_l3 = 1
		AND @do_not_insert_insert_l3 = 0
		AND (@upstream_create_method_insert_l3 = 'ut_after_insert_external_property_level_3_insert'
			OR @upstream_update_method_insert_l3 = 'ut_after_insert_external_property_level_3_update'
			OR @upstream_create_method_insert_l3 = 'ut_after_update_external_property_level_3_creation_needed_insert'
			OR @upstream_update_method_insert_l3 = 'ut_after_update_external_property_level_3_creation_needed_update'
			OR @upstream_create_method_insert_l3 = 'ut_after_update_external_property_level_3_insert'
			OR @upstream_update_method_insert_l3 = 'ut_after_update_external_property_level_3_update'
			)
	THEN 

	# We capture the values we need for the insert/udpate:

		SET @this_trigger_insert_l3_insert = 'ut_insert_map_external_source_unit_add_room_insert' ;
		SET @this_trigger_insert_l3_update = 'ut_insert_map_external_source_unit_add_room_update' ;

		SET @creation_system_id_insert_l3 = NEW.`creation_system_id`;
		SET @created_by_id_insert_l3 = NEW.`created_by_id`;

		SET @update_system_id_insert_l3 = NEW.`creation_system_id`;
		SET @updated_by_id_insert_l3 = NEW.`created_by_id`;
			
		SET @is_update_needed_insert_l3 = NULL;
			
		SET @uneet_name_insert_l3 = NEW.`room_designation`;

		SET @unee_t_unit_type_insert_l3_raw = NEW.`unee_t_unit_type` ;

		SET @unee_t_unit_type_insert_l3 = (IFNULL(@unee_t_unit_type_insert_l3_raw
				, 'Unknown'
				)
			)
			;
		
		SET @new_record_id_insert_l3 = NEW.`system_id_room`;

		SET @l3_default_assignee_mgt_cny := NEW.`mgt_cny_default_assignee` ;
		SET @l3_default_assignee_landlord := NEW.`landlord_default_assignee` ;
		SET @l3_default_assignee_tenant := NEW.`tenant_default_assignee` ;
		SET @l3_default_assignee_agent := NEW.`agent_default_assignee` ;

		# We insert/Update a new record in the table `ut_map_external_source_units`

			INSERT INTO `ut_map_external_source_units`
				( `syst_created_datetime`
				, `creation_system_id`
				, `created_by_id`
				, `creation_method`
				, `organization_id`
				, `is_obsolete`
				, `is_update_needed`
				, `uneet_name`
				, `unee_t_unit_type`
				, `new_record_id`
				, `external_property_type_id`
				, `external_property_id`
				, `external_system`
				, `table_in_external_system`
				, `mgt_cny_default_assignee`
				, `landlord_default_assignee`
				, `tenant_default_assignee`
				, `agent_default_assignee`
				)
				VALUES
					(NOW()
					, @creation_system_id_insert_l3
					, @created_by_id_insert_l3
					, @this_trigger_insert_l3_insert
					, @organization_id_insert_l3
					, @is_obsolete_insert_l3
					, @is_update_needed_insert_l3
					, @uneet_name_insert_l3
					, @unee_t_unit_type_insert_l3
					, @new_record_id_insert_l3
					, @external_property_type_id_insert_l3
					, @external_property_id_insert_l3
					, @external_system_insert_l3
					, @table_in_external_system_insert_l3
					, @l3_default_assignee_mgt_cny
					, @l3_default_assignee_landlord
					, @l3_default_assignee_tenant
					, @l3_default_assignee_agent
					)
				ON DUPLICATE KEY UPDATE 
					`syst_updated_datetime` = NOW()
					, `update_system_id` = @update_system_id_insert_l3
					, `updated_by_id` = @updated_by_id_insert_l3
					, `update_method` = @this_trigger_insert_l3_update
					, `organization_id` = @organization_id_insert_l3
					, `uneet_name` = @uneet_name_insert_l3
					, `unee_t_unit_type` = @unee_t_unit_type_insert_l3
					, `is_update_needed` = 1
					, `mgt_cny_default_assignee` = @l3_default_assignee_mgt_cny
					, `landlord_default_assignee` = @l3_default_assignee_landlord
					, `tenant_default_assignee` = @l3_default_assignee_tenant
					, `agent_default_assignee` = @l3_default_assignee_agent
				;

	END IF;
END;
$$
DELIMITER ;

# Create the trigger when the L3P is updated
# This trigger will:
#	- Check if several conditions are met
#	- Capture the value we need in several variables
#	- Call the procedure `ut_update_uneet_when_L3P_is_updated` if needed.

	DROP TRIGGER IF EXISTS `ut_after_update_property_level_3`;

DELIMITER $$
CREATE TRIGGER `ut_after_update_property_level_3`
AFTER UPDATE ON `property_level_3_rooms`
FOR EACH ROW
BEGIN

# We only do this IF:
# 	- We need to create the unit in Unee-T
# 	- We need to update the unit in Unee-T
#	- This is done via an authorized insert or update method:
#		- 'ut_after_insert_external_property_level_3_insert'
#		- 'ut_after_insert_external_property_level_3_update'
#		- 'ut_after_update_external_property_level_3_creation_needed_insert'
#		- 'ut_after_update_external_property_level_3_creation_needed_update'
#		- 'ut_after_update_external_property_level_3_insert'
#		- 'ut_after_update_external_property_level_3_update'
#

# Capture the variables we need to verify if conditions are met:

	SET @upstream_create_method_update_l3 = NEW.`creation_method` ;
	SET @upstream_update_method_update_l3 = NEW.`update_method` ;
		
	SET @new_record_id_update_l3 = NEW.`system_id_room`;

	SET @check_new_record_id_update_l3 = (IF(@new_record_id_update_l3 IS NULL
			, 0
			, IF(@new_record_id_update_l3 = ''
				, 0
				, 1
				)
			)
		)
		;


# We can now check if the conditions are met:

	IF (@upstream_create_method_update_l3 = 'ut_after_insert_external_property_level_3_insert'
			OR @upstream_update_method_update_l3 = 'ut_after_insert_external_property_level_3_update'
			OR @upstream_create_method_update_l3 = 'ut_after_update_external_property_level_3_creation_needed_insert'
			OR @upstream_update_method_update_l3 = 'ut_after_update_external_property_level_3_creation_needed_update'
			OR @upstream_create_method_update_l3 = 'ut_after_update_external_property_level_3_insert'
			OR @upstream_update_method_update_l3 = 'ut_after_update_external_property_level_3_update'
			)
		AND @check_new_record_id_update_l3 = 1
	THEN 

	# Clean Slate - Make sure we don't use a legacy MEFE id

		SET @mefe_unit_id_update_l3 = NULL ;

	# The conditions are met: we capture the other variables we need

		SET @is_creation_needed_in_unee_t_update_l3 = NEW.`is_creation_needed_in_unee_t`;

		SET @new_is_creation_needed_in_unee_t_update_l3 = NEW.`is_creation_needed_in_unee_t`;
		SET @old_is_creation_needed_in_unee_t_update_l3 = OLD.`is_creation_needed_in_unee_t`;

		SET @creation_system_id_update_l3 = NEW.`update_system_id`;
		SET @created_by_id_update_l3 = NEW.`updated_by_id`;

		SET @update_system_id_update_l3 = NEW.`update_system_id`;
		SET @updated_by_id_update_l3 = NEW.`updated_by_id`;

		SET @organization_id_update_l3 = NEW.`organization_id`;
		
		SET @is_update_needed_update_l3 = NULL;
			
		SET @uneet_name_update_l3 = NEW.`room_designation`;

		SET @unee_t_unit_type_update_l3_raw = NEW.`unee_t_unit_type` ;

		SET @unee_t_unit_type_update_l3 = (IFNULL(@unee_t_unit_type_update_l3_raw
				, 'Unknown'
				)
			)
			;

		SET @external_property_id_update_l3 = NEW.`external_id`;
		SET @external_system_update_l3 = NEW.`external_system_id`;
		SET @table_in_external_system_update_l3 = NEW.`external_table`;

		SET @external_property_type_id_update_l3 = 3;

		SET @mefe_unit_id_update_l3 = (SELECT `unee_t_mefe_unit_id`
			FROM `ut_map_external_source_units`
			WHERE `new_record_id` = @new_record_id_update_l3
				AND `external_property_type_id` = @external_property_type_id_update_l1
				AND `unee_t_mefe_unit_id` IS NOT NULL
			);

		SET @l3_default_assignee_mgt_cny := NEW.`mgt_cny_default_assignee` ;
		SET @l3_default_assignee_landlord := NEW.`landlord_default_assignee` ;
		SET @l3_default_assignee_tenant := NEW.`tenant_default_assignee` ;
		SET @l3_default_assignee_agent := NEW.`agent_default_assignee` ;

		# If the record does NOT exist, we create the record
		# unless 
		#	- it is specifically specified that we do NOT need to create the record.
		#	- the record is marked as obsolete

			SET @do_not_insert_update_l3_raw = NEW.`do_not_insert` ;

			SET @is_obsolete_update_l3 = NEW.`is_obsolete`;

			SET @do_not_insert_update_l3 = (IF (@do_not_insert_update_l3_raw IS NULL
					, IF (@is_obsolete_update_l3 != 0
						, 1
						, 0
						)
					, IF (@is_obsolete_update_l3 != 0
						, 1
						, @do_not_insert_update_l3_raw
						)
					)
				);

		IF @is_creation_needed_in_unee_t_update_l3 = 1
			AND (@mefe_unit_id_update_l3 IS NULL
				OR  @mefe_unit_id_update_l3 = ''
				)
			AND @do_not_insert_update_l3 = 0
		THEN 

			# This is option 1 - creation IS needed
			#	- The unit is NOT marked as `do_not_insert`
			#	- We do NOT have a MEFE unit ID for that unit

				SET @this_trigger_update_l3_insert = 'ut_after_update_property_level_3_insert_creation_needed' ;
				SET @this_trigger_update_l3_update = 'ut_after_update_property_level_3_update_creation_needed' ;

			# We insert/Update a new record in the table `ut_map_external_source_units`

				INSERT INTO `ut_map_external_source_units`
					( `syst_created_datetime`
					, `creation_system_id`
					, `created_by_id`
					, `creation_method`
					, `organization_id`
					, `datetime_latest_trigger`
					, `latest_trigger`
					, `is_obsolete`
					, `is_update_needed`
					, `uneet_name`
					, `unee_t_unit_type`
					, `new_record_id`
					, `external_property_type_id`
					, `external_property_id`
					, `external_system`
					, `table_in_external_system`
					, `mgt_cny_default_assignee`
					, `landlord_default_assignee`
					, `tenant_default_assignee`
					, `agent_default_assignee`
					)
					VALUES
						(NOW()
						, @creation_system_id_update_l3
						, @created_by_id_update_l3
						, @this_trigger_update_l3_insert
						, @organization_id_update_l3
						, NOW()
						, @this_trigger_update_l3_insert
						, @is_obsolete_update_l3
						, @is_update_needed_update_l3
						, @uneet_name_update_l3
						, @unee_t_unit_type_update_l3
						, @new_record_id_update_l3
						, @external_property_type_id_update_l3
						, @external_property_id_update_l3
						, @external_system_update_l3
						, @table_in_external_system_update_l3
						, @l3_default_assignee_mgt_cny
						, @l3_default_assignee_landlord
						, @l3_default_assignee_tenant
						, @l3_default_assignee_agent
						)
					ON DUPLICATE KEY UPDATE 
						`syst_updated_datetime` = NOW()
						, `update_system_id` = @update_system_id_update_l3
						, `updated_by_id` = @updated_by_id_update_l3
						, `update_method` = @this_trigger_update_l3_update
						, `organization_id` = @organization_id_update_l3
						, `datetime_latest_trigger` = NOW()
						, `latest_trigger` = @this_trigger_update_l3_update
						, `uneet_name` = @uneet_name_update_l3
						, `unee_t_unit_type` = @unee_t_unit_type_update_l3
						, `is_update_needed` = 1
						, `mgt_cny_default_assignee` = @l3_default_assignee_mgt_cny
						, `landlord_default_assignee` = @l3_default_assignee_landlord
						, `tenant_default_assignee` = @l3_default_assignee_tenant
						, `agent_default_assignee` = @l3_default_assignee_agent
					;
###################################################################
#
# THIS IS CREATING SUBQUERY RETURN MORE THAN 1 ROW ERRORS
#
###################################################################
		ELSEIF @mefe_unit_id_update_l3 IS NOT NULL
			OR @mefe_unit_id_update_l3 != ''
		THEN 
			
			# This is option 2 - creation is NOT needed

				SET @this_trigger_update_l3_insert = 'ut_update_map_external_source_unit_edit_level_3_insert' ;
				SET @this_trigger_update_l3_update = 'ut_update_map_external_source_unit_edit_level_3_update' ;

				# We Update the existing new record in the table `ut_map_external_source_units`

				UPDATE `ut_map_external_source_units`
					SET 
						`syst_updated_datetime` = NOW()
						, `update_system_id` = @update_system_id_update_l3
						, `updated_by_id` = @updated_by_id_update_l3
						, `update_method` = @this_trigger_update_l3_update
						, `organization_id` = @organization_id_update_l3
						, `datetime_latest_trigger` = NOW()
						, `latest_trigger` = @this_trigger_update_l3_update
						, `uneet_name` = @uneet_name_update_l3
						, `unee_t_unit_type` = @unee_t_unit_type_update_l3
						, `is_update_needed` = 1
						, `mgt_cny_default_assignee` = @l3_default_assignee_mgt_cny
						, `landlord_default_assignee` = @l3_default_assignee_landlord
						, `tenant_default_assignee` = @l3_default_assignee_tenant
						, `agent_default_assignee` = @l3_default_assignee_agent
					WHERE `unee_t_mefe_unit_id` = @mefe_unit_id_update_l3
						;

###################################################################
#
# END IS CREATING SUBQUERY RETURN MORE THAN 1 ROW ERRORS
#
###################################################################

		# The conditions are NOT met <-- we do nothing
	
		END IF;

	END IF;

END;
$$
DELIMITER ;


########################################################################################
#
# END - This is a copy of the script `properties_level_3_creation_update_v1_22_9`
#
########################################################################################

########################################################################################
#
# This is a copy of the script `add_user_to_property_trigger_bulk_assign_to_new_unit_v1_29_0`
#
########################################################################################


#################
#	
# When a new MEFE unit is created, auto assign all the users if needed:
#	- Users who can see all units in the organization for the unit
#	- Users who can see all units in the country for the unit
#	- Users who can see all units in the area  for the unit
#
#################


# After we have received a MEFE unit Id from the API, we need to assign that property to:
#	- The default assignee for each role if we have that information
#	- The users who need access to that property:

	DROP TRIGGER IF EXISTS `ut_update_mefe_unit_id_assign_users_to_property`;

DELIMITER $$
CREATE TRIGGER `ut_update_mefe_unit_id_assign_users_to_property`
AFTER UPDATE ON `ut_map_external_source_units`
FOR EACH ROW
BEGIN

# We only do this IF
#	- We have a MEFE unit unit for that property
#	- This is an authorized update method
#		- `ut_creation_unit_mefe_api_reply`

	SET @unee_t_mefe_unit_id_trig_auto_assign_1 := NEW.`unee_t_mefe_unit_id` ;
	SET @upstream_update_method_trig_auto_assign_1 := NEW.`update_method` ;

	SET @requestor_id_trig_auto_assign_1 := NEW.`updated_by_id` ;

	SET @created_by_id_trig_auto_assign_1 := (SELECT `organization_id`
		FROM `ut_organization_mefe_user_id`
		WHERE `mefe_user_id` = @requestor_id_trig_auto_assign_1
		);

	IF @requestor_id_trig_auto_assign_1 IS NOT NULL
		AND @unee_t_mefe_unit_id_trig_auto_assign_1 IS NOT NULL
		AND @upstream_update_method_trig_auto_assign_1 = 'ut_creation_unit_mefe_api_reply'
	THEN 

	# We need to list all the users that we should assign to this new property:
	# These users are users who need to be assigned to:
	#	- All the properties in the organization
	#	- All the properties in the country where this property is
	#	- All the properties in the Area where this property is

		SET @external_property_type_id_trig_auto_assign_1 := NEW.`external_property_type_id` ;

		SET @property_id_trig_auto_assign_1 := NEW.`new_record_id` ;

		SET @organization_id_trig_auto_assign_1 := NEW.`organization_id` ;

	# What is the country for that property

		SET @property_country_code_trig_auto_assign_1 := (IF (@external_property_type_id_trig_auto_assign_1 = 1
				, (SELECT `country_code`
					FROM `ut_list_mefe_unit_id_level_1_by_area`
					WHERE `level_1_building_id` = @property_id_trig_auto_assign_1
					)
				, IF (@external_property_type_id_trig_auto_assign_1 = 2
					, (SELECT `country_code`
						FROM `ut_list_mefe_unit_id_level_2_by_area`
						WHERE `level_2_unit_id` = @property_id_trig_auto_assign_1
						)
					, IF (@external_property_type_id_trig_auto_assign_1 = 3
						, (SELECT `country_code`
							FROM `ut_list_mefe_unit_id_level_3_by_area`
							WHERE `level_3_room_id` = @property_id_trig_auto_assign_1
							)
						, 'error - 1308'
						)
					)
				)
			);

	# We get the other variables we need:

		SET @syst_created_datetime_trig_auto_assign_1 := NOW() ;
		SET @creation_system_id_trig_auto_assign_1 := 2 ;
		SET @creation_method_trig_auto_assign_1 := 'ut_update_mefe_unit_id_assign_users_to_property' ;

	# We create a temporary table to list all the users we need to add to that property:

		DROP TEMPORARY TABLE IF EXISTS `temp_list_users_auto_assign_new_property` ;

		CREATE TEMPORARY TABLE `temp_list_users_auto_assign_new_property` (
			`id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique ID in this table',
			`syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
			`creation_system_id` int(11) NOT NULL DEFAULT 1 COMMENT 'What is the id of the sytem that was used for the creation of the record?',
			`requestor_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who created this record',
			`created_by_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
 			`creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
			`organization_id` int(11) unsigned DEFAULT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
			`country_code` varchar(10) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The 2 letter version of the country code',
			`mefe_user_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The current Unee-T profile id of the person - this is the value of the field `_id` in the Mongo Collection `users`',
			`email` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The primary email address of the person',
			`unee_t_user_type_id` int(11) NOT NULL COMMENT 'A FK to the table `ut_user_types`',
			`mefe_unit_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'ID of that Unit in Unee-T. This is a the value in the Mongo collection',
			`unee_t_role_id` smallint(6) DEFAULT NULL COMMENT 'The ID of the Role Type for this user - this is a FK to the Unee-T BZFE table `ut_role_types`',
			`is_occupant` tinyint(1) DEFAULT 0 COMMENT '1 is the user is an occupant of the unit',
			`is_default_assignee` tinyint(1) DEFAULT 0 COMMENT '1 if this user is the default assignee for this role for this unit.',
			`is_default_invited` tinyint(1) DEFAULT 0 COMMENT '1 if the user is automatically invited to all the new cases in this role for this unit',
			`is_unit_owner` tinyint(1) DEFAULT 0 COMMENT '1 if this user is one of the Unee-T `owner` of that unit',
			`is_public` tinyint(1) DEFAULT 0 COMMENT '1 if the user is Visible to other Unee-T users in other roles for this unit. If yes/1/TRUE then all other roles will be able to see this user. IF No/FALSE/0 then only the users in the same role for that unit will be able to see this user in this unit',
			`can_see_role_landlord` tinyint(1) DEFAULT 0 COMMENT '1 if user is allowed to see the PUBLIC users in the role `landlord` (2) for this unit',
			`can_see_role_tenant` tinyint(1) DEFAULT 0 COMMENT '1 if user is allowed to see the PUBLIC users in the role `tenant` (1) for this unit',
			`can_see_role_mgt_cny` tinyint(1) DEFAULT 0 COMMENT '1 if user is allowed to see the PUBLIC users in the role `Mgt Company` (4) for this unit',
			`can_see_role_agent` tinyint(1) DEFAULT 0 COMMENT '1 if user is allowed to see the PUBLIC users in the role `agent` (5) for this unit',
			`can_see_role_contractor` tinyint(1) DEFAULT 0 COMMENT '1 if user is allowed to see the PUBLIC users in the role `contractor` (3) for this unit',
			`can_see_occupant` tinyint(1) DEFAULT 0 COMMENT '1 if user is allowed to see the PUBLIC occupants for this unit',
			`is_assigned_to_case` tinyint(1) DEFAULT 0 COMMENT '1 if user wants to be notified',
			`is_invited_to_case` tinyint(1) DEFAULT 0 COMMENT '1 if user wants to be notified',
			`is_next_step_updated` tinyint(1) DEFAULT 0 COMMENT '1 if user wants to be notified',
			`is_deadline_updated` tinyint(1) DEFAULT 0 COMMENT '1 if user wants to be notified',
			`is_solution_updated` tinyint(1) DEFAULT 0 COMMENT '1 if user wants to be notified',
			`is_case_resolved` tinyint(1) DEFAULT 0 COMMENT '1 if user wants to be notified',
			`is_case_blocker` tinyint(1) DEFAULT 0 COMMENT '1 if user wants to be notified',
			`is_case_critical` tinyint(1) DEFAULT 0 COMMENT '1 if user wants to be notified',
			`is_any_new_message` tinyint(1) DEFAULT 0 COMMENT '1 if user wants to be notified',
			`is_message_from_tenant` tinyint(1) DEFAULT 0 COMMENT '1 if user wants to be notified',
			`is_message_from_ll` tinyint(1) DEFAULT 0 COMMENT '1 if user wants to be notified',
			`is_message_from_occupant` tinyint(1) DEFAULT 0 COMMENT '1 if user wants to be notified',
			`is_message_from_agent` tinyint(1) DEFAULT 0 COMMENT '1 if user wants to be notified',
			`is_message_from_mgt_cny` tinyint(1) DEFAULT 0 COMMENT '1 if user wants to be notified',
			`is_message_from_contractor` tinyint(1) DEFAULT 0 COMMENT '1 if user wants to be notified',
			`is_new_ir` tinyint(1) DEFAULT 0 COMMENT '1 if user wants to be notified',
			`is_new_item` tinyint(1) DEFAULT 0 COMMENT '1 if user wants to be notified',
			`is_item_removed` tinyint(1) DEFAULT 0 COMMENT '1 if user wants to be notified',
			`is_item_moved` tinyint(1) DEFAULT 0 COMMENT '1 if user wants to be notified',
			PRIMARY KEY (`mefe_user_id`,`mefe_unit_id`),
			UNIQUE KEY `temp_list_users_auto_assign_new_property_id` (`id`)
			) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci
			;

	# We insert all the user that should see all the units in the organization

		INSERT INTO `temp_list_users_auto_assign_new_property`
			(`syst_created_datetime`
			, `creation_system_id`
			, `requestor_id`
			, `created_by_id`
			, `creation_method`
			, `organization_id`
			, `mefe_user_id`
			, `email`
			, `unee_t_user_type_id`
			, `mefe_unit_id`
			, `unee_t_role_id`
			, `is_occupant`
			, `is_default_assignee`
			, `is_default_invited`
			, `is_unit_owner`
			, `is_public`
			, `can_see_role_landlord`
			, `can_see_role_tenant`
			, `can_see_role_mgt_cny`
			, `can_see_role_agent`
			, `can_see_role_contractor`
			, `can_see_occupant`
			, `is_assigned_to_case`
			, `is_invited_to_case`
			, `is_next_step_updated`
			, `is_deadline_updated`
			, `is_solution_updated`
			, `is_case_resolved`
			, `is_case_blocker`
			, `is_case_critical`
			, `is_any_new_message`
			, `is_message_from_tenant`
			, `is_message_from_ll`
			, `is_message_from_occupant`
			, `is_message_from_agent`
			, `is_message_from_mgt_cny`
			, `is_message_from_contractor`
			, `is_new_ir`
			, `is_new_item`
			, `is_item_removed`
			, `is_item_moved`
			)
		SELECT 
			@syst_created_datetime_trig_auto_assign_1
			, @creation_system_id_trig_auto_assign_1
			, @requestor_id_trig_auto_assign_1
			, @created_by_id_trig_auto_assign_1
			, @creation_method_trig_auto_assign_1
			, @organization_id_trig_auto_assign_1
			, `a`.`mefe_user_id`
			, `a`.`email`
			, `a`.`unee_t_user_type_id`
			, @unee_t_mefe_unit_id_trig_auto_assign_1
			, `a`.`unee_t_role_id`
			, `a`.`is_occupant`
			, `a`.`is_default_assignee`
			, `a`.`is_default_invited`
			, `a`.`is_unit_owner`
			, `a`.`is_public`
			, `a`.`can_see_role_landlord`
			, `a`.`can_see_role_tenant`
			, `a`.`can_see_role_mgt_cny`
			, `a`.`can_see_role_agent`
			, `a`.`can_see_role_contractor`
			, `a`.`can_see_occupant`
			, `a`.`is_assigned_to_case`
			, `a`.`is_invited_to_case`
			, `a`.`is_next_step_updated`
			, `a`.`is_deadline_updated`
			, `a`.`is_solution_updated`
			, `a`.`is_case_resolved`
			, `a`.`is_case_blocker`
			, `a`.`is_case_critical`
			, `a`.`is_any_new_message`
			, `a`.`is_message_from_tenant`
			, `a`.`is_message_from_ll`
			, `a`.`is_message_from_occupant`
			, `a`.`is_message_from_agent`
			, `a`.`is_message_from_mgt_cny`
			, `a`.`is_message_from_contractor`
			, `a`.`is_new_ir`
			, `a`.`is_new_item`
			, `a`.`is_item_removed`
			, `a`.`is_item_moved`
			FROM `ut_list_users_default_permissions` AS `a`
				WHERE 
					`a`.`organization_id` = @organization_id_trig_auto_assign_1
					AND `a`.`is_all_unit` = 1
			;

	# We insert all the user that should see all the unit in the country where this unit is

		INSERT INTO `temp_list_users_auto_assign_new_property`
			(`syst_created_datetime`
			, `creation_system_id`
			, `requestor_id`
			, `created_by_id`
			, `creation_method`
			, `organization_id`
			, `country_code`
			, `mefe_user_id`
			, `email`
			, `unee_t_user_type_id`
			, `mefe_unit_id`
			, `unee_t_role_id`
			, `is_occupant`
			, `is_default_assignee`
			, `is_default_invited`
			, `is_unit_owner`
			, `is_public`
			, `can_see_role_landlord`
			, `can_see_role_tenant`
			, `can_see_role_mgt_cny`
			, `can_see_role_agent`
			, `can_see_role_contractor`
			, `can_see_occupant`
			, `is_assigned_to_case`
			, `is_invited_to_case`
			, `is_next_step_updated`
			, `is_deadline_updated`
			, `is_solution_updated`
			, `is_case_resolved`
			, `is_case_blocker`
			, `is_case_critical`
			, `is_any_new_message`
			, `is_message_from_tenant`
			, `is_message_from_ll`
			, `is_message_from_occupant`
			, `is_message_from_agent`
			, `is_message_from_mgt_cny`
			, `is_message_from_contractor`
			, `is_new_ir`
			, `is_new_item`
			, `is_item_removed`
			, `is_item_moved`
			)
			SELECT 
				@syst_created_datetime_trig_auto_assign_1
				, @creation_system_id_trig_auto_assign_1
				, @requestor_id_trig_auto_assign_1
				, @created_by_id_trig_auto_assign_1
				, @creation_method_trig_auto_assign_1
				, @organization_id_trig_auto_assign_1
				, `a`.`country_code`
				, `a`.`mefe_user_id`
				, `a`.`email`
				, `a`.`unee_t_user_type_id`
				, @unee_t_mefe_unit_id_trig_auto_assign_1
				, `a`.`unee_t_role_id`
				, `a`.`is_occupant`
				, `a`.`is_default_assignee`
				, `a`.`is_default_invited`
				, `a`.`is_unit_owner`
				, `a`.`is_public`
				, `a`.`can_see_role_landlord`
				, `a`.`can_see_role_tenant`
				, `a`.`can_see_role_mgt_cny`
				, `a`.`can_see_role_agent`
				, `a`.`can_see_role_contractor`
				, `a`.`can_see_occupant`
				, `a`.`is_assigned_to_case`
				, `a`.`is_invited_to_case`
				, `a`.`is_next_step_updated`
				, `a`.`is_deadline_updated`
				, `a`.`is_solution_updated`
				, `a`.`is_case_resolved`
				, `a`.`is_case_blocker`
				, `a`.`is_case_critical`
				, `a`.`is_any_new_message`
				, `a`.`is_message_from_tenant`
				, `a`.`is_message_from_ll`
				, `a`.`is_message_from_occupant`
				, `a`.`is_message_from_agent`
				, `a`.`is_message_from_mgt_cny`
				, `a`.`is_message_from_contractor`
				, `a`.`is_new_ir`
				, `a`.`is_new_item`
				, `a`.`is_item_removed`
				, `a`.`is_item_moved`
				FROM `ut_list_users_default_permissions` AS `a`
					WHERE 
						`a`.`organization_id` = @organization_id_trig_auto_assign_1
						AND `a`.`country_code` = @property_country_code_trig_auto_assign_1
						AND `a`.`is_all_units_in_country` = 1
				;

	# We can now check and assign the default assignees for the newly created property:

		# The Management Company (4)

			SET @default_user_mgt_cny = NEW.`mgt_cny_default_assignee`;

			SET @check_default_user_mgt_cny = (IF(@default_user_mgt_cny IS NULL
					, 0
					, IF(@default_user_mgt_cny = ''
						, 0
						, 1
						)
					)

				)
				;

			IF @check_default_user_mgt_cny = 1
			THEN

			# We Prepare the variables we need
				
				SET @country_code_default_assignee = (SELECT `country_code`
					FROM `ut_user_person_details`
					WHERE `unee_t_mefe_user_id` = @default_user_mgt_cny
					)
					;

				
				SET @email_default_assignee = (SELECT `email`
					FROM `ut_user_person_details`
					WHERE `unee_t_mefe_user_id` = @default_user_mgt_cny
					)
					;

				SET @unee_t_user_role_type = 4 ;

				SET @unee_t_user_type_id_default_assignee = (SELECT `id_unee_t_user_type`
					FROM `ut_user_types`
					WHERE `organization_id` = @organization_id_trig_auto_assign_1
						AND `creation_system_id` = 'Setup'
						AND `creation_method` = 'trigger_ut_after_insert_new_organization'
						AND `ut_user_role_type_id` = @unee_t_user_role_type
						AND `is_super_admin` = 0
					)
					;

			# We insert the record in the "prepare" table

				INSERT INTO `temp_list_users_auto_assign_new_property`
					(`syst_created_datetime`
					, `creation_system_id`
					, `requestor_id`
					, `created_by_id`
					, `creation_method`
					, `organization_id`
					, `country_code`
					, `mefe_user_id`
					, `email`
					, `unee_t_user_type_id`
					, `mefe_unit_id`
					, `unee_t_role_id`
					, `is_occupant`
					, `is_default_assignee`
					, `is_default_invited`
					, `is_unit_owner`
					, `is_public`
					, `can_see_role_landlord`
					, `can_see_role_tenant`
					, `can_see_role_mgt_cny`
					, `can_see_role_agent`
					, `can_see_role_contractor`
					, `can_see_occupant`
					)
					SELECT 
						NOW()
						, @creation_system_id_trig_auto_assign_1
						, @requestor_id_trig_auto_assign_1
						, @created_by_id_trig_auto_assign_1
						, @creation_method_trig_auto_assign_1
						, @organization_id_trig_auto_assign_1
						, @country_code_default_assignee
						, @default_user_mgt_cny
						, @email_default_assignee
						, @unee_t_user_type_id_default_assignee
						, @unee_t_mefe_unit_id_trig_auto_assign_1
						, @unee_t_user_role_type
						, `a`.`is_occupant`
						, `a`.`is_default_assignee`
						, `a`.`is_default_invited`
						, `a`.`is_unit_owner`
						, `a`.`is_public`
						, `a`.`can_see_role_landlord`
						, `a`.`can_see_role_tenant`
						, `a`.`can_see_role_mgt_cny`
						, `a`.`can_see_role_agent`
						, `a`.`can_see_role_contractor`
						, `a`.`can_see_occupant`
						FROM `ut_user_types` AS `a`
							WHERE `id_unee_t_user_type` = @unee_t_user_type_id_default_assignee
						;

			END IF;

		# The Lanlord (2)

			SET @default_user_landlord = NEW.`landlord_default_assignee`;

			SET @check_default_user_landlord = (IF(@default_user_landlord IS NULL
					, 0
					, IF(@default_user_landlord = ''
						, 0
						, 1
						)
					)

				)
				;

			IF @check_default_user_landlord = 1
			THEN

			# We Prepare the variables we need
				
				SET @country_code_default_assignee = (SELECT `country_code`
					FROM `ut_user_person_details`
					WHERE `unee_t_mefe_user_id` = @default_user_landlord
					)
					;

				
				SET @email_default_assignee = (SELECT `email`
					FROM `ut_user_person_details`
					WHERE `unee_t_mefe_user_id` = @default_user_landlord
					)
					;

				SET @unee_t_user_role_type = 2 ;

				SET @unee_t_user_type_id_default_assignee = (SELECT `id_unee_t_user_type`
					FROM `ut_user_types`
					WHERE `organization_id` = @organization_id_trig_auto_assign_1
						AND `creation_system_id` = 'Setup'
						AND `creation_method` = 'trigger_ut_after_insert_new_organization'
						AND `ut_user_role_type_id` = @unee_t_user_role_type
						AND `is_super_admin` = 0
					)
					;

			# We insert the record in the "prepare" table

				INSERT INTO `temp_list_users_auto_assign_new_property`
					(`syst_created_datetime`
					, `creation_system_id`
					, `requestor_id`
					, `created_by_id`
					, `creation_method`
					, `organization_id`
					, `country_code`
					, `mefe_user_id`
					, `email`
					, `unee_t_user_type_id`
					, `mefe_unit_id`
					, `unee_t_role_id`
					, `is_occupant`
					, `is_default_assignee`
					, `is_default_invited`
					, `is_unit_owner`
					, `is_public`
					, `can_see_role_landlord`
					, `can_see_role_tenant`
					, `can_see_role_mgt_cny`
					, `can_see_role_agent`
					, `can_see_role_contractor`
					, `can_see_occupant`
					)
					SELECT 
						NOW()
						, @creation_system_id_trig_auto_assign_1
						, @requestor_id_trig_auto_assign_1
						, @created_by_id_trig_auto_assign_1
						, @creation_method_trig_auto_assign_1
						, @organization_id_trig_auto_assign_1
						, @country_code_default_assignee
						, @default_user_landlord
						, @email_default_assignee
						, @unee_t_user_type_id_default_assignee
						, @unee_t_mefe_unit_id_trig_auto_assign_1
						, @unee_t_user_role_type
						, `a`.`is_occupant`
						, `a`.`is_default_assignee`
						, `a`.`is_default_invited`
						, `a`.`is_unit_owner`
						, `a`.`is_public`
						, `a`.`can_see_role_landlord`
						, `a`.`can_see_role_tenant`
						, `a`.`can_see_role_mgt_cny`
						, `a`.`can_see_role_agent`
						, `a`.`can_see_role_contractor`
						, `a`.`can_see_occupant`
						FROM `ut_user_types` AS `a`
							WHERE `id_unee_t_user_type` = @unee_t_user_type_id_default_assignee
						;

			END IF;

		# The Agent (5)

			SET @default_user_agent = NEW.`agent_default_assignee`;

			SET @check_default_user_agent = (IF(@default_user_agent IS NULL
					, 0
					, IF(@default_user_agent = ''
						, 0
						, 1
						)
					)

				)
				;

			IF @check_default_user_agent = 1
			THEN

			# We Prepare the variables we need
				
				SET @country_code_default_assignee = (SELECT `country_code`
					FROM `ut_user_person_details`
					WHERE `unee_t_mefe_user_id` = @default_user_agent
					)
					;

				
				SET @email_default_assignee = (SELECT `email`
					FROM `ut_user_person_details`
					WHERE `unee_t_mefe_user_id` = @default_user_agent
					)
					;

				SET @unee_t_user_role_type = 1 ;

				SET @unee_t_user_type_id_default_assignee = (SELECT `id_unee_t_user_type`
					FROM `ut_user_types`
					WHERE `organization_id` = @organization_id_trig_auto_assign_1
						AND `creation_system_id` = 'Setup'
						AND `creation_method` = 'trigger_ut_after_insert_new_organization'
						AND `ut_user_role_type_id` = @unee_t_user_role_type
						AND `is_super_admin` = 0
					)
					;
			# We insert the record in the "prepare" table

				INSERT INTO `temp_list_users_auto_assign_new_property`
					(`syst_created_datetime`
					, `creation_system_id`
					, `requestor_id`
					, `created_by_id`
					, `creation_method`
					, `organization_id`
					, `country_code`
					, `mefe_user_id`
					, `email`
					, `unee_t_user_type_id`
					, `mefe_unit_id`
					, `unee_t_role_id`
					, `is_occupant`
					, `is_default_assignee`
					, `is_default_invited`
					, `is_unit_owner`
					, `is_public`
					, `can_see_role_landlord`
					, `can_see_role_tenant`
					, `can_see_role_mgt_cny`
					, `can_see_role_agent`
					, `can_see_role_contractor`
					, `can_see_occupant`
					)
					SELECT 
						NOW()
						, @creation_system_id_trig_auto_assign_1
						, @requestor_id_trig_auto_assign_1
						, @created_by_id_trig_auto_assign_1
						, @creation_method_trig_auto_assign_1
						, @organization_id_trig_auto_assign_1
						, @country_code_default_assignee
						, @default_user_agent
						, @email_default_assignee
						, @unee_t_user_type_id_default_assignee
						, @unee_t_mefe_unit_id_trig_auto_assign_1
						, @unee_t_user_role_type
						, `a`.`is_occupant`
						, `a`.`is_default_assignee`
						, `a`.`is_default_invited`
						, `a`.`is_unit_owner`
						, `a`.`is_public`
						, `a`.`can_see_role_landlord`
						, `a`.`can_see_role_tenant`
						, `a`.`can_see_role_mgt_cny`
						, `a`.`can_see_role_agent`
						, `a`.`can_see_role_contractor`
						, `a`.`can_see_occupant`
						FROM `ut_user_types` AS `a`
							WHERE `id_unee_t_user_type` = @unee_t_user_type_id_default_assignee
						;
			END IF;

		# The Tenant (1)

			SET @default_user_tenant = NEW.`tenant_default_assignee`;

			SET @check_default_user_tenant = (IF(@default_user_tenant IS NULL
					, 0
					, IF(@default_user_tenant = ''
						, 0
						, 1
						)
					)

				)
				;

			IF @check_default_user_tenant = 1
			THEN

			# We Prepare the variables we need
				
				SET @country_code_default_assignee = (SELECT `country_code`
					FROM `ut_user_person_details`
					WHERE `unee_t_mefe_user_id` = @default_user_tenant
					)
					;

				
				SET @email_default_assignee = (SELECT `email`
					FROM `ut_user_person_details`
					WHERE `unee_t_mefe_user_id` = @default_user_tenant
					)
					;

				SET @unee_t_user_role_type = 5 ;

				SET @unee_t_user_type_id_default_assignee = (SELECT `id_unee_t_user_type`
					FROM `ut_user_types`
					WHERE `organization_id` = @organization_id_trig_auto_assign_1
						AND `creation_system_id` = 'Setup'
						AND `creation_method` = 'trigger_ut_after_insert_new_organization'
						AND `ut_user_role_type_id` = @unee_t_user_role_type
						AND `is_super_admin` = 0
					)
					;

			# We insert the record in the "prepare" table

				INSERT INTO `temp_list_users_auto_assign_new_property`
					(`syst_created_datetime`
					, `creation_system_id`
					, `requestor_id`
					, `created_by_id`
					, `creation_method`
					, `organization_id`
					, `country_code`
					, `mefe_user_id`
					, `email`
					, `unee_t_user_type_id`
					, `mefe_unit_id`
					, `unee_t_role_id`
					, `is_occupant`
					, `is_default_assignee`
					, `is_default_invited`
					, `is_unit_owner`
					, `is_public`
					, `can_see_role_landlord`
					, `can_see_role_tenant`
					, `can_see_role_mgt_cny`
					, `can_see_role_agent`
					, `can_see_role_contractor`
					, `can_see_occupant`
					)
					SELECT 
						NOW()
						, @creation_system_id_trig_auto_assign_1
						, @requestor_id_trig_auto_assign_1
						, @created_by_id_trig_auto_assign_1
						, @creation_method_trig_auto_assign_1
						, @organization_id_trig_auto_assign_1
						, @country_code_default_assignee
						, @default_user_tenant
						, @email_default_assignee
						, @unee_t_user_type_id_default_assignee
						, @unee_t_mefe_unit_id_trig_auto_assign_1
						, @unee_t_user_role_type
						, `a`.`is_occupant`
						, `a`.`is_default_assignee`
						, `a`.`is_default_invited`
						, `a`.`is_unit_owner`
						, `a`.`is_public`
						, `a`.`can_see_role_landlord`
						, `a`.`can_see_role_tenant`
						, `a`.`can_see_role_mgt_cny`
						, `a`.`can_see_role_agent`
						, `a`.`can_see_role_contractor`
						, `a`.`can_see_occupant`
						FROM `ut_user_types` AS `a`
							WHERE `id_unee_t_user_type` = @unee_t_user_type_id_default_assignee
						;

			END IF;

	# We assign the user to the unit

		# For Level 1 Properties, this is done in the table 
		# `external_map_user_unit_role_permissions_level_1`

			SET @propagate_to_all_level_2_trig_auto_assign_1 := 1 ;
			SET @propagate_to_all_level_3_trig_auto_assign_1 := 1;

			SET @is_obsolete_trig_auto_assign_1 := 0 ;
			SET @is_update_needed_trig_auto_assign_1 := 1 ;

			IF @external_property_type_id_trig_auto_assign_1 = 1
			THEN

				INSERT INTO `external_map_user_unit_role_permissions_level_1`
					(`syst_created_datetime`
					, `creation_system_id`
					, `created_by_id`
					, `creation_method`
					, `organization_id`
					, `is_obsolete`
					, `is_update_needed`
					# Which unit/user
					, `unee_t_mefe_user_id`
					, `unee_t_level_1_id`
					, `unee_t_user_type_id`
					, `propagate_level_2`
					, `propagate_level_3`
					)
					SELECT 
						@syst_created_datetime_trig_auto_assign_1
						, @creation_system_id_trig_auto_assign_1
						, @created_by_id_trig_auto_assign_1
						, @creation_method_trig_auto_assign_1
						, @organization_id_trig_auto_assign_1
						, @is_obsolete_trig_auto_assign_1
						, @is_update_needed_trig_auto_assign_1
						# Which unit/user
						, `a`.`mefe_user_id`
						, @property_id_trig_auto_assign_1
						, `a`.`unee_t_user_type_id`
						, @propagate_to_all_level_2_trig_auto_assign_1
						, @propagate_to_all_level_3_trig_auto_assign_1
					FROM `temp_list_users_auto_assign_new_property` AS `a`
						ON DUPLICATE KEY UPDATE
							`syst_updated_datetime` := @syst_created_datetime_trig_auto_assign_1
							, `update_system_id` := @creation_system_id_trig_auto_assign_1
							, `updated_by_id` := @created_by_id_trig_auto_assign_1
							, `update_method` := @creation_method_trig_auto_assign_1
							, `organization_id` := @organization_id_trig_auto_assign_1
							, `is_obsolete` := @is_obsolete_trig_auto_assign_1
							, `is_update_needed` := @is_update_needed_trig_auto_assign_1
							# Which unit/user
							, `unee_t_mefe_user_id` := `a`.`mefe_user_id`
							, `unee_t_level_1_id` := @property_id_trig_auto_assign_1
							, `unee_t_user_type_id` := `a`.`unee_t_user_type_id`
							, `propagate_level_2`:= @propagate_to_all_level_2_trig_auto_assign_1
							, `propagate_level_3` := @propagate_to_all_level_3_trig_auto_assign_1
						;

				# We insert these in the table `ut_map_user_permissions_unit_level_1`

					INSERT INTO `ut_map_user_permissions_unit_level_1`
						(`syst_created_datetime`
						, `creation_system_id`
						, `created_by_id`
						, `creation_method`
						, `organization_id`
						, `is_obsolete`
						, `is_update_needed`
						# Which unit/user
						, `unee_t_mefe_id`
						, `unee_t_unit_id`
						# which role
						, `unee_t_role_id`
						, `is_occupant`
						# additional permissions
						, `is_default_assignee`
						, `is_default_invited`
						, `is_unit_owner`
						# Visibility rules
						, `is_public`
						, `can_see_role_landlord`
						, `can_see_role_tenant`
						, `can_see_role_mgt_cny`
						, `can_see_role_agent`
						, `can_see_role_contractor`
						, `can_see_occupant`
						# Notification rules
						# - case - information
						, `is_assigned_to_case`
						, `is_invited_to_case`
						, `is_next_step_updated`
						, `is_deadline_updated`
						, `is_solution_updated`
						, `is_case_resolved`
						, `is_case_blocker`
						, `is_case_critical`
						# - case - messages
						, `is_any_new_message`
						, `is_message_from_tenant`
						, `is_message_from_ll`
						, `is_message_from_occupant`
						, `is_message_from_agent`
						, `is_message_from_mgt_cny`
						, `is_message_from_contractor`
						# - Inspection Reports
						, `is_new_ir`
						# - Inventory
						, `is_new_item`
						, `is_item_removed`
						, `is_item_moved`
						, `propagate_to_all_level_2`
						, `propagate_to_all_level_3`
						)
						SELECT
							@syst_created_datetime_trig_auto_assign_1
							, @creation_system_id_trig_auto_assign_1
							, @requestor_id_trig_auto_assign_1
							, @creation_method_trig_auto_assign_1
							, @organization_id_trig_auto_assign_1
							, @is_obsolete_trig_auto_assign_1
							, @is_update_needed_trig_auto_assign_1
							# Which unit/user
							, `a`.`mefe_user_id`
							, @unee_t_mefe_unit_id_trig_auto_assign_1
							# which role
							, `a`.`unee_t_role_id`
							, `a`.`is_occupant`
							# additional permissions
							, `a`.`is_default_assignee`
							, `a`.`is_default_invited`
							, `a`.`is_unit_owner`
							# Visibility rules
							, `a`.`is_public`
							, `a`.`can_see_role_landlord`
							, `a`.`can_see_role_tenant`
							, `a`.`can_see_role_mgt_cny`
							, `a`.`can_see_role_agent`
							, `a`.`can_see_role_contractor`
							, `a`.`can_see_occupant`
							# Notification rules
							# - case - information
							, `a`.`is_assigned_to_case`
							, `a`.`is_invited_to_case`
							, `a`.`is_next_step_updated`
							, `a`.`is_deadline_updated`
							, `a`.`is_solution_updated`
							, `a`.`is_case_resolved`
							, `a`.`is_case_blocker`
							, `a`.`is_case_critical`
							# - case - messages
							, `a`.`is_any_new_message`
							, `a`.`is_message_from_tenant`
							, `a`.`is_message_from_ll`
							, `a`.`is_message_from_occupant`
							, `a`.`is_message_from_agent`
							, `a`.`is_message_from_mgt_cny`
							, `a`.`is_message_from_contractor`
							# - Inspection Reports
							, `a`.`is_new_ir`
							# - Inventory
							, `a`.`is_new_item`
							, `a`.`is_item_removed`
							, `a`.`is_item_moved`
							, @propagate_to_all_level_2_trig_auto_assign_1
							, @propagate_to_all_level_3_trig_auto_assign_1
							FROM `temp_list_users_auto_assign_new_property` AS `a`
							ON DUPLICATE KEY UPDATE
								`syst_updated_datetime` := @syst_created_datetime_trig_auto_assign_1
								, `update_system_id` := @creation_system_id_trig_auto_assign_1
								, `updated_by_id` := @requestor_id_trig_auto_assign_1
								, `update_method` := @creation_method_trig_auto_assign_1
								, `organization_id` := @organization_id_trig_auto_assign_1
								, `is_obsolete` := @is_obsolete_trig_auto_assign_1
								, `is_update_needed` := @is_update_needed_trig_auto_assign_1
								# Which unit/user
								, `unee_t_mefe_id` := `a`.`mefe_user_id`
								, `unee_t_unit_id` := @unee_t_mefe_unit_id_trig_auto_assign_1
								# which role
								, `unee_t_role_id` := `a`.`unee_t_role_id`
								, `is_occupant` := `a`.`is_occupant`
								# additional permissions
								, `is_default_assignee` := `a`.`is_default_assignee`
								, `is_default_invited` := `a`.`is_default_invited`
								, `is_unit_owner` := `a`.`is_unit_owner`
								# Visibility rules
								, `is_public` := `a`.`is_public`
								, `can_see_role_landlord` := `a`.`can_see_role_landlord`
								, `can_see_role_tenant` := `a`.`can_see_role_tenant`
								, `can_see_role_mgt_cny` := `a`.`can_see_role_mgt_cny`
								, `can_see_role_agent` := `a`.`can_see_role_agent`
								, `can_see_role_contractor` := `a`.`can_see_role_contractor`
								, `can_see_occupant` := `a`.`can_see_occupant`
								# Notification rules
								# - case - information
								, `is_assigned_to_case` := `a`.`is_assigned_to_case`
								, `is_invited_to_case` := `a`.`is_invited_to_case`
								, `is_next_step_updated` := `a`.`is_next_step_updated`
								, `is_deadline_updated` := `a`.`is_deadline_updated`
								, `is_solution_updated` := `a`.`is_solution_updated`
								, `is_case_resolved` := `a`.`is_case_resolved`
								, `is_case_blocker` := `a`.`is_case_blocker`
								, `is_case_critical` := `a`.`is_case_critical`
								# - case - messages
								, `is_any_new_message` := `a`.`is_any_new_message`
								, `is_message_from_tenant` := `a`.`is_message_from_tenant`
								, `is_message_from_ll` := `a`.`is_message_from_ll`
								, `is_message_from_occupant` := `a`.`is_message_from_occupant`
								, `is_message_from_agent` := `a`.`is_message_from_agent`
								, `is_message_from_mgt_cny` := `a`.`is_message_from_mgt_cny`
								, `is_message_from_contractor` := `a`.`is_message_from_contractor`
								# - Inspection Reports
								, `is_new_ir` := `a`.`is_new_ir`
								# - Inventory
								, `is_new_item` := `a`.`is_new_item`
								, `is_item_removed` := `a`.`is_item_removed`
								, `is_item_moved` := `a`.`is_item_moved`
								, `propagate_to_all_level_2` = @propagate_to_all_level_2_trig_auto_assign_1
								, `propagate_to_all_level_3` = @propagate_to_all_level_3_trig_auto_assign_1
								;

			ELSEIF @external_property_type_id_trig_auto_assign_1 = 2
			THEN 

				INSERT INTO `external_map_user_unit_role_permissions_level_2`
					(`syst_created_datetime`
					, `creation_system_id`
					, `created_by_id`
					, `creation_method`
					, `organization_id`
					, `is_obsolete`
					, `is_update_needed`
					# Which unit/user
					, `unee_t_mefe_user_id`
					, `unee_t_level_2_id`
					, `unee_t_user_type_id`
					, `propagate_level_3`
					)
					SELECT 
						@syst_created_datetime_trig_auto_assign_1
						, @creation_system_id_trig_auto_assign_1
						, @created_by_id_trig_auto_assign_1
						, @creation_method_trig_auto_assign_1
						, @organization_id_trig_auto_assign_1
						, @is_obsolete_trig_auto_assign_1
						, @is_update_needed_trig_auto_assign_1
						# Which unit/user
						, `a`.`mefe_user_id`
						, @property_id_trig_auto_assign_1
						, `a`.`unee_t_user_type_id`
						, @propagate_to_all_level_3_trig_auto_assign_1
					FROM `temp_list_users_auto_assign_new_property` AS `a`
						ON DUPLICATE KEY UPDATE
							`syst_updated_datetime` := @syst_created_datetime_trig_auto_assign_1
							, `update_system_id` := @creation_system_id_trig_auto_assign_1
							, `updated_by_id` := @created_by_id_trig_auto_assign_1
							, `update_method` := @creation_method_trig_auto_assign_1
							, `organization_id` := @organization_id_trig_auto_assign_1
							, `is_obsolete` := @is_obsolete_trig_auto_assign_1
							, `is_update_needed` := @is_update_needed_trig_auto_assign_1
							# Which unit/user
							, `unee_t_mefe_user_id` := `a`.`mefe_user_id`
							, `unee_t_level_2_id` := @property_id_trig_auto_assign_1
							, `unee_t_user_type_id` := `a`.`unee_t_user_type_id`
							, `propagate_level_3` := @propagate_to_all_level_3_trig_auto_assign_1
						;

				# We insert these in the table `ut_map_user_permissions_unit_level_2` 

					INSERT INTO `ut_map_user_permissions_unit_level_2`
						(`syst_created_datetime`
						, `creation_system_id`
						, `created_by_id`
						, `creation_method`
						, `organization_id`
						, `is_obsolete`
						, `is_update_needed`
						# Which unit/user
						, `unee_t_mefe_id`
						, `unee_t_unit_id`
						# which role
						, `unee_t_role_id`
						, `is_occupant`
						# additional permissions
						, `is_default_assignee`
						, `is_default_invited`
						, `is_unit_owner`
						# Visibility rules
						, `is_public`
						, `can_see_role_landlord`
						, `can_see_role_tenant`
						, `can_see_role_mgt_cny`
						, `can_see_role_agent`
						, `can_see_role_contractor`
						, `can_see_occupant`
						# Notification rules
						# - case - information
						, `is_assigned_to_case`
						, `is_invited_to_case`
						, `is_next_step_updated`
						, `is_deadline_updated`
						, `is_solution_updated`
						, `is_case_resolved`
						, `is_case_blocker`
						, `is_case_critical`
						# - case - messages
						, `is_any_new_message`
						, `is_message_from_tenant`
						, `is_message_from_ll`
						, `is_message_from_occupant`
						, `is_message_from_agent`
						, `is_message_from_mgt_cny`
						, `is_message_from_contractor`
						# - Inspection Reports
						, `is_new_ir`
						# - Inventory
						, `is_new_item`
						, `is_item_removed`
						, `is_item_moved`
						, `propagate_to_all_level_3`
						)
						SELECT
							@syst_created_datetime_trig_auto_assign_1
							, @creation_system_id_trig_auto_assign_1
							, @requestor_id_trig_auto_assign_1
							, @creation_method_trig_auto_assign_1
							, @organization_id_trig_auto_assign_1
							, @is_obsolete_trig_auto_assign_1
							, @is_update_needed_trig_auto_assign_1
							# Which unit/user
							, `a`.`mefe_user_id`
							, @unee_t_mefe_unit_id_trig_auto_assign_1
							# which role
							, `a`.`unee_t_role_id`
							, `a`.`is_occupant`
							# additional permissions
							, `a`.`is_default_assignee`
							, `a`.`is_default_invited`
							, `a`.`is_unit_owner`
							# Visibility rules
							, `a`.`is_public`
							, `a`.`can_see_role_landlord`
							, `a`.`can_see_role_tenant`
							, `a`.`can_see_role_mgt_cny`
							, `a`.`can_see_role_agent`
							, `a`.`can_see_role_contractor`
							, `a`.`can_see_occupant`
							# Notification rules
							# - case - information
							, `a`.`is_assigned_to_case`
							, `a`.`is_invited_to_case`
							, `a`.`is_next_step_updated`
							, `a`.`is_deadline_updated`
							, `a`.`is_solution_updated`
							, `a`.`is_case_resolved`
							, `a`.`is_case_blocker`
							, `a`.`is_case_critical`
							# - case - messages
							, `a`.`is_any_new_message`
							, `a`.`is_message_from_tenant`
							, `a`.`is_message_from_ll`
							, `a`.`is_message_from_occupant`
							, `a`.`is_message_from_agent`
							, `a`.`is_message_from_mgt_cny`
							, `a`.`is_message_from_contractor`
							# - Inspection Reports
							, `a`.`is_new_ir`
							# - Inventory
							, `a`.`is_new_item`
							, `a`.`is_item_removed`
							, `a`.`is_item_moved`
							, @propagate_to_all_level_3_trig_auto_assign_1
							FROM `temp_list_users_auto_assign_new_property` AS `a`
							ON DUPLICATE KEY UPDATE
								`syst_updated_datetime` := @syst_created_datetime_trig_auto_assign_1
								, `update_system_id` := @creation_system_id_trig_auto_assign_1
								, `updated_by_id` := @requestor_id_trig_auto_assign_1
								, `update_method` := @creation_method_trig_auto_assign_1
								, `organization_id` := @organization_id_trig_auto_assign_1
								, `is_obsolete` := @is_obsolete_trig_auto_assign_1
								, `is_update_needed` := @is_update_needed_trig_auto_assign_1
								# Which unit/user
								, `unee_t_mefe_id` := `a`.`mefe_user_id`
								, `unee_t_unit_id` := @unee_t_mefe_unit_id_trig_auto_assign_1
								# which role
								, `unee_t_role_id` := `a`.`unee_t_role_id`
								, `is_occupant` := `a`.`is_occupant`
								# additional permissions
								, `is_default_assignee` := `a`.`is_default_assignee`
								, `is_default_invited` := `a`.`is_default_invited`
								, `is_unit_owner` := `a`.`is_unit_owner`
								# Visibility rules
								, `is_public` := `a`.`is_public`
								, `can_see_role_landlord` := `a`.`can_see_role_landlord`
								, `can_see_role_tenant` := `a`.`can_see_role_tenant`
								, `can_see_role_mgt_cny` := `a`.`can_see_role_mgt_cny`
								, `can_see_role_agent` := `a`.`can_see_role_agent`
								, `can_see_role_contractor` := `a`.`can_see_role_contractor`
								, `can_see_occupant` := `a`.`can_see_occupant`
								# Notification rules
								# - case - information
								, `is_assigned_to_case` := `a`.`is_assigned_to_case`
								, `is_invited_to_case` := `a`.`is_invited_to_case`
								, `is_next_step_updated` := `a`.`is_next_step_updated`
								, `is_deadline_updated` := `a`.`is_deadline_updated`
								, `is_solution_updated` := `a`.`is_solution_updated`
								, `is_case_resolved` := `a`.`is_case_resolved`
								, `is_case_blocker` := `a`.`is_case_blocker`
								, `is_case_critical` := `a`.`is_case_critical`
								# - case - messages
								, `is_any_new_message` := `a`.`is_any_new_message`
								, `is_message_from_tenant` := `a`.`is_message_from_tenant`
								, `is_message_from_ll` := `a`.`is_message_from_ll`
								, `is_message_from_occupant` := `a`.`is_message_from_occupant`
								, `is_message_from_agent` := `a`.`is_message_from_agent`
								, `is_message_from_mgt_cny` := `a`.`is_message_from_mgt_cny`
								, `is_message_from_contractor` := `a`.`is_message_from_contractor`
								# - Inspection Reports
								, `is_new_ir` := `a`.`is_new_ir`
								# - Inventory
								, `is_new_item` := `a`.`is_new_item`
								, `is_item_removed` := `a`.`is_item_removed`
								, `is_item_moved` := `a`.`is_item_moved`
								, `propagate_to_all_level_3` = @propagate_to_all_level_3_trig_auto_assign_1
								;

			ELSEIF @external_property_type_id_trig_auto_assign_1 = 3
			THEN 

				INSERT INTO `external_map_user_unit_role_permissions_level_3`
					(`syst_created_datetime`
					, `creation_system_id`
					, `created_by_id`
					, `creation_method`
					, `organization_id`
					, `is_obsolete`
					, `is_update_needed`
					# Which unit/user
					, `unee_t_mefe_user_id`
					, `unee_t_level_3_id`
					, `unee_t_user_type_id`
					)
					SELECT 
						@syst_created_datetime_trig_auto_assign_1
						, @creation_system_id_trig_auto_assign_1
						, @created_by_id_trig_auto_assign_1
						, @creation_method_trig_auto_assign_1
						, @organization_id_trig_auto_assign_1
						, @is_obsolete_trig_auto_assign_1
						, @is_update_needed_trig_auto_assign_1
						# Which unit/user
						, `a`.`mefe_user_id`
						, @property_id_trig_auto_assign_1
						, `a`.`unee_t_user_type_id`
					FROM `temp_list_users_auto_assign_new_property` AS `a`
						ON DUPLICATE KEY UPDATE
							`syst_updated_datetime` := @syst_created_datetime_trig_auto_assign_1
							, `update_system_id` := @creation_system_id_trig_auto_assign_1
							, `updated_by_id` := @created_by_id_trig_auto_assign_1
							, `update_method` := @creation_method_trig_auto_assign_1
							, `organization_id` := @organization_id_trig_auto_assign_1
							, `is_obsolete` := @is_obsolete_trig_auto_assign_1
							, `is_update_needed` := @is_update_needed_trig_auto_assign_1
							# Which unit/user
							, `unee_t_mefe_user_id` := `a`.`mefe_user_id`
							, `unee_t_level_3_id` := @property_id_trig_auto_assign_1
							, `unee_t_user_type_id` := `a`.`unee_t_user_type_id`
						;

				# We insert these in the table `ut_map_user_permissions_unit_level_3` 

					INSERT INTO `ut_map_user_permissions_unit_level_3`
						(`syst_created_datetime`
						, `creation_system_id`
						, `created_by_id`
						, `creation_method`
						, `organization_id`
						, `is_obsolete`
						, `is_update_needed`
						# Which unit/user
						, `unee_t_mefe_id`
						, `unee_t_unit_id`
						# which role
						, `unee_t_role_id`
						, `is_occupant`
						# additional permissions
						, `is_default_assignee`
						, `is_default_invited`
						, `is_unit_owner`
						# Visibility rules
						, `is_public`
						, `can_see_role_landlord`
						, `can_see_role_tenant`
						, `can_see_role_mgt_cny`
						, `can_see_role_agent`
						, `can_see_role_contractor`
						, `can_see_occupant`
						# Notification rules
						# - case - information
						, `is_assigned_to_case`
						, `is_invited_to_case`
						, `is_next_step_updated`
						, `is_deadline_updated`
						, `is_solution_updated`
						, `is_case_resolved`
						, `is_case_blocker`
						, `is_case_critical`
						# - case - messages
						, `is_any_new_message`
						, `is_message_from_tenant`
						, `is_message_from_ll`
						, `is_message_from_occupant`
						, `is_message_from_agent`
						, `is_message_from_mgt_cny`
						, `is_message_from_contractor`
						# - Inspection Reports
						, `is_new_ir`
						# - Inventory
						, `is_new_item`
						, `is_item_removed`
						, `is_item_moved`
						)
						SELECT
							@syst_created_datetime_trig_auto_assign_1
							, @creation_system_id_trig_auto_assign_1
							, @requestor_id_trig_auto_assign_1
							, @creation_method_trig_auto_assign_1
							, @organization_id_trig_auto_assign_1
							, @is_obsolete_trig_auto_assign_1
							, @is_update_needed_trig_auto_assign_1
							# Which unit/user
							, `a`.`mefe_user_id`
							, @unee_t_mefe_unit_id_trig_auto_assign_1
							# which role
							, `a`.`unee_t_role_id`
							, `a`.`is_occupant`
							# additional permissions
							, `a`.`is_default_assignee`
							, `a`.`is_default_invited`
							, `a`.`is_unit_owner`
							# Visibility rules
							, `a`.`is_public`
							, `a`.`can_see_role_landlord`
							, `a`.`can_see_role_tenant`
							, `a`.`can_see_role_mgt_cny`
							, `a`.`can_see_role_agent`
							, `a`.`can_see_role_contractor`
							, `a`.`can_see_occupant`
							# Notification rules
							# - case - information
							, `a`.`is_assigned_to_case`
							, `a`.`is_invited_to_case`
							, `a`.`is_next_step_updated`
							, `a`.`is_deadline_updated`
							, `a`.`is_solution_updated`
							, `a`.`is_case_resolved`
							, `a`.`is_case_blocker`
							, `a`.`is_case_critical`
							# - case - messages
							, `a`.`is_any_new_message`
							, `a`.`is_message_from_tenant`
							, `a`.`is_message_from_ll`
							, `a`.`is_message_from_occupant`
							, `a`.`is_message_from_agent`
							, `a`.`is_message_from_mgt_cny`
							, `a`.`is_message_from_contractor`
							# - Inspection Reports
							, `a`.`is_new_ir`
							# - Inventory
							, `a`.`is_new_item`
							, `a`.`is_item_removed`
							, `a`.`is_item_moved`
							FROM `temp_list_users_auto_assign_new_property` AS `a`
							ON DUPLICATE KEY UPDATE
								`syst_updated_datetime` := @syst_created_datetime_trig_auto_assign_1
								, `update_system_id` := @creation_system_id_trig_auto_assign_1
								, `updated_by_id` := @requestor_id_trig_auto_assign_1
								, `update_method` := @creation_method_trig_auto_assign_1
								, `organization_id` := @organization_id_trig_auto_assign_1
								, `is_obsolete` := @is_obsolete_trig_auto_assign_1
								, `is_update_needed` := @is_update_needed_trig_auto_assign_1
								# Which unit/user
								, `unee_t_mefe_id` := `a`.`mefe_user_id`
								, `unee_t_unit_id` := @unee_t_mefe_unit_id_trig_auto_assign_1
								# which role
								, `unee_t_role_id` := `a`.`unee_t_role_id`
								, `is_occupant` := `a`.`is_occupant`
								# additional permissions
								, `is_default_assignee` := `a`.`is_default_assignee`
								, `is_default_invited` := `a`.`is_default_invited`
								, `is_unit_owner` := `a`.`is_unit_owner`
								# Visibility rules
								, `is_public` := `a`.`is_public`
								, `can_see_role_landlord` := `a`.`can_see_role_landlord`
								, `can_see_role_tenant` := `a`.`can_see_role_tenant`
								, `can_see_role_mgt_cny` := `a`.`can_see_role_mgt_cny`
								, `can_see_role_agent` := `a`.`can_see_role_agent`
								, `can_see_role_contractor` := `a`.`can_see_role_contractor`
								, `can_see_occupant` := `a`.`can_see_occupant`
								# Notification rules
								# - case - information
								, `is_assigned_to_case` := `a`.`is_assigned_to_case`
								, `is_invited_to_case` := `a`.`is_invited_to_case`
								, `is_next_step_updated` := `a`.`is_next_step_updated`
								, `is_deadline_updated` := `a`.`is_deadline_updated`
								, `is_solution_updated` := `a`.`is_solution_updated`
								, `is_case_resolved` := `a`.`is_case_resolved`
								, `is_case_blocker` := `a`.`is_case_blocker`
								, `is_case_critical` := `a`.`is_case_critical`
								# - case - messages
								, `is_any_new_message` := `a`.`is_any_new_message`
								, `is_message_from_tenant` := `a`.`is_message_from_tenant`
								, `is_message_from_ll` := `a`.`is_message_from_ll`
								, `is_message_from_occupant` := `a`.`is_message_from_occupant`
								, `is_message_from_agent` := `a`.`is_message_from_agent`
								, `is_message_from_mgt_cny` := `a`.`is_message_from_mgt_cny`
								, `is_message_from_contractor` := `a`.`is_message_from_contractor`
								# - Inspection Reports
								, `is_new_ir` := `a`.`is_new_ir`
								# - Inventory
								, `is_new_item` := `a`.`is_new_item`
								, `is_item_removed` := `a`.`is_item_removed`
								, `is_item_moved` := `a`.`is_item_moved`
								;

			END IF;

		# We can now include these into the table that triggers the lambda

			INSERT INTO `ut_map_user_permissions_unit_all`
				(`syst_created_datetime`
				, `creation_system_id`
				, `created_by_id`
				, `creation_method`
				, `organization_id`
				, `is_obsolete`
				, `is_update_needed`
				# Which unit/user
				, `unee_t_mefe_id`
				, `unee_t_unit_id`
				# which role
				, `unee_t_role_id`
				, `is_occupant`
				# additional permissions
				, `is_default_assignee`
				, `is_default_invited`
				, `is_unit_owner`
				# Visibility rules
				, `is_public`
				, `can_see_role_landlord`
				, `can_see_role_tenant`
				, `can_see_role_mgt_cny`
				, `can_see_role_agent`
				, `can_see_role_contractor`
				, `can_see_occupant`
				# Notification rules
				# - case - information
				, `is_assigned_to_case`
				, `is_invited_to_case`
				, `is_next_step_updated`
				, `is_deadline_updated`
				, `is_solution_updated`
				, `is_case_resolved`
				, `is_case_blocker`
				, `is_case_critical`
				# - case - messages
				, `is_any_new_message`
				, `is_message_from_tenant`
				, `is_message_from_ll`
				, `is_message_from_occupant`
				, `is_message_from_agent`
				, `is_message_from_mgt_cny`
				, `is_message_from_contractor`
				# - Inspection Reports
				, `is_new_ir`
				# - Inventory
				, `is_new_item`
				, `is_item_removed`
				, `is_item_moved`
				)
				SELECT
					@syst_created_datetime_trig_auto_assign_1
					, @creation_system_id_trig_auto_assign_1
					, @requestor_id_trig_auto_assign_1
					, @creation_method_trig_auto_assign_1
					, @organization_id_trig_auto_assign_1
					, @is_obsolete_trig_auto_assign_1
					, @is_update_needed_trig_auto_assign_1
					# Which unit/user
					, `a`.`mefe_user_id`
					, @unee_t_mefe_unit_id_trig_auto_assign_1
					# which role
					, `a`.`unee_t_role_id`
					, `a`.`is_occupant`
					# additional permissions
					, `a`.`is_default_assignee`
					, `a`.`is_default_invited`
					, `a`.`is_unit_owner`
					# Visibility rules
					, `a`.`is_public`
					, `a`.`can_see_role_landlord`
					, `a`.`can_see_role_tenant`
					, `a`.`can_see_role_mgt_cny`
					, `a`.`can_see_role_agent`
					, `a`.`can_see_role_contractor`
					, `a`.`can_see_occupant`
					# Notification rules
					# - case - information
					, `a`.`is_assigned_to_case`
					, `a`.`is_invited_to_case`
					, `a`.`is_next_step_updated`
					, `a`.`is_deadline_updated`
					, `a`.`is_solution_updated`
					, `a`.`is_case_resolved`
					, `a`.`is_case_blocker`
					, `a`.`is_case_critical`
					# - case - messages
					, `a`.`is_any_new_message`
					, `a`.`is_message_from_tenant`
					, `a`.`is_message_from_ll`
					, `a`.`is_message_from_occupant`
					, `a`.`is_message_from_agent`
					, `a`.`is_message_from_mgt_cny`
					, `a`.`is_message_from_contractor`
					# - Inspection Reports
					, `a`.`is_new_ir`
					# - Inventory
					, `a`.`is_new_item`
					, `a`.`is_item_removed`
					, `a`.`is_item_moved`
					FROM `temp_list_users_auto_assign_new_property` AS `a`
					ON DUPLICATE KEY UPDATE
						`syst_updated_datetime` := @syst_created_datetime_trig_auto_assign_1
						, `update_system_id` := @creation_system_id_trig_auto_assign_1
						, `updated_by_id` := @requestor_id_trig_auto_assign_1
						, `update_method` := @creation_method_trig_auto_assign_1
						, `organization_id` := @organization_id_trig_auto_assign_1
						, `is_obsolete` := @is_obsolete_trig_auto_assign_1
						, `is_update_needed` := @is_update_needed_trig_auto_assign_1
						# Which unit/user
						, `unee_t_mefe_id` := `a`.`mefe_user_id`
						, `unee_t_unit_id` := @unee_t_mefe_unit_id_trig_auto_assign_1
						# which role
						, `unee_t_role_id` := `a`.`unee_t_role_id`
						, `is_occupant` := `a`.`is_occupant`
						# additional permissions
						, `is_default_assignee` := `a`.`is_default_assignee`
						, `is_default_invited` := `a`.`is_default_invited`
						, `is_unit_owner` := `a`.`is_unit_owner`
						# Visibility rules
						, `is_public` := `a`.`is_public`
						, `can_see_role_landlord` := `a`.`can_see_role_landlord`
						, `can_see_role_tenant` := `a`.`can_see_role_tenant`
						, `can_see_role_mgt_cny` := `a`.`can_see_role_mgt_cny`
						, `can_see_role_agent` := `a`.`can_see_role_agent`
						, `can_see_role_contractor` := `a`.`can_see_role_contractor`
						, `can_see_occupant` := `a`.`can_see_occupant`
						# Notification rules
						# - case - information
						, `is_assigned_to_case` := `a`.`is_assigned_to_case`
						, `is_invited_to_case` := `a`.`is_invited_to_case`
						, `is_next_step_updated` := `a`.`is_next_step_updated`
						, `is_deadline_updated` := `a`.`is_deadline_updated`
						, `is_solution_updated` := `a`.`is_solution_updated`
						, `is_case_resolved` := `a`.`is_case_resolved`
						, `is_case_blocker` := `a`.`is_case_blocker`
						, `is_case_critical` := `a`.`is_case_critical`
						# - case - messages
						, `is_any_new_message` := `a`.`is_any_new_message`
						, `is_message_from_tenant` := `a`.`is_message_from_tenant`
						, `is_message_from_ll` := `a`.`is_message_from_ll`
						, `is_message_from_occupant` := `a`.`is_message_from_occupant`
						, `is_message_from_agent` := `a`.`is_message_from_agent`
						, `is_message_from_mgt_cny` := `a`.`is_message_from_mgt_cny`
						, `is_message_from_contractor` := `a`.`is_message_from_contractor`
						# - Inspection Reports
						, `is_new_ir` := `a`.`is_new_ir`
						# - Inventory
						, `is_new_item` := `a`.`is_new_item`
						, `is_item_removed` := `a`.`is_item_removed`
						, `is_item_moved` := `a`.`is_item_moved`
						;

	END IF;
END;
$$
DELIMITER ;

########################################################################################
#
# END - This is a copy of the script `add_user_to_property_trigger_bulk_assign_to_new_unit_v1_29_0`
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