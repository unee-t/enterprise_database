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
#	- On persons
#		- `ut_user_information_persons`
#		- `ut_check_unee_t_updates_persons`
#		- `ut_info_external_persons`
#		- `ut_info_persons`
#		- `ut_info_mefe_users`
#		- `ut_user_person_details`
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
#		- `ut_organization_default_L1P`
#		- `ut_organization_default_L2P`
#		- DEPRECATED - REMOVED `ut_organization_associated_mefe_user`
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
#
#	- To facilitate the selection of default assignees
#		- `ut_list_possible_assignees`
#		
#	- To facilitate the selection of default L1P and default L2P
#		- `ut_list_possible_properties`
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
	    `b`.`id_organization` AS `organization_id`
	    , `b`.`designation`
	    , `a`.`unee_t_mefe_user_id` AS `mefe_user_id`
	    , `a`.`unee_t_mefe_user_api_key`
	FROM
	    `ut_map_external_source_users` AS `a`
	    INNER JOIN `uneet_enterprise_organizations` AS `b`
		ON (`a`.`organization_id` = `b`.`id_organization`) 
		AND (`a`.`external_person_id` = `b`.`mefe_master_user_external_person_id`) 
		AND (`a`.`table_in_external_system` = `b`.`mefe_master_user_external_person_table`) 
		AND (`a`.`external_system` = `b`.`mefe_master_user_external_person_system`)
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

# Create the view to get the necessary information to assign the default users
#	  `ut_user_person_details`

	DROP VIEW IF EXISTS `ut_user_person_details` ;

	CREATE VIEW `ut_user_person_details`
	AS
	SELECT
		`a`.`unee_t_mefe_user_id`
		, `b`.`country_code`
		, `b`.`email`
		, `b`.`organization_id`
		, `b`.`person_status_id`
		, `b`.`gender`
		, `b`.`salutation_id`
		, `b`.`given_name`
		, `b`.`middle_name`
		, `b`.`family_name`
		, `b`.`alias`
		, `b`.`job_title`
		, `b`.`organization`
		, `b`.`tel_1`
	FROM
		`ut_map_external_source_users` AS `a`
		INNER JOIN `persons` AS `b`
			ON (`a`.`person_id` = `b`.`id_person`)
		WHERE  `a`.`unee_t_mefe_user_id` IS NOT NULL
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
	    `a`.`id_area` AS `default_area_id`
	    , `a`.`area_name` AS `default_area_name`
	    , `b`.`id_organization` AS `organization_id`
	FROM
	    `external_property_groups_areas` AS `a`
	    INNER JOIN `uneet_enterprise_organizations` AS `b`
		ON (`a`.`created_by_id` = `b`.`id_organization`) 
		AND (`a`.`id_area` = `b`.`default_area`)
		;

# We create a view to get the default external system for each organization

	DROP VIEW IF EXISTS `ut_organization_default_external_system` ;

	CREATE VIEW `ut_organization_default_external_system`
	AS
	SELECT
		`a`.`designation`
		, `b`.`id_organization` AS `organization_id`
	FROM
		`ut_external_sot_for_unee_t_objects` AS `a`
		INNER JOIN `uneet_enterprise_organizations` AS `b`
			ON (`a`.`organization_id` = `b`.`id_organization`) 
			AND (`a`.`id_external_sot_for_unee_t` = `b`.`default_sot_id`)
		;

# We create a view to get the default table for areas for each organization

	DROP VIEW IF EXISTS `ut_organization_default_table_areas` ;

	CREATE VIEW `ut_organization_default_table_areas`
	AS
	SELECT
		`a`.`area_table`
		, `b`.`id_organization` AS `organization_id`
	FROM
		`ut_external_sot_for_unee_t_objects` AS `a`
		INNER JOIN `uneet_enterprise_organizations` AS `b`
			ON (`a`.`organization_id` = `b`.`id_organization`) 
			AND (`a`.`id_external_sot_for_unee_t` = `b`.`default_sot_id`)
		;

# We create a view to get the default table_level_1_properties for each organization

	DROP VIEW IF EXISTS `ut_organization_default_table_level_1_properties` ;

	CREATE VIEW `ut_organization_default_table_level_1_properties`
	AS
	SELECT
		`a`.`properties_level_1_table`
		, `b`.`id_organization` AS `organization_id`
	FROM
		`ut_external_sot_for_unee_t_objects` AS `a`
		INNER JOIN `uneet_enterprise_organizations` AS `b`
			ON (`a`.`organization_id` = `b`.`id_organization`) 
			AND (`a`.`id_external_sot_for_unee_t` = `b`.`default_sot_id`)
		;

# We create a view to get the default table_level_2_properties for each organization

	DROP VIEW IF EXISTS `ut_organization_default_table_level_2_properties` ;

	CREATE VIEW `ut_organization_default_table_level_2_properties`
	AS
	SELECT
		`a`.`properties_level_2_table`
		, `b`.`id_organization` AS `organization_id`
	FROM
		`ut_external_sot_for_unee_t_objects` AS `a`
		INNER JOIN `uneet_enterprise_organizations` AS `b`
			ON (`a`.`organization_id` = `b`.`id_organization`) 
			AND (`a`.`id_external_sot_for_unee_t` = `b`.`default_sot_id`)
		;

# We create a view to get the default table_level_3_properties for each organization

	DROP VIEW IF EXISTS `ut_organization_default_table_level_3_properties` ;

	CREATE VIEW `ut_organization_default_table_level_3_properties`
	AS
	SELECT
		`a`.`properties_level_3_table`
		, `b`.`id_organization` AS `organization_id`
	FROM
		`ut_external_sot_for_unee_t_objects` AS `a`
		INNER JOIN `uneet_enterprise_organizations` AS `b`
			ON (`a`.`organization_id` = `b`.`id_organization`) 
			AND (`a`.`id_external_sot_for_unee_t` = `b`.`default_sot_id`)
		;

# We create a view to get the default table `persons` for each organization

	DROP VIEW IF EXISTS `ut_organization_default_table_persons` ;

	CREATE VIEW `ut_organization_default_table_persons`
	AS
	SELECT
		`a`.`person_table`
		, `b`.`id_organization` AS `organization_id`
	FROM
		`ut_external_sot_for_unee_t_objects` AS `a`
		INNER JOIN `uneet_enterprise_organizations` AS `b`
			ON (`a`.`organization_id` = `b`.`id_organization`) 
			AND (`a`.`id_external_sot_for_unee_t` = `b`.`default_sot_id`)
		;

# We create the view to get the details of the default L1P for a given organization

	DROP VIEW IF EXISTS `ut_organization_default_L1P` ;

	CREATE VIEW `ut_organization_default_L1P`
	AS
	SELECT
		`a`.`organization_id`
		, `b`.`designation` AS `organization`
		, `a`.`unee_t_mefe_unit_id`
		, `a`.`uneet_name`
		, `a`.`mefe_unit_id_parent`
		, `a`.`is_obsolete`
		, `a`.`external_property_id`
		, `a`.`external_system`
		, `a`.`table_in_external_system`
		, `a`.`tower`
	FROM
			`ut_map_external_source_units` AS `a`
		INNER JOIN 	`uneet_enterprise_organizations` AS `b`
			ON (`a`.`organization_id` = `b`.`id_organization`)
	WHERE `a`.`unee_t_mefe_unit_id` IS NOT NULL
		AND `a`.`external_property_type_id` = 1
		;


# We create the view to get the details of the default L2P for a given organization

	DROP VIEW IF EXISTS `ut_organization_default_L2P` ;

	CREATE VIEW `ut_organization_default_L2P`
	AS
	SELECT
		`a`.`organization_id`
		, `b`.`designation` AS `organization`
		, `a`.`unee_t_mefe_unit_id`
		, `a`.`uneet_name`
		, `a`.`mefe_unit_id_parent`
		, `a`.`is_obsolete`
		, `a`.`external_property_id`
		, `a`.`external_system`
		, `a`.`table_in_external_system`
		, `a`.`tower`
	FROM
			`ut_map_external_source_units` AS `a`
		INNER JOIN 	`uneet_enterprise_organizations` AS `b`
			ON (`a`.`organization_id` = `b`.`id_organization`)
	WHERE `a`.`unee_t_mefe_unit_id` IS NOT NULL
		AND `a`.`external_property_type_id` = 2
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

# Add the view to facilitate selection of default users for each role

	DROP VIEW IF EXISTS `ut_list_possible_assignees` ;

	CREATE VIEW `ut_list_possible_assignees`
	AS 
	SELECT
	    `a`.`unee_t_mefe_user_id`
	    , `a`.`is_obsolete`
	    , `a`.`organization_id`
	    , `a`.`person_id`
	    , `b`.`given_name`
	    , `b`.`family_name`
	    , `b`.`alias`
	    , `b`.`email`
	    , CONCAT( `b`.`given_name`
		, IF(`b`.`alias` IS NULL
			, ' '
			, IF(`b`.`alias` = ''
				, ' ' 
				, CONCAT(' ('
					, `b`.`alias`
					, ') '
					)
				)
			)
		, `b`.`family_name`
		) AS `person_designation`
	FROM
	    `ut_map_external_source_users` AS `a`
	    INNER JOIN `persons` AS `b`
		ON (`a`.`person_id` = `b`.`id_person`)
	WHERE (`a`.`is_obsolete` = 0
		AND `a`.`unee_t_mefe_user_id` IS NOT NULL
		AND `a`.`creation_system_id` != 'Setup')
	;
	
# Add the view to facilitate the selection of default L1P and default L2P

	DROP VIEW IF EXISTS `ut_list_possible_properties` ;

	CREATE VIEW `ut_list_possible_properties`
	AS 
	SELECT
		`a`.`organization_id`
		, `b`.`designation` AS `organization`
		, `a`.`external_property_type_id`
		, `a`.`unee_t_mefe_unit_id`
		, `a`.`uneet_name`
		, `a`.`mefe_unit_id_parent`
		, `a`.`is_obsolete`
	FROM
			`ut_map_external_source_units` AS `a`
		INNER JOIN 	`uneet_enterprise_organizations` AS `b`
			ON (`a`.`organization_id` = `b`.`id_organization`)
	WHERE `a`.`unee_t_mefe_unit_id` IS NOT NULL
		;

