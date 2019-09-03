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
#
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
# 
####################################################
#
# What are the version of the Unee-T BZ Database schema BEFORE and AFTER this update?

	SET @old_schema_version := 'v1.22.5';
	SET @new_schema_version := 'v1.22.6';

# What is the name of this script?

	SET @this_script := CONCAT ('upgrade_unee-t_entreprise', @old_schema_version, '_to_', @new_schema_version, '.sql');

# In this update
#
#WIP	- Fix a bug where some of the level 2 properties are not assigned to users who should be assigned to all the properties in the country.
# For more details, see
# https://docs.google.com/document/d/1IyLZHC6nmmeOaTdDkswLUN4QbEC_BG_FfwwuWoNyF5E/edit?usp=sharing
#
# WIP Make sure that we do NOT create the properties if they are marked as obsolete
#OK	- L1P (updated script `properties_level_1_creation_update_v1_22_6`)
#OK	- L2P (updated script `properties_level_2_creation_update_v1_22_6`)
#OK	- L3P (updated script `properties_level_3_creation_update_v1_22_6`)
#	- Break up 2 similar triggers
#		- `ut_update_external_property_level_2`
#		- `ut_update_external_property_level_2_creation_needed`
#	- Instead, we use a combination of:
#TEST NEEDED		- Procedure `ut_update_L2P_when_ext_L2P_is_updated`
#TEST NEEDED		- Trigger `ut_after_update_external_property_level_2` 
#
#	- Break up 2 similar triggers
#		- `ut_update_external_property_level_3`
#		- `ut_update_external_property_level_3_creation_needed`
#	- Instead, we use a combination of:
#WIP		- Procedure `ut_update_L3P_when_ext_L3P_is_updated`
#WIP		- Trigger `ut_update_external_property_level_3` 
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
# - Re-create triggers:
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
#
# We Drop the legacy triggers:

	DROP TRIGGER IF EXISTS `ut_update_external_property_level_2`;
	DROP TRIGGER IF EXISTS `ut_update_external_property_level_2_creation_needed`;
	
	DROP TRIGGER IF EXISTS `ut_update_map_external_source_unit_add_unit_creation_needed`;
	DROP TRIGGER IF EXISTS `ut_update_map_external_source_unit_edit_level_2`;


# Create the The procedure that does the update in the table `property_level_2_units`
# When the table `external_property_level_2_units` has been updated

	DROP PROCEDURE IF EXISTS `ut_update_L2P_when_ext_L2P_is_updated`;

DELIMITER $$
CREATE PROCEDURE `ut_update_L2P_when_ext_L2P_is_updated`()
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN

	# We update the record in the table `external_property_level_2_units`
	# We do this via INSERT INTO ... ON DUPLICATE KEY UPDATE for maximum safety

		INSERT INTO `property_level_2_units`
			(`external_id`
			, `external_system_id` 
			, `external_table`
			, `syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `creation_method`
			, `organization_id`
			, `activated_by_id`
			, `is_obsolete`
			, `is_creation_needed_in_unee_t`
			, `do_not_insert`
			, `unee_t_unit_type`
			, `building_system_id`
			, `tower`
			, `unit_category_id`
			, `designation`
			, `count_rooms`
			, `unit_id`
			, `surface`
			, `surface_measurment_unit`
			, `description`
			)
			VALUES
 				(@external_id_update_extl2
				, @external_system_id_update_extl2
				, @external_table_update_extl2
				, @syst_created_datetime_update_extl2
				, @creation_system_id_update_extl2
				, @created_by_id_update_extl2
				, @downstream_creation_method_update_extl2
				, @organization_id_create_update_extl2
				, @activated_by_id_update_extl2
				, @is_obsolete_update_extl2
				, @is_creation_needed_in_unee_t_update_extl2
				, @do_not_insert_update_extl2
				, @unee_t_unit_type_update_extl2
				, @building_system_id_update_extl2
				, @tower_update_extl2
				, @unit_category_id_update_extl2
				, @designation_update_extl2
				, @count_rooms_update_extl2
				, @unit_id_update_extl2
				, @surface_update_extl2
				, @surface_measurment_unit_update_extl2
				, @description_update_extl2
 			)
			ON DUPLICATE KEY UPDATE
 				`syst_updated_datetime` = @syst_updated_datetime_update_extl2
 				, `update_system_id` = @update_system_id_update_extl2
 				, `updated_by_id` = @updated_by_id_update_extl2
				, `update_method` = @downstream_update_method_update_extl2
				, `organization_id` = @organization_id_update_update_extl2
				, `activated_by_id` = @activated_by_id_update_extl2
				, `is_obsolete` = @is_obsolete_update_extl2
				, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t_update_extl2
				, `do_not_insert` = @do_not_insert_update_extl2
				, `unee_t_unit_type` = @unee_t_unit_type_update_extl2
				, `building_system_id` = @building_system_id_update_extl2
				, `tower` = @tower_update_extl2
				, `unit_category_id` = @unit_category_id_update_extl2
				, `designation` = @designation_update_extl2
				, `count_rooms` = @count_rooms_update_extl2
				, `unit_id` = @unit_id_update_extl2
				, `surface` = @surface_update_extl2
				, `surface_measurment_unit` = @surface_measurment_unit_update_extl2
				, `description` = @description_update_extl2
			;
				
		# Housekeeping - we make sure that if a unit is obsolete - all rooms in that unit are obsolete too
		# We only do that if the field `is_obsolete` is changed from 0 to 1

			SET @system_id_unit_update_extl2 = NEW.`system_id_unit` ;

			UPDATE `external_property_level_3_rooms` AS `a`
				INNER JOIN `external_property_level_2_units` AS `b`
					ON (`a`.`system_id_unit` = `b`.`system_id_unit`)
				SET `a`.`is_obsolete` = `b`.`is_obsolete`
				WHERE `a`.`system_id_unit` = @system_id_unit_update_extl2
				;
				
END;
$$
DELIMITER ;

# Create the trigger when the extL2P is updated
# This trigger will:
#	- Check if several conditions are met
#	- Capture the value we need in several variables
#	- Call the procedure `ut_update_L2P_when_ext_L2P_is_updated` if needed.

	DROP TRIGGER IF EXISTS `ut_after_update_external_property_level_2`;

DELIMITER $$
CREATE TRIGGER `ut_after_update_external_property_level_2`
AFTER UPDATE ON `external_property_level_2_units`
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
#	- The unit already exists in the table `property_level_2_units`
#	- We have a valid building_id for that unit.
#	- The `do_not_insert_field` is NOT equal to 1
#	- This is a valid update method:
#		- `imported_from_hmlet_ipi`
#		- `Manage_Units_Add_Page`
#		- `Manage_Units_Edit_Page`
#		- 'Manage_Units_Import_Page'
#		- 'Export_and_Import_Units_Import_Page'


# Capture the variables we need to verify if conditions are met:

	SET @is_creation_needed_in_unee_t_update_extl2 = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator_update_extl2 = NEW.`created_by_id` ;
	SET @source_system_updater_update_extl2 = (IF(NEW.`updated_by_id` IS NULL
			, @source_system_creator_update_extl2
			, NEW.`updated_by_id`
			)
		);

	SET @creator_mefe_user_id_update_extl2 = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator_update_extl2
		)
		;

	SET @upstream_create_method_update_extl2 = NEW.`creation_method` ;
	SET @upstream_update_method_update_extl2 = NEW.`update_method` ;

	SET @organization_id_update_extl2 = @source_system_creator_update_extl2 ;

	SET @external_id_update_extl2 = NEW.`external_id` ;
	SET @external_system_id_update_extl2 = NEW.`external_system_id` ; 
	SET @external_table_update_extl2 = NEW.`external_table` ;
	SET @tower_update_extl2 = NEW.`tower` ;

	SET @new_is_creation_needed_in_unee_t_update_extl2 = NEW.`is_creation_needed_in_unee_t` ;
	SET @old_is_creation_needed_in_unee_t_update_extl2 = OLD.`is_creation_needed_in_unee_t` ;

	SET @id_in_property_level_2_units_update_extl2 = (SELECT `system_id_unit`
		FROM `property_level_2_units`
		WHERE `external_system_id` = @external_system_id_update_extl2
			AND `external_table` = @external_table_update_extl2
			AND `external_id` = @external_id_update_extl2
			AND `organization_id` = @organization_id_update_extl2
		);

	SET @upstream_do_not_insert_update_extl2 = NEW.`do_not_insert` ;

	# This is an UPDATE - the record SHOULD exist already

		SET @do_not_insert_update_extl2 = (IF (@id_in_property_level_2_units_update_extl2 IS NULL
				, 1
				, @upstream_do_not_insert_update_extl2
				)
			);

	# Get the information about the building for that unit...
	# We need the information from the table `external_property_level_2_units` (and NOT the table `external_external_property_level_1_buildings`)
	
		SET @building_id_1_update_extl2 = NEW.`building_system_id` ;

		SET @tower_update_extl2 = NEW.`tower` ;

		SET @building_external_id_update_extl2 = (SELECT `external_id`
			FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_1_update_extl2
				);
		SET @building_external_system_id_update_extl2 = (SELECT `external_system_id`
			FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_1_update_extl2
			);
		SET @building_external_table_update_extl2 = (SELECT `external_table`
		   FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_1_update_extl2
			);
		SET @building_external_tower_update_extl2 = (SELECT `tower`
			FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_1_update_extl2
			);

		SET @building_system_id_update_extl2 = (SELECT `id_building`
			FROM `property_level_1_buildings`
			WHERE `external_id` = @building_external_id_update_extl2
				AND `external_system_id` = @building_external_system_id_update_extl2
				AND `external_table` = @building_external_table_update_extl2
				AND `organization_id` = @organization_id_update_extl2
				AND `tower` = @building_external_tower_update_extl2
				);

# We can now check if the conditions are met:

	IF @is_creation_needed_in_unee_t_update_ext_l2_2 = 1
		AND @do_not_insert_update_ext_l2_2 = 0
		AND @external_id_update_ext_l2_2 IS NOT NULL
		AND @external_system_id_update_ext_l2_2 IS NOT NULL
		AND @external_table_update_ext_l2_2 IS NOT NULL
		AND @tower_update_ext_l2_2 IS NOT NULL
		AND @organization_id_update_ext_l2_2 IS NOT NULL
		AND @building_system_id_update_ext_l2_2 IS NOT NULL
		AND (@upstream_update_method_update_ext_l2_2 = 'imported_from_hmlet_ipi'
			OR @upstream_update_method_update_ext_l2_2 = 'Manage_Units_Add_Page'
			OR @upstream_update_method_update_ext_l2_2 = 'Manage_Units_Edit_Page'
			OR @upstream_update_method_update_ext_l2_2 = 'Manage_Units_Import_Page'
			OR @upstream_update_method_update_ext_l2_2 = 'Export_and_Import_Units_Import_Page'
			)
	THEN 

	# The conditions are met: we capture the other variables we need

		SET @syst_created_datetime_update_extl2 = NOW();
		SET @creation_system_id_update_extl2 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator_update_extl2
			)
			;
		SET @created_by_id_update_extl2 = @creator_mefe_user_id_update_extl2 ;
		SET @downstream_creation_method_update_extl2 = @this_trigger_update_extl2 ;

		SET @syst_updated_datetime_update_extl2 = NOW();

		SET @update_system_id_update_extl2 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater_update_extl2
			)
			;
		SET @updated_by_id_update_extl2 = @creator_mefe_user_id_update_extl2 ;
		SET @downstream_update_method_update_extl2 = @this_trigger_update_extl2 ;

		SET @organization_id_create_update_extl2 = @source_system_creator_update_extl2 ;
		SET @organization_id_update_update_extl2 = @source_system_updater_update_extl2 ;

		SET @activated_by_id_update_extl2 = NEW.`activated_by_id` ;
		SET @is_obsolete_update_extl2 = NEW.`is_obsolete` ;
		SET @is_creation_needed_in_unee_t_update_extl2 = NEW.`is_creation_needed_in_unee_t` ;
		SET @unee_t_unit_type_update_extl2 = NEW.`unee_t_unit_type` ;
			
		SET @unit_category_id_update_extl2 = NEW.`unit_category_id` ;
		SET @designation_update_extl2 = NEW.`designation` ;
		SET @count_rooms_update_extl2 = NEW.`count_rooms` ;
		SET @unit_id_update_extl2 = NEW.`unit_id` ;
		SET @surface_update_extl2 = NEW.`surface` ;
		SET @surface_measurment_unit_update_extl2 = NEW.`surface_measurment_unit` ;
		SET @description_update_extl2 = NEW.`description` ;

		IF @new_is_creation_needed_in_unee_t_update_ext_l2_2 = @old_is_creation_needed_in_unee_t_update_ext_l2_2
		THEN 
			
			# This is option 1

				SET @this_trigger_update_extl2 = 'ut_update_external_property_level_2';

			# We have all the variables, we can call the procedure that does the update

				CALL `ut_update_L2P_when_ext_L2P_is_updated` ;


		END IF;

		ELSEIF @new_is_creation_needed_in_unee_t_update_ext_l2_2 != @old_is_creation_needed_in_unee_t_update_ext_l2_2
		THEN 

			# This is option 2

				SET @this_trigger_update_ext_l2 = 'ut_update_external_property_level_2_creation_needed';

			# We have all the variables, we can call the procedure that does the update

				CALL `ut_update_L2P_when_ext_L2P_is_updated` ;

		
		END IF;

	# The conditions are NOT met <-- we do nothing
				
END;
$$
DELIMITER ;



# Create the procedure that does the update in the table `ut_map_external_source_units`
# When the table `property_level_2_units` has been updated

	DROP PROCEDURE IF EXISTS `ut_update_uneet_when_L2P_is_updated`;

DELIMITER $$
CREATE PROCEDURE `ut_update_uneet_when_L2P_is_updated`()
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN

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
				)
				VALUES
					(@syst_created_datetime_update_l2
					, @creation_system_id_update_l2
					, @created_by_id_update_l2
					, @creation_method_update_l2
					, @organization_id_update_l2
					, @is_obsolete_update_l2
					, @is_update_needed_update_l2
					, @is_mefe_api_success_update_l2
					, @mefe_api_error_message_update_l2
					, @uneet_name_update_l2
					, @unee_t_unit_type_update_l2
					, @new_record_id_update_l2
					, @external_property_type_id_update_l2
					, @external_property_id_update_l2
					, @external_system_update_l2
					, @table_in_external_system_update_l2
					)
				ON DUPLICATE KEY UPDATE
					`syst_updated_datetime` = @syst_updated_datetime_update_l2
					, `update_system_id` = @update_system_id_update_l2
					, `updated_by_id` = @updated_by_id_update_l2
					, `update_method` = @update_method_update_l2
					, `organization_id` = @organization_id_update_l2
					, `is_mefe_api_success` = @is_mefe_api_success_update_l2
					, `mefe_api_error_message` = @mefe_api_error_message_update_l2
					, `uneet_name` = @uneet_name_update_l2
					, `unee_t_unit_type` = @unee_t_unit_type_update_l2
					, `is_update_needed` = 1
				;
				
END;
$$
DELIMITER ;

# Create the trigger when the L2P is updated
# This trigger will:
#	- Check if several conditions are met
#	- Capture the value we need in several variables
#	- Call the procedure `ut_update_uneet_when_L2P_is_updated` if needed.

	DROP TRIGGER IF EXISTS `ut_after_update_property_level_2`;

DELIMITER $$
CREATE TRIGGER `ut_after_update_property_level_2`
AFTER UPDATE ON `property_level_2_units`
FOR EACH ROW
BEGIN

# We only do this IF:
# 	- We need to create the unit in Unee-T
#	- The unit is NOT marked as `do_not_insert`
#	- We do NOT have a MEFE unit ID for that unit
#	- This is done via an authorized update method:
#		- 'ut_insert_external_property_level_2'
#		- 'ut_update_external_property_level_2_creation_needed'

# Capture the variables we need to verify if conditions are met:


	SET @is_creation_needed_in_unee_t_update_l2 = NEW.`is_creation_needed_in_unee_t`;

	SET @new_is_creation_needed_in_unee_t_update_l2 = NEW.`is_creation_needed_in_unee_t`;
	SET @old_is_creation_needed_in_unee_t_update_l2 = OLD.`is_creation_needed_in_unee_t`;

	SET @do_not_insert_update_l2_raw = NEW.`do_not_insert` ;

	SET @system_id_unit_update_l2 = NEW.`system_id_unit` ;

	SET @mefe_unit_id_update_l2 = NULL ;

	SET @mefe_unit_id_update_l2 = (SELECT `unee_t_mefe_unit_id`
		FROM `ut_map_external_source_units`
		WHERE `new_record_id` = @system_id_unit_update_l2
			AND `external_property_type_id` = 2
		);

	# This is an insert - if the record does NOT exist, we create the record
	# unless 
	#	- it is specifically specified that we do NOT need to create the record.
	#	- the record is marked as obsolete

		SET @is_obsolete_update_l2 = NEW.`is_obsolete`;

		SET @do_not_insert_update_l2 = (IF (@do_not_insert_update_l2_raw IS NULL
				, IF (@is_obsolete_update_l2 != 0
					, 1
					, 0
					)
				, IF (@is_obsolete_update_l2 != 0
					, 1
					, NEW.`do_not_insert`
					)
				)
			);

	SET @upstream_create_method_update_l2 = NEW.`creation_method` ;
	SET @upstream_update_method_update_l2 = NEW.`update_method` ;

# We can now check if the conditions are met:

	IF @is_creation_needed_in_unee_t_update_l2 = 1
		AND @do_not_insert_update_l2 = 0
		AND (@upstream_create_method_update_l2 = 'ut_insert_external_property_level_2'
			OR @upstream_update_method_update_l2 = 'ut_insert_external_property_level_2'
			OR @upstream_create_method_update_l2 = 'ut_update_external_property_level_2_creation_needed'
			OR @upstream_update_method_update_l2 = 'ut_update_external_property_level_2_creation_needed'
			)
	THEN 

	# The conditions are met: we capture the other variables we need

		SET @syst_created_datetime_update_l2 = NOW();
		SET @creation_system_id_update_l2 = NEW.`update_system_id`;
		SET @created_by_id_update_l2 = NEW.`updated_by_id`;
		SET @creation_method_update_l2 = @this_trigger_update_l2 ;

		SET @syst_updated_datetime_update_l2 = NOW();
		SET @update_system_id_update_l2 = NEW.`update_system_id`;
		SET @updated_by_id_update_l2 = NEW.`updated_by_id`;
		SET @update_method_update_l2 = @this_trigger_update_l2 ;

		SET @organization_id_update_l2 = NEW.`organization_id`;
		
		SET @is_update_needed_update_l2 = NULL;
		
		SET @uneet_name_update_l2 = NEW.`designation`;

		SET @unee_t_unit_type_update_l2 = (IFNULL(NEW.`unee_t_unit_type`
				, 'Unknown'
				)
			)
			;
			
		SET @new_record_id_update_l2 = NEW.`system_id_unit`;
		SET @external_property_type_id_update_l2 = 2;

		SET @external_property_id_update_l2 = NEW.`external_id`;
		SET @external_system_update_l2 = NEW.`external_system_id`;
		SET @table_in_external_system_update_l2 = NEW.`external_table`;			


		IF @mefe_unit_id_update_l2 IS NOT NULL
		THEN 
			
			# This is option 1 - creation is NOT needed

				SET @this_trigger_update_l2 = 'ut_update_map_external_source_unit_edit_level_2';

			# We have all the variables, we can call the procedure that does the update

				CALL `ut_update_uneet_when_L2P_is_updated` ;


		END IF;

		ELSEIF @mefe_unit_id_update_l2_2 IS NULL
		THEN 

			# This is option 2 - creation IS needed

				SET @this_trigger_update_l2 = 'ut_update_map_external_source_unit_add_unit_creation_needed';

			# We have all the variables, we can call the procedure that does the update

				CALL `ut_update_uneet_when_L2P_is_updated` ;

		
		END IF;


	# The conditions are NOT met <-- we do nothing
				
END;
$$
DELIMITER ;













#
#
#
#
#
#
#
#
#
#
#

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