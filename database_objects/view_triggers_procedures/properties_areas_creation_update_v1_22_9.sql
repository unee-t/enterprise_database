#################
#
# This lists all the triggers we use to create 
# an area
# via the Unee-T Enterprise Interface
#
#################

# We create a trigger when a record is added to the `external_property_groups_areas` table

	DROP TRIGGER IF EXISTS `ut_after_insert_external_area`;

DELIMITER $$
CREATE TRIGGER `ut_after_insert_external_area`
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
#		- 'trigger_ut_after_insert_new_organization'
#		- ''

	SET @is_creation_needed_in_unee_t_insert_ext_area = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator_insert_ext_area = NEW.`created_by_id` ;
	SET @source_system_updater_insert_ext_area = NEW.`updated_by_id`;

	SET @creator_mefe_user_id_insert_ext_area = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator_insert_ext_area
		)
		;

	SET @upstream_create_method_insert_ext_area = NEW.`creation_method` ;
	SET @upstream_update_method_insert_ext_area = NEW.`update_method` ;

	SET @external_id_insert_ext_area = NEW.`external_id` ;
	SET @external_system_id_insert_ext_area = NEW.`external_system_id` ; 
	SET @external_table_insert_ext_area = NEW.`external_table` ;

	IF @is_creation_needed_in_unee_t_insert_ext_area = 1
		AND @external_id_insert_ext_area IS NOT NULL
		AND @external_system_id_insert_ext_area IS NOT NULL
		AND @external_table_insert_ext_area IS NOT NULL
		AND (@upstream_create_method_insert_ext_area = 'imported_from_hmlet_ipi'
			OR @upstream_create_method_insert_ext_area = 'Manage_Areas_Add_Page'
			OR @upstream_create_method_insert_ext_area = 'Manage_Areas_Edit_Page'
			OR @upstream_create_method_insert_ext_area = 'Manage_Areas_Import_Page'
			OR @upstream_create_method_insert_ext_area = 'Export_and_Import_Areas_Import_Page'
			OR @upstream_create_method_insert_ext_area = 'trigger_ut_after_insert_new_organization'
			OR @upstream_update_method_insert_ext_area = 'imported_from_hmlet_ipi'
			OR @upstream_update_method_insert_ext_area = 'Manage_Areas_Add_Page'
			OR @upstream_update_method_insert_ext_area = 'Manage_Areas_Edit_Page'
			OR @upstream_update_method_insert_ext_area = 'Manage_Areas_Import_Page'
			OR @upstream_update_method_insert_ext_area = 'Export_and_Import_Areas_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `property_groups_areas` table:

		SET @this_trigger_insert_ext_area = 'ut_insert_external_area' ;

		SET @creation_system_id_insert_ext_area = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator_insert_ext_area
			)
			;

		SET @created_by_id_insert_ext_area = @creator_mefe_user_id_insert_ext_area ;
		SET @downstream_creation_method_insert_ext_area = @this_trigger_insert_ext_area ;

		SET @syst_updated_datetime_insert_ext_area = NOW();

		SET @source_system_updater_insert_ext_area = NEW.`updated_by_id` ; 

		SET @update_system_id_insert_ext_area = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater_insert_ext_area
			)
			;
		SET @updated_by_id_insert_ext_area = @creator_mefe_user_id_insert_ext_area ;
		SET @downstream_update_method_insert_ext_area = @this_trigger_insert_ext_area ;

		SET @organization_id_create_insert_ext_area = @source_system_creator_insert_ext_area ;
		SET @organization_id_update_insert_ext_area = @source_system_updater_insert_ext_area ;

		SET @country_code_insert_ext_area = NEW.`country_code` ;
		SET @is_obsolete_insert_ext_area = NEW.`is_obsolete` ;
		SET @is_default_insert_ext_area = NEW.`is_default` ;
		SET @order_insert_ext_area = NEW.`order` ;
		SET @area_name_insert_ext_area = NEW.`area_name` ;
		SET @area_definition_insert_ext_area = NEW.`area_definition` ;

		SET @area_default_assignee_mgt_cny := NEW.`mgt_cny_default_assignee` ;
		SET @area_default_assignee_landlord := NEW.`landlord_default_assignee` ;
		SET @area_default_assignee_tenant := NEW.`tenant_default_assignee` ;
		SET @area_default_assignee_agent := NEW.`agent_default_assignee` ;

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
			, `mgt_cny_default_assignee`
			, `landlord_default_assignee`
			, `tenant_default_assignee`
			, `agent_default_assignee`
			)
			VALUES
				(@external_id_insert_ext_area
				, @external_system_id_insert_ext_area
				, @external_table_insert_ext_area
				, @syst_created_datetime_insert_ext_area
				, @creation_system_id_insert_ext_area
				, @created_by_id_insert_ext_area
				, @downstream_creation_method_insert_ext_area
				, @organization_id_create_insert_ext_area
				, @country_code_insert_ext_area
				, @is_obsolete_insert_ext_area
				, @is_default_insert_ext_area
				, @order_insert_ext_area
				, @area_name_insert_ext_area
				, @area_definition_insert_ext_area
				, @area_default_assignee_mgt_cny
				, @area_default_assignee_landlord
				, @area_default_assignee_tenant
				, @area_default_assignee_agent
				)
			ON DUPLICATE KEY UPDATE
				`syst_updated_datetime` = @syst_updated_datetime_insert_ext_area
				, `update_system_id` = @update_system_id_insert_ext_area
				, `updated_by_id` = @updated_by_id_insert_ext_area
				, `update_method` = @downstream_update_method_insert_ext_area
				, `country_code` = @country_code_insert_ext_area
				, `is_obsolete` = @is_obsolete_insert_ext_area
				, `is_default` = @is_default_insert_ext_area
				, `order` = @order_insert_ext_area
				, `area_name` = @area_name_insert_ext_area
				, `area_definition` = @area_definition_insert_ext_area
				, `mgt_cny_default_assignee` = @area_default_assignee_mgt_cny
				, `landlord_default_assignee` = @area_default_assignee_landlord
				, `tenant_default_assignee` = @area_default_assignee_tenant
				, `agent_default_assignee` = @area_default_assignee_agent
			;

	END IF;

END;
$$
DELIMITER ;

# We create a trigger when a record is updated in the `external_property_groups_areas` table
# The area DOES exist in the table `property_groups_areas`

	DROP TRIGGER IF EXISTS `ut_after_update_external_area`;

DELIMITER $$
CREATE TRIGGER `ut_after_update_external_area`
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

# Capture the variables we need to verify if conditions are met:

	SET @is_creation_needed_in_unee_t_update_ext_area = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator_update_ext_area = NEW.`created_by_id` ;
	SET @source_system_updater_update_ext_area = NEW.`updated_by_id`;

	SET @creator_mefe_user_id_update_ext_area = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator_update_ext_area
		)
		;

	SET @upstream_create_method_update_ext_area = NEW.`creation_method` ;
	SET @upstream_update_method_update_ext_area = NEW.`update_method` ;
	
	SET @organization_id_update_ext_area = @source_system_creator_update_ext_area ;

	SET @external_id_update_ext_area = NEW.`external_id` ;
	SET @external_system_id_update_ext_area = NEW.`external_system_id` ; 
	SET @external_table_update_ext_area = NEW.`external_table` ;

	SET @new_is_creation_needed_in_unee_t_update_ext_area = NEW.`is_creation_needed_in_unee_t` ;
	SET @old_is_creation_needed_in_unee_t_update_ext_area = OLD.`is_creation_needed_in_unee_t` ;

# We can now check if the conditions are met:

	IF @is_creation_needed_in_unee_t_update_ext_area = 1
		AND @external_id_update_ext_area IS NOT NULL
		AND @external_system_id_update_ext_area IS NOT NULL
		AND @external_table_update_ext_area IS NOT NULL
		AND @organization_id_update_ext_area IS NOT NULL
		AND (@upstream_update_method_update_ext_area = 'imported_from_hmlet_ipi'
			OR @upstream_update_method_update_ext_area = 'Manage_Areas_Add_Page'
			OR @upstream_update_method_update_ext_area = 'Manage_Areas_Edit_Page'
			OR @upstream_update_method_update_ext_area = 'Manage_Areas_Import_Page'
			OR @upstream_update_method_update_ext_area = 'Export_and_Import_Areas_Import_Page'
			)
	THEN 

	# The conditions are met: we capture the other variables we need

		SET @creation_system_id_update_ext_area = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater_update_ext_area
			)
			;

		SET @record_to_update_update_ext_area = (SELECT `id_area`
			FROM `property_groups_areas`
			WHERE `external_id` = @external_id_update_ext_area
				AND `external_system_id` = @external_system_id_update_ext_area
				AND `external_table` = @external_table_update_ext_area
				AND `organization_id` = @organization_id_update_ext_area
			);

		SET @syst_updated_datetime_update_ext_area = NOW();

		SET @source_system_updater_update_ext_area = NEW.`updated_by_id` ; 

		SET @update_system_id_update_ext_area = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater_update_ext_area
			)
			;
	
		SET @updated_by_id_update_ext_area = @creator_mefe_user_id_update_ext_area ;

		SET @organization_id_create_update_ext_area = @source_system_creator_update_ext_area ;
		SET @organization_id_update_update_ext_area = @source_system_updater_update_ext_area ;

		SET @country_code_update_ext_area = NEW.`country_code` ;
		SET @is_obsolete_update_ext_area = NEW.`is_obsolete` ;
		SET @is_default_update_ext_area = NEW.`is_default` ;
		SET @order_update_ext_area = NEW.`order` ;
		SET @area_name_update_ext_area = NEW.`area_name` ;
		SET @area_definition_update_ext_area = NEW.`area_definition` ;

		SET @area_default_assignee_mgt_cny := NEW.`mgt_cny_default_assignee` ;
		SET @area_default_assignee_landlord := NEW.`landlord_default_assignee` ;
		SET @area_default_assignee_tenant := NEW.`tenant_default_assignee` ;
		SET @area_default_assignee_agent := NEW.`agent_default_assignee` ;


		IF @new_is_creation_needed_in_unee_t_update_ext_area != @old_is_creation_needed_in_unee_t_update_ext_area
		THEN

			# This is option 1 - creation IS needed

				SET @this_trigger_update_area_insert = 'ut_after_update_external_area_insert_creation_needed' ;
				SET @this_trigger_update_area_update = 'ut_after_update_external_area_update_creation_needed' ;

			# We update the record in the table `property_groups_areas`
			# We do this via INSERT INTO ... ON DUPLICATE KEY UPDATE for maximum safety

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
				, `mgt_cny_default_assignee`
				, `landlord_default_assignee`
				, `tenant_default_assignee`
				, `agent_default_assignee`
				)
				VALUES
					(@external_id_update_ext_area
					, @external_system_id_update_ext_area
					, @external_table_update_ext_area
					, NOW()
					, @creation_system_id_update_ext_area
					, @created_by_id_update_ext_area
					, @this_trigger_update_area_insert
					, @is_creation_needed_in_unee_t_update_ext_area
					, @organization_id_create_update_ext_area
					, @country_code_update_ext_area
					, @is_obsolete_update_ext_area
					, @is_default_update_ext_area
					, @order_update_ext_area
					, @area_name_update_ext_area
					, @area_definition_update_ext_area
					, @area_default_assignee_mgt_cny
					, @area_default_assignee_landlord
					, @area_default_assignee_tenant
					, @area_default_assignee_agent
					)
				ON DUPLICATE KEY UPDATE
					`syst_updated_datetime` = NOW()
					, `update_system_id` = @update_system_id_update_ext_area
					, `updated_by_id` = @updated_by_id_update_ext_area
					, `update_method` = @this_trigger_update_area_update
					, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t_update_ext_area
					, `organization_id` = @organization_id_update_update_ext_area
					, `country_code` = @country_code_update_ext_area
					, `is_obsolete` = @is_obsolete_update_ext_area
					, `is_default` = @is_default_update_ext_area
					, `order` = @order_update_ext_area
					, `area_name` = @area_name_update_ext_area
					, `area_definition` = @area_definition_update_ext_area
					, `mgt_cny_default_assignee` = @area_default_assignee_mgt_cny
					, `landlord_default_assignee` = @area_default_assignee_landlord
					, `tenant_default_assignee` = @area_default_assignee_tenant
					, `agent_default_assignee` = @area_default_assignee_agent
				;

		ELSEIF @new_is_creation_needed_in_unee_t_update_ext_area = @old_is_creation_needed_in_unee_t_update_ext_area
		THEN 

			# This is option 2 - creation is NOT needed

				SET @this_trigger_update_area_insert = 'ut_after_update_external_area_insert_update_needed' ;
				SET @this_trigger_update_area_update = 'ut_after_update_external_area_update_update_needed' ;

			# We update the record in the table `property_groups_areas`
			# We do this via INSERT INTO ... ON DUPLICATE KEY UPDATE for maximum safety

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
				, `mgt_cny_default_assignee`
				, `landlord_default_assignee`
				, `tenant_default_assignee`
				, `agent_default_assignee`
				)
				VALUES
					(@external_id_update_ext_area
					, @external_system_id_update_ext_area
					, @external_table_update_ext_area
					, NOW()
					, @creation_system_id_update_ext_area
					, @created_by_id_update_ext_area
					, @this_trigger_update_area_insert
					, @is_creation_needed_in_unee_t_update_ext_area
					, @organization_id_create_update_ext_area
					, @country_code_update_ext_area
					, @is_obsolete_update_ext_area
					, @is_default_update_ext_area
					, @order_update_ext_area
					, @area_name_update_ext_area
					, @area_definition_update_ext_area
					, @area_default_assignee_mgt_cny
					, @area_default_assignee_landlord
					, @area_default_assignee_tenant
					, @area_default_assignee_agent
					)
				ON DUPLICATE KEY UPDATE
					`syst_updated_datetime` = NOW()
					, `update_system_id` = @update_system_id_update_ext_area
					, `updated_by_id` = @updated_by_id_update_ext_area
					, `update_method` = @this_trigger_update_area_update
					, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t_update_ext_area
					, `organization_id` = @organization_id_update_update_ext_area
					, `country_code` = @country_code_update_ext_area
					, `is_obsolete` = @is_obsolete_update_ext_area
					, `is_default` = @is_default_update_ext_area
					, `order` = @order_update_ext_area
					, `area_name` = @area_name_update_ext_area
					, `area_definition` = @area_definition_update_ext_area
					, `mgt_cny_default_assignee` = @area_default_assignee_mgt_cny
					, `landlord_default_assignee` = @area_default_assignee_landlord
					, `tenant_default_assignee` = @area_default_assignee_tenant
					, `agent_default_assignee` = @area_default_assignee_agent
				;

		END IF;

	# The conditions are NOT met <-- we do nothing

	END IF;

END;
$$
DELIMITER ;
