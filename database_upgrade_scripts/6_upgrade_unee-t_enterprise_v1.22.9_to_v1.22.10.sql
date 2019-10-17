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

	SET @old_schema_version := 'v1.22.9';
	SET @new_schema_version := 'v1.22.10';

# What is the name of this script?

	SET @this_script := CONCAT ('upgrade_unee-t_entreprise', @old_schema_version, '_to_', @new_schema_version, '.sql');

# In this update
#
#OK Alter the table `uneet_enterprise_organizations` to store the default assignee for each role:
#OK	- Mgt Cny
#OK	- Agent
#OK	- Landlord
#OK	- Tenant
#
# Alter several table to store the external information for the parent element:
#
#OK	- `external_property_level_1_buildings`
#OK	  Add the following columns
#OK		- `area_external_system`
#OK		- `area_external_table`
#OK		- `area_external_id`
#
#OK	- `external_property_level_2_units`
#OK	  Add the following columns
#OK		- `l1p_external_system`
#OK		- `l1p_external_table`
#OK		- `l1p_external_id`
#
#OK	- `external_property_level_3_rooms`
#OK	  Add the following columns
#OK		- `l2p_external_system`
#OK		- `l2p_external_table`
#OK		- `l2p_external_id`
#
#OK	- `property_level_1_buildings`
#OK	  REMOVE the FK to the table `property_groups_areas`
#OK	  Add the following columns
#OK		- `area_external_system`
#OK		- `area_external_table`
#OK		- `area_external_id`
#OK	  DEPRECATE the column `area_id`
#
#OK	- `property_level_2_units`
#OK	  REMOVE the FK to the table `property_level_1_buildings`
#OK   ADD FK to the table `external_property_groups_areas`
#OK	  Add the following columns
#OK		- `l1p_external_system`
#OK		- `l1p_external_table`
#OK		- `l1p_external_id`
#OK	  DEPRECATE the column `building_system_id`
#
#OK	- `property_level_3_rooms`
#OK	  REMOVE the FK to the table `property_level_2_units`
#OK	  Add the following columns
#OK		- `l2p_external_system`
#OK		- `l2p_external_table`
#OK		- `l2p_external_id`
#OK	  DEPRECATE the column `system_id_unit`
#
#OK	- `ut_map_external_source_units`
#OK	  Add the following columns
#OK		- `parent_external_system`
#OK		- `parent_external_table`
#OK		- `parent_external_id`
#
#
######################################################################################
#
# WARNING:
#
#
# 	We need to look at the code and make sure that 
#	the view `ut_organization_associated_mefe_user` is NOT used anywhere
#
#
######################################################################################
#
#
#WIP	- Update the routine to create new user (persons)
#WIP		- When we create a new record, If we have no default 
#			- system, 
#			- table or
#			- external_id
#		  THEN we use the default values in the default SoT for the organization
#WIP		- Make sure that we propagate:
#WIP			- MEFE parent ID if applicable
#
#WIP	- Update the routine to create new areas
#WIP		- When we create a new record, If we have no default 
#			- system, 
#			- table or
#			- external_id
#		  THEN we use the default values in the default SoT for the organization
#WIP		- Make sure that we propagate to the table `ut_map_external_source_areas`
#OK	- IF we do NOT have a default assignee, 
#		  THEN we use the default assignee for the organization.
#
#WIP - Update the routine to create new L1P.
#WIP		- When we create a new record, If we have no default 
#			- system, 
#			- table or
#			- external_id
#		  THEN we use the default values in the default SoT for the organization
#OK		- Propagate information about the parent.
#OK	- IF we do NOT have a default assignee, 
#		  THEN we use the default assignee for the Area
#
#WIP - Update the routine to create new L2P. 
#WIP		- When we create a new record, If we have no default 
#			- system, 
#			- table or
#			- external_id
#		  THEN we use the default values in the default SoT for the organization
#OK		- Propagate information about the parent.
#OK	- IF we do NOT have a default assignee, 
#		  THEN we use the default assignee for the L1P
#
#WIP - Update the routine to create new L3P.
#WIP		- When we create a new record, If we have no default 
#			- system, 
#			- table or
#			- external_id
#		  THEN we use the default values in the default SoT for the organization
#OK		- Propagate information about the parent.
#OK	- IF we do NOT have a default assignee, 
#		  THEN we use the default assignee for the L2P
#
# Update the tables with the parent id information:
# we use the info from the parent record for that
#OK	- `external_property_level_1_buildings`
#OK	- `external_property_level_2_units`
#OK	- `external_property_level_3_rooms`
#OK	- `property_level_1_buildings`
#OK	- `property_level_2_units`
#OK	- `property_level_3_rooms`
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

# Alter several tables (see above)
#	- `external_property_level_1_buildings`
#	- `external_property_level_2_units`
#	- `external_property_level_3_rooms`
#	- `property_level_1_buildings`
#	- `property_level_2_units`
#	- `property_level_3_rooms`
#	- `ut_map_external_source_units`
#	- `uneet_enterprise_organizations`

	/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;

	/* Foreign Keys must be dropped in the target to ensure that requires changes can be done*/

	ALTER TABLE `external_property_level_1_buildings` 
		DROP FOREIGN KEY `ext_property_level_1_country_code`  , 
		DROP FOREIGN KEY `ext_property_level_1_created_by`  , 
		DROP FOREIGN KEY `ext_property_level_1_default_assignee_agent`  , 
		DROP FOREIGN KEY `ext_property_level_1_default_assignee_landlord`  , 
		DROP FOREIGN KEY `ext_property_level_1_default_assignee_mgt_cny`  , 
		DROP FOREIGN KEY `ext_property_level_1_default_assignee_tenant`  , 
		DROP FOREIGN KEY `ext_property_level_1_updated_by`  , 
		DROP FOREIGN KEY `ext_property_unit_type`  ;

	ALTER TABLE `external_property_level_2_units` 
		DROP FOREIGN KEY `ext_property_level_2_created_by`  , 
		DROP FOREIGN KEY `ext_property_level_2_default_assignee_agent`  , 
		DROP FOREIGN KEY `ext_property_level_2_default_assignee_landlord`  , 
		DROP FOREIGN KEY `ext_property_level_2_default_assignee_mgt_cny`  , 
		DROP FOREIGN KEY `ext_property_level_2_default_assignee_tenant`  , 
		DROP FOREIGN KEY `ext_property_level_2_unit_type`  , 
		DROP FOREIGN KEY `ext_property_level_2_updated_by`  ;

	ALTER TABLE `external_property_level_3_rooms` 
		DROP FOREIGN KEY `ext_property_level_3_created_by_id`  , 
		DROP FOREIGN KEY `ext_property_level_3_default_assignee_agent`  , 
		DROP FOREIGN KEY `ext_property_level_3_default_assignee_landlord`  , 
		DROP FOREIGN KEY `ext_property_level_3_default_assignee_mgt_cny`  , 
		DROP FOREIGN KEY `ext_property_level_3_default_assignee_tenant`  , 
		DROP FOREIGN KEY `ext_property_level_3_unit_type`  , 
		DROP FOREIGN KEY `ext_property_level_3_updated_by_id`  ;

	ALTER TABLE `property_level_1_buildings` 
		DROP FOREIGN KEY `property_level_1_country_code`  , 
		DROP FOREIGN KEY `property_level_1_default_assignee_agent`  , 
		DROP FOREIGN KEY `property_level_1_default_assignee_landlord`  , 
		DROP FOREIGN KEY `property_level_1_default_assignee_mgt_cny`  , 
		DROP FOREIGN KEY `property_level_1_default_assignee_tenant`  , 
		DROP FOREIGN KEY `property_level_1_organization_id`  , 
		DROP FOREIGN KEY `unee_t_valid_unit_type_building`  ;

	ALTER TABLE `property_level_2_units` 
		DROP FOREIGN KEY `property_level_2_default_assignee_agent`  , 
		DROP FOREIGN KEY `property_level_2_default_assignee_landlord`  , 
		DROP FOREIGN KEY `property_level_2_default_assignee_mgt_cny`  , 
		DROP FOREIGN KEY `property_level_2_default_assignee_tenant`  , 
		DROP FOREIGN KEY `property_level_2_organization_id`  , 
		DROP FOREIGN KEY `unee_t_valid_unit_type_unit`  ;

	ALTER TABLE `property_level_3_rooms` 
		DROP FOREIGN KEY `property_level_3_default_assignee_agent`  , 
		DROP FOREIGN KEY `property_level_3_default_assignee_landlord`  , 
		DROP FOREIGN KEY `property_level_3_default_assignee_mgt_cny`  , 
		DROP FOREIGN KEY `property_level_3_default_assignee_tenant`  , 
		DROP FOREIGN KEY `property_level_3_organization_id`  , 
		DROP FOREIGN KEY `unee_t_valid_unit_type_room`  ;

	ALTER TABLE `uneet_enterprise_organizations` 
		DROP FOREIGN KEY `organization_default_area_must_exist`  , 
		DROP FOREIGN KEY `organization_default_building_must_exist`  , 
		DROP FOREIGN KEY `organization_default_role_type_must_exist`  , 
		DROP FOREIGN KEY `organization_default_sot_must_exist`  , 
		DROP FOREIGN KEY `organization_default_unit_must_exist`  ;

	ALTER TABLE `ut_map_external_source_units` 
		DROP FOREIGN KEY `mefe_unit_organization_id`  , 
		DROP FOREIGN KEY `prop_area_id_must_exist`  , 
		DROP FOREIGN KEY `prop_mefe_user_id_for_default_assignee_for_agent_must_exist`  , 
		DROP FOREIGN KEY `prop_mefe_user_id_for_default_assignee_for_landlord_must_exist`  , 
		DROP FOREIGN KEY `prop_mefe_user_id_for_default_assignee_for_mgt_cny_must_exist`  , 
		DROP FOREIGN KEY `prop_mefe_user_id_for_default_assignee_for_tenant_must_exist`  , 
		DROP FOREIGN KEY `property_property_type`  , 
		DROP FOREIGN KEY `unee_t_valid_unit_type_map_units`  , 
		DROP FOREIGN KEY `unit_mefe_area_id_must_exist`  , 
		DROP FOREIGN KEY `unit_mefe_unit_id_parent_must_exist`  ;


	/* Alter table in target */
	ALTER TABLE `external_property_level_1_buildings` 
		CHANGE `is_creation_needed_in_unee_t` `is_creation_needed_in_unee_t` tinyint(1)   NULL DEFAULT 0 COMMENT '1 if we need to create this property as a unit in Unee-T' after `order` , 
		ADD COLUMN `area_external_system` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The external system where the area information is stored' after `unee_t_unit_type` , 
		ADD COLUMN `area_external_table` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The table in the external system where the area information is stored' after `area_external_system` , 
		ADD COLUMN `area_external_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The ID in the table in the external system where the area information is stored.' after `area_external_table` , 
		CHANGE `designation` `designation` varchar(255)  COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The name of the building' after `area_external_id` , 
		CHANGE `area_id` `area_id` int(11)   NULL COMMENT 'The ID of the ext Area - A FK to the table `external_property_groups_areas`' after `agent_default_assignee` , 
		DROP FOREIGN KEY `ext_property_level_1_area`  ;
	ALTER TABLE `external_property_level_1_buildings`
		ADD CONSTRAINT `ext_L1P_ext_area_must_exist` 
		FOREIGN KEY (`area_id`) REFERENCES `external_property_groups_areas` (`id_area`) ON UPDATE CASCADE ;


	/* Alter table in target */
	ALTER TABLE `external_property_level_2_units` 
		ADD COLUMN `l1p_external_system` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The external system where the L1P information is stored' after `unee_t_unit_type` , 
		ADD COLUMN `l1p_external_table` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The table in the external system where the L1P information is stored' after `l1p_external_system` , 
		ADD COLUMN `l1p_external_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The ID in the table in the external system where the L1P information is stored.' after `l1p_external_table` , 
		CHANGE `tower` `tower` varchar(50)  COLLATE utf8mb4_unicode_520_ci NULL DEFAULT '1' COMMENT 'The building in which this unit is (default is 1)' after `l1p_external_id` , 
		CHANGE `building_system_id` `building_system_id` int(11)   NOT NULL DEFAULT 1 COMMENT 'The ID of of the ext_L1P - A FK to the table `external_property_level_1_buildings`' after `agent_default_assignee` , 
		DROP FOREIGN KEY `ext_property_level_2_property_level_1`  ;
	ALTER TABLE `external_property_level_2_units`
		ADD CONSTRAINT `ext_L2P_ext_L1P_must_exist` 
		FOREIGN KEY (`building_system_id`) REFERENCES `external_property_level_1_buildings` (`id_building`) ON UPDATE CASCADE ;


	/* Alter table in target */
	ALTER TABLE `external_property_level_3_rooms` 
		ADD COLUMN `l2p_external_system` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The external system where the L2P information is stored' after `unee_t_unit_type` , 
		ADD COLUMN `l2p_external_table` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The table in the external system where the L2P information is stored' after `l2p_external_system` , 
		ADD COLUMN `l2p_external_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The ID in the table in the external system where the L2P information is stored.' after `l2p_external_table` , 
		CHANGE `room_type_id` `room_type_id` int(11)   NOT NULL DEFAULT 1 COMMENT 'The id of the LMB LOI. This is a FK to the table \'db_all_sourcing_dt_4_lmb_loi\'' after `l2p_external_id` , 
		CHANGE `system_id_unit` `system_id_unit` int(11)   NOT NULL COMMENT 'The ID of the ext L2P - A FK to the table `external_property_level_2_units`' after `agent_default_assignee` , 
		DROP FOREIGN KEY `ext_property_level_3_property_level_2`  ;

	/* Alter table in target */
	ALTER TABLE `property_level_1_buildings` 
		CHANGE `is_creation_needed_in_unee_t` `is_creation_needed_in_unee_t` tinyint(1)   NULL DEFAULT 0 COMMENT '1 if we need to create this property as a unit in Unee-T' after `order` , 
		ADD COLUMN `area_external_system` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The external system where the area information is stored' after `unee_t_unit_type` , 
		ADD COLUMN `area_external_table` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The table in the external system where the area information is stored' after `area_external_system` , 
		ADD COLUMN `area_external_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The ID in the table in the external system where the area information is stored.' after `area_external_table` , 
		CHANGE `designation` `designation` varchar(255)  COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The name of the building' after `area_external_id` , 
		CHANGE `area_id` `area_id` int(11)   NULL COMMENT 'DEPRECATED - The Id of the area for this building. This is a FK to the table `209_areas`' after `agent_default_assignee` , 
		DROP FOREIGN KEY `property_level_1__area_id`  ;

	/* Alter table in target */
	ALTER TABLE `property_level_2_units` 
		ADD COLUMN `l1p_external_system` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The external system where the L1P information is stored' after `unee_t_unit_type` , 
		ADD COLUMN `l1p_external_table` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The table in the external system where the L1P information is stored' after `l1p_external_system` , 
		ADD COLUMN `l1p_external_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The ID in the table in the external system where the L1P information is stored.' after `l1p_external_table` , 
		CHANGE `tower` `tower` varchar(50)  COLLATE utf8mb4_unicode_520_ci NULL DEFAULT '1' COMMENT 'The building in which this unit is (default is 1)' after `l1p_external_id` , 
		CHANGE `building_system_id` `building_system_id` int(11)   NOT NULL DEFAULT 1 COMMENT 'DEPRECATED - A FK to the table `property_buildings`' after `agent_default_assignee` , 
		DROP FOREIGN KEY `property_level_2_building_id`  ;

	/* Alter table in target */
	ALTER TABLE `property_level_3_rooms` 
		ADD COLUMN `l2p_external_system` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The external system where the L2P information is stored' after `unee_t_unit_type` , 
		ADD COLUMN `l2p_external_table` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The table in the external system where the L2P information is stored' after `l2p_external_system` , 
		ADD COLUMN `l2p_external_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The ID in the table in the external system where the L2P information is stored.' after `l2p_external_table` , 
		CHANGE `room_type_id` `room_type_id` int(11)   NOT NULL DEFAULT 1 COMMENT 'The id of the LMB LOI. This is a FK to the table \'db_all_sourcing_dt_4_lmb_loi\'' after `l2p_external_id` , 
		CHANGE `system_id_unit` `system_id_unit` int(11)   NOT NULL COMMENT 'DEPRECATED - A FK to the table `property_unit`' after `agent_default_assignee` , 
		DROP FOREIGN KEY `room_id_flat_id`  ;

	/* Alter table in target */
	ALTER TABLE `uneet_enterprise_organizations` 
		ADD COLUMN `default_assignee_mgt_cny` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The MEFE user ID for the default assignee for the role \'Management Company\'' after `default_unit` , 
		ADD COLUMN `default_assignee_agent` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The MEFE user ID for the default assignee for the role \'Agent\'' after `default_assignee_mgt_cny` , 
		ADD COLUMN `default_assignee_landlord` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The MEFE user ID for the default assignee for the role \'Lanlord\'' after `default_assignee_agent` , 
		ADD COLUMN `default_assignee_tenant` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The MEFE user ID for the default assignee for the role \'Tenant\'' after `default_assignee_landlord` , 
		CHANGE `default_sot_system` `default_sot_system` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL DEFAULT 'system' COMMENT 'DEPRECATED - The Default source of truth for that organization' after `default_assignee_tenant` , 
		ADD KEY `org_MEFE_id_for_default_assignee_agent_must_exist`(`default_assignee_agent`) , 
		ADD KEY `org_MEFE_id_for_default_assignee_landlord_must_exist`(`default_assignee_landlord`) , 
		ADD KEY `org_MEFE_id_for_default_assignee_mgt_cny_must_exist`(`default_assignee_mgt_cny`) , 
		ADD KEY `org_MEFE_id_for_default_assignee_tenant_must_exist`(`default_assignee_tenant`) ;
	ALTER TABLE `uneet_enterprise_organizations`
		ADD CONSTRAINT `org_MEFE_id_for_default_assignee_agent_must_exist` 
		FOREIGN KEY (`default_assignee_agent`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `org_MEFE_id_for_default_assignee_landlord_must_exist` 
		FOREIGN KEY (`default_assignee_landlord`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `org_MEFE_id_for_default_assignee_mgt_cny_must_exist` 
		FOREIGN KEY (`default_assignee_mgt_cny`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `org_MEFE_id_for_default_assignee_tenant_must_exist` 
		FOREIGN KEY (`default_assignee_tenant`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE ;


	/* Alter table in target */
	ALTER TABLE `ut_map_external_source_units` 
		ADD COLUMN `parent_external_system` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The system that store the parent information' after `tower` , 
		ADD COLUMN `parent_external_table` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The table in the system that store the parent information' after `parent_external_system` , 
		ADD COLUMN `parent_external_id` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'The ID in the table that store the parent information' after `parent_external_table` , 
		CHANGE `mgt_cny_default_assignee` `mgt_cny_default_assignee` varchar(255)  COLLATE utf8mb4_unicode_520_ci NULL COMMENT 'Default Assignee for the role \'Management Company\' - A FK to the table `ut_map_external_source_users`' after `parent_external_id` ; 

	/* The foreign keys that were dropped are now re-created*/

	ALTER TABLE `external_property_level_1_buildings` 
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
		ADD CONSTRAINT `ext_property_level_2_unit_type` 
		FOREIGN KEY (`unee_t_unit_type`) REFERENCES `ut_unit_types` (`designation`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `ext_property_level_2_updated_by` 
		FOREIGN KEY (`updated_by_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE ;

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
		ADD CONSTRAINT `ext_property_level_3_unit_type` 
		FOREIGN KEY (`unee_t_unit_type`) REFERENCES `ut_unit_types` (`designation`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `ext_property_level_3_updated_by_id` 
		FOREIGN KEY (`updated_by_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE ;

	ALTER TABLE `property_level_1_buildings` 
		ADD CONSTRAINT `property_level_1_country_code` 
		FOREIGN KEY (`country_code`) REFERENCES `property_groups_countries` (`country_code`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `property_level_1_default_assignee_agent` 
		FOREIGN KEY (`agent_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `property_level_1_default_assignee_landlord` 
		FOREIGN KEY (`landlord_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `property_level_1_default_assignee_mgt_cny` 
		FOREIGN KEY (`mgt_cny_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `property_level_1_default_assignee_tenant` 
		FOREIGN KEY (`tenant_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `property_level_1_organization_id` 
		FOREIGN KEY (`organization_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `unee_t_valid_unit_type_building` 
		FOREIGN KEY (`unee_t_unit_type`) REFERENCES `ut_unit_types` (`designation`) ON UPDATE CASCADE ;

	ALTER TABLE `property_level_2_units` 
		ADD CONSTRAINT `property_level_2_default_assignee_agent` 
		FOREIGN KEY (`agent_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `property_level_2_default_assignee_landlord` 
		FOREIGN KEY (`landlord_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `property_level_2_default_assignee_mgt_cny` 
		FOREIGN KEY (`mgt_cny_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `property_level_2_default_assignee_tenant` 
		FOREIGN KEY (`tenant_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `property_level_2_organization_id` 
		FOREIGN KEY (`organization_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `unee_t_valid_unit_type_unit` 
		FOREIGN KEY (`unee_t_unit_type`) REFERENCES `ut_unit_types` (`designation`) ON UPDATE CASCADE ;

	ALTER TABLE `property_level_3_rooms` 
		ADD CONSTRAINT `property_level_3_default_assignee_agent` 
		FOREIGN KEY (`agent_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `property_level_3_default_assignee_landlord` 
		FOREIGN KEY (`landlord_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `property_level_3_default_assignee_mgt_cny` 
		FOREIGN KEY (`mgt_cny_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `property_level_3_default_assignee_tenant` 
		FOREIGN KEY (`tenant_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `property_level_3_organization_id` 
		FOREIGN KEY (`organization_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `unee_t_valid_unit_type_room` 
		FOREIGN KEY (`unee_t_unit_type`) REFERENCES `ut_unit_types` (`designation`) ON UPDATE CASCADE ;

	ALTER TABLE `uneet_enterprise_organizations` 
		ADD CONSTRAINT `organization_default_area_must_exist` 
		FOREIGN KEY (`default_area`) REFERENCES `external_property_groups_areas` (`id_area`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `organization_default_building_must_exist` 
		FOREIGN KEY (`default_building`) REFERENCES `ut_map_external_source_units` (`unee_t_mefe_unit_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `organization_default_role_type_must_exist` 
		FOREIGN KEY (`default_role_type_id`) REFERENCES `ut_user_role_types` (`id_role_type`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `organization_default_sot_must_exist` 
		FOREIGN KEY (`default_sot_id`) REFERENCES `ut_external_sot_for_unee_t_objects` (`id_external_sot_for_unee_t`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `organization_default_unit_must_exist` 
		FOREIGN KEY (`default_unit`) REFERENCES `ut_map_external_source_units` (`unee_t_mefe_unit_id`) ON UPDATE CASCADE ;

	ALTER TABLE `ut_map_external_source_units` 
		ADD CONSTRAINT `mefe_unit_organization_id` 
		FOREIGN KEY (`organization_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `prop_area_id_must_exist` 
		FOREIGN KEY (`area_id`) REFERENCES `property_groups_areas` (`id_area`) , 
		ADD CONSTRAINT `prop_mefe_user_id_for_default_assignee_for_agent_must_exist` 
		FOREIGN KEY (`agent_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `prop_mefe_user_id_for_default_assignee_for_landlord_must_exist` 
		FOREIGN KEY (`landlord_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `prop_mefe_user_id_for_default_assignee_for_mgt_cny_must_exist` 
		FOREIGN KEY (`mgt_cny_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `prop_mefe_user_id_for_default_assignee_for_tenant_must_exist` 
		FOREIGN KEY (`tenant_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `property_property_type` 
		FOREIGN KEY (`external_property_type_id`) REFERENCES `ut_property_types` (`id_property_type`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `unee_t_valid_unit_type_map_units` 
		FOREIGN KEY (`unee_t_unit_type`) REFERENCES `ut_unit_types` (`designation`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `unit_mefe_area_id_must_exist` 
		FOREIGN KEY (`mefe_area_id`) REFERENCES `ut_map_external_source_areas` (`mefe_area_id`) ON UPDATE CASCADE , 
		ADD CONSTRAINT `unit_mefe_unit_id_parent_must_exist` 
		FOREIGN KEY (`mefe_unit_id_parent`) REFERENCES `ut_map_external_source_units` (`unee_t_mefe_unit_id`) ON UPDATE CASCADE ;

	/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;


#################
#
# Areas
#
#################

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

		# Default assignees:

			# Mgt Cny (4)

				SET @organization_default_assignee_mgt_cny := (SELECT `default_assignee_mgt_cny`
					FROM `uneet_enterprise_organizations` 
					WHERE `id_organization` = @source_system_creator_insert_ext_area
					)
					;

				SET @area_default_assignee_mgt_cny_raw := NEW.`mgt_cny_default_assignee` ;

				SET @area_default_assignee_mgt_cny :=  IF(@area_default_assignee_mgt_cny_raw IS NULL
					, @organization_default_assignee_mgt_cny
					, IF(@area_default_assignee_mgt_cny_raw = ''
						, @organization_default_assignee_mgt_cny
						, @area_default_assignee_mgt_cny_raw
						)
					)
					;

			# Landlord ()

				SET @organization_default_assignee_landlord := (SELECT `default_assignee_landlord`
					FROM `uneet_enterprise_organizations` 
					WHERE `id_organization` = @source_system_creator_insert_ext_area
					)
					;

				SET @area_default_assignee_landlord_raw := NEW.`landlord_default_assignee` ;

				SET @area_default_assignee_landlord :=  IF(@area_default_assignee_landlord_raw IS NULL
					, @organization_default_assignee_landlord
					, IF(@area_default_assignee_landlord_raw = ''
						, @organization_default_assignee_landlord
						, @area_default_assignee_landlord_raw
						)
					)
					;

			# Tenant ()
			
				SET @organization_default_assignee_tenant := (SELECT `default_assignee_tenant`
					FROM `uneet_enterprise_organizations` 
					WHERE `id_organization` = @source_system_creator_insert_ext_area
					)
					;

				SET @area_default_assignee_tenant_raw := NEW.`tenant_default_assignee` ;

				SET @area_default_assignee_tenant := IF(@area_default_assignee_tenant_raw IS NULL
					, @organization_default_assignee_tenant
					, IF(@area_default_assignee_tenant_raw = ''
						, @organization_default_assignee_tenant
						, @area_default_assignee_tenant_raw
						)
					)
					;
			
			# Agent ()
			
				SET @organization_default_assignee_agent := (SELECT `default_assignee_agent`
					FROM `uneet_enterprise_organizations` 
					WHERE `id_organization` = @source_system_creator_insert_ext_area
					)
					;

				SET @area_default_assignee_agent_raw := NEW.`agent_default_assignee` ;

				SET @area_default_assignee_agent :=  IF(@area_default_assignee_agent_raw IS NULL
					, @organization_default_assignee_agent
					, IF(@area_default_assignee_agent_raw = ''
						, @organization_default_assignee_agent
						, @area_default_assignee_agent_raw
						)
					)
					;

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

		# Default assignees:

			# Mgt Cny (4)

				SET @organization_default_assignee_mgt_cny := (SELECT `default_assignee_mgt_cny`
					FROM `uneet_enterprise_organizations` 
					WHERE `id_organization` = @organization_id_update_ext_area
					)
					;

				SET @area_default_assignee_mgt_cny_raw := NEW.`mgt_cny_default_assignee` ;

				SET @area_default_assignee_mgt_cny :=  IF(@area_default_assignee_mgt_cny_raw IS NULL
					, @organization_default_assignee_mgt_cny
					, IF(@area_default_assignee_mgt_cny_raw = ''
						, @organization_default_assignee_mgt_cny
						, @area_default_assignee_mgt_cny_raw
						)
					)
					;

			# Landlord ()

				SET @organization_default_assignee_landlord := (SELECT `default_assignee_landlord`
					FROM `uneet_enterprise_organizations` 
					WHERE `id_organization` = @organization_id_update_ext_area
					)
					;

				SET @area_default_assignee_landlord_raw := NEW.`landlord_default_assignee` ;

				SET @area_default_assignee_landlord :=  IF(@area_default_assignee_landlord_raw IS NULL
					, @organization_default_assignee_landlord
					, IF(@area_default_assignee_landlord_raw = ''
						, @organization_default_assignee_landlord
						, @area_default_assignee_landlord_raw
						)
					)
					;

			# Tenant ()
			
				SET @organization_default_assignee_tenant := (SELECT `default_assignee_tenant`
					FROM `uneet_enterprise_organizations` 
					WHERE `id_organization` = @organization_id_update_ext_area
					)
					;

				SET @area_default_assignee_tenant_raw := NEW.`tenant_default_assignee` ;

				SET @area_default_assignee_tenant := IF(@area_default_assignee_tenant_raw IS NULL
					, @organization_default_assignee_tenant
					, IF(@area_default_assignee_tenant_raw = ''
						, @organization_default_assignee_tenant
						, @area_default_assignee_tenant_raw
						)
					)
					;
			
			# Agent ()
			
				SET @organization_default_assignee_agent := (SELECT `default_assignee_agent`
					FROM `uneet_enterprise_organizations` 
					WHERE `id_organization` = @organization_id_update_ext_area
					)
					;

				SET @area_default_assignee_agent_raw := NEW.`agent_default_assignee` ;

				SET @area_default_assignee_agent :=  IF(@area_default_assignee_agent_raw IS NULL
					, @organization_default_assignee_agent
					, IF(@area_default_assignee_agent_raw = ''
						, @organization_default_assignee_agent
						, @area_default_assignee_agent_raw
						)
					)
					;

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

############
#
# L1P
#
############


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

		# Default assignees:

			# Mgt Cny (4)

				SET @area_default_assignee_mgt_cny := (SELECT `mgt_cny_default_assignee`
					FROM `external_property_groups_areas` 
					WHERE `id_area` = @area_id_1_insert_extl1
					)
					;

				SET @ext_l1_default_assignee_mgt_cny_raw := NEW.`mgt_cny_default_assignee` ;

				SET @ext_l1_default_assignee_mgt_cny :=  IF(@ext_l1_default_assignee_mgt_cny_raw IS NULL
					, @area_default_assignee_mgt_cny
					, IF(@ext_l1_default_assignee_mgt_cny_raw = ''
						, @area_default_assignee_mgt_cny
						, @ext_l1_default_assignee_mgt_cny_raw
						)
					)
					;

			# Landlord ()

				SET @area_default_assignee_landlord := (SELECT `landlord_default_assignee`
					FROM `external_property_groups_areas` 
					WHERE `id_area` = @area_id_1_insert_extl1
					)
					;

				SET @ext_l1_default_assignee_landlord_raw := NEW.`landlord_default_assignee` ;

				SET @ext_l1_default_assignee_landlord :=  IF(@ext_l1_default_assignee_landlord_raw IS NULL
					, @area_default_assignee_landlord
					, IF(@ext_l1_default_assignee_landlord_raw = ''
						, @area_default_assignee_landlord
						, @ext_l1_default_assignee_landlord_raw
						)
					)
					;

			# Tenant ()
			
				SET @area_default_assignee_tenant := (SELECT `tenant_default_assignee`
					FROM `external_property_groups_areas` 
					WHERE `id_area` = @area_id_1_insert_extl1
					)
					;

				SET @ext_l1_default_assignee_tenant_raw := NEW.`tenant_default_assignee` ;

				SET @ext_l1_default_assignee_tenant := IF(@ext_l1_default_assignee_tenant_raw IS NULL
					, @area_default_assignee_tenant
					, IF(@ext_l1_default_assignee_tenant_raw = ''
						, @area_default_assignee_tenant
						, @ext_l1_default_assignee_tenant_raw
						)
					)
					;
			
			# Agent ()
			
				SET @area_default_assignee_agent := (SELECT `agent_default_assignee`
					FROM `external_property_groups_areas` 
					WHERE `id_area` = @area_id_1_insert_extl1
					)
					;

				SET @ext_l1_default_assignee_agent_raw := NEW.`agent_default_assignee` ;

				SET @ext_l1_default_assignee_agent :=  IF(@ext_l1_default_assignee_agent_raw IS NULL
					, @area_default_assignee_agent
					, IF(@ext_l1_default_assignee_agent_raw = ''
						, @area_default_assignee_agent
						, @ext_l1_default_assignee_agent_raw
						)
					)
					;

		# Parent details

			SET @ext_l1_parent_system_id_raw := NEW.`area_external_system` ;
			SET @ext_l1_parent_table_raw := NEW.`area_external_table` ;
			SET @ext_l1_parent_external_id_raw := NEW.`area_external_id` ;

####################################################
#
# WIP account for the scenario where value = ''
#
####################################################

			SET @ext_l1_parent_system_id := IF(@ext_l1_parent_system_id_raw IS NULL
					, (SELECT `external_system_id` 
						FROM `external_property_groups_areas`
						WHERE `id_area` = @area_id_1_insert_extl1
						)
					, @ext_l1_parent_system_id_raw
				)
				;
			SET @ext_l1_parent_table := IF(@ext_l1_parent_table_raw IS NULL
					, (SELECT `external_table` 
						FROM `external_property_groups_areas`
						WHERE `id_area` = @area_id_1_insert_extl1
						)
					, @ext_l1_parent_table_raw
				)
				;
			SET @ext_l1_parent_external_id := IF(@ext_l1_parent_external_id_raw IS NULL
					, (SELECT `external_id` 
						FROM `external_property_groups_areas`
						WHERE `id_area` = @area_id_1_insert_extl1
						)
					, @ext_l1_parent_external_id_raw
				)
				;

####################################################
#
# END WIP account for the scenario where value = ''
#
####################################################

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
			, `area_external_system`
			, `area_external_table`
			, `area_external_id`
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
				, @ext_l1_parent_system_id
				, @ext_l1_parent_table
				, @ext_l1_parent_external_id
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
				, `area_external_system` = @ext_l1_parent_system_id
				, `area_external_table` = @ext_l1_parent_table
				, `area_external_id` = @ext_l1_parent_external_id
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

		# Default assignees:

			# Mgt Cny (4)

				SET @area_default_assignee_mgt_cny := (SELECT `mgt_cny_default_assignee`
					FROM `external_property_groups_areas` 
					WHERE `id_area` = @area_id_1_update_extl1
					)
					;

				SET @ext_l1_default_assignee_mgt_cny_raw := NEW.`mgt_cny_default_assignee` ;

				SET @ext_l1_default_assignee_mgt_cny :=  IF(@ext_l1_default_assignee_mgt_cny_raw IS NULL
					, @area_default_assignee_mgt_cny
					, IF(@ext_l1_default_assignee_mgt_cny_raw = ''
						, @area_default_assignee_mgt_cny
						, @ext_l1_default_assignee_mgt_cny_raw
						)
					)
					;

			# Landlord ()

				SET @area_default_assignee_landlord := (SELECT `landlord_default_assignee`
					FROM `external_property_groups_areas` 
					WHERE `id_area` = @area_id_1_update_extl1
					)
					;

				SET @ext_l1_default_assignee_landlord_raw := NEW.`landlord_default_assignee` ;

				SET @ext_l1_default_assignee_landlord :=  IF(@ext_l1_default_assignee_landlord_raw IS NULL
					, @area_default_assignee_landlord
					, IF(@ext_l1_default_assignee_landlord_raw = ''
						, @area_default_assignee_landlord
						, @ext_l1_default_assignee_landlord_raw
						)
					)
					;

			# Tenant ()
			
				SET @area_default_assignee_tenant := (SELECT `tenant_default_assignee`
					FROM `external_property_groups_areas` 
					WHERE `id_area` = @area_id_1_update_extl1
					)
					;

				SET @ext_l1_default_assignee_tenant_raw := NEW.`tenant_default_assignee` ;

				SET @ext_l1_default_assignee_tenant := IF(@ext_l1_default_assignee_tenant_raw IS NULL
					, @area_default_assignee_tenant
					, IF(@ext_l1_default_assignee_tenant_raw = ''
						, @area_default_assignee_tenant
						, @ext_l1_default_assignee_tenant_raw
						)
					)
					;
			
			# Agent ()
			
				SET @area_default_assignee_agent := (SELECT `agent_default_assignee`
					FROM `external_property_groups_areas` 
					WHERE `id_area` = @area_id_1_update_extl1
					)
					;

				SET @ext_l1_default_assignee_agent_raw := NEW.`agent_default_assignee` ;

				SET @ext_l1_default_assignee_agent :=  IF(@ext_l1_default_assignee_agent_raw IS NULL
					, @area_default_assignee_agent
					, IF(@ext_l1_default_assignee_agent_raw = ''
						, @area_default_assignee_agent
						, @ext_l1_default_assignee_agent_raw
						)
					)
					;

		# Parent details

			SET @ext_l1_parent_system_id_raw := NEW.`area_external_system` ;
			SET @ext_l1_parent_table_raw := NEW.`area_external_table` ;
			SET @ext_l1_parent_external_id_raw := NEW.`area_external_id` ;

####################################################
#
# WIP account for the scenario where value = ''
#
####################################################

			SET @ext_l1_parent_system_id := IF(@ext_l1_parent_system_id_raw IS NULL
					, (SELECT `external_system_id` 
						FROM `external_property_groups_areas`
						WHERE `id_area` = @area_id_1_update_extl1
						)
					, @ext_l1_parent_system_id_raw
				)
				;
			SET @ext_l1_parent_table := IF(@ext_l1_parent_table_raw IS NULL
					, (SELECT `external_table` 
						FROM `external_property_groups_areas`
						WHERE `id_area` = @area_id_1_update_extl1
						)
					, @ext_l1_parent_table_raw
				)
				;
			SET @ext_l1_parent_external_id := IF(@ext_l1_parent_external_id_raw IS NULL
					, (SELECT `external_id` 
						FROM `external_property_groups_areas`
						WHERE `id_area` = @area_id_1_update_extl1
						)
					, @ext_l1_parent_external_id_raw
				)
				;

####################################################
#
# END WIP account for the scenario where value = ''
#
####################################################

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
					, `area_external_system`
					, `area_external_table`
					, `area_external_id`
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
						, @ext_l1_parent_system_id
						, @ext_l1_parent_table
						, @ext_l1_parent_external_id
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
						, `area_external_system` = @ext_l1_parent_system_id
						, `area_external_table` = @ext_l1_parent_table
						, `area_external_id` = @ext_l1_parent_external_id
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
					, `area_external_system`
					, `area_external_table`
					, `area_external_id`
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
						, @ext_l1_parent_system_id
						, @ext_l1_parent_table
						, @ext_l1_parent_external_id
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
						, `area_external_system` = @ext_l1_parent_system_id
						, `area_external_table` = @ext_l1_parent_table
						, `area_external_id` = @ext_l1_parent_external_id
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

		SET @l1_parent_system_id := NEW.`area_external_system` ;
		SET @l1_parent_table := NEW.`area_external_table` ;
		SET @l1_parent_external_id := NEW.`area_external_id` ;

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
				, `parent_external_system`
				, `parent_external_table`
				, `parent_external_id`
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
					, @l1_parent_system_id
					, @l1_parent_table
					, @l1_parent_external_id
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
					, `parent_external_system` = @l1_parent_system_id
					, `parent_external_table` = @l1_parent_table
					, `parent_external_id` = @l1_parent_external_id
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

		SET @l1_parent_system_id := NEW.`area_external_system` ;
		SET @l1_parent_table := NEW.`area_external_table` ;
		SET @l1_parent_external_id := NEW.`area_external_id` ;
		
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
					, `parent_external_system`
					, `parent_external_table`
					, `parent_external_id`
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
						, @l1_parent_system_id
						, @l1_parent_table
						, @l1_parent_external_id
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
						, `parent_external_system` = @l1_parent_system_id
						, `parent_external_table` = @l1_parent_table
						, `parent_external_id` = @l1_parent_external_id
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
						, `parent_external_system` = @l1_parent_system_id
						, `parent_external_table` = @l1_parent_table
						, `parent_external_id` = @l1_parent_external_id
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


############
#
# L2P
#
############

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

		# Default assignees:

			# Mgt Cny (4)

				SET @ext_l1_default_assignee_mgt_cny := (SELECT `mgt_cny_default_assignee`
					FROM `external_property_level_1_buildings` 
					WHERE `id_building` = @building_id_1_insert_extl2
					)
					;

				SET @ext_l2_default_assignee_mgt_cny_raw := NEW.`mgt_cny_default_assignee` ;

				SET @ext_l2_default_assignee_mgt_cny :=  IF(@ext_l2_default_assignee_mgt_cny_raw IS NULL
					, @ext_l1_default_assignee_mgt_cny
					, IF(@ext_l2_default_assignee_mgt_cny_raw = ''
						, @ext_l1_default_assignee_mgt_cny
						, @ext_l2_default_assignee_mgt_cny_raw
						)
					)
					;

			# Landlord ()

				SET @ext_l1_default_assignee_landlord := (SELECT `landlord_default_assignee`
					FROM `external_property_level_1_buildings` 
					WHERE `id_building` = @building_id_1_insert_extl2
					)
					;

				SET @ext_l2_default_assignee_landlord_raw := NEW.`landlord_default_assignee` ;

				SET @ext_l2_default_assignee_landlord :=  IF(@ext_l2_default_assignee_landlord_raw IS NULL
					, @ext_l1_default_assignee_landlord
					, IF(@ext_l2_default_assignee_landlord_raw = ''
						, @ext_l1_default_assignee_landlord
						, @ext_l2_default_assignee_landlord_raw
						)
					)
					;

			# Tenant ()
			
				SET @ext_l1_default_assignee_tenant := (SELECT `tenant_default_assignee`
					FROM `external_property_level_1_buildings` 
					WHERE `id_building` = @building_id_1_insert_extl2
					)
					;

				SET @ext_l2_default_assignee_tenant_raw := NEW.`tenant_default_assignee` ;

				SET @ext_l2_default_assignee_tenant :=IF(@ext_l2_default_assignee_tenant_raw IS NULL
					, @ext_l1_default_assignee_tenant
					, IF(@ext_l2_default_assignee_tenant_raw = ''
						, @ext_l1_default_assignee_tenant
						, @ext_l2_default_assignee_tenant_raw
						)
					)
					;
			
			# Agent ()
			
				SET @ext_l1_default_assignee_agent := (SELECT `agent_default_assignee`
					FROM `external_property_level_1_buildings` 
					WHERE `id_building` = @building_id_1_insert_extl2
					)
					;

				SET @ext_l2_default_assignee_agent_raw := NEW.`agent_default_assignee` ;

				SET @ext_l2_default_assignee_agent := IF(@ext_l2_default_assignee_agent_raw IS NULL
					, @ext_l1_default_assignee_agent
					, IF(@ext_l2_default_assignee_agent_raw = ''
						, @ext_l1_default_assignee_agent
						, @ext_l2_default_assignee_agent_raw
						)
					)
					;

		# Parent details

			SET @ext_l2_parent_system_id_raw := NEW.`l1p_external_system` ;
			SET @ext_l2_parent_table_raw := NEW.`l1p_external_table` ;
			SET @ext_l2_parent_external_id_raw := NEW.`l1p_external_id` ;

####################################################
#
# WIP account for the scenario where value = ''
#
####################################################

			SET @ext_l2_parent_system_id := IF(@ext_l2_parent_system_id_raw IS NULL
					, (SELECT `external_system_id` 
						FROM `external_property_level_1_buildings`
						WHERE `id_building` = @building_id_1_insert_extl2
						)
					, @ext_l2_parent_system_id_raw
				)
				;
			SET @ext_l2_parent_table := IF(@ext_l2_parent_table_raw IS NULL
					, (SELECT `external_table` 
						FROM `external_property_level_1_buildings`
						WHERE `id_building` = @building_id_1_insert_extl2
						)
					, @ext_l2_parent_table_raw
				)
				;
			SET @ext_l2_parent_external_id := IF(@ext_l2_parent_external_id_raw IS NULL
					, (SELECT `external_id` 
						FROM `external_property_level_1_buildings`
						WHERE `id_building` = @building_id_1_insert_extl2
						)
					, @ext_l2_parent_external_id_raw
				)
				;

####################################################
#
# END WIP account for the scenario where value = ''
#
####################################################

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
			, `l1p_external_system`
			, `l1p_external_table`
			, `l1p_external_id`
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
				, @ext_l2_parent_system_id
				, @ext_l2_parent_table
				, @ext_l2_parent_external_id
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
				, `l1p_external_system` = @ext_l2_parent_system_id
				, `l1p_external_table` = @ext_l2_parent_table
				, `l1p_external_id` = @ext_l2_parent_external_id
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

		# Default assignees:

			# Mgt Cny (4)

				SET @ext_l1_default_assignee_mgt_cny := (SELECT `mgt_cny_default_assignee`
					FROM `external_property_level_1_buildings` 
					WHERE `id_building` = @building_id_1_update_extl2
					)
					;

				SET @ext_l2_default_assignee_mgt_cny_raw := NEW.`mgt_cny_default_assignee` ;

				SET @ext_l2_default_assignee_mgt_cny :=  IF(@ext_l2_default_assignee_mgt_cny_raw IS NULL
					, @ext_l1_default_assignee_mgt_cny
					, IF(@ext_l2_default_assignee_mgt_cny_raw = ''
						, @ext_l1_default_assignee_mgt_cny
						, @ext_l2_default_assignee_mgt_cny_raw
						)
					)
					;

			# Landlord ()

				SET @ext_l1_default_assignee_landlord := (SELECT `landlord_default_assignee`
					FROM `external_property_level_1_buildings` 
					WHERE `id_building` = @building_id_1_update_extl2
					)
					;

				SET @ext_l2_default_assignee_landlord_raw := NEW.`landlord_default_assignee` ;

				SET @ext_l2_default_assignee_landlord :=  IF(@ext_l2_default_assignee_landlord_raw IS NULL
					, @ext_l1_default_assignee_landlord
					, IF(@ext_l2_default_assignee_landlord_raw = ''
						, @ext_l1_default_assignee_landlord
						, @ext_l2_default_assignee_landlord_raw
						)
					)
					;

			# Tenant ()
			
				SET @ext_l1_default_assignee_tenant := (SELECT `tenant_default_assignee`
					FROM `external_property_level_1_buildings` 
					WHERE `id_building` = @building_id_1_update_extl2
					)
					;

				SET @ext_l2_default_assignee_tenant_raw := NEW.`tenant_default_assignee` ;

				SET @ext_l2_default_assignee_tenant :=IF(@ext_l2_default_assignee_tenant_raw IS NULL
					, @ext_l1_default_assignee_tenant
					, IF(@ext_l2_default_assignee_tenant_raw = ''
						, @ext_l1_default_assignee_tenant
						, @ext_l2_default_assignee_tenant_raw
						)
					)
					;
			
			# Agent ()
			
				SET @ext_l1_default_assignee_agent := (SELECT `agent_default_assignee`
					FROM `external_property_level_1_buildings` 
					WHERE `id_building` = @building_id_1_update_extl2
					)
					;

				SET @ext_l2_default_assignee_agent_raw := NEW.`agent_default_assignee` ;

				SET @ext_l2_default_assignee_agent := IF(@ext_l2_default_assignee_agent_raw IS NULL
					, @ext_l1_default_assignee_agent
					, IF(@ext_l2_default_assignee_agent_raw = ''
						, @ext_l1_default_assignee_agent
						, @ext_l2_default_assignee_agent_raw
						)
					)
					;

		# Parent details

			SET @ext_l2_parent_system_id_raw := NEW.`l1p_external_system` ;
			SET @ext_l2_parent_table_raw := NEW.`l1p_external_table` ;
			SET @ext_l2_parent_external_id_raw := NEW.`l1p_external_id` ;

####################################################
#
# WIP account for the scenario where value = ''
#
####################################################

			SET @ext_l2_parent_system_id := IF(@ext_l2_parent_system_id_raw IS NULL
					, (SELECT `external_system_id` 
						FROM `external_property_level_1_buildings`
						WHERE `id_building` = @building_id_1_update_extl2
						)
					, @ext_l2_parent_system_id_raw
				)
				;
			SET @ext_l2_parent_table := IF(@ext_l2_parent_table_raw IS NULL
					, (SELECT `external_table` 
						FROM `external_property_level_1_buildings`
						WHERE `id_building` = @building_id_1_update_extl2
						)
					, @ext_l2_parent_table_raw
				)
				;
			SET @ext_l2_parent_external_id := IF(@ext_l2_parent_external_id_raw IS NULL
					, (SELECT `external_id` 
						FROM `external_property_level_1_buildings`
						WHERE `id_building` = @building_id_1_update_extl2
						)
					, @ext_l2_parent_external_id_raw
				)
				;

####################################################
#
# END WIP account for the scenario where value = ''
#
####################################################

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
					, `l1p_external_system`
					, `l1p_external_table`
					, `l1p_external_id`
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
						, @ext_l2_parent_system_id
						, @ext_l2_parent_table
						, @ext_l2_parent_external_id
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
						, `l1p_external_system` = @ext_l2_parent_system_id
						, `l1p_external_table` = @ext_l2_parent_table
						, `l1p_external_id` = @ext_l2_parent_external_id
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
					, `l1p_external_system`
					, `l1p_external_table`
					, `l1p_external_id`
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
						, @ext_l2_parent_system_id
						, @ext_l2_parent_table
						, @ext_l2_parent_external_id
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
						, `l1p_external_system` = @ext_l2_parent_system_id
						, `l1p_external_table` = @ext_l2_parent_table
						, `l1p_external_id` = @ext_l2_parent_external_id
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

			SET @l2_parent_system_id := NEW.`l1p_external_system` ;
			SET @l2_parent_table := NEW.`l1p_external_table` ;
			SET @l2_parent_external_id := NEW.`l1p_external_id` ;

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
				, `parent_external_system`
				, `parent_external_table`
				, `parent_external_id`
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
					, @l2_parent_system_id
					, @l2_parent_table
					, @l2_parent_external_id
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
					, `parent_external_system` = @l2_parent_system_id
					, `parent_external_table` = @l2_parent_table
					, `parent_external_id` = @l2_parent_external_id
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

		SET @l2_parent_system_id := NEW.`l1p_external_system` ;
		SET @l2_parent_table := NEW.`l1p_external_table` ;
		SET @l2_parent_external_id := NEW.`l1p_external_id` ;

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
					, `parent_external_system`
					, `parent_external_table`
					, `parent_external_id`
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
						, @l2_parent_system_id
						, @l2_parent_table
						, @l2_parent_external_id
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
						, `parent_external_system` = @l2_parent_system_id
						, `parent_external_table` = @l2_parent_table
						, `parent_external_id` = @l2_parent_external_id
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
						, `parent_external_system` = @l2_parent_system_id
						, `parent_external_table` = @l2_parent_table
						, `parent_external_id` = @l2_parent_external_id
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


############
#
# L3P
#
############

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

		# Default assignees:

			# Mgt Cny (4)

				SET @ext_l2_default_assignee_mgt_cny := (SELECT `mgt_cny_default_assignee`
					FROM `external_property_level_2_units` 
					WHERE `system_id_unit` = @unit_id_1_insert_extl3_1
					)
					;

				SET @ext_l3_default_assignee_mgt_cny_raw := NEW.`mgt_cny_default_assignee` ;

				SET @ext_l3_default_assignee_mgt_cny :=  IF(@ext_l3_default_assignee_mgt_cny_raw IS NULL
					, @ext_l2_default_assignee_mgt_cny
					, IF(@ext_l3_default_assignee_mgt_cny_raw = ''
						, @ext_l2_default_assignee_mgt_cny
						, @ext_l3_default_assignee_mgt_cny_raw
						)
					)
					;

			# Landlord ()

				SET @ext_l2_default_assignee_landlord := (SELECT `landlord_default_assignee`
					FROM `external_property_level_2_units` 
					WHERE `system_id_unit` = @unit_id_1_insert_extl3_1
					)
					;

				SET @ext_l3_default_assignee_landlord_raw := NEW.`landlord_default_assignee` ;

				SET @ext_l3_default_assignee_landlord :=  IF(@ext_l3_default_assignee_landlord_raw IS NULL
					, @ext_l2_default_assignee_landlord
					, IF(@ext_l3_default_assignee_landlord_raw = ''
						, @ext_l2_default_assignee_landlord
						, @ext_l3_default_assignee_landlord_raw
						)
					)
					;

			# Tenant ()
			
				SET @ext_l2_default_assignee_tenant := (SELECT `tenant_default_assignee`
					FROM `external_property_level_2_units` 
					WHERE `system_id_unit` = @unit_id_1_insert_extl3_1
					)
					;

				SET @ext_l3_default_assignee_tenant_raw := NEW.`tenant_default_assignee` ;

				SET @ext_l3_default_assignee_tenant :=IF(@ext_l3_default_assignee_tenant_raw IS NULL
					, @ext_l2_default_assignee_tenant
					, IF(@ext_l3_default_assignee_tenant_raw = ''
						, @ext_l2_default_assignee_tenant
						, @ext_l3_default_assignee_tenant_raw
						)
					)
					;
			
			# Agent ()
			
				SET @ext_l2_default_assignee_agent := (SELECT `agent_default_assignee`
					FROM `external_property_level_2_units` 
					WHERE `system_id_unit` = @unit_id_1_insert_extl3_1
					)
					;

				SET @ext_l3_default_assignee_agent_raw := NEW.`agent_default_assignee` ;

				SET @ext_l3_default_assignee_agent := IF(@ext_l3_default_assignee_agent_raw IS NULL
					, @ext_l2_default_assignee_agent
					, IF(@ext_l3_default_assignee_agent_raw = ''
						, @ext_l2_default_assignee_agent
						, @ext_l3_default_assignee_agent_raw
						)
					)
					;

		# Parent details

			SET @ext_l3_parent_system_id_raw := NEW.`l2p_external_system` ;
			SET @ext_l3_parent_table_raw := NEW.`l2p_external_table` ;
			SET @ext_l3_parent_external_id_raw := NEW.`l2p_external_id` ;

####################################################
#
# WIP account for the scenario where value = ''
#
####################################################

			SET @ext_l3_parent_system_id := IF(@ext_l3_parent_system_id_raw IS NULL
					, (SELECT `external_system_id` 
						FROM `external_property_level_2_units`
						WHERE `system_id_unit` = @unit_id_1_insert_extl3_1
						)
					, @ext_l3_parent_system_id_raw
				)
				;
			SET @ext_l3_parent_table := IF(@ext_l3_parent_table_raw IS NULL
					, (SELECT `external_table` 
						FROM `external_property_level_2_units`
						WHERE `system_id_unit` = @unit_id_1_insert_extl3_1
						)
					, @ext_l3_parent_table_raw
				)
				;
			SET @ext_l3_parent_external_id := IF(@ext_l3_parent_external_id_raw IS NULL
					, (SELECT `external_id` 
						FROM `external_property_level_2_units`
						WHERE `system_id_unit` = @unit_id_1_insert_extl3_1
						)
					, @ext_l3_parent_external_id_raw
				)
				;

####################################################
#
# END WIP account for the scenario where value = ''
#
####################################################

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
			, `l2p_external_system`
			, `l2p_external_table`
			, `l2p_external_id`
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
				, @ext_l3_parent_system_id
				, @ext_l3_parent_table
				, @ext_l3_parent_external_id
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
				, `l2p_external_system` = @ext_l3_parent_system_id
				, `l2p_external_table` = @ext_l3_parent_table
				, `l2p_external_id` = @ext_l3_parent_external_id
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

		# Default assignees:

			# Mgt Cny (4)

				SET @ext_l2_default_assignee_mgt_cny := (SELECT `mgt_cny_default_assignee`
					FROM `external_property_level_2_units` 
					WHERE `system_id_unit` = @unit_id_1_update_extl3
					)
					;

				SET @ext_l3_default_assignee_mgt_cny_raw := NEW.`mgt_cny_default_assignee` ;

				SET @ext_l3_default_assignee_mgt_cny :=  IF(@ext_l3_default_assignee_mgt_cny_raw IS NULL
					, @ext_l2_default_assignee_mgt_cny
					, IF(@ext_l3_default_assignee_mgt_cny_raw = ''
						, @ext_l2_default_assignee_mgt_cny
						, @ext_l3_default_assignee_mgt_cny_raw
						)
					)
					;

			# Landlord ()

				SET @ext_l2_default_assignee_landlord := (SELECT `landlord_default_assignee`
					FROM `external_property_level_2_units` 
					WHERE `system_id_unit` = @unit_id_1_update_extl3
					)
					;

				SET @ext_l3_default_assignee_landlord_raw := NEW.`landlord_default_assignee` ;

				SET @ext_l3_default_assignee_landlord :=  IF(@ext_l3_default_assignee_landlord_raw IS NULL
					, @ext_l2_default_assignee_landlord
					, IF(@ext_l3_default_assignee_landlord_raw = ''
						, @ext_l2_default_assignee_landlord
						, @ext_l3_default_assignee_landlord_raw
						)
					)
					;

			# Tenant ()
			
				SET @ext_l2_default_assignee_tenant := (SELECT `tenant_default_assignee`
					FROM `external_property_level_2_units` 
					WHERE `system_id_unit` = @unit_id_1_update_extl3
					)
					;

				SET @ext_l3_default_assignee_tenant_raw := NEW.`tenant_default_assignee` ;

				SET @ext_l3_default_assignee_tenant :=IF(@ext_l3_default_assignee_tenant_raw IS NULL
					, @ext_l2_default_assignee_tenant
					, IF(@ext_l3_default_assignee_tenant_raw = ''
						, @ext_l2_default_assignee_tenant
						, @ext_l3_default_assignee_tenant_raw
						)
					)
					;
			
			# Agent ()
			
				SET @ext_l2_default_assignee_agent := (SELECT `agent_default_assignee`
					FROM `external_property_level_2_units` 
					WHERE `system_id_unit` = @unit_id_1_update_extl3
					)
					;

				SET @ext_l3_default_assignee_agent_raw := NEW.`agent_default_assignee` ;

				SET @ext_l3_default_assignee_agent := IF(@ext_l3_default_assignee_agent_raw IS NULL
					, @ext_l2_default_assignee_agent
					, IF(@ext_l3_default_assignee_agent_raw = ''
						, @ext_l2_default_assignee_agent
						, @ext_l3_default_assignee_agent_raw
						)
					)
					;

		# Parent details

			SET @ext_l3_parent_system_id_raw := NEW.`l2p_external_system` ;
			SET @ext_l3_parent_table_raw := NEW.`l2p_external_table` ;
			SET @ext_l3_parent_external_id_raw := NEW.`l2p_external_id` ;


####################################################
#
# WIP account for the scenario where value = ''
#
####################################################

			SET @ext_l3_parent_system_id := IF(@ext_l3_parent_system_id_raw IS NULL
				, (SELECT `external_system_id` 
						FROM `external_property_level_2_units`
						WHERE `system_id_unit` = @unit_id_1_update_extl3
					)
				, IF(@ext_l3_parent_system_id_raw = ''
					, (SELECT `external_system_id` 
						FROM `external_property_level_2_units`
						WHERE `system_id_unit` = @unit_id_1_update_extl3
						)
					, @ext_l3_parent_system_id_raw
					)
				)
				;

			SET @ext_l3_parent_table := IF(@ext_l3_parent_table_raw IS NULL
					, (SELECT `external_table` 
						FROM `external_property_level_2_units`
						WHERE `system_id_unit` = @unit_id_1_update_extl3
						)
					, @ext_l3_parent_table_raw
				)
				;

			SET @ext_l3_parent_external_id := IF(@ext_l3_parent_external_id_raw IS NULL
					, (SELECT `external_id` 
						FROM `external_property_level_2_units`
						WHERE `system_id_unit` = @unit_id_1_update_extl3
						)
					, @ext_l3_parent_external_id_raw
				)
				;

####################################################
#
# END WIP account for the scenario where value = ''
#
####################################################

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
						, `l2p_external_system`
						, `l2p_external_table`
						, `l2p_external_id`	
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
							, @ext_l3_parent_system_id
							, @ext_l3_parent_table
							, @ext_l3_parent_external_id
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
							, `l2p_external_system` = @ext_l3_parent_system_id
							, `l2p_external_table` = @ext_l3_parent_table
							, `l2p_external_id` = @ext_l3_parent_external_id
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
						, `l2p_external_system`
						, `l2p_external_table`
						, `l2p_external_id`	
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
							, @ext_l3_parent_system_id
							, @ext_l3_parent_table
							, @ext_l3_parent_external_id
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
							, `l2p_external_system` = @ext_l3_parent_system_id
							, `l2p_external_table` = @ext_l3_parent_table
							, `l2p_external_id` = @ext_l3_parent_external_id
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

		SET @l3_parent_system_id := NEW.`l2p_external_system` ;
		SET @l3_parent_table := NEW.`l2p_external_table` ;
		SET @l3_parent_external_id := NEW.`l2p_external_id` ;

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
				, `parent_external_system`
				, `parent_external_table`
				, `parent_external_id`
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
					, @l3_parent_system_id
					, @l3_parent_table
					, @l3_parent_external_id
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
					, `parent_external_system` = @l3_parent_system_id
					, `parent_external_table` = @l3_parent_table
					, `parent_external_id` = @l3_parent_external_id
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

		SET @l3_parent_system_id := NEW.`l2p_external_system` ;
		SET @l3_parent_table := NEW.`l2p_external_table` ;
		SET @l3_parent_external_id := NEW.`l2p_external_id` ;

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
					, `parent_external_system`
					, `parent_external_table`
					, `parent_external_id`
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
						, @l3_parent_system_id
						, @l3_parent_table
						, @l3_parent_external_id
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
						, `parent_external_system` = @l3_parent_system_id
						, `parent_external_table` = @l3_parent_table
						, `parent_external_id` = @l3_parent_external_id
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
						, `parent_external_system` = @l3_parent_system_id
						, `parent_external_table` = @l3_parent_table
						, `parent_external_id` = @l3_parent_external_id
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

# We do this LAST so everything is propagated to the other tables
#
# Update the tables with the parent id information:
# we use the info from the parent record for that
#	- `external_property_level_1_buildings`
#	- `external_property_level_2_units`
#	- `external_property_level_3_rooms`
#	- `property_level_1_buildings`
#	- `property_level_2_units`
#	- `property_level_3_rooms`
#	- `ut_map_external_source_units`

# Table `external_property_level_1_buildings`
	
	UPDATE `external_property_level_1_buildings` AS `a`
		INNER JOIN `external_property_groups_areas` AS `b` 
			ON (`a`.`area_id` = `b`.`id_area`)
	SET
		`a`.`area_external_system` = `b`.`external_system_id`
		, `a`.`area_external_table` = `b`.`external_table`
		, `a`.`area_external_id` = `b`.`external_id`
	;

# Table `external_property_level_2_units`

	UPDATE `external_property_level_2_units` AS `a`
		INNER JOIN `external_property_level_1_buildings` AS `b` 
			ON (`a`.`building_system_id` = `b`.`id_building`)
	SET
		`a`.`l1p_external_system` = `b`.`external_system_id`
		, `a`.`l1p_external_table` = `b`.`external_table`
		, `a`.`l1p_external_id` = `b`.`external_id`
	;

# Table `external_property_level_3_rooms`
	
	UPDATE `external_property_level_3_rooms` AS `a`
		INNER JOIN `external_property_level_2_units` AS `b` 
			ON (`a`.`system_id_unit` = `b`.`system_id_unit`)
	SET
		`a`.`l2p_external_system` = `b`.`external_system_id`
		, `a`.`l2p_external_table` = `b`.`external_table`
		, `a`.`l2p_external_id` = `b`.`external_id`
	;

# THIS IS OVERKILL SINCE THE ROUTINE PROPAGATES THIS
/*

# Table `property_level_1_buildings`
	
	UPDATE `external_property_level_1_buildings` AS `a`
		INNER JOIN `external_property_groups_areas` AS `b` 
			ON (`a`.`area_id` = `b`.`id_area`)
	SET
		`a`.`area_external_system` = `b`.`external_system_id`
		, `a`.`area_external_table` = `b`.`external_table`
		, `a`.`area_external_id` = `b`.`external_id`
	;

# Table `property_level_2_units`

	UPDATE `property_level_2_units` AS `a`
		INNER JOIN `property_level_1_buildings` AS `b` 
			ON (`a`.`building_system_id` = `b`.`id_building`)
	SET
		`a`.`l1p_external_system` = `b`.`external_system_id`
		, `a`.`l1p_external_table` = `b`.`external_table`
		, `a`.`l1p_external_id` = `b`.`external_id`
	;

# Table `property_level_3_rooms`
	
	UPDATE `property_level_3_rooms` AS `a`
		INNER JOIN `property_level_2_units` AS `b` 
			ON (`a`.`system_id_unit` = `b`.`system_id_unit`)
	SET
		`a`.`l2p_external_system` = `b`.`external_system_id`
		, `a`.`l2p_external_table` = `b`.`external_table`
		, `a`.`l2p_external_id` = `b`.`external_id`
	;

*/

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