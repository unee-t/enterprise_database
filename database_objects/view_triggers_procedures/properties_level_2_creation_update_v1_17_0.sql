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

	SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator = NEW.`created_by_id` ;
	SET @source_system_updater = (IF(NEW.`updated_by_id` IS NULL
			, @source_system_creator
			, NEW.`updated_by_id`
			)
		);

	SET @creator_mefe_user_id = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator
		)
		;

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;

	SET @external_system_id = NEW.`external_system_id` ;
	SET @external_table = NEW.`external_table` ;
	SET @external_id = NEW.`external_id` ;

	SET @organization_id = @source_system_creator ;

	SET @id_in_property_level_2_units = (SELECT `system_id_unit`
		FROM `property_level_2_units`
		WHERE `external_system_id` = @external_system_id
			AND `external_table` = @external_table
			AND `external_id` = @external_id
			AND `organization_id` = @organization_id
		);
		
	SET @upstream_do_not_insert = NEW.`do_not_insert` ;

	# This is an INSERT - the record should NOT exist already

		SET @do_not_insert = (IF (@id_in_property_level_2_units IS NULL
				, 0
				, @upstream_do_not_insert
				)
			
			);

	# Get the information about the building for that unit...
	# We need the information from the table `external_property_level_2_units` (and NOT the table `external_external_property_level_1_buildings`)
	
		SET @building_id_in_table_external_property_level_2_units = NEW.`building_system_id` ;

		SET @tower = NEW.`tower` ;

		SET @building_external_id = (SELECT `external_id`
			FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_in_table_external_property_level_2_units
				);
		SET @building_external_system_id = (SELECT `external_system_id`
			FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_in_table_external_property_level_2_units
			);
		SET @building_external_table = (SELECT `external_table`
		   FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_in_table_external_property_level_2_units
			);
		SET @building_external_tower = (SELECT `tower`
			FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_in_table_external_property_level_2_units
			);

		SET @building_system_id = (SELECT `id_building`
			FROM `property_level_1_buildings`
			WHERE `external_id` = @building_external_id
				AND `external_system_id` = @building_external_system_id
				AND `external_table` = @building_external_table
				AND `organization_id` = @organization_id
				AND `tower` = @building_external_tower
				);

	IF @is_creation_needed_in_unee_t = 1
		AND @do_not_insert = 0
		AND @external_id IS NOT NULL
		AND @external_system_id IS NOT NULL
		AND @external_table IS NOT NULL
		AND @organization_id IS NOT NULL
		AND @building_system_id IS NOT NULL
		AND (@upstream_create_method = 'imported_from_hmlet_ipi'
			OR @upstream_create_method = 'Manage_Units_Add_Page'
			OR @upstream_create_method = 'Manage_Units_Edit_Page'
			OR @upstream_create_method = 'Manage_Units_Import_Page'
			OR @upstream_update_method = 'imported_from_hmlet_ipi'
			OR @upstream_update_method = 'Manage_Units_Add_Page'
			OR @upstream_update_method = 'Manage_Units_Edit_Page'
			OR @upstream_create_method = 'Manage_Units_Import_Page'
			OR @upstream_update_method = 'Export_and_Import_Units_Import_Page'
			OR @upstream_create_method = 'Export_and_Import_Units_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `external_property_level_2_units` table:

		SET @this_trigger = 'ut_insert_external_property_level_2' ;

		SET @syst_created_datetime = NOW();
		SET @creation_system_id = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator
			)
			;
		SET @created_by_id = @creator_mefe_user_id ;
		SET @downstream_creation_method = @this_trigger ;

		SET @syst_updated_datetime = NOW();

		SET @update_system_id = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater
			)
			;
		SET @updated_by_id = @creator_mefe_user_id ;
		SET @downstream_update_method = @this_trigger ;

		SET @organization_id_create = @source_system_creator ;
		SET @organization_id_update = @source_system_updater;

		SET @activated_by_id = NEW.`activated_by_id` ;
		SET @is_obsolete = NEW.`is_obsolete` ;
		SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;
		SET @unee_t_unit_type = NEW.`unee_t_unit_type` ;
			
		SET @unit_category_id = NEW.`unit_category_id` ;
		SET @designation = NEW.`designation` ;
		SET @count_rooms = NEW.`count_rooms` ;
		SET @unit_id = NEW.`unit_id` ;
		SET @surface = NEW.`surface` ;
		SET @surface_measurment_unit = NEW.`surface_measurment_unit` ;
		SET @description = NEW.`description` ;

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
 				(@external_id
				, @external_system_id 
				, @external_table
				, @syst_created_datetime
				, @creation_system_id
				, @created_by_id
				, @downstream_creation_method
				, @organization_id_create
				, @activated_by_id
				, @is_obsolete
				, @is_creation_needed_in_unee_t
				, @do_not_insert
				, @unee_t_unit_type
				, @building_system_id
				, @tower
				, @unit_category_id
				, @designation
				, @count_rooms
				, @unit_id
				, @surface
				, @surface_measurment_unit
				, @description
 			)
			ON DUPLICATE KEY UPDATE
 				`syst_updated_datetime` = @syst_updated_datetime
 				, `update_system_id` = @update_system_id
 				, `updated_by_id` = @updated_by_id
				, `update_method` = @downstream_update_method
				, `activated_by_id` = @activated_by_id
				, `organization_id` = @organization_id_update
				, `is_obsolete` = @is_obsolete
				, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t
				, `do_not_insert` = @do_not_insert
				, `unee_t_unit_type` = @unee_t_unit_type
				, `building_system_id` = @building_system_id
				, `tower` = @tower
				, `unit_category_id` = @unit_category_id
				, `designation` = @designation
				, `count_rooms` = @count_rooms
				, `unit_id` = @unit_id
				, `surface` = @surface
				, `surface_measurment_unit` = @surface_measurment_unit
				, `description` = @description
			;

	END IF;

# Housekeeping - we make sure that if a unit is obsolete - all rooms in that unit are obsolete too

	SET @system_id_unit = NEW.`system_id_unit` ;

	UPDATE `external_property_level_3_rooms` AS `a`
		INNER JOIN `external_property_level_2_units` AS `b`
			ON (`a`.`system_id_unit` = `b`.`system_id_unit`)
		SET `a`.`is_obsolete` = `b`.`is_obsolete`
		WHERE `a`.`system_id_unit` = @system_id_unit
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

	SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator = NEW.`created_by_id` ;
	SET @source_system_updater = (IF(NEW.`updated_by_id` IS NULL
			, @source_system_creator
			, NEW.`updated_by_id`
			)
		);

	SET @creator_mefe_user_id = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator
		)
		;

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;

	SET @organization_id = @source_system_creator ;

	SET @external_id = NEW.`external_id` ;
	SET @external_system_id = NEW.`external_system_id` ; 
	SET @external_table = NEW.`external_table` ;
	SET @tower = NEW.`tower` ;

	SET @new_is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;
	SET @old_is_creation_needed_in_unee_t = OLD.`is_creation_needed_in_unee_t` ;

	SET @id_in_property_level_2_units = (SELECT `system_id_unit`
		FROM `property_level_2_units`
		WHERE `external_system_id` = @external_system_id
			AND `external_table` = @external_table
			AND `external_id` = @external_id
			AND `organization_id` = @organization_id
		);

	SET @upstream_do_not_insert = NEW.`do_not_insert` ;

	# This is an UPDATE - the record SHOULD exist already

		SET @do_not_insert = (IF (@id_in_property_level_2_units IS NULL
				, 1
				, @upstream_do_not_insert
				)
			);

	# Get the information about the building for that unit...
	# We need the information from the table `external_property_level_2_units` (and NOT the table `external_external_property_level_1_buildings`)
	
		SET @building_id_in_table_external_property_level_2_units = NEW.`building_system_id` ;

		SET @tower = NEW.`tower` ;

		SET @building_external_id = (SELECT `external_id`
			FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_in_table_external_property_level_2_units
				);
		SET @building_external_system_id = (SELECT `external_system_id`
			FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_in_table_external_property_level_2_units
			);
		SET @building_external_table = (SELECT `external_table`
		   FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_in_table_external_property_level_2_units
			);
		SET @building_external_tower = (SELECT `tower`
			FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_in_table_external_property_level_2_units
			);

		SET @building_system_id = (SELECT `id_building`
			FROM `property_level_1_buildings`
			WHERE `external_id` = @building_external_id
				AND `external_system_id` = @building_external_system_id
				AND `external_table` = @building_external_table
				AND `organization_id` = @organization_id
				AND `tower` = @building_external_tower
				);

	IF @is_creation_needed_in_unee_t = 1
		AND @new_is_creation_needed_in_unee_t = @old_is_creation_needed_in_unee_t
		AND @do_not_insert = 0
		AND @external_id IS NOT NULL
		AND @external_system_id IS NOT NULL
		AND @external_table IS NOT NULL
		AND @tower IS NOT NULL
		AND @organization_id IS NOT NULL
		AND @building_system_id IS NOT NULL
		AND (@upstream_update_method = 'imported_from_hmlet_ipi'
			OR @upstream_update_method = 'Manage_Units_Add_Page'
			OR @upstream_update_method = 'Manage_Units_Edit_Page'
			OR @upstream_update_method = 'Manage_Units_Import_Page'
			OR @upstream_update_method = 'Export_and_Import_Units_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `external_property_level_2_units` table:

		SET @this_trigger = 'ut_update_external_property_level_2';

		SET @syst_created_datetime = NOW();
		SET @creation_system_id = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator
			)
			;
		SET @created_by_id = @creator_mefe_user_id ;
		SET @downstream_creation_method = @this_trigger ;

		SET @syst_updated_datetime = NOW();

		SET @update_system_id = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater
			)
			;
		SET @updated_by_id = @creator_mefe_user_id ;
		SET @downstream_update_method = @this_trigger ;

		SET @organization_id_create = @source_system_creator;
		SET @organization_id_update = @source_system_updater;

		SET @activated_by_id = NEW.`activated_by_id` ;
		SET @is_obsolete = NEW.`is_obsolete` ;
		SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;
		SET @unee_t_unit_type = NEW.`unee_t_unit_type` ;
			
		SET @unit_category_id = NEW.`unit_category_id` ;
		SET @designation = NEW.`designation` ;
		SET @count_rooms = NEW.`count_rooms` ;
		SET @unit_id = NEW.`unit_id` ;
		SET @surface = NEW.`surface` ;
		SET @surface_measurment_unit = NEW.`surface_measurment_unit` ;
		SET @description = NEW.`description` ;

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
 				(@external_id
				, @external_system_id 
				, @external_table
				, @syst_created_datetime
				, @creation_system_id
				, @created_by_id
				, @downstream_creation_method
				, @organization_id_create
				, @activated_by_id
				, @is_obsolete
				, @is_creation_needed_in_unee_t
				, @do_not_insert
				, @unee_t_unit_type
				, @building_system_id
				, @tower
				, @unit_category_id
				, @designation
				, @count_rooms
				, @unit_id
				, @surface
				, @surface_measurment_unit
				, @description
 			)
			ON DUPLICATE KEY UPDATE
 				`syst_updated_datetime` = @syst_updated_datetime
 				, `update_system_id` = @update_system_id
 				, `updated_by_id` = @updated_by_id
				, `update_method` = @downstream_update_method
				, `organization_id` = @organization_id_update
				, `activated_by_id` = @activated_by_id
				, `is_obsolete` = @is_obsolete
				, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t
				, `do_not_insert` = @do_not_insert
				, `unee_t_unit_type` = @unee_t_unit_type
				, `building_system_id` = @building_system_id
				, `tower` = @tower
				, `unit_category_id` = @unit_category_id
				, `designation` = @designation
				, `count_rooms` = @count_rooms
				, `unit_id` = @unit_id
				, `surface` = @surface
				, `surface_measurment_unit` = @surface_measurment_unit
				, `description` = @description
			;

	END IF;

# Housekeeping - we make sure that if a unit is obsolete - all rooms in that unit are obsolete too
# We only do that if the field `is_obsolete` is changed from 0 to 1

	SET @system_id_unit = NEW.`system_id_unit` ;

	UPDATE `external_property_level_3_rooms` AS `a`
		INNER JOIN `external_property_level_2_units` AS `b`
			ON (`a`.`system_id_unit` = `b`.`system_id_unit`)
		SET `a`.`is_obsolete` = `b`.`is_obsolete`
		WHERE `a`.`system_id_unit` = @system_id_unit
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

	SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator = NEW.`created_by_id` ;
	SET @source_system_updater = (IF(NEW.`updated_by_id` IS NULL
			, @source_system_creator
			, NEW.`updated_by_id`
			)
		);

	SET @creator_mefe_user_id = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator
		)
		;

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;

	SET @organization_id = @source_system_creator ;

	SET @external_id = NEW.`external_id` ;
	SET @external_system_id = NEW.`external_system_id` ; 
	SET @external_table = NEW.`external_table` ;
	SET @tower = NEW.`tower` ;

	SET @new_is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;
	SET @old_is_creation_needed_in_unee_t = OLD.`is_creation_needed_in_unee_t` ;

	SET @id_in_property_level_2_units = (SELECT `system_id_unit`
		FROM `property_level_2_units`
		WHERE `external_system_id` = @external_system_id
			AND `external_table` = @external_table
			AND `external_id` = @external_id
			AND `organization_id` = @organization_id
		);

	SET @upstream_do_not_insert = NEW.`do_not_insert` ;

	# This is an UPDATE - the record SHOULD exist already
	# BUT there are some edge cases when we need to re-create this...
		SET @do_not_insert = @upstream_do_not_insert ;

	# Get the information about the building for that unit...
	# We need the information from the table `external_property_level_2_units` (and NOT the table `external_external_property_level_1_buildings`)
	
		SET @building_id_in_table_external_property_level_2_units = NEW.`building_system_id` ;

		SET @tower = NEW.`tower` ;

		SET @building_external_id = (SELECT `external_id`
			FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_in_table_external_property_level_2_units
				);
		SET @building_external_system_id = (SELECT `external_system_id`
			FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_in_table_external_property_level_2_units
			);
		SET @building_external_table = (SELECT `external_table`
		   FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_in_table_external_property_level_2_units
			);
		SET @building_external_tower = (SELECT `tower`
			FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_in_table_external_property_level_2_units
			);

		SET @building_system_id = (SELECT `id_building`
			FROM `property_level_1_buildings`
			WHERE `external_id` = @building_external_id
				AND `external_system_id` = @building_external_system_id
				AND `external_table` = @building_external_table
				AND `organization_id` = @organization_id
				AND `tower` = @building_external_tower
				);

	IF @is_creation_needed_in_unee_t = 1
		AND @new_is_creation_needed_in_unee_t != @old_is_creation_needed_in_unee_t
		AND @do_not_insert = 0
		AND @external_id IS NOT NULL
		AND @external_system_id IS NOT NULL
		AND @external_table IS NOT NULL
		AND @tower IS NOT NULL
		AND @organization_id IS NOT NULL
		AND @building_system_id IS NOT NULL
		AND (@upstream_update_method = 'imported_from_hmlet_ipi'
			OR @upstream_update_method = 'Manage_Units_Add_Page'
			OR @upstream_update_method = 'Manage_Units_Edit_Page'
			OR @upstream_update_method = 'Manage_Units_Import_Page'
			OR @upstream_update_method = 'Export_and_Import_Units_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `external_property_level_2_units` table:

		SET @this_trigger = 'ut_update_external_property_level_2_creation_needed';

		SET @syst_created_datetime = NOW();
		SET @creation_system_id = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator
			)
			;
		SET @created_by_id = @creator_mefe_user_id ;
		SET @downstream_creation_method = @this_trigger ;

		SET @syst_updated_datetime = NOW();

		SET @update_system_id = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater
			)
			;
		SET @updated_by_id = @creator_mefe_user_id ;
		SET @downstream_update_method = @this_trigger ;

		SET @organization_id_create = @source_system_creator;
		SET @organization_id_update = @source_system_updater;

		SET @activated_by_id = NEW.`activated_by_id` ;
		SET @is_obsolete = NEW.`is_obsolete` ;
		SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;
		SET @unee_t_unit_type = NEW.`unee_t_unit_type` ;
			
		SET @unit_category_id = NEW.`unit_category_id` ;
		SET @designation = NEW.`designation` ;
		SET @count_rooms = NEW.`count_rooms` ;
		SET @unit_id = NEW.`unit_id` ;
		SET @surface = NEW.`surface` ;
		SET @surface_measurment_unit = NEW.`surface_measurment_unit` ;
		SET @description = NEW.`description` ;

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
 				(@external_id
				, @external_system_id 
				, @external_table
				, @syst_created_datetime
				, @creation_system_id
				, @created_by_id
				, @downstream_creation_method
				, @organization_id_create
				, @activated_by_id
				, @is_obsolete
				, @is_creation_needed_in_unee_t
				, @do_not_insert
				, @unee_t_unit_type
				, @building_system_id
				, @tower
				, @unit_category_id
				, @designation
				, @count_rooms
				, @unit_id
				, @surface
				, @surface_measurment_unit
				, @description
 			)
			ON DUPLICATE KEY UPDATE
 				`syst_updated_datetime` = @syst_updated_datetime
 				, `update_system_id` = @update_system_id
 				, `updated_by_id` = @updated_by_id
				, `update_method` = @downstream_update_method
				, `organization_id` = @organization_id_update
				, `activated_by_id` = @activated_by_id
				, `is_obsolete` = @is_obsolete
				, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t
				, `do_not_insert` = @do_not_insert
				, `unee_t_unit_type` = @unee_t_unit_type
				, `building_system_id` = @building_system_id
				, `tower` = @tower
				, `unit_category_id` = @unit_category_id
				, `designation` = @designation
				, `count_rooms` = @count_rooms
				, `unit_id` = @unit_id
				, `surface` = @surface
				, `surface_measurment_unit` = @surface_measurment_unit
				, `description` = @description
			;

	END IF;

# Housekeeping - we make sure that if a unit is obsolete - all rooms in that unit are obsolete too
# We only do that if the field `is_obsolete` is changed from 0 to 1

	SET @system_id_unit = NEW.`system_id_unit` ;

	UPDATE `external_property_level_3_rooms` AS `a`
		INNER JOIN `external_property_level_2_units` AS `b`
			ON (`a`.`system_id_unit` = `b`.`system_id_unit`)
		SET `a`.`is_obsolete` = `b`.`is_obsolete`
		WHERE `a`.`system_id_unit` = @system_id_unit
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
	SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;

	SET @external_property_id = NEW.`external_id` ;
	SET @external_system = NEW.`external_system_id` ;
	SET @table_in_external_system = NEW.`external_table` ;
	SET @organization_id = NEW.`organization_id`;

	SET @id_in_ut_map_external_source_units = (SELECT `id_map`
		FROM `ut_map_external_source_units`
		WHERE `external_system` = @external_system
			AND `table_in_external_system` = @table_in_external_system
			AND `external_property_id` = @external_property_id
			AND `organization_id` = @organization_id
		);

	SET @do_not_insert = (IF (@id_in_ut_map_external_source_units IS NULL
			, 0
			, NEW.`do_not_insert`
			)
		
		);

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;

	IF @is_creation_needed_in_unee_t = 1
		AND @do_not_insert = 0
		AND (@upstream_create_method = 'ut_insert_external_property_level_2'
			OR @upstream_update_method = 'ut_insert_external_property_level_2'
			OR @upstream_create_method = 'ut_update_external_property_level_2'
			OR @upstream_update_method = 'ut_update_external_property_level_2'
			OR @upstream_create_method = 'ut_update_external_property_level_2_creation_needed'
			OR @upstream_update_method = 'ut_update_external_property_level_2_creation_needed'
			)

	THEN 

		# We capture the values we need for the insert/udpate:

			SET @this_trigger = 'ut_update_map_external_source_unit_add_unit' ;

			SET @syst_created_datetime = NOW();
			SET @creation_system_id = NEW.`creation_system_id`;
			SET @created_by_id = NEW.`created_by_id`;
			SET @creation_method = @this_trigger ;

			SET @syst_updated_datetime = NOW();
			SET @update_system_id = NEW.`creation_system_id`;
			SET @updated_by_id = NEW.`created_by_id`;
			SET @update_method = @this_trigger ;
			
			SET @is_obsolete = NEW.`is_obsolete`;
			SET @is_update_needed = NULL;
			
			SET @uneet_name = NEW.`designation`;

			SET @unee_t_unit_type = (IFNULL(NEW.`unee_t_unit_type`
					, 'Unknown'
					)
				)
				;
			
			SET @new_record_id = NEW.`system_id_unit`;
			SET @external_property_type_id = 2;	

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
					(@syst_created_datetime
					, @creation_system_id
					, @created_by_id
					, @creation_method
					, @organization_id
					, @is_obsolete
					, @is_update_needed
					, @uneet_name
					, @unee_t_unit_type
					, @new_record_id
					, @external_property_type_id
					, @external_property_id
					, @external_system
					, @table_in_external_system
					)
				ON DUPLICATE KEY UPDATE 
					`syst_updated_datetime` = @syst_updated_datetime
					, `update_system_id` = @update_system_id
					, `updated_by_id` = @updated_by_id
					, `update_method` = @update_method
					, `organization_id` = @organization_id
					, `uneet_name` = @uneet_name
					, `unee_t_unit_type` = @unee_t_unit_type
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

	SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t`;

	SET @new_is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t`;
	SET @old_is_creation_needed_in_unee_t = OLD.`is_creation_needed_in_unee_t`;

	SET @do_not_insert = NEW.`do_not_insert` ;

	SET @system_id_unit = NEW.`system_id_unit` ;

	SET @mefe_unit_id = (SELECT `unee_t_mefe_unit_id`
		FROM `ut_map_external_source_units`
		WHERE `new_record_id` = @system_id_unit
			AND `external_property_type_id` = 2
		);

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;

	IF @is_creation_needed_in_unee_t = 1
		AND @do_not_insert = 0 
		AND @mefe_unit_id IS NULL
		AND (@upstream_create_method = 'ut_insert_external_property_level_2'
			OR @upstream_update_method = 'ut_insert_external_property_level_2'
			OR @upstream_create_method = 'ut_update_external_property_level_2_creation_needed'
			OR @upstream_update_method = 'ut_update_external_property_level_2_creation_needed'
			)
	THEN 

	# We capture the values we need for the insert/udpate:

		SET @this_trigger = 'ut_update_map_external_source_unit_add_unit_creation_needed';

		SET @syst_created_datetime = NOW();
		SET @creation_system_id = NEW.`update_system_id`;
		SET @created_by_id = NEW.`updated_by_id`;
		SET @creation_method = @this_trigger ;

		SET @syst_updated_datetime = NOW();
		SET @update_system_id = NEW.`update_system_id`;
		SET @updated_by_id = NEW.`updated_by_id`;
		SET @update_method = @this_trigger ;

		SET @organization_id = NEW.`organization_id`;
			
		SET @is_obsolete = NEW.`is_obsolete`;
		SET @is_update_needed = NULL;
		
		SET @uneet_name = NEW.`designation`;

		SET @unee_t_unit_type = (IFNULL(NEW.`unee_t_unit_type`
				, 'Unknown'
				)
			)
			;
			
		SET @new_record_id = NEW.`system_id_unit`;
		SET @external_property_type_id = 2;

		SET @external_property_id = NEW.`external_id`;
		SET @external_system = NEW.`external_system_id`;
		SET @table_in_external_system = NEW.`external_table`;			

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
					(@syst_created_datetime
					, @creation_system_id
					, @created_by_id
					, @creation_method
					, @organization_id
					, @is_obsolete
					, @is_update_needed
					, @uneet_name
					, @unee_t_unit_type
					, @new_record_id
					, @external_property_type_id
					, @external_property_id
					, @external_system
					, @table_in_external_system
					)
				ON DUPLICATE KEY UPDATE
					`syst_updated_datetime` = @syst_updated_datetime
					, `update_system_id` = @update_system_id
					, `updated_by_id` = @updated_by_id
					, `update_method` = @update_method
					, `organization_id` = @organization_id
					, `uneet_name` = @uneet_name
					, `unee_t_unit_type` = @unee_t_unit_type
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

	SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t`;

	SET @new_is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t`;
	SET @old_is_creation_needed_in_unee_t = OLD.`is_creation_needed_in_unee_t`;

	SET @do_not_insert = NEW.`do_not_insert` ;

	SET @system_id_unit = NEW.`system_id_unit` ;

	SET @mefe_unit_id = (SELECT `unee_t_mefe_unit_id`
		FROM `ut_map_external_source_units`
		WHERE `new_record_id` = @system_id_unit
			AND `external_property_type_id` = 2
		);

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;

	IF @is_creation_needed_in_unee_t = 1
		AND @do_not_insert = 0 
		AND @mefe_unit_id IS NOT NULL
		AND (@upstream_create_method = 'ut_update_external_property_level_2'
			OR @upstream_update_method = 'ut_update_external_property_level_2'
			)
	THEN 

	# We capture the values we need for the insert/udpate:

		SET @this_trigger = 'ut_update_map_external_source_unit_edit_level_2';

		SET @syst_created_datetime = NOW();
		SET @creation_system_id = NEW.`update_system_id`;
		SET @created_by_id = NEW.`updated_by_id`;
		SET @creation_method = @this_trigger ;

		SET @syst_updated_datetime = NOW();
		SET @update_system_id = NEW.`update_system_id`;
		SET @updated_by_id = NEW.`updated_by_id`;
		SET @update_method = @this_trigger ;

		SET @organization_id = NEW.`organization_id`;
			
		SET @is_obsolete = NEW.`is_obsolete`;
		SET @is_update_needed = NULL;
		
		SET @uneet_name = NEW.`designation`;

		SET @unee_t_unit_type = (IFNULL(NEW.`unee_t_unit_type`
				, 'Unknown'
				)
			)
			;
			
		SET @new_record_id = NEW.`system_id_unit`;
		SET @external_property_type_id = 2;

		SET @external_property_id = NEW.`external_id`;
		SET @external_system = NEW.`external_system_id`;
		SET @table_in_external_system = NEW.`external_table`;

		SET @is_mefe_api_success := 0 ;
		SET @mefe_api_error_message := (CONCAT('N/A - written by '
				, '`'
				, @this_trigger
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
					(@syst_created_datetime
					, @creation_system_id
					, @created_by_id
					, @creation_method
					, @organization_id
					, @is_obsolete
					, @is_update_needed
					, @is_mefe_api_success
					, @mefe_api_error_message
					, @uneet_name
					, @unee_t_unit_type
					, @new_record_id
					, @external_property_type_id
					, @external_property_id
					, @external_system
					, @table_in_external_system
					)
				ON DUPLICATE KEY UPDATE
					`syst_updated_datetime` = @syst_updated_datetime
					, `update_system_id` = @update_system_id
					, `updated_by_id` = @updated_by_id
					, `update_method` = @update_method
					, `organization_id` = @organization_id
					, `is_mefe_api_success` = @is_mefe_api_success
					, `mefe_api_error_message` = @mefe_api_error_message
					, `uneet_name` = @uneet_name
					, `unee_t_unit_type` = @unee_t_unit_type
					, `is_update_needed` = 1
				;

	END IF;
END;
$$
DELIMITER ;