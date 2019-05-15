#################
#
# This lists all the triggers we use 
# to add a user to a role in a unit
# All Level_1 properties in an Area
# via the Unee-T Enterprise Interface
#
#################

# Assign user to an Area based on the units level_1 (buildings in that area):
# Insert the record in the tables
#	- `ut_map_user_permissions_unit_level_1`

			DROP TRIGGER IF EXISTS `ut_add_user_to_role_in_all_buildings_in_area`;

DELIMITER $$
CREATE TRIGGER `ut_add_user_to_role_in_all_buildings_in_area`
AFTER INSERT ON `external_map_user_unit_role_permissions_areas`
FOR EACH ROW
BEGIN

# We only do this IF
#	- We have a MEFE user ID for the creator of that record
#	- This is not an obsolete request
#	- We have a MEFE user ID for the user that we are adding
#	- We have an area ID for that area.
#	- We have a role_type
#	- We have a user_type
#	- This is done via an authorized insert method:
#		- 'Assign_Areas_to_Users_Add_Page'
#		- 'Assign_Areas_to_Users_Import_Page'
#		- ''
#		- ''
#		- ''
#

	SET @source_system_creator = NEW.`created_by_id` ;
	SET @source_system_updater = NEW.`updated_by_id`;

	SET @creator_mefe_user_id = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator
		)
		;

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;

	SET @organization_id = NEW.`organization_id` ;

	SET @is_obsolete = NEW.`is_obsolete` ;

	SET @area_id = NEW.`unee_t_area_id` ;

	SET @unee_t_mefe_user_id = NEW.`unee_t_mefe_user_id` ;
	SET @unee_t_user_type_id = NEW.`unee_t_user_type_id` ;
	SET @unee_t_role_id = NEW.`unee_t_role_id` ;

	IF @source_system_creator IS NOT NULL
		AND @is_obsolete = 0
		AND @area_id IS NOT NULL
		AND @unee_t_mefe_user_id IS NOT NULL
		AND @unee_t_user_type_id IS NOT NULL
		AND @unee_t_role_id IS NOT NULL
		AND (@upstream_create_method = 'Assign_Areas_to_Users_Add_Page'
			OR @upstream_update_method = 'Assign_Areas_to_Users_Add_Page'
			OR @upstream_create_method = 'Assign_Areas_to_Users_Import_Page'
			OR @upstream_update_method = 'Assign_Areas_to_Users_Import_Page'
			)
	THEN 

	# We capture the variables that we need:

		SET @this_trigger = 'ut_add_user_to_role_in_all_buildings_in_area' ;

		SET @syst_created_datetime = NOW() ;
		SET @creation_system_id = 2 ;
		SET @created_by_id = @source_system_creator ;
		SET @creation_method = @this_trigger ;

		SET @syst_updated_datetime = NOW() ;
		SET @update_system_id = 2 ;
		SET @updated_by_id = @source_system_updater ;
		SET @update_method = @this_trigger ;

		SET @organization_id = NEW.`organization_id`;

		SET @is_obsolete = NEW.`is_obsolete` ;
		SET @is_update_needed = 1 ;

		SET @area_external_id = (SELECT `external_id`
			FROM `property_groups_areas`
			WHERE `id_area` = @area_id
			);
		SET @area_external_system_id = (SELECT `external_system_id`
			FROM `property_groups_areas`
			WHERE `id_area` = @area_id
			);
		SET @area_external_table = (SELECT `external_table`
			FROM `property_groups_areas`
			WHERE `id_area` = @area_id
			);

		SET @area_id_external_table = (SELECT `id_area`
			FROM `external_property_groups_areas`
			WHERE `external_id` = @area_external_id
				AND `external_system_id` = @area_external_system_id
				AND `external_table` = @area_external_table
				AND `created_by_id` = @organization_id
			);

		SET @propagate_to_all_level_2 = NEW.`propagate_level_2` ;
		SET @propagate_to_all_level_3 = NEW.`propagate_level_3` ;

	# We include these into the table `external_map_user_unit_role_permissions_level_1`
	# for the Level_1 properties (Building)

		INSERT INTO `external_map_user_unit_role_permissions_level_1`
			(`syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `creation_method`
			, `organization_id`
			, `is_obsolete`
			, `is_update_needed`
			# Which unit/user
			, `unee_t_mefe_user_id`
			, `unee_t_level_1_id`
			# Which type of Unee-T user
			, `unee_t_user_type_id`
			# which role
			, `unee_t_role_id`
			, `propagate_level_2`
			, `propagate_level_3`
			)
			SELECT
				@syst_created_datetime
				, @creation_system_id
				, @source_system_creator
				, @creation_method
				, @organization_id
				, @is_obsolete
				, @is_update_needed
				# Which unit/user
				, @unee_t_mefe_user_id
				, `level_1_building_id`
				# Which type of Unee-T user
				, @unee_t_user_type_id
				# which role
				, @unee_t_role_id
				, @propagate_to_all_level_2
				, @propagate_to_all_level_3
				FROM `ut_list_mefe_unit_id_level_1_by_area`
				WHERE 
					`id_area` = @area_id
				GROUP BY `level_1_building_id`
				;

		# We insert the property level 1 to the table `ut_map_user_permissions_unit_level_1`

	# We need the MEFE unit_id for each of the buildings:

		SET @unee_t_mefe_unit_id = (SELECT `unee_t_mefe_unit_id`
			FROM `ut_list_mefe_unit_id_level_1_by_area`
			WHERE `level_1_building_id` = @unee_t_level_1_id
			);

	# We need the values for each of the preferences

		SET @is_occupant = (SELECT `is_occupant` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id
			);

		# additional permissions 
		SET @is_default_assignee = (SELECT `is_default_assignee` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id
			);
		SET @is_default_invited = (SELECT `is_default_invited` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id
			);
		SET @is_unit_owner = (SELECT `is_unit_owner` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id
			);

		# Visibility rules 
		SET @is_public = (SELECT `is_public` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id
			);
		SET @can_see_role_landlord = (SELECT `can_see_role_landlord` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id
			);
		SET @can_see_role_tenant = (SELECT `can_see_role_tenant` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id
			);
		SET @can_see_role_mgt_cny = (SELECT `can_see_role_mgt_cny` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id
			);
		SET @can_see_role_agent = (SELECT `can_see_role_agent` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id
			);
		SET @can_see_role_contractor = (SELECT `can_see_role_contractor` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id
			);
		SET @can_see_occupant = (SELECT `can_see_occupant` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id
			);

		# Notification rules 
		# - case - information 
		SET @is_assigned_to_case = (SELECT `is_assigned_to_case` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id
			);
		SET @is_invited_to_case = (SELECT `is_invited_to_case` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id
			);
		SET @is_next_step_updated = (SELECT `is_next_step_updated` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id
			);
		SET @is_deadline_updated = (SELECT `is_deadline_updated` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id
			);
		SET @is_solution_updated = (SELECT `is_solution_updated` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id
			);
		SET @is_case_resolved = (SELECT `is_case_resolved` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id
			);
		SET @is_case_blocker = (SELECT `is_case_blocker` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id
			);
		SET @is_case_critical = (SELECT `is_case_critical` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id
			);

		# - case - messages 
		SET @is_any_new_message = (SELECT `is_any_new_message` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id
			);
		SET @is_message_from_tenant = (SELECT `is_message_from_tenant` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id
			);
		SET @is_message_from_ll = (SELECT `is_message_from_ll` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id
			);
		SET @is_message_from_occupant = (SELECT `is_message_from_occupant` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id
			);
		SET @is_message_from_agent = (SELECT `is_message_from_agent` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id
			);
		SET @is_message_from_mgt_cny = (SELECT `is_message_from_mgt_cny` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id
			);
		SET @is_message_from_contractor = (SELECT `is_message_from_contractor` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id
			);

		# - Inspection Reports 
		SET @is_new_ir = (SELECT `is_new_ir` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id
			);

		# - Inventory 
		SET @is_new_item = (SELECT `is_new_item` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id
			);
		SET @is_item_removed = (SELECT `is_item_removed` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id
			);
		SET @is_item_moved = (SELECT `is_item_moved` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id
			);

	# We can now include these into the table for the Level_1 properties (Building)

			INSERT INTO `ut_map_user_permissions_unit_level_1`
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
				, `propagate_to_all_level_2`
				, `propagate_to_all_level_3`
				)
				SELECT
					@syst_created_datetime
					, @creation_system_id
					, @creator_mefe_user_id
					, @creation_method
					, @organization_id
					, @is_obsolete
					, @is_update_needed
					# Which unit/user
					, @unee_t_mefe_user_id
					, `unee_t_mefe_unit_id`
					# which role
					, @unee_t_role_id
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
					, @propagate_to_all_level_2
					, @propagate_to_all_level_3
				FROM `ut_list_mefe_unit_id_level_1_by_area`
				WHERE 
					`id_area` = @area_id
					GROUP BY `level_1_building_id`
					;

	END IF;
END;
$$
DELIMITER ;


