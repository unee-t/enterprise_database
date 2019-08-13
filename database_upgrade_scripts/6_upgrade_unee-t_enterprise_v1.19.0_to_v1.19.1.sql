#
# For any question about this script, ask Franck
#
####################################################################################
#
# We MUST use at least Aurora MySQl 5.7.22+ if you want 
# to be able to use the Lambda function Unee-T depends on to work as intended
#
# Alternativey if you do NOT need to use the Lambda function, it is possible to use
#	- MySQL 5.7.22 +
#	- MariaDb 10.2.3 +
#
####################################################################################
#
####################################################
#i
# Make sure to 
#	- update the below variable(s)
#
# For easier readability and maintenance, we use dedicated scripts to 
# Create or update:
#	- Views
#	- Procedures
#	- Triggers
#	- Lambda related objects for the relevant environments
#
# Make sure to run all these scripts too!!!
#
####################################################
#
# What are the version of the Unee-T BZ Database schema BEFORE and AFTER this update?

	SET @old_schema_version := 'v1.19.0';
	SET @new_schema_version := 'v1.19.1';

# What is the name of this script?

	SET @this_script := CONCAT ('upgrade_unee-t_entreprise', @old_schema_version, '_to_', @new_schema_version, '.sql');

# In this update
# Bug fix - typo in a trigger
#	- `ut_add_user_to_role_in_a_level_3_property`
#
# - Create new tables
#	- ``
#	- ``
#
# - Drop tables we do not need anymore
#	- ``
#	- ``
#
# - Alter a existing tables
#	- Add indexes for improved performances 
#		- ``
#		- ``
#	- Rebuild index for better performances
#		- ``
#		- ``
#	- Remove unnecessary columns
#		- ``
#		- ``
#	- Add a new column
#		- ``
#		- ``
#	- Make sure that, in a given organization, the main email for a person is unique
#		- `external_persons`
#		- `persons`
#
# - Drop Views:
#	- ``
#	- ``
#
# - Drop procedures :
#	- ``
#	- ``
#	- ``
#
# - Drop triggers:
#	- ``
#	- ``
#
#
###############################
#
# We have everything we need - Do it!
#
###############################

# When are we doing this?

	SET @the_timestamp := NOW();

# Do the changes:

# Bug fix - typo in a trigger

	# Assign user to an Level_3 property (room) 
	# Insert the record in the tables
	#	- `ut_map_user_permissions_unit_level_3`

		DROP TRIGGER IF EXISTS `ut_add_user_to_role_in_a_level_3_property`;

DELIMITER $$
CREATE TRIGGER `ut_add_user_to_role_in_a_level_3_property`
AFTER INSERT ON `external_map_user_unit_role_permissions_level_3`
FOR EACH ROW
BEGIN

	# We only do this IF
	#	- We have a MEFE user ID for the creator of that record
	#	- This is not an obsolete request
	#	- We have a MEFE user ID for the user that we are adding
	#	- We have a role_type
	#	- We have a user_type
	#	- We have an organization ID
	#	- This is done via an authorized insert method:
	#		- 'Assign_Rooms_to_Users_Add_Page'
	#		- 'Assign_Rooms_to_Users_Import_Page'
	#		- 'imported_from_hmlet_ipi'
	#		- ''
	#		- ''
	#

		SET @source_system_creator_add_u_l3_1 = NEW.`created_by_id` ;
		SET @source_system_updater_add_u_l3_1 = NEW.`updated_by_id`;

		SET @creator_mefe_user_id_add_u_l3_1 = (SELECT `mefe_user_id` 
			FROM `ut_organization_mefe_user_id`
			WHERE `organization_id` = @source_system_creator_add_u_l3_1
			)
			;

		SET @upstream_create_method_add_u_l3_1 = NEW.`creation_method` ;
		SET @upstream_update_method_add_u_l3_1 = NEW.`update_method` ;

		SET @organization_id = NEW.`organization_id` ;

		SET @is_obsolete = NEW.`is_obsolete` ;

		SET @unee_t_level_3_id = NEW.`unee_t_level_3_id` ;

		SET @unee_t_mefe_user_id = NEW.`unee_t_mefe_user_id` ;
		SET @unee_t_user_type_id = NEW.`unee_t_user_type_id` ;
		SET @unee_t_role_id = NEW.`unee_t_role_id` ;

		IF @source_system_creator_add_u_l3_1 IS NOT NULL
			AND @organization_id IS NOT NULL
			AND @is_obsolete = 0
			AND @unee_t_mefe_user_id IS NOT NULL
			AND @unee_t_user_type_id IS NOT NULL
			AND @unee_t_role_id IS NOT NULL
			AND (@upstream_create_method_add_u_l3_1 = 'Assign_Rooms_to_Users_Add_Page'
				OR @upstream_update_method_add_u_l3_1 = 'Assign_Rooms_to_Users_Add_Page'
				OR @upstream_create_method_add_u_l3_1 = 'Assign_Rooms_to_Users_Import_Page'
				OR @upstream_update_method_add_u_l3_1 = 'Assign_Rooms_to_Users_Import_Page'
				OR @upstream_create_method_add_u_l3_1 = 'imported_from_hmlet_ipi'
				OR @upstream_update_method_add_u_l3_1 = 'imported_from_hmlet_ipi'
				)
		THEN 

		# We capture the variables that we need:

			SET @this_trigger = 'ut_add_user_to_role_in_a_level_3_property' ;

			SET @syst_created_datetime = NOW() ;
			SET @creation_system_id = 2 ;
			SET @created_by_id_add_u_l3_1 = @source_system_creator_add_u_l3_1 ;
			SET @creation_method = @this_trigger ;

			SET @syst_updated_datetime = NOW() ;
			SET @update_system_id = 2 ;
			SET @updated_by_id_add_u_l3_1 = @source_system_updater_add_u_l3_1 ;
			SET @update_method = @this_trigger ;

			SET @is_obsolete = NEW.`is_obsolete` ;
			SET @is_update_needed = 1 ;

		# We insert these permissions in the table `ut_map_user_permissions_unit_level_3`

		# We need the MEFE unit_id for each of the level_3 properties:

			SET @unee_t_mefe_unit_id = (SELECT `unee_t_mefe_unit_id`
				FROM `ut_list_mefe_unit_id_level_3_by_area`
				WHERE `level_3_room_id` = @unee_t_level_3_id
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
						(@syst_created_datetime
						, @creation_system_id
						, @creator_mefe_user_id_add_u_l3_1
						, @creation_method
						, @organization_id
						, @is_obsolete
						, @is_update_needed
						# Which unit/user
						, @unee_t_mefe_user_id
						, @unee_t_mefe_unit_id
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
						)
						;

	END IF;
END;
$$
DELIMITER ;

# We can now update the version of the database schema
	# A comment for the update
		SET @comment_update_schema_version := CONCAT (
			'Database updated from '
			, @old_schema_version
			, ' to '
			, @new_schema_version
		)
		;
	
	# We record that the table has been updated to the new version.
	INSERT INTO `db_schema_version`
		(`schema_version`
		, `update_datetime`
		, `update_script`
		, `comment`
		)
		VALUES
		(@new_schema_version
		, @the_timestamp
		, @this_script
		, @comment_update_schema_version
		)
		;