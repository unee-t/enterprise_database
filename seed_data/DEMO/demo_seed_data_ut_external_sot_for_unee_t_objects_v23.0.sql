/*
SQLyog Ultimate v13.1.5  (64 bit)
MySQL - 5.7.12 : Database - temporary_for_tests
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
/*Table structure for table `ut_external_sot_for_unee_t_objects` */

DROP TABLE IF EXISTS `ut_external_sot_for_unee_t_objects`;

CREATE TABLE `ut_external_sot_for_unee_t_objects` (
  `id_external_sot_for_unee_t` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique id in this table',
  `syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
  `creation_system_id` int(11) NOT NULL DEFAULT '1' COMMENT 'What is the id of the system that was used for the creation of the record?',
  `created_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who created this record',
  `creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
  `syst_updated_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record last updated?',
  `update_system_id` int(11) DEFAULT NULL COMMENT 'What is the id of the system that was used for the last update the record?',
  `updated_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who updated this record',
  `update_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record updated?',
  `organization_id` int(11) unsigned DEFAULT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
  `order` int(11) DEFAULT NULL COMMENT 'Order in the list',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT '1 if this is not in use anymore.',
  `designation` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The designation',
  `description` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Detailed description',
  `person_table` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT 'table_persons' COMMENT 'The name of the table that stores information about persons',
  `area_table` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT 'table_areas' COMMENT 'The name of the table that stores the Area information in the external system',
  `properties_level_1_table` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT 'table_properties_level_1' COMMENT 'The name of the table that stores the info about Level 1 properties',
  `properties_level_2_table` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT 'table_properties_level_2' COMMENT 'The name of the table that stores the info about Level 2 properties',
  `properties_level_3_table` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT 'table_properties_level_3' COMMENT 'The name of the table that stores the info about Level 3 properties',
  PRIMARY KEY (`id_external_sot_for_unee_t`),
  KEY `sot_organization_id` (`organization_id`),
  CONSTRAINT `sot_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC;

/*Data for the table `ut_external_sot_for_unee_t_objects` */

insert  into `ut_external_sot_for_unee_t_objects`(`id_external_sot_for_unee_t`,`syst_created_datetime`,`creation_system_id`,`created_by_id`,`creation_method`,`syst_updated_datetime`,`update_system_id`,`updated_by_id`,`update_method`,`organization_id`,`order`,`is_obsolete`,`designation`,`description`,`person_table`,`area_table`,`properties_level_1_table`,`properties_level_2_table`,`properties_level_3_table`) values 
(1,'2019-03-10 14:36:25',1,'1',NULL,NULL,NULL,NULL,NULL,NULL,0,0,'UNKNOWN','We have no information about this system','table_persons','table_areas','table_properties_level_1','table_properties_level_2','table_properties_level_3'),
(2,'2019-04-02 19:33:10',1,'1',NULL,NULL,NULL,NULL,NULL,1,5,0,'Unee-T Enterprise','This system.','person_table','area_table','properties_level_1_table','properties_level_2_table','properties_level_3_table'),
(3,'2019-03-10 14:36:25',1,'1',NULL,NULL,NULL,NULL,NULL,2,10,0,'demo_company_system','The DEMO company backend system.','db_persons','db_areas','db_L1P','db_L2P','db_L3P');

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
