#################
#
# This lists all the triggers we use to create 
# a property_level_3
# via the Unee-T Enterprise Interface
#
#################
#
# This script creates or updates the following triggers:
#	- `ut_insert_external_property_level_3`
#	- `ut_update_external_property_level_3`
#	- `ut_update_external_property_level_3_creation_needed`
#	- `ut_update_map_external_source_unit_add_room`
#	- `ut_update_map_external_source_unit_add_room_creation_needed`
#

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

	SET @is_creation_needed_in_unee_t_insert_ext_l3_1 = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator_insert_ext_l3_1 = NEW.`created_by_id` ;
	SET @source_system_updater_insert_ext_l3_1 = (IF(NEW.`updated_by_id` IS NULL
			, @source_system_creator_insert_ext_l3_1
			, NEW.`updated_by_id`
			)
		);

	SET @creator_mefe_user_id_insert_ext_l3_1 = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator_insert_ext_l3_1
		)
		;

	SET @upstream_create_method_insert_ext_l3_1 = NEW.`creation_method` ;
	SET @upstream_update_method_insert_ext_l3_1 = NEW.`update_method` ;

	SET @organization_id_insert_ext_l3_1 = @source_system_creator_insert_ext_l3_1 ;

	SET @external_id_insert_ext_l3_1 = NEW.`external_id` ;
	SET @external_system_id_insert_ext_l3_1 = NEW.`external_system_id` ;
	SET @external_table_insert_ext_l3_1 = NEW.`external_table` ;

	SET @id_in_property_level_3_rooms_insert_ext_l3_1 = (SELECT `system_id_room`
		FROM `property_level_3_rooms`
		WHERE `external_system_id` = @external_system_id_insert_ext_l3_1
			AND `external_table` = @external_table_insert_ext_l3_1
			AND `external_id` = @external_id_insert_ext_l3_1
			AND `organization_id` = @organization_id_insert_ext_l3_1
		);
		
	SET @upstream_do_not_insert_insert_ext_l3_1 = NEW.`do_not_insert` ;

	# This is an INSERT - the record should NOT exist already

		SET @do_not_insert_insert_ext_l3_1 = (IF (@id_in_property_level_3_rooms_insert_ext_l3_1 IS NULL
				, 0
				, @upstream_do_not_insert_insert_ext_l3_1
				)
			
			);

	# Get the information about the unit for that room...
	# We need the information from the table `external_property_level_2_units` (and NOT the table `external_property_level_2_units`)
	
		SET @unit_id_1_insert_ext_l3_1 = NEW.`system_id_unit` ;

		SET @unit_external_id_insert_ext_l3_1 = (SELECT `external_id`
			FROM `external_property_level_2_units`
			WHERE `system_id_unit` = @unit_id_1_insert_ext_l3_1
				);
		SET @unit_external_system_id_insert_ext_l3_1 = (SELECT `external_system_id`
			FROM `external_property_level_2_units`
			WHERE `system_id_unit` = @unit_id_1_insert_ext_l3_1
			);
		SET @unit_external_table_insert_ext_l3_1 = (SELECT `external_table`
		   FROM `external_property_level_2_units`
			WHERE `system_id_unit` = @unit_id_1_insert_ext_l3_1
			);

		SET @system_id_unit_insert_ext_l3_1 = (SELECT `system_id_unit`
			FROM `property_level_2_units`
			WHERE `external_id` = @unit_external_id_insert_ext_l3_1
				AND `external_system_id` = @unit_external_system_id_insert_ext_l3_1
				AND `external_table` = @unit_external_table_insert_ext_l3_1
				AND `organization_id` = @organization_id_insert_ext_l3_1
				);

	IF @is_creation_needed_in_unee_t_insert_ext_l3_1 = 1
		AND @do_not_insert_insert_ext_l3_1 = 0
		AND @external_id_insert_ext_l3_1 IS NOT NULL
		AND @external_system_id_insert_ext_l3_1 IS NOT NULL
		AND @external_table_insert_ext_l3_1 IS NOT NULL
		AND @organization_id_insert_ext_l3_1 IS NOT NULL
		AND @system_id_unit_insert_ext_l3_1 IS NOT NULL
		AND (@upstream_create_method_insert_ext_l3_1 = 'imported_from_hmlet_ipi'
			OR @upstream_update_method_insert_ext_l3_1 = 'imported_from_hmlet_ipi'
			OR @upstream_create_method_insert_ext_l3_1 = 'Manage_Rooms_Add_Page'
			OR @upstream_update_method_insert_ext_l3_1 = 'Manage_Rooms_Add_Page'
			OR @upstream_create_method_insert_ext_l3_1 = 'Manage_Rooms_Edit_Page'
			OR @upstream_update_method_insert_ext_l3_1 = 'Manage_Rooms_Edit_Page'
			OR @upstream_create_method_insert_ext_l3_1 = 'Manage_Rooms_Import_Page'
			OR @upstream_update_method_insert_ext_l3_1 = 'Manage_Rooms_Import_Page'
			OR @upstream_create_method_insert_ext_l3_1 = 'Export_and_Import_Rooms_Import_Page'
			OR @upstream_update_method_insert_ext_l3_1 = 'Export_and_Import_Rooms_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `external_property_level_2_units` table:

		SET @this_trigger_insert_ext_l3_1 = 'ut_insert_external_property_level_3' ;

		SET @syst_created_datetime_insert_ext_l3_1 = NOW();
		SET @creation_system_id_insert_ext_l3_1 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator_insert_ext_l3_1
			)
			;
		SET @created_by_id_insert_ext_l3_1 = @creator_mefe_user_id_insert_ext_l3_1 ;
		SET @downstream_creation_method_insert_ext_l3_1 = @this_trigger_insert_ext_l3_1 ;

		SET @syst_updated_datetime_insert_ext_l3_1 = NOW();

		SET @update_system_id_insert_ext_l3_1 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater_insert_ext_l3_1
			)
			;
		SET @updated_by_id_insert_ext_l3_1 = @creator_mefe_user_id_insert_ext_l3_1 ;
		SET @downstream_update_method_insert_ext_l3_1 = @this_trigger_insert_ext_l3_1 ;

		SET @organization_id_create_insert_ext_l3_1 = @source_system_creator_insert_ext_l3_1 ;
		SET @organization_id_update_insert_ext_l3_1 = @source_system_updater_insert_ext_l3_1 ;
		
		SET @is_obsolete_insert_ext_l3_1 = NEW.`is_obsolete` ;
		SET @is_creation_needed_in_unee_t_insert_ext_l3_1 = NEW.`is_creation_needed_in_unee_t` ;

		SET @unee_t_unit_type_insert_ext_l3_1 = NEW.`unee_t_unit_type` ;
			
		SET @room_type_id_insert_ext_l3_1 = NEW.`room_type_id` ;
		SET @number_of_beds_insert_ext_l3_1 = NEW.`number_of_beds` ;
		SET @surface_insert_ext_l3_1 = NEW.`surface` ;
		SET @surface_measurment_unit_insert_ext_l3_1 = NEW.`surface_measurment_unit` ;
		SET @room_designation_insert_ext_l3_1 = NEW.`room_designation`;
		SET @room_description_insert_ext_l3_1 = NEW.`room_description` ;

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
 				(@external_id_insert_ext_l3_1
				, @external_system_id_insert_ext_l3_1
				, @external_table_insert_ext_l3_1
				, @syst_created_datetime_insert_ext_l3_1
				, @creation_system_id_insert_ext_l3_1
				, @created_by_id_insert_ext_l3_1
				, @downstream_creation_method_insert_ext_l3_1
				, @organization_id_create_insert_ext_l3_1
				, @is_obsolete_insert_ext_l3_1
				, @is_creation_needed_in_unee_t_insert_ext_l3_1
				, @do_not_insert_insert_ext_l3_1
				, @unee_t_unit_type_insert_ext_l3_1
				, @system_id_unit_insert_ext_l3_1
				, @room_type_id_insert_ext_l3_1
				, @surface_insert_ext_l3_1
				, @surface_measurment_unit_insert_ext_l3_1
				, @room_designation_insert_ext_l3_1
				, @room_description_insert_ext_l3_1
 			)
			ON DUPLICATE KEY UPDATE
 				`syst_updated_datetime` = @syst_updated_datetime_insert_ext_l3_1
 				, `update_system_id` = @update_system_id_insert_ext_l3_1
 				, `updated_by_id` = @updated_by_id_insert_ext_l3_1
				, `update_method` = @downstream_update_method_insert_ext_l3_1
				, `organization_id` = @organization_id_update_insert_ext_l3_1
				, `is_obsolete` = @is_obsolete_insert_ext_l3_1
				, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t_insert_ext_l3_1
				, `do_not_insert` = @do_not_insert_insert_ext_l3_1
				, `unee_t_unit_type` = @unee_t_unit_type_insert_ext_l3_1
				, `system_id_unit` = @system_id_unit_insert_ext_l3_1
				, `room_type_id` = @room_type_id_insert_ext_l3_1
				, `surface` = @surface_insert_ext_l3_1
				, `surface_measurment_unit` = @surface_measurment_unit_insert_ext_l3_1
				, `room_designation` = @room_designation_insert_ext_l3_1
				, `room_description` = @room_description_insert_ext_l3_1
			;

	END IF;

END;
$$
DELIMITER ;

# We create a trigger when a record is updated in the `external_property_level_3_rooms` table
#	- The unit DOES exist in the table `external_property_level_3_rooms`
#	- This is a NOT a new creation request in Unee-T

	DROP TRIGGER IF EXISTS `ut_update_external_property_level_3`;

DELIMITER $$
CREATE TRIGGER `ut_update_external_property_level_3`
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
#	- The unit was already marked as needed to be created in Unee-T
#	- The unit already exists in the table `property_level_2_units`
#	- We have a valid building_id for that unit.
#	- The `do_not_insert_field` is NOT equal to 1
#	- This is a valid update method:
#		- `imported_from_hmlet_ipi`
#		- `Manage_Units_Add_Page`
#		- `Manage_Units_Edit_Page`
#		- 'Manage_Units_Import_Page'
#		- 'Export_and_Import_Rooms_Import_Page'
#		- ''

	SET @is_creation_needed_in_unee_t_update_ext_l3_1 = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator_update_ext_l3_1 = NEW.`created_by_id` ;
	SET @source_system_updater_update_ext_l3_1 = (IF(NEW.`updated_by_id` IS NULL
			, @source_system_creator_update_ext_l3_1
			, NEW.`updated_by_id`
			)
		);

	SET @creator_mefe_user_id_update_ext_l3_1 = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator_update_ext_l3_1
		)
		;

	SET @upstream_create_method_update_ext_l3_1 = NEW.`creation_method` ;
	SET @upstream_update_method_update_ext_l3_1 = NEW.`update_method` ;

	SET @organization_id_update_ext_l3_1 = @source_system_creator_update_ext_l3_1 ;

	SET @external_id_update_ext_l3_1 = NEW.`external_id` ;
	SET @external_system_id_update_ext_l3_1 = NEW.`external_system_id` ; 
	SET @external_table_update_ext_l3_1 = NEW.`external_table` ;

	SET @new_is_creation_needed_in_unee_t_update_ext_l3_1 = NEW.`is_creation_needed_in_unee_t` ;
	SET @old_is_creation_needed_in_unee_t_update_ext_l3_1 = OLD.`is_creation_needed_in_unee_t` ;

	SET @id_in_property_level_3_rooms_update_ext_l3_1 = (SELECT `system_id_room`
		FROM `property_level_3_rooms`
		WHERE `external_system_id` = @external_system_id_update_ext_l3_1
			AND `external_table` = @external_table_update_ext_l3_1
			AND `external_id` = @external_id_update_ext_l3_1
			AND `organization_id` = @organization_id_update_ext_l3_1
		);

	SET @upstream_do_not_insert_update_ext_l3_1 = NEW.`do_not_insert` ;

	# This is an UPDATE - the record SHOULD exist already

		SET @do_not_insert_update_ext_l3_1 = @upstream_do_not_insert_update_ext_l3_1 ;
		/*(IF (@id_in_property_level_3_rooms IS NULL
				, 1
				, @upstream_do_not_insert
				)
			);
		*/

	# Get the information about the unit for that room...
	# We need the information from the table `external_property_level_2_units` (and NOT the table `external_property_level_2_units`)
	
		SET @unit_id_1_update_ext_l3_1 = NEW.`system_id_unit` ;

		SET @unit_external_id_update_ext_l3_1 = (SELECT `external_id`
			FROM `external_property_level_2_units`
			WHERE `system_id_unit` = @unit_id_1_update_ext_l3_1
				);
		SET @unit_external_system_id_update_ext_l3_1 = (SELECT `external_system_id`
			FROM `external_property_level_2_units`
			WHERE `system_id_unit` = @unit_id_1_update_ext_l3_1
			);
		SET @unit_external_table_update_ext_l3_1 = (SELECT `external_table`
		   FROM `external_property_level_2_units`
			WHERE `system_id_unit` = @unit_id_1_update_ext_l3_1
			);

		SET @system_id_unit_update_ext_l3_1 = (SELECT `system_id_unit`
			FROM `property_level_2_units`
			WHERE `external_id` = @unit_external_id_update_ext_l3_1
				AND `external_system_id` = @unit_external_system_id_update_ext_l3_1
				AND `external_table` = @unit_external_table_update_ext_l3_1
				AND `organization_id` = @organization_id_update_ext_l3_1
				);

	IF @is_creation_needed_in_unee_t_update_ext_l3_1 = 1
		AND @new_is_creation_needed_in_unee_t_update_ext_l3_1 = @old_is_creation_needed_in_unee_t_update_ext_l3_1
		AND @do_not_insert_update_ext_l3_1 = 0
		AND @external_id_update_ext_l3_1 IS NOT NULL
		AND @external_system_id_update_ext_l3_1 IS NOT NULL
		AND @external_table_update_ext_l3_1 IS NOT NULL
		AND @organization_id_update_ext_l3_1 IS NOT NULL
		AND @system_id_unit_update_ext_l3_1 IS NOT NULL
		AND (@upstream_create_method_update_ext_l3_1 = 'imported_from_hmlet_ipi'
			OR @upstream_update_method_update_ext_l3_1 = 'imported_from_hmlet_ipi'
			OR @upstream_create_method_update_ext_l3_1 = 'Manage_Rooms_Add_Page'
			OR @upstream_update_method_update_ext_l3_1 = 'Manage_Rooms_Add_Page'
			OR @upstream_create_method_update_ext_l3_1 = 'Manage_Rooms_Edit_Page'
			OR @upstream_update_method_update_ext_l3_1 = 'Manage_Rooms_Edit_Page'
			OR @upstream_create_method_update_ext_l3_1 = 'Manage_Rooms_Import_Page'
			OR @upstream_update_method_update_ext_l3_1 = 'Manage_Rooms_Import_Page'
			OR @upstream_create_method_update_ext_l3_1 = 'Export_and_Import_Rooms_Import_Page'
			OR @upstream_update_method_update_ext_l3_1 = 'Export_and_Import_Rooms_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `external_property_level_2_units` table:

		SET @this_trigger_update_ext_l3_1 = 'ut_update_external_property_level_3';

		SET @syst_created_datetime_update_ext_l3_1 = NOW();
		SET @creation_system_id_update_ext_l3_1 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator_update_ext_l3_1
			)
			;
		SET @created_by_id_update_ext_l3_1 = @creator_mefe_user_id_update_ext_l3_1 ;
		SET @downstream_creation_method_update_ext_l3_1 = @this_trigger_update_ext_l3_1 ;

		SET @syst_updated_datetime_update_ext_l3_1 = NOW();

		SET @update_system_id_update_ext_l3_1 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater_update_ext_l3_1
			)
			;
		SET @updated_by_id_update_ext_l3_1 = @creator_mefe_user_id_update_ext_l3_1 ;
		SET @downstream_update_method_update_ext_l3_1 = @this_trigger_update_ext_l3_1 ;

		SET @organization_id_create_update_ext_l3_1 = @source_system_creator_update_ext_l3_1 ;
		SET @organization_id_update_update_ext_l3_1 = @source_system_updater_update_ext_l3_1 ;

		SET @is_obsolete_update_ext_l3_1 = NEW.`is_obsolete` ;
		SET @is_creation_needed_in_unee_t_update_ext_l3_1 = NEW.`is_creation_needed_in_unee_t` ;

		SET @unee_t_unit_type_update_ext_l3_1 = NEW.`unee_t_unit_type` ;
			
		SET @room_type_id_update_ext_l3_1 = NEW.`room_type_id` ;
		SET @number_of_beds_update_ext_l3_1 = NEW.`number_of_beds` ;
		SET @surface_update_ext_l3_1 = NEW.`surface` ;
		SET @surface_measurment_unit_update_ext_l3_1 = NEW.`surface_measurment_unit` ;
		SET @room_designation_update_ext_l3_1 = NEW.`room_designation`;
		SET @room_description_update_ext_l3_1 = NEW.`room_description` ;

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
 				(@external_id_update_ext_l3_1
				, @external_system_id_update_ext_l3_1
				, @external_table_update_ext_l3_1
				, @syst_created_datetime_update_ext_l3_1
				, @creation_system_id_update_ext_l3_1
				, @created_by_id_update_ext_l3_1
				, @downstream_creation_method_update_ext_l3_1
				, @organization_id_create_update_ext_l3_1
				, @is_obsolete_update_ext_l3_1
				, @is_creation_needed_in_unee_t_update_ext_l3_1
				, @do_not_insert_update_ext_l3_1
				, @unee_t_unit_type_update_ext_l3_1
				, @system_id_unit_update_ext_l3_1
				, @room_type_id_update_ext_l3_1
				, @surface_update_ext_l3_1
				, @surface_measurment_unit_update_ext_l3_1
				, @room_designation_update_ext_l3_1
				, @room_description_update_ext_l3_1
 			)
			ON DUPLICATE KEY UPDATE
 				`syst_updated_datetime` = @syst_updated_datetime_update_ext_l3_1
 				, `update_system_id` = @update_system_id_update_ext_l3_1
 				, `updated_by_id` = @updated_by_id_update_ext_l3_1
				, `update_method` = @downstream_update_method_update_ext_l3_1
				, `organization_id` = @organization_id_update_update_ext_l3_1
				, `is_obsolete` = @is_obsolete_update_ext_l3_1
				, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t_update_ext_l3_1
				, `do_not_insert` = @do_not_insert_update_ext_l3_1
				, `unee_t_unit_type` = @unee_t_unit_type_update_ext_l3_1
				, `system_id_unit` = @system_id_unit_update_ext_l3_1
				, `room_type_id` = @room_type_id_update_ext_l3_1
				, `surface` = @surface_update_ext_l3_1
				, `surface_measurment_unit` = @surface_measurment_unit_update_ext_l3_1
				, `room_designation` = @room_designation_update_ext_l3_1
				, `room_description` = @room_description_update_ext_l3_1
			;

	END IF;

END;
$$
DELIMITER ;

# We create a trigger when a record is updated in the `external_property_level_3_rooms` table
#	- The unit DOES exist in the table `external_property_level_3_rooms`
#	- This IS a new creation request in Unee-T

	DROP TRIGGER IF EXISTS `ut_update_external_property_level_3_creation_needed`;

DELIMITER $$
CREATE TRIGGER `ut_update_external_property_level_3_creation_needed`
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
#	- The unit was NOT already marked as needed to be created in Unee-T
#	- The unit for this room already exists in the table `property_level_2_units`
#	- The `do_not_insert_field` is NOT equal to 1
#	- This is a valid update method:
#		- `imported_from_hmlet_ipi`
#		- `Manage_Units_Add_Page`
#		- `Manage_Units_Edit_Page`
#		- 'Manage_Units_Import_Page'
#		- 'Export_and_Import_Rooms_Import_Page'
#		- ''

	SET @is_creation_needed_in_unee_t_update_ext_l3_2 = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator_update_ext_l3_2 = NEW.`created_by_id` ;
	SET @updated_by_id_source_update_ext_l3_2 = NEW.`updated_by_id` ;
	SET @source_system_updater_update_ext_l3_2 = (IF(@updated_by_id_source_update_ext_l3_2 IS NULL
			, @source_system_creator_update_ext_l3_2
			, @updated_by_id_source_update_ext_l3_2
			)
		);

	SET @creator_mefe_user_id_update_ext_l3_2 = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator_update_ext_l3_2
		)
		;

	SET @upstream_create_method_update_ext_l3_2 = NEW.`creation_method` ;
	SET @upstream_update_method_update_ext_l3_2 = NEW.`update_method` ;

	SET @organization_id_update_ext_l3_2 = @source_system_creator_update_ext_l3_2 ;

	SET @external_id_update_ext_l3_2 = NEW.`external_id` ;
	SET @external_system_id_update_ext_l3_2 = NEW.`external_system_id` ; 
	SET @external_table_update_ext_l3_2 = NEW.`external_table` ;

	SET @new_is_creation_needed_in_unee_t_update_ext_l3_2 = NEW.`is_creation_needed_in_unee_t` ;
	SET @old_is_creation_needed_in_unee_t_update_ext_l3_2 = OLD.`is_creation_needed_in_unee_t` ;

	SET @upstream_do_not_insert_update_ext_l3_2 = NEW.`do_not_insert` ;

	# This is an UPDATE - the record SHOULD exist already
	# BUT there are some edge cases when we need to re-create this...

		SET @do_not_insert_update_ext_l3_2 = @upstream_do_not_insert_update_ext_l3_2 ;

	# Get the information about the unit for that room...
	# We need the information from the table `external_property_level_2_units` (and NOT the table `external_property_level_2_units`)
	
		SET @unit_id_1_update_ext_l3_2 = NEW.`system_id_unit` ;

		SET @unit_external_id_update_ext_l3_2 = (SELECT `external_id`
			FROM `external_property_level_2_units`
			WHERE `system_id_unit` = @unit_id_1_update_ext_l3_2
				);
		SET @unit_external_system_id_update_ext_l3_2 = (SELECT `external_system_id`
			FROM `external_property_level_2_units`
			WHERE `system_id_unit` = @unit_id_1_update_ext_l3_2
			);
		SET @unit_external_table_update_ext_l3_2 = (SELECT `external_table`
		   FROM `external_property_level_2_units`
			WHERE `system_id_unit` = @unit_id_1_update_ext_l3_2
			);

		SET @system_id_unit_update_ext_l3_2 = (SELECT `system_id_unit`
			FROM `property_level_2_units`
			WHERE `external_id` = @unit_external_id_update_ext_l3_2
				AND `external_system_id` = @unit_external_system_id_update_ext_l3_2
				AND `external_table` = @unit_external_table_update_ext_l3_2
				AND `organization_id` = @organization_id_update_ext_l3_2
				);

	IF @is_creation_needed_in_unee_t_update_ext_l3_2 = 1
		AND @new_is_creation_needed_in_unee_t_update_ext_l3_2 != @old_is_creation_needed_in_unee_t_update_ext_l3_2
		AND @do_not_insert_update_ext_l3_2 = 0
		AND @external_id_update_ext_l3_2 IS NOT NULL
		AND @external_system_id_update_ext_l3_2 IS NOT NULL
		AND @external_table_update_ext_l3_2 IS NOT NULL
		AND @organization_id_update_ext_l3_2 IS NOT NULL
		AND @system_id_unit_update_ext_l3_2 IS NOT NULL
		AND (@upstream_create_method_update_ext_l3_2 = 'imported_from_hmlet_ipi'
			OR @upstream_update_method_update_ext_l3_2 = 'imported_from_hmlet_ipi'
			OR @upstream_create_method_update_ext_l3_2 = 'Manage_Rooms_Add_Page'
			OR @upstream_update_method_update_ext_l3_2 = 'Manage_Rooms_Add_Page'
			OR @upstream_create_method_update_ext_l3_2 = 'Manage_Rooms_Edit_Page'
			OR @upstream_update_method_update_ext_l3_2 = 'Manage_Rooms_Edit_Page'
			OR @upstream_create_method_update_ext_l3_2 = 'Manage_Rooms_Import_Page'
			OR @upstream_update_method_update_ext_l3_2 = 'Manage_Rooms_Import_Page'
			OR @upstream_create_method_update_ext_l3_2 = 'Export_and_Import_Rooms_Import_Page'
			OR @upstream_update_method_update_ext_l3_2 = 'Export_and_Import_Rooms_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `external_property_level_2_units` table:

		SET @this_trigger_update_ext_l3_2 = 'ut_update_external_property_level_3_creation_needed';

		SET @syst_created_datetime_update_ext_l3_2 = NOW();
		SET @creation_system_id_update_ext_l3_2 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator_update_ext_l3_2
			)
			;
		SET @created_by_id_update_ext_l3_2 = @creator_mefe_user_id_update_ext_l3_2 ;
		SET @downstream_creation_method_update_ext_l3_2 = @this_trigger_update_ext_l3_2 ;

		SET @syst_updated_datetime_update_ext_l3_2 = NOW();

		SET @update_system_id_update_ext_l3_2 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater_update_ext_l3_2
			)
			;
		SET @updated_by_id_update_ext_l3_2 = @creator_mefe_user_id_update_ext_l3_2 ;
		SET @downstream_update_method_update_ext_l3_2 = @this_trigger_update_ext_l3_2 ;

		SET @organization_id_create_update_ext_l3_2 = @source_system_creator_update_ext_l3_2 ;
		SET @organization_id_update_update_ext_l3_2 = @source_system_updater_update_ext_l3_2 ;

		SET @is_obsolete_update_ext_l3_2 = NEW.`is_obsolete` ;
		SET @is_creation_needed_in_unee_t_update_ext_l3_2 = NEW.`is_creation_needed_in_unee_t` ;

		SET @unee_t_unit_type_update_ext_l3_2 = NEW.`unee_t_unit_type` ;
			
		SET @room_type_id_update_ext_l3_2 = NEW.`room_type_id` ;
		SET @number_of_beds_update_ext_l3_2 = NEW.`number_of_beds` ;
		SET @surface_update_ext_l3_2 = NEW.`surface` ;
		SET @surface_measurment_unit_update_ext_l3_2 = NEW.`surface_measurment_unit` ;
		SET @room_designation_update_ext_l3_2 = NEW.`room_designation`;
		SET @room_description_update_ext_l3_2 = NEW.`room_description` ;

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
 				(@external_id_update_ext_l3_2
				, @external_system_id_update_ext_l3_2
				, @external_table_update_ext_l3_2
				, @syst_created_datetime_update_ext_l3_2
				, @creation_system_id_update_ext_l3_2
				, @created_by_id_update_ext_l3_2
				, @downstream_creation_method_update_ext_l3_2
				, @organization_id_create_update_ext_l3_2
				, @is_obsolete_update_ext_l3_2
				, @is_creation_needed_in_unee_t_update_ext_l3_2
				, @do_not_insert_update_ext_l3_2
				, @unee_t_unit_type_update_ext_l3_2
				, @system_id_unit_update_ext_l3_2
				, @room_type_id_update_ext_l3_2
				, @surface_update_ext_l3_2
				, @surface_measurment_unit_update_ext_l3_2
				, @room_designation_update_ext_l3_2
				, @room_description_update_ext_l3_2
 			)
			ON DUPLICATE KEY UPDATE
 				`syst_updated_datetime` = @syst_updated_datetime_update_ext_l3_2
 				, `update_system_id` = @update_system_id_update_ext_l3_2
 				, `updated_by_id` = @updated_by_id_update_ext_l3_2
				, `update_method` = @downstream_update_method_update_ext_l3_2
				, `organization_id` = @organization_id_update_update_ext_l3_2
				, `is_obsolete` = @is_obsolete_update_ext_l3_2
				, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t_update_ext_l3_2
				, `do_not_insert` = @do_not_insert_update_ext_l3_2
				, `unee_t_unit_type` = @unee_t_unit_type_update_ext_l3_2
				, `system_id_unit` = @system_id_unit_update_ext_l3_2
				, `room_type_id` = @room_type_id_update_ext_l3_2
				, `surface` = @surface_update_ext_l3_2
				, `surface_measurment_unit` = @surface_measurment_unit_update_ext_l3_2
				, `room_designation` = @room_designation_update_ext_l3_2
				, `room_description` = @room_description_update_ext_l3_2
			;

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
		);

	# This is an insert - if the record does NOT exist, we create the record
	# unless 
	#	- it is specifically specified that we do NOT need to create the record.
	#	- the record is marked as obsolete

		SET @is_obsolete_insert_l3_1 = NEW.`is_obsolete`;


		SET @do_not_insert_insert_l3_1 = (IF (@id_in_ut_map_external_source_units_insert_l3_1 IS NULL
				, IF (@is_obsolete_insert_l3_1 != 0
					, 1
					, 0
					)
				, IF (@is_obsolete_insert_l3_1 != 0
					, 1
					, NEW.`do_not_insert`
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

		SET @unee_t_unit_type_insert_l3_1 = (IFNULL(NEW.`unee_t_unit_type`
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

# Create a trigger to update the table that will fire the lambda each time a new Room is marked as `is_creation_needed_in_unee_t` = 1

	DROP TRIGGER IF EXISTS `ut_update_map_external_source_unit_add_room_creation_needed`;

DELIMITER $$
CREATE TRIGGER `ut_update_map_external_source_unit_add_room_creation_needed`
AFTER UPDATE ON `property_level_3_rooms`
FOR EACH ROW
BEGIN

# We only do this IF:
# 	- We need to create the unit in Unee-T
#	- The unit is NOT marked as `do_not_insert`
#	- We do NOT have a MEFE unit ID for that unit
#	- This is done via an authorized update method:
#		- 'ut_insert_external_property_level_3'
#		- 'ut_update_external_property_level_3_creation_needed'
#		- ''

	SET @is_creation_needed_in_unee_t_update_l3_1 := NEW.`is_creation_needed_in_unee_t`;

	SET @new_is_creation_needed_in_unee_t_update_l3_1 := NEW.`is_creation_needed_in_unee_t`;
	SET @old_is_creation_needed_in_unee_t_update_l3_1 := OLD.`is_creation_needed_in_unee_t`;

	SET @do_not_insert_update_l3_1_raw := NEW.`do_not_insert` ;

	SET @system_id_room_update_l3_1 := NEW.`system_id_room` ;

	SET @mefe_unit_id_update_l3_1 := (SELECT `unee_t_mefe_unit_id`
		FROM `ut_map_external_source_units`
		WHERE `new_record_id` = @system_id_room_update_l3_1
			AND `external_property_type_id` = 3
		);

	# This is an insert - if the record does NOT exist, we create the record
	# unless 
	#	- it is specifically specified that we do NOT need to create the record.
	#	- the record is marked as obsolete

		SET @is_obsolete_update_l3_1 = NEW.`is_obsolete`;

		SET @do_not_insert_update_l3_1 = (IF (@do_not_insert_update_l3_1_raw IS NULL
				, IF (@is_obsolete_update_l3_1 != 0
					, 1
					, 0
					)
				, IF (@is_obsolete_update_l3_1 != 0
					, 1
					, NEW.`do_not_insert`
					)
				)
			);

	SET @upstream_create_method_update_l3_1 := NEW.`creation_method` ;
	SET @upstream_update_method_update_l3_1 := NEW.`update_method` ;

	IF @is_creation_needed_in_unee_t_update_l3_1 = 1
		AND @do_not_insert_update_l3_1 = 0 
		AND @mefe_unit_id_update_l3_1 IS NULL
		AND (@upstream_create_method_update_l3_1 = 'ut_insert_external_property_level_3'
			OR @upstream_update_method_update_l3_1 = 'ut_insert_external_property_level_3'
			OR @upstream_create_method_update_l3_1 = 'ut_update_external_property_level_3_creation_needed'
			OR @upstream_update_method_update_l3_1 = 'ut_update_external_property_level_3_creation_needed'
			)
	THEN 

	# We capture the values we need for the insert/udpate:

		SET @this_trigger_update_l3_1 = 'ut_update_map_external_source_unit_add_room_creation_needed' ;

		SET @syst_created_datetime_update_l3_1 = NOW();
		SET @creation_system_id_update_l3_1 = NEW.`update_system_id`;
		SET @created_by_id_update_l3_1 = NEW.`updated_by_id`;
		SET @creation_method_update_l3_1 = @this_trigger_update_l3_1 ;

		SET @syst_updated_datetime_update_l3_1 = NOW();
		SET @update_system_id_update_l3_1 = NEW.`update_system_id`;
		SET @updated_by_id_update_l3_1 = NEW.`updated_by_id`;
		SET @update_method_update_l3_1 = @this_trigger_update_l3_1 ;

		SET @organization_id_update_l3_1 = NEW.`organization_id`;
		
		SET @is_update_needed_update_l3_1 = NULL;
			
		SET @uneet_name_update_l3_1 = NEW.`room_designation`;

		SET @unee_t_unit_type_update_l3_1 = (IFNULL(NEW.`unee_t_unit_type`
				, 'Unknown'
				)
			)
			;
			
		SET @new_record_id_update_l3_1 = NEW.`system_id_room`;
		SET @external_property_type_id_update_l3_1 = 3;

		SET @external_property_id_update_l3_1 = NEW.`external_id`;
		SET @external_system_update_l3_1 = NEW.`external_system_id`;
		SET @table_in_external_system_update_l3_1 = NEW.`external_table`;			

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
					(@syst_created_datetime_update_l3_1
					, @creation_system_id_update_l3_1
					, @created_by_id_update_l3_1
					, @creation_method_update_l3_1
					, @organization_id_update_l3_1
					, @is_obsolete_update_l3_1
					, @is_update_needed_update_l3_1
					, @uneet_name_update_l3_1
					, @unee_t_unit_type_update_l3_1
					, @new_record_id_update_l3_1
					, @external_property_type_id_update_l3_1
					, @external_property_id_update_l3_1
					, @external_system_update_l3_1
					, @table_in_external_system_update_l3_1
					)
				ON DUPLICATE KEY UPDATE 
					`syst_updated_datetime` = @syst_updated_datetime_update_l3_1
					, `update_system_id` = @update_system_id_update_l3_1
					, `updated_by_id` = @updated_by_id_update_l3_1
					, `update_method` = @update_method_update_l3_1
					, `organization_id` = @organization_id_update_l3_1
					, `uneet_name` = @uneet_name_update_l3_1
					, `unee_t_unit_type` = @unee_t_unit_type_update_l3_1
					, `is_update_needed` = 1
				;

	END IF;
END;
$$
DELIMITER ;

# Create a trigger to update the table that will fire the lambda each time 
# a new Property Level 3 needs to be updated

	DROP TRIGGER IF EXISTS `ut_update_map_external_source_unit_edit_level_3`;

DELIMITER $$
CREATE TRIGGER `ut_update_map_external_source_unit_edit_level_3`
AFTER UPDATE ON `property_level_3_rooms`
FOR EACH ROW
BEGIN

# We only do this IF:
# 	- We need to create the unit in Unee-T
#	- The unit is NOT marked as `do_not_insert`
#	- We DO have a MEFE unit ID for that unit
#	- This is done via an authorized update method:
#		- 'ut_update_external_property_level_3'
#		- ''

	SET @is_creation_needed_in_unee_t_update_l3_2 := NEW.`is_creation_needed_in_unee_t`;

	SET @new_is_creation_needed_in_unee_t_update_l3_2 := NEW.`is_creation_needed_in_unee_t`;
	SET @old_is_creation_needed_in_unee_t_update_l3_2 := OLD.`is_creation_needed_in_unee_t`;

	SET @do_not_insert_update_l3_2_raw := NEW.`do_not_insert` ;

	SET @system_id_room_update_l3_2 := NEW.`system_id_room` ;

	SET @mefe_unit_id_update_l3_2 := (SELECT `unee_t_mefe_unit_id`
		FROM `ut_map_external_source_units`
		WHERE `new_record_id` = @system_id_room_update_l3_2
			AND `external_property_type_id` = 3
		);

	# This is an insert - if the record does NOT exist, we create the record
	# unless 
	#	- it is specifically specified that we do NOT need to create the record.
	#	- the record is marked as obsolete

		SET @is_obsolete_update_l3_2 = NEW.`is_obsolete`;

		SET @do_not_insert_update_l3_2 = (IF (@do_not_insert_update_l3_2_raw IS NULL
				, IF (@is_obsolete_update_l3_2 != 0
					, 1
					, 0
					)
				, IF (@is_obsolete_update_l3_2 != 0
					, 1
					, NEW.`do_not_insert`
					)
				)
			);

	SET @upstream_create_method_update_l3_2 := NEW.`creation_method` ;
	SET @upstream_update_method_update_l3_2 := NEW.`update_method` ;

	IF @is_creation_needed_in_unee_t_update_l3_2 = 1
		AND @do_not_insert_update_l3_2 = 0 
		AND @mefe_unit_id_update_l3_2 IS NOT NULL
		AND (@upstream_create_method_update_l3_2 = 'ut_update_external_property_level_3'
			OR @upstream_update_method_update_l3_2 = 'ut_update_external_property_level_3'
			)
	THEN 

	# We capture the values we need for the insert/udpate:

		SET @this_trigger_update_l3_2 = 'ut_update_map_external_source_unit_edit_level_3' ;

		SET @syst_created_datetime_update_l3_2 = NOW();
		SET @creation_system_id_update_l3_2 = NEW.`update_system_id`;
		SET @created_by_id_update_l3_2 = NEW.`updated_by_id`;
		SET @creation_method_update_l3_2 = @this_trigger_update_l3_2 ;

		SET @syst_updated_datetime_update_l3_2 = NOW();
		SET @update_system_id_update_l3_2 = NEW.`update_system_id`;
		SET @updated_by_id_update_l3_2 = NEW.`updated_by_id`;
		SET @update_method_update_l3_2 = @this_trigger_update_l3_2 ;

		SET @organization_id_update_l3_2 = NEW.`organization_id`;
		
		SET @is_update_needed_update_l3_2 = NULL;
			
		SET @uneet_name_update_l3_2 = NEW.`room_designation`;

		SET @unee_t_unit_type_update_l3_2 = (IFNULL(NEW.`unee_t_unit_type`
				, 'Unknown'
				)
			)
			;
			
		SET @new_record_id_update_l3_2 = NEW.`system_id_room`;
		SET @external_property_type_id_update_l3_2 = 3;

		SET @external_property_id_update_l3_2 = NEW.`external_id`;
		SET @external_system_update_l3_2 = NEW.`external_system_id`;
		SET @table_in_external_system_update_l3_2 = NEW.`external_table`;			

		SET @is_mefe_api_success_update_l3_2 := 0 ;
		SET @mefe_api_error_message_update_l3_2 := (CONCAT('N/A - written by '
				, '`'
				, @this_trigger_update_l3_2
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
					(@syst_created_datetime_update_l3_2
					, @creation_system_id_update_l3_2
					, @created_by_id_update_l3_2
					, @creation_method_update_l3_2
					, @organization_id_update_l3_2
					, @is_obsolete_update_l3_2
					, @is_update_needed_update_l3_2
					, @is_mefe_api_success_update_l3_2
					, @mefe_api_error_message_update_l3_2
					, @uneet_name_update_l3_2
					, @unee_t_unit_type_update_l3_2
					, @new_record_id_update_l3_2
					, @external_property_type_id_update_l3_2
					, @external_property_id_update_l3_2
					, @external_system_update_l3_2
					, @table_in_external_system_update_l3_2
					)
				ON DUPLICATE KEY UPDATE 
					`syst_updated_datetime` = @syst_updated_datetime_update_l3_2
					, `update_system_id` = @update_system_id_update_l3_2
					, `updated_by_id` = @updated_by_id_update_l3_2
					, `update_method` = @update_method_update_l3_2
					, `organization_id` = @organization_id_update_l3_2
					, `is_mefe_api_success` = @is_mefe_api_success_update_l3_2
					, `mefe_api_error_message` = @mefe_api_error_message_update_l3_2
					, `uneet_name` = @uneet_name_update_l3_2
					, `unee_t_unit_type` = @unee_t_unit_type_update_l3_2
					, `is_update_needed` = 1
				;

	END IF;
END;
$$
DELIMITER ;