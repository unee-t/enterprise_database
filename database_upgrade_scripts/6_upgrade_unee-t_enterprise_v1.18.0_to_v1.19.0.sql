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
#i
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
####################################################
#
# What are the version of the Unee-T BZ Database schema BEFORE and AFTER this update?

	SET @old_schema_version := 'v1.18.0';
	SET @new_schema_version := 'v1.19.0';

# What is the name of this script?

	SET @this_script := CONCAT ('upgrade_unee-t_entreprise', @old_schema_version, '_to_', @new_schema_version, '.sql');

# In this update
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
#	- Make sure that, in a given organization, the main email for a person is unique
#		- `external_persons`
#		- `persons`
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
# - Drop triggers:
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


# Drop tables we do not need anymore



# Drop the views we do not need:



# Drop the trigger we do not need:



# Drop the Procedures we do not need:



# Create the new tables we need:

	DROP TABLE IF EXISTS `unee_t_import_hmlet_members_from_member_list`;

	CREATE TABLE `unee_t_import_hmlet_members_from_member_list` (
	`id_imported_record` INT(11) NOT NULL AUTO_INCREMENT COMMENT 'Id in this table',
	`syst_created_datetime` TIMESTAMP NULL DEFAULT NULL COMMENT 'When was this record created?',
	`creation_system_id` INT(11) DEFAULT NULL COMMENT 'What is the id of the sytem that was used for the creation of the record?',
	`created_by_id` VARCHAR(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
	`creation_method` VARCHAR(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
	`syst_updated_datetime` TIMESTAMP NULL DEFAULT NULL COMMENT 'When was this record last updated?',
	`update_system_id` INT(11) DEFAULT NULL COMMENT 'What is the id of the sytem that was used for the last update the record?',
	`updated_by_id` VARCHAR(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who updated this record',
	`update_method` VARCHAR(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record updated?',
	`ipi_export_date` datetime DEFAULT NULL COMMENT 'The date when the Export from IPI was done',
	`ipi_export_table_name` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The name of the table that we created in IPI to create or update any record in this table.',
	`hmlet_contract_id` INT(11) NOT NULL COMMENT 'id of the hmlet contract in the ipi table `db_all_dt_4_customers`',
	`hmlet_contract_type_id` INT(11) DEFAULT NULL COMMENT 'A FK to the field `id_customer_types` in the table `db_customer_ls_0_types` in the ipi database',
	`hmlet_contract_type_is_included_occupancy` TINYINT(1) DEFAULT 0 COMMENT 'The value of the field `is_included_occupancy` in the IPI table `db_customer_ls_0_types`',
	`hmlet_contract_type` VARCHAR(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'human readable version of the hmlet contract type. A copy of the field `customer_types` from the IPI table `db_customer_ls_0_types`',
	`country_code` VARCHAR(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'A FK to the table `property_groups_countries` - 2 letter ISO country code',
	`hmlet_external_id_building` INT(10) NOT NULL COMMENT 'id of the building. This is a FK to the ipi table `db_sourcing_ls_0_condo`',
	`mefe_unit_id_level_1` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT 'placeholder_mefe_unit_id_level_1' COMMENT 'The MEFE unit id for the building (level_1 property)',
	`unee_t_level_1_id` int(11) DEFAULT NULL COMMENT 'A FK to the table `property_level_1_buildings`',
	`tower` varchar(50) COLLATE utf8mb4_unicode_520_ci DEFAULT '1' COMMENT 'The tower where the unit is',
	`hmlet_external_id_flat` int(10) NOT NULL COMMENT 'id of the flat. This is a FK to the table `db_all_dt_2_flats`',
	`hmlet_flat_designation` VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'Designation of the flat in IPI',
	`mefe_unit_id_level_2` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT 'placeholder_mefe_unit_id_level_2' COMMENT 'The MEFE unit id for the flat (level_2 property)',
	`unee_t_level_2_id` int(11) DEFAULT NULL COMMENT 'A FK to the table `property_level_2_units`',
	`hmlet_external_id_room` INT(11) DEFAULT NULL COMMENT 'id of the room. This is a FK to the ipi table `205_rooms`',
	`hmlet_room_designation` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'Designation of the room in IPI',
	`mefe_unit_id_level_3` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT 'placeholder_mefe_unit_id_level_3' COMMENT 'The MEFE unit id for the room (level_3 property)',
	`unee_t_level_3_id` int(11) DEFAULT NULL COMMENT 'A FK to the table `property_level_3_rooms`',
	`customer_name` VARCHAR(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'Name of the customer, this is a copy of the field `customer_invoice_name` from the IPI table `db_all_dt_4_customers`',
	`customer_status_id` INT(10) DEFAULT NULL COMMENT 'The current status of the customer. This is a FK to the field `id_customer_status` in the IPI table `db_customer_ls_0_statuses`',
	`customer_status` VARCHAR(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'human readable version of the customer status',
	`current_date_in` DATE DEFAULT NULL COMMENT 'The current start date of the contract for that customer',
	`current_date_out` DATE DEFAULT NULL COMMENT 'The current end date for the contract for that customer',
	`hmlet_external_person_id_main_contact` INT(11) DEFAULT NULL COMMENT 'The person Id for the main contact for this opportunity. This is a FK to the person table in the IPI databse',
	`main_contact_email` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The primary email address of the person',
	`main_contact_is_NOT_the_member` TINYINT(1) DEFAULT NULL COMMENT '1 if the email for the main contac on the contract and the email for this person are NOT the same',
	`first_name` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The first name of the person we need to create',
	`last_name` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The last name of the person we need to create',
	`email` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The email of the person we need to create',
	`email_for_unee_t_account` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The email adress we use to create the Unee-T account',
	`mobile_phone` VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The mobile phone of the person we need to create',
	`mefe_user_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci DEFAULT 'placeholder_mefe_user_id' COMMENT 'The MEFE user id for that member',
	PRIMARY KEY (`hmlet_contract_id`,`email`),
	UNIQUE KEY `unique_id_in_this_table` (`id_imported_record`),
	KEY `search_emails` (`email`),
	KEY `search_building_id` (`hmlet_external_id_building`),
	KEY `search_flat_id` (`hmlet_external_id_flat`),
	KEY `search_room_id` (`hmlet_external_id_room`),
	KEY `search_tower` (`tower`),
	KEY `search_mefe_user_id` (`mefe_user_id`),
	KEY `search_mefe_level_1_unit_id` (`mefe_unit_id_level_1`),
	KEY `search_mefe_level_2_unit_id` (`mefe_unit_id_level_2`),
	KEY `search_mefe_level_3_unit_id` (`mefe_unit_id_level_3`),
	KEY `search_organization_id` (`created_by_id`),
	KEY `search_contract_status_id` (`customer_status_id`),
	KEY `search_contract_type_id` (`hmlet_contract_type_id`)
	) ENGINE=INNODB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

# Alter the tables

	/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;

	/* Alter table in target */
	ALTER TABLE `external_map_user_unit_role_permissions_level_1` 
		DROP KEY `PRIMARY`
		, ADD PRIMARY KEY(`unee_t_mefe_user_id`,`unee_t_level_1_id`) 
		;

	/* Alter table in target */
	ALTER TABLE `external_map_user_unit_role_permissions_level_2` 
		DROP KEY `PRIMARY`
		, ADD PRIMARY KEY(`unee_t_mefe_user_id`,`unee_t_level_2_id`) 
		;

	/* Alter table in target */
	ALTER TABLE `external_map_user_unit_role_permissions_level_3` 
		DROP KEY `PRIMARY`
		, ADD PRIMARY KEY(`unee_t_mefe_user_id`,`unee_t_level_3_id`) 
		;

	/* Alter table in target */
	ALTER TABLE `external_persons` 
		ADD UNIQUE KEY `in_an_organization_extrenal_person_main_email_must_be_unique`(`created_by_id`,`email`) 
		;

	/* Alter table in target */
	ALTER TABLE `persons` 
		ADD UNIQUE KEY `in_an_organization_person_main_email_must_be_unique`(`email`,`organization_id`) 
		;

	/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;











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