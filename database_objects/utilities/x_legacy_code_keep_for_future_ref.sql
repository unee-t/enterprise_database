#################
#
# This lists all the legacy thinsgs that 
#   - we have tried 
#   - we are not using in the current version of the Db Schema
#
#################

##############
#
# Removed from `add_user_to_property_level_2_v1_11_0`
# ---> These were overkill in the context
#
###############


			# We need the MEFE user ID for the MEFE user that will call for that change

				SET @creator_mefe_user_id_add_u_l2_1 := (SELECT `mefe_user_id` 
					FROM `ut_organization_mefe_user_id`
					WHERE `organization_id` = @source_system_creator_add_u_l2_1
					)
					;

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
					WHERE `id_unee_t_user_type` = @unee_t_user_type_id
					);

			# We can now include these into the table for the Level_3 properties

##############
#
# END removal
#
###############







# Create a trigger to fire the lambda to tell the MEFE to create the association
# After update

		DROP TRIGGER IF EXISTS `ut_add_user_to_role_in_unit_with_visibility_update`;

DELIMITER $$
CREATE TRIGGER `ut_add_user_to_role_in_unit_with_visibility_update`
AFTER UPDATE ON `ut_map_user_permissions_unit_all`
FOR EACH ROW
BEGIN

# We only do this IF:
#	- The variable @disable_lambda != 1
#	- The record is not marked as obsolete
#	- The record is marked as update needed
#	- This is done via an authorized method:
#		- 'ut_add_user_to_role_in_unit_with_visibility_level_1'
#		- 'ut_add_user_to_role_in_unit_with_visibility_level_2'
#		- 'ut_add_user_to_role_in_unit_with_visibility_level_3'
#		- ''
#		- ''
#		- ''
#		- ''
#

	SET @upstream_create_method_8_4 = NEW.`creation_method` ;
	SET @upstream_update_method_8_4 = NEW.`update_method` ;

	SET @is_obsolete = NEW.`is_obsolete` ;
	SET @is_update_needed = NEW.`is_update_needed` ;

	IF (@disable_lambda != 1
		OR @disable_lambda IS NULL)
		AND @is_obsolete = 0
		AND @is_update_needed = 1
		AND (@upstream_update_method_8_4 = 'ut_add_user_to_role_in_unit_with_visibility_level_1'
			OR @upstream_update_method_8_4 = 'ut_add_user_to_role_in_unit_with_visibility_level_2'
			OR @upstream_update_method_8_4 = 'ut_add_user_to_role_in_unit_with_visibility_level_3'
			)
	THEN 

		# The specifics

			# What is this trigger (for log_purposes)
				SET @this_trigger_8_4 = 'ut_add_user_to_role_in_unit_with_visibility_update';

			# What is the procedure associated with this trigger:
				SET @associated_procedure = 'lambda_add_user_to_role_in_unit_with_visibility';
			
			# lambda:
			# https://github.com/unee-t/lambda2sns/blob/master/tests/call-lambda-as-root.sh#L5
			#	- DEV/Staging: 812644853088
			#	- Prod: 192458993663
			#	- Demo: 915001051872

				SET @lambda_key = 192458993663;

			# MEFE API Key:
				SET @key_this_envo = 'ABCDEFG';

	# The variables that we need:

		SET @mefe_api_request_id = NEW.`id_map_user_unit_permissions` ;

		SET @action_type = 'ASSIGN_ROLE' ;

		SET @requestor_mefe_user_id = NEW.`created_by_id` ;
		
		SET @invited_mefe_user_id = NEW.`unee_t_mefe_id` ;
		SET @mefe_unit_id = NEW.`unee_t_unit_id` ;
		SET @role_type = (SELECT `role_type`
			FROM `ut_user_role_types`
			WHERE `id_role_type` = NEW.`unee_t_role_id` 
			)
			;
		
		SET @is_occupant = NEW.`is_occupant`= 1 ;
		SET @is_occupant_not_null = (IFNULL(@is_occupant
				, 0
				)
			)
			;
		SET @is_occupant_json = IF(NEW.`is_occupant`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @is_visible = NEW.`is_public`= 1 ;
		SET @is_visible_not_null = (IFNULL(@is_visible
				, 0
				)
			)
			;
		SET @is_visible_json = IF(NEW.`is_public`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @is_default_assignee = NEW.`is_default_assignee`= 1 ;
		SET @is_default_assignee_not_null = (IFNULL(@is_default_assignee
				, 0
				)
			)
			;
		SET @is_default_assignee_json = IF(NEW.`is_default_assignee`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @is_default_invited = NEW.`is_default_invited` ;
		SET @is_default_invited_not_null = (IFNULL(@is_default_invited
				, 0
				)
			)
			;
		SET @is_default_invited_json = IF(NEW.`is_default_invited`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @can_see_role_agent = NEW.`can_see_role_agent`;
		SET @can_see_role_agent_not_null = (IFNULL(@can_see_role_agent
				, 0
				)
			)
			;
		SET @can_see_role_agent_json = IF(NEW.`can_see_role_agent`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @can_see_role_tenant = NEW.`can_see_role_tenant`;
		SET @can_see_role_tenant_not_null = (IFNULL(@can_see_role_tenant
				, 0
				)
			)
			;
		SET @can_see_role_tenant_json = IF(NEW.`can_see_role_tenant`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @can_see_role_landlord = NEW.`can_see_role_landlord`;
		SET @can_see_role_landlord_not_null = (IFNULL(@can_see_role_landlord
				, 0
				)
			)
			;
		SET @can_see_role_landlord_json = IF(NEW.`can_see_role_landlord`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @can_see_role_mgt_cny = NEW.`can_see_role_mgt_cny`;
		SET @can_see_role_mgt_cny_not_null = (IFNULL(@can_see_role_mgt_cny
				, 0
				)
			)
			;
		SET @can_see_role_mgt_cny_json = IF(NEW.`can_see_role_mgt_cny`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @can_see_role_contractor = NEW.`can_see_role_contractor`;
		SET @can_see_role_contractor_not_null = (IFNULL(@can_see_role_contractor
				, 0
				)
			)
			;
		SET @can_see_role_contractor_json = IF(NEW.`can_see_role_contractor`= 1
			, 'true'
			, 'false'
		 	)
			; 

		SET @can_see_occupant = NEW.`can_see_occupant` ; 
		SET @can_see_occupant_not_null = (IFNULL(@can_see_occupant
				, 0
				)
			)
			;
		SET @can_see_occupant_json = IF(NEW.`can_see_occupant`= 1
			, 'true'
			, 'false'
		 	)
			; 
	
	# We insert the event in the relevant log table

		# Simulate what the Procedure `lambda_add_user_to_role_in_unit_with_visibility` does
		# Make sure to update that if you update the procedure `lambda_add_user_to_role_in_unit_with_visibility`

			# The JSON Object:

				SET @json_object = (
					JSON_OBJECT(
						'mefeAPIRequestId' , @mefe_api_request_id
						, 'actionType', @action_type
						, 'requestorUserId', @requestor_mefe_user_id
						, 'addedUserId', @invited_mefe_user_id
						, 'unitId', @mefe_unit_id
						, 'roleType', @role_type
						, 'isOccupant', @is_occupant
						, 'isVisible', @is_visible
						, 'isDefaultAssignee', @is_default_assignee
						, 'isDefaultInvited', @is_default_invited
						, 'roleVisibility' , JSON_OBJECT('Agent', @can_see_role_agent
							, 'Tenant', @can_see_role_tenant
							, 'Owner/Landlord', @can_see_role_landlord
							, 'Management Company', @can_see_role_mgt_cny
							, 'Contractor', @can_see_role_contractor
							, 'Occupant', @can_see_occupant
							)
						)
					)
					;

			# The specific lambda:

				SET @lambda = CONCAT('arn:aws:lambda:ap-southeast-1:'
					, @lambda_key
					, ':function:alambda_simple')
					;
			
			# The specific Lambda CALL:

				SET @lambda_call = CONCAT('CALL mysql.lambda_async'
					, @lambda
					, @json_object
					)
					;

		# Now that we have simulated what the CALL does, we record that

			INSERT INTO `log_lambdas`
				(`created_datetime`
				, `creation_trigger`
				, `associated_call`
				, `mefe_unit_id`
				, `mefe_user_id`
				, `payload`
				)
				VALUES
					(NOW()
					, @this_trigger_8_4
					, @associated_procedure
					, @mefe_unit_id
					, @invited_mefe_user_id
					, @lambda_call
					)
					;
/*
	# We call the Lambda procedure to add a user to a role in a unit

		CALL `lambda_add_user_to_role_in_unit_with_visibility`(@mefe_api_request_id
			, @action_type
			, @requestor_mefe_user_id
			, @invited_mefe_user_id
			, @mefe_unit_id
			, @role_type
			, @is_occupant
			, @is_visible
			, @is_default_assignee
			, @is_default_invited
			, @can_see_role_agent
			, @can_see_role_tenant
			, @can_see_role_landlord
			, @can_see_role_mgt_cny
			, @can_see_role_contractor
			, @can_see_occupant
			)
			;
*/
	END IF;
END;
$$
DELIMITER ;





# Insert the record in the table `ut_map_user_permissions_unit_all` to know what needs to be done

	DROP TRIGGER IF EXISTS `ut_add_user_to_role_in_unit_with_visibility_level_1`;

DELIMITER $$
CREATE TRIGGER `ut_add_user_to_role_in_unit_with_visibility_level_1`
AFTER INSERT ON `ut_map_user_permissions_unit_level_1`
FOR EACH ROW
BEGIN

# We only do this IF
#	- This is done via an authorized insert method:
#		- 'ut_add_user_to_role_in_a_building'
#		- 'ut_add_user_to_role_in_unit_with_visibility_level_1'
#		- ''
#

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;

	IF (@upstream_create_method = 'ut_add_user_to_role_in_a_building'
		OR @upstream_update_method = 'ut_add_user_to_role_in_a_building'
		OR @upstream_create_method = 'ut_add_user_to_role_in_unit_with_visibility_level_1'
		OR @upstream_update_method = 'ut_add_user_to_role_in_unit_with_visibility_level_1'
		)
	THEN 

	# We capture the variables that we need:

		SET @this_trigger = 'ut_add_user_to_role_in_unit_with_visibility_level_1' ;

		SET @syst_created_datetime = NOW() ;
		SET @creation_system_id = NEW.`creation_system_id` ;
		SET @created_by_id = NEW.`created_by_id` ;
		SET @creation_method = @this_trigger ;

		SET @syst_updated_datetime = NOW() ;
		SET @update_system_id = NEW.`creation_system_id` ;
		SET @updated_by_id = NEW.`created_by_id` ;
		SET @update_method = @this_trigger ;

		SET @organization_id = NEW.`organization_id`;

		SET @is_obsolete = NEW.`is_obsolete` ;
		SET @is_update_needed = NULL ;

		SET @unee_t_mefe_id = NEW.`unee_t_mefe_id` ;
		SET @unee_t_unit_id = NEW.`unee_t_unit_id` ;

		SET @system_id_level_1 = (SELECT `new_record_id`
			FROM `ut_map_external_source_units`
			WHERE `unee_t_mefe_unit_id` = @unee_t_unit_id
				AND `external_property_type_id` = 1
			)
			;

		SET @unee_t_role_id = NEW.`unee_t_role_id` ;
		SET @is_occupant = NEW.`is_occupant` ;

		SET @is_default_assignee = NEW.`is_default_assignee` ;
		SET @is_default_invited = NEW.`is_default_invited` ;

		SET @is_unit_owner = NEW.`is_unit_owner` ;

		SET @is_public = NEW.`is_public` ;

		SET @can_see_role_landlord = NEW.`can_see_role_landlord` ;
		SET @can_see_role_tenant = NEW.`can_see_role_tenant` ;
		SET @can_see_role_mgt_cny = NEW.`can_see_role_mgt_cny` ;
		SET @can_see_role_agent = NEW.`can_see_role_agent` ;
		SET @can_see_role_contractor = NEW.`can_see_role_contractor` ;
		SET @can_see_occupant = NEW.`can_see_occupant` ;

		SET @is_assigned_to_case = NEW.`is_assigned_to_case` ;
		SET @is_invited_to_case = NEW.`is_invited_to_case` ;
		SET @is_next_step_updated = NEW.`is_next_step_updated` ;
		SET @is_deadline_updated = NEW.`is_deadline_updated` ;
		SET @is_solution_updated = NEW.`is_solution_updated` ;
		SET @is_case_resolved = NEW.`is_case_resolved` ;

		SET @is_case_blocker = NEW.`is_case_blocker` ;
		SET @is_case_critical = NEW.`is_case_critical` ;

		SET @is_any_new_message = NEW.`is_any_new_message` ;

		SET @is_message_from_tenant = NEW.`is_message_from_tenant` ;
		SET @is_message_from_ll = NEW.`is_message_from_ll` ;
		SET @is_message_from_occupant = NEW.`is_message_from_occupant` ;
		SET @is_message_from_agent = NEW.`is_message_from_agent` ;
		SET @is_message_from_mgt_cny = NEW.`is_message_from_mgt_cny` ;
		SET @is_message_from_contractor = NEW.`is_message_from_contractor` ;

		SET @is_new_ir = NEW.`is_new_ir` ;

		SET @is_new_item = NEW.`is_new_item` ;
		SET @is_item_removed = NEW.`is_item_removed` ;
		SET @is_item_moved = NEW.`is_item_moved` ;

		SET @propagate_to_all_level_2_add_u_l1_1 = NEW.`propagate_to_all_level_2` ;
		SET @propagate_to_all_level_3_add_u_l1_1 = NEW.`propagate_to_all_level_3` ;

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
			VALUES
				(@syst_created_datetime
				, @creation_system_id
				, @created_by_id
				, @creation_method
				, @organization_id
				, @is_obsolete
				, @is_update_needed
				, @unee_t_mefe_id
				, @unee_t_unit_id
				, @unee_t_role_id
				, @is_occupant
				, @is_default_assignee
				, @is_default_invited
				, @is_unit_owner
				, @is_public
				, @can_see_role_landlord
				, @can_see_role_tenant
				, @can_see_role_mgt_cny
				, @can_see_role_agent
				, @can_see_role_contractor
				, @can_see_occupant
				, @is_assigned_to_case
				, @is_invited_to_case
				, @is_next_step_updated
				, @is_deadline_updated
				, @is_solution_updated
				, @is_case_resolved
				, @is_case_blocker
				, @is_case_critical
				, @is_any_new_message
				, @is_message_from_tenant
				, @is_message_from_ll
				, @is_message_from_occupant
				, @is_message_from_agent
				, @is_message_from_mgt_cny
				, @is_message_from_contractor
				, @is_new_ir
				, @is_new_item
				, @is_item_removed
				, @is_item_moved
				)
			ON DUPLICATE KEY UPDATE
				`syst_updated_datetime` = @syst_updated_datetime
				, `update_system_id` = @update_system_id
				, `updated_by_id` = @updated_by_id
				, `update_method` = @update_method
				, `organization_id` = @organization_id
				, `is_obsolete` = @is_obsolete
				, `is_update_needed` = 1
				, `unee_t_mefe_id` = @unee_t_mefe_id
				, `unee_t_unit_id` = @unee_t_unit_id
				, `unee_t_role_id` = @unee_t_role_id
				, `is_occupant` = @is_occupant
				, `is_default_assignee` = @is_default_assignee
				, `is_default_invited` = @is_default_invited
				, `is_unit_owner` = @is_unit_owner
				, `is_public` = @is_public
				, `can_see_role_landlord` = @can_see_role_landlord
				, `can_see_role_tenant` = @can_see_role_tenant
				, `can_see_role_mgt_cny` = @can_see_role_mgt_cny
				, `can_see_role_agent` = @can_see_role_agent
				, `can_see_role_contractor` = @can_see_role_contractor
				, `can_see_occupant` = @can_see_occupant
				, `is_assigned_to_case` = @is_assigned_to_case
				, `is_invited_to_case` = @is_invited_to_case
				, `is_next_step_updated` = @is_next_step_updated
				, `is_deadline_updated` = @is_deadline_updated
				, `is_solution_updated` = @is_solution_updated
				, `is_case_resolved` = @is_case_resolved
				, `is_case_blocker` = @is_case_blocker
				, `is_case_critical` = @is_case_critical
				, `is_any_new_message` = @is_any_new_message
				, `is_message_from_tenant` = @is_message_from_tenant
				, `is_message_from_ll` = @is_message_from_ll
				, `is_message_from_occupant` = @is_message_from_occupant
				, `is_message_from_agent` = @is_message_from_agent
				, `is_message_from_mgt_cny` = @is_message_from_mgt_cny
				, `is_message_from_contractor` = @is_message_from_contractor
				, `is_new_ir` = @is_new_ir
				, `is_new_item` = @is_new_item
				, `is_item_removed` = @is_item_removed
				, `is_item_moved` = @is_item_moved
				;


		# We flush the variables:

			SET @this_trigger = NULL ;


/*
	# Check if we have marked this as something we need to propagate to the Units/flats in this building

		IF @propagate_to_all_level_2 = 1
		THEN 

			INSERT INTO `ut_map_user_permissions_unit_level_2`
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
				, `propagate_to_all_level_3`
				)
				SELECT @syst_created_datetime
					, @creation_system_id
					, @created_by_id
					, @creation_method
					, @organization_id
					, @is_obsolete
					, @is_update_needed
					, @unee_t_mefe_id
					, (SELECT `unee_t_mefe_unit_id`
						FROM `ut_check_unee_t_updates_property_level_2` AS `b`
						WHERE `b`.`system_id_unit` = `a`.`system_id_unit`
						)
					, @unee_t_role_id
					, @is_occupant
					, @is_default_assignee
					, @is_default_invited
					, @is_unit_owner
					, @is_public
					, @can_see_role_landlord
					, @can_see_role_tenant
					, @can_see_role_mgt_cny
					, @can_see_role_agent
					, @can_see_role_contractor
					, @can_see_occupant
					, @is_assigned_to_case
					, @is_invited_to_case
					, @is_next_step_updated
					, @is_deadline_updated
					, @is_solution_updated
					, @is_case_resolved
					, @is_case_blocker
					, @is_case_critical
					, @is_any_new_message
					, @is_message_from_tenant
					, @is_message_from_ll
					, @is_message_from_occupant
					, @is_message_from_agent
					, @is_message_from_mgt_cny
					, @is_message_from_contractor
					, @is_new_ir
					, @is_new_item
					, @is_item_removed
					, @is_item_moved
					, @propagate_to_all_level_3_add_u_l1_1
					FROM `property_level_2_units` AS `a`
						WHERE `a`.`building_system_id` = @system_id_level_1
							AND (SELECT `unee_t_mefe_unit_id`
								FROM `ut_check_unee_t_updates_property_level_2` AS `b`
								WHERE `b`.`system_id_unit` = `a`.`system_id_unit`
								) IS NOT NULL
					;

		END IF;
*/
	END IF;
END;
$$
DELIMITER ;


# Create the trigger to insert record in the table `ut_map_external_source_users`:
# Event: A person 
#	- is updated
# AND
#	- the person needs to be created in Unee-T
#	- was NOT marked as `is_creation_needed_in_unee_t` before
#	- we have an email address
#	- This is done via an authorized update method:
#		- `ut_insert_external_person`
#		- `ut_update_external_person_not_ut_user_type`
#		- `ut_update_external_person_ut_user_type`
#		- ''
#		- ''
#		- ''

	DROP TRIGGER IF EXISTS `ut_update_map_uneet_user_person_ut_account_creation_needed`;

DELIMITER $$
CREATE TRIGGER `ut_update_map_uneet_user_person_ut_account_creation_needed`
AFTER UPDATE ON `persons`
FOR EACH ROW
BEGIN

# We only do this IF:
#	- the person needs to be created in Unee-T
#	- was NOT marked as `is_creation_needed_in_unee_t` before
#	- we have an email address
#	- This is done via an authorized update method:
#		- 'ut_insert_external_person'
#		- 'ut_update_external_person_not_ut_user_type'
#		- 'ut_update_external_person_ut_user_type'
#		- ''
#		- ''

	SET @is_unee_t_account_needed_up_1 := NEW.`is_unee_t_account_needed`;

	SET @new_is_unee_t_account_needed_up_1 := NEW.`is_unee_t_account_needed`;
	SET @old_is_unee_t_account_needed_up_1 := OLD.`is_unee_t_account_needed`;

	SET @email_up_1 := NEW.`email`;

	SET @upstream_create_method_up_1 := NEW.`creation_method` ;
	SET @upstream_update_method_up_1 := NEW.`update_method` ;

	IF @is_unee_t_account_needed_up_1 = 1
		AND @new_is_unee_t_account_needed_up_1 != @old_is_unee_t_account_needed_up_1 
		AND @email_up_1 IS NOT NULL
		AND (@upstream_create_method_up_1 = 'ut_insert_external_person'
			OR @upstream_update_method_up_1 = 'ut_insert_external_person'
			OR @upstream_create_method_up_1 = 'ut_update_external_person_not_ut_user_type'
			OR @upstream_update_method_up_1 = 'ut_update_external_person_not_ut_user_type'
			OR @upstream_create_method_up_1 = 'ut_update_external_person_ut_user_type'
			OR @upstream_update_method_up_1 = 'ut_update_external_person_ut_user_type'
		  	)
	THEN 

	# We capture the values we need for the insert/udpate:

		SET @this_trigger_up_1 := 'ut_update_map_uneet_user_person_ut_account_creation_needed' ;

		SET @syst_created_datetime_up_1 := NOW();
		SET @creation_system_id_up_1 := NEW.`update_system_id`;
		SET @created_by_id_up_1 := NEW.`updated_by_id`;
		SET @creation_method_up_1 := @this_trigger ;

		SET @syst_updated_datetime_up_1 := NOW();
		SET @update_system_id_up_1 := NEW.`update_system_id`;
		SET @updated_by_id_up_1 := NEW.`updated_by_id`;
		SET @update_method_up_1 := @this_trigger ;

		SET @organization_id_up_1 := NEW.`organization_id`;

		SET @is_obsolete_up_1 := 0 ;
		SET @is_update_needed_up_1 := 1 ;

		SET @uneet_login_name_up_1 := NEW.`email`;

		SET @external_person_id_up_1 := NEW.`external_id`;
		SET @external_system_up_1 := NEW.`external_system`;
		SET @table_in_external_system_up_1 := NEW.`external_table`;
		SET @person_id_up_1 := (SELECT `id_person` 
			FROM `persons`
			WHERE `external_id` = @external_person_id_up_1
				AND `external_system` = @external_system_up_1
				AND `external_table` = @table_in_external_system_up_1
				AND `organization_id` = @organization_id_up_1
			)
			;

		# We insert a new record in the table `ut_map_external_source_users`

			INSERT INTO `ut_map_external_source_users`
				( `syst_created_datetime`
				, `creation_system_id`
				, `created_by_id`
				, `creation_method`
				, `organization_id`
				, `is_update_needed`
				, `person_id`
				, `uneet_login_name`
				, `external_person_id`
				, `external_system`
				, `table_in_external_system`
				)
				VALUES
					(@syst_created_datetime_up_1
					, @creation_system_id_up_1
					, @created_by_id_up_1
					, @creation_method_up_1
					, @organization_id_up_1
					, @is_update_needed_up_1
					, @person_id_up_1
					, @uneet_login_name_up_1
					, @external_person_id_up_1
					, @external_system_up_1
					, @table_in_external_system_up_1
					)
					 ON DUPLICATE KEY UPDATE
						`syst_updated_datetime` := @syst_updated_datetime_up_1
						, `update_system_id` := @update_system_id_up_1
						, `updated_by_id` := @updated_by_id_up_1
						, `update_method` := @update_method_up_1
						, `organization_id` := @organization_id_up_1
						, `uneet_login_name` := @uneet_login_name_up_1
						, `is_update_needed` := @is_update_needed_up_1
				;
	END IF;
END;
$$
DELIMITER ;


# Update the user information

	# When a Person record is updated, create a trigger to update the table `ut_map_external_source_users`

		DROP TRIGGER IF EXISTS `ut_person_has_been_updated_and_ut_account_needed`;

DELIMITER $$
CREATE TRIGGER `ut_person_has_been_updated_and_ut_account_needed`
AFTER UPDATE ON `persons`
FOR EACH ROW
BEGIN

# We only do this IF
#	- We need to create the Unee-T account
#	- There was NO change to the fact that we need to create a Unee-T account
#	- We have an email address
#	- This is done via an authorized insert method:
#		- 'ut_insert_external_person'
#		- 'ut_update_external_person_not_ut_user_type'
#		- 'ut_update_external_person_ut_user_type'
#		- ''
#		- ''
#
	
	SET @is_unee_t_account_needed_up_2 := NEW.`is_unee_t_account_needed`;

	SET @new_is_unee_t_account_needed_up_2 := NEW.`is_unee_t_account_needed`;
	SET @old_is_unee_t_account_needed_up_2 := OLD.`is_unee_t_account_needed`;
	
	SET @email_up_2 := NEW.`email`;

	SET @upstream_create_method_up_2 := NEW.`creation_method` ;
	SET @upstream_update_method_up_2 := NEW.`update_method` ;

	IF @is_unee_t_account_needed_up_2 = 1
		AND @old_is_unee_t_account_needed_up_2 = @new_is_unee_t_account_needed
        AND @email_up_2 IS NOT NULL
		AND (@upstream_create_method_up_2 = 'ut_insert_external_person'
			OR @upstream_update_method_up_2 = 'ut_insert_external_person'
			OR @upstream_create_method_up_2 = 'ut_update_external_person_not_ut_user_type'
			OR @upstream_update_method_up_2 = 'ut_update_external_person_not_ut_user_type'
			OR @upstream_create_method_up_2 = 'ut_update_external_person_ut_user_type'
			OR @upstream_update_method_up_2 = 'ut_update_external_person_ut_user_type'
			)
	THEN 

	# We capture the values we need for the insert/udpate:

		SET @this_trigger := 'ut_person_has_been_updated_and_ut_account_needed' ;

		SET @syst_created_datetime := NOW();
		SET @creation_system_id := NEW.`update_system_id`;
		SET @requestor_id := NEW.`updated_by_id`;

		SET @syst_updated_datetime := NOW();
		SET @update_system_id := NEW.`update_system_id`;
		SET @updated_by_id := NEW.`updated_by_id`;

		SET @organization_id := NEW.`organization_id` ;

		SET @uneet_login_name := NEW.`email`;

		SET @external_person_id := NEW.`external_id`;
		SET @external_system := NEW.`external_system`;
		SET @table_in_external_system := NEW.`external_table`;

        SET @person_id := (SELECT `id_person` 
            FROM `persons`
            WHERE `external_id` = @external_person_id
            	AND `external_system` = @external_system
				AND `external_table` = @table_in_external_system
				AND `organization_id` = @organization_id
            )
            ;
		
		# We update the existing record in the table `ut_map_external_source_users`

			UPDATE `ut_map_external_source_users`
				SET
                    `syst_updated_datetime` := @syst_updated_datetime
					, `update_system_id` := @update_system_id
					, `updated_by_id` := @updated_by_id
					, `update_method` := 'ut_person_has_been_updated_and_ut_account_needed'
					, `organization_id` := @organization_id
					, `is_update_needed` := 1
                    , `uneet_login_name` := @uneet_login_name
				WHERE `person_id` = @person_id
				;

		# We call the procedure that calls the lambda to update the user record in Unee-T

			CALL `ut_update_user`;

	END IF;
END;
$$
DELIMITER ;



# Trigger to CREATE the default permissions for a given user
# IF (and ONLY IF)
#	- there was a change in the table `ut_map_external_source_users`
#		- The change was made by the method:
#			- 'ut_creation_success_mefe_user_id'
#		- AND old MEFE user id is != new MEFE user id
#		    There are 2 scenarios:
#			1- Previous MEFE user ID was NOT NULL
#			   ---> this NEVER happens, we can safely ignore this scenario
#                - Check if user type is not NULL
#			   	- We Delete the existing default preferences for the old MEFE user ID
#                - We Create the default preferences for the new MEFE user ID
#			   ---> END - scenario we can ignore.
#			2- Previous MEFE user ID WAS NULL
#                IF the user type is NOT NULL
# THEN we create an entry in the table `ut_map_user_permissions_default`

		DROP TRIGGER IF EXISTS `ut_create_record_map_user_permissions_default`;

DELIMITER $$
CREATE TRIGGER `ut_create_record_map_user_permissions_default`
AFTER UPDATE ON `ut_map_external_source_users`
FOR EACH ROW
BEGIN

# We only need to do this IF
#	- We need to create the user in Unee-T
#	- We have a MEFE User ID
#	- We have a user type
# 	- This is a valid update method:
#		- 'ut_creation_success_mefe_user_id'
#		- ''
#		- ''
#		- ''
#		- ''

	SET @source_system_creator = NEW.`created_by_id` ;
	SET @source_system_updater = NEW.`updated_by_id`;

	SET @mefe_user_id = NEW.`unee_t_mefe_user_id` ;

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;

	SET @person_id = NEW.`person_id` ;

	SET @unee_t_user_type_id = (SELECT `unee_t_user_type_id`
		FROM `persons`
		WHERE `id_person` = @person_id
		)
		;

	IF @mefe_user_id IS NOT NULL
		AND @unee_t_user_type_id IS NOT NULL
		AND @upstream_update_method = 'ut_creation_success_mefe_user_id'
	THEN 

	# We capture the values we need for the insert/udpate:

		SET @this_trigger = 'ut_create_record_map_user_permissions_default' ;

		SET @organization_id_create = @source_system_creator ;
		SET @organization_id_update = @source_system_updater;

		SET @organization_id = NEW.`organization_id` ;

		SET @syst_created_datetime = NOW() ;
		SET @creation_system_id =  (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
    		WHERE `organization_id` = @organization_id
            )
            ;
		SET @created_by_id = @creator_mefe_user_id ;
		SET @downstream_creation_method = @this_trigger ;

		SET @syst_updated_datetime = NOW();
		SET @update_system_id = @creation_system_id ;
		SET @updated_by_id = NEW.`updated_by_id` ;
		SET @downstream_update_method = @this_trigger ;

		SET @is_occupant = (SELECT `is_occupant` 
            FROM `ut_user_types` 
            WHERE `id_unee_t_user_type` = @unee_t_user_type_id
            ) ;
		SET @is_public = (SELECT `is_public` 
        	FROM `ut_user_types` 
            WHERE `id_unee_t_user_type` = @unee_t_user_type_id
            ) ;
		SET @is_default_assignee = (SELECT `is_default_assignee` 
            FROM `ut_user_types` 
            WHERE `id_unee_t_user_type` = @unee_t_user_type_id) ;
		SET @is_default_invited = (SELECT `is_default_invited` 
            FROM `ut_user_types` 
            WHERE `id_unee_t_user_type` = @unee_t_user_type_id) ;
		SET @is_dashboard_access = (SELECT `is_dashboard_access` 
        	FROM `ut_user_types`
            WHERE `id_unee_t_user_type` = @unee_t_user_type_id
            ) ;

		SET @can_see_role_contractor = (SELECT `can_see_role_contractor` 
        	FROM `ut_user_types` 
		    WHERE `id_unee_t_user_type` = @unee_t_user_type_id
		    ) ;
		SET @can_see_role_mgt_cny = (SELECT `can_see_role_mgt_cny` 
		    FROM `ut_user_types`
		    WHERE `id_unee_t_user_type` = @unee_t_user_type_id
		    ) ;
		SET @can_see_occupant = (SELECT `can_see_occupant` 
        	FROM `ut_user_types` 
        	WHERE `id_unee_t_user_type` = @unee_t_user_type_id
        	) ;
		SET @can_see_role_landlord = (SELECT `can_see_role_landlord` 
        	FROM `ut_user_types` 
        	WHERE `id_unee_t_user_type` = @unee_t_user_type_id
        	) ;
		SET @can_see_role_agent = (SELECT `can_see_role_agent` 
        	FROM `ut_user_types` 
        	WHERE `id_unee_t_user_type` = @unee_t_user_type_id
        	) ;
		SET @can_see_role_tenant = (SELECT `can_see_role_tenant` 
        	FROM `ut_user_types` 
        	WHERE `id_unee_t_user_type` = @unee_t_user_type_id
        	) ;
        	
		SET @is_assigned_to_case = (SELECT `is_assigned_to_case` 
        	FROM `ut_user_types` 
        	WHERE `id_unee_t_user_type` = @unee_t_user_type_id
        	) ;
		SET @is_invited_to_case = (SELECT `is_invited_to_case` 
        	FROM `ut_user_types` 
        	WHERE `id_unee_t_user_type` = @unee_t_user_type_id
        	) ;
		SET @is_solution_updated = (SELECT `is_solution_updated` 
        	FROM `ut_user_types` 
        	WHERE `id_unee_t_user_type` = @unee_t_user_type_id
        	) ;
		SET @is_next_step_updated = (SELECT `is_next_step_updated` 
        	FROM `ut_user_types` 
        	WHERE `id_unee_t_user_type` = 
        	@unee_t_user_type_id
        	) ;
		SET @is_deadline_updated = (SELECT `is_deadline_updated` 
        	FROM `ut_user_types` 
        	WHERE `id_unee_t_user_type` = @unee_t_user_type_id
        	) ;
		SET @is_case_resolved = (SELECT `is_case_resolved` 
        	FROM `ut_user_types` 
        	WHERE `id_unee_t_user_type` = @unee_t_user_type_id
        	) ;
		SET @is_case_critical = (SELECT `is_case_critical` 
        	FROM `ut_user_types` 
        	WHERE `id_unee_t_user_type` = @unee_t_user_type_id
        	) ;
		SET @is_case_blocker = (SELECT `is_case_blocker` 
        	FROM `ut_user_types` 
        	WHERE `id_unee_t_user_type` = @unee_t_user_type_id
        	) ;
        	
		SET @is_message_from_contractor = (SELECT `is_message_from_contractor` 
        	FROM `ut_user_types` 
        	WHERE `id_unee_t_user_type` = @unee_t_user_type_id
        	) ;
		SET @is_message_from_mgt_cny = (SELECT `is_message_from_mgt_cny` 
        	FROM `ut_user_types`
        	WHERE `id_unee_t_user_type` = @unee_t_user_type_id
        	) ;
		SET @is_message_from_agent = (SELECT `is_message_from_agent` 
        	FROM `ut_user_types` 
        	WHERE `id_unee_t_user_type` = @unee_t_user_type_id
        	) ;
		SET @is_message_from_occupant = (SELECT `is_message_from_occupant` 
        	FROM `ut_user_types` 
        	WHERE `id_unee_t_user_type` = @unee_t_user_type_id
        	) ;
		SET @is_message_from_ll = (SELECT `is_message_from_ll` 
        	FROM `ut_user_types` 
        	WHERE `id_unee_t_user_type` = @unee_t_user_type_id
        	) ;
		SET @is_message_from_tenant = (SELECT `is_message_from_tenant` 
        	FROM `ut_user_types` 
        	WHERE `id_unee_t_user_type` = @unee_t_user_type_id
        	) ;
		
		SET @is_new_ir = (SELECT `is_new_ir` 
        	FROM `ut_user_types` 
        	WHERE `id_unee_t_user_type` = @unee_t_user_type_id
        	) ;
		SET @is_new_inventory = (SELECT `is_new_inventory` 
        	FROM `ut_user_types` 
        	WHERE `id_unee_t_user_type` = @unee_t_user_type_id
        	) ;
		SET @is_new_item = (SELECT `is_new_item` 
        	FROM `ut_user_types` 
        	WHERE `id_unee_t_user_type` = @unee_t_user_type_id
        	) ;
		SET @is_item_moved = (SELECT `is_item_moved` 
        	FROM `ut_user_types` WHERE `id_unee_t_user_type` = @unee_t_user_type_id
        	) ;
		SET @is_item_removed = (SELECT `is_item_removed` 
        	FROM `ut_user_types` 
        	WHERE `id_unee_t_user_type` = @unee_t_user_type_id
        	) ;

		# We have the values we need. We can insert now

			INSERT INTO `ut_map_user_permissions_default`
                ( `syst_created_datetime`
                , `creation_system_id`
                , `created_by_id`
                , `creation_method`
                , `organization_id`
                , `person_id`
                , `unee_t_user_type_id`
                , `is_occupant`
                , `is_public`
                , `is_default_assignee`
                , `is_default_invited`
                , `is_dashboard_access`
                , `can_see_role_contractor`
                , `can_see_role_mgt_cny`
                , `can_see_occupant`
                , `can_see_role_landlord`
                , `can_see_role_agent`
                , `can_see_role_tenant`
                , `is_assigned_to_case`
                , `is_invited_to_case`
                , `is_solution_updated`
                , `is_next_step_updated`
                , `is_deadline_updated`
                , `is_case_resolved`
                , `is_case_critical`
                , `is_case_blocker`
                , `is_message_from_contractor`
                , `is_message_from_mgt_cny`
                , `is_message_from_agent`
                , `is_message_from_occupant`
                , `is_message_from_ll`
                , `is_message_from_tenant`
                , `is_new_ir`
                , `is_new_inventory`
                , `is_new_item`
                , `is_item_moved`
                , `is_item_removed`
                )
                VALUES
                	(@syst_created_datetime
                	, @creation_system_id
                	, @created_by_id
                	, @downstream_creation_method
                	, @organization_id
                	, @person_id
                	, @unee_t_user_type_id
                	, @is_occupant
                	, @is_public
                	, @is_default_assignee
                	, @is_default_invited
                	, @is_dashboard_access
                	, @can_see_role_contractor
                	, @can_see_role_mgt_cny
                	, @can_see_occupant
                	, @can_see_role_landlord
                	, @can_see_role_agent
                	, @can_see_role_tenant
                	, @is_assigned_to_case
                	, @is_invited_to_case
                	, @is_solution_updated
                	, @is_next_step_updated
                	, @is_deadline_updated
                	, @is_case_resolved
                	, @is_case_critical
                	, @is_case_blocker
                	, @is_message_from_contractor
                	, @is_message_from_mgt_cny
                	, @is_message_from_agent
                	, @is_message_from_occupant
                	, @is_message_from_ll
                	, @is_message_from_tenant
                	, @is_new_ir
                	, @is_new_inventory
                	, @is_new_item
                	, @is_item_moved
                	, @is_item_removed
                	)
                	ON DUPLICATE KEY UPDATE
                	# the key for the table `ut_map_user_permissions_default` is the `person_id`
                		`syst_updated_datetime` = @syst_updated_datetime
                		, `update_system_id` = @update_system_id
                		, `updated_by_id` = @updated_by_id
                		, `update_method` = @downstream_update_method
                		, `organization_id` = @organization_id
                		, `is_obsolete` = @is_obsolete
                		, `unee_t_user_type_id` = @unee_t_user_type_id
                		, `is_occupant` = @is_occupant
                		, `is_public` = @is_public
                		, `is_default_assignee` = @is_default_assignee
                		, `is_default_invited` = @is_default_invited
                		, `is_dashboard_access` = @is_dashboard_access
                		, `can_see_role_contractor` = @can_see_role_contractor
                		, `can_see_role_mgt_cny` = @can_see_role_mgt_cny
                		, `can_see_occupant` = @can_see_occupant
                		, `can_see_role_landlord` = @can_see_role_landlord
                		, `can_see_role_agent` = @can_see_role_agent
                		, `can_see_role_tenant` = @can_see_role_tenant
                		, `is_assigned_to_case` = @is_assigned_to_case
                		, `is_invited_to_case` = @is_invited_to_case
                		, `is_solution_updated` = @is_solution_updated
                		, `is_next_step_updated` = @is_next_step_updated
                		, `is_deadline_updated` = @is_deadline_updated
                		, `is_case_resolved` = @is_case_resolved
                		, `is_case_critical` = @is_case_critical
                		, `is_case_blocker` = @is_case_blocker
                		, `is_message_from_contractor` = @is_message_from_contractor
                		, `is_message_from_mgt_cny` = @is_message_from_mgt_cny
                		, `is_message_from_agent` = @is_message_from_agent
                		, `is_message_from_occupant` = @is_message_from_occupant
                		, `is_message_from_ll` = @is_message_from_ll
                		, `is_message_from_tenant` = @is_message_from_tenant
                		, `is_new_ir` = @is_new_ir
                		, `is_new_inventory` = @is_new_inventory
                		, `is_new_item` = @is_new_item
                		, `is_item_moved` = @is_item_moved
                		, `is_item_removed` = @is_item_removed
                	;
	END IF;
END;
$$
DELIMITER ;
