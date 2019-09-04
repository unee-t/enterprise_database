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

	SET @old_schema_version := 'v1.22.5';
	SET @new_schema_version := 'v1.22.6';

# What is the name of this script?

	SET @this_script := CONCAT ('upgrade_unee-t_entreprise', @old_schema_version, '_to_', @new_schema_version, '.sql');

# In this update
#
#WIP	- Fix a bug where some of the level 2 properties are not assigned to users who should be assigned to all the properties in the country.
# For more details, see
# https://docs.google.com/document/d/1IyLZHC6nmmeOaTdDkswLUN4QbEC_BG_FfwwuWoNyF5E/edit?usp=sharing
#
#WIP	- Fix issue `sub-query returns more than one result`
#
#OK Make sure that we do NOT create the properties if they are marked as obsolete
#OK	- L1P (updated script `properties_level_1_creation_update_v1_22_6`)
#OK	- L2P (updated script `properties_level_2_creation_update_v1_22_6`)
#OK	- L3P (updated script `properties_level_3_creation_update_v1_22_6`)
#
# L1P:
#	- Break up 2 similar triggers
#OK		- `ut_update_external_property_level_1`
#OK		- `ut_update_external_property_level_1_creation_needed`
#	- Instead, we use a single trigger:
#OK		- Trigger `ut_after_update_external_property_level_1` 
#
#	- Break up 2 similar triggers
#OK		- `ut_update_map_external_source_unit_edit_level_1`
#OK		- `ut_update_map_external_source_unit_add_building_creation_needed`
#	- Instead, we use a single trigger:
#OK		- Trigger `ut_after_update_property_level_1` 
#
# L2P:
#	- Break up 2 similar triggers
#		- `ut_update_external_property_level_2`
#		- `ut_update_external_property_level_2_creation_needed`
#	- Instead, we use a single trigger:
#OK		- Trigger `ut_after_update_external_property_level_2` 
#
#	- Break up 2 similar triggers
#		- `ut_update_map_external_source_unit_edit_level_2`
#		- `ut_update_map_external_source_unit_add_unit_creation_needed`
#	- Instead, we use a single trigger:
#OK		- Trigger `ut_after_update_property_level_2` 
#
# L3P
#	- Break up 2 similar triggers
#		- `ut_update_external_property_level_3`
#		- `ut_update_external_property_level_3_creation_needed`
#OK		- Trigger `ut_after_update_external_property_level_3` 
#
#	- Break up 2 similar triggers
#		- `ut_update_map_external_source_unit_edit_level_2`
#		- `ut_update_map_external_source_unit_add_unit_creation_needed`
#	- Instead, we use a single trigger:
#OK		- Trigger `ut_after_update_property_level_3` 
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

	DROP TRIGGER IF EXISTS `ut_update_external_property_level_1`;
	DROP TRIGGER IF EXISTS `ut_update_external_property_level_1_creation_needed`;

	DROP TRIGGER IF EXISTS `ut_update_map_external_source_unit_edit_level_1`;
	DROP TRIGGER IF EXISTS `ut_update_map_external_source_unit_add_building_creation_needed`;

	DROP TRIGGER IF EXISTS `ut_update_external_property_level_2`;
	DROP TRIGGER IF EXISTS `ut_update_external_property_level_2_creation_needed`;
	
	DROP TRIGGER IF EXISTS `ut_update_map_external_source_unit_edit_level_2`;
	DROP TRIGGER IF EXISTS `ut_update_map_external_source_unit_add_unit_creation_needed`;
	
	DROP TRIGGER IF EXISTS `ut_update_external_property_level_3`;
	DROP TRIGGER IF EXISTS `ut_update_external_property_level_3_creation_needed`;

	DROP TRIGGER IF EXISTS `ut_update_map_external_source_unit_add_room`;
	DROP TRIGGER IF EXISTS `ut_update_map_external_source_unit_add_room_creation_needed`;

# Re-create all the procedures for L1P

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

	DROP TRIGGER IF EXISTS `ut_insert_external_property_level_1`;

DELIMITER $$
CREATE TRIGGER `ut_insert_external_property_level_1`
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

	SET @is_creation_needed_in_unee_t_insert_extl1_1 = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator_insert_extl1_1 = NEW.`created_by_id` ;
	SET @source_system_updater_insert_extl1_1 = (IF(NEW.`updated_by_id` IS NULL
			, @source_system_creator_insert_extl1_1
			, NEW.`updated_by_id`
			)
		);

	SET @creator_mefe_user_id_insert_extl1_1 = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator_insert_extl1_1
		)
		;

	SET @upstream_create_method_insert_extl1_1 = NEW.`creation_method` ;
	SET @upstream_update_method_insert_extl1_1 = NEW.`update_method` ;

	SET @external_system_id_insert_extl1_1 = NEW.`external_system_id` ; 
	SET @external_table_insert_extl1_1 = NEW.`external_table` ;
	SET @external_id_insert_extl1_1 = NEW.`external_id` ;
	SET @tower_insert_extl1_1 = NEW.`tower` ;

	SET @organization_id_insert_extl1_1 = @source_system_creator_insert_extl1_1 ;

	SET @id_in_property_level_1_buildings_insert_extl1_1 = (SELECT `id_building`
		FROM `property_level_1_buildings`
		WHERE `external_system_id` = @external_system_id_insert_extl1_1
			AND `external_table` = @external_table_insert_extl1_1
			AND `external_id` = @external_id_insert_extl1_1
			AND `tower` = @tower_insert_extl1_1
			AND `organization_id` = @organization_id_insert_extl1_1
		);

	SET @upstream_do_not_insert_insert_extl1_1 = NEW.`do_not_insert` ;

	# This is an INSERT - the record should NOT exist already

		SET @do_not_insert_insert_extl1_1 = (IF (@id_in_property_level_1_buildings_insert_extl1_1 IS NULL
				, 0
				, @upstream_do_not_insert_insert_extl1_1
				)
			);

	# Get the information about the area for that building...
	# We need the information from the table `property_groups_areas` (and NOT the table `external_property_groups_areas`)

		SET @area_id_1_insert_extl1_1 = NEW.`area_id` ;

		SET @area_external_id_insert_extl1_1 = (SELECT `external_id`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_1_insert_extl1_1
			);
		SET @area_external_system_id_insert_extl1_1 = (SELECT `external_system_id`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_1_insert_extl1_1
			);
		SET @area_external_table_insert_extl1_1 = (SELECT `external_table`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_1_insert_extl1_1
			);

		SET @area_id_2_insert_extl1_1 = (SELECT `id_area`
			FROM `property_groups_areas`
			WHERE `external_id` = @area_external_id_insert_extl1_1
				AND `external_system_id` = @area_external_system_id_insert_extl1_1
			   	AND `external_table` = @area_external_table_insert_extl1_1
			   	AND `organization_id` = @organization_id_insert_extl1_1
			);

	IF @is_creation_needed_in_unee_t_insert_extl1_1 = 1
		AND @do_not_insert_insert_extl1_1 = 0
		AND @external_id_insert_extl1_1 IS NOT NULL
		AND @external_system_id_insert_extl1_1 IS NOT NULL
		AND @external_table_insert_extl1_1 IS NOT NULL
		AND @tower_insert_extl1_1 IS NOT NULL
		AND @organization_id_insert_extl1_1 IS NOT NULL
		AND @area_id_2_insert_extl1_1 IS NOT NULL
		AND 
		(@upstream_create_method_insert_extl1_1 = 'imported_from_hmlet_ipi'
			OR @upstream_create_method_insert_extl1_1 = 'Manage_Buildings_Add_Page'
			OR @upstream_create_method_insert_extl1_1 = 'Manage_Buildings_Edit_Page'
			OR @upstream_create_method_insert_extl1_1 = 'Manage_Buildings_Import_Page'
			OR @upstream_create_method_insert_extl1_1 = 'Export_and_Import_Buildings_Import_Page'
			OR @upstream_update_method_insert_extl1_1 = 'imported_from_hmlet_ipi'
			OR @upstream_update_method_insert_extl1_1 = 'Manage_Buildings_Add_Page'
			OR @upstream_update_method_insert_extl1_1 = 'Manage_Buildings_Edit_Page'
			OR @upstream_update_method_insert_extl1_1 = 'Manage_Buildings_Import_Page'
			OR @upstream_update_method_insert_extl1_1 = 'Export_and_Import_Buildings_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `property_level_1_buildings` table:

		SET @this_trigger_insert_extl1_1 := 'ut_insert_external_property_level_1' ;

		SET @syst_created_datetime_insert_extl1_1 = NOW();
		SET @creation_system_id_insert_extl1_1 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator_insert_extl1_1
			)
			;
		SET @created_by_id_insert_extl1_1 = @creator_mefe_user_id_insert_extl1_1 ;
		SET @downstream_creation_method_insert_extl1_1 = @this_trigger_insert_extl1_1 ;

		SET @syst_updated_datetime_insert_extl1_1 = NOW();

		SET @update_system_id_insert_extl1_1 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater_insert_extl1_1
			)
			;
		SET @updated_by_id_insert_extl1_1 = @creator_mefe_user_id_insert_extl1_1 ;
		SET @downstream_update_method_insert_extl1_1 = @this_trigger_insert_extl1_1 ;

		SET @organization_id_create_insert_extl1_1 = @source_system_creator_insert_extl1_1 ;
		SET @organization_id_update_insert_extl1_1 = @source_system_updater_insert_extl1_1;

		SET @is_obsolete_insert_extl1_1 = NEW.`is_obsolete` ;
		SET @order_insert_extl1_1 = NEW.`order` ;

		SET @unee_t_unit_type_insert_extl1_1 = NEW.`unee_t_unit_type` ;
		SET @designation_insert_extl1_1 = NEW.`designation` ;

		SET @address_1_insert_extl1_1 = NEW.`address_1` ;
		SET @address_2_insert_extl1_1 = NEW.`address_2` ;
		SET @zip_postal_code_insert_extl1_1 = NEW.`zip_postal_code` ;
		SET @state_insert_extl1_1 = NEW.`state` ;
		SET @city_insert_extl1_1 = NEW.`city` ;
		SET @country_code_insert_extl1_1 = NEW.`country_code` ;

		SET @description_insert_extl1_1 = NEW.`description` ;

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
				(@external_id_insert_extl1_1
				, @external_system_id_insert_extl1_1
				, @external_table_insert_extl1_1
				, @syst_created_datetime_insert_extl1_1
				, @creation_system_id_insert_extl1_1
				, @created_by_id_insert_extl1_1
				, @downstream_creation_method_insert_extl1_1
				, @organization_id_create_insert_extl1_1
				, @is_obsolete_insert_extl1_1
				, @order_insert_extl1_1
				, @area_id_2_insert_extl1_1
				, @is_creation_needed_in_unee_t_insert_extl1_1
				, @do_not_insert_insert_extl1_1_insert_extl1_1
				, @unee_t_unit_type_insert_extl1_1
				, @designation_insert_extl1_1
				, @tower_insert_extl1_1
				, @address_1_insert_extl1_1
				, @address_2_insert_extl1_1
				, @zip_postal_code_insert_extl1_1
				, @state_insert_extl1_1
				, @city_insert_extl1_1
				, @country_code_insert_extl1_1
				, @description_insert_extl1_1
				)
			ON DUPLICATE KEY UPDATE
				`syst_updated_datetime` = @syst_updated_datetime_insert_extl1_1
				, `update_system_id` = @update_system_id_insert_extl1_1
				, `updated_by_id` = @updated_by_id_insert_extl1_1
				, `update_method` = @downstream_update_method_insert_extl1_1
				, `organization_id` = @organization_id_update_insert_extl1_1
				, `is_obsolete` = @is_obsolete_insert_extl1_1
				, `order` = @order_insert_extl1_1
				, `area_id` = @area_id_2_insert_extl1_1
				, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t_insert_extl1_1
				, `do_not_insert` = @do_not_insert_insert_extl1_1
				, `unee_t_unit_type` = @unee_t_unit_type_insert_extl1_1
				, `designation` = @designation_insert_extl1_1
				, `tower` = @tower_insert_extl1_1
				, `address_1` = @address_1_insert_extl1_1
				, `address_2` = @address_2_insert_extl1_1
				, `zip_postal_code` = @zip_postal_code_insert_extl1_1
				, `state` = @state_insert_extl1_1
				, `city` = @city_insert_extl1_1
				, `country_code` = @country_code_insert_extl1_1
				, `description` = @description_insert_extl1_1
			;

	END IF;

# Housekeeping - we make sure that if a building is obsolete - all units in that building are obsolete too

	SET @building_system_id_insert_extl1_1 = NEW.`id_building` ;

		UPDATE `external_property_level_2_units` AS `a`
			INNER JOIN `external_property_level_1_buildings` AS `b`
				ON (`a`.`building_system_id` = `b`.`id_building`)
			SET `a`.`is_obsolete` = `b`.`is_obsolete`
			WHERE `a`.`building_system_id` = @building_system_id_insert_extl1_1
				AND `a`.`tower` = @tower_insert_extl1_1
			;

END;
$$
DELIMITER ;

# We create a trigger when a record is updated in the `external_property_level_1_buildings` table
#	- The property DOES exist in the table `property_level_1_buildings`
#	- This is a NOT a new creation request in Unee-T

	DROP TRIGGER IF EXISTS `ut_update_external_property_level_1`;

DELIMITER $$
CREATE TRIGGER `ut_update_external_property_level_1`
AFTER UPDATE ON `external_property_level_1_buildings`
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
#	- The `do_not_insert_field` is NOT equal to 1
#	- The unit already exist in the table `property_level_1_buildings`
#	- This is a valid update method:
#		- 'imported_from_hmlet_ipi'
#		- 'Manage_Buildings_Add_Page'
#		- 'Manage_Buildings_Edit_Page'
#		- 'Manage_Buildings_Import_Page'
#		- 'Export_and_Import_Buildings_Import_Page'
#		- ''

	SET @is_creation_needed_in_unee_t_update_extl1_1 = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator_update_extl1_1 = NEW.`created_by_id` ;
	SET @source_system_updater_update_extl1_1 = (IF(NEW.`updated_by_id` IS NULL
			, @source_system_creator_update_extl1_1
			, NEW.`updated_by_id`
			)
		);

	SET @creator_mefe_user_id_update_extl1_1 = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator_update_extl1_1
		)
		;

	SET @upstream_create_method_update_extl1_1 = NEW.`creation_method` ;
	SET @upstream_update_method_update_extl1_1 = NEW.`update_method` ;

	SET @organization_id_update_extl1_1 = @source_system_creator_update_extl1_1 ;

	SET @external_id_update_extl1_1 = NEW.`external_id` ;
	SET @external_system_id_update_extl1_1 = NEW.`external_system_id` ; 
	SET @external_table_update_extl1_1 = NEW.`external_table` ;
	SET @tower_update_extl1_1 = NEW.`tower` ;

	SET @new_is_creation_needed_in_unee_t_update_extl1_1 = NEW.`is_creation_needed_in_unee_t` ;
	SET @old_is_creation_needed_in_unee_t_update_extl1_1 = OLD.`is_creation_needed_in_unee_t` ;

	SET @id_in_property_level_1_buildings_update_extl1_1 = (SELECT `id_building`
		FROM `property_level_1_buildings`
		WHERE `external_system_id` = @external_system_id_update_extl1_1
			AND `external_table` = @external_table_update_extl1_1
			AND `external_id` = @external_id_update_extl1_1
			AND `organization_id` = @organization_id_update_extl1_1
			AND `tower` = @tower_update_extl1_1
		);

	SET @upstream_do_not_insert_update_extl1_1 = NEW.`do_not_insert` ;

	# This is an UPDATE - the record SHOULD exist already
		SET @do_not_insert_update_extl1_1 = (IF (@id_in_property_level_1_buildings_update_extl1_1 IS NULL
				, 1
				, @upstream_do_not_insert_update_extl1_1
				)
			);

	# Get the information about the area for that building...
	# We need the information from the table `property_groups_areas` (and NOT the table `external_property_groups_areas`)

		SET @area_id_1_update_extl1_1 = NEW.`area_id` ;

		SET @area_external_id_update_extl1_1 = (SELECT `external_id`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_1_update_extl1_1
			);
		SET @area_external_system_id_update_extl1_1 = (SELECT `external_system_id`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_1_update_extl1_1
			);
		SET @area_external_table_update_extl1_1 = (SELECT `external_table`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_1_update_extl1_1
			);

		SET @area_id_2_update_extl1_1 = (SELECT `id_area`
			FROM `property_groups_areas`
			WHERE `external_id` = @area_external_id_update_extl1_1
				AND `external_system_id` = @area_external_system_id_update_extl1_1
			   	AND `external_table` = @area_external_table_update_extl1_1
			   	AND `organization_id` = @organization_id_update_extl1_1
			);

	IF @is_creation_needed_in_unee_t_update_extl1_1 = 1
		AND @new_is_creation_needed_in_unee_t_update_extl1_1 = @old_is_creation_needed_in_unee_t_update_extl1_1
		AND @do_not_insert_update_extl1_1 = 0
		AND @external_id_update_extl1_1 IS NOT NULL
		AND @external_system_id_update_extl1_1 IS NOT NULL
		AND @external_table_update_extl1_1 IS NOT NULL
		AND @tower_update_extl1_1 IS NOT NULL
		AND @organization_id_update_extl1_1 IS NOT NULL
		AND @area_id_2_update_extl1_1 IS NOT NULL
		AND (@upstream_create_method_update_extl1_1 = 'imported_from_hmlet_ipi'
			OR @upstream_update_method_update_extl1_1 = 'imported_from_hmlet_ipi'
			OR @upstream_create_method_update_extl1_1 = 'Manage_Buildings_Add_Page'
			OR @upstream_update_method_update_extl1_1 = 'Manage_Buildings_Add_Page'
			OR @upstream_create_method_update_extl1_1 = 'Manage_Buildings_Edit_Page'
			OR @upstream_update_method_update_extl1_1 = 'Manage_Buildings_Edit_Page'
			OR @upstream_create_method_update_extl1_1 = 'Manage_Buildings_Import_Page'
			OR @upstream_update_method_update_extl1_1 = 'Manage_Buildings_Import_Page'
			OR @upstream_create_method_update_extl1_1 = 'Export_and_Import_Buildings_Import_Page'
			OR @upstream_update_method_update_extl1_1 = 'Export_and_Import_Buildings_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `property_level_1_buildings` table:

		SET @this_trigger_update_extl1_1 = 'ut_update_external_property_level_1';

		SET @syst_created_datetime_update_extl1_1 = NOW();
		SET @creation_system_id_update_extl1_1 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator_update_extl1_1
			)
			;
		SET @created_by_id_update_extl1_1 = @creator_mefe_user_id_update_extl1_1 ;
		SET @downstream_creation_method_update_extl1_1 = @this_trigger_update_extl1_1 ;

		SET @syst_updated_datetime_update_extl1_1 = NOW();

		SET @update_system_id_update_extl1_1 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater_update_extl1_1
			)
			;
		SET @updated_by_id_update_extl1_1 = @creator_mefe_user_id_update_extl1_1 ;
		SET @downstream_update_method_update_extl1_1 = @this_trigger_update_extl1_1 ;

		SET @organization_id_create_update_extl1_1 = @source_system_creator_update_extl1_1;
		SET @organization_id_update_update_extl1_1 = @source_system_updater_update_extl1_1;

		SET @is_obsolete_update_extl1_1 = NEW.`is_obsolete` ;
		SET @order_update_extl1_1 = NEW.`order` ;

		SET @unee_t_unit_type_update_extl1_1 = NEW.`unee_t_unit_type` ;
		SET @designation_update_extl1_1 = NEW.`designation` ;

		SET @address_1_update_extl1_1 = NEW.`address_1` ;
		SET @address_2_update_extl1_1 = NEW.`address_2` ;
		SET @zip_postal_code_update_extl1_1 = NEW.`zip_postal_code` ;
		SET @state_update_extl1_1 = NEW.`state` ;
		SET @city_update_extl1_1 = NEW.`city` ;
		SET @country_code_update_extl1_1 = NEW.`country_code` ;

		SET @description_update_extl1_1 = NEW.`description` ;

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
				(@external_id_update_extl1_1
				, @external_system_id_update_extl1_1
				, @external_table_update_extl1_1
				, @syst_created_datetime_update_extl1_1
				, @creation_system_id_update_extl1_1
				, @created_by_id_update_extl1_1
				, @downstream_creation_method_update_extl1_1
				, @organization_id_create_update_extl1_1
				, @is_obsolete_update_extl1_1
				, @order_update_extl1_1
				, @area_id_2_update_extl1_1
				, @is_creation_needed_in_unee_t_update_extl1_1
				, @do_not_insert_update_extl1_1
				, @unee_t_unit_type_update_extl1_1
				, @designation_update_extl1_1
				, @tower_update_extl1_1
				, @address_1_update_extl1_1
				, @address_2_update_extl1_1
				, @zip_postal_code_update_extl1_1
				, @state_update_extl1_1
				, @city_update_extl1_1
				, @country_code_update_extl1_1
				, @description_update_extl1_1
				)
			ON DUPLICATE KEY UPDATE
				`syst_updated_datetime` = @syst_updated_datetime_update_extl1_1
				, `update_system_id` = @update_system_id_update_extl1_1
				, `updated_by_id` = @updated_by_id_update_extl1_1
				, `update_method` = @downstream_update_method_update_extl1_1
				, `organization_id` = @organization_id_update_update_extl1_1
				, `is_obsolete` = @is_obsolete_update_extl1_1
				, `order` = @order_update_extl1_1
				, `area_id` = @area_id_2_update_extl1_1
				, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t_update_extl1_1
				, `do_not_insert` = @do_not_insert_update_extl1_1
				, `unee_t_unit_type` = @unee_t_unit_type_update_extl1_1
				, `designation` = @designation_update_extl1_1
				, `tower` = @tower_update_extl1_1
				, `address_1` = @address_1_update_extl1_1
				, `address_2` = @address_2_update_extl1_1
				, `zip_postal_code` = @zip_postal_code_update_extl1_1
				, `state` = @state_update_extl1_1
				, `city` = @city_update_extl1_1
				, `country_code` = @country_code_update_extl1_1
				, `description` = @description_update_extl1_1
			;

	END IF;

# Housekeeping - we make sure that if a building is obsolete - all units in that building are obsolete too

	SET @building_system_id_update_extl1_1 = NEW.`id_building` ;

		UPDATE `external_property_level_2_units` AS `a`
			INNER JOIN `external_property_level_1_buildings` AS `b`
				ON (`a`.`building_system_id` = `b`.`id_building`)
			SET `a`.`is_obsolete` = `b`.`is_obsolete`
			WHERE `a`.`building_system_id` = @building_system_id_update_extl1_1
				AND `a`.`tower` = @tower_update_extl1_1
			;

END;
$$
DELIMITER ;

# We create a trigger when a record is updated in the `external_property_level_1_buildings` table
#	- The unit DOES exist in the table `property_level_1_buildings`
#	- This IS a new creation request in Unee-T

	DROP TRIGGER IF EXISTS `ut_update_external_property_level_1_creation_needed`;

DELIMITER $$
CREATE TRIGGER `ut_update_external_property_level_1_creation_needed`
AFTER UPDATE ON `external_property_level_1_buildings`
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
#	- The `do_not_insert_field` is NOT equal to 1
#	- The unit already exist in the table `property_level_1_buildings`
#	- This is a valid update method:
#		- 'imported_from_hmlet_ipi'
#		- 'Manage_Buildings_Add_Page'
#		- 'Manage_Buildings_Edit_Page'
#		- 'Manage_Buildings_Import_Page'
#		- 'Export_and_Import_Buildings_Import_Page'
#		- ''

	SET @is_creation_needed_in_unee_t_update_extl1_2 = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator_update_extl1_2 = NEW.`created_by_id` ;
	SET @source_system_updater_update_extl1_2 = (IF(NEW.`updated_by_id` IS NULL
			, @source_system_creator_update_extl1_2
			, NEW.`updated_by_id`
			)
		);

	SET @creator_mefe_user_id_update_extl1_2 = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator_update_extl1_2
		)
		;

	SET @upstream_create_method_update_extl1_2 = NEW.`creation_method` ;
	SET @upstream_update_method_update_extl1_2 = NEW.`update_method` ;

	SET @organization_id_update_extl1_2 = @source_system_creator_update_extl1_2 ;

	SET @external_id_update_extl1_2 = NEW.`external_id` ;
	SET @external_system_id_update_extl1_2 = NEW.`external_system_id` ; 
	SET @external_table_update_extl1_2 = NEW.`external_table` ;
	SET @tower_update_extl1_2 = NEW.`tower` ;

	SET @new_is_creation_needed_in_unee_t_update_extl1_2 = NEW.`is_creation_needed_in_unee_t` ;
	SET @old_is_creation_needed_in_unee_t_update_extl1_2 = OLD.`is_creation_needed_in_unee_t` ;

	SET @id_in_property_level_1_buildings_update_extl1_2 = (SELECT `id_building`
		FROM `property_level_1_buildings`
		WHERE `external_system_id` = @external_system_id_update_extl1_2
			AND `external_table` = @external_table_update_extl1_2
			AND `external_id` = @external_id_update_extl1_2
			AND `organization_id` = @organization_id_update_extl1_2
			AND `tower` = @tower_update_extl1_2
		);

	SET @upstream_do_not_insert_update_extl1_2 = NEW.`do_not_insert` ;

	# This is an UPDATE - the record SHOULD exist already
	# BUT there are some edge cases when we need to re-create this...

		SET @do_not_insert_update_extl1_2 = @upstream_do_not_insert_update_extl1_2 ;

	# Get the information about the area for that building...
	# We need the information from the table `property_groups_areas` (and NOT the table `external_property_groups_areas`)

		SET @area_id_1_update_extl1_2 = NEW.`area_id` ;

		SET @area_external_id_update_extl1_2 = (SELECT `external_id`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_1_update_extl1_2
			);
		SET @area_external_system_id_update_extl1_2 = (SELECT `external_system_id`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_1_update_extl1_2
			);
		SET @area_external_table_update_extl1_2 = (SELECT `external_table`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_1_update_extl1_2
			);

		SET @area_id_2_update_extl1_2 = (SELECT `id_area`
			FROM `property_groups_areas`
			WHERE `external_id` = @area_external_id_update_extl1_2
				AND `external_system_id` = @area_external_system_id_update_extl1_2
			   	AND `external_table` = @area_external_table_update_extl1_2
			   	AND `organization_id` = @organization_id_update_extl1_2
			);

	IF @is_creation_needed_in_unee_t_update_extl1_2 = 1
		AND @id_in_property_level_1_buildings_update_extl1_2 IS NULL
		AND @do_not_insert_update_extl1_2 = 0
		AND @external_id_update_extl1_2 IS NOT NULL
		AND @external_system_id_update_extl1_2 IS NOT NULL
		AND @external_table_update_extl1_2 IS NOT NULL
		AND @tower_update_extl1_2 IS NOT NULL
		AND @organization_id_update_extl1_2 IS NOT NULL
		AND @area_id_2_update_extl1_2 IS NOT NULL
		AND (@upstream_create_method_update_extl1_2 = 'imported_from_hmlet_ipi'
			OR @upstream_update_method_update_extl1_2 = 'imported_from_hmlet_ipi'
			OR @upstream_create_method_update_extl1_2 = 'Manage_Buildings_Add_Page'
			OR @upstream_update_method_update_extl1_2 = 'Manage_Buildings_Add_Page'
			OR @upstream_create_method_update_extl1_2 = 'Manage_Buildings_Edit_Page'
			OR @upstream_update_method_update_extl1_2 = 'Manage_Buildings_Edit_Page'
			OR @upstream_create_method_update_extl1_2 = 'Manage_Buildings_Import_Page'
			OR @upstream_update_method_update_extl1_2 = 'Manage_Buildings_Import_Page'
			OR @upstream_create_method_update_extl1_2 = 'Export_and_Import_Buildings_Import_Page'
			OR @upstream_update_method_update_extl1_2 = 'Export_and_Import_Buildings_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `property_level_1_buildings` table:

		SET @this_trigger_update_extl1_2 = 'ut_update_external_property_level_1_creation_needed';

		SET @syst_created_datetime_update_extl1_2 = NOW();
		SET @creation_system_id_update_extl1_2 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator_update_extl1_2
			)
			;
		SET @created_by_id_update_extl1_2 = @creator_mefe_user_id_update_extl1_2 ;
		SET @downstream_creation_method_update_extl1_2 = @this_trigger_update_extl1_2 ;

		SET @syst_updated_datetime_update_extl1_2 = NOW();

		SET @update_system_id_update_extl1_2 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater_update_extl1_2
			)
			;
		SET @updated_by_id_update_extl1_2 = @creator_mefe_user_id_update_extl1_2 ;
		SET @downstream_update_method_update_extl1_2 = @this_trigger_update_extl1_2 ;

		SET @organization_id_create_update_extl1_2 = @source_system_creator_update_extl1_2;
		SET @organization_id_update_update_extl1_2 = @source_system_updater_update_extl1_2;

		SET @is_obsolete_update_extl1_2 = NEW.`is_obsolete` ;
		SET @order_update_extl1_2 = NEW.`order` ;

		SET @unee_t_unit_type_update_extl1_2 = NEW.`unee_t_unit_type` ;
		SET @designation_update_extl1_2 = NEW.`designation` ;

		SET @address_1_update_extl1_2 = NEW.`address_1` ;
		SET @address_2_update_extl1_2 = NEW.`address_2` ;
		SET @zip_postal_code_update_extl1_2 = NEW.`zip_postal_code` ;
		SET @state_update_extl1_2 = NEW.`state` ;
		SET @city_update_extl1_2 = NEW.`city` ;
		SET @country_code_update_extl1_2 = NEW.`country_code` ;

		SET @description_update_extl1_2 = NEW.`description` ;

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
				(@external_id_update_extl1_2
				, @external_system_id_update_extl1_2
				, @external_table_update_extl1_2
				, @syst_created_datetime_update_extl1_2
				, @creation_system_id_update_extl1_2
				, @created_by_id_update_extl1_2
				, @downstream_creation_method_update_extl1_2
				, @organization_id_create_update_extl1_2
				, @is_obsolete_update_extl1_2
				, @order_update_extl1_2
				, @area_id_2_update_extl1_2
				, @is_creation_needed_in_unee_t_update_extl1
				, @do_not_insert_update_extl1_2
				, @unee_t_unit_type_update_extl1_2
				, @designation_update_extl1_2
				, @tower_update_extl1_2
				, @address_1_update_extl1_2
				, @address_2_update_extl1_2
				, @zip_postal_code_update_extl1_2
				, @state_update_extl1_2
				, @city_update_extl1_2
				, @country_code_update_extl1_2
				, @description_update_extl1_2
				)
			ON DUPLICATE KEY UPDATE
				`syst_updated_datetime` = @syst_updated_datetime_update_extl1_2
				, `update_system_id` = @update_system_id_update_extl1_2
				, `updated_by_id` = @updated_by_id_update_extl1_2
				, `update_method` = @downstream_update_method_update_extl1_2
				, `organization_id` = @organization_id_update_update_extl1_2
				, `is_obsolete` = @is_obsolete_update_extl1_2
				, `order` = @order_update_extl1_2
				, `area_id` = @area_id_2_update_extl1_2
				, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t_update_extl1
				, `do_not_insert` = @do_not_insert_update_extl1_2
				, `unee_t_unit_type` = @unee_t_unit_type_update_extl1_2
				, `designation` = @designation_update_extl1_2
				, `tower` = @tower_update_extl1_2
				, `address_1` = @address_1_update_extl1_2
				, `address_2` = @address_2_update_extl1_2
				, `zip_postal_code` = @zip_postal_code_update_extl1_2
				, `state` = @state_update_extl1_2
				, `city` = @city_update_extl1_2
				, `country_code` = @country_code_update_extl1_2
				, `description` = @description_update_extl1_2
			;

	END IF;

# Housekeeping - we make sure that if a building is obsolete - all units in that building are obsolete too

	SET @building_system_id_update_extl1_2 = NEW.`id_building` ;

		UPDATE `external_property_level_2_units` AS `a`
			INNER JOIN `external_property_level_1_buildings` AS `b`
				ON (`a`.`building_system_id` = `b`.`id_building`)
			SET `a`.`is_obsolete` = `b`.`is_obsolete`
			WHERE `a`.`building_system_id` = @building_system_id_update_extl1_2
				AND `a`.`tower` = @tower_update_extl1_2
			;

END;
$$
DELIMITER ;

# Create a trigger to update the table that will fire the lambda each time a new building needs to be created

		DROP TRIGGER IF EXISTS `ut_update_map_external_source_unit_add_building`;

DELIMITER $$
CREATE TRIGGER `ut_update_map_external_source_unit_add_building`
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

	SET @is_creation_needed_in_unee_t_insert_l1_1 = NEW.`is_creation_needed_in_unee_t` ;

	SET @external_property_id_insert_l1_1 = NEW.`external_id` ;
	SET @external_system_insert_l1_1 = NEW.`external_system_id` ;
	SET @table_in_external_system_insert_l1_1 = NEW.`external_table` ;
	SET @organization_id_insert_l1_1 = NEW.`organization_id`;
	SET @tower_insert_l1_1 = NEW.`tower` ; 

	SET @id_building_insert_l1_1 = NEW.`id_building` ;

	SET @id_in_ut_map_external_source_units_insert_l1_1 = (SELECT `id_map`
		FROM `ut_map_external_source_units`
		WHERE `external_property_type_id` = 1
			AND `external_property_id` = @external_property_id_insert_l1_1
			AND `external_system` = @external_system_insert_l1_1
			AND `table_in_external_system` = @table_in_external_system_insert_l1_1
			AND `organization_id` = @organization_id_insert_l1_1
			AND `tower` = @tower_insert_l1_1
		);

	SET @existing_mefe_unit_id_insert_l1_1 = (SELECT `unee_t_mefe_unit_id`
		FROM `ut_map_external_source_units`
		WHERE `external_property_type_id` = 1
			AND `external_property_id` = @external_property_id_insert_l1_1
			AND `external_system` = @external_system_insert_l1_1
			AND `table_in_external_system` = @table_in_external_system_insert_l1_1
			AND `organization_id` = @organization_id_insert_l1_1
			AND `tower` = @tower_insert_l1_1
		);

	# This is an insert - if the record does NOT exist, we create the record
	# unless 
	#	- it is specifically specified that we do NOT need to create the record.
	#	- the record is marked as obsolete

		SET @is_obsolete_insert_l1_1 = NEW.`is_obsolete`;

		SET @do_not_insert_insert_l1_1 = (IF (@id_in_ut_map_external_source_units_insert_l1_1 IS NULL
				,  IF (@is_obsolete_insert_l1_1 != 0
					, 1
					, 0
					)
				, IF (@is_obsolete_insert_l1_1 != 0
					, 1
					, NEW.`do_not_insert`
					)
				)
			);

	SET @upstream_create_method_insert_l1_1 = NEW.`creation_method` ;
	SET @upstream_update_method_insert_l1_1 = NEW.`update_method` ;

	IF @is_creation_needed_in_unee_t_insert_l1_1 = 1
		AND @do_not_insert_insert_l1_1 = 0
		AND @existing_mefe_unit_id_insert_l1_1 IS NULL
		AND (@upstream_create_method_insert_l1_1 = 'ut_insert_external_property_level_1'
			OR @upstream_update_method_insert_l1_1 = 'ut_insert_external_property_level_1'
			OR @upstream_create_method_insert_l1_1 = 'ut_update_external_property_level_1'
			OR @upstream_update_method_insert_l1_1 = 'ut_update_external_property_level_1'
			OR @upstream_create_method_insert_l1_1 = 'ut_update_external_property_level_1_creation_needed'
			OR @upstream_update_method_insert_l1_1 = 'ut_update_external_property_level_1_creation_needed'
			)
	THEN 

	# We capture the values we need for the insert/udpate:

		SET @this_trigger_insert_l1_1 = 'ut_update_map_external_source_unit_add_building' ;

		SET @syst_created_datetime_insert_l1_1 = NOW();
		SET @creation_system_id_insert_l1_1 = NEW.`creation_system_id`;
		SET @created_by_id_insert_l1_1 = NEW.`created_by_id`;
		SET @creation_method_insert_l1_1 = @this_trigger ;

		SET @syst_updated_datetime_insert_l1_1 = NOW();
		SET @update_system_id_insert_l1_1 = NEW.`creation_system_id`;
		SET @updated_by_id_insert_l1_1 = NEW.`created_by_id`;
		SET @update_method_insert_l1_1 = @this_trigger_insert_l1_1 ;

		SET @is_update_needed_insert_l1_1 = NULL;
			
		SET @uneet_name_insert_l1_1 = NEW.`designation`;

		SET @unee_t_unit_type_insert_l1_1 = (IFNULL(NEW.`unee_t_unit_type`
				, 'Unknown'
				)
			)
			;
			
		SET @new_record_id_insert_l1_1 = NEW.`id_building`;
		SET @external_property_type_id_insert_l1_1 = 1;
		
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
				, `tower`
				)
				VALUES
					(@syst_created_datetime_insert_l1_1
					, @creation_system_id_insert_l1_1
					, @created_by_id_insert_l1_1
					, @this_trigger_insert_l1_1
					, @organization_id_insert_l1_1
					, @is_obsolete_insert_l1_1
					, @is_update_needed_insert_l1_1
					, @uneet_name_insert_l1_1
					, @unee_t_unit_type_insert_l1_1
					, @new_record_id_insert_l1_1
					, @external_property_type_id_insert_l1_1
					, @external_property_id_insert_l1_1
					, @external_system_insert_l1_1
					, @table_in_external_system_insert_l1_1
					, @tower_insert_l1_1
					)
				ON DUPLICATE KEY UPDATE 
					`syst_updated_datetime` = @syst_updated_datetime_insert_l1_1
					, `update_system_id` = @update_system_id_insert_l1_1
					, `updated_by_id` = @updated_by_id_insert_l1_1
					, `update_method` = @this_trigger_insert_l1_1
					, `organization_id` = @organization_id_insert_l1_1
					, `uneet_name` = @uneet_name_insert_l1_1
					, `unee_t_unit_type` = @unee_t_unit_type_insert_l1_1
					, `is_update_needed` = @is_update_needed_insert_l1_1
				;

	END IF;
END;
$$
DELIMITER ;

# Create a trigger to update the table that will fire the lambda each time a new building is marked as `is_creation_needed_in_unee_t` = 1

	DROP TRIGGER IF EXISTS `ut_update_map_external_source_unit_add_building_creation_needed`;

DELIMITER $$
CREATE TRIGGER `ut_update_map_external_source_unit_add_building_creation_needed`
AFTER UPDATE ON `property_level_1_buildings`
FOR EACH ROW
BEGIN

# We only do this IF:
# 	- We need to create the unit in Unee-T
#	- We do NOT have a MEFE unit ID for that unit
#	- The record has NOT been explicitly been marked as `do_not_insert`
#	- This is done via an authorized update Method:
#		- `ut_insert_external_property_level_1`
#		- 'ut_update_external_property_level_1_creation_needed'
#		- ''

	SET @is_creation_needed_in_unee_t_update_l1_1 = NEW.`is_creation_needed_in_unee_t` ;

	SET @external_property_id_update_l1_1 = NEW.`external_id` ;
	SET @external_system_update_l1_1 = NEW.`external_system_id` ;
	SET @table_in_external_system_update_l1_1 = NEW.`external_table` ;
	SET @organization_id_update_l1_1 = NEW.`organization_id`;
	SET @tower_update_l1_1 = NEW.`tower` ; 

	SET @new_is_creation_needed_in_unee_t_update_l1_1 =  NEW.`is_creation_needed_in_unee_t` ;
	SET @old_is_creation_needed_in_unee_t_update_l1_1 = OLD.`is_creation_needed_in_unee_t` ; 

	SET @do_not_insert_update_l1_1_raw = NEW.`do_not_insert` ;

	SET @id_building_update_l1_1 = NEW.`id_building` ;

	SET @mefe_unit_id_update_l1_1 = (SELECT `unee_t_mefe_unit_id`
		FROM `ut_map_external_source_units`
		WHERE `external_property_type_id` = 1
			AND `external_property_id` = @external_property_id_update_l1_1
			AND `external_system` = @external_system_update_l1_1
			AND `table_in_external_system` = @table_in_external_system_update_l1_1
			AND `organization_id` = @organization_id_update_l1_1
			AND `tower` = @tower_update_l1_1
		);

	# This is an insert - if the record does NOT exist, we create the record
	# unless 
	#	- it is specifically specified that we do NOT need to create the record.
	#	- the record is marked as obsolete

		SET @is_obsolete_update_l1_1 = NEW.`is_obsolete`;

		SET @do_not_insert_update_l1_1 = (IF (@do_not_insert_update_l1_1_raw IS NULL
				, IF (@is_obsolete_update_l1_1 != 0
					, 1
					, 0
					)
				, IF (@is_obsolete_update_l1_1 != 0
					, 1
					, NEW.`do_not_insert`
					)
				)
			);

	SET @upstream_create_method_update_l1_1 = NEW.`creation_method` ;
	SET @upstream_update_method_update_l1_1 = NEW.`update_method` ;

	IF @is_creation_needed_in_unee_t_update_l1_1 = 1
		AND @do_not_insert_update_l1_1 = 0
		AND @mefe_unit_id_update_l1_1 IS NULL
		AND (@upstream_create_method_update_l1_1 = 'ut_insert_external_property_level_1'
			OR @upstream_update_method_update_l1_1 = 'ut_insert_external_property_level_1'
			OR @upstream_create_method_update_l1_1 = 'ut_update_external_property_level_1_creation_needed'
			OR @upstream_update_method_update_l1_1 = 'ut_update_external_property_level_1_creation_needed'
			)
	THEN 

		# We capture the values we need for the insert/udpate:

			SET @this_trigger_update_l1_1 = 'ut_update_map_external_source_unit_add_building_creation_needed' ;

			SET @syst_created_datetime_update_l1_1 = NOW();
			SET @creation_system_id_update_l1_1 = NEW.`update_system_id`;
			SET @created_by_id_update_l1_1 = NEW.`updated_by_id`;
			SET @creation_method_update_l1_1 = @this_trigger_update_l1_1 ;

			SET @syst_updated_datetime_update_l1_1 = NOW();
			SET @update_system_id_update_l1_1 = NEW.`update_system_id`;
			SET @updated_by_id_update_l1_1 = NEW.`updated_by_id`;
			SET @update_method_update_l1_1 = @this_trigger_update_l1_1 ;

			SET @organization_id_update_l1_1 = NEW.`organization_id`;

			SET @tower_update_l1_1 = NEW.`tower` ; 
			
			SET @is_update_needed_update_l1_1 = 1 ;
			
			SET @uneet_name_update_l1_1 = NEW.`designation`;

			SET @unee_t_unit_type_update_l1_1 = (IFNULL(NEW.`unee_t_unit_type`
					, 'Unknown'
					)
				)
				;
			
			SET @new_record_id_update_l1_1 = NEW.`id_building`;
			SET @external_property_type_id_update_l1_1 = 1;

			SET @external_property_id_update_l1_1 = NEW.`external_id`;
			SET @external_system_update_l1_1 = NEW.`external_system_id`;
			SET @table_in_external_system_update_l1_1 = NEW.`external_table`;
		
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
				, `tower`
				)
				VALUES
					(@syst_created_datetime_update_l1_1
					, @creation_system_id_update_l1_1
					, @created_by_id_update_l1_1
					, @this_trigger_update_l1_1
					, @organization_id_update_l1_1
					, @is_obsolete_update_l1_1
					, @is_update_needed_update_l1_1
					, @uneet_name_update_l1_1
					, @unee_t_unit_type_update_l1_1
					, @new_record_id_update_l1_1
					, @external_property_type_id_update_l1_1
					, @external_property_id_update_l1_1
					, @external_system_update_l1_1
					, @table_in_external_system_update_l1_1
					, @tower_update_l1_1
					)
				ON DUPLICATE KEY UPDATE
					`syst_updated_datetime` = @syst_updated_datetime_update_l1_1
					, `update_system_id` = @update_system_id_update_l1_1
					, `updated_by_id` = @updated_by_id_update_l1_1
					, `update_method` = @this_trigger_update_l1_1
					, `organization_id` = @organization_id_update_l1_1
					, `uneet_name` = @uneet_name_update_l1_1
					, `unee_t_unit_type` = @unee_t_unit_type_update_l1_1
					, `is_update_needed` = @is_update_needed_update_l1_1
				;

	END IF;
END;
$$
DELIMITER ;

# Create a trigger to update the table that will fire the lambda each time 
# a new Property Level 1 needs to be updated

	DROP TRIGGER IF EXISTS `ut_update_map_external_source_unit_edit_level_1`;

DELIMITER $$
CREATE TRIGGER `ut_update_map_external_source_unit_edit_level_1`
AFTER UPDATE ON `property_level_1_buildings`
FOR EACH ROW
BEGIN

# We only do this IF:
# 	- We need to create the unit in Unee-T
#	- We DO have a MEFE unit ID for that unit
#	- The record has NOT been explicitly been marked as `do_not_insert`
#	- This is done via an authorized update Method:
#		- `ut_update_external_property_level_1`
#		- ''

	SET @is_creation_needed_in_unee_t_update_l1_2 = NEW.`is_creation_needed_in_unee_t` ;

	SET @external_property_id_update_l1_2 = NEW.`external_id` ;
	SET @external_system_update_l1_2 = NEW.`external_system_id` ;
	SET @table_in_external_system_update_l1_2 = NEW.`external_table` ;
	SET @organization_id_update_l1_2 = NEW.`organization_id`;
	SET @tower_update_l1_2 = NEW.`tower` ; 

	SET @new_is_creation_needed_in_unee_t_update_l1_2 =  NEW.`is_creation_needed_in_unee_t` ;
	SET @old_is_creation_needed_in_unee_t_update_l1_2 = OLD.`is_creation_needed_in_unee_t` ; 

	SET @do_not_insert_update_l1_2_raw = NEW.`do_not_insert` ;

	SET @id_building_update_l1_2 = NEW.`id_building` ;

	SET @mefe_unit_id_update_l1_2 = (SELECT `unee_t_mefe_unit_id`
		FROM `ut_map_external_source_units`
		WHERE `external_property_type_id` = 1
			AND `external_property_id` = @external_property_id_update_l1_2
			AND `external_system` = @external_system_update_l1_2
			AND `table_in_external_system` = @table_in_external_system_update_l1_2
			AND `organization_id` = @organization_id_update_l1_2
			AND `tower` = @tower_update_l1_2
		);

	# This is an insert - if the record does NOT exist, we create the record
	# unless 
	#	- it is specifically specified that we do NOT need to create the record.
	#	- the record is marked as obsolete

		SET @is_obsolete_update_l1_2 = NEW.`is_obsolete`;

		SET @do_not_insert_update_l1_2 = (IF (@do_not_insert_update_l1_2_raw IS NULL
				, IF (@is_obsolete_update_l1_2 != 0
					, 1
					, 0
					)
				, IF (@is_obsolete_update_l1_2 != 0
					, 1
					, NEW.`do_not_insert`
					)
				)
			);


	SET @upstream_create_method_update_l1_2 = NEW.`creation_method` ;
	SET @upstream_update_method_update_l1_2 = NEW.`update_method` ;

	IF @is_creation_needed_in_unee_t_update_l1_2 = 1
		AND @do_not_insert_update_l1_2 = 0
		AND @mefe_unit_id_update_l1_2 IS NOT NULL
		AND (@upstream_create_method_update_l1_2 = 'ut_update_external_property_level_1'
			OR @upstream_update_method_update_l1_2 = 'ut_update_external_property_level_1'
			)
	THEN 

		# We capture the values we need for the insert/udpate:

			SET @this_trigger_update_l1_2 = 'ut_update_map_external_source_unit_edit_level_1' ;

			SET @syst_created_datetime_update_l1_2 = NOW();
			SET @creation_system_id_update_l1_2 = NEW.`update_system_id`;
			SET @created_by_id_update_l1_2 = NEW.`updated_by_id`;
			SET @creation_method_update_l1_2 = @this_trigger_update_l1_2 ;

			SET @syst_updated_datetime_update_l1_2 = NOW();
			SET @update_system_id_update_l1_2 = NEW.`update_system_id`;
			SET @updated_by_id_update_l1_2 = NEW.`updated_by_id`;
			SET @update_method_update_l1_2 = @this_trigger_update_l1_2 ;

			SET @is_update_needed_update_l1_2 = 1 ;
			
			SET @uneet_name_update_l1_2 = NEW.`designation`;

			SET @unee_t_unit_type_update_l1_2 = (IFNULL(NEW.`unee_t_unit_type`
					, 'Unknown'
					)
				)
				;
			
			SET @new_record_id_update_l1_2 = NEW.`id_building`;
			SET @external_property_type_id_update_l1_2 = 1;

			SET @external_property_id_update_l1_2 = NEW.`external_id`;
			SET @external_system_update_l1_2 = NEW.`external_system_id`;
			SET @table_in_external_system_update_l1_2 = NEW.`external_table`;

			SET @is_mefe_api_success_update_l1_2 := 0 ;
			SET @mefe_api_error_message_update_l1_2 := (CONCAT('N/A - written by '
					, '`'
					, @this_trigger_update_l1_2
					, '`'
					)
				);

		# We insert/Update a new record in the table `ut_map_external_source_units`

			INSERT INTO `ut_map_external_source_units`
				( `syst_created_datetime`
				, `creation_system_id`
				, `created_by_id`
				, `creation_method`
				, `organization_id`
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
				, `tower`
				)
				VALUES
					(@syst_created_datetime_update_l1_2
					, @creation_system_id_update_l1_2
					, @created_by_id_update_l1_2
					, @creation_method_update_l1_2
					, @organization_id_update_l1_2
					, @is_obsolete_update_l1_2
					, @is_update_needed_update_l1_2
					, @is_mefe_api_success_update_l1_2
					, @mefe_api_error_message_update_l1_2
					, @uneet_name_update_l1_2
					, @unee_t_unit_type_update_l1_2
					, @new_record_id_update_l1_2
					, @external_property_type_id_update_l1_2
					, @external_property_id_update_l1_2
					, @external_system_update_l1_2
					, @table_in_external_system_update_l1_2
					, @tower_update_l1_2
					)
				ON DUPLICATE KEY UPDATE
					`syst_updated_datetime` = @syst_updated_datetime_update_l1_2
					, `update_system_id` = @update_system_id_update_l1_2
					, `updated_by_id` = @updated_by_id_update_l1_2
					, `update_method` = @update_method_update_l1_2
					, `organization_id` = @organization_id_update_l1_2
					, `is_mefe_api_success` = @is_mefe_api_success_update_l1_2
					, `mefe_api_error_message` = @mefe_api_error_message_update_l1_2
					, `uneet_name` = @uneet_name_update_l1_2
					, `unee_t_unit_type` = @unee_t_unit_type_update_l1_2
					, `is_update_needed` = @is_update_needed_update_l1_2
				;

	END IF;
END;
$$
DELIMITER ;

# Re-create all the procedures and triggers for L2P

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

	DROP TRIGGER IF EXISTS `ut_insert_external_property_level_2`;

DELIMITER $$
CREATE TRIGGER `ut_insert_external_property_level_2`
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

	SET @is_creation_needed_in_unee_t_insert_extl2_1 = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator_insert_extl2_1 = NEW.`created_by_id` ;

	SET @source_system_updated_by_id_insert_extl2_1 = NEW.`updated_by_id` ;

	SET @source_system_updater_insert_extl2_1 = (IF(@source_system_updated_by_id_insert_extl2_1 IS NULL
			, @source_system_creator_insert_extl2_1
			, @source_system_updated_by_id_insert_extl2_1
			)
		);

	SET @creator_mefe_user_id_insert_extl2_1 = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator_insert_extl2_1
		)
		;

	SET @upstream_create_method_insert_extl2_1 = NEW.`creation_method` ;
	SET @upstream_update_method_insert_extl2_1 = NEW.`update_method` ;

	SET @external_system_id_insert_extl2_1 = NEW.`external_system_id` ;
	SET @external_table_insert_extl2_1 = NEW.`external_table` ;
	SET @external_id_insert_extl2_1 = NEW.`external_id` ;

	SET @organization_id_insert_extl2_1 = @source_system_creator_insert_extl2_1 ;

	SET @id_in_property_level_2_units_insert_extl2_1 = (SELECT `system_id_unit`
		FROM `property_level_2_units`
		WHERE `external_system_id` = @external_system_id_insert_extl2_1
			AND `external_table` = @external_table_insert_extl2_1
			AND `external_id` = @external_id_insert_extl2_1
			AND `organization_id` = @organization_id_insert_extl2_1
		);
		
	SET @upstream_do_not_insert_insert_extl2_1 = NEW.`do_not_insert` ;

	# This is an INSERT - the record should NOT exist already

		SET @do_not_insert_insert_extl2_1 = (IF (@id_in_property_level_2_units_insert_extl2_1 IS NULL
				, 0
				, @upstream_do_not_insert_insert_extl2_1
				)
			
			);

	# Get the information about the building for that unit...
	# We need the information from the table `external_property_level_2_units` (and NOT the table `external_external_property_level_1_buildings`)
	
		SET @building_id_1_insert_extl2_1 = NEW.`building_system_id` ;

		SET @tower_insert_extl2_1 = NEW.`tower` ;

		SET @building_external_id_insert_extl2_1 = (SELECT `external_id`
			FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_1_insert_extl2_1
				);
		SET @building_external_system_id_insert_extl2_1 = (SELECT `external_system_id`
			FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_1_insert_extl2_1
			);
		SET @building_external_table_insert_extl2_1 = (SELECT `external_table`
		   FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_1_insert_extl2_1
			);
		SET @building_external_tower_insert_extl2_1 = (SELECT `tower`
			FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_1_insert_extl2_1
			);

		SET @building_system_id_insert_extl2_1 = (SELECT `id_building`
			FROM `property_level_1_buildings`
			WHERE `external_id` = @building_external_id_insert_extl2_1
				AND `external_system_id` = @building_external_system_id_insert_extl2_1
				AND `external_table` = @building_external_table_insert_extl2_1
				AND `organization_id` = @organization_id_insert_extl2_1
				AND `tower` = @building_external_tower_insert_extl2_1
				);

		SET @activated_by_id_insert_extl2_1 = NEW.`activated_by_id` ;
		SET @is_obsolete_insert_extl2_1 = NEW.`is_obsolete` ;
		SET @is_creation_needed_in_unee_t_insert_extl2_1 = NEW.`is_creation_needed_in_unee_t` ;
		SET @unee_t_unit_type_insert_extl2_1 = NEW.`unee_t_unit_type` ;
			
		SET @unit_category_id_insert_extl2_1 = NEW.`unit_category_id` ;
		SET @designation_insert_extl2_1 = NEW.`designation` ;
		SET @count_rooms_insert_extl2_1 = NEW.`count_rooms` ;
		SET @unit_id_insert_extl2_1 = NEW.`unit_id` ;
		SET @surface_insert_extl2_1 = NEW.`surface` ;
		SET @surface_measurment_unit_insert_extl2_1 = NEW.`surface_measurment_unit` ;
		SET @description_insert_extl2_1 = NEW.`description` ;

		SET @system_id_unit_insert_extl2_1 = NEW.`system_id_unit` ;

	IF @is_creation_needed_in_unee_t_insert_extl2_1 = 1
		AND @do_not_insert_insert_extl2_1 = 0
		AND @external_id_insert_extl2_1 IS NOT NULL
		AND @external_system_id_insert_extl2_1 IS NOT NULL
		AND @external_table_insert_extl2_1 IS NOT NULL
		AND @organization_id_insert_extl2_1 IS NOT NULL
		AND @building_system_id_insert_extl2_1 IS NOT NULL
		AND (@upstream_create_method_insert_extl2_1 = 'imported_from_hmlet_ipi'
			OR @upstream_create_method_insert_extl2_1 = 'Manage_Units_Add_Page'
			OR @upstream_create_method_insert_extl2_1 = 'Manage_Units_Edit_Page'
			OR @upstream_create_method_insert_extl2_1 = 'Manage_Units_Import_Page'
			OR @upstream_update_method_insert_extl2_1 = 'imported_from_hmlet_ipi'
			OR @upstream_update_method_insert_extl2_1 = 'Manage_Units_Add_Page'
			OR @upstream_update_method_insert_extl2_1 = 'Manage_Units_Edit_Page'
			OR @upstream_create_method_insert_extl2_1 = 'Manage_Units_Import_Page'
			OR @upstream_update_method_insert_extl2_1 = 'Export_and_Import_Units_Import_Page'
			OR @upstream_create_method_insert_extl2_1 = 'Export_and_Import_Units_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `external_property_level_2_units` table:

		SET @this_trigger_insert_extl2_1 = 'ut_insert_external_property_level_2' ;

		SET @syst_created_datetime_insert_extl2_1 = NOW();
		SET @creation_system_id_insert_extl2_1 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator_insert_extl2_1
			)
			;
		SET @created_by_id_insert_extl2_1 = @creator_mefe_user_id_insert_extl2_1 ;
		SET @downstream_creation_method_insert_extl2_1 = @this_trigger_insert_extl2_1 ;

		SET @syst_updated_datetime_insert_extl2_1 = NOW();

		SET @update_system_id_insert_extl2_1 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater_insert_extl2_1
			)
			;
		SET @updated_by_id_insert_extl2_1 = @creator_mefe_user_id_insert_extl2_1 ;
		SET @downstream_update_method_insert_extl2_1 = @this_trigger_insert_extl2_1 ;

		SET @organization_id_create_insert_extl2_1 = @source_system_creator_insert_extl2_1 ;
		SET @organization_id_update_insert_extl2_1 = @source_system_updater_insert_extl2_1;

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
 				(@external_id_insert_extl2_1
				, @external_system_id_insert_extl2_1
				, @external_table_insert_extl2_1
				, @syst_created_datetime_insert_extl2_1
				, @creation_system_id_insert_extl2_1
				, @created_by_id_insert_extl2_1
				, @downstream_creation_method_insert_extl2_1
				, @organization_id_create_insert_extl2_1
				, @activated_by_id_insert_extl2_1
				, @is_obsolete_insert_extl2_1
				, @is_creation_needed_in_unee_t_insert_extl2_1
				, @do_not_insert_insert_extl2_1
				, @unee_t_unit_type_insert_extl2_1
				, @building_system_id_insert_extl2_1
				, @tower_insert_extl2_1
				, @unit_category_id_insert_extl2_1
				, @designation_insert_extl2_1
				, @count_rooms_insert_extl2_1
				, @unit_id_insert_extl2_1
				, @surface_insert_extl2_1
				, @surface_measurment_unit_insert_extl2_1
				, @description_insert_extl2_1
 			)
			ON DUPLICATE KEY UPDATE
 				`syst_updated_datetime` = @syst_updated_datetime_insert_extl2_1
 				, `update_system_id` = @update_system_id_insert_extl2_1
 				, `updated_by_id` = @updated_by_id_insert_extl2_1
				, `update_method` = @downstream_update_method_insert_extl2_1
				, `activated_by_id` = @activated_by_id_insert_extl2_1
				, `organization_id` = @organization_id_update_insert_extl2_1
				, `is_obsolete` = @is_obsolete_insert_extl2_1
				, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t_insert_extl2_1
				, `do_not_insert` = @do_not_insert_insert_extl2_1
				, `unee_t_unit_type` = @unee_t_unit_type_insert_extl2_1
				, `building_system_id` = @building_system_id_insert_extl2_1
				, `tower` = @tower_insert_extl2_1
				, `unit_category_id` = @unit_category_id_insert_extl2_1
				, `designation` = @designation_insert_extl2_1
				, `count_rooms` = @count_rooms_insert_extl2_1_insert_extl2_1
				, `unit_id` = @unit_id_insert_extl2_1
				, `surface` = @surface_insert_extl2_1
				, `surface_measurment_unit` = @surface_measurment_unit_insert_extl2_1
				, `description` = @description_insert_extl2_1
			;

	# Housekeeping - we make sure that if a unit is obsolete - all rooms in that unit are obsolete too

		UPDATE `external_property_level_3_rooms` AS `a`
			INNER JOIN `external_property_level_2_units` AS `b`
				ON (`a`.`system_id_unit` = `b`.`system_id_unit`)
			SET `a`.`is_obsolete` = `b`.`is_obsolete`
			WHERE `a`.`system_id_unit` = @system_id_unit_insert_extl2_1
			;

	END IF;

END;
$$
DELIMITER ;

# Create the trigger when the extL2P is updated
# This trigger will:
#	- Check if several conditions are met
#	- Capture the value we need in several variables
#	- Call the procedure `ut_update_L2P_when_extl2P_is_updated` if needed.

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

		SET @syst_created_datetime_update_extl2 = NOW();
		SET @creation_system_id_update_extl2 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator_update_extl2
			)
			;
		SET @created_by_id_update_extl2 = @creator_mefe_user_id_update_extl2 ;

		SET @syst_updated_datetime_update_extl2 = NOW();

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

				SET @this_trigger_update_extl2 = 'ut_update_external_property_level_2_creation_needed';
				SET @downstream_creation_method_update_extl2 = @this_trigger_update_extl2 ;
				SET @downstream_update_method_update_extl2 = @this_trigger_update_extl2 ;

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
						, @syst_created_datetime_update_extl2
						, @creation_system_id_update_extl2
						, @created_by_id_update_extl2
						, @downstream_creation_method_update_extl2
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
						`syst_updated_datetime` = @syst_updated_datetime_update_extl2
						, `update_system_id` = @update_system_id_update_extl2
						, `updated_by_id` = @updated_by_id_update_extl2
						, `update_method` = @downstream_update_method_update_extl2
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

				SET @this_trigger_update_extl2 = 'ut_update_external_property_level_2';
				SET @downstream_creation_method_update_extl2 = @this_trigger_update_extl2 ;
				SET @downstream_update_method_update_extl2 = @this_trigger_update_extl2 ;

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
						, @syst_created_datetime_update_extl2
						, @creation_system_id_update_extl2
						, @created_by_id_update_extl2
						, @downstream_creation_method_update_extl2
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
						`syst_updated_datetime` = @syst_updated_datetime_update_extl2
						, `update_system_id` = @update_system_id_update_extl2
						, `updated_by_id` = @updated_by_id_update_extl2
						, `update_method` = @downstream_update_method_update_extl2
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

	DROP TRIGGER IF EXISTS `ut_update_map_external_source_unit_add_unit`;

DELIMITER $$
CREATE TRIGGER `ut_update_map_external_source_unit_add_unit`
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

			SET @this_trigger_insert_l2 = 'ut_update_map_external_source_unit_add_unit' ;

			SET @syst_created_datetime_insert_l2 = NOW();
			SET @creation_method_insert_l2 = @this_trigger ;

			SET @syst_updated_datetime_insert_l2 = NOW();
			SET @update_method_insert_l2 = @this_trigger_insert_l2 ;
			
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
					(@syst_created_datetime_insert_l2
					, @creation_system_id_insert_l2
					, @created_by_id_insert_l2
					, @this_trigger_insert_l2
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
					`syst_updated_datetime` = @syst_updated_datetime_insert_l2
					, `update_system_id` = @update_system_id_insert_l2
					, `updated_by_id` = @updated_by_id_insert_l2
					, `update_method` = @this_trigger_insert_l2
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
#	- Call the procedure `ut_update_uneet_when_L2P_is_updated` if needed.

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

		SET @syst_created_datetime_update_l2 = NOW();
		SET @creation_system_id_update_l2 = NEW.`update_system_id`;
		SET @created_by_id_update_l2 = NEW.`updated_by_id`;

		SET @syst_updated_datetime_update_l2 = NOW();
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
				AND `external_property_type_id` = 2
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
			AND @mefe_unit_id_update_l2 IS NULL
			AND @do_not_insert_update_l2 = 0
		THEN 

			# This is option 1 - creation IS needed

				SET @this_trigger_update_l2 = 'ut_update_map_external_source_unit_add_unit_creation_needed';
				SET @creation_method_update_l2 = @this_trigger_update_l2 ;
				SET @update_method_update_l2 = @this_trigger_update_l2 ;

		# We insert/Update a new record in the table `ut_map_external_source_units`

				INSERT INTO `ut_map_external_source_units`
					( `syst_created_datetime`
					, `creation_system_id`
					, `created_by_id`
					, `creation_method`
					, `organization_id`
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
						(@syst_created_datetime_update_l2
						, @creation_system_id_update_l2
						, @created_by_id_update_l2
						, @creation_method_update_l2
						, @organization_id_update_l2
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
						`syst_updated_datetime` = @syst_updated_datetime_update_l2
						, `update_system_id` = @update_system_id_update_l2
						, `updated_by_id` = @updated_by_id_update_l2
						, `update_method` = @update_method_update_l2
						, `organization_id` = @organization_id_update_l2
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
		THEN 
			
			# This is option 2 - creation is NOT needed

				SET @this_trigger_update_l2 = 'ut_update_map_external_source_unit_edit_level_2';
				SET @creation_method_update_l2 = @this_trigger_update_l2 ;
				SET @update_method_update_l2 = @this_trigger_update_l2 ;

			# We insert/Update a new record in the table `ut_map_external_source_units`

				INSERT INTO `ut_map_external_source_units`
					( `syst_created_datetime`
					, `creation_system_id`
					, `created_by_id`
					, `creation_method`
					, `organization_id`
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
						(@syst_created_datetime_update_l2
						, @creation_system_id_update_l2
						, @created_by_id_update_l2
						, @creation_method_update_l2
						, @organization_id_update_l2
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
						`syst_updated_datetime` = @syst_updated_datetime_update_l2
						, `update_system_id` = @update_system_id_update_l2
						, `updated_by_id` = @updated_by_id_update_l2
						, `update_method` = @update_method_update_l2
						, `organization_id` = @organization_id_update_l2
						, `is_mefe_api_success` = @is_mefe_api_success_update_l2
						, `mefe_api_error_message` = @mefe_api_error_message_update_l2
						, `uneet_name` = @uneet_name_update_l2
						, `unee_t_unit_type` = @unee_t_unit_type_update_l2
						, `is_update_needed` = 1
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

# Re-create all procedures and triggers for L3P 

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
#		- `ut_insert_external_property_level_3`
#		- `ut_after_update_external_property_level_3`
#		- `ut_after_update_property_level_3`

# We create a trigger when a record is added to the `external_property_level_3_rooms` table

	DROP TRIGGER IF EXISTS `ut_insert_external_property_level_3`;

DELIMITER $$
CREATE TRIGGER `ut_insert_external_property_level_3`
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

		SET @this_trigger_insert_extl3_1 = 'ut_insert_external_property_level_3' ;

		SET @syst_created_datetime_insert_extl3_1 = NOW();
		SET @creation_system_id_insert_extl3_1 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator_insert_extl3_1
			)
			;
		SET @created_by_id_insert_extl3_1 = @creator_mefe_user_id_insert_extl3_1 ;
		SET @downstream_creation_method_insert_extl3_1 = @this_trigger_insert_extl3_1 ;

		SET @syst_updated_datetime_insert_extl3_1 = NOW();

		SET @update_system_id_insert_extl3_1 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater_insert_extl3_1
			)
			;
		SET @updated_by_id_insert_extl3_1 = @creator_mefe_user_id_insert_extl3_1 ;
		SET @downstream_update_method_insert_extl3_1 = @this_trigger_insert_extl3_1 ;

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
				, @syst_created_datetime_insert_extl3_1
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
 				`syst_updated_datetime` = @syst_updated_datetime_insert_extl3_1
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

	DROP TRIGGER IF EXISTS `ut_after_update_property_level_3`;

DELIMITER $$
CREATE TRIGGER `ut_after_update_property_level_3`
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

		SET @syst_created_datetime_update_extl3 = NOW();
		SET @creation_system_id_update_extl3 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator_update_extl3
			)
			;
		SET @created_by_id_update_extl3 = @creator_mefe_user_id_update_extl3 ;

		SET @syst_updated_datetime_update_extl3 = NOW();

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

				SET @this_trigger_update_ext_l3 = 'ut_update_external_property_level_3_creation_needed';
				SET @downstream_creation_method_update_extl3 = @this_trigger_update_extl3 ;
				SET @downstream_update_method_update_extl3 = @this_trigger_update_extl3 ;

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
							, @syst_created_datetime_update_extl3
							, @creation_system_id_update_extl3
							, @created_by_id_update_extl3
							, @downstream_creation_method_update_extl3
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
							`syst_updated_datetime` = @syst_updated_datetime_update_extl3
							, `update_system_id` = @update_system_id_update_extl3
							, `updated_by_id` = @updated_by_id_update_extl3
							, `update_method` = @downstream_update_method_update_extl3
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

				SET @this_trigger_update_extl3 = 'ut_update_external_property_level_3';
				SET @downstream_creation_method_update_extl3 = @this_trigger_update_extl3 ;
				SET @downstream_update_method_update_extl3 = @this_trigger_update_extl3 ;

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
							, @syst_created_datetime_update_extl3
							, @creation_system_id_update_extl3
							, @created_by_id_update_extl3
							, @downstream_creation_method_update_extl3
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
							`syst_updated_datetime` = @syst_updated_datetime_update_extl3
							, `update_system_id` = @update_system_id_update_extl3
							, `updated_by_id` = @updated_by_id_update_extl3
							, `update_method` = @downstream_update_method_update_extl3
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

	DROP TRIGGER IF EXISTS `ut_update_map_external_source_unit_add_room`;

DELIMITER $$
CREATE TRIGGER `ut_update_map_external_source_unit_add_room`
AFTER INSERT ON `property_level_3_rooms`
FOR EACH ROW
BEGIN

# We do this ONLY IF 
#	- We have marked the property as an object we need to create in Unee-T
#	- The record does NOT exist in the table `ut_map_external_source_units` yet
#	- This is done via an authorized insert method:
#		- 'ut_insert_external_property_level_3'
#		- 'ut_update_external_property_level_3'
#		- 'ut_update_external_property_level_3_creation_needed'
#		- ''
#
	SET @is_creation_needed_in_unee_t_insert_l3_1 = NEW.`is_creation_needed_in_unee_t` ;

	SET @external_property_id_insert_l3_1 = NEW.`external_id` ;
	SET @external_system_insert_l3_1 = NEW.`external_system_id` ;
	SET @table_in_external_system_insert_l3_1 = NEW.`external_table` ;
	SET @organization_id_insert_l3_1 = NEW.`organization_id`;

	SET @id_in_ut_map_external_source_units_insert_l3_1 = (SELECT `id_map`
		FROM `ut_map_external_source_units`
		WHERE `external_system` = @external_system_insert_l3_1
			AND `table_in_external_system` = @table_in_external_system_insert_l3_1
			AND `external_property_id` = @external_property_id_insert_l3_1
			AND `organization_id` = @organization_id_insert_l3_1
			AND `external_property_type_id` = 3
		);

	# This is an insert - if the record does NOT exist, we create the record
	# unless 
	#	- it is specifically specified that we do NOT need to create the record.
	#	- the record is marked as obsolete

		SET @is_obsolete_insert_l3_1 = NEW.`is_obsolete`;

		SET @do_not_insert_insert_l3_1_raw = NEW.`do_not_insert` ;

		SET @do_not_insert_insert_l3_1 = (IF (@id_in_ut_map_external_source_units_insert_l3_1 IS NULL
				, IF (@is_obsolete_insert_l3_1 != 0
					, 1
					, 0
					)
				, IF (@is_obsolete_insert_l3_1 != 0
					, 1
					, @do_not_insert_insert_l3_1_raw
					)
				)
			);

	SET @upstream_create_method_insert_l3_1 = NEW.`creation_method` ;
	SET @upstream_update_method_insert_l3_1 = NEW.`update_method` ;

	IF @is_creation_needed_in_unee_t_insert_l3_1 = 1
		AND @do_not_insert_insert_l3_1 = 0
		AND (@upstream_create_method_insert_l3_1 = 'ut_insert_external_property_level_3'
			OR @upstream_update_method_insert_l3_1 = 'ut_insert_external_property_level_3'
			OR @upstream_create_method_insert_l3_1 = 'ut_update_external_property_level_3'
			OR @upstream_update_method_insert_l3_1 = 'ut_update_external_property_level_3'
			OR @upstream_create_method_insert_l3_1 = 'ut_update_external_property_level_3_creation_needed'
			OR @upstream_update_method_insert_l3_1 = 'ut_update_external_property_level_3_creation_needed'
			)
	THEN 

	# We capture the values we need for the insert/udpate:

		SET @this_trigger_insert_l3_1 = 'ut_update_map_external_source_unit_add_room' ;

		SET @syst_created_datetime_insert_l3_1 = NOW();
		SET @creation_system_id_insert_l3_1 = NEW.`creation_system_id`;
		SET @created_by_id_insert_l3_1 = NEW.`created_by_id`;
		SET @creation_method_insert_l3_1 = @this_trigger_insert_l3_1 ;

		SET @syst_updated_datetime_insert_l3_1 = NOW();
		SET @update_system_id_insert_l3_1 = NEW.`creation_system_id`;
		SET @updated_by_id_insert_l3_1 = NEW.`created_by_id`;
		SET @update_method_insert_l3_1 = @this_trigger_insert_l3_1 ;
			
		SET @is_update_needed_insert_l3_1 = NULL;
			
		SET @uneet_name_insert_l3_1 = NEW.`room_designation`;

		SET @unee_t_unit_type_insert_l3_1_raw = NEW.`unee_t_unit_type` ;

		SET @unee_t_unit_type_insert_l3_1 = (IFNULL(@unee_t_unit_type_insert_l3_1_raw
				, 'Unknown'
				)
			)
			;
		
		SET @new_record_id_insert_l3_1 = NEW.`system_id_room`;
		SET @external_property_type_id_insert_l3_1 = 3;	

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
					(@syst_created_datetime_insert_l3_1
					, @creation_system_id_insert_l3_1
					, @created_by_id_insert_l3_1
					, @creation_method_insert_l3_1
					, @organization_id_insert_l3_1
					, @is_obsolete_insert_l3_1
					, @is_update_needed_insert_l3_1
					, @uneet_name_insert_l3_1
					, @unee_t_unit_type_insert_l3_1
					, @new_record_id_insert_l3_1
					, @external_property_type_id_insert_l3_1
					, @external_property_id_insert_l3_1
					, @external_system_insert_l3_1
					, @table_in_external_system_insert_l3_1
					)
				ON DUPLICATE KEY UPDATE 
					`syst_updated_datetime` = @syst_updated_datetime_insert_l3_1
					, `update_system_id` = @update_system_id_insert_l3_1
					, `updated_by_id` = @updated_by_id_insert_l3_1
					, `update_method` = @update_method_insert_l3_1
					, `organization_id` = @organization_id_insert_l3_1
					, `uneet_name` = @uneet_name_insert_l3_1
					, `unee_t_unit_type` = @unee_t_unit_type_insert_l3_1
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
#		- 'ut_insert_external_property_level_3'
#		- 'ut_update_map_external_source_unit_add_room_creation_needed'
#		- 'ut_update_map_external_source_unit_edit_level_3'

# Capture the variables we need to verify if conditions are met:

	SET @upstream_create_method_update_l3 = NEW.`creation_method` ;
	SET @upstream_update_method_update_l3 = NEW.`update_method` ;

# We can now check if the conditions are met:

	IF (@upstream_create_method_update_l3 = 'ut_insert_external_property_level_3'
			OR @upstream_update_method_update_l3 = 'ut_insert_external_property_level_3'
			OR @upstream_create_method_update_l3 = 'ut_update_map_external_source_unit_add_room_creation_needed'
			OR @upstream_update_method_update_l3 = 'ut_update_map_external_source_unit_add_room_creation_needed'
			OR @upstream_create_method_update_l3 = 'ut_update_map_external_source_unit_edit_level_3'
			OR @upstream_update_method_update_l3 = 'ut_update_map_external_source_unit_edit_level_3'
			)
	THEN 

	# The conditions are met: we capture the other variables we need

		SET @system_id_room_update_l3 = NEW.`system_id_room` ;

		SET @syst_created_datetime_update_l3 = NOW();
		SET @creation_system_id_update_l3 = NEW.`update_system_id`;
		SET @created_by_id_update_l3 = NEW.`updated_by_id`;
		SET @creation_method_update_l3 = @this_trigger_update_l3 ;

		SET @syst_updated_datetime_update_l3 = NOW();
		SET @update_system_id_update_l3 = NEW.`update_system_id`;
		SET @updated_by_id_update_l3 = NEW.`updated_by_id`;
		SET @update_method_update_l3 = @this_trigger_update_l3 ;

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
			AND @mefe_unit_id_update_l3 IS NULL
			AND @do_not_insert_update_l3 = 0
		THEN 

			# This is option 1 - creation IS needed
			#	- The unit is NOT marked as `do_not_insert`
			#	- We do NOT have a MEFE unit ID for that unit

				SET @this_trigger_update_l3 = 'ut_update_map_external_source_unit_add_room_creation_needed';
				SET @creation_method_update_l3 = @this_trigger_update_l3 ;
				SET @update_method_update_l3 = @this_trigger_update_l3 ;

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
						(@syst_created_datetime_update_l3
						, @creation_system_id_update_l3
						, @created_by_id_update_l3
						, @creation_method_update_l3
						, @organization_id_update_l3
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
						`syst_updated_datetime` = @syst_updated_datetime_update_l3
						, `update_system_id` = @update_system_id_update_l3
						, `updated_by_id` = @updated_by_id_update_l3
						, `update_method` = @update_method_update_l3
						, `organization_id` = @organization_id_update_l3
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
		THEN 
			
			# This is option 2 - creation is NOT needed

				SET @this_trigger_update_l3 = 'ut_update_map_external_source_unit_edit_level_3';
				SET @creation_method_update_l3 = @this_trigger_update_l3 ;
				SET @update_method_update_l3 = @this_trigger_update_l3 ;

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
							(@syst_created_datetime_update_l3
							, @creation_system_id_update_l3
							, @created_by_id_update_l3
							, @creation_method_update_l3
							, @organization_id_update_l3
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
							`syst_updated_datetime` = @syst_updated_datetime_update_l3
							, `update_system_id` = @update_system_id_update_l3
							, `updated_by_id` = @updated_by_id_update_l3
							, `update_method` = @update_method_update_l3
							, `organization_id` = @organization_id_update_l3
							, `uneet_name` = @uneet_name_update_l3
							, `unee_t_unit_type` = @unee_t_unit_type_update_l3
							, `is_update_needed` = 1
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