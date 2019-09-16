#################
#
# This is a compilation of the following files
#	- `1_views_v1_22_2`
#	- `add_user_to_property_areas_v1_10_0`
#	- `add_user_to_property_level_1_v1_19_0`
#	- `add_user_to_property_level_2_v1_20_0`
#	- `add_user_to_property_level_3_v1_22_0`
#	- `add_user_to_property_procedures_bulk_assign_v1_20_0`
#	- `add_user_to_property_retry_if_error_v1_22_0`
#	- `add_user_to_property_trigger_bulk_assign_to_new_unit_v1_20_0`
#	- `logs_result_after_api_was_called_v1_21_4`
#	- `misc_procedures_v1_17_0`
#	- `person_creation_v1_18_0`
#	- `person_update_v1_18_0`
#	- `properties_areas_creation_update_v1_20_0`
#	- `properties_level_1_creation_update_v1_22_7`
#	- `properties_level_2_creation_update_v1_22_7`
#	- `properties_level_3_creation_update_v1_22_7`
#	- `properties_retry_unit_creation_if_not_created_v1_22_3`
#	- `remove_user_from_a_role_all_v1_18_0`
#
#################


#################
#	
# Create the views we need (to make out life simpler)
#
#################

####################################################################
#
# The below views are used to get data more easily:
#
# - Faciliate collection of information
#
#	- Accesses and organizations:
#		- `ut_organization_mefe_user_id`
#
#	- On properties:
#		- `ut_add_information_unit_level_1`
#		- `ut_add_information_unit_level_2`
#		- `ut_add_information_unit_level_3`
#		- `ut_check_unee_t_updates_property_level_1`
#		- `ut_check_unee_t_updates_property_level_2`
#		- `ut_check_unee_t_updates_property_level_3`
#		- `ut_list_mefe_unit_id_level_1_by_area`
#		- `ut_list_mefe_unit_id_level_2_by_area`
#		- `ut_list_mefe_unit_id_level_3_by_area`
#		- `ut_verify_list_L1P_by_org_and_countries`
#		- `ut_verify_count_L1P_by_org_and_countries`
#		- `ut_verify_list_L2P_by_org_and_countries`
#		- `ut_verify_count_L2P_by_org_and_countries`
#		- `ut_verify_list_L3P_by_org_and_countries`
#		- `ut_verify_count_L3P_by_org_and_countries`
#		- `ut_verify_count_all_P_by_org_and_countries`
#		- 
#
#
#	- On persons
#		- `ut_user_information_persons`
#		- `ut_check_unee_t_updates_persons`
#		- `ut_info_external_persons`
#		- `ut_info_persons`
#		- `ut_info_mefe_users`
#
#	- On association user/units
#		- `ut_check_unee_t_update_add_user_to_unit_level_1`
#		- `ut_check_unee_t_update_add_user_to_unit_level_2`
#		- `ut_check_unee_t_update_add_user_to_unit_level_3`
#		- `ut_list_users_default_permissions`
#
#	- For a given organization:
#		- `ut_organization_default_area`
#		- `ut_organization_default_external_system`
#		- `ut_organization_default_table_areas`
#		- `ut_organization_default_table_level_1_properties`
#		- `ut_organization_default_table_level_2_properties`
#		- `ut_organization_default_table_level_3_properties`
#		- `ut_organization_default_table_persons`
#		- `ut_organization_associated_mefe_user`
#
#
# - Performance analysis
#	- `ut_analysis_mefe_api_unit_creation_time`
#	- `ut_analysis_mefe_api_user_creation_time`
#	- `ut_analysis_mefe_api_assign_user_to_unit_creation_time`
#
# - Error analysis
#	- Error on association user/unit
#		- `ut_analysis_errors_user_already_has_a_role_list`
#		- `ut_analysis_errors_user_already_has_a_role_count`
#		- ``
#		- ``
#	- ``
#	- ``
#	- ``
#	- ``
#	- ``
#
#  in the Unee-T Enterprise SQL database
#
####################################################################
#
#################
# WARNING!!!
#################
#
######################################################################################
#
# you also need to run all the other scripts so the Unee-T Enterprise Db is properly configured
#	- 1_Triggers_and_procedure_unee-t_enterprise_v1_8_0_updates_FROM_Unee-T_Enterprise_excl_assignment.sql
#	- 2_
#	- 4_Triggers_and_procedure_unee-t_enterprise_v1_8_0_lambda_related_objects_for_[ENVIRONMENT].sql
#
######################################################################################
#

# We create a view to list the ACTIVE MEFE User Id by organization

	DROP VIEW IF EXISTS `ut_organization_mefe_user_id` ;

	CREATE VIEW `ut_organization_mefe_user_id`
	AS
	SELECT
		`mefe_user_id`
		, `organization_id`
	FROM
		`ut_api_keys`
	WHERE `is_obsolete` = 0
		OR `revoked_datetime` IS NOT NULL
	GROUP BY `mefe_user_id`, `organization_id`
	;

# Create a View to get the additional information for condo/buildings
	
	DROP VIEW IF EXISTS `ut_add_information_unit_level_1` ;

	CREATE VIEW `ut_add_information_unit_level_1`
	AS
		SELECT
			`a`.`id_building` AS `unit_level_1_id`
			, `a`.`is_creation_needed_in_unee_t` AS `is_create_condo`
			, `a`.`unee_t_unit_type`
			, `a`.`designation` AS `name`
			, `a`.`description` AS `more_info`
			, `a`.`tower`
			, IF (`a`.`address_1` IS NOT NULL
				, CONCAT (`a`.`address_1`
					, ' \n'
					, IFNULL (`a`.`address_2`
						, ''
						)
					) 
				, IFNULL (`a`.`address_2`
					, NULL
					)
				)
				AS `street_address`
			, `a`.`city`
			, `a`.`zip_postal_code` AS `zip_code`
			, `a`.`state` AS `state`
			, `a`.`country_code`
			, `c`.`country_name` AS `country`
		FROM `property_level_1_buildings` AS `a`
			LEFT JOIN `property_groups_countries` AS `c`
			ON (`c`.`country_code` = `a`.`country_code`)
		;

# Create a View to get the additional information for Units/Flats
	
	DROP VIEW IF EXISTS `ut_add_information_unit_level_2` ;

	CREATE VIEW `ut_add_information_unit_level_2`
	AS
		SELECT
			`a`.`system_id_unit` AS `unit_level_2_id`
			, `a`.`is_creation_needed_in_unee_t` AS `is_create_flat`
			, `a`.`unee_t_unit_type`
			, `a`.`designation` AS `name`
			, `a`.`description` AS `more_info`
			, IF (`b`.`address_1` IS NOT NULL
				, CONCAT (`b`.`designation`
					, ' \n'
					, IF (`b`.`address_1` IS NOT NULL
						, CONCAT (`b`.`address_1`
							, ' \n'
							, IFNULL (`b`.`address_2`
								, ''
								)
							, IF (`a`.`unit_id` IS NOT NULL
								, CONCAT( ' \n'
									, ' #'
									, `a`.`unit_id`
									)
								, ''
								) 
							) 
						, IF (`b`.`address_2` IS NOT NULL
							, CONCAT (`b`.`address_2`
								, IF (`a`.`unit_id` IS NOT NULL
									, CONCAT( ' \n'
										, ' #'
										, `a`.`unit_id`
										)
									, ''
									) 
								)
							, IF (`a`.`unit_id` IS NOT NULL
								, CONCAT(' #'
									, `a`.`unit_id`
									)
								, ''
								)
							)
						)
					)
				, NULL
				)
				AS `street_address`
			, `b`.`city`
			, `b`.`state`
			, `b`.`zip_postal_code` AS `zip_code`
			, `d`.`country_name` AS `country`
		FROM
			`property_level_2_units` AS `a`
			INNER JOIN `property_level_1_buildings` AS `b`
			ON (`a`.`building_system_id` = `b`.`id_building`)
			LEFT JOIN `property_groups_countries` AS `d`
				ON (`d`.`country_code` = `b`.`country_code`)
		;

# Create a View to get the additional information for Rooms
	
	DROP VIEW IF EXISTS `ut_add_information_unit_level_3` ;

	CREATE VIEW `ut_add_information_unit_level_3`
	AS
		SELECT
			`a`.`system_id_room` AS `unit_level_3_id`
			, `a`.`is_creation_needed_in_unee_t` AS `is_create_room`
			, `a`.`unee_t_unit_type`
			, `a`.`room_designation` AS `name`
			, `a`.`room_description` AS `more_info`
			, IF (`c`.`address_1` IS NOT NULL
				, CONCAT (`c`.`designation`
					, ' \n'
					, IF (`c`.`address_1` IS NOT NULL
						, CONCAT (`c`.`address_1`
							, ' \n'
							, IFNULL (`c`.`address_2`
								, ''
								)
							, IF (`b`.`unit_id` IS NOT NULL
								, CONCAT( ' \n'
									, ' #'
									, `b`.`unit_id`
									)
								, ''
								) 
							) 
						, IF (`c`.`address_2` IS NOT NULL
							, CONCAT (`c`.`address_2`
								, IF (`b`.`unit_id` IS NOT NULL
									, CONCAT( ' \n'
										, ' #'
										, `b`.`unit_id`
										)
									, ''
									) 
								)
							, IF (`b`.`unit_id` IS NOT NULL
								, CONCAT(' #'
									, `b`.`unit_id`
									)
								, ''
								)
							)
						)
					)
				, NULL
				)
				AS `street_address`
			, `c`.`city`
			, `c`.`state`
			, `c`.`zip_postal_code` AS `zip_code`
			, `e`.`country_name` AS `country`
		FROM
			`property_level_3_rooms` AS `a`
			INNER JOIN `property_level_2_units` AS `b`
			ON (`a`.`system_id_unit` = `b`.`system_id_unit`)
			INNER JOIN `property_level_1_buildings` AS `c`
			ON (`b`.`building_system_id` = `c`.`id_building`)
			LEFT JOIN `property_groups_countries` AS `e`
			ON (`e`.`country_code` = `c`.`country_code`)
		;

# View to get the user information from the Persons table:

	DROP VIEW IF EXISTS `ut_user_information_persons` ;

	CREATE VIEW `ut_user_information_persons`
		AS
		SELECT 
			`id_person`
			, `external_id` AS `external_person_id`
			, `external_system`
			, `external_table` AS `table_in_external_system`
			, `organization_id` AS `organization_id`
			, `email` AS `email_address`
			, `given_name` AS `first_name`
			, `family_name` AS `last_name`
			, `tel_1` AS `phone_number`
			FROM `persons`
				WHERE `email` IS NOT NULL
		;

# We create the view that gives us information about when the person record was updated

	DROP VIEW IF EXISTS `ut_check_unee_t_updates_persons`;

	CREATE VIEW `ut_check_unee_t_updates_persons` 
	AS
	SELECT 
		`a`.`id_person`
		, `a`.`given_name`
		, `a`.`family_name`
		, `a`.`email`
		, `b`.`unee_t_mefe_user_id`
		, `b`.`uneet_login_name`
		, `b`.`uneet_created_datetime`
		, `b`.`is_unee_t_created_by_me`
		, `b`.`creation_method`
		, `b`.`update_method`
		, `b`.`organization_id`
		FROM `persons` AS `a`
			LEFT JOIN `ut_map_external_source_users` AS `b`
				ON (`a`.`id_person` = `b`.`person_id`)
		;

# We create the view that gives us information about when the building record was updated

	DROP VIEW IF EXISTS `ut_check_unee_t_updates_property_level_1`;

	CREATE VIEW `ut_check_unee_t_updates_property_level_1` 
	AS
	SELECT 
		`a`.`id_building`
		, `a`.`designation`
		, `a`.`tower`
		, `b`.`unee_t_mefe_unit_id`
		, `b`.`uneet_name`
		, `b`.`uneet_created_datetime`
		, `b`.`is_unee_t_created_by_me`
		, `b`.`creation_method`
		, `b`.`update_method`
		, `b`.`organization_id`
		FROM `property_level_1_buildings` AS `a`
			LEFT JOIN `ut_map_external_source_units` AS `b`
				ON (`a`.`id_building` = `b`.`new_record_id`)
					AND (`b`.`external_property_type_id` = 1)
			ORDER BY `a`.`area_id` ASC
				, `a`.`order` ASC
				, `a`.`tower` ASC
		; 

# We create the view that gives us information about when the Unit/Flat record was updated

	DROP VIEW IF EXISTS `ut_check_unee_t_updates_property_level_2`;

	CREATE VIEW `ut_check_unee_t_updates_property_level_2` 
	AS
	SELECT 
		`a`.`system_id_unit`
		, `a`.`designation`
		, `b`.`unee_t_mefe_unit_id`
		, `b`.`uneet_name`
		, `b`.`uneet_created_datetime`
		, `b`.`is_unee_t_created_by_me`
		, `b`.`creation_method`
		, `b`.`update_method`
		, `b`.`organization_id`
		FROM `property_level_2_units` AS `a`
			LEFT JOIN `ut_map_external_source_units` AS `b`
				ON (`a`.`system_id_unit` = `b`.`new_record_id`)
					AND (`b`.`external_property_type_id` = 2)
			INNER JOIN `property_level_1_buildings` AS `c`
				ON (`a`.`building_system_id` = `c`.`id_building`)
			ORDER BY `c`.`area_id` ASC
				, `c`.`order` ASC
				, `c`.`tower` ASC
				, `a`.`designation` ASC
		; 

# We create the view that gives us information about when the Room record was updated

	DROP VIEW IF EXISTS `ut_check_unee_t_updates_property_level_3`;

	CREATE VIEW `ut_check_unee_t_updates_property_level_3` 
	AS
	SELECT 
		`room`.`system_id_room`
		, `room`.`room_designation`
		, `map`.`unee_t_mefe_unit_id`
		, `map`.`uneet_name`
		, `map`.`uneet_created_datetime`
		, `map`.`is_unee_t_created_by_me`
		, `map`.`creation_method`
		, `map`.`update_method`
		, `map`.`organization_id`
		FROM `property_level_3_rooms` AS `room`
			LEFT JOIN `ut_map_external_source_units` AS `map`
				ON (`room`.`system_id_room` = `map`.`new_record_id`)
					AND (`map`.`external_property_type_id` = 3)
			INNER JOIN `property_level_2_units` AS `unit`
				ON (`room`.`system_id_unit` = `unit`.`system_id_unit`)
			INNER JOIN `property_level_1_buildings` AS `building`
				ON (`unit`.`building_system_id` = `building`.`id_building`)
			ORDER BY `building`.`area_id` ASC
				, `building`.`order` ASC
				, `building`.`tower` ASC
				, `unit`.`designation` ASC
				, `room`.`room_designation` ASC
		;

# We create a view to list the MEFE Unit Id of all the level_1 units by Areas.

	DROP VIEW IF EXISTS `ut_list_mefe_unit_id_level_1_by_area` ;

	CREATE VIEW `ut_list_mefe_unit_id_level_1_by_area`
	AS
	SELECT
		`b`.`id_area`
		, `d`.`area_id` AS `external_area_id`
		, `b`.`area_name` AS `area_name`
		, `a`.`id_building` AS `level_1_building_id`
		, `d`.`id_building` AS `external_level_1_building_id`
		, `a`.`designation` AS `level_1_building_name`
		, `c`.`external_property_type_id`
		, `c`.`unee_t_mefe_unit_id`
		, `a`.`organization_id`
		, `a`.`country_code`
		, `a`.`is_obsolete`
	FROM
		`property_level_1_buildings` AS `a`
		INNER JOIN `property_groups_areas` AS `b`
			ON (`a`.`area_id` = `b`.`id_area`)
		INNER JOIN `ut_map_external_source_units` AS `c`
			ON (`a`.`external_id` = `c`.`external_property_id`) 
				AND (`a`.`external_system_id` = `c`.`external_system`)
				AND (`a`.`external_table` = `c`.`table_in_external_system`) 
				AND (`a`.`organization_id` = `c`.`organization_id`)
				AND (`a`.`tower` = `c`.`tower`)
		INNER JOIN `external_property_level_1_buildings` AS `d`
			ON (`a`.`external_id` = `d`.`external_id`) 
				AND (`a`.`external_system_id` = `d`.`external_system_id`)
				AND (`a`.`external_table` = `d`.`external_table`) 
				AND (`a`.`tower` = `d`.`tower`) 
				AND (`a`.`organization_id` = `d`.`created_by_id`)
		WHERE `c`.`external_property_type_id` = 1
			AND `c`.`unee_t_mefe_unit_id` IS NOT NULL
		GROUP BY `c`.`unee_t_mefe_unit_id`
		ORDER BY `b`.`id_area` ASC
			, `a`.`designation` ASC
		;

# We create a view to list the MEFE Unit Id of all the level_2 units by Areas by buildings.

	DROP VIEW IF EXISTS `ut_list_mefe_unit_id_level_2_by_area` ;

	CREATE VIEW `ut_list_mefe_unit_id_level_2_by_area`
	AS
	SELECT
		`c`.`id_area`
		, `c`.`area_name` AS `area_name`
		, `b`.`id_building` AS `level_1_building_id`
		, `e`.`building_system_id` AS `external_level_1_building_id`
		, `b`.`designation` AS `level_1_building_name`
		, `a`.`system_id_unit` AS `level_2_unit_id`
		, `e`.`system_id_unit` AS `external_level_2_unit_id`
		, `a`.`designation` AS `level_2_unit_name`
		, `d`.`external_property_type_id`
		, `d`.`unee_t_mefe_unit_id`
		, `a`.`organization_id`
		, `b`.`country_code`
		, `a`.`is_obsolete`
	FROM
		`property_level_2_units` AS `a`
		INNER JOIN `property_level_1_buildings` AS `b`
			ON (`a`.`building_system_id` = `b`.`id_building`)
		INNER JOIN `property_groups_areas` AS `c`
			ON (`b`.`area_id` = `c`.`id_area`)
		INNER JOIN `ut_map_external_source_units` AS `d`
			ON (`a`.`external_id` = `d`.`external_property_id`) 
			AND (`a`.`external_system_id` = `d`.`external_system`) 
			AND (`a`.`external_table` = `d`.`table_in_external_system`) 
			AND (`a`.`organization_id` = `d`.`organization_id`)
			AND (`a`.`tower` = `d`.`tower`)
		INNER JOIN `external_property_level_2_units` AS `e`
			ON (`a`.`external_id` = `e`.`external_id`) 
			AND (`a`.`external_system_id` = `e`.`external_system_id`) 
			AND (`a`.`external_table` = `e`.`external_table`) 
			AND (`a`.`organization_id` = `e`.`created_by_id`)
		WHERE (`d`.`external_property_type_id` = 2)
			AND `d`.`unee_t_mefe_unit_id` IS NOT NULL
		GROUP BY `d`.`unee_t_mefe_unit_id`
		ORDER BY `c`.`id_area` ASC		
			, `a`.`designation` ASC
			, `b`.`designation` ASC
		;

# We create a view to list the MEFE Unit Id of all the level_3 units by Areas by buildings by unit.

	DROP VIEW IF EXISTS `ut_list_mefe_unit_id_level_3_by_area` ;

	CREATE VIEW `ut_list_mefe_unit_id_level_3_by_area`
	AS
	SELECT
		`d`.`id_area`
		, `d`.`area_name` AS `area_name`
		, `c`.`id_building` AS `level_1_building_id`
		, `c`.`designation` AS `level_1_building_name`
		, `b`.`system_id_unit` AS `level_2_unit_id`
		, `f`.`system_id_unit` AS `external_level_2_unit_id`
		, `b`.`designation` AS `level_2_unit_name`
		, `a`.`system_id_room` AS `level_3_room_id`
		, `f`.`system_id_room` AS `external_level_3_room_id`
		, `a`.`room_designation` AS `level_3_room_name`
		, `e`.`external_property_type_id`
		, `e`.`unee_t_mefe_unit_id`
		, `a`.`organization_id`
		, `c`.`country_code`
		, `a`.`is_obsolete`
	FROM
		`property_level_3_rooms` AS `a`
		INNER JOIN `property_level_2_units` AS `b`
			ON (`a`.`system_id_unit` = `b`.`system_id_unit`)
		INNER JOIN `property_level_1_buildings` AS `c`
			ON (`b`.`building_system_id` = `c`.`id_building`)
		INNER JOIN `property_groups_areas` AS `d`
			ON (`c`.`area_id` = `d`.`id_area`)
		INNER JOIN `ut_map_external_source_units` AS `e`
			ON (`a`.`external_id` = `e`.`external_property_id`) 
			AND (`a`.`external_system_id` = `e`.`external_system`) 
			AND (`a`.`external_table` = `e`.`table_in_external_system`) 
			AND (`a`.`organization_id` = `e`.`organization_id`)
			AND (`b`.`tower` = `e`.`tower`)
		INNER JOIN `external_property_level_3_rooms` AS `f`
			ON (`a`.`external_id` = `f`.`external_id`) 
			AND (`a`.`external_system_id` = `f`.`external_system_id`) 
			AND (`a`.`external_table` = `f`.`external_table`) 
			AND (`a`.`organization_id` = `f`.`created_by_id`)
		WHERE (`e`.`external_property_type_id` = 3)
			AND `e`.`unee_t_mefe_unit_id` IS NOT NULL
		GROUP BY `e`.`unee_t_mefe_unit_id`
		ORDER BY `d`.`id_area` ASC		
			, `c`.`designation` ASC
			, `b`.`designation` ASC
			, `a`.`room_designation` ASC
		;

# We create a view to check when the user has been assigned to a role in a unit Level 1

	DROP VIEW IF EXISTS `ut_check_unee_t_update_add_user_to_unit_level_1` ;

	CREATE VIEW `ut_check_unee_t_update_add_user_to_unit_level_1`
	AS 
	SELECT
		`external_map_user_unit_role_permissions_level_1`.`id_map_user_unit_permissions_level_1`
		, `ut_map_external_source_units`.`external_property_type_id`
		, `ut_map_external_source_units`.`uneet_name`
		, `external_map_user_unit_role_permissions_level_1`.`unee_t_mefe_user_id`
		, `ut_map_external_source_units`.`unee_t_mefe_unit_id`
		, `ut_map_user_permissions_unit_all`.`unee_t_update_ts`
	FROM
		`external_map_user_unit_role_permissions_level_1`
		INNER JOIN `ut_map_user_permissions_unit_all` 
			ON (`external_map_user_unit_role_permissions_level_1`.`unee_t_mefe_user_id` = `ut_map_user_permissions_unit_all`.`unee_t_mefe_id`)
		INNER JOIN `ut_map_external_source_units` 
			ON (`ut_map_user_permissions_unit_all`.`unee_t_unit_id` = `ut_map_external_source_units`.`unee_t_mefe_unit_id`) 
			AND (`external_map_user_unit_role_permissions_level_1`.`unee_t_level_1_id` = `ut_map_external_source_units`.`new_record_id`)
	WHERE (`ut_map_external_source_units`.`external_property_type_id` = 1)
	;

# We create a view to check when the user has been assigned to a role in a unit Level 2

	DROP VIEW IF EXISTS `ut_check_unee_t_update_add_user_to_unit_level_2` ;

	CREATE VIEW `ut_check_unee_t_update_add_user_to_unit_level_2`
	AS 
	SELECT
		`external_map_user_unit_role_permissions_level_2`.`id_map_user_unit_permissions_level_2`
		, `ut_map_external_source_units`.`external_property_type_id`
		, `ut_map_external_source_units`.`uneet_name`
		, `external_map_user_unit_role_permissions_level_2`.`unee_t_mefe_user_id`
		, `ut_map_external_source_units`.`unee_t_mefe_unit_id`
		, `ut_map_user_permissions_unit_all`.`unee_t_update_ts`
	FROM
		`external_map_user_unit_role_permissions_level_2`
		INNER JOIN `ut_map_user_permissions_unit_all` 
			ON (`external_map_user_unit_role_permissions_level_2`.`unee_t_mefe_user_id` = `ut_map_user_permissions_unit_all`.`unee_t_mefe_id`)
		INNER JOIN `ut_map_external_source_units` 
			ON (`ut_map_user_permissions_unit_all`.`unee_t_unit_id` = `ut_map_external_source_units`.`unee_t_mefe_unit_id`) 
			AND (`external_map_user_unit_role_permissions_level_2`.`unee_t_level_2_id` = `ut_map_external_source_units`.`new_record_id`)
	WHERE (`ut_map_external_source_units`.`external_property_type_id` = 2)
	;

# We create a view to check when the user has been assigned to a role in a unit Level 3

	DROP VIEW IF EXISTS `ut_check_unee_t_update_add_user_to_unit_level_3` ;

	CREATE VIEW `ut_check_unee_t_update_add_user_to_unit_level_3`
	AS 
	SELECT
		`external_map_user_unit_role_permissions_level_3`.`id_map_user_unit_permissions_level_3`
		, `ut_map_external_source_units`.`external_property_type_id`
		, `ut_map_external_source_units`.`uneet_name`
		, `external_map_user_unit_role_permissions_level_3`.`unee_t_mefe_user_id`
		, `ut_map_external_source_units`.`unee_t_mefe_unit_id`
		, `ut_map_user_permissions_unit_all`.`unee_t_update_ts`
	FROM
		`external_map_user_unit_role_permissions_level_3`
		INNER JOIN `ut_map_user_permissions_unit_all` 
			ON (`external_map_user_unit_role_permissions_level_3`.`unee_t_mefe_user_id` = `ut_map_user_permissions_unit_all`.`unee_t_mefe_id`)
		INNER JOIN `ut_map_external_source_units` 
			ON (`ut_map_user_permissions_unit_all`.`unee_t_unit_id` = `ut_map_external_source_units`.`unee_t_mefe_unit_id`) 
			AND (`external_map_user_unit_role_permissions_level_3`.`unee_t_level_3_id` = `ut_map_external_source_units`.`new_record_id`)
	WHERE (`ut_map_external_source_units`.`external_property_type_id` = 3)
	;

# We create a view to get external persons information
# This is to facilitate searches

	DROP VIEW IF EXISTS `ut_info_external_persons` ;

	CREATE VIEW `ut_info_external_persons`
	AS 
	SELECT
		`id_person` AS `id_external_persons`
		, `external_id`
		, `external_system`
		, `external_table`
		, `created_by_id` as `organization_id`
		, CONCAT(IFNULL(`given_name`
			, ''), ' ', IFNULL(`middle_name`
			, ''), ' ', IFNULL(`family_name`
			, ''), ' (', IFNULL(`alias`
			, ''), ')') AS `name`
		, `email`
	FROM
		`external_persons`
		;


# We create a view to get persons information
# This is to facilitate searches

	DROP VIEW IF EXISTS `ut_info_persons` ;

	CREATE VIEW `ut_info_persons`
	AS
	SELECT
		`id_person`
		, `external_id`
		, `external_system`
		, `external_table`
		, `organization_id`
		, CONCAT(IFNULL(`given_name`
			, ''), ' ', IFNULL(`middle_name`
			, ''), ' ', IFNULL(`family_name`
			, ''), ' (', IFNULL(`alias`
			, ''), ')') AS `name`
		, `email`
	FROM
		`persons`
		;

# We create a view to get mefe users information
# This is to facilitate searches

	DROP VIEW IF EXISTS `ut_info_mefe_users` ;

	CREATE VIEW `ut_info_mefe_users`
	AS 
	SELECT
		`persons`.`id_person`
		, `ut_map_external_source_users`.`unee_t_mefe_user_id`
		, `ut_map_external_source_users`.`external_person_id`
		, `ut_map_external_source_users`.`external_system`
		, `ut_map_external_source_users`.`table_in_external_system`
		, `persons`.`organization_id`
		, `ut_map_external_source_users`.`uneet_login_name`
		, CONCAT(IFNULL(`persons`.`given_name`
			, ''), ' ', IFNULL(`persons`.`middle_name`
			, ''), ' ', IFNULL(`persons`.`family_name`
			, ''), ' (', IFNULL(`persons`.`alias`
			, ''), ')') AS `name`
		, `persons`.`email`
	FROM
		`ut_map_external_source_users`
		INNER JOIN `persons` 
			ON (`ut_map_external_source_users`.`person_id` = `persons`.`id_person`)
		;

# We create a view to get check the creation time for units

	DROP VIEW IF EXISTS `ut_analysis_mefe_api_unit_creation_time` ;

	CREATE VIEW `ut_analysis_mefe_api_unit_creation_time`
	AS 
	SELECT
		`id_map`
		, `uneet_name`
		, `external_property_type_id`
		, `syst_created_datetime`
		, `syst_updated_datetime`
		, `uneet_created_datetime`
		, TIMEDIFF (`uneet_created_datetime`
			, `syst_created_datetime`
			) AS `creation_time`
	FROM
		`ut_map_external_source_units`
	WHERE (`unee_t_mefe_unit_id` IS NOT NULL)
	ORDER BY `syst_created_datetime` DESC
		, `external_property_type_id` ASC
		, `uneet_created_datetime` DESC
		, `syst_updated_datetime` DESC
		;

# We create a view to get check the creation time for users

	DROP VIEW IF EXISTS `ut_analysis_mefe_api_user_creation_time` ;

	CREATE VIEW `ut_analysis_mefe_api_user_creation_time`
	AS 
	SELECT
		`id_map`
		, `uneet_login_name`
		, `syst_created_datetime`
		, `syst_updated_datetime`
		, `uneet_created_datetime`
		, TIMEDIFF (`uneet_created_datetime`
			, `syst_created_datetime`
			) AS `creation_time`
	FROM
		`ut_map_external_source_users`
	WHERE (`unee_t_mefe_user_id` IS NOT NULL)
		ORDER BY `syst_created_datetime` DESC
			, `uneet_created_datetime` DESC
			, `syst_updated_datetime` DESC
	;

# We create a view to get check the creation time for association user/unit

	DROP VIEW IF EXISTS `ut_analysis_mefe_api_assign_user_to_unit_creation_time` ;

	CREATE VIEW `ut_analysis_mefe_api_assign_user_to_unit_creation_time`
	AS
	SELECT
		`a`.`id_map_user_unit_permissions`
		, `b`.`uneet_login_name`
		, `c`.`uneet_name`
		, `a`.`syst_created_datetime`
		, `a`.`syst_updated_datetime`
		, `a`.`unee_t_update_ts`
		, TIMEDIFF (`a`.`unee_t_update_ts`
		, `a`.`syst_created_datetime`
		) AS `creation_time`
	FROM
		`ut_map_user_permissions_unit_all` AS `a`
		INNER JOIN `ut_map_external_source_users` AS `b` 
			ON (`a`.`unee_t_mefe_id` = `b`.`unee_t_mefe_user_id`)
		INNER JOIN `ut_map_external_source_units` AS `c`
			ON (`a`.`unee_t_unit_id` = `c`.`unee_t_mefe_unit_id`)
	WHERE (`a`.`unee_t_update_ts` IS NOT NULL)
		ORDER BY `a`.`syst_created_datetime` DESC
			, `a`.`unee_t_update_ts` DESC
			, `a`.`syst_updated_datetime` DESC
	;

# We create a view to get the default area for each organization

	DROP VIEW IF EXISTS `ut_organization_default_area` ;

	CREATE VIEW `ut_organization_default_area`
	AS
	SELECT 
		`id_area` AS `default_area_id`
		, `area_name` AS `default_area_name`
		, `created_by_id` AS `organization_id`
	FROM `external_property_groups_areas`
	WHERE 
		`is_default` = 1
		AND (`country_code` IS NULL
			OR `country_code` = '')
	;

# We create a view to get the default external system for each organization

	DROP VIEW IF EXISTS `ut_organization_default_external_system` ;

	CREATE VIEW `ut_organization_default_external_system`
	AS
	SELECT 
		`designation`
		, `organization_id`
	FROM `ut_external_sot_for_unee_t_objects`
	;

# We create a view to get the default table for areas for each organization

	DROP VIEW IF EXISTS `ut_organization_default_table_areas` ;

	CREATE VIEW `ut_organization_default_table_areas`
	AS
	SELECT 
		`area_table`
		, `organization_id`
	FROM `ut_external_sot_for_unee_t_objects`
	;

# We create a view to get the default table_level_1_properties for each organization

	DROP VIEW IF EXISTS `ut_organization_default_table_level_1_properties` ;

	CREATE VIEW `ut_organization_default_table_level_1_properties`
	AS
	SELECT 
		`properties_level_1_table`
		, `organization_id`
	FROM `ut_external_sot_for_unee_t_objects`
	;

# We create a view to get the default table_level_2_properties for each organization

	DROP VIEW IF EXISTS `ut_organization_default_table_level_2_properties` ;

	CREATE VIEW `ut_organization_default_table_level_2_properties`
	AS
	SELECT 
		`properties_level_2_table`
		, `organization_id`
	FROM `ut_external_sot_for_unee_t_objects`
	;

# We create a view to get the default table_level_3_properties for each organization

	DROP VIEW IF EXISTS `ut_organization_default_table_level_3_properties` ;

	CREATE VIEW `ut_organization_default_table_level_3_properties`
	AS
	SELECT 
		`properties_level_3_table`
		, `organization_id`
	FROM `ut_external_sot_for_unee_t_objects`
	;

# We create a view to get the default table `persons` for each organization

	DROP VIEW IF EXISTS `ut_organization_default_table_persons` ;

	CREATE VIEW `ut_organization_default_table_persons`
	AS
	SELECT 
		`person_table`
		, `organization_id`
	FROM `ut_external_sot_for_unee_t_objects`
	;

# We create a view to get the associated MEFE user for each organization

	DROP VIEW IF EXISTS `ut_organization_associated_mefe_user` ;

	CREATE VIEW `ut_organization_associated_mefe_user`
	AS
	SELECT 
		`mefe_user_id` AS `associated_mefe_user`
		, `organization_id`
	FROM `ut_api_keys`
	;

# We create a view to list user by organization by country

	DROP VIEW IF EXISTS `ut_list_users_default_permissions` ;

	CREATE VIEW `ut_list_users_default_permissions`
	AS 
	SELECT 
		`a`.`unee_t_mefe_user_id` AS `mefe_user_id`
		, `a`.`organization_id`
		, `b`.`country_code`
		, `b`.`email`
		, `b`.`unee_t_user_type_id`
		, `c`.`ut_user_role_type_id` AS `unee_t_role_id`
		, `c`.`is_all_unit`
		, `c`.`is_all_units_in_country`
		, `c`.`is_all_units_in_area`
		, `c`.`is_all_units_in_level_1`
		, `c`.`is_all_units_in_level_2`
		, `c`.`is_occupant`
		, `c`.`is_public`
		, `c`.`is_default_assignee`
		, `c`.`is_default_invited`
		, `c`.`is_unit_owner`
		, `c`.`is_dashboard_access`
		, `c`.`can_see_role_contractor`
		, `c`.`can_see_role_mgt_cny`
		, `c`.`can_see_occupant`
		, `c`.`can_see_role_landlord`
		, `c`.`can_see_role_agent`
		, `c`.`can_see_role_tenant`
		, `c`.`is_assigned_to_case`
		, `c`.`is_invited_to_case`
		, `c`.`is_solution_updated`
		, `c`.`is_next_step_updated`
		, `c`.`is_deadline_updated`
		, `c`.`is_case_resolved`
		, `c`.`is_case_critical`
		, `c`.`is_case_blocker`
		, `c`.`is_message_from_contractor`
		, `c`.`is_message_from_mgt_cny`
		, `c`.`is_message_from_agent`
		, `c`.`is_message_from_occupant`
		, `c`.`is_message_from_ll`
		, `c`.`is_message_from_tenant`
		, `c`.`is_any_new_message`
		, `c`.`is_new_ir`
		, `c`.`is_new_inventory`
		, `c`.`is_new_item`
		, `c`.`is_item_moved`
		, `c`.`is_item_removed`
		FROM `ut_map_external_source_users` AS `a`
			INNER JOIN `persons` AS `b`
				ON `a`.`person_id` = `b`.`id_person`
			INNER JOIN `ut_user_types` AS `c`
				ON `b`.`unee_t_user_type_id` = `c`.`id_unee_t_user_type`
			INNER JOIN `person_statuses` AS `d`
				ON `b`.`person_status_id` = `d`.`id_person_status`
			WHERE `a`.`is_obsolete` = 0
				AND `a`.`unee_t_mefe_user_id` IS NOT NULL
				AND `d`.`is_active` = 1
				AND `b`.`country_code` != ''
			ORDER BY `a`.`organization_id` ASC
				, `b`.`country_code` ASC
				, `c`.`ut_user_role_type_id` ASC
			;

# Check all the non obsolete L1P

	DROP VIEW IF EXISTS `ut_verify_list_L1P_by_org_and_countries`;

	CREATE VIEW `ut_verify_list_L1P_by_org_and_countries`
	AS

		# This is a UNTE Db view
		# created for UNTE Db schema v22.2
		#
		# This query list all the L1P by:
		#   - Organization
		#   - Country code
		#   - Property name
		#
		# It shows 
		#   - mefe unit id
		#   - error message if applicable
		#
		# WHERE the L1P is NOT obsolete

		SELECT
			`c`.`designation` AS `organization`
			, `a`.`country_code`
            , `d`.`country_name` AS `country`
			, `a`.`designation` AS `L1P`
			, `a`.`id_building`
			, `b`.`unee_t_mefe_unit_id`
			, `b`.`mefe_api_error_message`
			, `b`.`uneet_created_datetime`
		FROM
			`property_level_1_buildings` AS `a`
			INNER JOIN `ut_map_external_source_units` AS `b`
				ON (`a`.`organization_id` = `b`.`organization_id`) 
				AND (`a`.`external_id` = `b`.`external_property_id`) 
				AND (`a`.`external_system_id` = `b`.`external_system`) 
				AND (`a`.`external_table` = `b`.`table_in_external_system`) 
				AND (`a`.`tower` = `b`.`tower`)
			INNER JOIN `uneet_enterprise_organizations` AS `c`
				ON (`a`.`organization_id` = `c`.`id_organization`)
            LEFT JOIN `property_groups_countries` AS `d`
                ON (`a`.`country_code` = `d`.`country_code`)
		WHERE `a`.`is_obsolete` = 0
		ORDER BY 
			`organization` ASC
			, `a`.`country_code` ASC
		;

# Count all the non obsolete L1P

	DROP VIEW IF EXISTS `ut_verify_count_L1P_by_org_and_countries`;

	CREATE VIEW `ut_verify_count_L1P_by_org_and_countries`
	AS

		# This is a UNTE Db view
		# created for UNTE Db schema v22.2
		#
		# This query counts all the L1P by:
		#   - Organization
		#   - Country code
		#   - Property name
		#
		# WHERE MEFE unit id is NOT NULL.

        SELECT
            `c`.`designation` AS `organization`
            , `a`.`organization_id`
            , `a`.`country_code`
            , `d`.`country_name` AS `country`
            , COUNT(`b`.`unee_t_mefe_unit_id`) AS `count_L1P`
        FROM
            `property_level_1_buildings` AS `a`
            INNER JOIN `ut_map_external_source_units` AS `b`
                ON (`a`.`organization_id` = `b`.`organization_id`) 
                AND (`a`.`external_id` = `b`.`external_property_id`) 
                AND (`a`.`external_system_id` = `b`.`external_system`) 
                AND (`a`.`external_table` = `b`.`table_in_external_system`) 
                AND (`a`.`tower` = `b`.`tower`)
            INNER JOIN `uneet_enterprise_organizations` AS `c`
                ON (`a`.`organization_id` = `c`.`id_organization`)
            LEFT JOIN `property_groups_countries` AS `d`
                ON (`a`.`country_code` = `d`.`country_code`)
        WHERE `b`.`unee_t_mefe_unit_id` IS NOT NULL
            AND `a`.`is_obsolete` = 0
        GROUP BY 
            `organization`
            , `country`
        ORDER BY 
            `organization` ASC
            , `country` ASC
    ;

# Check all the non obsolete L2P

    DROP VIEW IF EXISTS `ut_verify_list_L2P_by_org_and_countries`;

    CREATE VIEW `ut_verify_list_L2P_by_org_and_countries`
    AS

        # This is a UNTE Db view
        # created for UNTE Db schema v22.2
        #
        # This query list all the L1P by:
        #   - Organization
        #   - Country code
        #   - Property name
        #
        # It shows 
        #   - mefe unit id
        #   - error message if applicable
        #
        # WHERE the L2P is NOT obsolete

        SELECT
            `c`.`designation` AS `organization`
            , `a`.`organization_id`
            , `d`.`country`
            , `a`.`designation` AS `L2P`
            , `a`.`system_id_unit`
            , `b`.`unee_t_mefe_unit_id`
            , `b`.`mefe_api_error_message`
            , `b`.`uneet_created_datetime`
        FROM
            `property_level_2_units` AS `a`
            INNER JOIN `ut_map_external_source_units` AS `b`
                ON (`a`.`organization_id` = `b`.`organization_id`) 
                AND (`a`.`external_id` = `b`.`external_property_id`) 
                AND (`a`.`external_system_id` = `b`.`external_system`) 
                AND (`a`.`external_table` = `b`.`table_in_external_system`)
            INNER JOIN `uneet_enterprise_organizations` AS `c`
                ON (`a`.`organization_id` = `c`.`id_organization`)
            INNER JOIN `ut_add_information_unit_level_2` AS `d`
                ON (`a`.`system_id_unit` = `d`.`unit_level_2_id`)
        WHERE (`a`.`is_obsolete` = 0)
        ORDER BY 
            `organization` ASC
            , `d`.`country` ASC
        ;

# Count all the non obsolete L2P

    DROP VIEW IF EXISTS `ut_verify_count_L2P_by_org_and_countries`;

    CREATE VIEW `ut_verify_count_L2P_by_org_and_countries`
    AS

        # This is a UNTE Db view
        # created for UNTE Db schema v22.2
        #
        # This query counts all the L2P by:
        #   - Organization
        #   - Country code
        #   - Property name
        #
        # WHERE MEFE unit id is NOT NULL.

        SELECT
            `c`.`designation` AS `organization`
            , `a`.`organization_id`
            , `d`.`country`
            , COUNT(`b`.`unee_t_mefe_unit_id`) AS `count_L2P`
        FROM
            `property_level_2_units` AS `a`
            INNER JOIN `ut_map_external_source_units` AS `b`
                ON (`a`.`organization_id` = `b`.`organization_id`) 
                AND (`a`.`external_id` = `b`.`external_property_id`) 
                AND (`a`.`external_system_id` = `b`.`external_system`) 
                AND (`a`.`external_table` = `b`.`table_in_external_system`)
            INNER JOIN `uneet_enterprise_organizations` AS `c`
                ON (`a`.`organization_id` = `c`.`id_organization`)
            INNER JOIN `ut_add_information_unit_level_2` AS `d`
                ON (`a`.`system_id_unit` = `d`.`unit_level_2_id`)
        WHERE `b`.`unee_t_mefe_unit_id` IS NOT NULL
            AND `a`.`is_obsolete` = 0
        GROUP BY 
            `organization`
            , `d`.`country`
        ORDER BY 
            `organization` ASC
            , `d`.`country` ASC
        ;

# Check all the non obsolete L3P

    DROP VIEW IF EXISTS `ut_verify_list_L3P_by_org_and_countries`;

    CREATE VIEW `ut_verify_list_L3P_by_org_and_countries`
    AS

        # This is a UNTE Db view
        # created for UNTE Db schema v22.2
        #
        # This query list all the L1P by:
        #   - Organization
        #   - Country code
        #   - Property name
        #
        # It shows 
        #   - mefe unit id
        #   - error message if applicable
        #
        # WHERE the L3P is NOT obsolete

        SELECT
            `c`.`designation` AS `organization`
            , `d`.`country`
            , `a`.`room_designation` AS `L3P`
            , `a`.`system_id_room`
            , `b`.`unee_t_mefe_unit_id`
            , `b`.`mefe_api_error_message`
            , `b`.`uneet_created_datetime`
        FROM
            `property_level_3_rooms` AS `a`
            INNER JOIN `ut_map_external_source_units` AS `b`
                ON (`a`.`organization_id` = `b`.`organization_id`) 
                AND (`a`.`external_id` = `b`.`external_property_id`) 
                AND (`a`.`external_system_id` = `b`.`external_system`) 
                AND (`a`.`external_table` = `b`.`table_in_external_system`)
            INNER JOIN `uneet_enterprise_organizations` AS `c`
                ON (`a`.`organization_id` = `c`.`id_organization`)
            INNER JOIN `ut_add_information_unit_level_3` AS `d`
                ON (`a`.`system_id_room` = `d`.`unit_level_3_id`)
        WHERE (`a`.`is_obsolete` = 0)
        ORDER BY 
            `organization` ASC
            , `d`.`country` ASC
        ;

# Count all the non obsolete L3P

    DROP VIEW IF EXISTS `ut_verify_count_L3P_by_org_and_countries`;

    CREATE VIEW `ut_verify_count_L3P_by_org_and_countries`
    AS

        # This is a UNTE Db view
        # created for UNTE Db schema v22.2
        #
        # This query counts all the L3P by:
        #   - Organization
        #   - Country code
        #   - Property name
        #
        # WHERE MEFE unit id is NOT NULL.

        SELECT
            `c`.`designation` AS `organization`
            , `a`.`organization_id`
            , `d`.`country`
            , COUNT(`b`.`unee_t_mefe_unit_id`) AS `count_L3P`
        FROM
            `property_level_3_rooms` AS `a`
            INNER JOIN `ut_map_external_source_units` AS `b`
                ON (`a`.`organization_id` = `b`.`organization_id`) 
                AND (`a`.`external_id` = `b`.`external_property_id`) 
                AND (`a`.`external_system_id` = `b`.`external_system`) 
                AND (`a`.`external_table` = `b`.`table_in_external_system`)
            INNER JOIN `uneet_enterprise_organizations` AS `c`
                ON (`a`.`organization_id` = `c`.`id_organization`)
            INNER JOIN `ut_add_information_unit_level_3` AS `d`
                ON (`a`.`system_id_room` = `d`.`unit_level_3_id`)
        WHERE `b`.`unee_t_mefe_unit_id` IS NOT NULL
            AND `a`.`is_obsolete` = 0
        GROUP BY 
            `organization`
            , `d`.`country`
        ORDER BY 
            `organization` ASC
            , `d`.`country` ASC
        ;

# Count ALL the NON obsolete properties by organization and by countries

    DROP VIEW IF EXISTS `ut_verify_count_all_P_by_org_and_countries`;

    CREATE VIEW `ut_verify_count_all_P_by_org_and_countries`
    AS

        # This is a UNTE Db view
        # created for UNTE Db schema v22.2
        #
        # This query counts all the Properties by:
        #   - Organization
        #   - Country code
        #   - Property type
        #
        # WHERE MEFE unit id is NOT NULL.

        SELECT
            `a`.`organization`
            , `a`.`organization_id`
            , `a`.`country`
            , `a`.`count_L1P`
            , `b`.`count_L2P`
            , `c`.`count_L3P`
            , (`a`.`count_L1P` 
        		+ IFNULL(`b`.`count_L2P`, 0)
                + IFNULL(`c`.`count_L3P`, 0)
                )
                AS `total_non_obsolete_properties`
        FROM
            `ut_verify_count_L1P_by_org_and_countries` AS `a`
            LEFT JOIN `ut_verify_count_L2P_by_org_and_countries` AS `b`
                ON (`a`.`organization_id` = `b`.`organization_id`) 
                AND (`a`.`country` = `b`.`country`)
            LEFT JOIN `ut_verify_count_L3P_by_org_and_countries` AS `c`
                ON (`a`.`organization_id` = `c`.`organization_id`) 
                AND (`a`.`country` = `c`.`country`)
        ;


#################
#
# This lists all the triggers we use 
# to add a user to a role in a unit
# All Level_1 properties in an Area
# via the Unee-T Enterprise Interface
#
#################

# Assign user to an Area based on the units level_1 (buildings in that area):
# Insert the record in the tables
#	- `ut_map_user_permissions_unit_level_1`

			DROP TRIGGER IF EXISTS `ut_add_user_to_role_in_all_buildings_in_area`;

DELIMITER $$
CREATE TRIGGER `ut_add_user_to_role_in_all_buildings_in_area`
AFTER INSERT ON `external_map_user_unit_role_permissions_areas`
FOR EACH ROW
BEGIN

# We only do this IF
#	- We have a MEFE user ID for the creator of that record
#	- This is not an obsolete request
#	- We have a MEFE user ID for the user that we are adding
#	- We have an area ID for that area.
#	- We have a role_type
#	- We have a user_type
#	- This is done via an authorized insert method:
#		- 'Assign_Areas_to_Users_Add_Page'
#		- 'Assign_Areas_to_Users_Import_Page'
#		- ''
#		- ''
#		- ''
#

	SET @source_system_creator = NEW.`created_by_id` ;
	SET @source_system_updater = NEW.`updated_by_id`;

	SET @creator_mefe_user_id = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator
		)
		;

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;

	SET @organization_id = NEW.`organization_id` ;

	SET @is_obsolete = NEW.`is_obsolete` ;

	SET @area_id = NEW.`unee_t_area_id` ;

	SET @unee_t_mefe_user_id = NEW.`unee_t_mefe_user_id` ;
	SET @unee_t_user_type_id = NEW.`unee_t_user_type_id` ;
	SET @unee_t_role_id = NEW.`unee_t_role_id` ;

	IF @source_system_creator IS NOT NULL
		AND @is_obsolete = 0
		AND @area_id IS NOT NULL
		AND @unee_t_mefe_user_id IS NOT NULL
		AND @unee_t_user_type_id IS NOT NULL
		AND @unee_t_role_id IS NOT NULL
		AND (@upstream_create_method = 'Assign_Areas_to_Users_Add_Page'
			OR @upstream_update_method = 'Assign_Areas_to_Users_Add_Page'
			OR @upstream_create_method = 'Assign_Areas_to_Users_Import_Page'
			OR @upstream_update_method = 'Assign_Areas_to_Users_Import_Page'
			)
	THEN 

	# We capture the variables that we need:

		SET @this_trigger = 'ut_add_user_to_role_in_all_buildings_in_area' ;

		SET @syst_created_datetime = NOW() ;
		SET @creation_system_id = 2 ;
		SET @created_by_id = @source_system_creator ;
		SET @creation_method = @this_trigger ;

		SET @syst_updated_datetime = NOW() ;
		SET @update_system_id = 2 ;
		SET @updated_by_id = @source_system_updater ;
		SET @update_method = @this_trigger ;

		SET @organization_id = NEW.`organization_id`;

		SET @is_obsolete = NEW.`is_obsolete` ;
		SET @is_update_needed = 1 ;

		SET @area_external_id = (SELECT `external_id`
			FROM `property_groups_areas`
			WHERE `id_area` = @area_id
			);
		SET @area_external_system_id = (SELECT `external_system_id`
			FROM `property_groups_areas`
			WHERE `id_area` = @area_id
			);
		SET @area_external_table = (SELECT `external_table`
			FROM `property_groups_areas`
			WHERE `id_area` = @area_id
			);

		SET @area_id_external_table = (SELECT `id_area`
			FROM `external_property_groups_areas`
			WHERE `external_id` = @area_external_id
				AND `external_system_id` = @area_external_system_id
				AND `external_table` = @area_external_table
				AND `created_by_id` = @organization_id
			);

		SET @propagate_to_all_level_2 = NEW.`propagate_level_2` ;
		SET @propagate_to_all_level_3 = NEW.`propagate_level_3` ;

	# We include these into the table `external_map_user_unit_role_permissions_level_1`
	# for the Level_1 properties (Building)

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
			# Which type of Unee-T user
			, `unee_t_user_type_id`
			# which role
			, `unee_t_role_id`
			, `propagate_level_2`
			, `propagate_level_3`
			)
			SELECT
				@syst_created_datetime
				, @creation_system_id
				, @source_system_creator
				, @creation_method
				, @organization_id
				, @is_obsolete
				, @is_update_needed
				# Which unit/user
				, @unee_t_mefe_user_id
				, `level_1_building_id`
				# Which type of Unee-T user
				, @unee_t_user_type_id
				# which role
				, @unee_t_role_id
				, @propagate_to_all_level_2
				, @propagate_to_all_level_3
				FROM `ut_list_mefe_unit_id_level_1_by_area`
				WHERE 
					`id_area` = @area_id
				GROUP BY `level_1_building_id`
				;

		# We insert the property level 1 to the table `ut_map_user_permissions_unit_level_1`

	# We need the MEFE unit_id for each of the buildings:

		SET @unee_t_mefe_unit_id = (SELECT `unee_t_mefe_unit_id`
			FROM `ut_list_mefe_unit_id_level_1_by_area`
			WHERE `level_1_building_id` = @unee_t_level_1_id
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

	# We can now include these into the table for the Level_1 properties (Building)

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
					, @creator_mefe_user_id
					, @creation_method
					, @organization_id
					, @is_obsolete
					, @is_update_needed
					# Which unit/user
					, @unee_t_mefe_user_id
					, `unee_t_mefe_unit_id`
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
					, @propagate_to_all_level_2
					, @propagate_to_all_level_3
				FROM `ut_list_mefe_unit_id_level_1_by_area`
				WHERE 
					`id_area` = @area_id
					GROUP BY `level_1_building_id`
					;

	END IF;
END;
$$
DELIMITER ;


#################
#
# This lists all the triggers we use 
# to add a user to a role in a unit
# Level_1 properties
# via the Unee-T Enterprise Interface
#
#################

# This script creates the following trigger:
#	- `ut_add_user_to_role_in_a_level_1_property`
#	- ``
#

# For properties Level 1

	DROP TRIGGER IF EXISTS `ut_add_user_to_role_in_a_level_1_property`;

DELIMITER $$
CREATE TRIGGER `ut_add_user_to_role_in_a_level_1_property`
AFTER INSERT ON `external_map_user_unit_role_permissions_level_1`
FOR EACH ROW
BEGIN

# We only do this IF
#	- We have a MEFE user ID for the creator of that record
#	- We have an organization ID
#	- This is not an obsolete request
#	- We have a MEFE user ID for the user that we are adding
#	- We have an area ID for the area.
#	- We have a role_type
#	- We have a user_type
#	- We have a MEFE unit ID for the level 1 unit.
#	- This is done via an authorized insert method:
#		- 'Assign_Buildings_to_Users_Add_Page'
#		- 'Assign_Buildings_to_Users_Import_Page'
#		- 'ut_retry_assign_user_to_units_error_already_has_role'
#		- 'imported_from_hmlet_ipi'
#		- ''
#		- ''
#

	SET @source_system_creator_add_u_l1_1 := NEW.`created_by_id` ;
	SET @source_system_updater_add_u_l1_1 := NEW.`updated_by_id`;

	SET @creator_mefe_user_id_add_u_l1_1 := (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator_add_u_l1_1
		)
		;

	SET @organization_id_add_u_l1_1 := NEW.`organization_id` ;

	SET @is_obsolete_add_u_l1_1 := NEW.`is_obsolete` ;

	SET @unee_t_level_1_id_add_u_l1_1 := NEW.`unee_t_level_1_id` ;

	SET @unee_t_mefe_user_id_add_u_l1_1 := NEW.`unee_t_mefe_user_id` ;
	SET @unee_t_user_type_id_add_u_l1_1 := NEW.`unee_t_user_type_id` ;
	SET @unee_t_role_id_add_u_l1_1 := NEW.`unee_t_role_id` ;

	SET @unee_t_mefe_unit_id_add_u_l1_1 := (SELECT `unee_t_mefe_unit_id`
		FROM `ut_list_mefe_unit_id_level_1_by_area`
		WHERE `level_1_building_id` = @unee_t_level_1_id_add_u_l1_1
		);

	SET @upstream_create_method_add_u_l1_1 := NEW.`creation_method` ;
	SET @upstream_update_method_add_u_l1_1 := NEW.`update_method` ;

	IF @creator_mefe_user_id_add_u_l1_1 IS NOT NULL
		AND @organization_id_add_u_l1_1 IS NOT NULL
		AND @is_obsolete_add_u_l1_1 = 0
		AND @unee_t_mefe_user_id_add_u_l1_1 IS NOT NULL
		AND @unee_t_user_type_id_add_u_l1_1 IS NOT NULL
		AND @unee_t_role_id_add_u_l1_1 IS NOT NULL
		AND @unee_t_mefe_unit_id_add_u_l1_1 IS NOT NULL
		AND (@upstream_create_method_add_u_l1_1 = 'Assign_Buildings_to_Users_Add_Page'
			OR @upstream_update_method_add_u_l1_1 = 'Assign_Buildings_to_Users_Add_Page'
			OR @upstream_create_method_add_u_l1_1 = 'Assign_Buildings_to_Users_Import_Page'
			OR @upstream_update_method_add_u_l1_1 = 'Assign_Buildings_to_Users_Import_Page'
			OR @upstream_create_method_add_u_l1_1 = 'ut_retry_assign_user_to_units_error_already_has_role'
			OR @upstream_update_method_add_u_l1_1 = 'ut_retry_assign_user_to_units_error_already_has_role'
			OR @upstream_create_method_add_u_l2_1 = 'imported_from_hmlet_ipi'
			OR @upstream_update_method_add_u_l2_1 = 'imported_from_hmlet_ipi'
			)
	THEN 

	# We capture the variables that we need:

		SET @this_trigger_add_u_l1_1 := 'ut_add_user_to_role_in_a_level_1_property' ;

		SET @syst_created_datetime_add_u_l1_1 := NOW() ;
		SET @creation_system_id_add_u_l1_1 := 2 ;
		SET @created_by_id_add_u_l1_1 := @source_system_creator_add_u_l1_1 ;
		SET @creation_method_add_u_l1_1 := @this_trigger_add_u_l1_1 ;

		SET @syst_updated_datetime_add_u_l1_1 := NOW() ;
		SET @update_system_id_add_u_l1_1 := 2 ;
		SET @updated_by_id_add_u_l1_1 := @source_system_updater_add_u_l1_1 ;
		SET @update_method_add_u_l1_1 := @this_trigger_add_u_l1_1 ;

		SET @is_obsolete_add_u_l1_1 := NEW.`is_obsolete` ;
		SET @is_update_needed_add_u_l1_1 := 1 ;

		SET @propagate_to_all_level_2_add_u_l1_1 := NEW.`propagate_level_2` ;
		SET @propagate_to_all_level_3_add_u_l1_1 := NEW.`propagate_level_3` ;

	# We insert these permissions in the table `ut_map_user_permissions_unit_level_1`
	# We need the values for each of the preferences

		SET @is_occupant := (SELECT `is_occupant` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l1_1
			);

		# additional permissions 
		SET @is_default_assignee := (SELECT `is_default_assignee` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l1_1
			);
		SET @is_default_invited := (SELECT `is_default_invited` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l1_1
			);
		SET @is_unit_owner := (SELECT `is_unit_owner` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l1_1
			);

		# Visibility rules 
		SET @is_public := (SELECT `is_public` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l1_1
			);
		SET @can_see_role_landlord := (SELECT `can_see_role_landlord` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l1_1
			);
		SET @can_see_role_tenant := (SELECT `can_see_role_tenant` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l1_1
			);
		SET @can_see_role_mgt_cny := (SELECT `can_see_role_mgt_cny` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l1_1
			);
		SET @can_see_role_agent := (SELECT `can_see_role_agent` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l1_1
			);
		SET @can_see_role_contractor := (SELECT `can_see_role_contractor` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l1_1
			);
		SET @can_see_occupant := (SELECT `can_see_occupant` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l1_1
			);

		# Notification rules 
		# - case - information 
		SET @is_assigned_to_case := (SELECT `is_assigned_to_case` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l1_1
			);
		SET @is_invited_to_case := (SELECT `is_invited_to_case` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l1_1
			);
		SET @is_next_step_updated := (SELECT `is_next_step_updated` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l1_1
			);
		SET @is_deadline_updated := (SELECT `is_deadline_updated` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l1_1
			);
		SET @is_solution_updated := (SELECT `is_solution_updated` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l1_1
			);
		SET @is_case_resolved := (SELECT `is_case_resolved` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l1_1
			);
		SET @is_case_blocker := (SELECT `is_case_blocker` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l1_1
			);
		SET @is_case_critical := (SELECT `is_case_critical` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l1_1
			);

		# - case - messages 
		SET @is_any_new_message := (SELECT `is_any_new_message` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l1_1
			);
		SET @is_message_from_tenant := (SELECT `is_message_from_tenant` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l1_1
			);
		SET @is_message_from_ll := (SELECT `is_message_from_ll` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l1_1
			);
		SET @is_message_from_occupant := (SELECT `is_message_from_occupant` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l1_1
			);
		SET @is_message_from_agent := (SELECT `is_message_from_agent` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l1_1
			);
		SET @is_message_from_mgt_cny := (SELECT `is_message_from_mgt_cny` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l1_1
			);
		SET @is_message_from_contractor := (SELECT `is_message_from_contractor` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l1_1
			);

		# - Inspection Reports 
		SET @is_new_ir := (SELECT `is_new_ir` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l1_1
			);

		# - Inventory 
		SET @is_new_item := (SELECT `is_new_item` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l1_1
			);
		SET @is_item_removed := (SELECT `is_item_removed` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l1_1
			);
		SET @is_item_moved := (SELECT `is_item_moved` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l1_1
			);

	# We can now include these into the table for the Level_1 properties (Building)

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
				VALUES
					(@syst_created_datetime_add_u_l1_1
					, @creation_system_id_add_u_l1_1
					, @creator_mefe_user_id_add_u_l1_1
					, @creation_method_add_u_l1_1
					, @organization_id_add_u_l1_1
					, @is_obsolete_add_u_l1_1
					, @is_update_needed_add_u_l1_1
					# Which unit/user
					, @unee_t_mefe_user_id_add_u_l1_1
					, @unee_t_mefe_unit_id_add_u_l1_1
					# which role
					, @unee_t_role_id_add_u_l1_1
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
					, @propagate_to_all_level_2_add_u_l1_1
					, @propagate_to_all_level_3_add_u_l1_1
					)
				ON DUPLICATE KEY UPDATE
					`syst_updated_datetime` := @syst_created_datetime_add_u_l1_1
					, `update_system_id` := @creation_system_id_add_u_l1_1
					, `updated_by_id` := @creator_mefe_user_id_add_u_l1_1
					, `update_method` := @creation_method_add_u_l1_1
					, `organization_id` := @organization_id_add_u_l1_1
					, `is_obsolete` := @is_obsolete_add_u_l1_1
					, `is_update_needed` := @is_update_needed_add_u_l1_1
					# Which unit/user
					, `unee_t_mefe_id` := @unee_t_mefe_user_id_add_u_l1_1
					, `unee_t_unit_id` := @unee_t_mefe_unit_id_add_u_l1_1
					# which role
					, `unee_t_role_id` := @unee_t_role_id_add_u_l1_1
					, `is_occupant` := @is_occupant
					# additional permissions
					, `is_default_assignee` := @is_default_assignee
					, `is_default_invited` := @is_default_invited
					, `is_unit_owner` := @is_unit_owner
					# Visibility rules
					, `is_public` := @is_public
					, `can_see_role_landlord` := @can_see_role_landlord
					, `can_see_role_tenant` := @can_see_role_tenant
					, `can_see_role_mgt_cny` := @can_see_role_mgt_cny
					, `can_see_role_agent` := @can_see_role_agent
					, `can_see_role_contractor` := @can_see_role_contractor
					, `can_see_occupant` := @can_see_occupant
					# Notification rules
					# - case - information
					, `is_assigned_to_case` := @is_assigned_to_case
					, `is_invited_to_case` := @is_invited_to_case
					, `is_next_step_updated` := @is_next_step_updated
					, `is_deadline_updated` := @is_deadline_updated
					, `is_solution_updated` := @is_solution_updated
					, `is_case_resolved` := @is_case_resolved
					, `is_case_blocker` := @is_case_blocker
					, `is_case_critical` := @is_case_critical
					# - case - messages
					, `is_any_new_message` := @is_any_new_message
					, `is_message_from_tenant` := @is_message_from_tenant
					, `is_message_from_ll` := @is_message_from_ll
					, `is_message_from_occupant` := @is_message_from_occupant
					, `is_message_from_agent` := @is_message_from_agent
					, `is_message_from_mgt_cny` := @is_message_from_mgt_cny
					, `is_message_from_contractor` := @is_message_from_contractor
					# - Inspection Reports
					, `is_new_ir` := @is_new_ir
					# - Inventory
					, `is_new_item` := @is_new_item
					, `is_item_removed` := @is_item_removed
					, `is_item_moved` := @is_item_moved
					;

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
			VALUES
				(@syst_created_datetime_add_u_l1_1
				, @creation_system_id_add_u_l1_1
				, @creator_mefe_user_id_add_u_l1_1
				, @creation_method_add_u_l1_1
				, @organization_id_add_u_l1_1
				, @is_obsolete_add_u_l1_1
				, @is_update_needed_add_u_l1_1
				# Which unit/user
				, @unee_t_mefe_user_id_add_u_l1_1
				, @unee_t_mefe_unit_id_add_u_l1_1
				# which role
				, @unee_t_role_id_add_u_l1_1
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
				ON DUPLICATE KEY UPDATE
					`syst_updated_datetime` := @syst_updated_datetime_add_u_l1_1
					, `update_system_id` := @update_system_id_add_u_l1_1
					, `updated_by_id` := @creator_mefe_user_id_add_u_l1_1
					, `update_method` := @update_method_add_u_l1_1
					, `organization_id` := @organization_id_add_u_l1_1
					, `is_obsolete` := @is_obsolete_add_u_l1_1
					, `is_update_needed` := @is_update_needed_add_u_l1_1
					, `unee_t_mefe_id` := @unee_t_mefe_user_id_add_u_l1_1
					, `unee_t_unit_id` := @unee_t_mefe_unit_id_add_u_l1_1
					, `unee_t_role_id` := @unee_t_role_id_add_u_l1_1
					, `is_occupant` := @is_occupant
					, `is_default_assignee` := @is_default_assignee
					, `is_default_invited` := @is_default_invited
					, `is_unit_owner` := @is_unit_owner
					, `is_public` := @is_public
					, `can_see_role_landlord` := @can_see_role_landlord
					, `can_see_role_tenant` := @can_see_role_tenant
					, `can_see_role_mgt_cny` := @can_see_role_mgt_cny
					, `can_see_role_agent` := @can_see_role_agent
					, `can_see_role_contractor` := @can_see_role_contractor
					, `can_see_occupant` := @can_see_occupant
					, `is_assigned_to_case` := @is_assigned_to_case
					, `is_invited_to_case` := @is_invited_to_case
					, `is_next_step_updated` := @is_next_step_updated
					, `is_deadline_updated` := @is_deadline_updated
					, `is_solution_updated` := @is_solution_updated
					, `is_case_resolved` := @is_case_resolved
					, `is_case_blocker` := @is_case_blocker
					, `is_case_critical` := @is_case_critical
					, `is_any_new_message` := @is_any_new_message
					, `is_message_from_tenant` := @is_message_from_tenant
					, `is_message_from_ll` := @is_message_from_ll
					, `is_message_from_occupant` := @is_message_from_occupant
					, `is_message_from_agent` := @is_message_from_agent
					, `is_message_from_mgt_cny` := @is_message_from_mgt_cny
					, `is_message_from_contractor` := @is_message_from_contractor
					, `is_new_ir` := @is_new_ir
					, `is_new_item` := @is_new_item
					, `is_item_removed` := @is_item_removed
					, `is_item_moved` := @is_item_moved
					;

	# Propagate to level 2

		# We only do this IF
		#	- We need to propagate to level 2 units

		IF @propagate_to_all_level_2_add_u_l1_1 = 1
		THEN 

		# We create a temporary table to store all the units we need to assign

			DROP TEMPORARY TABLE IF EXISTS `temp_user_unit_role_permissions_level_2`;

			CREATE TEMPORARY TABLE `temp_user_unit_role_permissions_level_2` (
				`id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique ID in this table',
				`syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
				`creation_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'What is the id of the sytem that was used for the creation of the record?',
				`created_by_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
				`creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
				`organization_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
				`is_obsolete` tinyint(1) DEFAULT 0 COMMENT 'is this obsolete?',
				`is_update_needed` tinyint(1) DEFAULT 0 COMMENT '1 if Unee-T needs to be updated',
				`unee_t_mefe_user_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The current Unee-T profile id of the person - this is the value of the field `_id` in the Mongo Collection `users`',
				`unee_t_level_2_id` int(11) NOT NULL COMMENT 'A FK to the table `property_level_2_units`',
				`external_unee_t_level_2_id` int(11) NOT NULL COMMENT 'A FK to the table `property_level_2_units`',
				`unee_t_user_type_id` int(11) NOT NULL COMMENT 'A FK to the table `ut_user_types`',
				`unee_t_role_id` mediumint(9) unsigned DEFAULT NULL COMMENT 'FK to the Unee-T BZFE table `ut_role_types` - ID of the Role for this user.',
				PRIMARY KEY (`unee_t_mefe_user_id`,`unee_t_user_type_id`,`unee_t_level_2_id`,`organization_id`),
				UNIQUE KEY `unique_id_map_user_unit_role_permissions_units` (`id`)
			) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci
			;

		# We insert the data we need in the table `temp_user_unit_role_permissions_level_2` 
		# We need the value of the building_id in the table `property_level_1_buildings` 
		# and NOT in the table `external_property_level_1_buildings`

			INSERT INTO `temp_user_unit_role_permissions_level_2`
				(`syst_created_datetime`
				, `creation_system_id`
				, `created_by_id`
				, `creation_method`
				, `organization_id`
				, `is_obsolete`
				, `is_update_needed`
				, `unee_t_mefe_user_id`
				, `unee_t_level_2_id`
				, `external_unee_t_level_2_id`
				, `unee_t_user_type_id`
				, `unee_t_role_id`
				)
				SELECT @syst_created_datetime_add_u_l1_1
					, @creation_system_id_add_u_l1_1
					, @source_system_creator_add_u_l1_1
					, @creation_method_add_u_l1_1
					, @organization_id_add_u_l1_1
					, @is_obsolete_add_u_l1_1
					, @is_update_needed_add_u_l1_1
					, @unee_t_mefe_user_id_add_u_l1_1
					, `b`.`level_2_unit_id`
					, `b`.`external_level_2_unit_id`
					, @unee_t_user_type_id_add_u_l1_1
					, @unee_t_role_id_add_u_l1_1
					FROM `property_level_2_units` AS `a`
					INNER JOIN `ut_list_mefe_unit_id_level_2_by_area` AS `b`
						ON (`b`.`level_1_building_id` = `a`.`building_system_id` )
					WHERE `b`.`level_1_building_id` = @unee_t_level_1_id_add_u_l1_1
					GROUP BY `b`.`level_2_unit_id`
				;

		# We insert the data we need in the table `external_map_user_unit_role_permissions_level_2` 

			INSERT INTO `external_map_user_unit_role_permissions_level_2`
				(`syst_created_datetime`
				, `creation_system_id`
				, `created_by_id`
				, `creation_method`
				, `organization_id`
				, `is_obsolete`
				, `is_update_needed`
				, `unee_t_mefe_user_id`
				, `unee_t_level_2_id`
				, `unee_t_user_type_id`
				, `unee_t_role_id`
				, `propagate_level_3`
				)
				SELECT 
					`syst_created_datetime`
					, `creation_system_id`
					, `created_by_id`
					, `creation_method`
					, `organization_id`
					, `is_obsolete`
					, `is_update_needed`
					, `unee_t_mefe_user_id`
					, `unee_t_level_2_id`
					, `unee_t_user_type_id`
					, `unee_t_role_id`
					, @propagate_to_all_level_3_add_u_l1_1
					FROM `temp_user_unit_role_permissions_level_2` as `a`
				ON DUPLICATE KEY UPDATE
					`syst_updated_datetime` := `a`.`syst_created_datetime`
					, `update_system_id` := `a`.`creation_system_id`
					, `updated_by_id` := `a`.`created_by_id`
					, `update_method` := `a`.`creation_method`
					, `organization_id` := `a`.`organization_id`
					, `is_obsolete` := `a`.`is_obsolete`
					, `is_update_needed` := `a`.`is_update_needed`
					, `unee_t_mefe_user_id` := `a`.`unee_t_mefe_user_id`
					, `unee_t_level_2_id` := `a`.`unee_t_level_2_id`
					, `unee_t_user_type_id` := `a`.`unee_t_user_type_id`
					, `unee_t_role_id` := `a`.`unee_t_role_id`
					, `propagate_level_3`:= @propagate_to_all_level_3_add_u_l1_1
				;

			# We can now include these into the table for the Level_2 properties

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
						)
						SELECT
							`a`.`syst_created_datetime`
							, `a`.`creation_system_id`
							, @creator_mefe_user_id_add_u_l1_1
							, `a`.`creation_method`
							, `a`.`organization_id`
							, `a`.`is_obsolete`
							, `a`.`is_update_needed`
							# Which unit/user
							, `a`.`unee_t_mefe_user_id`
							, `b`.`unee_t_mefe_unit_id`
							# which role
							, @unee_t_role_id_add_u_l1_1
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
							FROM `temp_user_unit_role_permissions_level_2` AS `a`
							INNER JOIN `ut_list_mefe_unit_id_level_2_by_area` AS `b`
								ON (`b`.`level_2_unit_id` = `a`.`unee_t_level_2_id`)
						ON DUPLICATE KEY UPDATE
							`syst_updated_datetime` := `a`.`syst_created_datetime`
							, `update_system_id` := `a`.`creation_system_id`
							, `updated_by_id` := @creator_mefe_user_id_add_u_l1_1
							, `update_method` := `a`.`creation_method`
							, `organization_id` := `a`.`organization_id`
							, `is_obsolete` := `a`.`is_obsolete`
							, `is_update_needed` := `a`.`is_update_needed`
							, `unee_t_mefe_id` :=  `a`.`unee_t_mefe_user_id`
							, `unee_t_unit_id` := `b`.`unee_t_mefe_unit_id`
							, `unee_t_role_id` := `a`.`unee_t_role_id`
							, `is_occupant` := @is_occupant
							, `is_default_assignee` := @is_default_assignee
							, `is_default_invited` := @is_default_invited
							, `is_unit_owner` := @is_unit_owner
							, `is_public` := @is_public
							, `can_see_role_landlord` := @can_see_role_landlord
							, `can_see_role_tenant` := @can_see_role_tenant
							, `can_see_role_mgt_cny` := @can_see_role_mgt_cny
							, `can_see_role_agent` := @can_see_role_agent
							, `can_see_role_contractor` := @can_see_role_contractor
							, `can_see_occupant` := @can_see_occupant
							, `is_assigned_to_case` := @is_assigned_to_case
							, `is_invited_to_case` := @is_invited_to_case
							, `is_next_step_updated` := @is_next_step_updated
							, `is_deadline_updated` := @is_deadline_updated
							, `is_solution_updated` := @is_solution_updated
							, `is_case_resolved` := @is_case_resolved
							, `is_case_blocker` := @is_case_blocker
							, `is_case_critical` := @is_case_critical
							, `is_any_new_message` := @is_any_new_message
							, `is_message_from_tenant` := @is_message_from_tenant
							, `is_message_from_ll` := @is_message_from_ll
							, `is_message_from_occupant` := @is_message_from_occupant
							, `is_message_from_agent` := @is_message_from_agent
							, `is_message_from_mgt_cny` := @is_message_from_mgt_cny
							, `is_message_from_contractor` := @is_message_from_contractor
							, `is_new_ir` := @is_new_ir
							, `is_new_item` := @is_new_item
							, `is_item_removed` := @is_item_removed
							, `is_item_moved` := @is_item_moved
							;

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
						`a`.`syst_created_datetime`
						, `a`.`creation_system_id`
						, @creator_mefe_user_id_add_u_l1_1
						, `a`.`creation_method`
						, `a`.`organization_id`
						, `a`.`is_obsolete`
						, `a`.`is_update_needed`
						# Which unit/user
						, `a`.`unee_t_mefe_user_id`
						, `b`.`unee_t_mefe_unit_id`
						# which role
						, @unee_t_role_id_add_u_l1_1
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
						FROM `temp_user_unit_role_permissions_level_2` AS `a`
							INNER JOIN `ut_list_mefe_unit_id_level_2_by_area` AS `b`
								ON (`b`.`level_2_unit_id` = `a`.`unee_t_level_2_id`)
						ON DUPLICATE KEY UPDATE
							`syst_updated_datetime` := `a`.`syst_created_datetime`
							, `update_system_id` := `a`.`creation_system_id`
							, `updated_by_id` := @creator_mefe_user_id_add_u_l1_1
							, `update_method` := `a`.`creation_method`
							, `organization_id` := `a`.`organization_id`
							, `is_obsolete` := `a`.`is_obsolete`
							, `is_update_needed` := `a`.`is_update_needed`
							, `unee_t_mefe_id` :=  `a`.`unee_t_mefe_user_id`
							, `unee_t_unit_id` := `b`.`unee_t_mefe_unit_id`
							, `unee_t_role_id` := `a`.`unee_t_role_id`
							, `is_occupant` := @is_occupant
							, `is_default_assignee` := @is_default_assignee
							, `is_default_invited` := @is_default_invited
							, `is_unit_owner` := @is_unit_owner
							, `is_public` := @is_public
							, `can_see_role_landlord` := @can_see_role_landlord
							, `can_see_role_tenant` := @can_see_role_tenant
							, `can_see_role_mgt_cny` := @can_see_role_mgt_cny
							, `can_see_role_agent` := @can_see_role_agent
							, `can_see_role_contractor` := @can_see_role_contractor
							, `can_see_occupant` := @can_see_occupant
							, `is_assigned_to_case` := @is_assigned_to_case
							, `is_invited_to_case` := @is_invited_to_case
							, `is_next_step_updated` := @is_next_step_updated
							, `is_deadline_updated` := @is_deadline_updated
							, `is_solution_updated` := @is_solution_updated
							, `is_case_resolved` := @is_case_resolved
							, `is_case_blocker` := @is_case_blocker
							, `is_case_critical` := @is_case_critical
							, `is_any_new_message` := @is_any_new_message
							, `is_message_from_tenant` := @is_message_from_tenant
							, `is_message_from_ll` := @is_message_from_ll
							, `is_message_from_occupant` := @is_message_from_occupant
							, `is_message_from_agent` := @is_message_from_agent
							, `is_message_from_mgt_cny` := @is_message_from_mgt_cny
							, `is_message_from_contractor` := @is_message_from_contractor
							, `is_new_ir` := @is_new_ir
							, `is_new_item` := @is_new_item
							, `is_item_removed` := @is_item_removed
							, `is_item_moved` := @is_item_moved
							;

		# Propagate to level 3

			# We only do this IF
			#	- We need to propagate to level 3 units

			IF @propagate_to_all_level_3_add_u_l1_1 = 1
			THEN 

			# We create a temporary table to store all the rooms we need to assign

				DROP TEMPORARY TABLE IF EXISTS `temp_user_unit_role_permissions_level_3`;

				CREATE TEMPORARY TABLE `temp_user_unit_role_permissions_level_3` (
					`id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique ID in this table',
					`syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
					`creation_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'What is the id of the sytem that was used for the creation of the record?',
					`created_by_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
					`creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
					`organization_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
					`is_obsolete` tinyint(1) DEFAULT 0 COMMENT 'is this obsolete?',
					`is_update_needed` tinyint(1) DEFAULT 0 COMMENT '1 if Unee-T needs to be updated',
					`unee_t_mefe_user_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The current Unee-T profile id of the person - this is the value of the field `_id` in the Mongo Collection `users`',
					`unee_t_level_3_id` int(11) NOT NULL COMMENT 'A FK to the table `property_level_3_rooms`',
					`external_unee_t_level_3_id` int(11) NOT NULL COMMENT 'A FK to the table `external_property_level_3_rooms`',
					`unee_t_user_type_id` int(11) NOT NULL COMMENT 'A FK to the table `ut_user_types`',
					`unee_t_role_id` mediumint(9) unsigned DEFAULT NULL COMMENT 'FK to the Unee-T BZFE table `ut_role_types` - ID of the Role for this user.',
					PRIMARY KEY (`unee_t_mefe_user_id`,`unee_t_user_type_id`,`unee_t_level_3_id`,`organization_id`),
					UNIQUE KEY `unique_id_map_user_unit_role_permissions_rooms` (`id`)
				) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci
				;

			# We need all the rooms from all the unit in that building
			#	- The id of the building is in the variable @unee_t_level_1_id_add_u_l1_1
			#	- The ids of the units in that building are in the table `temp_user_unit_role_permissions_level_2`
			# We need to insert all these data in the table `temp_user_unit_role_permissions_level_3`

				INSERT INTO `temp_user_unit_role_permissions_level_3`
					(`syst_created_datetime`
					, `creation_system_id`
					, `created_by_id`
					, `creation_method`
					, `organization_id`
					, `is_obsolete`
					, `is_update_needed`
					, `unee_t_mefe_user_id`
					, `unee_t_level_3_id`
					, `external_unee_t_level_3_id`
					, `unee_t_user_type_id`
					, `unee_t_role_id`
					)
					SELECT 
						@syst_created_datetime_add_u_l1_1
						, @creation_system_id_add_u_l1_1
						, @source_system_creator_add_u_l1_1
						, @creation_method_add_u_l1_1
						, @organization_id_add_u_l1_1
						, @is_obsolete_add_u_l1_1
						, @is_update_needed_add_u_l1_1
						, @unee_t_mefe_user_id_add_u_l1_1
						, `b`.`level_3_room_id`
						, `b`.`external_level_3_room_id`
						, @unee_t_user_type_id_add_u_l1_1
						, @unee_t_role_id_add_u_l1_1
						FROM `property_level_3_rooms` AS `a`
						INNER JOIN `ut_list_mefe_unit_id_level_3_by_area` AS `b`
							ON (`b`.`level_2_unit_id` = `a`. `system_id_unit`)
						INNER JOIN `ut_list_mefe_unit_id_level_2_by_area` AS `c`
							ON (`c`.`level_1_building_id` = `b`.`level_1_building_id`)
						WHERE `c`.`level_1_building_id` = @unee_t_level_1_id_add_u_l1_1
						GROUP BY `b`.`level_3_room_id`
					;

			# We insert the data we need in the table `external_map_user_unit_role_permissions_level_3` 

				INSERT INTO `external_map_user_unit_role_permissions_level_3`
					(`syst_created_datetime`
					, `creation_system_id`
					, `created_by_id`
					, `creation_method`
					, `organization_id`
					, `is_obsolete`
					, `is_update_needed`
					, `unee_t_mefe_user_id`
					, `unee_t_level_3_id`
					, `unee_t_user_type_id`
					, `unee_t_role_id`
					)
					SELECT 
						`syst_created_datetime`
						, `creation_system_id`
						, `created_by_id`
						, `creation_method`
						, `organization_id`
						, `is_obsolete`
						, `is_update_needed`
						, `unee_t_mefe_user_id`
						, `unee_t_level_3_id`
						, `unee_t_user_type_id`
						, `unee_t_role_id`
						FROM `temp_user_unit_role_permissions_level_3` as `a`
					ON DUPLICATE KEY UPDATE
						`syst_updated_datetime` := `a`.`syst_created_datetime`
						, `update_system_id` := `a`.`creation_system_id`
						, `updated_by_id` := `a`.`created_by_id`
						, `update_method` := `a`.`creation_method`
						, `organization_id` := `a`.`organization_id`
						, `is_obsolete` := `a`.`is_obsolete`
						, `is_update_needed` := `a`.`is_update_needed`
						, `unee_t_mefe_user_id` := `a`.`unee_t_mefe_user_id`
						, `unee_t_level_3_id` := `a`.`unee_t_level_3_id`
						, `unee_t_user_type_id` := `a`.`unee_t_user_type_id`
						, `unee_t_role_id` := `a`.`unee_t_role_id`
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
								`a`.`syst_created_datetime`
								, `a`.`creation_system_id`
								, @creator_mefe_user_id_add_u_l1_1
								, `a`.`creation_method`
								, `a`.`organization_id`
								, `a`.`is_obsolete`
								, `a`.`is_update_needed`
								# Which unit/user
								, `a`.`unee_t_mefe_user_id`
								, `b`.`unee_t_mefe_unit_id`
								# which role
								, @unee_t_role_id_add_u_l1_1
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
								FROM `temp_user_unit_role_permissions_level_3` AS `a`
								INNER JOIN `ut_list_mefe_unit_id_level_3_by_area` AS `b`
									ON (`b`.`level_3_room_id` = `a`.`unee_t_level_3_id`)
							ON DUPLICATE KEY UPDATE
								`syst_updated_datetime` := `a`.`syst_created_datetime`
								, `update_system_id` := `a`.`creation_system_id`
								, `updated_by_id` := @creator_mefe_user_id_add_u_l1_1
								, `update_method` := `a`.`creation_method`
								, `organization_id` := `a`.`organization_id`
								, `is_obsolete` := `a`.`is_obsolete`
								, `is_update_needed` := `a`.`is_update_needed`
								, `unee_t_mefe_id` := @unee_t_mefe_user_id_add_u_l1_1
								, `unee_t_unit_id` := `b`.`unee_t_mefe_unit_id`
								, `unee_t_role_id` := @unee_t_role_id_add_u_l1_1
								, `is_occupant` := @is_occupant
								, `is_default_assignee` := @is_default_assignee
								, `is_default_invited` := @is_default_invited
								, `is_unit_owner` := @is_unit_owner
								, `is_public` := @is_public
								, `can_see_role_landlord` := @can_see_role_landlord
								, `can_see_role_tenant` := @can_see_role_tenant
								, `can_see_role_mgt_cny` := @can_see_role_mgt_cny
								, `can_see_role_agent` := @can_see_role_agent
								, `can_see_role_contractor` := @can_see_role_contractor
								, `can_see_occupant` := @can_see_occupant
								, `is_assigned_to_case` := @is_assigned_to_case
								, `is_invited_to_case` := @is_invited_to_case
								, `is_next_step_updated` := @is_next_step_updated
								, `is_deadline_updated` := @is_deadline_updated
								, `is_solution_updated` := @is_solution_updated
								, `is_case_resolved` := @is_case_resolved
								, `is_case_blocker` := @is_case_blocker
								, `is_case_critical` := @is_case_critical
								, `is_any_new_message` := @is_any_new_message
								, `is_message_from_tenant` := @is_message_from_tenant
								, `is_message_from_ll` := @is_message_from_ll
								, `is_message_from_occupant` := @is_message_from_occupant
								, `is_message_from_agent` := @is_message_from_agent
								, `is_message_from_mgt_cny` := @is_message_from_mgt_cny
								, `is_message_from_contractor` := @is_message_from_contractor
								, `is_new_ir` := @is_new_ir
								, `is_new_item` := @is_new_item
								, `is_item_removed` := @is_item_removed
								, `is_item_moved` := @is_item_moved
								;

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
							SELECT
								`a`.`syst_created_datetime`
								, `a`.`creation_system_id`
								, @creator_mefe_user_id_add_u_l1_1
								, `a`.`creation_method`
								, `a`.`organization_id`
								, `a`.`is_obsolete`
								, `a`.`is_update_needed`
								# Which unit/user
								, `a`.`unee_t_mefe_user_id`
								, `b`.`unee_t_mefe_unit_id`
								# which role
								, @unee_t_role_id_add_u_l1_1
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
								FROM `temp_user_unit_role_permissions_level_3` AS `a`
								INNER JOIN `ut_list_mefe_unit_id_level_3_by_area` AS `b`
									ON (`b`.`level_3_room_id` = `a`.`unee_t_level_3_id`)
							ON DUPLICATE KEY UPDATE
								`syst_updated_datetime` := `a`.`syst_created_datetime`
								, `update_system_id` := `a`.`creation_system_id`
								, `updated_by_id` := @creator_mefe_user_id_add_u_l1_1
								, `update_method` := `a`.`creation_method`
								, `organization_id` := `a`.`organization_id`
								, `is_obsolete` := `a`.`is_obsolete`
								, `is_update_needed` := `a`.`is_update_needed`
								, `unee_t_mefe_id` := @unee_t_mefe_user_id_add_u_l1_1
								, `unee_t_unit_id` := `b`.`unee_t_mefe_unit_id`
								, `unee_t_role_id` := @unee_t_role_id_add_u_l1_1
								, `is_occupant` := @is_occupant
								, `is_default_assignee` := @is_default_assignee
								, `is_default_invited` := @is_default_invited
								, `is_unit_owner` := @is_unit_owner
								, `is_public` := @is_public
								, `can_see_role_landlord` := @can_see_role_landlord
								, `can_see_role_tenant` := @can_see_role_tenant
								, `can_see_role_mgt_cny` := @can_see_role_mgt_cny
								, `can_see_role_agent` := @can_see_role_agent
								, `can_see_role_contractor` := @can_see_role_contractor
								, `can_see_occupant` := @can_see_occupant
								, `is_assigned_to_case` := @is_assigned_to_case
								, `is_invited_to_case` := @is_invited_to_case
								, `is_next_step_updated` := @is_next_step_updated
								, `is_deadline_updated` := @is_deadline_updated
								, `is_solution_updated` := @is_solution_updated
								, `is_case_resolved` := @is_case_resolved
								, `is_case_blocker` := @is_case_blocker
								, `is_case_critical` := @is_case_critical
								, `is_any_new_message` := @is_any_new_message
								, `is_message_from_tenant` := @is_message_from_tenant
								, `is_message_from_ll` := @is_message_from_ll
								, `is_message_from_occupant` := @is_message_from_occupant
								, `is_message_from_agent` := @is_message_from_agent
								, `is_message_from_mgt_cny` := @is_message_from_mgt_cny
								, `is_message_from_contractor` := @is_message_from_contractor
								, `is_new_ir` := @is_new_ir
								, `is_new_item` := @is_new_item
								, `is_item_removed` := @is_item_removed
								, `is_item_moved` := @is_item_moved
								;

			END IF;

		END IF;

	END IF;
END;
$$
DELIMITER ;


#################
#
# This lists all the triggers we use 
# to add a user to a role in a unit
# Level_2 properties
# via the Unee-T Enterprise Interface
#
#################

# This script creates the following trigger:
#   - `ut_add_user_to_role_in_a_level_2_property`
#   - ``
#

# For properties Level 2 (Units)

	DROP TRIGGER IF EXISTS `ut_add_user_to_role_in_a_level_2_property`;

DELIMITER $$
CREATE TRIGGER `ut_add_user_to_role_in_a_level_2_property`
AFTER INSERT ON `external_map_user_unit_role_permissions_level_2`
FOR EACH ROW
BEGIN

# We only do this IF
#	- We have a MEFE user ID for the creator of that record
#	- We have an organization ID
#	- This is not an obsolete request
#	- We have a MEFE user ID for the user that we are adding
#	- We have a role_type
#	- We have a user_type
#	- We have a MEFE unit ID for the level 2 unit.
#	- This is done via an authorized insert method:
#		- 'Assign_Units_to_Users_Add_Page'
#		- 'Assign_Units_to_Users_Import_Page'
#		- 'imported_from_hmlet_ipi'
#		- ''
#

	SET @source_system_creator_add_u_l2_1 := NEW.`created_by_id` ;
	SET @source_system_updater_add_u_l2_1 := NEW.`updated_by_id`;

	SET @creator_mefe_user_id_add_u_l2_1 := (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator_add_u_l2_1
		)
		;

	SET @organization_id_add_u_l2_1 := NEW.`organization_id` ;

	SET @is_obsolete_add_u_l2_1 := NEW.`is_obsolete` ;

	SET @unee_t_level_2_id_add_u_l2_1 := NEW.`unee_t_level_2_id` ;

	SET @unee_t_mefe_user_id_add_u_l2_1 := NEW.`unee_t_mefe_user_id` ;
	SET @unee_t_user_type_id_add_u_l2_1 := NEW.`unee_t_user_type_id` ;
	SET @unee_t_role_id_add_u_l2_1 := NEW.`unee_t_role_id` ;

	SET @unee_t_mefe_unit_id_add_u_l2_1 := (SELECT `unee_t_mefe_unit_id`
		FROM `ut_list_mefe_unit_id_level_2_by_area`
		WHERE `level_2_unit_id` = @unee_t_level_2_id_add_u_l2_1
		);

	SET @upstream_create_method_add_u_l2_1 := NEW.`creation_method` ;
	SET @upstream_update_method_add_u_l2_1 := NEW.`update_method` ;

	IF @source_system_creator_add_u_l2_1 IS NOT NULL
		AND @organization_id_add_u_l2_1 IS NOT NULL
		AND @is_obsolete_add_u_l2_1 = 0
		AND @unee_t_mefe_user_id_add_u_l2_1 IS NOT NULL
		AND @unee_t_user_type_id_add_u_l2_1 IS NOT NULL
		AND @unee_t_role_id_add_u_l2_1 IS NOT NULL
		AND @unee_t_mefe_unit_id_add_u_l2_1 IS NOT NULL
		AND (@upstream_create_method_add_u_l2_1 = 'Assign_Units_to_Users_Add_Page'
			OR @upstream_update_method_add_u_l2_1 = 'Assign_Units_to_Users_Add_Page'
			OR @upstream_create_method_add_u_l2_1 = 'Assign_Units_to_Users_Import_Page'
			OR @upstream_update_method_add_u_l2_1 = 'Assign_Units_to_Users_Import_Page'
			OR @upstream_create_method_add_u_l2_1 = 'imported_from_hmlet_ipi'
			OR @upstream_update_method_add_u_l2_1 = 'imported_from_hmlet_ipi'
			)
	THEN 

	# We capture the variables that we need:

		SET @this_trigger_add_u_l2_1 := 'ut_add_user_to_role_in_a_level_2_property' ;

		SET @syst_created_datetime_add_u_l2_1 := NOW() ;
		SET @creation_system_id_add_u_l2_1 := 2 ;
		SET @created_by_id_add_u_l2_1 := @source_system_creator_add_u_l2_1 ;
		SET @creation_method_add_u_l2_1 := @this_trigger_add_u_l2_1 ;

		SET @syst_updated_datetime_add_u_l2_1 := NOW() ;
		SET @update_system_id_add_u_l2_1 := 2 ;
		SET @updated_by_id_add_u_l2_1 := @source_system_updater_add_u_l2_1 ;
		SET @update_method_add_u_l2_1 := @this_trigger_add_u_l2_1 ;

		SET @is_update_needed_add_u_l2_1 := 1 ;

		SET @propagate_to_all_level_3 := NEW.`propagate_level_3` ;

	# We insert these permissions in the table `ut_map_user_permissions_unit_level_2`
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
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l2_1
			);

	# We can now include these into the table for the Level_2 properties

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
				VALUES
					(@syst_created_datetime_add_u_l2_1
					, @creation_system_id_add_u_l2_1
					, @creator_mefe_user_id_add_u_l2_1
					, @creation_method_add_u_l2_1
					, @organization_id_add_u_l2_1
					, @is_obsolete_add_u_l2_1
					, @is_update_needed_add_u_l2_1
					# Which unit/user
					, @unee_t_mefe_user_id_add_u_l2_1
					, @unee_t_mefe_unit_id_add_u_l2_1
					# which role
					, @unee_t_role_id_add_u_l2_1
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
					, @propagate_to_all_level_3
					)
				ON DUPLICATE KEY UPDATE
					`syst_updated_datetime` := @syst_updated_datetime_add_u_l2_1
					, `update_system_id` := @update_system_id_add_u_l2_1
					, `updated_by_id` := @creator_mefe_user_id_add_u_l2_1
					, `update_method` := @update_method_add_u_l2_1
					, `organization_id` := @organization_id_add_u_l2_1
					, `is_obsolete` := @is_obsolete_add_u_l2_1
					, `is_update_needed` := @is_update_needed_add_u_l2_1
					# Which unit/user
					, `unee_t_mefe_id` := @unee_t_mefe_user_id_add_u_l2_1
					, `unee_t_unit_id` := @unee_t_mefe_unit_id_add_u_l2_1
					# which role
					, `unee_t_role_id` := @unee_t_role_id_add_u_l2_1
					, `is_occupant` := @is_occupant
					# additional permissions
					, `is_default_assignee` := @is_default_assignee
					, `is_default_invited` := @is_default_invited
					, `is_unit_owner` := @is_unit_owner
					# Visibility rules
					, `is_public` := @is_public
					, `can_see_role_landlord` := @can_see_role_landlord
					, `can_see_role_tenant` := @can_see_role_tenant
					, `can_see_role_mgt_cny` := @can_see_role_mgt_cny
					, `can_see_role_agent` := @can_see_role_agent
					, `can_see_role_contractor` := @can_see_role_contractor
					, `can_see_occupant` := @can_see_occupant
					# Notification rules
					# - case - information
					, `is_assigned_to_case` := @is_assigned_to_case
					, `is_invited_to_case` := @is_invited_to_case
					, `is_next_step_updated` := @is_next_step_updated
					, `is_deadline_updated` := @is_deadline_updated
					, `is_solution_updated` := @is_solution_updated
					, `is_case_resolved` := @is_case_resolved
					, `is_case_blocker` := @is_case_blocker
					, `is_case_critical` := @is_case_critical
					# - case - messages
					, `is_any_new_message` := @is_any_new_message
					, `is_message_from_tenant` := @is_message_from_tenant
					, `is_message_from_ll` := @is_message_from_ll
					, `is_message_from_occupant` := @is_message_from_occupant
					, `is_message_from_agent` := @is_message_from_agent
					, `is_message_from_mgt_cny` := @is_message_from_mgt_cny
					, `is_message_from_contractor` := @is_message_from_contractor
					# - Inspection Reports
					, `is_new_ir` := @is_new_ir
					# - Inventory
					, `is_new_item` := @is_new_item
					, `is_item_removed` := @is_item_removed
					, `is_item_moved` := @is_item_moved
					;

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
			VALUES
				(@syst_created_datetime_add_u_l2_1
				, @creation_system_id_add_u_l2_1
				, @creator_mefe_user_id_add_u_l2_1
				, @creation_method_add_u_l2_1
				, @organization_id_add_u_l2_1
				, @is_obsolete_add_u_l2_1
				, @is_update_needed_add_u_l2_1
				# Which unit/user
				, @unee_t_mefe_user_id_add_u_l2_1
				, @unee_t_mefe_unit_id_add_u_l2_1
				# which role
				, @unee_t_role_id_add_u_l2_1
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
				ON DUPLICATE KEY UPDATE
					`syst_updated_datetime` := @syst_updated_datetime_add_u_l2_1
					, `update_system_id` := @update_system_id_add_u_l2_1
					, `updated_by_id` := @creator_mefe_user_id_add_u_l2_1
					, `update_method` := @update_method_add_u_l2_1
					, `organization_id` := @organization_id_add_u_l2_1
					, `is_obsolete` := @is_obsolete_add_u_l2_1
					, `is_update_needed` := @is_update_needed_add_u_l2_1
					, `unee_t_mefe_id` := @unee_t_mefe_user_id_add_u_l2_1
					, `unee_t_unit_id` := @unee_t_mefe_unit_id_add_u_l2_1
					, `unee_t_role_id` := @unee_t_role_id_add_u_l2_1
					, `is_occupant` := @is_occupant
					, `is_default_assignee` := @is_default_assignee
					, `is_default_invited` := @is_default_invited
					, `is_unit_owner` := @is_unit_owner
					, `is_public` := @is_public
					, `can_see_role_landlord` := @can_see_role_landlord
					, `can_see_role_tenant` := @can_see_role_tenant
					, `can_see_role_mgt_cny` := @can_see_role_mgt_cny
					, `can_see_role_agent` := @can_see_role_agent
					, `can_see_role_contractor` := @can_see_role_contractor
					, `can_see_occupant` := @can_see_occupant
					, `is_assigned_to_case` := @is_assigned_to_case
					, `is_invited_to_case` := @is_invited_to_case
					, `is_next_step_updated` := @is_next_step_updated
					, `is_deadline_updated` := @is_deadline_updated
					, `is_solution_updated` := @is_solution_updated
					, `is_case_resolved` := @is_case_resolved
					, `is_case_blocker` := @is_case_blocker
					, `is_case_critical` := @is_case_critical
					, `is_any_new_message` := @is_any_new_message
					, `is_message_from_tenant` := @is_message_from_tenant
					, `is_message_from_ll` := @is_message_from_ll
					, `is_message_from_occupant` := @is_message_from_occupant
					, `is_message_from_agent` := @is_message_from_agent
					, `is_message_from_mgt_cny` := @is_message_from_mgt_cny
					, `is_message_from_contractor` := @is_message_from_contractor
					, `is_new_ir` := @is_new_ir
					, `is_new_item` := @is_new_item
					, `is_item_removed` := @is_item_removed
					, `is_item_moved` := @is_item_moved
					;

	# Propagate to Level 3

		# We only do this IF
		#	- We need to propagate to level 3 units

		IF @propagate_to_all_level_3 = 1
		THEN 

		# We create a temporary table to store all the rooms we need to assign

			DROP TEMPORARY TABLE IF EXISTS `temp_user_unit_role_permissions_level_3`;

			CREATE TEMPORARY TABLE `temp_user_unit_role_permissions_level_3` (
				`id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique ID in this table',
				`syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
				`creation_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'What is the id of the sytem that was used for the creation of the record?',
				`created_by_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
				`creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
				`organization_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
				`is_obsolete` tinyint(1) DEFAULT 0 COMMENT 'is this obsolete?',
				`is_update_needed` tinyint(1) DEFAULT 0 COMMENT '1 if Unee-T needs to be updated',
				`unee_t_mefe_user_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The current Unee-T profile id of the person - this is the value of the field `_id` in the Mongo Collection `users`',
				`unee_t_level_3_id` int(11) NOT NULL COMMENT 'A FK to the table `property_level_3_rooms`',
				`external_unee_t_level_3_id` int(11) NOT NULL COMMENT 'A FK to the table `external_property_level_3_rooms`',
				`unee_t_user_type_id` int(11) NOT NULL COMMENT 'A FK to the table `ut_user_types`',
				`unee_t_role_id` mediumint(9) unsigned DEFAULT NULL COMMENT 'FK to the Unee-T BZFE table `ut_role_types` - ID of the Role for this user.',
				PRIMARY KEY (`unee_t_mefe_user_id`,`unee_t_user_type_id`,`unee_t_level_3_id`,`organization_id`),
				UNIQUE KEY `unique_id_map_user_unit_role_permissions_rooms` (`id`)
			) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci
			;

		# We insert these in the table `temp_user_unit_role_permissions_level_3` 

			INSERT INTO `temp_user_unit_role_permissions_level_3`
				(`syst_created_datetime`
				, `creation_system_id`
				, `created_by_id`
				, `creation_method`
				, `organization_id`
				, `is_obsolete`
				, `is_update_needed`
				, `unee_t_mefe_user_id`
				, `unee_t_level_3_id`
				, `external_unee_t_level_3_id`
				, `unee_t_user_type_id`
				, `unee_t_role_id`
				)
				SELECT 
					@syst_created_datetime_add_u_l2_1
					, @creation_system_id_add_u_l2_1
					, @source_system_creator_add_u_l2_1
					, @creation_method_add_u_l2_1
					, @organization_id_add_u_l2_1
					, @is_obsolete_add_u_l2_1
					, @is_update_needed_add_u_l2_1
					, @unee_t_mefe_user_id_add_u_l2_1
					, `b`.`level_3_room_id`
					, `b`.`external_level_3_room_id`
					, @unee_t_user_type_id_add_u_l2_1
					, @unee_t_role_id_add_u_l2_1
					FROM `property_level_3_rooms` AS `a`
					INNER JOIN `ut_list_mefe_unit_id_level_3_by_area` AS `b`
						ON (`b`.`level_2_unit_id` = `a`. `system_id_unit`)
					WHERE `b`.`level_2_unit_id` = @unee_t_level_2_id_add_u_l2_1
					GROUP BY `b`.`level_3_room_id`
				;

		# We insert the data we need in the table `external_map_user_unit_role_permissions_level_3` 

			INSERT INTO `external_map_user_unit_role_permissions_level_3`
				(`syst_created_datetime`
				, `creation_system_id`
				, `created_by_id`
				, `creation_method`
				, `organization_id`
				, `is_obsolete`
				, `is_update_needed`
				, `unee_t_mefe_user_id`
				, `unee_t_level_3_id`
				, `unee_t_user_type_id`
				, `unee_t_role_id`
				)
				SELECT 
					`syst_created_datetime`
					, `creation_system_id`
					, `created_by_id`
					, `creation_method`
					, `organization_id`
					, `is_obsolete`
					, `is_update_needed`
					, `unee_t_mefe_user_id`
					, `unee_t_level_3_id`
					, `unee_t_user_type_id`
					, `unee_t_role_id`
					FROM `temp_user_unit_role_permissions_level_3` as `a`
				ON DUPLICATE KEY UPDATE
					`syst_updated_datetime` := `a`.`syst_created_datetime`
					, `update_system_id` := `a`.`creation_system_id`
					, `updated_by_id` := `a`.`created_by_id`
					, `update_method` := `a`.`creation_method`
					, `organization_id` := `a`.`organization_id`
					, `is_obsolete` := `a`.`is_obsolete`
					, `is_update_needed` := `a`.`is_update_needed`
					, `unee_t_mefe_user_id` := `a`.`unee_t_mefe_user_id`
					, `unee_t_level_3_id` := `a`.`unee_t_level_3_id`
					, `unee_t_user_type_id` := `a`.`unee_t_user_type_id`
					, `unee_t_role_id` := `a`.`unee_t_role_id`
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
							@syst_created_datetime_add_u_l2_1
							, @creation_system_id_add_u_l2_1
							, @creator_mefe_user_id_add_u_l2_1
							, @creation_method_add_u_l2_1
							, @organization_id_add_u_l2_1
							, @is_obsolete_add_u_l2_1
							, @is_update_needed_add_u_l2_1
							# Which unit/user
							, @unee_t_mefe_user_id_add_u_l2_1
							, `b`.`unee_t_mefe_unit_id`
							# which role
							, @unee_t_role_id_add_u_l2_1
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
							FROM `temp_user_unit_role_permissions_level_3` AS `a`
							INNER JOIN `ut_list_mefe_unit_id_level_3_by_area` AS `b`
								ON (`b`.`level_3_room_id` = `a`.`unee_t_level_3_id`)
						ON DUPLICATE KEY UPDATE
							`syst_updated_datetime` := @syst_created_datetime_add_u_l2_1
							, `update_system_id` := @creation_system_id_add_u_l2_1
							, `updated_by_id` := @creator_mefe_user_id_add_u_l2_1
							, `update_method` := @creation_method_add_u_l2_1
							, `organization_id` := @organization_id_add_u_l2_1
							, `is_obsolete` := @is_obsolete_add_u_l2_1
							, `is_update_needed` := @is_update_needed_add_u_l2_1
							# Which unit/user
							, `unee_t_mefe_id` := @unee_t_mefe_user_id_add_u_l2_1
							, `unee_t_unit_id` := `b`.`unee_t_mefe_unit_id`
							# which role
							, `unee_t_role_id` := @unee_t_role_id_add_u_l2_1
							, `is_occupant` := @is_occupant
							# additional permissions
							, `is_default_assignee` := @is_default_assignee
							, `is_default_invited` := @is_default_invited
							, `is_unit_owner` := @is_unit_owner
							# Visibility rules
							, `is_public` := @is_public
							, `can_see_role_landlord` := @can_see_role_landlord
							, `can_see_role_tenant` := @can_see_role_tenant
							, `can_see_role_mgt_cny` := @can_see_role_mgt_cny
							, `can_see_role_agent` := @can_see_role_agent
							, `can_see_role_contractor` := @can_see_role_contractor
							, `can_see_occupant` := @can_see_occupant
							# Notification rules
							# - case - information
							, `is_assigned_to_case` := @is_assigned_to_case
							, `is_invited_to_case` := @is_invited_to_case
							, `is_next_step_updated` := @is_next_step_updated
							, `is_deadline_updated` := @is_deadline_updated
							, `is_solution_updated` := @is_solution_updated
							, `is_case_resolved` := @is_case_resolved
							, `is_case_blocker` := @is_case_blocker
							, `is_case_critical` := @is_case_critical
							# - case - messages
							, `is_any_new_message` := @is_any_new_message
							, `is_message_from_tenant` := @is_message_from_tenant
							, `is_message_from_ll` := @is_message_from_ll
							, `is_message_from_occupant` := @is_message_from_occupant
							, `is_message_from_agent` := @is_message_from_agent
							, `is_message_from_mgt_cny` := @is_message_from_mgt_cny
							, `is_message_from_contractor` := @is_message_from_contractor
							# - Inspection Reports
							, `is_new_ir` := @is_new_ir
							# - Inventory
							, `is_new_item` := @is_new_item
							, `is_item_removed` := @is_item_removed
							, `is_item_moved` := @is_item_moved
							;

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
						SELECT
							`a`.`syst_created_datetime`
							, `a`.`creation_system_id`
							, @creator_mefe_user_id_add_u_l2_1
							, `a`.`creation_method`
							, `a`.`organization_id`
							, `a`.`is_obsolete`
							, `a`.`is_update_needed`
							# Which unit/user
							, `a`.`unee_t_mefe_user_id`
							, `b`.`unee_t_mefe_unit_id`
							# which role
							, @unee_t_role_id_add_u_l2_1
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
							FROM `temp_user_unit_role_permissions_level_3` AS `a`
							INNER JOIN `ut_list_mefe_unit_id_level_3_by_area` AS `b`
								ON (`b`.`level_3_room_id` = `a`.`unee_t_level_3_id`)
						ON DUPLICATE KEY UPDATE
							`syst_updated_datetime` := `a`.`syst_created_datetime`
							, `update_system_id` := `a`.`creation_system_id`
							, `updated_by_id` := @creator_mefe_user_id_add_u_l2_1
							, `update_method` := `a`.`creation_method`
							, `organization_id` := `a`.`organization_id`
							, `is_obsolete` := `a`.`is_obsolete`
							, `is_update_needed` := `a`.`is_update_needed`
							, `unee_t_mefe_id` := @unee_t_mefe_user_id_add_u_l2_1
							, `unee_t_unit_id` := `b`.`unee_t_mefe_unit_id`
							, `unee_t_role_id` := @unee_t_role_id_add_u_l2_1
							, `is_occupant` := @is_occupant
							, `is_default_assignee` := @is_default_assignee
							, `is_default_invited` := @is_default_invited
							, `is_unit_owner` := @is_unit_owner
							, `is_public` := @is_public
							, `can_see_role_landlord` := @can_see_role_landlord
							, `can_see_role_tenant` := @can_see_role_tenant
							, `can_see_role_mgt_cny` := @can_see_role_mgt_cny
							, `can_see_role_agent` := @can_see_role_agent
							, `can_see_role_contractor` := @can_see_role_contractor
							, `can_see_occupant` := @can_see_occupant
							, `is_assigned_to_case` := @is_assigned_to_case
							, `is_invited_to_case` := @is_invited_to_case
							, `is_next_step_updated` := @is_next_step_updated
							, `is_deadline_updated` := @is_deadline_updated
							, `is_solution_updated` := @is_solution_updated
							, `is_case_resolved` := @is_case_resolved
							, `is_case_blocker` := @is_case_blocker
							, `is_case_critical` := @is_case_critical
							, `is_any_new_message` := @is_any_new_message
							, `is_message_from_tenant` := @is_message_from_tenant
							, `is_message_from_ll` := @is_message_from_ll
							, `is_message_from_occupant` := @is_message_from_occupant
							, `is_message_from_agent` := @is_message_from_agent
							, `is_message_from_mgt_cny` := @is_message_from_mgt_cny
							, `is_message_from_contractor` := @is_message_from_contractor
							, `is_new_ir` := @is_new_ir
							, `is_new_item` := @is_new_item
							, `is_item_removed` := @is_item_removed
							, `is_item_moved` := @is_item_moved
							;

		END IF;

	END IF;
END;
$$
DELIMITER ;


#################
#
# This lists all the triggers we use 
# to add a user to a role in a unit
# Level_3 properties
# via the Unee-T Enterprise Interface
#
#################

# This script creates the following triggers:
#	- `ut_add_user_to_role_in_a_level_3_property`
#	- ``

# For properties Level 3 (Rooms)

	DROP TRIGGER IF EXISTS `ut_add_user_to_role_in_a_level_3_property`;

DELIMITER $$
CREATE TRIGGER `ut_add_user_to_role_in_a_level_3_property`
AFTER INSERT ON `external_map_user_unit_role_permissions_level_3`
FOR EACH ROW
BEGIN

# We only do this IF
#	- We have a MEFE user ID for the creator of that record
#	- We have an organization ID
#	- This is not an obsolete request
#	- We have a MEFE user ID for the user that we are adding
#	- We have a role_type
#	- We have a user_type
#	- We have a MEFE unit ID for the level 3 unit.
#	- This is done via an authorized insert method:
#		- 'Assign_Rooms_to_Users_Add_Page'
#		- 'Assign_Rooms_to_Users_Import_Page'
#		- 'imported_from_hmlet_ipi'
#		- ''
#

	SET @source_system_creator_add_u_l3_1 := NEW.`created_by_id` ;
	SET @source_system_updater_add_u_l3_1 := NEW.`updated_by_id`;

	SET @creator_mefe_user_id_add_u_l3_1 := (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator_add_u_l3_1
		)
		;

	SET @organization_id_add_u_l3_1 := NEW.`organization_id` ;

	SET @is_obsolete_id_add_u_l3_1 := NEW.`is_obsolete` ;

	SET @unee_t_level_3_id_add_u_l3_1 := NEW.`unee_t_level_3_id` ;

	SET @unee_t_mefe_user_id_add_u_l3_1 := NEW.`unee_t_mefe_user_id` ;
	SET @unee_t_user_type_id_add_u_l3_1 := NEW.`unee_t_user_type_id` ;
	SET @unee_t_role_id_add_u_l3_1 := NEW.`unee_t_role_id` ;

	SET @unee_t_mefe_unit_id_add_u_l3_1 := (SELECT `unee_t_mefe_unit_id`
		FROM `ut_list_mefe_unit_id_level_3_by_area`
		WHERE `level_3_room_id` = @unee_t_level_3_id_add_u_l3_1
		);

	SET @upstream_create_method_add_u_l3_1 := NEW.`creation_method` ;
	SET @upstream_update_method_add_u_l3_1 := NEW.`update_method` ;

	IF @source_system_creator_add_u_l3_1 IS NOT NULL
		AND @organization_id_add_u_l3_1 IS NOT NULL
		AND @is_obsolete_id_add_u_l3_1 = 0
		AND @unee_t_mefe_user_id_add_u_l3_1 IS NOT NULL
		AND @unee_t_user_type_id_add_u_l3_1 IS NOT NULL
		AND @unee_t_role_id_add_u_l3_1 IS NOT NULL
		AND @unee_t_mefe_unit_id_add_u_l3_1 IS NOT NULL
		AND (@upstream_create_method_add_u_l3_1 = 'Assign_Rooms_to_Users_Add_Page'
			OR @upstream_update_method_add_u_l3_1 = 'Assign_Rooms_to_Users_Add_Page'
			OR @upstream_create_method_add_u_l3_1 = 'Assign_Rooms_to_Users_Import_Page'
			OR @upstream_update_method_add_u_l3_1 = 'Assign_Rooms_to_Users_Import_Page'
			OR @upstream_create_method_add_u_l3_1 = 'imported_from_hmlet_ipi'
			OR @upstream_update_method_add_u_l3_1 = 'imported_from_hmlet_ipi'
			)
	THEN 

	# We capture the variables that we need:

		SET @this_trigger_id_add_u_l3_1 := 'ut_add_user_to_role_in_a_level_3_property' ;

		SET @syst_created_datetime_add_u_l3_1 := NOW() ;
		SET @creation_system_id_add_u_l3_1 := 2 ;
		SET @created_by_id_add_u_l3_1 := @source_system_creator_add_u_l3_1 ;
		SET @creation_method_add_u_l3_1 := @this_trigger_id_add_u_l3_1 ;

		SET @syst_updated_datetime_add_u_l3_1 := NOW() ;
		SET @update_system_id_add_u_l3_1 := 2 ;
		SET @updated_by_id_add_u_l3_1 := @source_system_updater_add_u_l3_1 ;
		SET @update_method_add_u_l3_1 := @this_trigger_id_add_u_l3_1 ;

		SET @is_update_needed_add_u_l3_1 := 1 ;

	# We insert these permissions in the table `ut_map_user_permissions_unit_level_3`
	# We need the values for each of the preferences

		SET @is_occupant := (SELECT `is_occupant` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);

		# additional permissions 
		SET @is_default_assignee := (SELECT `is_default_assignee` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @is_default_invited := (SELECT `is_default_invited` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @is_unit_owner := (SELECT `is_unit_owner` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);

		# Visibility rules 
		SET @is_public := (SELECT `is_public` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @can_see_role_landlord := (SELECT `can_see_role_landlord` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @can_see_role_tenant := (SELECT `can_see_role_tenant` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @can_see_role_mgt_cny := (SELECT `can_see_role_mgt_cny` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @can_see_role_agent := (SELECT `can_see_role_agent` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @can_see_role_contractor := (SELECT `can_see_role_contractor` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @can_see_occupant := (SELECT `can_see_occupant` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);

		# Notification rules 
		# - case - information 
		SET @is_assigned_to_case := (SELECT `is_assigned_to_case` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @is_invited_to_case := (SELECT `is_invited_to_case` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @is_next_step_updated := (SELECT `is_next_step_updated` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @is_deadline_updated := (SELECT `is_deadline_updated` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @is_solution_updated := (SELECT `is_solution_updated` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @is_case_resolved := (SELECT `is_case_resolved` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @is_case_blocker := (SELECT `is_case_blocker` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @is_case_critical := (SELECT `is_case_critical` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);

		# - case - messages 
		SET @is_any_new_message := (SELECT `is_any_new_message` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @is_message_from_tenant := (SELECT `is_message_from_tenant` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @is_message_from_ll := (SELECT `is_message_from_ll` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @is_message_from_occupant := (SELECT `is_message_from_occupant` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @is_message_from_agent := (SELECT `is_message_from_agent` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @is_message_from_mgt_cny := (SELECT `is_message_from_mgt_cny` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @is_message_from_contractor := (SELECT `is_message_from_contractor` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);

		# - Inspection Reports 
		SET @is_new_ir := (SELECT `is_new_ir` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);

		# - Inventory 
		SET @is_new_item := (SELECT `is_new_item` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @is_item_removed := (SELECT `is_item_removed` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
			);
		SET @is_item_moved := (SELECT `is_item_moved` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_add_u_l3_1
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
					(@syst_created_datetime_add_u_l3_1
					, @creation_system_id_add_u_l3_1
					, @creator_mefe_user_id_add_u_l3_1
					, @creation_method_add_u_l3_1
					, @organization_id_add_u_l3_1
					, @is_obsolete_id_add_u_l3_1
					, @is_update_needed_add_u_l3_1
					# Which unit/user
					, @unee_t_mefe_user_id_add_u_l3_1
					, @unee_t_mefe_unit_id_add_u_l3_1
					# which role
					, @unee_t_role_id_add_u_l3_1
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
				ON DUPLICATE KEY UPDATE
					`syst_updated_datetime` := @syst_updated_datetime_add_u_l3_1
					, `update_system_id` := @update_system_id_add_u_l3_1
					, `updated_by_id` := @creator_mefe_user_id_add_u_l3_1
					, `update_method` := @update_method_add_u_l3_1
					, `organization_id` := @organization_id_add_u_l3_1
					, `is_obsolete` := @is_obsolete_add_u_l3_1
					, `is_update_needed` := @is_update_needed_add_u_l3_1
					# Which unit/user
					, `unee_t_mefe_id` := @unee_t_mefe_user_id_add_u_l3_1
					, `unee_t_unit_id` := @unee_t_mefe_unit_id_add_u_l3_1
					# which role
					, `unee_t_role_id` := @unee_t_role_id_add_u_l3_1
					, `is_occupant` := @is_occupant
					# additional permissions
					, `is_default_assignee` := @is_default_assignee
					, `is_default_invited` := @is_default_invited
					, `is_unit_owner` := @is_unit_owner
					# Visibility rules
					, `is_public` := @is_public
					, `can_see_role_landlord` := @can_see_role_landlord
					, `can_see_role_tenant` := @can_see_role_tenant
					, `can_see_role_mgt_cny` := @can_see_role_mgt_cny
					, `can_see_role_agent` := @can_see_role_agent
					, `can_see_role_contractor` := @can_see_role_contractor
					, `can_see_occupant` := @can_see_occupant
					# Notification rules
					# - case - information
					, `is_assigned_to_case` := @is_assigned_to_case
					, `is_invited_to_case` := @is_invited_to_case
					, `is_next_step_updated` := @is_next_step_updated
					, `is_deadline_updated` := @is_deadline_updated
					, `is_solution_updated` := @is_solution_updated
					, `is_case_resolved` := @is_case_resolved
					, `is_case_blocker` := @is_case_blocker
					, `is_case_critical` := @is_case_critical
					# - case - messages
					, `is_any_new_message` := @is_any_new_message
					, `is_message_from_tenant` := @is_message_from_tenant
					, `is_message_from_ll` := @is_message_from_ll
					, `is_message_from_occupant` := @is_message_from_occupant
					, `is_message_from_agent` := @is_message_from_agent
					, `is_message_from_mgt_cny` := @is_message_from_mgt_cny
					, `is_message_from_contractor` := @is_message_from_contractor
					# - Inspection Reports
					, `is_new_ir` := @is_new_ir
					# - Inventory
					, `is_new_item` := @is_new_item
					, `is_item_removed` := @is_item_removed
					, `is_item_moved` := @is_item_moved
					;

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
			VALUES
				(@syst_created_datetime_add_u_l3_1
				, @creation_system_id_add_u_l3_1
				, @creator_mefe_user_id_add_u_l3_1
				, @creation_method_add_u_l3_1
				, @organization_id_add_u_l3_1
				, @is_obsolete
				, @is_update_needed_add_u_l3_1
				# Which unit/user
				, @unee_t_mefe_user_id_add_u_l3_1
				, @unee_t_mefe_unit_id_add_u_l3_1
				# which role
				, @unee_t_role_id_add_u_l3_1
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
			ON DUPLICATE KEY UPDATE
				`syst_updated_datetime` := @syst_updated_datetime_add_u_l3_1
				, `update_system_id` := @update_system_id_add_u_l3_1
				, `updated_by_id` := @creator_mefe_user_id_add_u_l3_1
				, `update_method` := @update_method_add_u_l3_1
				, `organization_id` := @organization_id_add_u_l3_1
				, `is_obsolete` := @is_obsolete
				, `is_update_needed` := 1
				, `unee_t_mefe_id` := @unee_t_mefe_user_id_add_u_l3_1
				, `unee_t_unit_id` := @unee_t_mefe_unit_id_add_u_l3_1
				, `unee_t_role_id` := @unee_t_role_id_add_u_l3_1
				, `is_occupant` := @is_occupant
				, `is_default_assignee` := @is_default_assignee
				, `is_default_invited` := @is_default_invited
				, `is_unit_owner` := @is_unit_owner
				, `is_public` := @is_public
				, `can_see_role_landlord` := @can_see_role_landlord
				, `can_see_role_tenant` := @can_see_role_tenant
				, `can_see_role_mgt_cny` := @can_see_role_mgt_cny
				, `can_see_role_agent` := @can_see_role_agent
				, `can_see_role_contractor` := @can_see_role_contractor
				, `can_see_occupant` := @can_see_occupant
				, `is_assigned_to_case` := @is_assigned_to_case
				, `is_invited_to_case` := @is_invited_to_case
				, `is_next_step_updated` := @is_next_step_updated
				, `is_deadline_updated` := @is_deadline_updated
				, `is_solution_updated` := @is_solution_updated
				, `is_case_resolved` := @is_case_resolved
				, `is_case_blocker` := @is_case_blocker
				, `is_case_critical` := @is_case_critical
				, `is_any_new_message` := @is_any_new_message
				, `is_message_from_tenant` := @is_message_from_tenant
				, `is_message_from_ll` := @is_message_from_ll
				, `is_message_from_occupant` := @is_message_from_occupant
				, `is_message_from_agent` := @is_message_from_agent
				, `is_message_from_mgt_cny` := @is_message_from_mgt_cny
				, `is_message_from_contractor` := @is_message_from_contractor
				, `is_new_ir` := @is_new_ir
				, `is_new_item` := @is_new_item
				, `is_item_removed` := @is_item_removed
				, `is_item_moved` := @is_item_moved
				;

	END IF;
END;
$$
DELIMITER ;



#################
#	
# This is to assign ALL units in an organization to a given user
# This user must have a Unee-T user type which grants access to all units
# in his/her organization.
#
#################

	DROP PROCEDURE IF EXISTS `ut_bulk_assign_units_to_a_user`;
	
DELIMITER $$
CREATE PROCEDURE `ut_bulk_assign_units_to_a_user`()
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN

# This procedure needs the following variables:
#	- @requestor_id
#	- @person_id

	SET @mefe_user_id_assignee_bulk := (SELECT `unee_t_mefe_user_id`
		FROM `ut_map_external_source_users`
		WHERE `person_id` = @person_id
		) 
		;

	SET @person_id_bulk_assign := @person_id ;

	SET @organization_id_bulk_assign := (SELECT `organization_id` 
		FROM `ut_map_external_source_users`
		WHERE `unee_t_mefe_user_id` = @mefe_user_id_assignee_bulk
		)
		;

	SET @unee_t_user_type_id_bulk_assign := (SELECT `unee_t_user_type_id`
		FROM `persons`
		WHERE `id_person` = @person_id_bulk_assign
		);

	SET @is_all_units := (SELECT `is_all_unit`
		FROM `ut_user_types`
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);

	SET @is_all_units_in_country := (SELECT `is_all_units_in_country`
		FROM `ut_user_types`
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);

	SET @person_country := (SELECT `country_code`
		FROM `persons`
		WHERE `id_person` = @person_id_bulk_assign
		);

	SET @created_by_id := @organization_id_bulk_assign ;

	# We get the variables we need:

		SET @syst_created_datetime_bulk_assign := NOW() ;
		SET @creation_system_id_bulk_assign := 2 ;
		SET @created_by_id_bulk_assign := @requestor_id ;
		SET @creation_method_bulk_assign := 'ut_bulk_assign_units_to_a_user' ;

		SET @syst_updated_datetime_bulk_assign := NOW() ;
		SET @update_system_id_bulk_assign := 2 ;
		SET @updated_by_id_bulk_assign := @created_by_id_bulk_assign ;
		SET @update_method_bulk_assign := @creation_method_bulk_assign ;

		SET @is_obsolete_bulk_assign = 0 ;
		SET @is_update_needed_bulk_assign = 1 ;

		SET @unee_t_role_id_bulk_assign := (SELECT `ut_user_role_type_id`
		FROM `ut_user_types`
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);

		SET @is_occupant := (SELECT `is_occupant` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);

		SET @propagate_to_all_level_2 = 1 ;
		SET @propagate_to_all_level_3 = 1 ;

		# additional permissions 
		SET @is_default_assignee := (SELECT `is_default_assignee` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @is_default_invited := (SELECT `is_default_invited` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @is_unit_owner := (SELECT `is_unit_owner` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);

		# Visibility rules 
		SET @is_public := (SELECT `is_public` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @can_see_role_landlord := (SELECT `can_see_role_landlord` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @can_see_role_tenant := (SELECT `can_see_role_tenant` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @can_see_role_mgt_cny := (SELECT `can_see_role_mgt_cny` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @can_see_role_agent := (SELECT `can_see_role_agent` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @can_see_role_contractor := (SELECT `can_see_role_contractor` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @can_see_occupant := (SELECT `can_see_occupant` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);

		# Notification rules 
		# - case - information 
		SET @is_assigned_to_case := (SELECT `is_assigned_to_case` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @is_invited_to_case := (SELECT `is_invited_to_case` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @is_next_step_updated := (SELECT `is_next_step_updated` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @is_deadline_updated := (SELECT `is_deadline_updated` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @is_solution_updated := (SELECT `is_solution_updated` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @is_case_resolved := (SELECT `is_case_resolved` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @is_case_blocker := (SELECT `is_case_blocker` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @is_case_critical := (SELECT `is_case_critical` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);

		# - case - messages 
		SET @is_any_new_message := (SELECT `is_any_new_message` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @is_message_from_tenant := (SELECT `is_message_from_tenant` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @is_message_from_ll := (SELECT `is_message_from_ll` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @is_message_from_occupant := (SELECT `is_message_from_occupant` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @is_message_from_agent := (SELECT `is_message_from_agent` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @is_message_from_mgt_cny := (SELECT `is_message_from_mgt_cny` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @is_message_from_contractor := (SELECT `is_message_from_contractor` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);

		# - Inspection Reports 
		SET @is_new_ir := (SELECT `is_new_ir` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);

		# - Inventory 
		SET @is_new_item := (SELECT `is_new_item` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @is_item_removed := (SELECT `is_item_removed` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);
		SET @is_item_moved := (SELECT `is_item_moved` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_bulk_assign
		);

# If the user needs to be assigned to ALL the units in all the countries in that organization

	IF @is_all_units = 1
		AND @mefe_user_id_assignee_bulk IS NOT NULL
		AND @requestor_id IS NOT NULL
	THEN 

	# Propagate to Level 1 units

		# We create a temporary table to store all the units we need to assign

		DROP TEMPORARY TABLE IF EXISTS `temp_user_unit_role_permissions_level_1`;

		CREATE TEMPORARY TABLE `temp_user_unit_role_permissions_level_1` (
			`id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique ID in this table',
			`syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
			`creation_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'What is the id of the sytem that was used for the creation of the record?',
			`created_by_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
			`created_by_id_associated_mefe_user` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The MEFE user_id associated with this organization',
			`creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
			`organization_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
			`is_obsolete` tinyint(1) DEFAULT 0 COMMENT 'is this obsolete?',
			`is_update_needed` tinyint(1) DEFAULT 0 COMMENT '1 if Unee-T needs to be updated',
			`unee_t_mefe_user_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The current Unee-T profile id of the person - this is the value of the field `_id` in the Mongo Collection `users`',
			`unee_t_level_1_id` int(11) NOT NULL COMMENT 'A FK to the table `property_level_1_buildings`',
			`external_unee_t_level_1_id` int(11) NOT NULL COMMENT '...',
			`unee_t_mefe_unit_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The MEFE unit_id for the property',
			`unee_t_user_type_id` int(11) NOT NULL COMMENT 'A FK to the table `ut_user_types`',
			`unee_t_role_id` mediumint(9) unsigned DEFAULT NULL COMMENT 'FK to the Unee-T BZFE table `ut_role_types` - ID of the Role for this user.',
			PRIMARY KEY (`unee_t_mefe_user_id`,`unee_t_user_type_id`,`unee_t_level_1_id`,`organization_id`),
			UNIQUE KEY `unique_id_map_user_unit_role_permissions_buildings` (`id`)
		) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci
		;

		# We need all the buildings in that organization
		#	- The id of the organization is in the variable @organization_id_bulk_assign
		#	- The ids of the buildings are in the view `ut_list_mefe_unit_id_level_1_by_area`
		# We need to insert all these data in the table `temp_user_unit_role_permissions_level_3`

		SET @created_by_id := @organization_id_bulk_assign ;

		INSERT INTO `temp_user_unit_role_permissions_level_1`
			(`syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `created_by_id_associated_mefe_user`
			, `creation_method`
			, `organization_id`
			, `is_obsolete`
			, `is_update_needed`
			, `unee_t_mefe_user_id`
			, `unee_t_level_1_id`
			, `external_unee_t_level_1_id`
			, `unee_t_mefe_unit_id`
			, `unee_t_user_type_id`
			, `unee_t_role_id`
			)
			SELECT @syst_created_datetime_bulk_assign
			, @creation_system_id_bulk_assign
			, @created_by_id
			, @created_by_id_bulk_assign
			, @creation_method_bulk_assign
			, @organization_id_bulk_assign
			, @is_obsolete_bulk_assign
			, @is_update_needed_bulk_assign
			, @mefe_user_id_assignee_bulk
			, `a`.`level_1_building_id`
			, `a`.`external_level_1_building_id`
			, `a`.`unee_t_mefe_unit_id`
			, @unee_t_user_type_id_bulk_assign
			, @unee_t_role_id_bulk_assign
			FROM `ut_list_mefe_unit_id_level_1_by_area` AS `a`
			WHERE `a`.`organization_id` = @organization_id_bulk_assign
				AND `a`.`is_obsolete` = 0
			GROUP BY `a`.`level_1_building_id`
			;

		# We can now include these into the "external" table for the Level_1 properties (Buildings)

		INSERT INTO `external_map_user_unit_role_permissions_level_1`
			(`syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `creation_method`
			, `organization_id`
			, `is_obsolete`
			, `is_update_needed`
			, `unee_t_mefe_user_id`
			, `unee_t_level_1_id`
			, `unee_t_user_type_id`
			, `unee_t_role_id`
			, `propagate_level_2`
			, `propagate_level_3`
			)
			SELECT 
			`syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `creation_method`
			, `organization_id`
			, `is_obsolete`
			, `is_update_needed`
			, `unee_t_mefe_user_id`
			, `unee_t_level_1_id`
			, `unee_t_user_type_id`
			, `unee_t_role_id`
			, @propagate_to_all_level_2
			, @propagate_to_all_level_3
			FROM `temp_user_unit_role_permissions_level_1` as `a`
			ON DUPLICATE KEY UPDATE
			`syst_updated_datetime` := `a`.`syst_created_datetime`
			, `update_system_id` := `a`.`creation_system_id`
			, `updated_by_id` := `a`.`created_by_id`
			, `update_method` := `a`.`creation_method`
			, `organization_id` := `a`.`organization_id`
			, `is_obsolete` := `a`.`is_obsolete`
			, `is_update_needed` := `a`.`is_update_needed`
			, `unee_t_mefe_user_id` := `a`.`unee_t_mefe_user_id`
			, `unee_t_level_1_id` := `a`.`unee_t_level_1_id`
			, `unee_t_user_type_id` := `a`.`unee_t_user_type_id`
			, `unee_t_role_id` := `a`.`unee_t_role_id`
			, `propagate_level_2`:= @propagate_to_all_level_2
			, `propagate_level_3`:= @propagate_to_all_level_3
			;

		# We can now include these into the table for the Level_1 properties (Building)

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
			`a`.`syst_created_datetime`
			, `a`.`creation_system_id`
			, `a`.`created_by_id_associated_mefe_user`
			, `a`.`creation_method`
			, `a`.`organization_id`
			, `a`.`is_obsolete`
			, `a`.`is_update_needed`
			# Which unit/user
			, `a`.`unee_t_mefe_user_id`
			, `a`.`unee_t_mefe_unit_id`
			# which role
			, `a`.`unee_t_role_id`
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
			, @propagate_to_all_level_2
			, @propagate_to_all_level_3
			FROM `temp_user_unit_role_permissions_level_1` AS `a`
			ON DUPLICATE KEY UPDATE
			`syst_updated_datetime` := `a`.`syst_created_datetime`
			, `update_system_id` := `a`.`creation_system_id`
			, `updated_by_id` := `a`.`created_by_id_associated_mefe_user`
			, `update_method` := `a`.`creation_method`
			, `organization_id` := `a`.`organization_id`
			, `is_obsolete` := `a`.`is_obsolete`
			, `is_update_needed` := `a`.`is_update_needed`
			# Which unit/user
			, `unee_t_mefe_id` :=  `a`.`unee_t_mefe_user_id`
			, `unee_t_unit_id` := `a`.`unee_t_mefe_unit_id`
			# which role
			, `unee_t_role_id` := `a`.`unee_t_role_id`
			# additional permissions
			, `is_occupant` := @is_occupant
			, `is_default_assignee` := @is_default_assignee
			, `is_default_invited` := @is_default_invited
			, `is_unit_owner` := @is_unit_owner
			# Visibility rules
			, `is_public` := @is_public
			, `can_see_role_landlord` := @can_see_role_landlord
			, `can_see_role_tenant` := @can_see_role_tenant
			, `can_see_role_mgt_cny` := @can_see_role_mgt_cny
			, `can_see_role_agent` := @can_see_role_agent
			, `can_see_role_contractor` := @can_see_role_contractor
			, `can_see_occupant` := @can_see_occupant
			# Notification rules
			# - case - information
			, `is_assigned_to_case` := @is_assigned_to_case
			, `is_invited_to_case` := @is_invited_to_case
			, `is_next_step_updated` := @is_next_step_updated
			, `is_deadline_updated` := @is_deadline_updated
			, `is_solution_updated` := @is_solution_updated
			# - case - messages
			, `is_case_resolved` := @is_case_resolved
			, `is_case_blocker` := @is_case_blocker
			, `is_case_critical` := @is_case_critical
			, `is_any_new_message` := @is_any_new_message
			, `is_message_from_tenant` := @is_message_from_tenant
			, `is_message_from_ll` := @is_message_from_ll
			, `is_message_from_occupant` := @is_message_from_occupant
			, `is_message_from_agent` := @is_message_from_agent
			, `is_message_from_mgt_cny` := @is_message_from_mgt_cny
			, `is_message_from_contractor` := @is_message_from_contractor
			# - Inspection Reports
			, `is_new_ir` := @is_new_ir
			# - Inventory
			, `is_new_item` := @is_new_item
			, `is_item_removed` := @is_item_removed
			, `is_item_moved` := @is_item_moved
			, `propagate_to_all_level_2` := @propagate_to_all_level_2
			, `propagate_to_all_level_3` := @propagate_to_all_level_3
			;

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
			, `is_public`
			# Visibility rules
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
			# - case - messages
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
			# - Inspection Reports
			, `is_new_ir`
			# - Inventory
			, `is_new_item`
			, `is_item_removed`
			, `is_item_moved`
			)
			SELECT
			`a`.`syst_created_datetime`
			, `a`.`creation_system_id`
			, `a`.`created_by_id_associated_mefe_user`
			, `a`.`creation_method`
			, `a`.`organization_id`
			, `a`.`is_obsolete`
			, `a`.`is_update_needed`
			# Which unit/user
			, `a`.`unee_t_mefe_user_id`
			, `a`.`unee_t_mefe_unit_id`
			# which role
			, `a`.`unee_t_role_id`
			# additional permissions
			, @is_occupant
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
			FROM `temp_user_unit_role_permissions_level_1` AS `a`
			ON DUPLICATE KEY UPDATE
				`syst_updated_datetime` := `a`.`syst_created_datetime`
				, `update_system_id` := `a`.`creation_system_id`
				, `updated_by_id` := `a`.`created_by_id_associated_mefe_user`
				, `update_method` := `a`.`creation_method`
				, `organization_id` := `a`.`organization_id`
				, `is_obsolete` := `a`.`is_obsolete`
				, `is_update_needed` := `a`.`is_update_needed`
				# Which unit/user
				, `unee_t_mefe_id` = `a`.`unee_t_mefe_user_id`
				, `unee_t_unit_id` := `a`.`unee_t_mefe_unit_id`
				# which role
				, `unee_t_role_id` := `a`.`unee_t_role_id`
				# additional permissions
				, `is_occupant` := @is_occupant
				, `is_default_assignee` := @is_default_assignee
				, `is_default_invited` := @is_default_invited
				, `is_unit_owner` := @is_unit_owner
				, `is_public` := @is_public
				# Visibility rules
				, `can_see_role_landlord` := @can_see_role_landlord
				, `can_see_role_tenant` := @can_see_role_tenant
				, `can_see_role_mgt_cny` := @can_see_role_mgt_cny
				, `can_see_role_agent` := @can_see_role_agent
				, `can_see_role_contractor` := @can_see_role_contractor
				, `can_see_occupant` := @can_see_occupant
				# Notification rules
				# - case - information
				, `is_assigned_to_case` := @is_assigned_to_case
				, `is_invited_to_case` := @is_invited_to_case
				, `is_next_step_updated` := @is_next_step_updated
				, `is_deadline_updated` := @is_deadline_updated
				, `is_solution_updated` := @is_solution_updated
				# - case - messages
				, `is_case_resolved` := @is_case_resolved
				, `is_case_blocker` := @is_case_blocker
				, `is_case_critical` := @is_case_critical
				, `is_any_new_message` := @is_any_new_message
				, `is_message_from_tenant` := @is_message_from_tenant
				, `is_message_from_ll` := @is_message_from_ll
				, `is_message_from_occupant` := @is_message_from_occupant
				, `is_message_from_agent` := @is_message_from_agent
				, `is_message_from_mgt_cny` := @is_message_from_mgt_cny
				, `is_message_from_contractor` := @is_message_from_contractor
				# - Inspection Reports
				, `is_new_ir` := @is_new_ir
				# - Inventory
				, `is_new_item` := @is_new_item
				, `is_item_removed` := @is_item_removed
				, `is_item_moved` := @is_item_moved
				;

	# Propagate to Level 2 units

		# We create a temporary table to store all the units we need to assign

		DROP TEMPORARY TABLE IF EXISTS `temp_user_unit_role_permissions_level_2`;

		CREATE TEMPORARY TABLE `temp_user_unit_role_permissions_level_2` (
			`id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique ID in this table',
			`syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
			`creation_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'What is the id of the sytem that was used for the creation of the record?',
			`created_by_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
			`created_by_id_associated_mefe_user` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The MEFE user_id associated with this organization',
			`creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
			`organization_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
			`is_obsolete` tinyint(1) DEFAULT 0 COMMENT 'is this obsolete?',
			`is_update_needed` tinyint(1) DEFAULT 0 COMMENT '1 if Unee-T needs to be updated',
			`unee_t_mefe_user_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The current Unee-T profile id of the person - this is the value of the field `_id` in the Mongo Collection `users`',
			`unee_t_level_2_id` int(11) NOT NULL COMMENT 'A FK to the table `property_level_2_units`',
			`external_unee_t_level_2_id` int(11) NOT NULL COMMENT 'A FK to the table `property_level_2_units`',
			`unee_t_mefe_unit_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The MEFE unit_id for the property',
			`unee_t_user_type_id` int(11) NOT NULL COMMENT 'A FK to the table `ut_user_types`',
			`unee_t_role_id` mediumint(9) unsigned DEFAULT NULL COMMENT 'FK to the Unee-T BZFE table `ut_role_types` - ID of the Role for this user.',
			PRIMARY KEY (`unee_t_mefe_user_id`,`unee_t_user_type_id`,`unee_t_level_2_id`,`organization_id`),
			UNIQUE KEY `unique_id_map_user_unit_role_permissions_units` (`id`)
		) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci
		;

		# We need all the units from all the buildings in that organization
		#	- The id of the organization is in the variable @organization_id_bulk_assign
		#	- The ids of the units are in the view `ut_list_mefe_unit_id_level_2_by_area`
		# We need to insert all these data in the table `temp_user_unit_role_permissions_level_2`

		SET @created_by_id = @organization_id_bulk_assign ;

		INSERT INTO `temp_user_unit_role_permissions_level_2`
			(`syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `created_by_id_associated_mefe_user`
			, `creation_method`
			, `organization_id`
			, `is_obsolete`
			, `is_update_needed`
			, `unee_t_mefe_user_id`
			, `unee_t_level_2_id`
			, `external_unee_t_level_2_id`
			, `unee_t_mefe_unit_id`
			, `unee_t_user_type_id`
			, `unee_t_role_id`
			)
			SELECT 
			@syst_created_datetime_bulk_assign
			, @creation_system_id_bulk_assign
			, @created_by_id
			, @created_by_id_bulk_assign
			, @creation_method_bulk_assign
			, @organization_id_bulk_assign
			, @is_obsolete_bulk_assign
			, @is_update_needed_bulk_assign
			, @mefe_user_id_assignee_bulk
			, `a`.`level_2_unit_id`
			, `a`.`external_level_2_unit_id`
			, `a`.`unee_t_mefe_unit_id`
			, @unee_t_user_type_id_bulk_assign
			, @unee_t_role_id_bulk_assign
			FROM `ut_list_mefe_unit_id_level_2_by_area` AS `a`
			INNER JOIN `ut_list_mefe_unit_id_level_1_by_area` AS `b`
				ON (`a`.`level_1_building_id` = `b`.`level_1_building_id` )
			WHERE `a`.`organization_id` = @organization_id_bulk_assign
				AND `a`.`is_obsolete` = 0
			GROUP BY `a`.`level_2_unit_id`
			;

		# We insert the data we need in the table `external_map_user_unit_role_permissions_level_2` 

		INSERT INTO `external_map_user_unit_role_permissions_level_2`
			(`syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `creation_method`
			, `organization_id`
			, `is_obsolete`
			, `is_update_needed`
			, `unee_t_mefe_user_id`
			, `unee_t_level_2_id`
			, `unee_t_user_type_id`
			, `unee_t_role_id`
			, `propagate_level_3`
			)
			SELECT 
			`syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `creation_method`
			, `organization_id`
			, `is_obsolete`
			, `is_update_needed`
			, `unee_t_mefe_user_id`
			, `unee_t_level_2_id`
			, `unee_t_user_type_id`
			, `unee_t_role_id`
			, @propagate_to_all_level_3
			FROM `temp_user_unit_role_permissions_level_2` as `a`
			ON DUPLICATE KEY UPDATE
			`syst_updated_datetime` := `a`.`syst_created_datetime`
			, `update_system_id` := `a`.`creation_system_id`
			, `updated_by_id` := `a`.`created_by_id`
			, `update_method` := `a`.`creation_method`
			, `organization_id` := `a`.`organization_id`
			, `is_obsolete` := `a`.`is_obsolete`
			, `is_update_needed` := `a`.`is_update_needed`
			, `unee_t_mefe_user_id` := `a`.`unee_t_mefe_user_id`
			, `unee_t_level_2_id` := `a`.`unee_t_level_2_id`
			, `unee_t_user_type_id` := `a`.`unee_t_user_type_id`
			, `unee_t_role_id` := `a`.`unee_t_role_id`
			, `propagate_level_3`:= @propagate_to_all_level_3
			;

		# We can now include these into the table for the Level_2 properties

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
			)
			SELECT
			`a`.`syst_created_datetime`
			, `a`.`creation_system_id`
			, `a`.`created_by_id_associated_mefe_user`
			, `a`.`creation_method`
			, `a`.`organization_id`
			, `a`.`is_obsolete`
			, `a`.`is_update_needed`
			# Which unit/user
			, `a`.`unee_t_mefe_user_id`
			, `a`.`unee_t_mefe_unit_id`
			# which role
			, `a`.`unee_t_role_id`
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
			FROM `temp_user_unit_role_permissions_level_2` AS `a`
			INNER JOIN `ut_list_mefe_unit_id_level_2_by_area` AS `b`
				ON (`b`.`level_2_unit_id` = `a`.`unee_t_level_2_id`)
			ON DUPLICATE KEY UPDATE
				`syst_updated_datetime` := `a`.`syst_created_datetime`
				, `update_system_id` := `a`.`creation_system_id`
				, `updated_by_id` := `a`.`created_by_id_associated_mefe_user`
				, `update_method` := `a`.`creation_method`
				, `organization_id` := `a`.`organization_id`
				, `is_obsolete` := `a`.`is_obsolete`
				, `is_update_needed` := `a`.`is_update_needed`
				# Which unit/user
				, `unee_t_mefe_id` = `a`.`unee_t_mefe_user_id`
				, `unee_t_unit_id` := `a`.`unee_t_mefe_unit_id`
				# which role
				, `unee_t_role_id` := `a`.`unee_t_role_id`
				# additional permissions
				, `is_occupant` := @is_occupant
				, `is_default_assignee` := @is_default_assignee
				, `is_default_invited` := @is_default_invited
				, `is_unit_owner` := @is_unit_owner
				, `is_public` := @is_public
				# Visibility rules
				, `can_see_role_landlord` := @can_see_role_landlord
				, `can_see_role_tenant` := @can_see_role_tenant
				, `can_see_role_mgt_cny` := @can_see_role_mgt_cny
				, `can_see_role_agent` := @can_see_role_agent
				, `can_see_role_contractor` := @can_see_role_contractor
				, `can_see_occupant` := @can_see_occupant
				# Notification rules
				# - case - information
				, `is_assigned_to_case` := @is_assigned_to_case
				, `is_invited_to_case` := @is_invited_to_case
				, `is_next_step_updated` := @is_next_step_updated
				, `is_deadline_updated` := @is_deadline_updated
				, `is_solution_updated` := @is_solution_updated
				, `is_case_resolved` := @is_case_resolved
				, `is_case_blocker` := @is_case_blocker
				, `is_case_critical` := @is_case_critical
				# - case - messages
				, `is_any_new_message` := @is_any_new_message
				, `is_message_from_tenant` := @is_message_from_tenant
				, `is_message_from_ll` := @is_message_from_ll
				, `is_message_from_occupant` := @is_message_from_occupant
				, `is_message_from_agent` := @is_message_from_agent
				, `is_message_from_mgt_cny` := @is_message_from_mgt_cny
				, `is_message_from_contractor` := @is_message_from_contractor
				# - Inspection Reports
				, `is_new_ir` := @is_new_ir
				# - Inventory
				, `is_new_item` := @is_new_item
				, `is_item_removed` := @is_item_removed
				, `is_item_moved` := @is_item_moved
				;

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
			, `is_public`
			# Visibility rules
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
			# - case - messages
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
			# - Inspection Reports
			, `is_new_ir`
			# - Inventory
			, `is_new_item`
			, `is_item_removed`
			, `is_item_moved`
			)
			SELECT
			`a`.`syst_created_datetime`
			, `a`.`creation_system_id`
			, `a`.`created_by_id_associated_mefe_user`
			, `a`.`creation_method`
			, `a`.`organization_id`
			, `a`.`is_obsolete`
			, `a`.`is_update_needed`
			# Which unit/user
			, `a`.`unee_t_mefe_user_id`
			, `a`.`unee_t_mefe_unit_id`
			# which role
			, `a`.`unee_t_role_id`
			# additional permissions
			, @is_occupant
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
			FROM `temp_user_unit_role_permissions_level_2` AS `a`
			ON DUPLICATE KEY UPDATE
				`syst_updated_datetime` := `a`.`syst_created_datetime`
				, `update_system_id` := `a`.`creation_system_id`
				, `updated_by_id` := `a`.`created_by_id_associated_mefe_user`
				, `update_method` := `a`.`creation_method`
				, `organization_id` := `a`.`organization_id`
				, `is_obsolete` := `a`.`is_obsolete`
				, `is_update_needed` := `a`.`is_update_needed`
				# Which unit/user
				, `unee_t_mefe_id` = `a`.`unee_t_mefe_user_id`
				, `unee_t_unit_id` := `a`.`unee_t_mefe_unit_id`
				# which role
				, `unee_t_role_id` := `a`.`unee_t_role_id`
				# additional permissions
				, `is_occupant` := @is_occupant
				, `is_default_assignee` := @is_default_assignee
				, `is_default_invited` := @is_default_invited
				, `is_unit_owner` := @is_unit_owner
				, `is_public` := @is_public
				# Visibility rules
				, `can_see_role_landlord` := @can_see_role_landlord
				, `can_see_role_tenant` := @can_see_role_tenant
				, `can_see_role_mgt_cny` := @can_see_role_mgt_cny
				, `can_see_role_agent` := @can_see_role_agent
				, `can_see_role_contractor` := @can_see_role_contractor
				, `can_see_occupant` := @can_see_occupant
				# Notification rules
				# - case - information
				, `is_assigned_to_case` := @is_assigned_to_case
				, `is_invited_to_case` := @is_invited_to_case
				, `is_next_step_updated` := @is_next_step_updated
				, `is_deadline_updated` := @is_deadline_updated
				, `is_solution_updated` := @is_solution_updated
				, `is_case_resolved` := @is_case_resolved
				, `is_case_blocker` := @is_case_blocker
				, `is_case_critical` := @is_case_critical
				# - case - messages
				, `is_any_new_message` := @is_any_new_message
				, `is_message_from_tenant` := @is_message_from_tenant
				, `is_message_from_ll` := @is_message_from_ll
				, `is_message_from_occupant` := @is_message_from_occupant
				, `is_message_from_agent` := @is_message_from_agent
				, `is_message_from_mgt_cny` := @is_message_from_mgt_cny
				, `is_message_from_contractor` := @is_message_from_contractor
				# - Inspection Reports
				, `is_new_ir` := @is_new_ir
				# - Inventory
				, `is_new_item` := @is_new_item
				, `is_item_removed` := @is_item_removed
				, `is_item_moved` := @is_item_moved
				;

	# Propagate to Level 3 units

		# We create a temporary table to store all the units we need to assign

		DROP TEMPORARY TABLE IF EXISTS `temp_user_unit_role_permissions_level_3`;

		CREATE TEMPORARY TABLE `temp_user_unit_role_permissions_level_3` (
			`id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique ID in this table',
			`syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
			`creation_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'What is the id of the sytem that was used for the creation of the record?',
			`created_by_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
			`created_by_id_associated_mefe_user` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The MEFE user_id associated with this organization',
			`creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
			`organization_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
			`is_obsolete` tinyint(1) DEFAULT 0 COMMENT 'is this obsolete?',
			`is_update_needed` tinyint(1) DEFAULT 0 COMMENT '1 if Unee-T needs to be updated',
			`unee_t_mefe_user_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The current Unee-T profile id of the person - this is the value of the field `_id` in the Mongo Collection `users`',
			`unee_t_level_3_id` int(11) NOT NULL COMMENT 'A FK to the table `property_level_3_rooms`',
			`external_unee_t_level_3_id` int(11) NOT NULL COMMENT '...',
			`unee_t_mefe_unit_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The MEFE unit_id for the property',
			`unee_t_user_type_id` int(11) NOT NULL COMMENT 'A FK to the table `ut_user_types`',
			`unee_t_role_id` mediumint(9) unsigned DEFAULT NULL COMMENT 'FK to the Unee-T BZFE table `ut_role_types` - ID of the Role for this user.',
			PRIMARY KEY (`unee_t_mefe_user_id`,`unee_t_user_type_id`,`unee_t_level_3_id`,`organization_id`),
			UNIQUE KEY `unique_id_map_user_unit_role_permissions_rooms` (`id`)
		) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci
		;

		# We need all the rooms from all the units in that organization
		#	- The id of the organization is in the variable @organization_id_bulk_assign
		#	- The ids of the rooms are in the view `ut_list_mefe_unit_id_level_3_by_area`
		# We need to insert all these data in the table `temp_user_unit_role_permissions_level_3`

		SET @created_by_id := @organization_id_bulk_assign ;

		INSERT INTO `temp_user_unit_role_permissions_level_3`
			(`syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `created_by_id_associated_mefe_user`
			, `creation_method`
			, `organization_id`
			, `is_obsolete`
			, `is_update_needed`
			, `unee_t_mefe_user_id`
			, `unee_t_level_3_id`
			, `external_unee_t_level_3_id`
			, `unee_t_mefe_unit_id`
			, `unee_t_user_type_id`
			, `unee_t_role_id`
			)
			SELECT 
			@syst_created_datetime_bulk_assign
			, @creation_system_id_bulk_assign
			, @created_by_id
			, @created_by_id_bulk_assign
			, @creation_method_bulk_assign
			, @organization_id_bulk_assign
			, @is_obsolete_bulk_assign
			, @is_update_needed_bulk_assign
			, @mefe_user_id_assignee_bulk
			, `a`.`level_3_room_id`
			, `a`.`external_level_3_room_id`
			, `a`.`unee_t_mefe_unit_id`
			, @unee_t_user_type_id_bulk_assign
			, @unee_t_role_id_bulk_assign
			FROM `ut_list_mefe_unit_id_level_3_by_area` AS `a`
			INNER JOIN `ut_list_mefe_unit_id_level_2_by_area` AS `b`
				ON (`b`.`level_2_unit_id` = `a`.`level_2_unit_id`)
			WHERE `a`.`organization_id` = @organization_id_bulk_assign
				AND `a`.`is_obsolete` = 0
			GROUP BY `a`.`level_3_room_id`
			;

		# We insert the data we need in the table `external_map_user_unit_role_permissions_level_3` 

		INSERT INTO `external_map_user_unit_role_permissions_level_3`
			(`syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `creation_method`
			, `organization_id`
			, `is_obsolete`
			, `is_update_needed`
			, `unee_t_mefe_user_id`
			, `unee_t_level_3_id`
			, `unee_t_user_type_id`
			, `unee_t_role_id`
			)
			SELECT 
			`syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `creation_method`
			, `organization_id`
			, `is_obsolete`
			, `is_update_needed`
			, `unee_t_mefe_user_id`
			, `unee_t_level_3_id`
			, `unee_t_user_type_id`
			, `unee_t_role_id`
			FROM `temp_user_unit_role_permissions_level_3` as `a`
			ON DUPLICATE KEY UPDATE
			`syst_updated_datetime` := `a`.`syst_created_datetime`
			, `update_system_id` := `a`.`creation_system_id`
			, `updated_by_id` := `a`.`created_by_id`
			, `update_method` := `a`.`creation_method`
			, `organization_id` := `a`.`organization_id`
			, `is_obsolete` := `a`.`is_obsolete`
			, `is_update_needed` := `a`.`is_update_needed`
			, `unee_t_mefe_user_id` := `a`.`unee_t_mefe_user_id`
			, `unee_t_level_3_id` := `a`.`unee_t_level_3_id`
			, `unee_t_user_type_id` := `a`.`unee_t_user_type_id`
			, `unee_t_role_id` := `a`.`unee_t_role_id`
			;

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
			SELECT
			`a`.`syst_created_datetime`
			, `a`.`creation_system_id`
			, `a`.`created_by_id_associated_mefe_user`
			, `a`.`creation_method`
			, `a`.`organization_id`
			, `a`.`is_obsolete`
			, `a`.`is_update_needed`
			# Which unit/user
			, `a`.`unee_t_mefe_user_id`
			, `a`.`unee_t_mefe_unit_id`
			# which role
			, `a`.`unee_t_role_id`
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
			FROM `temp_user_unit_role_permissions_level_3` AS `a`
			INNER JOIN `ut_list_mefe_unit_id_level_3_by_area` AS `b`
				ON (`b`.`level_3_room_id` = `a`.`unee_t_level_3_id`)
			ON DUPLICATE KEY UPDATE
				`syst_updated_datetime` := `a`.`syst_created_datetime`
				, `update_system_id` := `a`.`creation_system_id`
				, `updated_by_id` := `a`.`created_by_id_associated_mefe_user`
				, `update_method` := `a`.`creation_method`
				, `organization_id` := `a`.`organization_id`
				, `is_obsolete` := `a`.`is_obsolete`
				, `is_update_needed` := `a`.`is_update_needed`
				# Which unit/user
				, `unee_t_mefe_id` = `a`.`unee_t_mefe_user_id`
				, `unee_t_unit_id` := `a`.`unee_t_mefe_unit_id`
				# which role
				, `unee_t_role_id` := `a`.`unee_t_role_id`
				# additional permissions
				, `is_occupant` := @is_occupant
				, `is_default_assignee` := @is_default_assignee
				, `is_default_invited` := @is_default_invited
				, `is_unit_owner` := @is_unit_owner
				, `is_public` := @is_public
				# Visibility rules
				, `can_see_role_landlord` := @can_see_role_landlord
				, `can_see_role_tenant` := @can_see_role_tenant
				, `can_see_role_mgt_cny` := @can_see_role_mgt_cny
				, `can_see_role_agent` := @can_see_role_agent
				, `can_see_role_contractor` := @can_see_role_contractor
				, `can_see_occupant` := @can_see_occupant
				# Notification rules
				# - case - information
				, `is_assigned_to_case` := @is_assigned_to_case
				, `is_invited_to_case` := @is_invited_to_case
				, `is_next_step_updated` := @is_next_step_updated
				, `is_deadline_updated` := @is_deadline_updated
				, `is_solution_updated` := @is_solution_updated
				, `is_case_resolved` := @is_case_resolved
				, `is_case_blocker` := @is_case_blocker
				, `is_case_critical` := @is_case_critical
				# - case - messages
				, `is_any_new_message` := @is_any_new_message
				, `is_message_from_tenant` := @is_message_from_tenant
				, `is_message_from_ll` := @is_message_from_ll
				, `is_message_from_occupant` := @is_message_from_occupant
				, `is_message_from_agent` := @is_message_from_agent
				, `is_message_from_mgt_cny` := @is_message_from_mgt_cny
				, `is_message_from_contractor` := @is_message_from_contractor
				# - Inspection Reports
				, `is_new_ir` := @is_new_ir
				# - Inventory
				, `is_new_item` := @is_new_item
				, `is_item_removed` := @is_item_removed
				, `is_item_moved` := @is_item_moved
				;

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
			, `is_public`
			# Visibility rules
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
			# - case - messages
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
			# - Inspection Reports
			, `is_new_ir`
			# - Inventory
			, `is_new_item`
			, `is_item_removed`
			, `is_item_moved`
			)
			SELECT
			`a`.`syst_created_datetime`
			, `a`.`creation_system_id`
			, `a`.`created_by_id_associated_mefe_user`
			, `a`.`creation_method`
			, `a`.`organization_id`
			, `a`.`is_obsolete`
			, `a`.`is_update_needed`
			# Which unit/user
			, `a`.`unee_t_mefe_user_id`
			, `a`.`unee_t_mefe_unit_id`
			# which role
			, `a`.`unee_t_role_id`
			# additional permissions
			, @is_occupant
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
			FROM `temp_user_unit_role_permissions_level_3` AS `a`
			ON DUPLICATE KEY UPDATE
				`syst_updated_datetime` := `a`.`syst_created_datetime`
				, `update_system_id` := `a`.`creation_system_id`
				, `updated_by_id` := `a`.`created_by_id_associated_mefe_user`
				, `update_method` := `a`.`creation_method`
				, `organization_id` := `a`.`organization_id`
				, `is_obsolete` := `a`.`is_obsolete`
				, `is_update_needed` := `a`.`is_update_needed`
				# Which unit/user
				, `unee_t_mefe_id` = `a`.`unee_t_mefe_user_id`
				, `unee_t_unit_id` := `a`.`unee_t_mefe_unit_id`
				# which role
				, `unee_t_role_id` := `a`.`unee_t_role_id`
				# additional permissions
				, `is_occupant` := @is_occupant
				, `is_default_assignee` := @is_default_assignee
				, `is_default_invited` := @is_default_invited
				, `is_unit_owner` := @is_unit_owner
				, `is_public` := @is_public
				# Visibility rules
				, `can_see_role_landlord` := @can_see_role_landlord
				, `can_see_role_tenant` := @can_see_role_tenant
				, `can_see_role_mgt_cny` := @can_see_role_mgt_cny
				, `can_see_role_agent` := @can_see_role_agent
				, `can_see_role_contractor` := @can_see_role_contractor
				, `can_see_occupant` := @can_see_occupant
				# Notification rules
				# - case - information
				, `is_assigned_to_case` := @is_assigned_to_case
				, `is_invited_to_case` := @is_invited_to_case
				, `is_next_step_updated` := @is_next_step_updated
				, `is_deadline_updated` := @is_deadline_updated
				, `is_solution_updated` := @is_solution_updated
				, `is_case_resolved` := @is_case_resolved
				, `is_case_blocker` := @is_case_blocker
				, `is_case_critical` := @is_case_critical
				# - case - messages
				, `is_any_new_message` := @is_any_new_message
				, `is_message_from_tenant` := @is_message_from_tenant
				, `is_message_from_ll` := @is_message_from_ll
				, `is_message_from_occupant` := @is_message_from_occupant
				, `is_message_from_agent` := @is_message_from_agent
				, `is_message_from_mgt_cny` := @is_message_from_mgt_cny
				, `is_message_from_contractor` := @is_message_from_contractor
				# - Inspection Reports
				, `is_new_ir` := @is_new_ir
				# - Inventory
				, `is_new_item` := @is_new_item
				, `is_item_removed` := @is_item_removed
				, `is_item_moved` := @is_item_moved
				;

# If the user needs to be assigned to ALL the units in his own country in that organization

	ELSEIF @is_all_units = 0
		AND @is_all_units_in_country = 1
		AND @person_country IS NOT NULL
		AND @created_by_id IS NOT NULL
		AND @mefe_user_id_assignee_bulk IS NOT NULL
		AND @requestor_id IS NOT NULL
	THEN 

	# Propagate to Level 1 units

		# We create a temporary table to store all the units we need to assign

		DROP TEMPORARY TABLE IF EXISTS `temp_user_unit_role_permissions_level_1`;

		CREATE TEMPORARY TABLE `temp_user_unit_role_permissions_level_1` (
			`id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique ID in this table',
			`syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
			`creation_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'What is the id of the sytem that was used for the creation of the record?',
			`created_by_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
			`created_by_id_associated_mefe_user` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The MEFE user_id associated with this organization',
			`creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
			`organization_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
			`country_code` varchar(10) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The 2 letter ISO country code (FR, SG, EN, etc...). See table `property_groups_countries`',
			`is_obsolete` tinyint(1) DEFAULT 0 COMMENT 'is this obsolete?',
			`is_update_needed` tinyint(1) DEFAULT 0 COMMENT '1 if Unee-T needs to be updated',
			`unee_t_mefe_user_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The current Unee-T profile id of the person - this is the value of the field `_id` in the Mongo Collection `users`',
			`unee_t_level_1_id` int(11) NOT NULL COMMENT 'A FK to the table `property_level_1_buildings`',
			`external_unee_t_level_1_id` int(11) NOT NULL COMMENT '...',
			`unee_t_mefe_unit_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The MEFE unit_id for the property',
			`unee_t_user_type_id` int(11) NOT NULL COMMENT 'A FK to the table `ut_user_types`',
			`unee_t_role_id` mediumint(9) unsigned DEFAULT NULL COMMENT 'FK to the Unee-T BZFE table `ut_role_types` - ID of the Role for this user.',
			PRIMARY KEY (`unee_t_mefe_user_id`,`unee_t_user_type_id`,`unee_t_level_1_id`,`organization_id`),
			UNIQUE KEY `unique_id_map_user_unit_role_permissions_buildings` (`id`)
		) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci
		;

		# We need all the buildings in 
		#	- That organization: 
		#	  The id of the organization is in the variable @organization_id_bulk_assign
		#	- That Country
		#	  The id of the country is in the variable @person_country
		#
		#	- The ids of the buildings are in the view `ut_list_mefe_unit_id_level_1_by_area`
		#
		# We need to insert all these data in the table `temp_user_unit_role_permissions_level_1`

		INSERT INTO `temp_user_unit_role_permissions_level_1`
			(`syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `created_by_id_associated_mefe_user`
			, `creation_method`
			, `organization_id`
			, `country_code`
			, `is_obsolete`
			, `is_update_needed`
			, `unee_t_mefe_user_id`
			, `unee_t_level_1_id`
			, `external_unee_t_level_1_id`
			, `unee_t_mefe_unit_id`
			, `unee_t_user_type_id`
			, `unee_t_role_id`
			)
			SELECT @syst_created_datetime_bulk_assign
			, @creation_system_id_bulk_assign
			, @created_by_id
			, @created_by_id_bulk_assign
			, @creation_method_bulk_assign
			, @organization_id_bulk_assign
			, @person_country
			, @is_obsolete_bulk_assign
			, @is_update_needed_bulk_assign
			, @mefe_user_id_assignee_bulk
			, `a`.`level_1_building_id`
			, `a`.`external_level_1_building_id`
			, `a`.`unee_t_mefe_unit_id`
			, @unee_t_user_type_id_bulk_assign
			, @unee_t_role_id_bulk_assign
			FROM `ut_list_mefe_unit_id_level_1_by_area` AS `a`
			WHERE `a`.`organization_id` = @organization_id_bulk_assign
				AND `a`.`country_code` = @person_country
				AND `a`.`is_obsolete` = 0
			GROUP BY `a`.`level_1_building_id`
			;

		# We can now include these into the "external" table for the Level_1 properties (Buildings)

		INSERT INTO `external_map_user_unit_role_permissions_level_1`
			(`syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `creation_method`
			, `organization_id`
			, `is_obsolete`
			, `is_update_needed`
			, `unee_t_mefe_user_id`
			, `unee_t_level_1_id`
			, `unee_t_user_type_id`
			, `unee_t_role_id`
			, `propagate_level_2`
			, `propagate_level_3`
			)
			SELECT 
			`syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `creation_method`
			, `organization_id`
			, `is_obsolete`
			, `is_update_needed`
			, `unee_t_mefe_user_id`
			, `unee_t_level_1_id`
			, `unee_t_user_type_id`
			, `unee_t_role_id`
			, @propagate_to_all_level_2
			, @propagate_to_all_level_3
			FROM `temp_user_unit_role_permissions_level_1` as `a`
			ON DUPLICATE KEY UPDATE
			`syst_updated_datetime` := `a`.`syst_created_datetime`
			, `update_system_id` := `a`.`creation_system_id`
			, `updated_by_id` := `a`.`created_by_id`
			, `update_method` := `a`.`creation_method`
			, `organization_id` := `a`.`organization_id`
			, `is_obsolete` := `a`.`is_obsolete`
			, `is_update_needed` := `a`.`is_update_needed`
			, `unee_t_mefe_user_id` := `a`.`unee_t_mefe_user_id`
			, `unee_t_level_1_id` := `a`.`unee_t_level_1_id`
			, `unee_t_user_type_id` := `a`.`unee_t_user_type_id`
			, `unee_t_role_id` := `a`.`unee_t_role_id`
			, `propagate_level_2`:= @propagate_to_all_level_2
			, `propagate_level_3`:= @propagate_to_all_level_3
			;

		# We can now include these into the table for the Level_1 properties (Building)

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
			`a`.`syst_created_datetime`
			, `a`.`creation_system_id`
			, `a`.`created_by_id_associated_mefe_user`
			, `a`.`creation_method`
			, `a`.`organization_id`
			, `a`.`is_obsolete`
			, `a`.`is_update_needed`
			# Which unit/user
			, `a`.`unee_t_mefe_user_id`
			, `a`.`unee_t_mefe_unit_id`
			# which role
			, `a`.`unee_t_role_id`
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
			, @propagate_to_all_level_2
			, @propagate_to_all_level_3
			FROM `temp_user_unit_role_permissions_level_1` AS `a`
			ON DUPLICATE KEY UPDATE
			`syst_updated_datetime` := `a`.`syst_created_datetime`
			, `update_system_id` := `a`.`creation_system_id`
			, `updated_by_id` := `a`.`created_by_id_associated_mefe_user`
			, `update_method` := `a`.`creation_method`
			, `organization_id` := `a`.`organization_id`
			, `is_obsolete` := `a`.`is_obsolete`
			, `is_update_needed` := `a`.`is_update_needed`
			# Which unit/user
			, `unee_t_mefe_id` :=  `a`.`unee_t_mefe_user_id`
			, `unee_t_unit_id` := `a`.`unee_t_mefe_unit_id`
			# which role
			, `unee_t_role_id` := `a`.`unee_t_role_id`
			# additional permissions
			, `is_occupant` := @is_occupant
			, `is_default_assignee` := @is_default_assignee
			, `is_default_invited` := @is_default_invited
			, `is_unit_owner` := @is_unit_owner
			# Visibility rules
			, `is_public` := @is_public
			, `can_see_role_landlord` := @can_see_role_landlord
			, `can_see_role_tenant` := @can_see_role_tenant
			, `can_see_role_mgt_cny` := @can_see_role_mgt_cny
			, `can_see_role_agent` := @can_see_role_agent
			, `can_see_role_contractor` := @can_see_role_contractor
			, `can_see_occupant` := @can_see_occupant
			# Notification rules
			# - case - information
			, `is_assigned_to_case` := @is_assigned_to_case
			, `is_invited_to_case` := @is_invited_to_case
			, `is_next_step_updated` := @is_next_step_updated
			, `is_deadline_updated` := @is_deadline_updated
			, `is_solution_updated` := @is_solution_updated
			# - case - messages
			, `is_case_resolved` := @is_case_resolved
			, `is_case_blocker` := @is_case_blocker
			, `is_case_critical` := @is_case_critical
			, `is_any_new_message` := @is_any_new_message
			, `is_message_from_tenant` := @is_message_from_tenant
			, `is_message_from_ll` := @is_message_from_ll
			, `is_message_from_occupant` := @is_message_from_occupant
			, `is_message_from_agent` := @is_message_from_agent
			, `is_message_from_mgt_cny` := @is_message_from_mgt_cny
			, `is_message_from_contractor` := @is_message_from_contractor
			# - Inspection Reports
			, `is_new_ir` := @is_new_ir
			# - Inventory
			, `is_new_item` := @is_new_item
			, `is_item_removed` := @is_item_removed
			, `is_item_moved` := @is_item_moved
			, `propagate_to_all_level_2` := @propagate_to_all_level_2
			, `propagate_to_all_level_3` := @propagate_to_all_level_3
			;

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
			, `is_public`
			# Visibility rules
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
			# - case - messages
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
			# - Inspection Reports
			, `is_new_ir`
			# - Inventory
			, `is_new_item`
			, `is_item_removed`
			, `is_item_moved`
			)
			SELECT
			`a`.`syst_created_datetime`
			, `a`.`creation_system_id`
			, `a`.`created_by_id_associated_mefe_user`
			, `a`.`creation_method`
			, `a`.`organization_id`
			, `a`.`is_obsolete`
			, `a`.`is_update_needed`
			# Which unit/user
			, `a`.`unee_t_mefe_user_id`
			, `a`.`unee_t_mefe_unit_id`
			# which role
			, `a`.`unee_t_role_id`
			# additional permissions
			, @is_occupant
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
			FROM `temp_user_unit_role_permissions_level_1` AS `a`
			ON DUPLICATE KEY UPDATE
				`syst_updated_datetime` := `a`.`syst_created_datetime`
				, `update_system_id` := `a`.`creation_system_id`
				, `updated_by_id` := `a`.`created_by_id_associated_mefe_user`
				, `update_method` := `a`.`creation_method`
				, `organization_id` := `a`.`organization_id`
				, `is_obsolete` := `a`.`is_obsolete`
				, `is_update_needed` := `a`.`is_update_needed`
				# Which unit/user
				, `unee_t_mefe_id` = `a`.`unee_t_mefe_user_id`
				, `unee_t_unit_id` := `a`.`unee_t_mefe_unit_id`
				# which role
				, `unee_t_role_id` := `a`.`unee_t_role_id`
				# additional permissions
				, `is_occupant` := @is_occupant
				, `is_default_assignee` := @is_default_assignee
				, `is_default_invited` := @is_default_invited
				, `is_unit_owner` := @is_unit_owner
				, `is_public` := @is_public
				# Visibility rules
				, `can_see_role_landlord` := @can_see_role_landlord
				, `can_see_role_tenant` := @can_see_role_tenant
				, `can_see_role_mgt_cny` := @can_see_role_mgt_cny
				, `can_see_role_agent` := @can_see_role_agent
				, `can_see_role_contractor` := @can_see_role_contractor
				, `can_see_occupant` := @can_see_occupant
				# Notification rules
				# - case - information
				, `is_assigned_to_case` := @is_assigned_to_case
				, `is_invited_to_case` := @is_invited_to_case
				, `is_next_step_updated` := @is_next_step_updated
				, `is_deadline_updated` := @is_deadline_updated
				, `is_solution_updated` := @is_solution_updated
				# - case - messages
				, `is_case_resolved` := @is_case_resolved
				, `is_case_blocker` := @is_case_blocker
				, `is_case_critical` := @is_case_critical
				, `is_any_new_message` := @is_any_new_message
				, `is_message_from_tenant` := @is_message_from_tenant
				, `is_message_from_ll` := @is_message_from_ll
				, `is_message_from_occupant` := @is_message_from_occupant
				, `is_message_from_agent` := @is_message_from_agent
				, `is_message_from_mgt_cny` := @is_message_from_mgt_cny
				, `is_message_from_contractor` := @is_message_from_contractor
				# - Inspection Reports
				, `is_new_ir` := @is_new_ir
				# - Inventory
				, `is_new_item` := @is_new_item
				, `is_item_removed` := @is_item_removed
				, `is_item_moved` := @is_item_moved
				;

	# Propagate to Level 2 units

		# We create a temporary table to store all the units we need to assign

		DROP TEMPORARY TABLE IF EXISTS `temp_user_unit_role_permissions_level_2`;

		CREATE TEMPORARY TABLE `temp_user_unit_role_permissions_level_2` (
			`id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique ID in this table',
			`syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
			`creation_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'What is the id of the sytem that was used for the creation of the record?',
			`created_by_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
			`created_by_id_associated_mefe_user` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The MEFE user_id associated with this organization',
			`creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
			`organization_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
			`country_code` varchar(10) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The 2 letter ISO country code (FR, SG, EN, etc...). See table `property_groups_countries`',
			`is_obsolete` tinyint(1) DEFAULT 0 COMMENT 'is this obsolete?',
			`is_update_needed` tinyint(1) DEFAULT 0 COMMENT '1 if Unee-T needs to be updated',
			`unee_t_mefe_user_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The current Unee-T profile id of the person - this is the value of the field `_id` in the Mongo Collection `users`',
			`unee_t_level_2_id` int(11) NOT NULL COMMENT 'A FK to the table `property_level_2_units`',
			`external_unee_t_level_2_id` int(11) NOT NULL COMMENT 'A FK to the table `property_level_2_units`',
			`unee_t_mefe_unit_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The MEFE unit_id for the property',
			`unee_t_user_type_id` int(11) NOT NULL COMMENT 'A FK to the table `ut_user_types`',
			`unee_t_role_id` mediumint(9) unsigned DEFAULT NULL COMMENT 'FK to the Unee-T BZFE table `ut_role_types` - ID of the Role for this user.',
			PRIMARY KEY (`unee_t_mefe_user_id`,`unee_t_user_type_id`,`unee_t_level_2_id`,`organization_id`),
			UNIQUE KEY `unique_id_map_user_unit_role_permissions_units` (`id`)
		) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci
		;

		# We need all the units in 
		#	- That organization: 
		#	  The id of the organization is in the variable @organization_id_bulk_assign
		#	- That Country
		#	  The id of the country is in the variable @person_country
		#
		#	- The ids of the units are in the view `ut_list_mefe_unit_id_level_2_by_area`
		#
		# We need to insert all these data in the table `temp_user_unit_role_permissions_level_2`

		INSERT INTO `temp_user_unit_role_permissions_level_2`
			(`syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `created_by_id_associated_mefe_user`
			, `creation_method`
			, `organization_id`
			, `country_code`
			, `is_obsolete`
			, `is_update_needed`
			, `unee_t_mefe_user_id`
			, `unee_t_level_2_id`
			, `external_unee_t_level_2_id`
			, `unee_t_mefe_unit_id`
			, `unee_t_user_type_id`
			, `unee_t_role_id`
			)
			SELECT 
			@syst_created_datetime_bulk_assign
			, @creation_system_id_bulk_assign
			, @created_by_id
			, @created_by_id_bulk_assign
			, @creation_method_bulk_assign
			, @organization_id_bulk_assign
			, @person_country
			, @is_obsolete_bulk_assign
			, @is_update_needed_bulk_assign
			, @mefe_user_id_assignee_bulk
			, `a`.`level_2_unit_id`
			, `a`.`external_level_2_unit_id`
			, `a`.`unee_t_mefe_unit_id`
			, @unee_t_user_type_id_bulk_assign
			, @unee_t_role_id_bulk_assign
			FROM `ut_list_mefe_unit_id_level_2_by_area` AS `a`
			INNER JOIN `ut_list_mefe_unit_id_level_1_by_area` AS `b`
				ON (`a`.`level_1_building_id` = `b`.`level_1_building_id` )
			WHERE `a`.`organization_id` = @organization_id_bulk_assign
				AND `a`.`country_code` = @person_country
				AND `a`.`is_obsolete` = 0
			GROUP BY `a`.`level_2_unit_id`
			;

		# We insert the data we need in the table `external_map_user_unit_role_permissions_level_2` 

		INSERT INTO `external_map_user_unit_role_permissions_level_2`
			(`syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `creation_method`
			, `organization_id`
			, `is_obsolete`
			, `is_update_needed`
			, `unee_t_mefe_user_id`
			, `unee_t_level_2_id`
			, `unee_t_user_type_id`
			, `unee_t_role_id`
			, `propagate_level_3`
			)
			SELECT 
			`syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `creation_method`
			, `organization_id`
			, `is_obsolete`
			, `is_update_needed`
			, `unee_t_mefe_user_id`
			, `unee_t_level_2_id`
			, `unee_t_user_type_id`
			, `unee_t_role_id`
			, @propagate_to_all_level_3
			FROM `temp_user_unit_role_permissions_level_2` as `a`
			ON DUPLICATE KEY UPDATE
			`syst_updated_datetime` := `a`.`syst_created_datetime`
			, `update_system_id` := `a`.`creation_system_id`
			, `updated_by_id` := `a`.`created_by_id`
			, `update_method` := `a`.`creation_method`
			, `organization_id` := `a`.`organization_id`
			, `is_obsolete` := `a`.`is_obsolete`
			, `is_update_needed` := `a`.`is_update_needed`
			, `unee_t_mefe_user_id` := `a`.`unee_t_mefe_user_id`
			, `unee_t_level_2_id` := `a`.`unee_t_level_2_id`
			, `unee_t_user_type_id` := `a`.`unee_t_user_type_id`
			, `unee_t_role_id` := `a`.`unee_t_role_id`
			, `propagate_level_3`:= @propagate_to_all_level_3
			;

		# We can now include these into the table for the Level_2 properties

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
			)
			SELECT
			`a`.`syst_created_datetime`
			, `a`.`creation_system_id`
			, `a`.`created_by_id_associated_mefe_user`
			, `a`.`creation_method`
			, `a`.`organization_id`
			, `a`.`is_obsolete`
			, `a`.`is_update_needed`
			# Which unit/user
			, `a`.`unee_t_mefe_user_id`
			, `a`.`unee_t_mefe_unit_id`
			# which role
			, `a`.`unee_t_role_id`
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
			FROM `temp_user_unit_role_permissions_level_2` AS `a`
			INNER JOIN `ut_list_mefe_unit_id_level_2_by_area` AS `b`
				ON (`b`.`level_2_unit_id` = `a`.`unee_t_level_2_id`)
			ON DUPLICATE KEY UPDATE
				`syst_updated_datetime` := `a`.`syst_created_datetime`
				, `update_system_id` := `a`.`creation_system_id`
				, `updated_by_id` := `a`.`created_by_id_associated_mefe_user`
				, `update_method` := `a`.`creation_method`
				, `organization_id` := `a`.`organization_id`
				, `is_obsolete` := `a`.`is_obsolete`
				, `is_update_needed` := `a`.`is_update_needed`
				# Which unit/user
				, `unee_t_mefe_id` = `a`.`unee_t_mefe_user_id`
				, `unee_t_unit_id` := `a`.`unee_t_mefe_unit_id`
				# which role
				, `unee_t_role_id` := `a`.`unee_t_role_id`
				# additional permissions
				, `is_occupant` := @is_occupant
				, `is_default_assignee` := @is_default_assignee
				, `is_default_invited` := @is_default_invited
				, `is_unit_owner` := @is_unit_owner
				, `is_public` := @is_public
				# Visibility rules
				, `can_see_role_landlord` := @can_see_role_landlord
				, `can_see_role_tenant` := @can_see_role_tenant
				, `can_see_role_mgt_cny` := @can_see_role_mgt_cny
				, `can_see_role_agent` := @can_see_role_agent
				, `can_see_role_contractor` := @can_see_role_contractor
				, `can_see_occupant` := @can_see_occupant
				# Notification rules
				# - case - information
				, `is_assigned_to_case` := @is_assigned_to_case
				, `is_invited_to_case` := @is_invited_to_case
				, `is_next_step_updated` := @is_next_step_updated
				, `is_deadline_updated` := @is_deadline_updated
				, `is_solution_updated` := @is_solution_updated
				, `is_case_resolved` := @is_case_resolved
				, `is_case_blocker` := @is_case_blocker
				, `is_case_critical` := @is_case_critical
				# - case - messages
				, `is_any_new_message` := @is_any_new_message
				, `is_message_from_tenant` := @is_message_from_tenant
				, `is_message_from_ll` := @is_message_from_ll
				, `is_message_from_occupant` := @is_message_from_occupant
				, `is_message_from_agent` := @is_message_from_agent
				, `is_message_from_mgt_cny` := @is_message_from_mgt_cny
				, `is_message_from_contractor` := @is_message_from_contractor
				# - Inspection Reports
				, `is_new_ir` := @is_new_ir
				# - Inventory
				, `is_new_item` := @is_new_item
				, `is_item_removed` := @is_item_removed
				, `is_item_moved` := @is_item_moved
				;

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
			, `is_public`
			# Visibility rules
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
			# - case - messages
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
			# - Inspection Reports
			, `is_new_ir`
			# - Inventory
			, `is_new_item`
			, `is_item_removed`
			, `is_item_moved`
			)
			SELECT
			`a`.`syst_created_datetime`
			, `a`.`creation_system_id`
			, `a`.`created_by_id_associated_mefe_user`
			, `a`.`creation_method`
			, `a`.`organization_id`
			, `a`.`is_obsolete`
			, `a`.`is_update_needed`
			# Which unit/user
			, `a`.`unee_t_mefe_user_id`
			, `a`.`unee_t_mefe_unit_id`
			# which role
			, `a`.`unee_t_role_id`
			# additional permissions
			, @is_occupant
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
			FROM `temp_user_unit_role_permissions_level_2` AS `a`
			ON DUPLICATE KEY UPDATE
				`syst_updated_datetime` := `a`.`syst_created_datetime`
				, `update_system_id` := `a`.`creation_system_id`
				, `updated_by_id` := `a`.`created_by_id_associated_mefe_user`
				, `update_method` := `a`.`creation_method`
				, `organization_id` := `a`.`organization_id`
				, `is_obsolete` := `a`.`is_obsolete`
				, `is_update_needed` := `a`.`is_update_needed`
				# Which unit/user
				, `unee_t_mefe_id` = `a`.`unee_t_mefe_user_id`
				, `unee_t_unit_id` := `a`.`unee_t_mefe_unit_id`
				# which role
				, `unee_t_role_id` := `a`.`unee_t_role_id`
				# additional permissions
				, `is_occupant` := @is_occupant
				, `is_default_assignee` := @is_default_assignee
				, `is_default_invited` := @is_default_invited
				, `is_unit_owner` := @is_unit_owner
				, `is_public` := @is_public
				# Visibility rules
				, `can_see_role_landlord` := @can_see_role_landlord
				, `can_see_role_tenant` := @can_see_role_tenant
				, `can_see_role_mgt_cny` := @can_see_role_mgt_cny
				, `can_see_role_agent` := @can_see_role_agent
				, `can_see_role_contractor` := @can_see_role_contractor
				, `can_see_occupant` := @can_see_occupant
				# Notification rules
				# - case - information
				, `is_assigned_to_case` := @is_assigned_to_case
				, `is_invited_to_case` := @is_invited_to_case
				, `is_next_step_updated` := @is_next_step_updated
				, `is_deadline_updated` := @is_deadline_updated
				, `is_solution_updated` := @is_solution_updated
				, `is_case_resolved` := @is_case_resolved
				, `is_case_blocker` := @is_case_blocker
				, `is_case_critical` := @is_case_critical
				# - case - messages
				, `is_any_new_message` := @is_any_new_message
				, `is_message_from_tenant` := @is_message_from_tenant
				, `is_message_from_ll` := @is_message_from_ll
				, `is_message_from_occupant` := @is_message_from_occupant
				, `is_message_from_agent` := @is_message_from_agent
				, `is_message_from_mgt_cny` := @is_message_from_mgt_cny
				, `is_message_from_contractor` := @is_message_from_contractor
				# - Inspection Reports
				, `is_new_ir` := @is_new_ir
				# - Inventory
				, `is_new_item` := @is_new_item
				, `is_item_removed` := @is_item_removed
				, `is_item_moved` := @is_item_moved
				;

	# Propagate to Level 3 units

		# We create a temporary table to store all the units we need to assign

		DROP TEMPORARY TABLE IF EXISTS `temp_user_unit_role_permissions_level_3`;

		CREATE TEMPORARY TABLE `temp_user_unit_role_permissions_level_3` (
			`id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique ID in this table',
			`syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
			`creation_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'What is the id of the sytem that was used for the creation of the record?',
			`created_by_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
			`created_by_id_associated_mefe_user` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The MEFE user_id associated with this organization',
			`creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
			`organization_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
			`country_code` varchar(10) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The 2 letter ISO country code (FR, SG, EN, etc...). See table `property_groups_countries`',
			`is_obsolete` tinyint(1) DEFAULT 0 COMMENT 'is this obsolete?',
			`is_update_needed` tinyint(1) DEFAULT 0 COMMENT '1 if Unee-T needs to be updated',
			`unee_t_mefe_user_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The current Unee-T profile id of the person - this is the value of the field `_id` in the Mongo Collection `users`',
			`unee_t_level_3_id` int(11) NOT NULL COMMENT 'A FK to the table `property_level_3_rooms`',
			`external_unee_t_level_3_id` int(11) NOT NULL COMMENT '...',
			`unee_t_mefe_unit_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The MEFE unit_id for the property',
			`unee_t_user_type_id` int(11) NOT NULL COMMENT 'A FK to the table `ut_user_types`',
			`unee_t_role_id` mediumint(9) unsigned DEFAULT NULL COMMENT 'FK to the Unee-T BZFE table `ut_role_types` - ID of the Role for this user.',
			PRIMARY KEY (`unee_t_mefe_user_id`,`unee_t_user_type_id`,`unee_t_level_3_id`,`organization_id`),
			UNIQUE KEY `unique_id_map_user_unit_role_permissions_rooms` (`id`)
		) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci
		;

		# We need all the rooms in 
		#	- That organization: 
		#	  The id of the organization is in the variable @organization_id_bulk_assign
		#	- That Country
		#	  The id of the country is in the variable @person_country
		#
		#	- The ids of the rooms are in the view `ut_list_mefe_unit_id_level_3_by_area`
		#
		# We need to insert all these data in the table `temp_user_unit_role_permissions_level_3`

		INSERT INTO `temp_user_unit_role_permissions_level_3`
			(`syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `created_by_id_associated_mefe_user`
			, `creation_method`
			, `organization_id`
			, `country_code`
			, `is_obsolete`
			, `is_update_needed`
			, `unee_t_mefe_user_id`
			, `unee_t_level_3_id`
			, `external_unee_t_level_3_id`
			, `unee_t_mefe_unit_id`
			, `unee_t_user_type_id`
			, `unee_t_role_id`
			)
			SELECT 
			@syst_created_datetime_bulk_assign
			, @creation_system_id_bulk_assign
			, @created_by_id
			, @created_by_id_bulk_assign
			, @creation_method_bulk_assign
			, @organization_id_bulk_assign
			, @person_country
			, @is_obsolete_bulk_assign
			, @is_update_needed_bulk_assign
			, @mefe_user_id_assignee_bulk
			, `a`.`level_3_room_id`
			, `a`.`external_level_3_room_id`
			, `a`.`unee_t_mefe_unit_id`
			, @unee_t_user_type_id_bulk_assign
			, @unee_t_role_id_bulk_assign
			FROM `ut_list_mefe_unit_id_level_3_by_area` AS `a`
			INNER JOIN `ut_list_mefe_unit_id_level_2_by_area` AS `b`
				ON (`b`.`level_2_unit_id` = `a`.`level_2_unit_id`)
			WHERE `a`.`organization_id` = @organization_id_bulk_assign
				AND `a`.`country_code` = @person_country
				AND `a`.`is_obsolete` = 0
			GROUP BY `a`.`level_3_room_id`
			;

		# We insert the data we need in the table `external_map_user_unit_role_permissions_level_3` 

		INSERT INTO `external_map_user_unit_role_permissions_level_3`
			(`syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `creation_method`
			, `organization_id`
			, `is_obsolete`
			, `is_update_needed`
			, `unee_t_mefe_user_id`
			, `unee_t_level_3_id`
			, `unee_t_user_type_id`
			, `unee_t_role_id`
			)
			SELECT 
			`syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `creation_method`
			, `organization_id`
			, `is_obsolete`
			, `is_update_needed`
			, `unee_t_mefe_user_id`
			, `unee_t_level_3_id`
			, `unee_t_user_type_id`
			, `unee_t_role_id`
			FROM `temp_user_unit_role_permissions_level_3` as `a`
			ON DUPLICATE KEY UPDATE
			`syst_updated_datetime` := `a`.`syst_created_datetime`
			, `update_system_id` := `a`.`creation_system_id`
			, `updated_by_id` := `a`.`created_by_id`
			, `update_method` := `a`.`creation_method`
			, `organization_id` := `a`.`organization_id`
			, `is_obsolete` := `a`.`is_obsolete`
			, `is_update_needed` := `a`.`is_update_needed`
			, `unee_t_mefe_user_id` := `a`.`unee_t_mefe_user_id`
			, `unee_t_level_3_id` := `a`.`unee_t_level_3_id`
			, `unee_t_user_type_id` := `a`.`unee_t_user_type_id`
			, `unee_t_role_id` := `a`.`unee_t_role_id`
			;

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
			SELECT
			`a`.`syst_created_datetime`
			, `a`.`creation_system_id`
			, `a`.`created_by_id_associated_mefe_user`
			, `a`.`creation_method`
			, `a`.`organization_id`
			, `a`.`is_obsolete`
			, `a`.`is_update_needed`
			# Which unit/user
			, `a`.`unee_t_mefe_user_id`
			, `a`.`unee_t_mefe_unit_id`
			# which role
			, `a`.`unee_t_role_id`
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
			FROM `temp_user_unit_role_permissions_level_3` AS `a`
			INNER JOIN `ut_list_mefe_unit_id_level_3_by_area` AS `b`
				ON (`b`.`level_3_room_id` = `a`.`unee_t_level_3_id`)
			ON DUPLICATE KEY UPDATE
				`syst_updated_datetime` := `a`.`syst_created_datetime`
				, `update_system_id` := `a`.`creation_system_id`
				, `updated_by_id` := `a`.`created_by_id_associated_mefe_user`
				, `update_method` := `a`.`creation_method`
				, `organization_id` := `a`.`organization_id`
				, `is_obsolete` := `a`.`is_obsolete`
				, `is_update_needed` := `a`.`is_update_needed`
				# Which unit/user
				, `unee_t_mefe_id` = `a`.`unee_t_mefe_user_id`
				, `unee_t_unit_id` := `a`.`unee_t_mefe_unit_id`
				# which role
				, `unee_t_role_id` := `a`.`unee_t_role_id`
				# additional permissions
				, `is_occupant` := @is_occupant
				, `is_default_assignee` := @is_default_assignee
				, `is_default_invited` := @is_default_invited
				, `is_unit_owner` := @is_unit_owner
				, `is_public` := @is_public
				# Visibility rules
				, `can_see_role_landlord` := @can_see_role_landlord
				, `can_see_role_tenant` := @can_see_role_tenant
				, `can_see_role_mgt_cny` := @can_see_role_mgt_cny
				, `can_see_role_agent` := @can_see_role_agent
				, `can_see_role_contractor` := @can_see_role_contractor
				, `can_see_occupant` := @can_see_occupant
				# Notification rules
				# - case - information
				, `is_assigned_to_case` := @is_assigned_to_case
				, `is_invited_to_case` := @is_invited_to_case
				, `is_next_step_updated` := @is_next_step_updated
				, `is_deadline_updated` := @is_deadline_updated
				, `is_solution_updated` := @is_solution_updated
				, `is_case_resolved` := @is_case_resolved
				, `is_case_blocker` := @is_case_blocker
				, `is_case_critical` := @is_case_critical
				# - case - messages
				, `is_any_new_message` := @is_any_new_message
				, `is_message_from_tenant` := @is_message_from_tenant
				, `is_message_from_ll` := @is_message_from_ll
				, `is_message_from_occupant` := @is_message_from_occupant
				, `is_message_from_agent` := @is_message_from_agent
				, `is_message_from_mgt_cny` := @is_message_from_mgt_cny
				, `is_message_from_contractor` := @is_message_from_contractor
				# - Inspection Reports
				, `is_new_ir` := @is_new_ir
				# - Inventory
				, `is_new_item` := @is_new_item
				, `is_item_removed` := @is_item_removed
				, `is_item_moved` := @is_item_moved
				;

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
			, `is_public`
			# Visibility rules
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
			# - case - messages
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
			# - Inspection Reports
			, `is_new_ir`
			# - Inventory
			, `is_new_item`
			, `is_item_removed`
			, `is_item_moved`
			)
			SELECT
			`a`.`syst_created_datetime`
			, `a`.`creation_system_id`
			, `a`.`created_by_id_associated_mefe_user`
			, `a`.`creation_method`
			, `a`.`organization_id`
			, `a`.`is_obsolete`
			, `a`.`is_update_needed`
			# Which unit/user
			, `a`.`unee_t_mefe_user_id`
			, `a`.`unee_t_mefe_unit_id`
			# which role
			, `a`.`unee_t_role_id`
			# additional permissions
			, @is_occupant
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
			FROM `temp_user_unit_role_permissions_level_3` AS `a`
			ON DUPLICATE KEY UPDATE
				`syst_updated_datetime` := `a`.`syst_created_datetime`
				, `update_system_id` := `a`.`creation_system_id`
				, `updated_by_id` := `a`.`created_by_id_associated_mefe_user`
				, `update_method` := `a`.`creation_method`
				, `organization_id` := `a`.`organization_id`
				, `is_obsolete` := `a`.`is_obsolete`
				, `is_update_needed` := `a`.`is_update_needed`
				# Which unit/user
				, `unee_t_mefe_id` = `a`.`unee_t_mefe_user_id`
				, `unee_t_unit_id` := `a`.`unee_t_mefe_unit_id`
				# which role
				, `unee_t_role_id` := `a`.`unee_t_role_id`
				# additional permissions
				, `is_occupant` := @is_occupant
				, `is_default_assignee` := @is_default_assignee
				, `is_default_invited` := @is_default_invited
				, `is_unit_owner` := @is_unit_owner
				, `is_public` := @is_public
				# Visibility rules
				, `can_see_role_landlord` := @can_see_role_landlord
				, `can_see_role_tenant` := @can_see_role_tenant
				, `can_see_role_mgt_cny` := @can_see_role_mgt_cny
				, `can_see_role_agent` := @can_see_role_agent
				, `can_see_role_contractor` := @can_see_role_contractor
				, `can_see_occupant` := @can_see_occupant
				# Notification rules
				# - case - information
				, `is_assigned_to_case` := @is_assigned_to_case
				, `is_invited_to_case` := @is_invited_to_case
				, `is_next_step_updated` := @is_next_step_updated
				, `is_deadline_updated` := @is_deadline_updated
				, `is_solution_updated` := @is_solution_updated
				, `is_case_resolved` := @is_case_resolved
				, `is_case_blocker` := @is_case_blocker
				, `is_case_critical` := @is_case_critical
				# - case - messages
				, `is_any_new_message` := @is_any_new_message
				, `is_message_from_tenant` := @is_message_from_tenant
				, `is_message_from_ll` := @is_message_from_ll
				, `is_message_from_occupant` := @is_message_from_occupant
				, `is_message_from_agent` := @is_message_from_agent
				, `is_message_from_mgt_cny` := @is_message_from_mgt_cny
				, `is_message_from_contractor` := @is_message_from_contractor
				# - Inspection Reports
				, `is_new_ir` := @is_new_ir
				# - Inventory
				, `is_new_item` := @is_new_item
				, `is_item_removed` := @is_item_removed
				, `is_item_moved` := @is_item_moved
				;

	END IF;

END $$
DELIMITER ;



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

	SET @unee_t_mefe_unit_id_trig_auto_assign_1 := NEW.`unee_t_mefe_unit_id` ;
	SET @upstream_update_method_trig_auto_assign_1 := NEW.`update_method` ;

	SET @requestor_id_trig_auto_assign_1 := NEW.`updated_by_id` ;

	SET @created_by_id_trig_auto_assign_1 := (SELECT `organization_id`
		FROM `ut_api_keys`
		WHERE `mefe_user_id` = @requestor_id_trig_auto_assign_1
		);

	IF @requestor_id_trig_auto_assign_1 IS NOT NULL
		AND @unee_t_mefe_unit_id_trig_auto_assign_1 IS NOT NULL
		AND @upstream_update_method_trig_auto_assign_1 = 'ut_creation_unit_mefe_api_reply'
	THEN 

	# We need to list all the users that we should assign to this new property:
	# These users are users who need to be assigned to:
	#	- All the properties in the organization
	#	- All the properties in the country where this property is
	#	- All the properties in the Area where this property is

		SET @external_property_type_id_trig_auto_assign_1 := NEW.`external_property_type_id` ;

		SET @property_id_trig_auto_assign_1 := NEW.`new_record_id` ;

		SET @organization_id_trig_auto_assign_1 := NEW.`organization_id` ;

	# What is the country for that property

		SET @property_country_code_trig_auto_assign_1 := (IF (@external_property_type_id_trig_auto_assign_1 = 1
				, (SELECT `country_code`
					FROM `ut_list_mefe_unit_id_level_1_by_area`
					WHERE `level_1_building_id` = @property_id_trig_auto_assign_1
					)
				, IF (@external_property_type_id_trig_auto_assign_1 = 2
					, (SELECT `country_code`
						FROM `ut_list_mefe_unit_id_level_2_by_area`
						WHERE `level_2_unit_id` = @property_id_trig_auto_assign_1
						)
					, IF (@external_property_type_id_trig_auto_assign_1 = 3
						, (SELECT `country_code`
							FROM `ut_list_mefe_unit_id_level_3_by_area`
							WHERE `level_3_room_id` = @property_id_trig_auto_assign_1
							)
						, 'error - 1308'
						)
					)
				)
			);

	# We get the other variables we need:

		SET @syst_created_datetime_trig_auto_assign_1 := NOW() ;
		SET @creation_system_id_trig_auto_assign_1 := 2 ;
		SET @creation_method_trig_auto_assign_1 := 'ut_update_mefe_unit_id_assign_users_to_property' ;

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
			@syst_created_datetime_trig_auto_assign_1
			, @creation_system_id_trig_auto_assign_1
			, @requestor_id_trig_auto_assign_1
			, @created_by_id_trig_auto_assign_1
			, @creation_method_trig_auto_assign_1
			, @organization_id_trig_auto_assign_1
			, `a`.`mefe_user_id`
			, `a`.`email`
			, `a`.`unee_t_user_type_id`
			, @unee_t_mefe_unit_id_trig_auto_assign_1
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
					`a`.`organization_id` = @organization_id_trig_auto_assign_1
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
				@syst_created_datetime_trig_auto_assign_1
				, @creation_system_id_trig_auto_assign_1
				, @requestor_id_trig_auto_assign_1
				, @created_by_id_trig_auto_assign_1
				, @creation_method_trig_auto_assign_1
				, @organization_id_trig_auto_assign_1
				, `a`.`country_code`
				, `a`.`mefe_user_id`
				, `a`.`email`
				, `a`.`unee_t_user_type_id`
				, @unee_t_mefe_unit_id_trig_auto_assign_1
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
						`a`.`organization_id` = @organization_id_trig_auto_assign_1
						AND `a`.`country_code` = @property_country_code_trig_auto_assign_1
						AND `a`.`is_all_units_in_country` = 1
				;

	# We assign the user to the unit

		# For Level 1 Properties, this is done in the table 
		# `external_map_user_unit_role_permissions_level_1`

			SET @propagate_to_all_level_2_trig_auto_assign_1 := 1 ;
			SET @propagate_to_all_level_3_trig_auto_assign_1 := 1;

			SET @is_obsolete_trig_auto_assign_1 := 0 ;
			SET @is_update_needed_trig_auto_assign_1 := 1 ;

			IF @external_property_type_id_trig_auto_assign_1 = 1
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
						@syst_created_datetime_trig_auto_assign_1
						, @creation_system_id_trig_auto_assign_1
						, @created_by_id_trig_auto_assign_1
						, @creation_method_trig_auto_assign_1
						, @organization_id_trig_auto_assign_1
						, @is_obsolete_trig_auto_assign_1
						, @is_update_needed_trig_auto_assign_1
						# Which unit/user
						, `a`.`mefe_user_id`
						, @property_id_trig_auto_assign_1
						, `a`.`unee_t_user_type_id`
						, @propagate_to_all_level_2_trig_auto_assign_1
						, @propagate_to_all_level_3_trig_auto_assign_1
					FROM `temp_list_users_auto_assign_new_property` AS `a`
						ON DUPLICATE KEY UPDATE
							`syst_updated_datetime` := @syst_created_datetime_trig_auto_assign_1
							, `update_system_id` := @creation_system_id_trig_auto_assign_1
							, `updated_by_id` := @created_by_id_trig_auto_assign_1
							, `update_method` := @creation_method_trig_auto_assign_1
							, `organization_id` := @organization_id_trig_auto_assign_1
							, `is_obsolete` := @is_obsolete_trig_auto_assign_1
							, `is_update_needed` := @is_update_needed_trig_auto_assign_1
							# Which unit/user
							, `unee_t_mefe_user_id` := `a`.`mefe_user_id`
							, `unee_t_level_1_id` := @property_id_trig_auto_assign_1
							, `unee_t_user_type_id` := `a`.`unee_t_user_type_id`
							, `propagate_level_2`:= @propagate_to_all_level_2_trig_auto_assign_1
							, `propagate_level_3` := @propagate_to_all_level_3_trig_auto_assign_1
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
							@syst_created_datetime_trig_auto_assign_1
							, @creation_system_id_trig_auto_assign_1
							, @requestor_id_trig_auto_assign_1
							, @creation_method_trig_auto_assign_1
							, @organization_id_trig_auto_assign_1
							, @is_obsolete_trig_auto_assign_1
							, @is_update_needed_trig_auto_assign_1
							# Which unit/user
							, `a`.`mefe_user_id`
							, @unee_t_mefe_unit_id_trig_auto_assign_1
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
							, @propagate_to_all_level_2_trig_auto_assign_1
							, @propagate_to_all_level_3_trig_auto_assign_1
							FROM `temp_list_users_auto_assign_new_property` AS `a`
							ON DUPLICATE KEY UPDATE
								`syst_updated_datetime` := @syst_created_datetime_trig_auto_assign_1
								, `update_system_id` := @creation_system_id_trig_auto_assign_1
								, `updated_by_id` := @requestor_id_trig_auto_assign_1
								, `update_method` := @creation_method_trig_auto_assign_1
								, `organization_id` := @organization_id_trig_auto_assign_1
								, `is_obsolete` := @is_obsolete_trig_auto_assign_1
								, `is_update_needed` := @is_update_needed_trig_auto_assign_1
								# Which unit/user
								, `unee_t_mefe_id` := `a`.`mefe_user_id`
								, `unee_t_unit_id` := @unee_t_mefe_unit_id_trig_auto_assign_1
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
								, `propagate_to_all_level_2` = @propagate_to_all_level_2_trig_auto_assign_1
								, `propagate_to_all_level_3` = @propagate_to_all_level_3_trig_auto_assign_1
								;

			ELSEIF @external_property_type_id_trig_auto_assign_1 = 2
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
						@syst_created_datetime_trig_auto_assign_1
						, @creation_system_id_trig_auto_assign_1
						, @created_by_id_trig_auto_assign_1
						, @creation_method_trig_auto_assign_1
						, @organization_id_trig_auto_assign_1
						, @is_obsolete_trig_auto_assign_1
						, @is_update_needed_trig_auto_assign_1
						# Which unit/user
						, `a`.`mefe_user_id`
						, @property_id_trig_auto_assign_1
						, `a`.`unee_t_user_type_id`
						, @propagate_to_all_level_3_trig_auto_assign_1
					FROM `temp_list_users_auto_assign_new_property` AS `a`
						ON DUPLICATE KEY UPDATE
							`syst_updated_datetime` := @syst_created_datetime_trig_auto_assign_1
							, `update_system_id` := @creation_system_id_trig_auto_assign_1
							, `updated_by_id` := @created_by_id_trig_auto_assign_1
							, `update_method` := @creation_method_trig_auto_assign_1
							, `organization_id` := @organization_id_trig_auto_assign_1
							, `is_obsolete` := @is_obsolete_trig_auto_assign_1
							, `is_update_needed` := @is_update_needed_trig_auto_assign_1
							# Which unit/user
							, `unee_t_mefe_user_id` := `a`.`mefe_user_id`
							, `unee_t_level_2_id` := @property_id_trig_auto_assign_1
							, `unee_t_user_type_id` := `a`.`unee_t_user_type_id`
							, `propagate_level_3` := @propagate_to_all_level_3_trig_auto_assign_1
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
							@syst_created_datetime_trig_auto_assign_1
							, @creation_system_id_trig_auto_assign_1
							, @requestor_id_trig_auto_assign_1
							, @creation_method_trig_auto_assign_1
							, @organization_id_trig_auto_assign_1
							, @is_obsolete_trig_auto_assign_1
							, @is_update_needed_trig_auto_assign_1
							# Which unit/user
							, `a`.`mefe_user_id`
							, @unee_t_mefe_unit_id_trig_auto_assign_1
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
							, @propagate_to_all_level_3_trig_auto_assign_1
							FROM `temp_list_users_auto_assign_new_property` AS `a`
							ON DUPLICATE KEY UPDATE
								`syst_updated_datetime` := @syst_created_datetime_trig_auto_assign_1
								, `update_system_id` := @creation_system_id_trig_auto_assign_1
								, `updated_by_id` := @requestor_id_trig_auto_assign_1
								, `update_method` := @creation_method_trig_auto_assign_1
								, `organization_id` := @organization_id_trig_auto_assign_1
								, `is_obsolete` := @is_obsolete_trig_auto_assign_1
								, `is_update_needed` := @is_update_needed_trig_auto_assign_1
								# Which unit/user
								, `unee_t_mefe_id` := `a`.`mefe_user_id`
								, `unee_t_unit_id` := @unee_t_mefe_unit_id_trig_auto_assign_1
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
								, `propagate_to_all_level_3` = @propagate_to_all_level_3_trig_auto_assign_1
								;

			ELSEIF @external_property_type_id_trig_auto_assign_1 = 3
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
						@syst_created_datetime_trig_auto_assign_1
						, @creation_system_id_trig_auto_assign_1
						, @created_by_id_trig_auto_assign_1
						, @creation_method_trig_auto_assign_1
						, @organization_id_trig_auto_assign_1
						, @is_obsolete_trig_auto_assign_1
						, @is_update_needed_trig_auto_assign_1
						# Which unit/user
						, `a`.`mefe_user_id`
						, @property_id_trig_auto_assign_1
						, `a`.`unee_t_user_type_id`
					FROM `temp_list_users_auto_assign_new_property` AS `a`
						ON DUPLICATE KEY UPDATE
							`syst_updated_datetime` := @syst_created_datetime_trig_auto_assign_1
							, `update_system_id` := @creation_system_id_trig_auto_assign_1
							, `updated_by_id` := @created_by_id_trig_auto_assign_1
							, `update_method` := @creation_method_trig_auto_assign_1
							, `organization_id` := @organization_id_trig_auto_assign_1
							, `is_obsolete` := @is_obsolete_trig_auto_assign_1
							, `is_update_needed` := @is_update_needed_trig_auto_assign_1
							# Which unit/user
							, `unee_t_mefe_user_id` := `a`.`mefe_user_id`
							, `unee_t_level_3_id` := @property_id_trig_auto_assign_1
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
							@syst_created_datetime_trig_auto_assign_1
							, @creation_system_id_trig_auto_assign_1
							, @requestor_id_trig_auto_assign_1
							, @creation_method_trig_auto_assign_1
							, @organization_id_trig_auto_assign_1
							, @is_obsolete_trig_auto_assign_1
							, @is_update_needed_trig_auto_assign_1
							# Which unit/user
							, `a`.`mefe_user_id`
							, @unee_t_mefe_unit_id_trig_auto_assign_1
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
								`syst_updated_datetime` := @syst_created_datetime_trig_auto_assign_1
								, `update_system_id` := @creation_system_id_trig_auto_assign_1
								, `updated_by_id` := @requestor_id_trig_auto_assign_1
								, `update_method` := @creation_method_trig_auto_assign_1
								, `organization_id` := @organization_id_trig_auto_assign_1
								, `is_obsolete` := @is_obsolete_trig_auto_assign_1
								, `is_update_needed` := @is_update_needed_trig_auto_assign_1
								# Which unit/user
								, `unee_t_mefe_id` := `a`.`mefe_user_id`
								, `unee_t_unit_id` := @unee_t_mefe_unit_id_trig_auto_assign_1
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
					@syst_created_datetime_trig_auto_assign_1
					, @creation_system_id_trig_auto_assign_1
					, @requestor_id_trig_auto_assign_1
					, @creation_method_trig_auto_assign_1
					, @organization_id_trig_auto_assign_1
					, @is_obsolete_trig_auto_assign_1
					, @is_update_needed_trig_auto_assign_1
					# Which unit/user
					, `a`.`mefe_user_id`
					, @unee_t_mefe_unit_id_trig_auto_assign_1
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
						`syst_updated_datetime` := @syst_created_datetime_trig_auto_assign_1
						, `update_system_id` := @creation_system_id_trig_auto_assign_1
						, `updated_by_id` := @requestor_id_trig_auto_assign_1
						, `update_method` := @creation_method_trig_auto_assign_1
						, `organization_id` := @organization_id_trig_auto_assign_1
						, `is_obsolete` := @is_obsolete_trig_auto_assign_1
						, `is_update_needed` := @is_update_needed_trig_auto_assign_1
						# Which unit/user
						, `unee_t_mefe_id` := `a`.`mefe_user_id`
						, `unee_t_unit_id` := @unee_t_mefe_unit_id_trig_auto_assign_1
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

	SET @unee_t_mefe_unit_id_trig_auto_assign_1 := NEW.`unee_t_mefe_unit_id` ;
	SET @upstream_update_method_trig_auto_assign_1 := NEW.`update_method` ;

	SET @requestor_id_trig_auto_assign_1 := NEW.`updated_by_id` ;

	SET @created_by_id_trig_auto_assign_1 := (SELECT `organization_id`
		FROM `ut_api_keys`
		WHERE `mefe_user_id` = @requestor_id_trig_auto_assign_1
		);

	IF @requestor_id_trig_auto_assign_1 IS NOT NULL
		AND @unee_t_mefe_unit_id_trig_auto_assign_1 IS NOT NULL
		AND @upstream_update_method_trig_auto_assign_1 = 'ut_creation_unit_mefe_api_reply'
	THEN 

	# We need to list all the users that we should assign to this new property:
	# These users are users who need to be assigned to:
	#	- All the properties in the organization
	#	- All the properties in the country where this property is
	#	- All the properties in the Area where this property is

		SET @external_property_type_id_trig_auto_assign_1 := NEW.`external_property_type_id` ;

		SET @property_id_trig_auto_assign_1 := NEW.`new_record_id` ;

		SET @organization_id_trig_auto_assign_1 := NEW.`organization_id` ;

	# What is the country for that property

		SET @property_country_code_trig_auto_assign_1 := (IF (@external_property_type_id_trig_auto_assign_1 = 1
				, (SELECT `country_code`
					FROM `ut_list_mefe_unit_id_level_1_by_area`
					WHERE `level_1_building_id` = @property_id_trig_auto_assign_1
					)
				, IF (@external_property_type_id_trig_auto_assign_1 = 2
					, (SELECT `country_code`
						FROM `ut_list_mefe_unit_id_level_2_by_area`
						WHERE `level_2_unit_id` = @property_id_trig_auto_assign_1
						)
					, IF (@external_property_type_id_trig_auto_assign_1 = 3
						, (SELECT `country_code`
							FROM `ut_list_mefe_unit_id_level_3_by_area`
							WHERE `level_3_room_id` = @property_id_trig_auto_assign_1
							)
						, 'error - 1308'
						)
					)
				)
			);

	# We get the other variables we need:

		SET @syst_created_datetime_trig_auto_assign_1 := NOW() ;
		SET @creation_system_id_trig_auto_assign_1 := 2 ;
		SET @creation_method_trig_auto_assign_1 := 'ut_update_mefe_unit_id_assign_users_to_property' ;

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
			@syst_created_datetime_trig_auto_assign_1
			, @creation_system_id_trig_auto_assign_1
			, @requestor_id_trig_auto_assign_1
			, @created_by_id_trig_auto_assign_1
			, @creation_method_trig_auto_assign_1
			, @organization_id_trig_auto_assign_1
			, `a`.`mefe_user_id`
			, `a`.`email`
			, `a`.`unee_t_user_type_id`
			, @unee_t_mefe_unit_id_trig_auto_assign_1
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
					`a`.`organization_id` = @organization_id_trig_auto_assign_1
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
				@syst_created_datetime_trig_auto_assign_1
				, @creation_system_id_trig_auto_assign_1
				, @requestor_id_trig_auto_assign_1
				, @created_by_id_trig_auto_assign_1
				, @creation_method_trig_auto_assign_1
				, @organization_id_trig_auto_assign_1
				, `a`.`country_code`
				, `a`.`mefe_user_id`
				, `a`.`email`
				, `a`.`unee_t_user_type_id`
				, @unee_t_mefe_unit_id_trig_auto_assign_1
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
						`a`.`organization_id` = @organization_id_trig_auto_assign_1
						AND `a`.`country_code` = @property_country_code_trig_auto_assign_1
						AND `a`.`is_all_units_in_country` = 1
				;

	# We assign the user to the unit

		# For Level 1 Properties, this is done in the table 
		# `external_map_user_unit_role_permissions_level_1`

			SET @propagate_to_all_level_2_trig_auto_assign_1 := 1 ;
			SET @propagate_to_all_level_3_trig_auto_assign_1 := 1;

			SET @is_obsolete_trig_auto_assign_1 := 0 ;
			SET @is_update_needed_trig_auto_assign_1 := 1 ;

			IF @external_property_type_id_trig_auto_assign_1 = 1
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
						@syst_created_datetime_trig_auto_assign_1
						, @creation_system_id_trig_auto_assign_1
						, @created_by_id_trig_auto_assign_1
						, @creation_method_trig_auto_assign_1
						, @organization_id_trig_auto_assign_1
						, @is_obsolete_trig_auto_assign_1
						, @is_update_needed_trig_auto_assign_1
						# Which unit/user
						, `a`.`mefe_user_id`
						, @property_id_trig_auto_assign_1
						, `a`.`unee_t_user_type_id`
						, @propagate_to_all_level_2_trig_auto_assign_1
						, @propagate_to_all_level_3_trig_auto_assign_1
					FROM `temp_list_users_auto_assign_new_property` AS `a`
						ON DUPLICATE KEY UPDATE
							`syst_updated_datetime` := @syst_created_datetime_trig_auto_assign_1
							, `update_system_id` := @creation_system_id_trig_auto_assign_1
							, `updated_by_id` := @created_by_id_trig_auto_assign_1
							, `update_method` := @creation_method_trig_auto_assign_1
							, `organization_id` := @organization_id_trig_auto_assign_1
							, `is_obsolete` := @is_obsolete_trig_auto_assign_1
							, `is_update_needed` := @is_update_needed_trig_auto_assign_1
							# Which unit/user
							, `unee_t_mefe_user_id` := `a`.`mefe_user_id`
							, `unee_t_level_1_id` := @property_id_trig_auto_assign_1
							, `unee_t_user_type_id` := `a`.`unee_t_user_type_id`
							, `propagate_level_2`:= @propagate_to_all_level_2_trig_auto_assign_1
							, `propagate_level_3` := @propagate_to_all_level_3_trig_auto_assign_1
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
							@syst_created_datetime_trig_auto_assign_1
							, @creation_system_id_trig_auto_assign_1
							, @requestor_id_trig_auto_assign_1
							, @creation_method_trig_auto_assign_1
							, @organization_id_trig_auto_assign_1
							, @is_obsolete_trig_auto_assign_1
							, @is_update_needed_trig_auto_assign_1
							# Which unit/user
							, `a`.`mefe_user_id`
							, @unee_t_mefe_unit_id_trig_auto_assign_1
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
							, @propagate_to_all_level_2_trig_auto_assign_1
							, @propagate_to_all_level_3_trig_auto_assign_1
							FROM `temp_list_users_auto_assign_new_property` AS `a`
							ON DUPLICATE KEY UPDATE
								`syst_updated_datetime` := @syst_created_datetime_trig_auto_assign_1
								, `update_system_id` := @creation_system_id_trig_auto_assign_1
								, `updated_by_id` := @requestor_id_trig_auto_assign_1
								, `update_method` := @creation_method_trig_auto_assign_1
								, `organization_id` := @organization_id_trig_auto_assign_1
								, `is_obsolete` := @is_obsolete_trig_auto_assign_1
								, `is_update_needed` := @is_update_needed_trig_auto_assign_1
								# Which unit/user
								, `unee_t_mefe_id` := `a`.`mefe_user_id`
								, `unee_t_unit_id` := @unee_t_mefe_unit_id_trig_auto_assign_1
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
								, `propagate_to_all_level_2` = @propagate_to_all_level_2_trig_auto_assign_1
								, `propagate_to_all_level_3` = @propagate_to_all_level_3_trig_auto_assign_1
								;

			ELSEIF @external_property_type_id_trig_auto_assign_1 = 2
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
						@syst_created_datetime_trig_auto_assign_1
						, @creation_system_id_trig_auto_assign_1
						, @created_by_id_trig_auto_assign_1
						, @creation_method_trig_auto_assign_1
						, @organization_id_trig_auto_assign_1
						, @is_obsolete_trig_auto_assign_1
						, @is_update_needed_trig_auto_assign_1
						# Which unit/user
						, `a`.`mefe_user_id`
						, @property_id_trig_auto_assign_1
						, `a`.`unee_t_user_type_id`
						, @propagate_to_all_level_3_trig_auto_assign_1
					FROM `temp_list_users_auto_assign_new_property` AS `a`
						ON DUPLICATE KEY UPDATE
							`syst_updated_datetime` := @syst_created_datetime_trig_auto_assign_1
							, `update_system_id` := @creation_system_id_trig_auto_assign_1
							, `updated_by_id` := @created_by_id_trig_auto_assign_1
							, `update_method` := @creation_method_trig_auto_assign_1
							, `organization_id` := @organization_id_trig_auto_assign_1
							, `is_obsolete` := @is_obsolete_trig_auto_assign_1
							, `is_update_needed` := @is_update_needed_trig_auto_assign_1
							# Which unit/user
							, `unee_t_mefe_user_id` := `a`.`mefe_user_id`
							, `unee_t_level_2_id` := @property_id_trig_auto_assign_1
							, `unee_t_user_type_id` := `a`.`unee_t_user_type_id`
							, `propagate_level_3` := @propagate_to_all_level_3_trig_auto_assign_1
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
							@syst_created_datetime_trig_auto_assign_1
							, @creation_system_id_trig_auto_assign_1
							, @requestor_id_trig_auto_assign_1
							, @creation_method_trig_auto_assign_1
							, @organization_id_trig_auto_assign_1
							, @is_obsolete_trig_auto_assign_1
							, @is_update_needed_trig_auto_assign_1
							# Which unit/user
							, `a`.`mefe_user_id`
							, @unee_t_mefe_unit_id_trig_auto_assign_1
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
							, @propagate_to_all_level_3_trig_auto_assign_1
							FROM `temp_list_users_auto_assign_new_property` AS `a`
							ON DUPLICATE KEY UPDATE
								`syst_updated_datetime` := @syst_created_datetime_trig_auto_assign_1
								, `update_system_id` := @creation_system_id_trig_auto_assign_1
								, `updated_by_id` := @requestor_id_trig_auto_assign_1
								, `update_method` := @creation_method_trig_auto_assign_1
								, `organization_id` := @organization_id_trig_auto_assign_1
								, `is_obsolete` := @is_obsolete_trig_auto_assign_1
								, `is_update_needed` := @is_update_needed_trig_auto_assign_1
								# Which unit/user
								, `unee_t_mefe_id` := `a`.`mefe_user_id`
								, `unee_t_unit_id` := @unee_t_mefe_unit_id_trig_auto_assign_1
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
								, `propagate_to_all_level_3` = @propagate_to_all_level_3_trig_auto_assign_1
								;

			ELSEIF @external_property_type_id_trig_auto_assign_1 = 3
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
						@syst_created_datetime_trig_auto_assign_1
						, @creation_system_id_trig_auto_assign_1
						, @created_by_id_trig_auto_assign_1
						, @creation_method_trig_auto_assign_1
						, @organization_id_trig_auto_assign_1
						, @is_obsolete_trig_auto_assign_1
						, @is_update_needed_trig_auto_assign_1
						# Which unit/user
						, `a`.`mefe_user_id`
						, @property_id_trig_auto_assign_1
						, `a`.`unee_t_user_type_id`
					FROM `temp_list_users_auto_assign_new_property` AS `a`
						ON DUPLICATE KEY UPDATE
							`syst_updated_datetime` := @syst_created_datetime_trig_auto_assign_1
							, `update_system_id` := @creation_system_id_trig_auto_assign_1
							, `updated_by_id` := @created_by_id_trig_auto_assign_1
							, `update_method` := @creation_method_trig_auto_assign_1
							, `organization_id` := @organization_id_trig_auto_assign_1
							, `is_obsolete` := @is_obsolete_trig_auto_assign_1
							, `is_update_needed` := @is_update_needed_trig_auto_assign_1
							# Which unit/user
							, `unee_t_mefe_user_id` := `a`.`mefe_user_id`
							, `unee_t_level_3_id` := @property_id_trig_auto_assign_1
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
							@syst_created_datetime_trig_auto_assign_1
							, @creation_system_id_trig_auto_assign_1
							, @requestor_id_trig_auto_assign_1
							, @creation_method_trig_auto_assign_1
							, @organization_id_trig_auto_assign_1
							, @is_obsolete_trig_auto_assign_1
							, @is_update_needed_trig_auto_assign_1
							# Which unit/user
							, `a`.`mefe_user_id`
							, @unee_t_mefe_unit_id_trig_auto_assign_1
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
								`syst_updated_datetime` := @syst_created_datetime_trig_auto_assign_1
								, `update_system_id` := @creation_system_id_trig_auto_assign_1
								, `updated_by_id` := @requestor_id_trig_auto_assign_1
								, `update_method` := @creation_method_trig_auto_assign_1
								, `organization_id` := @organization_id_trig_auto_assign_1
								, `is_obsolete` := @is_obsolete_trig_auto_assign_1
								, `is_update_needed` := @is_update_needed_trig_auto_assign_1
								# Which unit/user
								, `unee_t_mefe_id` := `a`.`mefe_user_id`
								, `unee_t_unit_id` := @unee_t_mefe_unit_id_trig_auto_assign_1
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
					@syst_created_datetime_trig_auto_assign_1
					, @creation_system_id_trig_auto_assign_1
					, @requestor_id_trig_auto_assign_1
					, @creation_method_trig_auto_assign_1
					, @organization_id_trig_auto_assign_1
					, @is_obsolete_trig_auto_assign_1
					, @is_update_needed_trig_auto_assign_1
					# Which unit/user
					, `a`.`mefe_user_id`
					, @unee_t_mefe_unit_id_trig_auto_assign_1
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
						`syst_updated_datetime` := @syst_created_datetime_trig_auto_assign_1
						, `update_system_id` := @creation_system_id_trig_auto_assign_1
						, `updated_by_id` := @requestor_id_trig_auto_assign_1
						, `update_method` := @creation_method_trig_auto_assign_1
						, `organization_id` := @organization_id_trig_auto_assign_1
						, `is_obsolete` := @is_obsolete_trig_auto_assign_1
						, `is_update_needed` := @is_update_needed_trig_auto_assign_1
						# Which unit/user
						, `unee_t_mefe_id` := `a`.`mefe_user_id`
						, `unee_t_unit_id` := @unee_t_mefe_unit_id_trig_auto_assign_1
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


#################
#	
# This is part 7
# Procedures to update the Db after downstream system calls back
#
#################

####################################################################
#
# The below Procedures are used so that we can update the database
# after an action from a downstream system was done
#	- `create a user`
#	- ``
#
# We are creating the following procedures:
#	- `ut_creation_unit_mefe_api_reply` (was previously `ut_creation_success_mefe_unit_id`)
#	- `ut_creation_user_mefe_api_reply` (was previously `ut_creation_success_mefe_user_id`)
#	- `ut_creation_user_role_association_mefe_api_reply` (was previously `ut_creation_success_add_user_to_role_in_unit_with_visibility`)
#	- `ut_update_unit_mefe_api_reply` (was previously `ut_update_success_mefe_unit`)
#	- `ut_update_user_mefe_api_reply` (was previously `ut_update_success_mefe_user`)
#	- `ut_remove_user_role_association_mefe_api_reply` (was previously `ut_update_success_remove_user_from_unit`)
#
#
####################################################################
#
#################
# WARNING!!!
#################
#
######################################################################################
#
# you also need to run all the other scripts so the Unee-T Enterprise Db is properly configured
#	- 1_Triggers_and_procedure_unee-t_enterprise_v1_8_0_updates_FROM_Unee-T_Enterprise_excl_assignment.sql
#	- 2_
#	- 4_Triggers_and_procedure_unee-t_enterprise_v1_8_0_lambda_related_objects_for_[ENVIRONMENT].sql
#
######################################################################################
#


# Create the procedure so that the Golang Script can update the record each time a unit is successfully created.

		DROP PROCEDURE IF EXISTS `ut_creation_unit_mefe_api_reply`;
	
DELIMITER $$
CREATE PROCEDURE `ut_creation_unit_mefe_api_reply`()
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN

# This procedure needs the following variables:
#	- @unit_creation_request_id
#	- @mefe_unit_id
#	- @creation_datetime
#	- @is_created_by_me
#	- @mefe_api_error_message

	# We need to capture the MEFE user ID of the updater

		SET @updated_by_id := (SELECT `created_by_id`
			FROM `ut_map_external_source_units` 
			WHERE `id_map` = @unit_creation_request_id
			);

	# Is it a success or an error?

		SET @is_mefe_api_success := (IF (@mefe_api_error_message = ''
				, 1
				, 0
				)
			);

	# Now we can do the update

		UPDATE `ut_map_external_source_units`
		SET 
			`unee_t_mefe_unit_id` := @mefe_unit_id
			, `uneet_created_datetime` := @creation_datetime
			, `is_unee_t_created_by_me` := @is_created_by_me
			, `is_update_needed` := 0
			, `syst_updated_datetime` := NOW()
			, `update_system_id` := 2
			, `updated_by_id` := @updated_by_id
			, `update_method` := 'ut_creation_unit_mefe_api_reply'
			, `is_mefe_api_success` := @is_mefe_api_success
			, `mefe_api_error_message` := @mefe_api_error_message
			WHERE `id_map` = @unit_creation_request_id
		;

END $$
DELIMITER ;

# Create the procedure so that the Golang Script can update the record each time a user is successfully created.

		DROP PROCEDURE IF EXISTS `ut_creation_user_mefe_api_reply`;
	
DELIMITER $$
CREATE PROCEDURE `ut_creation_user_mefe_api_reply`()
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN

# This procedure needs the following variables:
#	- @user_creation_request_id
#	- @mefe_user_id
#	- @mefe_user_api_key
#	- @creation_datetime
#	- @is_created_by_me
#	- @mefe_api_error_message

	# We need to capture the MEFE user ID of the updater

		SET @updated_by_id = (SELECT `created_by_id`
			FROM `ut_map_external_source_users` 
			WHERE `id_map` = @user_creation_request_id
			);

	# Is it a success or an error?

		SET @is_mefe_api_success := (IF (@mefe_api_error_message = ''
				, 1
				, 0
				)
			);

	# Now we can do the update

		UPDATE `ut_map_external_source_users`
		SET 
			`unee_t_mefe_user_id` := @mefe_user_id
			, `unee_t_mefe_user_api_key` = @mefe_user_api_key
			, `uneet_created_datetime` := @creation_datetime
			, `is_unee_t_created_by_me` := @is_created_by_me
			, `is_update_needed` := 0
			, `syst_updated_datetime` := NOW()
			, `update_system_id` := 2
			, `updated_by_id` := @updated_by_id
			, `update_method` = 'ut_creation_user_mefe_api_reply'
			, `is_mefe_api_success` := @is_mefe_api_success
			, `mefe_api_error_message` := @mefe_api_error_message
			WHERE `id_map` = @user_creation_request_id
		;

END $$
DELIMITER ;

# Create the procedure so that the Golang Script can update the record each time a mapping user/role/visibility/unit is successfully created.

		DROP PROCEDURE IF EXISTS `ut_creation_user_role_association_mefe_api_reply`;
	
DELIMITER $$
CREATE PROCEDURE `ut_creation_user_role_association_mefe_api_reply`()
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN

# This procedure needs the following variables:
#	- @id_map_user_unit_permissions
#	- @creation_datetime 
#	- @mefe_api_error_message

	# We need to capture the MEFE user ID of the updater

		SET @updated_by_id := (SELECT `created_by_id`
			FROM `ut_map_user_permissions_unit_all` 
			WHERE `id_map_user_unit_permissions` = @unit_creation_request_id
			);

	# Is it a success or an error?

		SET @is_mefe_api_success := (IF (@mefe_api_error_message = ''
				, 1
				, 0
				)
			);

	# Now we can do the update

		UPDATE `ut_map_user_permissions_unit_all`
		SET 
			`is_update_needed` := 0
			, `syst_updated_datetime` := NOW()
			, `update_system_id` := 2
			, `updated_by_id` := @updated_by_id
			, `update_method` := 'ut_creation_user_role_association_mefe_api_reply'
			, `unee_t_update_ts` := @creation_datetime
			, `is_mefe_api_success` := @is_mefe_api_success
			, `mefe_api_error_message` := @mefe_api_error_message
			WHERE `id_map_user_unit_permissions` = @id_map_user_unit_permissions
		;

END $$
DELIMITER ;

# Create the procedure so that the Golang Script can update the record each time a user is successfully updated.

		DROP PROCEDURE IF EXISTS `ut_update_unit_mefe_api_reply`;
	
DELIMITER $$
CREATE PROCEDURE `ut_update_unit_mefe_api_reply`()
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN

# This procedure needs the following variables:
#	- @update_unit_request_id
#	- @updated_datetime (a TIMESTAMP)

	# We need to capture the MEFE user ID of the updater

		SET @updated_by_id := (SELECT `updated_by_id`
			FROM `ut_map_external_source_units` 
			WHERE `id_map` = @update_unit_request_id
			);

	# Is it a success or an error?

		SET @is_mefe_api_success := (IF (@mefe_api_error_message = ''
				, 1
				, 0
				)
			);

	# Now we can do the update

		UPDATE `ut_map_external_source_units`
		SET 
			`is_update_needed` := 0
			, `syst_updated_datetime` := @updated_datetime
			, `update_system_id` := 2
			, `updated_by_id` := @updated_by_id
			, `update_method` := 'ut_update_unit_mefe_api_reply'
			, `is_mefe_api_success` := @is_mefe_api_success
			, `mefe_api_error_message` := @mefe_api_error_message
			WHERE `id_map` = @update_unit_request_id
		;

END $$
DELIMITER ;

# Create the procedure so that the Golang Script can update the record each time a user is successfully updated.

		DROP PROCEDURE IF EXISTS `ut_update_user_mefe_api_reply`;
	
DELIMITER $$
CREATE PROCEDURE `ut_update_user_mefe_api_reply`()
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN

# This procedure needs the following variables:
#	- @update_user_request_id
#	- @updated_datetime (a TIMESTAMP)
#	- @mefe_api_error_message


	# We need to capture the MEFE user ID of the updater

		SET @updated_by_id := (SELECT `updated_by_id`
			FROM `ut_map_external_source_users` 
			WHERE `id_map` = @update_user_request_id
			);

	# Is it a success or an error?

		SET @is_mefe_api_success := (IF (@mefe_api_error_message = ''
				, 1
				, 0
				)
			);

	# Now we can do the update

		UPDATE `ut_map_external_source_users`
		SET 
			`is_update_needed` := 0
			, `syst_updated_datetime` := @updated_datetime
			, `update_system_id` := 2
			, `updated_by_id` := @updated_by_id
			, `update_method` := 'ut_update_user_mefe_api_reply'
			, `is_mefe_api_success` := @is_mefe_api_success
			, `mefe_api_error_message` := @mefe_api_error_message
			WHERE `id_map` = @update_user_request_id
		;

END $$
DELIMITER ;

    # Create the procedure so that the Golang Script can update the record each time a user is successfully updated.

		DROP PROCEDURE IF EXISTS `ut_remove_user_role_association_mefe_api_reply`;
	
DELIMITER $$
CREATE PROCEDURE `ut_remove_user_role_association_mefe_api_reply`()
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN

# This procedure needs the following variables:
#	- @remove_user_from_unit_request_id 
#	- @updated_datetime (a TIMESTAMP)
#	- @mefe_api_error_message

	# We need to capture the MEFE user ID of the updater

		SET @updated_by_id := (SELECT `updated_by_id`
			FROM `ut_map_user_permissions_unit_all` 
			WHERE `id_map_user_unit_permissions` = @remove_user_from_unit_request_id
			);

	# Is it a success or an error?

		SET @is_mefe_api_success := (IF (@mefe_api_error_message = ''
				, 1
				, 0
				)
			);

	# Now we can do the update

		UPDATE `ut_map_user_permissions_unit_all`
		SET 
			`is_update_needed` := 0
			, `syst_updated_datetime` := @updated_datetime
			, `update_system_id` := 2
			, `updated_by_id` := @updated_by_id
			, `unee_t_update_ts` := @updated_datetime
			, `update_method` := 'ut_remove_user_role_association_mefe_api_reply'
			, `is_mefe_api_success` := @is_mefe_api_success
			, `mefe_api_error_message` := @mefe_api_error_message
			WHERE `id_map_user_unit_permissions` = @remove_user_from_unit_request_id
		;

END $$
DELIMITER ;

#####################
#
# Ad hoc procedures
#
#####################

	# Edge case - the lambda has failed and we need to trigger it one more time

		DROP PROCEDURE IF EXISTS `retry_create_user`;
	
DELIMITER $$
CREATE PROCEDURE `retry_create_user`()
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN

# This procedure 
#	- checks all the users with no MEFE ID in the table `ut_map_external_source_users`
#	- Delete these users in the table `ut_map_external_source_users`
#	- 

		# Create a table with all the records with no MEFE user_id in the table `ut_map_external_source_users`

			DROP TABLE IF EXISTS `temp_table_retry_mefe_user_creation`;

			CREATE TABLE `temp_table_retry_mefe_user_creation`
			AS 
			SELECT * 
				FROM `ut_map_external_source_users`
				WHERE `unee_t_mefe_user_id` IS NULL
			;

		# We delete all the record in the table `ut_map_external_source_users` where we have no MEFE_user_id

			DELETE FROM `ut_map_external_source_users`
			WHERE `unee_t_mefe_user_id` IS NULL
			;

		# We insert the failed record again in the table `Condominium` - this re-fires the lambdas to create these users

			INSERT INTO `ut_map_external_source_users`
			SELECT * 
			FROM 
			`temp_table_retry_mefe_user_creation`
			;

		# Clean up - Remove the temp table

			DROP TABLE IF EXISTS `temp_table_retry_mefe_user_creation`;

END $$
DELIMITER ;


#################
#	
# This creates all the Ad hoc procedures we need
#
#################

####################################################################
#
# This script creates additional procedure that we can run if needed
#	- `retry_create_user`
#	- ``
#	- ``
#
####################################################################

# Edge case - the lambda has failed and we need to trigger it one more time

	DROP PROCEDURE IF EXISTS `retry_create_user`;

DELIMITER $$
CREATE PROCEDURE `retry_create_user`()
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN

# This procedure 
#	- checks all the users with no MEFE ID in the table `ut_map_external_source_users`
#	- Delete these users in the table `ut_map_external_source_users`
#	- 

		# Create a table with all the records with no MEFE user_id in the table `ut_map_external_source_users`

			DROP TABLE IF EXISTS `temp_table_retry_mefe_user_creation`;

			CREATE TABLE `temp_table_retry_mefe_user_creation`
			AS 
			SELECT * 
				FROM `ut_map_external_source_users`
				WHERE `unee_t_mefe_user_id` IS NULL
			;

		# We delete all the record in the table `ut_map_external_source_users` where we have no MEFE_user_id

			DELETE FROM `ut_map_external_source_users`
			WHERE `unee_t_mefe_user_id` IS NULL
			;

		# We insert the failed record again in the table `Condominium` - this re-fires the lambdas to create these users

			INSERT INTO `ut_map_external_source_users`
			SELECT * 
			FROM 
			`temp_table_retry_mefe_user_creation`
			;

		# Clean up - Remove the temp table

			DROP TABLE IF EXISTS `temp_table_retry_mefe_user_creation`;

END $$
DELIMITER ;



#################
#
# This lists all the triggers we use to 
# create a person
# via the Unee-T Enterprise Interface
#
#################

# We create a trigger when a record is added to the `external_persons` table

	DROP TRIGGER IF EXISTS `ut_insert_external_person`;

DELIMITER $$
CREATE TRIGGER `ut_insert_external_person`
AFTER INSERT ON `external_persons`
FOR EACH ROW
BEGIN

# We only do this if:
#	- We need to create the record in Unee-T
#	- We havea valid MEFE user ID for the system that created this record
# 	- We have an email address
#	- We have an external id
#	- We have an external table
#	- We have an external sytem
#	- This is a valid insert method:
#		- 'imported_from_hmlet_ipi'
#		- 'Manage_Unee_T_Users_Add_Page'
#		- 'Manage_Unee_T_Users_Edit_Page'
#		- 'Manage_Unee_T_Users_Import_Page'
#		- ''
#		- ''

	SET @is_unee_t_account_needed = NEW.`is_unee_t_account_needed` ;

	SET @source_system_creator = NEW.`created_by_id` ;
	SET @source_system_updater = NEW.`updated_by_id`;

	SET @creator_mefe_user_id = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator
		)
		;

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;
	
	SET @email = NEW.`email` ;
	SET @external_id = NEW.`external_id` ;
	SET @external_system = NEW.`external_system` ; 
	SET @external_table = NEW.`external_table` ;

	IF @is_unee_t_account_needed = 1
		AND @creator_mefe_user_id IS NOT NULL
		AND @email IS NOT NULL
		AND @external_id IS NOT NULL
		AND @external_system IS NOT NULL
		AND @external_table IS NOT NULL
		AND (@upstream_create_method = 'imported_from_hmlet_ipi'
			OR @upstream_create_method = 'Manage_Unee_T_Users_Add_Page'
			OR @upstream_create_method = 'Manage_Unee_T_Users_Edit_Page'
			OR @upstream_create_method = 'Manage_Unee_T_Users_Import_Page'
			OR @upstream_update_method = 'imported_from_hmlet_ipi'
			OR @upstream_update_method = 'Manage_Unee_T_Users_Add_Page'
			OR @upstream_update_method = 'Manage_Unee_T_Users_Edit_Page'
			OR @upstream_update_method = 'Manage_Unee_T_Users_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `persons` table:

		SET @this_trigger = 'ut_insert_external_person' ;

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
		SET @organization_id_update = @source_system_creator;

		SET @person_status_id = NEW.`person_status_id` ;
		SET @dupe_id = NEW.`dupe_id` ;
		SET @handler_id = NEW.`handler_id` ;

		SET @unee_t_user_type_id = NEW.`unee_t_user_type_id` ;
		SET @country_code = NEW.`country_code` ;
		SET @gender = NEW.`gender` ;
		SET @given_name = NEW.`given_name` ;
		SET @middle_name = NEW.`middle_name` ;
		SET @family_name = NEW.`family_name` ;
		SET @date_of_birth = NEW.`date_of_birth` ;
		SET @alias = NEW.`alias` ;
		SET @job_title = NEW.`job_title` ;
		SET @organization = NEW.`organization` ;
		SET @email = NEW.`email` ;
		SET @tel_1 = NEW.`tel_1` ;
		SET @tel_2 = NEW.`tel_2` ;
		SET @whatsapp = NEW.`whatsapp` ;
		SET @linkedin = NEW.`linkedin` ;
		SET @facebook = NEW.`facebook` ;
		SET @adr1 = NEW.`adr1` ;
		SET @adr2 = NEW.`adr2` ;
		SET @adr3 = NEW.`adr3` ;
		SET @City = NEW.`City` ;
		SET @zip_postcode = NEW.`zip_postcode` ;
		SET @region_or_state = NEW.`region_or_state` ;
		SET @country = NEW.`country` ;
		
		# We insert a new record in the table `persons`

			INSERT INTO `persons`
				(`external_id`
				, `external_system` 
				, `external_table`
				, `syst_created_datetime`
				, `creation_system_id`
				, `created_by_id`
				, `creation_method`
				, `organization_id`
				, `person_status_id`
				, `dupe_id`
				, `handler_id`
				, `is_unee_t_account_needed`
				, `unee_t_user_type_id`
				, `country_code`
				, `gender`
				, `given_name`
				, `middle_name`
				, `family_name`
				, `date_of_birth`
				, `alias`
				, `job_title`
				, `organization`
				, `email`
				, `tel_1`
				, `tel_2`
				, `whatsapp`
				, `linkedin`
				, `facebook`
				, `adr1`
				, `adr2`
				, `adr3`
				, `City`
				, `zip_postcode`
				, `region_or_state`
				, `country`
				)
				VALUES
					(@external_id
					, @external_system
					, @external_table
					, @syst_created_datetime
					, @creation_system_id
					, @created_by_id
					, 'person_create_method_1'
					, @organization_id_create
					, @person_status_id
					, @dupe_id
					, @handler_id
					, @is_unee_t_account_needed
					, @unee_t_user_type_id
					, @country_code
					, @gender
					, @given_name
					, @middle_name
					, @family_name
					, @date_of_birth
					, @alias
					, @job_title
					, @organization
					, @email
					, @tel_1
					, @tel_2
					, @whatsapp
					, @linkedin
					, @facebook
					, @adr1
					, @adr2
					, @adr3
					, @City
					, @zip_postcode
					, @region_or_state
					, @country
					)
				ON DUPLICATE KEY UPDATE
					`syst_updated_datetime` = @syst_updated_datetime
					, `update_system_id` = @update_system_id
					, `updated_by_id` = @updated_by_id
					, `update_method` = 'person_create_method_2'
					, `organization_id` = @organization_id_update
					, `person_status_id` = @person_status_id
					, `dupe_id` = @dupe_id
					, `handler_id` = @handler_id
					, `is_unee_t_account_needed` = @is_unee_t_account_needed
					, `unee_t_user_type_id` = @unee_t_user_type_id
					, `country_code` = @country_code
					, `gender` = @gender
					, `given_name` = @given_name
					, `middle_name` = @middle_name
					, `family_name` = @family_name
					, `date_of_birth` = @date_of_birth
					, `alias` = @alias
					, `job_title` = @job_title
					, `organization` = @organization
					, `email` = @email
					, `tel_1` = @tel_1
					, `tel_2` = @tel_2
					, `whatsapp` = @whatsapp
					, `linkedin` = @linkedin
					, `facebook` = @facebook
					, `adr1` = @adr1
					, `adr2` = @adr2
					, `adr3` = @adr3
					, `City` = @City
					, `zip_postcode` = @zip_postcode
					, `region_or_state` = @region_or_state
					, `country` = @country
				;

		# We insert a new record in the table `ut_map_external_source_users`
		# This is the table that triggers the lambda to create the user in Unee-T

			# We get the additional variables we need:

				SET @is_update_needed = NULL;

				SET @person_id = (SELECT `id_person` 
					FROM `persons`
					WHERE `external_id` = @external_id
						AND `external_system` = @external_system
						AND `external_table` = @external_table
						AND `organization_id` = @organization_id_create
					)
					;

			# We do the insert now

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
						(@syst_created_datetime
						, @creation_system_id
						, @created_by_id
						, 'person_create_method_3'
						, @organization_id_create
						, @is_update_needed
						, @person_id
						, @email
						, @external_id
						, @external_system
						, @external_table
						)
						ON DUPLICATE KEY UPDATE
							`syst_updated_datetime` = @syst_updated_datetime
							, `update_system_id` = @update_system_id
							, `updated_by_id` = @updated_by_id
							, `update_method` = 'person_create_method_4'
							, `organization_id` = @organization_id_update
							, `uneet_login_name` = @email
							, `is_update_needed` = 1
					;

	END IF;
END;
$$
DELIMITER ;

# Once we have a reply from the MEFE API with a MEFE user ID for that user we can
# assign this user to all the units in the organization
# We do this ONLY if
#	- This is an authorized method
#	- The field `is_all_unit` in the table `ut_user_types` for the user type selected for this user is = 1

	DROP TRIGGER IF EXISTS `ut_after_mefe_user_id_is_created_bulk_assign_user_unit`;

DELIMITER $$
CREATE TRIGGER `ut_after_mefe_user_id_is_created_bulk_assign_user_unit`
AFTER UPDATE ON `ut_map_external_source_users`
FOR EACH ROW
BEGIN

# We do this ONLY if
#	- We have a MEFE user ID for that user
#	- This is an authorized method:
#		- `ut_creation_user_mefe_api_reply`
#		- ``

	SET @unee_t_mefe_user_id := NEW.`unee_t_mefe_user_id` ;

	SET @person_id := NEW.`person_id` ;

	SET @requestor_id = NEW.`updated_by_id` ;

	SET @upstream_update_method := NEW.`update_method` ;

	IF @unee_t_mefe_user_id IS NOT NULL
		AND (@upstream_update_method = 'ut_creation_user_mefe_api_reply'
		)
	THEN 

		# We call the procedure to bulk assign a user to several units.
		# This procedure needs the following variables:
		#	- @requestor_id
		#	- @person_id

		CALL `ut_bulk_assign_units_to_a_user` ;

	END IF;
END;
$$
DELIMITER ;

#################
#
# This lists all the triggers we use to 
# update a person
# via the Unee-T Enterprise Interface
#
#################
#
#
# This script creates the follwoing objects:
#	- `ut_update_external_person_not_ut_user_type`
#	- `ut_update_external_person_ut_user_type`
#	- ``
#


# We create a trigger when we udpate the `external_persons` table
# AND this is NOT an update of the field `unee_t_user_type_id`

	DROP TRIGGER IF EXISTS `ut_update_external_person_not_ut_user_type`;

DELIMITER $$
CREATE TRIGGER `ut_update_external_person_not_ut_user_type`
AFTER UPDATE ON `external_persons`
FOR EACH ROW
BEGIN

# We only do this if we have 
#	- We need to create the record in Unee-T
#	- We havea valid MEFE user ID for the system that updated this record
# 	- We have an email address
#	- We have an external id
#	- We have an external table
#	- We have an external sytem
#	- This is NOT an update of the field `unee_t_user_type_id`
#	- This is a valid update method:
#		- 'imported_from_hmlet_ipi'
#		- 'Manage_Unee_T_Users_Add_Page'
#		- 'Manage_Unee_T_Users_Edit_Page'
#		- 'Manage_Unee_T_Users_Import_Page'
#		- 'Export_and_Import_Users_Import_Page'
#		- ''

	SET @is_creation_needed_in_unee_t := NEW.`is_unee_t_account_needed` ;

	SET @source_system_creator := NEW.`created_by_id` ;
	SET @source_system_updater := NEW.`updated_by_id`;

	SET @updater_mefe_user_id_person_update_1 := (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_updater
		)
		;

	SET @upstream_create_method := NEW.`creation_method` ;
	SET @upstream_update_method := NEW.`update_method` ;
	
	SET @email := NEW.`email` ;
	SET @external_id := NEW.`external_id` ;
	SET @external_system := NEW.`external_system` ; 
	SET @external_table := NEW.`external_table` ;

	SET @old_unee_t_user_type_id := (IFNULL (OLD.`unee_t_user_type_id` 
			, 0
			)
		);
	SET @unee_t_user_type_id := NEW.`unee_t_user_type_id` ;

	SET @new_person_status_id := NEW.`person_status_id` ;

	IF @is_creation_needed_in_unee_t = 1
		AND @updater_mefe_user_id_person_update_1 IS NOT NULL
		AND @email IS NOT NULL
		AND @external_id IS NOT NULL
		AND @external_system IS NOT NULL
		AND @external_table IS NOT NULL
		AND @old_unee_t_user_type_id = @unee_t_user_type_id
		AND (@upstream_update_method = 'imported_from_hmlet_ipi'
			OR @upstream_update_method = 'Manage_Unee_T_Users_Add_Page'
			OR @upstream_update_method = 'Manage_Unee_T_Users_Edit_Page'
			OR @upstream_update_method = 'Manage_Unee_T_Users_Import_Page'
			OR @upstream_update_method = 'Export_and_Import_Users_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate:

		SET @this_trigger := 'ut_update_external_person_not_ut_user_type' ;

		SET @syst_created_datetime := NOW();
		SET @creation_system_id := (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator
			)
			;
		SET @created_by_id := @updater_mefe_user_id_person_update_1 ;
		SET @downstream_creation_method := @this_trigger ;

		SET @syst_updated_datetime := NOW();
		SET @update_system_id :=  (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater
			)
			;
		SET @updated_by_id := @updater_mefe_user_id_person_update_1 ;
		SET @downstream_update_method := @this_trigger ;

		SET @organization_id_create := @source_system_creator ;
		SET @organization_id_update := @source_system_updater ;

		SET @person_status_id := NEW.`person_status_id` ;
		SET @dupe_id := NEW.`dupe_id` ;
		SET @handler_id := NEW.`handler_id` ;

		SET @is_unee_t_account_needed := @is_creation_needed_in_unee_t ;

		SET @country_code := NEW.`country_code` ;
		SET @gender := NEW.`gender` ;
		SET @given_name := NEW.`given_name` ;
		SET @middle_name := NEW.`middle_name` ;
		SET @family_name := NEW.`family_name` ;
		SET @date_of_birth := NEW.`date_of_birth` ;
		SET @alias := NEW.`alias` ;
		SET @job_title := NEW.`job_title` ;
		SET @organization := NEW.`organization` ;
		SET @email := NEW.`email` ;
		SET @tel_1 := NEW.`tel_1` ;
		SET @tel_2 := NEW.`tel_2` ;
		SET @whatsapp := NEW.`whatsapp` ;
		SET @linkedin := NEW.`linkedin` ;
		SET @facebook := NEW.`facebook` ;
		SET @adr1 := NEW.`adr1` ;
		SET @adr2 := NEW.`adr2` ;
		SET @adr3 := NEW.`adr3` ;
		SET @City := NEW.`City` ;
		SET @zip_postcode := NEW.`zip_postcode` ;
		SET @region_or_state := NEW.`region_or_state` ;
		SET @country := NEW.`country` ;
		
		# We Update the record in the table `persons`

			INSERT INTO `persons`
				(`external_id`
				, `external_system` 
				, `external_table`
				, `syst_created_datetime`
				, `creation_system_id`
				, `created_by_id`
				, `creation_method`
				, `organization_id`
				, `person_status_id`
				, `dupe_id`
				, `handler_id`
				, `is_unee_t_account_needed`
				, `unee_t_user_type_id`
				, `country_code`
				, `gender`
				, `given_name`
				, `middle_name`
				, `family_name`
				, `date_of_birth`
				, `alias`
				, `job_title`
				, `organization`
				, `email`
				, `tel_1`
				, `tel_2`
				, `whatsapp`
				, `linkedin`
				, `facebook`
				, `adr1`
				, `adr2`
				, `adr3`
				, `City`
				, `zip_postcode`
				, `region_or_state`
				, `country`
				)
				VALUES
					(@external_id
					, @external_system
					, @external_table
					, @syst_created_datetime
					, @creation_system_id
					, @created_by_id
					, 'person_update_method_1'
					, @organization_id_update
					, @person_status_id
					, @dupe_id
					, @handler_id
					, @is_unee_t_account_needed
					, @unee_t_user_type_id
					, @country_code
					, @gender
					, @given_name
					, @middle_name
					, @family_name
					, @date_of_birth
					, @alias
					, @job_title
					, @organization
					, @email
					, @tel_1
					, @tel_2
					, @whatsapp
					, @linkedin
					, @facebook
					, @adr1
					, @adr2
					, @adr3
					, @City
					, @zip_postcode
					, @region_or_state
					, @country
					)
				ON DUPLICATE KEY UPDATE
					`syst_updated_datetime` := @syst_updated_datetime
					, `update_system_id` := @update_system_id
					, `updated_by_id` := @updated_by_id
					, `update_method` := 'person_update_method_2'
					, `organization_id` := @organization_id_update
					, `person_status_id` := @person_status_id
					, `dupe_id` := @dupe_id
					, `handler_id` := @handler_id
					, `is_unee_t_account_needed` := @is_unee_t_account_needed
					, `unee_t_user_type_id` := @unee_t_user_type_id
					, `country_code` := @country_code
					, `gender` := @gender
					, `given_name` := @given_name
					, `middle_name` := @middle_name
					, `family_name` := @family_name
					, `date_of_birth` := @date_of_birth
					, `alias` := @alias
					, `job_title` := @job_title
					, `organization` := @organization
					, `email` := @email
					, `tel_1` := @tel_1
					, `tel_2` := @tel_2
					, `whatsapp` := @whatsapp
					, `linkedin` := @linkedin
					, `facebook` := @facebook
					, `adr1` := @adr1
					, `adr2` := @adr2
					, `adr3` := @adr3
					, `City` := @City
					, `zip_postcode` := @zip_postcode
					, `region_or_state` := @region_or_state
					, `country` := @country
				;

		# We check if we need to create this user in the table `ut_map_external_source_users`
		
			SET @new_is_unee_t_account_needed_up_1 := NEW.`is_unee_t_account_needed`;
			SET @old_is_unee_t_account_needed_up_1 := OLD.`is_unee_t_account_needed`;

			SET @uneet_login_name := @email ;
	
			SET @is_update_needed_up_1 := 1 ;

			SET @person_id_up_1 := (SELECT `id_person` 
				FROM `persons`
				WHERE `external_id` = @external_id
					AND `external_system` = @external_system
					AND `external_table` = @external_table
					AND `organization_id` = @organization_id_update
				)
				;

			SET @mefe_user_id := (SELECT `unee_t_mefe_user_id`
				FROM `ut_map_external_source_users`
				WHERE `external_person_id` = @external_id
					AND `external_system` = @external_system
					AND `table_in_external_system` = @external_table
					AND `organization_id` = @organization_id_update
				)
				;

			SET @record_in_table = (SELECT `id_map` 
				FROM `ut_map_external_source_users`
				WHERE `external_person_id` = @external_id
					AND `external_system` = @external_system
					AND `table_in_external_system` = @external_table
					AND `organization_id` = @organization_id_update
				)
				;

			IF (@mefe_user_id IS NULL
				AND @is_unee_t_account_needed = 1
				AND @email IS NOT NULL
				)
			THEN 

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
						(@syst_created_datetime
						, @creation_system_id
						, @created_by_id
						, 'person_update_method_3'
						, @organization_id_update
						, @is_update_needed
						, @person_id_up_1
						, @uneet_login_name
						, @external_id
						, @external_system
						, @external_table
						)
						ON DUPLICATE KEY UPDATE
							`syst_updated_datetime` := @syst_created_datetime
							, `update_system_id` := @creation_system_id
							, `updated_by_id` := @created_by_id
							, `update_method` := 'person_update_method_4'
							, `organization_id` := @organization_id_update
							, `uneet_login_name` := @uneet_login_name
							, `is_update_needed` := @is_update_needed_up_1
					;

			ELSEIF (@mefe_user_id IS NOT NULL
				AND @is_unee_t_account_needed = 1
				AND @record_in_table IS NOT NULL
				AND @email IS NOT NULL
				)
			THEN 

			SET @requestor_id := @updated_by_id ;

			SET @person_id := (SELECT `id_person` 
				FROM `persons`
				WHERE `external_id` = @external_id
					AND `external_system` = @external_system
					AND `external_table` = @external_table
					AND `organization_id` = @organization_id_update
				)
				;

			# We update the existing record in the table `ut_map_external_source_users`

				UPDATE `ut_map_external_source_users`
					SET
						`syst_updated_datetime` := @syst_updated_datetime
						, `update_system_id` := @update_system_id
						, `updated_by_id` := @updated_by_id
						, `update_method` := 'update method 3'
						# @downstream_update_method
						, `organization_id` := @organization_id_update
						, `is_update_needed` := @is_update_needed_up_1
						, `uneet_login_name` := @uneet_login_name
					WHERE `unee_t_mefe_user_id` = @mefe_user_id
					;

			# We call the procedure that calls the lambda to update the user record in Unee-T
			# This procedure needs to following variables:
			#	- @requestor_id : the MEFE user Id for the generic user for the organization
			#	- @person_id : Id for the person we are updating.

				CALL `ut_update_user`;

			# We check if the new status of the user is active or not.

				SET @check_if_active_person_status := (SELECT `is_active`
					FROM `person_statuses`
					WHERE `id_person_status` = @new_person_status_id
					);

			# IF this is an INACTIVE status, THEN we remove the user from all the units.

				IF @check_if_active_person_status = 0
				THEN

					# A user might exist in different organization, we do this ONLY for untis in this organization!
					# We remove the user from all the Level 1 properties:

						DELETE `external_map_user_unit_role_permissions_level_1` 
						FROM `external_map_user_unit_role_permissions_level_1`
						WHERE 
							`external_map_user_unit_role_permissions_level_1`.`unee_t_mefe_user_id` = @mefe_user_id
							AND `organization_id` = @organization_id_update
							;

					# We remove the user from all the Level 2 properties:
						DELETE `external_map_user_unit_role_permissions_level_2` 
						FROM `external_map_user_unit_role_permissions_level_2`
						WHERE 
							`external_map_user_unit_role_permissions_level_2`.`unee_t_mefe_user_id` = @mefe_user_id
							AND `organization_id` = @organization_id_update
							;

					# We remove the user from all the Level 3 properties:

						DELETE `external_map_user_unit_role_permissions_level_3`
						FROM `external_map_user_unit_role_permissions_level_3`
						WHERE 
							`external_map_user_unit_role_permissions_level_3`.`unee_t_mefe_user_id` = @mefe_user_id
							AND `organization_id` = @organization_id_update
							;

				END IF;

			END IF;

	END IF;
END;
$$
DELIMITER ;

# We create a trigger when we udpate the `external_persons` table
# AND this IS an update of the field `unee_t_user_type_id`

		DROP TRIGGER IF EXISTS `ut_update_external_person_ut_user_type`;

DELIMITER $$
CREATE TRIGGER `ut_update_external_person_ut_user_type`
AFTER UPDATE ON `external_persons`
FOR EACH ROW
BEGIN

# We only do this if we have 
#	- We need to create the record in Unee-T
#	- We havea valid MEFE user ID for the system that updated this record
# 	- We have an email address
#	- We have an external id
#	- We have an external table
#	- We have an external sytem
#	- This IS an update of the field `unee_t_user_type_id`
#	- This is a valid update method:
#		- 'imported_from_hmlet_ipi'
#		- 'Manage_Unee_T_Users_Add_Page'
#		- 'Manage_Unee_T_Users_Edit_Page'
#		- 'Manage_Unee_T_Users_Import_Page'
#		- 'Export_and_Import_Users_Import_Page'
#		- ''

	SET @is_creation_needed_in_unee_t := NEW.`is_unee_t_account_needed` ;

	SET @source_system_creator := NEW.`created_by_id` ;
	SET @source_system_updater := NEW.`updated_by_id`;

	SET @updater_mefe_user_id_person_update_2 := (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_updater
		)
		;

	SET @upstream_create_method := NEW.`creation_method` ;
	SET @upstream_update_method := NEW.`update_method` ;
	
	SET @email := NEW.`email` ;
	SET @external_id := NEW.`external_id` ;
	SET @external_system := NEW.`external_system` ; 
	SET @external_table := NEW.`external_table` ;

	SET @old_unee_t_user_type_id := (IFNULL (OLD.`unee_t_user_type_id` 
			, 0
			)
		);
	SET @unee_t_user_type_id := NEW.`unee_t_user_type_id` ;

	SET @new_person_status_id := NEW.`person_status_id` ;

	IF @updater_mefe_user_id_person_update_2 IS NOT NULL
		AND @email IS NOT NULL
		AND @external_id IS NOT NULL
		AND @external_system IS NOT NULL
		AND @external_table IS NOT NULL
		AND @old_unee_t_user_type_id != @unee_t_user_type_id
		AND (@upstream_update_method = 'imported_from_hmlet_ipi'
			OR @upstream_update_method = 'Manage_Unee_T_Users_Add_Page'
			OR @upstream_update_method = 'Manage_Unee_T_Users_Edit_Page'
			OR @upstream_update_method = 'Manage_Unee_T_Users_Import_Page'
			OR @upstream_update_method = 'Export_and_Import_Users_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate:

		SET @this_trigger := 'ut_update_external_person_ut_user_type' ;

		SET @syst_created_datetime := NOW();
		SET @creation_system_id := (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator
			)
			;
		SET @created_by_id := @updater_mefe_user_id_person_update_2 ;
		SET @downstream_creation_method := @this_trigger ;

		SET @syst_updated_datetime := NOW();
		SET @update_system_id :=  (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater
			)
			;
		SET @updated_by_id := @updater_mefe_user_id_person_update_2 ;
		SET @downstream_update_method := @this_trigger ;

		SET @organization_id_create := @source_system_creator ;
		SET @organization_id_update := @source_system_updater ;

		SET @person_status_id := NEW.`person_status_id` ;
		SET @dupe_id := NEW.`dupe_id` ;
		SET @handler_id := NEW.`handler_id` ;

		SET @is_unee_t_account_needed := @is_creation_needed_in_unee_t ;

		SET @country_code := NEW.`country_code` ;
		SET @gender := NEW.`gender` ;
		SET @given_name := NEW.`given_name` ;
		SET @middle_name := NEW.`middle_name` ;
		SET @family_name := NEW.`family_name` ;
		SET @date_of_birth := NEW.`date_of_birth` ;
		SET @alias := NEW.`alias` ;
		SET @job_title := NEW.`job_title` ;
		SET @organization := NEW.`organization` ;
		SET @email := NEW.`email` ;
		SET @tel_1 := NEW.`tel_1` ;
		SET @tel_2 := NEW.`tel_2` ;
		SET @whatsapp := NEW.`whatsapp` ;
		SET @linkedin := NEW.`linkedin` ;
		SET @facebook := NEW.`facebook` ;
		SET @adr1 := NEW.`adr1` ;
		SET @adr2 := NEW.`adr2` ;
		SET @adr3 := NEW.`adr3` ;
		SET @City := NEW.`City` ;
		SET @zip_postcode := NEW.`zip_postcode` ;
		SET @region_or_state := NEW.`region_or_state` ;
		SET @country := NEW.`country` ;
		
		# We Update the record in the table `persons`

			INSERT INTO `persons`
				(`external_id`
				, `external_system` 
				, `external_table`
				, `syst_created_datetime`
				, `creation_system_id`
				, `created_by_id`
				, `creation_method`
				, `organization_id`
				, `person_status_id`
				, `dupe_id`
				, `handler_id`
				, `is_unee_t_account_needed`
				, `unee_t_user_type_id`
				, `country_code`
				, `gender`
				, `given_name`
				, `middle_name`
				, `family_name`
				, `date_of_birth`
				, `alias`
				, `job_title`
				, `organization`
				, `email`
				, `tel_1`
				, `tel_2`
				, `whatsapp`
				, `linkedin`
				, `facebook`
				, `adr1`
				, `adr2`
				, `adr3`
				, `City`
				, `zip_postcode`
				, `region_or_state`
				, `country`
				)
				VALUES
					(@external_id
					, @external_system
					, @external_table
					, @syst_created_datetime
					, @creation_system_id
					, @created_by_id
					, 'person_update_method_5'
					, @organization_id_update
					, @person_status_id
					, @dupe_id
					, @handler_id
					, @is_unee_t_account_needed
					, @unee_t_user_type_id
					, @country_code
					, @gender
					, @given_name
					, @middle_name
					, @family_name
					, @date_of_birth
					, @alias
					, @job_title
					, @organization
					, @email
					, @tel_1
					, @tel_2
					, @whatsapp
					, @linkedin
					, @facebook
					, @adr1
					, @adr2
					, @adr3
					, @City
					, @zip_postcode
					, @region_or_state
					, @country
					)
				ON DUPLICATE KEY UPDATE
					`syst_updated_datetime` := @syst_updated_datetime
					, `update_system_id` := @update_system_id
					, `updated_by_id` := @updated_by_id
					, `update_method` := 'person_update_method_6'
					, `organization_id` := @organization_id_update
					, `person_status_id` := @person_status_id
					, `dupe_id` := @dupe_id
					, `handler_id` := @handler_id
					, `is_unee_t_account_needed` := @is_unee_t_account_needed
					, `unee_t_user_type_id` := @unee_t_user_type_id
					, `country_code` := @country_code
					, `gender` := @gender
					, `given_name` := @given_name
					, `middle_name` := @middle_name
					, `family_name` := @family_name
					, `date_of_birth` := @date_of_birth
					, `alias` := @alias
					, `job_title` := @job_title
					, `organization` := @organization
					, `email` := @email
					, `tel_1` := @tel_1
					, `tel_2` := @tel_2
					, `whatsapp` := @whatsapp
					, `linkedin` := @linkedin
					, `facebook` := @facebook
					, `adr1` := @adr1
					, `adr2` := @adr2
					, `adr3` := @adr3
					, `City` := @City
					, `zip_postcode` := @zip_postcode
					, `region_or_state` := @region_or_state
					, `country` := @country
				;

		# We check if we need to create this user in the table `ut_map_external_source_users`
		
			SET @new_is_unee_t_account_needed_up_2 := NEW.`is_unee_t_account_needed`;
			SET @old_is_unee_t_account_needed_up_2 := OLD.`is_unee_t_account_needed`;

			SET @uneet_login_name := @email ;
	
			SET @is_update_needed_up_2 := 1 ;

			SET @person_id_up_2 := (SELECT `id_person` 
				FROM `persons`
				WHERE `external_id` = @external_id
					AND `external_system` = @external_system
					AND `external_table` = @external_table
					AND `organization_id` = @organization_id_update
				)
				;

			SET @mefe_user_id := (SELECT `unee_t_mefe_user_id`
				FROM `ut_map_external_source_users`
				WHERE `external_person_id` = @external_id
					AND `external_system` = @external_system
					AND `table_in_external_system` = @external_table
					AND `organization_id` = @organization_id_update
				)
				;

		SET @record_in_table = (SELECT `id_map` 
			FROM `ut_map_external_source_users`
			WHERE `external_person_id` = @external_id
				AND `external_system` = @external_system
				AND `table_in_external_system` = @external_table
				AND `organization_id` = @organization_id_update
			)
			;

			IF @is_unee_t_account_needed = 1 
				AND @mefe_user_id IS NULL
				AND @email IS NOT NULL
			THEN 

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
						(@syst_created_datetime
						, @creation_system_id
						, @created_by_id
						, 'person_update_method_7'
						, @organization_id_update
						, @is_update_needed
						, @person_id_up_2
						, @uneet_login_name
						, @external_id
						, @external_system
						, @external_table
						)
						ON DUPLICATE KEY UPDATE
							`syst_updated_datetime` := @syst_created_datetime
							, `update_system_id` := @creation_system_id
							, `updated_by_id` := @created_by_id
							, `update_method` := 'person_update_method_8'
							, `organization_id` := @organization_id_update
							, `uneet_login_name` := @uneet_login_name
							, `is_update_needed` := @is_update_needed_up_2
					;

			ELSEIF @is_unee_t_account_needed = 1
				AND @mefe_user_id IS NOT NULL
				AND @record_in_table IS NOT NULL
				AND @email IS NOT NULL
			THEN 

			SET @requestor_id := @updated_by_id ;

			SET @person_id := (SELECT `id_person` 
				FROM `persons`
				WHERE `external_id` = @external_id
					AND `external_system` = @external_system
					AND `external_table` = @external_table
					AND `organization_id` = @organization_id_update
				)
				;

			# We update the existing record in the table `ut_map_external_source_users`

				UPDATE `ut_map_external_source_users`
					SET
						`syst_updated_datetime` := @syst_updated_datetime
						, `update_system_id` := @update_system_id
						, `updated_by_id` := @updated_by_id
						, `update_method` := 'person_update_method_9'
						, `organization_id` := @organization_id_update
						, `is_update_needed` := @is_update_needed_up_2
						, `uneet_login_name` := @uneet_login_name
					WHERE `person_id` = @person_id
					;

			# We call the procedure that calls the lambda to update the user record in Unee-T
			# This procedure needs to following variables:
			#	- @requestor_id : the MEFE user Id for the generic user for the organization
			#	- @person_id : Id for the person we are updating.

				CALL `ut_update_user`;

			# We check if the new status of the user is active or not.

				SET @check_if_active_person_status := (SELECT `is_active`
					FROM `person_statuses`
					WHERE `id_person_status` = @new_person_status_id
					);

			# IF this is an INACTIVE status, THEN we remove the user from all the units.

				IF @check_if_active_person_status = 0
				THEN

					# A user might exist in different organization, we do this ONLY for untis in this organization!
					# We remove the user from all the Level 1 properties:

						DELETE `external_map_user_unit_role_permissions_level_1` 
						FROM `external_map_user_unit_role_permissions_level_1`
						WHERE 
							`external_map_user_unit_role_permissions_level_1`.`unee_t_mefe_user_id` = @mefe_user_id
							AND `organization_id` = @organization_id_update
							;

					# We remove the user from all the Level 2 properties:
						DELETE `external_map_user_unit_role_permissions_level_2` 
						FROM `external_map_user_unit_role_permissions_level_2`
						WHERE 
							`external_map_user_unit_role_permissions_level_2`.`unee_t_mefe_user_id` = @mefe_user_id
							AND `organization_id` = @organization_id_update
							;

					# We remove the user from all the Level 3 properties:

						DELETE `external_map_user_unit_role_permissions_level_3`
						FROM `external_map_user_unit_role_permissions_level_3`
						WHERE 
							`external_map_user_unit_role_permissions_level_3`.`unee_t_mefe_user_id` = @mefe_user_id
							AND `organization_id` = @organization_id_update
							;
			# IF this is an ACTIVE status, THEN we add the user to all the unit he/she belongs to.

				ELSEIF @check_if_active_person_status = 1
				THEN

					# We call the procedure to check and assign all properties to this user if needed
					# This procedure needs the following variables:
					#	- @requestor_id : the MEFE user Id for the generic user for the organization
					#	- @person_id : Id for the person we are updating.
					#
					# The procedure will check if the new user_type for this user 
					# grants access to all the units in the organization
					# if this is true then we will assign this user to all the units in the organization

						SET @person_id = (SELECT `id_person` 
							FROM `persons`
							WHERE `external_id` = @external_id
								AND `external_system` = @external_system
								AND `external_table` = @external_table
								AND `organization_id` = @organization_id_update
							)
							;
						SET @requestor_id = @updater_mefe_user_id_person_update_1;

						CALL `ut_bulk_assign_units_to_a_user` ;

				END IF;

			END IF;

	END IF;
END;
$$
DELIMITER ;


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
#		- 'ut_insert_external_property_level_1'
#		- 'ut_update_external_property_level_1'
#		- 'ut_update_external_property_level_1_creation_needed'
#		- ''
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
		AND (@upstream_create_method_insert_l1 = 'ut_insert_external_property_level_1'
			OR @upstream_update_method_insert_l1 = 'ut_insert_external_property_level_1'
			OR @upstream_create_method_insert_l1 = 'ut_update_external_property_level_1'
			OR @upstream_update_method_insert_l1 = 'ut_update_external_property_level_1'
			OR @upstream_create_method_insert_l1 = 'ut_update_external_property_level_1_creation_needed'
			OR @upstream_update_method_insert_l1 = 'ut_update_external_property_level_1_creation_needed'
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
#		- `ut_insert_external_property_level_1`
#		- 'ut_update_external_property_level_1_creation_needed'

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

	IF (@upstream_create_method_update_l1 = 'ut_insert_external_property_level_1'
			OR @upstream_update_method_update_l1 = 'ut_insert_external_property_level_1'
			OR @upstream_create_method_update_l1 = 'ut_update_external_property_level_1_creation_needed'
			OR @upstream_update_method_update_l1 = 'ut_update_external_property_level_1_creation_needed'
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


#################
#
# This is part 8
# Remove a user from a role
#
#################


# Remove a user from an area 
#	- Delete the records in the table
#		- `external_map_user_unit_role_permissions_level_1`
#

	DROP TRIGGER IF EXISTS `ut_delete_user_from_role_in_an_area`;

DELIMITER $$
CREATE TRIGGER `ut_delete_user_from_role_in_an_area`
AFTER DELETE ON `external_map_user_unit_role_permissions_areas`
FOR EACH ROW
BEGIN

# We only do this if:
#	- This is a valid method of deletion ???

	IF 1=1
	THEN 

		# We delete the record in the tables that are visible in the Unee-T Enterprise interface

			SET @deleted_area_id := OLD.`unee_t_area_id` ;
			SET @deleted_mefe_user_id := OLD.`unee_t_mefe_user_id` ;

			DELETE `external_map_user_unit_role_permissions_level_1` 
			FROM `external_map_user_unit_role_permissions_level_1`
			INNER JOIN `ut_list_mefe_unit_id_level_1_by_area`
				ON (`ut_list_mefe_unit_id_level_1_by_area`.`level_1_building_id` 
				= `external_map_user_unit_role_permissions_level_1`.`unee_t_level_1_id`)
			WHERE 
				`external_map_user_unit_role_permissions_level_1`.`unee_t_mefe_user_id` = @deleted_mefe_user_id
				AND `ut_list_mefe_unit_id_level_1_by_area`.`id_area` = @deleted_area_id
				;

	END IF;
END;
$$
DELIMITER ;

# Remove a user from a Level 1 property (building)
# 	- Delete the records in the table
#		- `external_map_user_unit_role_permissions_level_2`
#		- `ut_map_user_permissions_unit_level_1`
#	- Update the table:
#		 - `ut_map_user_permissions_unit_all`
#	- Call the procedure to remove a user from a role in a unit
#		- `ut_remove_user_from_unit`

	DROP TRIGGER IF EXISTS `ut_delete_user_from_role_in_a_level_1_property`;

DELIMITER $$
CREATE TRIGGER `ut_delete_user_from_role_in_a_level_1_property`
AFTER DELETE ON `external_map_user_unit_role_permissions_level_1`
FOR EACH ROW
BEGIN

# We only do this if:
#	- This is a valid method of deletion ???

	IF 1=1
	THEN 

		SET @deleted_level_1_id := OLD.`unee_t_level_1_id` ;
		SET @deleted_mefe_user_id := OLD.`unee_t_mefe_user_id` ;
		SET @organization_id := OLD.`created_by_id` ;

		DELETE `external_map_user_unit_role_permissions_level_2` 
		FROM `external_map_user_unit_role_permissions_level_2`
		INNER JOIN `ut_list_mefe_unit_id_level_2_by_area`
			ON (`ut_list_mefe_unit_id_level_2_by_area`.`level_2_unit_id` = `external_map_user_unit_role_permissions_level_2`.`unee_t_level_2_id`)
		WHERE 
			`external_map_user_unit_role_permissions_level_2`.`unee_t_mefe_user_id` = @deleted_mefe_user_id
			AND `ut_list_mefe_unit_id_level_2_by_area`.`level_1_building_id` = @deleted_level_1_id
			;

		# We need several variables:

			SET @this_trigger := 'ut_delete_user_from_role_in_a_level_1_property';

			SET @syst_updated_datetime := NOW() ;
			SET @update_system_id := 2 ;
			SET @updated_by_id := (SELECT `mefe_user_id`
				FROM `ut_api_keys`
				WHERE `organization_id` = @organization_id
				) ;
			SET @update_method := @this_trigger ;

			SET @unee_t_mefe_user_id := @deleted_mefe_user_id ;

			SET @unee_t_mefe_unit_id_l1 := (SELECT `unee_t_mefe_unit_id`
				FROM `ut_list_mefe_unit_id_level_1_by_area`
				WHERE `level_1_building_id` = @deleted_level_1_id
				);
			
			SET @is_obsolete := 1 ;

		# We call the procedure that will activate the MEFE API to remove a user from a unit.
		# This procedure needs the following variables:
		#	- @unee_t_mefe_id
		#	- @unee_t_unit_id
		#	- @is_obsolete
		#	- @update_method
		#	- @update_system_id
		#	- @updated_by_id
		#	- @disable_lambda != 1

			SET @unee_t_mefe_id := @unee_t_mefe_user_id ;
			SET @unee_t_unit_id := @unee_t_mefe_unit_id_l1 ;

		# We call the lambda

			CALL `ut_remove_user_from_unit` ;

		# We call the procedure to delete the relationship from the Unee-T Enterprise Db 

			CALL `remove_user_from_role_unit_level_1` ;

	END IF;
END;
$$
DELIMITER ;

# We create the procedures to remove the records from the table `ut_map_user_permissions_unit_level_1`

	DROP PROCEDURE IF EXISTS `remove_user_from_role_unit_level_1` ;

DELIMITER $$
CREATE PROCEDURE `remove_user_from_role_unit_level_1` ()
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN

# This Procedure needs the following variables:
#	- @unee_t_mefe_user_id
#	- @unee_t_mefe_unit_id_l1

		# We delete the relation user/unit in the `ut_map_user_permissions_unit_level_1`

			DELETE `ut_map_user_permissions_unit_level_1` 
			FROM `ut_map_user_permissions_unit_level_1`
				WHERE `unee_t_mefe_id` = @unee_t_mefe_user_id
					AND `unee_t_unit_id` = @unee_t_mefe_unit_id_l1
					;

		# We delete the relation user/unit in the table `ut_map_user_permissions_unit_all`

			DELETE `ut_map_user_permissions_unit_all` 
			FROM `ut_map_user_permissions_unit_all`
				WHERE `unee_t_mefe_id` = @unee_t_mefe_user_id
					AND `unee_t_unit_id` = @unee_t_mefe_unit_id_l1
					;

END;
$$
DELIMITER ;

# Remove a user from a Level 2 property (unit)
# 	- Delete the records in the table
#		- `external_map_user_unit_role_permissions_level_3`
#		- `ut_map_user_permissions_unit_level_2`
#	- Update the table:
#		- `ut_map_user_permissions_unit_all`
#	- Call the procedure to remove a user from a role in a unit
#		- `ut_remove_user_from_unit`

	DROP TRIGGER IF EXISTS `ut_delete_user_from_role_in_a_level_2_property`;

DELIMITER $$
CREATE TRIGGER `ut_delete_user_from_role_in_a_level_2_property`
AFTER DELETE ON `external_map_user_unit_role_permissions_level_2`
FOR EACH ROW
BEGIN

# We only do this if:
#	- This is a valid method of deletion ???

	IF 1=1
	THEN 

		SET @deleted_level_2_id := OLD.`unee_t_level_2_id` ;
		SET @deleted_mefe_user_id := OLD.`unee_t_mefe_user_id` ;
		SET @organization_id := OLD.`creation_system_id` ;

		DELETE `external_map_user_unit_role_permissions_level_3` 
		FROM `external_map_user_unit_role_permissions_level_3`
		INNER JOIN `ut_list_mefe_unit_id_level_3_by_area`
			ON (`ut_list_mefe_unit_id_level_3_by_area`.`level_3_room_id` = `external_map_user_unit_role_permissions_level_3`.`unee_t_level_3_id`)
		WHERE 
			`external_map_user_unit_role_permissions_level_3`.`unee_t_mefe_user_id` = @deleted_mefe_user_id
			AND `ut_list_mefe_unit_id_level_3_by_area`.`level_2_unit_id` = @deleted_level_2_id
			;

		# We need several variables:

			SET @this_trigger := 'ut_delete_user_from_role_in_a_level_2_property';

			SET @syst_updated_datetime := NOW() ;
			SET @update_system_id := 2 ;
			SET @updated_by_id := (SELECT `mefe_user_id`
				FROM `ut_api_keys`
				WHERE `organization_id` = @organization_id
				) ;
			SET @update_method := @this_trigger ;

			SET @unee_t_mefe_user_id := @deleted_mefe_user_id ;

			SET @unee_t_mefe_unit_id_l2 := (SELECT `unee_t_mefe_unit_id`
				FROM `ut_list_mefe_unit_id_level_2_by_area`
				WHERE `level_2_unit_id` = @deleted_level_2_id
				);
			
			SET @is_obsolete := 1 ;

		# We call the procedure that will activate the MEFE API to remove a user from a unit.
		# This procedure needs the following variables:
		#	- @unee_t_mefe_id
		#	- @unee_t_unit_id
		#	- @is_obsolete
		#	- @update_method
		#	- @update_system_id
		#	- @updated_by_id
		#	- @disable_lambda != 1

			SET @unee_t_mefe_id := @unee_t_mefe_user_id ;
			SET @unee_t_unit_id := @unee_t_mefe_unit_id_l2 ;

		# We call the lambda

			CALL `ut_remove_user_from_unit` ;

		# We call the procedure to delete the relationship from the Unee-T Enterprise Db 

			CALL `remove_user_from_role_unit_level_2` ;

	END IF;
END;
$$
DELIMITER ;

# We create the procedures to remove the records from the table `ut_map_user_permissions_unit_level_2`

	DROP PROCEDURE IF EXISTS `remove_user_from_role_unit_level_2`;

DELIMITER $$
CREATE PROCEDURE `remove_user_from_role_unit_level_2` ()
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN

# This Procedure needs the following variables:
#	- @unee_t_mefe_user_id
#	- @unee_t_mefe_unit_id_l2

		# We delete the relation user/unit in the `ut_map_user_permissions_unit_level_2`

			DELETE `ut_map_user_permissions_unit_level_2` 
			FROM `ut_map_user_permissions_unit_level_2`
				WHERE `unee_t_mefe_id` = @unee_t_mefe_user_id
					AND `unee_t_unit_id` = @unee_t_mefe_unit_id_l2
					;

		# We delete the relation user/unit in the table `ut_map_user_permissions_unit_all`

			DELETE `ut_map_user_permissions_unit_all` 
			FROM `ut_map_user_permissions_unit_all`
				WHERE `unee_t_mefe_id` = @unee_t_mefe_user_id
					AND `unee_t_unit_id` = @unee_t_mefe_unit_id_l2
					;

END;
$$
DELIMITER ;

# Remove a user from a Level 3 property (rooms)
# 	- Delete the records in the table
#		- `ut_map_user_permissions_unit_level_3`
#	- Update the table:
#		 - `ut_map_user_permissions_unit_all`
#	- Call the procedure to remove a user from a role in a unit
#		- `ut_remove_user_from_unit`

			DROP TRIGGER IF EXISTS `ut_delete_user_from_role_in_a_level_3_property`;

DELIMITER $$
CREATE TRIGGER `ut_delete_user_from_role_in_a_level_3_property`
AFTER DELETE ON `external_map_user_unit_role_permissions_level_3`
FOR EACH ROW
BEGIN

# We only do this if:
#	- This is a valid method of deletion ???

	IF 1=1
	THEN 

		SET @deleted_level_3_id := OLD.`unee_t_level_3_id` ;
		SET @deleted_mefe_user_id := OLD.`unee_t_mefe_user_id` ;
		SET @organization_id := OLD.`creation_system_id` ;

		# We need several variables:

			SET @this_trigger := 'ut_delete_user_from_role_in_a_level_3_property';

			SET @syst_updated_datetime := NOW() ;
			SET @update_system_id := 2 ;
			SET @updated_by_id := (SELECT `mefe_user_id`
				FROM `ut_api_keys`
				WHERE `organization_id` = @organization_id
				) ;
			SET @update_method := @this_trigger ;

			SET @unee_t_mefe_user_id := @deleted_mefe_user_id ;

			SET @unee_t_mefe_unit_id_l3 := (SELECT `unee_t_mefe_unit_id`
				FROM `ut_list_mefe_unit_id_level_3_by_area`
				WHERE `level_3_room_id` = @deleted_level_3_id
				);
			
			SET @is_obsolete := 1 ;

		# We call the procedure that will activate the MEFE API to remove a user from a unit.
		# This procedure needs the following variables:
		#	- @unee_t_mefe_id
		#	- @unee_t_unit_id
		#	- @is_obsolete
		#	- @update_method
		#	- @update_system_id
		#	- @updated_by_id
		#	- @disable_lambda != 1

			SET @unee_t_mefe_id := @unee_t_mefe_user_id ;
			SET @unee_t_unit_id := @unee_t_mefe_unit_id_l3 ;

		# We call the lambda

			CALL `ut_remove_user_from_unit` ;

		# We call the procedure to delete the relationship from the Unee-T Enterprise Db 

			CALL `remove_user_from_role_unit_level_3` ;

	END IF;
END;
$$
DELIMITER ;

# We create the procedures to remove the records from the table `ut_map_user_permissions_unit_level_3`

	DROP PROCEDURE IF EXISTS `remove_user_from_role_unit_level_3`;

DELIMITER $$
CREATE PROCEDURE `remove_user_from_role_unit_level_3` ()
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN

# This Procedure needs the following variables:
#	- @unee_t_mefe_user_id
#	- @unee_t_mefe_unit_id_l3

		# We delete the relation user/unit in the `ut_map_user_permissions_unit_level_3`

			DELETE `ut_map_user_permissions_unit_level_3` 
			FROM `ut_map_user_permissions_unit_level_3`
				WHERE (`unee_t_mefe_id` = @unee_t_mefe_user_id
					AND `unee_t_unit_id` = @unee_t_mefe_unit_id_l3)
					;

		# We delete the relation user/unit in the table `ut_map_user_permissions_unit_all`

			DELETE `ut_map_user_permissions_unit_all` 
			FROM `ut_map_user_permissions_unit_all`
				WHERE `unee_t_mefe_id` = @unee_t_mefe_user_id
					AND `unee_t_unit_id` = @unee_t_mefe_unit_id_l3
					;

END;
$$
DELIMITER ;

#################
#
# This lists all the triggers we use to create 
# a property_level_3
# via the Unee-T Enterprise Interface
#
#################
#
# This script creates or updates the following 
# 	- Procedures: 
#		- `ut_update_L3P_when_ext_L3P_is_updated`
#		- `ut_update_uneet_when_L3P_is_updated`
#	- triggers:
#		- `ut_after_insert_external_property_level_3`
#		- `ut_after_update_external_property_level_3`
#		- `ut_after_update_property_level_3`

# We create a trigger when a record is added to the `external_property_level_3_rooms` table

	DROP TRIGGER IF EXISTS `ut_after_insert_external_property_level_3`;

DELIMITER $$
CREATE TRIGGER `ut_after_insert_external_property_level_3`
AFTER INSERT ON `external_property_level_3_rooms`
FOR EACH ROW
BEGIN

# We only do this if 
#	- We need to create the unit in Unee-T
#	- We have a `external_id`
#	- We have a `external_system_id`
#	- We have a `external_table`
#	- We have a `organization_id`
#	- We have a MEFE user ID for the user who did the update
#	- The room does NOT exists in the table `property_level_3_rooms`
#   - we have a valid unit ID for this room.
#	- This is a valid insert method:
#		- 'imported_from_hmlet_ipi'
#		- 'Manage_Rooms_Add_Page'
#		- 'Manage_Rooms_Edit_Page'
#		- 'Manage_Rooms_Import_Page'
#		- 'Export_and_Import_Rooms_Import_Page'
#		- ''

	SET @is_creation_needed_in_unee_t_insert_extl3_1 = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator_insert_extl3_1 = NEW.`created_by_id` ;

	SET @source_updated_by_id_insert_extl3_1 = NEW.`updated_by_id` ;

	SET @source_system_updater_insert_extl3_1 = (IF(@source_updated_by_id_insert_extl3_ IS NULL
			, @source_system_creator_insert_extl3_1
			, @source_updated_by_id_insert_extl3_
			)
		);

	SET @creator_mefe_user_id_insert_extl3_1 = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator_insert_extl3_1
		)
		;

	SET @upstream_create_method_insert_extl3_1 = NEW.`creation_method` ;
	SET @upstream_update_method_insert_extl3_1 = NEW.`update_method` ;

	SET @organization_id_insert_extl3_1 = @source_system_creator_insert_extl3_1 ;

	SET @external_id_insert_extl3_1 = NEW.`external_id` ;
	SET @external_system_id_insert_extl3_1 = NEW.`external_system_id` ;
	SET @external_table_insert_extl3_1 = NEW.`external_table` ;

	SET @id_in_property_level_3_rooms_insert_extl3_1 = (SELECT `system_id_room`
		FROM `property_level_3_rooms`
		WHERE `external_system_id` = @external_system_id_insert_extl3_1
			AND `external_table` = @external_table_insert_extl3_1
			AND `external_id` = @external_id_insert_extl3_1
			AND `organization_id` = @organization_id_insert_extl3_1
		);
		
	SET @upstream_do_not_insert_insert_extl3_1 = NEW.`do_not_insert` ;

	# This is an INSERT - the record should NOT exist already

		SET @do_not_insert_insert_extl3_1 = (IF (@id_in_property_level_3_rooms_insert_extl3_1 IS NULL
				, 0
				, @upstream_do_not_insert_insert_extl3_1
				)
			
			);

	# Get the information about the unit for that room...
	# We need the information from the table `external_property_level_2_units` (and NOT the table `external_property_level_2_units`)
	
		SET @unit_id_1_insert_extl3_1 = NEW.`system_id_unit` ;

		SET @unit_external_id_insert_extl3_1 = (SELECT `external_id`
			FROM `external_property_level_2_units`
			WHERE `system_id_unit` = @unit_id_1_insert_extl3_1
				);
		SET @unit_external_system_id_insert_extl3_1 = (SELECT `external_system_id`
			FROM `external_property_level_2_units`
			WHERE `system_id_unit` = @unit_id_1_insert_extl3_1
			);
		SET @unit_external_table_insert_extl3_1 = (SELECT `external_table`
		   FROM `external_property_level_2_units`
			WHERE `system_id_unit` = @unit_id_1_insert_extl3_1
			);

		SET @system_id_unit_insert_extl3_1 = (SELECT `system_id_unit`
			FROM `property_level_2_units`
			WHERE `external_id` = @unit_external_id_insert_extl3_1
				AND `external_system_id` = @unit_external_system_id_insert_extl3_1
				AND `external_table` = @unit_external_table_insert_extl3_1
				AND `organization_id` = @organization_id_insert_extl3_1
				);

	IF @is_creation_needed_in_unee_t_insert_extl3_1 = 1
		AND @do_not_insert_insert_extl3_1 = 0
		AND @external_id_insert_extl3_1 IS NOT NULL
		AND @external_system_id_insert_extl3_1 IS NOT NULL
		AND @external_table_insert_extl3_1 IS NOT NULL
		AND @organization_id_insert_extl3_1 IS NOT NULL
		AND @system_id_unit_insert_extl3_1 IS NOT NULL
		AND (@upstream_create_method_insert_extl3_1 = 'imported_from_hmlet_ipi'
			OR @upstream_update_method_insert_extl3_1 = 'imported_from_hmlet_ipi'
			OR @upstream_create_method_insert_extl3_1 = 'Manage_Rooms_Add_Page'
			OR @upstream_update_method_insert_extl3_1 = 'Manage_Rooms_Add_Page'
			OR @upstream_create_method_insert_extl3_1 = 'Manage_Rooms_Edit_Page'
			OR @upstream_update_method_insert_extl3_1 = 'Manage_Rooms_Edit_Page'
			OR @upstream_create_method_insert_extl3_1 = 'Manage_Rooms_Import_Page'
			OR @upstream_update_method_insert_extl3_1 = 'Manage_Rooms_Import_Page'
			OR @upstream_create_method_insert_extl3_1 = 'Export_and_Import_Rooms_Import_Page'
			OR @upstream_update_method_insert_extl3_1 = 'Export_and_Import_Rooms_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `external_property_level_2_units` table:

		SET @this_trigger_insert_extl3_1_insert = 'ut_insert_external_property_level_3_insert' ;
		SET @this_trigger_insert_extl3_1_update = 'ut_insert_external_property_level_3_update' ;

		SET @creation_system_id_insert_extl3_1 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator_insert_extl3_1
			)
			;
		SET @created_by_id_insert_extl3_1 = @creator_mefe_user_id_insert_extl3_1 ;
		SET @downstream_creation_method_insert_extl3_1 = @this_trigger_insert_extl3_1_insert ;

		SET @update_system_id_insert_extl3_1 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater_insert_extl3_1
			)
			;
		SET @updated_by_id_insert_extl3_1 = @creator_mefe_user_id_insert_extl3_1 ;
		SET @downstream_update_method_insert_extl3_1 = @this_trigger_insert_extl3_1_update ;

		SET @organization_id_create_insert_extl3_1 = @source_system_creator_insert_extl3_1 ;
		SET @organization_id_update_insert_extl3_1 = @source_system_updater_insert_extl3_1 ;
		
		SET @is_obsolete_insert_extl3_1 = NEW.`is_obsolete` ;
		SET @is_creation_needed_in_unee_t_insert_extl3_1 = NEW.`is_creation_needed_in_unee_t` ;

		SET @unee_t_unit_type_insert_extl3_1 = NEW.`unee_t_unit_type` ;
			
		SET @room_type_id_insert_extl3_1 = NEW.`room_type_id` ;
		SET @number_of_beds_insert_extl3_1 = NEW.`number_of_beds` ;
		SET @surface_insert_extl3_1 = NEW.`surface` ;
		SET @surface_measurment_unit_insert_extl3_1 = NEW.`surface_measurment_unit` ;
		SET @room_designation_insert_extl3_1 = NEW.`room_designation`;
		SET @room_description_insert_extl3_1 = NEW.`room_description` ;

	# We insert the record in the table `property_level_3_rooms`
	# We do this via INSERT INTO ... ON DUPLICATE KEY UPDATE for maximum safety

		INSERT INTO `property_level_3_rooms`
			(`external_id`
			, `external_system_id` 
			, `external_table`
			, `syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `creation_method`
			, `organization_id`
			, `is_obsolete`
			, `is_creation_needed_in_unee_t`
			, `do_not_insert`
			, `unee_t_unit_type`
			, `system_id_unit`
			, `room_type_id`
			, `surface`
			, `surface_measurment_unit`
			, `room_designation`
			, `room_description`
			)
			VALUES
 				(@external_id_insert_extl3_1
				, @external_system_id_insert_extl3_1
				, @external_table_insert_extl3_1
				, NOW()
				, @creation_system_id_insert_extl3_1
				, @created_by_id_insert_extl3_1
				, @downstream_creation_method_insert_extl3_1
				, @organization_id_create_insert_extl3_1
				, @is_obsolete_insert_extl3_1
				, @is_creation_needed_in_unee_t_insert_extl3_1
				, @do_not_insert_insert_extl3_1
				, @unee_t_unit_type_insert_extl3_1
				, @system_id_unit_insert_extl3_1
				, @room_type_id_insert_extl3_1
				, @surface_insert_extl3_1
				, @surface_measurment_unit_insert_extl3_1
				, @room_designation_insert_extl3_1
				, @room_description_insert_extl3_1
 			)
			ON DUPLICATE KEY UPDATE
 				`syst_updated_datetime` = NOW()
 				, `update_system_id` = @update_system_id_insert_extl3_1
 				, `updated_by_id` = @updated_by_id_insert_extl3_1
				, `update_method` = @downstream_update_method_insert_extl3_1
				, `organization_id` = @organization_id_update_insert_extl3_1
				, `is_obsolete` = @is_obsolete_insert_extl3_1
				, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t_insert_extl3_1
				, `do_not_insert` = @do_not_insert_insert_extl3_1
				, `unee_t_unit_type` = @unee_t_unit_type_insert_extl3_1
				, `system_id_unit` = @system_id_unit_insert_extl3_1
				, `room_type_id` = @room_type_id_insert_extl3_1
				, `surface` = @surface_insert_extl3_1
				, `surface_measurment_unit` = @surface_measurment_unit_insert_extl3_1
				, `room_designation` = @room_designation_insert_extl3_1
				, `room_description` = @room_description_insert_extl3_1
			;

	END IF;

END;
$$
DELIMITER ;

# We create a trigger when a record is updated in the `external_property_level_3_rooms` table
#	- The unit DOES exist in the table `external_property_level_3_rooms`
#	- This is a NOT a new creation request in Unee-T

	DROP TRIGGER IF EXISTS `ut_after_update_external_property_level_3`;

DELIMITER $$
CREATE TRIGGER `ut_after_update_external_property_level_3`
AFTER UPDATE ON `external_property_level_3_rooms`
FOR EACH ROW
BEGIN

# We only do this if 
#	- we need to create the property in Unee-T
#	- We have a `external_id`
#	- We have a `external_system_id`
#	- We have a `external_table`
#	- We have a `organization_id`
#	- We have a MEFE user ID for the user who did the update
#	- The unit already exists in the table `property_level_2_units`
#	- We have a valid building_id for that unit.
#	- The `do_not_insert_field` is NOT equal to 1
#	- This is a valid update method:
#		- `imported_from_hmlet_ipi`
#		- `Manage_Units_Add_Page`
#		- `Manage_Units_Edit_Page`
#		- 'Manage_Units_Import_Page'
#		- 'Export_and_Import_Rooms_Import_Page'

# Capture the variables we need to verify if conditions are met:

	SET @is_creation_needed_in_unee_t_update_extl3 = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator_update_extl3 = NEW.`created_by_id` ;

	SET @source_updated_by_id_update_extl3 = NEW.`updated_by_id` ;

	SET @source_system_updater_update_extl3 = (IF(@source_updated_by_id_update_extl3 IS NULL
			, @source_system_creator_update_extl3
			, @source_updated_by_id_update_extl3
			)
		);

	SET @creator_mefe_user_id_update_extl3 = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator_update_extl3
		)
		;

	SET @upstream_create_method_update_extl3 = NEW.`creation_method` ;
	SET @upstream_update_method_update_extl3 = NEW.`update_method` ;

	SET @organization_id_update_extl3 = @source_system_creator_update_extl3 ;

	SET @external_id_update_extl3 = NEW.`external_id` ;
	SET @external_system_id_update_extl3 = NEW.`external_system_id` ; 
	SET @external_table_update_extl3 = NEW.`external_table` ;

	SET @new_is_creation_needed_in_unee_t_update_extl3 = NEW.`is_creation_needed_in_unee_t` ;
	SET @old_is_creation_needed_in_unee_t_update_extl3 = OLD.`is_creation_needed_in_unee_t` ;

	SET @id_in_property_level_3_rooms_update_extl3 = (SELECT `system_id_room`
		FROM `property_level_3_rooms`
		WHERE `external_system_id` = @external_system_id_update_extl3
			AND `external_table` = @external_table_update_extl3
			AND `external_id` = @external_id_update_extl3
			AND `organization_id` = @organization_id_update_extl3
		);

	SET @upstream_do_not_insert_update_extl3 = NEW.`do_not_insert` ;

	# Get the information about the unit for that room...
	# We need the information from the table `external_property_level_2_units` (and NOT the table `external_property_level_2_units`)
	
		SET @unit_id_1_update_extl3 = NEW.`system_id_unit` ;

		SET @unit_external_id_update_extl3 = (SELECT `external_id`
			FROM `external_property_level_2_units`
			WHERE `system_id_unit` = @unit_id_1_update_extl3
				);
		SET @unit_external_system_id_update_extl3 = (SELECT `external_system_id`
			FROM `external_property_level_2_units`
			WHERE `system_id_unit` = @unit_id_1_update_extl3
			);
		SET @unit_external_table_update_extl3 = (SELECT `external_table`
		   FROM `external_property_level_2_units`
			WHERE `system_id_unit` = @unit_id_1_update_extl3
			);

		SET @system_id_unit_update_extl3 = (SELECT `system_id_unit`
			FROM `property_level_2_units`
			WHERE `external_id` = @unit_external_id_update_extl3
				AND `external_system_id` = @unit_external_system_id_update_extl3
				AND `external_table` = @unit_external_table_update_extl3
				AND `organization_id` = @organization_id_update_extl3
				);

# We can now check if the conditions are met:

	IF @is_creation_needed_in_unee_t_update_extl3 = 1
		AND @upstream_do_not_insert_update_extl3 = 0
		AND @external_id_update_extl3 IS NOT NULL
		AND @external_system_id_update_extl3 IS NOT NULL
		AND @external_table_update_extl3 IS NOT NULL
		AND @organization_id_update_extl3 IS NOT NULL
		AND @system_id_unit_update_extl3 IS NOT NULL
		AND (@upstream_create_method_update_extl3 = 'imported_from_hmlet_ipi'
			OR @upstream_update_method_update_extl3 = 'imported_from_hmlet_ipi'
			OR @upstream_create_method_update_extl3 = 'Manage_Rooms_Add_Page'
			OR @upstream_update_method_update_extl3 = 'Manage_Rooms_Add_Page'
			OR @upstream_create_method_update_extl3 = 'Manage_Rooms_Edit_Page'
			OR @upstream_update_method_update_extl3 = 'Manage_Rooms_Edit_Page'
			OR @upstream_create_method_update_extl3 = 'Manage_Rooms_Import_Page'
			OR @upstream_update_method_update_extl3 = 'Manage_Rooms_Import_Page'
			OR @upstream_create_method_update_extl3 = 'Export_and_Import_Rooms_Import_Page'
			OR @upstream_update_method_update_extl3 = 'Export_and_Import_Rooms_Import_Page'
			)
	THEN 

	# The conditions are met: we capture the other variables we need

		SET @creation_system_id_update_extl3 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator_update_extl3
			)
			;
		SET @created_by_id_update_extl3 = @creator_mefe_user_id_update_extl3 ;

		SET @update_system_id_update_extl3 = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater_update_extl3
			)
			;
		SET @updated_by_id_update_extl3 = @creator_mefe_user_id_update_extl3 ;

		SET @organization_id_create_update_extl3 = @source_system_creator_update_extl3 ;
		SET @organization_id_update_update_extl3 = @source_system_updater_update_extl3 ;

		SET @is_obsolete_update_extl3 = NEW.`is_obsolete` ;
		SET @is_creation_needed_in_unee_t_update_extl3 = NEW.`is_creation_needed_in_unee_t` ;

		SET @unee_t_unit_type_update_extl3 = NEW.`unee_t_unit_type` ;
			
		SET @room_type_id_update_extl3 = NEW.`room_type_id` ;
		SET @number_of_beds_update_extl3 = NEW.`number_of_beds` ;
		SET @surface_update_extl3 = NEW.`surface` ;
		SET @surface_measurment_unit_update_extl3 = NEW.`surface_measurment_unit` ;
		SET @room_designation_update_extl3 = NEW.`room_designation`;
		SET @room_description_update_extl3 = NEW.`room_description` ;

		IF @new_is_creation_needed_in_unee_t_update_extl3 != @old_is_creation_needed_in_unee_t_update_extl3
		THEN 

			# This is option 1 - creation IS needed

				SET @this_trigger_update_ext_l3_insert = 'ut_update_external_property_level_3_creation_needed_insert';
				SET @this_trigger_update_ext_l3_update = 'ut_update_external_property_level_3_creation_needed_update';

				# We insert the record in the table `property_level_3_rooms`
				# We do this via INSERT INTO ... ON DUPLICATE KEY UPDATE for maximum safety

					INSERT INTO `property_level_3_rooms`
						(`external_id`
						, `external_system_id` 
						, `external_table`
						, `syst_created_datetime`
						, `creation_system_id`
						, `created_by_id`
						, `creation_method`
						, `organization_id`
						, `is_obsolete`
						, `is_creation_needed_in_unee_t`
						, `do_not_insert`
						, `unee_t_unit_type`
						, `system_id_unit`
						, `room_type_id`
						, `surface`
						, `surface_measurment_unit`
						, `room_designation`
						, `room_description`
						)
						VALUES
							(@external_id_update_extl3
							, @external_system_id_update_extl3
							, @external_table_update_extl3
							, NOW()
							, @creation_system_id_update_extl3
							, @created_by_id_update_extl3
							, @this_trigger_update_ext_l3_insert
							, @organization_id_create_update_extl3
							, @is_obsolete_update_extl3
							, @is_creation_needed_in_unee_t_update_extl3
							, @do_not_insert_update_extl3
							, @unee_t_unit_type_update_extl3
							, @system_id_unit_update_extl3
							, @room_type_id_update_extl3
							, @surface_update_extl3
							, @surface_measurment_unit_update_extl3
							, @room_designation_update_extl3
							, @room_description_update_extl3
						)
						ON DUPLICATE KEY UPDATE
							`syst_updated_datetime` = NOW()
							, `update_system_id` = @update_system_id_update_extl3
							, `updated_by_id` = @updated_by_id_update_extl3
							, `update_method` = @this_trigger_update_ext_l3_update
							, `organization_id` = @organization_id_update_update_extl3
							, `is_obsolete` = @is_obsolete_update_extl3
							, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t_update_extl3
							, `do_not_insert` = @do_not_insert_update_extl3
							, `unee_t_unit_type` = @unee_t_unit_type_update_extl3
							, `system_id_unit` = @system_id_unit_update_extl3
							, `room_type_id` = @room_type_id_update_extl3
							, `surface` = @surface_update_extl3
							, `surface_measurment_unit` = @surface_measurment_unit_update_extl3
							, `room_designation` = @room_designation_update_extl3
							, `room_description` = @room_description_update_extl3
						;

		ELSEIF @new_is_creation_needed_in_unee_t_update_extl3 = @old_is_creation_needed_in_unee_t_update_extl3
		THEN 
			
			# This is option 2 creation is NOT needed

				SET @this_trigger_update_ext_l3_insert = 'ut_update_external_property_level_3_insert';
				SET @this_trigger_update_ext_l3_update = 'ut_update_external_property_level_3_update';

				# We insert the record in the table `property_level_3_rooms`
				# We do this via INSERT INTO ... ON DUPLICATE KEY UPDATE for maximum safety

					INSERT INTO `property_level_3_rooms`
						(`external_id`
						, `external_system_id` 
						, `external_table`
						, `syst_created_datetime`
						, `creation_system_id`
						, `created_by_id`
						, `creation_method`
						, `organization_id`
						, `is_obsolete`
						, `is_creation_needed_in_unee_t`
						, `do_not_insert`
						, `unee_t_unit_type`
						, `system_id_unit`
						, `room_type_id`
						, `surface`
						, `surface_measurment_unit`
						, `room_designation`
						, `room_description`
						)
						VALUES
							(@external_id_update_extl3
							, @external_system_id_update_extl3
							, @external_table_update_extl3
							, NOW()
							, @creation_system_id_update_extl3
							, @created_by_id_update_extl3
							, @this_trigger_update_ext_l3_insert
							, @organization_id_create_update_extl3
							, @is_obsolete_update_extl3
							, @is_creation_needed_in_unee_t_update_extl3
							, @do_not_insert_update_extl3
							, @unee_t_unit_type_update_extl3
							, @system_id_unit_update_extl3
							, @room_type_id_update_extl3
							, @surface_update_extl3
							, @surface_measurment_unit_update_extl3
							, @room_designation_update_extl3
							, @room_description_update_extl3
						)
						ON DUPLICATE KEY UPDATE
							`syst_updated_datetime` = NOW()
							, `update_system_id` = @update_system_id_update_extl3
							, `updated_by_id` = @updated_by_id_update_extl3
							, `update_method` = @this_trigger_update_ext_l3_update
							, `organization_id` = @organization_id_update_update_extl3
							, `is_obsolete` = @is_obsolete_update_extl3
							, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t_update_extl3
							, `do_not_insert` = @do_not_insert_update_extl3
							, `unee_t_unit_type` = @unee_t_unit_type_update_extl3
							, `system_id_unit` = @system_id_unit_update_extl3
							, `room_type_id` = @room_type_id_update_extl3
							, `surface` = @surface_update_extl3
							, `surface_measurment_unit` = @surface_measurment_unit_update_extl3
							, `room_designation` = @room_designation_update_extl3
							, `room_description` = @room_description_update_extl3
						;

		END IF;

	# The conditions are NOT met <-- we do nothing

	END IF;

END;
$$
DELIMITER ;

# Create a trigger to update the table that will fire the lambda each time a new Room needs to be created

	DROP TRIGGER IF EXISTS `ut_after_insert_property_level_3`;

DELIMITER $$
CREATE TRIGGER `ut_after_insert_property_level_3`
AFTER INSERT ON `property_level_3_rooms`
FOR EACH ROW
BEGIN

# We do this ONLY IF 
#	- We have marked the property as an object we need to create in Unee-T
#	- The record does NOT exist in the table `ut_map_external_source_units` yet
#	- This is done via an authorized insert method:
#		- 'ut_insert_external_property_level_3_insert'
#		- 'ut_insert_external_property_level_3_update'
#		- 'ut_update_external_property_level_3'
#		- 'ut_update_external_property_level_3_creation_needed'
#		- ''
#
	SET @is_creation_needed_in_unee_t_insert_l3 = NEW.`is_creation_needed_in_unee_t` ;

	SET @external_property_id_insert_l3 = NEW.`external_id` ;
	SET @external_system_insert_l3 = NEW.`external_system_id` ;
	SET @table_in_external_system_insert_l3 = NEW.`external_table` ;
	SET @organization_id_insert_l3 = NEW.`organization_id`;

	SET @id_in_ut_map_external_source_units_insert_l3 = (SELECT `id_map`
		FROM `ut_map_external_source_units`
		WHERE `external_system` = @external_system_insert_l3
			AND `table_in_external_system` = @table_in_external_system_insert_l3
			AND `external_property_id` = @external_property_id_insert_l3
			AND `organization_id` = @organization_id_insert_l3
			AND `external_property_type_id` = 3
		);

	# This is an insert - if the record does NOT exist, we create the record
	# unless 
	#	- it is specifically specified that we do NOT need to create the record.
	#	- the record is marked as obsolete

		SET @is_obsolete_insert_l3 = NEW.`is_obsolete`;

		SET @do_not_insert_insert_l3_raw = NEW.`do_not_insert` ;

		SET @do_not_insert_insert_l3 = (IF (@id_in_ut_map_external_source_units_insert_l3 IS NULL
				, IF (@is_obsolete_insert_l3 != 0
					, 1
					, 0
					)
				, IF (@is_obsolete_insert_l3 != 0
					, 1
					, @do_not_insert_insert_l3_raw
					)
				)
			);

	SET @upstream_create_method_insert_l3 = NEW.`creation_method` ;
	SET @upstream_update_method_insert_l3 = NEW.`update_method` ;

	IF @is_creation_needed_in_unee_t_insert_l3 = 1
		AND @do_not_insert_insert_l3 = 0
		AND (@upstream_create_method_insert_l3 = 'ut_insert_external_property_level_3_insert'
			OR @upstream_update_method_insert_l3 = 'ut_insert_external_property_level_3_update'
			OR @upstream_create_method_insert_l3 = 'ut_update_external_property_level_3'
			OR @upstream_update_method_insert_l3 = 'ut_update_external_property_level_3'
			OR @upstream_create_method_insert_l3 = 'ut_update_external_property_level_3_creation_needed'
			OR @upstream_update_method_insert_l3 = 'ut_update_external_property_level_3_creation_needed'
			)
	THEN 

	# We capture the values we need for the insert/udpate:

		SET @this_trigger_insert_l3_insert = 'ut_insert_map_external_source_unit_add_room_insert' ;
		SET @this_trigger_insert_l3_update = 'ut_insert_map_external_source_unit_add_room_update' ;

		SET @creation_system_id_insert_l3 = NEW.`creation_system_id`;
		SET @created_by_id_insert_l3 = NEW.`created_by_id`;

		SET @update_system_id_insert_l3 = NEW.`creation_system_id`;
		SET @updated_by_id_insert_l3 = NEW.`created_by_id`;
			
		SET @is_update_needed_insert_l3 = NULL;
			
		SET @uneet_name_insert_l3 = NEW.`room_designation`;

		SET @unee_t_unit_type_insert_l3_raw = NEW.`unee_t_unit_type` ;

		SET @unee_t_unit_type_insert_l3 = (IFNULL(@unee_t_unit_type_insert_l3_raw
				, 'Unknown'
				)
			)
			;
		
		SET @new_record_id_insert_l3 = NEW.`system_id_room`;
		SET @external_property_type_id_insert_l3 = 3;	

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
				)
				VALUES
					(NOW()
					, @creation_system_id_insert_l3
					, @created_by_id_insert_l3
					, @this_trigger_insert_l3_insert
					, @organization_id_insert_l3
					, @is_obsolete_insert_l3
					, @is_update_needed_insert_l3
					, @uneet_name_insert_l3
					, @unee_t_unit_type_insert_l3
					, @new_record_id_insert_l3
					, @external_property_type_id_insert_l3
					, @external_property_id_insert_l3
					, @external_system_insert_l3
					, @table_in_external_system_insert_l3
					)
				ON DUPLICATE KEY UPDATE 
					`syst_updated_datetime` = NOW()
					, `update_system_id` = @update_system_id_insert_l3
					, `updated_by_id` = @updated_by_id_insert_l3
					, `update_method` = @this_trigger_insert_l3_update
					, `organization_id` = @organization_id_insert_l3
					, `uneet_name` = @uneet_name_insert_l3
					, `unee_t_unit_type` = @unee_t_unit_type_insert_l3
					, `is_update_needed` = 1
				;

	END IF;
END;
$$
DELIMITER ;

# Create the trigger when the L3P is updated
# This trigger will:
#	- Check if several conditions are met
#	- Capture the value we need in several variables
#	- Call the procedure `ut_update_uneet_when_L3P_is_updated` if needed.

	DROP TRIGGER IF EXISTS `ut_after_update_property_level_3`;

DELIMITER $$
CREATE TRIGGER `ut_after_update_property_level_3`
AFTER UPDATE ON `property_level_3_rooms`
FOR EACH ROW
BEGIN

# We only do this IF:
# 	- We need to create the unit in Unee-T
# 	- We need to update the unit in Unee-T
#	- This is done via an authorized insert or update method:
#		- 'ut_insert_external_property_level_3_insert'
#		- 'ut_insert_external_property_level_3_update'
#		- 'ut_update_map_external_source_unit_add_room_creation_needed'
#		- 'ut_update_map_external_source_unit_edit_level_3'

# Capture the variables we need to verify if conditions are met:

	SET @upstream_create_method_update_l3 = NEW.`creation_method` ;
	SET @upstream_update_method_update_l3 = NEW.`update_method` ;

# We can now check if the conditions are met:

	IF (@upstream_create_method_update_l3 = 'ut_insert_external_property_level_3_insert'
			OR @upstream_update_method_update_l3 = 'ut_insert_external_property_level_3_update'
			OR @upstream_create_method_update_l3 = 'ut_update_map_external_source_unit_add_room_creation_needed'
			OR @upstream_update_method_update_l3 = 'ut_update_map_external_source_unit_add_room_creation_needed'
			OR @upstream_create_method_update_l3 = 'ut_update_map_external_source_unit_edit_level_3'
			OR @upstream_update_method_update_l3 = 'ut_update_map_external_source_unit_edit_level_3'
			)
	THEN 

	# The conditions are met: we capture the other variables we need

		SET @system_id_room_update_l3 = NEW.`system_id_room` ;

		SET @creation_system_id_update_l3 = NEW.`update_system_id`;
		SET @created_by_id_update_l3 = NEW.`updated_by_id`;

		SET @update_system_id_update_l3 = NEW.`update_system_id`;
		SET @updated_by_id_update_l3 = NEW.`updated_by_id`;

		SET @organization_id_update_l3 = NEW.`organization_id`;
		
		SET @is_update_needed_update_l3 = NULL;
			
		SET @uneet_name_update_l3 = NEW.`room_designation`;

		SET @unee_t_unit_type_update_l3_raw = NEW.`unee_t_unit_type` ;

		SET @unee_t_unit_type_update_l3 = (IFNULL(@unee_t_unit_type_update_l3_raw
				, 'Unknown'
				)
			)
			;
			
		SET @new_record_id_update_l3 = NEW.`system_id_room`;
		SET @external_property_type_id_update_l3 = 3;

		SET @external_property_id_update_l3 = NEW.`external_id`;
		SET @external_system_update_l3 = NEW.`external_system_id`;
		SET @table_in_external_system_update_l3 = NEW.`external_table`;	

		SET @mefe_unit_id_update_l3 = NULL ;

		SET @mefe_unit_id_update_l3 = (SELECT `unee_t_mefe_unit_id`
			FROM `ut_map_external_source_units`
			WHERE `new_record_id` = @system_id_room_update_l3
				AND `external_property_type_id` = 3
				AND `unee_t_mefe_unit_id` IS NOT NULL
			);

		# If the record does NOT exist, we create the record
		# unless 
		#	- it is specifically specified that we do NOT need to create the record.
		#	- the record is marked as obsolete

		SET @is_creation_needed_in_unee_t_update_l3 = NEW.`is_creation_needed_in_unee_t`;

		SET @new_is_creation_needed_in_unee_t_update_l3 = NEW.`is_creation_needed_in_unee_t`;
		SET @old_is_creation_needed_in_unee_t_update_l3 = OLD.`is_creation_needed_in_unee_t`;

		SET @do_not_insert_update_l3_raw = NEW.`do_not_insert` ;

		SET @is_obsolete_update_l3 = NEW.`is_obsolete`;

		SET @do_not_insert_update_l3 = (IF (@do_not_insert_update_l3_raw IS NULL
				, IF (@is_obsolete_update_l3 != 0
					, 1
					, 0
					)
				, IF (@is_obsolete_update_l3 != 0
					, 1
					, @do_not_insert_update_l3_raw
					)
				)
			);

		IF @is_creation_needed_in_unee_t_update_l3 = 1
			AND (@mefe_unit_id_update_l3 IS NULL
				OR  @mefe_unit_id_update_l3 = ''
				)
			AND @do_not_insert_update_l3 = 0
		THEN 

			# This is option 1 - creation IS needed
			#	- The unit is NOT marked as `do_not_insert`
			#	- We do NOT have a MEFE unit ID for that unit

				SET @this_trigger_update_l3_insert = 'ut_update_map_external_source_unit_add_room_creation_needed_insert' ;
				SET @this_trigger_update_l3_update = 'ut_update_map_external_source_unit_add_room_creation_needed_update' ;

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
					)
					VALUES
						(NOW()
						, @creation_system_id_update_l3
						, @created_by_id_update_l3
						, @this_trigger_update_l3_insert
						, @organization_id_update_l3
						, NOW()
						, @this_trigger_update_l3_insert
						, @is_obsolete_update_l3
						, @is_update_needed_update_l3
						, @uneet_name_update_l3
						, @unee_t_unit_type_update_l3
						, @new_record_id_update_l3
						, @external_property_type_id_update_l3
						, @external_property_id_update_l3
						, @external_system_update_l3
						, @table_in_external_system_update_l3
						)
					ON DUPLICATE KEY UPDATE 
						`syst_updated_datetime` = NOW()
						, `update_system_id` = @update_system_id_update_l3
						, `updated_by_id` = @updated_by_id_update_l3
						, `update_method` = @this_trigger_update_l3_update
						, `organization_id` = @organization_id_update_l3
						, `datetime_latest_trigger` = NOW()
						, `latest_trigger` = @this_trigger_update_l3_update
						, `uneet_name` = @uneet_name_update_l3
						, `unee_t_unit_type` = @unee_t_unit_type_update_l3
						, `is_update_needed` = 1
					;
###################################################################
#
# THIS IS CREATING SUBQUERY RETURN MORE THAN 1 ROW ERRORS
#
###################################################################
		ELSEIF @mefe_unit_id_update_l3 IS NOT NULL
			OR @mefe_unit_id_update_l3 != ''
		THEN 
			
			# This is option 2 - creation is NOT needed

				SET @this_trigger_update_l3_insert = 'ut_update_map_external_source_unit_edit_level_3_insert' ;
				SET @this_trigger_update_l3_update = 'ut_update_map_external_source_unit_edit_level_3_update' ;

				# We Update the existing new record in the table `ut_map_external_source_units`

				UPDATE `ut_map_external_source_units`
					SET 
						`syst_updated_datetime` = NOW()
						, `update_system_id` = @update_system_id_update_l3
						, `updated_by_id` = @updated_by_id_update_l3
						, `update_method` = @this_trigger_update_l3_update
						, `organization_id` = @organization_id_update_l3
						, `datetime_latest_trigger` = NOW()
						, `latest_trigger` = @this_trigger_update_l3_update
						, `uneet_name` = @uneet_name_update_l3
						, `unee_t_unit_type` = @unee_t_unit_type_update_l3
						, `is_update_needed` = 1
					WHERE `unee_t_mefe_unit_id` = @mefe_unit_id_update_l3
						;

###################################################################
#
# END IS CREATING SUBQUERY RETURN MORE THAN 1 ROW ERRORS
#
###################################################################

		# The conditions are NOT met <-- we do nothing
	
		END IF;

	END IF;

END;
$$
DELIMITER ;

#################
#
# Views and procedures we need if we need to re-try
#   - Create a unit in Unee-T
#
#################
#
# This script creates the following tables:
#	- `retry_create_units_list_units`
#
# This script will create or update the following:
#	- Views:
#		- `ut_list_unit_id_level_1_failed_creation`
#		- `ut_list_unit_id_level_2_failed_creation`
#		- `ut_list_unit_id_level_3_failed_creation`
#
# 	- Procedures
#		- `ut_retry_create_unit_level_1`
#		- `ut_retry_create_unit_level_2`
#		- `ut_retry_create_unit_level_3`
#		- ``
#

# We Create a table that will be used to activate the trigger for re-creation

	DROP TABLE IF EXISTS `retry_create_units_list_units` ;

	CREATE TABLE `retry_create_units_list_units` (
		`unit_creation_request_id` INT(11) NOT NULL COMMENT 'Id in this table',
		`created_by_id` VARCHAR(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who created this record',
		`creation_method` VARCHAR(255) COLLATE utf8mb4_unicode_520_ci NOT NULL,
		`uneet_name` VARCHAR(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The name of the unit in the MEFE',
		`unee_t_unit_type` VARCHAR(100) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The Unee-T type of unit for this property - this MUST be one of the `designation` in the table `ut_unit_types`',
		`more_info` TEXT COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'detailed description of the building',
		`street_address` VARCHAR(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
		`city` VARCHAR(50) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The City',
		`state` VARCHAR(50) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The State',
		`zip_code` VARCHAR(50) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'ZIP or Postal code',
		`country` VARCHAR(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'Description/help text'
		) ENGINE=INNODB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci
		;

# Level 1 units we need to re-create are listes in the View `ut_list_unit_id_level_1_failed_creation`

	DROP VIEW IF EXISTS `ut_list_unit_id_level_1_failed_creation` ;

	CREATE VIEW `ut_list_unit_id_level_1_failed_creation`
	AS 
	SELECT 
		`a`.`id_map` AS `unit_creation_request_id`
		, `a`.`syst_created_datetime` AS `creation_request_ts`
		, `a`.`syst_updated_datetime` AS `mefe_api_reply_ts`
		, `a`.`mefe_api_error_message`
		, `a`.`created_by_id`
		, `a`.`organization_id`
		, `a`.`new_record_id` AS `building_id`
		, `a`.`uneet_name`
		, `a`.`unee_t_unit_type`
		, `b`.`more_info`
		, `b`.`street_address`
		, `b`.`city`
		, `b`.`state`
		, `b`.`zip_code`
		, `b`.`country`
	FROM `ut_map_external_source_units` AS `a`
	INNER JOIN `ut_add_information_unit_level_1` AS `b`
		ON (`b`.`unit_level_1_id` = `a`.`new_record_id`)
	WHERE `a`.`unee_t_mefe_unit_id` IS NULL
		AND `a`.`is_obsolete` = 0
		AND `external_property_type_id` = 1
		;

# Level 2 units we need to re-create are listes in the View `ut_list_unit_id_level_2_failed_creation`

	DROP VIEW IF EXISTS `ut_list_unit_id_level_2_failed_creation` ;

	CREATE VIEW `ut_list_unit_id_level_2_failed_creation`
	AS 
	SELECT 
		`a`.`id_map` AS `unit_creation_request_id`
		, `a`.`syst_created_datetime` AS `creation_request_ts`
		, `a`.`syst_updated_datetime` AS `mefe_api_reply_ts`
		, `a`.`mefe_api_error_message`
		, `a`.`created_by_id`
		, `a`.`organization_id`
		, `a`.`new_record_id` AS `system_id_unit`
		, `a`.`uneet_name`
		, `a`.`unee_t_unit_type`
		, `b`.`more_info`
		, `b`.`street_address`
		, `b`.`city`
		, `b`.`state`
		, `b`.`zip_code`
		, `b`.`country`
	FROM `ut_map_external_source_units` AS `a`
	INNER JOIN `ut_add_information_unit_level_2` AS `b`
		ON (`b`.`unit_level_2_id` = `a`.`new_record_id`)
	WHERE `a`.`unee_t_mefe_unit_id` IS NULL
		AND `a`.`is_obsolete` = 0
		AND `external_property_type_id` = 2
		;

# Level 3 units we need to re-create are listes in the View `ut_list_unit_id_level_3_failed_creation`

	DROP VIEW IF EXISTS `ut_list_unit_id_level_3_failed_creation` ;

	CREATE VIEW `ut_list_unit_id_level_3_failed_creation`
	AS 
	SELECT 
		`a`.`id_map` AS `unit_creation_request_id`
		, `a`.`syst_created_datetime` AS `creation_request_ts`
		, `a`.`syst_updated_datetime` AS `mefe_api_reply_ts`
		, `a`.`mefe_api_error_message`
		, `a`.`created_by_id`
		, `a`.`organization_id`
		, `a`.`new_record_id` AS `system_id_room`
		, `a`.`uneet_name`
		, `a`.`unee_t_unit_type`
		, `b`.`more_info`
		, `b`.`street_address`
		, `b`.`city`
		, `b`.`state`
		, `b`.`zip_code`
		, `b`.`country`
	FROM `ut_map_external_source_units` AS `a`
	INNER JOIN `ut_add_information_unit_level_3` AS `b`
		ON (`b`.`unit_level_3_id` = `a`.`new_record_id`)
	WHERE `unee_t_mefe_unit_id` IS NULL
		AND `a`.`is_obsolete` = 0
		AND `a`.`external_property_type_id` = 3
		;

# Level 1 units - Create the procedure to re-try creating the units if the API failed

	DROP PROCEDURE IF EXISTS `ut_retry_create_unit_level_1`;

DELIMITER $$
CREATE PROCEDURE `ut_retry_create_unit_level_1`()
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN

####################
#
# WARNING!!
# Only run this if you are CERTAIN that the API has failed somehow
#
####################

# Clean slate - remove all data from `retry_create_units_list_units`

	TRUNCATE TABLE `retry_create_units_list_units` ;

# We insert the data we need in the table `retry_create_units_list_units`

	INSERT INTO `retry_create_units_list_units`
		(`unit_creation_request_id`
		, `created_by_id`
		, `creation_method`
		, `uneet_name`
		, `unee_t_unit_type`
		, `more_info`
		, `street_address`
		, `city`
		, `state`
		, `zip_code`
		, `country`
		)
	SELECT
		`unit_creation_request_id`
		, `created_by_id`
		, 'ut_retry_create_unit_level_1' AS `creation_method`
		, `uneet_name`
		, `unee_t_unit_type`
		, `more_info`
		, `street_address`
		, `city`
		, `state`
		, `zip_code`
		, `country`
	FROM `ut_list_unit_id_level_1_failed_creation`
		;

END $$
DELIMITER ;

# Level 2 units - Create the procedure to re-try creating the units if the API failed

	DROP PROCEDURE IF EXISTS `ut_retry_create_unit_level_2`;

DELIMITER $$
CREATE PROCEDURE `ut_retry_create_unit_level_2`()
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN

####################
#
# WARNING!!
# Only run this if you are CERTAIN that the API has failed somehow
#
####################

# Clean slate - remove all data from `retry_create_units_list_units`

	TRUNCATE TABLE `retry_create_units_list_units` ;

# We insert the data we need in the new table

	INSERT INTO `retry_create_units_list_units`
		(`unit_creation_request_id`
		, `created_by_id`
		, `creation_method`
		, `uneet_name`
		, `unee_t_unit_type`
		, `more_info`
		, `street_address`
		, `city`
		, `state`
		, `zip_code`
		, `country`
		)
	SELECT
		`unit_creation_request_id`
		, `created_by_id`
		, 'ut_retry_create_unit_level_2' AS `creation_method`
		, `uneet_name`
		, `unee_t_unit_type`
		, `more_info`
		, `street_address`
		, `city`
		, `state`
		, `zip_code`
		, `country`
	FROM `ut_list_unit_id_level_2_failed_creation`
		;

END $$
DELIMITER ;

# Level 3 units - Create the procedure to re-try creating the units if the API failed

	DROP PROCEDURE IF EXISTS `ut_retry_create_unit_level_3`;

DELIMITER $$
CREATE PROCEDURE `ut_retry_create_unit_level_3`()
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN

####################
#
# WARNING!!
# Only run this if you are CERTAIN that the API has failed somehow
#
####################

# Clean slate - remove all data from `retry_create_units_list_units`

	TRUNCATE TABLE `retry_create_units_list_units` ;

# We insert the data we need in the new table

	INSERT INTO `retry_create_units_list_units`
		(`unit_creation_request_id`
		, `created_by_id`
		, `creation_method`
		, `uneet_name`
		, `unee_t_unit_type`
		, `more_info`
		, `street_address`
		, `city`
		, `state`
		, `zip_code`
		, `country`
		)
	SELECT
		`unit_creation_request_id`
		, `created_by_id`
		, 'ut_retry_create_unit_level_3' AS `creation_method`
		, `uneet_name`
		, `unee_t_unit_type`
		, `more_info`
		, `street_address`
		, `city`
		, `state`
		, `zip_code`
		, `country`
	FROM `ut_list_unit_id_level_3_failed_creation`
		;

END $$
DELIMITER ;


#################
#
# This is part 8
# Remove a user from a role
#
#################


# Remove a user from an area 
#	- Delete the records in the table
#		- `external_map_user_unit_role_permissions_level_1`
#

	DROP TRIGGER IF EXISTS `ut_delete_user_from_role_in_an_area`;

DELIMITER $$
CREATE TRIGGER `ut_delete_user_from_role_in_an_area`
AFTER DELETE ON `external_map_user_unit_role_permissions_areas`
FOR EACH ROW
BEGIN

# We only do this if:
#	- This is a valid method of deletion ???

	IF 1=1
	THEN 

		# We delete the record in the tables that are visible in the Unee-T Enterprise interface

			SET @deleted_area_id := OLD.`unee_t_area_id` ;
			SET @deleted_mefe_user_id := OLD.`unee_t_mefe_user_id` ;

			DELETE `external_map_user_unit_role_permissions_level_1` 
			FROM `external_map_user_unit_role_permissions_level_1`
			INNER JOIN `ut_list_mefe_unit_id_level_1_by_area`
				ON (`ut_list_mefe_unit_id_level_1_by_area`.`level_1_building_id` 
				= `external_map_user_unit_role_permissions_level_1`.`unee_t_level_1_id`)
			WHERE 
				`external_map_user_unit_role_permissions_level_1`.`unee_t_mefe_user_id` = @deleted_mefe_user_id
				AND `ut_list_mefe_unit_id_level_1_by_area`.`id_area` = @deleted_area_id
				;

	END IF;
END;
$$
DELIMITER ;

# Remove a user from a Level 1 property (building)
# 	- Delete the records in the table
#		- `external_map_user_unit_role_permissions_level_2`
#		- `ut_map_user_permissions_unit_level_1`
#	- Update the table:
#		 - `ut_map_user_permissions_unit_all`
#	- Call the procedure to remove a user from a role in a unit
#		- `ut_remove_user_from_unit`

	DROP TRIGGER IF EXISTS `ut_delete_user_from_role_in_a_level_1_property`;

DELIMITER $$
CREATE TRIGGER `ut_delete_user_from_role_in_a_level_1_property`
AFTER DELETE ON `external_map_user_unit_role_permissions_level_1`
FOR EACH ROW
BEGIN

# We only do this if:
#	- This is a valid method of deletion ???

	IF 1=1
	THEN 

		SET @deleted_level_1_id := OLD.`unee_t_level_1_id` ;
		SET @deleted_mefe_user_id := OLD.`unee_t_mefe_user_id` ;
		SET @organization_id := OLD.`created_by_id` ;

		DELETE `external_map_user_unit_role_permissions_level_2` 
		FROM `external_map_user_unit_role_permissions_level_2`
		INNER JOIN `ut_list_mefe_unit_id_level_2_by_area`
			ON (`ut_list_mefe_unit_id_level_2_by_area`.`level_2_unit_id` = `external_map_user_unit_role_permissions_level_2`.`unee_t_level_2_id`)
		WHERE 
			`external_map_user_unit_role_permissions_level_2`.`unee_t_mefe_user_id` = @deleted_mefe_user_id
			AND `ut_list_mefe_unit_id_level_2_by_area`.`level_1_building_id` = @deleted_level_1_id
			;

		# We need several variables:

			SET @this_trigger := 'ut_delete_user_from_role_in_a_level_1_property';

			SET @syst_updated_datetime := NOW() ;
			SET @update_system_id := 2 ;
			SET @updated_by_id := (SELECT `mefe_user_id`
				FROM `ut_api_keys`
				WHERE `organization_id` = @organization_id
				) ;
			SET @update_method := @this_trigger ;

			SET @unee_t_mefe_user_id := @deleted_mefe_user_id ;

			SET @unee_t_mefe_unit_id_l1 := (SELECT `unee_t_mefe_unit_id`
				FROM `ut_list_mefe_unit_id_level_1_by_area`
				WHERE `level_1_building_id` = @deleted_level_1_id
				);
			
			SET @is_obsolete := 1 ;

		# We call the procedure that will activate the MEFE API to remove a user from a unit.
		# This procedure needs the following variables:
		#	- @unee_t_mefe_id
		#	- @unee_t_unit_id
		#	- @is_obsolete
		#	- @update_method
		#	- @update_system_id
		#	- @updated_by_id
		#	- @disable_lambda != 1

			SET @unee_t_mefe_id := @unee_t_mefe_user_id ;
			SET @unee_t_unit_id := @unee_t_mefe_unit_id_l1 ;

		# We call the lambda

			CALL `ut_remove_user_from_unit` ;

		# We call the procedure to delete the relationship from the Unee-T Enterprise Db 

			CALL `remove_user_from_role_unit_level_1` ;

	END IF;
END;
$$
DELIMITER ;

# We create the procedures to remove the records from the table `ut_map_user_permissions_unit_level_1`

	DROP PROCEDURE IF EXISTS `remove_user_from_role_unit_level_1` ;

DELIMITER $$
CREATE PROCEDURE `remove_user_from_role_unit_level_1` ()
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN

# This Procedure needs the following variables:
#	- @unee_t_mefe_user_id
#	- @unee_t_mefe_unit_id_l1

		# We delete the relation user/unit in the `ut_map_user_permissions_unit_level_1`

			DELETE `ut_map_user_permissions_unit_level_1` 
			FROM `ut_map_user_permissions_unit_level_1`
				WHERE `unee_t_mefe_id` = @unee_t_mefe_user_id
					AND `unee_t_unit_id` = @unee_t_mefe_unit_id_l1
					;

		# We delete the relation user/unit in the table `ut_map_user_permissions_unit_all`

			DELETE `ut_map_user_permissions_unit_all` 
			FROM `ut_map_user_permissions_unit_all`
				WHERE `unee_t_mefe_id` = @unee_t_mefe_user_id
					AND `unee_t_unit_id` = @unee_t_mefe_unit_id_l1
					;

END;
$$
DELIMITER ;

# Remove a user from a Level 2 property (unit)
# 	- Delete the records in the table
#		- `external_map_user_unit_role_permissions_level_3`
#		- `ut_map_user_permissions_unit_level_2`
#	- Update the table:
#		- `ut_map_user_permissions_unit_all`
#	- Call the procedure to remove a user from a role in a unit
#		- `ut_remove_user_from_unit`

	DROP TRIGGER IF EXISTS `ut_delete_user_from_role_in_a_level_2_property`;

DELIMITER $$
CREATE TRIGGER `ut_delete_user_from_role_in_a_level_2_property`
AFTER DELETE ON `external_map_user_unit_role_permissions_level_2`
FOR EACH ROW
BEGIN

# We only do this if:
#	- This is a valid method of deletion ???

	IF 1=1
	THEN 

		SET @deleted_level_2_id := OLD.`unee_t_level_2_id` ;
		SET @deleted_mefe_user_id := OLD.`unee_t_mefe_user_id` ;
		SET @organization_id := OLD.`creation_system_id` ;

		DELETE `external_map_user_unit_role_permissions_level_3` 
		FROM `external_map_user_unit_role_permissions_level_3`
		INNER JOIN `ut_list_mefe_unit_id_level_3_by_area`
			ON (`ut_list_mefe_unit_id_level_3_by_area`.`level_3_room_id` = `external_map_user_unit_role_permissions_level_3`.`unee_t_level_3_id`)
		WHERE 
			`external_map_user_unit_role_permissions_level_3`.`unee_t_mefe_user_id` = @deleted_mefe_user_id
			AND `ut_list_mefe_unit_id_level_3_by_area`.`level_2_unit_id` = @deleted_level_2_id
			;

		# We need several variables:

			SET @this_trigger := 'ut_delete_user_from_role_in_a_level_2_property';

			SET @syst_updated_datetime := NOW() ;
			SET @update_system_id := 2 ;
			SET @updated_by_id := (SELECT `mefe_user_id`
				FROM `ut_api_keys`
				WHERE `organization_id` = @organization_id
				) ;
			SET @update_method := @this_trigger ;

			SET @unee_t_mefe_user_id := @deleted_mefe_user_id ;

			SET @unee_t_mefe_unit_id_l2 := (SELECT `unee_t_mefe_unit_id`
				FROM `ut_list_mefe_unit_id_level_2_by_area`
				WHERE `level_2_unit_id` = @deleted_level_2_id
				);
			
			SET @is_obsolete := 1 ;

		# We call the procedure that will activate the MEFE API to remove a user from a unit.
		# This procedure needs the following variables:
		#	- @unee_t_mefe_id
		#	- @unee_t_unit_id
		#	- @is_obsolete
		#	- @update_method
		#	- @update_system_id
		#	- @updated_by_id
		#	- @disable_lambda != 1

			SET @unee_t_mefe_id := @unee_t_mefe_user_id ;
			SET @unee_t_unit_id := @unee_t_mefe_unit_id_l2 ;

		# We call the lambda

			CALL `ut_remove_user_from_unit` ;

		# We call the procedure to delete the relationship from the Unee-T Enterprise Db 

			CALL `remove_user_from_role_unit_level_2` ;

	END IF;
END;
$$
DELIMITER ;

# We create the procedures to remove the records from the table `ut_map_user_permissions_unit_level_2`

	DROP PROCEDURE IF EXISTS `remove_user_from_role_unit_level_2`;

DELIMITER $$
CREATE PROCEDURE `remove_user_from_role_unit_level_2` ()
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN

# This Procedure needs the following variables:
#	- @unee_t_mefe_user_id
#	- @unee_t_mefe_unit_id_l2

		# We delete the relation user/unit in the `ut_map_user_permissions_unit_level_2`

			DELETE `ut_map_user_permissions_unit_level_2` 
			FROM `ut_map_user_permissions_unit_level_2`
				WHERE `unee_t_mefe_id` = @unee_t_mefe_user_id
					AND `unee_t_unit_id` = @unee_t_mefe_unit_id_l2
					;

		# We delete the relation user/unit in the table `ut_map_user_permissions_unit_all`

			DELETE `ut_map_user_permissions_unit_all` 
			FROM `ut_map_user_permissions_unit_all`
				WHERE `unee_t_mefe_id` = @unee_t_mefe_user_id
					AND `unee_t_unit_id` = @unee_t_mefe_unit_id_l2
					;

END;
$$
DELIMITER ;

# Remove a user from a Level 3 property (rooms)
# 	- Delete the records in the table
#		- `ut_map_user_permissions_unit_level_3`
#	- Update the table:
#		 - `ut_map_user_permissions_unit_all`
#	- Call the procedure to remove a user from a role in a unit
#		- `ut_remove_user_from_unit`

			DROP TRIGGER IF EXISTS `ut_delete_user_from_role_in_a_level_3_property`;

DELIMITER $$
CREATE TRIGGER `ut_delete_user_from_role_in_a_level_3_property`
AFTER DELETE ON `external_map_user_unit_role_permissions_level_3`
FOR EACH ROW
BEGIN

# We only do this if:
#	- This is a valid method of deletion ???

	IF 1=1
	THEN 

		SET @deleted_level_3_id := OLD.`unee_t_level_3_id` ;
		SET @deleted_mefe_user_id := OLD.`unee_t_mefe_user_id` ;
		SET @organization_id := OLD.`creation_system_id` ;

		# We need several variables:

			SET @this_trigger := 'ut_delete_user_from_role_in_a_level_3_property';

			SET @syst_updated_datetime := NOW() ;
			SET @update_system_id := 2 ;
			SET @updated_by_id := (SELECT `mefe_user_id`
				FROM `ut_api_keys`
				WHERE `organization_id` = @organization_id
				) ;
			SET @update_method := @this_trigger ;

			SET @unee_t_mefe_user_id := @deleted_mefe_user_id ;

			SET @unee_t_mefe_unit_id_l3 := (SELECT `unee_t_mefe_unit_id`
				FROM `ut_list_mefe_unit_id_level_3_by_area`
				WHERE `level_3_room_id` = @deleted_level_3_id
				);
			
			SET @is_obsolete := 1 ;

		# We call the procedure that will activate the MEFE API to remove a user from a unit.
		# This procedure needs the following variables:
		#	- @unee_t_mefe_id
		#	- @unee_t_unit_id
		#	- @is_obsolete
		#	- @update_method
		#	- @update_system_id
		#	- @updated_by_id
		#	- @disable_lambda != 1

			SET @unee_t_mefe_id := @unee_t_mefe_user_id ;
			SET @unee_t_unit_id := @unee_t_mefe_unit_id_l3 ;

		# We call the lambda

			CALL `ut_remove_user_from_unit` ;

		# We call the procedure to delete the relationship from the Unee-T Enterprise Db 

			CALL `remove_user_from_role_unit_level_3` ;

	END IF;
END;
$$
DELIMITER ;

# We create the procedures to remove the records from the table `ut_map_user_permissions_unit_level_3`

	DROP PROCEDURE IF EXISTS `remove_user_from_role_unit_level_3`;

DELIMITER $$
CREATE PROCEDURE `remove_user_from_role_unit_level_3` ()
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN

# This Procedure needs the following variables:
#	- @unee_t_mefe_user_id
#	- @unee_t_mefe_unit_id_l3

		# We delete the relation user/unit in the `ut_map_user_permissions_unit_level_3`

			DELETE `ut_map_user_permissions_unit_level_3` 
			FROM `ut_map_user_permissions_unit_level_3`
				WHERE (`unee_t_mefe_id` = @unee_t_mefe_user_id
					AND `unee_t_unit_id` = @unee_t_mefe_unit_id_l3)
					;

		# We delete the relation user/unit in the table `ut_map_user_permissions_unit_all`

			DELETE `ut_map_user_permissions_unit_all` 
			FROM `ut_map_user_permissions_unit_all`
				WHERE `unee_t_mefe_id` = @unee_t_mefe_user_id
					AND `unee_t_unit_id` = @unee_t_mefe_unit_id_l3
					;

END;
$$
DELIMITER ;

