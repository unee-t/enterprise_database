# This script erases all the data created as part of tests and trials

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

# Delete the records from the table `uneet_enterprise_settings`

	DELETE FROM `uneet_enterprise_settings`;
	
	ALTER TABLE `uneet_enterprise_settings` AUTO_INCREMENT = 1;

# Delete the records from the table `external_persons`

	DELETE FROM `external_persons`;
	
	ALTER TABLE `external_persons` AUTO_INCREMENT = 1;

# Delete the records from the table `external_property_addresses`

	DELETE FROM `external_property_addresses`;
	
	ALTER TABLE `external_property_addresses` AUTO_INCREMENT = 1;

# Delete the records from the table `external_property_groups_areas`

	DELETE FROM `external_property_groups_areas`;
	
	ALTER TABLE `external_property_groups_areas` AUTO_INCREMENT = 1;

# Delete the records from the table `external_property_level_1_building`

	DELETE FROM `external_property_level_1_buildings`;
	
	ALTER TABLE `external_property_level_1_buildings` AUTO_INCREMENT = 1;

# Delete the records from the table `external_property_level_2_units`

	DELETE FROM `external_property_level_2_units`;
	
	ALTER TABLE `external_property_level_2_units` AUTO_INCREMENT = 1;

# Delete the records from the table `external_property_level_3_rooms`

	DELETE FROM `external_property_level_3_rooms`;
	
	ALTER TABLE `external_property_level_3_rooms` AUTO_INCREMENT = 1;

# Delete the records from the table `log_lambdas`

	DELETE FROM `log_lambdas`;
	
	ALTER TABLE `log_lambdas` AUTO_INCREMENT = 1;


# Delete the records from the table `persons`

	DELETE FROM `persons`;
	
	ALTER TABLE `persons` AUTO_INCREMENT = 1;


# Delete the records from the table `property_addresses`

	DELETE FROM `property_addresses`;
	
	ALTER TABLE `property_addresses` AUTO_INCREMENT = 1;


# Delete the records from the table `property_groups_areas`

	DELETE FROM `property_groups_areas`;
	
	ALTER TABLE `property_groups_areas` AUTO_INCREMENT = 1;

# Default Data for the table `property_groups_areas`

	INSERT  INTO `property_groups_areas`(`id_area`,`external_id`,`external_system_id`,`external_table`,`syst_created_datetime`,`creation_system_id`,`created_by_id`,`creation_method`,`syst_updated_datetime`,`update_system_id`,`updated_by_id`,`update_method`,`is_creation_needed_in_unee_t`,`organization_id`,`country_code`,`is_obsolete`,`is_default`,`order`,`area_name`,`area_definition`) VALUES 
		(1,'test_1','test','test_areas','2019-03-24 11:35:36',1,NULL,NULL,NULL,NULL,NULL,NULL,1,1,NULL,0,1,NULL,'UNKNOWN','We have no information about the area for that unit.');

# Delete the records from the table `property_level_1_buildings`

	DELETE FROM `property_level_1_buildings`;
	
	ALTER TABLE `property_level_1_buildings` AUTO_INCREMENT = 1;

# Delete the records from the table `property_level_2_units`

	DELETE FROM `property_level_2_units`;
	
	ALTER TABLE `property_level_2_units` AUTO_INCREMENT = 1;

# Delete the records from the table `property_level_3_rooms`

	DELETE FROM `property_level_3_rooms`;
	
	ALTER TABLE `property_level_3_rooms` AUTO_INCREMENT = 1;

# Delete the records from the table `uneet_enterprise_audit`

	DELETE FROM `uneet_enterprise_audit`;
	
	ALTER TABLE `uneet_enterprise_audit` AUTO_INCREMENT = 1;

# Delete the records from the table `ut_map_external_source_units`

	DELETE FROM `ut_map_external_source_units`;
	
	ALTER TABLE `ut_map_external_source_units` AUTO_INCREMENT = 1;

# Delete the records from the table `ut_map_external_source_users`

	DELETE FROM `ut_map_external_source_users`;
	
	ALTER TABLE `ut_map_external_source_users` AUTO_INCREMENT = 1;

# Delete the records from the table `ut_map_user_permissions_default`

	DELETE FROM `ut_map_user_permissions_default`;
	
	ALTER TABLE `ut_map_user_permissions_default` AUTO_INCREMENT = 1;

# Delete the records from the table `ut_map_user_permissions_unit_all`

	DELETE FROM `ut_map_user_permissions_unit_all`;
	
	ALTER TABLE `ut_map_user_permissions_unit_all` AUTO_INCREMENT = 1;

# Delete the records from the table `ut_map_user_permissions_unit_level_1`

	DELETE FROM `ut_map_user_permissions_unit_level_1`;
	
	ALTER TABLE `ut_map_user_permissions_unit_level_1` AUTO_INCREMENT = 1;

# Delete the records from the table `ut_map_user_permissions_unit_level_2`

	DELETE FROM `ut_map_user_permissions_unit_level_2`;
	
	ALTER TABLE `ut_map_user_permissions_unit_level_2` AUTO_INCREMENT = 1;

# Delete the records from the table `ut_map_user_permissions_unit_level_3`

	DELETE FROM `ut_map_user_permissions_unit_level_3`;
	
	ALTER TABLE `ut_map_user_permissions_unit_level_3` AUTO_INCREMENT = 1;	

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
