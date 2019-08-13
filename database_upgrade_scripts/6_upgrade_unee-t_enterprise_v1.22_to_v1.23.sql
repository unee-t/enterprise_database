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

	SET @old_schema_version := 'v1.22.0';
	SET @new_schema_version := 'v1.23.0_alpha_5';

# What is the name of this script?

	SET @this_script := CONCAT ('upgrade_unee-t_entreprise', @old_schema_version, '_to_', @new_schema_version, '.sql');

# In this update
# New functionalities
#	- Record the default Assignee for each role at each level:
#		- Area
#		- Level 1 (Building)
#		- Level 2 (Unit)
#		- Level 3 (Room)
#
#	- When the Default assignee is selected for a Level, automatically propagate to all the sub levels:
#	  Example
#		- Default assignee of building 1 is user A
#		  This is automatically propagate to
#			- Level 2
#			- Level 3
#
# Housekeeping: rename the table `ut_api_keys` to `unte_api_keys`
#	WARNING: WE HAVE TO UPDATE SOME VIEWS.
#	MAKE SURE TO RUN THE SCRIPT `1_views_v1_23_0.sql`
#
# - Drop tables we do not need anymore
#	- ``
#	- ``
#
# - Alter a existing tables to add:
#	- UNTE API create request ID
#	- UNTE API edit request ID
#	- `is_update_on_duplicate` bit
# The tables impacted are:
#	- `external_persons`
#	- `external_property_groups_areas`
#	- `external_property_level_1_buildings`
#	- `external_property_level_2_units`
#	- `external_property_level_3_rooms`
#	- `persons`
#	- `property_groups_areas`
#	- `property_level_1_buildings`
#	- `property_level_2_units`
#	- `property_level_3_rooms`
#	- `retry_assign_user_to_units_list`
#	- `retry_create_units_list_units`
#	- `ut_map_external_source_areas`
#	- `ut_map_external_source_units`
#	- `ut_map_external_source_users`
#	- `ut_map_user_permissions_unit_all`
#	- `ut_map_user_permissions_unit_level_1`
#	- `ut_map_user_permissions_unit_level_2`
#	- `ut_map_user_permissions_unit_level_3`
#
#	- Add default assignee for
#		- Mgt Cny
#		- Landlord
#		- Tenant
#		- Agent
# The tables impacted are:
#	- `external_property_groups_areas`
#	- `external_property_level_1_buildings`
#	- `external_property_level_2_units`
#	- `external_property_level_3_rooms`
#	- `property_groups_areas`
#	- `property_level_1_buildings`
#	- `property_level_2_units`
#	- `property_level_3_rooms`
#
# Add several columns to the the table `uneet_enterprise_organizations` to store default values:
#	- `default_sot_system`
#	- `default_sot_persons`
#	- `default_sot_areas`
#	- `default_sot_properties`
#	- `default_area`
#	- `default_building`
#	- `default_unit`
# This is needed so that we can have a functional API to create new units
#
#
# Add a new mapping table `ut_map_external_source_areas` to store info on areas
#
# - Create new tables needed for the UNTE APIs
#	- `unte_api_add_unit` <-- API to create new properties
#WIP	- `unte_api_edit_unit` <-- API to edit existing properties
#WIP	- `unte_api_add_area` <-- API to create new areas
#WIP	- `unte_api_edit_area` <-- API to edit existing areas 
#WIP	- `unte_api_add_user` <-- API to create new users
#WIP	- `unte_api_edit_user` <-- API to edit existing users
#WIP	- `unte_api_add_user_to_unit` <-- API to create new association user to unit
#WIP	- `unte_api_remove_user_from_unit` <-- API to remove existing association user/unit.
#
#
# Bug Fix:
#WIP	- some units are not auto assigned to some users
#WIP	- After unit is created users are not auto assigned to that unit as they should
#WIP	- After user permissions are reset units are not auto assigned as they should
#
# Utilities:
#	- Create a routine to reset user role and reassign the same role to these users.
#		This is useful when we need to make sure all users have access to all the units they need to see
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
# Add more values to the table `ut_unit_types`
# Make 2 values obsolete in the table `ut_unit_types`
#
###############################
#
# We have everything we need - Do it!
#
###############################

# When are we doing this?

	SET @the_timestamp := NOW();

# Do the changes:

# this change is done by running the scripts:
#	- ``

# Rename the table `ut_api_keys` to `unte_api_keys`

		ALTER TABLE `ut_api_keys` RENAME `unte_api_keys`;

	# Rename an index for better clarity

		/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;

		ALTER TABLE `unte_api_keys` 
			ADD UNIQUE KEY `unique_api_key`(`api_key`) , 
			DROP KEY `unit_api_key` , 
			DROP FOREIGN KEY `api_key_organization_id`  ;
		ALTER TABLE `unte_api_keys`
			ADD CONSTRAINT `unte_api_key_organization_id` 
			FOREIGN KEY (`organization_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE ;

		/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;

# Change the structure of some tables

	/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;

	/* Foreign Keys must be dropped in the target to ensure that requires changes can be done*/

	ALTER TABLE `external_persons` 
		DROP FOREIGN KEY `person_created_by_id`  , 
		DROP FOREIGN KEY `person_gender`  , 
		DROP FOREIGN KEY `person_salutation`  , 
		DROP FOREIGN KEY `person_status`  , 
		DROP FOREIGN KEY `person_ut_user_type`  , 
		DROP FOREIGN KEY `peson_udpated_by_id`  ;

	ALTER TABLE `persons` 
		DROP FOREIGN KEY `person_organization_id`  , 
		DROP FOREIGN KEY `person_person_salutation`  , 
		DROP FOREIGN KEY `person_person_status`  , 
		DROP FOREIGN KEY `person_unee-t_user_type`  , 
		DROP FOREIGN KEY `sot_creation_system_person`  , 
		DROP FOREIGN KEY `sot_update_system_person`  ;

	ALTER TABLE `property_groups_areas` 
		DROP FOREIGN KEY `areas_organization_id`  ;

	ALTER TABLE `property_level_1_buildings` 
		DROP FOREIGN KEY `property_level_1_organization_id`  , 
		DROP FOREIGN KEY `unee_t_valid_unit_type_building`  ;

	ALTER TABLE `property_level_2_units` 
		DROP FOREIGN KEY `property_level_2_organization_id`  , 
		DROP FOREIGN KEY `unee_t_valid_unit_type_unit`  ;

	ALTER TABLE `property_level_3_rooms` 
		DROP FOREIGN KEY `property_level_3_organization_id`  , 
		DROP FOREIGN KEY `room_id_flat_id`  , 
		DROP FOREIGN KEY `room_id_room_type_id`  , 
		DROP FOREIGN KEY `unee_t_valid_unit_type_room`  ;

	ALTER TABLE `ut_map_external_source_units` 
		DROP FOREIGN KEY `mefe_unit_organization_id`  , 
		DROP FOREIGN KEY `property_property_type`  , 
		DROP FOREIGN KEY `unee_t_valid_unit_type_map_units`  ;

	ALTER TABLE `ut_map_external_source_users` 
		DROP FOREIGN KEY `mefe_user_organization_id`  , 
		DROP FOREIGN KEY `unee-t_user_person`  ;

	ALTER TABLE `ut_map_user_permissions_unit_all` 
		DROP FOREIGN KEY `map_mefe_unit_mefe_user_all_organization_id`  , 
		DROP FOREIGN KEY `mefe_unit_must_exist_here`  , 
		DROP FOREIGN KEY `mefe_user_must_exist_here`  ;

	ALTER TABLE `ut_map_user_permissions_unit_level_1` 
		DROP FOREIGN KEY `map_mefe_unit_mefe_user_level_1_organization_id`  , 
		DROP FOREIGN KEY `unit_level_1_mefe_unit_id_must_exist`  , 
		DROP FOREIGN KEY `unit_level_1_mefe_user_id_must_exist`  ;

	ALTER TABLE `ut_map_user_permissions_unit_level_2` 
		DROP FOREIGN KEY `map_mefe_unit_mefe_user_level_2_organization_id`  , 
		DROP FOREIGN KEY `unit_level_2_mefe_unit_id_must_exist`  , 
		DROP FOREIGN KEY `unit_level_2_mefe_user_id_must_exist`  ;

	ALTER TABLE `ut_map_user_permissions_unit_level_3` 
		DROP FOREIGN KEY `map_mefe_unit_mefe_user_level_3_organization_id`  , 
		DROP FOREIGN KEY `map_user_permissions_unit_level_3_room_id`  , 
		DROP FOREIGN KEY `unit_level_3_mefe_unit_id_must_exist`  , 
		DROP FOREIGN KEY `unit_level_3_mefe_user_id_must_exist`  ;


	/* Alter table in target */
	ALTER TABLE `external_persons` 
		ADD COLUMN `create_api_request_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The Unique ID that identifies the API request to create this' after `id_person` , 
		ADD COLUMN `edit_api_request_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The Unique ID that identifies the API request to edit this' after `create_api_request_id` , 
		CHANGE `external_id` `external_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The id of the record in an external system' after `edit_api_request_id` , 
		ADD COLUMN `is_update_on_duplicate_key` tinyint(1)   NULL COMMENT '1 if this was a ON DUPLICATE KEY UPDATE event' after `update_method` , 
		CHANGE `person_status_id` `person_status_id` int(11)   NULL DEFAULT 1 COMMENT 'The id of the person status in the table 164_person_statuses' after `is_update_on_duplicate_key` , 
		ADD UNIQUE KEY `create_api_request_id`(`create_api_request_id`) , 
		ADD UNIQUE KEY `edit_api_request_id`(`edit_api_request_id`) ;

	/* Alter table in target */
	ALTER TABLE `external_property_groups_areas` 
		ADD COLUMN `create_api_request_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The Unique ID that identifies the API request to create this' after `id_area` , 
		ADD COLUMN `edit_api_request_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The Unique ID that identifies the API request to edit this' after `create_api_request_id` , 
		CHANGE `external_id` `external_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The id of the record in an external system' after `edit_api_request_id` , 
		ADD COLUMN `is_update_on_duplicate_key` tinyint(1)   NULL COMMENT '1 if this was a ON DUPLICATE KEY UPDATE event' after `update_method` , 
		CHANGE `is_creation_needed_in_unee_t` `is_creation_needed_in_unee_t` tinyint(1)   NULL DEFAULT 1 COMMENT '1 if we need this object in Unee-T' after `is_update_on_duplicate_key` , 
		ADD COLUMN `mgt_cny_default_assignee` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'A FK to the table `ut_map_external_source_users`. This is the MEFE user Id for the default assignee for the role \"management company\"' after `area_definition` , 
		ADD COLUMN `landlord_default_assignee` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'A FK to the table `ut_map_external_source_users`. This is the MEFE user Id for the default assignee for the role \"landlord\"' after `mgt_cny_default_assignee` , 
		ADD COLUMN `tenant_default_assignee` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'A FK to the table `ut_map_external_source_users`. This is the MEFE user Id for the default assignee for the role \"tenant\"' after `landlord_default_assignee` , 
		ADD COLUMN `agent_default_assignee` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'A FK to the table `ut_map_external_source_users`. This is the MEFE user Id for the default assignee for the role \"Agent\"' after `tenant_default_assignee` , 
		ADD UNIQUE KEY `create_api_request_id`(`create_api_request_id`) , 
		ADD UNIQUE KEY `edit_api_request_id`(`edit_api_request_id`) , 
		ADD KEY `ext_property_area_country_code`(`country_code`) , 
		ADD KEY `ext_property_area_default_assignee_agent`(`agent_default_assignee`) , 
		ADD KEY `ext_property_area_default_assignee_landlord`(`landlord_default_assignee`) , 
		ADD KEY `ext_property_area_default_assignee_mgt_cny`(`mgt_cny_default_assignee`) , 
		ADD KEY `ext_property_area_default_assignee_tenant`(`tenant_default_assignee`) , 
		DROP FOREIGN KEY `property_area_created_by`  , 
		DROP FOREIGN KEY `property_area_updated_by`  ;
	ALTER TABLE `external_property_groups_areas`
		ADD CONSTRAINT `ext_property_area_country_code` 
		FOREIGN KEY (`country_code`) REFERENCES `property_groups_countries` (`country_code`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `ext_property_area_created_by` 
		FOREIGN KEY (`created_by_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `ext_property_area_default_assignee_agent` 
		FOREIGN KEY (`agent_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `ext_property_area_default_assignee_landlord` 
		FOREIGN KEY (`landlord_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `ext_property_area_default_assignee_mgt_cny` 
		FOREIGN KEY (`mgt_cny_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `ext_property_area_default_assignee_tenant` 
		FOREIGN KEY (`tenant_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `ext_property_area_updated_by` 
		FOREIGN KEY (`updated_by_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE ;


	/* Alter table in target */
	ALTER TABLE `external_property_level_1_buildings` 
		ADD COLUMN `create_api_request_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The Unique ID that identifies the API request to create this' after `id_building` , 
		ADD COLUMN `edit_api_request_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The Unique ID that identifies the API request to edit this' after `create_api_request_id` , 
		CHANGE `external_id` `external_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The id of the record in an external system' after `edit_api_request_id` , 
		ADD COLUMN `is_update_on_duplicate_key` tinyint(1)   NULL COMMENT '1 if this was a ON DUPLICATE KEY UPDATE event' after `update_method` , 
		CHANGE `is_obsolete` `is_obsolete` tinyint(1)   NULL DEFAULT 0 COMMENT '1 if this record is obsolete' after `is_update_on_duplicate_key` , 
		ADD COLUMN `mgt_cny_default_assignee` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'A FK to the table `ut_map_external_source_users`. This is the MEFE user Id for the default assignee for the role \"landlord\"' after `description` , 
		ADD COLUMN `landlord_default_assignee` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'A FK to the table `ut_map_external_source_users`. This is the MEFE user Id for the default assignee for the role \"management company\"' after `mgt_cny_default_assignee` , 
		ADD COLUMN `tenant_default_assignee` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'A FK to the table `ut_map_external_source_users`. This is the MEFE user Id for the default assignee for the role \"tenant\"' after `landlord_default_assignee` , 
		ADD COLUMN `agent_default_assignee` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'A FK to the table `ut_map_external_source_users`. This is the MEFE user Id for the default assignee for the role \"Agent\"' after `tenant_default_assignee` , 
		ADD UNIQUE KEY `create_api_request_id`(`create_api_request_id`) , 
		ADD UNIQUE KEY `edit_api_request_id`(`edit_api_request_id`) , 
		ADD KEY `ext_property_level_1_country_code`(`country_code`) , 
		ADD KEY `ext_property_level_1_default_assignee_agent`(`agent_default_assignee`) , 
		ADD KEY `ext_property_level_1_default_assignee_landlord`(`landlord_default_assignee`) , 
		ADD KEY `ext_property_level_1_default_assignee_mgt_cny`(`mgt_cny_default_assignee`) , 
		ADD KEY `ext_property_level_1_default_assignee_tenant`(`tenant_default_assignee`) , 
		DROP FOREIGN KEY `property_level_1_area`  , 
		DROP FOREIGN KEY `property_level_1_created_by`  , 
		DROP FOREIGN KEY `property_level_1_updated_by`  , 
		DROP FOREIGN KEY `property_unit_type`  ;
	ALTER TABLE `external_property_level_1_buildings`
		ADD CONSTRAINT `ext_property_level_1_area` 
		FOREIGN KEY (`area_id`) REFERENCES `external_property_groups_areas` (`id_area`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `ext_property_level_1_country_code` 
		FOREIGN KEY (`country_code`) REFERENCES `property_groups_countries` (`country_code`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `ext_property_level_1_created_by` 
		FOREIGN KEY (`created_by_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `ext_property_level_1_default_assignee_agent` 
		FOREIGN KEY (`agent_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `ext_property_level_1_default_assignee_landlord` 
		FOREIGN KEY (`landlord_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `ext_property_level_1_default_assignee_mgt_cny` 
		FOREIGN KEY (`mgt_cny_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `ext_property_level_1_default_assignee_tenant` 
		FOREIGN KEY (`tenant_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `ext_property_level_1_updated_by` 
		FOREIGN KEY (`updated_by_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `ext_property_unit_type` 
		FOREIGN KEY (`unee_t_unit_type`) REFERENCES `ut_unit_types` (`designation`) ON UPDATE CASCADE ;


	/* Alter table in target */
	ALTER TABLE `external_property_level_2_units` 
		ADD COLUMN `create_api_request_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The Unique ID that identifies the API request to create this' after `system_id_unit` , 
		ADD COLUMN `edit_api_request_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The Unique ID that identifies the API request to edit this' after `create_api_request_id` , 
		CHANGE `external_id` `external_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The id of the record in an external system' after `edit_api_request_id` , 
		ADD COLUMN `is_update_on_duplicate_key` tinyint(1)   NULL COMMENT '1 if this was a ON DUPLICATE KEY UPDATE event' after `update_method` , 
		CHANGE `activated_by_id` `activated_by_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The MEFE ID of the user who marked this unit as Active' after `is_update_on_duplicate_key` , 
		ADD COLUMN `mgt_cny_default_assignee` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'A FK to the table `ut_map_external_source_users`. This is the MEFE user Id for the default assignee for the role \"Management Company\"' after `description` , 
		ADD COLUMN `landlord_default_assignee` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'A FK to the table `ut_map_external_source_users`. This is the MEFE user Id for the default assignee for the role \"landlord\"' after `mgt_cny_default_assignee` , 
		ADD COLUMN `tenant_default_assignee` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'A FK to the table `ut_map_external_source_users`. This is the MEFE user Id for the default assignee for the role \"Tenant\"' after `landlord_default_assignee` , 
		ADD COLUMN `agent_default_assignee` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'A FK to the table `ut_map_external_source_users`. This is the MEFE user Id for the default assignee for the role \"Agent\"' after `tenant_default_assignee` , 
		ADD UNIQUE KEY `create_api_request_id`(`create_api_request_id`) , 
		ADD UNIQUE KEY `edit_api_request_id`(`edit_api_request_id`) , 
		ADD KEY `ext_property_level_2_default_assignee_agent`(`agent_default_assignee`) , 
		ADD KEY `ext_property_level_2_default_assignee_landlord`(`landlord_default_assignee`) , 
		ADD KEY `ext_property_level_2_default_assignee_mgt_cny`(`mgt_cny_default_assignee`) , 
		ADD KEY `ext_property_level_2_default_assignee_tenant`(`tenant_default_assignee`) , 
		DROP FOREIGN KEY `property_level_2_created_by`  , 
		DROP FOREIGN KEY `property_level_2_property_level_1`  , 
		DROP FOREIGN KEY `property_level_2_unit_type`  , 
		DROP FOREIGN KEY `property_level_2_updated_by`  ;
	ALTER TABLE `external_property_level_2_units`
		ADD CONSTRAINT `ext_property_level_2_created_by` 
		FOREIGN KEY (`created_by_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `ext_property_level_2_default_assignee_agent` 
		FOREIGN KEY (`agent_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `ext_property_level_2_default_assignee_landlord` 
		FOREIGN KEY (`landlord_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `ext_property_level_2_default_assignee_mgt_cny` 
		FOREIGN KEY (`mgt_cny_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `ext_property_level_2_default_assignee_tenant` 
		FOREIGN KEY (`tenant_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `ext_property_level_2_property_level_1` 
		FOREIGN KEY (`building_system_id`) REFERENCES `external_property_level_1_buildings` (`id_building`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `ext_property_level_2_unit_type` 
		FOREIGN KEY (`unee_t_unit_type`) REFERENCES `ut_unit_types` (`designation`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `ext_property_level_2_updated_by` 
		FOREIGN KEY (`updated_by_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE ;


	/* Alter table in target */
	ALTER TABLE `external_property_level_3_rooms` 
		ADD COLUMN `create_api_request_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The Unique ID that identifies the API request to create this' after `system_id_room` , 
		ADD COLUMN `edit_api_request_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The Unique ID that identifies the API request to edit this' after `create_api_request_id` , 
		CHANGE `external_id` `external_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The id of the record in an external system' after `edit_api_request_id` , 
		ADD COLUMN `is_update_on_duplicate_key` tinyint(1)   NULL COMMENT '1 if this was a ON DUPLICATE KEY UPDATE event' after `update_method` , 
		CHANGE `is_obsolete` `is_obsolete` tinyint(1)   NULL DEFAULT 0 COMMENT 'Is this an obsolete record' after `is_update_on_duplicate_key` , 
		ADD COLUMN `mgt_cny_default_assignee` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'A FK to the table `ut_map_external_source_users`. This is the MEFE user Id for the default assignee for the role \"Management Company\"' after `room_description` , 
		ADD COLUMN `landlord_default_assignee` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'A FK to the table `ut_map_external_source_users`. This is the MEFE user Id for the default assignee for the role \"landlord\"' after `mgt_cny_default_assignee` , 
		ADD COLUMN `tenant_default_assignee` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'A FK to the table `ut_map_external_source_users`. This is the MEFE user Id for the default assignee for the role \"Tenant\"' after `landlord_default_assignee` , 
		ADD COLUMN `agent_default_assignee` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'A FK to the table `ut_map_external_source_users`. This is the MEFE user Id for the default assignee for the role \"Agent\"' after `tenant_default_assignee` , 
		ADD UNIQUE KEY `create_api_request_id`(`create_api_request_id`) , 
		ADD UNIQUE KEY `edit_api_request_id`(`edit_api_request_id`) , 
		ADD KEY `ext_property_level_3_default_assignee_agent`(`agent_default_assignee`) , 
		ADD KEY `ext_property_level_3_default_assignee_landlord`(`landlord_default_assignee`) , 
		ADD KEY `ext_property_level_3_default_assignee_mgt_cny`(`mgt_cny_default_assignee`) , 
		ADD KEY `ext_property_level_3_default_assignee_tenant`(`tenant_default_assignee`) , 
		DROP FOREIGN KEY `property_level_3_created_by_id`  , 
		DROP FOREIGN KEY `property_level_3_property_level_2`  , 
		DROP FOREIGN KEY `property_level_3_unit_type`  , 
		DROP FOREIGN KEY `property_level_3_updated_by_id`  ;
	ALTER TABLE `external_property_level_3_rooms`
		ADD CONSTRAINT `ext_property_level_3_created_by_id` 
		FOREIGN KEY (`created_by_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `ext_property_level_3_default_assignee_agent` 
		FOREIGN KEY (`agent_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `ext_property_level_3_default_assignee_landlord` 
		FOREIGN KEY (`landlord_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `ext_property_level_3_default_assignee_mgt_cny` 
		FOREIGN KEY (`mgt_cny_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `ext_property_level_3_default_assignee_tenant` 
		FOREIGN KEY (`tenant_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `ext_property_level_3_property_level_2` 
		FOREIGN KEY (`system_id_unit`) REFERENCES `external_property_level_2_units` (`system_id_unit`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `ext_property_level_3_unit_type` 
		FOREIGN KEY (`unee_t_unit_type`) REFERENCES `ut_unit_types` (`designation`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `ext_property_level_3_updated_by_id` 
		FOREIGN KEY (`updated_by_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE ;


	/* Alter table in target */
	ALTER TABLE `persons` 
		ADD COLUMN `create_api_request_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The Unique ID that identifies the API request to create this' after `id_person` , 
		ADD COLUMN `edit_api_request_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The Unique ID that identifies the API request to edit this' after `create_api_request_id` , 
		CHANGE `external_id` `external_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The id of the record in an external system' after `edit_api_request_id` , 
		ADD COLUMN `is_update_on_duplicate_key` tinyint(1)   NULL COMMENT '1 if this was a ON DUPLICATE KEY UPDATE event' after `update_method` , 
		CHANGE `organization_id` `organization_id` int(11) unsigned   NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record' after `is_update_on_duplicate_key` , 
		ADD UNIQUE KEY `create_api_request_id`(`create_api_request_id`) , 
		ADD UNIQUE KEY `edit_api_request_id`(`edit_api_request_id`) ;

	/* Alter table in target */
	ALTER TABLE `property_groups_areas` 
		ADD COLUMN `create_api_request_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The Unique ID that identifies the API request to create this' after `id_area` , 
		ADD COLUMN `edit_api_request_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The Unique ID that identifies the API request to edit this' after `create_api_request_id` , 
		CHANGE `external_id` `external_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The id of the record in an external system' after `edit_api_request_id` , 
		ADD COLUMN `is_update_on_duplicate_key` tinyint(1)   NULL COMMENT '1 if this was a ON DUPLICATE KEY UPDATE event' after `update_method` , 
		CHANGE `is_creation_needed_in_unee_t` `is_creation_needed_in_unee_t` tinyint(1)   NULL DEFAULT 1 COMMENT '1 if we need this object in Unee-T' after `is_update_on_duplicate_key` , 
		ADD COLUMN `mgt_cny_default_assignee` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'A FK to the table `ut_map_external_source_users`. This is the MEFE user Id for the default assignee for the role \"Management Company\"' after `area_definition` , 
		ADD COLUMN `landlord_default_assignee` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'A FK to the table `ut_map_external_source_users`. This is the MEFE user Id for the default assignee for the role \"landlord\"' after `mgt_cny_default_assignee` , 
		ADD COLUMN `tenant_default_assignee` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'A FK to the table `ut_map_external_source_users`. This is the MEFE user Id for the default assignee for the role \"Tenant\"' after `landlord_default_assignee` , 
		ADD COLUMN `agent_default_assignee` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'A FK to the table `ut_map_external_source_users`. This is the MEFE user Id for the default assignee for the role \"Agent\"' after `tenant_default_assignee` , 
		ADD KEY `area_default_assignee_agent`(`agent_default_assignee`) , 
		ADD KEY `area_default_assignee_landlord`(`landlord_default_assignee`) , 
		ADD KEY `area_default_assignee_mgt_cny`(`mgt_cny_default_assignee`) , 
		ADD KEY `area_default_assignee_tenant`(`tenant_default_assignee`) , 
		ADD KEY `areas_country_code`(`country_code`) , 
		ADD UNIQUE KEY `create_api_request_id`(`create_api_request_id`) , 
		ADD UNIQUE KEY `edit_api_request_id`(`edit_api_request_id`) ;
	ALTER TABLE `property_groups_areas`
		ADD CONSTRAINT `area_default_assignee_agent` 
		FOREIGN KEY (`agent_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `area_default_assignee_landlord` 
		FOREIGN KEY (`landlord_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `area_default_assignee_mgt_cny` 
		FOREIGN KEY (`mgt_cny_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `area_default_assignee_tenant` 
		FOREIGN KEY (`tenant_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `areas_country_code` 
		FOREIGN KEY (`country_code`) REFERENCES `property_groups_countries` (`country_code`) ON UPDATE CASCADE ;


	/* Alter table in target */
	ALTER TABLE `property_level_1_buildings` 
		ADD COLUMN `create_api_request_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The Unique ID that identifies the API request to create this' after `id_building` , 
		ADD COLUMN `edit_api_request_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The Unique ID that identifies the API request to edit this' after `create_api_request_id` , 
		CHANGE `external_id` `external_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The id of the record in an external system' after `edit_api_request_id` , 
		ADD COLUMN `is_update_on_duplicate_key` tinyint(1)   NULL COMMENT '1 if this was a ON DUPLICATE KEY UPDATE event' after `update_method` , 
		CHANGE `organization_id` `organization_id` int(11) unsigned   NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record' after `is_update_on_duplicate_key` , 
		ADD COLUMN `mgt_cny_default_assignee` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'A FK to the table `ut_map_external_source_users`. This is the MEFE user Id for the default assignee for the role \"Management Company\"' after `description` , 
		ADD COLUMN `landlord_default_assignee` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'A FK to the table `ut_map_external_source_users`. This is the MEFE user Id for the default assignee for the role \"landlord\"' after `mgt_cny_default_assignee` , 
		ADD COLUMN `tenant_default_assignee` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'A FK to the table `ut_map_external_source_users`. This is the MEFE user Id for the default assignee for the role \"Tenant\"' after `landlord_default_assignee` , 
		ADD COLUMN `agent_default_assignee` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'A FK to the table `ut_map_external_source_users`. This is the MEFE user Id for the default assignee for the role \"Agent\"' after `tenant_default_assignee` , 
		ADD UNIQUE KEY `create_api_request_id`(`create_api_request_id`) , 
		ADD UNIQUE KEY `edit_api_request_id`(`edit_api_request_id`) , 
		ADD KEY `property_level_1_country_code`(`country_code`) , 
		ADD KEY `property_level_1_default_assignee_agent`(`agent_default_assignee`) , 
		ADD KEY `property_level_1_default_assignee_landlord`(`landlord_default_assignee`) , 
		ADD KEY `property_level_1_default_assignee_mgt_cny`(`mgt_cny_default_assignee`) , 
		ADD KEY `property_level_1_default_assignee_tenant`(`tenant_default_assignee`) , 
		DROP FOREIGN KEY `building_id_area_id`  ;
	ALTER TABLE `property_level_1_buildings`
		ADD CONSTRAINT `property_level_1__area_id` 
		FOREIGN KEY (`area_id`) REFERENCES `property_groups_areas` (`id_area`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `property_level_1_country_code` 
		FOREIGN KEY (`country_code`) REFERENCES `property_groups_countries` (`country_code`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `property_level_1_default_assignee_agent` 
		FOREIGN KEY (`agent_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `property_level_1_default_assignee_landlord` 
		FOREIGN KEY (`landlord_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `property_level_1_default_assignee_mgt_cny` 
		FOREIGN KEY (`mgt_cny_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `property_level_1_default_assignee_tenant` 
		FOREIGN KEY (`tenant_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE ;


	/* Alter table in target */
	ALTER TABLE `property_level_2_units` 
		ADD COLUMN `create_api_request_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The Unique ID that identifies the API request to create this' after `system_id_unit` , 
		ADD COLUMN `edit_api_request_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The Unique ID that identifies the API request to edit this' after `create_api_request_id` , 
		CHANGE `external_id` `external_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The id of the record in an external system' after `edit_api_request_id` , 
		ADD COLUMN `is_update_on_duplicate_key` tinyint(1)   NULL COMMENT '1 if this was a ON DUPLICATE KEY UPDATE event' after `update_method` , 
		CHANGE `organization_id` `organization_id` int(11) unsigned   NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record' after `is_update_on_duplicate_key` , 
		ADD COLUMN `mgt_cny_default_assignee` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'A FK to the table `ut_map_external_source_users`. This is the MEFE user Id for the default assignee for the role \"Management Company\"' after `description` , 
		ADD COLUMN `landlord_default_assignee` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'A FK to the table `ut_map_external_source_users`. This is the MEFE user Id for the default assignee for the role \"landlord\"' after `mgt_cny_default_assignee` , 
		ADD COLUMN `tenant_default_assignee` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'A FK to the table `ut_map_external_source_users`. This is the MEFE user Id for the default assignee for the role \"Tenant\"' after `landlord_default_assignee` , 
		ADD COLUMN `agent_default_assignee` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'A FK to the table `ut_map_external_source_users`. This is the MEFE user Id for the default assignee for the role \"Agent\"' after `tenant_default_assignee` , 
		ADD UNIQUE KEY `create_api_request_id`(`create_api_request_id`) , 
		ADD UNIQUE KEY `edit_api_request_id`(`edit_api_request_id`) , 
		ADD KEY `property_level_2_default_assignee_agent`(`agent_default_assignee`) , 
		ADD KEY `property_level_2_default_assignee_landlord`(`landlord_default_assignee`) , 
		ADD KEY `property_level_2_default_assignee_mgt_cny`(`mgt_cny_default_assignee`) , 
		ADD KEY `property_level_2_default_assignee_tenant`(`tenant_default_assignee`) , 
		DROP FOREIGN KEY `unit_building_id`  ;
	ALTER TABLE `property_level_2_units`
		ADD CONSTRAINT `property_level_2_building_id` 
		FOREIGN KEY (`building_system_id`) REFERENCES `property_level_1_buildings` (`id_building`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `property_level_2_default_assignee_agent` 
		FOREIGN KEY (`agent_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `property_level_2_default_assignee_landlord` 
		FOREIGN KEY (`landlord_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `property_level_2_default_assignee_mgt_cny` 
		FOREIGN KEY (`mgt_cny_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `property_level_2_default_assignee_tenant` 
		FOREIGN KEY (`tenant_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE ;


	/* Alter table in target */
	ALTER TABLE `property_level_3_rooms` 
		ADD COLUMN `create_api_request_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The Unique ID that identifies the API request to create this' after `system_id_room` , 
		ADD COLUMN `edit_api_request_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The Unique ID that identifies the API request to edit this' after `create_api_request_id` , 
		CHANGE `external_id` `external_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The id of the record in an external system' after `edit_api_request_id` , 
		ADD COLUMN `is_update_on_duplicate_key` tinyint(1)   NULL COMMENT '1 if this was a ON DUPLICATE KEY UPDATE event' after `update_method` , 
		CHANGE `organization_id` `organization_id` int(11) unsigned   NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record' after `is_update_on_duplicate_key` , 
		ADD COLUMN `mgt_cny_default_assignee` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'A FK to the table `ut_map_external_source_users`. This is the MEFE user Id for the default assignee for the role \"Management Company\"' after `room_description` , 
		ADD COLUMN `landlord_default_assignee` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'A FK to the table `ut_map_external_source_users`. This is the MEFE user Id for the default assignee for the role \"landlord\"' after `mgt_cny_default_assignee` , 
		ADD COLUMN `tenant_default_assignee` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'A FK to the table `ut_map_external_source_users`. This is the MEFE user Id for the default assignee for the role \"Tenant\"' after `landlord_default_assignee` , 
		ADD COLUMN `agent_default_assignee` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'A FK to the table `ut_map_external_source_users`. This is the MEFE user Id for the default assignee for the role \"Agent\"' after `tenant_default_assignee` , 
		ADD UNIQUE KEY `create_api_request_id`(`create_api_request_id`) , 
		ADD UNIQUE KEY `edit_api_request_id`(`edit_api_request_id`) , 
		ADD KEY `property_level_3_default_assignee_agent`(`agent_default_assignee`) , 
		ADD KEY `property_level_3_default_assignee_landlord`(`landlord_default_assignee`) , 
		ADD KEY `property_level_3_default_assignee_mgt_cny`(`mgt_cny_default_assignee`) , 
		ADD KEY `property_level_3_default_assignee_tenant`(`tenant_default_assignee`) ;
	ALTER TABLE `property_level_3_rooms`
		ADD CONSTRAINT `property_level_3_default_assignee_agent` 
		FOREIGN KEY (`agent_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `property_level_3_default_assignee_landlord` 
		FOREIGN KEY (`landlord_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `property_level_3_default_assignee_mgt_cny` 
		FOREIGN KEY (`mgt_cny_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `property_level_3_default_assignee_tenant` 
		FOREIGN KEY (`tenant_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE ;


	/* Alter table in target */
	ALTER TABLE `retry_assign_user_to_units_list` 
		ADD COLUMN `create_api_request_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The Unique ID that identifies the API request to create this' after `id_map_user_unit_permissions` , 
		ADD COLUMN `edit_api_request_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The Unique ID that identifies the API request to edit this' after `create_api_request_id` , 
		CHANGE `syst_created_datetime` `syst_created_datetime` timestamp   NULL COMMENT 'When was this record created?' after `edit_api_request_id` , 
		CHANGE `creation_method` `creation_method` varchar(255)  COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'How was this record created' after `created_by_id` , 
		ADD UNIQUE KEY `create_api_request_id`(`create_api_request_id`) , 
		ADD UNIQUE KEY `edit_api_request_id`(`edit_api_request_id`) ;

	/* Alter table in target */
	ALTER TABLE `retry_create_units_list_units` 
		ADD COLUMN `create_api_request_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The Unique ID that identifies the API request to create this' after `unit_creation_request_id` , 
		ADD COLUMN `edit_api_request_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The Unique ID that identifies the API request to edit this' after `create_api_request_id` , 
		CHANGE `created_by_id` `created_by_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The MEFE ID of the user who created this record' after `edit_api_request_id` , 
		CHANGE `creation_method` `creation_method` varchar(255)  COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'How was this record created' after `created_by_id` , 
		ADD UNIQUE KEY `create_api_request_id`(`create_api_request_id`) , 
		ADD UNIQUE KEY `edit_api_request_id`(`edit_api_request_id`) ;

	/* Alter table in target */
	ALTER TABLE `uneet_enterprise_organizations` 
		ADD COLUMN `default_sot_system` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL DEFAULT 'system' COMMENT 'The Default source of truth for that organization' after `description` , 
		ADD COLUMN `default_sot_persons` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL DEFAULT 'persons' COMMENT 'The Default source of truth for that organization for the person records' after `default_sot_system` , 
		ADD COLUMN `default_sot_areas` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL DEFAULT 'areas' COMMENT 'The Default source of truth for that organization for the area records' after `default_sot_persons` , 
		ADD COLUMN `default_sot_properties` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL DEFAULT 'properties' COMMENT 'The Default source of truth for that organization for the properties records' after `default_sot_areas` , 
		ADD COLUMN `default_area` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The MEFE ID for the default area for properties created by this organization' after `default_sot_properties` , 
		ADD COLUMN `default_building` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The MEFE ID for the default building for properties created by this organization' after `default_area` , 
		ADD COLUMN `default_unit` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The MEFE ID for the default unit for properties created by this organization' after `default_building` , 
		ADD KEY `organization_default_area_must_exist`(`default_area`) , 
		ADD KEY `organization_default_building_must_exist`(`default_building`) , 
		ADD KEY `organization_default_unit_must_exist`(`default_unit`) ;
	ALTER TABLE `uneet_enterprise_organizations`
		ADD CONSTRAINT `organization_default_area_must_exist` 
		FOREIGN KEY (`default_area`) REFERENCES `ut_map_external_source_units` (`unee_t_mefe_unit_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `organization_default_building_must_exist` 
		FOREIGN KEY (`default_building`) REFERENCES `ut_map_external_source_units` (`unee_t_mefe_unit_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `organization_default_unit_must_exist` 
		FOREIGN KEY (`default_unit`) REFERENCES `ut_map_external_source_units` (`unee_t_mefe_unit_id`) ON UPDATE CASCADE ;

	/* Alter table in target */
		ALTER TABLE `ut_map_external_source_units` 
			ADD COLUMN `create_api_request_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The Unique ID that identifies the API request to create this' after `id_map` , 
			ADD COLUMN `edit_api_request_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The Unique ID that identifies the API request to edit this' after `create_api_request_id` , 
			CHANGE `syst_created_datetime` `syst_created_datetime` timestamp   NULL COMMENT 'When was this record created?' after `edit_api_request_id` , 
			ADD COLUMN `is_update_on_duplicate_key` tinyint(1)   NULL COMMENT '1 if this was a ON DUPLICATE KEY UPDATE event' after `update_method` , 
			CHANGE `organization_id` `organization_id` int(11) unsigned   NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record' after `is_update_on_duplicate_key` , 
			ADD COLUMN `mefe_area_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The MEFE ID of the area - This is a FK to the table `ut_map_external_source_areas`' after `is_update_needed` , 
			ADD COLUMN `mefe_unit_id_parent` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The MEFE unit ID of the parent (if applicable)' after `mefe_area_id` , 
			CHANGE `unee_t_mefe_unit_id` `unee_t_mefe_unit_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The MEFE ID of the unit - a FK to the Mongo Collection unitMetaData' after `mefe_unit_id_parent` , 
			ADD UNIQUE KEY `create_api_request_id`(`create_api_request_id`) , 
			ADD UNIQUE KEY `edit_api_request_id`(`edit_api_request_id`) , 
			ADD KEY `unit_latest_job_id`(`edit_api_request_id`) , 
			ADD KEY `unit_mefe_area_id_must_exist`(`mefe_area_id`) , 
			ADD KEY `unit_mefe_unit_id_parent_must_exist`(`mefe_unit_id_parent`) ;
		ALTER TABLE `ut_map_external_source_units`
			ADD CONSTRAINT `unit_mefe_area_id_must_exist` 
			FOREIGN KEY (`mefe_area_id`) REFERENCES `ut_map_external_source_areas` (`mefe_area_id`) ON UPDATE CASCADE , 
			ADD CONSTRAINT `unit_mefe_unit_id_parent_must_exist` 
			FOREIGN KEY (`mefe_unit_id_parent`) REFERENCES `ut_map_external_source_units` (`unee_t_mefe_unit_id`) ON UPDATE CASCADE ;

	/* Alter table in target */
	ALTER TABLE `ut_map_external_source_users` 
		ADD COLUMN `create_api_request_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The Unique ID that identifies the API request to create this' after `id_map` , 
		ADD COLUMN `edit_api_request_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The Unique ID that identifies the API request to edit this' after `create_api_request_id` , 
		CHANGE `syst_created_datetime` `syst_created_datetime` timestamp   NULL COMMENT 'When was this record created?' after `edit_api_request_id` , 
		ADD COLUMN `is_update_on_duplicate_key` tinyint(1)   NULL COMMENT '1 if this was a ON DUPLICATE KEY UPDATE event' after `update_method` , 
		CHANGE `organization_id` `organization_id` int(11) unsigned   NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record' after `is_update_on_duplicate_key` , 
		ADD COLUMN `mefe_user_id_parent` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The MEFE user ID of the parent/supervisor for that user (if applicable)' after `person_id` , 
		CHANGE `unee_t_mefe_user_id` `unee_t_mefe_user_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The MEFE ID of the user - a FK to the Mongo Collection `users`' after `mefe_user_id_parent` , 
		ADD UNIQUE KEY `create_api_request_id`(`create_api_request_id`) , 
		ADD UNIQUE KEY `edit_api_request_id`(`edit_api_request_id`) , 
		ADD KEY `unee_t_mefe_user_api_key`(`unee_t_mefe_user_api_key`) , 
		ADD KEY `user_latest_job_id`(`edit_api_request_id`) , 
		ADD KEY `user_parent_mefe_id_must_exist`(`mefe_user_id_parent`) ;
	ALTER TABLE `ut_map_external_source_users`
		ADD CONSTRAINT `user_parent_mefe_id_must_exist` 
		FOREIGN KEY (`mefe_user_id_parent`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE ;


	/* Alter table in target */
	ALTER TABLE `ut_map_user_permissions_unit_all` 
		ADD COLUMN `create_api_request_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The Unique ID that identifies the API request to create this' after `id_map_user_unit_permissions` , 
		ADD COLUMN `edit_api_request_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The Unique ID that identifies the API request to edit this' after `create_api_request_id` , 
		CHANGE `syst_created_datetime` `syst_created_datetime` timestamp   NULL COMMENT 'When was this record created?' after `edit_api_request_id` , 
		ADD COLUMN `is_update_on_duplicate_key` tinyint(1)   NULL COMMENT '1 if this was a ON DUPLICATE KEY UPDATE event' after `update_method` , 
		CHANGE `organization_id` `organization_id` int(11) unsigned   NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record' after `is_update_on_duplicate_key` , 
		ADD UNIQUE KEY `create_api_request_id`(`create_api_request_id`) , 
		ADD UNIQUE KEY `edit_api_request_id`(`edit_api_request_id`) ;

	/* Alter table in target */
	ALTER TABLE `ut_map_user_permissions_unit_level_1` 
		ADD COLUMN `create_api_request_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The Unique ID that identifies the API request to create this' after `id` , 
		ADD COLUMN `edit_api_request_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The Unique ID that identifies the API request to edit this' after `create_api_request_id` , 
		CHANGE `syst_created_datetime` `syst_created_datetime` timestamp   NULL COMMENT 'When was this record created?' after `edit_api_request_id` , 
		ADD COLUMN `is_update_on_duplicate_key` tinyint(1)   NULL COMMENT '1 if this was a ON DUPLICATE KEY UPDATE event' after `update_method` , 
		CHANGE `organization_id` `organization_id` int(11) unsigned   NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record' after `is_update_on_duplicate_key` , 
		ADD UNIQUE KEY `create_api_request_id`(`create_api_request_id`) , 
		ADD UNIQUE KEY `edit_api_request_id`(`edit_api_request_id`) ;

	/* Alter table in target */
	ALTER TABLE `ut_map_user_permissions_unit_level_2` 
		ADD COLUMN `create_api_request_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The Unique ID that identifies the API request to create this' after `id` , 
		ADD COLUMN `edit_api_request_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The Unique ID that identifies the API request to edit this' after `create_api_request_id` , 
		CHANGE `syst_created_datetime` `syst_created_datetime` timestamp   NULL COMMENT 'When was this record created?' after `edit_api_request_id` , 
		ADD COLUMN `is_update_on_duplicate_key` tinyint(1)   NULL COMMENT '1 if this was a ON DUPLICATE KEY UPDATE event' after `update_method` , 
		CHANGE `organization_id` `organization_id` int(11) unsigned   NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record' after `is_update_on_duplicate_key` , 
		ADD UNIQUE KEY `create_api_request_id`(`create_api_request_id`) , 
		ADD UNIQUE KEY `edit_api_request_id`(`edit_api_request_id`) ;

	/* Alter table in target */
	ALTER TABLE `ut_map_user_permissions_unit_level_3` 
		ADD COLUMN `create_api_request_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The Unique ID that identifies the API request to create this' after `id` , 
		ADD COLUMN `edit_api_request_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The Unique ID that identifies the API request to edit this' after `create_api_request_id` , 
		CHANGE `syst_created_datetime` `syst_created_datetime` timestamp   NULL COMMENT 'When was this record created?' after `edit_api_request_id` , 
		ADD COLUMN `is_update_on_duplicate_key` tinyint(1)   NULL COMMENT '1 if this was a ON DUPLICATE KEY UPDATE event' after `update_method` , 
		CHANGE `organization_id` `organization_id` int(11) unsigned   NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record' after `is_update_on_duplicate_key` , 
		ADD UNIQUE KEY `create_api_request_id`(`create_api_request_id`) , 
		ADD UNIQUE KEY `edit_api_request_id`(`edit_api_request_id`) ; 

	/* The foreign keys that were dropped are now re-created*/

	ALTER TABLE `external_persons` 
		ADD CONSTRAINT `person_created_by_id` 
		FOREIGN KEY (`created_by_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `person_gender` 
		FOREIGN KEY (`gender`) REFERENCES `person_genders` (`id_person_gender`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `person_salutation` 
		FOREIGN KEY (`salutation_id`) REFERENCES `person_salutations` (`id_salutation`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `person_status` 
		FOREIGN KEY (`person_status_id`) REFERENCES `person_statuses` (`id_person_status`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `person_ut_user_type` 
		FOREIGN KEY (`unee_t_user_type_id`) REFERENCES `ut_user_types` (`id_unee_t_user_type`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `peson_udpated_by_id` 
		FOREIGN KEY (`updated_by_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE ;

	ALTER TABLE `persons` 
		ADD CONSTRAINT `person_organization_id` 
		FOREIGN KEY (`organization_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `person_person_salutation` 
		FOREIGN KEY (`salutation_id`) REFERENCES `person_salutations` (`id_salutation`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `person_person_status` 
		FOREIGN KEY (`person_status_id`) REFERENCES `person_statuses` (`id_person_status`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `person_unee-t_user_type` 
		FOREIGN KEY (`unee_t_user_type_id`) REFERENCES `ut_user_types` (`id_unee_t_user_type`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `sot_creation_system_person` 
		FOREIGN KEY (`creation_system_id`) REFERENCES `ut_external_sot_for_unee_t_objects` (`id_external_sot_for_unee_t`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `sot_update_system_person` 
		FOREIGN KEY (`update_system_id`) REFERENCES `ut_external_sot_for_unee_t_objects` (`id_external_sot_for_unee_t`) ON UPDATE CASCADE ;

	ALTER TABLE `property_groups_areas` 
		ADD CONSTRAINT `areas_organization_id` 
		FOREIGN KEY (`organization_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE ;

	ALTER TABLE `property_level_1_buildings` 
		ADD CONSTRAINT `property_level_1_organization_id` 
		FOREIGN KEY (`organization_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `unee_t_valid_unit_type_building` 
		FOREIGN KEY (`unee_t_unit_type`) REFERENCES `ut_unit_types` (`designation`) ON UPDATE CASCADE ;

	ALTER TABLE `property_level_2_units` 
		ADD CONSTRAINT `property_level_2_organization_id` 
		FOREIGN KEY (`organization_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `unee_t_valid_unit_type_unit` 
		FOREIGN KEY (`unee_t_unit_type`) REFERENCES `ut_unit_types` (`designation`) ON UPDATE CASCADE ;

	ALTER TABLE `property_level_3_rooms` 
		ADD CONSTRAINT `property_level_3_organization_id` 
		FOREIGN KEY (`organization_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `room_id_flat_id` 
		FOREIGN KEY (`system_id_unit`) REFERENCES `property_level_2_units` (`system_id_unit`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `room_id_room_type_id` 
		FOREIGN KEY (`room_type_id`) REFERENCES `property_types_level_3_rooms` (`id_room_type`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `unee_t_valid_unit_type_room` 
		FOREIGN KEY (`unee_t_unit_type`) REFERENCES `ut_unit_types` (`designation`) ON UPDATE CASCADE ;

	ALTER TABLE `ut_map_external_source_units` 
		ADD CONSTRAINT `mefe_unit_organization_id` 
		FOREIGN KEY (`organization_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `property_property_type` 
		FOREIGN KEY (`external_property_type_id`) REFERENCES `ut_property_types` (`id_property_type`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `unee_t_valid_unit_type_map_units` 
		FOREIGN KEY (`unee_t_unit_type`) REFERENCES `ut_unit_types` (`designation`) ON UPDATE CASCADE ;

	ALTER TABLE `ut_map_external_source_users` 
		ADD CONSTRAINT `mefe_user_organization_id` 
		FOREIGN KEY (`organization_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `unee-t_user_person` 
		FOREIGN KEY (`person_id`) REFERENCES `persons` (`id_person`) ON UPDATE CASCADE ;

	ALTER TABLE `ut_map_user_permissions_unit_all` 
		ADD CONSTRAINT `map_mefe_unit_mefe_user_all_organization_id` 
		FOREIGN KEY (`organization_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `mefe_unit_must_exist_here` 
		FOREIGN KEY (`unee_t_unit_id`) REFERENCES `ut_map_external_source_units` (`unee_t_mefe_unit_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `mefe_user_must_exist_here` 
		FOREIGN KEY (`unee_t_mefe_id`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE ;

	ALTER TABLE `ut_map_user_permissions_unit_level_1` 
		ADD CONSTRAINT `map_mefe_unit_mefe_user_level_1_organization_id` 
		FOREIGN KEY (`organization_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `unit_level_1_mefe_unit_id_must_exist` 
		FOREIGN KEY (`unee_t_unit_id`) REFERENCES `ut_map_external_source_units` (`unee_t_mefe_unit_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `unit_level_1_mefe_user_id_must_exist` 
		FOREIGN KEY (`unee_t_mefe_id`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE ;

	ALTER TABLE `ut_map_user_permissions_unit_level_2` 
		ADD CONSTRAINT `map_mefe_unit_mefe_user_level_2_organization_id` 
		FOREIGN KEY (`organization_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `unit_level_2_mefe_unit_id_must_exist` 
		FOREIGN KEY (`unee_t_unit_id`) REFERENCES `ut_map_external_source_units` (`unee_t_mefe_unit_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `unit_level_2_mefe_user_id_must_exist` 
		FOREIGN KEY (`unee_t_mefe_id`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE ;

	ALTER TABLE `ut_map_user_permissions_unit_level_3` 
		ADD CONSTRAINT `map_mefe_unit_mefe_user_level_3_organization_id` 
		FOREIGN KEY (`organization_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `map_user_permissions_unit_level_3_room_id` 
		FOREIGN KEY (`system_id_level_3`) REFERENCES `property_level_3_rooms` (`system_id_room`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `unit_level_3_mefe_unit_id_must_exist` 
		FOREIGN KEY (`unee_t_unit_id`) REFERENCES `ut_map_external_source_units` (`unee_t_mefe_unit_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `unit_level_3_mefe_user_id_must_exist` 
		FOREIGN KEY (`unee_t_mefe_id`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE ;

	/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;

# Create the mapping table `ut_map_external_source_areas` to store info on areas

	CREATE TABLE `ut_map_external_source_areas`(
		`id_map_source_area` int(11) unsigned NOT NULL  auto_increment COMMENT 'Id in this table' , 
		`create_api_request_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'The Unique ID that identifies the API request to create this' , 
		`edit_api_request_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'The Unique ID that identifies the API request to edit this' , 
		`syst_created_datetime` timestamp NULL  COMMENT 'When was this record created?' , 
		`creation_system_id` int(11) NULL  COMMENT 'What is the id of the sytem that was used for the creation of the record?' , 
		`created_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'The MEFE ID of the user who created this record' , 
		`creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'How was this record created' , 
		`syst_updated_datetime` timestamp NULL  COMMENT 'When was this record last updated?' , 
		`update_system_id` int(11) NULL  COMMENT 'What is the id of the sytem that was used for the last update the record?' , 
		`updated_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'The MEFE ID of the user who updated this record' , 
		`update_method` varchar(255) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'How was this record updated?' , 
		`is_update_on_duplicate_key` tinyint(1) NULL  COMMENT '1 if this was a ON DUPLICATE KEY UPDATE event' , 
		`organization_id` int(11) unsigned NOT NULL  COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record' , 
		`is_obsolete` tinyint(1) NULL  DEFAULT 0 COMMENT '1 if we need to remove this unit from the mapping' , 
		`is_update_needed` tinyint(1) NULL  DEFAULT 0 COMMENT '1 if we need to propagate that to downstream systens' , 
		`mefe_area_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'The MEFE ID for the Area' , 
		`uneet_created_datetime` timestamp NULL  COMMENT 'Timestamp when the unit was created' , 
		`is_mefe_api_success` tinyint(1) NULL  COMMENT '1 if this is a success, 0 if not' , 
		`mefe_api_error_message` text COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'The error message from the MEFE API (if applicable)' , 
		`is_unee_t_created_by_me` tinyint(1) NULL  DEFAULT 0 COMMENT '1 if this user has been created by this or 0 if the user was existing in Unee-T before' , 
		`uneet_area_name` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL  COMMENT 'The name of the unit in the BZ database' , 
		`new_record_id` int(11) NOT NULL  COMMENT 'The id of the record in the table `property_level_xxx`. This is used in combination with `external_property_type_id` to get more information about the unit' , 
		`external_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL  COMMENT 'The ID in the table which is the source of truth for the Unee-T unit information' , 
		`external_system` varchar(100) COLLATE utf8mb4_unicode_520_ci NOT NULL  COMMENT 'The name of the external source of truth' , 
		`table_in_external_system` varchar(100) COLLATE utf8mb4_unicode_520_ci NOT NULL  COMMENT 'The name of the table in the extrenal source of truth where the info is stored' , 
		PRIMARY KEY (`organization_id`,`external_id`,`external_system`,`table_in_external_system`) , 
		UNIQUE KEY `id_map_source_area`(`id_map_source_area`) , 
		UNIQUE KEY `latest_job_id_is_unique`(`edit_api_request_id`) , 
		UNIQUE KEY `area_mefe_id_is_unique`(`mefe_area_id`) , 
		UNIQUE KEY `create_api_request_id`(`create_api_request_id`) , 
		UNIQUE KEY `edit_api_request_id`(`edit_api_request_id`) , 
		CONSTRAINT `map_external_source_areas_organization_must_exist` 
		FOREIGN KEY (`organization_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE 
	) ENGINE=InnoDB DEFAULT CHARSET='utf8mb4' COLLATE='utf8mb4_unicode_520_ci';

# Create the tables we need for the UNTE API

	# Table to create a new unit.

		CREATE TABLE `unte_api_add_unit`(
			`id_unte_api_add_unit` int(11) unsigned NOT NULL  auto_increment COMMENT 'Unique ID in this table' , 
			`request_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL  COMMENT 'The ID of the request that was sent to the UNTE' , 
			`external_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL  COMMENT 'The id of the record in an external system' , 
			`external_system_id` varchar(100) COLLATE utf8mb4_unicode_520_ci NOT NULL  DEFAULT 'unknown' COMMENT 'The id of the system which provides the external_system_id' , 
			`external_table` varchar(100) COLLATE utf8mb4_unicode_520_ci NOT NULL  DEFAULT 'unknown' COMMENT 'The table in the external system where this record is stored' , 
			`syst_created_datetime` timestamp NULL  COMMENT 'When was this record created?' , 
			`creation_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'What is the id of the system that was used for the creation of the record?' , 
			`organization_key` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL  COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record' , 
			`creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'How was this record created' , 
			`syst_updated_datetime` timestamp NULL  COMMENT 'When was this record last updated?' , 
			`update_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'What is the id of the system that was used for the last update the record?' , 
			`updated_by_id` int(11) unsigned NULL  COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record' , 
			`update_method` varchar(255) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'How was this record updated?' , 
			`is_obsolete` tinyint(1) NULL  DEFAULT 0 COMMENT '1 if this record is obsolete' , 
			`order` int(10) NULL  DEFAULT 0 COMMENT 'order in the list' , 
			`area_mefe_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'The MEFE Id of the Area for that property' , 
			`parent_mefe_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'The MEFE Id of the parent for this unit (area, L1, or L2)' , 
			`unee_t_unit_type` varchar(100) COLLATE utf8mb4_unicode_520_ci NOT NULL  COMMENT 'The Unee-T type of unit for this property - this MUST be one of the `designation` in the table `ut_unit_types`' , 
			`designation` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL  COMMENT 'The name of the building' , 
			`tower` varchar(50) COLLATE utf8mb4_unicode_520_ci NOT NULL  DEFAULT '1' COMMENT 'If there is more than 1 building, the id for the unique building. Default is 1.' , 
			`unit_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'The unique id of this unit in the building' , 
			`address_1` varchar(50) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'Address 1' , 
			`address_2` varchar(50) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'Address 2' , 
			`zip_postal_code` varchar(50) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'ZIP or Postal code' , 
			`state` varchar(50) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'The State' , 
			`city` varchar(50) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'The City' , 
			`country_code` varchar(10) COLLATE utf8mb4_unicode_520_ci NOT NULL  COMMENT 'The 2 letter ISO country code (FR, SG, EN, etc...). See table `property_groups_countries`' , 
			`description` text COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'detailed description of the building' , 
			`count_rooms` int(10) NULL  COMMENT 'Number of rooms in the unit' , 
			`surface` int(10) unsigned NULL  COMMENT 'The surface of the unit' , 
			`surface_measurement_unit` varchar(10) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'Either sqm (Square Meters) or sqf (Square Feet)' , 
			`number_of_beds` int(10) NULL  COMMENT 'Number of beds in the room' , 
			`mgt_cny_default_assignee` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL  COMMENT 'A FK to the table `ut_map_external_source_users`. This is the MEFE user Id for the default assignee for the role \"landlord\"' , 
			`landlord_default_assignee` varchar(255) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'A FK to the table `ut_map_external_source_users`. This is the MEFE user Id for the default assignee for the role \"management company\"' , 
			`tenant_default_assignee` varchar(255) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'A FK to the table `ut_map_external_source_users`. This is the MEFE user Id for the default assignee for the role \"tenant\"' , 
			`agent_default_assignee` varchar(255) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'A FK to the table `ut_map_external_source_users`. This is the MEFE user Id for the default assignee for the role \"Agent\"' , 
			`is_creation_needed_in_unee_t` tinyint(1) NULL  DEFAULT 0 COMMENT '1 if we need to create this property as a unit in Unee-T' , 
			`mefe_unit_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'The MEFE ID of the unit - a FK to the Mongo Collection unitMetaData' , 
			`uneet_created_datetime` timestamp NULL  COMMENT 'Timestamp when the unit was created' , 
			`is_api_success` tinyint(1) NULL  COMMENT '1 if this is a success, 0 if not' , 
			`api_error_message` text COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'The error message (if any)' , 
			PRIMARY KEY (`external_id`,`external_system_id`,`external_table`,`organization_key`,`tower`) , 
			UNIQUE KEY `unique_id_unte_api_add_unit`(`id_unte_api_add_unit`) , 
			UNIQUE KEY `unit_creation_unique_request_id`(`request_id`) , 
			KEY `api_add_unit_parent_mefe_id`(`parent_mefe_id`) , 
			KEY `api_add_unit_unit_type`(`unee_t_unit_type`) , 
			KEY `api_add_unit_country_code`(`country_code`) , 
			KEY `api_add_unit_api_key_default_assignee_agent`(`agent_default_assignee`) , 
			KEY `api_add_unit_api_key_default_assignee_landlord`(`landlord_default_assignee`) , 
			KEY `api_add_unit_api_key_default_assignee_mgt_cny`(`mgt_cny_default_assignee`) , 
			KEY `api_add_unit_api_key_default_assignee_tenant`(`tenant_default_assignee`) , 
			KEY `api_add_unit_mefe_id`(`mefe_unit_id`) , 
			KEY `api_add_unit_job_request_id`(`request_id`) , 
			KEY `api_add_unit_organization_key`(`organization_key`) , 
			KEY `api_add_unit_area_mefe_id_must_exist`(`area_mefe_id`) , 
			CONSTRAINT `api_add_unit_api_key_default_assignee_agent_must_exist` 
			FOREIGN KEY (`agent_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_api_key`) ON UPDATE CASCADE , 
			CONSTRAINT `api_add_unit_api_key_default_assignee_landlord_must_exist` 
			FOREIGN KEY (`landlord_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_api_key`) ON UPDATE CASCADE , 
			CONSTRAINT `api_add_unit_api_key_default_assignee_mgt_cny_must_exist` 
			FOREIGN KEY (`mgt_cny_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_api_key`) ON UPDATE CASCADE , 
			CONSTRAINT `api_add_unit_api_key_default_assignee_tenant_must_exist` 
			FOREIGN KEY (`tenant_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_api_key`) ON UPDATE CASCADE , 
			CONSTRAINT `api_add_unit_area_mefe_id_must_exist` 
			FOREIGN KEY (`area_mefe_id`) REFERENCES `ut_map_external_source_areas` (`mefe_area_id`) ON UPDATE CASCADE , 
			CONSTRAINT `api_add_unit_country_code_must_exist` 
			FOREIGN KEY (`country_code`) REFERENCES `property_groups_countries` (`country_code`) ON UPDATE CASCADE , 
			CONSTRAINT `api_add_unit_mefe_id_must_exist` 
			FOREIGN KEY (`mefe_unit_id`) REFERENCES `ut_map_external_source_units` (`unee_t_mefe_unit_id`) ON UPDATE CASCADE , 
			CONSTRAINT `api_add_unit_mefe_id_parent_must_exist` 
			FOREIGN KEY (`parent_mefe_id`) REFERENCES `ut_map_external_source_units` (`unee_t_mefe_unit_id`) ON UPDATE CASCADE , 
			CONSTRAINT `api_add_unit_organization_key_must_exist` 
			FOREIGN KEY (`organization_key`) REFERENCES `unte_api_keys` (`api_key`) ON UPDATE CASCADE , 
			CONSTRAINT `api_add_unit_unit_type_must_exist` 
			FOREIGN KEY (`unee_t_unit_type`) REFERENCES `ut_unit_types` (`designation`) ON UPDATE CASCADE 
		) ENGINE=InnoDB DEFAULT CHARSET='utf8mb4' COLLATE='utf8mb4_unicode_520_ci';

# Update values to the table `ut_unit_types`

	UPDATE `ut_unit_types`
	SET 
		`syst_updated_datetime` = '2019-07-15 15:47:05',
		`update_system_id` = 1,
		`updated_by_id` = '1',
		`order` = '9999',
		`is_level_1` = '0',
		`is_level_2` = '0',
		`is_level_3` = '0',
		`is_obsolete` = '1'
	WHERE `id_property_type` = '14'
	;

	UPDATE `ut_unit_types`
	SET

		`syst_updated_datetime` = '2019-07-15 15:47:05',
		`update_system_id` = 1,
		`updated_by_id` = '1',
		`order` = '9999',
		`is_level_1` = '0',
		`is_level_2` = '0',
		`is_level_3` = '0',
		`is_obsolete` = '1'
	WHERE `id_property_type` = '16'
	;

# INSERT new values to the table `ut_unit_types`

	INSERT  INTO `ut_unit_types`(`id_property_type`,`syst_created_datetime`,`creation_system_id`,`created_by_id`,`syst_updated_datetime`,`update_system_id`,`updated_by_id`,`order`,`is_level_1`,`is_level_2`,`is_level_3`,`is_obsolete`,`designation`,`description`) VALUES 
	(17,'2019-07-15 15:47:05',1,'1',NULL,NULL,NULL,5000,1,0,0,0,'Other/Building',NULL),
	(18,'2019-07-15 15:47:05',1,'1',NULL,NULL,NULL,5005,0,1,0,0,'Other/Unit',NULL),
	(19,'2019-07-15 15:47:05',1,'1',NULL,NULL,NULL,5010,0,0,1,0,'Other/Room',NULL),
	(21,'2019-07-15 15:47:05',1,'1',NULL,NULL,NULL,6000,1,0,0,0,'Unknown/Building',NULL),
	(22,'2019-07-15 15:47:05',1,'1',NULL,NULL,NULL,6005,0,1,0,0,'Unknown/Unit',NULL),
	(23,'2019-07-15 15:47:05',1,'1',NULL,NULL,NULL,6010,0,0,1,0,'Unknown/Room',NULL)
	;

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