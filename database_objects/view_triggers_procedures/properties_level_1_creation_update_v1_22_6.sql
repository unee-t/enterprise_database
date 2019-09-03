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

	SET @is_creation_needed_in_unee_t_insert_ext_l1_1 = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator_insert_ext_l1_1 = NEW.`created_by_id` ;
	SET @source_system_updater_insert_ext_l1_1 = (IF(NEW.`updated_by_id` IS NULL
			, @source_system_creator_insert_ext_l1_1
			, NEW.`updated_by_id`
			)
		);

	SET @creator_mefe_user_id_insert_ext_l1_1 = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator_insert_ext_l1_1
		)
		;

	SET @upstream_create_method_insert_ext_l1_1 = NEW.`creation_method` ;
	SET @upstream_update_method_insert_ext_l1_1 = NEW.`update_method` ;

	SET @external_system_id_insert_ext_l1_1 = NEW.`external_system_id` ; 
	SET @external_table_insert_ext_l1_1 = NEW.`external_table` ;
	SET @external_id_insert_ext_l1_1 = NEW.`external_id` ;
	SET @tower_insert_ext_l1_1 = NEW.`tower` ;

	SET @organization_id_insert_ext_l1_1 = @source_system_creator_insert_ext_l1_1 ;

	SET @id_in_property_level_1_buildings_insert_ext_l1_1 = (SELECT `id_building`
		FROM `property_level_1_buildings`
		WHERE `external_system_id` = @external_system_id_insert_ext_l1_1
			AND `external_table` = @external_table_insert_ext_l1_1
			AND `external_id` = @external_id_insert_ext_l1_1
			AND `tower` = @tower_insert_ext_l1_1
			AND `organization_id` = @organization_id_insert_ext_l1_1
		);

	SET @upstream_do_not_insert_insert_ext_l1_1 = NEW.`do_not_insert` ;

	# This is an INSERT - the record should NOT exist already

		SET @do_not_insert_insert_ext_l1_1 = (IF (@id_in_property_level_1_buildings_insert_ext_l1_1 IS NULL
				, 0
				, @upstream_do_not_insert_insert_ext_l1_1
				)
			);

	# Get the information about the area for that building...
	# We need the information from the table `property_groups_areas` (and NOT the table `external_property_groups_areas`)

		SET @area_id_1_insert_ext_l1_1 = NEW.`area_id` ;

		SET @area_external_id_insert_ext_l1_1 = (SELECT `external_id`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_1_insert_ext_l1_1
			);
		SET @area_external_system_id_insert_ext_l1_1 = (SELECT `external_system_id`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_1_insert_ext_l1_1
			);
		SET @area_external_table_insert_ext_l1_1 = (SELECT `external_table`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_1_insert_ext_l1_1
			);

		SET @area_id_2_insert_ext_l1_1 = (SELECT `id_area`
			FROM `property_groups_areas`
			WHERE `external_id` = @area_external_id_insert_ext_l1_1
				AND `external_system_id` = @area_external_system_id_insert_ext_l1_1
			   	AND `external_table` = @area_external_table_insert_ext_l1_1
			   	AND `organization_id` = @organization_id_insert_ext_l1_1
			);

	IF @is_creation_needed_in_unee_t_insert_ext_l1_1 = 1
		AND @do_not_insert_insert_ext_l1_1 = 0
		AND @external_id_insert_ext_l1_1 IS NOT NULL
		AND @external_system_id_insert_ext_l1_1 IS NOT NULL
		AND @external_table_insert_ext_l1_1 IS NOT NULL
		AND @tower_insert_ext_l1_1 IS NOT NULL
		AND @organization_id_insert_ext_l1_1 IS NOT NULL
		AND @area_id_2_insert_ext_l1_1 IS NOT NULL
		AND 
		(@upstream_create_method_insert_ext_l1_1 = 'imported_from_hmlet_ipi'
			OR @upstream_create_method_insert_ext_l1_1 = 'Manage_Buildings_Add_Page'
			OR @upstream_create_method_insert_ext_l1_1 = 'Manage_Buildings_Edit_Page'
			OR @upstream_create_method_insert_ext_l1_1 = 'Manage_Buildings_Import_Page'
			OR @upstream_create_method_insert_ext_l1_1 = 'Export_and_Import_Buildings_Import_Page'
			OR @upstream_update_method_insert_ext_l1_1 = 'imported_from_hmlet_ipi'
			OR @upstream_update_method_insert_ext_l1_1 = 'Manage_Buildings_Add_Page'
			OR @upstream_update_method_insert_ext_l1_1 = 'Manage_Buildings_Edit_Page'
			OR @upstream_update_method_insert_ext_l1_1 = 'Manage_Buildings_Import_Page'
			OR @upstream_update_method_insert_ext_l1_1 = 'Export_and_Import_Buildings_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `property_level_1_buildings` table:

		SET @this_trigger_insert_ext_l1_1 := 'ut_insert_external_property_level_1' ;

		SET @syst_created_datetime_insert_ext_l1_1 = NOW();
		SET @creation_system_id_insert_ext_l1_1 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator_insert_ext_l1_1
			)
			;
		SET @created_by_id_insert_ext_l1_1 = @creator_mefe_user_id_insert_ext_l1_1 ;
		SET @downstream_creation_method_insert_ext_l1_1 = @this_trigger_insert_ext_l1_1 ;

		SET @syst_updated_datetime_insert_ext_l1_1 = NOW();

		SET @update_system_id_insert_ext_l1_1 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater_insert_ext_l1_1
			)
			;
		SET @updated_by_id_insert_ext_l1_1 = @creator_mefe_user_id_insert_ext_l1_1 ;
		SET @downstream_update_method_insert_ext_l1_1 = @this_trigger_insert_ext_l1_1 ;

		SET @organization_id_create_insert_ext_l1_1 = @source_system_creator_insert_ext_l1_1 ;
		SET @organization_id_update_insert_ext_l1_1 = @source_system_updater_insert_ext_l1_1;

		SET @is_obsolete_insert_ext_l1_1 = NEW.`is_obsolete` ;
		SET @order_insert_ext_l1_1 = NEW.`order` ;

		SET @unee_t_unit_type_insert_ext_l1_1 = NEW.`unee_t_unit_type` ;
		SET @designation_insert_ext_l1_1 = NEW.`designation` ;

		SET @address_1_insert_ext_l1_1 = NEW.`address_1` ;
		SET @address_2_insert_ext_l1_1 = NEW.`address_2` ;
		SET @zip_postal_code_insert_ext_l1_1 = NEW.`zip_postal_code` ;
		SET @state_insert_ext_l1_1 = NEW.`state` ;
		SET @city_insert_ext_l1_1 = NEW.`city` ;
		SET @country_code_insert_ext_l1_1 = NEW.`country_code` ;

		SET @description_insert_ext_l1_1 = NEW.`description` ;

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
				(@external_id_insert_ext_l1_1
				, @external_system_id_insert_ext_l1_1
				, @external_table_insert_ext_l1_1
				, @syst_created_datetime_insert_ext_l1_1
				, @creation_system_id_insert_ext_l1_1
				, @created_by_id_insert_ext_l1_1
				, @downstream_creation_method_insert_ext_l1_1
				, @organization_id_create_insert_ext_l1_1
				, @is_obsolete_insert_ext_l1_1
				, @order_insert_ext_l1_1
				, @area_id_2_insert_ext_l1_1
				, @is_creation_needed_in_unee_t_insert_ext_l1_1
				, @do_not_insert_insert_ext_l1_1_insert_ext_l1_1
				, @unee_t_unit_type_insert_ext_l1_1
				, @designation_insert_ext_l1_1
				, @tower_insert_ext_l1_1
				, @address_1_insert_ext_l1_1
				, @address_2_insert_ext_l1_1
				, @zip_postal_code_insert_ext_l1_1
				, @state_insert_ext_l1_1
				, @city_insert_ext_l1_1
				, @country_code_insert_ext_l1_1
				, @description_insert_ext_l1_1
				)
			ON DUPLICATE KEY UPDATE
				`syst_updated_datetime` = @syst_updated_datetime_insert_ext_l1_1
				, `update_system_id` = @update_system_id_insert_ext_l1_1
				, `updated_by_id` = @updated_by_id_insert_ext_l1_1
				, `update_method` = @downstream_update_method_insert_ext_l1_1
				, `organization_id` = @organization_id_update_insert_ext_l1_1
				, `is_obsolete` = @is_obsolete_insert_ext_l1_1
				, `order` = @order_insert_ext_l1_1
				, `area_id` = @area_id_2_insert_ext_l1_1
				, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t_insert_ext_l1_1
				, `do_not_insert` = @do_not_insert_insert_ext_l1_1
				, `unee_t_unit_type` = @unee_t_unit_type_insert_ext_l1_1
				, `designation` = @designation_insert_ext_l1_1
				, `tower` = @tower_insert_ext_l1_1
				, `address_1` = @address_1_insert_ext_l1_1
				, `address_2` = @address_2_insert_ext_l1_1
				, `zip_postal_code` = @zip_postal_code_insert_ext_l1_1
				, `state` = @state_insert_ext_l1_1
				, `city` = @city_insert_ext_l1_1
				, `country_code` = @country_code_insert_ext_l1_1
				, `description` = @description_insert_ext_l1_1
			;

	END IF;

# Housekeeping - we make sure that if a building is obsolete - all units in that building are obsolete too

	SET @building_system_id_insert_ext_l1_1 = NEW.`id_building` ;

		UPDATE `external_property_level_2_units` AS `a`
			INNER JOIN `external_property_level_1_buildings` AS `b`
				ON (`a`.`building_system_id` = `b`.`id_building`)
			SET `a`.`is_obsolete` = `b`.`is_obsolete`
			WHERE `a`.`building_system_id` = @building_system_id_insert_ext_l1_1
				AND `a`.`tower` = @tower_insert_ext_l1_1
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

	SET @is_creation_needed_in_unee_t_update_ext_l1_1 = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator_update_ext_l1_1 = NEW.`created_by_id` ;
	SET @source_system_updater_update_ext_l1_1 = (IF(NEW.`updated_by_id` IS NULL
			, @source_system_creator_update_ext_l1_1
			, NEW.`updated_by_id`
			)
		);

	SET @creator_mefe_user_id_update_ext_l1_1 = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator_update_ext_l1_1
		)
		;

	SET @upstream_create_method_update_ext_l1_1 = NEW.`creation_method` ;
	SET @upstream_update_method_update_ext_l1_1 = NEW.`update_method` ;

	SET @organization_id_update_ext_l1_1 = @source_system_creator_update_ext_l1_1 ;

	SET @external_id_update_ext_l1_1 = NEW.`external_id` ;
	SET @external_system_id_update_ext_l1_1 = NEW.`external_system_id` ; 
	SET @external_table_update_ext_l1_1 = NEW.`external_table` ;
	SET @tower_update_ext_l1_1 = NEW.`tower` ;

	SET @new_is_creation_needed_in_unee_t_update_ext_l1_1 = NEW.`is_creation_needed_in_unee_t` ;
	SET @old_is_creation_needed_in_unee_t_update_ext_l1_1 = OLD.`is_creation_needed_in_unee_t` ;

	SET @id_in_property_level_1_buildings_update_ext_l1_1 = (SELECT `id_building`
		FROM `property_level_1_buildings`
		WHERE `external_system_id` = @external_system_id_update_ext_l1_1
			AND `external_table` = @external_table_update_ext_l1_1
			AND `external_id` = @external_id_update_ext_l1_1
			AND `organization_id` = @organization_id_update_ext_l1_1
			AND `tower` = @tower_update_ext_l1_1
		);

	SET @upstream_do_not_insert_update_ext_l1_1 = NEW.`do_not_insert` ;

	# This is an UPDATE - the record SHOULD exist already
		SET @do_not_insert_update_ext_l1_1 = (IF (@id_in_property_level_1_buildings_update_ext_l1_1 IS NULL
				, 1
				, @upstream_do_not_insert_update_ext_l1_1
				)
			);

	# Get the information about the area for that building...
	# We need the information from the table `property_groups_areas` (and NOT the table `external_property_groups_areas`)

		SET @area_id_1_update_ext_l1_1 = NEW.`area_id` ;

		SET @area_external_id_update_ext_l1_1 = (SELECT `external_id`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_1_update_ext_l1_1
			);
		SET @area_external_system_id_update_ext_l1_1 = (SELECT `external_system_id`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_1_update_ext_l1_1
			);
		SET @area_external_table_update_ext_l1_1 = (SELECT `external_table`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_1_update_ext_l1_1
			);

		SET @area_id_2_update_ext_l1_1 = (SELECT `id_area`
			FROM `property_groups_areas`
			WHERE `external_id` = @area_external_id_update_ext_l1_1
				AND `external_system_id` = @area_external_system_id_update_ext_l1_1
			   	AND `external_table` = @area_external_table_update_ext_l1_1
			   	AND `organization_id` = @organization_id_update_ext_l1_1
			);

	IF @is_creation_needed_in_unee_t_update_ext_l1_1 = 1
		AND @new_is_creation_needed_in_unee_t_update_ext_l1_1 = @old_is_creation_needed_in_unee_t_update_ext_l1_1
		AND @do_not_insert_update_ext_l1_1 = 0
		AND @external_id_update_ext_l1_1 IS NOT NULL
		AND @external_system_id_update_ext_l1_1 IS NOT NULL
		AND @external_table_update_ext_l1_1 IS NOT NULL
		AND @tower_update_ext_l1_1 IS NOT NULL
		AND @organization_id_update_ext_l1_1 IS NOT NULL
		AND @area_id_2_update_ext_l1_1 IS NOT NULL
		AND (@upstream_create_method_update_ext_l1_1 = 'imported_from_hmlet_ipi'
			OR @upstream_update_method_update_ext_l1_1 = 'imported_from_hmlet_ipi'
			OR @upstream_create_method_update_ext_l1_1 = 'Manage_Buildings_Add_Page'
			OR @upstream_update_method_update_ext_l1_1 = 'Manage_Buildings_Add_Page'
			OR @upstream_create_method_update_ext_l1_1 = 'Manage_Buildings_Edit_Page'
			OR @upstream_update_method_update_ext_l1_1 = 'Manage_Buildings_Edit_Page'
			OR @upstream_create_method_update_ext_l1_1 = 'Manage_Buildings_Import_Page'
			OR @upstream_update_method_update_ext_l1_1 = 'Manage_Buildings_Import_Page'
			OR @upstream_create_method_update_ext_l1_1 = 'Export_and_Import_Buildings_Import_Page'
			OR @upstream_update_method_update_ext_l1_1 = 'Export_and_Import_Buildings_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `property_level_1_buildings` table:

		SET @this_trigger_update_ext_l1_1 = 'ut_update_external_property_level_1';

		SET @syst_created_datetime_update_ext_l1_1 = NOW();
		SET @creation_system_id_update_ext_l1_1 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator_update_ext_l1_1
			)
			;
		SET @created_by_id_update_ext_l1_1 = @creator_mefe_user_id_update_ext_l1_1 ;
		SET @downstream_creation_method_update_ext_l1_1 = @this_trigger_update_ext_l1_1 ;

		SET @syst_updated_datetime_update_ext_l1_1 = NOW();

		SET @update_system_id_update_ext_l1_1 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater_update_ext_l1_1
			)
			;
		SET @updated_by_id_update_ext_l1_1 = @creator_mefe_user_id_update_ext_l1_1 ;
		SET @downstream_update_method_update_ext_l1_1 = @this_trigger_update_ext_l1_1 ;

		SET @organization_id_create_update_ext_l1_1 = @source_system_creator_update_ext_l1_1;
		SET @organization_id_update_update_ext_l1_1 = @source_system_updater_update_ext_l1_1;

		SET @is_obsolete_update_ext_l1_1 = NEW.`is_obsolete` ;
		SET @order_update_ext_l1_1 = NEW.`order` ;

		SET @unee_t_unit_type_update_ext_l1_1 = NEW.`unee_t_unit_type` ;
		SET @designation_update_ext_l1_1 = NEW.`designation` ;

		SET @address_1_update_ext_l1_1 = NEW.`address_1` ;
		SET @address_2_update_ext_l1_1 = NEW.`address_2` ;
		SET @zip_postal_code_update_ext_l1_1 = NEW.`zip_postal_code` ;
		SET @state_update_ext_l1_1 = NEW.`state` ;
		SET @city_update_ext_l1_1 = NEW.`city` ;
		SET @country_code_update_ext_l1_1 = NEW.`country_code` ;

		SET @description_update_ext_l1_1 = NEW.`description` ;

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
				(@external_id_update_ext_l1_1
				, @external_system_id_update_ext_l1_1
				, @external_table_update_ext_l1_1
				, @syst_created_datetime_update_ext_l1_1
				, @creation_system_id_update_ext_l1_1
				, @created_by_id_update_ext_l1_1
				, @downstream_creation_method_update_ext_l1_1
				, @organization_id_create_update_ext_l1_1
				, @is_obsolete_update_ext_l1_1
				, @order_update_ext_l1_1
				, @area_id_2_update_ext_l1_1
				, @is_creation_needed_in_unee_t_update_ext_l1_1
				, @do_not_insert_update_ext_l1_1
				, @unee_t_unit_type_update_ext_l1_1
				, @designation_update_ext_l1_1
				, @tower_update_ext_l1_1
				, @address_1_update_ext_l1_1
				, @address_2_update_ext_l1_1
				, @zip_postal_code_update_ext_l1_1
				, @state_update_ext_l1_1
				, @city_update_ext_l1_1
				, @country_code_update_ext_l1_1
				, @description_update_ext_l1_1
				)
			ON DUPLICATE KEY UPDATE
				`syst_updated_datetime` = @syst_updated_datetime_update_ext_l1_1
				, `update_system_id` = @update_system_id_update_ext_l1_1
				, `updated_by_id` = @updated_by_id_update_ext_l1_1
				, `update_method` = @downstream_update_method_update_ext_l1_1
				, `organization_id` = @organization_id_update_update_ext_l1_1
				, `is_obsolete` = @is_obsolete_update_ext_l1_1
				, `order` = @order_update_ext_l1_1
				, `area_id` = @area_id_2_update_ext_l1_1
				, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t_update_ext_l1_1
				, `do_not_insert` = @do_not_insert_update_ext_l1_1
				, `unee_t_unit_type` = @unee_t_unit_type_update_ext_l1_1
				, `designation` = @designation_update_ext_l1_1
				, `tower` = @tower_update_ext_l1_1
				, `address_1` = @address_1_update_ext_l1_1
				, `address_2` = @address_2_update_ext_l1_1
				, `zip_postal_code` = @zip_postal_code_update_ext_l1_1
				, `state` = @state_update_ext_l1_1
				, `city` = @city_update_ext_l1_1
				, `country_code` = @country_code_update_ext_l1_1
				, `description` = @description_update_ext_l1_1
			;

	END IF;

# Housekeeping - we make sure that if a building is obsolete - all units in that building are obsolete too

	SET @building_system_id_update_ext_l1_1 = NEW.`id_building` ;

		UPDATE `external_property_level_2_units` AS `a`
			INNER JOIN `external_property_level_1_buildings` AS `b`
				ON (`a`.`building_system_id` = `b`.`id_building`)
			SET `a`.`is_obsolete` = `b`.`is_obsolete`
			WHERE `a`.`building_system_id` = @building_system_id_update_ext_l1_1
				AND `a`.`tower` = @tower_update_ext_l1_1
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

	SET @is_creation_needed_in_unee_t_update_ext_l1_2 = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator_update_ext_l1_2 = NEW.`created_by_id` ;
	SET @source_system_updater_update_ext_l1_2 = (IF(NEW.`updated_by_id` IS NULL
			, @source_system_creator_update_ext_l1_2
			, NEW.`updated_by_id`
			)
		);

	SET @creator_mefe_user_id_update_ext_l1_2 = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator_update_ext_l1_2
		)
		;

	SET @upstream_create_method_update_ext_l1_2 = NEW.`creation_method` ;
	SET @upstream_update_method_update_ext_l1_2 = NEW.`update_method` ;

	SET @organization_id_update_ext_l1_2 = @source_system_creator_update_ext_l1_2 ;

	SET @external_id_update_ext_l1_2 = NEW.`external_id` ;
	SET @external_system_id_update_ext_l1_2 = NEW.`external_system_id` ; 
	SET @external_table_update_ext_l1_2 = NEW.`external_table` ;
	SET @tower_update_ext_l1_2 = NEW.`tower` ;

	SET @new_is_creation_needed_in_unee_t_update_ext_l1_2 = NEW.`is_creation_needed_in_unee_t` ;
	SET @old_is_creation_needed_in_unee_t_update_ext_l1_2 = OLD.`is_creation_needed_in_unee_t` ;

	SET @id_in_property_level_1_buildings_update_ext_l1_2 = (SELECT `id_building`
		FROM `property_level_1_buildings`
		WHERE `external_system_id` = @external_system_id_update_ext_l1_2
			AND `external_table` = @external_table_update_ext_l1_2
			AND `external_id` = @external_id_update_ext_l1_2
			AND `organization_id` = @organization_id_update_ext_l1_2
			AND `tower` = @tower_update_ext_l1_2
		);

	SET @upstream_do_not_insert_update_ext_l1_2 = NEW.`do_not_insert` ;

	# This is an UPDATE - the record SHOULD exist already
	# BUT there are some edge cases when we need to re-create this...

		SET @do_not_insert_update_ext_l1_2 = @upstream_do_not_insert_update_ext_l1_2 ;

	# Get the information about the area for that building...
	# We need the information from the table `property_groups_areas` (and NOT the table `external_property_groups_areas`)

		SET @area_id_1_update_ext_l1_2 = NEW.`area_id` ;

		SET @area_external_id_update_ext_l1_2 = (SELECT `external_id`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_1_update_ext_l1_2
			);
		SET @area_external_system_id_update_ext_l1_2 = (SELECT `external_system_id`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_1_update_ext_l1_2
			);
		SET @area_external_table_update_ext_l1_2 = (SELECT `external_table`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_1_update_ext_l1_2
			);

		SET @area_id_2_update_ext_l1_2 = (SELECT `id_area`
			FROM `property_groups_areas`
			WHERE `external_id` = @area_external_id_update_ext_l1_2
				AND `external_system_id` = @area_external_system_id_update_ext_l1_2
			   	AND `external_table` = @area_external_table_update_ext_l1_2
			   	AND `organization_id` = @organization_id_update_ext_l1_2
			);

	IF @is_creation_needed_in_unee_t_update_ext_l1_2 = 1
		AND @id_in_property_level_1_buildings_update_ext_l1_2 IS NULL
		AND @do_not_insert_update_ext_l1_2 = 0
		AND @external_id_update_ext_l1_2 IS NOT NULL
		AND @external_system_id_update_ext_l1_2 IS NOT NULL
		AND @external_table_update_ext_l1_2 IS NOT NULL
		AND @tower_update_ext_l1_2 IS NOT NULL
		AND @organization_id_update_ext_l1_2 IS NOT NULL
		AND @area_id_2_update_ext_l1_2 IS NOT NULL
		AND (@upstream_create_method_update_ext_l1_2 = 'imported_from_hmlet_ipi'
			OR @upstream_update_method_update_ext_l1_2 = 'imported_from_hmlet_ipi'
			OR @upstream_create_method_update_ext_l1_2 = 'Manage_Buildings_Add_Page'
			OR @upstream_update_method_update_ext_l1_2 = 'Manage_Buildings_Add_Page'
			OR @upstream_create_method_update_ext_l1_2 = 'Manage_Buildings_Edit_Page'
			OR @upstream_update_method_update_ext_l1_2 = 'Manage_Buildings_Edit_Page'
			OR @upstream_create_method_update_ext_l1_2 = 'Manage_Buildings_Import_Page'
			OR @upstream_update_method_update_ext_l1_2 = 'Manage_Buildings_Import_Page'
			OR @upstream_create_method_update_ext_l1_2 = 'Export_and_Import_Buildings_Import_Page'
			OR @upstream_update_method_update_ext_l1_2 = 'Export_and_Import_Buildings_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `property_level_1_buildings` table:

		SET @this_trigger_update_ext_l1_2 = 'ut_update_external_property_level_1_creation_needed';

		SET @syst_created_datetime_update_ext_l1_2 = NOW();
		SET @creation_system_id_update_ext_l1_2 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator_update_ext_l1_2
			)
			;
		SET @created_by_id_update_ext_l1_2 = @creator_mefe_user_id_update_ext_l1_2 ;
		SET @downstream_creation_method_update_ext_l1_2 = @this_trigger_update_ext_l1_2 ;

		SET @syst_updated_datetime_update_ext_l1_2 = NOW();

		SET @update_system_id_update_ext_l1_2 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater_update_ext_l1_2
			)
			;
		SET @updated_by_id_update_ext_l1_2 = @creator_mefe_user_id_update_ext_l1_2 ;
		SET @downstream_update_method_update_ext_l1_2 = @this_trigger_update_ext_l1_2 ;

		SET @organization_id_create_update_ext_l1_2 = @source_system_creator_update_ext_l1_2;
		SET @organization_id_update_update_ext_l1_2 = @source_system_updater_update_ext_l1_2;

		SET @is_obsolete_update_ext_l1_2 = NEW.`is_obsolete` ;
		SET @order_update_ext_l1_2 = NEW.`order` ;

		SET @unee_t_unit_type_update_ext_l1_2 = NEW.`unee_t_unit_type` ;
		SET @designation_update_ext_l1_2 = NEW.`designation` ;

		SET @address_1_update_ext_l1_2 = NEW.`address_1` ;
		SET @address_2_update_ext_l1_2 = NEW.`address_2` ;
		SET @zip_postal_code_update_ext_l1_2 = NEW.`zip_postal_code` ;
		SET @state_update_ext_l1_2 = NEW.`state` ;
		SET @city_update_ext_l1_2 = NEW.`city` ;
		SET @country_code_update_ext_l1_2 = NEW.`country_code` ;

		SET @description_update_ext_l1_2 = NEW.`description` ;

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
				(@external_id_update_ext_l1_2
				, @external_system_id_update_ext_l1_2
				, @external_table_update_ext_l1_2
				, @syst_created_datetime_update_ext_l1_2
				, @creation_system_id_update_ext_l1_2
				, @created_by_id_update_ext_l1_2
				, @downstream_creation_method_update_ext_l1_2
				, @organization_id_create_update_ext_l1_2
				, @is_obsolete_update_ext_l1_2
				, @order_update_ext_l1_2
				, @area_id_2_update_ext_l1_2
				, @is_creation_needed_in_unee_t_update_ext_l1
				, @do_not_insert_update_ext_l1_2
				, @unee_t_unit_type_update_ext_l1_2
				, @designation_update_ext_l1_2
				, @tower_update_ext_l1_2
				, @address_1_update_ext_l1_2
				, @address_2_update_ext_l1_2
				, @zip_postal_code_update_ext_l1_2
				, @state_update_ext_l1_2
				, @city_update_ext_l1_2
				, @country_code_update_ext_l1_2
				, @description_update_ext_l1_2
				)
			ON DUPLICATE KEY UPDATE
				`syst_updated_datetime` = @syst_updated_datetime_update_ext_l1_2
				, `update_system_id` = @update_system_id_update_ext_l1_2
				, `updated_by_id` = @updated_by_id_update_ext_l1_2
				, `update_method` = @downstream_update_method_update_ext_l1_2
				, `organization_id` = @organization_id_update_update_ext_l1_2
				, `is_obsolete` = @is_obsolete_update_ext_l1_2
				, `order` = @order_update_ext_l1_2
				, `area_id` = @area_id_2_update_ext_l1_2
				, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t_update_ext_l1
				, `do_not_insert` = @do_not_insert_update_ext_l1_2
				, `unee_t_unit_type` = @unee_t_unit_type_update_ext_l1_2
				, `designation` = @designation_update_ext_l1_2
				, `tower` = @tower_update_ext_l1_2
				, `address_1` = @address_1_update_ext_l1_2
				, `address_2` = @address_2_update_ext_l1_2
				, `zip_postal_code` = @zip_postal_code_update_ext_l1_2
				, `state` = @state_update_ext_l1_2
				, `city` = @city_update_ext_l1_2
				, `country_code` = @country_code_update_ext_l1_2
				, `description` = @description_update_ext_l1_2
			;

	END IF;

# Housekeeping - we make sure that if a building is obsolete - all units in that building are obsolete too

	SET @building_system_id_update_ext_l1_2 = NEW.`id_building` ;

		UPDATE `external_property_level_2_units` AS `a`
			INNER JOIN `external_property_level_1_buildings` AS `b`
				ON (`a`.`building_system_id` = `b`.`id_building`)
			SET `a`.`is_obsolete` = `b`.`is_obsolete`
			WHERE `a`.`building_system_id` = @building_system_id_update_ext_l1_2
				AND `a`.`tower` = @tower_update_ext_l1_2
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