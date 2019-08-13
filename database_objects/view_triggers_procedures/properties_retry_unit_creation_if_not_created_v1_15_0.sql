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
	WHERE `unee_t_mefe_unit_id` IS NULL
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
	WHERE `unee_t_mefe_unit_id` IS NULL
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
		AND `external_property_type_id` = 3
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
