#################
#
# This lists all the triggers we use to create 
# a property_level_1
# via the Unee-T Enterprise Interface
#
#################

# This script creates the following objects:
#	- Triggers
#		- `ut_insert_external_property_level_1`
#		- `ut_update_external_property_level_1`
#		- `ut_update_external_property_level_1_creation_needed`
#		- `ut_update_map_external_source_unit_add_building`
#		- `ut_update_map_external_source_unit_add_building_creation_needed`
#		- `ut_update_map_external_source_unit_edit_level_1`
#		- ``
#		- ``
#	- Procedures
#		- ``
#		- ``
#		- ``
#		- ``

# We create a trigger when a record is added to the `external_property_level_1_buildings` table

	DROP TRIGGER IF EXISTS `ut_insert_external_property_level_1`;

DELIMITER $$
CREATE TRIGGER `ut_insert_external_property_level_1`
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

	SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator = NEW.`created_by_id` ;
	SET @source_system_updater = (IF(NEW.`updated_by_id` IS NULL
			, @source_system_creator
			, NEW.`updated_by_id`
			)
		);

	SET @creator_mefe_user_id = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator
		)
		;

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;
	
	SET @organization_id = @source_system_creator ;

	SET @external_id = NEW.`external_id` ;
	SET @external_system_id = NEW.`external_system_id` ; 
	SET @external_table = NEW.`external_table` ;
	SET @tower = NEW.`tower` ;

	SET @id_in_property_level_1_buildings = (SELECT `id_building`
		FROM `property_level_1_buildings`
		WHERE `external_system_id` = @external_system_id
			AND `external_table` = @external_table
			AND `external_id` = @external_id
			AND `organization_id` = @organization_id
			AND `tower` = @tower
		);

	SET @upstream_do_not_insert = NEW.`do_not_insert` ;

	# This is an INSERT - the record should NOT exist already

		SET @do_not_insert = (IF (@id_in_property_level_1_buildings IS NULL
				, 0
				, @upstream_do_not_insert
				)
			);

	# Get the information about the area for that building...
	# We need the information from the table `property_groups_areas` (and NOT the table `external_property_groups_areas`)
	
		SET @area_id_in_table_external_property_level_1_buildings = NEW.`area_id` ;

		SET @area_external_id = (SELECT `external_id`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_in_table_external_property_level_1_buildings
			);
		SET @area_external_system_id = (SELECT `external_system_id`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_in_table_external_property_level_1_buildings
			);
		SET @area_external_table = (SELECT `external_table`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_in_table_external_property_level_1_buildings
			);

		SET @area_id = (SELECT `id_area`
			FROM `property_groups_areas`
			WHERE `external_id` = @area_external_id
				AND `external_system_id` = @area_external_system_id
			   	AND `external_table` = @area_external_table
			   	AND `organization_id` = @organization_id
			);

	IF @is_creation_needed_in_unee_t = 1
		AND @do_not_insert = 0
		AND @external_id IS NOT NULL
		AND @external_system_id IS NOT NULL
		AND @external_table IS NOT NULL
		AND @tower IS NOT NULL
		AND @organization_id IS NOT NULL
		AND @area_id IS NOT NULL
		AND 
		(@upstream_create_method = 'imported_from_hmlet_ipi'
			OR @upstream_create_method = 'Manage_Buildings_Add_Page'
			OR @upstream_create_method = 'Manage_Buildings_Edit_Page'
			OR @upstream_create_method = 'Manage_Buildings_Import_Page'
			OR @upstream_create_method = 'Export_and_Import_Buildings_Import_Page'
			OR @upstream_update_method = 'imported_from_hmlet_ipi'
			OR @upstream_update_method = 'Manage_Buildings_Add_Page'
			OR @upstream_update_method = 'Manage_Buildings_Edit_Page'
			OR @upstream_update_method = 'Manage_Buildings_Import_Page'
			OR @upstream_update_method = 'Export_and_Import_Buildings_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `property_level_1_buildings` table:

		SET @this_trigger = 'ut_insert_external_property_level_1' ;

		SET @syst_created_datetime = NOW();
		SET @creation_system_id = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator
			)
			;
		SET @created_by_id = @creator_mefe_user_id ;
		SET @downstream_creation_method = @this_trigger ;

		SET @syst_updated_datetime = NOW();

		SET @update_system_id = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater
			)
			;
		SET @updated_by_id = @creator_mefe_user_id ;
		SET @downstream_update_method = @this_trigger ;

		SET @organization_id_create = @source_system_creator ;
		SET @organization_id_update = @source_system_updater;

		SET @is_obsolete = NEW.`is_obsolete` ;
		SET @order = NEW.`order` ;

		SET @unee_t_unit_type = NEW.`unee_t_unit_type` ;
		SET @designation = NEW.`designation` ;

		SET @address_1 = NEW.`address_1` ;
		SET @address_2 = NEW.`address_2` ;
		SET @zip_postal_code = NEW.`zip_postal_code` ;
		SET @state = NEW.`state` ;
		SET @city = NEW.`city` ;
		SET @country_code = NEW.`country_code` ;

		SET @description = NEW.`description` ;

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
				(@external_id
				, @external_system_id
				, @external_table
				, @syst_created_datetime
				, @creation_system_id
				, @created_by_id
				, @downstream_creation_method
				, @organization_id_create
				, @is_obsolete
				, @order
				, @area_id
				, @is_creation_needed_in_unee_t
				, @do_not_insert
				, @unee_t_unit_type
				, @designation
				, @tower
				, @address_1
				, @address_2
				, @zip_postal_code
				, @state
				, @city
				, @country_code
				, @description
				)
			ON DUPLICATE KEY UPDATE
				`syst_updated_datetime` = @syst_updated_datetime
				, `update_system_id` = @update_system_id
				, `updated_by_id` = @updated_by_id
				, `update_method` = @downstream_update_method
				, `organization_id` = @organization_id_update
				, `is_obsolete` = @is_obsolete
				, `order` = @order
				, `area_id` = @area_id
				, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t
				, `do_not_insert` = @do_not_insert
				, `unee_t_unit_type` = @unee_t_unit_type
				, `designation` = @designation
				, `tower` = @tower
				, `address_1` = @address_1
				, `address_2` = @address_2
				, `zip_postal_code` = @zip_postal_code
				, `state` = @state
				, `city` = @city
				, `country_code` = @country_code
				, `description` = @description
			;

	END IF;

# Housekeeping - we make sure that if a building is obsolete - all units in that building are obsolete too

	SET @building_system_id = NEW.`id_building` ;

		UPDATE `external_property_level_2_units` AS `a`
			INNER JOIN `external_property_level_1_buildings` AS `b`
				ON (`a`.`building_system_id` = `b`.`id_building`)
			SET `a`.`is_obsolete` = `b`.`is_obsolete`
			WHERE `a`.`building_system_id` = @building_system_id
			;

END;
$$
DELIMITER ;

# We create a trigger when a record is updated in the `external_property_level_1_buildings` table
#	- The property DOES exist in the table `property_level_1_buildings`
#	- This is a NOT a new creation request in Unee-T

	DROP TRIGGER IF EXISTS `ut_update_external_property_level_1`;

DELIMITER $$
CREATE TRIGGER `ut_update_external_property_level_1`
AFTER UPDATE ON `external_property_level_1_buildings`
FOR EACH ROW
BEGIN

# We only do this if 
#	- we need to create the property in Unee-T
#	- We have a `external_id`
#	- We have a `external_system_id`
#	- We have a `external_table`
#	- We have a `organization_id`
#	- We have a `tower`
#	- We have a MEFE user ID for the user who did the update
#	- The unit was already marked as needed to be created in Unee-T
#	- The `do_not_insert_field` is NOT equal to 1
#	- The unit already exist in the table `property_level_1_buildings`
#	- This is a valid update method:
#		- 'imported_from_hmlet_ipi'
#		- 'Manage_Buildings_Add_Page'
#		- 'Manage_Buildings_Edit_Page'
#		- 'Manage_Buildings_Import_Page'
#		- 'Export_and_Import_Buildings_Import_Page'
#		- ''

	SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator = NEW.`created_by_id` ;
	SET @source_system_updater = (IF(NEW.`updated_by_id` IS NULL
			, @source_system_creator
			, NEW.`updated_by_id`
			)
		);

	SET @creator_mefe_user_id = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator
		)
		;

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;

	SET @organization_id = @source_system_creator ;

	SET @external_id = NEW.`external_id` ;
	SET @external_system_id = NEW.`external_system_id` ; 
	SET @external_table = NEW.`external_table` ;
	SET @tower = NEW.`tower` ;

	SET @new_is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;
	SET @old_is_creation_needed_in_unee_t = OLD.`is_creation_needed_in_unee_t` ;

	SET @id_in_property_level_1_buildings = (SELECT `id_building`
		FROM `property_level_1_buildings`
		WHERE `external_system_id` = @external_system_id
			AND `external_table` = @external_table
			AND `external_id` = @external_id
			AND `organization_id` = @organization_id
			AND `tower` = @tower
		);

	SET @upstream_do_not_insert = NEW.`do_not_insert` ;

	# This is an UPDATE - the record SHOULD exist already
		SET @do_not_insert = (IF (@id_in_property_level_1_buildings IS NULL
				, 1
				, @upstream_do_not_insert
				)
			);

	# Get the information about the area for that building...
	# We need the information from the table `property_groups_areas` (and NOT the table `external_property_groups_areas`)
	
		SET @area_id_in_table_external_property_level_1_buildings = NEW.`area_id` ;

		SET @area_external_id = (SELECT `external_id`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_in_table_external_property_level_1_buildings
			);
		SET @area_external_system_id = (SELECT `external_system_id`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_in_table_external_property_level_1_buildings
			);
		SET @area_external_table = (SELECT `external_table`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_in_table_external_property_level_1_buildings
			);

		SET @area_id = (SELECT `id_area`
			FROM `property_groups_areas`
			WHERE `external_id` = @area_external_id
				AND `external_system_id` = @area_external_system_id
			   	AND `external_table` = @area_external_table
			   	AND `organization_id` = @organization_id
			);

	IF @is_creation_needed_in_unee_t = 1
		AND @new_is_creation_needed_in_unee_t = @old_is_creation_needed_in_unee_t
		AND @do_not_insert = 0
		AND @external_id IS NOT NULL
		AND @external_system_id IS NOT NULL
		AND @external_table IS NOT NULL
		AND @tower IS NOT NULL
		AND @organization_id IS NOT NULL
		AND @area_id IS NOT NULL
		AND (@upstream_create_method = 'imported_from_hmlet_ipi'
			OR @upstream_update_method = 'imported_from_hmlet_ipi'
			OR @upstream_create_method = 'Manage_Buildings_Add_Page'
			OR @upstream_update_method = 'Manage_Buildings_Add_Page'
			OR @upstream_create_method = 'Manage_Buildings_Edit_Page'
			OR @upstream_update_method = 'Manage_Buildings_Edit_Page'
			OR @upstream_create_method = 'Manage_Buildings_Import_Page'
			OR @upstream_update_method = 'Manage_Buildings_Import_Page'
			OR @upstream_create_method = 'Export_and_Import_Buildings_Import_Page'
			OR @upstream_update_method = 'Export_and_Import_Buildings_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `property_level_1_buildings` table:

		SET @this_trigger = 'ut_update_external_property_level_1';

		SET @syst_created_datetime = NOW();
		SET @creation_system_id = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator
			)
			;
		SET @created_by_id = @creator_mefe_user_id ;
		SET @downstream_creation_method = @this_trigger ;

		SET @syst_updated_datetime = NOW();

		SET @update_system_id = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater
			)
			;
		SET @updated_by_id = @creator_mefe_user_id ;
		SET @downstream_update_method = @this_trigger ;

		SET @organization_id_create = @source_system_creator;
		SET @organization_id_update = @source_system_updater;

		SET @is_obsolete = NEW.`is_obsolete` ;
		SET @order = NEW.`order` ;

		SET @unee_t_unit_type = NEW.`unee_t_unit_type` ;
		SET @designation = NEW.`designation` ;

		SET @address_1 = NEW.`address_1` ;
		SET @address_2 = NEW.`address_2` ;
		SET @zip_postal_code = NEW.`zip_postal_code` ;
		SET @state = NEW.`state` ;
		SET @city = NEW.`city` ;
		SET @country_code = NEW.`country_code` ;

		SET @description = NEW.`description` ;

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
				(@external_id
				, @external_system_id
				, @external_table
				, @syst_created_datetime
				, @creation_system_id
				, @created_by_id
				, @downstream_creation_method
				, @organization_id_create
				, @is_obsolete
				, @order
				, @area_id
				, @is_creation_needed_in_unee_t
				, @do_not_insert
				, @unee_t_unit_type
				, @designation
				, @tower
				, @address_1
				, @address_2
				, @zip_postal_code
				, @state
				, @city
				, @country_code
				, @description
				)
			ON DUPLICATE KEY UPDATE
				`syst_updated_datetime` = @syst_updated_datetime
				, `update_system_id` = @update_system_id
				, `updated_by_id` = @updated_by_id
				, `update_method` = @downstream_update_method
				, `organization_id` = @organization_id_update
				, `is_obsolete` = @is_obsolete
				, `order` = @order
				, `area_id` = @area_id
				, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t
				, `do_not_insert` = @do_not_insert
				, `unee_t_unit_type` = @unee_t_unit_type
				, `designation` = @designation
				, `tower` = @tower
				, `address_1` = @address_1
				, `address_2` = @address_2
				, `zip_postal_code` = @zip_postal_code
				, `state` = @state
				, `city` = @city
				, `country_code` = @country_code
				, `description` = @description
			;

	END IF;

# Housekeeping - we make sure that if a building is obsolete - all units in that building are obsolete too

	SET @building_system_id = NEW.`id_building` ;

		UPDATE `external_property_level_2_units` AS `a`
			INNER JOIN `external_property_level_1_buildings` AS `b`
				ON (`a`.`building_system_id` = `b`.`id_building`)
			SET `a`.`is_obsolete` = `b`.`is_obsolete`
			WHERE `a`.`building_system_id` = @building_system_id
			;

END;
$$
DELIMITER ;


# We create a trigger when a record is updated in the `external_property_level_1_buildings` table
#	- The unit DOES exist in the table `property_level_1_buildings`
#	- This IS a new creation request in Unee-T

	DROP TRIGGER IF EXISTS `ut_update_external_property_level_1_creation_needed`;

DELIMITER $$
CREATE TRIGGER `ut_update_external_property_level_1_creation_needed`
AFTER UPDATE ON `external_property_level_1_buildings`
FOR EACH ROW
BEGIN

# We only do this if 
#	- we need to create the property in Unee-T
#	- We have a `external_id`
#	- We have a `external_system_id`
#	- We have a `external_table`
#	- We have a `organization_id`
#	- We have a `tower`
#	- We have a MEFE user ID for the user who did the update
#	- The unit was already marked as needed to be created in Unee-T
#	- The `do_not_insert_field` is NOT equal to 1
#	- The unit already exist in the table `property_level_1_buildings`
#	- This is a valid update method:
#		- 'imported_from_hmlet_ipi'
#		- 'Manage_Buildings_Add_Page'
#		- 'Manage_Buildings_Edit_Page'
#		- 'Manage_Buildings_Import_Page'
#		- 'Export_and_Import_Buildings_Import_Page'
#		- ''

	SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator = NEW.`created_by_id` ;
	SET @source_system_updater = (IF(NEW.`updated_by_id` IS NULL
			, @source_system_creator
			, NEW.`updated_by_id`
			)
		);

	SET @creator_mefe_user_id = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator
		)
		;

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;

	SET @organization_id = @source_system_creator ;

	SET @external_id = NEW.`external_id` ;
	SET @external_system_id = NEW.`external_system_id` ; 
	SET @external_table = NEW.`external_table` ;
	SET @tower = NEW.`tower` ;

	SET @new_is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;
	SET @old_is_creation_needed_in_unee_t = OLD.`is_creation_needed_in_unee_t` ;

	SET @id_in_property_level_1_buildings = (SELECT `id_building`
		FROM `property_level_1_buildings`
		WHERE `external_system_id` = @external_system_id
			AND `external_table` = @external_table
			AND `external_id` = @external_id
			AND `organization_id` = @organization_id
			AND `tower` = @tower
		);

	SET @upstream_do_not_insert = NEW.`do_not_insert` ;

	# This is an UPDATE - the record SHOULD exist already
	# BUT there are some edge cases when we need to re-create this...
		SET @do_not_insert = @upstream_do_not_insert ;

	# Get the information about the area for that building...
	# We need the information from the table `property_groups_areas` (and NOT the table `external_property_groups_areas`)
	
		SET @area_id_in_table_external_property_level_1_buildings = NEW.`area_id` ;

		SET @area_external_id = (SELECT `external_id`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_in_table_external_property_level_1_buildings
			);
		SET @area_external_system_id = (SELECT `external_system_id`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_in_table_external_property_level_1_buildings
			);
		SET @area_external_table = (SELECT `external_table`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_in_table_external_property_level_1_buildings
			);

		SET @area_id = (SELECT `id_area`
			FROM `property_groups_areas`
			WHERE `external_id` = @area_external_id
				AND `external_system_id` = @area_external_system_id
			   	AND `external_table` = @area_external_table
			   	AND `organization_id` = @organization_id
			);

	IF @is_creation_needed_in_unee_t = 1
		AND @new_is_creation_needed_in_unee_t != @old_is_creation_needed_in_unee_t
		AND @do_not_insert = 0
		AND @external_id IS NOT NULL
		AND @external_system_id IS NOT NULL
		AND @external_table IS NOT NULL
		AND @tower IS NOT NULL
		AND @organization_id IS NOT NULL
		AND @area_id IS NOT NULL
		AND (@upstream_create_method = 'imported_from_hmlet_ipi'
			OR @upstream_update_method = 'imported_from_hmlet_ipi'
			OR @upstream_create_method = 'Manage_Buildings_Add_Page'
			OR @upstream_update_method = 'Manage_Buildings_Add_Page'
			OR @upstream_create_method = 'Manage_Buildings_Edit_Page'
			OR @upstream_update_method = 'Manage_Buildings_Edit_Page'
			OR @upstream_create_method = 'Manage_Buildings_Import_Page'
			OR @upstream_update_method = 'Manage_Buildings_Import_Page'
			OR @upstream_create_method = 'Export_and_Import_Buildings_Import_Page'
			OR @upstream_update_method = 'Export_and_Import_Buildings_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `property_level_1_buildings` table:

		SET @this_trigger = 'ut_update_external_property_level_1_creation_needed';

		SET @syst_created_datetime = NOW();
		SET @creation_system_id = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator
			)
			;
		SET @created_by_id = @creator_mefe_user_id ;
		SET @downstream_creation_method = @this_trigger ;

		SET @syst_updated_datetime = NOW();

		SET @update_system_id = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater
			)
			;
		SET @updated_by_id = @creator_mefe_user_id ;
		SET @downstream_update_method = @this_trigger ;

		SET @organization_id_create = @source_system_creator;
		SET @organization_id_update = @source_system_updater;

		SET @is_obsolete = NEW.`is_obsolete` ;
		SET @order = NEW.`order` ;

		SET @unee_t_unit_type = NEW.`unee_t_unit_type` ;
		SET @designation = NEW.`designation` ;

		SET @address_1 = NEW.`address_1` ;
		SET @address_2 = NEW.`address_2` ;
		SET @zip_postal_code = NEW.`zip_postal_code` ;
		SET @state = NEW.`state` ;
		SET @city = NEW.`city` ;
		SET @country_code = NEW.`country_code` ;

		SET @description = NEW.`description` ;

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
				(@external_id
				, @external_system_id
				, @external_table
				, @syst_created_datetime
				, @creation_system_id
				, @created_by_id
				, @downstream_creation_method
				, @organization_id_create
				, @is_obsolete
				, @order
				, @area_id
				, @is_creation_needed_in_unee_t
				, @do_not_insert
				, @unee_t_unit_type
				, @designation
				, @tower
				, @address_1
				, @address_2
				, @zip_postal_code
				, @state
				, @city
				, @country_code
				, @description
				)
			ON DUPLICATE KEY UPDATE
				`syst_updated_datetime` = @syst_updated_datetime
				, `update_system_id` = @update_system_id
				, `updated_by_id` = @updated_by_id
				, `update_method` = @downstream_update_method
				, `organization_id` = @organization_id_update
				, `is_obsolete` = @is_obsolete
				, `order` = @order
				, `area_id` = @area_id
				, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t
				, `do_not_insert` = @do_not_insert
				, `unee_t_unit_type` = @unee_t_unit_type
				, `designation` = @designation
				, `tower` = @tower
				, `address_1` = @address_1
				, `address_2` = @address_2
				, `zip_postal_code` = @zip_postal_code
				, `state` = @state
				, `city` = @city
				, `country_code` = @country_code
				, `description` = @description
			;

	END IF;

# Housekeeping - we make sure that if a building is obsolete - all units in that building are obsolete too

	SET @building_system_id = NEW.`id_building` ;

		UPDATE `external_property_level_2_units` AS `a`
			INNER JOIN `external_property_level_1_buildings` AS `b`
				ON (`a`.`building_system_id` = `b`.`id_building`)
			SET `a`.`is_obsolete` = `b`.`is_obsolete`
			WHERE `a`.`building_system_id` = @building_system_id
			;

END;
$$
DELIMITER ;

# Create a trigger to update the table that will fire the lambda each time a new building needs to be created

		DROP TRIGGER IF EXISTS `ut_update_map_external_source_unit_add_building`;

DELIMITER $$
CREATE TRIGGER `ut_update_map_external_source_unit_add_building`
AFTER INSERT ON `property_level_1_buildings`
FOR EACH ROW
BEGIN

# We do this ONLY IF 
#	- We have marked the property as an object we need to create in Unee-T
#	- The record does NOT exist in the table `ut_map_external_source_units` yet
#	- The record has NOT been explicitly been marked as `do_not_insert`
#	- This is done via an authorized Insert Method:
#		- 'ut_insert_external_property_level_1'
#		- 'ut_update_external_property_level_1'
#		- 'ut_update_external_property_level_1_creation_needed'
#		- ''
#

	SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;

	SET @external_property_id = NEW.`external_id` ;
	SET @external_system = NEW.`external_system_id` ;
	SET @table_in_external_system = NEW.`external_table` ;
	SET @organization_id = NEW.`organization_id`;
	SET @tower = NEW.`tower` ; 

	SET @id_building = NEW.`id_building` ;

	SET @id_in_ut_map_external_source_units = (SELECT `id_map`
		FROM `ut_map_external_source_units`
		WHERE `external_property_type_id` = 1
			AND `external_property_id` = @external_property_id
			AND `external_system` = @external_system
			AND `table_in_external_system` = @table_in_external_system
			AND `organization_id` = @organization_id
			AND `tower` = @tower
		);

	SET @existing_mefe_unit_id = (SELECT `unee_t_mefe_unit_id`
		FROM `ut_map_external_source_units`
		WHERE `external_property_type_id` = 1
			AND `external_property_id` = @external_property_id
			AND `external_system` = @external_system
			AND `table_in_external_system` = @table_in_external_system
			AND `organization_id` = @organization_id
			AND `tower` = @tower
		);

	# This is an insert - if the record does NOT exist, we create the record
	# unless it is specifically specified that we do NOT need to create the record.
		SET @do_not_insert = (IF (@id_in_ut_map_external_source_units IS NULL
				, 0
				, NEW.`do_not_insert`
				)
			
			);

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;

	IF @is_creation_needed_in_unee_t = 1
		AND @do_not_insert = 0
		AND @existing_mefe_unit_id IS NULL
		AND (@upstream_create_method = 'ut_insert_external_property_level_1'
			OR @upstream_update_method = 'ut_insert_external_property_level_1'
			OR @upstream_create_method = 'ut_update_external_property_level_1'
			OR @upstream_update_method = 'ut_update_external_property_level_1'
			OR @upstream_create_method = 'ut_update_external_property_level_1_creation_needed'
			OR @upstream_update_method = 'ut_update_external_property_level_1_creation_needed'
			)
	THEN 

	# We capture the values we need for the insert/udpate:

		SET @this_trigger = 'ut_update_map_external_source_unit_add_building' ;

		SET @syst_created_datetime = NOW();
		SET @creation_system_id = NEW.`creation_system_id`;
		SET @created_by_id = NEW.`created_by_id`;
		SET @creation_method = @this_trigger ;

		SET @syst_updated_datetime = NOW();
		SET @update_system_id = NEW.`creation_system_id`;
		SET @updated_by_id = NEW.`created_by_id`;
		SET @update_method = @this_trigger ;

		SET @is_obsolete = NEW.`is_obsolete`;
		SET @is_update_needed = NULL;
			
		SET @uneet_name = NEW.`designation`;

		SET @unee_t_unit_type = (IFNULL(NEW.`unee_t_unit_type`
				, 'Unknown'
				)
			)
			;
			
		SET @new_record_id = NEW.`id_building`;
		SET @external_property_type_id = 1;
		
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
				, `new_record_id`
				, `external_property_type_id`
				, `external_property_id`
				, `external_system`
				, `table_in_external_system`
				, `tower`
				)
				VALUES
					(@syst_created_datetime
					, @creation_system_id
					, @created_by_id
					, @creation_method
					, @organization_id
					, @is_obsolete
					, @is_update_needed
					, @uneet_name
					, @unee_t_unit_type
					, @new_record_id
					, @external_property_type_id
					, @external_property_id
					, @external_system
					, @table_in_external_system
					, @tower
					)
				ON DUPLICATE KEY UPDATE 
					`syst_updated_datetime` = @syst_updated_datetime
					, `update_system_id` = @update_system_id
					, `updated_by_id` = @updated_by_id
					, `update_method` = @update_method
					, `organization_id` = @organization_id
					, `uneet_name` = @uneet_name
					, `unee_t_unit_type` = @unee_t_unit_type
					, `is_update_needed` = @is_update_needed
				;

	END IF;
END;
$$
DELIMITER ;

# Create a trigger to update the table that will fire the lambda each time a new building is marked as `is_creation_needed_in_unee_t` = 1

	DROP TRIGGER IF EXISTS `ut_update_map_external_source_unit_add_building_creation_needed`;

DELIMITER $$
CREATE TRIGGER `ut_update_map_external_source_unit_add_building_creation_needed`
AFTER UPDATE ON `property_level_1_buildings`
FOR EACH ROW
BEGIN

# We only do this IF:
# 	- We need to create the unit in Unee-T
#	- We do NOT have a MEFE unit ID for that unit
#	- The record has NOT been explicitly been marked as `do_not_insert`
#	- This is done via an authorized update Method:
#		- `ut_insert_external_property_level_1`
#		- 'ut_update_external_property_level_1_creation_needed'
#		- ''

	SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;

	SET @external_property_id = NEW.`external_id` ;
	SET @external_system = NEW.`external_system_id` ;
	SET @table_in_external_system = NEW.`external_table` ;
	SET @organization_id = NEW.`organization_id`;
	SET @tower = NEW.`tower` ; 

	SET @new_is_creation_needed_in_unee_t =  NEW.`is_creation_needed_in_unee_t` ;
	SET @old_is_creation_needed_in_unee_t = OLD.`is_creation_needed_in_unee_t` ; 

	SET @do_not_insert = NEW.`do_not_insert` ;

	SET @id_building = NEW.`id_building` ;

	SET @mefe_unit_id = (SELECT `unee_t_mefe_unit_id`
		FROM `ut_map_external_source_units`
		WHERE `external_property_type_id` = 1
			AND `external_property_id` = @external_property_id
			AND `external_system` = @external_system
			AND `table_in_external_system` = @table_in_external_system
			AND `organization_id` = @organization_id
			AND `tower` = @tower
		);

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;

	IF @is_creation_needed_in_unee_t = 1
		AND @do_not_insert = 0
		AND @mefe_unit_id IS NULL
		AND (@upstream_create_method = 'ut_insert_external_property_level_1'
			OR @upstream_update_method = 'ut_insert_external_property_level_1'
			OR @upstream_create_method = 'ut_update_external_property_level_1_creation_needed'
			OR @upstream_update_method = 'ut_update_external_property_level_1_creation_needed'
			)
	THEN 

		# We capture the values we need for the insert/udpate:

			SET @this_trigger = 'ut_update_map_external_source_unit_add_building_creation_needed' ;

			SET @syst_created_datetime = NOW();
			SET @creation_system_id = NEW.`update_system_id`;
			SET @created_by_id = NEW.`updated_by_id`;
			SET @creation_method = @this_trigger ;

			SET @syst_updated_datetime = NOW();
			SET @update_system_id = NEW.`update_system_id`;
			SET @updated_by_id = NEW.`updated_by_id`;
			SET @update_method = @this_trigger ;

			SET @organization_id = NEW.`organization_id`;

			SET @tower = NEW.`tower` ; 
			
			SET @is_obsolete = NEW.`is_obsolete`;
			SET @is_update_needed = 1 ;
			
			SET @uneet_name = NEW.`designation`;

			SET @unee_t_unit_type = (IFNULL(NEW.`unee_t_unit_type`
					, 'Unknown'
					)
				)
				;
			
			SET @new_record_id = NEW.`id_building`;
			SET @external_property_type_id = 1;

			SET @external_property_id = NEW.`external_id`;
			SET @external_system = NEW.`external_system_id`;
			SET @table_in_external_system = NEW.`external_table`;
		
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
				, `new_record_id`
				, `external_property_type_id`
				, `external_property_id`
				, `external_system`
				, `table_in_external_system`
				, `tower`
				)
				VALUES
					(@syst_created_datetime
					, @creation_system_id
					, @created_by_id
					, @creation_method
					, @organization_id
					, @is_obsolete
					, @is_update_needed
					, @uneet_name
					, @unee_t_unit_type
					, @new_record_id
					, @external_property_type_id
					, @external_property_id
					, @external_system
					, @table_in_external_system
					, @tower
					)
				ON DUPLICATE KEY UPDATE
					`syst_updated_datetime` = @syst_updated_datetime
					, `update_system_id` = @update_system_id
					, `updated_by_id` = @updated_by_id
					, `update_method` = @update_method
					, `organization_id` = @organization_id
					, `uneet_name` = @uneet_name
					, `unee_t_unit_type` = @unee_t_unit_type
					, `is_update_needed` = @is_update_needed
				;

	END IF;
END;
$$
DELIMITER ;

# Create a trigger to update the table that will fire the lambda each time 
# a new Property Level 1 needs to be updated

	DROP TRIGGER IF EXISTS `ut_update_map_external_source_unit_edit_level_1`;

DELIMITER $$
CREATE TRIGGER `ut_update_map_external_source_unit_edit_level_1`
AFTER UPDATE ON `property_level_1_buildings`
FOR EACH ROW
BEGIN

# We only do this IF:
# 	- We need to create the unit in Unee-T
#	- We DO have a MEFE unit ID for that unit
#	- The record has NOT been explicitly been marked as `do_not_insert`
#	- This is done via an authorized update Method:
#		- `ut_update_external_property_level_1`
#		- ''

	SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;

	SET @external_property_id = NEW.`external_id` ;
	SET @external_system = NEW.`external_system_id` ;
	SET @table_in_external_system = NEW.`external_table` ;
	SET @organization_id = NEW.`organization_id`;
	SET @tower = NEW.`tower` ; 

	SET @new_is_creation_needed_in_unee_t =  NEW.`is_creation_needed_in_unee_t` ;
	SET @old_is_creation_needed_in_unee_t = OLD.`is_creation_needed_in_unee_t` ; 

	SET @do_not_insert = NEW.`do_not_insert` ;

	SET @id_building = NEW.`id_building` ;

	SET @mefe_unit_id = (SELECT `unee_t_mefe_unit_id`
		FROM `ut_map_external_source_units`
		WHERE `external_property_type_id` = 1
			AND `external_property_id` = @external_property_id
			AND `external_system` = @external_system
			AND `table_in_external_system` = @table_in_external_system
			AND `organization_id` = @organization_id
			AND `tower` = @tower
		);

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;

	IF @is_creation_needed_in_unee_t = 1
		AND @do_not_insert = 0
		AND @mefe_unit_id IS NOT NULL
		AND (@upstream_create_method = 'ut_update_external_property_level_1'
			OR @upstream_update_method = 'ut_update_external_property_level_1'
			)
	THEN 

		# We capture the values we need for the insert/udpate:

			SET @this_trigger = 'ut_update_map_external_source_unit_edit_level_1' ;

			SET @syst_created_datetime = NOW();
			SET @creation_system_id = NEW.`update_system_id`;
			SET @created_by_id = NEW.`updated_by_id`;
			SET @creation_method = @this_trigger ;

			SET @syst_updated_datetime = NOW();
			SET @update_system_id = NEW.`update_system_id`;
			SET @updated_by_id = NEW.`updated_by_id`;
			SET @update_method = @this_trigger ;

			SET @organization_id = NEW.`organization_id`;

			SET @tower = NEW.`tower` ; 
			
			SET @is_obsolete = NEW.`is_obsolete`;
			SET @is_update_needed = 1 ;
			
			SET @uneet_name = NEW.`designation`;

			SET @unee_t_unit_type = (IFNULL(NEW.`unee_t_unit_type`
					, 'Unknown'
					)
				)
				;
			
			SET @new_record_id = NEW.`id_building`;
			SET @external_property_type_id = 1;

			SET @external_property_id = NEW.`external_id`;
			SET @external_system = NEW.`external_system_id`;
			SET @table_in_external_system = NEW.`external_table`;

			SET @is_mefe_api_success := 0 ;
			SET @mefe_api_error_message := (CONCAT('N/A - written by '
					, '`'
					, @this_trigger
					, '`'
					)
				);

		# We insert/Update a new record in the table `ut_map_external_source_units`

			INSERT INTO `ut_map_external_source_units`
				( `syst_created_datetime`
				, `creation_system_id`
				, `created_by_id`
				, `creation_method`
				, `organization_id`
				, `is_obsolete`
				, `is_update_needed`
				, `is_mefe_api_success`
				, `mefe_api_error_message`
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
					(@syst_created_datetime
					, @creation_system_id
					, @created_by_id
					, @creation_method
					, @organization_id
					, @is_obsolete
					, @is_update_needed
					, @is_mefe_api_success
					, @mefe_api_error_message
					, @uneet_name
					, @unee_t_unit_type
					, @new_record_id
					, @external_property_type_id
					, @external_property_id
					, @external_system
					, @table_in_external_system
					, @tower
					)
				ON DUPLICATE KEY UPDATE
					`syst_updated_datetime` = @syst_updated_datetime
					, `update_system_id` = @update_system_id
					, `updated_by_id` = @updated_by_id
					, `update_method` = @update_method
					, `organization_id` = @organization_id
					, `is_mefe_api_success` = @is_mefe_api_success
					, `mefe_api_error_message` = @mefe_api_error_message
					, `uneet_name` = @uneet_name
					, `unee_t_unit_type` = @unee_t_unit_type
					, `is_update_needed` = @is_update_needed
				;

	END IF;
END;
$$
DELIMITER ;
