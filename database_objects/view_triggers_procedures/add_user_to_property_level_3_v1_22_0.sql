#################
#
# This lists all the triggers we use 
# to add a user to a role in a unit
# Level_3 properties
# via the Unee-T Enterprise Interface
#
#################

# This script creates the following triggers:
#	- `ut_add_user_to_role_in_a_level_3_property`
#	- ``

# For properties Level 3 (Rooms)

	DROP TRIGGER IF EXISTS `ut_add_user_to_role_in_a_level_3_property`;

DELIMITER $$
CREATE TRIGGER `ut_add_user_to_role_in_a_level_3_property`
AFTER INSERT ON `external_map_user_unit_role_permissions_level_3`
FOR EACH ROW
BEGIN

# We only do this IF
#	- We have a MEFE user ID for the creator of that record
#	- We have an organization ID
#	- This is not an obsolete request
#	- We have a MEFE user ID for the user that we are adding
#	- We have a role_type
#	- We have a user_type
#	- We have a MEFE unit ID for the level 3 unit.
#	- This is done via an authorized insert method:
#		- 'Assign_Rooms_to_Users_Add_Page'
#		- 'Assign_Rooms_to_Users_Import_Page'
#		- 'imported_from_hmlet_ipi'
#		- ''
#

	SET @source_system_creator_add_u_l3_1 := NEW.`created_by_id` ;
	SET @source_system_updater_add_u_l3_1 := NEW.`updated_by_id`;

	SET @creator_mefe_user_id_add_u_l3_1 := (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator_add_u_l3_1
		)
		;

	SET @organization_id_add_u_l3_1 := NEW.`organization_id` ;

	SET @is_obsolete_id_add_u_l3_1 := NEW.`is_obsolete` ;

	SET @unee_t_level_3_id_add_u_l3_1 := NEW.`unee_t_level_3_id` ;

	SET @unee_t_mefe_user_id_add_u_l3_1 := NEW.`unee_t_mefe_user_id` ;
	SET @unee_t_user_type_id_add_u_l3_1 := NEW.`unee_t_user_type_id` ;
	SET @unee_t_role_id_add_u_l3_1 := NEW.`unee_t_role_id` ;

	SET @unee_t_mefe_unit_id_add_u_l3_1 := (SELECT `unee_t_mefe_unit_id`
		FROM `ut_list_mefe_unit_id_level_3_by_area`
		WHERE `level_3_room_id` = @unee_t_level_3_id_add_u_l3_1
		);

	SET @upstream_create_method_add_u_l3_1 := NEW.`creation_method` ;
	SET @upstream_update_method_add_u_l3_1 := NEW.`update_method` ;

	IF @source_system_creator_add_u_l3_1 IS NOT NULL
		AND @organization_id_add_u_l3_1 IS NOT NULL
		AND @is_obsolete_id_add_u_l3_1 = 0
		AND @unee_t_mefe_user_id_add_u_l3_1 IS NOT NULL
		AND @unee_t_user_type_id_add_u_l3_1 IS NOT NULL
		AND @unee_t_role_id_add_u_l3_1 IS NOT NULL
		AND @unee_t_mefe_unit_id_add_u_l3_1 IS NOT NULL
		AND (@upstream_create_method_add_u_l3_1 = 'Assign_Rooms_to_Users_Add_Page'
			OR @upstream_update_method_add_u_l3_1 = 'Assign_Rooms_to_Users_Add_Page'
			OR @upstream_create_method_add_u_l3_1 = 'Assign_Rooms_to_Users_Import_Page'
			OR @upstream_update_method_add_u_l3_1 = 'Assign_Rooms_to_Users_Import_Page'
			OR @upstream_create_method_add_u_l3_1 = 'imported_from_hmlet_ipi'
			OR @upstream_update_method_add_u_l3_1 = 'imported_from_hmlet_ipi'
			)
	THEN 

	# We capture the variables that we need:

		SET @this_trigger_id_add_u_l3_1 := 'ut_add_user_to_role_in_a_level_3_property' ;

		SET @syst_created_datetime_add_u_l3_1 := NOW() ;
		SET @creation_system_id_add_u_l3_1 := 2 ;
		SET @created_by_id_add_u_l3_1 := @source_system_creator_add_u_l3_1 ;
		SET @creation_method_add_u_l3_1 := @this_trigger_id_add_u_l3_1 ;

		SET @syst_updated_datetime_add_u_l3_1 := NOW() ;
		SET @update_system_id_add_u_l3_1 := 2 ;
		SET @updated_by_id_add_u_l3_1 := @source_system_updater_add_u_l3_1 ;
		SET @update_method_add_u_l3_1 := @this_trigger_id_add_u_l3_1 ;

		SET @is_update_needed_add_u_l3_1 := 1 ;

	# We insert these permissions in the table `ut_map_user_permissions_unit_level_3`
	# We need the values for each of the preferences

		SET @is_occupant := (SELECT `is_occupant` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);

		# additional permissions 
		SET @is_default_assignee := (SELECT `is_default_assignee` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @is_default_invited := (SELECT `is_default_invited` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @is_unit_owner := (SELECT `is_unit_owner` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);

		# Visibility rules 
		SET @is_public := (SELECT `is_public` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @can_see_role_landlord := (SELECT `can_see_role_landlord` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @can_see_role_tenant := (SELECT `can_see_role_tenant` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @can_see_role_mgt_cny := (SELECT `can_see_role_mgt_cny` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @can_see_role_agent := (SELECT `can_see_role_agent` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @can_see_role_contractor := (SELECT `can_see_role_contractor` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @can_see_occupant := (SELECT `can_see_occupant` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);

		# Notification rules 
		# - case - information 
		SET @is_assigned_to_case := (SELECT `is_assigned_to_case` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @is_invited_to_case := (SELECT `is_invited_to_case` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @is_next_step_updated := (SELECT `is_next_step_updated` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @is_deadline_updated := (SELECT `is_deadline_updated` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @is_solution_updated := (SELECT `is_solution_updated` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @is_case_resolved := (SELECT `is_case_resolved` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @is_case_blocker := (SELECT `is_case_blocker` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @is_case_critical := (SELECT `is_case_critical` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);

		# - case - messages 
		SET @is_any_new_message := (SELECT `is_any_new_message` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @is_message_from_tenant := (SELECT `is_message_from_tenant` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @is_message_from_ll := (SELECT `is_message_from_ll` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @is_message_from_occupant := (SELECT `is_message_from_occupant` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @is_message_from_agent := (SELECT `is_message_from_agent` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @is_message_from_mgt_cny := (SELECT `is_message_from_mgt_cny` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @is_message_from_contractor := (SELECT `is_message_from_contractor` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);

		# - Inspection Reports 
		SET @is_new_ir := (SELECT `is_new_ir` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);

		# - Inventory 
		SET @is_new_item := (SELECT `is_new_item` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @is_item_removed := (SELECT `is_item_removed` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @is_item_moved := (SELECT `is_item_moved` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);

	# We can now include these into the table for the Level_3 properties

			INSERT INTO `ut_map_user_permissions_unit_level_3`
				(`syst_created_datetime`
				, `creation_system_id`
				, `created_by_id`
				, `creation_method`
				, `organization_id`
				, `is_obsolete`
				, `is_update_needed`
				# Which unit/user
				, `unee_t_mefe_id`
				, `unee_t_unit_id`
				# which role
				, `unee_t_role_id`
				, `is_occupant`
				# additional permissions
				, `is_default_assignee`
				, `is_default_invited`
				, `is_unit_owner`
				# Visibility rules
				, `is_public`
				, `can_see_role_landlord`
				, `can_see_role_tenant`
				, `can_see_role_mgt_cny`
				, `can_see_role_agent`
				, `can_see_role_contractor`
				, `can_see_occupant`
				# Notification rules
				# - case - information
				, `is_assigned_to_case`
				, `is_invited_to_case`
				, `is_next_step_updated`
				, `is_deadline_updated`
				, `is_solution_updated`
				, `is_case_resolved`
				, `is_case_blocker`
				, `is_case_critical`
				# - case - messages
				, `is_any_new_message`
				, `is_message_from_tenant`
				, `is_message_from_ll`
				, `is_message_from_occupant`
				, `is_message_from_agent`
				, `is_message_from_mgt_cny`
				, `is_message_from_contractor`
				# - Inspection Reports
				, `is_new_ir`
				# - Inventory
				, `is_new_item`
				, `is_item_removed`
				, `is_item_moved`
				)
				VALUES
					(@syst_created_datetime_add_u_l3_1
					, @creation_system_id_add_u_l3_1
					, @creator_mefe_user_id_add_u_l3_1
					, @creation_method_add_u_l3_1
					, @organization_id_add_u_l3_1
					, @is_obsolete_id_add_u_l3_1
					, @is_update_needed_add_u_l3_1
					# Which unit/user
					, @unee_t_mefe_user_id_add_u_l3_1
					, @unee_t_mefe_unit_id_add_u_l3_1
					# which role
					, @unee_t_role_id_add_u_l3_1
					, @is_occupant
					# additional permissions
					, @is_default_assignee
					, @is_default_invited
					, @is_unit_owner
					# Visibility rules
					, @is_public
					, @can_see_role_landlord
					, @can_see_role_tenant
					, @can_see_role_mgt_cny
					, @can_see_role_agent
					, @can_see_role_contractor
					, @can_see_occupant
					# Notification rules
					# - case - information
					, @is_assigned_to_case
					, @is_invited_to_case
					, @is_next_step_updated
					, @is_deadline_updated
					, @is_solution_updated
					, @is_case_resolved
					, @is_case_blocker
					, @is_case_critical
					# - case - messages
					, @is_any_new_message
					, @is_message_from_tenant
					, @is_message_from_ll
					, @is_message_from_occupant
					, @is_message_from_agent
					, @is_message_from_mgt_cny
					, @is_message_from_contractor
					# - Inspection Reports
					, @is_new_ir
					# - Inventory
					, @is_new_item
					, @is_item_removed
					, @is_item_moved
					)
				ON DUPLICATE KEY UPDATE
					`syst_updated_datetime` := @syst_updated_datetime_add_u_l3_1
					, `update_system_id` := @update_system_id_add_u_l3_1
					, `updated_by_id` := @creator_mefe_user_id_add_u_l3_1
					, `update_method` := @update_method_add_u_l3_1
					, `organization_id` := @organization_id_add_u_l3_1
					, `is_obsolete` := @is_obsolete_add_u_l3_1
					, `is_update_needed` := @is_update_needed_add_u_l3_1
					# Which unit/user
					, `unee_t_mefe_id` := @unee_t_mefe_user_id_add_u_l3_1
					, `unee_t_unit_id` := @unee_t_mefe_unit_id_add_u_l3_1
					# which role
					, `unee_t_role_id` := @unee_t_role_id_add_u_l3_1
					, `is_occupant` := @is_occupant
					# additional permissions
					, `is_default_assignee` := @is_default_assignee
					, `is_default_invited` := @is_default_invited
					, `is_unit_owner` := @is_unit_owner
					# Visibility rules
					, `is_public` := @is_public
					, `can_see_role_landlord` := @can_see_role_landlord
					, `can_see_role_tenant` := @can_see_role_tenant
					, `can_see_role_mgt_cny` := @can_see_role_mgt_cny
					, `can_see_role_agent` := @can_see_role_agent
					, `can_see_role_contractor` := @can_see_role_contractor
					, `can_see_occupant` := @can_see_occupant
					# Notification rules
					# - case - information
					, `is_assigned_to_case` := @is_assigned_to_case
					, `is_invited_to_case` := @is_invited_to_case
					, `is_next_step_updated` := @is_next_step_updated
					, `is_deadline_updated` := @is_deadline_updated
					, `is_solution_updated` := @is_solution_updated
					, `is_case_resolved` := @is_case_resolved
					, `is_case_blocker` := @is_case_blocker
					, `is_case_critical` := @is_case_critical
					# - case - messages
					, `is_any_new_message` := @is_any_new_message
					, `is_message_from_tenant` := @is_message_from_tenant
					, `is_message_from_ll` := @is_message_from_ll
					, `is_message_from_occupant` := @is_message_from_occupant
					, `is_message_from_agent` := @is_message_from_agent
					, `is_message_from_mgt_cny` := @is_message_from_mgt_cny
					, `is_message_from_contractor` := @is_message_from_contractor
					# - Inspection Reports
					, `is_new_ir` := @is_new_ir
					# - Inventory
					, `is_new_item` := @is_new_item
					, `is_item_removed` := @is_item_removed
					, `is_item_moved` := @is_item_moved
					;

	# We can now include these into the table that triggers the lambda

		INSERT INTO `ut_map_user_permissions_unit_all`
			(`syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `creation_method`
			, `organization_id`
			, `is_obsolete`
			, `is_update_needed`
			# Which unit/user
			, `unee_t_mefe_id`
			, `unee_t_unit_id`
			# which role
			, `unee_t_role_id`
			, `is_occupant`
			# additional permissions
			, `is_default_assignee`
			, `is_default_invited`
			, `is_unit_owner`
			# Visibility rules
			, `is_public`
			, `can_see_role_landlord`
			, `can_see_role_tenant`
			, `can_see_role_mgt_cny`
			, `can_see_role_agent`
			, `can_see_role_contractor`
			, `can_see_occupant`
			# Notification rules
			# - case - information
			, `is_assigned_to_case`
			, `is_invited_to_case`
			, `is_next_step_updated`
			, `is_deadline_updated`
			, `is_solution_updated`
			, `is_case_resolved`
			, `is_case_blocker`
			, `is_case_critical`
			# - case - messages
			, `is_any_new_message`
			, `is_message_from_tenant`
			, `is_message_from_ll`
			, `is_message_from_occupant`
			, `is_message_from_agent`
			, `is_message_from_mgt_cny`
			, `is_message_from_contractor`
			# - Inspection Reports
			, `is_new_ir`
			# - Inventory
			, `is_new_item`
			, `is_item_removed`
			, `is_item_moved`
			)
			VALUES
				(@syst_created_datetime_add_u_l3_1
				, @creation_system_id_add_u_l3_1
				, @creator_mefe_user_id_add_u_l3_1
				, @creation_method_add_u_l3_1
				, @organization_id_add_u_l3_1
				, @is_obsolete
				, @is_update_needed_add_u_l3_1
				# Which unit/user
				, @unee_t_mefe_user_id_add_u_l3_1
				, @unee_t_mefe_unit_id_add_u_l3_1
				# which role
				, @unee_t_role_id_add_u_l3_1
				, @is_occupant
				# additional permissions
				, @is_default_assignee
				, @is_default_invited
				, @is_unit_owner
				# Visibility rules
				, @is_public
				, @can_see_role_landlord
				, @can_see_role_tenant
				, @can_see_role_mgt_cny
				, @can_see_role_agent
				, @can_see_role_contractor
				, @can_see_occupant
				# Notification rules
				# - case - information
				, @is_assigned_to_case
				, @is_invited_to_case
				, @is_next_step_updated
				, @is_deadline_updated
				, @is_solution_updated
				, @is_case_resolved
				, @is_case_blocker
				, @is_case_critical
				# - case - messages
				, @is_any_new_message
				, @is_message_from_tenant
				, @is_message_from_ll
				, @is_message_from_occupant
				, @is_message_from_agent
				, @is_message_from_mgt_cny
				, @is_message_from_contractor
				# - Inspection Reports
				, @is_new_ir
				# - Inventory
				, @is_new_item
				, @is_item_removed
				, @is_item_moved
				)
			ON DUPLICATE KEY UPDATE
				`syst_updated_datetime` := @syst_updated_datetime_add_u_l3_1
				, `update_system_id` := @update_system_id_add_u_l3_1
				, `updated_by_id` := @creator_mefe_user_id_add_u_l3_1
				, `update_method` := @update_method_add_u_l3_1
				, `organization_id` := @organization_id_add_u_l3_1
				, `is_obsolete` := @is_obsolete
				, `is_update_needed` := 1
				, `unee_t_mefe_id` := @unee_t_mefe_user_id_add_u_l3_1
				, `unee_t_unit_id` := @unee_t_mefe_unit_id_add_u_l3_1
				, `unee_t_role_id` := @unee_t_role_id_add_u_l3_1
				, `is_occupant` := @is_occupant
				, `is_default_assignee` := @is_default_assignee
				, `is_default_invited` := @is_default_invited
				, `is_unit_owner` := @is_unit_owner
				, `is_public` := @is_public
				, `can_see_role_landlord` := @can_see_role_landlord
				, `can_see_role_tenant` := @can_see_role_tenant
				, `can_see_role_mgt_cny` := @can_see_role_mgt_cny
				, `can_see_role_agent` := @can_see_role_agent
				, `can_see_role_contractor` := @can_see_role_contractor
				, `can_see_occupant` := @can_see_occupant
				, `is_assigned_to_case` := @is_assigned_to_case
				, `is_invited_to_case` := @is_invited_to_case
				, `is_next_step_updated` := @is_next_step_updated
				, `is_deadline_updated` := @is_deadline_updated
				, `is_solution_updated` := @is_solution_updated
				, `is_case_resolved` := @is_case_resolved
				, `is_case_blocker` := @is_case_blocker
				, `is_case_critical` := @is_case_critical
				, `is_any_new_message` := @is_any_new_message
				, `is_message_from_tenant` := @is_message_from_tenant
				, `is_message_from_ll` := @is_message_from_ll
				, `is_message_from_occupant` := @is_message_from_occupant
				, `is_message_from_agent` := @is_message_from_agent
				, `is_message_from_mgt_cny` := @is_message_from_mgt_cny
				, `is_message_from_contractor` := @is_message_from_contractor
				, `is_new_ir` := @is_new_ir
				, `is_new_item` := @is_new_item
				, `is_item_removed` := @is_item_removed
				, `is_item_moved` := @is_item_moved
				;

	END IF;
END;
$$
DELIMITER ;

