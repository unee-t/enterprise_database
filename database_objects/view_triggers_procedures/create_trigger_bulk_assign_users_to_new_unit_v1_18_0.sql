#################
#	
# When a new MEFE unit is created, auto assign all the users if needed:
#	- Users who can see all units in the organization for the unit
#	- Users who can see all units in the country for the unit
#	- Users who can see all units in the area  for the unit
#
#################


# After we have received a MEFE unit Id from the API, we need to assign that property 
# to the users who need access to that property:

	DROP TRIGGER IF EXISTS `ut_update_mefe_unit_id_assign_users_to_property`;

DELIMITER $$
CREATE TRIGGER `ut_update_mefe_unit_id_assign_users_to_property`
AFTER UPDATE ON `ut_map_external_source_units`
FOR EACH ROW
BEGIN

# We only do this IF
#	- We have a MEFE unit unit for that property
#	- This is an authorized update method
#		- `ut_creation_unit_mefe_api_reply`

	SET @unee_t_mefe_unit_id := NEW.`unee_t_mefe_unit_id` ;
	SET @upstream_update_method := NEW.`update_method` ;

	SET @requestor_id := NEW.`updated_by_id` ;

	SET @created_by_id := (SELECT `organization_id`
		FROM `ut_api_keys`
		WHERE `mefe_user_id` = @requestor_id
		);

	IF @requestor_id IS NOT NULL
		AND @unee_t_mefe_unit_id IS NOT NULL
		AND @upstream_update_method = 'ut_creation_unit_mefe_api_reply'
	THEN 

	# We need to list all the users that we should assign to this new property:
	# These users are users who need to be assigned to:
	#	- All the properties in the organization
	#	- All the properties in the country where this property is
	#	- All the properties in the Area where this property is

		SET @external_property_type_id := NEW.`external_property_type_id` ;

		SET @property_id := NEW.`new_record_id` ;

		SET @organization_id := NEW.`organization_id` ;

	# What is the country for that property

		SET @property_country_code := (IF (@external_property_type_id = 1
				, (SELECT `country_code`
					FROM `ut_list_mefe_unit_id_level_1_by_area`
					WHERE `level_1_building_id` = @property_id
					)
				, IF (@external_property_type_id = 2
					, (SELECT `country_code`
						FROM `ut_list_mefe_unit_id_level_2_by_area`
						WHERE `level_2_unit_id` = @property_id
						)
					, IF (@external_property_type_id = 3
						, (SELECT `country_code`
							FROM `ut_list_mefe_unit_id_level_3_by_area`
							WHERE `level_3_room_id` = @property_id
							)
						, 'error - 1308'
						)
					)
				)
			);

	# We get the other variables we need:

		SET @syst_created_datetime := NOW() ;
		SET @creation_system_id := 2 ;
		SET @creation_method := 'ut_update_mefe_unit_id_assign_users_to_property' ;

	# We create a temporary table to list all the users we need to add to that property:

		DROP TEMPORARY TABLE IF EXISTS `temp_list_users_auto_assign_new_property` ;

		CREATE TEMPORARY TABLE `temp_list_users_auto_assign_new_property` (
			`id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique ID in this table',
			`syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
			`creation_system_id` int(11) NOT NULL DEFAULT 1 COMMENT 'What is the id of the sytem that was used for the creation of the record?',
			`requestor_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who created this record',
			`created_by_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
 			`creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
			`organization_id` int(11) unsigned DEFAULT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
			`country_code` varchar(10) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The 2 letter version of the country code',
			`mefe_user_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The current Unee-T profile id of the person - this is the value of the field `_id` in the Mongo Collection `users`',
			`email` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The primary email address of the person',
			`unee_t_user_type_id` int(11) NOT NULL COMMENT 'A FK to the table `ut_user_types`',
			`mefe_unit_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'ID of that Unit in Unee-T. This is a the value in the Mongo collection',
			`unee_t_role_id` smallint(6) DEFAULT NULL COMMENT 'The ID of the Role Type for this user - this is a FK to the Unee-T BZFE table `ut_role_types`',
			`is_occupant` tinyint(1) DEFAULT 0 COMMENT '1 is the user is an occupant of the unit',
			`is_default_assignee` tinyint(1) DEFAULT 0 COMMENT '1 if this user is the default assignee for this role for this unit.',
			`is_default_invited` tinyint(1) DEFAULT 0 COMMENT '1 if the user is automatically invited to all the new cases in this role for this unit',
			`is_unit_owner` tinyint(1) DEFAULT 0 COMMENT '1 if this user is one of the Unee-T `owner` of that unit',
			`is_public` tinyint(1) DEFAULT 0 COMMENT '1 if the user is Visible to other Unee-T users in other roles for this unit. If yes/1/TRUE then all other roles will be able to see this user. IF No/FALSE/0 then only the users in the same role for that unit will be able to see this user in this unit',
			`can_see_role_landlord` tinyint(1) DEFAULT 0 COMMENT '1 if user is allowed to see the PUBLIC users in the role `landlord` (2) for this unit',
			`can_see_role_tenant` tinyint(1) DEFAULT 0 COMMENT '1 if user is allowed to see the PUBLIC users in the role `tenant` (1) for this unit',
			`can_see_role_mgt_cny` tinyint(1) DEFAULT 0 COMMENT '1 if user is allowed to see the PUBLIC users in the role `Mgt Company` (4) for this unit',
			`can_see_role_agent` tinyint(1) DEFAULT 0 COMMENT '1 if user is allowed to see the PUBLIC users in the role `agent` (5) for this unit',
			`can_see_role_contractor` tinyint(1) DEFAULT 0 COMMENT '1 if user is allowed to see the PUBLIC users in the role `contractor` (3) for this unit',
			`can_see_occupant` tinyint(1) DEFAULT 0 COMMENT '1 if user is allowed to see the PUBLIC occupants for this unit',
			`is_assigned_to_case` tinyint(1) DEFAULT 0 COMMENT '1 if user wants to be notified',
			`is_invited_to_case` tinyint(1) DEFAULT 0 COMMENT '1 if user wants to be notified',
			`is_next_step_updated` tinyint(1) DEFAULT 0 COMMENT '1 if user wants to be notified',
			`is_deadline_updated` tinyint(1) DEFAULT 0 COMMENT '1 if user wants to be notified',
			`is_solution_updated` tinyint(1) DEFAULT 0 COMMENT '1 if user wants to be notified',
			`is_case_resolved` tinyint(1) DEFAULT 0 COMMENT '1 if user wants to be notified',
			`is_case_blocker` tinyint(1) DEFAULT 0 COMMENT '1 if user wants to be notified',
			`is_case_critical` tinyint(1) DEFAULT 0 COMMENT '1 if user wants to be notified',
			`is_any_new_message` tinyint(1) DEFAULT 0 COMMENT '1 if user wants to be notified',
			`is_message_from_tenant` tinyint(1) DEFAULT 0 COMMENT '1 if user wants to be notified',
			`is_message_from_ll` tinyint(1) DEFAULT 0 COMMENT '1 if user wants to be notified',
			`is_message_from_occupant` tinyint(1) DEFAULT 0 COMMENT '1 if user wants to be notified',
			`is_message_from_agent` tinyint(1) DEFAULT 0 COMMENT '1 if user wants to be notified',
			`is_message_from_mgt_cny` tinyint(1) DEFAULT 0 COMMENT '1 if user wants to be notified',
			`is_message_from_contractor` tinyint(1) DEFAULT 0 COMMENT '1 if user wants to be notified',
			`is_new_ir` tinyint(1) DEFAULT 0 COMMENT '1 if user wants to be notified',
			`is_new_item` tinyint(1) DEFAULT 0 COMMENT '1 if user wants to be notified',
			`is_item_removed` tinyint(1) DEFAULT 0 COMMENT '1 if user wants to be notified',
			`is_item_moved` tinyint(1) DEFAULT 0 COMMENT '1 if user wants to be notified',
			PRIMARY KEY (`mefe_user_id`,`mefe_unit_id`),
			UNIQUE KEY `temp_list_users_auto_assign_new_property_id` (`id`)
			) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci
			;

	# We insert all the user that should see all the units in the organization

		INSERT INTO `temp_list_users_auto_assign_new_property`
			(`syst_created_datetime`
			, `creation_system_id`
			, `requestor_id`
			, `created_by_id`
			, `creation_method`
			, `organization_id`
			, `mefe_user_id`
			, `email`
			, `unee_t_user_type_id`
			, `mefe_unit_id`
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
			@syst_created_datetime
			, @creation_system_id
			, @requestor_id
			, @created_by_id
			, @creation_method
			, @organization_id
			, `a`.`mefe_user_id`
			, `a`.`email`
			, `a`.`unee_t_user_type_id`
			, @unee_t_mefe_unit_id
			, `a`.`unee_t_role_id`
			, `a`.`is_occupant`
			, `a`.`is_default_assignee`
			, `a`.`is_default_invited`
			, `a`.`is_unit_owner`
			, `a`.`is_public`
			, `a`.`can_see_role_landlord`
			, `a`.`can_see_role_tenant`
			, `a`.`can_see_role_mgt_cny`
			, `a`.`can_see_role_agent`
			, `a`.`can_see_role_contractor`
			, `a`.`can_see_occupant`
			, `a`.`is_assigned_to_case`
			, `a`.`is_invited_to_case`
			, `a`.`is_next_step_updated`
			, `a`.`is_deadline_updated`
			, `a`.`is_solution_updated`
			, `a`.`is_case_resolved`
			, `a`.`is_case_blocker`
			, `a`.`is_case_critical`
			, `a`.`is_any_new_message`
			, `a`.`is_message_from_tenant`
			, `a`.`is_message_from_ll`
			, `a`.`is_message_from_occupant`
			, `a`.`is_message_from_agent`
			, `a`.`is_message_from_mgt_cny`
			, `a`.`is_message_from_contractor`
			, `a`.`is_new_ir`
			, `a`.`is_new_item`
			, `a`.`is_item_removed`
			, `a`.`is_item_moved`
			FROM `ut_list_users_default_permissions` AS `a`
				WHERE 
					`a`.`organization_id` = @organization_id
					AND `a`.`is_all_unit` = 1
			;

	# We insert all the user that should see all the unit in the country where this unit is

		INSERT INTO `temp_list_users_auto_assign_new_property`
			(`syst_created_datetime`
			, `creation_system_id`
			, `requestor_id`
			, `created_by_id`
			, `creation_method`
			, `organization_id`
			, `country_code`
			, `mefe_user_id`
			, `email`
			, `unee_t_user_type_id`
			, `mefe_unit_id`
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
				@syst_created_datetime
				, @creation_system_id
				, @requestor_id
				, @created_by_id
				, @creation_method
				, @organization_id
				, `a`.`country_code`
				, `a`.`mefe_user_id`
				, `a`.`email`
				, `a`.`unee_t_user_type_id`
				, @unee_t_mefe_unit_id
				, `a`.`unee_t_role_id`
				, `a`.`is_occupant`
				, `a`.`is_default_assignee`
				, `a`.`is_default_invited`
				, `a`.`is_unit_owner`
				, `a`.`is_public`
				, `a`.`can_see_role_landlord`
				, `a`.`can_see_role_tenant`
				, `a`.`can_see_role_mgt_cny`
				, `a`.`can_see_role_agent`
				, `a`.`can_see_role_contractor`
				, `a`.`can_see_occupant`
				, `a`.`is_assigned_to_case`
				, `a`.`is_invited_to_case`
				, `a`.`is_next_step_updated`
				, `a`.`is_deadline_updated`
				, `a`.`is_solution_updated`
				, `a`.`is_case_resolved`
				, `a`.`is_case_blocker`
				, `a`.`is_case_critical`
				, `a`.`is_any_new_message`
				, `a`.`is_message_from_tenant`
				, `a`.`is_message_from_ll`
				, `a`.`is_message_from_occupant`
				, `a`.`is_message_from_agent`
				, `a`.`is_message_from_mgt_cny`
				, `a`.`is_message_from_contractor`
				, `a`.`is_new_ir`
				, `a`.`is_new_item`
				, `a`.`is_item_removed`
				, `a`.`is_item_moved`
				FROM `ut_list_users_default_permissions` AS `a`
					WHERE 
						`a`.`organization_id` = @organization_id
						AND `a`.`country_code` = @property_country_code
						AND `a`.`is_all_units_in_country` = 1
				;

	# We assign the user to the unit

		# For Level 1 Properties, this is done in the table 
		# `external_map_user_unit_role_permissions_level_1`

			SET @propagate_to_all_level_2 := 1 ;
			SET @propagate_to_all_level_3 := 1;

			SET @is_obsolete := 0 ;
			SET @is_update_needed := 1 ;

			IF @external_property_type_id = 1
			THEN

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
					, `unee_t_user_type_id`
					, `propagate_level_2`
					, `propagate_level_3`
					)
					SELECT 
						@syst_created_datetime
						, @creation_system_id
						, @created_by_id
						, @creation_method
						, @organization_id
						, @is_obsolete
						, @is_update_needed
						# Which unit/user
						, `a`.`mefe_user_id`
						, @property_id
						, `a`.`unee_t_user_type_id`
						, @propagate_to_all_level_2
						, @propagate_to_all_level_3
					FROM `temp_list_users_auto_assign_new_property` AS `a`
						ON DUPLICATE KEY UPDATE
							`syst_updated_datetime` := @syst_created_datetime
							, `update_system_id` := @creation_system_id
							, `updated_by_id` := @created_by_id
							, `update_method` := @creation_method
							, `organization_id` := @organization_id
							, `is_obsolete` := @is_obsolete
							, `is_update_needed` := @is_update_needed
							# Which unit/user
							, `unee_t_mefe_user_id` := `a`.`mefe_user_id`
							, `unee_t_level_1_id` := @property_id
							, `unee_t_user_type_id` := `a`.`unee_t_user_type_id`
							, `propagate_level_2`:= @propagate_to_all_level_2
							, `propagate_level_3` := @propagate_to_all_level_3
						;

				# We insert these in the table `ut_map_user_permissions_unit_level_1`

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
							, @requestor_id
							, @creation_method
							, @organization_id
							, @is_obsolete
							, @is_update_needed
							# Which unit/user
							, `a`.`mefe_user_id`
							, @unee_t_mefe_unit_id
							# which role
							, `a`.`unee_t_role_id`
							, `a`.`is_occupant`
							# additional permissions
							, `a`.`is_default_assignee`
							, `a`.`is_default_invited`
							, `a`.`is_unit_owner`
							# Visibility rules
							, `a`.`is_public`
							, `a`.`can_see_role_landlord`
							, `a`.`can_see_role_tenant`
							, `a`.`can_see_role_mgt_cny`
							, `a`.`can_see_role_agent`
							, `a`.`can_see_role_contractor`
							, `a`.`can_see_occupant`
							# Notification rules
							# - case - information
							, `a`.`is_assigned_to_case`
							, `a`.`is_invited_to_case`
							, `a`.`is_next_step_updated`
							, `a`.`is_deadline_updated`
							, `a`.`is_solution_updated`
							, `a`.`is_case_resolved`
							, `a`.`is_case_blocker`
							, `a`.`is_case_critical`
							# - case - messages
							, `a`.`is_any_new_message`
							, `a`.`is_message_from_tenant`
							, `a`.`is_message_from_ll`
							, `a`.`is_message_from_occupant`
							, `a`.`is_message_from_agent`
							, `a`.`is_message_from_mgt_cny`
							, `a`.`is_message_from_contractor`
							# - Inspection Reports
							, `a`.`is_new_ir`
							# - Inventory
							, `a`.`is_new_item`
							, `a`.`is_item_removed`
							, `a`.`is_item_moved`
							, @propagate_to_all_level_2
							, @propagate_to_all_level_3
							FROM `temp_list_users_auto_assign_new_property` AS `a`
							ON DUPLICATE KEY UPDATE
								`syst_updated_datetime` := @syst_created_datetime
								, `update_system_id` := @creation_system_id
								, `updated_by_id` := @requestor_id
								, `update_method` := @creation_method
								, `organization_id` := @organization_id
								, `is_obsolete` := @is_obsolete
								, `is_update_needed` := @is_update_needed
								# Which unit/user
								, `unee_t_mefe_id` := `a`.`mefe_user_id`
								, `unee_t_unit_id` := @unee_t_mefe_unit_id
								# which role
								, `unee_t_role_id` := `a`.`unee_t_role_id`
								, `is_occupant` := `a`.`is_occupant`
								# additional permissions
								, `is_default_assignee` := `a`.`is_default_assignee`
								, `is_default_invited` := `a`.`is_default_invited`
								, `is_unit_owner` := `a`.`is_unit_owner`
								# Visibility rules
								, `is_public` := `a`.`is_public`
								, `can_see_role_landlord` := `a`.`can_see_role_landlord`
								, `can_see_role_tenant` := `a`.`can_see_role_tenant`
								, `can_see_role_mgt_cny` := `a`.`can_see_role_mgt_cny`
								, `can_see_role_agent` := `a`.`can_see_role_agent`
								, `can_see_role_contractor` := `a`.`can_see_role_contractor`
								, `can_see_occupant` := `a`.`can_see_occupant`
								# Notification rules
								# - case - information
								, `is_assigned_to_case` := `a`.`is_assigned_to_case`
								, `is_invited_to_case` := `a`.`is_invited_to_case`
								, `is_next_step_updated` := `a`.`is_next_step_updated`
								, `is_deadline_updated` := `a`.`is_deadline_updated`
								, `is_solution_updated` := `a`.`is_solution_updated`
								, `is_case_resolved` := `a`.`is_case_resolved`
								, `is_case_blocker` := `a`.`is_case_blocker`
								, `is_case_critical` := `a`.`is_case_critical`
								# - case - messages
								, `is_any_new_message` := `a`.`is_any_new_message`
								, `is_message_from_tenant` := `a`.`is_message_from_tenant`
								, `is_message_from_ll` := `a`.`is_message_from_ll`
								, `is_message_from_occupant` := `a`.`is_message_from_occupant`
								, `is_message_from_agent` := `a`.`is_message_from_agent`
								, `is_message_from_mgt_cny` := `a`.`is_message_from_mgt_cny`
								, `is_message_from_contractor` := `a`.`is_message_from_contractor`
								# - Inspection Reports
								, `is_new_ir` := `a`.`is_new_ir`
								# - Inventory
								, `is_new_item` := `a`.`is_new_item`
								, `is_item_removed` := `a`.`is_item_removed`
								, `is_item_moved` := `a`.`is_item_moved`
								, `propagate_to_all_level_2` = @propagate_to_all_level_2
								, `propagate_to_all_level_3` = @propagate_to_all_level_3
								;

			ELSEIF @external_property_type_id = 2
			THEN 

				INSERT INTO `external_map_user_unit_role_permissions_level_2`
					(`syst_created_datetime`
					, `creation_system_id`
					, `created_by_id`
					, `creation_method`
					, `organization_id`
					, `is_obsolete`
					, `is_update_needed`
					# Which unit/user
					, `unee_t_mefe_user_id`
					, `unee_t_level_2_id`
					, `unee_t_user_type_id`
					, `propagate_level_3`
					)
					SELECT 
						@syst_created_datetime
						, @creation_system_id
						, @created_by_id
						, @creation_method
						, @organization_id
						, @is_obsolete
						, @is_update_needed
						# Which unit/user
						, `a`.`mefe_user_id`
						, @property_id
						, `a`.`unee_t_user_type_id`
						, @propagate_to_all_level_3
					FROM `temp_list_users_auto_assign_new_property` AS `a`
						ON DUPLICATE KEY UPDATE
							`syst_updated_datetime` := @syst_created_datetime
							, `update_system_id` := @creation_system_id
							, `updated_by_id` := @created_by_id
							, `update_method` := @creation_method
							, `organization_id` := @organization_id
							, `is_obsolete` := @is_obsolete
							, `is_update_needed` := @is_update_needed
							# Which unit/user
							, `unee_t_mefe_user_id` := `a`.`mefe_user_id`
							, `unee_t_level_2_id` := @property_id
							, `unee_t_user_type_id` := `a`.`unee_t_user_type_id`
							, `propagate_level_3` := @propagate_to_all_level_3
						;

				# We insert these in the table `ut_map_user_permissions_unit_level_2` 

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
						SELECT
							@syst_created_datetime
							, @creation_system_id
							, @requestor_id
							, @creation_method
							, @organization_id
							, @is_obsolete
							, @is_update_needed
							# Which unit/user
							, `a`.`mefe_user_id`
							, @unee_t_mefe_unit_id
							# which role
							, `a`.`unee_t_role_id`
							, `a`.`is_occupant`
							# additional permissions
							, `a`.`is_default_assignee`
							, `a`.`is_default_invited`
							, `a`.`is_unit_owner`
							# Visibility rules
							, `a`.`is_public`
							, `a`.`can_see_role_landlord`
							, `a`.`can_see_role_tenant`
							, `a`.`can_see_role_mgt_cny`
							, `a`.`can_see_role_agent`
							, `a`.`can_see_role_contractor`
							, `a`.`can_see_occupant`
							# Notification rules
							# - case - information
							, `a`.`is_assigned_to_case`
							, `a`.`is_invited_to_case`
							, `a`.`is_next_step_updated`
							, `a`.`is_deadline_updated`
							, `a`.`is_solution_updated`
							, `a`.`is_case_resolved`
							, `a`.`is_case_blocker`
							, `a`.`is_case_critical`
							# - case - messages
							, `a`.`is_any_new_message`
							, `a`.`is_message_from_tenant`
							, `a`.`is_message_from_ll`
							, `a`.`is_message_from_occupant`
							, `a`.`is_message_from_agent`
							, `a`.`is_message_from_mgt_cny`
							, `a`.`is_message_from_contractor`
							# - Inspection Reports
							, `a`.`is_new_ir`
							# - Inventory
							, `a`.`is_new_item`
							, `a`.`is_item_removed`
							, `a`.`is_item_moved`
							, @propagate_to_all_level_3
							FROM `temp_list_users_auto_assign_new_property` AS `a`
							ON DUPLICATE KEY UPDATE
								`syst_updated_datetime` := @syst_created_datetime
								, `update_system_id` := @creation_system_id
								, `updated_by_id` := @requestor_id
								, `update_method` := @creation_method
								, `organization_id` := @organization_id
								, `is_obsolete` := @is_obsolete
								, `is_update_needed` := @is_update_needed
								# Which unit/user
								, `unee_t_mefe_id` := `a`.`mefe_user_id`
								, `unee_t_unit_id` := @unee_t_mefe_unit_id
								# which role
								, `unee_t_role_id` := `a`.`unee_t_role_id`
								, `is_occupant` := `a`.`is_occupant`
								# additional permissions
								, `is_default_assignee` := `a`.`is_default_assignee`
								, `is_default_invited` := `a`.`is_default_invited`
								, `is_unit_owner` := `a`.`is_unit_owner`
								# Visibility rules
								, `is_public` := `a`.`is_public`
								, `can_see_role_landlord` := `a`.`can_see_role_landlord`
								, `can_see_role_tenant` := `a`.`can_see_role_tenant`
								, `can_see_role_mgt_cny` := `a`.`can_see_role_mgt_cny`
								, `can_see_role_agent` := `a`.`can_see_role_agent`
								, `can_see_role_contractor` := `a`.`can_see_role_contractor`
								, `can_see_occupant` := `a`.`can_see_occupant`
								# Notification rules
								# - case - information
								, `is_assigned_to_case` := `a`.`is_assigned_to_case`
								, `is_invited_to_case` := `a`.`is_invited_to_case`
								, `is_next_step_updated` := `a`.`is_next_step_updated`
								, `is_deadline_updated` := `a`.`is_deadline_updated`
								, `is_solution_updated` := `a`.`is_solution_updated`
								, `is_case_resolved` := `a`.`is_case_resolved`
								, `is_case_blocker` := `a`.`is_case_blocker`
								, `is_case_critical` := `a`.`is_case_critical`
								# - case - messages
								, `is_any_new_message` := `a`.`is_any_new_message`
								, `is_message_from_tenant` := `a`.`is_message_from_tenant`
								, `is_message_from_ll` := `a`.`is_message_from_ll`
								, `is_message_from_occupant` := `a`.`is_message_from_occupant`
								, `is_message_from_agent` := `a`.`is_message_from_agent`
								, `is_message_from_mgt_cny` := `a`.`is_message_from_mgt_cny`
								, `is_message_from_contractor` := `a`.`is_message_from_contractor`
								# - Inspection Reports
								, `is_new_ir` := `a`.`is_new_ir`
								# - Inventory
								, `is_new_item` := `a`.`is_new_item`
								, `is_item_removed` := `a`.`is_item_removed`
								, `is_item_moved` := `a`.`is_item_moved`
								, `propagate_to_all_level_3` = @propagate_to_all_level_3
								;

			ELSEIF @external_property_type_id = 3
			THEN 

				INSERT INTO `external_map_user_unit_role_permissions_level_3`
					(`syst_created_datetime`
					, `creation_system_id`
					, `created_by_id`
					, `creation_method`
					, `organization_id`
					, `is_obsolete`
					, `is_update_needed`
					# Which unit/user
					, `unee_t_mefe_user_id`
					, `unee_t_level_3_id`
					, `unee_t_user_type_id`
					)
					SELECT 
						@syst_created_datetime
						, @creation_system_id
						, @created_by_id
						, @creation_method
						, @organization_id
						, @is_obsolete
						, @is_update_needed
						# Which unit/user
						, `a`.`mefe_user_id`
						, @property_id
						, `a`.`unee_t_user_type_id`
					FROM `temp_list_users_auto_assign_new_property` AS `a`
						ON DUPLICATE KEY UPDATE
							`syst_updated_datetime` := @syst_created_datetime
							, `update_system_id` := @creation_system_id
							, `updated_by_id` := @created_by_id
							, `update_method` := @creation_method
							, `organization_id` := @organization_id
							, `is_obsolete` := @is_obsolete
							, `is_update_needed` := @is_update_needed
							# Which unit/user
							, `unee_t_mefe_user_id` := `a`.`mefe_user_id`
							, `unee_t_level_3_id` := @property_id
							, `unee_t_user_type_id` := `a`.`unee_t_user_type_id`
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
							@syst_created_datetime
							, @creation_system_id
							, @requestor_id
							, @creation_method
							, @organization_id
							, @is_obsolete
							, @is_update_needed
							# Which unit/user
							, `a`.`mefe_user_id`
							, @unee_t_mefe_unit_id
							# which role
							, `a`.`unee_t_role_id`
							, `a`.`is_occupant`
							# additional permissions
							, `a`.`is_default_assignee`
							, `a`.`is_default_invited`
							, `a`.`is_unit_owner`
							# Visibility rules
							, `a`.`is_public`
							, `a`.`can_see_role_landlord`
							, `a`.`can_see_role_tenant`
							, `a`.`can_see_role_mgt_cny`
							, `a`.`can_see_role_agent`
							, `a`.`can_see_role_contractor`
							, `a`.`can_see_occupant`
							# Notification rules
							# - case - information
							, `a`.`is_assigned_to_case`
							, `a`.`is_invited_to_case`
							, `a`.`is_next_step_updated`
							, `a`.`is_deadline_updated`
							, `a`.`is_solution_updated`
							, `a`.`is_case_resolved`
							, `a`.`is_case_blocker`
							, `a`.`is_case_critical`
							# - case - messages
							, `a`.`is_any_new_message`
							, `a`.`is_message_from_tenant`
							, `a`.`is_message_from_ll`
							, `a`.`is_message_from_occupant`
							, `a`.`is_message_from_agent`
							, `a`.`is_message_from_mgt_cny`
							, `a`.`is_message_from_contractor`
							# - Inspection Reports
							, `a`.`is_new_ir`
							# - Inventory
							, `a`.`is_new_item`
							, `a`.`is_item_removed`
							, `a`.`is_item_moved`
							FROM `temp_list_users_auto_assign_new_property` AS `a`
							ON DUPLICATE KEY UPDATE
								`syst_updated_datetime` := @syst_created_datetime
								, `update_system_id` := @creation_system_id
								, `updated_by_id` := @requestor_id
								, `update_method` := @creation_method
								, `organization_id` := @organization_id
								, `is_obsolete` := @is_obsolete
								, `is_update_needed` := @is_update_needed
								# Which unit/user
								, `unee_t_mefe_id` := `a`.`mefe_user_id`
								, `unee_t_unit_id` := @unee_t_mefe_unit_id
								# which role
								, `unee_t_role_id` := `a`.`unee_t_role_id`
								, `is_occupant` := `a`.`is_occupant`
								# additional permissions
								, `is_default_assignee` := `a`.`is_default_assignee`
								, `is_default_invited` := `a`.`is_default_invited`
								, `is_unit_owner` := `a`.`is_unit_owner`
								# Visibility rules
								, `is_public` := `a`.`is_public`
								, `can_see_role_landlord` := `a`.`can_see_role_landlord`
								, `can_see_role_tenant` := `a`.`can_see_role_tenant`
								, `can_see_role_mgt_cny` := `a`.`can_see_role_mgt_cny`
								, `can_see_role_agent` := `a`.`can_see_role_agent`
								, `can_see_role_contractor` := `a`.`can_see_role_contractor`
								, `can_see_occupant` := `a`.`can_see_occupant`
								# Notification rules
								# - case - information
								, `is_assigned_to_case` := `a`.`is_assigned_to_case`
								, `is_invited_to_case` := `a`.`is_invited_to_case`
								, `is_next_step_updated` := `a`.`is_next_step_updated`
								, `is_deadline_updated` := `a`.`is_deadline_updated`
								, `is_solution_updated` := `a`.`is_solution_updated`
								, `is_case_resolved` := `a`.`is_case_resolved`
								, `is_case_blocker` := `a`.`is_case_blocker`
								, `is_case_critical` := `a`.`is_case_critical`
								# - case - messages
								, `is_any_new_message` := `a`.`is_any_new_message`
								, `is_message_from_tenant` := `a`.`is_message_from_tenant`
								, `is_message_from_ll` := `a`.`is_message_from_ll`
								, `is_message_from_occupant` := `a`.`is_message_from_occupant`
								, `is_message_from_agent` := `a`.`is_message_from_agent`
								, `is_message_from_mgt_cny` := `a`.`is_message_from_mgt_cny`
								, `is_message_from_contractor` := `a`.`is_message_from_contractor`
								# - Inspection Reports
								, `is_new_ir` := `a`.`is_new_ir`
								# - Inventory
								, `is_new_item` := `a`.`is_new_item`
								, `is_item_removed` := `a`.`is_item_removed`
								, `is_item_moved` := `a`.`is_item_moved`
								;

			END IF;

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
				SELECT
					@syst_created_datetime
					, @creation_system_id
					, @requestor_id
					, @creation_method
					, @organization_id
					, @is_obsolete
					, @is_update_needed
					# Which unit/user
					, `a`.`mefe_user_id`
					, @unee_t_mefe_unit_id
					# which role
					, `a`.`unee_t_role_id`
					, `a`.`is_occupant`
					# additional permissions
					, `a`.`is_default_assignee`
					, `a`.`is_default_invited`
					, `a`.`is_unit_owner`
					# Visibility rules
					, `a`.`is_public`
					, `a`.`can_see_role_landlord`
					, `a`.`can_see_role_tenant`
					, `a`.`can_see_role_mgt_cny`
					, `a`.`can_see_role_agent`
					, `a`.`can_see_role_contractor`
					, `a`.`can_see_occupant`
					# Notification rules
					# - case - information
					, `a`.`is_assigned_to_case`
					, `a`.`is_invited_to_case`
					, `a`.`is_next_step_updated`
					, `a`.`is_deadline_updated`
					, `a`.`is_solution_updated`
					, `a`.`is_case_resolved`
					, `a`.`is_case_blocker`
					, `a`.`is_case_critical`
					# - case - messages
					, `a`.`is_any_new_message`
					, `a`.`is_message_from_tenant`
					, `a`.`is_message_from_ll`
					, `a`.`is_message_from_occupant`
					, `a`.`is_message_from_agent`
					, `a`.`is_message_from_mgt_cny`
					, `a`.`is_message_from_contractor`
					# - Inspection Reports
					, `a`.`is_new_ir`
					# - Inventory
					, `a`.`is_new_item`
					, `a`.`is_item_removed`
					, `a`.`is_item_moved`
					FROM `temp_list_users_auto_assign_new_property` AS `a`
					ON DUPLICATE KEY UPDATE
						`syst_updated_datetime` := @syst_created_datetime
						, `update_system_id` := @creation_system_id
						, `updated_by_id` := @requestor_id
						, `update_method` := @creation_method
						, `organization_id` := @organization_id
						, `is_obsolete` := @is_obsolete
						, `is_update_needed` := @is_update_needed
						# Which unit/user
						, `unee_t_mefe_id` := `a`.`mefe_user_id`
						, `unee_t_unit_id` := @unee_t_mefe_unit_id
						# which role
						, `unee_t_role_id` := `a`.`unee_t_role_id`
						, `is_occupant` := `a`.`is_occupant`
						# additional permissions
						, `is_default_assignee` := `a`.`is_default_assignee`
						, `is_default_invited` := `a`.`is_default_invited`
						, `is_unit_owner` := `a`.`is_unit_owner`
						# Visibility rules
						, `is_public` := `a`.`is_public`
						, `can_see_role_landlord` := `a`.`can_see_role_landlord`
						, `can_see_role_tenant` := `a`.`can_see_role_tenant`
						, `can_see_role_mgt_cny` := `a`.`can_see_role_mgt_cny`
						, `can_see_role_agent` := `a`.`can_see_role_agent`
						, `can_see_role_contractor` := `a`.`can_see_role_contractor`
						, `can_see_occupant` := `a`.`can_see_occupant`
						# Notification rules
						# - case - information
						, `is_assigned_to_case` := `a`.`is_assigned_to_case`
						, `is_invited_to_case` := `a`.`is_invited_to_case`
						, `is_next_step_updated` := `a`.`is_next_step_updated`
						, `is_deadline_updated` := `a`.`is_deadline_updated`
						, `is_solution_updated` := `a`.`is_solution_updated`
						, `is_case_resolved` := `a`.`is_case_resolved`
						, `is_case_blocker` := `a`.`is_case_blocker`
						, `is_case_critical` := `a`.`is_case_critical`
						# - case - messages
						, `is_any_new_message` := `a`.`is_any_new_message`
						, `is_message_from_tenant` := `a`.`is_message_from_tenant`
						, `is_message_from_ll` := `a`.`is_message_from_ll`
						, `is_message_from_occupant` := `a`.`is_message_from_occupant`
						, `is_message_from_agent` := `a`.`is_message_from_agent`
						, `is_message_from_mgt_cny` := `a`.`is_message_from_mgt_cny`
						, `is_message_from_contractor` := `a`.`is_message_from_contractor`
						# - Inspection Reports
						, `is_new_ir` := `a`.`is_new_ir`
						# - Inventory
						, `is_new_item` := `a`.`is_new_item`
						, `is_item_removed` := `a`.`is_item_removed`
						, `is_item_moved` := `a`.`is_item_moved`
						;

	END IF;
END;
$$
DELIMITER ;