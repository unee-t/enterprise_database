/*
SQLyog Ultimate v13.1.5  (64 bit)
MySQL - 5.7.12-log : Database - unee_t_enterprise
*********************************************************************
*/

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
