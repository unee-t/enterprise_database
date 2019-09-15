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

	SET @old_schema_version := 'v1.22.6';
	SET @new_schema_version := 'v1.22.7';

# What is the name of this script?

	SET @this_script := CONCAT ('upgrade_unee-t_entreprise', @old_schema_version, '_to_', @new_schema_version, '.sql');

# In this update
#
#WIP	- Fix issue `sub-query returns more than one result`
#
#OK	- Fix bugs in the script `properties_level_3_creation_update` some triggers were incorrectly named.
#OK	- Improve how we record which trigger activated the lambda calls
#OK		- Use NOW() instead of a variable (more accurate datetime)
#OK		- L3P
#OK		- L2P
#OK		- L2P
#OK	- Add 2 columns to the table `ut_map_external_source_units` to record the latest activated trigger.
#OK		- `datetime_latest_trigger`
#OK		- `latest_trigger`
#
#OK	- merge the 2 AFTER UPDATE triggers into 1 for the lambda related calls.
#
#
# New functionalities
#	- Facilitate checks, logs and controls. 
#		- CREATE an object: Add the id `create_api_request_id` of the request to CREATE the DB object:
#			- User: table `ut_map_external_source_users`
#			- Unit: table `ut_map_external_source_units`
#			- Association User/Unit: table `ut_map_user_permissions_unit_all`
#			- Area (NEW): table `ut_map_external_source_areas`
#		- EDIT an object: 
#			- Add the id `create_api_request_id` of the request to CREATE the DB object:
#				- User: table `ut_map_external_source_users`
#				- Unit: table `ut_map_external_source_units`
#				- Association User/Unit: table `ut_map_user_permissions_unit_all`
#				- Area (NEW): table `ut_map_external_source_areas`
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
#
# We Drop the legacy triggers:


	DROP TRIGGER IF EXISTS `ut_insert_external_property_level_1`;
	DROP TRIGGER IF EXISTS `ut_update_map_external_source_unit_add_building`;


	DROP TRIGGER IF EXISTS `ut_insert_external_property_level_2`;
	DROP TRIGGER IF EXISTS `ut_update_map_external_source_unit_add_unit`;

	DROP TRIGGER IF EXISTS `ut_update_unit_creation_needed`;
	DROP TRIGGER IF EXISTS `ut_update_unit_already_exists`;



# Change the structure of some tables

	/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;

	/* Alter table in target */

	ALTER TABLE `log_lambdas` 
		CHANGE `creation_trigger` `creation_trigger` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The trigger that created this lambda cal' after `created_datetime` , 
		ADD COLUMN `action_type` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The Type of action that we ask of th MEFE API' after `associated_call` , 
		ADD COLUMN `mefeAPIRequestId` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The unique MEFE API Request ID' after `action_type` , 
		ADD COLUMN `table_that_triggered_lambda` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The source table that triggered the lambda call' after `mefeAPIRequestId` , 
		ADD COLUMN `id_in_table_that_triggered_lambda` int(11)   NULL COMMENT 'The ID in the source table that triggered the lambda call' after `table_that_triggered_lambda` , 
		ADD COLUMN `event_type_that_triggered_lambda` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The trigger event that generated the lambda call (INSERT, UPDATE, DELETE)' after `id_in_table_that_triggered_lambda` , 
		ADD COLUMN `external_property_type_id` int(11)   NULL COMMENT 'The type of property if applicable. This is a FK to the table `ut_property_types`' after `event_type_that_triggered_lambda` , 
		CHANGE `mefe_unit_id` `mefe_unit_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The MEFE Unit ID (If applicable)' after `external_property_type_id` , 
		CHANGE `mefe_user_id` `mefe_user_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The MEFE User ID (If applicable)' after `unit_name` , 
		CHANGE `payload` `payload` mediumtext  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The payload for the lambda' after `unee_t_login` ;

	/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;

# Change the structure of more tables:

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
			ADD COLUMN `datetime_latest_trigger` datetime   NULL COMMENT 'The date and time the latest trigger was fired for this table' after `organization_id` , 
			ADD COLUMN `latest_trigger` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The name of the latest trigger that was fired in this table' after `datetime_latest_trigger` , 
			CHANGE `is_obsolete` `is_obsolete` tinyint(1)   NULL DEFAULT 0 COMMENT '1 if we need to remove this unit from the mapping' after `latest_trigger` ,
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
		ADD CONSTRAINT `L3P_room_id_room_type_id` 
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

###########################################################################################
#
# Re Create the objects from the script `properties_level_1_creation_update_v1_22_7`
#
###########################################################################################

#################
#
# This lists all the triggers we use to create 
# a property_level_1
# via the Unee-T Enterprise Interface
#
#################

# This script creates the following objects:
#	- Triggers
#		- `ut_insert_external_property_level_1`
#		- `ut_update_external_property_level_1`
#		- `ut_update_external_property_level_1_creation_needed`
#		- `ut_update_map_external_source_unit_add_building`
#		- `ut_update_map_external_source_unit_add_building_creation_needed`
#		- `ut_update_map_external_source_unit_edit_level_1`
#		- ``
#		- ``
#	- Procedures
#		- ``
#		- ``
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
#		- 'ut_insert_external_property_level_1'
#		- 'ut_update_external_property_level_1'
#		- 'ut_update_external_property_level_1_creation_needed'
#		- ''
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
		AND (@upstream_create_method_insert_l1 = 'ut_insert_external_property_level_1'
			OR @upstream_update_method_insert_l1 = 'ut_insert_external_property_level_1'
			OR @upstream_create_method_insert_l1 = 'ut_update_external_property_level_1'
			OR @upstream_update_method_insert_l1 = 'ut_update_external_property_level_1'
			OR @upstream_create_method_insert_l1 = 'ut_update_external_property_level_1_creation_needed'
			OR @upstream_update_method_insert_l1 = 'ut_update_external_property_level_1_creation_needed'
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
#		- `ut_insert_external_property_level_1`
#		- 'ut_update_external_property_level_1_creation_needed'

# Capture the variables we need to verify if conditions are met:

	SET @is_creation_needed_in_unee_t_update_l1 = NEW.`is_creation_needed_in_unee_t` ;

	SET @external_property_id_update_l1 = NEW.`external_id` ;
	SET @external_system_update_l1 = NEW.`external_system_id` ;
	SET @table_in_external_system_update_l1 = NEW.`external_table` ;
	SET @organization_id_update_l1 = NEW.`organization_id`;
	SET @tower_update_l1 = NEW.`tower` ; 

	SET @new_is_creation_needed_in_unee_t_update_l1 =  NEW.`is_creation_needed_in_unee_t` ;
	SET @old_is_creation_needed_in_unee_t_update_l1 = OLD.`is_creation_needed_in_unee_t` ; 

	SET @id_building_update_l1 = NEW.`id_building` ;

	SET @upstream_create_method_update_l1 = NEW.`creation_method` ;
	SET @upstream_update_method_update_l1 = NEW.`update_method` ;

# We can now check if the conditions are met:

	IF (@upstream_create_method_update_l1 = 'ut_insert_external_property_level_1'
			OR @upstream_update_method_update_l1 = 'ut_insert_external_property_level_1'
			OR @upstream_create_method_update_l1 = 'ut_update_external_property_level_1_creation_needed'
			OR @upstream_update_method_update_l1 = 'ut_update_external_property_level_1_creation_needed'
			)
	THEN 

	# The conditions are met: we capture the other variables we need

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
			
		SET @new_record_id_update_l1 = NEW.`id_building`;

		SET @external_property_id_update_l1 = NEW.`external_id` ;
		SET @external_system_update_l1 = NEW.`external_system_id` ;
		SET @table_in_external_system_update_l1 = NEW.`external_table` ;
	
		SET @external_property_type_id_update_l1 = 1 ;

		SET @mefe_unit_id_update_l1 = (SELECT `unee_t_mefe_unit_id`
			FROM `ut_map_external_source_units`
			WHERE `external_property_type_id` = @external_property_type_id_update_l1
				AND `external_property_id` = @external_property_id_update_l1
				AND `external_system` = @external_system_update_l1
				AND `table_in_external_system` = @table_in_external_system_update_l1
				AND `organization_id` = @organization_id_update_l1
				AND `tower` = @tower_update_l1
			);
		
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





###########################################################################################
#
# Re Create the objects from the script `properties_level_2_creation_update_v1_22_7`
#
###########################################################################################

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
		SET @organization_id_update_insert_extl2 = @source_system_updater_insert_extl2;

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

				SET @this_trigger_update_extl2_insert = 'ut_after_update_external_property_level_2_insert_update_needed';
				SET @this_trigger_update_extl2_update = 'ut_after_update_external_property_level_2_update_update_needed';

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
#		- 'ut_insert_external_property_level_2'
#		- 'ut_update_external_property_level_2'
#		- 'ut_update_external_property_level_2_creation_needed'
#		- ''
#
	SET @is_creation_needed_in_unee_t_insert_l2 = NEW.`is_creation_needed_in_unee_t` ;

	SET @external_property_id_insert_l2 = NEW.`external_id` ;
	SET @external_system_insert_l2 = NEW.`external_system_id` ;
	SET @table_in_external_system_insert_l2 = NEW.`external_table` ;
	SET @organization_id_insert_l2 = NEW.`organization_id`;
	
	SET @tower_insert_l2 = NEW.`tower`;

	SET @id_in_ut_map_external_source_units_insert_l2 = (SELECT `id_map`
		FROM `ut_map_external_source_units`
		WHERE `external_system` = @external_system_insert_l2
			AND `table_in_external_system` = @table_in_external_system_insert_l2
			AND `external_property_id` = @external_property_id_insert_l2
			AND `organization_id` = @organization_id_insert_l2
			AND `external_property_type_id` = 2
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

	SET @creation_system_id_insert_l2 = NEW.`creation_system_id`;
	SET @created_by_id_insert_l2 = NEW.`created_by_id`;

	SET @update_system_id_insert_l2 = NEW.`creation_system_id`;
	SET @updated_by_id_insert_l2 = NEW.`created_by_id`;
			
	SET @uneet_name_insert_l2 = NEW.`designation`;

	SET @unee_t_unit_type_insert_l2_raw = NEW.`unee_t_unit_type` ;

	SET @unee_t_unit_type_insert_l2 = (IFNULL(@unee_t_unit_type_insert_l2_raw
			, 'Unknown'
			)
		)
		;
			
	SET @new_record_id_insert_l2 = NEW.`system_id_unit`;

	IF @is_creation_needed_in_unee_t_insert_l2 = 1
		AND @do_not_insert_insert_l2 = 0
		AND (@upstream_create_method_insert_l2 = 'ut_insert_external_property_level_2'
			OR @upstream_update_method_insert_l2 = 'ut_insert_external_property_level_2'
			OR @upstream_create_method_insert_l2 = 'ut_update_external_property_level_2'
			OR @upstream_update_method_insert_l2 = 'ut_update_external_property_level_2'
			OR @upstream_create_method_insert_l2 = 'ut_update_external_property_level_2_creation_needed'
			OR @upstream_update_method_insert_l2 = 'ut_update_external_property_level_2_creation_needed'
			)
	THEN 

		# We capture the values we need for the insert/udpate:

			SET @this_trigger_insert_l2_insert = 'ut_after_insert_in_property_level_2_insert' ;
			SET @this_trigger_insert_l2_update = 'ut_after_insert_in_property_level_2_update' ;

			SET @creation_method_insert_l2 = @this_trigger ;
			
			SET @is_update_needed_insert_l2 = NULL;

			SET @external_property_type_id_insert_l2 = 2;	

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
#		- 'ut_insert_external_property_level_2'
#		- 'ut_update_external_property_level_2_creation_needed'

# Capture the variables we need to verify if conditions are met:

	SET @system_id_unit_update_l2 = NEW.`system_id_unit` ;

	SET @mefe_unit_id_update_l2 = NULL ;

	SET @upstream_create_method_update_l2 = NEW.`creation_method` ;
	SET @upstream_update_method_update_l2 = NEW.`update_method` ;

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
			
		SET @new_record_id_update_l2 = NEW.`system_id_unit`;
		SET @external_property_id_update_l2 = NEW.`external_id`;
		SET @external_system_update_l2 = NEW.`external_system_id`;
		SET @table_in_external_system_update_l2 = NEW.`external_table`;			

		SET @is_creation_needed_in_unee_t_update_l2 = NEW.`is_creation_needed_in_unee_t`;

		SET @new_is_creation_needed_in_unee_t_update_l2 = NEW.`is_creation_needed_in_unee_t`;
		SET @old_is_creation_needed_in_unee_t_update_l2 = OLD.`is_creation_needed_in_unee_t`;

		SET @do_not_insert_update_l2_raw = NEW.`do_not_insert` ;

		SET @is_obsolete_update_l2 = NEW.`is_obsolete`;

# We can now check if the conditions are met:

	IF (@upstream_create_method_update_l2 = 'ut_insert_external_property_level_2'
			OR @upstream_update_method_update_l2 = 'ut_insert_external_property_level_2'
			OR @upstream_create_method_update_l2 = 'ut_update_external_property_level_2_creation_needed'
			OR @upstream_update_method_update_l2 = 'ut_update_external_property_level_2_creation_needed'
			)
	THEN 

	# The conditions are met: we capture the other variables we need

		SET @external_property_type_id_update_l2 = 2;

		SET @mefe_unit_id_update_l2 = (SELECT `unee_t_mefe_unit_id`
			FROM `ut_map_external_source_units`
			WHERE `new_record_id` = @system_id_unit_update_l2
				AND `external_property_type_id` = @external_property_type_id_update_l2
				AND `unee_t_mefe_unit_id` IS NOT NULL
			);

		# If the record does NOT exist, we create the record
		# unless 
		#	- it is specifically specified that we do NOT need to create the record.
		#	- the record is marked as obsolete

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





###########################################################################################
#
# Re Create the objects from the script `properties_level_3_creation_update_v1_22_7`
#
###########################################################################################

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

		SET @this_trigger_insert_extl3_1_insert = 'ut_insert_external_property_level_3_insert' ;
		SET @this_trigger_insert_extl3_1_update = 'ut_insert_external_property_level_3_update' ;

		SET @creation_system_id_insert_extl3_1 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator_insert_extl3_1
			)
			;
		SET @created_by_id_insert_extl3_1 = @creator_mefe_user_id_insert_extl3_1 ;
		SET @downstream_creation_method_insert_extl3_1 = @this_trigger_insert_extl3_1_insert ;

		SET @update_system_id_insert_extl3_1 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater_insert_extl3_1
			)
			;
		SET @updated_by_id_insert_extl3_1 = @creator_mefe_user_id_insert_extl3_1 ;
		SET @downstream_update_method_insert_extl3_1 = @this_trigger_insert_extl3_1_update ;

		SET @organization_id_create_insert_extl3_1 = @source_system_creator_insert_extl3_1 ;
		SET @organization_id_update_insert_extl3_1 = @source_system_updater_insert_extl3_1 ;
		
		SET @is_obsolete_insert_extl3_1 = NEW.`is_obsolete` ;
		SET @is_creation_needed_in_unee_t_insert_extl3_1 = NEW.`is_creation_needed_in_unee_t` ;

		SET @unee_t_unit_type_insert_extl3_1 = NEW.`unee_t_unit_type` ;
			
		SET @room_type_id_insert_extl3_1 = NEW.`room_type_id` ;
		SET @number_of_beds_insert_extl3_1 = NEW.`number_of_beds` ;
		SET @surface_insert_extl3_1 = NEW.`surface` ;
		SET @surface_measurment_unit_insert_extl3_1 = NEW.`surface_measurment_unit` ;
		SET @room_designation_insert_extl3_1 = NEW.`room_designation`;
		SET @room_description_insert_extl3_1 = NEW.`room_description` ;

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
			)
			VALUES
 				(@external_id_insert_extl3_1
				, @external_system_id_insert_extl3_1
				, @external_table_insert_extl3_1
				, NOW()
				, @creation_system_id_insert_extl3_1
				, @created_by_id_insert_extl3_1
				, @downstream_creation_method_insert_extl3_1
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
 			)
			ON DUPLICATE KEY UPDATE
 				`syst_updated_datetime` = NOW()
 				, `update_system_id` = @update_system_id_insert_extl3_1
 				, `updated_by_id` = @updated_by_id_insert_extl3_1
				, `update_method` = @downstream_update_method_insert_extl3_1
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
		SET @is_creation_needed_in_unee_t_update_extl3 = NEW.`is_creation_needed_in_unee_t` ;

		SET @unee_t_unit_type_update_extl3 = NEW.`unee_t_unit_type` ;
			
		SET @room_type_id_update_extl3 = NEW.`room_type_id` ;
		SET @number_of_beds_update_extl3 = NEW.`number_of_beds` ;
		SET @surface_update_extl3 = NEW.`surface` ;
		SET @surface_measurment_unit_update_extl3 = NEW.`surface_measurment_unit` ;
		SET @room_designation_update_extl3 = NEW.`room_designation`;
		SET @room_description_update_extl3 = NEW.`room_description` ;

		IF @new_is_creation_needed_in_unee_t_update_extl3 != @old_is_creation_needed_in_unee_t_update_extl3
		THEN 

			# This is option 1 - creation IS needed

				SET @this_trigger_update_ext_l3_insert = 'ut_update_external_property_level_3_creation_needed_insert';
				SET @this_trigger_update_ext_l3_update = 'ut_update_external_property_level_3_creation_needed_update';

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
						;

		ELSEIF @new_is_creation_needed_in_unee_t_update_extl3 = @old_is_creation_needed_in_unee_t_update_extl3
		THEN 
			
			# This is option 2 creation is NOT needed

				SET @this_trigger_update_ext_l3_insert = 'ut_update_external_property_level_3_insert';
				SET @this_trigger_update_ext_l3_update = 'ut_update_external_property_level_3_update';

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
#		- 'ut_insert_external_property_level_3_insert'
#		- 'ut_insert_external_property_level_3_update'
#		- 'ut_update_external_property_level_3'
#		- 'ut_update_external_property_level_3_creation_needed'
#		- ''
#
	SET @is_creation_needed_in_unee_t_insert_l3 = NEW.`is_creation_needed_in_unee_t` ;

	SET @external_property_id_insert_l3 = NEW.`external_id` ;
	SET @external_system_insert_l3 = NEW.`external_system_id` ;
	SET @table_in_external_system_insert_l3 = NEW.`external_table` ;
	SET @organization_id_insert_l3 = NEW.`organization_id`;

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
		AND (@upstream_create_method_insert_l3 = 'ut_insert_external_property_level_3_insert'
			OR @upstream_update_method_insert_l3 = 'ut_insert_external_property_level_3_update'
			OR @upstream_create_method_insert_l3 = 'ut_update_external_property_level_3'
			OR @upstream_update_method_insert_l3 = 'ut_update_external_property_level_3'
			OR @upstream_create_method_insert_l3 = 'ut_update_external_property_level_3_creation_needed'
			OR @upstream_update_method_insert_l3 = 'ut_update_external_property_level_3_creation_needed'
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
		SET @external_property_type_id_insert_l3 = 3;	

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
#		- 'ut_insert_external_property_level_3_insert'
#		- 'ut_insert_external_property_level_3_update'
#		- 'ut_update_map_external_source_unit_add_room_creation_needed'
#		- 'ut_update_map_external_source_unit_edit_level_3'

# Capture the variables we need to verify if conditions are met:

	SET @upstream_create_method_update_l3 = NEW.`creation_method` ;
	SET @upstream_update_method_update_l3 = NEW.`update_method` ;

# We can now check if the conditions are met:

	IF (@upstream_create_method_update_l3 = 'ut_insert_external_property_level_3_insert'
			OR @upstream_update_method_update_l3 = 'ut_insert_external_property_level_3_update'
			OR @upstream_create_method_update_l3 = 'ut_update_map_external_source_unit_add_room_creation_needed'
			OR @upstream_update_method_update_l3 = 'ut_update_map_external_source_unit_add_room_creation_needed'
			OR @upstream_create_method_update_l3 = 'ut_update_map_external_source_unit_edit_level_3'
			OR @upstream_update_method_update_l3 = 'ut_update_map_external_source_unit_edit_level_3'
			)
	THEN 

	# The conditions are met: we capture the other variables we need

		SET @system_id_room_update_l3 = NEW.`system_id_room` ;

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
			
		SET @new_record_id_update_l3 = NEW.`system_id_room`;
		SET @external_property_type_id_update_l3 = 3;

		SET @external_property_id_update_l3 = NEW.`external_id`;
		SET @external_system_update_l3 = NEW.`external_system_id`;
		SET @table_in_external_system_update_l3 = NEW.`external_table`;	

		SET @mefe_unit_id_update_l3 = NULL ;

		SET @mefe_unit_id_update_l3 = (SELECT `unee_t_mefe_unit_id`
			FROM `ut_map_external_source_units`
			WHERE `new_record_id` = @system_id_room_update_l3
				AND `external_property_type_id` = 3
				AND `unee_t_mefe_unit_id` IS NOT NULL
			);

		# If the record does NOT exist, we create the record
		# unless 
		#	- it is specifically specified that we do NOT need to create the record.
		#	- the record is marked as obsolete

		SET @is_creation_needed_in_unee_t_update_l3 = NEW.`is_creation_needed_in_unee_t`;

		SET @new_is_creation_needed_in_unee_t_update_l3 = NEW.`is_creation_needed_in_unee_t`;
		SET @old_is_creation_needed_in_unee_t_update_l3 = OLD.`is_creation_needed_in_unee_t`;

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

				SET @this_trigger_update_l3_insert = 'ut_update_map_external_source_unit_add_room_creation_needed_insert' ;
				SET @this_trigger_update_l3_update = 'ut_update_map_external_source_unit_add_room_creation_needed_update' ;

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