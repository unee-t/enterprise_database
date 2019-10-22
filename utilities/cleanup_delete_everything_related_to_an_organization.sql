# This script removes all records related to a given organization in the UNTE database:

# Define the organization we need to remove:

	SET @organization_to_remove = 7 ;

# Make sure we remove all default values:

	UPDATE `uneet_enterprise_organizations`
		SET 
			`default_sot_id` = NULL
			, `default_area` = NULL
			, `default_building` = NULL
			, `default_unit` = NULL
			, `default_role_type_id` = NULL
			, `default_assignee_agent` = NULL
			, `default_assignee_landlord` = NULL
			, `default_assignee_mgt_cny` = NULL
			, `default_assignee_tenant` = NULL
		WHERE `id_organization` = @organization_to_remove
		;

# Delete the records:

	# Associations user/unit:

		DELETE FROM `external_map_user_unit_role_permissions_areas` 
			WHERE `created_by_id` = @organization_to_remove
			;

		DELETE FROM `external_map_user_unit_role_permissions_level_3` 
			WHERE `created_by_id` = @organization_to_remove
			;

		DELETE FROM `external_map_user_unit_role_permissions_level_2` 
			WHERE `created_by_id` = @organization_to_remove
			;

		DELETE FROM `external_map_user_unit_role_permissions_level_1` 
			WHERE `created_by_id` = @organization_to_remove
			;

		DELETE FROM `ut_map_user_permissions_unit_level_3` 
			WHERE `organization_id` = @organization_to_remove
			;

		DELETE FROM `ut_map_user_permissions_unit_level_2` 
			WHERE `organization_id` = @organization_to_remove
			;

		DELETE FROM `ut_map_user_permissions_unit_level_1` 
			WHERE `organization_id` = @organization_to_remove
			;

		DELETE FROM `ut_map_user_permissions_unit_all` 
			WHERE `organization_id` = @organization_to_remove
			;

	# Properties

		DELETE FROM `ut_map_external_source_units` 
			WHERE `organization_id` = @organization_to_remove
			;

		DELETE FROM `property_level_3_rooms` 
			WHERE `organization_id` = @organization_to_remove
			;

		DELETE FROM `property_level_2_units` 
			WHERE `organization_id` = @organization_to_remove
			;

		DELETE FROM `property_level_1_buildings` 
			WHERE `organization_id` = @organization_to_remove
			;

		DELETE FROM `external_property_level_3_rooms` 
			WHERE `created_by_id` = @organization_to_remove
			;

		DELETE FROM `external_property_level_2_units` 
			WHERE `created_by_id` = @organization_to_remove
			;

		DELETE FROM `external_property_level_1_buildings` 
			WHERE `created_by_id` = @organization_to_remove
			;

	# Areas:

		DELETE FROM `ut_map_external_source_areas` 
			WHERE `organization_id` = @organization_to_remove
			;

		DELETE FROM `property_groups_areas` 
			WHERE `organization_id` = @organization_to_remove
			;

		DELETE FROM `external_property_groups_areas` 
			WHERE `created_by_id` = @organization_to_remove
			;

	# UNTE users

		DROP TABLE IF EXISTS `list_unte_users_for_organization` ;

		CREATE TABLE `list_unte_users_for_organization` 
		AS 
		SELECT `username` 
			FROM `uneet_enterprise_users`
			WHERE `organization_id` = @organization_to_remove
			;

		DELETE `uneet_enterprise_ugmembers`
			, `list_unte_users_for_organization`
			FROM `uneet_enterprise_ugmembers`
			INNER JOIN `list_unte_users_for_organization`
			ON (`uneet_enterprise_ugmembers`.`UserName` = `list_unte_users_for_organization`.`username`)
			;

		DROP TABLE IF EXISTS `list_unte_users_for_organization` ;

	# MEFE users

		DELETE FROM `ut_map_external_source_users` 
			WHERE `organization_id` = @organization_to_remove
			;

		DELETE FROM `persons` 
			WHERE `organization_id` = @organization_to_remove
			;

		DELETE FROM `external_persons` 
			WHERE `created_by_id` = @organization_to_remove
			;

		DELETE FROM `ut_user_types` 
			WHERE `organization_id` = @organization_to_remove
			;

	# The organization

		DELETE FROM `ut_api_keys` 
			WHERE `organization_id` = @organization_to_remove
			;
		DELETE FROM `uneet_enterprise_users` 
			WHERE `organization_id` = @organization_to_remove
			;

		UPDATE `uneet_enterprise_organizations`
			SET `default_sot_id` = NULL
			WHERE `id_organization` = @organization_to_remove
			;

		DELETE FROM `ut_external_sot_for_unee_t_objects` 
			WHERE `organization_id` = @organization_to_remove
			;

		DELETE FROM `uneet_enterprise_organizations` 
			WHERE `id_organization` = @organization_to_remove
			;
