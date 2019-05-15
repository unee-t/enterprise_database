#################
#
# This lists all the triggers we use 
# to add a user to a role in a unit
# Level_2 properties
# via the Unee-T Enterprise Interface
#
#################

# This script creates the following trigger:
#   - `ut_add_user_to_role_in_a_level_2_property`
#   - ``
#

# For properties Level 2 (Units)

	DROP TRIGGER IF EXISTS `ut_add_user_to_role_in_a_level_2_property`;

DELIMITER $$
CREATE TRIGGER `ut_add_user_to_role_in_a_level_2_property`
AFTER INSERT ON `external_map_user_unit_role_permissions_level_2`
FOR EACH ROW
BEGIN

# We only do this IF
#	- We have a MEFE user ID for the creator of that record
#	- We have an organization ID
#	- This is not an obsolete request
#	- We have a MEFE user ID for the user that we are adding
#	- We have a role_type
#	- We have a user_type
#	- We have a MEFE unit ID for the level 2 unit.
#	- This is done via an authorized insert method:
#		- 'Assign_Units_to_Users_Add_Page'
#		- 'Assign_Units_to_Users_Import_Page'
#		- ''
#

	SET @source_system_creator_add_u_l2_1 := NEW.`created_by_id` ;
	SET @source_system_updater_add_u_l2_1 := NEW.`updated_by_id`;

	SET @creator_mefe_user_id_add_u_l2_1 := (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator_add_u_l2_1
		)
		;

	SET @organization_id_add_u_l2_1 := NEW.`organization_id` ;

	SET @is_obsolete_add_u_l2_1 := NEW.`is_obsolete` ;

	SET @unee_t_level_2_id_add_u_l2_1 := NEW.`unee_t_level_2_id` ;

	SET @unee_t_mefe_user_id_add_u_l2_1 := NEW.`unee_t_mefe_user_id` ;
	SET @unee_t_user_type_id_add_u_l2_1 := NEW.`unee_t_user_type_id` ;
	SET @unee_t_role_id_add_u_l2_1 := NEW.`unee_t_role_id` ;

	SET @unee_t_mefe_unit_id_add_u_l2_1 := (SELECT `unee_t_mefe_unit_id`
		FROM `ut_list_mefe_unit_id_level_2_by_area`
		WHERE `level_2_unit_id` = @unee_t_level_2_id_add_u_l2_1
		);

	SET @upstream_create_method_add_u_l2_1 := NEW.`creation_method` ;
	SET @upstream_update_method_add_u_l2_1 := NEW.`update_method` ;

	IF @source_system_creator_add_u_l2_1 IS NOT NULL
		AND @organization_id_add_u_l2_1 IS NOT NULL
		AND @is_obsolete_add_u_l2_1 = 0
		AND @unee_t_mefe_user_id_add_u_l2_1 IS NOT NULL
		AND @unee_t_user_type_id_add_u_l2_1 IS NOT NULL
		AND @unee_t_role_id_add_u_l2_1 IS NOT NULL
		AND @unee_t_mefe_unit_id_add_u_l2_1 IS NOT NULL
		AND (@upstream_create_method_add_u_l2_1 = 'Assign_Units_to_Users_Add_Page'
			OR @upstream_update_method_add_u_l2_1 = 'Assign_Units_to_Users_Add_Page'
			OR @upstream_create_method_add_u_l2_1 = 'Assign_Units_to_Users_Import_Page'
			OR @upstream_update_method_add_u_l2_1 = 'Assign_Units_to_Users_Import_Page'
			)
	THEN 

	# We capture the variables that we need:

		SET @this_trigger_add_u_l2_1 := 'ut_add_user_to_role_in_a_level_2_property' ;

		SET @syst_created_datetime_add_u_l2_1 := NOW() ;
		SET @creation_system_id_add_u_l2_1 := 2 ;
		SET @created_by_id_add_u_l2_1 := @source_system_creator_add_u_l2_1 ;
		SET @creation_method_add_u_l2_1 := @this_trigger_add_u_l2_1 ;

		SET @syst_updated_datetime_add_u_l2_1 := NOW() ;
		SET @update_system_id_add_u_l2_1 := 2 ;
		SET @updated_by_id_add_u_l2_1 := @source_system_updater_add_u_l2_1 ;
		SET @update_method_add_u_l2_1 := @this_trigger_add_u_l2_1 ;

		SET @is_obsolete_add_u_l2_1 := NEW.`is_obsolete` ;
		SET @is_update_needed_add_u_l2_1 := 1 ;

		SET @propagate_to_all_level_3 := NEW.`propagate_level_3` ;

	# We insert these permissions in the table `ut_map_user_permissions_unit_level_2`
	# We need the values for each of the preferences

		SET @is_occupant := (SELECT `is_occupant` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l2_1
			);

		# additional permissions 
		SET @is_default_assignee := (SELECT `is_default_assignee` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l2_1
			);
		SET @is_default_invited := (SELECT `is_default_invited` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l2_1
			);
		SET @is_unit_owner := (SELECT `is_unit_owner` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l2_1
			);

		# Visibility rules 
		SET @is_public := (SELECT `is_public` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l2_1
			);
		SET @can_see_role_landlord := (SELECT `can_see_role_landlord` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l2_1
			);
		SET @can_see_role_tenant := (SELECT `can_see_role_tenant` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l2_1
			);
		SET @can_see_role_mgt_cny := (SELECT `can_see_role_mgt_cny` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l2_1
			);
		SET @can_see_role_agent := (SELECT `can_see_role_agent` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l2_1
			);
		SET @can_see_role_contractor := (SELECT `can_see_role_contractor` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l2_1
			);
		SET @can_see_occupant := (SELECT `can_see_occupant` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l2_1
			);

		# Notification rules 
		# - case - information 
		SET @is_assigned_to_case := (SELECT `is_assigned_to_case` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l2_1
			);
		SET @is_invited_to_case := (SELECT `is_invited_to_case` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l2_1
			);
		SET @is_next_step_updated := (SELECT `is_next_step_updated` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l2_1
			);
		SET @is_deadline_updated := (SELECT `is_deadline_updated` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l2_1
			);
		SET @is_solution_updated := (SELECT `is_solution_updated` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l2_1
			);
		SET @is_case_resolved := (SELECT `is_case_resolved` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l2_1
			);
		SET @is_case_blocker := (SELECT `is_case_blocker` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l2_1
			);
		SET @is_case_critical := (SELECT `is_case_critical` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l2_1
			);

		# - case - messages 
		SET @is_any_new_message := (SELECT `is_any_new_message` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l2_1
			);
		SET @is_message_from_tenant := (SELECT `is_message_from_tenant` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l2_1
			);
		SET @is_message_from_ll := (SELECT `is_message_from_ll` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l2_1
			);
		SET @is_message_from_occupant := (SELECT `is_message_from_occupant` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l2_1
			);
		SET @is_message_from_agent := (SELECT `is_message_from_agent` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l2_1
			);
		SET @is_message_from_mgt_cny := (SELECT `is_message_from_mgt_cny` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l2_1
			);
		SET @is_message_from_contractor := (SELECT `is_message_from_contractor` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l2_1
			);

		# - Inspection Reports 
		SET @is_new_ir := (SELECT `is_new_ir` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l2_1
			);

		# - Inventory 
		SET @is_new_item := (SELECT `is_new_item` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l2_1
			);
		SET @is_item_removed := (SELECT `is_item_removed` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l2_1
			);
		SET @is_item_moved := (SELECT `is_item_moved` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l2_1
			);

	# We can now include these into the table for the Level_2 properties

			INSERT INTO `ut_map_user_permissions_unit_level_2`
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
				, `propagate_to_all_level_3`
				)
				VALUES
					(@syst_created_datetime_add_u_l2_1
					, @creation_system_id_add_u_l2_1
					, @creator_mefe_user_id_add_u_l2_1
					, @creation_method_add_u_l2_1
					, @organization_id_add_u_l2_1
					, @is_obsolete_add_u_l2_1
					, @is_update_needed_add_u_l2_1
					# Which unit/user
					, @unee_t_mefe_user_id_add_u_l2_1
					, @unee_t_mefe_unit_id_add_u_l2_1
					# which role
					, @unee_t_role_id_add_u_l2_1
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
					, @propagate_to_all_level_3
					)
				ON DUPLICATE KEY UPDATE
					`syst_updated_datetime` := @syst_updated_datetime_add_u_l2_1
					, `update_system_id` := @update_system_id_add_u_l2_1
					, `updated_by_id` := @creator_mefe_user_id_add_u_l2_1
					, `update_method` := @update_method_add_u_l2_1
					, `organization_id` := @organization_id_add_u_l2_1
					, `is_obsolete` := @is_obsolete_add_u_l2_1
					, `is_update_needed` := @is_update_needed_add_u_l2_1
					# Which unit/user
					, `unee_t_mefe_id` := @unee_t_mefe_user_id_add_u_l2_1
					, `unee_t_unit_id` := @unee_t_mefe_unit_id_add_u_l2_1
					# which role
					, `unee_t_role_id` := @unee_t_role_id_add_u_l2_1
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
				(@syst_created_datetime_add_u_l2_1
				, @creation_system_id_add_u_l2_1
				, @creator_mefe_user_id_add_u_l2_1
				, @creation_method_add_u_l2_1
				, @organization_id_add_u_l2_1
				, @is_obsolete_add_u_l2_1
				, @is_update_needed_add_u_l2_1
				# Which unit/user
				, @unee_t_mefe_user_id_add_u_l2_1
				, @unee_t_mefe_unit_id_add_u_l2_1
				# which role
				, @unee_t_role_id_add_u_l2_1
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
					`syst_updated_datetime` := @syst_updated_datetime_add_u_l2_1
					, `update_system_id` := @update_system_id_add_u_l2_1
					, `updated_by_id` := @creator_mefe_user_id_add_u_l2_1
					, `update_method` := @update_method_add_u_l2_1
					, `organization_id` := @organization_id_add_u_l2_1
					, `is_obsolete` := @is_obsolete_add_u_l2_1
					, `is_update_needed` := @is_update_needed_add_u_l2_1
					, `unee_t_mefe_id` := @unee_t_mefe_user_id_add_u_l2_1
					, `unee_t_unit_id` := @unee_t_mefe_unit_id_add_u_l2_1
					, `unee_t_role_id` := @unee_t_role_id_add_u_l2_1
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

	# Propagate to Level 3

		# We only do this IF
		#	- We need to propagate to level 3 units

		IF @propagate_to_all_level_3 = 1
		THEN 

		# We create a temporary table to store all the rooms we need to assign

			DROP TEMPORARY TABLE IF EXISTS `temp_user_unit_role_permissions_level_3`;

			CREATE TEMPORARY TABLE `temp_user_unit_role_permissions_level_3` (
				`id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique ID in this table',
				`syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
				`creation_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'What is the id of the sytem that was used for the creation of the record?',
				`created_by_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
				`creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
				`organization_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
				`is_obsolete` tinyint(1) DEFAULT 0 COMMENT 'is this obsolete?',
				`is_update_needed` tinyint(1) DEFAULT 0 COMMENT '1 if Unee-T needs to be updated',
				`unee_t_mefe_user_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The current Unee-T profile id of the person - this is the value of the field `_id` in the Mongo Collection `users`',
				`unee_t_level_3_id` int(11) NOT NULL COMMENT 'A FK to the table `property_level_3_rooms`',
				`external_unee_t_level_3_id` int(11) NOT NULL COMMENT 'A FK to the table `external_property_level_3_rooms`',
				`unee_t_user_type_id` int(11) NOT NULL COMMENT 'A FK to the table `ut_user_types`',
				`unee_t_role_id` mediumint(9) unsigned DEFAULT NULL COMMENT 'FK to the Unee-T BZFE table `ut_role_types` - ID of the Role for this user.',
				PRIMARY KEY (`unee_t_mefe_user_id`,`unee_t_user_type_id`,`unee_t_level_3_id`,`organization_id`),
				UNIQUE KEY `unique_id_map_user_unit_role_permissions_rooms` (`id`)
			) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci
			;

		# We insert these in the table `temp_user_unit_role_permissions_level_3` 

			INSERT INTO `temp_user_unit_role_permissions_level_3`
				(`syst_created_datetime`
				, `creation_system_id`
				, `created_by_id`
				, `creation_method`
				, `organization_id`
				, `is_obsolete`
				, `is_update_needed`
				, `unee_t_mefe_user_id`
				, `unee_t_level_3_id`
				, `external_unee_t_level_3_id`
				, `unee_t_user_type_id`
				, `unee_t_role_id`
				)
				SELECT 
					@syst_created_datetime_add_u_l2_1
					, @creation_system_id_add_u_l2_1
					, @source_system_creator_add_u_l2_1
					, @creation_method_add_u_l2_1
					, @organization_id_add_u_l2_1
					, @is_obsolete_add_u_l2_1
					, @is_update_needed_add_u_l2_1
					, @unee_t_mefe_user_id_add_u_l2_1
					, `b`.`level_3_room_id`
					, `b`.`external_level_3_room_id`
					, @unee_t_user_type_id_add_u_l2_1
					, @unee_t_role_id_add_u_l2_1
					FROM `property_level_3_rooms` AS `a`
					INNER JOIN `ut_list_mefe_unit_id_level_3_by_area` AS `b`
						ON (`b`.`level_2_unit_id` = `a`. `system_id_unit`)
					WHERE `b`.`level_2_unit_id` = @unee_t_level_2_id_add_u_l2_1
					GROUP BY `b`.`level_3_room_id`
				;

		# We insert the data we need in the table `external_map_user_unit_role_permissions_level_3` 

			INSERT INTO `external_map_user_unit_role_permissions_level_3`
				(`syst_created_datetime`
				, `creation_system_id`
				, `created_by_id`
				, `creation_method`
				, `organization_id`
				, `is_obsolete`
				, `is_update_needed`
				, `unee_t_mefe_user_id`
				, `unee_t_level_3_id`
				, `unee_t_user_type_id`
				, `unee_t_role_id`
				)
				SELECT 
					`syst_created_datetime`
					, `creation_system_id`
					, `created_by_id`
					, `creation_method`
					, `organization_id`
					, `is_obsolete`
					, `is_update_needed`
					, `unee_t_mefe_user_id`
					, `unee_t_level_3_id`
					, `unee_t_user_type_id`
					, `unee_t_role_id`
					FROM `temp_user_unit_role_permissions_level_3` as `a`
				ON DUPLICATE KEY UPDATE
					`syst_updated_datetime` := `a`.`syst_created_datetime`
					, `update_system_id` := `a`.`creation_system_id`
					, `updated_by_id` := `a`.`created_by_id`
					, `update_method` := `a`.`creation_method`
					, `organization_id` := `a`.`organization_id`
					, `is_obsolete` := `a`.`is_obsolete`
					, `is_update_needed` := `a`.`is_update_needed`
					, `unee_t_mefe_user_id` := `a`.`unee_t_mefe_user_id`
					, `unee_t_level_3_id` := `a`.`unee_t_level_3_id`
					, `unee_t_user_type_id` := `a`.`unee_t_user_type_id`
					, `unee_t_role_id` := `a`.`unee_t_role_id`
				;

		# We insert these in the table `ut_map_user_permissions_unit_level_3` 

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
						SELECT
							@syst_created_datetime_add_u_l2_1
							, @creation_system_id_add_u_l2_1
							, @creator_mefe_user_id_add_u_l2_1
							, @creation_method_add_u_l2_1
							, @organization_id_add_u_l2_1
							, @is_obsolete_add_u_l2_1
							, @is_update_needed_add_u_l2_1
							# Which unit/user
							, @unee_t_mefe_user_id_add_u_l2_1
							, `b`.`unee_t_mefe_unit_id`
							# which role
							, @unee_t_role_id_add_u_l2_1
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
							FROM `temp_user_unit_role_permissions_level_3` AS `a`
							INNER JOIN `ut_list_mefe_unit_id_level_3_by_area` AS `b`
								ON (`b`.`level_3_room_id` = `a`.`unee_t_level_3_id`)
						ON DUPLICATE KEY UPDATE
							`syst_updated_datetime` := @syst_created_datetime_add_u_l2_1
							, `update_system_id` := @creation_system_id_add_u_l2_1
							, `updated_by_id` := @creator_mefe_user_id_add_u_l2_1
							, `update_method` := @creation_method_add_u_l2_1
							, `organization_id` := @organization_id_add_u_l2_1
							, `is_obsolete` := @is_obsolete_add_u_l2_1
							, `is_update_needed` := @is_update_needed_add_u_l2_1
							# Which unit/user
							, `unee_t_mefe_id` := @unee_t_mefe_user_id_add_u_l2_1
							, `unee_t_unit_id` := `b`.`unee_t_mefe_unit_id`
							# which role
							, `unee_t_role_id` := @unee_t_role_id_add_u_l2_1
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
					, `unee_t_mefe_id`
					, `unee_t_unit_id`
					, `unee_t_role_id`
					, `is_occupant`
					, `is_default_assignee`
					, `is_default_invited`
					, `is_unit_owner`
					, `is_public`
					, `can_see_role_landlord`
					, `can_see_role_tenant`
					, `can_see_role_mgt_cny`
					, `can_see_role_agent`
					, `can_see_role_contractor`
					, `can_see_occupant`
					, `is_assigned_to_case`
					, `is_invited_to_case`
					, `is_next_step_updated`
					, `is_deadline_updated`
					, `is_solution_updated`
					, `is_case_resolved`
					, `is_case_blocker`
					, `is_case_critical`
					, `is_any_new_message`
					, `is_message_from_tenant`
					, `is_message_from_ll`
					, `is_message_from_occupant`
					, `is_message_from_agent`
					, `is_message_from_mgt_cny`
					, `is_message_from_contractor`
					, `is_new_ir`
					, `is_new_item`
					, `is_item_removed`
					, `is_item_moved`
					)
						SELECT
							`a`.`syst_created_datetime`
							, `a`.`creation_system_id`
							, @creator_mefe_user_id_add_u_l2_1
							, `a`.`creation_method`
							, `a`.`organization_id`
							, `a`.`is_obsolete`
							, `a`.`is_update_needed`
							# Which unit/user
							, `a`.`unee_t_mefe_user_id`
							, `b`.`unee_t_mefe_unit_id`
							# which role
							, @unee_t_role_id_add_u_l2_1
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
							FROM `temp_user_unit_role_permissions_level_3` AS `a`
							INNER JOIN `ut_list_mefe_unit_id_level_3_by_area` AS `b`
								ON (`b`.`level_3_room_id` = `a`.`unee_t_level_3_id`)
						ON DUPLICATE KEY UPDATE
							`syst_updated_datetime` := `a`.`syst_created_datetime`
							, `update_system_id` := `a`.`creation_system_id`
							, `updated_by_id` := @creator_mefe_user_id_add_u_l2_1
							, `update_method` := `a`.`creation_method`
							, `organization_id` := `a`.`organization_id`
							, `is_obsolete` := `a`.`is_obsolete`
							, `is_update_needed` := `a`.`is_update_needed`
							, `unee_t_mefe_id` := @unee_t_mefe_user_id_add_u_l2_1
							, `unee_t_unit_id` := `b`.`unee_t_mefe_unit_id`
							, `unee_t_role_id` := @unee_t_role_id_add_u_l2_1
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

	END IF;
END;
$$
DELIMITER ;