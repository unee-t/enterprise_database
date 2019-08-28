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

	SET @old_schema_version := 'v1.22.3';
	SET @new_schema_version := 'v1.22.4';

# What is the name of this script?

	SET @this_script := CONCAT ('upgrade_unee-t_entreprise', @old_schema_version, '_to_', @new_schema_version, '.sql');

# In this update
#
#WIP	- Fix a bug where some of the level 2 properties are not assigned to users who should be assigned to all the properties in the country.
# For more details, see
# https://docs.google.com/document/d/1IyLZHC6nmmeOaTdDkswLUN4QbEC_BG_FfwwuWoNyF5E/edit?usp=sharing
#
#WIP Fix bug when updated `is_obsolete` is not propagating from extL2P to L2P to ut_map
#
#OK	- Add more records to the table `property_types_level_3_rooms`
#OK	- Remove unnecessary FK from some tables:
#		- `property_level_3_rooms`
#		- ``
#
#OK - Make sure we use `utf8mb4_unicode_520_ci` everywhere:
#	  Alter the followig tables:
#		- `log_lambdas`
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

# this change is done by running the scripts:
#	- ``

# Update the values in the table `property_types_level_3_rooms`

	/*!40101 SET NAMES utf8 */;

	/*!40101 SET SQL_MODE=''*/;

	/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
	/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
	/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
	/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
	/*Table structure for table `property_types_level_3_rooms` */

	DROP TABLE IF EXISTS `property_types_level_3_rooms`;

	CREATE TABLE `property_types_level_3_rooms` (
	`id_room_type` int(11) NOT NULL AUTO_INCREMENT COMMENT 'The unique id in this table',
	`external_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The id of the record in an external system',
	`external_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The id of the system which provides the external_system_id',
	`external_table` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The table in the external system where this record is stored',
	`creation_system_id` int(11) NOT NULL DEFAULT '1' COMMENT 'What is the id of the system that was used for the creation of the record?',
	`update_system_id` int(11) DEFAULT NULL COMMENT 'What is the id of the system that was used for the last update the record?',
	`is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
	`is_default` tinyint(1) DEFAULT '0' COMMENT 'This is the default value in our systems',
	`order` int(11) NOT NULL COMMENT 'Order in the list',
	`room_type` varchar(50) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'Designation',
	`room_type_definition` mediumtext COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text',
	PRIMARY KEY (`id_room_type`,`room_type`),
	KEY `loi_type_creation_system_id` (`creation_system_id`),
	KEY `loi_type_update_system_id` (`update_system_id`)
	) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC;

	/*Data for the table `property_types_level_3_rooms` */

	insert  into `property_types_level_3_rooms`(`id_room_type`,`external_id`,`external_system_id`,`external_table`,`creation_system_id`,`update_system_id`,`is_obsolete`,`is_default`,`order`,`room_type`,`room_type_definition`) values 
	(1,NULL,NULL,NULL,1,NULL,0,1,0,'Unknown','We have no information on the room type'),
	(2,'P','hmlet',NULL,1,NULL,0,0,10,'Pocket','Smallest room in the flat'),
	(3,'R','hmlet',NULL,1,NULL,0,0,20,'Regular','Shares a bathroom or shower room.'),
	(4,'M','hmlet',NULL,1,NULL,0,0,30,'Master','En suite bathroom or shower room.'),
	(5,'S','hmlet',NULL,1,NULL,0,0,15,'Studio','There is only one room there'),
	(6,'C','hmlet',NULL,1,NULL,0,0,25,'Common','Difference between Regular is unclear...'),
	(7,'JM','hmlet',NULL,1,NULL,0,0,30,'Junior Master',NULL),
	(8,'JR','hmlet',NULL,1,NULL,0,0,35,'',NULL);

	/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
	/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
	/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
	/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

# Remove unnecessary FK for the table `property_level_3_rooms`

	/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;

	/* Alter table in target */
	ALTER TABLE `property_level_3_rooms` 
		DROP FOREIGN KEY `room_id_room_type_id`  ;
	/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;

# Make sure the table `log_lambdas` use the correct collation:

	ALTER TABLE `log_lambdas` MODIFY `creation_trigger` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci ;
	ALTER TABLE `log_lambdas` MODIFY `mefe_unit_id` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci ;
	ALTER TABLE `log_lambdas` MODIFY `mefe_user_id` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci ;
	ALTER TABLE `log_lambdas` MODIFY `payload` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci ;

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