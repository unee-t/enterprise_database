#################
#	
# This is to assign ALL units in an organization to a given user
# This user must have a Unee-T user type which grants access to all units
# in his/her organization.
#
#################

	DROP PROCEDURE IF EXISTS `ut_bulk_assign_units_to_a_user`;
	
DELIMITER $$
CREATE PROCEDURE `ut_bulk_assign_units_to_a_user`()
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN

# This procedure needs the following variables:
#	- @requestor_id
#	- @person_id

	SET @mefe_user_id_assignee_bulk := (SELECT `unee_t_mefe_user_id`
		FROM `ut_map_external_source_users`
		WHERE `person_id` = @person_id
		) 
		;

	SET @person_id_bulk_assign := @person_id ;

	SET @organization_id_bulk_assign := (SELECT `organization_id` 
		FROM `ut_map_external_source_users`
		WHERE `unee_t_mefe_user_id` = @mefe_user_id_assignee_bulk
		)
		;

	SET @unee_t_user_type_id_bulk_assign := (SELECT `unee_t_user_type_id`
		FROM `persons`
		WHERE `id_person` = @person_id_bulk_assign
		);

	SET @is_all_units := (SELECT `is_all_unit`
		FROM `ut_user_types`
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);

	SET @is_all_units_in_country := (SELECT `is_all_units_in_country`
		FROM `ut_user_types`
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);

	SET @person_country := (SELECT `country_code`
		FROM `persons`
		WHERE `id_person` = @person_id_bulk_assign
		);

	SET @created_by_id := @organization_id_bulk_assign ;

	# We get the variables we need:

		SET @syst_created_datetime_bulk_assign := NOW() ;
		SET @creation_system_id_bulk_assign := 2 ;
		SET @created_by_id_bulk_assign := @requestor_id ;
		SET @creation_method_bulk_assign := 'ut_bulk_assign_units_to_a_user' ;

		SET @syst_updated_datetime_bulk_assign := NOW() ;
		SET @update_system_id_bulk_assign := 2 ;
		SET @updated_by_id_bulk_assign := @created_by_id_bulk_assign ;
		SET @update_method_bulk_assign := @creation_method_bulk_assign ;

		SET @is_obsolete_bulk_assign = 0 ;
		SET @is_update_needed_bulk_assign = 1 ;

		SET @unee_t_role_id_bulk_assign := (SELECT `ut_user_role_type_id`
		FROM `ut_user_types`
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);

		SET @is_occupant := (SELECT `is_occupant` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);

		SET @propagate_to_all_level_2 = 1 ;
		SET @propagate_to_all_level_3 = 1 ;

		# additional permissions 
		SET @is_default_assignee := (SELECT `is_default_assignee` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @is_default_invited := (SELECT `is_default_invited` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @is_unit_owner := (SELECT `is_unit_owner` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);

		# Visibility rules 
		SET @is_public := (SELECT `is_public` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @can_see_role_landlord := (SELECT `can_see_role_landlord` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @can_see_role_tenant := (SELECT `can_see_role_tenant` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @can_see_role_mgt_cny := (SELECT `can_see_role_mgt_cny` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @can_see_role_agent := (SELECT `can_see_role_agent` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @can_see_role_contractor := (SELECT `can_see_role_contractor` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @can_see_occupant := (SELECT `can_see_occupant` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);

		# Notification rules 
		# - case - information 
		SET @is_assigned_to_case := (SELECT `is_assigned_to_case` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @is_invited_to_case := (SELECT `is_invited_to_case` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @is_next_step_updated := (SELECT `is_next_step_updated` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @is_deadline_updated := (SELECT `is_deadline_updated` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @is_solution_updated := (SELECT `is_solution_updated` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @is_case_resolved := (SELECT `is_case_resolved` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @is_case_blocker := (SELECT `is_case_blocker` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @is_case_critical := (SELECT `is_case_critical` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);

		# - case - messages 
		SET @is_any_new_message := (SELECT `is_any_new_message` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @is_message_from_tenant := (SELECT `is_message_from_tenant` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @is_message_from_ll := (SELECT `is_message_from_ll` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @is_message_from_occupant := (SELECT `is_message_from_occupant` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @is_message_from_agent := (SELECT `is_message_from_agent` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @is_message_from_mgt_cny := (SELECT `is_message_from_mgt_cny` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @is_message_from_contractor := (SELECT `is_message_from_contractor` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);

		# - Inspection Reports 
		SET @is_new_ir := (SELECT `is_new_ir` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);

		# - Inventory 
		SET @is_new_item := (SELECT `is_new_item` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @is_item_removed := (SELECT `is_item_removed` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @is_item_moved := (SELECT `is_item_moved` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);

# If the user needs to be assigned to ALL the units in all the countries in that organization

	IF @is_all_units = 1
		AND @mefe_user_id_assignee_bulk IS NOT NULL
		AND @requestor_id IS NOT NULL
	THEN 

	# Propagate to Level 1 units

		# We create a temporary table to store all the units we need to assign

		DROP TEMPORARY TABLE IF EXISTS `temp_user_unit_role_permissions_level_1`;

		CREATE TEMPORARY TABLE `temp_user_unit_role_permissions_level_1` (
			`id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique ID in this table',
			`syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
			`creation_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'What is the id of the sytem that was used for the creation of the record?',
			`created_by_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
			`created_by_id_associated_mefe_user` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The MEFE user_id associated with this organization',
			`creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
			`organization_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
			`is_obsolete` tinyint(1) DEFAULT 0 COMMENT 'is this obsolete?',
			`is_update_needed` tinyint(1) DEFAULT 0 COMMENT '1 if Unee-T needs to be updated',
			`unee_t_mefe_user_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The current Unee-T profile id of the person - this is the value of the field `_id` in the Mongo Collection `users`',
			`unee_t_level_1_id` int(11) NOT NULL COMMENT 'A FK to the table `property_level_1_buildings`',
			`external_unee_t_level_1_id` int(11) NOT NULL COMMENT '...',
			`unee_t_mefe_unit_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The MEFE unit_id for the property',
			`unee_t_user_type_id` int(11) NOT NULL COMMENT 'A FK to the table `ut_user_types`',
			`unee_t_role_id` mediumint(9) unsigned DEFAULT NULL COMMENT 'FK to the Unee-T BZFE table `ut_role_types` - ID of the Role for this user.',
			PRIMARY KEY (`unee_t_mefe_user_id`,`unee_t_user_type_id`,`unee_t_level_1_id`,`organization_id`),
			UNIQUE KEY `unique_id_map_user_unit_role_permissions_buildings` (`id`)
		) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci
		;

		# We need all the buildings in that organization
		#	- The id of the organization is in the variable @organization_id_bulk_assign
		#	- The ids of the buildings are in the view `ut_list_mefe_unit_id_level_1_by_area`
		# We need to insert all these data in the table `temp_user_unit_role_permissions_level_3`

		SET @created_by_id := @organization_id_bulk_assign ;

		INSERT INTO `temp_user_unit_role_permissions_level_1`
			(`syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `created_by_id_associated_mefe_user`
			, `creation_method`
			, `organization_id`
			, `is_obsolete`
			, `is_update_needed`
			, `unee_t_mefe_user_id`
			, `unee_t_level_1_id`
			, `external_unee_t_level_1_id`
			, `unee_t_mefe_unit_id`
			, `unee_t_user_type_id`
			, `unee_t_role_id`
			)
			SELECT @syst_created_datetime_bulk_assign
			, @creation_system_id_bulk_assign
			, @created_by_id
			, @created_by_id_bulk_assign
			, @creation_method_bulk_assign
			, @organization_id_bulk_assign
			, @is_obsolete_bulk_assign
			, @is_update_needed_bulk_assign
			, @mefe_user_id_assignee_bulk
			, `a`.`level_1_building_id`
			, `a`.`external_level_1_building_id`
			, `a`.`unee_t_mefe_unit_id`
			, @unee_t_user_type_id_bulk_assign
			, @unee_t_role_id_bulk_assign
			FROM `ut_list_mefe_unit_id_level_1_by_area` AS `a`
			WHERE `a`.`organization_id` = @organization_id_bulk_assign
				AND `a`.`is_obsolete` = 0
			GROUP BY `a`.`level_1_building_id`
			;

		# We can now include these into the "external" table for the Level_1 properties (Buildings)

		INSERT INTO `external_map_user_unit_role_permissions_level_1`
			(`syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `creation_method`
			, `organization_id`
			, `is_obsolete`
			, `is_update_needed`
			, `unee_t_mefe_user_id`
			, `unee_t_level_1_id`
			, `unee_t_user_type_id`
			, `unee_t_role_id`
			, `propagate_level_2`
			, `propagate_level_3`
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
			, `unee_t_level_1_id`
			, `unee_t_user_type_id`
			, `unee_t_role_id`
			, @propagate_to_all_level_2
			, @propagate_to_all_level_3
			FROM `temp_user_unit_role_permissions_level_1` as `a`
			ON DUPLICATE KEY UPDATE
			`syst_updated_datetime` := `a`.`syst_created_datetime`
			, `update_system_id` := `a`.`creation_system_id`
			, `updated_by_id` := `a`.`created_by_id`
			, `update_method` := `a`.`creation_method`
			, `organization_id` := `a`.`organization_id`
			, `is_obsolete` := `a`.`is_obsolete`
			, `is_update_needed` := `a`.`is_update_needed`
			, `unee_t_mefe_user_id` := `a`.`unee_t_mefe_user_id`
			, `unee_t_level_1_id` := `a`.`unee_t_level_1_id`
			, `unee_t_user_type_id` := `a`.`unee_t_user_type_id`
			, `unee_t_role_id` := `a`.`unee_t_role_id`
			, `propagate_level_2`:= @propagate_to_all_level_2
			, `propagate_level_3`:= @propagate_to_all_level_3
			;

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
			`a`.`syst_created_datetime`
			, `a`.`creation_system_id`
			, `a`.`created_by_id_associated_mefe_user`
			, `a`.`creation_method`
			, `a`.`organization_id`
			, `a`.`is_obsolete`
			, `a`.`is_update_needed`
			# Which unit/user
			, `a`.`unee_t_mefe_user_id`
			, `a`.`unee_t_mefe_unit_id`
			# which role
			, `a`.`unee_t_role_id`
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
			FROM `temp_user_unit_role_permissions_level_1` AS `a`
			ON DUPLICATE KEY UPDATE
			`syst_updated_datetime` := `a`.`syst_created_datetime`
			, `update_system_id` := `a`.`creation_system_id`
			, `updated_by_id` := `a`.`created_by_id_associated_mefe_user`
			, `update_method` := `a`.`creation_method`
			, `organization_id` := `a`.`organization_id`
			, `is_obsolete` := `a`.`is_obsolete`
			, `is_update_needed` := `a`.`is_update_needed`
			# Which unit/user
			, `unee_t_mefe_id` :=  `a`.`unee_t_mefe_user_id`
			, `unee_t_unit_id` := `a`.`unee_t_mefe_unit_id`
			# which role
			, `unee_t_role_id` := `a`.`unee_t_role_id`
			# additional permissions
			, `is_occupant` := @is_occupant
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
			# - case - messages
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
			# - Inspection Reports
			, `is_new_ir` := @is_new_ir
			# - Inventory
			, `is_new_item` := @is_new_item
			, `is_item_removed` := @is_item_removed
			, `is_item_moved` := @is_item_moved
			, `propagate_to_all_level_2` := @propagate_to_all_level_2
			, `propagate_to_all_level_3` := @propagate_to_all_level_3
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
			, `is_public`
			# Visibility rules
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
			# - case - messages
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
			# - Inspection Reports
			, `is_new_ir`
			# - Inventory
			, `is_new_item`
			, `is_item_removed`
			, `is_item_moved`
			)
			SELECT
			`a`.`syst_created_datetime`
			, `a`.`creation_system_id`
			, `a`.`created_by_id_associated_mefe_user`
			, `a`.`creation_method`
			, `a`.`organization_id`
			, `a`.`is_obsolete`
			, `a`.`is_update_needed`
			# Which unit/user
			, `a`.`unee_t_mefe_user_id`
			, `a`.`unee_t_mefe_unit_id`
			# which role
			, `a`.`unee_t_role_id`
			# additional permissions
			, @is_occupant
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
			FROM `temp_user_unit_role_permissions_level_1` AS `a`
			ON DUPLICATE KEY UPDATE
				`syst_updated_datetime` := `a`.`syst_created_datetime`
				, `update_system_id` := `a`.`creation_system_id`
				, `updated_by_id` := `a`.`created_by_id_associated_mefe_user`
				, `update_method` := `a`.`creation_method`
				, `organization_id` := `a`.`organization_id`
				, `is_obsolete` := `a`.`is_obsolete`
				, `is_update_needed` := `a`.`is_update_needed`
				# Which unit/user
				, `unee_t_mefe_id` = `a`.`unee_t_mefe_user_id`
				, `unee_t_unit_id` := `a`.`unee_t_mefe_unit_id`
				# which role
				, `unee_t_role_id` := `a`.`unee_t_role_id`
				# additional permissions
				, `is_occupant` := @is_occupant
				, `is_default_assignee` := @is_default_assignee
				, `is_default_invited` := @is_default_invited
				, `is_unit_owner` := @is_unit_owner
				, `is_public` := @is_public
				# Visibility rules
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
				# - case - messages
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
				# - Inspection Reports
				, `is_new_ir` := @is_new_ir
				# - Inventory
				, `is_new_item` := @is_new_item
				, `is_item_removed` := @is_item_removed
				, `is_item_moved` := @is_item_moved
				;

	# Propagate to Level 2 units

		# We create a temporary table to store all the units we need to assign

		DROP TEMPORARY TABLE IF EXISTS `temp_user_unit_role_permissions_level_2`;

		CREATE TEMPORARY TABLE `temp_user_unit_role_permissions_level_2` (
			`id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique ID in this table',
			`syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
			`creation_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'What is the id of the sytem that was used for the creation of the record?',
			`created_by_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
			`created_by_id_associated_mefe_user` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The MEFE user_id associated with this organization',
			`creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
			`organization_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
			`is_obsolete` tinyint(1) DEFAULT 0 COMMENT 'is this obsolete?',
			`is_update_needed` tinyint(1) DEFAULT 0 COMMENT '1 if Unee-T needs to be updated',
			`unee_t_mefe_user_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The current Unee-T profile id of the person - this is the value of the field `_id` in the Mongo Collection `users`',
			`unee_t_level_2_id` int(11) NOT NULL COMMENT 'A FK to the table `property_level_2_units`',
			`external_unee_t_level_2_id` int(11) NOT NULL COMMENT 'A FK to the table `property_level_2_units`',
			`unee_t_mefe_unit_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The MEFE unit_id for the property',
			`unee_t_user_type_id` int(11) NOT NULL COMMENT 'A FK to the table `ut_user_types`',
			`unee_t_role_id` mediumint(9) unsigned DEFAULT NULL COMMENT 'FK to the Unee-T BZFE table `ut_role_types` - ID of the Role for this user.',
			PRIMARY KEY (`unee_t_mefe_user_id`,`unee_t_user_type_id`,`unee_t_level_2_id`,`organization_id`),
			UNIQUE KEY `unique_id_map_user_unit_role_permissions_units` (`id`)
		) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci
		;

		# We need all the units from all the buildings in that organization
		#	- The id of the organization is in the variable @organization_id_bulk_assign
		#	- The ids of the units are in the view `ut_list_mefe_unit_id_level_2_by_area`
		# We need to insert all these data in the table `temp_user_unit_role_permissions_level_2`

		SET @created_by_id = @organization_id_bulk_assign ;

		INSERT INTO `temp_user_unit_role_permissions_level_2`
			(`syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `created_by_id_associated_mefe_user`
			, `creation_method`
			, `organization_id`
			, `is_obsolete`
			, `is_update_needed`
			, `unee_t_mefe_user_id`
			, `unee_t_level_2_id`
			, `external_unee_t_level_2_id`
			, `unee_t_mefe_unit_id`
			, `unee_t_user_type_id`
			, `unee_t_role_id`
			)
			SELECT 
			@syst_created_datetime_bulk_assign
			, @creation_system_id_bulk_assign
			, @created_by_id
			, @created_by_id_bulk_assign
			, @creation_method_bulk_assign
			, @organization_id_bulk_assign
			, @is_obsolete_bulk_assign
			, @is_update_needed_bulk_assign
			, @mefe_user_id_assignee_bulk
			, `a`.`level_2_unit_id`
			, `a`.`external_level_2_unit_id`
			, `a`.`unee_t_mefe_unit_id`
			, @unee_t_user_type_id_bulk_assign
			, @unee_t_role_id_bulk_assign
			FROM `ut_list_mefe_unit_id_level_2_by_area` AS `a`
			INNER JOIN `ut_list_mefe_unit_id_level_1_by_area` AS `b`
				ON (`a`.`level_1_building_id` = `b`.`level_1_building_id` )
			WHERE `a`.`organization_id` = @organization_id_bulk_assign
				AND `a`.`is_obsolete` = 0
			GROUP BY `a`.`level_2_unit_id`
			;

		# We insert the data we need in the table `external_map_user_unit_role_permissions_level_2` 

		INSERT INTO `external_map_user_unit_role_permissions_level_2`
			(`syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `creation_method`
			, `organization_id`
			, `is_obsolete`
			, `is_update_needed`
			, `unee_t_mefe_user_id`
			, `unee_t_level_2_id`
			, `unee_t_user_type_id`
			, `unee_t_role_id`
			, `propagate_level_3`
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
			, `unee_t_level_2_id`
			, `unee_t_user_type_id`
			, `unee_t_role_id`
			, @propagate_to_all_level_3
			FROM `temp_user_unit_role_permissions_level_2` as `a`
			ON DUPLICATE KEY UPDATE
			`syst_updated_datetime` := `a`.`syst_created_datetime`
			, `update_system_id` := `a`.`creation_system_id`
			, `updated_by_id` := `a`.`created_by_id`
			, `update_method` := `a`.`creation_method`
			, `organization_id` := `a`.`organization_id`
			, `is_obsolete` := `a`.`is_obsolete`
			, `is_update_needed` := `a`.`is_update_needed`
			, `unee_t_mefe_user_id` := `a`.`unee_t_mefe_user_id`
			, `unee_t_level_2_id` := `a`.`unee_t_level_2_id`
			, `unee_t_user_type_id` := `a`.`unee_t_user_type_id`
			, `unee_t_role_id` := `a`.`unee_t_role_id`
			, `propagate_level_3`:= @propagate_to_all_level_3
			;

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
			)
			SELECT
			`a`.`syst_created_datetime`
			, `a`.`creation_system_id`
			, `a`.`created_by_id_associated_mefe_user`
			, `a`.`creation_method`
			, `a`.`organization_id`
			, `a`.`is_obsolete`
			, `a`.`is_update_needed`
			# Which unit/user
			, `a`.`unee_t_mefe_user_id`
			, `a`.`unee_t_mefe_unit_id`
			# which role
			, `a`.`unee_t_role_id`
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
			FROM `temp_user_unit_role_permissions_level_2` AS `a`
			INNER JOIN `ut_list_mefe_unit_id_level_2_by_area` AS `b`
				ON (`b`.`level_2_unit_id` = `a`.`unee_t_level_2_id`)
			ON DUPLICATE KEY UPDATE
				`syst_updated_datetime` := `a`.`syst_created_datetime`
				, `update_system_id` := `a`.`creation_system_id`
				, `updated_by_id` := `a`.`created_by_id_associated_mefe_user`
				, `update_method` := `a`.`creation_method`
				, `organization_id` := `a`.`organization_id`
				, `is_obsolete` := `a`.`is_obsolete`
				, `is_update_needed` := `a`.`is_update_needed`
				# Which unit/user
				, `unee_t_mefe_id` = `a`.`unee_t_mefe_user_id`
				, `unee_t_unit_id` := `a`.`unee_t_mefe_unit_id`
				# which role
				, `unee_t_role_id` := `a`.`unee_t_role_id`
				# additional permissions
				, `is_occupant` := @is_occupant
				, `is_default_assignee` := @is_default_assignee
				, `is_default_invited` := @is_default_invited
				, `is_unit_owner` := @is_unit_owner
				, `is_public` := @is_public
				# Visibility rules
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
			, `is_public`
			# Visibility rules
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
			# - case - messages
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
			# - Inspection Reports
			, `is_new_ir`
			# - Inventory
			, `is_new_item`
			, `is_item_removed`
			, `is_item_moved`
			)
			SELECT
			`a`.`syst_created_datetime`
			, `a`.`creation_system_id`
			, `a`.`created_by_id_associated_mefe_user`
			, `a`.`creation_method`
			, `a`.`organization_id`
			, `a`.`is_obsolete`
			, `a`.`is_update_needed`
			# Which unit/user
			, `a`.`unee_t_mefe_user_id`
			, `a`.`unee_t_mefe_unit_id`
			# which role
			, `a`.`unee_t_role_id`
			# additional permissions
			, @is_occupant
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
			FROM `temp_user_unit_role_permissions_level_2` AS `a`
			ON DUPLICATE KEY UPDATE
				`syst_updated_datetime` := `a`.`syst_created_datetime`
				, `update_system_id` := `a`.`creation_system_id`
				, `updated_by_id` := `a`.`created_by_id_associated_mefe_user`
				, `update_method` := `a`.`creation_method`
				, `organization_id` := `a`.`organization_id`
				, `is_obsolete` := `a`.`is_obsolete`
				, `is_update_needed` := `a`.`is_update_needed`
				# Which unit/user
				, `unee_t_mefe_id` = `a`.`unee_t_mefe_user_id`
				, `unee_t_unit_id` := `a`.`unee_t_mefe_unit_id`
				# which role
				, `unee_t_role_id` := `a`.`unee_t_role_id`
				# additional permissions
				, `is_occupant` := @is_occupant
				, `is_default_assignee` := @is_default_assignee
				, `is_default_invited` := @is_default_invited
				, `is_unit_owner` := @is_unit_owner
				, `is_public` := @is_public
				# Visibility rules
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

	# Propagate to Level 3 units

		# We create a temporary table to store all the units we need to assign

		DROP TEMPORARY TABLE IF EXISTS `temp_user_unit_role_permissions_level_3`;

		CREATE TEMPORARY TABLE `temp_user_unit_role_permissions_level_3` (
			`id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique ID in this table',
			`syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
			`creation_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'What is the id of the sytem that was used for the creation of the record?',
			`created_by_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
			`created_by_id_associated_mefe_user` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The MEFE user_id associated with this organization',
			`creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
			`organization_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
			`is_obsolete` tinyint(1) DEFAULT 0 COMMENT 'is this obsolete?',
			`is_update_needed` tinyint(1) DEFAULT 0 COMMENT '1 if Unee-T needs to be updated',
			`unee_t_mefe_user_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The current Unee-T profile id of the person - this is the value of the field `_id` in the Mongo Collection `users`',
			`unee_t_level_3_id` int(11) NOT NULL COMMENT 'A FK to the table `property_level_3_rooms`',
			`external_unee_t_level_3_id` int(11) NOT NULL COMMENT '...',
			`unee_t_mefe_unit_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The MEFE unit_id for the property',
			`unee_t_user_type_id` int(11) NOT NULL COMMENT 'A FK to the table `ut_user_types`',
			`unee_t_role_id` mediumint(9) unsigned DEFAULT NULL COMMENT 'FK to the Unee-T BZFE table `ut_role_types` - ID of the Role for this user.',
			PRIMARY KEY (`unee_t_mefe_user_id`,`unee_t_user_type_id`,`unee_t_level_3_id`,`organization_id`),
			UNIQUE KEY `unique_id_map_user_unit_role_permissions_rooms` (`id`)
		) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci
		;

		# We need all the rooms from all the units in that organization
		#	- The id of the organization is in the variable @organization_id_bulk_assign
		#	- The ids of the rooms are in the view `ut_list_mefe_unit_id_level_3_by_area`
		# We need to insert all these data in the table `temp_user_unit_role_permissions_level_3`

		SET @created_by_id := @organization_id_bulk_assign ;

		INSERT INTO `temp_user_unit_role_permissions_level_3`
			(`syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `created_by_id_associated_mefe_user`
			, `creation_method`
			, `organization_id`
			, `is_obsolete`
			, `is_update_needed`
			, `unee_t_mefe_user_id`
			, `unee_t_level_3_id`
			, `external_unee_t_level_3_id`
			, `unee_t_mefe_unit_id`
			, `unee_t_user_type_id`
			, `unee_t_role_id`
			)
			SELECT 
			@syst_created_datetime_bulk_assign
			, @creation_system_id_bulk_assign
			, @created_by_id
			, @created_by_id_bulk_assign
			, @creation_method_bulk_assign
			, @organization_id_bulk_assign
			, @is_obsolete_bulk_assign
			, @is_update_needed_bulk_assign
			, @mefe_user_id_assignee_bulk
			, `a`.`level_3_room_id`
			, `a`.`external_level_3_room_id`
			, `a`.`unee_t_mefe_unit_id`
			, @unee_t_user_type_id_bulk_assign
			, @unee_t_role_id_bulk_assign
			FROM `ut_list_mefe_unit_id_level_3_by_area` AS `a`
			INNER JOIN `ut_list_mefe_unit_id_level_2_by_area` AS `b`
				ON (`b`.`level_2_unit_id` = `a`.`level_2_unit_id`)
			WHERE `a`.`organization_id` = @organization_id_bulk_assign
				AND `a`.`is_obsolete` = 0
			GROUP BY `a`.`level_3_room_id`
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
			SELECT
			`a`.`syst_created_datetime`
			, `a`.`creation_system_id`
			, `a`.`created_by_id_associated_mefe_user`
			, `a`.`creation_method`
			, `a`.`organization_id`
			, `a`.`is_obsolete`
			, `a`.`is_update_needed`
			# Which unit/user
			, `a`.`unee_t_mefe_user_id`
			, `a`.`unee_t_mefe_unit_id`
			# which role
			, `a`.`unee_t_role_id`
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
				, `updated_by_id` := `a`.`created_by_id_associated_mefe_user`
				, `update_method` := `a`.`creation_method`
				, `organization_id` := `a`.`organization_id`
				, `is_obsolete` := `a`.`is_obsolete`
				, `is_update_needed` := `a`.`is_update_needed`
				# Which unit/user
				, `unee_t_mefe_id` = `a`.`unee_t_mefe_user_id`
				, `unee_t_unit_id` := `a`.`unee_t_mefe_unit_id`
				# which role
				, `unee_t_role_id` := `a`.`unee_t_role_id`
				# additional permissions
				, `is_occupant` := @is_occupant
				, `is_default_assignee` := @is_default_assignee
				, `is_default_invited` := @is_default_invited
				, `is_unit_owner` := @is_unit_owner
				, `is_public` := @is_public
				# Visibility rules
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
			, `is_public`
			# Visibility rules
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
			# - case - messages
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
			# - Inspection Reports
			, `is_new_ir`
			# - Inventory
			, `is_new_item`
			, `is_item_removed`
			, `is_item_moved`
			)
			SELECT
			`a`.`syst_created_datetime`
			, `a`.`creation_system_id`
			, `a`.`created_by_id_associated_mefe_user`
			, `a`.`creation_method`
			, `a`.`organization_id`
			, `a`.`is_obsolete`
			, `a`.`is_update_needed`
			# Which unit/user
			, `a`.`unee_t_mefe_user_id`
			, `a`.`unee_t_mefe_unit_id`
			# which role
			, `a`.`unee_t_role_id`
			# additional permissions
			, @is_occupant
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
			ON DUPLICATE KEY UPDATE
				`syst_updated_datetime` := `a`.`syst_created_datetime`
				, `update_system_id` := `a`.`creation_system_id`
				, `updated_by_id` := `a`.`created_by_id_associated_mefe_user`
				, `update_method` := `a`.`creation_method`
				, `organization_id` := `a`.`organization_id`
				, `is_obsolete` := `a`.`is_obsolete`
				, `is_update_needed` := `a`.`is_update_needed`
				# Which unit/user
				, `unee_t_mefe_id` = `a`.`unee_t_mefe_user_id`
				, `unee_t_unit_id` := `a`.`unee_t_mefe_unit_id`
				# which role
				, `unee_t_role_id` := `a`.`unee_t_role_id`
				# additional permissions
				, `is_occupant` := @is_occupant
				, `is_default_assignee` := @is_default_assignee
				, `is_default_invited` := @is_default_invited
				, `is_unit_owner` := @is_unit_owner
				, `is_public` := @is_public
				# Visibility rules
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

# If the user needs to be assigned to ALL the units in his own country in that organization

	ELSEIF @is_all_units = 0
		AND @is_all_units_in_country = 1
		AND @person_country IS NOT NULL
		AND @created_by_id IS NOT NULL
		AND @mefe_user_id_assignee_bulk IS NOT NULL
		AND @requestor_id IS NOT NULL
	THEN 

	# Propagate to Level 1 units

		# We create a temporary table to store all the units we need to assign

		DROP TEMPORARY TABLE IF EXISTS `temp_user_unit_role_permissions_level_1`;

		CREATE TEMPORARY TABLE `temp_user_unit_role_permissions_level_1` (
			`id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique ID in this table',
			`syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
			`creation_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'What is the id of the sytem that was used for the creation of the record?',
			`created_by_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
			`created_by_id_associated_mefe_user` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The MEFE user_id associated with this organization',
			`creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
			`organization_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
			`country_code` varchar(10) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The 2 letter ISO country code (FR, SG, EN, etc...). See table `property_groups_countries`',
			`is_obsolete` tinyint(1) DEFAULT 0 COMMENT 'is this obsolete?',
			`is_update_needed` tinyint(1) DEFAULT 0 COMMENT '1 if Unee-T needs to be updated',
			`unee_t_mefe_user_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The current Unee-T profile id of the person - this is the value of the field `_id` in the Mongo Collection `users`',
			`unee_t_level_1_id` int(11) NOT NULL COMMENT 'A FK to the table `property_level_1_buildings`',
			`external_unee_t_level_1_id` int(11) NOT NULL COMMENT '...',
			`unee_t_mefe_unit_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The MEFE unit_id for the property',
			`unee_t_user_type_id` int(11) NOT NULL COMMENT 'A FK to the table `ut_user_types`',
			`unee_t_role_id` mediumint(9) unsigned DEFAULT NULL COMMENT 'FK to the Unee-T BZFE table `ut_role_types` - ID of the Role for this user.',
			PRIMARY KEY (`unee_t_mefe_user_id`,`unee_t_user_type_id`,`unee_t_level_1_id`,`organization_id`),
			UNIQUE KEY `unique_id_map_user_unit_role_permissions_buildings` (`id`)
		) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci
		;

		# We need all the buildings in 
		#	- That organization: 
		#	  The id of the organization is in the variable @organization_id_bulk_assign
		#	- That Country
		#	  The id of the country is in the variable @person_country
		#
		#	- The ids of the buildings are in the view `ut_list_mefe_unit_id_level_1_by_area`
		#
		# We need to insert all these data in the table `temp_user_unit_role_permissions_level_1`

		INSERT INTO `temp_user_unit_role_permissions_level_1`
			(`syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `created_by_id_associated_mefe_user`
			, `creation_method`
			, `organization_id`
			, `country_code`
			, `is_obsolete`
			, `is_update_needed`
			, `unee_t_mefe_user_id`
			, `unee_t_level_1_id`
			, `external_unee_t_level_1_id`
			, `unee_t_mefe_unit_id`
			, `unee_t_user_type_id`
			, `unee_t_role_id`
			)
			SELECT @syst_created_datetime_bulk_assign
			, @creation_system_id_bulk_assign
			, @created_by_id
			, @created_by_id_bulk_assign
			, @creation_method_bulk_assign
			, @organization_id_bulk_assign
			, @person_country
			, @is_obsolete_bulk_assign
			, @is_update_needed_bulk_assign
			, @mefe_user_id_assignee_bulk
			, `a`.`level_1_building_id`
			, `a`.`external_level_1_building_id`
			, `a`.`unee_t_mefe_unit_id`
			, @unee_t_user_type_id_bulk_assign
			, @unee_t_role_id_bulk_assign
			FROM `ut_list_mefe_unit_id_level_1_by_area` AS `a`
			WHERE `a`.`organization_id` = @organization_id_bulk_assign
				AND `a`.`country_code` = @person_country
				AND `a`.`is_obsolete` = 0
			GROUP BY `a`.`level_1_building_id`
			;

		# We can now include these into the "external" table for the Level_1 properties (Buildings)

		INSERT INTO `external_map_user_unit_role_permissions_level_1`
			(`syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `creation_method`
			, `organization_id`
			, `is_obsolete`
			, `is_update_needed`
			, `unee_t_mefe_user_id`
			, `unee_t_level_1_id`
			, `unee_t_user_type_id`
			, `unee_t_role_id`
			, `propagate_level_2`
			, `propagate_level_3`
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
			, `unee_t_level_1_id`
			, `unee_t_user_type_id`
			, `unee_t_role_id`
			, @propagate_to_all_level_2
			, @propagate_to_all_level_3
			FROM `temp_user_unit_role_permissions_level_1` as `a`
			ON DUPLICATE KEY UPDATE
			`syst_updated_datetime` := `a`.`syst_created_datetime`
			, `update_system_id` := `a`.`creation_system_id`
			, `updated_by_id` := `a`.`created_by_id`
			, `update_method` := `a`.`creation_method`
			, `organization_id` := `a`.`organization_id`
			, `is_obsolete` := `a`.`is_obsolete`
			, `is_update_needed` := `a`.`is_update_needed`
			, `unee_t_mefe_user_id` := `a`.`unee_t_mefe_user_id`
			, `unee_t_level_1_id` := `a`.`unee_t_level_1_id`
			, `unee_t_user_type_id` := `a`.`unee_t_user_type_id`
			, `unee_t_role_id` := `a`.`unee_t_role_id`
			, `propagate_level_2`:= @propagate_to_all_level_2
			, `propagate_level_3`:= @propagate_to_all_level_3
			;

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
			`a`.`syst_created_datetime`
			, `a`.`creation_system_id`
			, `a`.`created_by_id_associated_mefe_user`
			, `a`.`creation_method`
			, `a`.`organization_id`
			, `a`.`is_obsolete`
			, `a`.`is_update_needed`
			# Which unit/user
			, `a`.`unee_t_mefe_user_id`
			, `a`.`unee_t_mefe_unit_id`
			# which role
			, `a`.`unee_t_role_id`
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
			FROM `temp_user_unit_role_permissions_level_1` AS `a`
			ON DUPLICATE KEY UPDATE
			`syst_updated_datetime` := `a`.`syst_created_datetime`
			, `update_system_id` := `a`.`creation_system_id`
			, `updated_by_id` := `a`.`created_by_id_associated_mefe_user`
			, `update_method` := `a`.`creation_method`
			, `organization_id` := `a`.`organization_id`
			, `is_obsolete` := `a`.`is_obsolete`
			, `is_update_needed` := `a`.`is_update_needed`
			# Which unit/user
			, `unee_t_mefe_id` :=  `a`.`unee_t_mefe_user_id`
			, `unee_t_unit_id` := `a`.`unee_t_mefe_unit_id`
			# which role
			, `unee_t_role_id` := `a`.`unee_t_role_id`
			# additional permissions
			, `is_occupant` := @is_occupant
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
			# - case - messages
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
			# - Inspection Reports
			, `is_new_ir` := @is_new_ir
			# - Inventory
			, `is_new_item` := @is_new_item
			, `is_item_removed` := @is_item_removed
			, `is_item_moved` := @is_item_moved
			, `propagate_to_all_level_2` := @propagate_to_all_level_2
			, `propagate_to_all_level_3` := @propagate_to_all_level_3
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
			, `is_public`
			# Visibility rules
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
			# - case - messages
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
			# - Inspection Reports
			, `is_new_ir`
			# - Inventory
			, `is_new_item`
			, `is_item_removed`
			, `is_item_moved`
			)
			SELECT
			`a`.`syst_created_datetime`
			, `a`.`creation_system_id`
			, `a`.`created_by_id_associated_mefe_user`
			, `a`.`creation_method`
			, `a`.`organization_id`
			, `a`.`is_obsolete`
			, `a`.`is_update_needed`
			# Which unit/user
			, `a`.`unee_t_mefe_user_id`
			, `a`.`unee_t_mefe_unit_id`
			# which role
			, `a`.`unee_t_role_id`
			# additional permissions
			, @is_occupant
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
			FROM `temp_user_unit_role_permissions_level_1` AS `a`
			ON DUPLICATE KEY UPDATE
				`syst_updated_datetime` := `a`.`syst_created_datetime`
				, `update_system_id` := `a`.`creation_system_id`
				, `updated_by_id` := `a`.`created_by_id_associated_mefe_user`
				, `update_method` := `a`.`creation_method`
				, `organization_id` := `a`.`organization_id`
				, `is_obsolete` := `a`.`is_obsolete`
				, `is_update_needed` := `a`.`is_update_needed`
				# Which unit/user
				, `unee_t_mefe_id` = `a`.`unee_t_mefe_user_id`
				, `unee_t_unit_id` := `a`.`unee_t_mefe_unit_id`
				# which role
				, `unee_t_role_id` := `a`.`unee_t_role_id`
				# additional permissions
				, `is_occupant` := @is_occupant
				, `is_default_assignee` := @is_default_assignee
				, `is_default_invited` := @is_default_invited
				, `is_unit_owner` := @is_unit_owner
				, `is_public` := @is_public
				# Visibility rules
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
				# - case - messages
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
				# - Inspection Reports
				, `is_new_ir` := @is_new_ir
				# - Inventory
				, `is_new_item` := @is_new_item
				, `is_item_removed` := @is_item_removed
				, `is_item_moved` := @is_item_moved
				;

	# Propagate to Level 2 units

		# We create a temporary table to store all the units we need to assign

		DROP TEMPORARY TABLE IF EXISTS `temp_user_unit_role_permissions_level_2`;

		CREATE TEMPORARY TABLE `temp_user_unit_role_permissions_level_2` (
			`id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique ID in this table',
			`syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
			`creation_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'What is the id of the sytem that was used for the creation of the record?',
			`created_by_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
			`created_by_id_associated_mefe_user` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The MEFE user_id associated with this organization',
			`creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
			`organization_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
			`country_code` varchar(10) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The 2 letter ISO country code (FR, SG, EN, etc...). See table `property_groups_countries`',
			`is_obsolete` tinyint(1) DEFAULT 0 COMMENT 'is this obsolete?',
			`is_update_needed` tinyint(1) DEFAULT 0 COMMENT '1 if Unee-T needs to be updated',
			`unee_t_mefe_user_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The current Unee-T profile id of the person - this is the value of the field `_id` in the Mongo Collection `users`',
			`unee_t_level_2_id` int(11) NOT NULL COMMENT 'A FK to the table `property_level_2_units`',
			`external_unee_t_level_2_id` int(11) NOT NULL COMMENT 'A FK to the table `property_level_2_units`',
			`unee_t_mefe_unit_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The MEFE unit_id for the property',
			`unee_t_user_type_id` int(11) NOT NULL COMMENT 'A FK to the table `ut_user_types`',
			`unee_t_role_id` mediumint(9) unsigned DEFAULT NULL COMMENT 'FK to the Unee-T BZFE table `ut_role_types` - ID of the Role for this user.',
			PRIMARY KEY (`unee_t_mefe_user_id`,`unee_t_user_type_id`,`unee_t_level_2_id`,`organization_id`),
			UNIQUE KEY `unique_id_map_user_unit_role_permissions_units` (`id`)
		) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci
		;

		# We need all the units in 
		#	- That organization: 
		#	  The id of the organization is in the variable @organization_id_bulk_assign
		#	- That Country
		#	  The id of the country is in the variable @person_country
		#
		#	- The ids of the units are in the view `ut_list_mefe_unit_id_level_2_by_area`
		#
		# We need to insert all these data in the table `temp_user_unit_role_permissions_level_2`

		INSERT INTO `temp_user_unit_role_permissions_level_2`
			(`syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `created_by_id_associated_mefe_user`
			, `creation_method`
			, `organization_id`
			, `country_code`
			, `is_obsolete`
			, `is_update_needed`
			, `unee_t_mefe_user_id`
			, `unee_t_level_2_id`
			, `external_unee_t_level_2_id`
			, `unee_t_mefe_unit_id`
			, `unee_t_user_type_id`
			, `unee_t_role_id`
			)
			SELECT 
			@syst_created_datetime_bulk_assign
			, @creation_system_id_bulk_assign
			, @created_by_id
			, @created_by_id_bulk_assign
			, @creation_method_bulk_assign
			, @organization_id_bulk_assign
			, @person_country
			, @is_obsolete_bulk_assign
			, @is_update_needed_bulk_assign
			, @mefe_user_id_assignee_bulk
			, `a`.`level_2_unit_id`
			, `a`.`external_level_2_unit_id`
			, `a`.`unee_t_mefe_unit_id`
			, @unee_t_user_type_id_bulk_assign
			, @unee_t_role_id_bulk_assign
			FROM `ut_list_mefe_unit_id_level_2_by_area` AS `a`
			INNER JOIN `ut_list_mefe_unit_id_level_1_by_area` AS `b`
				ON (`a`.`level_1_building_id` = `b`.`level_1_building_id` )
			WHERE `a`.`organization_id` = @organization_id_bulk_assign
				AND `a`.`country_code` = @person_country
				AND `a`.`is_obsolete` = 0
			GROUP BY `a`.`level_2_unit_id`
			;

		# We insert the data we need in the table `external_map_user_unit_role_permissions_level_2` 

		INSERT INTO `external_map_user_unit_role_permissions_level_2`
			(`syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `creation_method`
			, `organization_id`
			, `is_obsolete`
			, `is_update_needed`
			, `unee_t_mefe_user_id`
			, `unee_t_level_2_id`
			, `unee_t_user_type_id`
			, `unee_t_role_id`
			, `propagate_level_3`
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
			, `unee_t_level_2_id`
			, `unee_t_user_type_id`
			, `unee_t_role_id`
			, @propagate_to_all_level_3
			FROM `temp_user_unit_role_permissions_level_2` as `a`
			ON DUPLICATE KEY UPDATE
			`syst_updated_datetime` := `a`.`syst_created_datetime`
			, `update_system_id` := `a`.`creation_system_id`
			, `updated_by_id` := `a`.`created_by_id`
			, `update_method` := `a`.`creation_method`
			, `organization_id` := `a`.`organization_id`
			, `is_obsolete` := `a`.`is_obsolete`
			, `is_update_needed` := `a`.`is_update_needed`
			, `unee_t_mefe_user_id` := `a`.`unee_t_mefe_user_id`
			, `unee_t_level_2_id` := `a`.`unee_t_level_2_id`
			, `unee_t_user_type_id` := `a`.`unee_t_user_type_id`
			, `unee_t_role_id` := `a`.`unee_t_role_id`
			, `propagate_level_3`:= @propagate_to_all_level_3
			;

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
			)
			SELECT
			`a`.`syst_created_datetime`
			, `a`.`creation_system_id`
			, `a`.`created_by_id_associated_mefe_user`
			, `a`.`creation_method`
			, `a`.`organization_id`
			, `a`.`is_obsolete`
			, `a`.`is_update_needed`
			# Which unit/user
			, `a`.`unee_t_mefe_user_id`
			, `a`.`unee_t_mefe_unit_id`
			# which role
			, `a`.`unee_t_role_id`
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
			FROM `temp_user_unit_role_permissions_level_2` AS `a`
			INNER JOIN `ut_list_mefe_unit_id_level_2_by_area` AS `b`
				ON (`b`.`level_2_unit_id` = `a`.`unee_t_level_2_id`)
			ON DUPLICATE KEY UPDATE
				`syst_updated_datetime` := `a`.`syst_created_datetime`
				, `update_system_id` := `a`.`creation_system_id`
				, `updated_by_id` := `a`.`created_by_id_associated_mefe_user`
				, `update_method` := `a`.`creation_method`
				, `organization_id` := `a`.`organization_id`
				, `is_obsolete` := `a`.`is_obsolete`
				, `is_update_needed` := `a`.`is_update_needed`
				# Which unit/user
				, `unee_t_mefe_id` = `a`.`unee_t_mefe_user_id`
				, `unee_t_unit_id` := `a`.`unee_t_mefe_unit_id`
				# which role
				, `unee_t_role_id` := `a`.`unee_t_role_id`
				# additional permissions
				, `is_occupant` := @is_occupant
				, `is_default_assignee` := @is_default_assignee
				, `is_default_invited` := @is_default_invited
				, `is_unit_owner` := @is_unit_owner
				, `is_public` := @is_public
				# Visibility rules
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
			, `is_public`
			# Visibility rules
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
			# - case - messages
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
			# - Inspection Reports
			, `is_new_ir`
			# - Inventory
			, `is_new_item`
			, `is_item_removed`
			, `is_item_moved`
			)
			SELECT
			`a`.`syst_created_datetime`
			, `a`.`creation_system_id`
			, `a`.`created_by_id_associated_mefe_user`
			, `a`.`creation_method`
			, `a`.`organization_id`
			, `a`.`is_obsolete`
			, `a`.`is_update_needed`
			# Which unit/user
			, `a`.`unee_t_mefe_user_id`
			, `a`.`unee_t_mefe_unit_id`
			# which role
			, `a`.`unee_t_role_id`
			# additional permissions
			, @is_occupant
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
			FROM `temp_user_unit_role_permissions_level_2` AS `a`
			ON DUPLICATE KEY UPDATE
				`syst_updated_datetime` := `a`.`syst_created_datetime`
				, `update_system_id` := `a`.`creation_system_id`
				, `updated_by_id` := `a`.`created_by_id_associated_mefe_user`
				, `update_method` := `a`.`creation_method`
				, `organization_id` := `a`.`organization_id`
				, `is_obsolete` := `a`.`is_obsolete`
				, `is_update_needed` := `a`.`is_update_needed`
				# Which unit/user
				, `unee_t_mefe_id` = `a`.`unee_t_mefe_user_id`
				, `unee_t_unit_id` := `a`.`unee_t_mefe_unit_id`
				# which role
				, `unee_t_role_id` := `a`.`unee_t_role_id`
				# additional permissions
				, `is_occupant` := @is_occupant
				, `is_default_assignee` := @is_default_assignee
				, `is_default_invited` := @is_default_invited
				, `is_unit_owner` := @is_unit_owner
				, `is_public` := @is_public
				# Visibility rules
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

	# Propagate to Level 3 units

		# We create a temporary table to store all the units we need to assign

		DROP TEMPORARY TABLE IF EXISTS `temp_user_unit_role_permissions_level_3`;

		CREATE TEMPORARY TABLE `temp_user_unit_role_permissions_level_3` (
			`id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique ID in this table',
			`syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
			`creation_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'What is the id of the sytem that was used for the creation of the record?',
			`created_by_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
			`created_by_id_associated_mefe_user` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The MEFE user_id associated with this organization',
			`creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
			`organization_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
			`country_code` varchar(10) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The 2 letter ISO country code (FR, SG, EN, etc...). See table `property_groups_countries`',
			`is_obsolete` tinyint(1) DEFAULT 0 COMMENT 'is this obsolete?',
			`is_update_needed` tinyint(1) DEFAULT 0 COMMENT '1 if Unee-T needs to be updated',
			`unee_t_mefe_user_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The current Unee-T profile id of the person - this is the value of the field `_id` in the Mongo Collection `users`',
			`unee_t_level_3_id` int(11) NOT NULL COMMENT 'A FK to the table `property_level_3_rooms`',
			`external_unee_t_level_3_id` int(11) NOT NULL COMMENT '...',
			`unee_t_mefe_unit_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The MEFE unit_id for the property',
			`unee_t_user_type_id` int(11) NOT NULL COMMENT 'A FK to the table `ut_user_types`',
			`unee_t_role_id` mediumint(9) unsigned DEFAULT NULL COMMENT 'FK to the Unee-T BZFE table `ut_role_types` - ID of the Role for this user.',
			PRIMARY KEY (`unee_t_mefe_user_id`,`unee_t_user_type_id`,`unee_t_level_3_id`,`organization_id`),
			UNIQUE KEY `unique_id_map_user_unit_role_permissions_rooms` (`id`)
		) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci
		;

		# We need all the rooms in 
		#	- That organization: 
		#	  The id of the organization is in the variable @organization_id_bulk_assign
		#	- That Country
		#	  The id of the country is in the variable @person_country
		#
		#	- The ids of the rooms are in the view `ut_list_mefe_unit_id_level_3_by_area`
		#
		# We need to insert all these data in the table `temp_user_unit_role_permissions_level_3`

		INSERT INTO `temp_user_unit_role_permissions_level_3`
			(`syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `created_by_id_associated_mefe_user`
			, `creation_method`
			, `organization_id`
			, `country_code`
			, `is_obsolete`
			, `is_update_needed`
			, `unee_t_mefe_user_id`
			, `unee_t_level_3_id`
			, `external_unee_t_level_3_id`
			, `unee_t_mefe_unit_id`
			, `unee_t_user_type_id`
			, `unee_t_role_id`
			)
			SELECT 
			@syst_created_datetime_bulk_assign
			, @creation_system_id_bulk_assign
			, @created_by_id
			, @created_by_id_bulk_assign
			, @creation_method_bulk_assign
			, @organization_id_bulk_assign
			, @person_country
			, @is_obsolete_bulk_assign
			, @is_update_needed_bulk_assign
			, @mefe_user_id_assignee_bulk
			, `a`.`level_3_room_id`
			, `a`.`external_level_3_room_id`
			, `a`.`unee_t_mefe_unit_id`
			, @unee_t_user_type_id_bulk_assign
			, @unee_t_role_id_bulk_assign
			FROM `ut_list_mefe_unit_id_level_3_by_area` AS `a`
			INNER JOIN `ut_list_mefe_unit_id_level_2_by_area` AS `b`
				ON (`b`.`level_2_unit_id` = `a`.`level_2_unit_id`)
			WHERE `a`.`organization_id` = @organization_id_bulk_assign
				AND `a`.`country_code` = @person_country
				AND `a`.`is_obsolete` = 0
			GROUP BY `a`.`level_3_room_id`
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
			SELECT
			`a`.`syst_created_datetime`
			, `a`.`creation_system_id`
			, `a`.`created_by_id_associated_mefe_user`
			, `a`.`creation_method`
			, `a`.`organization_id`
			, `a`.`is_obsolete`
			, `a`.`is_update_needed`
			# Which unit/user
			, `a`.`unee_t_mefe_user_id`
			, `a`.`unee_t_mefe_unit_id`
			# which role
			, `a`.`unee_t_role_id`
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
				, `updated_by_id` := `a`.`created_by_id_associated_mefe_user`
				, `update_method` := `a`.`creation_method`
				, `organization_id` := `a`.`organization_id`
				, `is_obsolete` := `a`.`is_obsolete`
				, `is_update_needed` := `a`.`is_update_needed`
				# Which unit/user
				, `unee_t_mefe_id` = `a`.`unee_t_mefe_user_id`
				, `unee_t_unit_id` := `a`.`unee_t_mefe_unit_id`
				# which role
				, `unee_t_role_id` := `a`.`unee_t_role_id`
				# additional permissions
				, `is_occupant` := @is_occupant
				, `is_default_assignee` := @is_default_assignee
				, `is_default_invited` := @is_default_invited
				, `is_unit_owner` := @is_unit_owner
				, `is_public` := @is_public
				# Visibility rules
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
			, `is_public`
			# Visibility rules
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
			# - case - messages
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
			# - Inspection Reports
			, `is_new_ir`
			# - Inventory
			, `is_new_item`
			, `is_item_removed`
			, `is_item_moved`
			)
			SELECT
			`a`.`syst_created_datetime`
			, `a`.`creation_system_id`
			, `a`.`created_by_id_associated_mefe_user`
			, `a`.`creation_method`
			, `a`.`organization_id`
			, `a`.`is_obsolete`
			, `a`.`is_update_needed`
			# Which unit/user
			, `a`.`unee_t_mefe_user_id`
			, `a`.`unee_t_mefe_unit_id`
			# which role
			, `a`.`unee_t_role_id`
			# additional permissions
			, @is_occupant
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
			ON DUPLICATE KEY UPDATE
				`syst_updated_datetime` := `a`.`syst_created_datetime`
				, `update_system_id` := `a`.`creation_system_id`
				, `updated_by_id` := `a`.`created_by_id_associated_mefe_user`
				, `update_method` := `a`.`creation_method`
				, `organization_id` := `a`.`organization_id`
				, `is_obsolete` := `a`.`is_obsolete`
				, `is_update_needed` := `a`.`is_update_needed`
				# Which unit/user
				, `unee_t_mefe_id` = `a`.`unee_t_mefe_user_id`
				, `unee_t_unit_id` := `a`.`unee_t_mefe_unit_id`
				# which role
				, `unee_t_role_id` := `a`.`unee_t_role_id`
				# additional permissions
				, `is_occupant` := @is_occupant
				, `is_default_assignee` := @is_default_assignee
				, `is_default_invited` := @is_default_invited
				, `is_unit_owner` := @is_unit_owner
				, `is_public` := @is_public
				# Visibility rules
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

	END IF;

END $$
DELIMITER ;