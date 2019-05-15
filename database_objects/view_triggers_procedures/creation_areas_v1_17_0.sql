#################
#
# This lists all the triggers we use to create 
# an area
# via the Unee-T Enterprise Interface
#
#################

# We create a trigger when a record is added to the `external_property_groups_areas` table

	DROP TRIGGER IF EXISTS `ut_insert_external_area`;

DELIMITER $$
CREATE TRIGGER `ut_insert_external_area`
AFTER INSERT ON `external_property_groups_areas`
FOR EACH ROW
BEGIN

# We only do this if 
#	- We need to create the area in Unee-T
#	  by default we should create ALL areas but we want maximum flexibility here...
#	- This is a valid insert method:
#		- 'imported_from_hmlet_ipi'
#		- `Manage_Areas_Add_Page`
#		- `Manage_Areas_Edit_Page`
#		- 'Manage_Areas_Import_Page'
#		- 'Export_and_Import_Areas_Import_Page'
#		- ''

	SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator = NEW.`created_by_id` ;
	SET @source_system_updater = NEW.`updated_by_id`;

	SET @creator_mefe_user_id = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator
		)
		;

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;

	SET @external_id = NEW.`external_id` ;
	SET @external_system_id = NEW.`external_system_id` ; 
	SET @external_table = NEW.`external_table` ;

	IF @is_creation_needed_in_unee_t = 1
		AND @external_id IS NOT NULL
		AND @external_system_id IS NOT NULL
		AND @external_table IS NOT NULL
		AND (@upstream_create_method = 'imported_from_hmlet_ipi'
			OR @upstream_create_method = 'Manage_Areas_Add_Page'
			OR @upstream_create_method = 'Manage_Areas_Edit_Page'
			OR @upstream_create_method = 'Manage_Areas_Import_Page'
			OR @upstream_create_method = 'Export_and_Import_Areas_Import_Page'
			OR @upstream_update_method = 'imported_from_hmlet_ipi'
			OR @upstream_update_method = 'Manage_Areas_Add_Page'
			OR @upstream_update_method = 'Manage_Areas_Edit_Page'
			OR @upstream_update_method = 'Manage_Areas_Import_Page'
			OR @upstream_update_method = 'Export_and_Import_Areas_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `property_groups_areas` table:

		SET @this_trigger = 'ut_insert_external_area' ;

		SET @syst_created_datetime = NOW();
		SET @creation_system_id = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator
			)
			;
		SET @created_by_id = @creator_mefe_user_id ;
		SET @downstream_creation_method = @this_trigger ;

		SET @syst_updated_datetime = NOW();

		SET @source_system_updater = NEW.`updated_by_id` ; 

		SET @update_system_id = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater
			)
			;
		SET @updated_by_id = @creator_mefe_user_id ;
		SET @downstream_update_method = @this_trigger ;

		SET @organization_id_create = @source_system_creator ;
		SET @organization_id_update = @source_system_updater;

		SET @country_code = NEW.`country_code` ;
		SET @is_obsolete = NEW.`is_obsolete` ;
		SET @is_default = NEW.`is_default` ;
		SET @order = NEW.`order` ;
		SET @area_name = NEW.`area_name` ;
		SET @area_definition = NEW.`area_definition` ;

	# We insert the record in the table `property_groups_areas`

			INSERT INTO `property_groups_areas`
				(`external_id`
				, `external_system_id` 
				, `external_table`
				, `syst_created_datetime`
				, `creation_system_id`
				, `created_by_id`
				, `creation_method`
				, `organization_id`
				, `country_code`
				, `is_obsolete`
				, `is_default`
				, `order`
				, `area_name`
				, `area_definition`
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
					, @country_code
					, @is_obsolete
					, @is_default
					, @order
					, @area_name
					, @area_definition
					)
				ON DUPLICATE KEY UPDATE
					`syst_updated_datetime` = @syst_updated_datetime
					, `update_system_id` = @update_system_id
					, `updated_by_id` = @updated_by_id
					, `update_method` = @downstream_update_method
					, `country_code` = @country_code
					, `is_obsolete` = @is_obsolete
					, `is_default` = @is_default
					, `order` = @order
					, `area_definition` = @area_definition
					, `area_name` = @area_name
				;

	END IF;

END;
$$
DELIMITER ;

# We create a trigger when a record is updated in the `external_property_groups_areas` table
# The area DOES exist in the table `property_groups_areas`

	DROP TRIGGER IF EXISTS `ut_update_external_area`;

DELIMITER $$
CREATE TRIGGER `ut_update_external_area`
AFTER UPDATE ON `external_property_groups_areas`
FOR EACH ROW
BEGIN

# We only do this if 
#	- We need to create the area in Unee-T
#	  by default we should create ALL areas but we want maximum flexibility here...
#	- This is a valid update method:
#		- 'imported_from_hmlet_ipi'
#		- `Manage_Areas_Add_Page`
#		- `Manage_Areas_Edit_Page`
#		- 'Manage_Areas_Import_Page'
#		- 'Export_and_Import_Areas_Import_Page'
#		- ''

	SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator = NEW.`created_by_id` ;
	SET @source_system_updater = NEW.`updated_by_id`;

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

	SET @new_is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;
	SET @old_is_creation_needed_in_unee_t = OLD.`is_creation_needed_in_unee_t` ;

	IF @is_creation_needed_in_unee_t = 1
		AND @new_is_creation_needed_in_unee_t = @old_is_creation_needed_in_unee_t
		AND @external_id IS NOT NULL
		AND @external_system_id IS NOT NULL
		AND @external_table IS NOT NULL
		AND @organization_id IS NOT NULL
		AND (@upstream_update_method = 'imported_from_hmlet_ipi'
			OR @upstream_update_method = 'Manage_Areas_Add_Page'
			OR @upstream_update_method = 'Manage_Areas_Edit_Page'
			OR @upstream_update_method = 'Manage_Areas_Import_Page'
			OR @upstream_update_method = 'Export_and_Import_Areas_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `property_groups_areas` table:

		SET @this_trigger = 'ut_update_external_area' ;

		SET @record_to_update = (SELECT `id_area`
			FROM `property_groups_areas`
			WHERE `external_id` = @external_id
				AND `external_system_id` = @external_system_id
				AND `external_table` = @external_table
				AND `organization_id` = @organization_id
			);

		SET @syst_updated_datetime = NOW();

		SET @source_system_updater = NEW.`updated_by_id` ; 

		SET @update_system_id = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater
			)
			;
		SET @updated_by_id = @creator_mefe_user_id ;
		SET @downstream_update_method = @this_trigger ;

		SET @organization_id_create = @source_system_creator;
		SET @organization_id_update = @source_system_updater;

		SET @country_code = NEW.`country_code` ;
		SET @is_obsolete = NEW.`is_obsolete` ;
		SET @is_default = NEW.`is_default` ;
		SET @order = NEW.`order` ;
		SET @area_name = NEW.`area_name` ;
		SET @area_definition = NEW.`area_definition` ;

	# We update the record in the table `property_groups_areas`
	
		UPDATE `property_groups_areas`
		SET
			`syst_updated_datetime` = @syst_updated_datetime
			, `update_system_id` = @update_system_id
			, `updated_by_id` = @updated_by_id
			, `update_method` = @downstream_update_method
			, `country_code` = @country_code
			, `is_obsolete` = @is_obsolete
			, `is_default` = @is_default
			, `order` = @order
			, `area_definition` = @area_definition
			, `area_name` = @area_name
			WHERE `id_area` = @record_to_update
			;

	END IF;

END;
$$
DELIMITER ;

# We create a trigger when a record is updated in the `external_property_groups_areas` table
# AND the area is marked as needed to be created in Unee-T
# The area does NOT exists in the table `property_groups_areas`

	DROP TRIGGER IF EXISTS `ut_created_external_area_after_insert`;

DELIMITER $$
CREATE TRIGGER `ut_created_external_area_after_insert`
AFTER UPDATE ON `external_property_groups_areas`
FOR EACH ROW
BEGIN

# We only do this if:
#	- We need to create the area in Unee-T
#	  by default we should create ALL areas but we want maximum flexibility here...
#	- This is a valid update method:
#		- 'imported_from_hmlet_ipi'
#		- `Manage_Areas_Add_Page`
#		- `Manage_Areas_Edit_Page`
#		- 'Manage_Areas_Import_Page'
#		- 'Export_and_Import_Areas_Import_Page'
#		- ''

	SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator = NEW.`created_by_id` ;
	SET @source_system_updater = NEW.`updated_by_id`;

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

	SET @new_is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;
	SET @old_is_creation_needed_in_unee_t = OLD.`is_creation_needed_in_unee_t` ;

	IF @is_creation_needed_in_unee_t = 1
		AND @new_is_creation_needed_in_unee_t != @old_is_creation_needed_in_unee_t
		AND @external_id IS NOT NULL
		AND @external_system_id IS NOT NULL
		AND @external_table IS NOT NULL
		AND @organization_id IS NOT NULL
		AND (@upstream_update_method = 'imported_from_hmlet_ipi'
			OR @upstream_update_method = 'Manage_Areas_Add_Page'
			OR @upstream_update_method = 'Manage_Areas_Edit_Page'
			OR @upstream_update_method = 'Manage_Areas_Import_Page'
			OR @upstream_update_method = 'Export_and_Import_Areas_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `property_groups_areas` table:

		SET @this_trigger = 'ut_created_external_area_after_insert' ;

		SET @syst_created_datetime = NOW();
		SET @creation_system_id = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator
			)
			;
		SET @created_by_id = @creator_mefe_user_id ;
		SET @downstream_creation_method = @this_trigger ;

		SET @syst_updated_datetime = NOW();

		SET @source_system_updater = NEW.`updated_by_id` ; 

		SET @update_system_id = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater
			)
			;
		SET @updated_by_id = @creator_mefe_user_id ;
		SET @downstream_update_method = @this_trigger ;

		SET @organization_id_create = @source_system_creator;
		SET @organization_id_update = @source_system_updater;

		SET @country_code = NEW.`country_code` ;
		SET @is_obsolete = NEW.`is_obsolete` ;
		SET @is_default = NEW.`is_default` ;
		SET @order = NEW.`order` ;
		SET @area_name = NEW.`area_name` ;
		SET @area_definition = NEW.`area_definition` ;

	# We insert the record in the table `property_groups_areas`

			INSERT INTO `property_groups_areas`
				(`external_id`
				, `external_system_id` 
				, `external_table`
				, `syst_created_datetime`
				, `creation_system_id`
				, `created_by_id`
				, `creation_method`
				, `is_creation_needed_in_unee_t`
				, `organization_id`
				, `country_code`
				, `is_obsolete`
				, `is_default`
				, `order`
				, `area_name`
				, `area_definition`
				)
				VALUES
					(@external_id
					, @external_system_id
					, @external_table
					, @syst_created_datetime
					, @creation_system_id
					, @created_by_id
					, @downstream_creation_method
					, @is_creation_needed_in_unee_t
					, @organization_id_create
					, @country_code
					, @is_obsolete
					, @is_default
					, @order
					, @area_name
					, @area_definition
					)
				ON DUPLICATE KEY UPDATE
					`syst_updated_datetime` = @syst_updated_datetime
					, `update_system_id` = @update_system_id
					, `updated_by_id` = @updated_by_id
					, `update_method` = @downstream_update_method
					, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t
					, `organization_id` = @organization_id_update
					, `country_code` = @country_code
					, `is_obsolete` = @is_obsolete
					, `is_default` = @is_default
					, `order` = @order
					, `area_definition` = @area_definition
					, `area_name` = @area_name

				;

	END IF;

END;
$$
DELIMITER ;