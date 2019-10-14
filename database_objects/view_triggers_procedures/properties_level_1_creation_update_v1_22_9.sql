#################
#
# This lists all the triggers we use to create 
# a property_level_1
# via the Unee-T Enterprise Interface
#
#################

# This script creates the following objects:
#	- Triggers
#		- `ut_after_insert_in_external_property_level_1`
#		- `ut_after_update_external_property_level_1`
#		- `ut_after_insert_in_property_level_1`
#		- `ut_after_update_property_level_1`
#		- ``
#		- ``

# We create a trigger when a record is added to the `external_property_level_1_buildings` table

	DROP TRIGGER IF EXISTS `ut_after_insert_in_external_property_level_1`;

DELIMITER $$
CREATE TRIGGER `ut_after_insert_in_external_property_level_1`
AFTER INSERT ON `external_property_level_1_buildings`
FOR EACH ROW
BEGIN

# We only do this if 
#	- we need to create the property in Unee-T
#	- The record does NOT exist in in the table `property_level_1_buildings` yet.
#	- We have a `external_id`
#	- We have a `external_system_id`
#	- We have a `external_table`
#	- We have a `organization_id`
#	- We have a `tower`
#	- We have a MEFE user ID for the user who did the update
#	- The unit was already marked as needed to be created in Unee-T
#	- We have a valid area id in the table `external_property_groups_areas`
#	- The `do_not_insert_field` is NOT equal to 1
#	- This is a valid insert method:
#		- 'imported_from_hmlet_ipi'
#		- 'Manage_Buildings_Add_Page'
#		- 'Manage_Buildings_Edit_Page'
#		- 'Manage_Buildings_Import_Page'
#		- 'Export_and_Import_Buildings_Import_Page'
#		- ''

	SET @is_creation_needed_in_unee_t_insert_extl1 = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator_insert_extl1 = NEW.`created_by_id` ;
	SET @source_system_updater_insert_extl1 = (IF(NEW.`updated_by_id` IS NULL
			, @source_system_creator_insert_extl1
			, NEW.`updated_by_id`
			)
		);

	SET @creator_mefe_user_id_insert_extl1 = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator_insert_extl1
		)
		;

	SET @upstream_create_method_insert_extl1 = NEW.`creation_method` ;
	SET @upstream_update_method_insert_extl1 = NEW.`update_method` ;

	SET @external_system_id_insert_extl1 = NEW.`external_system_id` ; 
	SET @external_table_insert_extl1 = NEW.`external_table` ;
	SET @external_id_insert_extl1 = NEW.`external_id` ;
	SET @tower_insert_extl1 = NEW.`tower` ;

	SET @organization_id_insert_extl1 = @source_system_creator_insert_extl1 ;

	SET @id_in_property_level_1_buildings_insert_extl1 = (SELECT `id_building`
		FROM `property_level_1_buildings`
		WHERE `external_system_id` = @external_system_id_insert_extl1
			AND `external_table` = @external_table_insert_extl1
			AND `external_id` = @external_id_insert_extl1
			AND `tower` = @tower_insert_extl1
			AND `organization_id` = @organization_id_insert_extl1
		);

	SET @upstream_do_not_insert_insert_extl1 = NEW.`do_not_insert` ;

	# This is an INSERT - the record should NOT exist already

		SET @do_not_insert_insert_extl1 = (IF (@id_in_property_level_1_buildings_insert_extl1 IS NULL
				, 0
				, @upstream_do_not_insert_insert_extl1
				)
			);

	# Get the information about the area for that building...
	# We need the information from the table `property_groups_areas` (and NOT the table `external_property_groups_areas`)

		SET @area_id_1_insert_extl1 = NEW.`area_id` ;

		SET @area_external_id_insert_extl1 = (SELECT `external_id`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_1_insert_extl1
			);
		SET @area_external_system_id_insert_extl1 = (SELECT `external_system_id`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_1_insert_extl1
			);
		SET @area_external_table_insert_extl1 = (SELECT `external_table`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_1_insert_extl1
			);

		SET @area_id_2_insert_extl1 = (SELECT `id_area`
			FROM `property_groups_areas`
			WHERE `external_id` = @area_external_id_insert_extl1
				AND `external_system_id` = @area_external_system_id_insert_extl1
			   	AND `external_table` = @area_external_table_insert_extl1
			   	AND `organization_id` = @organization_id_insert_extl1
			);

	IF @is_creation_needed_in_unee_t_insert_extl1 = 1
		AND @do_not_insert_insert_extl1 = 0
		AND @external_id_insert_extl1 IS NOT NULL
		AND @external_system_id_insert_extl1 IS NOT NULL
		AND @external_table_insert_extl1 IS NOT NULL
		AND @tower_insert_extl1 IS NOT NULL
		AND @organization_id_insert_extl1 IS NOT NULL
		AND @area_id_2_insert_extl1 IS NOT NULL
		AND 
		(@upstream_create_method_insert_extl1 = 'imported_from_hmlet_ipi'
			OR @upstream_create_method_insert_extl1 = 'Manage_Buildings_Add_Page'
			OR @upstream_create_method_insert_extl1 = 'Manage_Buildings_Edit_Page'
			OR @upstream_create_method_insert_extl1 = 'Manage_Buildings_Import_Page'
			OR @upstream_create_method_insert_extl1 = 'Export_and_Import_Buildings_Import_Page'
			OR @upstream_update_method_insert_extl1 = 'imported_from_hmlet_ipi'
			OR @upstream_update_method_insert_extl1 = 'Manage_Buildings_Add_Page'
			OR @upstream_update_method_insert_extl1 = 'Manage_Buildings_Edit_Page'
			OR @upstream_update_method_insert_extl1 = 'Manage_Buildings_Import_Page'
			OR @upstream_update_method_insert_extl1 = 'Export_and_Import_Buildings_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `property_level_1_buildings` table:

		SET @this_trigger_insert_extl1_insert := 'ut_after_insert_in_external_property_level_1_insert' ;
		SET @this_trigger_insert_extl1_update := 'ut_after_insert_in_external_property_level_1_update' ;

		SET @creation_system_id_insert_extl1 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator_insert_extl1
			)
			;
		SET @created_by_id_insert_extl1 = @creator_mefe_user_id_insert_extl1 ;

		SET @update_system_id_insert_extl1 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater_insert_extl1
			)
			;
		SET @updated_by_id_insert_extl1 = @creator_mefe_user_id_insert_extl1 ;

		SET @organization_id_create_insert_extl1 = @source_system_creator_insert_extl1 ;
		SET @organization_id_update_insert_extl1 = @source_system_updater_insert_extl1;

		SET @is_obsolete_insert_extl1 = NEW.`is_obsolete` ;
		SET @order_insert_extl1 = NEW.`order` ;

		SET @unee_t_unit_type_insert_extl1 = NEW.`unee_t_unit_type` ;
		SET @designation_insert_extl1 = NEW.`designation` ;

		SET @address_1_insert_extl1 = NEW.`address_1` ;
		SET @address_2_insert_extl1 = NEW.`address_2` ;
		SET @zip_postal_code_insert_extl1 = NEW.`zip_postal_code` ;
		SET @state_insert_extl1 = NEW.`state` ;
		SET @city_insert_extl1 = NEW.`city` ;
		SET @country_code_insert_extl1 = NEW.`country_code` ;

		SET @description_insert_extl1 = NEW.`description` ;

	# We insert the record in the table `property_level_1_buildings`

		INSERT INTO `property_level_1_buildings`
			(`external_id`
			, `external_system_id` 
			, `external_table`
			, `syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `creation_method`
			, `organization_id`
			, `is_obsolete`
			, `order`
			, `area_id`
			, `is_creation_needed_in_unee_t`
			, `do_not_insert`
			, `unee_t_unit_type`
			, `designation`
			, `tower`
			, `address_1`
			, `address_2`
			, `zip_postal_code`
			, `state`
			, `city`
			, `country_code`
			, `description`
			)
			VALUES
				(@external_id_insert_extl1
				, @external_system_id_insert_extl1
				, @external_table_insert_extl1
				, NOW()
				, @creation_system_id_insert_extl1
				, @created_by_id_insert_extl1
				, @this_trigger_insert_extl1_insert
				, @organization_id_create_insert_extl1
				, @is_obsolete_insert_extl1
				, @order_insert_extl1
				, @area_id_2_insert_extl1
				, @is_creation_needed_in_unee_t_insert_extl1
				, @do_not_insert_insert_extl1_insert_extl1
				, @unee_t_unit_type_insert_extl1
				, @designation_insert_extl1
				, @tower_insert_extl1
				, @address_1_insert_extl1
				, @address_2_insert_extl1
				, @zip_postal_code_insert_extl1
				, @state_insert_extl1
				, @city_insert_extl1
				, @country_code_insert_extl1
				, @description_insert_extl1
				)
			ON DUPLICATE KEY UPDATE
				`syst_updated_datetime` = NOW()
				, `update_system_id` = @update_system_id_insert_extl1
				, `updated_by_id` = @updated_by_id_insert_extl1
				, `update_method` = @this_trigger_insert_extl1_update
				, `organization_id` = @organization_id_update_insert_extl1
				, `is_obsolete` = @is_obsolete_insert_extl1
				, `order` = @order_insert_extl1
				, `area_id` = @area_id_2_insert_extl1
				, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t_insert_extl1
				, `do_not_insert` = @do_not_insert_insert_extl1
				, `unee_t_unit_type` = @unee_t_unit_type_insert_extl1
				, `designation` = @designation_insert_extl1
				, `tower` = @tower_insert_extl1
				, `address_1` = @address_1_insert_extl1
				, `address_2` = @address_2_insert_extl1
				, `zip_postal_code` = @zip_postal_code_insert_extl1
				, `state` = @state_insert_extl1
				, `city` = @city_insert_extl1
				, `country_code` = @country_code_insert_extl1
				, `description` = @description_insert_extl1
			;

	END IF;

# Housekeeping - we make sure that if a building is obsolete - all units in that building are obsolete too

	SET @building_system_id_insert_extl1 = NEW.`id_building` ;

		UPDATE `external_property_level_2_units` AS `a`
			INNER JOIN `external_property_level_1_buildings` AS `b`
				ON (`a`.`building_system_id` = `b`.`id_building`)
			SET `a`.`is_obsolete` = `b`.`is_obsolete`
			WHERE `a`.`building_system_id` = @building_system_id_insert_extl1
				AND `a`.`tower` = @tower_insert_extl1
			;

END;
$$
DELIMITER ;

# Create the trigger when the extL1P is updated
# This trigger will:
#	- Check if several conditions are met
#	- Capture the value we need in several variables
#	- Do the update.

	DROP TRIGGER IF EXISTS `ut_after_update_external_property_level_1`;

DELIMITER $$
CREATE TRIGGER `ut_after_update_external_property_level_1`
AFTER UPDATE ON `external_property_level_1_buildings`
FOR EACH ROW
BEGIN

# We only do this if 
#	- We have a `external_id`
#	- We have a `external_system_id`
#	- We have a `external_table`
#	- We have a `organization_id`
#	- We have a `tower`
#	- We have a MEFE user ID for the user who did the update
#	- The `do_not_insert_field` is NOT equal to 1
#	- This is a valid update method:
#		- 'imported_from_hmlet_ipi'
#		- 'Manage_Buildings_Add_Page'
#		- 'Manage_Buildings_Edit_Page'
#		- 'Manage_Buildings_Import_Page'
#		- 'Export_and_Import_Buildings_Import_Page'
#		- ''

# Capture the variables we need to verify if conditions are met:


	SET @is_creation_needed_in_unee_t_update_extl1 = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator_update_extl1 = NEW.`created_by_id` ;

	SET @source_system_updated_by_id_update_extl1 = NEW.`updated_by_id` ;

	SET @source_system_updater_update_extl1 = (IF(@source_system_updated_by_id_update_extl1 IS NULL
			, @source_system_creator_update_extl1
			, @source_system_updated_by_id_update_extl1
			)
		) ;

	SET @creator_mefe_user_id_update_extl1 = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator_update_extl1
		)
		;

	SET @upstream_create_method_update_extl1 = NEW.`creation_method` ;
	SET @upstream_update_method_update_extl1 = NEW.`update_method` ;

	SET @organization_id_update_extl1 = @source_system_creator_update_extl1 ;

	SET @external_id_update_extl1 = NEW.`external_id` ;
	SET @external_system_id_update_extl1 = NEW.`external_system_id` ; 
	SET @external_table_update_extl1 = NEW.`external_table` ;
	SET @tower_update_extl1 = NEW.`tower` ;

	SET @new_is_creation_needed_in_unee_t_update_extl1 = NEW.`is_creation_needed_in_unee_t` ;
	SET @old_is_creation_needed_in_unee_t_update_extl1 = OLD.`is_creation_needed_in_unee_t` ;

	SET @id_in_property_level_1_buildings_update_extl1 = (SELECT `id_building`
		FROM `property_level_1_buildings`
		WHERE `external_system_id` = @external_system_id_update_extl1
			AND `external_table` = @external_table_update_extl1
			AND `external_id` = @external_id_update_extl1
			AND `organization_id` = @organization_id_update_extl1
			AND `tower` = @tower_update_extl1
		);

	SET @upstream_do_not_insert_update_extl1 = NEW.`do_not_insert` ;

	# Get the information about the area for that building...
	# We need the information from the table `property_groups_areas` (and NOT the table `external_property_groups_areas`)

		SET @area_id_1_update_extl1 = NEW.`area_id` ;

		SET @area_external_id_update_extl1 = (SELECT `external_id`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_1_update_extl1
			);
		SET @area_external_system_id_update_extl1 = (SELECT `external_system_id`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_1_update_extl1
			);
		SET @area_external_table_update_extl1 = (SELECT `external_table`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_1_update_extl1
			);

		SET @area_id_2_update_extl1 = (SELECT `id_area`
			FROM `property_groups_areas`
			WHERE `external_id` = @area_external_id_update_extl1
				AND `external_system_id` = @area_external_system_id_update_extl1
			   	AND `external_table` = @area_external_table_update_extl1
			   	AND `organization_id` = @organization_id_update_extl1
			);

# We can now check if the conditions are met:


	IF @is_creation_needed_in_unee_t_update_extl1 = 1
		AND @external_id_update_extl1 IS NOT NULL
		AND @external_system_id_update_extl1 IS NOT NULL
		AND @external_table_update_extl1 IS NOT NULL
		AND @tower_update_extl1 IS NOT NULL
		AND @organization_id_update_extl1 IS NOT NULL
		AND @area_id_2_update_extl1 IS NOT NULL
		AND (@upstream_create_method_update_extl1 = 'imported_from_hmlet_ipi'
			OR @upstream_update_method_update_extl1 = 'imported_from_hmlet_ipi'
			OR @upstream_create_method_update_extl1 = 'Manage_Buildings_Add_Page'
			OR @upstream_update_method_update_extl1 = 'Manage_Buildings_Add_Page'
			OR @upstream_create_method_update_extl1 = 'Manage_Buildings_Edit_Page'
			OR @upstream_update_method_update_extl1 = 'Manage_Buildings_Edit_Page'
			OR @upstream_create_method_update_extl1 = 'Manage_Buildings_Import_Page'
			OR @upstream_update_method_update_extl1 = 'Manage_Buildings_Import_Page'
			OR @upstream_create_method_update_extl1 = 'Export_and_Import_Buildings_Import_Page'
			OR @upstream_update_method_update_extl1 = 'Export_and_Import_Buildings_Import_Page'
			)
	THEN 

	# The conditions are met: we capture the other variables we need

		SET @creation_system_id_update_extl1 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator_update_extl1
			)
			;
		SET @created_by_id_update_extl1 = @creator_mefe_user_id_update_extl1 ;

		SET @update_system_id_update_extl1 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater_update_extl1
			)
			;
		SET @updated_by_id_update_extl1 = @creator_mefe_user_id_update_extl1 ;

		SET @organization_id_create_update_extl1 = @source_system_creator_update_extl1 ;
		SET @organization_id_update_update_extl1 = @source_system_updater_update_extl1 ;

		SET @is_obsolete_update_extl1 = NEW.`is_obsolete` ;
		SET @order_update_extl1 = NEW.`order` ;

		SET @unee_t_unit_type_update_extl1 = NEW.`unee_t_unit_type` ;
		SET @designation_update_extl1 = NEW.`designation` ;

		SET @address_1_update_extl1 = NEW.`address_1` ;
		SET @address_2_update_extl1 = NEW.`address_2` ;
		SET @zip_postal_code_update_extl1 = NEW.`zip_postal_code` ;
		SET @state_update_extl1 = NEW.`state` ;
		SET @city_update_extl1 = NEW.`city` ;
		SET @country_code_update_extl1 = NEW.`country_code` ;

		SET @description_update_extl1 = NEW.`description` ;

		SET @building_system_id_update_extl1 = NEW.`id_building` ;

		IF @new_is_creation_needed_in_unee_t_update_extl1 != @old_is_creation_needed_in_unee_t_update_extl1
		THEN 

			# This is option 1 - creation IS needed

				SET @this_trigger_update_extl1_insert = 'ut_after_update_external_property_level_1_insert_creation_needed';
				SET @this_trigger_update_extl1_update = 'ut_after_update_external_property_level_1_update_creation_needed';

			# We update the record in the table `property_level_1_buildings`
			# We do this via INSERT INTO ... ON DUPLICATE KEY UPDATE for maximum safety

				INSERT INTO `property_level_1_buildings`
					(`external_id`
					, `external_system_id` 
					, `external_table`
					, `syst_created_datetime`
					, `creation_system_id`
					, `created_by_id`
					, `creation_method`
					, `organization_id`
					, `is_obsolete`
					, `order`
					, `area_id`
					, `is_creation_needed_in_unee_t`
					, `do_not_insert`
					, `unee_t_unit_type`
					, `designation`
					, `tower`
					, `address_1`
					, `address_2`
					, `zip_postal_code`
					, `state`
					, `city`
					, `country_code`
					, `description`
					)
					VALUES
						(@external_id_update_extl1
						, @external_system_id_update_extl1
						, @external_table_update_extl1
						, NOW()
						, @creation_system_id_update_extl1
						, @created_by_id_update_extl1
						, @this_trigger_update_extl1_insert
						, @organization_id_create_update_extl1
						, @is_obsolete_update_extl1
						, @order_update_extl1
						, @area_id_2_update_extl1
						, @is_creation_needed_in_unee_t_update_extl1
						, @do_not_insert_update_extl1
						, @unee_t_unit_type_update_extl1
						, @designation_update_extl1
						, @tower_update_extl1
						, @address_1_update_extl1
						, @address_2_update_extl1
						, @zip_postal_code_update_extl1
						, @state_update_extl1
						, @city_update_extl1
						, @country_code_update_extl1
						, @description_update_extl1
						)
					ON DUPLICATE KEY UPDATE
						`syst_updated_datetime` = NOW()
						, `update_system_id` = @update_system_id_update_extl1
						, `updated_by_id` = @updated_by_id_update_extl1
						, `update_method` = @this_trigger_update_extl1_update
						, `organization_id` = @organization_id_update_update_extl1
						, `is_obsolete` = @is_obsolete_update_extl1
						, `order` = @order_update_extl1
						, `area_id` = @area_id_2_update_extl1
						, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t_update_extl1
						, `do_not_insert` = @do_not_insert_update_extl1
						, `unee_t_unit_type` = @unee_t_unit_type_update_extl1
						, `designation` = @designation_update_extl1
						, `tower` = @tower_update_extl1
						, `address_1` = @address_1_update_extl1
						, `address_2` = @address_2_update_extl1
						, `zip_postal_code` = @zip_postal_code_update_extl1
						, `state` = @state_update_extl1
						, `city` = @city_update_extl1
						, `country_code` = @country_code_update_extl1
						, `description` = @description_update_extl1
					;

			# Housekeeping - we make sure that if a building is obsolete - all units in that building are obsolete too

				UPDATE `external_property_level_2_units` AS `a`
					INNER JOIN `external_property_level_1_buildings` AS `b`
						ON (`a`.`building_system_id` = `b`.`id_building`)
					SET `a`.`is_obsolete` = `b`.`is_obsolete`
					WHERE `a`.`building_system_id` = @building_system_id_update_extl1
						AND `a`.`tower` = @tower_update_extl1
					;

		ELSEIF @new_is_creation_needed_in_unee_t_update_extl1 = @old_is_creation_needed_in_unee_t_update_extl1
		THEN 
			
			# This is option 2 - creation is NOT needed

				SET @this_trigger_update_extl1_insert = 'ut_after_update_external_property_level_1_insert_update_needed';
				SET @this_trigger_update_extl1_update = 'ut_after_update_external_property_level_1_update_update_needed';

			# We update the record in the table `property_level_1_buildings`
			# We do this via INSERT INTO ... ON DUPLICATE KEY UPDATE for maximum safety

				INSERT INTO `property_level_1_buildings`
					(`external_id`
					, `external_system_id` 
					, `external_table`
					, `syst_created_datetime`
					, `creation_system_id`
					, `created_by_id`
					, `creation_method`
					, `organization_id`
					, `is_obsolete`
					, `order`
					, `area_id`
					, `is_creation_needed_in_unee_t`
					, `do_not_insert`
					, `unee_t_unit_type`
					, `designation`
					, `tower`
					, `address_1`
					, `address_2`
					, `zip_postal_code`
					, `state`
					, `city`
					, `country_code`
					, `description`
					)
					VALUES
						(@external_id_update_extl1
						, @external_system_id_update_extl1
						, @external_table_update_extl1
						, NOW()
						, @creation_system_id_update_extl1
						, @created_by_id_update_extl1
						, @this_trigger_update_extl1_insert
						, @organization_id_create_update_extl1
						, @is_obsolete_update_extl1
						, @order_update_extl1
						, @area_id_2_update_extl1
						, @is_creation_needed_in_unee_t_update_extl1
						, @do_not_insert_update_extl1
						, @unee_t_unit_type_update_extl1
						, @designation_update_extl1
						, @tower_update_extl1
						, @address_1_update_extl1
						, @address_2_update_extl1
						, @zip_postal_code_update_extl1
						, @state_update_extl1
						, @city_update_extl1
						, @country_code_update_extl1
						, @description_update_extl1
						)
					ON DUPLICATE KEY UPDATE
						`syst_updated_datetime` = NOW()
						, `update_system_id` = @update_system_id_update_extl1
						, `updated_by_id` = @updated_by_id_update_extl1
						, `update_method` = @this_trigger_update_extl1_update
						, `organization_id` = @organization_id_update_update_extl1
						, `is_obsolete` = @is_obsolete_update_extl1
						, `order` = @order_update_extl1
						, `area_id` = @area_id_2_update_extl1
						, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t_update_extl1
						, `do_not_insert` = @do_not_insert_update_extl1
						, `unee_t_unit_type` = @unee_t_unit_type_update_extl1
						, `designation` = @designation_update_extl1
						, `tower` = @tower_update_extl1
						, `address_1` = @address_1_update_extl1
						, `address_2` = @address_2_update_extl1
						, `zip_postal_code` = @zip_postal_code_update_extl1
						, `state` = @state_update_extl1
						, `city` = @city_update_extl1
						, `country_code` = @country_code_update_extl1
						, `description` = @description_update_extl1
					;

			# Housekeeping - we make sure that if a building is obsolete - all units in that building are obsolete too

				UPDATE `external_property_level_2_units` AS `a`
					INNER JOIN `external_property_level_1_buildings` AS `b`
						ON (`a`.`building_system_id` = `b`.`id_building`)
					SET `a`.`is_obsolete` = `b`.`is_obsolete`
					WHERE `a`.`building_system_id` = @building_system_id_update_extl1
						AND `a`.`tower` = @tower_update_extl1
					;

		END IF;

	# The conditions are NOT met <-- we do nothing

	END IF;

END;
$$
DELIMITER ;

# Create a trigger to update the table that will fire the lambda each time a new building needs to be created

		DROP TRIGGER IF EXISTS `ut_after_insert_in_property_level_1`;

DELIMITER $$
CREATE TRIGGER `ut_after_insert_in_property_level_1`
AFTER INSERT ON `property_level_1_buildings`
FOR EACH ROW
BEGIN

# We do this ONLY IF 
#	- We have marked the property as an object we need to create in Unee-T
#	- The record does NOT exist in the table `ut_map_external_source_units` yet
#	- The record has NOT been explicitly been marked as `do_not_insert`
#	- This is done via an authorized Insert Method:
#		- 'ut_after_insert_in_external_property_level_1_insert'
#		- 'ut_after_insert_in_external_property_level_1_update'
#		- 'ut_after_update_external_property_level_1_insert_creation_needed'
#		- 'ut_after_update_external_property_level_1_update_creation_needed'
#		- 'ut_after_update_external_property_level_1_insert_update_needed'
#		- 'ut_after_update_external_property_level_1_update_update_needed'
#

	SET @is_creation_needed_in_unee_t_insert_l1 = NEW.`is_creation_needed_in_unee_t` ;

	SET @external_property_id_insert_l1 = NEW.`external_id` ;
	SET @external_system_insert_l1 = NEW.`external_system_id` ;
	SET @table_in_external_system_insert_l1 = NEW.`external_table` ;
	SET @organization_id_insert_l1 = NEW.`organization_id`;
	SET @tower_insert_l1 = NEW.`tower` ; 

	SET @id_building_insert_l1 = NEW.`id_building` ;

	SET @external_property_type_id_insert_l1 = 1 ;

	SET @id_in_ut_map_external_source_units_insert_l1 = (SELECT `id_map`
		FROM `ut_map_external_source_units`
		WHERE `external_property_type_id` = @external_property_type_id_insert_l1
			AND `external_property_id` = @external_property_id_insert_l1
			AND `external_system` = @external_system_insert_l1
			AND `table_in_external_system` = @table_in_external_system_insert_l1
			AND `organization_id` = @organization_id_insert_l1
			AND `tower` = @tower_insert_l1
		);

	SET @existing_mefe_unit_id_insert_l1 = (SELECT `unee_t_mefe_unit_id`
		FROM `ut_map_external_source_units`
		WHERE `external_property_type_id` = @external_property_type_id_insert_l1
			AND `external_property_id` = @external_property_id_insert_l1
			AND `external_system` = @external_system_insert_l1
			AND `table_in_external_system` = @table_in_external_system_insert_l1
			AND `organization_id` = @organization_id_insert_l1
			AND `tower` = @tower_insert_l1
		);

	# This is an insert - if the record does NOT exist, we create the record
	# unless 
	#	- it is specifically specified that we do NOT need to create the record.
	#	- the record is marked as obsolete

		SET @is_obsolete_insert_l1 = NEW.`is_obsolete`;

		SET @do_not_insert_insert_l1_raw = NEW.`do_not_insert` ;

		SET @do_not_insert_insert_l1 = (IF (@id_in_ut_map_external_source_units_insert_l1 IS NULL
				,  IF (@is_obsolete_insert_l1 != 0
					, 1
					, 0
					)
				, IF (@is_obsolete_insert_l1 != 0
					, 1
					, @do_not_insert_insert_l1_raw
					)
				)
			);

	SET @upstream_create_method_insert_l1 = NEW.`creation_method` ;
	SET @upstream_update_method_insert_l1 = NEW.`update_method` ;

	IF @is_creation_needed_in_unee_t_insert_l1 = 1
		AND @do_not_insert_insert_l1 = 0
		AND @existing_mefe_unit_id_insert_l1 IS NULL
		AND (@upstream_create_method_insert_l1 = 'ut_after_insert_in_external_property_level_1_insert'
			OR @upstream_update_method_insert_l1 = 'ut_after_insert_in_external_property_level_1_update'
			OR @upstream_create_method_insert_l1 = 'ut_after_update_external_property_level_1_insert_creation_needed'
			OR @upstream_update_method_insert_l1 = 'ut_after_update_external_property_level_1_update_creation_needed'
			OR @upstream_create_method_insert_l1 = 'ut_after_update_external_property_level_1_insert_update_needed'
			OR @upstream_update_method_insert_l1 = 'ut_after_update_external_property_level_1_update_update_needed'
			)
	THEN 

	# We capture the values we need for the insert/udpate:

		SET @this_trigger_insert_l1_insert = 'ut_after_insert_in_property_level_1_insert' ;
		SET @this_trigger_insert_l1_update = 'ut_after_insert_in_property_level_1_update' ;

		SET @creation_system_id_insert_l1 = NEW.`creation_system_id`;
		SET @created_by_id_insert_l1 = NEW.`created_by_id`;

		SET @update_system_id_insert_l1 = NEW.`creation_system_id` ;
		SET @updated_by_id_insert_l1 = NEW.`created_by_id`;

		SET @is_update_needed_insert_l1 = NULL ;
			
		SET @uneet_name_insert_l1 = NEW.`designation`;

		SET @unee_t_unit_type_insert_l1_raw = NEW.`unee_t_unit_type` ;

		SET @unee_t_unit_type_insert_l1 = (IFNULL(@unee_t_unit_type_insert_l1_raw
				, 'Unknown'
				)
			)
			;
			
		SET @new_record_id_insert_l1 = NEW.`id_building` ;
		
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
				, `new_record_id`
				, `external_property_type_id`
				, `external_property_id`
				, `external_system`
				, `table_in_external_system`
				, `tower`
				)
				VALUES
					(NOW()
					, @creation_system_id_insert_l1
					, @created_by_id_insert_l1
					, @this_trigger_insert_l1_insert
					, @organization_id_insert_l1
					, NOW()
					, @this_trigger_insert_l1_insert
					, @is_obsolete_insert_l1
					, @is_update_needed_insert_l1
					, @uneet_name_insert_l1
					, @unee_t_unit_type_insert_l1
					, @new_record_id_insert_l1
					, @external_property_type_id_insert_l1
					, @external_property_id_insert_l1
					, @external_system_insert_l1
					, @table_in_external_system_insert_l1
					, @tower_insert_l1
					)
				ON DUPLICATE KEY UPDATE 
					`syst_updated_datetime` = NOW()
					, `update_system_id` = @update_system_id_insert_l1
					, `updated_by_id` = @updated_by_id_insert_l1
					, `update_method` = @this_trigger_insert_l1_update
					, `organization_id` = @organization_id_insert_l1
					, `datetime_latest_trigger` = NOW()
					, `latest_trigger` = @this_trigger_insert_l1_update
					, `uneet_name` = @uneet_name_insert_l1
					, `unee_t_unit_type` = @unee_t_unit_type_insert_l1
					, `is_update_needed` = 1
				;

	END IF;

END;
$$
DELIMITER ;

# Create the trigger when the L1P is updated
# This trigger will:
#	- Check if several conditions are met
#	- Capture the value we need in several variables
#	- Do the Insert/update if needed

	DROP TRIGGER IF EXISTS `ut_after_update_property_level_1`;

DELIMITER $$
CREATE TRIGGER `ut_after_update_property_level_1`
AFTER UPDATE ON `property_level_1_buildings`
FOR EACH ROW
BEGIN

# We only do this IF:
# 	- We need to create the unit in Unee-T
#	- The record has NOT been explicitly been marked as `do_not_insert`
#	- This is done via an authorized update Method:
#		- `ut_after_insert_in_external_property_level_1_insert`
#		- 'ut_after_insert_in_external_property_level_1_update'
#		- 'ut_after_update_external_property_level_1_insert_creation_needed'
#		- 'ut_after_update_external_property_level_1_update_creation_needed'
#		- 'ut_after_update_external_property_level_1_insert_update_needed'
#		- 'ut_after_update_external_property_level_1_update_update_needed'
#

# Capture the variables we need to verify if conditions are met:

	SET @is_creation_needed_in_unee_t_update_l1 = NEW.`is_creation_needed_in_unee_t` ;

	SET @external_property_id_update_l1 = NEW.`external_id` ;
	SET @external_system_update_l1 = NEW.`external_system_id` ;
	SET @table_in_external_system_update_l1 = NEW.`external_table` ;
	SET @organization_id_update_l1 = NEW.`organization_id`;
	SET @tower_update_l1 = NEW.`tower` ; 

	SET @new_is_creation_needed_in_unee_t_update_l1 =  NEW.`is_creation_needed_in_unee_t` ;
	SET @old_is_creation_needed_in_unee_t_update_l1 = OLD.`is_creation_needed_in_unee_t` ; 

	SET @id_building_update_l1 = NEW.`id_building` ;

	SET @upstream_create_method_update_l1 = NEW.`creation_method` ;
	SET @upstream_update_method_update_l1 = NEW.`update_method` ;

# We can now check if the conditions are met:

	IF (@upstream_create_method_update_l1 = 'ut_after_insert_in_external_property_level_1_insert'
			OR @upstream_create_method_update_l1 = 'ut_after_insert_in_external_property_level_1_update'
			OR @upstream_update_method_update_l1 = 'ut_after_insert_in_external_property_level_1_update'
			OR @upstream_create_method_update_l1 = 'ut_after_update_external_property_level_1_insert_creation_needed'
			OR @upstream_update_method_update_l1 = 'ut_after_update_external_property_level_1_update_creation_needed'
			OR @upstream_create_method_update_l1 = 'ut_after_update_external_property_level_1_insert_update_needed'
			OR @upstream_update_method_update_l1 = 'ut_after_update_external_property_level_1_update_update_needed'
			)
	THEN 

	# The conditions are met: we capture the other variables we need

		SET @creation_system_id_update_l1 = NEW.`update_system_id` ;
		SET @created_by_id_update_l1 = NEW.`updated_by_id` ;

		SET @update_system_id_update_l1 = NEW.`update_system_id` ;
		SET @updated_by_id_update_l1 = NEW.`updated_by_id` ;

		SET @organization_id_update_l1 = NEW.`organization_id` ;

		SET @tower_update_l1 = NEW.`tower` ; 
			
		SET @is_update_needed_update_l1 = NULL ;
			
		SET @uneet_name_update_l1 = NEW.`designation`;

		SET @unee_t_unit_type_update_l1_raw = NEW.`unee_t_unit_type` ;

		SET @unee_t_unit_type_update_l1 = (IFNULL(@unee_t_unit_type_update_l1_raw
				, 'Unknown'
				)
			)
			;
			
		SET @new_record_id_update_l1 = NEW.`id_building`;

		SET @external_property_id_update_l1 = NEW.`external_id` ;
		SET @external_system_update_l1 = NEW.`external_system_id` ;
		SET @table_in_external_system_update_l1 = NEW.`external_table` ;
	
		SET @external_property_type_id_update_l1 = 1 ;

		SET @mefe_unit_id_update_l1 = (SELECT `unee_t_mefe_unit_id`
			FROM `ut_map_external_source_units`
			WHERE `external_property_type_id` = @external_property_type_id_update_l1
				AND `external_property_id` = @external_property_id_update_l1
				AND `external_system` = @external_system_update_l1
				AND `table_in_external_system` = @table_in_external_system_update_l1
				AND `organization_id` = @organization_id_update_l1
				AND `tower` = @tower_update_l1
			);
		
		# If the record does NOT exist, we create the record
		# unless 
		#	- it is specifically specified that we do NOT need to create the record.
		#	- the record is marked as obsolete

			SET @do_not_insert_update_l1_raw = NEW.`do_not_insert` ;

			SET @is_obsolete_update_l1 = NEW.`is_obsolete`;

			SET @do_not_insert_update_l1 = (IF (@do_not_insert_update_l1_raw IS NULL
					, IF (@is_obsolete_update_l1 != 0
						, 1
						, 0
						)
					, IF (@is_obsolete_update_l1 != 0
						, 1
						, @do_not_insert_update_l1_raw
						)
					)
				);
	
		IF @is_creation_needed_in_unee_t_update_l1 = 1
			AND (@mefe_unit_id_update_l1 IS NULL
				OR  @mefe_unit_id_update_l1 = ''
				)
			AND @do_not_insert_update_l1 = 0
		THEN 

			# This is option 1 - creation IS needed

				SET @this_trigger_update_l1_insert = 'ut_after_update_property_level_1_insert_creation_needed' ;
				SET @this_trigger_update_l1_update = 'ut_after_update_property_level_1_update_creation_needed' ;
		
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
					, `new_record_id`
					, `external_property_type_id`
					, `external_property_id`
					, `external_system`
					, `table_in_external_system`
					, `tower`
					)
					VALUES
						(NOW()
						, @creation_system_id_update_l1
						, @created_by_id_update_l1
						, @this_trigger_update_l1_insert
						, @organization_id_update_l1
						, NOW()
						, @this_trigger_update_l1_insert
						, @is_obsolete_update_l1
						, @is_update_needed_update_l1
						, @uneet_name_update_l1
						, @unee_t_unit_type_update_l1
						, @new_record_id_update_l1
						, @external_property_type_id_update_l1
						, @external_property_id_update_l1
						, @external_system_update_l1
						, @table_in_external_system_update_l1
						, @tower_update_l1
						)
					ON DUPLICATE KEY UPDATE
						`syst_updated_datetime` = NOW()
						, `update_system_id` = @update_system_id_update_l1
						, `updated_by_id` = @updated_by_id_update_l1
						, `update_method` = @this_trigger_update_l1_update
						, `organization_id` = @organization_id_update_l1
						, `datetime_latest_trigger` = NOW()
						, `latest_trigger` = @this_trigger_update_l1_update
						, `uneet_name` = @uneet_name_update_l1
						, `unee_t_unit_type` = @unee_t_unit_type_update_l1
						, `is_update_needed` = 1
					;

###################################################################
#
# THIS IS CREATING SUBQUERY RETURN MORE THAN 1 ROW ERRORS
#
###################################################################

		ELSEIF @mefe_unit_id_update_l1 IS NOT NULL
			OR @mefe_unit_id_update_l1 != ''
		THEN 
			
			# This is option 2 - creation is NOT needed

				SET @this_trigger_update_l1_insert = 'ut_after_update_property_level_1_insert_update_needed' ;
				SET @this_trigger_update_l1_update = 'ut_after_update_property_level_1_update_update_needed' ;

			# We Update the existing new record in the table `ut_map_external_source_units`

				UPDATE `ut_map_external_source_units`
					SET 
						`syst_updated_datetime` = NOW()
						, `update_system_id` = @update_system_id_update_l1
						, `updated_by_id` = @updated_by_id_update_l1
						, `update_method` = @this_trigger_update_l1_update
						, `organization_id` = @organization_id_update_l1
						, `datetime_latest_trigger` = NOW()
						, `latest_trigger` = @this_trigger_update_l1_update
						, `uneet_name` = @uneet_name_update_l1
						, `unee_t_unit_type` = @unee_t_unit_type_update_l1
						, `is_update_needed` = 1
					WHERE `unee_t_mefe_unit_id` = @mefe_unit_id_update_l1
					;

###################################################################
#
# END IS CREATING SUBQUERY RETURN MORE THAN 1 ROW ERRORS
#
###################################################################

		END IF;

	END IF;

	# The conditions are NOT met <-- we do nothing

END;
$$
DELIMITER ;