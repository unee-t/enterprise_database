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

	SET @is_creation_needed_in_unee_t_insert_ext_area_1 = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator_insert_ext_area_1 = NEW.`created_by_id` ;
	SET @source_system_updater_insert_ext_area_1 = NEW.`updated_by_id`;

	SET @creator_mefe_user_id_insert_ext_area_1 = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator_insert_ext_area_1
		)
		;

	SET @upstream_create_method_insert_ext_area_1 = NEW.`creation_method` ;
	SET @upstream_update_method_insert_ext_area_1 = NEW.`update_method` ;

	SET @external_id_insert_ext_area_1 = NEW.`external_id` ;
	SET @external_system_id_insert_ext_area_1 = NEW.`external_system_id` ; 
	SET @external_table_insert_ext_area_1 = NEW.`external_table` ;

	IF @is_creation_needed_in_unee_t_insert_ext_area_1 = 1
		AND @external_id_insert_ext_area_1 IS NOT NULL
		AND @external_system_id_insert_ext_area_1 IS NOT NULL
		AND @external_table_insert_ext_area_1 IS NOT NULL
		AND (@upstream_create_method_insert_ext_area_1 = 'imported_from_hmlet_ipi'
			OR @upstream_create_method_insert_ext_area_1 = 'Manage_Areas_Add_Page'
			OR @upstream_create_method_insert_ext_area_1 = 'Manage_Areas_Edit_Page'
			OR @upstream_create_method_insert_ext_area_1 = 'Manage_Areas_Import_Page'
			OR @upstream_create_method_insert_ext_area_1 = 'Export_and_Import_Areas_Import_Page'
			OR @upstream_update_method_insert_ext_area_1 = 'imported_from_hmlet_ipi'
			OR @upstream_update_method_insert_ext_area_1 = 'Manage_Areas_Add_Page'
			OR @upstream_update_method_insert_ext_area_1 = 'Manage_Areas_Edit_Page'
			OR @upstream_update_method_insert_ext_area_1 = 'Manage_Areas_Import_Page'
			OR @upstream_update_method_insert_ext_area_1 = 'Export_and_Import_Areas_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `property_groups_areas` table:

		SET @this_trigger_insert_ext_area_1 = 'ut_insert_external_area' ;

		SET @syst_created_datetime_insert_ext_area_1 = NOW();
		SET @creation_system_id_insert_ext_area_1 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator_insert_ext_area_1
			)
			;
		SET @created_by_id_insert_ext_area_1 = @creator_mefe_user_id_insert_ext_area_1 ;
		SET @downstream_creation_method_insert_ext_area_1 = @this_trigger_insert_ext_area_1 ;

		SET @syst_updated_datetime_insert_ext_area_1 = NOW();

		SET @source_system_updater_insert_ext_area_1 = NEW.`updated_by_id` ; 

		SET @update_system_id_insert_ext_area_1 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater_insert_ext_area_1
			)
			;
		SET @updated_by_id_insert_ext_area_1 = @creator_mefe_user_id_insert_ext_area_1 ;
		SET @downstream_update_method_insert_ext_area_1 = @this_trigger_insert_ext_area_1 ;

		SET @organization_id_create_insert_ext_area_1 = @source_system_creator_insert_ext_area_1 ;
		SET @organization_id_update_insert_ext_area_1 = @source_system_updater_insert_ext_area_1 ;

		SET @country_code_insert_ext_area_1 = NEW.`country_code` ;
		SET @is_obsolete_insert_ext_area_1 = NEW.`is_obsolete` ;
		SET @is_default_insert_ext_area_1 = NEW.`is_default` ;
		SET @order_insert_ext_area_1 = NEW.`order` ;
		SET @area_name_insert_ext_area_1 = NEW.`area_name` ;
		SET @area_definition_insert_ext_area_1 = NEW.`area_definition` ;

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
					(@external_id_insert_ext_area_1
					, @external_system_id_insert_ext_area_1
					, @external_table_insert_ext_area_1
					, @syst_created_datetime_insert_ext_area_1
					, @creation_system_id_insert_ext_area_1
					, @created_by_id_insert_ext_area_1
					, @downstream_creation_method_insert_ext_area_1
					, @organization_id_create_insert_ext_area_1
					, @country_code_insert_ext_area_1
					, @is_obsolete_insert_ext_area_1
					, @is_default_insert_ext_area_1
					, @order_insert_ext_area_1
					, @area_name_insert_ext_area_1
					, @area_definition_insert_ext_area_1
					)
				ON DUPLICATE KEY UPDATE
					`syst_updated_datetime` = @syst_updated_datetime_insert_ext_area_1
					, `update_system_id` = @update_system_id_insert_ext_area_1
					, `updated_by_id` = @updated_by_id_insert_ext_area_1
					, `update_method` = @downstream_update_method_insert_ext_area_1
					, `country_code` = @country_code_insert_ext_area_1
					, `is_obsolete` = @is_obsolete_insert_ext_area_1
					, `is_default` = @is_default_insert_ext_area_1
					, `order` = @order_insert_ext_area_1
					, `area_definition` = @area_definition_insert_ext_area_1
					, `area_name` = @area_name_insert_ext_area_1
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

	SET @is_creation_needed_in_unee_t_update_ext_area_1 = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator_update_ext_area_1 = NEW.`created_by_id` ;
	SET @source_system_updater_update_ext_area_1 = NEW.`updated_by_id`;

	SET @creator_mefe_user_id_update_ext_area_1 = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator_update_ext_area_1
		)
		;

	SET @upstream_create_method_update_ext_area_1 = NEW.`creation_method` ;
	SET @upstream_update_method_update_ext_area_1 = NEW.`update_method` ;
	
	SET @organization_id_update_ext_area_1 = @source_system_creator_update_ext_area_1 ;

	SET @external_id_update_ext_area_1 = NEW.`external_id` ;
	SET @external_system_id_update_ext_area_1 = NEW.`external_system_id` ; 
	SET @external_table_update_ext_area_1 = NEW.`external_table` ;

	SET @new_is_creation_needed_in_unee_t_update_ext_area_1 = NEW.`is_creation_needed_in_unee_t` ;
	SET @old_is_creation_needed_in_unee_t_update_ext_area_1 = OLD.`is_creation_needed_in_unee_t` ;

	IF @is_creation_needed_in_unee_t_update_ext_area_1 = 1
		AND @new_is_creation_needed_in_unee_t_update_ext_area_1 = @old_is_creation_needed_in_unee_t_update_ext_area_1
		AND @external_id_update_ext_area_1 IS NOT NULL
		AND @external_system_id_update_ext_area_1 IS NOT NULL
		AND @external_table_update_ext_area_1 IS NOT NULL
		AND @organization_id_update_ext_area_1 IS NOT NULL
		AND (@upstream_update_method_update_ext_area_1 = 'imported_from_hmlet_ipi'
			OR @upstream_update_method_update_ext_area_1 = 'Manage_Areas_Add_Page'
			OR @upstream_update_method_update_ext_area_1 = 'Manage_Areas_Edit_Page'
			OR @upstream_update_method_update_ext_area_1 = 'Manage_Areas_Import_Page'
			OR @upstream_update_method_update_ext_area_1 = 'Export_and_Import_Areas_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `property_groups_areas` table:

		SET @this_trigger_update_ext_area_1 = 'ut_update_external_area' ;

		SET @record_to_update_update_ext_area_1 = (SELECT `id_area`
			FROM `property_groups_areas`
			WHERE `external_id` = @external_id_update_ext_area_1
				AND `external_system_id` = @external_system_id_update_ext_area_1
				AND `external_table` = @external_table_update_ext_area_1
				AND `organization_id` = @organization_id_update_ext_area_1
			);

		SET @syst_updated_datetime_update_ext_area_1 = NOW();

		SET @source_system_updater_update_ext_area_1 = NEW.`updated_by_id` ; 

		SET @update_system_id_update_ext_area_1 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater_update_ext_area_1
			)
			;
		SET @updated_by_id_update_ext_area_1 = @creator_mefe_user_id_update_ext_area_1 ;
		SET @downstream_update_method_update_ext_area_1 = @this_trigger_update_ext_area_1 ;

		SET @organization_id_create_update_ext_area_1 = @source_system_creator_update_ext_area_1 ;
		SET @organization_id_update_update_ext_area_1 = @source_system_updater_update_ext_area_1 ;

		SET @country_code_update_ext_area_1 = NEW.`country_code` ;
		SET @is_obsolete_update_ext_area_1 = NEW.`is_obsolete` ;
		SET @is_default_update_ext_area_1 = NEW.`is_default` ;
		SET @order_update_ext_area_1 = NEW.`order` ;
		SET @area_name_update_ext_area_1 = NEW.`area_name` ;
		SET @area_definition_update_ext_area_1 = NEW.`area_definition` ;

	# We update the record in the table `property_groups_areas`
	
		UPDATE `property_groups_areas`
		SET
			`syst_updated_datetime` = @syst_updated_datetime_update_ext_area_1
			, `update_system_id` = @update_system_id_update_ext_area_1
			, `updated_by_id` = @updated_by_id_update_ext_area_1
			, `update_method` = @downstream_update_method_update_ext_area_1
			, `country_code` = @country_code_update_ext_area_1
			, `is_obsolete` = @is_obsolete_update_ext_area_1
			, `is_default` = @is_default_update_ext_area_1
			, `order` = @order_update_ext_area_1
			, `area_definition` = @area_definition_update_ext_area_1
			, `area_name` = @area_name_update_ext_area_1
			WHERE `id_area` = @record_to_update_update_ext_area_1
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

	SET @is_creation_needed_in_unee_t_update_ext_area_2 = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator_update_ext_area_2 = NEW.`created_by_id` ;
	SET @source_system_updater_update_ext_area_2 = NEW.`updated_by_id`;

	SET @creator_mefe_user_id_update_ext_area_2 = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator_update_ext_area_2
		)
		;

	SET @upstream_create_method_update_ext_area_2 = NEW.`creation_method` ;
	SET @upstream_update_method_update_ext_area_2 = NEW.`update_method` ;
	
	SET @organization_id_update_ext_area_2 = @source_system_creator_update_ext_area_2 ;

	SET @external_id_update_ext_area_2 = NEW.`external_id` ;
	SET @external_system_id_update_ext_area_2 = NEW.`external_system_id` ; 
	SET @external_table_update_ext_area_2 = NEW.`external_table` ;

	SET @new_is_creation_needed_in_unee_t_update_ext_area_2 = NEW.`is_creation_needed_in_unee_t` ;
	SET @old_is_creation_needed_in_unee_t_update_ext_area_2 = OLD.`is_creation_needed_in_unee_t` ;

	IF @is_creation_needed_in_unee_t_update_ext_area_2 = 1
		AND @new_is_creation_needed_in_unee_t_update_ext_area_2 != @old_is_creation_needed_in_unee_t_update_ext_area_2
		AND @external_id_update_ext_area_2 IS NOT NULL
		AND @external_system_id_update_ext_area_2 IS NOT NULL
		AND @external_table_update_ext_area_2 IS NOT NULL
		AND @organization_id_update_ext_area_2 IS NOT NULL
		AND (@upstream_update_method_update_ext_area_2 = 'imported_from_hmlet_ipi'
			OR @upstream_update_method_update_ext_area_2 = 'Manage_Areas_Add_Page'
			OR @upstream_update_method_update_ext_area_2 = 'Manage_Areas_Edit_Page'
			OR @upstream_update_method_update_ext_area_2 = 'Manage_Areas_Import_Page'
			OR @upstream_update_method_update_ext_area_2 = 'Export_and_Import_Areas_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `property_groups_areas` table:

		SET @this_trigger_update_ext_area_2 = 'ut_created_external_area_after_insert' ;

		SET @syst_created_datetime_update_ext_area_2 = NOW();
		SET @creation_system_id_update_ext_area_2 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator_update_ext_area_2
			)
			;
		SET @created_by_id_update_ext_area_2 = @creator_mefe_user_id_update_ext_area_2 ;
		SET @downstream_creation_method_update_ext_area_2 = @this_trigger_update_ext_area_2 ;

		SET @syst_updated_datetime_update_ext_area_2 = NOW();

		SET @source_system_updater_update_ext_area_2 = NEW.`updated_by_id` ; 

		SET @update_system_id_update_ext_area_2 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater_update_ext_area_2
			)
			;
		SET @updated_by_id_update_ext_area_2 = @creator_mefe_user_id_update_ext_area_2 ;
		SET @downstream_update_method_update_ext_area_2 = @this_trigger_update_ext_area_2 ;

		SET @organization_id_create_update_ext_area_2 = @source_system_creator_update_ext_area_2 ;
		SET @organization_id_update_update_ext_area_2 = @source_system_updater_update_ext_area_2 ;

		SET @country_code_update_ext_area_2 = NEW.`country_code` ;
		SET @is_obsolete_update_ext_area_2 = NEW.`is_obsolete` ;
		SET @is_default_update_ext_area_2 = NEW.`is_default` ;
		SET @order_update_ext_area_2 = NEW.`order` ;
		SET @area_name_update_ext_area_2 = NEW.`area_name` ;
		SET @area_definition_update_ext_area_2 = NEW.`area_definition` ;

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
					(@external_id_update_ext_area_2
					, @external_system_id_update_ext_area_2
					, @external_table_update_ext_area_2
					, @syst_created_datetime_update_ext_area_2
					, @creation_system_id_update_ext_area_2
					, @created_by_id_update_ext_area_2
					, @downstream_creation_method_update_ext_area_2
					, @is_creation_needed_in_unee_t_update_ext_area_2
					, @organization_id_create_update_ext_area_2
					, @country_code_update_ext_area_2
					, @is_obsolete_update_ext_area_2
					, @is_default_update_ext_area_2
					, @order_update_ext_area_2
					, @area_name_update_ext_area_2
					, @area_definition_update_ext_area_2
					)
				ON DUPLICATE KEY UPDATE
					`syst_updated_datetime` = @syst_updated_datetime_update_ext_area_2
					, `update_system_id` = @update_system_id_update_ext_area_2
					, `updated_by_id` = @updated_by_id_update_ext_area_2
					, `update_method` = @downstream_update_method_update_ext_area_2
					, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t_update_ext_area_2
					, `organization_id` = @organization_id_update_update_ext_area_2
					, `country_code` = @country_code_update_ext_area_2
					, `is_obsolete` = @is_obsolete_update_ext_area_2
					, `is_default` = @is_default_update_ext_area_2
					, `order` = @order_update_ext_area_2
					, `area_definition` = @area_definition_update_ext_area_2
					, `area_name` = @area_name_update_ext_area_2
				;

	END IF;

END;
$$
DELIMITER ;