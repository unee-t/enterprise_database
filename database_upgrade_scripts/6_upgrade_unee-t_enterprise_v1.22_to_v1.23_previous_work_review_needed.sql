# Upgrade from v22.8 to v23.0
# These are the alteration that we need to consider/review
#







/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;

USE `unee_t_enterprise_v1.23.0`;

/* Create table in target */
CREATE TABLE `unte_api_add_unit`(
	`id_unte_api_add_unit` int(11) unsigned NOT NULL  auto_increment COMMENT 'Unique ID in this table' , 
	`request_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL  COMMENT 'The ID of the request that was sent to the UNTE' , 
	`external_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL  COMMENT 'The id of the record in an external system' , 
	`external_system_id` varchar(100) COLLATE utf8mb4_unicode_520_ci NOT NULL  DEFAULT 'unknown' COMMENT 'The id of the system which provides the external_system_id' , 
	`external_table` varchar(100) COLLATE utf8mb4_unicode_520_ci NOT NULL  DEFAULT 'unknown' COMMENT 'The table in the external system where this record is stored' , 
	`syst_created_datetime` timestamp NULL  COMMENT 'When was this record created?' , 
	`creation_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'What is the id of the system that was used for the creation of the record?' , 
	`organization_key` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL  COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record' , 
	`creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'How was this record created' , 
	`syst_updated_datetime` timestamp NULL  COMMENT 'When was this record last updated?' , 
	`update_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'What is the id of the system that was used for the last update the record?' , 
	`updated_by_id` int(11) unsigned NULL  COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record' , 
	`update_method` varchar(255) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'How was this record updated?' , 
	`is_obsolete` tinyint(1) NULL  DEFAULT 0 COMMENT '1 if this record is obsolete' , 
	`order` int(10) NULL  DEFAULT 0 COMMENT 'order in the list' , 
	`area_mefe_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'The MEFE Id of the Area for that property' , 
	`parent_mefe_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'The MEFE Id of the parent for this unit (area, L1, or L2)' , 
	`unee_t_unit_type` varchar(100) COLLATE utf8mb4_unicode_520_ci NOT NULL  COMMENT 'The Unee-T type of unit for this property - this MUST be one of the `designation` in the table `ut_unit_types`' , 
	`designation` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL  COMMENT 'The name of the building' , 
	`tower` varchar(50) COLLATE utf8mb4_unicode_520_ci NOT NULL  DEFAULT '1' COMMENT 'If there is more than 1 building, the id for the unique building. Default is 1.' , 
	`unit_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'The unique id of this unit in the building' , 
	`address_1` varchar(50) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'Address 1' , 
	`address_2` varchar(50) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'Address 2' , 
	`zip_postal_code` varchar(50) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'ZIP or Postal code' , 
	`state` varchar(50) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'The State' , 
	`city` varchar(50) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'The City' , 
	`country_code` varchar(10) COLLATE utf8mb4_unicode_520_ci NOT NULL  COMMENT 'The 2 letter ISO country code (FR, SG, EN, etc...). See table `property_groups_countries`' , 
	`description` text COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'detailed description of the building' , 
	`count_rooms` int(10) NULL  COMMENT 'Number of rooms in the unit' , 
	`surface` int(10) unsigned NULL  COMMENT 'The surface of the unit' , 
	`surface_measurement_unit` varchar(10) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'Either sqm (Square Meters) or sqf (Square Feet)' , 
	`number_of_beds` int(10) NULL  COMMENT 'Number of beds in the room' , 
	`mgt_cny_default_assignee` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL  COMMENT 'A FK to the table `ut_map_external_source_users`. This is the MEFE user Id for the default assignee for the role \"landlord\"' , 
	`landlord_default_assignee` varchar(255) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'A FK to the table `ut_map_external_source_users`. This is the MEFE user Id for the default assignee for the role \"management company\"' , 
	`tenant_default_assignee` varchar(255) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'A FK to the table `ut_map_external_source_users`. This is the MEFE user Id for the default assignee for the role \"tenant\"' , 
	`agent_default_assignee` varchar(255) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'A FK to the table `ut_map_external_source_users`. This is the MEFE user Id for the default assignee for the role \"Agent\"' , 
	`is_creation_needed_in_unee_t` tinyint(1) NULL  DEFAULT 0 COMMENT '1 if we need to create this property as a unit in Unee-T' , 
	`mefe_unit_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'The MEFE ID of the unit - a FK to the Mongo Collection unitMetaData' , 
	`uneet_created_datetime` timestamp NULL  COMMENT 'Timestamp when the unit was created' , 
	`is_api_success` tinyint(1) NULL  COMMENT '1 if this is a success, 0 if not' , 
	`api_error_message` text COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'The error message (if any)' , 
	PRIMARY KEY (`external_id`,`external_system_id`,`external_table`,`organization_key`,`tower`) , 
	UNIQUE KEY `unique_id_unte_api_add_unit`(`id_unte_api_add_unit`) , 
	UNIQUE KEY `unit_creation_unique_request_id`(`request_id`) , 
	KEY `api_add_unit_parent_mefe_id`(`parent_mefe_id`) , 
	KEY `api_add_unit_unit_type`(`unee_t_unit_type`) , 
	KEY `api_add_unit_country_code`(`country_code`) , 
	KEY `api_add_unit_api_key_default_assignee_agent`(`agent_default_assignee`) , 
	KEY `api_add_unit_api_key_default_assignee_landlord`(`landlord_default_assignee`) , 
	KEY `api_add_unit_api_key_default_assignee_mgt_cny`(`mgt_cny_default_assignee`) , 
	KEY `api_add_unit_api_key_default_assignee_tenant`(`tenant_default_assignee`) , 
	KEY `api_add_unit_mefe_id`(`mefe_unit_id`) , 
	KEY `api_add_unit_job_request_id`(`request_id`) , 
	KEY `api_add_unit_organization_key`(`organization_key`) , 
	KEY `api_add_unit_area_mefe_id_must_exist`(`area_mefe_id`) , 
	CONSTRAINT `api_add_unit_api_key_default_assignee_agent_must_exist` 
	FOREIGN KEY (`agent_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_api_key`) ON UPDATE CASCADE , 
	CONSTRAINT `api_add_unit_api_key_default_assignee_landlord_must_exist` 
	FOREIGN KEY (`landlord_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_api_key`) ON UPDATE CASCADE , 
	CONSTRAINT `api_add_unit_api_key_default_assignee_mgt_cny_must_exist` 
	FOREIGN KEY (`mgt_cny_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_api_key`) ON UPDATE CASCADE , 
	CONSTRAINT `api_add_unit_api_key_default_assignee_tenant_must_exist` 
	FOREIGN KEY (`tenant_default_assignee`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_api_key`) ON UPDATE CASCADE , 
	CONSTRAINT `api_add_unit_area_mefe_id_must_exist` 
	FOREIGN KEY (`area_mefe_id`) REFERENCES `ut_map_external_source_areas` (`mefe_area_id`) ON UPDATE CASCADE , 
	CONSTRAINT `api_add_unit_country_code_must_exist` 
	FOREIGN KEY (`country_code`) REFERENCES `property_groups_countries` (`country_code`) ON UPDATE CASCADE , 
	CONSTRAINT `api_add_unit_mefe_id_must_exist` 
	FOREIGN KEY (`mefe_unit_id`) REFERENCES `ut_map_external_source_units` (`unee_t_mefe_unit_id`) ON UPDATE CASCADE , 
	CONSTRAINT `api_add_unit_mefe_id_parent_must_exist` 
	FOREIGN KEY (`parent_mefe_id`) REFERENCES `ut_map_external_source_units` (`unee_t_mefe_unit_id`) ON UPDATE CASCADE , 
	CONSTRAINT `api_add_unit_organization_key_must_exist` 
	FOREIGN KEY (`organization_key`) REFERENCES `unte_api_keys` (`api_key`) ON UPDATE CASCADE , 
	CONSTRAINT `api_add_unit_unit_type_must_exist` 
	FOREIGN KEY (`unee_t_unit_type`) REFERENCES `ut_unit_types` (`designation`) ON UPDATE CASCADE 
) ENGINE=InnoDB DEFAULT CHARSET='utf8mb4' COLLATE='utf8mb4_unicode_520_ci';


/* Create table in target */
CREATE TABLE `unte_api_keys`(
	`id_api_key` int(11) unsigned NOT NULL  auto_increment COMMENT 'Id in this table' , 
	`syst_created_datetime` timestamp NULL  COMMENT 'When was this record created?' , 
	`creation_system_id` int(11) NULL  COMMENT 'What is the id of the sytem that was used for the creation of the record?' , 
	`created_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'The MEFE ID of the user who created this record' , 
	`creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'How was this record created' , 
	`syst_updated_datetime` timestamp NULL  COMMENT 'When was this record last updated?' , 
	`update_system_id` int(11) NULL  COMMENT 'What is the id of the sytem that was used for the last update the record?' , 
	`updated_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'The MEFE ID of the user who updated this record' , 
	`update_method` varchar(255) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'How was this record updated?' , 
	`external_system_id` int(11) NULL  COMMENT 'A FK to the table `ut_external_sot_for_unee_t_objects` - Store data about the source of truth for the information we need' , 
	`revoked_datetime` timestamp NULL  COMMENT 'When was this API key revoked' , 
	`is_obsolete` tinyint(1) NULL  DEFAULT 0 COMMENT '1 is this API key is revoked or obsolete' , 
	`api_key` varchar(255) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'The API Key' , 
	`mefe_user_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL  COMMENT 'The ID of MEFE user which is associated to this API key' , 
	`organization_id` int(11) unsigned NOT NULL  COMMENT 'A FK to the table `uneet_enterprise_organizations` - The ID of the organization for the user' , 
	PRIMARY KEY (`mefe_user_id`,`organization_id`) , 
	UNIQUE KEY `unique_id_for_each_api`(`id_api_key`) , 
	UNIQUE KEY `unique_api_key`(`api_key`) , 
	KEY `api_key_organization_id`(`organization_id`) , 
	CONSTRAINT `unte_api_key_organization_id` 
	FOREIGN KEY (`organization_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE 
) ENGINE=InnoDB DEFAULT CHARSET='utf8mb4' COLLATE='utf8mb4_unicode_520_ci';


/* Create table in target */
CREATE TABLE `ut_add_information_unit_level_1`(
	`unit_level_1_id` int(11) NOT NULL  DEFAULT 0 COMMENT 'Unique ID in this table' , 
	`is_create_condo` tinyint(1) NULL  COMMENT '1 if we need to create this property as a unit in Unee-T' , 
	`unee_t_unit_type` varchar(100) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'The Unee-T type of unit for this property - this MUST be one of the `designation` in the table `ut_unit_types`' , 
	`name` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL  COMMENT 'The name of the building' , 
	`more_info` text COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'detailed description of the building' , 
	`tower` varchar(50) COLLATE utf8mb4_unicode_520_ci NOT NULL  DEFAULT '' COMMENT 'If there is more than 1 building, the id for the unique building. Default is 1.' , 
	`street_address` varchar(102) COLLATE utf8mb4_unicode_520_ci NULL  , 
	`city` varchar(50) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'The City' , 
	`zip_code` varchar(50) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'ZIP or Postal code' , 
	`state` varchar(50) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'The State' , 
	`country_code` varchar(10) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'The 2 letter ISO country code (FR, SG, EN, etc...). See table `property_groups_countries`' , 
	`country` varchar(256) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'Description/help text' 
) ENGINE=InnoDB DEFAULT CHARSET='utf8mb4' COLLATE='utf8mb4_unicode_520_ci';


/* Create table in target */
CREATE TABLE `ut_add_information_unit_level_2`(
	`unit_level_2_id` int(11) NOT NULL  DEFAULT 0 COMMENT 'Unique Id in this table' , 
	`is_create_flat` tinyint(1) NULL  COMMENT '1 if we need to create this property as a unit in Unee-T' , 
	`unee_t_unit_type` varchar(100) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'The Unee-T type of unit for this property - this MUST be one of the `designation` in the table `ut_unit_types`' , 
	`name` varchar(50) COLLATE utf8mb4_unicode_520_ci NOT NULL  COMMENT 'The name of the unit/flat' , 
	`more_info` text COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'Description of the unit' , 
	`street_address` varchar(413) COLLATE utf8mb4_unicode_520_ci NULL  , 
	`city` varchar(50) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'The City' , 
	`state` varchar(50) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'The State' , 
	`zip_code` varchar(50) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'ZIP or Postal code' , 
	`country` varchar(256) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'Description/help text' 
) ENGINE=InnoDB DEFAULT CHARSET='utf8mb4' COLLATE='utf8mb4_unicode_520_ci';


/* Create table in target */
CREATE TABLE `ut_add_information_unit_level_3`(
	`unit_level_3_id` int(11) NOT NULL  DEFAULT 0 COMMENT 'unique id in this table' , 
	`is_create_room` tinyint(1) NULL  COMMENT '1 if we need to create this property as a unit in Unee-T' , 
	`unee_t_unit_type` varchar(100) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'The Unee-T type of unit for this property - this MUST be one of the `designation` in the table `ut_unit_types`' , 
	`name` varchar(255) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'The designation (name) of the room' , 
	`more_info` mediumtext COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'Comment (use this to explain teh difference between ipi_calculation and actual)' , 
	`street_address` varchar(413) COLLATE utf8mb4_unicode_520_ci NULL  , 
	`city` varchar(50) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'The City' , 
	`state` varchar(50) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'The State' , 
	`zip_code` varchar(50) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'ZIP or Postal code' , 
	`country` varchar(256) COLLATE utf8mb4_unicode_520_ci NULL  COMMENT 'Description/help text' 
) ENGINE=InnoDB DEFAULT CHARSET='utf8mb4' COLLATE='utf8mb4_unicode_520_ci';

/* Create Trigger in target */

DELIMITER $$
CREATE
    TRIGGER `unte_api_cleanup_before_insert_new_property` BEFORE INSERT ON `unte_api_add_unit` 
    FOR EACH ROW 
BEGIN


		SET @organization_key_new_property := NEW.`organization_key` ;

		# We use the organization key to get the id of the organization:

			SET @organization_id_new_property := (SELECT `organization_id`
				FROM `unte_api_keys`
				WHERE `api_key` = @organization_key_new_property
				)
				;

		# We use the organization_id to get the default values for that organization:
		#	- Default source_of_truth
		#	- Default table for persons
		#	- Default table for properties
		#	- Default table for areas
		#	- Default Area
		#	- Default building
		#	- Default unit

			SET @external_system_id_default := (SELECT `default_sot_system`
				FROM `uneet_enterprise_organizations`
				WHERE `id_organization` = @organization_id_new_property
				)
				;

			SET @external_table_person_default := (SELECT `default_sot_persons`
				FROM `uneet_enterprise_organizations`
				WHERE `id_organization` = @organization_id_new_property
				)
				;

			SET @external_table_new_area_default := (SELECT `default_sot_areas`
				FROM `uneet_enterprise_organizations`
				WHERE `id_organization` = @organization_id_new_property
				)
				;

			SET @external_table_new_property_default := (SELECT `default_sot_properties`
				FROM `uneet_enterprise_organizations`
				WHERE `id_organization` = @organization_id_new_property
				)
				;

			SET @area_new_property_default := (SELECT `default_area`
				FROM `uneet_enterprise_organizations`
				WHERE `id_organization` = @organization_id_new_property
				)
				;

			SET @building_new_property_default := (SELECT `default_building`
				FROM `uneet_enterprise_organizations`
				WHERE `id_organization` = @organization_id_new_property
				)
				;

			SET @unit_new_property_default := (SELECT `default_unit`
				FROM `uneet_enterprise_organizations`
				WHERE `id_organization` = @organization_id_new_property
				)
				;

		# What was the specified values for
		#	- external system

			SET @external_system_id_new_property_input := NEW.`external_system_id` ;

			# IF this is NULL, we need to use the default value for that organization

				SET @external_system_id_new_property := (IF(@external_system_id_new_property_input IS NULL
						, @external_system_id_default
						, IF(@external_system_id_new_property_input = ''
							, @external_system_id_default
							, @external_system_id_new_property_input
							)
						)
					)
				;

		# What was the specified values for
		#	- external table

			SET @external_table_new_property_input := NEW.`external_table` ;

			# IF this is NULL, we need to use the default value for that organization

				SET @external_table_new_property := (IF(@external_table_new_property_input IS NULL
						, @external_table_new_property_default
						, IF(@external_table_new_property_input = ''
							, @external_table_new_property_default
							, @external_table_new_property_input
							)
						)
					)
				;

		# What was the specified values for
		#	- creation_system_id

			SET @external_creation_system_id_input := NEW.`creation_system_id` ;

			# IF this is NULL, we need to use the default value for that organization

				SET @external_creation_system_id := (IF(@external_creation_system_id_input IS NULL
						, 'Not Specified'
						, @external_creation_system_id_input
						)
					)
				;

		# What was the specified values for
		#	- area_mefe_id

			SET @external_area_mefe_id_input := NEW.`area_mefe_id` ;

			# IF this is NULL, we need to use the default value for that organization

				SET @external_area_mefe_id := (IF(@external_area_mefe_id_input IS NULL
						# in this scenario, we use the default area for this organization
						, @area_new_property_default
						# in this scenario, we use the area that was provided
						, @external_area_mefe_id_input
						)
					)
				;

		# What is the Unit Type for this property?

			SET @external_unit_type_new_property := NEW.`unee_t_unit_type` ;

			# What level of property is that?

				# Is this level 1?

					SET @is_unit_type_1_new_property := (SELECT `is_level_1`
						FROM `ut_unit_types`
						WHERE `designation` = @external_unit_type_new_property
						)
						;

				# Is this level 2?

					SET @is_unit_type_2_new_property := (SELECT `is_level_2`
						FROM `ut_unit_types`
						WHERE `designation` = @external_unit_type_new_property
						)
						;

				# Is this level 3?

					SET @is_unit_type_3_new_property := (SELECT `is_level_3`
						FROM `ut_unit_types`
						WHERE `designation` = @external_unit_type_new_property
						)
						;

				# We can now create the variable for the property level:
				#	- 1 <-- Level 1
				#	- 2 <-- Level 2
				#	- 3 <-- Level 3

					SET @external_ut_unit_types_level_new_property := (IF (@is_unit_type_1_new_property = 1
							, 1
							, IF (@is_unit_type_2_new_property = 1
								, 2
								, IF (@is_unit_type_3_new_property = 1
									, 3
									, (@error_message_unknown_unit_level := 'The trigger `unte_api_insert_new_property` is not able to determine the unit level')
									)
								)
							)
						)
						;

		# What was the specified values for
		#	- parent_mefe_id

			SET @external_parent_mefe_id_input := NEW.`parent_mefe_id` ;

			# Is this a correct input? 
			#	- IF this is a level 1 unit, 
			#	  THEN there should be NO parent id
			#	- IF this is a level 2 unit
			#	  THEN there SHOULD be a parent id
			#	- IF this is a level 3 unit
			#	  THEN there SHOULD be a parent id

				SET @is_parent_input_correct := (
					IF (@external_ut_unit_types_level_new_property = 1
						, IF (@external_parent_mefe_id_input IS NULL
							, 'level 1 - no parent - OK'
							, 'level 1 - with parent - NOT OK'
							)
						, IF (@external_ut_unit_types_level_new_property = 2
							, IF (@external_parent_mefe_id_input IS NULL
								, 'level 2 - no parent - NOT OK'
								, 'level 2 - with parent - OK'
								)
							, IF (@external_ut_unit_types_level_new_property = 3
								, IF (@external_parent_mefe_id_input IS NULL
									, 'level 3 - no parent - NOT OK'
									, 'level 3 - with parent - OK'
									)
								, 'Unknown level - NOT OK'
								)
							)
						)
					)
				;

				# We can now do what's needed:
				#	- IF we are in a scenario Level 1 WITH parent <-- make the parent NULL
				#	- IF we are in a scenario Level 2 with NO parent <-- use the default Level 1 for this property
				#	- IF we are in a scenario Level 3 with NO parent <-- use the default Level 2 for this property

					SET @external_parent_mefe_id := IF(@is_parent_input_correct = 'level 1 - no parent - OK'
						# in this scenario, we use the parent that was provided (which should be NULL)
						, @external_parent_mefe_id_input
						, IF(@is_parent_input_correct = 'level 1 - with parent - NOT OK'
							# in this scenario, we use NULL instead of the level 1 id that was provided
							, NULL
							, IF(@is_parent_input_correct = 'level 2 - no parent - NOT OK'
								# in this scenario, we use the default level 1 id
								, @building_new_property_default
								, IF(@is_parent_input_correct = 'level 2 - with parent - OK'
									# in this scenario, we use the level 1 id that was provided
									, @external_parent_mefe_id_input
									, IF(@is_parent_input_correct = 'level 3 - no parent - NOT OK'
										# in this scenario, we use the default level 2 id
										, @unit_new_property_default
										, IF(@is_parent_input_correct = 'level 3 - with parent - OK'
											# in this scenario, we use the level 2 id that was provided
											, @external_parent_mefe_id_input
											# in this an unexpected scenario, we use NULL as parent
											, NULL
											)
										)
									)
								)
							)
						)
						;

		# Do we have a success?
			SET @is_api_success_first_step := (IF(@error_message_unknown_unit_level IS NULL
					, 1
					, 0
					)
				)
				;

		SET NEW.`external_system_id` := @external_system_id_new_property ;
		SET NEW.`external_table` := @external_table_new_property ;
		SET NEW.`syst_updated_datetime` := NOW() ;
		SET NEW.`update_system_id` := 'Unee-T Enterprise' ;
		SET NEW.`update_method` := 'TRIGGER - unte_api_cleanup_before_insert_new_property' ;
		SET NEW.`is_api_success` := @is_api_success_first_step ;
		SET NEW.`api_error_message` := @error_message_unknown_unit_level ;
		SET NEW.`area_mefe_id` := @external_area_mefe_id ;

END;
$$
DELIMITER ;


/* Create Trigger in target */

DELIMITER $$
CREATE
    TRIGGER `unte_api_insert_new_property` AFTER INSERT ON `unte_api_add_unit` 
    FOR EACH ROW 
BEGIN

	# We capture the data we need to use in variables to make it easier.

		SET @request_id_new_property := NEW.`request_id` ;
		SET @new_record_new_property := NEW.`id_unte_api_add_unit` ;
		SET @external_id_new_property := NEW.`external_id` ;
		SET @syst_created_datetime_new_property := NEW.`syst_created_datetime` ;
		SET @organization_key_new_property := NEW.`organization_key` ;

		SET @external_system_id_new_property := NEW.`external_system_id` ;
		SET @external_table_new_property := NEW.`external_table` ;
		SET @external_area_mefe_id := NEW.`area_mefe_id` ;

		# We use the organization key to get the id of the organization:

			SET @organization_id_new_property := (SELECT `organization_id`
				FROM `unte_api_keys`
				WHERE `api_key` = @organization_key_new_property
				)
				;

		# What was the specified values for
		#	- creation_method

			SET @external_creation_method_input := NEW.`creation_method` ;

		# What is the Unit Type for this property?

			SET @external_unit_type_new_property := NEW.`unee_t_unit_type` ;

			# What level of property is that?

				# Is this level 1?

					SET @is_unit_type_1_new_property := (SELECT `is_level_1`
						FROM `ut_unit_types`
						WHERE `designation` = @external_unit_type_new_property
						)
						;

				# Is this level 2?

					SET @is_unit_type_2_new_property := (SELECT `is_level_2`
						FROM `ut_unit_types`
						WHERE `designation` = @external_unit_type_new_property
						)
						;

				# Is this level 3?

					SET @is_unit_type_3_new_property := (SELECT `is_level_3`
						FROM `ut_unit_types`
						WHERE `designation` = @external_unit_type_new_property
						)
						;

				# We can now create the variable for the property level:
				#	- 1 <-- Level 1
				#	- 2 <-- Level 2
				#	- 3 <-- Level 3

					SET @external_ut_unit_types_level_new_property := (IF (@is_unit_type_1_new_property = 1
							, 1
							, IF (@is_unit_type_2_new_property = 1
								, 2
								, IF (@is_unit_type_3_new_property = 1
									, 3
									, 'Unexpected error when trying to determine unit level'
									)
								)
							)
						)
						;

		# What was the specified values for
		#	- parent_mefe_id

			SET @external_parent_mefe_id_input := NEW.`parent_mefe_id` ;

			# Is this a correct input? 
			#	- IF this is a level 1 unit, 
			#	  THEN there should be NO parent id
			#	- IF this is a level 2 unit
			#	  THEN there SHOULD be a parent id
			#	- IF this is a level 3 unit
			#	  THEN there SHOULD be a parent id

				SET @is_parent_input_correct := (
					IF (@external_ut_unit_types_level_new_property = 1
						, IF (@external_parent_mefe_id_input IS NULL
							, 'level 1 - no parent - OK'
							, 'level 1 - with parent - NOT OK'
							)
						, IF (@external_ut_unit_types_level_new_property = 2
							, IF (@external_parent_mefe_id_input IS NULL
								, 'level 2 - no parent - NOT OK'
								, 'level 2 - with parent - OK'
								)
							, IF (@external_ut_unit_types_level_new_property = 3
								, IF (@external_parent_mefe_id_input IS NULL
									, 'level 3 - no parent - NOT OK'
									, 'level 3 - with parent - OK'
									)
								, 'Unknown level - NOT OK'
								)
							)
						)
					)
				;

				# We can now do what's needed:
				#	- IF we are in a scenario Level 1 WITH parent <-- make the parent NULL
				#	- IF we are in a scenario Level 2 with NO parent <-- use the default Level 1 for this property
				#	- IF we are in a scenario Level 3 with NO parent <-- use the default Level 2 for this property

					SET @external_parent_mefe_id := IF(@is_parent_input_correct = 'level 1 - no parent - OK'
						# in this scenario, we use the parent that was provided (which should be NULL)
						, @external_parent_mefe_id_input
						, IF(@is_parent_input_correct = 'level 1 - with parent - NOT OK'
							# in this scenario, we use NULL instead of the level 1 id that was provided
							, NULL
							, IF(@is_parent_input_correct = 'level 2 - no parent - NOT OK'
								# in this scenario, we use the default level 1 id
								, @building_new_property_default
								, IF(@is_parent_input_correct = 'level 2 - with parent - OK'
									# in this scenario, we use the level 1 id that was provided
									, @external_parent_mefe_id_input
									, IF(@is_parent_input_correct = 'level 3 - no parent - NOT OK'
										# in this scenario, we use the default level 2 id
										, @unit_new_property_default
										, IF(@is_parent_input_correct = 'level 3 - with parent - OK'
											# in this scenario, we use the level 2 id that was provided
											, @external_parent_mefe_id_input
											# in this an unexpected scenario, we use NULL as parent
											, NULL
											)
										)
									)
								)
							)
						)
						;

	# We can now get the other variables that were provided as part of the API call:

		SET @designation_new_property := NEW.`designation` ;

		SET @tower_new_property_input := NEW.`tower` ;

			# IF `tower` is NULL, then we use 1 as default

				SET @tower_new_property := IF(@tower_new_property_input IS NULL
					, 1
					, @tower_new_property_input
					)
					;

		SET @unit_id_new_property := NEW.`unit_id` ;
		SET @address_1_new_property := NEW.`address_1` ;
		SET @address_2_new_property := NEW.`address_2` ;
		SET @zip_postal_code_new_property := NEW.`zip_postal_code` ;
		SET @state_new_property := NEW.`state` ;
		SET @city_new_property := NEW.`city` ;
		SET @country_code_new_property := NEW.`country_code` ;
		SET @description_new_property := NEW.`description` ;
		SET @count_rooms_new_property := NEW.`count_rooms` ;
		SET @surface_new_property := NEW.`surface` ;
		SET @surface_measurement_unit_new_property := NEW.`surface_measurement_unit` ;
		SET @number_of_beds_new_property := NEW.`number_of_beds` ;

		# Get the information for the default assignee:

			SET @api_key_mgt_cny_default_assignee_new_property := NEW.`mgt_cny_default_assignee` ;

				# We use the MEFE API key to get the MEFE ID for this user.

				SET @mgt_cny_default_assignee_new_property := (SELECT `unee_t_mefe_user_id`
					FROM `ut_map_external_source_users`
					WHERE `unee_t_mefe_user_api_key` = @api_key_mgt_cny_default_assignee_new_property
					)
					;

			SET @api_key_landlord_default_assignee_new_property := NEW.`landlord_default_assignee` ;

				# We use the MEFE API key to get the MEFE ID for this user.

				SET @landlord_default_assignee_new_property := (SELECT `unee_t_mefe_user_id`
					FROM `ut_map_external_source_users`
					WHERE `unee_t_mefe_user_api_key` = @api_key_landlord_default_assignee_new_property
					)
					;
			SET @api_key_tenant_default_assignee_new_property := NEW.`tenant_default_assignee` ;

				# We use the MEFE API key to get the MEFE ID for this user.

				SET @tenant_default_assignee_new_property := (SELECT `unee_t_mefe_user_id`
					FROM `ut_map_external_source_users`
					WHERE `unee_t_mefe_user_api_key` = @tenant_default_assignee_new_property
					)
					;

			SET @api_key_agent_default_assignee_new_property := NEW.`agent_default_assignee` ;

				# We use the MEFE API key to get the MEFE ID for this user.

				SET @agent_default_assignee_new_property := (SELECT `unee_t_mefe_user_id`
					FROM `ut_map_external_source_users`
					WHERE `unee_t_mefe_user_api_key` = @api_key_agent_default_assignee_new_property
					)
					;

	# We get 1 more variable to record that this can propagate as it should

		SET @external_creation_method := 'unte_api_create_property';

# We have all we need, we can no insert the record in the external tables if appropriate:

	IF @external_ut_unit_types_level_new_property = 1

	# This is a Level 1 property: we need to insert this as a level 1 property

	THEN

		# We need several variables

			SET @area_external_id_new_property := (SELECT `external_id`
				FROM `ut_map_external_source_areas`
				WHERE `mefe_area_id` = @external_area_mefe_id
				)
				;

			SET @area_external_system_new_property := (SELECT `external_system`
				FROM `ut_map_external_source_areas`
				WHERE `mefe_area_id` = @external_area_mefe_id
				)
				;

			SET @area_table_in_external_system_new_property := (SELECT `table_in_external_system`
				FROM `ut_map_external_source_areas`
				WHERE `mefe_area_id` = @external_area_mefe_id
				)
				;

			SET @area_organization_id_new_property := (SELECT `organization_id`
				FROM `ut_map_external_source_areas`
				WHERE `mefe_area_id` = @external_area_mefe_id
				)
				;

			SET @external_area_id_new_property := (SELECT `id_area`
				FROM `external_property_groups_areas`
				WHERE `external_id` = @area_external_id_new_property
					AND `external_system_id` = @area_external_system_new_property
					AND `external_table` = @area_table_in_external_system_new_property
					AND `created_by_id` = @area_organization_id_new_property
				)
				;

			SET @area_id_new_property := (SELECT `id_area`
				FROM `property_groups_areas`
				WHERE `external_id` = @area_external_id_new_property
					AND `external_system_id` = @area_external_system_new_property
					AND `external_table` = @area_table_in_external_system_new_property
					AND `organization_id` = @area_organization_id_new_property
				)
				;

		# We have all the variables we need: we can do the insert

		# We insert the record in the table `external_property_level_1_buildings`

			INSERT INTO `external_property_level_1_buildings`
				(`create_api_request_id`
				, `external_id`
				, `external_system_id` 
				, `external_table`
				, `syst_created_datetime`
				, `creation_system_id`
				, `created_by_id`
				, `creation_method`
				, `is_update_on_duplicate_key`
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
				, `mgt_cny_default_assignee`
				, `landlord_default_assignee`
				, `tenant_default_assignee`
				, `agent_default_assignee`
				)
				VALUES
					(@request_id_new_property
					, @external_id_new_property
					, @external_system_id_new_property
					, @external_table_new_property
					, @syst_created_datetime_new_property
					, @external_creation_system_id
					, @organization_id_new_property
					, @external_creation_method
					, 0
					, 0
					, 0
					, @external_area_id_new_property
					, 1
					, 0
					, @external_unit_type_new_property
					, @designation_new_property
					, @tower_new_property
					, @address_1_new_property
					, @address_2_new_property
					, @zip_postal_code_new_property
					, @state_new_property
					, @city_new_property
					, @country_code_new_property
					, @description_new_property
					, @mgt_cny_default_assignee_new_property
					, @landlord_default_assignee_new_property
					, @tenant_default_assignee_new_property
					, @agent_default_assignee_new_property
					)
				ON DUPLICATE KEY UPDATE
					`edit_api_request_id` := @request_id_new_property
					, `syst_updated_datetime` := @syst_created_datetime_new_property
					, `update_system_id` := @external_creation_system_id
					, `updated_by_id` := @organization_id_new_property
					, `update_method` := @external_creation_method
					, `is_update_on_duplicate_key` := 1
					, `is_obsolete` := 0
					, `order` := 0
					, `area_id` := @external_area_id_new_property
					, `is_creation_needed_in_unee_t` := 1
					, `do_not_insert` := 0
					, `unee_t_unit_type` := @external_unit_type_new_property
					, `designation` := @designation_new_property
					, `tower` := @tower_new_property
					, `address_1` := @address_1_new_property
					, `address_2` := @address_2_new_property
					, `zip_postal_code` := @zip_postal_code_new_property
					, `state` := @state_new_property
					, `city` := @city_new_property
					, `country_code` := @country_code_new_property
					, `description` := @description_new_property
					, `mgt_cny_default_assignee` := @mgt_cny_default_assignee_new_property
					, `landlord_default_assignee` := @landlord_default_assignee_new_property
					, `tenant_default_assignee` := @tenant_default_assignee_new_property
					, `agent_default_assignee` := @agent_default_assignee_new_property
				;



# BELOW IS WIP!!!!






		# Once this is done, we update the table `unte_api_add_unit` to record what was done



	ELSEIF @external_ut_unit_types_level_new_property = 2

	# This is a Level 2 property: we need to insert this as a level 2 property

	THEN

		# We insert the record in the table `external_property_level_2_units`

			SET @placeholder := 1 ;
/*
			INSERT INTO ``
				(``
				, ``
				, ``
				)
				VALUES 
					(
					, 
					, 
					)
				ON DUPLICATE KEY UPDATE
					`` := @
					, `` := @
					, `` := @
				;

*/


	ELSEIF @external_ut_unit_types_level_new_property = 3

	# This is a Level 3 property: we need to insert this as a level 3 property

	THEN

		# We insert the record in the table `external_property_level_3_rooms`

			SET @placeholder := 1 ;
/*
			INSERT INTO ``
				(``
				, ``
				, ``
				)
				VALUES 
					(
					, 
					, 
					)
				ON DUPLICATE KEY UPDATE
					`` := @
					, `` := @
					, `` := @
				;
*/


	ELSE 

		# We do nothing

			SET @placeholder := 1 ;

	END IF;

END;
$$
DELIMITER ;


/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;