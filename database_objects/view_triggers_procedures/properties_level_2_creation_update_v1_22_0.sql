#################
#
# This lists all the triggers we use to create 
# a property_level_2
# via the Unee-T Enterprise Interface
#
#################

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

	SET @is_creation_needed_in_unee_t_insert_ext_l2_1 = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator_insert_ext_l2_1 = NEW.`created_by_id` ;
	SET @source_system_updater_insert_ext_l2_1 = (IF(NEW.`updated_by_id` IS NULL
			, @source_system_creator_insert_ext_l2_1
			, NEW.`updated_by_id`
			)
		);

	SET @creator_mefe_user_id_insert_ext_l2_1 = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator_insert_ext_l2_1
		)
		;

	SET @upstream_create_method_insert_ext_l2_1 = NEW.`creation_method` ;
	SET @upstream_update_method_insert_ext_l2_1 = NEW.`update_method` ;

	SET @external_system_id_insert_ext_l2_1 = NEW.`external_system_id` ;
	SET @external_table_insert_ext_l2_1 = NEW.`external_table` ;
	SET @external_id_insert_ext_l2_1 = NEW.`external_id` ;

	SET @organization_id_insert_ext_l2_1 = @source_system_creator_insert_ext_l2_1 ;

	SET @id_in_property_level_2_units_insert_ext_l2_1 = (SELECT `system_id_unit`
		FROM `property_level_2_units`
		WHERE `external_system_id` = @external_system_id_insert_ext_l2_1
			AND `external_table` = @external_table_insert_ext_l2_1
			AND `external_id` = @external_id_insert_ext_l2_1
			AND `organization_id` = @organization_id_insert_ext_l2_1
		);
		
	SET @upstream_do_not_insert_insert_ext_l2_1 = NEW.`do_not_insert` ;

	# This is an INSERT - the record should NOT exist already

		SET @do_not_insert_insert_ext_l2_1 = (IF (@id_in_property_level_2_units_insert_ext_l2_1 IS NULL
				, 0
				, @upstream_do_not_insert_insert_ext_l2_1
				)
			
			);

	# Get the information about the building for that unit...
	# We need the information from the table `external_property_level_2_units` (and NOT the table `external_external_property_level_1_buildings`)
	
		SET @building_id_1_insert_ext_l2_1 = NEW.`building_system_id` ;

		SET @tower_insert_ext_l2_1 = NEW.`tower` ;

		SET @building_external_id_insert_ext_l2_1 = (SELECT `external_id`
			FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_1_insert_ext_l2_1
				);
		SET @building_external_system_id_insert_ext_l2_1 = (SELECT `external_system_id`
			FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_1_insert_ext_l2_1
			);
		SET @building_external_table_insert_ext_l2_1 = (SELECT `external_table`
		   FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_1_insert_ext_l2_1
			);
		SET @building_external_tower_insert_ext_l2_1 = (SELECT `tower`
			FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_1_insert_ext_l2_1
			);

		SET @building_system_id_insert_ext_l2_1 = (SELECT `id_building`
			FROM `property_level_1_buildings`
			WHERE `external_id` = @building_external_id_insert_ext_l2_1
				AND `external_system_id` = @building_external_system_id_insert_ext_l2_1
				AND `external_table` = @building_external_table_insert_ext_l2_1
				AND `organization_id` = @organization_id_insert_ext_l2_1
				AND `tower` = @building_external_tower_insert_ext_l2_1
				);

	IF @is_creation_needed_in_unee_t_insert_ext_l2_1 = 1
		AND @do_not_insert_insert_ext_l2_1 = 0
		AND @external_id_insert_ext_l2_1 IS NOT NULL
		AND @external_system_id_insert_ext_l2_1 IS NOT NULL
		AND @external_table_insert_ext_l2_1 IS NOT NULL
		AND @organization_id_insert_ext_l2_1 IS NOT NULL
		AND @building_system_id_insert_ext_l2_1 IS NOT NULL
		AND (@upstream_create_method_insert_ext_l2_1 = 'imported_from_hmlet_ipi'
			OR @upstream_create_method_insert_ext_l2_1 = 'Manage_Units_Add_Page'
			OR @upstream_create_method_insert_ext_l2_1 = 'Manage_Units_Edit_Page'
			OR @upstream_create_method_insert_ext_l2_1 = 'Manage_Units_Import_Page'
			OR @upstream_update_method_insert_ext_l2_1 = 'imported_from_hmlet_ipi'
			OR @upstream_update_method_insert_ext_l2_1 = 'Manage_Units_Add_Page'
			OR @upstream_update_method_insert_ext_l2_1 = 'Manage_Units_Edit_Page'
			OR @upstream_create_method_insert_ext_l2_1 = 'Manage_Units_Import_Page'
			OR @upstream_update_method_insert_ext_l2_1 = 'Export_and_Import_Units_Import_Page'
			OR @upstream_create_method_insert_ext_l2_1 = 'Export_and_Import_Units_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `external_property_level_2_units` table:

		SET @this_trigger_insert_ext_l2_1 = 'ut_insert_external_property_level_2' ;

		SET @syst_created_datetime_insert_ext_l2_1 = NOW();
		SET @creation_system_id_insert_ext_l2_1 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator_insert_ext_l2_1
			)
			;
		SET @created_by_id_insert_ext_l2_1 = @creator_mefe_user_id_insert_ext_l2_1 ;
		SET @downstream_creation_method_insert_ext_l2_1 = @this_trigger_insert_ext_l2_1 ;

		SET @syst_updated_datetime_insert_ext_l2_1 = NOW();

		SET @update_system_id_insert_ext_l2_1 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater_insert_ext_l2_1
			)
			;
		SET @updated_by_id_insert_ext_l2_1 = @creator_mefe_user_id_insert_ext_l2_1 ;
		SET @downstream_update_method_insert_ext_l2_1 = @this_trigger_insert_ext_l2_1 ;

		SET @organization_id_create_insert_ext_l2_1 = @source_system_creator_insert_ext_l2_1 ;
		SET @organization_id_update_insert_ext_l2_1 = @source_system_updater_insert_ext_l2_1;

		SET @activated_by_id_insert_ext_l2_1 = NEW.`activated_by_id` ;
		SET @is_obsolete_insert_ext_l2_1 = NEW.`is_obsolete` ;
		SET @is_creation_needed_in_unee_t_insert_ext_l2_1 = NEW.`is_creation_needed_in_unee_t` ;
		SET @unee_t_unit_type_insert_ext_l2_1 = NEW.`unee_t_unit_type` ;
			
		SET @unit_category_id_insert_ext_l2_1 = NEW.`unit_category_id` ;
		SET @designation_insert_ext_l2_1 = NEW.`designation` ;
		SET @count_rooms_insert_ext_l2_1 = NEW.`count_rooms` ;
		SET @unit_id_insert_ext_l2_1 = NEW.`unit_id` ;
		SET @surface_insert_ext_l2_1 = NEW.`surface` ;
		SET @surface_measurment_unit_insert_ext_l2_1 = NEW.`surface_measurment_unit` ;
		SET @description_insert_ext_l2_1 = NEW.`description` ;

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
 				(@external_id_insert_ext_l2_1
				, @external_system_id_insert_ext_l2_1
				, @external_table_insert_ext_l2_1
				, @syst_created_datetime_insert_ext_l2_1
				, @creation_system_id_insert_ext_l2_1
				, @created_by_id_insert_ext_l2_1
				, @downstream_creation_method_insert_ext_l2_1
				, @organization_id_create_insert_ext_l2_1
				, @activated_by_id_insert_ext_l2_1
				, @is_obsolete_insert_ext_l2_1
				, @is_creation_needed_in_unee_t_insert_ext_l2_1
				, @do_not_insert_insert_ext_l2_1
				, @unee_t_unit_type_insert_ext_l2_1
				, @building_system_id_insert_ext_l2_1
				, @tower_insert_ext_l2_1
				, @unit_category_id_insert_ext_l2_1
				, @designation_insert_ext_l2_1
				, @count_rooms_insert_ext_l2_1
				, @unit_id_insert_ext_l2_1
				, @surface_insert_ext_l2_1
				, @surface_measurment_unit_insert_ext_l2_1
				, @description_insert_ext_l2_1
 			)
			ON DUPLICATE KEY UPDATE
 				`syst_updated_datetime` = @syst_updated_datetime_insert_ext_l2_1
 				, `update_system_id` = @update_system_id_insert_ext_l2_1
 				, `updated_by_id` = @updated_by_id_insert_ext_l2_1
				, `update_method` = @downstream_update_method_insert_ext_l2_1
				, `activated_by_id` = @activated_by_id_insert_ext_l2_1
				, `organization_id` = @organization_id_update_insert_ext_l2_1
				, `is_obsolete` = @is_obsolete_insert_ext_l2_1
				, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t_insert_ext_l2_1
				, `do_not_insert` = @do_not_insert_insert_ext_l2_1
				, `unee_t_unit_type` = @unee_t_unit_type_insert_ext_l2_1
				, `building_system_id` = @building_system_id_insert_ext_l2_1
				, `tower` = @tower_insert_ext_l2_1
				, `unit_category_id` = @unit_category_id_insert_ext_l2_1
				, `designation` = @designation_insert_ext_l2_1
				, `count_rooms` = @count_rooms_insert_ext_l2_1_insert_ext_l2_1
				, `unit_id` = @unit_id_insert_ext_l2_1
				, `surface` = @surface_insert_ext_l2_1
				, `surface_measurment_unit` = @surface_measurment_unit_insert_ext_l2_1
				, `description` = @description_insert_ext_l2_1
			;

	END IF;

# Housekeeping - we make sure that if a unit is obsolete - all rooms in that unit are obsolete too

	SET @system_id_unit_insert_ext_l2_1 = NEW.`system_id_unit` ;

	UPDATE `external_property_level_3_rooms` AS `a`
		INNER JOIN `external_property_level_2_units` AS `b`
			ON (`a`.`system_id_unit` = `b`.`system_id_unit`)
		SET `a`.`is_obsolete` = `b`.`is_obsolete`
		WHERE `a`.`system_id_unit` = @system_id_unit_insert_ext_l2_1
		;

END;
$$
DELIMITER ;

# We create a trigger when a record is updated in the `external_property_level_2_units` table
#	- The unit DOES exist in the table `external_property_level_2_units`
#	- This is a NOT a new creation request in Unee-T

	DROP TRIGGER IF EXISTS `ut_update_external_property_level_2`;

DELIMITER $$
CREATE TRIGGER `ut_update_external_property_level_2`
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
#		- ''

	SET @is_creation_needed_in_unee_t_update_ext_l2_1 = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator_update_ext_l2_1 = NEW.`created_by_id` ;
	SET @source_system_updater_update_ext_l2_1 = (IF(NEW.`updated_by_id` IS NULL
			, @source_system_creator_update_ext_l2_1
			, NEW.`updated_by_id`
			)
		);

	SET @creator_mefe_user_id_update_ext_l2_1 = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator_update_ext_l2_1
		)
		;

	SET @upstream_create_method_update_ext_l2_1 = NEW.`creation_method` ;
	SET @upstream_update_method_update_ext_l2_1 = NEW.`update_method` ;

	SET @organization_id_update_ext_l2_1 = @source_system_creator_update_ext_l2_1 ;

	SET @external_id_update_ext_l2_1 = NEW.`external_id` ;
	SET @external_system_id_update_ext_l2_1 = NEW.`external_system_id` ; 
	SET @external_table_update_ext_l2_1 = NEW.`external_table` ;
	SET @tower_update_ext_l2_1 = NEW.`tower` ;

	SET @new_is_creation_needed_in_unee_t_update_ext_l2_1 = NEW.`is_creation_needed_in_unee_t` ;
	SET @old_is_creation_needed_in_unee_t_update_ext_l2_1 = OLD.`is_creation_needed_in_unee_t` ;

	SET @id_in_property_level_2_units_update_ext_l2_1 = (SELECT `system_id_unit`
		FROM `property_level_2_units`
		WHERE `external_system_id` = @external_system_id_update_ext_l2_1
			AND `external_table` = @external_table_update_ext_l2_1
			AND `external_id` = @external_id_update_ext_l2_1
			AND `organization_id` = @organization_id_update_ext_l2_1
		);

	SET @upstream_do_not_insert_update_ext_l2_1 = NEW.`do_not_insert` ;

	# This is an UPDATE - the record SHOULD exist already

		SET @do_not_insert_update_ext_l2_1 = (IF (@id_in_property_level_2_units_update_ext_l2_1 IS NULL
				, 1
				, @upstream_do_not_insert_update_ext_l2_1
				)
			);

	# Get the information about the building for that unit...
	# We need the information from the table `external_property_level_2_units` (and NOT the table `external_external_property_level_1_buildings`)
	
		SET @building_id_1_update_ext_l2_1 = NEW.`building_system_id` ;

		SET @tower_update_ext_l2_1 = NEW.`tower` ;

		SET @building_external_id_update_ext_l2_1 = (SELECT `external_id`
			FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_1_update_ext_l2_1
				);
		SET @building_external_system_id_update_ext_l2_1 = (SELECT `external_system_id`
			FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_1_update_ext_l2_1
			);
		SET @building_external_table_update_ext_l2_1 = (SELECT `external_table`
		   FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_1_update_ext_l2_1
			);
		SET @building_external_tower_update_ext_l2_1 = (SELECT `tower`
			FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_1_update_ext_l2_1
			);

		SET @building_system_id_update_ext_l2_1 = (SELECT `id_building`
			FROM `property_level_1_buildings`
			WHERE `external_id` = @building_external_id_update_ext_l2_1
				AND `external_system_id` = @building_external_system_id_update_ext_l2_1
				AND `external_table` = @building_external_table_update_ext_l2_1
				AND `organization_id` = @organization_id_update_ext_l2_1
				AND `tower` = @building_external_tower_update_ext_l2_1
				);

	IF @is_creation_needed_in_unee_t_update_ext_l2_1 = 1
		AND @new_is_creation_needed_in_unee_t_update_ext_l2_1 = @old_is_creation_needed_in_unee_t_update_ext_l2_1
		AND @do_not_insert_update_ext_l2_1 = 0
		AND @external_id_update_ext_l2_1 IS NOT NULL
		AND @external_system_id_update_ext_l2_1 IS NOT NULL
		AND @external_table_update_ext_l2_1 IS NOT NULL
		AND @tower_update_ext_l2_1 IS NOT NULL
		AND @organization_id_update_ext_l2_1 IS NOT NULL
		AND @building_system_id_update_ext_l2_1 IS NOT NULL
		AND (@upstream_update_method_update_ext_l2_1 = 'imported_from_hmlet_ipi'
			OR @upstream_update_method_update_ext_l2_1 = 'Manage_Units_Add_Page'
			OR @upstream_update_method_update_ext_l2_1 = 'Manage_Units_Edit_Page'
			OR @upstream_update_method_update_ext_l2_1 = 'Manage_Units_Import_Page'
			OR @upstream_update_method_update_ext_l2_1 = 'Export_and_Import_Units_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `external_property_level_2_units` table:

		SET @this_trigger_update_ext_l2_1 = 'ut_update_external_property_level_2';

		SET @syst_created_datetime_update_ext_l2_1 = NOW();
		SET @creation_system_id_update_ext_l2_1 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator_update_ext_l2_1
			)
			;
		SET @created_by_id_update_ext_l2_1 = @creator_mefe_user_id_update_ext_l2_1 ;
		SET @downstream_creation_method_update_ext_l2_1 = @this_trigger_update_ext_l2_1 ;

		SET @syst_updated_datetime_update_ext_l2_1 = NOW();

		SET @update_system_id_update_ext_l2_1 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater_update_ext_l2_1
			)
			;
		SET @updated_by_id_update_ext_l2_1 = @creator_mefe_user_id_update_ext_l2_1 ;
		SET @downstream_update_method_update_ext_l2_1 = @this_trigger_update_ext_l2_1 ;

		SET @organization_id_create_update_ext_l2_1 = @source_system_creator_update_ext_l2_1 ;
		SET @organization_id_update_update_ext_l2_1 = @source_system_updater_update_ext_l2_1 ;

		SET @activated_by_id_update_ext_l2_1 = NEW.`activated_by_id` ;
		SET @is_obsolete_update_ext_l2_1 = NEW.`is_obsolete` ;
		SET @is_creation_needed_in_unee_t_update_ext_l2_1 = NEW.`is_creation_needed_in_unee_t` ;
		SET @unee_t_unit_type_update_ext_l2_1 = NEW.`unee_t_unit_type` ;
			
		SET @unit_category_id_update_ext_l2_1 = NEW.`unit_category_id` ;
		SET @designation_update_ext_l2_1 = NEW.`designation` ;
		SET @count_rooms_update_ext_l2_1 = NEW.`count_rooms` ;
		SET @unit_id_update_ext_l2_1 = NEW.`unit_id` ;
		SET @surface_update_ext_l2_1 = NEW.`surface` ;
		SET @surface_measurment_unit_update_ext_l2_1 = NEW.`surface_measurment_unit` ;
		SET @description_update_ext_l2_1 = NEW.`description` ;

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
 				(@external_id_update_ext_l2_1
				, @external_system_id_update_ext_l2_1
				, @external_table_update_ext_l2_1
				, @syst_created_datetime_update_ext_l2_1
				, @creation_system_id_update_ext_l2_1
				, @created_by_id_update_ext_l2_1
				, @downstream_creation_method_update_ext_l2_1
				, @organization_id_create_update_ext_l2_1
				, @activated_by_id_update_ext_l2_1
				, @is_obsolete_update_ext_l2_1
				, @is_creation_needed_in_unee_t_update_ext_l2_1
				, @do_not_insert_update_ext_l2_1
				, @unee_t_unit_type_update_ext_l2_1
				, @building_system_id_update_ext_l2_1
				, @tower_update_ext_l2_1
				, @unit_category_id_update_ext_l2_1
				, @designation_update_ext_l2_1
				, @count_rooms_update_ext_l2_1
				, @unit_id_update_ext_l2_1
				, @surface_update_ext_l2_1
				, @surface_measurment_unit_update_ext_l2_1
				, @description_update_ext_l2_1
 			)
			ON DUPLICATE KEY UPDATE
 				`syst_updated_datetime` = @syst_updated_datetime_update_ext_l2_1
 				, `update_system_id` = @update_system_id_update_ext_l2_1
 				, `updated_by_id` = @updated_by_id_update_ext_l2_1
				, `update_method` = @downstream_update_method_update_ext_l2_1
				, `organization_id` = @organization_id_update_update_ext_l2_1
				, `activated_by_id` = @activated_by_id_update_ext_l2_1
				, `is_obsolete` = @is_obsolete_update_ext_l2_1
				, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t_update_ext_l2_1
				, `do_not_insert` = @do_not_insert_update_ext_l2_1
				, `unee_t_unit_type` = @unee_t_unit_type_update_ext_l2_1
				, `building_system_id` = @building_system_id_update_ext_l2_1
				, `tower` = @tower_update_ext_l2_1
				, `unit_category_id` = @unit_category_id_update_ext_l2_1
				, `designation` = @designation_update_ext_l2_1
				, `count_rooms` = @count_rooms_update_ext_l2_1
				, `unit_id` = @unit_id_update_ext_l2_1
				, `surface` = @surface_update_ext_l2_1
				, `surface_measurment_unit` = @surface_measurment_unit_update_ext_l2_1
				, `description` = @description_update_ext_l2_1
			;

	END IF;

# Housekeeping - we make sure that if a unit is obsolete - all rooms in that unit are obsolete too
# We only do that if the field `is_obsolete` is changed from 0 to 1

	SET @system_id_unit_update_ext_l2_1 = NEW.`system_id_unit` ;

	UPDATE `external_property_level_3_rooms` AS `a`
		INNER JOIN `external_property_level_2_units` AS `b`
			ON (`a`.`system_id_unit` = `b`.`system_id_unit`)
		SET `a`.`is_obsolete` = `b`.`is_obsolete`
		WHERE `a`.`system_id_unit` = @system_id_unit_update_ext_l2_1
		;

END;
$$
DELIMITER ;

# We create a trigger when a record is updated in the `external_property_level_2_units` table
#	- The unit DOES exist in the table `external_property_level_2_units`
#	- This IS a new creation request in Unee-T

	DROP TRIGGER IF EXISTS `ut_update_external_property_level_2_creation_needed`;

DELIMITER $$
CREATE TRIGGER `ut_update_external_property_level_2_creation_needed`
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
#		- ''

	SET @is_creation_needed_in_unee_t_update_ext_l2_2 = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator_update_ext_l2_2 = NEW.`created_by_id` ;
	SET @source_system_updater_update_ext_l2_2 = (IF(NEW.`updated_by_id` IS NULL
			, @source_system_creator_update_ext_l2_2
			, NEW.`updated_by_id`
			)
		);

	SET @creator_mefe_user_id_update_ext_l2_2 = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator_update_ext_l2_2
		)
		;

	SET @upstream_create_method_update_ext_l2_2 = NEW.`creation_method` ;
	SET @upstream_update_method_update_ext_l2_2 = NEW.`update_method` ;

	SET @organization_id_update_ext_l2_2 = @source_system_creator_update_ext_l2_2 ;

	SET @external_id_update_ext_l2_2 = NEW.`external_id` ;
	SET @external_system_id_update_ext_l2_2 = NEW.`external_system_id` ; 
	SET @external_table_update_ext_l2_2 = NEW.`external_table` ;
	SET @tower_update_ext_l2_2 = NEW.`tower` ;

	SET @new_is_creation_needed_in_unee_t_update_ext_l2_2 = NEW.`is_creation_needed_in_unee_t` ;
	SET @old_is_creation_needed_in_unee_t_update_ext_l2_2 = OLD.`is_creation_needed_in_unee_t` ;

	SET @id_in_property_level_2_units_update_ext_l2_2 = (SELECT `system_id_unit`
		FROM `property_level_2_units`
		WHERE `external_system_id` = @external_system_id_update_ext_l2_2
			AND `external_table` = @external_table_update_ext_l2_2
			AND `external_id` = @external_id_update_ext_l2_2
			AND `organization_id` = @organization_id_update_ext_l2_2
		);

	SET @upstream_do_not_insert_update_ext_l2_2 = NEW.`do_not_insert` ;

	# This is an UPDATE - the record SHOULD exist already
	# BUT there are some edge cases when we need to re-create this...
		SET @do_not_insert_update_ext_l2_2 = @upstream_do_not_insert_update_ext_l2_2 ;

	# Get the information about the building for that unit...
	# We need the information from the table `external_property_level_2_units` (and NOT the table `external_external_property_level_1_buildings`)
	
		SET @building_id_1_update_ext_l2_2 = NEW.`building_system_id` ;

		SET @tower_update_ext_l2_2 = NEW.`tower` ;

		SET @building_external_id_update_ext_l2_2 = (SELECT `external_id`
			FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_1_update_ext_l2_2
				);
		SET @building_external_system_id_update_ext_l2_2 = (SELECT `external_system_id`
			FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_1_update_ext_l2_2
			);
		SET @building_external_table_update_ext_l2_2 = (SELECT `external_table`
		   FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_1_update_ext_l2_2
			);
		SET @building_external_tower_update_ext_l2_2 = (SELECT `tower`
			FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_1_update_ext_l2_2
			);

		SET @building_system_id_update_ext_l2_2 = (SELECT `id_building`
			FROM `property_level_1_buildings`
			WHERE `external_id` = @building_external_id_update_ext_l2_2
				AND `external_system_id` = @building_external_system_id_update_ext_l2_2
				AND `external_table` = @building_external_table_update_ext_l2_2
				AND `organization_id` = @organization_id_update_ext_l2_2
				AND `tower` = @building_external_tower_update_ext_l2_2
				);

	IF @is_creation_needed_in_unee_t_update_ext_l2_2 = 1
		AND @new_is_creation_needed_in_unee_t_update_ext_l2_2 != @old_is_creation_needed_in_unee_t_update_ext_l2_2
		AND @do_not_insert_update_ext_l2_2 = 0
		AND @external_id_update_ext_l2_2 IS NOT NULL
		AND @external_system_id_update_ext_l2_2 IS NOT NULL
		AND @external_table_update_ext_l2_2 IS NOT NULL
		AND @tower_update_ext_l2_2 IS NOT NULL
		AND @organization_id_update_ext_l2_2 IS NOT NULL
		AND @building_system_id_update_ext_l2_2 IS NOT NULL
		AND (@upstream_update_method_update_ext_l2_2 = 'imported_from_hmlet_ipi'
			OR @upstream_update_method_update_ext_l2_2 = 'Manage_Units_Add_Page'
			OR @upstream_update_method_update_ext_l2_2 = 'Manage_Units_Edit_Page'
			OR @upstream_update_method_update_ext_l2_2 = 'Manage_Units_Import_Page'
			OR @upstream_update_method_update_ext_l2_2 = 'Export_and_Import_Units_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `external_property_level_2_units` table:

		SET @this_trigger_update_ext_l2_2 = 'ut_update_external_property_level_2_creation_needed';

		SET @syst_created_datetime_update_ext_l2_2 = NOW();
		SET @creation_system_id_update_ext_l2_2 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator_update_ext_l2_2
			)
			;
		SET @created_by_id_update_ext_l2_2 = @creator_mefe_user_id_update_ext_l2_2 ;
		SET @downstream_creation_method_update_ext_l2_2 = @this_trigger_update_ext_l2_2 ;

		SET @syst_updated_datetime_update_ext_l2_2 = NOW();

		SET @update_system_id_update_ext_l2_2 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater_update_ext_l2_2
			)
			;
		SET @updated_by_id_update_ext_l2_2 = @creator_mefe_user_id_update_ext_l2_2 ;
		SET @downstream_update_method_update_ext_l2_2 = @this_trigger_update_ext_l2_2 ;

		SET @organization_id_create_update_ext_l2_2 = @source_system_creator_update_ext_l2_2 ;
		SET @organization_id_update_update_ext_l2_2 = @source_system_updater_update_ext_l2_2 ;

		SET @activated_by_id_update_ext_l2_2 = NEW.`activated_by_id` ;
		SET @is_obsolete_update_ext_l2_2 = NEW.`is_obsolete` ;
		SET @is_creation_needed_in_unee_t_update_ext_l2_2 = NEW.`is_creation_needed_in_unee_t` ;
		SET @unee_t_unit_type_update_ext_l2_2 = NEW.`unee_t_unit_type` ;
			
		SET @unit_category_id_update_ext_l2_2 = NEW.`unit_category_id` ;
		SET @designation_update_ext_l2_2 = NEW.`designation` ;
		SET @count_rooms_update_ext_l2_2 = NEW.`count_rooms` ;
		SET @unit_id_update_ext_l2_2 = NEW.`unit_id` ;
		SET @surface_update_ext_l2_2 = NEW.`surface` ;
		SET @surface_measurment_unit_update_ext_l2_2 = NEW.`surface_measurment_unit` ;
		SET @description_update_ext_l2_2 = NEW.`description` ;

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
 				(@external_id_update_ext_l2_2
				, @external_system_id_update_ext_l2_2
				, @external_table_update_ext_l2_2
				, @syst_created_datetime_update_ext_l2_2
				, @creation_system_id_update_ext_l2_2
				, @created_by_id_update_ext_l2_2
				, @downstream_creation_method_update_ext_l2_2
				, @organization_id_create_update_ext_l2_2
				, @activated_by_id_update_ext_l2_2
				, @is_obsolete_update_ext_l2_2
				, @is_creation_needed_in_unee_t_update_ext_l2_2
				, @do_not_insert_update_ext_l2_2
				, @unee_t_unit_type_update_ext_l2_2
				, @building_system_id_update_ext_l2_2
				, @tower_update_ext_l2_2
				, @unit_category_id_update_ext_l2_2
				, @designation_update_ext_l2_2
				, @count_rooms_update_ext_l2_2
				, @unit_id_update_ext_l2_2
				, @surface_update_ext_l2_2
				, @surface_measurment_unit_update_ext_l2_2
				, @description_update_ext_l2_2
 			)
			ON DUPLICATE KEY UPDATE
 				`syst_updated_datetime` = @syst_updated_datetime_update_ext_l2_2
 				, `update_system_id` = @update_system_id_update_ext_l2_2
 				, `updated_by_id` = @updated_by_id_update_ext_l2_2
				, `update_method` = @downstream_update_method_update_ext_l2_2
				, `organization_id` = @organization_id_update_update_ext_l2_2
				, `activated_by_id` = @activated_by_id_update_ext_l2_2
				, `is_obsolete` = @is_obsolete_update_ext_l2_2
				, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t_update_ext_l2_2
				, `do_not_insert` = @do_not_insert_update_ext_l2_2
				, `unee_t_unit_type` = @unee_t_unit_type_update_ext_l2_2
				, `building_system_id` = @building_system_id_update_ext_l2_2
				, `tower` = @tower_update_ext_l2_2
				, `unit_category_id` = @unit_category_id_update_ext_l2_2
				, `designation` = @designation_update_ext_l2_2
				, `count_rooms` = @count_rooms_update_ext_l2_2
				, `unit_id` = @unit_id_update_ext_l2_2
				, `surface` = @surface_update_ext_l2_2
				, `surface_measurment_unit` = @surface_measurment_unit_update_ext_l2_2
				, `description` = @description_update_ext_l2_2
			;

	END IF;

# Housekeeping - we make sure that if a unit is obsolete - all rooms in that unit are obsolete too
# We only do that if the field `is_obsolete` is changed from 0 to 1

	SET @system_id_unit_update_ext_l2_2 = NEW.`system_id_unit` ;

	UPDATE `external_property_level_3_rooms` AS `a`
		INNER JOIN `external_property_level_2_units` AS `b`
			ON (`a`.`system_id_unit` = `b`.`system_id_unit`)
		SET `a`.`is_obsolete` = `b`.`is_obsolete`
		WHERE `a`.`system_id_unit` = @system_id_unit_update_ext_l2_2
		;

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
	SET @is_creation_needed_in_unee_t_insert_l2_1 = NEW.`is_creation_needed_in_unee_t` ;

	SET @external_property_id_insert_l2_1 = NEW.`external_id` ;
	SET @external_system_insert_l2_1 = NEW.`external_system_id` ;
	SET @table_in_external_system_insert_l2_1 = NEW.`external_table` ;
	SET @organization_id_insert_l2_1 = NEW.`organization_id`;

	SET @id_in_ut_map_external_source_units_insert_l2_1 = (SELECT `id_map`
		FROM `ut_map_external_source_units`
		WHERE `external_system` = @external_system_insert_l2_1
			AND `table_in_external_system` = @table_in_external_system_insert_l2_1
			AND `external_property_id` = @external_property_id_insert_l2_1
			AND `organization_id` = @organization_id_insert_l2_1
		);

	SET @do_not_insert_insert_l2_1 = (IF (@id_in_ut_map_external_source_units_insert_l2_1 IS NULL
			, 0
			, NEW.`do_not_insert`
			)
		
		);

	SET @upstream_create_method_insert_l2_1 = NEW.`creation_method` ;
	SET @upstream_update_method_insert_l2_1 = NEW.`update_method` ;

	IF @is_creation_needed_in_unee_t_insert_l2_1 = 1
		AND @do_not_insert_insert_l2_1 = 0
		AND (@upstream_create_method_insert_l2_1 = 'ut_insert_external_property_level_2'
			OR @upstream_update_method_insert_l2_1 = 'ut_insert_external_property_level_2'
			OR @upstream_create_method_insert_l2_1 = 'ut_update_external_property_level_2'
			OR @upstream_update_method_insert_l2_1 = 'ut_update_external_property_level_2'
			OR @upstream_create_method_insert_l2_1 = 'ut_update_external_property_level_2_creation_needed'
			OR @upstream_update_method_insert_l2_1 = 'ut_update_external_property_level_2_creation_needed'
			)

	THEN 

		# We capture the values we need for the insert/udpate:

			SET @this_trigger_insert_l2_1 = 'ut_update_map_external_source_unit_add_unit' ;

			SET @syst_created_datetime_insert_l2_1 = NOW();
			SET @creation_system_id_insert_l2_1 = NEW.`creation_system_id`;
			SET @created_by_id_insert_l2_1 = NEW.`created_by_id`;
			SET @creation_method_insert_l2_1 = @this_trigger ;

			SET @syst_updated_datetime_insert_l2_1 = NOW();
			SET @update_system_id_insert_l2_1 = NEW.`creation_system_id`;
			SET @updated_by_id_insert_l2_1 = NEW.`created_by_id`;
			SET @update_method_insert_l2_1 = @this_trigger_insert_l2_1 ;
			
			SET @is_obsolete_insert_l2_1 = NEW.`is_obsolete`;
			SET @is_update_needed_insert_l2_1 = NULL;
			
			SET @uneet_name_insert_l2_1 = NEW.`designation`;

			SET @unee_t_unit_type_insert_l2_1 = (IFNULL(NEW.`unee_t_unit_type`
					, 'Unknown'
					)
				)
				;
			
			SET @new_record_id_insert_l2_1 = NEW.`system_id_unit`;
			SET @external_property_type_id_insert_l2_1 = 2;	

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
					(@syst_created_datetime_insert_l2_1
					, @creation_system_id_insert_l2_1
					, @created_by_id_insert_l2_1
					, @this_trigger_insert_l2_1
					, @organization_id_insert_l2_1
					, @is_obsolete_insert_l2_1
					, @is_update_needed_insert_l2_1
					, @uneet_name_insert_l2_1
					, @unee_t_unit_type_insert_l2_1
					, @new_record_id_insert_l2_1
					, @external_property_type_id_insert_l2_1
					, @external_property_id_insert_l2_1
					, @external_system_insert_l2_1
					, @table_in_external_system_insert_l2_1
					)
				ON DUPLICATE KEY UPDATE 
					`syst_updated_datetime` = @syst_updated_datetime_insert_l2_1
					, `update_system_id` = @update_system_id_insert_l2_1
					, `updated_by_id` = @updated_by_id_insert_l2_1
					, `update_method` = @this_trigger_insert_l2_1
					, `organization_id` = @organization_id_insert_l2_1
					, `uneet_name` = @uneet_name_insert_l2_1
					, `unee_t_unit_type` = @unee_t_unit_type_insert_l2_1
					, `is_update_needed` = 1
				;

	END IF;
END;
$$
DELIMITER ;

# Create a trigger to update the table that will fire the lambda each time a new unit/flat is marked as `is_creation_needed_in_unee_t` = 1

	DROP TRIGGER IF EXISTS `ut_update_map_external_source_unit_add_unit_creation_needed`;

DELIMITER $$
CREATE TRIGGER `ut_update_map_external_source_unit_add_unit_creation_needed`
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
#		- ''

	SET @is_creation_needed_in_unee_t_update_l2_1 = NEW.`is_creation_needed_in_unee_t`;

	SET @new_is_creation_needed_in_unee_t_update_l2_1 = NEW.`is_creation_needed_in_unee_t`;
	SET @old_is_creation_needed_in_unee_t_update_l2_1 = OLD.`is_creation_needed_in_unee_t`;

	SET @do_not_insert_update_l2_1 = NEW.`do_not_insert` ;

	SET @system_id_unit_update_l2_1 = NEW.`system_id_unit` ;

	SET @mefe_unit_id_update_l2_1 = (SELECT `unee_t_mefe_unit_id`
		FROM `ut_map_external_source_units`
		WHERE `new_record_id` = @system_id_unit_update_l2_1
			AND `external_property_type_id` = 2
		);

	SET @upstream_create_method_update_l2_1 = NEW.`creation_method` ;
	SET @upstream_update_method_update_l2_1 = NEW.`update_method` ;

	IF @is_creation_needed_in_unee_t_update_l2_1 = 1
		AND @do_not_insert_update_l2_1 = 0 
		AND @mefe_unit_id_update_l2_1 IS NULL
		AND (@upstream_create_method_update_l2_1 = 'ut_insert_external_property_level_2'
			OR @upstream_update_method_update_l2_1 = 'ut_insert_external_property_level_2'
			OR @upstream_create_method_update_l2_1 = 'ut_update_external_property_level_2_creation_needed'
			OR @upstream_update_method_update_l2_1 = 'ut_update_external_property_level_2_creation_needed'
			)
	THEN 

	# We capture the values we need for the insert/udpate:

		SET @this_trigger_update_l2_1 = 'ut_update_map_external_source_unit_add_unit_creation_needed';

		SET @syst_created_datetime_update_l2_1 = NOW();
		SET @creation_system_id_update_l2_1 = NEW.`update_system_id`;
		SET @created_by_id_update_l2_1 = NEW.`updated_by_id`;
		SET @creation_method_update_l2_1 = @this_trigger_update_l2_1 ;

		SET @syst_updated_datetime_update_l2_1 = NOW();
		SET @update_system_id_update_l2_1 = NEW.`update_system_id`;
		SET @updated_by_id_update_l2_1 = NEW.`updated_by_id`;
		SET @update_method_update_l2_1 = @this_trigger_update_l2_1 ;

		SET @organization_id_update_l2_1 = NEW.`organization_id`;
			
		SET @is_obsolete_update_l2_1 = NEW.`is_obsolete`;
		SET @is_update_needed_update_l2_1 = NULL;
		
		SET @uneet_name_update_l2_1 = NEW.`designation`;

		SET @unee_t_unit_type_update_l2_1 = (IFNULL(NEW.`unee_t_unit_type`
				, 'Unknown'
				)
			)
			;
			
		SET @new_record_id_update_l2_1 = NEW.`system_id_unit`;
		SET @external_property_type_id_update_l2_1 = 2;

		SET @external_property_id_update_l2_1 = NEW.`external_id`;
		SET @external_system_update_l2_1 = NEW.`external_system_id`;
		SET @table_in_external_system_update_l2_1 = NEW.`external_table`;			

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
					(@syst_created_datetime_update_l2_1
					, @creation_system_id_update_l2_1
					, @created_by_id_update_l2_1
					, @this_trigger_update_l2_1
					, @organization_id_update_l2_1
					, @is_obsolete_update_l2_1
					, @is_update_needed_update_l2_1
					, @uneet_name_update_l2_1
					, @unee_t_unit_type_update_l2_1
					, @new_record_id_update_l2_1
					, @external_property_type_id_update_l2_1
					, @external_property_id_update_l2_1
					, @external_system_update_l2_1
					, @table_in_external_system_update_l2_1
					)
				ON DUPLICATE KEY UPDATE
					`syst_updated_datetime` = @syst_updated_datetime_update_l2_1
					, `update_system_id` = @update_system_id_update_l2_1
					, `updated_by_id` = @updated_by_id_update_l2_1
					, `update_method` = @this_trigger_update_l2_1
					, `organization_id` = @organization_id_update_l2_1
					, `uneet_name` = @uneet_name_update_l2_1
					, `unee_t_unit_type` = @unee_t_unit_type_update_l2_1
					, `is_update_needed` = 1
				;

	END IF;
END;
$$
DELIMITER ;

# Create a trigger to update the table that will fire the lambda each time 
# a new Property Level 2 needs to be updated

	DROP TRIGGER IF EXISTS `ut_update_map_external_source_unit_edit_level_2`;

DELIMITER $$
CREATE TRIGGER `ut_update_map_external_source_unit_edit_level_2`
AFTER UPDATE ON `property_level_2_units`
FOR EACH ROW
BEGIN

# We only do this IF:
# 	- We need to create the unit in Unee-T
#	- The unit is NOT marked as `do_not_insert`
#	- We DO have a MEFE unit ID for that unit
#	- This is done via an authorized update method:
#		- 'ut_update_external_property_level_2'
#		- ''

	SET @is_creation_needed_in_unee_t_update_l2_2 = NEW.`is_creation_needed_in_unee_t`;

	SET @new_is_creation_needed_in_unee_t_update_l2_2 = NEW.`is_creation_needed_in_unee_t`;
	SET @old_is_creation_needed_in_unee_t_update_l2_2 = OLD.`is_creation_needed_in_unee_t`;

	SET @do_not_insert_update_l2_2 = NEW.`do_not_insert` ;

	SET @system_id_unit_update_l2_2 = NEW.`system_id_unit` ;

	SET @mefe_unit_id_update_l2_2 = (SELECT `unee_t_mefe_unit_id`
		FROM `ut_map_external_source_units`
		WHERE `new_record_id` = @system_id_unit_update_l2_2
			AND `external_property_type_id` = 2
		);

	SET @upstream_create_method_update_l2_2 = NEW.`creation_method` ;
	SET @upstream_update_method_update_l2_2 = NEW.`update_method` ;

	IF @is_creation_needed_in_unee_t_update_l2_2 = 1
		AND @do_not_insert_update_l2_2 = 0 
		AND @mefe_unit_id_update_l2_2 IS NOT NULL
		AND (@upstream_create_method_update_l2_2 = 'ut_update_external_property_level_2'
			OR @upstream_update_method_update_l2_2 = 'ut_update_external_property_level_2'
			)
	THEN 

	# We capture the values we need for the insert/udpate:

		SET @this_trigger_update_l2_2 = 'ut_update_map_external_source_unit_edit_level_2';

		SET @syst_created_datetime_update_l2_2 = NOW();
		SET @creation_system_id_update_l2_2 = NEW.`update_system_id`;
		SET @created_by_id_update_l2_2 = NEW.`updated_by_id`;
		SET @creation_method_update_l2_2 = @this_trigger_update_l2_2 ;

		SET @syst_updated_datetime_update_l2_2 = NOW();
		SET @update_system_id_update_l2_2 = NEW.`update_system_id`;
		SET @updated_by_id_update_l2_2 = NEW.`updated_by_id`;
		SET @update_method_update_l2_2 = @this_trigger_update_l2_2 ;

		SET @organization_id_update_l2_2 = NEW.`organization_id`;
			
		SET @is_obsolete_update_l2_2 = NEW.`is_obsolete`;
		SET @is_update_needed_update_l2_2 = NULL;
		
		SET @uneet_name_update_l2_2 = NEW.`designation`;

		SET @unee_t_unit_type_update_l2_2 = (IFNULL(NEW.`unee_t_unit_type`
				, 'Unknown'
				)
			)
			;
			
		SET @new_record_id_update_l2_2 = NEW.`system_id_unit`;
		SET @external_property_type_id_update_l2_2 = 2;

		SET @external_property_id_update_l2_2 = NEW.`external_id`;
		SET @external_system_update_l2_2 = NEW.`external_system_id`;
		SET @table_in_external_system_update_l2_2 = NEW.`external_table`;

		SET @is_mefe_api_success_update_l2_2 := 0 ;
		SET @mefe_api_error_message_update_l2_2 := (CONCAT('N/A - written by '
				, '`'
				, @this_trigger_update_l2_2
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
				)
				VALUES
					(@syst_created_datetime_update_l2_2
					, @creation_system_id_update_l2_2
					, @created_by_id_update_l2_2
					, @creation_method_update_l2_2
					, @organization_id_update_l2_2
					, @is_obsolete_update_l2_2
					, @is_update_needed_update_l2_2
					, @is_mefe_api_success_update_l2_2
					, @mefe_api_error_message_update_l2_2
					, @uneet_name_update_l2_2
					, @unee_t_unit_type_update_l2_2
					, @new_record_id_update_l2_2
					, @external_property_type_id_update_l2_2
					, @external_property_id_update_l2_2
					, @external_system_update_l2_2
					, @table_in_external_system_update_l2_2
					)
				ON DUPLICATE KEY UPDATE
					`syst_updated_datetime` = @syst_updated_datetime_update_l2_2
					, `update_system_id` = @update_system_id_update_l2_2
					, `updated_by_id` = @updated_by_id_update_l2_2
					, `update_method` = @update_method_update_l2_2
					, `organization_id` = @organization_id_update_l2_2
					, `is_mefe_api_success` = @is_mefe_api_success_update_l2_2
					, `mefe_api_error_message` = @mefe_api_error_message_update_l2_2
					, `uneet_name` = @uneet_name_update_l2_2
					, `unee_t_unit_type` = @unee_t_unit_type_update_l2_2
					, `is_update_needed` = 1
				;

	END IF;
END;
$$
DELIMITER ;