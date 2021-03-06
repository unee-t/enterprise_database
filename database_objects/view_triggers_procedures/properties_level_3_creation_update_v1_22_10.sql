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