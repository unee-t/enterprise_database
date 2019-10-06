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
	SET @new_schema_version := 'v1.23.0_alpha_1';

# What is the name of this script?

	SET @this_script := CONCAT ('upgrade_unee-t_entreprise', @old_schema_version, '_to_', @new_schema_version, '.sql');

# In this update
#			- WIP - create dedicated tables to record if each change to one of the objects was done correctly:
#				- WIP User: table `ut_map_external_source_users_edit_requests`
#				- WIP Unit: table `ut_map_external_source_units_edit_requests`
#				- WIP Association User/Unit: table `ut_map_user_permissions_unit_all_edit_requests`
#				- WIP Area (NEW): table `ut_map_external_source_areas_edit_requests`
#
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
#
#
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