#################
#
# Views and procedures we need if we need to re-try
#   - Association user to unit
# The source of the error was:
#	- `[the requestor] is not an owner of unit`
#	- `The invited user already has a role in this unit`
#
#################
#
# This script creates the following tables:
#	- `retry_assign_user_to_units_list`
#
# This script will create or update the following:
#	- Views:
#		- `ut_analysis_errors_user_already_has_a_role_list`
#		- `ut_analysis_errors_user_already_has_a_role_count`
#		- `ut_analysis_errors_not_an_owner_list`
#		- `ut_analysis_errors_not_an_owner_count`
#
# 	- Procedures
#		- `ut_retry_assign_user_to_units_error_ownership`
#		- `ut_retry_assign_user_to_units_error_already_has_role`
#		- ``


# We Create a table that will be used to activate the trigger for re-creation

	DROP TABLE IF EXISTS `retry_assign_user_to_units_list` ;

	CREATE TABLE `retry_assign_user_to_units_list` (
		`id_map_user_unit_permissions` INT(11) NOT NULL COMMENT 'Id in this table',
  		`syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
  		`creation_system_id` int(11) NOT NULL DEFAULT 1 COMMENT 'What is the id of the sytem that was used for the creation of the record?',
		`created_by_id` VARCHAR(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who created this record',
		`creation_method` VARCHAR(255) COLLATE utf8mb4_unicode_520_ci NOT NULL,
		`mefe_user_id` VARCHAR (255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The current Unee-T profile id of the person - this is the value of the field `_id` in the Mongo Collection `users`',
		`uneet_login_name` VARCHAR(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The MEFE login of the user we invite',
		`mefe_unit_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'ID of that Unit in Unee-T. This is the value of the field _id in the Mongo collection units',
		`uneet_name` VARCHAR(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The name of the unit in the MEFE',
		`unee_t_role_id` smallint(6) DEFAULT NULL COMMENT 'FK to the Unee-T BZFE table `ut_role_types` - ID of the Role for this user.',
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
		`is_message_from_my_role` tinyint(1) DEFAULT 0 COMMENT '1 if user wants to be notified',
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
		UNIQUE KEY `map_user_unit_role_permissions` (`id_map_user_unit_permissions`),
		KEY `retry_mefe_unit_must_exist` (`mefe_unit_id`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci
		;

# We create a view to list all the error where the user already has a role in the unit

	DROP VIEW IF EXISTS `ut_analysis_errors_user_already_has_a_role_list` ;

	CREATE VIEW `ut_analysis_errors_user_already_has_a_role_list`
	AS
		SELECT
		`a`.`id_map_user_unit_permissions`
		, `a`.`syst_created_datetime`
		, `a`.`unee_t_update_ts`
		, `a`.`is_mefe_api_success`
		, `a`.`mefe_api_error_message`
		, `a`.`unee_t_mefe_id` AS `mefe_user_id`
		, `b`.`uneet_login_name`
		, `a`.`unee_t_unit_id`
		, `c`.`uneet_name`
		, `d`.`role_type`
	FROM
		`ut_map_user_permissions_unit_all` AS `a`
		LEFT JOIN `ut_map_external_source_users` AS `b`
		ON (`a`.`unee_t_mefe_id` = `b`.`unee_t_mefe_user_id`)
		LEFT JOIN `ut_map_external_source_units` AS `c`
		ON (`a`.`unee_t_unit_id` = `c`.`unee_t_mefe_unit_id`)
		LEFT JOIN `ut_user_role_types` AS `d`
		ON (`a`.`unee_t_role_id` = `d`.`id_role_type`)
	WHERE (`a`.`is_mefe_api_success` = 0
		AND `a`.`mefe_api_error_message` LIKE '%The invited user already has a role in this unit%')
		;

# We create a view to count all the error where the user already has a role in the unit

	DROP VIEW IF EXISTS `ut_analysis_errors_user_already_has_a_role_count` ;

	CREATE VIEW `ut_analysis_errors_user_already_has_a_role_count`
	AS	
	SELECT
		COUNT(`id_map_user_unit_permissions`) AS `count_user_already_has_role`
	FROM
		`ut_analysis_errors_user_already_has_a_role_list`
	GROUP BY `is_mefe_api_success`
	;

# We create a view to list all the error where the unit the reqestor is not an owner of the unit

	DROP VIEW IF EXISTS `ut_analysis_errors_not_an_owner_list` ;

	CREATE VIEW `ut_analysis_errors_not_an_owner_list`
	AS
		SELECT
		`a`.`id_map_user_unit_permissions`
		, `a`.`syst_created_datetime`
		, `a`.`unee_t_update_ts`
		, `a`.`is_mefe_api_success`
		, `a`.`mefe_api_error_message`
		, `a`.`unee_t_mefe_id` AS `mefe_user_id`
		, `b`.`uneet_login_name`
		, `a`.`unee_t_unit_id`
		, `c`.`uneet_name`
		, `d`.`role_type`
	FROM
		`ut_map_user_permissions_unit_all` AS `a`
		LEFT JOIN `ut_map_external_source_users` AS `b`
		ON (`a`.`unee_t_mefe_id` = `b`.`unee_t_mefe_user_id`)
		LEFT JOIN `ut_map_external_source_units` AS `c`
		ON (`a`.`unee_t_unit_id` = `c`.`unee_t_mefe_unit_id`)
		LEFT JOIN `ut_user_role_types` AS `d`
		ON (`a`.`unee_t_role_id` = `d`.`id_role_type`)
	WHERE (`a`.`is_mefe_api_success` = 0
		AND `a`.`mefe_api_error_message` LIKE '%not an owner of unit%')
		;

# We create a view to count all the error where the user already has a role in the unit

	DROP VIEW IF EXISTS `ut_analysis_errors_not_an_owner_count` ;

	CREATE VIEW `ut_analysis_errors_not_an_owner_count`
	AS	
	SELECT
		COUNT(`id_map_user_unit_permissions`) AS `count_reuquestor_not_an_owner`
	FROM
		`ut_analysis_errors_not_an_owner_list`
	GROUP BY `is_mefe_api_success`
	;

# Error `[the requestor] is not an owner of unit`
# Create the procedure to re-try creating the association user to unit if the API failed

	DROP PROCEDURE IF EXISTS `ut_retry_assign_user_to_units_error_ownership`;

DELIMITER $$
CREATE PROCEDURE `ut_retry_assign_user_to_units_error_ownership`()
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN

####################
#
# WARNING!!
# Only run this if you are CERTAIN that the API has failed somehow
#
####################

# Clean slate - remove all data from `retry_assign_user_to_units_list`

	TRUNCATE TABLE `retry_assign_user_to_units_list` ;

# We insert the data we need in the table `retry_assign_user_to_units_list`
# This will trigger a retry of the lambda call

	INSERT INTO `retry_assign_user_to_units_list`
		( `id_map_user_unit_permissions`
		, `syst_created_datetime`
		, `creation_system_id`
		, `created_by_id`
		, `creation_method`
		, `mefe_user_id`
		, `uneet_login_name`
		, `mefe_unit_id`
		, `uneet_name`
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
		, `is_message_from_my_role`
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
		`a`.`id_map_user_unit_permissions`
		, `b`.`syst_created_datetime`
		, `b`.`creation_system_id`
		, `b`.`created_by_id`
		, 'ut_retry_assign_user_to_units_error_ownership'
		, `a`.`mefe_user_id`
		, `a`.`uneet_login_name`
		, `a`.`unee_t_unit_id`
		, `a`.`uneet_name`
		, `b`.`unee_t_role_id`
		, `b`.`is_occupant`
		, `b`.`is_default_assignee`
		, `b`.`is_default_invited`
		, `b`.`is_unit_owner`
		, `b`.`is_public`
		, `b`.`can_see_role_landlord`
		, `b`.`can_see_role_tenant`
		, `b`.`can_see_role_mgt_cny`
		, `b`.`can_see_role_agent`
		, `b`.`can_see_role_contractor`
		, `b`.`can_see_occupant`
		, `b`.`is_assigned_to_case`
		, `b`.`is_invited_to_case`
		, `b`.`is_next_step_updated`
		, `b`.`is_deadline_updated`
		, `b`.`is_solution_updated`
		, `b`.`is_case_resolved`
		, `b`.`is_case_blocker`
		, `b`.`is_case_critical`
		, `b`.`is_any_new_message`
		, `b`.`is_message_from_my_role`
		, `b`.`is_message_from_tenant`
		, `b`.`is_message_from_ll`
		, `b`.`is_message_from_occupant`
		, `b`.`is_message_from_agent`
		, `b`.`is_message_from_mgt_cny`
		, `b`.`is_message_from_contractor`
		, `b`.`is_new_ir`
		, `b`.`is_new_item`
		, `b`.`is_item_removed`
		, `b`.`is_item_moved`
	FROM `ut_analysis_errors_not_an_owner_list` AS `a`
		INNER JOIN `ut_map_user_permissions_unit_all` AS `b`
			ON (`a`.`id_map_user_unit_permissions` = `b`.`id_map_user_unit_permissions`)
		;

END $$
DELIMITER ;

# Error `The invited user already has a role in this unit`
# Create the procedure to re-try creating the association user to unit if the API failed

	DROP PROCEDURE IF EXISTS `ut_retry_assign_user_to_units_error_already_has_role`;

DELIMITER $$
CREATE PROCEDURE `ut_retry_assign_user_to_units_error_already_has_role`()
	LANGUAGE SQL
SQL SECURITY INVOKER
BEGIN

####################
#
# WARNING!!
# Only run this if you are CERTAIN that the API has failed somehow
#
####################

	SET @creation_method := 'ut_retry_assign_user_to_units_error_already_has_role' ;

# Level 1 units first
# We create a TEMP table that will store the info so they can be accessible after deletion

	DROP TEMPORARY TABLE IF EXISTS `retry_assign_user_to_units_list_temporary_level_1` ;

	CREATE TEMPORARY TABLE `retry_assign_user_to_units_list_temporary_level_1` (
		`id_map_user_unit_permissions` INT(11) NOT NULL COMMENT 'Id in this table',
  		`syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
  		`creation_system_id` int(11) NOT NULL DEFAULT 1 COMMENT 'What is the id of the sytem that was used for the creation of the record?',
		`created_by_id` VARCHAR(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who created this record',
		`creation_method` VARCHAR(255) COLLATE utf8mb4_unicode_520_ci NOT NULL,
		`organization_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
		`mefe_user_id` VARCHAR (255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The current Unee-T profile id of the person - this is the value of the field `_id` in the Mongo Collection `users`',
		`uneet_login_name` VARCHAR(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The MEFE login of the user we invite',
		`mefe_unit_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'ID of that Unit in Unee-T. This is the value of the field _id in the Mongo collection units',
		`unee_t_level_1_id` int(11) NOT NULL COMMENT 'A FK to the table `property_level_1_buildings`',
		`unee_t_user_type_id` int(11) NOT NULL COMMENT 'A FK to the table `ut_user_types`',
		`external_property_type_id` int(11) NOT NULL COMMENT 'A FK to the table `ut_property_types`',
		`uneet_name` VARCHAR(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The name of the unit in the MEFE',
		`unee_t_role_id` smallint(6) DEFAULT NULL COMMENT 'FK to the Unee-T BZFE table `ut_role_types` - ID of the Role for this user.',
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
		`is_message_from_my_role` tinyint(1) DEFAULT 0 COMMENT '1 if user wants to be notified',
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
		UNIQUE KEY `map_user_unit_role_permissions` (`id_map_user_unit_permissions`),
		KEY `retry_mefe_unit_must_exist` (`mefe_unit_id`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci
		;

# We insert the data we need in the table `retry_assign_user_to_units_list_temporary_level_1`
# We start with the Level 1 units.

	INSERT INTO `retry_assign_user_to_units_list_temporary_level_1`
		( `id_map_user_unit_permissions`
		, `syst_created_datetime`
		, `creation_system_id`
		, `created_by_id`
		, `creation_method`
		, `organization_id`
		, `mefe_user_id`
		, `uneet_login_name`
		, `mefe_unit_id`
		, `unee_t_level_1_id`
		, `unee_t_user_type_id`
		, `external_property_type_id`
		, `uneet_name`
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
		, `is_message_from_my_role`
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
		`a`.`id_map_user_unit_permissions`
		, `b`.`syst_created_datetime`
		, `b`.`creation_system_id`
		, `b`.`organization_id`
		, @creation_method
		, `b`.`organization_id`
		, `a`.`mefe_user_id`
		, `a`.`uneet_login_name`
		, `a`.`unee_t_unit_id`
		, `c`.`new_record_id`
		, `e`.`unee_t_user_type_id`
		, `c`.`external_property_type_id`
		, `a`.`uneet_name`
		, `b`.`unee_t_role_id`
		, `b`.`is_occupant`
		, `b`.`is_default_assignee`
		, `b`.`is_default_invited`
		, `b`.`is_unit_owner`
		, `b`.`is_public`
		, `b`.`can_see_role_landlord`
		, `b`.`can_see_role_tenant`
		, `b`.`can_see_role_mgt_cny`
		, `b`.`can_see_role_agent`
		, `b`.`can_see_role_contractor`
		, `b`.`can_see_occupant`
		, `b`.`is_assigned_to_case`
		, `b`.`is_invited_to_case`
		, `b`.`is_next_step_updated`
		, `b`.`is_deadline_updated`
		, `b`.`is_solution_updated`
		, `b`.`is_case_resolved`
		, `b`.`is_case_blocker`
		, `b`.`is_case_critical`
		, `b`.`is_any_new_message`
		, `b`.`is_message_from_my_role`
		, `b`.`is_message_from_tenant`
		, `b`.`is_message_from_ll`
		, `b`.`is_message_from_occupant`
		, `b`.`is_message_from_agent`
		, `b`.`is_message_from_mgt_cny`
		, `b`.`is_message_from_contractor`
		, `b`.`is_new_ir`
		, `b`.`is_new_item`
		, `b`.`is_item_removed`
		, `b`.`is_item_moved`
	FROM `ut_analysis_errors_user_already_has_a_role_list` AS `a`
		INNER JOIN `ut_map_user_permissions_unit_all` AS `b`
			ON (`a`.`id_map_user_unit_permissions` = `b`.`id_map_user_unit_permissions`)
		INNER JOIN `ut_map_external_source_units` AS `c`
			ON (`a`.`unee_t_unit_id` = `c`.`unee_t_mefe_unit_id`)
		INNER JOIN `ut_map_external_source_users` AS `d`
			ON (`a`.`mefe_user_id` = `d`.`unee_t_mefe_user_id`)
		INNER JOIN `persons` AS `e`
			ON (`e`.`id_person` = `d`.`person_id`)
		WHERE `c`.`external_property_type_id` = 1
		;

# We can now DELETE all the offending records from the table `external_map_user_unit_role_permissions_level_1`
# The deletion will cascase to Level 2 and level 3 units.

	DELETE `external_map_user_unit_role_permissions_level_1` FROM `external_map_user_unit_role_permissions_level_1`
		INNER JOIN `retry_assign_user_to_units_list_temporary_level_1`
			ON (`external_map_user_unit_role_permissions_level_1`.`unee_t_level_1_id` = `retry_assign_user_to_units_list_temporary_level_1`.`unee_t_level_1_id`
				AND `external_map_user_unit_role_permissions_level_1`.`unee_t_mefe_user_id` = `retry_assign_user_to_units_list_temporary_level_1`.`mefe_user_id`)
		;

# Clean slate - remove all data from `retry_assign_user_to_units_list`

	TRUNCATE TABLE `retry_assign_user_to_units_list` ;

# Are now re-inserting the records that were deleted for the Level 1 units:

	INSERT INTO `external_map_user_unit_role_permissions_level_1`
		( `syst_created_datetime`
		, `creation_system_id`
		, `created_by_id`
		, `creation_method`
		, `organization_id`
		, `unee_t_mefe_user_id`
		, `unee_t_level_1_id`
		, `unee_t_user_type_id`
		, `unee_t_role_id`
		, `propagate_level_2`
		, `propagate_level_3`
		)
	SELECT
		`a`.`syst_created_datetime`
		, `a`.`creation_system_id`
		, `a`.`created_by_id`
		, `a`.`creation_method`
		, `a`.`organization_id`
		, `a`.`mefe_user_id`
		, `a`.`unee_t_level_1_id`
		, `a`.`unee_t_user_type_id`
		, `a`.`unee_t_role_id`
		, 1
		, 1
	FROM `retry_assign_user_to_units_list_temporary_level_1` AS `a`
		;

# Level 2 units
# We create a TEMP table that will store the info so they can be accessible after deletion

	DROP TEMPORARY TABLE IF EXISTS `retry_assign_user_to_units_list_temporary_level_2` ;

	CREATE TEMPORARY TABLE `retry_assign_user_to_units_list_temporary_level_2` (
		`id_map_user_unit_permissions` INT(11) NOT NULL COMMENT 'Id in this table',
  		`syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
  		`creation_system_id` int(11) NOT NULL DEFAULT 1 COMMENT 'What is the id of the sytem that was used for the creation of the record?',
		`created_by_id` VARCHAR(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who created this record',
		`creation_method` VARCHAR(255) COLLATE utf8mb4_unicode_520_ci NOT NULL,
		`organization_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
		`mefe_user_id` VARCHAR (255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The current Unee-T profile id of the person - this is the value of the field `_id` in the Mongo Collection `users`',
		`uneet_login_name` VARCHAR(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The MEFE login of the user we invite',
		`mefe_unit_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'ID of that Unit in Unee-T. This is the value of the field _id in the Mongo collection units',
		`unee_t_level_2_id` int(11) NOT NULL COMMENT 'A FK to the table `property_level_1_buildings`',
		`unee_t_user_type_id` int(11) NOT NULL COMMENT 'A FK to the table `ut_user_types`',
		`external_property_type_id` int(11) NOT NULL COMMENT 'A FK to the table `ut_property_types`',
		`uneet_name` VARCHAR(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The name of the unit in the MEFE',
		`unee_t_role_id` smallint(6) DEFAULT NULL COMMENT 'FK to the Unee-T BZFE table `ut_role_types` - ID of the Role for this user.',
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
		`is_message_from_my_role` tinyint(1) DEFAULT 0 COMMENT '1 if user wants to be notified',
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
		UNIQUE KEY `map_user_unit_role_permissions` (`id_map_user_unit_permissions`),
		KEY `retry_mefe_unit_must_exist` (`mefe_unit_id`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci
		;

# We insert the data we need in the table `retry_assign_user_to_units_list_temporary_level_2`
# Level 2 units.

	INSERT INTO `retry_assign_user_to_units_list_temporary_level_2`
		( `id_map_user_unit_permissions`
		, `syst_created_datetime`
		, `creation_system_id`
		, `created_by_id`
		, `creation_method`
		, `organization_id`
		, `mefe_user_id`
		, `uneet_login_name`
		, `mefe_unit_id`
		, `unee_t_level_2_id`
		, `unee_t_user_type_id`
		, `external_property_type_id`
		, `uneet_name`
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
		, `is_message_from_my_role`
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
		`a`.`id_map_user_unit_permissions`
		, `b`.`syst_created_datetime`
		, `b`.`creation_system_id`
		, `b`.`organization_id`
		, @creation_method
		, `b`.`organization_id`
		, `a`.`mefe_user_id`
		, `a`.`uneet_login_name`
		, `a`.`unee_t_unit_id`
		, `c`.`new_record_id`
		, `e`.`unee_t_user_type_id`
		, `c`.`external_property_type_id`
		, `a`.`uneet_name`
		, `b`.`unee_t_role_id`
		, `b`.`is_occupant`
		, `b`.`is_default_assignee`
		, `b`.`is_default_invited`
		, `b`.`is_unit_owner`
		, `b`.`is_public`
		, `b`.`can_see_role_landlord`
		, `b`.`can_see_role_tenant`
		, `b`.`can_see_role_mgt_cny`
		, `b`.`can_see_role_agent`
		, `b`.`can_see_role_contractor`
		, `b`.`can_see_occupant`
		, `b`.`is_assigned_to_case`
		, `b`.`is_invited_to_case`
		, `b`.`is_next_step_updated`
		, `b`.`is_deadline_updated`
		, `b`.`is_solution_updated`
		, `b`.`is_case_resolved`
		, `b`.`is_case_blocker`
		, `b`.`is_case_critical`
		, `b`.`is_any_new_message`
		, `b`.`is_message_from_my_role`
		, `b`.`is_message_from_tenant`
		, `b`.`is_message_from_ll`
		, `b`.`is_message_from_occupant`
		, `b`.`is_message_from_agent`
		, `b`.`is_message_from_mgt_cny`
		, `b`.`is_message_from_contractor`
		, `b`.`is_new_ir`
		, `b`.`is_new_item`
		, `b`.`is_item_removed`
		, `b`.`is_item_moved`
	FROM `ut_analysis_errors_user_already_has_a_role_list` AS `a`
		INNER JOIN `ut_map_user_permissions_unit_all` AS `b`
			ON (`a`.`id_map_user_unit_permissions` = `b`.`id_map_user_unit_permissions`)
		INNER JOIN `ut_map_external_source_units` AS `c`
			ON (`a`.`unee_t_unit_id` = `c`.`unee_t_mefe_unit_id`)
		INNER JOIN `ut_map_external_source_users` AS `d`
			ON (`a`.`mefe_user_id` = `d`.`unee_t_mefe_user_id`)
		INNER JOIN `persons` AS `e`
			ON (`e`.`id_person` = `d`.`person_id`)
		WHERE `c`.`external_property_type_id` = 2
		;

# We can now DELETE all the offending records from the table `external_map_user_unit_role_permissions_level_2`
# The deletion will cascase to Level 2 and level 3 units.

	DELETE `external_map_user_unit_role_permissions_level_2` FROM `external_map_user_unit_role_permissions_level_2`
		INNER JOIN `retry_assign_user_to_units_list_temporary_level_2`
			ON (`external_map_user_unit_role_permissions_level_2`.`unee_t_level_2_id` = `retry_assign_user_to_units_list_temporary_level_2`.`unee_t_level_2_id`
				AND `external_map_user_unit_role_permissions_level_2`.`unee_t_mefe_user_id` = `retry_assign_user_to_units_list_temporary_level_2`.`mefe_user_id`)
		;

# Clean slate - remove all data from `retry_assign_user_to_units_list`

	TRUNCATE TABLE `retry_assign_user_to_units_list` ;

# Are now re-inserting the records that were deleted for the Level 2 units:

	INSERT INTO `external_map_user_unit_role_permissions_level_2`
		( `syst_created_datetime`
		, `creation_system_id`
		, `created_by_id`
		, `creation_method`
		, `organization_id`
		, `unee_t_mefe_user_id`
		, `unee_t_level_2_id`
		, `unee_t_user_type_id`
		, `unee_t_role_id`
		, `propagate_level_2`
		, `propagate_level_3`
		)
	SELECT
		`a`.`syst_created_datetime`
		, `a`.`creation_system_id`
		, `a`.`created_by_id`
		, `a`.`creation_method`
		, `a`.`organization_id`
		, `a`.`mefe_user_id`
		, `a`.`unee_t_level_2_id`
		, `a`.`unee_t_user_type_id`
		, `a`.`unee_t_role_id`
		, 1
		, 1
	FROM `retry_assign_user_to_units_list_temporary_level_2` AS `a`
		;



END $$
DELIMITER ;
