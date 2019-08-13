/*
SQLyog Ultimate v13.1.2 (64 bit)
MySQL - 5.7.12-log : Database - unee_t_enterprise
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
/*Table structure for table `db_schema_version` */

DROP TABLE IF EXISTS `db_schema_version`;

CREATE TABLE `db_schema_version` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique ID in this table',
  `schema_version` varchar(256) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The current version of the BZ DB schema for Unee-T',
  `update_datetime` timestamp NULL DEFAULT NULL COMMENT 'Timestamp - when this version was implemented in THIS environment',
  `update_script` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The script we used to do the update',
  `comment` mediumtext COLLATE utf8mb4_unicode_520_ci COMMENT 'Comment',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC;

/*Table structure for table `external_map_user_unit_role_permissions_areas` */

DROP TABLE IF EXISTS `external_map_user_unit_role_permissions_areas`;

CREATE TABLE `external_map_user_unit_role_permissions_areas` (
  `id_map_user_unit_permissions` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique ID in this table',
  `syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
  `creation_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'What is the id of the sytem that was used for the creation of the record?',
  `created_by_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
  `creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
  `syst_updated_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record last updated?',
  `update_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the sytem that was used for the last update the record?',
  `updated_by_id` int(11) unsigned DEFAULT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
  `update_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record updated?',
  `organization_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  `is_update_needed` tinyint(1) DEFAULT '0' COMMENT '1 if Unee-T needs to be updated',
  `unee_t_update_ts` timestamp NULL DEFAULT NULL COMMENT 'The Timestamp when the last Unee-T update has been made',
  `unee_t_mefe_user_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The current Unee-T profile id of the person - this is the value of the field `_id` in the Mongo Collection `users`',
  `unee_t_area_id` int(11) NOT NULL COMMENT 'A FK to the table `property_groups_area`',
  `unee_t_user_type_id` int(11) NOT NULL COMMENT 'A FK to the table `ut_user_types`',
  `unee_t_role_id` mediumint(9) unsigned DEFAULT NULL COMMENT 'FK to the Unee-T BZFE table `ut_role_types` - ID of the Role for this user.',
  `propagate_level_2` tinyint(1) DEFAULT '0' COMMENT '1 if you want to propagate the permissions to all the units in the area',
  `propagate_level_3` tinyint(1) DEFAULT '0' COMMENT '1 if you want to propagate the permissions to all the rooms in all the units in the area',
  PRIMARY KEY (`unee_t_mefe_user_id`,`unee_t_user_type_id`,`unee_t_area_id`,`organization_id`),
  UNIQUE KEY `unique_id_map_user_unit_role_permissions_areas` (`id_map_user_unit_permissions`),
  KEY `ext_map_user_unit_role_permissions_areas_created_by` (`created_by_id`),
  KEY `ext_map_user_unit_role_permissions_areas_updated_by` (`updated_by_id`),
  KEY `ext_map_user_unit_role_permissions_areas_user_type` (`unee_t_user_type_id`),
  KEY `ext_map_user_unit_role_permissions_areas_role` (`unee_t_role_id`),
  KEY `ext_map_user_unit_role_permissions_areas_area_id` (`unee_t_area_id`),
  CONSTRAINT `ext_map_user_unit_role_permissions_areas_area_id` FOREIGN KEY (`unee_t_area_id`) REFERENCES `property_groups_areas` (`id_area`) ON UPDATE CASCADE,
  CONSTRAINT `ext_map_user_unit_role_permissions_areas_created_by` FOREIGN KEY (`created_by_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE,
  CONSTRAINT `ext_map_user_unit_role_permissions_areas_role` FOREIGN KEY (`unee_t_role_id`) REFERENCES `ut_user_role_types` (`id_role_type`) ON UPDATE CASCADE,
  CONSTRAINT `ext_map_user_unit_role_permissions_areas_updated_by` FOREIGN KEY (`updated_by_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE,
  CONSTRAINT `ext_map_user_unit_role_permissions_areas_user_type` FOREIGN KEY (`unee_t_user_type_id`) REFERENCES `ut_user_types` (`id_unee_t_user_type`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

/*Table structure for table `external_map_user_unit_role_permissions_level_1` */

DROP TABLE IF EXISTS `external_map_user_unit_role_permissions_level_1`;

CREATE TABLE `external_map_user_unit_role_permissions_level_1` (
  `id_map_user_unit_permissions_level_1` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique ID in this table',
  `syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
  `creation_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'What is the id of the sytem that was used for the creation of the record?',
  `created_by_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
  `creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
  `syst_updated_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record last updated?',
  `update_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the sytem that was used for the last update the record?',
  `updated_by_id` int(11) unsigned DEFAULT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
  `update_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record updated?',
  `organization_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  `is_update_needed` tinyint(1) DEFAULT '0' COMMENT '1 if Unee-T needs to be updated',
  `unee_t_update_ts` timestamp NULL DEFAULT NULL COMMENT 'The Timestamp when the last Unee-T update has been made',
  `unee_t_mefe_user_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The current Unee-T profile id of the person - this is the value of the field `_id` in the Mongo Collection `users`',
  `unee_t_level_1_id` int(11) NOT NULL COMMENT 'A FK to the table `property_level_1_buildings`',
  `unee_t_user_type_id` int(11) NOT NULL COMMENT 'A FK to the table `ut_user_types`',
  `unee_t_role_id` mediumint(9) unsigned DEFAULT NULL COMMENT 'FK to the Unee-T BZFE table `ut_role_types` - ID of the Role for this user.',
  `propagate_level_2` tinyint(1) DEFAULT '0' COMMENT '1 if you want to propagate the permissions to all the units in the area',
  `propagate_level_3` tinyint(1) DEFAULT '0' COMMENT '1 if you want to propagate the permissions to all the rooms in all the units in the area',
  PRIMARY KEY (`unee_t_mefe_user_id`,`unee_t_user_type_id`,`unee_t_level_1_id`,`created_by_id`),
  UNIQUE KEY `unique_id_map_user_unit_role_permissions_buildings` (`id_map_user_unit_permissions_level_1`),
  KEY `ext_map_user_unit_role_permissions_buildings_created_by` (`created_by_id`),
  KEY `ext_map_user_unit_role_permissions_buildings_updated_by` (`updated_by_id`),
  KEY `ext_map_user_unit_role_permissions_buildings_user_type` (`unee_t_user_type_id`),
  KEY `ext_map_user_unit_role_permissions_buildings_role` (`unee_t_role_id`),
  KEY `ext_map_user_unit_role_permissions_buildings_level_1_id` (`unee_t_level_1_id`),
  CONSTRAINT `ext_map_user_unit_role_permissions_buildings_created_by` FOREIGN KEY (`created_by_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE,
  CONSTRAINT `ext_map_user_unit_role_permissions_buildings_level_1_id` FOREIGN KEY (`unee_t_level_1_id`) REFERENCES `property_level_1_buildings` (`id_building`) ON UPDATE CASCADE,
  CONSTRAINT `ext_map_user_unit_role_permissions_buildings_role` FOREIGN KEY (`unee_t_role_id`) REFERENCES `ut_user_role_types` (`id_role_type`) ON UPDATE CASCADE,
  CONSTRAINT `ext_map_user_unit_role_permissions_buildings_updated_by` FOREIGN KEY (`updated_by_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE,
  CONSTRAINT `ext_map_user_unit_role_permissions_buildings_user_type` FOREIGN KEY (`unee_t_user_type_id`) REFERENCES `ut_user_types` (`id_unee_t_user_type`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3922 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

/*Table structure for table `external_map_user_unit_role_permissions_level_2` */

DROP TABLE IF EXISTS `external_map_user_unit_role_permissions_level_2`;

CREATE TABLE `external_map_user_unit_role_permissions_level_2` (
  `id_map_user_unit_permissions_level_2` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique ID in this table',
  `syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
  `creation_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'What is the id of the sytem that was used for the creation of the record?',
  `created_by_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
  `creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
  `syst_updated_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record last updated?',
  `update_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the sytem that was used for the last update the record?',
  `updated_by_id` int(11) unsigned DEFAULT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
  `update_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record updated?',
  `organization_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  `is_update_needed` tinyint(1) DEFAULT '0' COMMENT '1 if Unee-T needs to be updated',
  `unee_t_update_ts` timestamp NULL DEFAULT NULL COMMENT 'The Timestamp when the last Unee-T update has been made',
  `unee_t_mefe_user_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The current Unee-T profile id of the person - this is the value of the field `_id` in the Mongo Collection `users`',
  `unee_t_level_2_id` int(11) NOT NULL COMMENT 'A FK to the table `property_level_2_units`',
  `unee_t_user_type_id` int(11) NOT NULL COMMENT 'A FK to the table `ut_user_types`',
  `unee_t_role_id` mediumint(9) unsigned DEFAULT NULL COMMENT 'FK to the Unee-T BZFE table `ut_role_types` - ID of the Role for this user.',
  `propagate_level_3` tinyint(1) DEFAULT '0' COMMENT '1 if you want to propagate the permissions to all the rooms in all the units in the area',
  PRIMARY KEY (`unee_t_mefe_user_id`,`unee_t_user_type_id`,`unee_t_level_2_id`,`created_by_id`),
  UNIQUE KEY `unique_id_map_user_unit_role_permissions_units` (`id_map_user_unit_permissions_level_2`),
  KEY `ext_map_user_unit_role_permissions_units_created_by` (`created_by_id`),
  KEY `ext_map_user_unit_role_permissions_units_updated_by` (`updated_by_id`),
  KEY `ext_map_user_unit_role_permissions_units_user_type` (`unee_t_user_type_id`),
  KEY `ext_map_user_unit_role_permissions_units_role` (`unee_t_role_id`),
  KEY `ext_map_user_unit_role_permissions_units_level_2_id` (`unee_t_level_2_id`),
  CONSTRAINT `ext_map_user_unit_role_permissions_units_created_by` FOREIGN KEY (`created_by_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE,
  CONSTRAINT `ext_map_user_unit_role_permissions_units_level_2_id` FOREIGN KEY (`unee_t_level_2_id`) REFERENCES `property_level_2_units` (`system_id_unit`) ON UPDATE CASCADE,
  CONSTRAINT `ext_map_user_unit_role_permissions_units_role` FOREIGN KEY (`unee_t_role_id`) REFERENCES `ut_user_role_types` (`id_role_type`) ON UPDATE CASCADE,
  CONSTRAINT `ext_map_user_unit_role_permissions_units_updated_by` FOREIGN KEY (`updated_by_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE,
  CONSTRAINT `ext_map_user_unit_role_permissions_units_user_type` FOREIGN KEY (`unee_t_user_type_id`) REFERENCES `ut_user_types` (`id_unee_t_user_type`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=23262 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

/*Table structure for table `external_map_user_unit_role_permissions_level_3` */

DROP TABLE IF EXISTS `external_map_user_unit_role_permissions_level_3`;

CREATE TABLE `external_map_user_unit_role_permissions_level_3` (
  `id_map_user_unit_permissions_level_3` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique ID in this table',
  `syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
  `creation_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'What is the id of the sytem that was used for the creation of the record?',
  `created_by_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
  `creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
  `syst_updated_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record last updated?',
  `update_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the sytem that was used for the last update the record?',
  `updated_by_id` int(11) unsigned DEFAULT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
  `update_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record updated?',
  `organization_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  `is_update_needed` tinyint(1) DEFAULT '0' COMMENT '1 if Unee-T needs to be updated',
  `unee_t_update_ts` timestamp NULL DEFAULT NULL COMMENT 'The Timestamp when the last Unee-T update has been made',
  `unee_t_mefe_user_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The current Unee-T profile id of the person - this is the value of the field `_id` in the Mongo Collection `users`',
  `unee_t_level_3_id` int(11) NOT NULL COMMENT 'A FK to the table `property_level_3_rooms`',
  `unee_t_user_type_id` int(11) NOT NULL COMMENT 'A FK to the table `ut_user_types`',
  `unee_t_role_id` mediumint(9) unsigned DEFAULT NULL COMMENT 'FK to the Unee-T BZFE table `ut_role_types` - ID of the Role for this user.',
  PRIMARY KEY (`unee_t_mefe_user_id`,`unee_t_user_type_id`,`unee_t_level_3_id`,`created_by_id`),
  UNIQUE KEY `unique_id_map_user_unit_role_permissions_rooms` (`id_map_user_unit_permissions_level_3`),
  KEY `ext_map_user_unit_role_permissions_rooms_created_by` (`created_by_id`),
  KEY `ext_map_user_unit_role_permissions_rooms_updated_by` (`updated_by_id`),
  KEY `ext_map_user_unit_role_permissions_rooms_user_type` (`unee_t_user_type_id`),
  KEY `ext_map_user_unit_role_permissions_rooms_role` (`unee_t_role_id`),
  KEY `ext_map_user_unit_role_permissions_rooms_level_3_id` (`unee_t_level_3_id`),
  CONSTRAINT `ext_map_user_unit_role_permissions_rooms_created_by` FOREIGN KEY (`created_by_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE,
  CONSTRAINT `ext_map_user_unit_role_permissions_rooms_level_3_id` FOREIGN KEY (`unee_t_level_3_id`) REFERENCES `property_level_3_rooms` (`system_id_room`) ON UPDATE CASCADE,
  CONSTRAINT `ext_map_user_unit_role_permissions_rooms_role` FOREIGN KEY (`unee_t_role_id`) REFERENCES `ut_user_role_types` (`id_role_type`) ON UPDATE CASCADE,
  CONSTRAINT `ext_map_user_unit_role_permissions_rooms_updated_by` FOREIGN KEY (`updated_by_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE,
  CONSTRAINT `ext_map_user_unit_role_permissions_rooms_user_type` FOREIGN KEY (`unee_t_user_type_id`) REFERENCES `ut_user_types` (`id_unee_t_user_type`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=32654 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

/*Table structure for table `external_persons` */

DROP TABLE IF EXISTS `external_persons`;

CREATE TABLE `external_persons` (
  `id_person` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique ID in this table',
  `external_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The id of the record in an external system',
  `external_system` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The id of the system which provides the external_system_id',
  `external_table` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The table in the external system where this record is stored',
  `syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
  `creation_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the sytem that was used for the creation of the record?',
  `created_by_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
  `creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
  `syst_updated_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record last updated?',
  `update_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the sytem that was used for the last update the record?',
  `updated_by_id` int(11) unsigned DEFAULT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that updated this record',
  `update_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record updated?',
  `person_status_id` int(11) DEFAULT '1' COMMENT 'The id of the person status in the table 164_person_statuses',
  `dupe_id` int(11) DEFAULT NULL COMMENT 'This is a duplicate of this other record in this table',
  `handler_id` int(11) DEFAULT NULL COMMENT 'id of the person in charge of this person in the organization',
  `is_unee_t_account_needed` tinyint(1) DEFAULT '0' COMMENT '1 if we have decided to create a Unee-T account for that person',
  `unee_t_user_type_id` int(11) DEFAULT NULL COMMENT 'The type of unee-T user profile we create for this person. This is a FK to tyhe table `ut_unee_t_user_types`',
  `country_code` varchar(10) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The 2 letter version of the country code',
  `gender` int(11) unsigned DEFAULT '0' COMMENT 'A FK to the table `persons_gender`',
  `salutation_id` int(11) DEFAULT '1' COMMENT 'The salutation, a link to the table 150_salutations',
  `given_name` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'given name',
  `middle_name` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'middle name',
  `family_name` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'family name',
  `date_of_birth` date DEFAULT NULL COMMENT 'The birth date of the person',
  `alias` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'V4.35.0 - an Alias for the person',
  `job_title` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The job title of the person in the company',
  `organization` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'In which organization inside the company is the person working on?',
  `email` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The primary email address of the person',
  `tel_1` varchar(50) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'Primary phone number for the person',
  `tel_2` varchar(50) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'Secondary Phone number for the person',
  `whatsapp` varchar(50) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'whatsapp id for that person',
  `linkedin` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'the url to the linkedin profile of that person',
  `facebook` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'the url to the facebook profile for that person',
  `adr1` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `adr2` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `adr3` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `City` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `zip_postcode` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `region_or_state` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `country` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  PRIMARY KEY (`external_id`,`external_system`,`external_table`,`created_by_id`),
  UNIQUE KEY `unique_person_id` (`id_person`),
  KEY `person_person_salutation` (`salutation_id`),
  KEY `person_person_status` (`person_status_id`),
  KEY `person_unee-t_user_type` (`unee_t_user_type_id`),
  KEY `person_created_by_id` (`created_by_id`),
  KEY `person_gender` (`gender`),
  KEY `peson_udpated_by_id` (`updated_by_id`),
  CONSTRAINT `person_created_by_id` FOREIGN KEY (`created_by_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE,
  CONSTRAINT `person_gender` FOREIGN KEY (`gender`) REFERENCES `person_genders` (`id_person_gender`) ON UPDATE CASCADE,
  CONSTRAINT `person_salutation` FOREIGN KEY (`salutation_id`) REFERENCES `person_salutations` (`id_salutation`) ON UPDATE CASCADE,
  CONSTRAINT `person_status` FOREIGN KEY (`person_status_id`) REFERENCES `person_statuses` (`id_person_status`) ON UPDATE CASCADE,
  CONSTRAINT `person_ut_user_type` FOREIGN KEY (`unee_t_user_type_id`) REFERENCES `ut_user_types` (`id_unee_t_user_type`) ON UPDATE CASCADE,
  CONSTRAINT `peson_udpated_by_id` FOREIGN KEY (`updated_by_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=82 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

/*Table structure for table `external_property_groups_areas` */

DROP TABLE IF EXISTS `external_property_groups_areas`;

CREATE TABLE `external_property_groups_areas` (
  `id_area` int(11) NOT NULL AUTO_INCREMENT COMMENT 'The unique id in this table',
  `external_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The id of the record in an external system',
  `external_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The id of the system which provides the external_system_id',
  `external_table` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The table in the external system where this record is stored',
  `syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
  `creation_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'What is the id of the system that was used for the creation of the record?',
  `created_by_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
  `creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
  `syst_updated_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record last updated?',
  `update_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the system that was used for the last update the record?',
  `updated_by_id` int(11) unsigned DEFAULT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
  `update_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record updated?',
  `is_creation_needed_in_unee_t` tinyint(1) DEFAULT '1' COMMENT '1 if we need this object in Unee-T',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  `is_default` tinyint(1) DEFAULT '0' COMMENT 'This is the default value in our systems',
  `order` int(11) DEFAULT NULL COMMENT 'Order in the list',
  `country_code` varchar(10) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The country code for that legal entity - See table `185_country` for more details on the country',
  `area_name` varchar(50) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'Designation',
  `area_definition` mediumtext COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text',
  PRIMARY KEY (`external_id`,`external_system_id`,`external_table`,`created_by_id`),
  UNIQUE KEY `unique_id_area` (`id_area`),
  KEY `property_area_created_by` (`created_by_id`),
  KEY `property_area_updated_by` (`updated_by_id`),
  CONSTRAINT `property_area_created_by` FOREIGN KEY (`created_by_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE,
  CONSTRAINT `property_area_updated_by` FOREIGN KEY (`updated_by_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

/*Table structure for table `external_property_level_1_buildings` */

DROP TABLE IF EXISTS `external_property_level_1_buildings`;

CREATE TABLE `external_property_level_1_buildings` (
  `id_building` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique ID in this table',
  `external_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The id of the record in an external system',
  `external_system_id` varchar(100) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The id of the system which provides the external_system_id',
  `external_table` varchar(100) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The table in the external system where this record is stored',
  `syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
  `creation_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the system that was used for the creation of the record?',
  `created_by_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
  `creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
  `syst_updated_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record last updated?',
  `update_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the system that was used for the last update the record?',
  `updated_by_id` int(11) unsigned DEFAULT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
  `update_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record updated?',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT '1 if this record is obsolete',
  `order` int(10) DEFAULT '0' COMMENT 'order in the list',
  `area_id` int(11) DEFAULT NULL COMMENT 'The Id of the area for this building. This is a FK to the table `209_areas`',
  `is_creation_needed_in_unee_t` tinyint(1) DEFAULT '0' COMMENT '1 if we need to create this property as a unit in Unee-T',
  `do_not_insert` tinyint(1) DEFAULT '0' COMMENT '1 if we know the record exists in MEFE already and we do NOT need to re-create this in MEFE',
  `unee_t_unit_type` varchar(100) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The Unee-T type of unit for this property - this MUST be one of the `designation` in the table `ut_unit_types`',
  `designation` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The name of the building',
  `tower` varchar(50) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '1' COMMENT 'If there is mor than 1 building, the id for the unique building. Default is 1.',
  `address_1` varchar(50) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'Address 1',
  `address_2` varchar(50) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'Address 2',
  `zip_postal_code` varchar(50) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'ZIP or Postal code',
  `state` varchar(50) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The State',
  `city` varchar(50) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The City',
  `country_code` varchar(10) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The 2 letter ISO country code (FR, SG, EN, etc...). See table `property_groups_countries`',
  `description` text COLLATE utf8mb4_unicode_520_ci COMMENT 'detailed description of the building',
  PRIMARY KEY (`external_id`,`external_system_id`,`external_table`,`tower`,`created_by_id`),
  UNIQUE KEY `unique_id_building` (`id_building`),
  KEY `building_id_area_id` (`area_id`),
  KEY `unee_t_valid_unit_type_building` (`unee_t_unit_type`),
  KEY `property_level_1_created_by` (`created_by_id`),
  KEY `property_level_1_updated_by` (`updated_by_id`),
  CONSTRAINT `property_level_1_area` FOREIGN KEY (`area_id`) REFERENCES `external_property_groups_areas` (`id_area`) ON UPDATE CASCADE,
  CONSTRAINT `property_level_1_created_by` FOREIGN KEY (`created_by_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE,
  CONSTRAINT `property_level_1_updated_by` FOREIGN KEY (`updated_by_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE,
  CONSTRAINT `property_unit_type` FOREIGN KEY (`unee_t_unit_type`) REFERENCES `ut_unit_types` (`designation`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=122 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

/*Table structure for table `external_property_level_2_units` */

DROP TABLE IF EXISTS `external_property_level_2_units`;

CREATE TABLE `external_property_level_2_units` (
  `system_id_unit` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique Id in this table',
  `external_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The id of the record in an external system',
  `external_system_id` varchar(100) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The id of the system which provides the external_system_id',
  `external_table` varbinary(100) NOT NULL COMMENT 'The table in the external system where this record is stored',
  `syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
  `creation_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the system that was used for the creation of the record?',
  `created_by_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
  `creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
  `syst_updated_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record last updated?',
  `update_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the system that was used for the last update the record?',
  `updated_by_id` int(11) unsigned DEFAULT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
  `update_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record updated?',
  `activated_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who marked this unit as Active',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT '1 if this unit is obsolete',
  `is_creation_needed_in_unee_t` tinyint(1) DEFAULT '0' COMMENT '1 if we need to create this property as a unit in Unee-T',
  `do_not_insert` tinyint(1) DEFAULT '0' COMMENT '1 if we know the record exists in MEFE already and we do NOT need to re-create this in MEFE',
  `unee_t_unit_type` varchar(100) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The Unee-T type of unit for this property - this MUST be one of the `designation` in the table `ut_unit_types`',
  `building_system_id` int(11) NOT NULL DEFAULT '1' COMMENT 'A FK to the table `property_buildings`',
  `tower` varchar(50) COLLATE utf8mb4_unicode_520_ci DEFAULT '1' COMMENT 'The building in which this unit is (default is 1)',
  `unit_category_id` int(11) DEFAULT NULL COMMENT 'A FK to the table `property_categories`',
  `designation` varchar(50) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The name of the unit/flat',
  `count_rooms` int(10) DEFAULT NULL COMMENT 'Number of rooms in the unit',
  `unit_id` varchar(50) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The unique id of this unit in the building',
  `surface` int(10) DEFAULT NULL COMMENT 'The surface of the unit',
  `surface_measurment_unit` varchar(10) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'Either sqm (Square Meters) or sqf (Square Feet)',
  `description` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description of the unit',
  PRIMARY KEY (`external_id`,`external_system_id`,`external_table`,`created_by_id`),
  UNIQUE KEY `unique_id_unit` (`system_id_unit`),
  KEY `unit_building_id` (`building_system_id`),
  KEY `unee_t_valid_unit_type_unit` (`unee_t_unit_type`),
  KEY `property_level_2_created_by` (`created_by_id`),
  KEY `property_level_2_updated_by` (`updated_by_id`),
  CONSTRAINT `property_level_2_created_by` FOREIGN KEY (`created_by_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE,
  CONSTRAINT `property_level_2_property_level_1` FOREIGN KEY (`building_system_id`) REFERENCES `external_property_level_1_buildings` (`id_building`) ON UPDATE CASCADE,
  CONSTRAINT `property_level_2_unit_type` FOREIGN KEY (`unee_t_unit_type`) REFERENCES `ut_unit_types` (`designation`) ON UPDATE CASCADE,
  CONSTRAINT `property_level_2_updated_by` FOREIGN KEY (`updated_by_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=618 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

/*Table structure for table `external_property_level_3_rooms` */

DROP TABLE IF EXISTS `external_property_level_3_rooms`;

CREATE TABLE `external_property_level_3_rooms` (
  `system_id_room` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique id in this table',
  `external_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The id of the record in an external system',
  `external_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The id of the system which provides the external_system_id',
  `external_table` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The table in the external system where this record is stored',
  `syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
  `creation_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'What is the id of the system that was used for the creation of the record?',
  `created_by_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
  `creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
  `syst_updated_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record last updated?',
  `update_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'What is the id of the system that was used for the last update the record?',
  `updated_by_id` int(11) unsigned DEFAULT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
  `update_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record updated?',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'Is this an obsolete record',
  `is_creation_needed_in_unee_t` tinyint(1) DEFAULT '0' COMMENT '1 if we need to create this property as a unit in Unee-T',
  `do_not_insert` tinyint(1) DEFAULT '0' COMMENT '1 if we know the record exists in MEFE already and we do NOT need to re-create this in MEFE',
  `unee_t_unit_type` varchar(100) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The Unee-T type of unit for this property - this MUST be one of the `designation` in the table `ut_unit_types`',
  `system_id_unit` int(11) NOT NULL COMMENT 'A FK to the table `property_unit`',
  `room_type_id` int(11) NOT NULL DEFAULT '1' COMMENT 'The id of the LMB LOI. This is a FK to the table ''db_all_sourcing_dt_4_lmb_loi''',
  `number_of_beds` int(2) DEFAULT NULL COMMENT 'Number of beds in the room',
  `surface` int(10) DEFAULT NULL COMMENT 'The surface of the room',
  `surface_measurment_unit` varchar(10) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'Either sqm (Square Meters) or sqf (Square Feet)',
  `room_designation` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The designation (name) of the room',
  `room_description` mediumtext COLLATE utf8mb4_unicode_520_ci COMMENT 'Comment (use this to explain teh difference between ipi_calculation and actual)',
  PRIMARY KEY (`external_id`,`external_system_id`,`external_table`,`created_by_id`),
  UNIQUE KEY `unique_system_id_room` (`system_id_room`),
  KEY `room_id_flat_id` (`system_id_unit`),
  KEY `unee_t_valid_unit_type_room` (`unee_t_unit_type`),
  KEY `property_level_3_created_by_id` (`created_by_id`),
  KEY `property_level_3_updated_by_id` (`updated_by_id`),
  CONSTRAINT `property_level_3_created_by_id` FOREIGN KEY (`created_by_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE,
  CONSTRAINT `property_level_3_property_level_2` FOREIGN KEY (`system_id_unit`) REFERENCES `external_property_level_2_units` (`system_id_unit`) ON UPDATE CASCADE,
  CONSTRAINT `property_level_3_unit_type` FOREIGN KEY (`unee_t_unit_type`) REFERENCES `ut_unit_types` (`designation`) ON UPDATE CASCADE,
  CONSTRAINT `property_level_3_updated_by_id` FOREIGN KEY (`updated_by_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=567 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

/*Table structure for table `hmlet_new_unit_names` */

DROP TABLE IF EXISTS `hmlet_new_unit_names`;

CREATE TABLE `hmlet_new_unit_names` (
  `id_map` int(11) NOT NULL DEFAULT '0' COMMENT 'Id in this table',
  `syst_updated_datetime` datetime NOT NULL,
  `update_system_id` int(1) NOT NULL,
  `updated_by_id` longtext CHARACTER SET utf8,
  `update_method` varchar(16) CHARACTER SET utf8 NOT NULL,
  `organization_id` int(1) NOT NULL,
  `is_update_needed` int(1) NOT NULL,
  `old_name` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The name of the unit in the BZ database',
  `new_name` varchar(50) COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `external_property_type_id` int(11) NOT NULL COMMENT 'A FK to the table `ut_property_types`'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

/*Table structure for table `log_lambdas` */

DROP TABLE IF EXISTS `log_lambdas`;

CREATE TABLE `log_lambdas` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID in this table',
  `created_datetime` timestamp NULL DEFAULT NULL COMMENT 'Timestamp when this was created',
  `creation_trigger` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'The trigger that created this lambda',
  `associated_call` varbinary(255) DEFAULT NULL COMMENT 'The name of the procedure that we invoke to call the lambda',
  `mefe_unit_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'The MEFE id of the unit',
  `unit_name` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The name of the Unit (easire for debugging)',
  `mefe_user_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'The MEFE id of the user',
  `unee_t_login` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The Unee-T login for the user (easier for debugging)',
  `payload` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'The payload',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=60699 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

/*Table structure for table `person_genders` */

DROP TABLE IF EXISTS `person_genders`;

CREATE TABLE `person_genders` (
  `id_person_gender` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Uniquer ID in this table',
  `creation_system_id` int(11) NOT NULL DEFAULT '1' COMMENT 'What is the id of the sytem that was used for the creation of the record?',
  `update_system_id` int(11) DEFAULT NULL COMMENT 'What is the id of the sytem that was used for the last update the record?',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  `is_default` tinyint(1) DEFAULT '0' COMMENT 'This is the default value in our systems',
  `is_active` tinyint(1) DEFAULT '0' COMMENT 'This satus is considered as ACTIVE',
  `order` int(11) NOT NULL COMMENT 'Order in the list',
  `person_gender` varchar(50) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'Designation',
  `description` mediumtext COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text',
  PRIMARY KEY (`id_person_gender`),
  UNIQUE KEY `unique_gender` (`person_gender`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

/*Table structure for table `person_salutations` */

DROP TABLE IF EXISTS `person_salutations`;

CREATE TABLE `person_salutations` (
  `id_salutation` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique ID in this table',
  `creation_system_id` int(11) NOT NULL DEFAULT '1' COMMENT 'What is the id of the sytem that was used for the creation of the record?',
  `update_system_id` int(11) DEFAULT NULL COMMENT 'What is the id of the sytem that was used for the update of the record?',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  `order` int(10) NOT NULL DEFAULT '0' COMMENT 'Order in the list',
  `salutation` varchar(50) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'Designation',
  `salutation_description` mediumtext COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text)',
  PRIMARY KEY (`id_salutation`,`salutation`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC;

/*Table structure for table `person_statuses` */

DROP TABLE IF EXISTS `person_statuses`;

CREATE TABLE `person_statuses` (
  `id_person_status` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Uniquer ID in this table',
  `creation_system_id` int(11) NOT NULL DEFAULT '1' COMMENT 'What is the id of the sytem that was used for the creation of the record?',
  `update_system_id` int(11) DEFAULT NULL COMMENT 'What is the id of the sytem that was used for the last update the record?',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  `is_default` tinyint(1) DEFAULT '0' COMMENT 'This is the default value in our systems',
  `is_active` tinyint(1) DEFAULT '0' COMMENT 'This satus is considered as ACTIVE',
  `order` int(11) NOT NULL COMMENT 'Order in the list',
  `person_status` varchar(50) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'Designation',
  `person_status_definition` mediumtext COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text',
  PRIMARY KEY (`id_person_status`,`person_status`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC;

/*Table structure for table `persons` */

DROP TABLE IF EXISTS `persons`;

CREATE TABLE `persons` (
  `id_person` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique ID in this table',
  `external_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The id of the record in an external system',
  `external_system` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The id of the system which provides the external_system_id',
  `external_table` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The table in the external system where this record is stored',
  `syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
  `creation_system_id` int(11) DEFAULT NULL COMMENT 'What is the id of the sytem that was used for the creation of the record?',
  `created_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who created this record',
  `creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
  `syst_updated_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record last updated?',
  `update_system_id` int(11) DEFAULT NULL COMMENT 'What is the id of the sytem that was used for the last update the record?',
  `updated_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who updated this record',
  `update_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record updated?',
  `organization_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
  `person_status_id` int(11) DEFAULT '1' COMMENT 'The id of the person status in the table 164_person_statuses',
  `dupe_id` int(11) DEFAULT NULL COMMENT 'This is a duplicate of this other record in this table',
  `handler_id` int(11) DEFAULT NULL COMMENT 'id of the person in charge of this person in the organization',
  `is_unee_t_account_needed` tinyint(1) DEFAULT '0' COMMENT '1 if we have decided to create a Unee-T account for that person',
  `unee_t_user_type_id` int(11) DEFAULT NULL COMMENT 'The type of unee-T user profile we create for this person. This is a FK to tyhe table `ut_unee_t_user_types`',
  `country_code` varchar(10) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The 2 letter version of the country code',
  `gender` tinyint(1) DEFAULT '0' COMMENT '0: Unknown; 1: Male; 2: Female',
  `salutation_id` int(11) DEFAULT '1' COMMENT 'The salutation, a link to the table 150_salutations',
  `given_name` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'given name',
  `middle_name` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'middle name',
  `family_name` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'family name',
  `date_of_birth` date DEFAULT NULL COMMENT 'The birth date of the person',
  `alias` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'V4.35.0 - an Alias for the person',
  `job_title` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The job title of the person in the company',
  `organization` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'In which organization inside the company is the person working on?',
  `email` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The primary email address of the person',
  `tel_1` varchar(50) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'Primary phone number for the person',
  `tel_2` varchar(50) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'Secondary Phone number for the person',
  `whatsapp` varchar(50) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'whatsapp id for that person',
  `linkedin` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'the url to the linkedin profile of that person',
  `facebook` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'the url to the facebook profile for that person',
  `adr1` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `adr2` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `adr3` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `City` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `zip_postcode` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `region_or_state` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `country` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  PRIMARY KEY (`external_id`,`external_system`,`external_table`,`organization_id`),
  UNIQUE KEY `unique_person_id` (`id_person`),
  KEY `person_person_salutation` (`salutation_id`),
  KEY `person_person_status` (`person_status_id`),
  KEY `person_unee-t_user_type` (`unee_t_user_type_id`),
  KEY `sot_creation_system_person` (`creation_system_id`),
  KEY `sot_update_system_person` (`update_system_id`),
  KEY `person_organization_id` (`organization_id`),
  CONSTRAINT `person_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE,
  CONSTRAINT `person_person_salutation` FOREIGN KEY (`salutation_id`) REFERENCES `person_salutations` (`id_salutation`) ON UPDATE CASCADE,
  CONSTRAINT `person_person_status` FOREIGN KEY (`person_status_id`) REFERENCES `person_statuses` (`id_person_status`) ON UPDATE CASCADE,
  CONSTRAINT `person_unee-t_user_type` FOREIGN KEY (`unee_t_user_type_id`) REFERENCES `ut_user_types` (`id_unee_t_user_type`) ON UPDATE CASCADE,
  CONSTRAINT `sot_creation_system_person` FOREIGN KEY (`creation_system_id`) REFERENCES `ut_external_sot_for_unee_t_objects` (`id_external_sot_for_unee_t`) ON UPDATE CASCADE,
  CONSTRAINT `sot_update_system_person` FOREIGN KEY (`update_system_id`) REFERENCES `ut_external_sot_for_unee_t_objects` (`id_external_sot_for_unee_t`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=219 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC;

/*Table structure for table `property_groups_areas` */

DROP TABLE IF EXISTS `property_groups_areas`;

CREATE TABLE `property_groups_areas` (
  `id_area` int(11) NOT NULL AUTO_INCREMENT COMMENT 'The unique id in this table',
  `external_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The id of the record in an external system',
  `external_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The id of the system which provides the external_system_id',
  `external_table` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The table in the external system where this record is stored',
  `syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
  `creation_system_id` int(11) NOT NULL DEFAULT '1' COMMENT 'What is the id of the system that was used for the creation of the record?',
  `created_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who created this record',
  `creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
  `syst_updated_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record last updated?',
  `update_system_id` int(11) DEFAULT NULL COMMENT 'What is the id of the system that was used for the last update the record?',
  `updated_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who updated this record',
  `update_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record updated?',
  `is_creation_needed_in_unee_t` tinyint(1) DEFAULT '1' COMMENT '1 if we need this object in Unee-T',
  `organization_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
  `country_code` varchar(10) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The country code for that legal entity - See table `185_country` for more details on the country',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  `is_default` tinyint(1) DEFAULT '0' COMMENT 'This is the default value in our systems',
  `order` int(11) DEFAULT NULL COMMENT 'Order in the list',
  `area_name` varchar(50) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'Designation',
  `area_definition` mediumtext COLLATE utf8mb4_unicode_520_ci COMMENT 'Description/help text',
  PRIMARY KEY (`organization_id`,`external_id`,`external_system_id`,`external_table`),
  KEY `loi_type_creation_system_id` (`creation_system_id`),
  KEY `loi_type_update_system_id` (`update_system_id`),
  KEY `areas_organization_id` (`organization_id`),
  KEY `unique_id_area` (`id_area`),
  CONSTRAINT `areas_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC;

/*Table structure for table `property_groups_countries` */

DROP TABLE IF EXISTS `property_groups_countries`;

CREATE TABLE `property_groups_countries` (
  `id_country` int(11) NOT NULL AUTO_INCREMENT,
  `syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
  `creation_system_id` int(11) NOT NULL DEFAULT '1' COMMENT 'What is the id of the system that was used for the creation of the record?',
  `created_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who created this record',
  `syst_updated_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record last updated?',
  `update_system_id` int(11) DEFAULT NULL COMMENT 'What is the id of the system that was used for the last update the record?',
  `updated_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who updated this record',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  `is_default` tinyint(1) DEFAULT '0' COMMENT 'This is the default value in our systems',
  `is_system` tinyint(1) DEFAULT '1' COMMENT 'identify the records that are used for critical computation routines and that should be considered as critical for the system',
  `order` int(11) NOT NULL DEFAULT '0' COMMENT 'Order in the list',
  `country_code` varchar(10) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'Designation',
  `country_name` varchar(256) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'Description/help text',
  PRIMARY KEY (`id_country`,`country_code`),
  KEY `search_country_codes` (`country_code`),
  KEY `search_country_names` (`country_name`)
) ENGINE=InnoDB AUTO_INCREMENT=246 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC;

/*Table structure for table `property_level_1_buildings` */

DROP TABLE IF EXISTS `property_level_1_buildings`;

CREATE TABLE `property_level_1_buildings` (
  `id_building` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique ID in this table',
  `external_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The id of the record in an external system',
  `external_system_id` varchar(100) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The id of the system which provides the external_system_id',
  `external_table` varchar(100) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The table in the external system where this record is stored',
  `syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
  `creation_system_id` int(11) DEFAULT NULL COMMENT 'What is the id of the system that was used for the creation of the record?',
  `created_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who created this record',
  `creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
  `syst_updated_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record last updated?',
  `update_system_id` int(11) DEFAULT NULL COMMENT 'What is the id of the system that was used for the last update the record?',
  `updated_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who updated this record',
  `update_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record updated?',
  `organization_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT '1 if this record is obsolete',
  `order` int(10) DEFAULT '0' COMMENT 'order in the list',
  `area_id` int(11) DEFAULT NULL COMMENT 'The Id of the area for this building. This is a FK to the table `209_areas`',
  `is_creation_needed_in_unee_t` tinyint(1) DEFAULT '0' COMMENT '1 if we need to create this property as a unit in Unee-T',
  `do_not_insert` tinyint(1) DEFAULT '0' COMMENT '1 if we know the record exists in MEFE already and we do NOT need to re-create this in MEFE',
  `unee_t_unit_type` varchar(100) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The Unee-T type of unit for this property - this MUST be one of the `designation` in the table `ut_unit_types`',
  `designation` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The name of the building',
  `tower` varchar(50) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '1' COMMENT 'If there is more than 1 building, the id for the unique building. Default is 1.',
  `address_1` varchar(50) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'Address 1',
  `address_2` varchar(50) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'Address 2',
  `zip_postal_code` varchar(50) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'ZIP or Postal code',
  `state` varchar(50) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The State',
  `city` varchar(50) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The City',
  `country_code` varchar(10) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The 2 letter ISO country code (FR, SG, EN, etc...). See table `property_groups_countries`',
  `description` text COLLATE utf8mb4_unicode_520_ci COMMENT 'detailed description of the building',
  PRIMARY KEY (`external_id`,`external_system_id`,`external_table`,`tower`,`organization_id`),
  UNIQUE KEY `unique_id_building` (`id_building`),
  KEY `building_id_area_id` (`area_id`),
  KEY `unee_t_valid_unit_type_building` (`unee_t_unit_type`),
  KEY `property_level_1_organization_id` (`organization_id`),
  CONSTRAINT `building_id_area_id` FOREIGN KEY (`area_id`) REFERENCES `property_groups_areas` (`id_area`) ON UPDATE CASCADE,
  CONSTRAINT `property_level_1_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE,
  CONSTRAINT `unee_t_valid_unit_type_building` FOREIGN KEY (`unee_t_unit_type`) REFERENCES `ut_unit_types` (`designation`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=312 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC;

/*Table structure for table `property_level_2_units` */

DROP TABLE IF EXISTS `property_level_2_units`;

CREATE TABLE `property_level_2_units` (
  `system_id_unit` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique Id in this table',
  `external_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The id of the record in an external system',
  `external_system_id` varchar(100) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The id of the system which provides the external_system_id',
  `external_table` varbinary(100) NOT NULL COMMENT 'The table in the external system where this record is stored',
  `syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
  `creation_system_id` int(11) DEFAULT NULL COMMENT 'What is the id of the system that was used for the creation of the record?',
  `created_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who created this record',
  `creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
  `syst_updated_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record last updated?',
  `update_system_id` int(11) DEFAULT NULL COMMENT 'What is the id of the system that was used for the last update the record?',
  `updated_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who updated this record',
  `update_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record updated?',
  `organization_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
  `activated_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who marked this unit as Active',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT '1 if this unit is obsolete',
  `is_creation_needed_in_unee_t` tinyint(1) DEFAULT '0' COMMENT '1 if we need to create this property as a unit in Unee-T',
  `do_not_insert` tinyint(1) DEFAULT '0' COMMENT '1 if we know the record exists in MEFE already and we do NOT need to re-create this in MEFE',
  `unee_t_unit_type` varchar(100) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The Unee-T type of unit for this property - this MUST be one of the `designation` in the table `ut_unit_types`',
  `building_system_id` int(11) NOT NULL DEFAULT '1' COMMENT 'A FK to the table `property_buildings`',
  `tower` varchar(50) COLLATE utf8mb4_unicode_520_ci DEFAULT '1' COMMENT 'The building in which this unit is (default is 1)',
  `unit_category_id` int(11) DEFAULT NULL COMMENT 'A FK to the table `property_categories`',
  `designation` varchar(50) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The name of the unit/flat',
  `count_rooms` int(10) DEFAULT NULL COMMENT 'Number of rooms in the unit',
  `unit_id` varchar(50) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The unique id of this unit in the building',
  `surface` int(10) DEFAULT NULL COMMENT 'The surface of the unit',
  `surface_measurment_unit` varchar(10) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'Either sqm (Square Meters) or sqf (Square Feet)',
  `description` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description of the unit',
  PRIMARY KEY (`external_id`,`external_system_id`,`external_table`,`organization_id`),
  UNIQUE KEY `unique_id_unit` (`system_id_unit`),
  KEY `unit_building_id` (`building_system_id`),
  KEY `unee_t_valid_unit_type_unit` (`unee_t_unit_type`),
  KEY `property_level_2_organization_id` (`organization_id`),
  CONSTRAINT `property_level_2_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE,
  CONSTRAINT `unee_t_valid_unit_type_unit` FOREIGN KEY (`unee_t_unit_type`) REFERENCES `ut_unit_types` (`designation`) ON UPDATE CASCADE,
  CONSTRAINT `unit_building_id` FOREIGN KEY (`building_system_id`) REFERENCES `property_level_1_buildings` (`id_building`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1836 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC;

/*Table structure for table `property_level_3_rooms` */

DROP TABLE IF EXISTS `property_level_3_rooms`;

CREATE TABLE `property_level_3_rooms` (
  `system_id_room` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique id in this table',
  `external_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The id of the record in an external system',
  `external_system_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The id of the system which provides the external_system_id',
  `external_table` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The table in the external system where this record is stored',
  `syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
  `creation_system_id` int(11) NOT NULL DEFAULT '1' COMMENT 'What is the id of the system that was used for the creation of the record?',
  `created_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who created this record',
  `creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
  `syst_updated_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record last updated?',
  `update_system_id` int(11) DEFAULT NULL COMMENT 'What is the id of the system that was used for the last update the record?',
  `updated_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who updated this record',
  `update_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record updated?',
  `organization_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'Is this an obsolete record',
  `is_creation_needed_in_unee_t` tinyint(1) DEFAULT '0' COMMENT '1 if we need to create this property as a unit in Unee-T',
  `do_not_insert` tinyint(1) DEFAULT '0' COMMENT '1 if we know the record exists in MEFE already and we do NOT need to re-create this in MEFE',
  `unee_t_unit_type` varchar(100) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The Unee-T type of unit for this property - this MUST be one of the `designation` in the table `ut_unit_types`',
  `system_id_unit` int(11) NOT NULL COMMENT 'A FK to the table `property_unit`',
  `room_type_id` int(11) NOT NULL DEFAULT '1' COMMENT 'The id of the LMB LOI. This is a FK to the table ''db_all_sourcing_dt_4_lmb_loi''',
  `number_of_beds` int(2) DEFAULT NULL COMMENT 'Number of beds in the room',
  `surface` int(10) DEFAULT NULL COMMENT 'The surface of the room',
  `surface_measurment_unit` varchar(10) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'Either sqm (Square Meters) or sqf (Square Feet)',
  `room_designation` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The designation (name) of the room',
  `room_description` mediumtext COLLATE utf8mb4_unicode_520_ci COMMENT 'Comment (use this to explain teh difference between ipi_calculation and actual)',
  PRIMARY KEY (`external_id`,`external_system_id`,`external_table`,`organization_id`),
  UNIQUE KEY `unique_system_id_room` (`system_id_room`),
  KEY `room_id_flat_id` (`system_id_unit`),
  KEY `room_id_room_type_id` (`room_type_id`),
  KEY `unee_t_valid_unit_type_room` (`unee_t_unit_type`),
  KEY `property_level_3_organization_id` (`organization_id`),
  CONSTRAINT `property_level_3_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE,
  CONSTRAINT `room_id_flat_id` FOREIGN KEY (`system_id_unit`) REFERENCES `property_level_2_units` (`system_id_unit`) ON UPDATE CASCADE,
  CONSTRAINT `room_id_room_type_id` FOREIGN KEY (`room_type_id`) REFERENCES `property_types_level_3_rooms` (`id_room_type`) ON UPDATE CASCADE,
  CONSTRAINT `unee_t_valid_unit_type_room` FOREIGN KEY (`unee_t_unit_type`) REFERENCES `ut_unit_types` (`designation`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=990 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC;

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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC;

/*Table structure for table `retry_assign_user_to_units_list` */

DROP TABLE IF EXISTS `retry_assign_user_to_units_list`;

CREATE TABLE `retry_assign_user_to_units_list` (
  `id_map_user_unit_permissions` int(11) NOT NULL COMMENT 'Id in this table',
  `syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
  `creation_system_id` int(11) NOT NULL DEFAULT '1' COMMENT 'What is the id of the sytem that was used for the creation of the record?',
  `created_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who created this record',
  `creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `mefe_user_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The current Unee-T profile id of the person - this is the value of the field `_id` in the Mongo Collection `users`',
  `uneet_login_name` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The MEFE login of the user we invite',
  `mefe_unit_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'ID of that Unit in Unee-T. This is the value of the field _id in the Mongo collection units',
  `uneet_name` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The name of the unit in the MEFE',
  `unee_t_role_id` smallint(6) DEFAULT NULL COMMENT 'FK to the Unee-T BZFE table `ut_role_types` - ID of the Role for this user.',
  `is_occupant` tinyint(1) DEFAULT '0' COMMENT '1 is the user is an occupant of the unit',
  `is_default_assignee` tinyint(1) DEFAULT '0' COMMENT '1 if this user is the default assignee for this role for this unit.',
  `is_default_invited` tinyint(1) DEFAULT '0' COMMENT '1 if the user is automatically invited to all the new cases in this role for this unit',
  `is_unit_owner` tinyint(1) DEFAULT '0' COMMENT '1 if this user is one of the Unee-T `owner` of that unit',
  `is_public` tinyint(1) DEFAULT '0' COMMENT '1 if the user is Visible to other Unee-T users in other roles for this unit. If yes/1/TRUE then all other roles will be able to see this user. IF No/FALSE/0 then only the users in the same role for that unit will be able to see this user in this unit',
  `can_see_role_landlord` tinyint(1) DEFAULT '0' COMMENT '1 if user is allowed to see the PUBLIC users in the role `landlord` (2) for this unit',
  `can_see_role_tenant` tinyint(1) DEFAULT '0' COMMENT '1 if user is allowed to see the PUBLIC users in the role `tenant` (1) for this unit',
  `can_see_role_mgt_cny` tinyint(1) DEFAULT '0' COMMENT '1 if user is allowed to see the PUBLIC users in the role `Mgt Company` (4) for this unit',
  `can_see_role_agent` tinyint(1) DEFAULT '0' COMMENT '1 if user is allowed to see the PUBLIC users in the role `agent` (5) for this unit',
  `can_see_role_contractor` tinyint(1) DEFAULT '0' COMMENT '1 if user is allowed to see the PUBLIC users in the role `contractor` (3) for this unit',
  `can_see_occupant` tinyint(1) DEFAULT '0' COMMENT '1 if user is allowed to see the PUBLIC occupants for this unit',
  `is_assigned_to_case` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_invited_to_case` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_next_step_updated` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_deadline_updated` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_solution_updated` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_case_resolved` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_case_blocker` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_case_critical` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_any_new_message` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_message_from_my_role` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_message_from_tenant` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_message_from_ll` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_message_from_occupant` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_message_from_agent` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_message_from_mgt_cny` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_message_from_contractor` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_new_ir` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_new_item` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_item_removed` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_item_moved` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  PRIMARY KEY (`mefe_user_id`,`mefe_unit_id`),
  UNIQUE KEY `map_user_unit_role_permissions` (`id_map_user_unit_permissions`),
  KEY `retry_mefe_unit_must_exist` (`mefe_unit_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

/*Table structure for table `retry_create_units_list_units` */

DROP TABLE IF EXISTS `retry_create_units_list_units`;

CREATE TABLE `retry_create_units_list_units` (
  `unit_creation_request_id` int(11) NOT NULL COMMENT 'Id in this table',
  `created_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who created this record',
  `creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `uneet_name` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The name of the unit in the MEFE',
  `unee_t_unit_type` varchar(100) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The Unee-T type of unit for this property - this MUST be one of the `designation` in the table `ut_unit_types`',
  `more_info` text COLLATE utf8mb4_unicode_520_ci COMMENT 'detailed description of the building',
  `street_address` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `city` varchar(50) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The City',
  `state` varchar(50) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The State',
  `zip_code` varchar(50) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'ZIP or Postal code',
  `country` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'Description/help text'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

/*Table structure for table `uneet_enterprise_audit` */

DROP TABLE IF EXISTS `uneet_enterprise_audit`;

CREATE TABLE `uneet_enterprise_audit` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `ip` varchar(40) CHARACTER SET utf8 NOT NULL,
  `user` varchar(300) CHARACTER SET utf8 DEFAULT NULL,
  `table` varchar(300) CHARACTER SET utf8 DEFAULT NULL,
  `action` varchar(250) CHARACTER SET utf8 NOT NULL,
  `description` mediumtext CHARACTER SET utf8,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=263 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

/*Table structure for table `uneet_enterprise_organizations` */

DROP TABLE IF EXISTS `uneet_enterprise_organizations`;

CREATE TABLE `uneet_enterprise_organizations` (
  `id_organization` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id in this table',
  `syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
  `creation_system_id` int(11) DEFAULT NULL COMMENT 'What is the id of the sytem that was used for the creation of the record?',
  `creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
  `created_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who created this record',
  `syst_updated_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record last updated?',
  `update_system_id` int(11) DEFAULT NULL COMMENT 'What is the id of the sytem that was used for the last update the record?',
  `updated_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who updated this record',
  `update_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record updated?',
  `order` smallint(6) unsigned DEFAULT NULL COMMENT 'Order in the list',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT '1 is this API key is revoked or obsolete',
  `designation` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The Name of the organization',
  `description` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Description of the organization',
  PRIMARY KEY (`id_organization`),
  UNIQUE KEY `unique_organization_name` (`designation`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

/*Table structure for table `uneet_enterprise_settings` */

DROP TABLE IF EXISTS `uneet_enterprise_settings`;

CREATE TABLE `uneet_enterprise_settings` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `TYPE` int(11) DEFAULT '1',
  `NAME` mediumtext CHARACTER SET utf8,
  `USERNAME` mediumtext CHARACTER SET utf8,
  `COOKIE` varchar(500) CHARACTER SET utf8 DEFAULT NULL,
  `SEARCH` mediumtext CHARACTER SET utf8,
  `TABLENAME` varchar(300) CHARACTER SET utf8 DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

/*Table structure for table `uneet_enterprise_uggroups` */

DROP TABLE IF EXISTS `uneet_enterprise_uggroups`;

CREATE TABLE `uneet_enterprise_uggroups` (
  `GroupID` int(11) NOT NULL AUTO_INCREMENT,
  `Label` varchar(300) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  PRIMARY KEY (`GroupID`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

/*Table structure for table `uneet_enterprise_ugmembers` */

DROP TABLE IF EXISTS `uneet_enterprise_ugmembers`;

CREATE TABLE `uneet_enterprise_ugmembers` (
  `UserName` varchar(300) COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `GroupID` int(11) NOT NULL,
  PRIMARY KEY (`UserName`(50),`GroupID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

/*Table structure for table `uneet_enterprise_ugrights` */

DROP TABLE IF EXISTS `uneet_enterprise_ugrights`;

CREATE TABLE `uneet_enterprise_ugrights` (
  `TableName` varchar(300) COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `GroupID` int(11) NOT NULL,
  `AccessMask` varchar(10) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  PRIMARY KEY (`TableName`(50),`GroupID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

/*Table structure for table `uneet_enterprise_users` */

DROP TABLE IF EXISTS `uneet_enterprise_users`;

CREATE TABLE `uneet_enterprise_users` (
  `ID` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `fullname` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `groupid` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `active` int(11) DEFAULT NULL COMMENT 'is this an active user',
  `organization_id` int(11) unsigned DEFAULT NULL COMMENT 'A FK to the table `uneet_enterprise_organizations` - The ID of the organization for the user',
  PRIMARY KEY (`ID`),
  KEY `user_organization_id` (`organization_id`),
  CONSTRAINT `user_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

/*Table structure for table `ut_api_keys` */

DROP TABLE IF EXISTS `ut_api_keys`;

CREATE TABLE `ut_api_keys` (
  `id_api_key` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id in this table',
  `syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
  `creation_system_id` int(11) DEFAULT NULL COMMENT 'What is the id of the sytem that was used for the creation of the record?',
  `created_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who created this record',
  `creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
  `syst_updated_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record last updated?',
  `update_system_id` int(11) DEFAULT NULL COMMENT 'What is the id of the sytem that was used for the last update the record?',
  `updated_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who updated this record',
  `update_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record updated?',
  `external_system_id` int(11) DEFAULT NULL COMMENT 'A FK to the table `ut_external_sot_for_unee_t_objects` - Store data about the source of truth for the information we need',
  `revoked_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this API key revoked',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT '1 is this API key is revoked or obsolete',
  `api_key` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The API Key',
  `mefe_user_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The ID of MEFE user which is associated to this API key',
  `organization_id` int(11) unsigned NOT NULL COMMENT 'A FK to the table `uneet_enterprise_organizations` - The ID of the organization for the user',
  PRIMARY KEY (`mefe_user_id`,`organization_id`) COMMENT 'We have only 1 MEFE User ID for each organization',
  UNIQUE KEY `unique_id_for_each_api` (`id_api_key`) COMMENT 'unique ID in this table',
  UNIQUE KEY `unit_api_key` (`api_key`) COMMENT 'It is not possible to have similar API keys',
  KEY `api_key_organization_id` (`organization_id`),
  CONSTRAINT `api_key_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

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

/*Table structure for table `ut_map_external_source_units` */

DROP TABLE IF EXISTS `ut_map_external_source_units`;

CREATE TABLE `ut_map_external_source_units` (
  `id_map` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Id in this table',
  `syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
  `creation_system_id` int(11) DEFAULT NULL COMMENT 'What is the id of the sytem that was used for the creation of the record?',
  `created_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who created this record',
  `creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
  `syst_updated_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record last updated?',
  `update_system_id` int(11) DEFAULT NULL COMMENT 'What is the id of the sytem that was used for the last update the record?',
  `updated_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who updated this record',
  `update_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record updated?',
  `organization_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT '1 if we need to remove this unit from the mapping',
  `is_update_needed` tinyint(1) DEFAULT '0' COMMENT '1 if we need to propagate that to downstream systens',
  `unee_t_mefe_unit_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the unit - a FK to the Mongo Collection unitMetaData',
  `uneet_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'Timestamp when the unit was created',
  `is_mefe_api_success` tinyint(1) DEFAULT '0' COMMENT '1 if this is a success, 0 if not',
  `mefe_api_error_message` text COLLATE utf8mb4_unicode_520_ci COMMENT 'The error message from the MEFE API (if applicable)',
  `is_unee_t_created_by_me` tinyint(1) DEFAULT '0' COMMENT '1 if this user has been created by this or 0 if the user was existing in Unee-T before',
  `unee_t_unit_type` varchar(100) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT 'Unknown' COMMENT 'The Unee-T type of unit for this property - this MUST be one of the `designation` in the table `ut_unit_types`',
  `uneet_name` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The name of the unit in the BZ database',
  `new_record_id` int(11) NOT NULL COMMENT 'The id of the record in the table `property_level_xxx`. This is used in combination with `external_property_type_id` to get more information about the unit',
  `external_property_type_id` int(11) NOT NULL COMMENT 'A FK to the table `ut_property_types`',
  `external_property_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The ID in the table which is the source of truth for the Unee-T unit information',
  `external_system` varchar(100) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The name of the external source of truth',
  `table_in_external_system` varchar(100) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The name of the table in the extrenal source of truth where the info is stored',
  `tower` varchar(50) COLLATE utf8mb4_unicode_520_ci NOT NULL DEFAULT '1' COMMENT 'If there is more than 1 building, the id for the unique building. Default is 1.',
  PRIMARY KEY (`external_property_id`,`external_system`,`table_in_external_system`,`organization_id`,`tower`,`external_property_type_id`),
  UNIQUE KEY `unique_mefe_unit_id` (`unee_t_mefe_unit_id`),
  KEY `id_map` (`id_map`),
  KEY `unee_t_valid_unit_type_map_units` (`unee_t_unit_type`),
  KEY `property_property_type` (`external_property_type_id`),
  KEY `mefe_unit_organization_id` (`organization_id`),
  CONSTRAINT `mefe_unit_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE,
  CONSTRAINT `property_property_type` FOREIGN KEY (`external_property_type_id`) REFERENCES `ut_property_types` (`id_property_type`) ON UPDATE CASCADE,
  CONSTRAINT `unee_t_valid_unit_type_map_units` FOREIGN KEY (`unee_t_unit_type`) REFERENCES `ut_unit_types` (`designation`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3936 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

/*Table structure for table `ut_map_external_source_users` */

DROP TABLE IF EXISTS `ut_map_external_source_users`;

CREATE TABLE `ut_map_external_source_users` (
  `id_map` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Id in this table',
  `syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
  `creation_system_id` int(11) DEFAULT NULL COMMENT 'What is the id of the sytem that was used for the creation of the record?',
  `created_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who created this record',
  `creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
  `syst_updated_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record last updated?',
  `update_system_id` int(11) DEFAULT NULL COMMENT 'What is the id of the sytem that was used for the last update the record?',
  `updated_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who updated this record',
  `update_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record updated?',
  `organization_id` int(11) unsigned NOT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT '1 if we need to remove this unit from the mapping',
  `is_update_needed` tinyint(1) DEFAULT '0' COMMENT '1 if we need to propagate that to downstream systens',
  `person_id` int(11) DEFAULT NULL COMMENT 'A FK to the table `persons`',
  `unee_t_mefe_user_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user - a FK to the Mongo Collection `users`',
  `unee_t_mefe_user_api_key` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE API key that this user can use to get info via the Unee-T APis.',
  `uneet_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'Timestamp when the user was created in Unee-T',
  `is_mefe_api_success` tinyint(1) DEFAULT '0' COMMENT '1 if this is a success, 0 if not',
  `mefe_api_error_message` text COLLATE utf8mb4_unicode_520_ci COMMENT 'The error message from the MEFE API (if applicable)',
  `is_unee_t_created_by_me` tinyint(1) DEFAULT '0' COMMENT '1 if this unit has been created by this or 0 if the user was existing in Unee-T before',
  `uneet_login_name` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The login name of the user in the BZ database',
  `external_person_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The ID in the IPI table for this record',
  `external_system` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The name of the external source of truth',
  `table_in_external_system` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The name of the table in the extrenal source of truth where the info is stored',
  PRIMARY KEY (`external_person_id`,`external_system`,`table_in_external_system`,`organization_id`),
  UNIQUE KEY `unique_mefe_user_id` (`unee_t_mefe_user_id`),
  UNIQUE KEY `unee-t_user_person` (`person_id`),
  KEY `id_map` (`id_map`),
  KEY `mefe_user_organization_id` (`organization_id`),
  CONSTRAINT `mefe_user_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE,
  CONSTRAINT `unee-t_user_person` FOREIGN KEY (`person_id`) REFERENCES `persons` (`id_person`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=77 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

/*Table structure for table `ut_map_user_permissions_unit_all` */

DROP TABLE IF EXISTS `ut_map_user_permissions_unit_all`;

CREATE TABLE `ut_map_user_permissions_unit_all` (
  `id_map_user_unit_permissions` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique ID in this table',
  `syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
  `creation_system_id` int(11) NOT NULL DEFAULT '1' COMMENT 'What is the id of the sytem that was used for the creation of the record?',
  `created_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who created this record',
  `creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
  `syst_updated_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record last updated?',
  `update_system_id` int(11) DEFAULT NULL COMMENT 'What is the id of the sytem that was used for the last update the record?',
  `updated_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who updated this record',
  `update_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record updated?',
  `organization_id` int(11) unsigned DEFAULT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  `is_update_needed` tinyint(1) DEFAULT '0' COMMENT '1 if Unee-T needs to be updated',
  `unee_t_update_ts` timestamp NULL DEFAULT NULL COMMENT 'The Timestamp when the last Unee-T update has been made',
  `is_mefe_api_success` tinyint(1) DEFAULT '0' COMMENT '1 if this is a success, 0 if not',
  `mefe_api_error_message` text COLLATE utf8mb4_unicode_520_ci COMMENT 'The error message from the MEFE API (if applicable)',
  `unee_t_mefe_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The current Unee-T profile id of the person - this is the value of the field `_id` in the Mongo Collection `users`',
  `unee_t_unit_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'ID of that Unit in Unee-T. This is a the value in the Mongo collection',
  `unee_t_role_id` smallint(6) DEFAULT NULL COMMENT 'FK to the Unee-T BZFE table `ut_role_types` - ID of the Role for this user.',
  `is_occupant` tinyint(1) DEFAULT '0' COMMENT '1 is the user is an occupant of the unit',
  `is_default_assignee` tinyint(1) DEFAULT '0' COMMENT '1 if this user is the default assignee for this role for this unit.',
  `is_default_invited` tinyint(1) DEFAULT '0' COMMENT '1 if the user is automatically invited to all the new cases in this role for this unit',
  `is_unit_owner` tinyint(1) DEFAULT '0' COMMENT '1 if this user is one of the Unee-T `owner` of that unit',
  `is_public` tinyint(1) DEFAULT '0' COMMENT '1 if the user is Visible to other Unee-T users in other roles for this unit. If yes/1/TRUE then all other roles will be able to see this user. IF No/FALSE/0 then only the users in the same role for that unit will be able to see this user in this unit',
  `can_see_role_landlord` tinyint(1) DEFAULT '0' COMMENT '1 if user is allowed to see the PUBLIC users in the role `landlord` (2) for this unit',
  `can_see_role_tenant` tinyint(1) DEFAULT '0' COMMENT '1 if user is allowed to see the PUBLIC users in the role `tenant` (1) for this unit',
  `can_see_role_mgt_cny` tinyint(1) DEFAULT '0' COMMENT '1 if user is allowed to see the PUBLIC users in the role `Mgt Company` (4) for this unit',
  `can_see_role_agent` tinyint(1) DEFAULT '0' COMMENT '1 if user is allowed to see the PUBLIC users in the role `agent` (5) for this unit',
  `can_see_role_contractor` tinyint(1) DEFAULT '0' COMMENT '1 if user is allowed to see the PUBLIC users in the role `contractor` (3) for this unit',
  `can_see_occupant` tinyint(1) DEFAULT '0' COMMENT '1 if user is allowed to see the PUBLIC occupants for this unit',
  `is_assigned_to_case` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_invited_to_case` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_next_step_updated` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_deadline_updated` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_solution_updated` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_case_resolved` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_case_blocker` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_case_critical` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_any_new_message` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_message_from_my_role` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_message_from_tenant` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_message_from_ll` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_message_from_occupant` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_message_from_agent` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_message_from_mgt_cny` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_message_from_contractor` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_new_ir` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_new_item` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_item_removed` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_item_moved` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  PRIMARY KEY (`unee_t_mefe_id`,`unee_t_unit_id`),
  UNIQUE KEY `map_user_unit_role_permissions` (`id_map_user_unit_permissions`),
  KEY `mefe_unit_must_exist_here` (`unee_t_unit_id`),
  KEY `map_mefe_unit_mefe_user_all_organization_id` (`organization_id`),
  CONSTRAINT `map_mefe_unit_mefe_user_all_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE,
  CONSTRAINT `mefe_unit_must_exist_here` FOREIGN KEY (`unee_t_unit_id`) REFERENCES `ut_map_external_source_units` (`unee_t_mefe_unit_id`) ON UPDATE CASCADE,
  CONSTRAINT `mefe_user_must_exist_here` FOREIGN KEY (`unee_t_mefe_id`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=59902 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

/*Table structure for table `ut_map_user_permissions_unit_level_1` */

DROP TABLE IF EXISTS `ut_map_user_permissions_unit_level_1`;

CREATE TABLE `ut_map_user_permissions_unit_level_1` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique ID in this table',
  `syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
  `creation_system_id` int(11) NOT NULL DEFAULT '1' COMMENT 'What is the id of the sytem that was used for the creation of the record?',
  `created_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who created this record',
  `creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
  `syst_updated_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record last updated?',
  `update_system_id` int(11) DEFAULT NULL COMMENT 'What is the id of the sytem that was used for the last update the record?',
  `updated_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who updated this record',
  `update_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record updated?',
  `organization_id` int(11) unsigned DEFAULT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  `is_update_needed` tinyint(1) DEFAULT '0' COMMENT '1 if Unee-T needs to be updated',
  `unee_t_update_ts` timestamp NULL DEFAULT NULL COMMENT 'The Timestamp when the last Unee-T update has been made',
  `unee_t_mefe_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The current Unee-T profile id of the person - this is the value of the field `_id` in the Mongo Collection `users`',
  `unee_t_unit_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'ID of that Unit in Unee-T. This is a the value in the Mongo collection',
  `unee_t_role_id` smallint(6) DEFAULT NULL COMMENT 'The ID of the Role Type for this user - this is a FK to the Unee-T BZFE table `ut_role_types`',
  `is_occupant` tinyint(1) DEFAULT '0' COMMENT '1 is the user is an occupant of the unit',
  `is_default_assignee` tinyint(1) DEFAULT '0' COMMENT '1 if this user is the default assignee for this role for this unit.',
  `is_default_invited` tinyint(1) DEFAULT '0' COMMENT '1 if the user is automatically invited to all the new cases in this role for this unit',
  `is_unit_owner` tinyint(1) DEFAULT '0' COMMENT '1 if this user is one of the Unee-T `owner` of that unit',
  `is_public` tinyint(1) DEFAULT '0' COMMENT '1 if the user is Visible to other Unee-T users in other roles for this unit. If yes/1/TRUE then all other roles will be able to see this user. IF No/FALSE/0 then only the users in the same role for that unit will be able to see this user in this unit',
  `can_see_role_landlord` tinyint(1) DEFAULT '0' COMMENT '1 if user is allowed to see the PUBLIC users in the role `landlord` (2) for this unit',
  `can_see_role_tenant` tinyint(1) DEFAULT '0' COMMENT '1 if user is allowed to see the PUBLIC users in the role `tenant` (1) for this unit',
  `can_see_role_mgt_cny` tinyint(1) DEFAULT '0' COMMENT '1 if user is allowed to see the PUBLIC users in the role `Mgt Company` (4) for this unit',
  `can_see_role_agent` tinyint(1) DEFAULT '0' COMMENT '1 if user is allowed to see the PUBLIC users in the role `agent` (5) for this unit',
  `can_see_role_contractor` tinyint(1) DEFAULT '0' COMMENT '1 if user is allowed to see the PUBLIC users in the role `contractor` (3) for this unit',
  `can_see_occupant` tinyint(1) DEFAULT '0' COMMENT '1 if user is allowed to see the PUBLIC occupants for this unit',
  `is_assigned_to_case` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_invited_to_case` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_next_step_updated` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_deadline_updated` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_solution_updated` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_case_resolved` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_case_blocker` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_case_critical` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_any_new_message` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_message_from_my_role` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_message_from_tenant` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_message_from_ll` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_message_from_occupant` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_message_from_agent` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_message_from_mgt_cny` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_message_from_contractor` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_new_ir` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_new_item` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_item_removed` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_item_moved` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `propagate_to_all_level_2` tinyint(1) DEFAULT '0' COMMENT '1 if we need to copy these permissions to all the level 2 properties in this Level 2 properties associated to this property.',
  `propagate_to_all_level_3` tinyint(1) DEFAULT '0' COMMENT '1 if we need to copy these permissions to all the level 3 properties in this Level 2  associated to this property',
  PRIMARY KEY (`unee_t_mefe_id`,`unee_t_unit_id`),
  UNIQUE KEY `unit_level_1_map_user_unit_unique_id` (`id`),
  KEY `unit_level_1_mefe_unit_id_must_exist` (`unee_t_unit_id`),
  KEY `map_mefe_unit_mefe_user_level_1_organization_id` (`organization_id`),
  CONSTRAINT `map_mefe_unit_mefe_user_level_1_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE,
  CONSTRAINT `unit_level_1_mefe_unit_id_must_exist` FOREIGN KEY (`unee_t_unit_id`) REFERENCES `ut_map_external_source_units` (`unee_t_mefe_unit_id`) ON UPDATE CASCADE,
  CONSTRAINT `unit_level_1_mefe_user_id_must_exist` FOREIGN KEY (`unee_t_mefe_id`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3798 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

/*Table structure for table `ut_map_user_permissions_unit_level_2` */

DROP TABLE IF EXISTS `ut_map_user_permissions_unit_level_2`;

CREATE TABLE `ut_map_user_permissions_unit_level_2` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique ID in this table',
  `syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
  `creation_system_id` int(11) NOT NULL DEFAULT '1' COMMENT 'What is the id of the sytem that was used for the creation of the record?',
  `created_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who created this record',
  `creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
  `syst_updated_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record last updated?',
  `update_system_id` int(11) DEFAULT NULL COMMENT 'What is the id of the sytem that was used for the last update the record?',
  `updated_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who updated this record',
  `update_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record updated?',
  `organization_id` int(11) unsigned DEFAULT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  `is_update_needed` tinyint(1) DEFAULT '0' COMMENT '1 if Unee-T needs to be updated',
  `unee_t_update_ts` timestamp NULL DEFAULT NULL COMMENT 'The Timestamp when the last Unee-T update has been made',
  `unee_t_mefe_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The current Unee-T profile id of the person - this is the value of the field `_id` in the Mongo Collection `users`',
  `unee_t_unit_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'ID of that Unit in Unee-T. This is a the value in the Mongo collection',
  `unee_t_role_id` smallint(6) DEFAULT NULL COMMENT 'The ID of the Role Type for this user - this is a FK to the Unee-T BZFE table `ut_role_types`',
  `is_occupant` tinyint(1) DEFAULT '0' COMMENT '1 is the user is an occupant of the unit',
  `is_default_assignee` tinyint(1) DEFAULT '0' COMMENT '1 if this user is the default assignee for this role for this unit.',
  `is_default_invited` tinyint(1) DEFAULT '0' COMMENT '1 if the user is automatically invited to all the new cases in this role for this unit',
  `is_unit_owner` tinyint(1) DEFAULT '0' COMMENT '1 if this user is one of the Unee-T `owner` of that unit',
  `is_public` tinyint(1) DEFAULT '0' COMMENT '1 if the user is Visible to other Unee-T users in other roles for this unit. If yes/1/TRUE then all other roles will be able to see this user. IF No/FALSE/0 then only the users in the same role for that unit will be able to see this user in this unit',
  `can_see_role_landlord` tinyint(1) DEFAULT '0' COMMENT '1 if user is allowed to see the PUBLIC users in the role `landlord` (2) for this unit',
  `can_see_role_tenant` tinyint(1) DEFAULT '0' COMMENT '1 if user is allowed to see the PUBLIC users in the role `tenant` (1) for this unit',
  `can_see_role_mgt_cny` tinyint(1) DEFAULT '0' COMMENT '1 if user is allowed to see the PUBLIC users in the role `Mgt Company` (4) for this unit',
  `can_see_role_agent` tinyint(1) DEFAULT '0' COMMENT '1 if user is allowed to see the PUBLIC users in the role `agent` (5) for this unit',
  `can_see_role_contractor` tinyint(1) DEFAULT '0' COMMENT '1 if user is allowed to see the PUBLIC users in the role `contractor` (3) for this unit',
  `can_see_occupant` tinyint(1) DEFAULT '0' COMMENT '1 if user is allowed to see the PUBLIC occupants for this unit',
  `is_assigned_to_case` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_invited_to_case` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_next_step_updated` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_deadline_updated` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_solution_updated` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_case_resolved` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_case_blocker` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_case_critical` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_any_new_message` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_message_from_my_role` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_message_from_tenant` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_message_from_ll` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_message_from_occupant` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_message_from_agent` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_message_from_mgt_cny` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_message_from_contractor` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_new_ir` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_new_item` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_item_removed` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_item_moved` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `propagate_to_all_level_3` tinyint(1) DEFAULT '0' COMMENT '1 if we need to copy these permissions to all the level 3 properties in this Level 2  associated to this property',
  PRIMARY KEY (`unee_t_mefe_id`,`unee_t_unit_id`),
  UNIQUE KEY `unit_level_2_map_user_unit_unique_id` (`id`),
  KEY `unit_level_2_mefe_unit_id_must_exist` (`unee_t_unit_id`),
  KEY `map_mefe_unit_mefe_user_level_2_organization_id` (`organization_id`),
  CONSTRAINT `map_mefe_unit_mefe_user_level_2_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE,
  CONSTRAINT `unit_level_2_mefe_unit_id_must_exist` FOREIGN KEY (`unee_t_unit_id`) REFERENCES `ut_map_external_source_units` (`unee_t_mefe_unit_id`) ON UPDATE CASCADE,
  CONSTRAINT `unit_level_2_mefe_user_id_must_exist` FOREIGN KEY (`unee_t_mefe_id`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=23010 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

/*Table structure for table `ut_map_user_permissions_unit_level_3` */

DROP TABLE IF EXISTS `ut_map_user_permissions_unit_level_3`;

CREATE TABLE `ut_map_user_permissions_unit_level_3` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique ID in this table',
  `syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
  `creation_system_id` int(11) NOT NULL DEFAULT '1' COMMENT 'What is the id of the sytem that was used for the creation of the record?',
  `created_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who created this record',
  `creation_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record created',
  `syst_updated_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record last updated?',
  `update_system_id` int(11) DEFAULT NULL COMMENT 'What is the id of the sytem that was used for the last update the record?',
  `updated_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who updated this record',
  `update_method` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'How was this record updated?',
  `organization_id` int(11) unsigned DEFAULT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
  `system_id_level_3` int(11) DEFAULT NULL COMMENT 'A FK to the table `property_level_3_rooms`',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  `is_update_needed` tinyint(1) DEFAULT '0' COMMENT '1 if Unee-T needs to be updated',
  `unee_t_update_ts` timestamp NULL DEFAULT NULL COMMENT 'The Timestamp when the last Unee-T update has been made',
  `unee_t_mefe_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The current Unee-T profile id of the person - this is the value of the field `_id` in the Mongo Collection `users`',
  `unee_t_unit_id` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'ID of that Unit in Unee-T. This is a the value in the Mongo collection',
  `unee_t_role_id` smallint(6) DEFAULT NULL COMMENT 'The ID of the Role Type for this user - this is a FK to the Unee-T BZFE table `ut_role_types`',
  `is_occupant` tinyint(1) DEFAULT '0' COMMENT '1 is the user is an occupant of the unit',
  `is_default_assignee` tinyint(1) DEFAULT '0' COMMENT '1 if this user is the default assignee for this role for this unit.',
  `is_default_invited` tinyint(1) DEFAULT '0' COMMENT '1 if the user is automatically invited to all the new cases in this role for this unit',
  `is_unit_owner` tinyint(1) DEFAULT '0' COMMENT '1 if this user is one of the Unee-T `owner` of that unit',
  `is_public` tinyint(1) DEFAULT '0' COMMENT '1 if the user is Visible to other Unee-T users in other roles for this unit. If yes/1/TRUE then all other roles will be able to see this user. IF No/FALSE/0 then only the users in the same role for that unit will be able to see this user in this unit',
  `can_see_role_landlord` tinyint(1) DEFAULT '0' COMMENT '1 if user is allowed to see the PUBLIC users in the role `landlord` (2) for this unit',
  `can_see_role_tenant` tinyint(1) DEFAULT '0' COMMENT '1 if user is allowed to see the PUBLIC users in the role `tenant` (1) for this unit',
  `can_see_role_mgt_cny` tinyint(1) DEFAULT '0' COMMENT '1 if user is allowed to see the PUBLIC users in the role `Mgt Company` (4) for this unit',
  `can_see_role_agent` tinyint(1) DEFAULT '0' COMMENT '1 if user is allowed to see the PUBLIC users in the role `agent` (5) for this unit',
  `can_see_role_contractor` tinyint(1) DEFAULT '0' COMMENT '1 if user is allowed to see the PUBLIC users in the role `contractor` (3) for this unit',
  `can_see_occupant` tinyint(1) DEFAULT '0' COMMENT '1 if user is allowed to see the PUBLIC occupants for this unit',
  `is_assigned_to_case` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_invited_to_case` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_next_step_updated` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_deadline_updated` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_solution_updated` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_case_resolved` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_case_blocker` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_case_critical` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_any_new_message` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_message_from_my_role` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_message_from_tenant` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_message_from_ll` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_message_from_occupant` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_message_from_agent` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_message_from_mgt_cny` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_message_from_contractor` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_new_ir` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_new_item` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_item_removed` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_item_moved` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  PRIMARY KEY (`unee_t_mefe_id`,`unee_t_unit_id`),
  UNIQUE KEY `unit_level_3_map_user_unit_unique_id` (`id`),
  KEY `map_user_permissions_unit_level_3_room_id` (`system_id_level_3`),
  KEY `unit_level_3_mefe_unit_id_must_exist` (`unee_t_unit_id`),
  KEY `map_mefe_unit_mefe_user_level_3_organization_id` (`organization_id`),
  CONSTRAINT `map_mefe_unit_mefe_user_level_3_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE,
  CONSTRAINT `map_user_permissions_unit_level_3_room_id` FOREIGN KEY (`system_id_level_3`) REFERENCES `property_level_3_rooms` (`system_id_room`) ON UPDATE CASCADE,
  CONSTRAINT `unit_level_3_mefe_unit_id_must_exist` FOREIGN KEY (`unee_t_unit_id`) REFERENCES `ut_map_external_source_units` (`unee_t_mefe_unit_id`) ON UPDATE CASCADE,
  CONSTRAINT `unit_level_3_mefe_user_id_must_exist` FOREIGN KEY (`unee_t_mefe_id`) REFERENCES `ut_map_external_source_users` (`unee_t_mefe_user_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=31948 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

/*Table structure for table `ut_property_types` */

DROP TABLE IF EXISTS `ut_property_types`;

CREATE TABLE `ut_property_types` (
  `id_property_type` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique id in this table',
  `syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
  `creation_system_id` int(11) NOT NULL DEFAULT '1' COMMENT 'What is the id of the system that was used for the creation of the record?',
  `created_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who created this record',
  `syst_updated_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record last updated?',
  `update_system_id` int(11) DEFAULT NULL COMMENT 'What is the id of the system that was used for the last update the record?',
  `updated_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who updated this record',
  `order` int(11) DEFAULT NULL COMMENT 'Order in the list',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT '1 if this is not in use anymore.',
  `designation` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The designation',
  `description` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Detailed description',
  PRIMARY KEY (`id_property_type`),
  UNIQUE KEY `unique_property_type` (`designation`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC;

/*Table structure for table `ut_unit_types` */

DROP TABLE IF EXISTS `ut_unit_types`;

CREATE TABLE `ut_unit_types` (
  `id_property_type` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique id in this table',
  `syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
  `creation_system_id` int(11) NOT NULL DEFAULT '1' COMMENT 'What is the id of the system that was used for the creation of the record?',
  `created_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who created this record',
  `syst_updated_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record last updated?',
  `update_system_id` int(11) DEFAULT NULL COMMENT 'What is the id of the system that was used for the last update the record?',
  `updated_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who updated this record',
  `order` int(11) DEFAULT NULL COMMENT 'Order in the list',
  `is_level_1` tinyint(1) DEFAULT '0' COMMENT 'This apply to Level 1 properties',
  `is_level_2` tinyint(1) DEFAULT '0' COMMENT 'This apply to Level 2 properties',
  `is_level_3` tinyint(1) DEFAULT '0' COMMENT 'This apply to Level 3 properties',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT '1 if this is not in use anymore.',
  `designation` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'The designation',
  `description` text COLLATE utf8mb4_unicode_520_ci COMMENT 'Detailed description',
  PRIMARY KEY (`id_property_type`),
  UNIQUE KEY `unique_unee_t_property_type` (`designation`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci ROW_FORMAT=DYNAMIC;

/*Table structure for table `ut_user_role_types` */

DROP TABLE IF EXISTS `ut_user_role_types`;

CREATE TABLE `ut_user_role_types` (
  `id_role_type` mediumint(9) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID in this table',
  `syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
  `creation_system_id` int(11) DEFAULT NULL COMMENT 'What is the id of the system that was used for the creation of the record?',
  `created_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who created this record',
  `syst_updated_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record last updated?',
  `update_system_id` int(11) DEFAULT NULL COMMENT 'What is the id of the system that was used for the last update the record?',
  `updated_by_id` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'The MEFE ID of the user who updated this record',
  `order` int(11) DEFAULT NULL COMMENT 'Order in the list',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT '1 if this is not in use anymore.',
  `role_type` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL COMMENT 'A name for this role type',
  `bz_description` varchar(255) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL COMMENT 'A short, generic description that we include each time we create a new BZ unit.',
  `description` mediumtext COLLATE utf8mb4_unicode_520_ci COMMENT 'Detailed description of this group type',
  PRIMARY KEY (`id_role_type`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

/*Table structure for table `ut_user_types` */

DROP TABLE IF EXISTS `ut_user_types`;

CREATE TABLE `ut_user_types` (
  `id_unee_t_user_type` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique ID in this table',
  `syst_created_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record created?',
  `creation_system_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'What is the id of the sytem that was used for the creation of the record?',
  `created_by_id` int(11) unsigned DEFAULT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
  `creation_method` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'How was this record created',
  `syst_updated_datetime` timestamp NULL DEFAULT NULL COMMENT 'When was this record last updated?',
  `update_system_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'What is the id of the sytem that was used for the last update the record?',
  `updated_by_id` int(11) unsigned DEFAULT NULL COMMENT 'a FK to the table `uneet_enterprise_organizations` The ID of the organization that created this record',
  `update_method` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'How was this record updated?',
  `organization_id` int(11) unsigned NOT NULL COMMENT 'A FK to the table `uneet_enterprise_organizations` - The ID of the organization for the user',
  `order` int(5) DEFAULT NULL COMMENT 'Order in the list',
  `is_obsolete` tinyint(1) DEFAULT '0' COMMENT 'is this obsolete?',
  `designation` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'The unee-t user type',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Detailed description on how/when we should use this value',
  `ut_user_role_type_id` mediumint(9) unsigned DEFAULT NULL COMMENT 'A FK tgo the table `ut_user_role_types` Role of this user type in the unit',
  `is_all_unit` tinyint(1) DEFAULT '0' COMMENT '1 if we want to assign all units in the organization to this role. All properties in all the countries and all the Areas will be automatically added.',
  `is_all_units_in_country` tinyint(1) DEFAULT '0' COMMENT '1 if we want to assign all units in the organization and in the countries chosen for this user. All the properties in the countries will be automatically assigned to this role.',
  `is_all_units_in_area` tinyint(1) DEFAULT '0' COMMENT '1 if we want to assign all units in the organization and in the areas chosen for the user. All the properties in all these areas will be automatically assigned to this role.',
  `is_all_units_in_level_1` tinyint(1) DEFAULT '0' COMMENT '1 if we want to assign all units in the organization and in the Level 1 Properties chosen for the user. All the properties in all the Level 1 properties selected will be automatically assigned to these users.',
  `is_all_units_in_level_2` tinyint(1) DEFAULT '0' COMMENT '1 if we want to assign all units in the organization and in the Level 2 Properties chosen for the user. All the properties in all the Level 2 properties selected will be automatically assigned to these users.',
  `is_occupant` tinyint(1) DEFAULT '0' COMMENT '1 if this is for an Occupant of the unit',
  `is_public` tinyint(1) DEFAULT '0' COMMENT '1 if the user is visible to other users who can see the role for this user',
  `is_default_assignee` tinyint(1) DEFAULT '0' COMMENT '1 if the user is the default assignee for this role',
  `is_default_invited` tinyint(1) DEFAULT '0' COMMENT '1 if user is invited by default to all cases created AND/OR assigned to this role',
  `is_unit_owner` tinyint(1) DEFAULT '0' COMMENT '1 if the user is a super user for that unit',
  `is_dashboard_access` tinyint(1) DEFAULT '0' COMMENT '1 if user has access to the Unee-T dashboard interface',
  `can_see_role_contractor` tinyint(1) DEFAULT '0' COMMENT '1 if user can see PUBLIC users in this role',
  `can_see_role_mgt_cny` tinyint(1) DEFAULT '0' COMMENT '1 if user can see PUBLIC users in this role',
  `can_see_occupant` tinyint(1) DEFAULT '0' COMMENT '1 if user can see PUBLIC users with this attribute',
  `can_see_role_landlord` tinyint(1) DEFAULT '0' COMMENT '1 if user can see PUBLIC users in this role',
  `can_see_role_agent` tinyint(1) DEFAULT '0' COMMENT '1 if user can see PUBLIC users in this role',
  `can_see_role_tenant` tinyint(1) DEFAULT '0' COMMENT '1 if user can see PUBLIC users in this role',
  `is_assigned_to_case` tinyint(1) DEFAULT '1' COMMENT '1 if user wants to be notified',
  `is_invited_to_case` tinyint(1) DEFAULT '1' COMMENT '1 if user wants to be notified',
  `is_solution_updated` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_next_step_updated` tinyint(1) DEFAULT '1' COMMENT '1 if user wants to be notified',
  `is_deadline_updated` tinyint(1) DEFAULT '1' COMMENT '1 if user wants to be notified',
  `is_case_resolved` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_case_critical` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_case_blocker` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_message_from_contractor` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_message_from_mgt_cny` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_message_from_agent` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_message_from_occupant` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_message_from_ll` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_message_from_tenant` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_any_new_message` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_new_ir` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_new_inventory` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_new_item` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_item_moved` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  `is_item_removed` tinyint(1) DEFAULT '0' COMMENT '1 if user wants to be notified',
  PRIMARY KEY (`designation`,`organization_id`),
  UNIQUE KEY `unique_id_in_this_table` (`id_unee_t_user_type`),
  KEY `user_type_organization_id` (`organization_id`),
  KEY `user_type_user_role_id` (`ut_user_role_type_id`),
  CONSTRAINT `user_type_created_by` FOREIGN KEY (`organization_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE,
  CONSTRAINT `user_type_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE,
  CONSTRAINT `user_type_updated_by` FOREIGN KEY (`organization_id`) REFERENCES `uneet_enterprise_organizations` (`id_organization`) ON UPDATE CASCADE,
  CONSTRAINT `user_type_user_role_id` FOREIGN KEY (`ut_user_role_type_id`) REFERENCES `ut_user_role_types` (`id_role_type`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

/* Trigger structure for table `external_map_user_unit_role_permissions_areas` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_add_user_to_role_in_all_buildings_in_area` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_add_user_to_role_in_all_buildings_in_area` AFTER INSERT ON `external_map_user_unit_role_permissions_areas` FOR EACH ROW 
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
END */$$


DELIMITER ;

/* Trigger structure for table `external_map_user_unit_role_permissions_areas` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_delete_user_from_role_in_an_area` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_delete_user_from_role_in_an_area` AFTER DELETE ON `external_map_user_unit_role_permissions_areas` FOR EACH ROW 
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
END */$$


DELIMITER ;

/* Trigger structure for table `external_map_user_unit_role_permissions_level_1` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_add_user_to_role_in_a_level_1_property` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_add_user_to_role_in_a_level_1_property` AFTER INSERT ON `external_map_user_unit_role_permissions_level_1` FOR EACH ROW 
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
END */$$


DELIMITER ;

/* Trigger structure for table `external_map_user_unit_role_permissions_level_1` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_delete_user_from_role_in_a_level_1_property` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_delete_user_from_role_in_a_level_1_property` AFTER DELETE ON `external_map_user_unit_role_permissions_level_1` FOR EACH ROW 
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
END */$$


DELIMITER ;

/* Trigger structure for table `external_map_user_unit_role_permissions_level_2` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_add_user_to_role_in_a_level_2_property` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_add_user_to_role_in_a_level_2_property` AFTER INSERT ON `external_map_user_unit_role_permissions_level_2` FOR EACH ROW 
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

		SET @is_obsolete_add_u_l2_1 := NEW.`is_obsolete` ;
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
END */$$


DELIMITER ;

/* Trigger structure for table `external_map_user_unit_role_permissions_level_2` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_delete_user_from_role_in_a_level_2_property` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_delete_user_from_role_in_a_level_2_property` AFTER DELETE ON `external_map_user_unit_role_permissions_level_2` FOR EACH ROW 
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
END */$$


DELIMITER ;

/* Trigger structure for table `external_map_user_unit_role_permissions_level_3` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_add_user_to_role_in_a_level_3_property` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_add_user_to_role_in_a_level_3_property` AFTER INSERT ON `external_map_user_unit_role_permissions_level_3` FOR EACH ROW 
BEGIN

# We only do this IF
#	- We have a MEFE user ID for the creator of that record
#	- This is not an obsolete request
#	- We have a MEFE user ID for the user that we are adding
#	- We have a role_type
#	- We have a user_type
#	- We have an organization ID
#	- This is done via an authorized insert method:
#		- 'Assign_Rooms_to_Users_Add_Page'
#		- 'Assign_Rooms_to_Users_Import_Page'
#		- ''
#		- ''
#

	SET @source_system_creator_add_u_l3_1 = NEW.`created_by_id` ;
	SET @source_system_updater_add_u_l3_1 = NEW.`updated_by_id`;

	SET @creator_mefe_user_id_add_u_l3_1 = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator_add_u_l3_1
		)
		;

	SET @upstream_create_method_add_u_l3_1 = NEW.`creation_method` ;
	SET @upstream_update_method_add_u_l3_1 = NEW.`update_method` ;

	SET @organization_id = NEW.`organization_id` ;

	SET @is_obsolete = NEW.`is_obsolete` ;

	SET @unee_t_level_3_id = NEW.`unee_t_level_3_id` ;

	SET @unee_t_mefe_user_id = NEW.`unee_t_mefe_user_id` ;
	SET @unee_t_user_type_id = NEW.`unee_t_user_type_id` ;
	SET @unee_t_role_id = NEW.`unee_t_role_id` ;

	IF @source_system_creator_add_u_l3_1 IS NOT NULL
		AND @organization_id IS NOT NULL
		AND @is_obsolete = 0
		AND @unee_t_mefe_user_id IS NOT NULL
		AND @unee_t_user_type_id IS NOT NULL
		AND @unee_t_role_id IS NOT NULL
		AND (@upstream_create_method_add_u_l3_1 = 'Assign_Rooms_to_Users_Add_Page'
			OR @upstream_update_method_add_u_l3_1 = 'Assign_Rooms_to_Users_Add_Page'
			OR @upstream_create_method_add_u_l3_1 = 'Assign_Rooms_to_Users_Import_Page'
			OR @upstream_update_method_add_u_l3_1 = 'Assign_Rooms_to_Users_Import_Page'
			)
	THEN 

	# We capture the variables that we need:

		SET @this_trigger = 'ut_add_user_to_role_in_a_level_3_property' ;

		SET @syst_created_datetime = NOW() ;
		SET @creation_system_id = 2 ;
		SET @created_by_id_add_u_l3_1 = @source_system_creator_add_u_l3_1 ;
		SET @creation_method = @this_trigger ;

		SET @syst_updated_datetime = NOW() ;
		SET @update_system_id = 2 ;
		SET @updated_by_id_add_u_l3_1 = @source_system_updater_add_u_l3_1 ;
		SET @update_method = @this_trigger ;

		SET @is_obsolete = NEW.`is_obsolete` ;
		SET @is_update_needed = 1 ;

	# We insert these permissions in the table `ut_map_user_permissions_unit_level_3`

	# We need the MEFE unit_id for each of the level_3 properties:

		SET @unee_t_mefe_unit_id = (SELECT `unee_t_mefe_unit_id`
			FROM `ut_list_mefe_unit_id_level_3_by_area`
			WHERE `level_3_room_id` = @unee_t_level_3_id
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
					(@syst_created_datetime
					, @creation_system_id
					, @creator_mefe_user_id_add_u_l3_1
					, @creation_method
					, @organization_id
					, @is_obsolete
					, @is_update_needed
					# Which unit/user
					, @unee_t_mefe_user_id
					, @unee_t_mefe_unit_id
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
					)
					;

	END IF;
END */$$


DELIMITER ;

/* Trigger structure for table `external_map_user_unit_role_permissions_level_3` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_delete_user_from_role_in_a_level_3_property` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_delete_user_from_role_in_a_level_3_property` AFTER DELETE ON `external_map_user_unit_role_permissions_level_3` FOR EACH ROW 
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
END */$$


DELIMITER ;

/* Trigger structure for table `external_persons` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_insert_external_person` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_insert_external_person` AFTER INSERT ON `external_persons` FOR EACH ROW 
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
END */$$


DELIMITER ;

/* Trigger structure for table `external_persons` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_update_external_person_not_ut_user_type` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_update_external_person_not_ut_user_type` AFTER UPDATE ON `external_persons` FOR EACH ROW 
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
				WHERE `person_id` = @person_id_up_1
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
			END IF;

		# We check if we just need to update this record

			SET @record_in_table = (SELECT `id_map` 
				FROM `ut_map_external_source_users`
				WHERE `external_person_id` = @external_id
					AND `external_system` = @external_system
					AND `table_in_external_system` = @external_table
					AND `organization_id` = @organization_id_update
				)
				;

			SET @requestor_id := @updated_by_id ;

			SET @person_id := (SELECT `id_person` 
				FROM `persons`
				WHERE `external_id` = @external_id
					AND `external_system` = @external_system
					AND `external_table` = @external_table
					AND `organization_id` = @organization_id_update
				)
				;

			IF @is_unee_t_account_needed = 1
				AND @record_in_table IS NOT NULL
				AND @new_is_unee_t_account_needed_up_1 = @old_is_unee_t_account_needed_up_1 
				AND @email IS NOT NULL
			THEN 

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
					WHERE `person_id` = @person_id
					;

			# We call the procedure that calls the lambda to update the user record in Unee-T

				CALL `ut_update_user`;

			END IF;

	END IF;
END */$$


DELIMITER ;

/* Trigger structure for table `external_persons` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_update_external_person_ut_user_type` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_update_external_person_ut_user_type` AFTER UPDATE ON `external_persons` FOR EACH ROW 
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
				WHERE `person_id` = @person_id_up_2
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
			END IF;

		# We check if we just need to update this record

			SET @record_in_table = (SELECT `id_map` 
				FROM `ut_map_external_source_users`
				WHERE `external_person_id` = @external_id
					AND `external_system` = @external_system
					AND `table_in_external_system` = @external_table
					AND `organization_id` = @organization_id_update
				)
				;

			SET @requestor_id := @updated_by_id ;

			SET @person_id := (SELECT `id_person` 
				FROM `persons`
				WHERE `external_id` = @external_id
					AND `external_system` = @external_system
					AND `external_table` = @external_table
					AND `organization_id` = @organization_id_update
				)
				;

			IF @is_unee_t_account_needed = 1
				AND @record_in_table IS NOT NULL
				AND @new_is_unee_t_account_needed_up_2 = @old_is_unee_t_account_needed_up_2
				AND @email IS NOT NULL
			THEN 

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

			# We call the procedure to check and assign all properties to this user if needed
			# This procedure needs the following variables:
			#	- @requestor_id : the MEFE user Id for the generic user for the organization
			#	- @person_id : Id for the person we are updating.
			#
			# The procedure will check if the new user_type for this user 
			# grants access to all the units in the organization
			# if this is true then we will assign this user to all the units in the organization

				CALL `ut_assign_user_to_all_unit_in_organization` ;

			END IF;

	END IF;
END */$$


DELIMITER ;

/* Trigger structure for table `external_property_groups_areas` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_insert_external_area` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_insert_external_area` AFTER INSERT ON `external_property_groups_areas` FOR EACH ROW 
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

	SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator = NEW.`created_by_id` ;
	SET @source_system_updater = NEW.`updated_by_id`;

	SET @creator_mefe_user_id = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator
		)
		;

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;

	SET @external_id = NEW.`external_id` ;
	SET @external_system_id = NEW.`external_system_id` ; 
	SET @external_table = NEW.`external_table` ;

	IF @is_creation_needed_in_unee_t = 1
		AND @external_id IS NOT NULL
		AND @external_system_id IS NOT NULL
		AND @external_table IS NOT NULL
		AND (@upstream_create_method = 'imported_from_hmlet_ipi'
			OR @upstream_create_method = 'Manage_Areas_Add_Page'
			OR @upstream_create_method = 'Manage_Areas_Edit_Page'
			OR @upstream_create_method = 'Manage_Areas_Import_Page'
			OR @upstream_create_method = 'Export_and_Import_Areas_Import_Page'
			OR @upstream_update_method = 'imported_from_hmlet_ipi'
			OR @upstream_update_method = 'Manage_Areas_Add_Page'
			OR @upstream_update_method = 'Manage_Areas_Edit_Page'
			OR @upstream_update_method = 'Manage_Areas_Import_Page'
			OR @upstream_update_method = 'Export_and_Import_Areas_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `property_groups_areas` table:

		SET @this_trigger = 'ut_insert_external_area' ;

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

		SET @organization_id_create = @source_system_creator ;
		SET @organization_id_update = @source_system_updater;

		SET @country_code = NEW.`country_code` ;
		SET @is_obsolete = NEW.`is_obsolete` ;
		SET @is_default = NEW.`is_default` ;
		SET @order = NEW.`order` ;
		SET @area_name = NEW.`area_name` ;
		SET @area_definition = NEW.`area_definition` ;

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
					(@external_id
					, @external_system_id
					, @external_table
					, @syst_created_datetime
					, @creation_system_id
					, @created_by_id
					, @downstream_creation_method
					, @organization_id_create
					, @country_code
					, @is_obsolete
					, @is_default
					, @order
					, @area_name
					, @area_definition
					)
				ON DUPLICATE KEY UPDATE
					`syst_updated_datetime` = @syst_updated_datetime
					, `update_system_id` = @update_system_id
					, `updated_by_id` = @updated_by_id
					, `update_method` = @downstream_update_method
					, `country_code` = @country_code
					, `is_obsolete` = @is_obsolete
					, `is_default` = @is_default
					, `order` = @order
					, `area_definition` = @area_definition
					, `area_name` = @area_name
				;

	END IF;

END */$$


DELIMITER ;

/* Trigger structure for table `external_property_groups_areas` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_update_external_area` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_update_external_area` AFTER UPDATE ON `external_property_groups_areas` FOR EACH ROW 
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

	SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator = NEW.`created_by_id` ;
	SET @source_system_updater = NEW.`updated_by_id`;

	SET @creator_mefe_user_id = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator
		)
		;

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;
	
	SET @organization_id = @source_system_creator ;

	SET @external_id = NEW.`external_id` ;
	SET @external_system_id = NEW.`external_system_id` ; 
	SET @external_table = NEW.`external_table` ;

	SET @new_is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;
	SET @old_is_creation_needed_in_unee_t = OLD.`is_creation_needed_in_unee_t` ;

	IF @is_creation_needed_in_unee_t = 1
		AND @new_is_creation_needed_in_unee_t = @old_is_creation_needed_in_unee_t
		AND @external_id IS NOT NULL
		AND @external_system_id IS NOT NULL
		AND @external_table IS NOT NULL
		AND @organization_id IS NOT NULL
		AND (@upstream_update_method = 'imported_from_hmlet_ipi'
			OR @upstream_update_method = 'Manage_Areas_Add_Page'
			OR @upstream_update_method = 'Manage_Areas_Edit_Page'
			OR @upstream_update_method = 'Manage_Areas_Import_Page'
			OR @upstream_update_method = 'Export_and_Import_Areas_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `property_groups_areas` table:

		SET @this_trigger = 'ut_update_external_area' ;

		SET @record_to_update = (SELECT `id_area`
			FROM `property_groups_areas`
			WHERE `external_id` = @external_id
				AND `external_system_id` = @external_system_id
				AND `external_table` = @external_table
				AND `organization_id` = @organization_id
			);

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
		SET @organization_id_update = @source_system_updater;

		SET @country_code = NEW.`country_code` ;
		SET @is_obsolete = NEW.`is_obsolete` ;
		SET @is_default = NEW.`is_default` ;
		SET @order = NEW.`order` ;
		SET @area_name = NEW.`area_name` ;
		SET @area_definition = NEW.`area_definition` ;

	# We update the record in the table `property_groups_areas`
	
		UPDATE `property_groups_areas`
		SET
			`syst_updated_datetime` = @syst_updated_datetime
			, `update_system_id` = @update_system_id
			, `updated_by_id` = @updated_by_id
			, `update_method` = @downstream_update_method
			, `country_code` = @country_code
			, `is_obsolete` = @is_obsolete
			, `is_default` = @is_default
			, `order` = @order
			, `area_definition` = @area_definition
			, `area_name` = @area_name
			WHERE `id_area` = @record_to_update
			;

	END IF;

END */$$


DELIMITER ;

/* Trigger structure for table `external_property_groups_areas` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_created_external_area_after_insert` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_created_external_area_after_insert` AFTER UPDATE ON `external_property_groups_areas` FOR EACH ROW 
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

	SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator = NEW.`created_by_id` ;
	SET @source_system_updater = NEW.`updated_by_id`;

	SET @creator_mefe_user_id = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator
		)
		;

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;
	
	SET @organization_id = @source_system_creator ;

	SET @external_id = NEW.`external_id` ;
	SET @external_system_id = NEW.`external_system_id` ; 
	SET @external_table = NEW.`external_table` ;

	SET @new_is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;
	SET @old_is_creation_needed_in_unee_t = OLD.`is_creation_needed_in_unee_t` ;

	IF @is_creation_needed_in_unee_t = 1
		AND @new_is_creation_needed_in_unee_t != @old_is_creation_needed_in_unee_t
		AND @external_id IS NOT NULL
		AND @external_system_id IS NOT NULL
		AND @external_table IS NOT NULL
		AND @organization_id IS NOT NULL
		AND (@upstream_update_method = 'imported_from_hmlet_ipi'
			OR @upstream_update_method = 'Manage_Areas_Add_Page'
			OR @upstream_update_method = 'Manage_Areas_Edit_Page'
			OR @upstream_update_method = 'Manage_Areas_Import_Page'
			OR @upstream_update_method = 'Export_and_Import_Areas_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `property_groups_areas` table:

		SET @this_trigger = 'ut_created_external_area_after_insert' ;

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
		SET @organization_id_update = @source_system_updater;

		SET @country_code = NEW.`country_code` ;
		SET @is_obsolete = NEW.`is_obsolete` ;
		SET @is_default = NEW.`is_default` ;
		SET @order = NEW.`order` ;
		SET @area_name = NEW.`area_name` ;
		SET @area_definition = NEW.`area_definition` ;

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
					(@external_id
					, @external_system_id
					, @external_table
					, @syst_created_datetime
					, @creation_system_id
					, @created_by_id
					, @downstream_creation_method
					, @is_creation_needed_in_unee_t
					, @organization_id_create
					, @country_code
					, @is_obsolete
					, @is_default
					, @order
					, @area_name
					, @area_definition
					)
				ON DUPLICATE KEY UPDATE
					`syst_updated_datetime` = @syst_updated_datetime
					, `update_system_id` = @update_system_id
					, `updated_by_id` = @updated_by_id
					, `update_method` = @downstream_update_method
					, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t
					, `organization_id` = @organization_id_update
					, `country_code` = @country_code
					, `is_obsolete` = @is_obsolete
					, `is_default` = @is_default
					, `order` = @order
					, `area_definition` = @area_definition
					, `area_name` = @area_name

				;

	END IF;

END */$$


DELIMITER ;

/* Trigger structure for table `external_property_level_1_buildings` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_insert_external_property_level_1` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_insert_external_property_level_1` AFTER INSERT ON `external_property_level_1_buildings` FOR EACH ROW 
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

	SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator = NEW.`created_by_id` ;
	SET @source_system_updater = (IF(NEW.`updated_by_id` IS NULL
			, @source_system_creator
			, NEW.`updated_by_id`
			)
		);

	SET @creator_mefe_user_id = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator
		)
		;

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;
	
	SET @organization_id = @source_system_creator ;

	SET @external_id = NEW.`external_id` ;
	SET @external_system_id = NEW.`external_system_id` ; 
	SET @external_table = NEW.`external_table` ;
	SET @tower = NEW.`tower` ;

	SET @id_in_property_level_1_buildings = (SELECT `id_building`
		FROM `property_level_1_buildings`
		WHERE `external_system_id` = @external_system_id
			AND `external_table` = @external_table
			AND `external_id` = @external_id
			AND `organization_id` = @organization_id
			AND `tower` = @tower
		);

	SET @upstream_do_not_insert = NEW.`do_not_insert` ;

	# This is an INSERT - the record should NOT exist already

		SET @do_not_insert = (IF (@id_in_property_level_1_buildings IS NULL
				, 0
				, @upstream_do_not_insert
				)
			);

	# Get the information about the area for that building...
	# We need the information from the table `property_groups_areas` (and NOT the table `external_property_groups_areas`)
	
		SET @area_id_in_table_external_property_level_1_buildings = NEW.`area_id` ;

		SET @area_external_id = (SELECT `external_id`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_in_table_external_property_level_1_buildings
			);
		SET @area_external_system_id = (SELECT `external_system_id`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_in_table_external_property_level_1_buildings
			);
		SET @area_external_table = (SELECT `external_table`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_in_table_external_property_level_1_buildings
			);

		SET @area_id = (SELECT `id_area`
			FROM `property_groups_areas`
			WHERE `external_id` = @area_external_id
				AND `external_system_id` = @area_external_system_id
			   	AND `external_table` = @area_external_table
			   	AND `organization_id` = @organization_id
			);

	IF @is_creation_needed_in_unee_t = 1
		AND @do_not_insert = 0
		AND @external_id IS NOT NULL
		AND @external_system_id IS NOT NULL
		AND @external_table IS NOT NULL
		AND @tower IS NOT NULL
		AND @organization_id IS NOT NULL
		AND @area_id IS NOT NULL
		AND 
		(@upstream_create_method = 'imported_from_hmlet_ipi'
			OR @upstream_create_method = 'Manage_Buildings_Add_Page'
			OR @upstream_create_method = 'Manage_Buildings_Edit_Page'
			OR @upstream_create_method = 'Manage_Buildings_Import_Page'
			OR @upstream_create_method = 'Export_and_Import_Buildings_Import_Page'
			OR @upstream_update_method = 'imported_from_hmlet_ipi'
			OR @upstream_update_method = 'Manage_Buildings_Add_Page'
			OR @upstream_update_method = 'Manage_Buildings_Edit_Page'
			OR @upstream_update_method = 'Manage_Buildings_Import_Page'
			OR @upstream_update_method = 'Export_and_Import_Buildings_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `property_level_1_buildings` table:

		SET @this_trigger = 'ut_insert_external_property_level_1' ;

		SET @syst_created_datetime = NOW();
		SET @creation_system_id = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator
			)
			;
		SET @created_by_id = @creator_mefe_user_id ;
		SET @downstream_creation_method = @this_trigger ;

		SET @syst_updated_datetime = NOW();

		SET @update_system_id = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater
			)
			;
		SET @updated_by_id = @creator_mefe_user_id ;
		SET @downstream_update_method = @this_trigger ;

		SET @organization_id_create = @source_system_creator ;
		SET @organization_id_update = @source_system_updater;

		SET @is_obsolete = NEW.`is_obsolete` ;
		SET @order = NEW.`order` ;

		SET @unee_t_unit_type = NEW.`unee_t_unit_type` ;
		SET @designation = NEW.`designation` ;

		SET @address_1 = NEW.`address_1` ;
		SET @address_2 = NEW.`address_2` ;
		SET @zip_postal_code = NEW.`zip_postal_code` ;
		SET @state = NEW.`state` ;
		SET @city = NEW.`city` ;
		SET @country_code = NEW.`country_code` ;

		SET @description = NEW.`description` ;

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
				(@external_id
				, @external_system_id
				, @external_table
				, @syst_created_datetime
				, @creation_system_id
				, @created_by_id
				, @downstream_creation_method
				, @organization_id_create
				, @is_obsolete
				, @order
				, @area_id
				, @is_creation_needed_in_unee_t
				, @do_not_insert
				, @unee_t_unit_type
				, @designation
				, @tower
				, @address_1
				, @address_2
				, @zip_postal_code
				, @state
				, @city
				, @country_code
				, @description
				)
			ON DUPLICATE KEY UPDATE
				`syst_updated_datetime` = @syst_updated_datetime
				, `update_system_id` = @update_system_id
				, `updated_by_id` = @updated_by_id
				, `update_method` = @downstream_update_method
				, `organization_id` = @organization_id_update
				, `is_obsolete` = @is_obsolete
				, `order` = @order
				, `area_id` = @area_id
				, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t
				, `do_not_insert` = @do_not_insert
				, `unee_t_unit_type` = @unee_t_unit_type
				, `designation` = @designation
				, `tower` = @tower
				, `address_1` = @address_1
				, `address_2` = @address_2
				, `zip_postal_code` = @zip_postal_code
				, `state` = @state
				, `city` = @city
				, `country_code` = @country_code
				, `description` = @description
			;

	END IF;

# Housekeeping - we make sure that if a building is obsolete - all units in that building are obsolete too

	SET @building_system_id = NEW.`id_building` ;

		UPDATE `external_property_level_2_units` AS `a`
			INNER JOIN `external_property_level_1_buildings` AS `b`
				ON (`a`.`building_system_id` = `b`.`id_building`)
			SET `a`.`is_obsolete` = `b`.`is_obsolete`
			WHERE `a`.`building_system_id` = @building_system_id
			;

END */$$


DELIMITER ;

/* Trigger structure for table `external_property_level_1_buildings` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_update_external_property_level_1` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_update_external_property_level_1` AFTER UPDATE ON `external_property_level_1_buildings` FOR EACH ROW 
BEGIN

# We only do this if 
#	- we need to create the property in Unee-T
#	- We have a `external_id`
#	- We have a `external_system_id`
#	- We have a `external_table`
#	- We have a `organization_id`
#	- We have a `tower`
#	- We have a MEFE user ID for the user who did the update
#	- The unit was already marked as needed to be created in Unee-T
#	- The `do_not_insert_field` is NOT equal to 1
#	- The unit already exist in the table `property_level_1_buildings`
#	- This is a valid update method:
#		- 'imported_from_hmlet_ipi'
#		- 'Manage_Buildings_Add_Page'
#		- 'Manage_Buildings_Edit_Page'
#		- 'Manage_Buildings_Import_Page'
#		- 'Export_and_Import_Buildings_Import_Page'
#		- ''

	SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator = NEW.`created_by_id` ;
	SET @source_system_updater = (IF(NEW.`updated_by_id` IS NULL
			, @source_system_creator
			, NEW.`updated_by_id`
			)
		);

	SET @creator_mefe_user_id = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator
		)
		;

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;

	SET @organization_id = @source_system_creator ;

	SET @external_id = NEW.`external_id` ;
	SET @external_system_id = NEW.`external_system_id` ; 
	SET @external_table = NEW.`external_table` ;
	SET @tower = NEW.`tower` ;

	SET @new_is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;
	SET @old_is_creation_needed_in_unee_t = OLD.`is_creation_needed_in_unee_t` ;

	SET @id_in_property_level_1_buildings = (SELECT `id_building`
		FROM `property_level_1_buildings`
		WHERE `external_system_id` = @external_system_id
			AND `external_table` = @external_table
			AND `external_id` = @external_id
			AND `organization_id` = @organization_id
			AND `tower` = @tower
		);

	SET @upstream_do_not_insert = NEW.`do_not_insert` ;

	# This is an UPDATE - the record SHOULD exist already
		SET @do_not_insert = (IF (@id_in_property_level_1_buildings IS NULL
				, 1
				, @upstream_do_not_insert
				)
			);

	# Get the information about the area for that building...
	# We need the information from the table `property_groups_areas` (and NOT the table `external_property_groups_areas`)
	
		SET @area_id_in_table_external_property_level_1_buildings = NEW.`area_id` ;

		SET @area_external_id = (SELECT `external_id`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_in_table_external_property_level_1_buildings
			);
		SET @area_external_system_id = (SELECT `external_system_id`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_in_table_external_property_level_1_buildings
			);
		SET @area_external_table = (SELECT `external_table`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_in_table_external_property_level_1_buildings
			);

		SET @area_id = (SELECT `id_area`
			FROM `property_groups_areas`
			WHERE `external_id` = @area_external_id
				AND `external_system_id` = @area_external_system_id
			   	AND `external_table` = @area_external_table
			   	AND `organization_id` = @organization_id
			);

	IF @is_creation_needed_in_unee_t = 1
		AND @new_is_creation_needed_in_unee_t = @old_is_creation_needed_in_unee_t
		AND @do_not_insert = 0
		AND @external_id IS NOT NULL
		AND @external_system_id IS NOT NULL
		AND @external_table IS NOT NULL
		AND @tower IS NOT NULL
		AND @organization_id IS NOT NULL
		AND @area_id IS NOT NULL
		AND (@upstream_create_method = 'imported_from_hmlet_ipi'
			OR @upstream_update_method = 'imported_from_hmlet_ipi'
			OR @upstream_create_method = 'Manage_Buildings_Add_Page'
			OR @upstream_update_method = 'Manage_Buildings_Add_Page'
			OR @upstream_create_method = 'Manage_Buildings_Edit_Page'
			OR @upstream_update_method = 'Manage_Buildings_Edit_Page'
			OR @upstream_create_method = 'Manage_Buildings_Import_Page'
			OR @upstream_update_method = 'Manage_Buildings_Import_Page'
			OR @upstream_create_method = 'Export_and_Import_Buildings_Import_Page'
			OR @upstream_update_method = 'Export_and_Import_Buildings_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `property_level_1_buildings` table:

		SET @this_trigger = 'ut_update_external_property_level_1';

		SET @syst_created_datetime = NOW();
		SET @creation_system_id = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator
			)
			;
		SET @created_by_id = @creator_mefe_user_id ;
		SET @downstream_creation_method = @this_trigger ;

		SET @syst_updated_datetime = NOW();

		SET @update_system_id = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater
			)
			;
		SET @updated_by_id = @creator_mefe_user_id ;
		SET @downstream_update_method = @this_trigger ;

		SET @organization_id_create = @source_system_creator;
		SET @organization_id_update = @source_system_updater;

		SET @is_obsolete = NEW.`is_obsolete` ;
		SET @order = NEW.`order` ;

		SET @unee_t_unit_type = NEW.`unee_t_unit_type` ;
		SET @designation = NEW.`designation` ;

		SET @address_1 = NEW.`address_1` ;
		SET @address_2 = NEW.`address_2` ;
		SET @zip_postal_code = NEW.`zip_postal_code` ;
		SET @state = NEW.`state` ;
		SET @city = NEW.`city` ;
		SET @country_code = NEW.`country_code` ;

		SET @description = NEW.`description` ;

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
				(@external_id
				, @external_system_id
				, @external_table
				, @syst_created_datetime
				, @creation_system_id
				, @created_by_id
				, @downstream_creation_method
				, @organization_id_create
				, @is_obsolete
				, @order
				, @area_id
				, @is_creation_needed_in_unee_t
				, @do_not_insert
				, @unee_t_unit_type
				, @designation
				, @tower
				, @address_1
				, @address_2
				, @zip_postal_code
				, @state
				, @city
				, @country_code
				, @description
				)
			ON DUPLICATE KEY UPDATE
				`syst_updated_datetime` = @syst_updated_datetime
				, `update_system_id` = @update_system_id
				, `updated_by_id` = @updated_by_id
				, `update_method` = @downstream_update_method
				, `organization_id` = @organization_id_update
				, `is_obsolete` = @is_obsolete
				, `order` = @order
				, `area_id` = @area_id
				, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t
				, `do_not_insert` = @do_not_insert
				, `unee_t_unit_type` = @unee_t_unit_type
				, `designation` = @designation
				, `tower` = @tower
				, `address_1` = @address_1
				, `address_2` = @address_2
				, `zip_postal_code` = @zip_postal_code
				, `state` = @state
				, `city` = @city
				, `country_code` = @country_code
				, `description` = @description
			;

	END IF;

# Housekeeping - we make sure that if a building is obsolete - all units in that building are obsolete too

	SET @building_system_id = NEW.`id_building` ;

		UPDATE `external_property_level_2_units` AS `a`
			INNER JOIN `external_property_level_1_buildings` AS `b`
				ON (`a`.`building_system_id` = `b`.`id_building`)
			SET `a`.`is_obsolete` = `b`.`is_obsolete`
			WHERE `a`.`building_system_id` = @building_system_id
			;

END */$$


DELIMITER ;

/* Trigger structure for table `external_property_level_1_buildings` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_update_external_property_level_1_creation_needed` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_update_external_property_level_1_creation_needed` AFTER UPDATE ON `external_property_level_1_buildings` FOR EACH ROW 
BEGIN

# We only do this if 
#	- we need to create the property in Unee-T
#	- We have a `external_id`
#	- We have a `external_system_id`
#	- We have a `external_table`
#	- We have a `organization_id`
#	- We have a `tower`
#	- We have a MEFE user ID for the user who did the update
#	- The unit was already marked as needed to be created in Unee-T
#	- The `do_not_insert_field` is NOT equal to 1
#	- The unit already exist in the table `property_level_1_buildings`
#	- This is a valid update method:
#		- 'imported_from_hmlet_ipi'
#		- 'Manage_Buildings_Add_Page'
#		- 'Manage_Buildings_Edit_Page'
#		- 'Manage_Buildings_Import_Page'
#		- 'Export_and_Import_Buildings_Import_Page'
#		- ''

	SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator = NEW.`created_by_id` ;
	SET @source_system_updater = (IF(NEW.`updated_by_id` IS NULL
			, @source_system_creator
			, NEW.`updated_by_id`
			)
		);

	SET @creator_mefe_user_id = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator
		)
		;

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;

	SET @organization_id = @source_system_creator ;

	SET @external_id = NEW.`external_id` ;
	SET @external_system_id = NEW.`external_system_id` ; 
	SET @external_table = NEW.`external_table` ;
	SET @tower = NEW.`tower` ;

	SET @new_is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;
	SET @old_is_creation_needed_in_unee_t = OLD.`is_creation_needed_in_unee_t` ;

	SET @id_in_property_level_1_buildings = (SELECT `id_building`
		FROM `property_level_1_buildings`
		WHERE `external_system_id` = @external_system_id
			AND `external_table` = @external_table
			AND `external_id` = @external_id
			AND `organization_id` = @organization_id
			AND `tower` = @tower
		);

	SET @upstream_do_not_insert = NEW.`do_not_insert` ;

	# This is an UPDATE - the record SHOULD exist already
	# BUT there are some edge cases when we need to re-create this...
		SET @do_not_insert = @upstream_do_not_insert ;

	# Get the information about the area for that building...
	# We need the information from the table `property_groups_areas` (and NOT the table `external_property_groups_areas`)
	
		SET @area_id_in_table_external_property_level_1_buildings = NEW.`area_id` ;

		SET @area_external_id = (SELECT `external_id`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_in_table_external_property_level_1_buildings
			);
		SET @area_external_system_id = (SELECT `external_system_id`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_in_table_external_property_level_1_buildings
			);
		SET @area_external_table = (SELECT `external_table`
			FROM `external_property_groups_areas`
			WHERE `id_area` = @area_id_in_table_external_property_level_1_buildings
			);

		SET @area_id = (SELECT `id_area`
			FROM `property_groups_areas`
			WHERE `external_id` = @area_external_id
				AND `external_system_id` = @area_external_system_id
			   	AND `external_table` = @area_external_table
			   	AND `organization_id` = @organization_id
			);

	IF @is_creation_needed_in_unee_t = 1
		AND @new_is_creation_needed_in_unee_t != @old_is_creation_needed_in_unee_t
		AND @do_not_insert = 0
		AND @external_id IS NOT NULL
		AND @external_system_id IS NOT NULL
		AND @external_table IS NOT NULL
		AND @tower IS NOT NULL
		AND @organization_id IS NOT NULL
		AND @area_id IS NOT NULL
		AND (@upstream_create_method = 'imported_from_hmlet_ipi'
			OR @upstream_update_method = 'imported_from_hmlet_ipi'
			OR @upstream_create_method = 'Manage_Buildings_Add_Page'
			OR @upstream_update_method = 'Manage_Buildings_Add_Page'
			OR @upstream_create_method = 'Manage_Buildings_Edit_Page'
			OR @upstream_update_method = 'Manage_Buildings_Edit_Page'
			OR @upstream_create_method = 'Manage_Buildings_Import_Page'
			OR @upstream_update_method = 'Manage_Buildings_Import_Page'
			OR @upstream_create_method = 'Export_and_Import_Buildings_Import_Page'
			OR @upstream_update_method = 'Export_and_Import_Buildings_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `property_level_1_buildings` table:

		SET @this_trigger = 'ut_update_external_property_level_1_creation_needed';

		SET @syst_created_datetime = NOW();
		SET @creation_system_id = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator
			)
			;
		SET @created_by_id = @creator_mefe_user_id ;
		SET @downstream_creation_method = @this_trigger ;

		SET @syst_updated_datetime = NOW();

		SET @update_system_id = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater
			)
			;
		SET @updated_by_id = @creator_mefe_user_id ;
		SET @downstream_update_method = @this_trigger ;

		SET @organization_id_create = @source_system_creator;
		SET @organization_id_update = @source_system_updater;

		SET @is_obsolete = NEW.`is_obsolete` ;
		SET @order = NEW.`order` ;

		SET @unee_t_unit_type = NEW.`unee_t_unit_type` ;
		SET @designation = NEW.`designation` ;

		SET @address_1 = NEW.`address_1` ;
		SET @address_2 = NEW.`address_2` ;
		SET @zip_postal_code = NEW.`zip_postal_code` ;
		SET @state = NEW.`state` ;
		SET @city = NEW.`city` ;
		SET @country_code = NEW.`country_code` ;

		SET @description = NEW.`description` ;

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
				(@external_id
				, @external_system_id
				, @external_table
				, @syst_created_datetime
				, @creation_system_id
				, @created_by_id
				, @downstream_creation_method
				, @organization_id_create
				, @is_obsolete
				, @order
				, @area_id
				, @is_creation_needed_in_unee_t
				, @do_not_insert
				, @unee_t_unit_type
				, @designation
				, @tower
				, @address_1
				, @address_2
				, @zip_postal_code
				, @state
				, @city
				, @country_code
				, @description
				)
			ON DUPLICATE KEY UPDATE
				`syst_updated_datetime` = @syst_updated_datetime
				, `update_system_id` = @update_system_id
				, `updated_by_id` = @updated_by_id
				, `update_method` = @downstream_update_method
				, `organization_id` = @organization_id_update
				, `is_obsolete` = @is_obsolete
				, `order` = @order
				, `area_id` = @area_id
				, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t
				, `do_not_insert` = @do_not_insert
				, `unee_t_unit_type` = @unee_t_unit_type
				, `designation` = @designation
				, `tower` = @tower
				, `address_1` = @address_1
				, `address_2` = @address_2
				, `zip_postal_code` = @zip_postal_code
				, `state` = @state
				, `city` = @city
				, `country_code` = @country_code
				, `description` = @description
			;

	END IF;

# Housekeeping - we make sure that if a building is obsolete - all units in that building are obsolete too

	SET @building_system_id = NEW.`id_building` ;

		UPDATE `external_property_level_2_units` AS `a`
			INNER JOIN `external_property_level_1_buildings` AS `b`
				ON (`a`.`building_system_id` = `b`.`id_building`)
			SET `a`.`is_obsolete` = `b`.`is_obsolete`
			WHERE `a`.`building_system_id` = @building_system_id
			;

END */$$


DELIMITER ;

/* Trigger structure for table `external_property_level_2_units` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_insert_external_property_level_2` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_insert_external_property_level_2` AFTER INSERT ON `external_property_level_2_units` FOR EACH ROW 
BEGIN

# We only do this if 
#	- We need to create the unit in Unee-T
#	- We have a `external_id`
#	- We have a `external_system_id`
#	- We have a `external_table`
#	- We have a `organization_id`
#	- We have a MEFE user ID for the user who did the update
#	- The unit does NOT exists in the table `property_level_2_units`
#   - we have a valid building ID for this unit.
#	- This is a valid insert method:
#		- 'imported_from_hmlet_ipi'
#		- 'Manage_Units_Add_Page'
#		- 'Manage_Units_Edit_Page'
#		- 'Manage_Units_Import_Page'
#		- 'Export_and_Import_Units_Import_Page'
#		- ''

	SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator = NEW.`created_by_id` ;
	SET @source_system_updater = (IF(NEW.`updated_by_id` IS NULL
			, @source_system_creator
			, NEW.`updated_by_id`
			)
		);

	SET @creator_mefe_user_id = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator
		)
		;

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;

	SET @external_system_id = NEW.`external_system_id` ;
	SET @external_table = NEW.`external_table` ;
	SET @external_id = NEW.`external_id` ;

	SET @organization_id = @source_system_creator ;

	SET @id_in_property_level_2_units = (SELECT `system_id_unit`
		FROM `property_level_2_units`
		WHERE `external_system_id` = @external_system_id
			AND `external_table` = @external_table
			AND `external_id` = @external_id
			AND `organization_id` = @organization_id
		);
		
	SET @upstream_do_not_insert = NEW.`do_not_insert` ;

	# This is an INSERT - the record should NOT exist already

		SET @do_not_insert = (IF (@id_in_property_level_2_units IS NULL
				, 0
				, @upstream_do_not_insert
				)
			
			);

	# Get the information about the building for that unit...
	# We need the information from the table `external_property_level_2_units` (and NOT the table `external_external_property_level_1_buildings`)
	
		SET @building_id_in_table_external_property_level_2_units = NEW.`building_system_id` ;

		SET @tower = NEW.`tower` ;

		SET @building_external_id = (SELECT `external_id`
			FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_in_table_external_property_level_2_units
				);
		SET @building_external_system_id = (SELECT `external_system_id`
			FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_in_table_external_property_level_2_units
			);
		SET @building_external_table = (SELECT `external_table`
		   FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_in_table_external_property_level_2_units
			);
		SET @building_external_tower = (SELECT `tower`
			FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_in_table_external_property_level_2_units
			);

		SET @building_system_id = (SELECT `id_building`
			FROM `property_level_1_buildings`
			WHERE `external_id` = @building_external_id
				AND `external_system_id` = @building_external_system_id
				AND `external_table` = @building_external_table
				AND `organization_id` = @organization_id
				AND `tower` = @building_external_tower
				);

	IF @is_creation_needed_in_unee_t = 1
		AND @do_not_insert = 0
		AND @external_id IS NOT NULL
		AND @external_system_id IS NOT NULL
		AND @external_table IS NOT NULL
		AND @organization_id IS NOT NULL
		AND @building_system_id IS NOT NULL
		AND (@upstream_create_method = 'imported_from_hmlet_ipi'
			OR @upstream_create_method = 'Manage_Units_Add_Page'
			OR @upstream_create_method = 'Manage_Units_Edit_Page'
			OR @upstream_create_method = 'Manage_Units_Import_Page'
			OR @upstream_update_method = 'imported_from_hmlet_ipi'
			OR @upstream_update_method = 'Manage_Units_Add_Page'
			OR @upstream_update_method = 'Manage_Units_Edit_Page'
			OR @upstream_create_method = 'Manage_Units_Import_Page'
			OR @upstream_update_method = 'Export_and_Import_Units_Import_Page'
			OR @upstream_create_method = 'Export_and_Import_Units_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `external_property_level_2_units` table:

		SET @this_trigger = 'ut_insert_external_property_level_2' ;

		SET @syst_created_datetime = NOW();
		SET @creation_system_id = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator
			)
			;
		SET @created_by_id = @creator_mefe_user_id ;
		SET @downstream_creation_method = @this_trigger ;

		SET @syst_updated_datetime = NOW();

		SET @update_system_id = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater
			)
			;
		SET @updated_by_id = @creator_mefe_user_id ;
		SET @downstream_update_method = @this_trigger ;

		SET @organization_id_create = @source_system_creator ;
		SET @organization_id_update = @source_system_updater;

		SET @activated_by_id = NEW.`activated_by_id` ;
		SET @is_obsolete = NEW.`is_obsolete` ;
		SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;
		SET @unee_t_unit_type = NEW.`unee_t_unit_type` ;
			
		SET @unit_category_id = NEW.`unit_category_id` ;
		SET @designation = NEW.`designation` ;
		SET @count_rooms = NEW.`count_rooms` ;
		SET @unit_id = NEW.`unit_id` ;
		SET @surface = NEW.`surface` ;
		SET @surface_measurment_unit = NEW.`surface_measurment_unit` ;
		SET @description = NEW.`description` ;

	# We insert the record in the table `property_level_2_units`
	# We do this via INSERT INTO ... ON DUPLICATE KEY UPDATE for maximum safety

		INSERT INTO `property_level_2_units`
			(`external_id`
			, `external_system_id` 
			, `external_table`
			, `syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `creation_method`
			, `organization_id`
			, `activated_by_id`
			, `is_obsolete`
			, `is_creation_needed_in_unee_t`
			, `do_not_insert`
			, `unee_t_unit_type`
			, `building_system_id`
			, `tower`
			, `unit_category_id`
			, `designation`
			, `count_rooms`
			, `unit_id`
			, `surface`
			, `surface_measurment_unit`
			, `description`
			)
			VALUES
 				(@external_id
				, @external_system_id 
				, @external_table
				, @syst_created_datetime
				, @creation_system_id
				, @created_by_id
				, @downstream_creation_method
				, @organization_id_create
				, @activated_by_id
				, @is_obsolete
				, @is_creation_needed_in_unee_t
				, @do_not_insert
				, @unee_t_unit_type
				, @building_system_id
				, @tower
				, @unit_category_id
				, @designation
				, @count_rooms
				, @unit_id
				, @surface
				, @surface_measurment_unit
				, @description
 			)
			ON DUPLICATE KEY UPDATE
 				`syst_updated_datetime` = @syst_updated_datetime
 				, `update_system_id` = @update_system_id
 				, `updated_by_id` = @updated_by_id
				, `update_method` = @downstream_update_method
				, `activated_by_id` = @activated_by_id
				, `organization_id` = @organization_id_update
				, `is_obsolete` = @is_obsolete
				, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t
				, `do_not_insert` = @do_not_insert
				, `unee_t_unit_type` = @unee_t_unit_type
				, `building_system_id` = @building_system_id
				, `tower` = @tower
				, `unit_category_id` = @unit_category_id
				, `designation` = @designation
				, `count_rooms` = @count_rooms
				, `unit_id` = @unit_id
				, `surface` = @surface
				, `surface_measurment_unit` = @surface_measurment_unit
				, `description` = @description
			;

	END IF;

# Housekeeping - we make sure that if a unit is obsolete - all rooms in that unit are obsolete too

	SET @system_id_unit = NEW.`system_id_unit` ;

	UPDATE `external_property_level_3_rooms` AS `a`
		INNER JOIN `external_property_level_2_units` AS `b`
			ON (`a`.`system_id_unit` = `b`.`system_id_unit`)
		SET `a`.`is_obsolete` = `b`.`is_obsolete`
		WHERE `a`.`system_id_unit` = @system_id_unit
		;

END */$$


DELIMITER ;

/* Trigger structure for table `external_property_level_2_units` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_update_external_property_level_2` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_update_external_property_level_2` AFTER UPDATE ON `external_property_level_2_units` FOR EACH ROW 
BEGIN

# We only do this if 
#	- we need to create the property in Unee-T
#	- We have a `external_id`
#	- We have a `external_system_id`
#	- We have a `external_table`
#	- We have a `organization_id`
#	- We have a `tower`
#	- We have a MEFE user ID for the user who did the update
#	- The unit was already marked as needed to be created in Unee-T
#	- The unit already exists in the table `property_level_2_units`
#	- We have a valid building_id for that unit.
#	- The `do_not_insert_field` is NOT equal to 1
#	- This is a valid update method:
#		- `imported_from_hmlet_ipi`
#		- `Manage_Units_Add_Page`
#		- `Manage_Units_Edit_Page`
#		- 'Manage_Units_Import_Page'
#		- 'Export_and_Import_Units_Import_Page'
#		- ''

	SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator = NEW.`created_by_id` ;
	SET @source_system_updater = (IF(NEW.`updated_by_id` IS NULL
			, @source_system_creator
			, NEW.`updated_by_id`
			)
		);

	SET @creator_mefe_user_id = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator
		)
		;

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;

	SET @organization_id = @source_system_creator ;

	SET @external_id = NEW.`external_id` ;
	SET @external_system_id = NEW.`external_system_id` ; 
	SET @external_table = NEW.`external_table` ;
	SET @tower = NEW.`tower` ;

	SET @new_is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;
	SET @old_is_creation_needed_in_unee_t = OLD.`is_creation_needed_in_unee_t` ;

	SET @id_in_property_level_2_units = (SELECT `system_id_unit`
		FROM `property_level_2_units`
		WHERE `external_system_id` = @external_system_id
			AND `external_table` = @external_table
			AND `external_id` = @external_id
			AND `organization_id` = @organization_id
		);

	SET @upstream_do_not_insert = NEW.`do_not_insert` ;

	# This is an UPDATE - the record SHOULD exist already

		SET @do_not_insert = (IF (@id_in_property_level_2_units IS NULL
				, 1
				, @upstream_do_not_insert
				)
			);

	# Get the information about the building for that unit...
	# We need the information from the table `external_property_level_2_units` (and NOT the table `external_external_property_level_1_buildings`)
	
		SET @building_id_in_table_external_property_level_2_units = NEW.`building_system_id` ;

		SET @tower = NEW.`tower` ;

		SET @building_external_id = (SELECT `external_id`
			FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_in_table_external_property_level_2_units
				);
		SET @building_external_system_id = (SELECT `external_system_id`
			FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_in_table_external_property_level_2_units
			);
		SET @building_external_table = (SELECT `external_table`
		   FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_in_table_external_property_level_2_units
			);
		SET @building_external_tower = (SELECT `tower`
			FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_in_table_external_property_level_2_units
			);

		SET @building_system_id = (SELECT `id_building`
			FROM `property_level_1_buildings`
			WHERE `external_id` = @building_external_id
				AND `external_system_id` = @building_external_system_id
				AND `external_table` = @building_external_table
				AND `organization_id` = @organization_id
				AND `tower` = @building_external_tower
				);

	IF @is_creation_needed_in_unee_t = 1
		AND @new_is_creation_needed_in_unee_t = @old_is_creation_needed_in_unee_t
		AND @do_not_insert = 0
		AND @external_id IS NOT NULL
		AND @external_system_id IS NOT NULL
		AND @external_table IS NOT NULL
		AND @tower IS NOT NULL
		AND @organization_id IS NOT NULL
		AND @building_system_id IS NOT NULL
		AND (@upstream_update_method = 'imported_from_hmlet_ipi'
			OR @upstream_update_method = 'Manage_Units_Add_Page'
			OR @upstream_update_method = 'Manage_Units_Edit_Page'
			OR @upstream_update_method = 'Manage_Units_Import_Page'
			OR @upstream_update_method = 'Export_and_Import_Units_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `external_property_level_2_units` table:

		SET @this_trigger = 'ut_update_external_property_level_2';

		SET @syst_created_datetime = NOW();
		SET @creation_system_id = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator
			)
			;
		SET @created_by_id = @creator_mefe_user_id ;
		SET @downstream_creation_method = @this_trigger ;

		SET @syst_updated_datetime = NOW();

		SET @update_system_id = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater
			)
			;
		SET @updated_by_id = @creator_mefe_user_id ;
		SET @downstream_update_method = @this_trigger ;

		SET @organization_id_create = @source_system_creator;
		SET @organization_id_update = @source_system_updater;

		SET @activated_by_id = NEW.`activated_by_id` ;
		SET @is_obsolete = NEW.`is_obsolete` ;
		SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;
		SET @unee_t_unit_type = NEW.`unee_t_unit_type` ;
			
		SET @unit_category_id = NEW.`unit_category_id` ;
		SET @designation = NEW.`designation` ;
		SET @count_rooms = NEW.`count_rooms` ;
		SET @unit_id = NEW.`unit_id` ;
		SET @surface = NEW.`surface` ;
		SET @surface_measurment_unit = NEW.`surface_measurment_unit` ;
		SET @description = NEW.`description` ;

	# We update the record in the table `external_property_level_2_units`
	# We do this via INSERT INTO ... ON DUPLICATE KEY UPDATE for maximum safety

		INSERT INTO `property_level_2_units`
			(`external_id`
			, `external_system_id` 
			, `external_table`
			, `syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `creation_method`
			, `organization_id`
			, `activated_by_id`
			, `is_obsolete`
			, `is_creation_needed_in_unee_t`
			, `do_not_insert`
			, `unee_t_unit_type`
			, `building_system_id`
			, `tower`
			, `unit_category_id`
			, `designation`
			, `count_rooms`
			, `unit_id`
			, `surface`
			, `surface_measurment_unit`
			, `description`
			)
			VALUES
 				(@external_id
				, @external_system_id 
				, @external_table
				, @syst_created_datetime
				, @creation_system_id
				, @created_by_id
				, @downstream_creation_method
				, @organization_id_create
				, @activated_by_id
				, @is_obsolete
				, @is_creation_needed_in_unee_t
				, @do_not_insert
				, @unee_t_unit_type
				, @building_system_id
				, @tower
				, @unit_category_id
				, @designation
				, @count_rooms
				, @unit_id
				, @surface
				, @surface_measurment_unit
				, @description
 			)
			ON DUPLICATE KEY UPDATE
 				`syst_updated_datetime` = @syst_updated_datetime
 				, `update_system_id` = @update_system_id
 				, `updated_by_id` = @updated_by_id
				, `update_method` = @downstream_update_method
				, `organization_id` = @organization_id_update
				, `activated_by_id` = @activated_by_id
				, `is_obsolete` = @is_obsolete
				, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t
				, `do_not_insert` = @do_not_insert
				, `unee_t_unit_type` = @unee_t_unit_type
				, `building_system_id` = @building_system_id
				, `tower` = @tower
				, `unit_category_id` = @unit_category_id
				, `designation` = @designation
				, `count_rooms` = @count_rooms
				, `unit_id` = @unit_id
				, `surface` = @surface
				, `surface_measurment_unit` = @surface_measurment_unit
				, `description` = @description
			;

	END IF;

# Housekeeping - we make sure that if a unit is obsolete - all rooms in that unit are obsolete too
# We only do that if the field `is_obsolete` is changed from 0 to 1

	SET @system_id_unit = NEW.`system_id_unit` ;

	UPDATE `external_property_level_3_rooms` AS `a`
		INNER JOIN `external_property_level_2_units` AS `b`
			ON (`a`.`system_id_unit` = `b`.`system_id_unit`)
		SET `a`.`is_obsolete` = `b`.`is_obsolete`
		WHERE `a`.`system_id_unit` = @system_id_unit
		;

END */$$


DELIMITER ;

/* Trigger structure for table `external_property_level_2_units` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_update_external_property_level_2_creation_needed` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_update_external_property_level_2_creation_needed` AFTER UPDATE ON `external_property_level_2_units` FOR EACH ROW 
BEGIN

# We only do this if 
#	- we need to create the property in Unee-T
#	- We have a `external_id`
#	- We have a `external_system_id`
#	- We have a `external_table`
#	- We have a `organization_id`
#	- We have a `tower`
#	- We have a MEFE user ID for the user who did the update
#	- The unit was already marked as needed to be created in Unee-T
#	- The unit already exists in the table `property_level_2_units`
#	- We have a valid building_id for that unit.
#	- The `do_not_insert_field` is NOT equal to 1
#	- This is a valid update method:
#		- `imported_from_hmlet_ipi`
#		- `Manage_Units_Add_Page`
#		- `Manage_Units_Edit_Page`
#		- 'Manage_Units_Import_Page'
#		- 'Export_and_Import_Units_Import_Page'
#		- ''

	SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator = NEW.`created_by_id` ;
	SET @source_system_updater = (IF(NEW.`updated_by_id` IS NULL
			, @source_system_creator
			, NEW.`updated_by_id`
			)
		);

	SET @creator_mefe_user_id = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator
		)
		;

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;

	SET @organization_id = @source_system_creator ;

	SET @external_id = NEW.`external_id` ;
	SET @external_system_id = NEW.`external_system_id` ; 
	SET @external_table = NEW.`external_table` ;
	SET @tower = NEW.`tower` ;

	SET @new_is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;
	SET @old_is_creation_needed_in_unee_t = OLD.`is_creation_needed_in_unee_t` ;

	SET @id_in_property_level_2_units = (SELECT `system_id_unit`
		FROM `property_level_2_units`
		WHERE `external_system_id` = @external_system_id
			AND `external_table` = @external_table
			AND `external_id` = @external_id
			AND `organization_id` = @organization_id
		);

	SET @upstream_do_not_insert = NEW.`do_not_insert` ;

	# This is an UPDATE - the record SHOULD exist already
	# BUT there are some edge cases when we need to re-create this...
		SET @do_not_insert = @upstream_do_not_insert ;

	# Get the information about the building for that unit...
	# We need the information from the table `external_property_level_2_units` (and NOT the table `external_external_property_level_1_buildings`)
	
		SET @building_id_in_table_external_property_level_2_units = NEW.`building_system_id` ;

		SET @tower = NEW.`tower` ;

		SET @building_external_id = (SELECT `external_id`
			FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_in_table_external_property_level_2_units
				);
		SET @building_external_system_id = (SELECT `external_system_id`
			FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_in_table_external_property_level_2_units
			);
		SET @building_external_table = (SELECT `external_table`
		   FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_in_table_external_property_level_2_units
			);
		SET @building_external_tower = (SELECT `tower`
			FROM `external_property_level_1_buildings`
			WHERE `id_building` = @building_id_in_table_external_property_level_2_units
			);

		SET @building_system_id = (SELECT `id_building`
			FROM `property_level_1_buildings`
			WHERE `external_id` = @building_external_id
				AND `external_system_id` = @building_external_system_id
				AND `external_table` = @building_external_table
				AND `organization_id` = @organization_id
				AND `tower` = @building_external_tower
				);

	IF @is_creation_needed_in_unee_t = 1
		AND @new_is_creation_needed_in_unee_t != @old_is_creation_needed_in_unee_t
		AND @do_not_insert = 0
		AND @external_id IS NOT NULL
		AND @external_system_id IS NOT NULL
		AND @external_table IS NOT NULL
		AND @tower IS NOT NULL
		AND @organization_id IS NOT NULL
		AND @building_system_id IS NOT NULL
		AND (@upstream_update_method = 'imported_from_hmlet_ipi'
			OR @upstream_update_method = 'Manage_Units_Add_Page'
			OR @upstream_update_method = 'Manage_Units_Edit_Page'
			OR @upstream_update_method = 'Manage_Units_Import_Page'
			OR @upstream_update_method = 'Export_and_Import_Units_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `external_property_level_2_units` table:

		SET @this_trigger = 'ut_update_external_property_level_2_creation_needed';

		SET @syst_created_datetime = NOW();
		SET @creation_system_id = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator
			)
			;
		SET @created_by_id = @creator_mefe_user_id ;
		SET @downstream_creation_method = @this_trigger ;

		SET @syst_updated_datetime = NOW();

		SET @update_system_id = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater
			)
			;
		SET @updated_by_id = @creator_mefe_user_id ;
		SET @downstream_update_method = @this_trigger ;

		SET @organization_id_create = @source_system_creator;
		SET @organization_id_update = @source_system_updater;

		SET @activated_by_id = NEW.`activated_by_id` ;
		SET @is_obsolete = NEW.`is_obsolete` ;
		SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;
		SET @unee_t_unit_type = NEW.`unee_t_unit_type` ;
			
		SET @unit_category_id = NEW.`unit_category_id` ;
		SET @designation = NEW.`designation` ;
		SET @count_rooms = NEW.`count_rooms` ;
		SET @unit_id = NEW.`unit_id` ;
		SET @surface = NEW.`surface` ;
		SET @surface_measurment_unit = NEW.`surface_measurment_unit` ;
		SET @description = NEW.`description` ;

	# We update the record in the table `external_property_level_2_units`
	# We do this via INSERT INTO ... ON DUPLICATE KEY UPDATE for maximum safety

		INSERT INTO `property_level_2_units`
			(`external_id`
			, `external_system_id` 
			, `external_table`
			, `syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `creation_method`
			, `organization_id`
			, `activated_by_id`
			, `is_obsolete`
			, `is_creation_needed_in_unee_t`
			, `do_not_insert`
			, `unee_t_unit_type`
			, `building_system_id`
			, `tower`
			, `unit_category_id`
			, `designation`
			, `count_rooms`
			, `unit_id`
			, `surface`
			, `surface_measurment_unit`
			, `description`
			)
			VALUES
 				(@external_id
				, @external_system_id 
				, @external_table
				, @syst_created_datetime
				, @creation_system_id
				, @created_by_id
				, @downstream_creation_method
				, @organization_id_create
				, @activated_by_id
				, @is_obsolete
				, @is_creation_needed_in_unee_t
				, @do_not_insert
				, @unee_t_unit_type
				, @building_system_id
				, @tower
				, @unit_category_id
				, @designation
				, @count_rooms
				, @unit_id
				, @surface
				, @surface_measurment_unit
				, @description
 			)
			ON DUPLICATE KEY UPDATE
 				`syst_updated_datetime` = @syst_updated_datetime
 				, `update_system_id` = @update_system_id
 				, `updated_by_id` = @updated_by_id
				, `update_method` = @downstream_update_method
				, `organization_id` = @organization_id_update
				, `activated_by_id` = @activated_by_id
				, `is_obsolete` = @is_obsolete
				, `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t
				, `do_not_insert` = @do_not_insert
				, `unee_t_unit_type` = @unee_t_unit_type
				, `building_system_id` = @building_system_id
				, `tower` = @tower
				, `unit_category_id` = @unit_category_id
				, `designation` = @designation
				, `count_rooms` = @count_rooms
				, `unit_id` = @unit_id
				, `surface` = @surface
				, `surface_measurment_unit` = @surface_measurment_unit
				, `description` = @description
			;

	END IF;

# Housekeeping - we make sure that if a unit is obsolete - all rooms in that unit are obsolete too
# We only do that if the field `is_obsolete` is changed from 0 to 1

	SET @system_id_unit = NEW.`system_id_unit` ;

	UPDATE `external_property_level_3_rooms` AS `a`
		INNER JOIN `external_property_level_2_units` AS `b`
			ON (`a`.`system_id_unit` = `b`.`system_id_unit`)
		SET `a`.`is_obsolete` = `b`.`is_obsolete`
		WHERE `a`.`system_id_unit` = @system_id_unit
		;

END */$$


DELIMITER ;

/* Trigger structure for table `external_property_level_3_rooms` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_insert_external_property_level_3` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_insert_external_property_level_3` AFTER INSERT ON `external_property_level_3_rooms` FOR EACH ROW 
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

	SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator = NEW.`created_by_id` ;
	SET @source_system_updater = (IF(NEW.`updated_by_id` IS NULL
			, @source_system_creator
			, NEW.`updated_by_id`
			)
		);

	SET @creator_mefe_user_id = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator
		)
		;

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;

	SET @organization_id = @source_system_creator ;

	SET @external_id = NEW.`external_id` ;
	SET @external_system_id = NEW.`external_system_id` ;
	SET @external_table = NEW.`external_table` ;

	SET @id_in_property_level_3_rooms = (SELECT `system_id_room`
		FROM `property_level_3_rooms`
		WHERE `external_system_id` = @external_system_id
			AND `external_table` = @external_table
			AND `external_id` = @external_id
			AND `organization_id` = @organization_id
		);
		
	SET @upstream_do_not_insert = NEW.`do_not_insert` ;

	# This is an INSERT - the record should NOT exist already

		SET @do_not_insert = (IF (@id_in_property_level_3_rooms IS NULL
				, 0
				, @upstream_do_not_insert
				)
			
			);

	# Get the information about the unit for that room...
	# We need the information from the table `external_property_level_2_units` (and NOT the table `external_property_level_2_units`)
	
		SET @unit_id_in_table_external_property_level_3_rooms = NEW.`system_id_unit` ;

        SET @unit_external_id = (SELECT `external_id`
			FROM `external_property_level_2_units`
			WHERE `system_id_unit` = @unit_id_in_table_external_property_level_3_rooms
			    );
		SET @unit_external_system_id = (SELECT `external_system_id`
		    FROM `external_property_level_2_units`
		    WHERE `system_id_unit` = @unit_id_in_table_external_property_level_3_rooms
		    );
		SET @unit_external_table = (SELECT `external_table`
		   FROM `external_property_level_2_units`
		    WHERE `system_id_unit` = @unit_id_in_table_external_property_level_3_rooms
		    );

		SET @system_id_unit = (SELECT `system_id_unit`
			FROM `property_level_2_units`
			WHERE `external_id` = @unit_external_id
		    	AND `external_system_id` = @unit_external_system_id
		    	AND `external_table` = @unit_external_table
		    	AND `organization_id` = @organization_id
			    );

	IF @is_creation_needed_in_unee_t = 1
		AND @do_not_insert = 0
		AND @external_id IS NOT NULL
		AND @external_system_id IS NOT NULL
		AND @external_table IS NOT NULL
		AND @organization_id IS NOT NULL
        AND @system_id_unit IS NOT NULL
		AND (@upstream_create_method = 'imported_from_hmlet_ipi'
			OR @upstream_update_method = 'imported_from_hmlet_ipi'
			OR @upstream_create_method = 'Manage_Rooms_Add_Page'
			OR @upstream_update_method = 'Manage_Rooms_Add_Page'
			OR @upstream_create_method = 'Manage_Rooms_Edit_Page'
			OR @upstream_update_method = 'Manage_Rooms_Edit_Page'
			OR @upstream_create_method = 'Manage_Rooms_Import_Page'
			OR @upstream_update_method = 'Manage_Rooms_Import_Page'
			OR @upstream_create_method = 'Export_and_Import_Rooms_Import_Page'
			OR @upstream_update_method = 'Export_and_Import_Rooms_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `external_property_level_2_units` table:

		SET @this_trigger = 'ut_insert_external_property_level_3' ;

		SET @syst_created_datetime = NOW();
		SET @creation_system_id = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator
			)
			;
		SET @created_by_id = @creator_mefe_user_id ;
		SET @downstream_creation_method = @this_trigger ;

		SET @syst_updated_datetime = NOW();

		SET @update_system_id = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater
			)
			;
		SET @updated_by_id = @creator_mefe_user_id ;
		SET @downstream_update_method = @this_trigger ;

	    SET @organization_id_create = @source_system_creator ;
		SET @organization_id_update = @source_system_updater;
        
		SET @is_obsolete = NEW.`is_obsolete` ;
        SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;

        SET @unee_t_unit_type = NEW.`unee_t_unit_type` ;
            
		SET @room_type_id = NEW.`room_type_id` ;
		SET @number_of_beds = NEW.`number_of_beds` ;
		SET @surface = NEW.`surface` ;
		SET @surface_measurment_unit = NEW.`surface_measurment_unit` ;
		SET @room_designation = NEW.`room_designation`;
		SET @room_description = NEW.`room_description` ;

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
 				(@external_id
        	    , @external_system_id 
        	    , @external_table
        	    , @syst_created_datetime
        	    , @creation_system_id
        	    , @created_by_id
        	    , @downstream_creation_method
        	    , @organization_id_create
        	    , @is_obsolete
        	    , @is_creation_needed_in_unee_t
        	    , @do_not_insert
        	    , @unee_t_unit_type
        	    , @system_id_unit
        	    , @room_type_id
        	    , @surface
        	    , @surface_measurment_unit
				, @room_designation
        	    , @room_description
 			)
        	ON DUPLICATE KEY UPDATE
 				`syst_updated_datetime` = @syst_updated_datetime
 				, `update_system_id` = @update_system_id
 				, `updated_by_id` = @updated_by_id
        		, `update_method` = @downstream_update_method
				, `organization_id` = @organization_id_update
        	    , `is_obsolete` = @is_obsolete
        	    , `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t
        	    , `do_not_insert` = @do_not_insert
        	    , `unee_t_unit_type` = @unee_t_unit_type
        	    , `system_id_unit` = @system_id_unit
        	    , `room_type_id` = @room_type_id
        	    , `surface` = @surface
        	    , `surface_measurment_unit` = @surface_measurment_unit
        	    , `room_designation` = @room_designation
				, `room_description` = @room_description
        	;

	END IF;

END */$$


DELIMITER ;

/* Trigger structure for table `external_property_level_3_rooms` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_update_external_property_level_3` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_update_external_property_level_3` AFTER UPDATE ON `external_property_level_3_rooms` FOR EACH ROW 
BEGIN

# We only do this if 
#	- we need to create the property in Unee-T
#	- We have a `external_id`
#	- We have a `external_system_id`
#	- We have a `external_table`
#	- We have a `organization_id`
#	- We have a MEFE user ID for the user who did the update
#	- The unit was already marked as needed to be created in Unee-T
#	- The unit already exists in the table `property_level_2_units`
#	- We have a valid building_id for that unit.
#	- The `do_not_insert_field` is NOT equal to 1
#	- This is a valid update method:
#		- `imported_from_hmlet_ipi`
#		- `Manage_Units_Add_Page`
#		- `Manage_Units_Edit_Page`
#		- 'Manage_Units_Import_Page'
#		- 'Export_and_Import_Rooms_Import_Page'
#		- ''

	SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator = NEW.`created_by_id` ;
	SET @source_system_updater = (IF(NEW.`updated_by_id` IS NULL
			, @source_system_creator
			, NEW.`updated_by_id`
			)
		);

	SET @creator_mefe_user_id = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator
		)
		;

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;

	SET @organization_id = @source_system_creator ;

	SET @external_id = NEW.`external_id` ;
	SET @external_system_id = NEW.`external_system_id` ; 
	SET @external_table = NEW.`external_table` ;

	SET @new_is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;
	SET @old_is_creation_needed_in_unee_t = OLD.`is_creation_needed_in_unee_t` ;

	SET @id_in_property_level_3_rooms = (SELECT `system_id_room`
		FROM `property_level_3_rooms`
		WHERE `external_system_id` = @external_system_id
			AND `external_table` = @external_table
			AND `external_id` = @external_id
			AND `organization_id` = @organization_id
		);

	SET @upstream_do_not_insert = NEW.`do_not_insert` ;

	# This is an UPDATE - the record SHOULD exist already

		SET @do_not_insert = @upstream_do_not_insert ;
		/*(IF (@id_in_property_level_3_rooms IS NULL
				, 1
				, @upstream_do_not_insert
				)
			);
		*/

	# Get the information about the unit for that room...
	# We need the information from the table `external_property_level_2_units` (and NOT the table `external_property_level_2_units`)
	
		SET @unit_id_in_table_external_property_level_3_rooms = NEW.`system_id_unit` ;

        SET @unit_external_id = (SELECT `external_id`
			FROM `external_property_level_2_units`
			WHERE `system_id_unit` = @unit_id_in_table_external_property_level_3_rooms
			    );
		SET @unit_external_system_id = (SELECT `external_system_id`
		    FROM `external_property_level_2_units`
		    WHERE `system_id_unit` = @unit_id_in_table_external_property_level_3_rooms
		    );
		SET @unit_external_table = (SELECT `external_table`
		   FROM `external_property_level_2_units`
		    WHERE `system_id_unit` = @unit_id_in_table_external_property_level_3_rooms
		    );

		SET @system_id_unit = (SELECT `system_id_unit`
			FROM `property_level_2_units`
			WHERE `external_id` = @unit_external_id
		    	AND `external_system_id` = @unit_external_system_id
		    	AND `external_table` = @unit_external_table
		    	AND `organization_id` = @organization_id
			    );

	IF @is_creation_needed_in_unee_t = 1
		AND @new_is_creation_needed_in_unee_t = @old_is_creation_needed_in_unee_t
		AND @do_not_insert = 0
		AND @external_id IS NOT NULL
		AND @external_system_id IS NOT NULL
		AND @external_table IS NOT NULL
		AND @organization_id IS NOT NULL
        AND @system_id_unit IS NOT NULL
		AND (@upstream_create_method = 'imported_from_hmlet_ipi'
			OR @upstream_update_method = 'imported_from_hmlet_ipi'
			OR @upstream_create_method = 'Manage_Rooms_Add_Page'
			OR @upstream_update_method = 'Manage_Rooms_Add_Page'
			OR @upstream_create_method = 'Manage_Rooms_Edit_Page'
			OR @upstream_update_method = 'Manage_Rooms_Edit_Page'
			OR @upstream_create_method = 'Manage_Rooms_Import_Page'
			OR @upstream_update_method = 'Manage_Rooms_Import_Page'
			OR @upstream_create_method = 'Export_and_Import_Rooms_Import_Page'
			OR @upstream_update_method = 'Export_and_Import_Rooms_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `external_property_level_2_units` table:

		SET @this_trigger = 'ut_update_external_property_level_3';

		SET @syst_created_datetime = NOW();
		SET @creation_system_id = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator
			)
			;
		SET @created_by_id = @creator_mefe_user_id ;
		SET @downstream_creation_method = @this_trigger ;

		SET @syst_updated_datetime = NOW();

		SET @update_system_id = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater
			)
			;
		SET @updated_by_id = @creator_mefe_user_id ;
		SET @downstream_update_method = @this_trigger ;

		SET @organization_id_create = @source_system_creator;
		SET @organization_id_update = @source_system_updater;

		SET @is_obsolete = NEW.`is_obsolete` ;
        SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;

        SET @unee_t_unit_type = NEW.`unee_t_unit_type` ;
            
		SET @room_type_id = NEW.`room_type_id` ;
		SET @number_of_beds = NEW.`number_of_beds` ;
		SET @surface = NEW.`surface` ;
		SET @surface_measurment_unit = NEW.`surface_measurment_unit` ;
		SET @room_designation = NEW.`room_designation`;
		SET @room_description = NEW.`room_description` ;

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
 				(@external_id
        	    , @external_system_id 
        	    , @external_table
        	    , @syst_created_datetime
        	    , @creation_system_id
        	    , @created_by_id
        	    , @downstream_creation_method
        	    , @organization_id_create
        	    , @is_obsolete
        	    , @is_creation_needed_in_unee_t
        	    , @do_not_insert
        	    , @unee_t_unit_type
        	    , @system_id_unit
        	    , @room_type_id
        	    , @surface
        	    , @surface_measurment_unit
				, @room_designation
        	    , @room_description
 			)
        	ON DUPLICATE KEY UPDATE
 				`syst_updated_datetime` = @syst_updated_datetime
 				, `update_system_id` = @update_system_id
 				, `updated_by_id` = @updated_by_id
        		, `update_method` = @downstream_update_method
				, `organization_id` = @organization_id_update
        	    , `is_obsolete` = @is_obsolete
        	    , `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t
        	    , `do_not_insert` = @do_not_insert
        	    , `unee_t_unit_type` = @unee_t_unit_type
        	    , `system_id_unit` = @system_id_unit
        	    , `room_type_id` = @room_type_id
        	    , `surface` = @surface
        	    , `surface_measurment_unit` = @surface_measurment_unit
        	    , `room_designation` = @room_designation
				, `room_description` = @room_description
        	;

	END IF;

END */$$


DELIMITER ;

/* Trigger structure for table `external_property_level_3_rooms` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_update_external_property_level_3_creation_needed` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_update_external_property_level_3_creation_needed` AFTER UPDATE ON `external_property_level_3_rooms` FOR EACH ROW 
BEGIN

# We only do this if 
#	- we need to create the property in Unee-T
#	- We have a `external_id`
#	- We have a `external_system_id`
#	- We have a `external_table`
#	- We have a `organization_id`
#	- We have a MEFE user ID for the user who did the update
#	- The unit was NOT already marked as needed to be created in Unee-T
#	- The unit for this room already exists in the table `property_level_2_units`
#	- The `do_not_insert_field` is NOT equal to 1
#	- This is a valid update method:
#		- `imported_from_hmlet_ipi`
#		- `Manage_Units_Add_Page`
#		- `Manage_Units_Edit_Page`
#		- 'Manage_Units_Import_Page'
#		- 'Export_and_Import_Rooms_Import_Page'
#		- ''

	SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;

	SET @source_system_creator = NEW.`created_by_id` ;
	SET @updated_by_id_source = NEW.`updated_by_id` ;
	SET @source_system_updater = (IF(@updated_by_id_source IS NULL
			, @source_system_creator
			, @updated_by_id_source
			)
		);

	SET @creator_mefe_user_id = (SELECT `mefe_user_id` 
		FROM `ut_organization_mefe_user_id`
		WHERE `organization_id` = @source_system_creator
		)
		;

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;

	SET @organization_id = @source_system_creator ;

	SET @external_id = NEW.`external_id` ;
	SET @external_system_id = NEW.`external_system_id` ; 
	SET @external_table = NEW.`external_table` ;

	SET @new_is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;
	SET @old_is_creation_needed_in_unee_t = OLD.`is_creation_needed_in_unee_t` ;

	SET @upstream_do_not_insert = NEW.`do_not_insert` ;

	# This is an UPDATE - the record SHOULD exist already
	# BUT there are some edge cases when we need to re-create this...
		SET @do_not_insert = @upstream_do_not_insert ;

	# Get the information about the unit for that room...
	# We need the information from the table `external_property_level_2_units` (and NOT the table `external_property_level_2_units`)
	
		SET @unit_id_in_table_external_property_level_3_rooms = NEW.`system_id_unit` ;

        SET @unit_external_id = (SELECT `external_id`
			FROM `external_property_level_2_units`
			WHERE `system_id_unit` = @unit_id_in_table_external_property_level_3_rooms
			    );
		SET @unit_external_system_id = (SELECT `external_system_id`
		    FROM `external_property_level_2_units`
		    WHERE `system_id_unit` = @unit_id_in_table_external_property_level_3_rooms
		    );
		SET @unit_external_table = (SELECT `external_table`
		   FROM `external_property_level_2_units`
		    WHERE `system_id_unit` = @unit_id_in_table_external_property_level_3_rooms
		    );

		SET @system_id_unit = (SELECT `system_id_unit`
			FROM `property_level_2_units`
			WHERE `external_id` = @unit_external_id
		    	AND `external_system_id` = @unit_external_system_id
		    	AND `external_table` = @unit_external_table
		    	AND `organization_id` = @organization_id
			    );

	IF @is_creation_needed_in_unee_t = 1
		AND @new_is_creation_needed_in_unee_t != @old_is_creation_needed_in_unee_t
		AND @do_not_insert = 0
		AND @external_id IS NOT NULL
		AND @external_system_id IS NOT NULL
		AND @external_table IS NOT NULL
		AND @organization_id IS NOT NULL
        AND @system_id_unit IS NOT NULL
		AND (@upstream_create_method = 'imported_from_hmlet_ipi'
			OR @upstream_update_method = 'imported_from_hmlet_ipi'
			OR @upstream_create_method = 'Manage_Rooms_Add_Page'
			OR @upstream_update_method = 'Manage_Rooms_Add_Page'
			OR @upstream_create_method = 'Manage_Rooms_Edit_Page'
			OR @upstream_update_method = 'Manage_Rooms_Edit_Page'
			OR @upstream_create_method = 'Manage_Rooms_Import_Page'
			OR @upstream_update_method = 'Manage_Rooms_Import_Page'
			OR @upstream_create_method = 'Export_and_Import_Rooms_Import_Page'
			OR @upstream_update_method = 'Export_and_Import_Rooms_Import_Page'
			)
	THEN 

	# We capture the values we need for the insert/udpate to the `external_property_level_2_units` table:

		SET @this_trigger = 'ut_update_external_property_level_3_creation_needed';

		SET @syst_created_datetime = NOW();
		SET @creation_system_id = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_creator
			)
			;
		SET @created_by_id = @creator_mefe_user_id ;
		SET @downstream_creation_method = @this_trigger ;

		SET @syst_updated_datetime = NOW();

		SET @update_system_id = (SELECT `id_external_sot_for_unee_t` 
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `organization_id` = @source_system_updater
			)
			;
		SET @updated_by_id = @creator_mefe_user_id ;
		SET @downstream_update_method = @this_trigger ;

		SET @organization_id_create = @source_system_creator;
		SET @organization_id_update = @source_system_updater;

		SET @is_obsolete = NEW.`is_obsolete` ;
        SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;

        SET @unee_t_unit_type = NEW.`unee_t_unit_type` ;
            
		SET @room_type_id = NEW.`room_type_id` ;
		SET @number_of_beds = NEW.`number_of_beds` ;
		SET @surface = NEW.`surface` ;
		SET @surface_measurment_unit = NEW.`surface_measurment_unit` ;
		SET @room_designation = NEW.`room_designation`;
		SET @room_description = NEW.`room_description` ;

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
 				(@external_id
        	    , @external_system_id 
        	    , @external_table
        	    , @syst_created_datetime
        	    , @creation_system_id
        	    , @created_by_id
        	    , @downstream_creation_method
        	    , @organization_id_create
        	    , @is_obsolete
        	    , @is_creation_needed_in_unee_t
        	    , @do_not_insert
        	    , @unee_t_unit_type
        	    , @system_id_unit
        	    , @room_type_id
        	    , @surface
        	    , @surface_measurment_unit
				, @room_designation
        	    , @room_description
 			)
        	ON DUPLICATE KEY UPDATE
 				`syst_updated_datetime` = @syst_updated_datetime
 				, `update_system_id` = @update_system_id
 				, `updated_by_id` = @updated_by_id
        		, `update_method` = @downstream_update_method
				, `organization_id` = @organization_id_update
        	    , `is_obsolete` = @is_obsolete
        	    , `is_creation_needed_in_unee_t` = @is_creation_needed_in_unee_t
        	    , `do_not_insert` = @do_not_insert
        	    , `unee_t_unit_type` = @unee_t_unit_type
        	    , `system_id_unit` = @system_id_unit
        	    , `room_type_id` = @room_type_id
        	    , `surface` = @surface
        	    , `surface_measurment_unit` = @surface_measurment_unit
        	    , `room_designation` = @room_designation
				, `room_description` = @room_description
        	;

	END IF;

END */$$


DELIMITER ;

/* Trigger structure for table `property_level_1_buildings` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_update_map_external_source_unit_add_building` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_update_map_external_source_unit_add_building` AFTER INSERT ON `property_level_1_buildings` FOR EACH ROW 
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

	SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;

	SET @external_property_id = NEW.`external_id` ;
	SET @external_system = NEW.`external_system_id` ;
	SET @table_in_external_system = NEW.`external_table` ;
	SET @organization_id = NEW.`organization_id`;
	SET @tower = NEW.`tower` ; 

	SET @id_building = NEW.`id_building` ;

	SET @id_in_ut_map_external_source_units = (SELECT `id_map`
		FROM `ut_map_external_source_units`
		WHERE `external_property_type_id` = 1
			AND `external_property_id` = @external_property_id
			AND `external_system` = @external_system
			AND `table_in_external_system` = @table_in_external_system
			AND `organization_id` = @organization_id
			AND `tower` = @tower
		);

	SET @existing_mefe_unit_id = (SELECT `unee_t_mefe_unit_id`
		FROM `ut_map_external_source_units`
		WHERE `external_property_type_id` = 1
			AND `external_property_id` = @external_property_id
			AND `external_system` = @external_system
			AND `table_in_external_system` = @table_in_external_system
			AND `organization_id` = @organization_id
			AND `tower` = @tower
		);

	# This is an insert - if the record does NOT exist, we create the record
	# unless it is specifically specified that we do NOT need to create the record.
		SET @do_not_insert = (IF (@id_in_ut_map_external_source_units IS NULL
				, 0
				, NEW.`do_not_insert`
				)
			
			);

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;

	IF @is_creation_needed_in_unee_t = 1
		AND @do_not_insert = 0
		AND @existing_mefe_unit_id IS NULL
		AND (@upstream_create_method = 'ut_insert_external_property_level_1'
			OR @upstream_update_method = 'ut_insert_external_property_level_1'
			OR @upstream_create_method = 'ut_update_external_property_level_1'
			OR @upstream_update_method = 'ut_update_external_property_level_1'
			OR @upstream_create_method = 'ut_update_external_property_level_1_creation_needed'
			OR @upstream_update_method = 'ut_update_external_property_level_1_creation_needed'
			)
	THEN 

	# We capture the values we need for the insert/udpate:

		SET @this_trigger = 'ut_update_map_external_source_unit_add_building' ;

		SET @syst_created_datetime = NOW();
		SET @creation_system_id = NEW.`creation_system_id`;
		SET @created_by_id = NEW.`created_by_id`;
		SET @creation_method = @this_trigger ;

		SET @syst_updated_datetime = NOW();
		SET @update_system_id = NEW.`creation_system_id`;
		SET @updated_by_id = NEW.`created_by_id`;
		SET @update_method = @this_trigger ;

		SET @is_obsolete = NEW.`is_obsolete`;
		SET @is_update_needed = NULL;
			
		SET @uneet_name = NEW.`designation`;

		SET @unee_t_unit_type = (IFNULL(NEW.`unee_t_unit_type`
				, 'Unknown'
				)
			)
			;
			
		SET @new_record_id = NEW.`id_building`;
		SET @external_property_type_id = 1;
		
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
				, `tower`
				)
				VALUES
					(@syst_created_datetime
					, @creation_system_id
					, @created_by_id
					, @creation_method
					, @organization_id
					, @is_obsolete
					, @is_update_needed
					, @uneet_name
					, @unee_t_unit_type
					, @new_record_id
					, @external_property_type_id
					, @external_property_id
					, @external_system
					, @table_in_external_system
					, @tower
					)
				ON DUPLICATE KEY UPDATE 
					`syst_updated_datetime` = @syst_updated_datetime
					, `update_system_id` = @update_system_id
					, `updated_by_id` = @updated_by_id
					, `update_method` = @update_method
					, `organization_id` = @organization_id
					, `uneet_name` = @uneet_name
					, `unee_t_unit_type` = @unee_t_unit_type
					, `is_update_needed` = @is_update_needed
				;

	END IF;
END */$$


DELIMITER ;

/* Trigger structure for table `property_level_1_buildings` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_update_map_external_source_unit_add_building_creation_needed` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_update_map_external_source_unit_add_building_creation_needed` AFTER UPDATE ON `property_level_1_buildings` FOR EACH ROW 
BEGIN

# We only do this IF:
# 	- We need to create the unit in Unee-T
#	- We do NOT have a MEFE unit ID for that unit
#	- The record has NOT been explicitly been marked as `do_not_insert`
#	- This is done via an authorized update Method:
#		- `ut_insert_external_property_level_1`
#		- 'ut_update_external_property_level_1_creation_needed'
#		- ''

	SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;

	SET @external_property_id = NEW.`external_id` ;
	SET @external_system = NEW.`external_system_id` ;
	SET @table_in_external_system = NEW.`external_table` ;
	SET @organization_id = NEW.`organization_id`;
	SET @tower = NEW.`tower` ; 

	SET @new_is_creation_needed_in_unee_t =  NEW.`is_creation_needed_in_unee_t` ;
	SET @old_is_creation_needed_in_unee_t = OLD.`is_creation_needed_in_unee_t` ; 

	SET @do_not_insert = NEW.`do_not_insert` ;

	SET @id_building = NEW.`id_building` ;

	SET @mefe_unit_id = (SELECT `unee_t_mefe_unit_id`
		FROM `ut_map_external_source_units`
		WHERE `external_property_type_id` = 1
			AND `external_property_id` = @external_property_id
			AND `external_system` = @external_system
			AND `table_in_external_system` = @table_in_external_system
			AND `organization_id` = @organization_id
			AND `tower` = @tower
		);

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;

	IF @is_creation_needed_in_unee_t = 1
		AND @do_not_insert = 0
		AND @mefe_unit_id IS NULL
		AND (@upstream_create_method = 'ut_insert_external_property_level_1'
			OR @upstream_update_method = 'ut_insert_external_property_level_1'
			OR @upstream_create_method = 'ut_update_external_property_level_1_creation_needed'
			OR @upstream_update_method = 'ut_update_external_property_level_1_creation_needed'
			)
	THEN 

		# We capture the values we need for the insert/udpate:

			SET @this_trigger = 'ut_update_map_external_source_unit_add_building_creation_needed' ;

			SET @syst_created_datetime = NOW();
			SET @creation_system_id = NEW.`update_system_id`;
			SET @created_by_id = NEW.`updated_by_id`;
			SET @creation_method = @this_trigger ;

			SET @syst_updated_datetime = NOW();
			SET @update_system_id = NEW.`update_system_id`;
			SET @updated_by_id = NEW.`updated_by_id`;
			SET @update_method = @this_trigger ;

			SET @organization_id = NEW.`organization_id`;

			SET @tower = NEW.`tower` ; 
			
			SET @is_obsolete = NEW.`is_obsolete`;
			SET @is_update_needed = 1 ;
			
			SET @uneet_name = NEW.`designation`;

			SET @unee_t_unit_type = (IFNULL(NEW.`unee_t_unit_type`
					, 'Unknown'
					)
				)
				;
			
			SET @new_record_id = NEW.`id_building`;
			SET @external_property_type_id = 1;

			SET @external_property_id = NEW.`external_id`;
			SET @external_system = NEW.`external_system_id`;
			SET @table_in_external_system = NEW.`external_table`;
		
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
				, `tower`
				)
				VALUES
					(@syst_created_datetime
					, @creation_system_id
					, @created_by_id
					, @creation_method
					, @organization_id
					, @is_obsolete
					, @is_update_needed
					, @uneet_name
					, @unee_t_unit_type
					, @new_record_id
					, @external_property_type_id
					, @external_property_id
					, @external_system
					, @table_in_external_system
					, @tower
					)
				ON DUPLICATE KEY UPDATE
					`syst_updated_datetime` = @syst_updated_datetime
					, `update_system_id` = @update_system_id
					, `updated_by_id` = @updated_by_id
					, `update_method` = @update_method
					, `organization_id` = @organization_id
					, `uneet_name` = @uneet_name
					, `unee_t_unit_type` = @unee_t_unit_type
					, `is_update_needed` = @is_update_needed
				;

	END IF;
END */$$


DELIMITER ;

/* Trigger structure for table `property_level_1_buildings` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_update_map_external_source_unit_edit_level_1` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_update_map_external_source_unit_edit_level_1` AFTER UPDATE ON `property_level_1_buildings` FOR EACH ROW 
BEGIN

# We only do this IF:
# 	- We need to create the unit in Unee-T
#	- We DO have a MEFE unit ID for that unit
#	- The record has NOT been explicitly been marked as `do_not_insert`
#	- This is done via an authorized update Method:
#		- `ut_update_external_property_level_1`
#		- ''

	SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;

	SET @external_property_id = NEW.`external_id` ;
	SET @external_system = NEW.`external_system_id` ;
	SET @table_in_external_system = NEW.`external_table` ;
	SET @organization_id = NEW.`organization_id`;
	SET @tower = NEW.`tower` ; 

	SET @new_is_creation_needed_in_unee_t =  NEW.`is_creation_needed_in_unee_t` ;
	SET @old_is_creation_needed_in_unee_t = OLD.`is_creation_needed_in_unee_t` ; 

	SET @do_not_insert = NEW.`do_not_insert` ;

	SET @id_building = NEW.`id_building` ;

	SET @mefe_unit_id = (SELECT `unee_t_mefe_unit_id`
		FROM `ut_map_external_source_units`
		WHERE `external_property_type_id` = 1
			AND `external_property_id` = @external_property_id
			AND `external_system` = @external_system
			AND `table_in_external_system` = @table_in_external_system
			AND `organization_id` = @organization_id
			AND `tower` = @tower
		);

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;

	IF @is_creation_needed_in_unee_t = 1
		AND @do_not_insert = 0
		AND @mefe_unit_id IS NOT NULL
		AND (@upstream_create_method = 'ut_update_external_property_level_1'
			OR @upstream_update_method = 'ut_update_external_property_level_1'
			)
	THEN 

		# We capture the values we need for the insert/udpate:

			SET @this_trigger = 'ut_update_map_external_source_unit_edit_level_1' ;

			SET @syst_created_datetime = NOW();
			SET @creation_system_id = NEW.`update_system_id`;
			SET @created_by_id = NEW.`updated_by_id`;
			SET @creation_method = @this_trigger ;

			SET @syst_updated_datetime = NOW();
			SET @update_system_id = NEW.`update_system_id`;
			SET @updated_by_id = NEW.`updated_by_id`;
			SET @update_method = @this_trigger ;

			SET @organization_id = NEW.`organization_id`;

			SET @tower = NEW.`tower` ; 
			
			SET @is_obsolete = NEW.`is_obsolete`;
			SET @is_update_needed = 1 ;
			
			SET @uneet_name = NEW.`designation`;

			SET @unee_t_unit_type = (IFNULL(NEW.`unee_t_unit_type`
					, 'Unknown'
					)
				)
				;
			
			SET @new_record_id = NEW.`id_building`;
			SET @external_property_type_id = 1;

			SET @external_property_id = NEW.`external_id`;
			SET @external_system = NEW.`external_system_id`;
			SET @table_in_external_system = NEW.`external_table`;

			SET @is_mefe_api_success := 0 ;
			SET @mefe_api_error_message := (CONCAT('N/A - written by '
					, '`'
					, @this_trigger
					, '`'
					)
				);

		# We insert/Update a new record in the table `ut_map_external_source_units`

			INSERT INTO `ut_map_external_source_units`
				( `syst_created_datetime`
				, `creation_system_id`
				, `created_by_id`
				, `creation_method`
				, `organization_id`
				, `is_obsolete`
				, `is_update_needed`
				, `is_mefe_api_success`
				, `mefe_api_error_message`
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
					(@syst_created_datetime
					, @creation_system_id
					, @created_by_id
					, @creation_method
					, @organization_id
					, @is_obsolete
					, @is_update_needed
					, @is_mefe_api_success
					, @mefe_api_error_message
					, @uneet_name
					, @unee_t_unit_type
					, @new_record_id
					, @external_property_type_id
					, @external_property_id
					, @external_system
					, @table_in_external_system
					, @tower
					)
				ON DUPLICATE KEY UPDATE
					`syst_updated_datetime` = @syst_updated_datetime
					, `update_system_id` = @update_system_id
					, `updated_by_id` = @updated_by_id
					, `update_method` = @update_method
					, `organization_id` = @organization_id
					, `is_mefe_api_success` = @is_mefe_api_success
					, `mefe_api_error_message` = @mefe_api_error_message
					, `uneet_name` = @uneet_name
					, `unee_t_unit_type` = @unee_t_unit_type
					, `is_update_needed` = @is_update_needed
				;

	END IF;
END */$$


DELIMITER ;

/* Trigger structure for table `property_level_2_units` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_update_map_external_source_unit_add_unit` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_update_map_external_source_unit_add_unit` AFTER INSERT ON `property_level_2_units` FOR EACH ROW 
BEGIN

# We do this ONLY IF 
#	- We have marked the property as an object we need to create in Unee-T
#	- The record does NOT exist in the table `ut_map_external_source_units` yet
#	- This is done via an authorized insert method:
#		- 'ut_insert_external_property_level_2'
#		- 'ut_update_external_property_level_2'
#		- 'ut_update_external_property_level_2_creation_needed'
#		- ''
#
	SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;

	SET @external_property_id = NEW.`external_id` ;
	SET @external_system = NEW.`external_system_id` ;
	SET @table_in_external_system = NEW.`external_table` ;
	SET @organization_id = NEW.`organization_id`;

	SET @id_in_ut_map_external_source_units = (SELECT `id_map`
		FROM `ut_map_external_source_units`
		WHERE `external_system` = @external_system
			AND `table_in_external_system` = @table_in_external_system
			AND `external_property_id` = @external_property_id
			AND `organization_id` = @organization_id
		);

	SET @do_not_insert = (IF (@id_in_ut_map_external_source_units IS NULL
			, 0
			, NEW.`do_not_insert`
			)
		
		);

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;

	IF @is_creation_needed_in_unee_t = 1
		AND @do_not_insert = 0
		AND (@upstream_create_method = 'ut_insert_external_property_level_2'
			OR @upstream_update_method = 'ut_insert_external_property_level_2'
			OR @upstream_create_method = 'ut_update_external_property_level_2'
			OR @upstream_update_method = 'ut_update_external_property_level_2'
			OR @upstream_create_method = 'ut_update_external_property_level_2_creation_needed'
			OR @upstream_update_method = 'ut_update_external_property_level_2_creation_needed'
			)

	THEN 

		# We capture the values we need for the insert/udpate:

			SET @this_trigger = 'ut_update_map_external_source_unit_add_unit' ;

			SET @syst_created_datetime = NOW();
			SET @creation_system_id = NEW.`creation_system_id`;
			SET @created_by_id = NEW.`created_by_id`;
			SET @creation_method = @this_trigger ;

			SET @syst_updated_datetime = NOW();
			SET @update_system_id = NEW.`creation_system_id`;
			SET @updated_by_id = NEW.`created_by_id`;
			SET @update_method = @this_trigger ;
			
			SET @is_obsolete = NEW.`is_obsolete`;
			SET @is_update_needed = NULL;
			
			SET @uneet_name = NEW.`designation`;

			SET @unee_t_unit_type = (IFNULL(NEW.`unee_t_unit_type`
					, 'Unknown'
					)
				)
				;
			
			SET @new_record_id = NEW.`system_id_unit`;
			SET @external_property_type_id = 2;	

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
					(@syst_created_datetime
					, @creation_system_id
					, @created_by_id
					, @creation_method
					, @organization_id
					, @is_obsolete
					, @is_update_needed
					, @uneet_name
					, @unee_t_unit_type
					, @new_record_id
					, @external_property_type_id
					, @external_property_id
					, @external_system
					, @table_in_external_system
					)
				ON DUPLICATE KEY UPDATE 
					`syst_updated_datetime` = @syst_updated_datetime
					, `update_system_id` = @update_system_id
					, `updated_by_id` = @updated_by_id
					, `update_method` = @update_method
					, `organization_id` = @organization_id
					, `uneet_name` = @uneet_name
					, `unee_t_unit_type` = @unee_t_unit_type
					, `is_update_needed` = 1
				;

	END IF;
END */$$


DELIMITER ;

/* Trigger structure for table `property_level_2_units` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_update_map_external_source_unit_add_unit_creation_needed` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_update_map_external_source_unit_add_unit_creation_needed` AFTER UPDATE ON `property_level_2_units` FOR EACH ROW 
BEGIN

# We only do this IF:
# 	- We need to create the unit in Unee-T
#	- The unit is NOT marked as `do_not_insert`
#	- We do NOT have a MEFE unit ID for that unit
#	- This is done via an authorized update method:
#		- 'ut_insert_external_property_level_2'
#		- 'ut_update_external_property_level_2_creation_needed'
#		- ''

	SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t`;

	SET @new_is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t`;
	SET @old_is_creation_needed_in_unee_t = OLD.`is_creation_needed_in_unee_t`;

	SET @do_not_insert = NEW.`do_not_insert` ;

	SET @system_id_unit = NEW.`system_id_unit` ;

	SET @mefe_unit_id = (SELECT `unee_t_mefe_unit_id`
		FROM `ut_map_external_source_units`
		WHERE `new_record_id` = @system_id_unit
			AND `external_property_type_id` = 2
		);

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;

	IF @is_creation_needed_in_unee_t = 1
		AND @do_not_insert = 0 
		AND @mefe_unit_id IS NULL
		AND (@upstream_create_method = 'ut_insert_external_property_level_2'
			OR @upstream_update_method = 'ut_insert_external_property_level_2'
			OR @upstream_create_method = 'ut_update_external_property_level_2_creation_needed'
			OR @upstream_update_method = 'ut_update_external_property_level_2_creation_needed'
			)
	THEN 

	# We capture the values we need for the insert/udpate:

		SET @this_trigger = 'ut_update_map_external_source_unit_add_unit_creation_needed';

		SET @syst_created_datetime = NOW();
		SET @creation_system_id = NEW.`update_system_id`;
		SET @created_by_id = NEW.`updated_by_id`;
		SET @creation_method = @this_trigger ;

		SET @syst_updated_datetime = NOW();
		SET @update_system_id = NEW.`update_system_id`;
		SET @updated_by_id = NEW.`updated_by_id`;
		SET @update_method = @this_trigger ;

		SET @organization_id = NEW.`organization_id`;
			
		SET @is_obsolete = NEW.`is_obsolete`;
		SET @is_update_needed = NULL;
		
		SET @uneet_name = NEW.`designation`;

		SET @unee_t_unit_type = (IFNULL(NEW.`unee_t_unit_type`
				, 'Unknown'
				)
			)
			;
			
		SET @new_record_id = NEW.`system_id_unit`;
		SET @external_property_type_id = 2;

		SET @external_property_id = NEW.`external_id`;
		SET @external_system = NEW.`external_system_id`;
		SET @table_in_external_system = NEW.`external_table`;			

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
					(@syst_created_datetime
					, @creation_system_id
					, @created_by_id
					, @creation_method
					, @organization_id
					, @is_obsolete
					, @is_update_needed
					, @uneet_name
					, @unee_t_unit_type
					, @new_record_id
					, @external_property_type_id
					, @external_property_id
					, @external_system
					, @table_in_external_system
					)
				ON DUPLICATE KEY UPDATE
					`syst_updated_datetime` = @syst_updated_datetime
					, `update_system_id` = @update_system_id
					, `updated_by_id` = @updated_by_id
					, `update_method` = @update_method
					, `organization_id` = @organization_id
					, `uneet_name` = @uneet_name
					, `unee_t_unit_type` = @unee_t_unit_type
					, `is_update_needed` = 1
				;

	END IF;
END */$$


DELIMITER ;

/* Trigger structure for table `property_level_2_units` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_update_map_external_source_unit_edit_level_2` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_update_map_external_source_unit_edit_level_2` AFTER UPDATE ON `property_level_2_units` FOR EACH ROW 
BEGIN

# We only do this IF:
# 	- We need to create the unit in Unee-T
#	- The unit is NOT marked as `do_not_insert`
#	- We DO have a MEFE unit ID for that unit
#	- This is done via an authorized update method:
#		- 'ut_update_external_property_level_2'
#		- ''

	SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t`;

	SET @new_is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t`;
	SET @old_is_creation_needed_in_unee_t = OLD.`is_creation_needed_in_unee_t`;

	SET @do_not_insert = NEW.`do_not_insert` ;

	SET @system_id_unit = NEW.`system_id_unit` ;

	SET @mefe_unit_id = (SELECT `unee_t_mefe_unit_id`
		FROM `ut_map_external_source_units`
		WHERE `new_record_id` = @system_id_unit
			AND `external_property_type_id` = 2
		);

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;

	IF @is_creation_needed_in_unee_t = 1
		AND @do_not_insert = 0 
		AND @mefe_unit_id IS NOT NULL
		AND (@upstream_create_method = 'ut_update_external_property_level_2'
			OR @upstream_update_method = 'ut_update_external_property_level_2'
			)
	THEN 

	# We capture the values we need for the insert/udpate:

		SET @this_trigger = 'ut_update_map_external_source_unit_edit_level_2';

		SET @syst_created_datetime = NOW();
		SET @creation_system_id = NEW.`update_system_id`;
		SET @created_by_id = NEW.`updated_by_id`;
		SET @creation_method = @this_trigger ;

		SET @syst_updated_datetime = NOW();
		SET @update_system_id = NEW.`update_system_id`;
		SET @updated_by_id = NEW.`updated_by_id`;
		SET @update_method = @this_trigger ;

		SET @organization_id = NEW.`organization_id`;
			
		SET @is_obsolete = NEW.`is_obsolete`;
		SET @is_update_needed = NULL;
		
		SET @uneet_name = NEW.`designation`;

		SET @unee_t_unit_type = (IFNULL(NEW.`unee_t_unit_type`
				, 'Unknown'
				)
			)
			;
			
		SET @new_record_id = NEW.`system_id_unit`;
		SET @external_property_type_id = 2;

		SET @external_property_id = NEW.`external_id`;
		SET @external_system = NEW.`external_system_id`;
		SET @table_in_external_system = NEW.`external_table`;

		SET @is_mefe_api_success := 0 ;
		SET @mefe_api_error_message := (CONCAT('N/A - written by '
				, '`'
				, @this_trigger
				, '`'
				)
			);

		# We insert/Update a new record in the table `ut_map_external_source_units`

			INSERT INTO `ut_map_external_source_units`
				( `syst_created_datetime`
				, `creation_system_id`
				, `created_by_id`
				, `creation_method`
				, `organization_id`
				, `is_obsolete`
				, `is_update_needed`
				, `is_mefe_api_success`
				, `mefe_api_error_message`
				, `uneet_name`
				, `unee_t_unit_type`
				, `new_record_id`
				, `external_property_type_id`
				, `external_property_id`
				, `external_system`
				, `table_in_external_system`
				)
				VALUES
					(@syst_created_datetime
					, @creation_system_id
					, @created_by_id
					, @creation_method
					, @organization_id
					, @is_obsolete
					, @is_update_needed
					, @is_mefe_api_success
					, @mefe_api_error_message
					, @uneet_name
					, @unee_t_unit_type
					, @new_record_id
					, @external_property_type_id
					, @external_property_id
					, @external_system
					, @table_in_external_system
					)
				ON DUPLICATE KEY UPDATE
					`syst_updated_datetime` = @syst_updated_datetime
					, `update_system_id` = @update_system_id
					, `updated_by_id` = @updated_by_id
					, `update_method` = @update_method
					, `organization_id` = @organization_id
					, `is_mefe_api_success` = @is_mefe_api_success
					, `mefe_api_error_message` = @mefe_api_error_message
					, `uneet_name` = @uneet_name
					, `unee_t_unit_type` = @unee_t_unit_type
					, `is_update_needed` = 1
				;

	END IF;
END */$$


DELIMITER ;

/* Trigger structure for table `property_level_3_rooms` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_update_map_external_source_unit_add_room` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_update_map_external_source_unit_add_room` AFTER INSERT ON `property_level_3_rooms` FOR EACH ROW 
BEGIN

# We do this ONLY IF 
#	- We have marked the property as an object we need to create in Unee-T
#	- The record does NOT exist in the table `ut_map_external_source_units` yet
#	- This is done via an authorized insert method:
#		- 'ut_insert_external_property_level_3'
#		- 'ut_update_external_property_level_3'
#		- 'ut_update_external_property_level_3_creation_needed'
#		- ''
#
	SET @is_creation_needed_in_unee_t = NEW.`is_creation_needed_in_unee_t` ;

	SET @external_property_id = NEW.`external_id` ;
	SET @external_system = NEW.`external_system_id` ;
	SET @table_in_external_system = NEW.`external_table` ;
	SET @organization_id = NEW.`organization_id`;

	SET @id_in_ut_map_external_source_units = (SELECT `id_map`
		FROM `ut_map_external_source_units`
		WHERE `external_system` = @external_system
			AND `table_in_external_system` = @table_in_external_system
			AND `external_property_id` = @external_property_id
			AND `organization_id` = @organization_id
		);

	SET @do_not_insert = (IF (@id_in_ut_map_external_source_units IS NULL
			, 0
			, 1
			)
		
		);

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;

	IF @is_creation_needed_in_unee_t = 1
		AND @do_not_insert = 0
		AND (@upstream_create_method = 'ut_insert_external_property_level_3'
			OR @upstream_update_method = 'ut_insert_external_property_level_3'
			OR @upstream_create_method = 'ut_update_external_property_level_3'
			OR @upstream_update_method = 'ut_update_external_property_level_3'
			OR @upstream_create_method = 'ut_update_external_property_level_3_creation_needed'
			OR @upstream_update_method = 'ut_update_external_property_level_3_creation_needed'
			)
	THEN 

	# We capture the values we need for the insert/udpate:

		SET @this_trigger = 'ut_update_map_external_source_unit_add_room' ;

		SET @syst_created_datetime = NOW();
		SET @creation_system_id = NEW.`creation_system_id`;
		SET @created_by_id = NEW.`created_by_id`;
		SET @creation_method = @this_trigger ;

		SET @syst_updated_datetime = NOW();
		SET @update_system_id = NEW.`creation_system_id`;
		SET @updated_by_id = NEW.`created_by_id`;
		SET @update_method = @this_trigger ;
			
		SET @is_obsolete = NEW.`is_obsolete`;
		SET @is_update_needed = NULL;
			
		SET @uneet_name = NEW.`room_designation`;

		SET @unee_t_unit_type = (IFNULL(NEW.`unee_t_unit_type`
				, 'Unknown'
				)
			)
			;
		
		SET @new_record_id = NEW.`system_id_room`;
		SET @external_property_type_id = 3;	

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
					(@syst_created_datetime
					, @creation_system_id
					, @created_by_id
					, @creation_method
					, @organization_id
					, @is_obsolete
					, @is_update_needed
					, @uneet_name
					, @unee_t_unit_type
					, @new_record_id
					, @external_property_type_id
					, @external_property_id
					, @external_system
					, @table_in_external_system
					)
				ON DUPLICATE KEY UPDATE 
					`syst_updated_datetime` = @syst_updated_datetime
					, `update_system_id` = @update_system_id
					, `updated_by_id` = @updated_by_id
					, `update_method` = @update_method
					, `organization_id` = @organization_id
					, `uneet_name` = @uneet_name
					, `unee_t_unit_type` = @unee_t_unit_type
					, `is_update_needed` = 1
				;

	END IF;
END */$$


DELIMITER ;

/* Trigger structure for table `property_level_3_rooms` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_update_map_external_source_unit_add_room_creation_needed` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_update_map_external_source_unit_add_room_creation_needed` AFTER UPDATE ON `property_level_3_rooms` FOR EACH ROW 
BEGIN

# We only do this IF:
# 	- We need to create the unit in Unee-T
#	- The unit is NOT marked as `do_not_insert`
#	- We do NOT have a MEFE unit ID for that unit
#	- This is done via an authorized update method:
#		- 'ut_insert_external_property_level_3'
#		- 'ut_update_external_property_level_3_creation_needed'
#		- ''

	SET @is_creation_needed_in_unee_t := NEW.`is_creation_needed_in_unee_t`;

	SET @new_is_creation_needed_in_unee_t := NEW.`is_creation_needed_in_unee_t`;
	SET @old_is_creation_needed_in_unee_t := OLD.`is_creation_needed_in_unee_t`;

	SET @do_not_insert := NEW.`do_not_insert` ;

	SET @system_id_room := NEW.`system_id_room` ;

	SET @mefe_unit_id := (SELECT `unee_t_mefe_unit_id`
		FROM `ut_map_external_source_units`
		WHERE `new_record_id` = @system_id_room
			AND `external_property_type_id` = 3
		);

	SET @upstream_create_method := NEW.`creation_method` ;
	SET @upstream_update_method := NEW.`update_method` ;

	IF @is_creation_needed_in_unee_t = 1
		AND @do_not_insert = 0 
		AND @mefe_unit_id IS NULL
		AND (@upstream_create_method = 'ut_insert_external_property_level_3'
			OR @upstream_update_method = 'ut_insert_external_property_level_3'
			OR @upstream_create_method = 'ut_update_external_property_level_3_creation_needed'
			OR @upstream_update_method = 'ut_update_external_property_level_3_creation_needed'
			)
	THEN 

	# We capture the values we need for the insert/udpate:

		SET @this_trigger = 'ut_update_map_external_source_unit_add_room_creation_needed' ;

		SET @syst_created_datetime = NOW();
		SET @creation_system_id = NEW.`update_system_id`;
		SET @created_by_id = NEW.`updated_by_id`;
		SET @creation_method = @this_trigger ;

		SET @syst_updated_datetime = NOW();
		SET @update_system_id = NEW.`update_system_id`;
		SET @updated_by_id = NEW.`updated_by_id`;
		SET @update_method = @this_trigger ;

		SET @organization_id = NEW.`organization_id`;
		
		SET @is_obsolete = NEW.`is_obsolete`;
		SET @is_update_needed = NULL;
			
		SET @uneet_name = NEW.`room_designation`;

		SET @unee_t_unit_type = (IFNULL(NEW.`unee_t_unit_type`
				, 'Unknown'
				)
			)
			;
			
		SET @new_record_id = NEW.`system_id_room`;
		SET @external_property_type_id = 3;

		SET @external_property_id = NEW.`external_id`;
		SET @external_system = NEW.`external_system_id`;
		SET @table_in_external_system = NEW.`external_table`;			

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
					(@syst_created_datetime
					, @creation_system_id
					, @created_by_id
					, @creation_method
					, @organization_id
					, @is_obsolete
					, @is_update_needed
					, @uneet_name
					, @unee_t_unit_type
					, @new_record_id
					, @external_property_type_id
					, @external_property_id
					, @external_system
					, @table_in_external_system
					)
				ON DUPLICATE KEY UPDATE 
					`syst_updated_datetime` = @syst_updated_datetime
					, `update_system_id` = @update_system_id
					, `updated_by_id` = @updated_by_id
					, `update_method` = @update_method
					, `organization_id` = @organization_id
					, `uneet_name` = @uneet_name
					, `unee_t_unit_type` = @unee_t_unit_type
					, `is_update_needed` = 1
				;

	END IF;
END */$$


DELIMITER ;

/* Trigger structure for table `property_level_3_rooms` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_update_map_external_source_unit_edit_level_3` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_update_map_external_source_unit_edit_level_3` AFTER UPDATE ON `property_level_3_rooms` FOR EACH ROW 
BEGIN

# We only do this IF:
# 	- We need to create the unit in Unee-T
#	- The unit is NOT marked as `do_not_insert`
#	- We DO have a MEFE unit ID for that unit
#	- This is done via an authorized update method:
#		- 'ut_update_external_property_level_3'
#		- ''

	SET @is_creation_needed_in_unee_t := NEW.`is_creation_needed_in_unee_t`;

	SET @new_is_creation_needed_in_unee_t := NEW.`is_creation_needed_in_unee_t`;
	SET @old_is_creation_needed_in_unee_t := OLD.`is_creation_needed_in_unee_t`;

	SET @do_not_insert := NEW.`do_not_insert` ;

	SET @system_id_room := NEW.`system_id_room` ;

	SET @mefe_unit_id := (SELECT `unee_t_mefe_unit_id`
		FROM `ut_map_external_source_units`
		WHERE `new_record_id` = @system_id_room
			AND `external_property_type_id` = 3
		);

	SET @upstream_create_method := NEW.`creation_method` ;
	SET @upstream_update_method := NEW.`update_method` ;

	IF @is_creation_needed_in_unee_t = 1
		AND @do_not_insert = 0 
		AND @mefe_unit_id IS NOT NULL
		AND (@upstream_create_method = 'ut_update_external_property_level_3'
			OR @upstream_update_method = 'ut_update_external_property_level_3'
			)
	THEN 

	# We capture the values we need for the insert/udpate:

		SET @this_trigger = 'ut_update_map_external_source_unit_edit_level_3' ;

		SET @syst_created_datetime = NOW();
		SET @creation_system_id = NEW.`update_system_id`;
		SET @created_by_id = NEW.`updated_by_id`;
		SET @creation_method = @this_trigger ;

		SET @syst_updated_datetime = NOW();
		SET @update_system_id = NEW.`update_system_id`;
		SET @updated_by_id = NEW.`updated_by_id`;
		SET @update_method = @this_trigger ;

		SET @organization_id = NEW.`organization_id`;
		
		SET @is_obsolete = NEW.`is_obsolete`;
		SET @is_update_needed = NULL;
			
		SET @uneet_name = NEW.`room_designation`;

		SET @unee_t_unit_type = (IFNULL(NEW.`unee_t_unit_type`
				, 'Unknown'
				)
			)
			;
			
		SET @new_record_id = NEW.`system_id_room`;
		SET @external_property_type_id = 3;

		SET @external_property_id = NEW.`external_id`;
		SET @external_system = NEW.`external_system_id`;
		SET @table_in_external_system = NEW.`external_table`;			

		SET @is_mefe_api_success := 0 ;
		SET @mefe_api_error_message := (CONCAT('N/A - written by '
				, '`'
				, @this_trigger
				, '`'
				)
			);

		# We insert/Update a new record in the table `ut_map_external_source_units`

			INSERT INTO `ut_map_external_source_units`
				( `syst_created_datetime`
				, `creation_system_id`
				, `created_by_id`
				, `creation_method`
				, `organization_id`
				, `is_obsolete`
				, `is_update_needed`
				, `is_mefe_api_success`
				, `mefe_api_error_message`
				, `uneet_name`
				, `unee_t_unit_type`
				, `new_record_id`
				, `external_property_type_id`
				, `external_property_id`
				, `external_system`
				, `table_in_external_system`
				)
				VALUES
					(@syst_created_datetime
					, @creation_system_id
					, @created_by_id
					, @creation_method
					, @organization_id
					, @is_obsolete
					, @is_update_needed
					, @is_mefe_api_success
					, @mefe_api_error_message
					, @uneet_name
					, @unee_t_unit_type
					, @new_record_id
					, @external_property_type_id
					, @external_property_id
					, @external_system
					, @table_in_external_system
					)
				ON DUPLICATE KEY UPDATE 
					`syst_updated_datetime` = @syst_updated_datetime
					, `update_system_id` = @update_system_id
					, `updated_by_id` = @updated_by_id
					, `update_method` = @update_method
					, `organization_id` = @organization_id
					, `is_mefe_api_success` = @is_mefe_api_success
					, `mefe_api_error_message` = @mefe_api_error_message
					, `uneet_name` = @uneet_name
					, `unee_t_unit_type` = @unee_t_unit_type
					, `is_update_needed` = 1
				;

	END IF;
END */$$


DELIMITER ;

/* Trigger structure for table `retry_assign_user_to_units_list` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_retry_assign_user_to_unit` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_retry_assign_user_to_unit` AFTER INSERT ON `retry_assign_user_to_units_list` FOR EACH ROW 
BEGIN

# We only do this IF:
#	- The variable @disable_lambda != 1
#	- This is done via an authorized create method:
#		- 'ut_retry_assign_user_to_units_error_ownership'
#		- 'ut_retry_assign_user_to_units_error_already_has_role'
#		- ''
#		- ''

	SET @upstream_create_method := NEW.`creation_method` ;

	IF (@disable_lambda != 1
			OR @disable_lambda IS NULL)
		AND (@upstream_create_method = 'ut_retry_assign_user_to_units_error_ownership'
			OR @upstream_create_method = 'ut_retry_assign_user_to_units_error_already_has_role'
		)
	THEN 

		# The specifics

			# What is this trigger (for log_purposes)
				SET @this_trigger := 'ut_retry_assign_user_to_unit';

			# What is the procedure associated with this trigger:
				SET @associated_procedure := 'lambda_add_user_to_role_in_unit_with_visibility';
			
			# lambda:
			# https://github.com/unee-t/lambda2sns/blob/master/tests/call-lambda-as-root.sh#L5
			#	- DEV/Staging: 812644853088
			#	- Prod: 192458993663
			#	- Demo: 915001051872

				SET @lambda_key := '192458993663';

			# MEFE API Key:
				SET @key_this_envo := 'omitted';

	# The variables that we need:

		SET @mefe_api_request_id = NEW.`id_map_user_unit_permissions` ;

		SET @action_type = 'ASSIGN_ROLE' ;

		SET @requestor_mefe_user_id = NEW.`created_by_id` ;
		
		SET @invited_mefe_user_id = NEW.`mefe_user_id` ;
		SET @mefe_unit_id = NEW.`mefe_unit_id` ;
		SET @role_type = (SELECT `role_type`
			FROM `ut_user_role_types`
			WHERE `id_role_type` = NEW.`unee_t_role_id` 
			)
			;
		
		SET @is_occupant = NEW.`is_occupant`= 1 ;
		SET @is_occupant_not_null = (IFNULL(@is_occupant
				, 0
				)
			)
			;
		SET @is_occupant_json = IF(NEW.`is_occupant`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @is_visible = NEW.`is_public`= 1 ;
		SET @is_visible_not_null = (IFNULL(@is_visible
				, 0
				)
			)
			;
		SET @is_visible_json = IF(NEW.`is_public`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @is_default_assignee = NEW.`is_default_assignee`= 1 ;
		SET @is_default_assignee_not_null = (IFNULL(@is_default_assignee
				, 0
				)
			)
			;
		SET @is_default_assignee_json = IF(NEW.`is_default_assignee`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @is_default_invited = NEW.`is_default_invited` ;
		SET @is_default_invited_not_null = (IFNULL(@is_default_invited
				, 0
				)
			)
			;
		SET @is_default_invited_json = IF(NEW.`is_default_invited`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @can_see_role_agent = NEW.`can_see_role_agent`;
		SET @can_see_role_agent_not_null = (IFNULL(@can_see_role_agent
				, 0
				)
			)
			;
		SET @can_see_role_agent_json = IF(NEW.`can_see_role_agent`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @can_see_role_tenant = NEW.`can_see_role_tenant`;
		SET @can_see_role_tenant_not_null = (IFNULL(@can_see_role_tenant
				, 0
				)
			)
			;
		SET @can_see_role_tenant_json = IF(NEW.`can_see_role_tenant`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @can_see_role_landlord = NEW.`can_see_role_landlord`;
		SET @can_see_role_landlord_not_null = (IFNULL(@can_see_role_landlord
				, 0
				)
			)
			;
		SET @can_see_role_landlord_json = IF(NEW.`can_see_role_landlord`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @can_see_role_mgt_cny = NEW.`can_see_role_mgt_cny`;
		SET @can_see_role_mgt_cny_not_null = (IFNULL(@can_see_role_mgt_cny
				, 0
				)
			)
			;
		SET @can_see_role_mgt_cny_json = IF(NEW.`can_see_role_mgt_cny`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @can_see_role_contractor = NEW.`can_see_role_contractor`;
		SET @can_see_role_contractor_not_null = (IFNULL(@can_see_role_contractor
				, 0
				)
			)
			;
		SET @can_see_role_contractor_json = IF(NEW.`can_see_role_contractor`= 1
			, 'true'
			, 'false'
		 	)
			; 

		SET @can_see_occupant = NEW.`can_see_occupant` ; 
		SET @can_see_occupant_not_null = (IFNULL(@can_see_occupant
				, 0
				)
			)
			;
		SET @can_see_occupant_json = IF(NEW.`can_see_occupant`= 1
			, 'true'
			, 'false'
		 	)
			; 
	
	# We insert the event in the relevant log table

		# Simulate what the Procedure `lambda_add_user_to_role_in_unit_with_visibility` does
		# Make sure to update that if you update the procedure `lambda_add_user_to_role_in_unit_with_visibility`

			# The JSON Object:

				SET @json_object = (
					JSON_OBJECT(
						'mefeAPIRequestId' , @mefe_api_request_id
						, 'actionType', @action_type
						, 'requestorUserId', @requestor_mefe_user_id
						, 'addedUserId', @invited_mefe_user_id
						, 'unitId', @mefe_unit_id
						, 'roleType', @role_type
						, 'isOccupant', @is_occupant
						, 'isVisible', @is_visible
						, 'isDefaultAssignee', @is_default_assignee
						, 'isDefaultInvited', @is_default_invited
						, 'roleVisibility' , JSON_OBJECT('Agent', @can_see_role_agent
							, 'Tenant', @can_see_role_tenant
							, 'Owner/Landlord', @can_see_role_landlord
							, 'Management Company', @can_see_role_mgt_cny
							, 'Contractor', @can_see_role_contractor
							, 'Occupant', @can_see_occupant
							)
						)
					)
					;

			# The specific lambda:

				SET @lambda = CONCAT('arn:aws:lambda:ap-southeast-1:'
					, @lambda_key
					, ':function:alambda_simple')
					;
			
			# The specific Lambda CALL:

				SET @lambda_call = CONCAT('CALL mysql.lambda_async'
					, @lambda
					, @json_object
					)
					;

		# Now that we have simulated what the CALL does, we record that

			SET @unit_name := (SELECT `uneet_name`
				FROM `ut_map_external_source_units`
				WHERE `unee_t_mefe_unit_id` = @mefe_unit_id
				);
			SET @unee_t_login := (SELECT `uneet_login_name`
				FROM `ut_map_external_source_users`
				WHERE `unee_t_mefe_user_id` = @invited_mefe_user_id
				);

			INSERT INTO `log_lambdas`
				(`created_datetime`
				, `creation_trigger`
				, `associated_call`
				, `mefe_unit_id`
				, `unit_name`
				, `mefe_user_id`
				, `unee_t_login`
				, `payload`
				)
				VALUES
					(NOW()
					, @this_trigger
					, @associated_procedure
					, @mefe_unit_id
					, @unit_name
					, @invited_mefe_user_id
					, @unee_t_login
					, @lambda_call
					)
					;

	# We call the Lambda procedure to add a user to a role in a unit

		CALL `lambda_add_user_to_role_in_unit_with_visibility`(@mefe_api_request_id
			, @action_type
			, @requestor_mefe_user_id
			, @invited_mefe_user_id
			, @mefe_unit_id
			, @role_type
			, @is_occupant
			, @is_visible
			, @is_default_assignee
			, @is_default_invited
			, @can_see_role_agent
			, @can_see_role_tenant
			, @can_see_role_landlord
			, @can_see_role_mgt_cny
			, @can_see_role_contractor
			, @can_see_occupant
			)
			;

	END IF;
END */$$


DELIMITER ;

/* Trigger structure for table `retry_create_units_list_units` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_retry_create_unit` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_retry_create_unit` AFTER INSERT ON `retry_create_units_list_units` FOR EACH ROW 
BEGIN

# We only do this IF:
#	- The variable @disable_lambda != 1
#	- This is done via an authorized create method:
#		- 'ut_retry_create_unit_level_1'
#		- 'ut_retry_create_unit_level_2'
#		- 'ut_retry_create_unit_level_3'
#		- ''
#		- ''
#		- ''

	SET @upstream_create_method := NEW.`creation_method` ;

	IF (@disable_lambda != 1
			OR @disable_lambda IS NULL)
		AND (@upstream_create_method = 'ut_retry_create_unit_level_1'
			OR @upstream_create_method = 'ut_retry_create_unit_level_2'
			OR @upstream_create_method = 'ut_retry_create_unit_level_3'
		)
	THEN 

		# The specifics

			# What is this trigger (for log_purposes)
				SET @this_trigger := 'ut_retry_create_unit';

			# What is the procedure associated with this trigger:
				SET @associated_procedure := 'lambda_create_unit';
			
			# lambda:
			# https://github.com/unee-t/lambda2sns/blob/master/tests/call-lambda-as-root.sh#L5
			#	- DEV/Staging: 812644853088
			#	- Prod: 192458993663
			#	- Demo: 915001051872

				SET @lambda_key := '192458993663';

			# MEFE API Key:
				SET @key_this_envo := 'omitted';

	# We define the variables we need
	
		SET @lambda_id := @lambda_key ;
		SET @mefe_api_key := @key_this_envo ;

		SET @unit_creation_request_id := NEW.`unit_creation_request_id` ;

		SET @action_type := 'CREATE_UNIT' ;
		SET @creator_id := NEW.`created_by_id` ;
		SET @uneet_name := NEW.`uneet_name` ;
		SET @unee_t_unit_type := NEW.`unee_t_unit_type` ;
	
		SET @more_info := NEW.`more_info` ;	
		SET @street_address := NEW.`street_address` ;	
		SET @city := NEW.`city` ;	
		SET @state := NEW.`state` ;	
		SET @zip_code := NEW.`zip_code` ;
		SET @country := NEW.`country` ;

		SET @owner_id := @creator_id ;
	
	# We insert the event in the relevant log table

		# Simulate what the trigger does

			# The JSON Object:

				SET @json_object := (
						JSON_OBJECT(
						'unitCreationRequestId' , @unit_creation_request_id
						, 'actionType', @action_type
						, 'creatorId', @creator_id
						, 'name', @uneet_name
						, 'type', @unee_t_unit_type
						, 'moreInfo', @more_info
						, 'streetAddress', @street_address
						, 'city', @city
						, 'state', @state
						, 'zipCode', @zip_code
						, 'country', @country
						, 'ownerId', @owner_id
						)
					)
					;

			# The specific lambda:

				SET @lambda := CONCAT('arn:aws:lambda:ap-southeast-1:'
					, @lambda_key
					, ':function:alambda_simple')
					;
			
			# The specific Lambda CALL:

				SET @lambda_call := CONCAT('CALL mysql.lambda_async'
					, @lambda
					, @json_object
					)
					;

		# Now that we have simulated what the CALL does, we record that

			INSERT INTO `log_lambdas`
				(`created_datetime`
				, `creation_trigger`
				, `associated_call`
				, `mefe_unit_id`
				, `unit_name`
				, `mefe_user_id`
				, `payload`
				)
				VALUES
					(NOW()
					, @this_trigger
					, @associated_procedure
					, 'n/a'
					, @uneet_name
					, 'n/a'
					, @lambda_call
					)
					;


	# We call the Lambda procedure to create a unit

		CALL `lambda_create_unit`(@unit_creation_request_id
			, @action_type
			, @creator_id
			, @uneet_name
			, @unee_t_unit_type
			, @more_info
			, @street_address
			, @city
			, @state
			, @zip_code
			, @country
			, @owner_id
			)
			;

	END IF;
END */$$


DELIMITER ;

/* Trigger structure for table `ut_map_external_source_units` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_create_unit` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_create_unit` AFTER INSERT ON `ut_map_external_source_units` FOR EACH ROW 
BEGIN

# We only do this IF:
#	- The variable @disable_lambda != 1
#	- We do NOT have a MEFE Unit ID for that unit
#	- This is from a recognized creation method:
#		- `ut_update_map_external_source_unit_add_building`
#		- `ut_update_map_external_source_unit_add_building_creation_needed`
#		- `ut_update_map_external_source_unit_add_unit`
#		- `ut_update_map_external_source_unit_add_unit_creation_needed`
#		- `ut_update_map_external_source_unit_add_room`
#		- `ut_update_map_external_source_unit_add_room_creation_needed`
#		- 'ut_update_map_external_source_unit_edit_level_1'
#		- 'ut_update_map_external_source_unit_edit_level_2'
#		- 'ut_update_map_external_source_unit_edit_level_3'
#		- ''
#		- ''
#		- ''

	SET @mefe_unit_id = NEW.`unee_t_mefe_unit_id` ;

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;

	IF @mefe_unit_id IS NULL
		AND (@upstream_create_method = 'ut_update_map_external_source_unit_add_building'
			OR @upstream_update_method = 'ut_update_map_external_source_unit_add_building'
			OR @upstream_create_method = 'ut_update_map_external_source_unit_add_building_creation_needed'
			OR @upstream_update_method = 'ut_update_map_external_source_unit_add_building_creation_needed'
			OR @upstream_create_method = 'ut_update_map_external_source_unit_add_unit'
			OR @upstream_update_method = 'ut_update_map_external_source_unit_add_unit'
			OR @upstream_create_method = 'ut_update_map_external_source_unit_add_unit_creation_needed'
			OR @upstream_update_method = 'ut_update_map_external_source_unit_add_unit_creation_needed'
			OR @upstream_create_method = 'ut_update_map_external_source_unit_add_room'
			OR @upstream_update_method = 'ut_update_map_external_source_unit_add_room'
			OR @upstream_create_method = 'ut_update_map_external_source_unit_add_room_creation_needed'
			OR @upstream_update_method = 'ut_update_map_external_source_unit_add_room_creation_needed'
			OR @upstream_create_method = 'ut_update_map_external_source_unit_edit_level_1'
			OR @upstream_update_method = 'ut_update_map_external_source_unit_edit_level_1'
			OR @upstream_create_method = 'ut_update_map_external_source_unit_edit_level_2'
			OR @upstream_update_method = 'ut_update_map_external_source_unit_edit_level_2'
			OR @upstream_create_method = 'ut_update_map_external_source_unit_edit_level_3'
			OR @upstream_update_method = 'ut_update_map_external_source_unit_edit_level_3'
			)
		AND (@disable_lambda != 1
			OR @disable_lambda IS NULL)
	THEN

		# The specifics

			# What is this trigger (for log_purposes)
				SET @this_trigger = 'ut_create_unit';

			# What is the procedure associated with this trigger:
				SET @associated_procedure = 'lambda_create_unit';
			
			# lambda:
			# https://github.com/unee-t/lambda2sns/blob/master/tests/call-lambda-as-root.sh#L5
			#	- DEV/Staging: 812644853088
			#	- Prod: 192458993663
			#	- Demo: 915001051872

				SET @lambda_key = 812644853088;

			# MEFE API Key:
				SET @key_this_envo = 'ABCDEFG';

	# We define the variables we need

		SET @lambda_id = @lambda_key;
		SET @mefe_api_key = @key_this_envo;

		SET @new_record_id = NEW.`new_record_id`;		
		SET @external_property_type_id = NEW.`external_property_type_id`;

		SET @unit_creation_request_id = (SELECT `id_map` 
			FROM `ut_map_external_source_units`
			WHERE `new_record_id` = @new_record_id
				AND `external_property_type_id` = @external_property_type_id
			)
			;
		SET @action_type = 'CREATE_UNIT';
		SET @creator_id = NEW.`created_by_id`;
		SET @uneet_name = NEW.`uneet_name`;
		SET @unee_t_unit_type = NEW.`unee_t_unit_type`;

		# More info:

			SET @more_info = (IF(@external_property_type_id = 1
					, (SELECT `more_info`
						FROM `ut_add_information_unit_level_1`
						WHERE `unit_level_1_id` = @new_record_id
						)
					, IF(@external_property_type_id = 2
						, (SELECT `more_info`
							FROM `ut_add_information_unit_level_2`
							WHERE `unit_level_2_id` = @new_record_id
							)
						, IF(@external_property_type_id = 3
							, (SELECT `more_info`
								FROM `ut_add_information_unit_level_3`
								WHERE `unit_level_3_id` = @new_record_id
								)
							, 'ERROR 561'
							) 
						)
					)
				)
				;
			SET @more_info_not_null = (IFNULL(@more_info
					, ''
					)
				)
				;
		# Street Address

			SET @street_address = (IF(@external_property_type_id = 1
					, (SELECT `street_address`
						FROM `ut_add_information_unit_level_1`
						WHERE `unit_level_1_id` = @new_record_id
						)
					, IF(@external_property_type_id = 2
						, (SELECT `street_address`
							FROM `ut_add_information_unit_level_2`
							WHERE `unit_level_2_id` = @new_record_id
							)
						, IF(@external_property_type_id = 3
							, (SELECT `street_address`
								FROM `ut_add_information_unit_level_3`
								WHERE `unit_level_3_id` = @new_record_id
								)
							, 'ERROR 435'
							) 
						)
					)
				)
				;

			SET @street_address_not_null = (IFNULL(@street_address
					, ''
					)
				)
				;
		
		# City

			SET @city = (IF(@external_property_type_id = 1
					, (SELECT `city`
						FROM `ut_add_information_unit_level_1`
						WHERE `unit_level_1_id` = @new_record_id
						)
					, IF(@external_property_type_id = 2
						, (SELECT `city`
							FROM `ut_add_information_unit_level_2`
							WHERE `unit_level_2_id` = @new_record_id
							)
						, IF(@external_property_type_id = 3
							, (SELECT `city`
								FROM `ut_add_information_unit_level_3`
								WHERE `unit_level_3_id` = @new_record_id
								)
							, 'ERROR 457'
							) 
						)
					)
				)
				;

			SET @city_not_null = (IFNULL(@city
					, ''
					)
				)
				;
		# State

			SET @state = (IF(@external_property_type_id = 1
					, (SELECT `state`
						FROM `ut_add_information_unit_level_1`
						WHERE `unit_level_1_id` = @new_record_id
						)
					, IF(@external_property_type_id = 2
						, (SELECT `state`
							FROM `ut_add_information_unit_level_2`
							WHERE `unit_level_2_id` = @new_record_id
							)
						, IF(@external_property_type_id = 3
							, (SELECT `state`
								FROM `ut_add_information_unit_level_3`
								WHERE `unit_level_3_id` = @new_record_id
								)
							, 'ERROR 479'
							) 
						)
					)
				)
				;

			SET @state_not_null = (IFNULL(@state
					, ''
					)
				)
				;
			
		# Zip Code

			SET @zip_code = (IF(@external_property_type_id = 1
					, (SELECT `zip_code`
						FROM `ut_add_information_unit_level_1`
						WHERE `unit_level_1_id` = @new_record_id
						)
					, IF(@external_property_type_id = 2
						, (SELECT `zip_code`
							FROM `ut_add_information_unit_level_2`
							WHERE `unit_level_2_id` = @new_record_id
							)
						, IF(@external_property_type_id = 3
							, (SELECT `zip_code`
								FROM `ut_add_information_unit_level_3`
								WHERE `unit_level_3_id` = @new_record_id
								)
							, 'ERROR 501'
							) 
						)
					)
				)
				;

			SET @zip_code_not_null = (IFNULL(@zip_code
					, ''
					)
				)
				;
		
		# Country

			SET @country = (IF(@external_property_type_id = 1
					, (SELECT `country`
						FROM `ut_add_information_unit_level_1`
						WHERE `unit_level_1_id` = @new_record_id
						)
					, IF(@external_property_type_id = 2
						, (SELECT `country`
							FROM `ut_add_information_unit_level_2`
							WHERE `unit_level_2_id` = @new_record_id
							)
						, IF(@external_property_type_id = 3
							, (SELECT `country`
								FROM `ut_add_information_unit_level_3`
								WHERE `unit_level_3_id` = @new_record_id
								)
							, 'ERROR 522'
							) 
						)
					)
				)
				;

			SET @country_not_null = (IFNULL(@country
					, ''
					)
				)
				;
		
		# Owner Id

			SET @owner_id = @creator_id ;

	# We insert the event in the relevant log table

		# Simulate what the Procedure `lambda_create_unit` does
		# Make sure to update that if you update the procedure `lambda_create_unit`

			# The JSON Object:

				SET @json_object = (
						JSON_OBJECT(
						'unitCreationRequestId' , @unit_creation_request_id
						, 'actionType', @action_type
						, 'creatorId', @creator_id
						, 'name', @uneet_name
						, 'type', @unee_t_unit_type
						, 'moreInfo', @more_info
						, 'streetAddress', @street_address
						, 'city', @city
						, 'state', @state
						, 'zipCode', @zip_code
						, 'country', @country
						, 'ownerId', @owner_id
						)
					)
					;

			# The specific lambda:

				SET @lambda = CONCAT('arn:aws:lambda:ap-southeast-1:'
					, @lambda_key
					, ':function:alambda_simple')
					;
			
			# The specific Lambda CALL:

				SET @lambda_call = CONCAT('CALL mysql.lambda_async'
					, @lambda
					, @json_object
					)
					;

		# Now that we have simulated what the CALL does, we record that

			INSERT INTO `log_lambdas`
				(`created_datetime`
				, `creation_trigger`
				, `associated_call`
				, `mefe_unit_id`
				, `unit_name`
				, `mefe_user_id`
				, `payload`
				)
				VALUES
					(NOW()
					, @this_trigger
					, @associated_procedure
					, 'n/a'
					, @uneet_name
					, 'n/a'
					, @lambda_call
					)
					;

	# We call the Lambda procedure to create a unit

		CALL `lambda_create_unit`(@unit_creation_request_id
			, @action_type
			, @creator_id
			, @uneet_name
			, @unee_t_unit_type
			, @more_info
			, @street_address
			, @city
			, @state
			, @zip_code
			, @country
			, @owner_id
			)
			;

	END IF;

END */$$


DELIMITER ;

/* Trigger structure for table `ut_map_external_source_units` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_update_unit_creation_needed` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_update_unit_creation_needed` AFTER UPDATE ON `ut_map_external_source_units` FOR EACH ROW 
BEGIN

# We only do this IF:
#	- The variable @disable_lambda != 1
#	- We do NOT have a MEFE Unit ID
#	- this unit is marked a `is_update_needed` = 1
#	- This is done via an authorized update method:
#		- `ut_update_map_external_source_unit_add_building`
#		- `ut_update_map_external_source_unit_add_building_creation_needed`
#		- `ut_update_map_external_source_unit_add_unit`
#		- `ut_update_map_external_source_unit_add_unit_creation_needed`
#		- `ut_update_map_external_source_unit_add_room`
#		- `ut_update_map_external_source_unit_add_room_creation_needed`
#		- ''
#		- ''
#		- ''

	SET @mefe_unit_id = NEW.`unee_t_mefe_unit_id` ;

	SET @is_update_needed = NEW.`is_update_needed` ;

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;

	IF @mefe_unit_id IS NULL
		AND @is_update_needed = 1
		AND (@upstream_create_method = 'ut_update_map_external_source_unit_add_building'
			OR @upstream_update_method = 'ut_update_map_external_source_unit_add_building'
			OR @upstream_create_method = 'ut_update_map_external_source_unit_add_building_creation_needed'
			OR @upstream_update_method = 'ut_update_map_external_source_unit_add_building_creation_needed'
			OR @upstream_create_method = 'ut_update_map_external_source_unit_add_unit'
			OR @upstream_update_method = 'ut_update_map_external_source_unit_add_unit'
			OR @upstream_create_method = 'ut_update_map_external_source_unit_add_unit_creation_needed'
			OR @upstream_update_method = 'ut_update_map_external_source_unit_add_unit_creation_needed'
			OR @upstream_create_method = 'ut_update_map_external_source_unit_add_room'
			OR @upstream_update_method = 'ut_update_map_external_source_unit_add_room'
			OR @upstream_create_method = 'ut_update_map_external_source_unit_add_room_creation_needed'
			OR @upstream_update_method = 'ut_update_map_external_source_unit_add_room_creation_needed'
			)
		AND (@disable_lambda != 1
			OR @disable_lambda IS NULL)
	THEN

		# The specifics

			# What is this trigger (for log_purposes)
				SET @this_trigger = 'ut_update_unit_creation_needed';

			# What is the procedure associated with this trigger:
				SET @associated_procedure = 'lambda_create_unit';
			
			# lambda:
			# https://github.com/unee-t/lambda2sns/blob/master/tests/call-lambda-as-root.sh#L5
			#	- DEV/Staging: 812644853088
			#	- Prod: 192458993663
			#	- Demo: 915001051872

				SET @lambda_key = 812644853088;

			# MEFE API Key:
				SET @key_this_envo = 'ABCDEFG';

	# We define the variables we need
	# Where can we find the details about that unit?

		SET @lambda_id = @lambda_key;
		SET @mefe_api_key = @key_this_envo;

		SET @new_record_id = NEW.`new_record_id`;		
		SET @external_property_type_id = NEW.`external_property_type_id`;

		SET @unit_creation_request_id = (SELECT `id_map` 
			FROM `ut_map_external_source_units`
			WHERE `new_record_id` = @new_record_id
				AND `external_property_type_id` = @external_property_type_id
			)
			;
		SET @action_type = 'CREATE_UNIT';
		SET @creator_id = NEW.`created_by_id`;
		SET @uneet_name = NEW.`uneet_name`;
		SET @unee_t_unit_type = NEW.`unee_t_unit_type`;

		# More info:

			SET @more_info = (IF(@external_property_type_id = 1
					, (SELECT `more_info`
						FROM `ut_add_information_unit_level_1`
						WHERE `unit_level_1_id` = @new_record_id
						)
					, IF(@external_property_type_id = 2
						, (SELECT `more_info`
							FROM `ut_add_information_unit_level_2`
							WHERE `unit_level_2_id` = @new_record_id
							)
						, IF(@external_property_type_id = 3
							, (SELECT `more_info`
								FROM `ut_add_information_unit_level_3`
								WHERE `unit_level_3_id` = @new_record_id
								)
							, 'ERROR 561'
							) 
						)
					)
				)
				;
			SET @more_info_not_null = (IFNULL(@more_info
					, ''
					)
				)
				;

		# Street Address

			SET @street_address = (IF(@external_property_type_id = 1
					, (SELECT `street_address`
						FROM `ut_add_information_unit_level_1`
						WHERE `unit_level_1_id` = @new_record_id
						)
					, IF(@external_property_type_id = 2
						, (SELECT `street_address`
							FROM `ut_add_information_unit_level_2`
							WHERE `unit_level_2_id` = @new_record_id
							)
						, IF(@external_property_type_id = 3
							, (SELECT `street_address`
								FROM `ut_add_information_unit_level_3`
								WHERE `unit_level_3_id` = @new_record_id
								)
							, 'ERROR 435'
							) 
						)
					)
				)
				;

			SET @street_address_not_null = (IFNULL(@street_address
					, ''
					)
				)
				;
		
		# City

			SET @city = (IF(@external_property_type_id = 1
					, (SELECT `city`
						FROM `ut_add_information_unit_level_1`
						WHERE `unit_level_1_id` = @new_record_id
						)
					, IF(@external_property_type_id = 2
						, (SELECT `city`
							FROM `ut_add_information_unit_level_2`
							WHERE `unit_level_2_id` = @new_record_id
							)
						, IF(@external_property_type_id = 3
							, (SELECT `city`
								FROM `ut_add_information_unit_level_3`
								WHERE `unit_level_3_id` = @new_record_id
								)
							, 'ERROR 457'
							) 
						)
					)
				)
				;

			SET @city_not_null = (IFNULL(@city
					, ''
					)
				)
				;
		# State

			SET @state = (IF(@external_property_type_id = 1
					, (SELECT `state`
						FROM `ut_add_information_unit_level_1`
						WHERE `unit_level_1_id` = @new_record_id
						)
					, IF(@external_property_type_id = 2
						, (SELECT `state`
							FROM `ut_add_information_unit_level_2`
							WHERE `unit_level_2_id` = @new_record_id
							)
						, IF(@external_property_type_id = 3
							, (SELECT `state`
								FROM `ut_add_information_unit_level_3`
								WHERE `unit_level_3_id` = @new_record_id
								)
							, 'ERROR 479'
							) 
						)
					)
				)
				;

			SET @state_not_null = (IFNULL(@state
					, ''
					)
				)
				;
			
		# Zip Code

			SET @zip_code = (IF(@external_property_type_id = 1
					, (SELECT `zip_code`
						FROM `ut_add_information_unit_level_1`
						WHERE `unit_level_1_id` = @new_record_id
						)
					, IF(@external_property_type_id = 2
						, (SELECT `zip_code`
							FROM `ut_add_information_unit_level_2`
							WHERE `unit_level_2_id` = @new_record_id
							)
						, IF(@external_property_type_id = 3
							, (SELECT `zip_code`
								FROM `ut_add_information_unit_level_3`
								WHERE `unit_level_3_id` = @new_record_id
								)
							, 'ERROR 501'
							) 
						)
					)
				)
				;

			SET @zip_code_not_null = (IFNULL(@zip_code
					, ''
					)
				)
				;
		
		# Country

			SET @country = (IF(@external_property_type_id = 1
					, (SELECT `country`
						FROM `ut_add_information_unit_level_1`
						WHERE `unit_level_1_id` = @new_record_id
						)
					, IF(@external_property_type_id = 2
						, (SELECT `country`
							FROM `ut_add_information_unit_level_2`
							WHERE `unit_level_2_id` = @new_record_id
							)
						, IF(@external_property_type_id = 3
							, (SELECT `country`
								FROM `ut_add_information_unit_level_3`
								WHERE `unit_level_3_id` = @new_record_id
								)
							, 'ERROR 522'
							) 
						)
					)
				)
				;

			SET @country_not_null = (IFNULL(@country
					, ''
					)
				)
				;
		
		# Owner Id

			SET @owner_id = @creator_id ;

	# We insert the event in the relevant log table

		# Simulate what the Procedure `lambda_create_unit` does
		# Make sure to update that if you update the procedure `lambda_create_unit`

			# The JSON Object:

				SET @json_object = (
						JSON_OBJECT(
						'unitCreationRequestId' , @unit_creation_request_id
						, 'actionType', @action_type
						, 'creatorId', @creator_id
						, 'name', @uneet_name
						, 'type', @unee_t_unit_type
						, 'moreInfo', @more_info
						, 'streetAddress', @street_address
						, 'city', @city
						, 'state', @state
						, 'zipCode', @zip_code
						, 'country', @country
						, 'ownerId', @owner_id
						)
					)
					;

			# The specific lambda:

				SET @lambda = CONCAT('arn:aws:lambda:ap-southeast-1:'
					, @lambda_key
					, ':function:alambda_simple')
					;
			
			# The specific Lambda CALL:

				SET @lambda_call = CONCAT('CALL mysql.lambda_async'
					, @lambda
					, @json_object
					)
					;

		# Now that we have simulated what the CALL does, we record that

			INSERT INTO `log_lambdas`
				(`created_datetime`
				, `creation_trigger`
				, `associated_call`
				, `mefe_unit_id`
				, `unit_name`
				, `mefe_user_id`
				, `payload`
				)
				VALUES
					(NOW()
					, @this_trigger
					, @associated_procedure
					, 'n/a'
					, @uneet_name
					, 'n/a'
					, @lambda_call
					)
					;

	# We call the Lambda procedure to create a unit

		CALL `lambda_create_unit`(@unit_creation_request_id
			, @action_type
			, @creator_id
			, @uneet_name
			, @unee_t_unit_type
			, @more_info
			, @street_address
			, @city
			, @state
			, @zip_code
			, @country
			, @owner_id
			)
			;

	END IF;
END */$$


DELIMITER ;

/* Trigger structure for table `ut_map_external_source_units` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_update_unit_already_exists` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_update_unit_already_exists` AFTER UPDATE ON `ut_map_external_source_units` FOR EACH ROW 
BEGIN

# We only do this IF:
#	- The variable @disable_lambda != 1
#	- We have a MEFE Unit ID
#	- this unit is marked a `is_update_needed` = 1
#	- This is done via an authorized update method:
#		- 'ut_update_map_external_source_unit_edit_level_1'
#		- 'ut_update_map_external_source_unit_edit_level_2'
#		- 'ut_update_map_external_source_unit_edit_level_3'
#		- ''
#		- ''
#		- ''

	SET @mefe_unit_id = NEW.`unee_t_mefe_unit_id` ;

	SET @is_update_needed = NEW.`is_update_needed` ;

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;

	IF @mefe_unit_id IS NOT NULL
		AND @is_update_needed = 1
		AND (@upstream_create_method = 'ut_update_map_external_source_unit_edit_level_1'
			OR @upstream_update_method = 'ut_update_map_external_source_unit_edit_level_1'
			OR @upstream_create_method = 'ut_update_map_external_source_unit_edit_level_2'
			OR @upstream_update_method = 'ut_update_map_external_source_unit_edit_level_2'
			OR @upstream_create_method = 'ut_update_map_external_source_unit_edit_level_3'
			OR @upstream_update_method = 'ut_update_map_external_source_unit_edit_level_3'
			)
		AND (@disable_lambda != 1
			OR @disable_lambda IS NULL)
	THEN

		# The specifics

			# What is this trigger (for log_purposes)
				SET @this_trigger = 'ut_update_unit_already_exists';

			# What is the procedure associated with this trigger:
				SET @associated_procedure = 'lambda_update_unit';
			
			# lambda:
			# https://github.com/unee-t/lambda2sns/blob/master/tests/call-lambda-as-root.sh#L5
			#	- DEV/Staging: 812644853088
			#	- Prod: 192458993663
			#	- Demo: 915001051872

				SET @lambda_key = 812644853088;

			# MEFE API Key:
				SET @key_this_envo = 'ABCDEFG';

	# We define the variables we need
	# Where can we find the details about that unit?

		SET @new_record_id = NEW.`new_record_id`;		
		SET @external_property_type_id = NEW.`external_property_type_id`;

		SET @update_unit_request_id = (SELECT `id_map` 
			FROM `ut_map_external_source_units`
			WHERE `unee_t_mefe_unit_id` = @mefe_unit_id
			)
			;
		SET @action_type = 'EDIT_UNIT';
		SET @requestor_user_id = NEW.`updated_by_id`; 

		SET @creator_id = NEW.`created_by_id`;

		SET @unee_t_unit_type = NEW.`unee_t_unit_type`;
		SET @unee_t_unit_name = NEW.`uneet_name`;


		# More info:

			SET @more_info = (IF(@external_property_type_id = 1
					, (SELECT `more_info`
						FROM `ut_add_information_unit_level_1`
						WHERE `unit_level_1_id` = @new_record_id
						)
					, IF(@external_property_type_id = 2
						, (SELECT `more_info`
							FROM `ut_add_information_unit_level_2`
							WHERE `unit_level_2_id` = @new_record_id
							)
						, IF(@external_property_type_id = 3
							, (SELECT `more_info`
								FROM `ut_add_information_unit_level_3`
								WHERE `unit_level_3_id` = @new_record_id
								)
							, 'ERROR 3499'
							) 
						)
					)
				)
				;
			SET @more_info_not_null = (IFNULL(@more_info
					, ''
					)
				)
				;
		# Street Address

			SET @street_address = (IF(@external_property_type_id = 1
					, (SELECT `street_address`
						FROM `ut_add_information_unit_level_1`
						WHERE `unit_level_1_id` = @new_record_id
						)
					, IF(@external_property_type_id = 2
						, (SELECT `street_address`
							FROM `ut_add_information_unit_level_2`
							WHERE `unit_level_2_id` = @new_record_id
							)
						, IF(@external_property_type_id = 3
							, (SELECT `street_address`
								FROM `ut_add_information_unit_level_3`
								WHERE `unit_level_3_id` = @new_record_id
								)
							, 'ERROR 3527'
							) 
						)
					)
				)
				;

			SET @street_address_not_null = (IFNULL(@street_address
					, ''
					)
				)
				;
		
		# City

			SET @city = (IF(@external_property_type_id = 1
					, (SELECT `city`
						FROM `ut_add_information_unit_level_1`
						WHERE `unit_level_1_id` = @new_record_id
						)
					, IF(@external_property_type_id = 2
						, (SELECT `city`
							FROM `ut_add_information_unit_level_2`
							WHERE `unit_level_2_id` = @new_record_id
							)
						, IF(@external_property_type_id = 3
							, (SELECT `city`
								FROM `ut_add_information_unit_level_3`
								WHERE `unit_level_3_id` = @new_record_id
								)
							, 'ERROR 3557'
							) 
						)
					)
				)
				;

			SET @city_not_null = (IFNULL(@city
					, ''
					)
				)
				;
		# State

			SET @state = (IF(@external_property_type_id = 1
					, (SELECT `state`
						FROM `ut_add_information_unit_level_1`
						WHERE `unit_level_1_id` = @new_record_id
						)
					, IF(@external_property_type_id = 2
						, (SELECT `state`
							FROM `ut_add_information_unit_level_2`
							WHERE `unit_level_2_id` = @new_record_id
							)
						, IF(@external_property_type_id = 3
							, (SELECT `state`
								FROM `ut_add_information_unit_level_3`
								WHERE `unit_level_3_id` = @new_record_id
								)
							, 'ERROR 3586'
							) 
						)
					)
				)
				;

			SET @state_not_null = (IFNULL(@state
					, ''
					)
				)
				;
			
		# Zip Code

			SET @zip_code = (IF(@external_property_type_id = 1
					, (SELECT `zip_code`
						FROM `ut_add_information_unit_level_1`
						WHERE `unit_level_1_id` = @new_record_id
						)
					, IF(@external_property_type_id = 2
						, (SELECT `zip_code`
							FROM `ut_add_information_unit_level_2`
							WHERE `unit_level_2_id` = @new_record_id
							)
						, IF(@external_property_type_id = 3
							, (SELECT `zip_code`
								FROM `ut_add_information_unit_level_3`
								WHERE `unit_level_3_id` = @new_record_id
								)
							, 'ERROR 3616'
							) 
						)
					)
				)
				;

			SET @zip_code_not_null = (IFNULL(@zip_code
					, ''
					)
				)
				;
		
		# Country

			SET @country = (IF(@external_property_type_id = 1
					, (SELECT `country`
						FROM `ut_add_information_unit_level_1`
						WHERE `unit_level_1_id` = @new_record_id
						)
					, IF(@external_property_type_id = 2
						, (SELECT `country`
							FROM `ut_add_information_unit_level_2`
							WHERE `unit_level_2_id` = @new_record_id
							)
						, IF(@external_property_type_id = 3
							, (SELECT `country`
								FROM `ut_add_information_unit_level_3`
								WHERE `unit_level_3_id` = @new_record_id
								)
							, 'ERROR 522'
							) 
						)
					)
				)
				;

			SET @country_not_null = (IFNULL(@country
					, ''
					)
				)
				;

	# We insert the event in the relevant log table

		# Simulate what the Procedure `lambda_update_unit` does
		# Make sure to update that if you update the procedure `lambda_update_unit`

			# The JSON Object:

				SET @json_object = (
						JSON_OBJECT(
							'updateUnitRequestId' , @update_unit_request_id
							, 'actionType', @action_type
							, 'requestorUserId', @requestor_user_id
							, 'unitId', @mefe_unit_id
							, 'creatorId', @creator_id
							, 'type', @unee_t_unit_type
							, 'name', @unee_t_unit_name
							, 'moreInfo', @more_info
							, 'streetAddress', @street_address
							, 'city', @city
							, 'state', @state
							, 'zipCode', @zip_code
							, 'country', @country
						)
					)
					;

			# The specific lambda:

				SET @lambda = CONCAT('arn:aws:lambda:ap-southeast-1:'
					, @lambda_key
					, ':function:alambda_simple')
					;
			
			# The specific Lambda CALL:

				SET @lambda_call = CONCAT('CALL mysql.lambda_async'
					, @lambda
					, @json_object
					)
					;

		# Now that we have simulated what the CALL does, we record that

			SET @unit_name := (SELECT `uneet_name`
				FROM `ut_map_external_source_units`
				WHERE `unee_t_mefe_unit_id` = @mefe_unit_id
				);

			INSERT INTO `log_lambdas`
				(`created_datetime`
				, `creation_trigger`
				, `associated_call`
				, `mefe_unit_id`
				, `unit_name`
				, `mefe_user_id`
				, `payload`
				)
				VALUES
					(NOW()
					, @this_trigger
					, @associated_procedure
					, @mefe_unit_id
					, @unit_name
					, 'n/a'
					, @lambda_call
					)
					;

	# We call the Lambda procedure to update the unit

		CALL `lambda_update_unit`(@update_unit_request_id
			, @action_type
			, @requestor_user_id
			, @mefe_unit_id
			, @creator_id
			, @unee_t_unit_type
			, @unee_t_unit_name
			, @more_info
			, @street_address
			, @city
			, @state
			, @zip_code
			, @country
			)
			;

	END IF;
END */$$


DELIMITER ;

/* Trigger structure for table `ut_map_external_source_users` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_create_user` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_create_user` AFTER INSERT ON `ut_map_external_source_users` FOR EACH ROW 
BEGIN

# We only do this IF:
#	- The variable @disable_lambda != 1
#	- This is done via an authorized create method:
#WIP		- 'ut_update_map_uneet_user_person_ut_account_creation_needed'
#WIP		- 'ut_update_map_uneet_user_person'
#WIP		- 'retry_create_user'
#		- ''
#		- ''
#		- ''

	SET @upstream_create_method_8_1 = NEW.`creation_method` ;
	SET @upstream_update_method_8_1 = NEW.`update_method` ;

	IF (@disable_lambda != 1
			OR @disable_lambda IS NULL)
	/*	AND (@upstream_create_method_8_1 = 'ut_update_map_uneet_user_person_ut_account_creation_needed'
			OR @upstream_update_method_8_1 = 'ut_update_map_uneet_user_person_ut_account_creation_needed'
			OR @upstream_create_method_8_1 = 'ut_update_map_uneet_user_person'
			OR @upstream_update_method_8_1 = 'ut_update_map_uneet_user_person'
			OR @upstream_create_method_8_1 = 'retry_create_user'
			OR @upstream_update_method_8_1 = 'retry_create_user'
		)
	*/
	THEN 

		# The specifics

			# What is this trigger (for log_purposes)
				SET @this_trigger_8_1 = 'ut_create_user';

			# What is the procedure associated with this trigger:
				SET @associated_procedure = 'lambda_create_user';
			
			# lambda:
			# https://github.com/unee-t/lambda2sns/blob/master/tests/call-lambda-as-root.sh#L5
			#	- DEV/Staging: 812644853088
			#	- Prod: 192458993663
			#	- Demo: 915001051872
	
					SET @lambda_key = 812644853088;

			# MEFE API Key:
				SET @key_this_envo = 'ABCDEFG';

	# We define the variables we need now

		SET @lambda_id = @lambda_key;
		SET @mefe_api_key = @key_this_envo;
		SET @person_id = NEW.`person_id`;

	# The variables we need in the Lambda payload:

		SET @user_creation_request_id = (SELECT `id_map` 
			FROM `ut_map_external_source_users`
			WHERE `person_id` = @person_id
			)
			;
		SET @action_type = 'CREATE_USER';
		SET @creator_id = NEW.`created_by_id` ;
		SET @email_address = (SELECT `email_address` 
			FROM `ut_user_information_persons`
			WHERE `id_person` = @person_id
			)
			;
		SET @first_name = (SELECT `first_name` 
			FROM `ut_user_information_persons`
			WHERE `id_person` = @person_id
			)
			;
		SET @last_name = (SELECT `last_name` 
			FROM `ut_user_information_persons`
			WHERE `id_person` = @person_id
			)
			;
		SET @phone_number = (SELECT `phone_number` 
			FROM `ut_user_information_persons`
			WHERE `id_person` = @person_id
			)
			;

	# We insert the event in the relevant log table

		# Simulate what the Procedure `lambda_create_user` does
		# Make sure to update that if you update the procedure `lambda_create_user`

			# The JSON Object:

				SET @json_object = (
						JSON_OBJECT(
							'userCreationRequestId' , @user_creation_request_id
							, 'actionType', @action_type
							, 'creatorId', @creator_id
							, 'emailAddress', @email_address
							, 'firstName', @first_name
							, 'lastName', @last_name
							, 'phoneNumber', @phone_number
						)
					)
					;

			# The specific lambda:

				SET @lambda = CONCAT('arn:aws:lambda:ap-southeast-1:'
					, @lambda_key
					, ':function:alambda_simple')
					;
			
			# The specific Lambda CALL:

				SET @lambda_call = CONCAT('CALL mysql.lambda_async'
					, @lambda
					, @json_object
					)
					;

		# Now that we have simulated what the CALL does, we record that

				INSERT INTO `log_lambdas`
					 (`created_datetime`
					 , `creation_trigger`
					 , `associated_call`
					 , `mefe_unit_id`
					 , `mefe_user_id`
					 , `unee_t_login`
					 , `payload`
					 )
					 VALUES
						(NOW()
						, @this_trigger_8_1
						, @associated_procedure
						, 'n/a'
						, 'n/a'
						, @email_address
						, @lambda_call
						)
						;

	# We call the Lambda procedure to create the user

		CALL `lambda_create_user`(@user_creation_request_id
			, @action_type
			, @creator_id
			, @email_address
			, @first_name
			, @last_name
			, @phone_number
			)
			;
	
	END IF;
END */$$


DELIMITER ;

/* Trigger structure for table `ut_map_external_source_users` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_assign_person_to_all_units` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_assign_person_to_all_units` AFTER UPDATE ON `ut_map_external_source_users` FOR EACH ROW 
BEGIN

# We do this ONLY if
#	- We have a MEFE user ID for that user
#	- The field `is_all_unit` in the table `ut_user_types` for the user type selected for this user is = 1
#	- This is an authorized method:
#		- `ut_creation_user_mefe_api_reply`
#		- ``

	SET @person_id_create_person_1 := NEW.`person_id` ;

	SET @unee_t_user_type_id_create_person_1 := (SELECT `unee_t_user_type_id`
		FROM `persons`
		WHERE `id_person` = @person_id_create_person_1
		);

	SET @is_all_units_create_person_1 := (SELECT `is_all_unit`
		FROM `ut_user_types`
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_create_person_1
		);

	SET @unee_t_mefe_user_id_create_person_1 := NEW.`unee_t_mefe_user_id` ;

	SET @upstream_update_method_create_person_1 := NEW.`update_method` ;

	IF @is_all_units_create_person_1 = 1
		  AND @unee_t_mefe_user_id_create_person_1 IS NOT NULL
		  AND (@upstream_update_method_create_person_1 = 'ut_creation_user_mefe_api_reply'
		  	)
	THEN 

	# We get the variables we need:

		SET @syst_created_datetime_create_person_1 := NOW() ;
		SET @creation_system_id_create_person_1 := 2 ;
		SET @created_by_id_create_person_1 := NEW.`created_by_id` ;
		SET @creation_method_create_person_1 := 'ut_assign_person_to_all_units' ;

		SET @syst_updated_datetime_create_person_1 := NOW() ;
		SET @update_system_id_create_person_1 := 2 ;
		SET @updated_by_id_create_person_1 := @created_by_id_create_person_1 ;
		SET @update_method_create_person_1 := @creation_method_create_person_1 ;

		SET @organization_id_create_person_1 := NEW.`organization_id`;
		SET @is_obsolete_create_person_1 = 0 ;
		SET @is_update_needed_create_person_1 = 1 ;

		SET @unee_t_role_id_create_person_1 := (SELECT `ut_user_role_type_id`
			FROM `ut_user_types`
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_create_person_1
			);

		SET @is_occupant := (SELECT `is_occupant` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_create_person_1
			);

		SET @propagate_to_all_level_2 = 1 ;
		SET @propagate_to_all_level_3 = 1 ;

		# additional permissions 
		SET @is_default_assignee := (SELECT `is_default_assignee` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_create_person_1
			);
		SET @is_default_invited := (SELECT `is_default_invited` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_create_person_1
			);
		SET @is_unit_owner := (SELECT `is_unit_owner` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_create_person_1
			);

		# Visibility rules 
		SET @is_public := (SELECT `is_public` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_create_person_1
			);
		SET @can_see_role_landlord := (SELECT `can_see_role_landlord` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_create_person_1
			);
		SET @can_see_role_tenant := (SELECT `can_see_role_tenant` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_create_person_1
			);
		SET @can_see_role_mgt_cny := (SELECT `can_see_role_mgt_cny` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_create_person_1
			);
		SET @can_see_role_agent := (SELECT `can_see_role_agent` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_create_person_1
			);
		SET @can_see_role_contractor := (SELECT `can_see_role_contractor` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_create_person_1
			);
		SET @can_see_occupant := (SELECT `can_see_occupant` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_create_person_1
			);

		# Notification rules 
		# - case - information 
		SET @is_assigned_to_case := (SELECT `is_assigned_to_case` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_create_person_1
			);
		SET @is_invited_to_case := (SELECT `is_invited_to_case` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_create_person_1
			);
		SET @is_next_step_updated := (SELECT `is_next_step_updated` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_create_person_1
			);
		SET @is_deadline_updated := (SELECT `is_deadline_updated` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_create_person_1
			);
		SET @is_solution_updated := (SELECT `is_solution_updated` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_create_person_1
			);
		SET @is_case_resolved := (SELECT `is_case_resolved` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_create_person_1
			);
		SET @is_case_blocker := (SELECT `is_case_blocker` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_create_person_1
			);
		SET @is_case_critical := (SELECT `is_case_critical` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_create_person_1
			);

		# - case - messages 
		SET @is_any_new_message := (SELECT `is_any_new_message` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_create_person_1
			);
		SET @is_message_from_tenant := (SELECT `is_message_from_tenant` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_create_person_1
			);
		SET @is_message_from_ll := (SELECT `is_message_from_ll` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_create_person_1
			);
		SET @is_message_from_occupant := (SELECT `is_message_from_occupant` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_create_person_1
			);
		SET @is_message_from_agent := (SELECT `is_message_from_agent` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_create_person_1
			);
		SET @is_message_from_mgt_cny := (SELECT `is_message_from_mgt_cny` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_create_person_1
			);
		SET @is_message_from_contractor := (SELECT `is_message_from_contractor` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_create_person_1
			);

		# - Inspection Reports 
		SET @is_new_ir := (SELECT `is_new_ir` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_create_person_1
			);

		# - Inventory 
		SET @is_new_item := (SELECT `is_new_item` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_create_person_1
			);
		SET @is_item_removed := (SELECT `is_item_removed` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_create_person_1
			);
		SET @is_item_moved := (SELECT `is_item_moved` 
			FROM `ut_user_types` 
			WHERE `id_unee_t_user_type` = @unee_t_user_type_id_create_person_1
			);

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
		#	- The id of the organization is in the variable @organization_id_create_person_1
		#	- The ids of the buildings are in the view `ut_list_mefe_unit_id_level_1_by_area`
		# We need to insert all these data in the table `temp_user_unit_role_permissions_level_3`

			SET @created_by_id := (SELECT `organization_id`
				FROM `ut_api_keys` 
				WHERE `mefe_user_id` = @created_by_id_create_person_1
				)
				;

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
				SELECT @syst_created_datetime_create_person_1
					, @creation_system_id_create_person_1
					, @created_by_id
					, @created_by_id_create_person_1
					, @creation_method_create_person_1
					, @organization_id_create_person_1
					, @is_obsolete_create_person_1
					, @is_update_needed_create_person_1
					, @unee_t_mefe_user_id_create_person_1
					, `a`.`level_1_building_id`
					, `a`.`external_level_1_building_id`
					, `a`.`unee_t_mefe_unit_id`
					, @unee_t_user_type_id_create_person_1
					, @unee_t_role_id_create_person_1
					FROM `ut_list_mefe_unit_id_level_1_by_area` AS `a`
					WHERE `a`.`organization_id` = @organization_id_create_person_1
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
		#	- The id of the organization is in the variable @organization_id_create_person_1
		#	- The ids of the units are in the view `ut_list_mefe_unit_id_level_2_by_area`
		# We need to insert all these data in the table `temp_user_unit_role_permissions_level_2`

			SET @created_by_id = (SELECT `organization_id`
				FROM `ut_api_keys` 
				WHERE `mefe_user_id` = @created_by_id_create_person_1
				)
				;

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
					@syst_created_datetime_create_person_1
					, @creation_system_id_create_person_1
					, @created_by_id
					, @created_by_id_create_person_1
					, @creation_method_create_person_1
					, @organization_id_create_person_1
					, @is_obsolete_create_person_1
					, @is_update_needed_create_person_1
					, @unee_t_mefe_user_id_create_person_1
					, `a`.`level_2_unit_id`
					, `a`.`external_level_2_unit_id`
					, `a`.`unee_t_mefe_unit_id`
					, @unee_t_user_type_id_create_person_1
					, @unee_t_role_id_create_person_1
					FROM `ut_list_mefe_unit_id_level_2_by_area` AS `a`
					INNER JOIN `ut_list_mefe_unit_id_level_1_by_area` AS `b`
						ON (`a`.`level_1_building_id` = `b`.`level_1_building_id` )
					WHERE `a`.`organization_id` = @organization_id_create_person_1
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
		#	- The id of the organization is in the variable @organization_id_create_person_1
		#	- The ids of the rooms are in the view `ut_list_mefe_unit_id_level_3_by_area`
		# We need to insert all these data in the table `temp_user_unit_role_permissions_level_3`

			SET @created_by_id := (SELECT `organization_id`
				FROM `ut_api_keys` 
				WHERE `mefe_user_id` = @created_by_id_create_person_1
				)
				;

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
					 @syst_created_datetime_create_person_1
					, @creation_system_id_create_person_1
					, @created_by_id
					, @created_by_id_create_person_1
					, @creation_method_create_person_1
					, @organization_id_create_person_1
					, @is_obsolete_create_person_1
					, @is_update_needed_create_person_1
					, @unee_t_mefe_user_id_create_person_1
					, `a`.`level_3_room_id`
					, `a`.`external_level_3_room_id`
					, `a`.`unee_t_mefe_unit_id`
					, @unee_t_user_type_id_create_person_1
					, @unee_t_role_id_create_person_1
					FROM `ut_list_mefe_unit_id_level_3_by_area` AS `a`
					INNER JOIN `ut_list_mefe_unit_id_level_2_by_area` AS `b`
						ON (`b`.`level_2_unit_id` = `a`.`level_2_unit_id`)
					WHERE `a`.`organization_id` = @organization_id_create_person_1
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
END */$$


DELIMITER ;

/* Trigger structure for table `ut_map_user_permissions_unit_all` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_add_user_to_role_in_unit_with_visibility` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_add_user_to_role_in_unit_with_visibility` AFTER INSERT ON `ut_map_user_permissions_unit_all` FOR EACH ROW 
BEGIN

# We only do this IF:
#	- The variable @disable_lambda != 1
#WIP	- This is done via an authorized insert method:
#WIP		- 'ut_add_user_to_role_in_a_level_3_property'
#WIP		- 'ut_add_user_to_role_in_a_level_2_property'
#WIP		- 'ut_add_user_to_role_in_a_level_1_property'
#WIP		- ''
#WIP		- ''
#

	SET @upstream_create_method_8_3 = NEW.`creation_method` ;
	SET @upstream_update_method_8_3 = NEW.`update_method` ;

	IF (@disable_lambda != 1
		OR @disable_lambda IS NULL)
	THEN 

		# The specifics

			# What is this trigger (for log_purposes)
				SET @this_trigger_8_3 = 'ut_add_user_to_role_in_unit_with_visibility';

			# What is the procedure associated with this trigger:
				SET @associated_procedure = 'lambda_add_user_to_role_in_unit_with_visibility';
			
			# lambda:
			# https://github.com/unee-t/lambda2sns/blob/master/tests/call-lambda-as-root.sh#L5
			#	- DEV/Staging: 812644853088
			#	- Prod: 192458993663
			#	- Demo: 915001051872

				SET @lambda_key = 812644853088;

			# MEFE API Key:
				SET @key_this_envo = 'ABCDEFG';

	# The variables that we need:

		SET @mefe_api_request_id = NEW.`id_map_user_unit_permissions` ;

		SET @action_type = 'ASSIGN_ROLE' ;

		SET @requestor_mefe_user_id = NEW.`created_by_id` ;
		
		SET @invited_mefe_user_id = NEW.`unee_t_mefe_id` ;
		SET @mefe_unit_id = NEW.`unee_t_unit_id` ;
		SET @role_type = (SELECT `role_type`
			FROM `ut_user_role_types`
			WHERE `id_role_type` = NEW.`unee_t_role_id` 
			)
			;
		
		SET @is_occupant = NEW.`is_occupant`= 1 ;
		SET @is_occupant_not_null = (IFNULL(@is_occupant
				, 0
				)
			)
			;
		SET @is_occupant_json = IF(NEW.`is_occupant`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @is_visible = NEW.`is_public`= 1 ;
		SET @is_visible_not_null = (IFNULL(@is_visible
				, 0
				)
			)
			;
		SET @is_visible_json = IF(NEW.`is_public`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @is_default_assignee = NEW.`is_default_assignee`= 1 ;
		SET @is_default_assignee_not_null = (IFNULL(@is_default_assignee
				, 0
				)
			)
			;
		SET @is_default_assignee_json = IF(NEW.`is_default_assignee`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @is_default_invited = NEW.`is_default_invited` ;
		SET @is_default_invited_not_null = (IFNULL(@is_default_invited
				, 0
				)
			)
			;
		SET @is_default_invited_json = IF(NEW.`is_default_invited`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @can_see_role_agent = NEW.`can_see_role_agent`;
		SET @can_see_role_agent_not_null = (IFNULL(@can_see_role_agent
				, 0
				)
			)
			;
		SET @can_see_role_agent_json = IF(NEW.`can_see_role_agent`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @can_see_role_tenant = NEW.`can_see_role_tenant`;
		SET @can_see_role_tenant_not_null = (IFNULL(@can_see_role_tenant
				, 0
				)
			)
			;
		SET @can_see_role_tenant_json = IF(NEW.`can_see_role_tenant`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @can_see_role_landlord = NEW.`can_see_role_landlord`;
		SET @can_see_role_landlord_not_null = (IFNULL(@can_see_role_landlord
				, 0
				)
			)
			;
		SET @can_see_role_landlord_json = IF(NEW.`can_see_role_landlord`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @can_see_role_mgt_cny = NEW.`can_see_role_mgt_cny`;
		SET @can_see_role_mgt_cny_not_null = (IFNULL(@can_see_role_mgt_cny
				, 0
				)
			)
			;
		SET @can_see_role_mgt_cny_json = IF(NEW.`can_see_role_mgt_cny`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @can_see_role_contractor = NEW.`can_see_role_contractor`;
		SET @can_see_role_contractor_not_null = (IFNULL(@can_see_role_contractor
				, 0
				)
			)
			;
		SET @can_see_role_contractor_json = IF(NEW.`can_see_role_contractor`= 1
			, 'true'
			, 'false'
		 	)
			; 

		SET @can_see_occupant = NEW.`can_see_occupant` ; 
		SET @can_see_occupant_not_null = (IFNULL(@can_see_occupant
				, 0
				)
			)
			;
		SET @can_see_occupant_json = IF(NEW.`can_see_occupant`= 1
			, 'true'
			, 'false'
		 	)
			; 
	
	# We insert the event in the relevant log table

		# Simulate what the Procedure `lambda_add_user_to_role_in_unit_with_visibility` does
		# Make sure to update that if you update the procedure `lambda_add_user_to_role_in_unit_with_visibility`

			# The JSON Object:

				SET @json_object = (
					JSON_OBJECT(
						'mefeAPIRequestId' , @mefe_api_request_id
						, 'actionType', @action_type
						, 'requestorUserId', @requestor_mefe_user_id
						, 'addedUserId', @invited_mefe_user_id
						, 'unitId', @mefe_unit_id
						, 'roleType', @role_type
						, 'isOccupant', @is_occupant
						, 'isVisible', @is_visible
						, 'isDefaultAssignee', @is_default_assignee
						, 'isDefaultInvited', @is_default_invited
						, 'roleVisibility' , JSON_OBJECT('Agent', @can_see_role_agent
							, 'Tenant', @can_see_role_tenant
							, 'Owner/Landlord', @can_see_role_landlord
							, 'Management Company', @can_see_role_mgt_cny
							, 'Contractor', @can_see_role_contractor
							, 'Occupant', @can_see_occupant
							)
						)
					)
					;

			# The specific lambda:

				SET @lambda = CONCAT('arn:aws:lambda:ap-southeast-1:'
					, @lambda_key
					, ':function:alambda_simple')
					;
			
			# The specific Lambda CALL:

				SET @lambda_call = CONCAT('CALL mysql.lambda_async'
					, @lambda
					, @json_object
					)
					;

		# Now that we have simulated what the CALL does, we record that

			SET @unit_name := (SELECT `uneet_name`
				FROM `ut_map_external_source_units`
				WHERE `unee_t_mefe_unit_id` = @mefe_unit_id
				);
			SET @unee_t_login := (SELECT `uneet_login_name`
				FROM `ut_map_external_source_users`
				WHERE `unee_t_mefe_user_id` = @invited_mefe_user_id
				);

			INSERT INTO `log_lambdas`
				(`created_datetime`
				, `creation_trigger`
				, `associated_call`
				, `mefe_unit_id`
				, `unit_name`
				, `mefe_user_id`
				, `unee_t_login`
				, `payload`
				)
				VALUES
					(NOW()
					, @this_trigger_8_3
					, @associated_procedure
					, @mefe_unit_id
					, @unit_name
					, @invited_mefe_user_id
					, @unee_t_login
					, @lambda_call
					)
					;

	# We call the Lambda procedure to add a user to a role in a unit

		CALL `lambda_add_user_to_role_in_unit_with_visibility`(@mefe_api_request_id
			, @action_type
			, @requestor_mefe_user_id
			, @invited_mefe_user_id
			, @mefe_unit_id
			, @role_type
			, @is_occupant
			, @is_visible
			, @is_default_assignee
			, @is_default_invited
			, @can_see_role_agent
			, @can_see_role_tenant
			, @can_see_role_landlord
			, @can_see_role_mgt_cny
			, @can_see_role_contractor
			, @can_see_occupant
			)
			;

	END IF;
END */$$


DELIMITER ;

/* Trigger structure for table `ut_map_user_permissions_unit_all` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_add_user_to_role_in_unit_with_visibility_update` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_add_user_to_role_in_unit_with_visibility_update` AFTER UPDATE ON `ut_map_user_permissions_unit_all` FOR EACH ROW 
BEGIN

# We only do this IF:
#	- The variable @disable_lambda != 1
#	- The record is not marked as obsolete
#	- The record is marked as update needed
#	- This is done via an authorized method:
#		- 'ut_add_user_to_role_in_unit_with_visibility_level_1'
#		- 'ut_add_user_to_role_in_unit_with_visibility_level_2'
#		- 'ut_add_user_to_role_in_unit_with_visibility_level_3'
#		- ''
#		- ''
#		- ''
#		- ''
#

	SET @upstream_create_method = NEW.`creation_method` ;
	SET @upstream_update_method = NEW.`update_method` ;

	SET @is_obsolete = NEW.`is_obsolete` ;
	SET @is_update_needed = NEW.`is_update_needed` ;

	IF (@disable_lambda != 1
		OR @disable_lambda IS NULL)
		AND @is_obsolete = 0
		AND @is_update_needed = 1
		AND (@upstream_update_method = 'ut_add_user_to_role_in_unit_with_visibility_level_1'
			OR @upstream_update_method = 'ut_add_user_to_role_in_unit_with_visibility_level_2'
			OR @upstream_update_method = 'ut_add_user_to_role_in_unit_with_visibility_level_3'
			)
	THEN 

		# The specifics

			# What is this trigger (for log_purposes)
				SET @this_trigger = 'ut_add_user_to_role_in_unit_with_visibility_update';

			# What is the procedure associated with this trigger:
				SET @associated_procedure = 'lambda_add_user_to_role_in_unit_with_visibility';
			
			# lambda:
			# https://github.com/unee-t/lambda2sns/blob/master/tests/call-lambda-as-root.sh#L5
			#	- DEV/Staging: 812644853088
			#	- Prod: 192458993663
			#	- Demo: 915001051872

				SET @lambda_key = 192458993663;

			# MEFE API Key:
				SET @key_this_envo = 'ABCDEFG';

	# The variables that we need:

		SET @mefe_api_request_id = NEW.`id_map_user_unit_permissions` ;

		SET @action_type = 'ASSIGN_ROLE' ;

		SET @requestor_mefe_user_id = NEW.`created_by_id` ;
		
		SET @invited_mefe_user_id = NEW.`unee_t_mefe_id` ;
		SET @mefe_unit_id = NEW.`unee_t_unit_id` ;
		SET @role_type = (SELECT `role_type`
			FROM `ut_user_role_types`
			WHERE `id_role_type` = NEW.`unee_t_role_id` 
			)
			;
		
		SET @is_occupant = NEW.`is_occupant`= 1 ;
		SET @is_occupant_not_null = (IFNULL(@is_occupant
				, 0
				)
			)
			;
		SET @is_occupant_json = IF(NEW.`is_occupant`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @is_visible = NEW.`is_public`= 1 ;
		SET @is_visible_not_null = (IFNULL(@is_visible
				, 0
				)
			)
			;
		SET @is_visible_json = IF(NEW.`is_public`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @is_default_assignee = NEW.`is_default_assignee`= 1 ;
		SET @is_default_assignee_not_null = (IFNULL(@is_default_assignee
				, 0
				)
			)
			;
		SET @is_default_assignee_json = IF(NEW.`is_default_assignee`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @is_default_invited = NEW.`is_default_invited` ;
		SET @is_default_invited_not_null = (IFNULL(@is_default_invited
				, 0
				)
			)
			;
		SET @is_default_invited_json = IF(NEW.`is_default_invited`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @can_see_role_agent = NEW.`can_see_role_agent`;
		SET @can_see_role_agent_not_null = (IFNULL(@can_see_role_agent
				, 0
				)
			)
			;
		SET @can_see_role_agent_json = IF(NEW.`can_see_role_agent`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @can_see_role_tenant = NEW.`can_see_role_tenant`;
		SET @can_see_role_tenant_not_null = (IFNULL(@can_see_role_tenant
				, 0
				)
			)
			;
		SET @can_see_role_tenant_json = IF(NEW.`can_see_role_tenant`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @can_see_role_landlord = NEW.`can_see_role_landlord`;
		SET @can_see_role_landlord_not_null = (IFNULL(@can_see_role_landlord
				, 0
				)
			)
			;
		SET @can_see_role_landlord_json = IF(NEW.`can_see_role_landlord`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @can_see_role_mgt_cny = NEW.`can_see_role_mgt_cny`;
		SET @can_see_role_mgt_cny_not_null = (IFNULL(@can_see_role_mgt_cny
				, 0
				)
			)
			;
		SET @can_see_role_mgt_cny_json = IF(NEW.`can_see_role_mgt_cny`= 1
			, 'true'
			, 'false'
		 	)
			;

		SET @can_see_role_contractor = NEW.`can_see_role_contractor`;
		SET @can_see_role_contractor_not_null = (IFNULL(@can_see_role_contractor
				, 0
				)
			)
			;
		SET @can_see_role_contractor_json = IF(NEW.`can_see_role_contractor`= 1
			, 'true'
			, 'false'
		 	)
			; 

		SET @can_see_occupant = NEW.`can_see_occupant` ; 
		SET @can_see_occupant_not_null = (IFNULL(@can_see_occupant
				, 0
				)
			)
			;
		SET @can_see_occupant_json = IF(NEW.`can_see_occupant`= 1
			, 'true'
			, 'false'
		 	)
			; 
	
	# We insert the event in the relevant log table

		# Simulate what the Procedure `lambda_add_user_to_role_in_unit_with_visibility` does
		# Make sure to update that if you update the procedure `lambda_add_user_to_role_in_unit_with_visibility`

			# The JSON Object:

				SET @json_object = (
					JSON_OBJECT(
						'mefeAPIRequestId' , @mefe_api_request_id
						, 'actionType', @action_type
						, 'requestorUserId', @requestor_mefe_user_id
						, 'addedUserId', @invited_mefe_user_id
						, 'unitId', @mefe_unit_id
						, 'roleType', @role_type
						, 'isOccupant', @is_occupant
						, 'isVisible', @is_visible
						, 'isDefaultAssignee', @is_default_assignee
						, 'isDefaultInvited', @is_default_invited
						, 'roleVisibility' , JSON_OBJECT('Agent', @can_see_role_agent
							, 'Tenant', @can_see_role_tenant
							, 'Owner/Landlord', @can_see_role_landlord
							, 'Management Company', @can_see_role_mgt_cny
							, 'Contractor', @can_see_role_contractor
							, 'Occupant', @can_see_occupant
							)
						)
					)
					;

			# The specific lambda:

				SET @lambda = CONCAT('arn:aws:lambda:ap-southeast-1:'
					, @lambda_key
					, ':function:alambda_simple')
					;
			
			# The specific Lambda CALL:

				SET @lambda_call = CONCAT('CALL mysql.lambda_async'
					, @lambda
					, @json_object
					)
					;

		# Now that we have simulated what the CALL does, we record that

			INSERT INTO `log_lambdas`
				(`created_datetime`
				, `creation_trigger`
				, `associated_call`
				, `mefe_unit_id`
				, `mefe_user_id`
				, `payload`
				)
				VALUES
					(NOW()
					, @this_trigger
					, @associated_procedure
					, @mefe_unit_id
					, @invited_mefe_user_id
					, @lambda_call
					)
					;

	# We call the Lambda procedure to add a user to a role in a unit

		CALL `lambda_add_user_to_role_in_unit_with_visibility`(@mefe_api_request_id
			, @action_type
			, @requestor_mefe_user_id
			, @invited_mefe_user_id
			, @mefe_unit_id
			, @role_type
			, @is_occupant
			, @is_visible
			, @is_default_assignee
			, @is_default_invited
			, @can_see_role_agent
			, @can_see_role_tenant
			, @can_see_role_landlord
			, @can_see_role_mgt_cny
			, @can_see_role_contractor
			, @can_see_occupant
			)
			;

	END IF;
END */$$


DELIMITER ;

/* Trigger structure for table `ut_map_user_permissions_unit_level_3` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `ut_add_user_to_role_in_unit_with_visibility_level_3` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `ut_add_user_to_role_in_unit_with_visibility_level_3` AFTER INSERT ON `ut_map_user_permissions_unit_level_3` FOR EACH ROW 
BEGIN

# We only do this IF
#	- This is done via an authorized insert method:
#		- 'ut_add_user_to_role_in_a_level_3_property'
#

	SET @upstream_create_method_add_u_l3_2 = NEW.`creation_method` ;
	SET @upstream_update_method_add_u_l3_2 = NEW.`update_method` ;

	IF (@upstream_update_method_add_u_l3_2 = 'ut_add_user_to_role_in_a_level_3_property'
		)
	THEN 

	# We capture the variables that we need:

		SET @this_trigger = 'ut_add_user_to_role_in_unit_with_visibility_level_3' ;

		SET @syst_created_datetime = NOW() ;
		SET @creation_system_id = NEW.`creation_system_id` ;
		SET @created_by_id_add_u_l3_1 = NEW.`created_by_id` ;
		SET @creation_method = @this_trigger ;


		SET @syst_updated_datetime = NOW() ;
		SET @update_system_id = NEW.`creation_system_id` ;
		SET @updated_by_id_add_u_l3_1 = NEW.`created_by_id` ;
		SET @update_method = @this_trigger ;

		SET @organization_id = NEW.`organization_id`; 

		SET @is_obsolete = NEW.`is_obsolete` ;
		SET @is_update_needed = NULL ;

		SET @unee_t_mefe_user_id = NEW.`unee_t_mefe_id` ;
		SET @unee_t_mefe_unit_id = NEW.`unee_t_unit_id` ;

		SET @system_id_level_2 = (SELECT `new_record_id`
			FROM `ut_map_external_source_units`
			WHERE `unee_t_mefe_unit_id` = @unee_t_mefe_unit_id
				AND `external_property_type_id` = 2
			)
			;

		SET @unee_t_role_id = NEW.`unee_t_role_id` ;
		SET @is_occupant = NEW.`is_occupant` ;

		SET @is_default_assignee = NEW.`is_default_assignee` ;
		SET @is_default_invited = NEW.`is_default_invited` ;

		SET @is_unit_owner = NEW.`is_unit_owner` ;

		SET @is_public = NEW.`is_public` ;

		SET @can_see_role_landlord = NEW.`can_see_role_landlord` ;
		SET @can_see_role_tenant = NEW.`can_see_role_tenant` ;
		SET @can_see_role_mgt_cny = NEW.`can_see_role_mgt_cny` ;
		SET @can_see_role_agent = NEW.`can_see_role_agent` ;
		SET @can_see_role_contractor = NEW.`can_see_role_contractor` ;
		SET @can_see_occupant = NEW.`can_see_occupant` ;

		SET @is_assigned_to_case = NEW.`is_assigned_to_case` ;
		SET @is_invited_to_case = NEW.`is_invited_to_case` ;
		SET @is_next_step_updated = NEW.`is_next_step_updated` ;
		SET @is_deadline_updated = NEW.`is_deadline_updated` ;
		SET @is_solution_updated = NEW.`is_solution_updated` ;
		SET @is_case_resolved = NEW.`is_case_resolved` ;

		SET @is_case_blocker = NEW.`is_case_blocker` ;
		SET @is_case_critical = NEW.`is_case_critical` ;

		SET @is_any_new_message = NEW.`is_any_new_message` ;

		SET @is_message_from_tenant = NEW.`is_message_from_tenant` ;
		SET @is_message_from_ll = NEW.`is_message_from_ll` ;
		SET @is_message_from_occupant = NEW.`is_message_from_occupant` ;
		SET @is_message_from_agent = NEW.`is_message_from_agent` ;
		SET @is_message_from_mgt_cny = NEW.`is_message_from_mgt_cny` ;
		SET @is_message_from_contractor = NEW.`is_message_from_contractor` ;

		SET @is_new_ir = NEW.`is_new_ir` ;

		SET @is_new_item = NEW.`is_new_item` ;
		SET @is_item_removed = NEW.`is_item_removed` ;
		SET @is_item_moved = NEW.`is_item_moved` ;

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
			VALUES
				(@syst_created_datetime
				, @creation_system_id
				, @created_by_id_add_u_l3_1
				, @creation_method
				, @organization_id
				, @is_obsolete
				, @is_update_needed
				, @unee_t_mefe_user_id
				, @unee_t_mefe_unit_id
				, @unee_t_role_id
				, @is_occupant
				, @is_default_assignee
				, @is_default_invited
				, @is_unit_owner
				, @is_public
				, @can_see_role_landlord
				, @can_see_role_tenant
				, @can_see_role_mgt_cny
				, @can_see_role_agent
				, @can_see_role_contractor
				, @can_see_occupant
				, @is_assigned_to_case
				, @is_invited_to_case
				, @is_next_step_updated
				, @is_deadline_updated
				, @is_solution_updated
				, @is_case_resolved
				, @is_case_blocker
				, @is_case_critical
				, @is_any_new_message
				, @is_message_from_tenant
				, @is_message_from_ll
				, @is_message_from_occupant
				, @is_message_from_agent
				, @is_message_from_mgt_cny
				, @is_message_from_contractor
				, @is_new_ir
				, @is_new_item
				, @is_item_removed
				, @is_item_moved
				)
			ON DUPLICATE KEY UPDATE
				`syst_updated_datetime` = @syst_updated_datetime
				, `update_system_id` = @update_system_id
				, `updated_by_id` = @updated_by_id_add_u_l3_1
				, `update_method` = @update_method
				, `organization_id` = @organization_id
				, `is_obsolete` = @is_obsolete
				, `is_update_needed` = 1
				, `unee_t_mefe_id` = @unee_t_mefe_user_id
				, `unee_t_unit_id` = @unee_t_mefe_unit_id
				, `unee_t_role_id` = @unee_t_role_id
				, `is_occupant` = @is_occupant
				, `is_default_assignee` = @is_default_assignee
				, `is_default_invited` = @is_default_invited
				, `is_unit_owner` = @is_unit_owner
				, `is_public` = @is_public
				, `can_see_role_landlord` = @can_see_role_landlord
				, `can_see_role_tenant` = @can_see_role_tenant
				, `can_see_role_mgt_cny` = @can_see_role_mgt_cny
				, `can_see_role_agent` = @can_see_role_agent
				, `can_see_role_contractor` = @can_see_role_contractor
				, `can_see_occupant` = @can_see_occupant
				, `is_assigned_to_case` = @is_assigned_to_case
				, `is_invited_to_case` = @is_invited_to_case
				, `is_next_step_updated` = @is_next_step_updated
				, `is_deadline_updated` = @is_deadline_updated
				, `is_solution_updated` = @is_solution_updated
				, `is_case_resolved` = @is_case_resolved
				, `is_case_blocker` = @is_case_blocker
				, `is_case_critical` = @is_case_critical
				, `is_any_new_message` = @is_any_new_message
				, `is_message_from_tenant` = @is_message_from_tenant
				, `is_message_from_ll` = @is_message_from_ll
				, `is_message_from_occupant` = @is_message_from_occupant
				, `is_message_from_agent` = @is_message_from_agent
				, `is_message_from_mgt_cny` = @is_message_from_mgt_cny
				, `is_message_from_contractor` = @is_message_from_contractor
				, `is_new_ir` = @is_new_ir
				, `is_new_item` = @is_new_item
				, `is_item_removed` = @is_item_removed
				, `is_item_moved` = @is_item_moved
				;

	END IF;
END */$$


DELIMITER ;

/* Procedure structure for procedure `lambda_add_user_to_role_in_unit_with_visibility` */

/*!50003 DROP PROCEDURE IF EXISTS  `lambda_add_user_to_role_in_unit_with_visibility` */;

DELIMITER $$

/*!50003 CREATE PROCEDURE `lambda_add_user_to_role_in_unit_with_visibility`(
	IN mefe_api_request_id int(11)
	, IN action_type varchar(255)
	, IN requestor_mefe_user_id varchar(255)
	, IN invited_mefe_user_id varchar(255)
	, IN mefe_unit_id varchar(255)
	, IN role_type varchar(255)
	, IN is_occupant boolean
	, IN is_visible boolean
	, IN is_default_assignee boolean
	, IN is_default_invited boolean
	, IN can_see_role_agent boolean
	, IN can_see_role_tenant boolean
	, IN can_see_role_landlord boolean
	, IN can_see_role_mgt_cny boolean
	, IN can_see_role_contractor boolean
	, IN can_see_occupant boolean
	)
    SQL SECURITY INVOKER
BEGIN
		
		# Prepare the CALL argument that was prepared by the trigger
		# https://github.com/unee-t/lambda2sns/blob/master/tests/call-lambda-as-root.sh#L5
		#	- DEV/Staging: 812644853088
		#	- Prod: 192458993663
		#	- Demo: 915001051872

			CALL mysql.lambda_async (CONCAT('arn:aws:lambda:ap-southeast-1:812644853088:function:alambda_simple')
				, JSON_OBJECT(
					'mefeAPIRequestId' , mefe_api_request_id
					, 'actionType', action_type
					, 'requestorUserId', requestor_mefe_user_id
					, 'addedUserId', invited_mefe_user_id
					, 'unitId', mefe_unit_id
					, 'roleType', role_type
					, 'isOccupant', is_occupant
					, 'isVisible', is_visible
					, 'isDefaultAssignee', is_default_assignee
					, 'isDefaultInvited', is_default_invited
					, 'roleVisibility' , JSON_OBJECT('Agent', can_see_role_agent
						, 'Tenant', can_see_role_tenant
						, 'Owner/Landlord', can_see_role_landlord
						, 'Management Company', can_see_role_mgt_cny
						, 'Contractor', can_see_role_contractor
						, 'Occupant', can_see_occupant
						)
					)
				)
				;

END */$$
DELIMITER ;

/* Procedure structure for procedure `lambda_create_unit` */

/*!50003 DROP PROCEDURE IF EXISTS  `lambda_create_unit` */;

DELIMITER $$

/*!50003 CREATE PROCEDURE `lambda_create_unit`(
	IN unit_creation_request_id INT(11)
	, IN action_type VARCHAR(255)
	, IN creator_id VARCHAR(255)
	, IN uneet_name VARCHAR(255)
	, IN unee_t_unit_type VARCHAR(255)
	, IN more_info VARCHAR(255)
	, IN street_address VARCHAR(255)
	, IN city VARCHAR(255)
	, IN state VARCHAR(255)
	, IN zip_code VARCHAR(255)
	, IN country VARCHAR(255)
	, IN owner_id VARCHAR(255)
	)
    SQL SECURITY INVOKER
BEGIN
		
		# Prepare the CALL argument that was prepared by the trigger
		# https://github.com/unee-t/lambda2sns/blob/master/tests/call-lambda-as-root.sh#L5
		#	- DEV/Staging: 812644853088
		#	- Prod: 192458993663
		#	- Demo: 915001051872

			CALL mysql.lambda_async (CONCAT('arn:aws:lambda:ap-southeast-1:812644853088:function:alambda_simple')
				, JSON_OBJECT(
					'unitCreationRequestId' , unit_creation_request_id
					, 'actionType', action_type
					, 'creatorId', creator_id
					, 'name', uneet_name
					, 'type', unee_t_unit_type
					, 'moreInfo', more_info
					, 'streetAddress', street_address
					, 'city', city
					, 'state', state
					, 'zipCode', zip_code
					, 'country', country
					, 'ownerId', owner_id
					)
				)
				;

END */$$
DELIMITER ;

/* Procedure structure for procedure `lambda_create_user` */

/*!50003 DROP PROCEDURE IF EXISTS  `lambda_create_user` */;

DELIMITER $$

/*!50003 CREATE PROCEDURE `lambda_create_user`(
	IN user_creation_request_id INT(11)
	, IN action_type VARCHAR(255)
	, IN creator_id VARCHAR(255)
	, IN email_address VARCHAR(255)
	, IN first_name VARCHAR(255)
	, IN last_name VARCHAR(255)
	, IN phone_number VARCHAR(255)
	)
    SQL SECURITY INVOKER
BEGIN
		
		# Prepare the CALL argument that was prepared by the trigger
		# https://github.com/unee-t/lambda2sns/blob/master/tests/call-lambda-as-root.sh#L5
		#	- DEV/Staging: 812644853088
		#	- Prod: 192458993663
		#	- Demo: 915001051872

			CALL mysql.lambda_async (CONCAT('arn:aws:lambda:ap-southeast-1:812644853088:function:alambda_simple')
				, JSON_OBJECT(
					'userCreationRequestId' , user_creation_request_id
					, 'actionType', action_type
					, 'creatorId', creator_id
					, 'emailAddress', email_address
					, 'firstName', first_name
					, 'lastName', last_name
					, 'phoneNumber', phone_number
					)
				)
				;

END */$$
DELIMITER ;

/* Procedure structure for procedure `lambda_remove_user_from_unit` */

/*!50003 DROP PROCEDURE IF EXISTS  `lambda_remove_user_from_unit` */;

DELIMITER $$

/*!50003 CREATE PROCEDURE `lambda_remove_user_from_unit`(
	IN remove_user_from_unit_request_id int(11)
	, IN action_type varchar(255)
	, IN requestor_user_id varchar(255)
	, IN mefe_user_id varchar(255)
	, IN mefe_unit_id varchar(255)
	)
    SQL SECURITY INVOKER
BEGIN
		
		# Prepare the CALL argument that was prepared by the trigger
		# https://github.com/unee-t/lambda2sns/blob/master/tests/call-lambda-as-root.sh#L5
		#	- DEV/Staging: 812644853088
		#	- Prod: 192458993663
		#	- Demo: 915001051872

			CALL mysql.lambda_async (CONCAT('arn:aws:lambda:ap-southeast-1:812644853088:function:alambda_simple')
				, JSON_OBJECT(
					'removeUserFromUnitRequestId' , remove_user_from_unit_request_id
					, 'actionType', action_type
					, 'requestorUserId', requestor_user_id
					, 'userId', mefe_user_id
					, 'unitId', mefe_unit_id
					)
				)
				;

END */$$
DELIMITER ;

/* Procedure structure for procedure `lambda_update_unit` */

/*!50003 DROP PROCEDURE IF EXISTS  `lambda_update_unit` */;

DELIMITER $$

/*!50003 CREATE PROCEDURE `lambda_update_unit`(
	IN update_unit_request_id int(11)
	, IN action_type varchar(255)
	, IN requestor_user_id varchar(255)
	, IN mefe_unit_id varchar(255)
	, IN creator_id varchar(255)
	, IN unee_t_unit_type varchar(255)
	, IN unee_t_unit_name varchar(255)
	, IN more_info varchar(255)
	, IN street_address varchar(255)
	, IN city varchar(255)
	, IN state varchar(255)
	, IN zip_code varchar(255)
	, IN country varchar(255)
	)
    SQL SECURITY INVOKER
BEGIN
		
		# Prepare the CALL argument that was prepared by the trigger
		# https://github.com/unee-t/lambda2sns/blob/master/tests/call-lambda-as-root.sh#L5
		#	- DEV/Staging: 812644853088
		#	- Prod: 192458993663
		#	- Demo: 915001051872

			CALL mysql.lambda_async (CONCAT('arn:aws:lambda:ap-southeast-1:812644853088:function:alambda_simple')
				, JSON_OBJECT(
					'updateUnitRequestId' , update_unit_request_id
					, 'actionType', action_type
					, 'requestorUserId', requestor_user_id
					, 'unitId', mefe_unit_id
					, 'creatorId', creator_id
					, 'type', unee_t_unit_type
					, 'name', unee_t_unit_name
					, 'moreInfo', more_info
					, 'streetAddress', street_address
					, 'city', city
					, 'state', state
					, 'zipCode', zip_code
					, 'country', country
					)
				)
				;

END */$$
DELIMITER ;

/* Procedure structure for procedure `lambda_update_unit_name_type` */

/*!50003 DROP PROCEDURE IF EXISTS  `lambda_update_unit_name_type` */;

DELIMITER $$

/*!50003 CREATE PROCEDURE `lambda_update_unit_name_type`(
	IN update_unit_request_id int(11)
	, IN action_type varchar(255)
	, IN requestor_user_id varchar(255)
	, IN mefe_unit_id varchar(255)
	, IN creator_id varchar(255)
	, IN unee_t_unit_type varchar(255)
	, IN unee_t_unit_name varchar(255)
	)
    SQL SECURITY INVOKER
BEGIN
		
		# Prepare the CALL argument that was prepared by the trigger
		# https://github.com/unee-t/lambda2sns/blob/master/tests/call-lambda-as-root.sh#L5
		#	- DEV/Staging: 812644853088
		#	- Prod: 192458993663
		#	- Demo: 915001051872

			CALL mysql.lambda_async (CONCAT('arn:aws:lambda:ap-southeast-1:812644853088:function:alambda_simple')
                , JSON_OBJECT(
                	'updateUnitRequestId' , update_unit_request_id
                	, 'actionType', action_type
                	, 'requestorUserId', requestor_user_id
                	, 'unitId', mefe_unit_id
                	, 'creatorId', creator_id
                	, 'type', unee_t_unit_type
                	, 'name', unee_t_unit_name
                	)
                )
                ;

END */$$
DELIMITER ;

/* Procedure structure for procedure `lambda_update_user_profile` */

/*!50003 DROP PROCEDURE IF EXISTS  `lambda_update_user_profile` */;

DELIMITER $$

/*!50003 CREATE PROCEDURE `lambda_update_user_profile`(
	IN update_user_request_id int(11)
	, IN action_type varchar(255)
	, IN requestor_mefe_user_id varchar(255)
	, IN creator_mefe_user_id varchar(255)
	, IN mefe_user_id varchar(255)
	, IN first_name varchar(255)
	, IN last_name varchar(255)
	, IN phone_number varchar(255)
	, IN mefe_email_address varchar(255)
	, IN bzfe_email_address varchar(255)
	)
    SQL SECURITY INVOKER
BEGIN
		
		# Prepare the CALL argument that was prepared by the trigger
		# https://github.com/unee-t/lambda2sns/blob/master/tests/call-lambda-as-root.sh#L5
		#	- DEV/Staging: 812644853088
		#	- Prod: 192458993663
		#	- Demo: 915001051872

			CALL mysql.lambda_async (CONCAT('arn:aws:lambda:ap-southeast-1:812644853088:function:alambda_simple')
				, JSON_OBJECT(
					'updateUserRequestId' , update_user_request_id
					, 'actionType', action_type
					, 'requestorUserId', requestor_mefe_user_id
					, 'creatorId', creator_mefe_user_id
					, 'userId', mefe_user_id
					, 'firstName', first_name
					, 'lastName', last_name
					, 'phoneNumber', phone_number
					, 'emailAddress', mefe_email_address
					, 'bzfeEmailAddress', bzfe_email_address
					)
				)
				;

END */$$
DELIMITER ;

/* Procedure structure for procedure `remove_user_from_role_unit_level_1` */

/*!50003 DROP PROCEDURE IF EXISTS  `remove_user_from_role_unit_level_1` */;

DELIMITER $$

/*!50003 CREATE PROCEDURE `remove_user_from_role_unit_level_1`()
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

END */$$
DELIMITER ;

/* Procedure structure for procedure `remove_user_from_role_unit_level_2` */

/*!50003 DROP PROCEDURE IF EXISTS  `remove_user_from_role_unit_level_2` */;

DELIMITER $$

/*!50003 CREATE PROCEDURE `remove_user_from_role_unit_level_2`()
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

END */$$
DELIMITER ;

/* Procedure structure for procedure `remove_user_from_role_unit_level_3` */

/*!50003 DROP PROCEDURE IF EXISTS  `remove_user_from_role_unit_level_3` */;

DELIMITER $$

/*!50003 CREATE PROCEDURE `remove_user_from_role_unit_level_3`()
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

END */$$
DELIMITER ;

/* Procedure structure for procedure `retry_create_user` */

/*!50003 DROP PROCEDURE IF EXISTS  `retry_create_user` */;

DELIMITER $$

/*!50003 CREATE PROCEDURE `retry_create_user`()
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

END */$$
DELIMITER ;

/* Procedure structure for procedure `ut_assign_user_to_all_unit_in_organization` */

/*!50003 DROP PROCEDURE IF EXISTS  `ut_assign_user_to_all_unit_in_organization` */;

DELIMITER $$

/*!50003 CREATE PROCEDURE `ut_assign_user_to_all_unit_in_organization`()
    SQL SECURITY INVOKER
BEGIN

# This procedure needs the following variables:
#	- @requestor_id
#	- @person_id

	SET @mefe_user_id_assignee_all := (SELECT `unee_t_mefe_user_id`
		FROM `ut_map_external_source_users`
		WHERE `person_id` = @person_id
		) 
		;

	SET @person_id_is_all_unit := (SELECT `person_id` 
		FROM `ut_map_external_source_users`
		WHERE `unee_t_mefe_user_id` = @mefe_user_id_assignee_all
		)
		;

	SET @organization_id_is_all_unit = (SELECT `organization_id` 
		FROM `ut_map_external_source_users`
		WHERE `unee_t_mefe_user_id` = @mefe_user_id_assignee_all
		)
		;

	SET @unee_t_user_type_id_is_all_unit = (SELECT `unee_t_user_type_id`
		FROM `persons`
		WHERE `id_person` = @person_id_is_all_unit
		);

	SET @is_all_units_is_all_unit = (SELECT `is_all_unit`
		FROM `ut_user_types`
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_is_all_unit
		);

	IF @is_all_units_is_all_unit = 1
		AND @mefe_user_id_assignee_all IS NOT NULL
		AND @requestor_id IS NOT NULL
	THEN 

	# We get the variables we need:

		SET @syst_created_datetime_is_all_unit := NOW() ;
		SET @creation_system_id_is_all_unit := 2 ;
		SET @created_by_id_is_all_unit := @requestor_id ;
		SET @creation_method_is_all_unit := 'ut_update_external_person_not_ut_user_type' ;

		SET @syst_updated_datetime_is_all_unit := NOW() ;
		SET @update_system_id_is_all_unit := 2 ;
		SET @updated_by_id_is_all_unit := @created_by_id_is_all_unit ;
		SET @update_method_is_all_unit := @creation_method_is_all_unit ;

		SET @is_obsolete_is_all_unit = 0 ;
		SET @is_update_needed_is_all_unit = 1 ;

		SET @unee_t_role_id_is_all_unit := (SELECT `ut_user_role_type_id`
		FROM `ut_user_types`
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_is_all_unit
		);

		SET @is_occupant := (SELECT `is_occupant` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_is_all_unit
		);

		SET @propagate_to_all_level_2 = 1 ;
		SET @propagate_to_all_level_3 = 1 ;

		# additional permissions 
		SET @is_default_assignee := (SELECT `is_default_assignee` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_is_all_unit
		);
		SET @is_default_invited := (SELECT `is_default_invited` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_is_all_unit
		);
		SET @is_unit_owner := (SELECT `is_unit_owner` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_is_all_unit
		);

		# Visibility rules 
		SET @is_public := (SELECT `is_public` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_is_all_unit
		);
		SET @can_see_role_landlord := (SELECT `can_see_role_landlord` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_is_all_unit
		);
		SET @can_see_role_tenant := (SELECT `can_see_role_tenant` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_is_all_unit
		);
		SET @can_see_role_mgt_cny := (SELECT `can_see_role_mgt_cny` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_is_all_unit
		);
		SET @can_see_role_agent := (SELECT `can_see_role_agent` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_is_all_unit
		);
		SET @can_see_role_contractor := (SELECT `can_see_role_contractor` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_is_all_unit
		);
		SET @can_see_occupant := (SELECT `can_see_occupant` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_is_all_unit
		);

		# Notification rules 
		# - case - information 
		SET @is_assigned_to_case := (SELECT `is_assigned_to_case` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_is_all_unit
		);
		SET @is_invited_to_case := (SELECT `is_invited_to_case` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_is_all_unit
		);
		SET @is_next_step_updated := (SELECT `is_next_step_updated` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_is_all_unit
		);
		SET @is_deadline_updated := (SELECT `is_deadline_updated` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_is_all_unit
		);
		SET @is_solution_updated := (SELECT `is_solution_updated` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_is_all_unit
		);
		SET @is_case_resolved := (SELECT `is_case_resolved` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_is_all_unit
		);
		SET @is_case_blocker := (SELECT `is_case_blocker` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_is_all_unit
		);
		SET @is_case_critical := (SELECT `is_case_critical` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_is_all_unit
		);

		# - case - messages 
		SET @is_any_new_message := (SELECT `is_any_new_message` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_is_all_unit
		);
		SET @is_message_from_tenant := (SELECT `is_message_from_tenant` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_is_all_unit
		);
		SET @is_message_from_ll := (SELECT `is_message_from_ll` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_is_all_unit
		);
		SET @is_message_from_occupant := (SELECT `is_message_from_occupant` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_is_all_unit
		);
		SET @is_message_from_agent := (SELECT `is_message_from_agent` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_is_all_unit
		);
		SET @is_message_from_mgt_cny := (SELECT `is_message_from_mgt_cny` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_is_all_unit
		);
		SET @is_message_from_contractor := (SELECT `is_message_from_contractor` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_is_all_unit
		);

		# - Inspection Reports 
		SET @is_new_ir := (SELECT `is_new_ir` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_is_all_unit
		);

		# - Inventory 
		SET @is_new_item := (SELECT `is_new_item` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_is_all_unit
		);
		SET @is_item_removed := (SELECT `is_item_removed` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_is_all_unit
		);
		SET @is_item_moved := (SELECT `is_item_moved` 
		FROM `ut_user_types` 
		WHERE `id_unee_t_user_type` = @unee_t_user_type_id_is_all_unit
		);

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
		#	- The id of the organization is in the variable @organization_id_is_all_unit
		#	- The ids of the buildings are in the view `ut_list_mefe_unit_id_level_1_by_area`
		# We need to insert all these data in the table `temp_user_unit_role_permissions_level_3`

		SET @created_by_id := @organization_id_is_all_unit ;

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
			SELECT @syst_created_datetime_is_all_unit
			, @creation_system_id_is_all_unit
			, @created_by_id
			, @created_by_id_is_all_unit
			, @creation_method_is_all_unit
			, @organization_id_is_all_unit
			, @is_obsolete_is_all_unit
			, @is_update_needed_is_all_unit
			, @mefe_user_id_assignee_all
			, `a`.`level_1_building_id`
			, `a`.`external_level_1_building_id`
			, `a`.`unee_t_mefe_unit_id`
			, @unee_t_user_type_id_is_all_unit
			, @unee_t_role_id_is_all_unit
			FROM `ut_list_mefe_unit_id_level_1_by_area` AS `a`
			WHERE `a`.`organization_id` = @organization_id_is_all_unit
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
		#	- The id of the organization is in the variable @organization_id_is_all_unit
		#	- The ids of the units are in the view `ut_list_mefe_unit_id_level_2_by_area`
		# We need to insert all these data in the table `temp_user_unit_role_permissions_level_2`

		SET @created_by_id = @organization_id_is_all_unit ;

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
			@syst_created_datetime_is_all_unit
			, @creation_system_id_is_all_unit
			, @created_by_id
			, @created_by_id_is_all_unit
			, @creation_method_is_all_unit
			, @organization_id_is_all_unit
			, @is_obsolete_is_all_unit
			, @is_update_needed_is_all_unit
			, @mefe_user_id_assignee_all
			, `a`.`level_2_unit_id`
			, `a`.`external_level_2_unit_id`
			, `a`.`unee_t_mefe_unit_id`
			, @unee_t_user_type_id_is_all_unit
			, @unee_t_role_id_is_all_unit
			FROM `ut_list_mefe_unit_id_level_2_by_area` AS `a`
			INNER JOIN `ut_list_mefe_unit_id_level_1_by_area` AS `b`
				ON (`a`.`level_1_building_id` = `b`.`level_1_building_id` )
			WHERE `a`.`organization_id` = @organization_id_is_all_unit
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
		#	- The id of the organization is in the variable @organization_id_is_all_unit
		#	- The ids of the rooms are in the view `ut_list_mefe_unit_id_level_3_by_area`
		# We need to insert all these data in the table `temp_user_unit_role_permissions_level_3`

		SET @created_by_id := @organization_id_is_all_unit ;

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
			@syst_created_datetime_is_all_unit
			, @creation_system_id_is_all_unit
			, @created_by_id
			, @created_by_id_is_all_unit
			, @creation_method_is_all_unit
			, @organization_id_is_all_unit
			, @is_obsolete_is_all_unit
			, @is_update_needed_is_all_unit
			, @mefe_user_id_assignee_all
			, `a`.`level_3_room_id`
			, `a`.`external_level_3_room_id`
			, `a`.`unee_t_mefe_unit_id`
			, @unee_t_user_type_id_is_all_unit
			, @unee_t_role_id_is_all_unit
			FROM `ut_list_mefe_unit_id_level_3_by_area` AS `a`
			INNER JOIN `ut_list_mefe_unit_id_level_2_by_area` AS `b`
				ON (`b`.`level_2_unit_id` = `a`.`level_2_unit_id`)
			WHERE `a`.`organization_id` = @organization_id_is_all_unit
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

END */$$
DELIMITER ;

/* Procedure structure for procedure `ut_creation_unit_mefe_api_reply` */

/*!50003 DROP PROCEDURE IF EXISTS  `ut_creation_unit_mefe_api_reply` */;

DELIMITER $$

/*!50003 CREATE PROCEDURE `ut_creation_unit_mefe_api_reply`()
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

END */$$
DELIMITER ;

/* Procedure structure for procedure `ut_creation_user_mefe_api_reply` */

/*!50003 DROP PROCEDURE IF EXISTS  `ut_creation_user_mefe_api_reply` */;

DELIMITER $$

/*!50003 CREATE PROCEDURE `ut_creation_user_mefe_api_reply`()
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

END */$$
DELIMITER ;

/* Procedure structure for procedure `ut_creation_user_role_association_mefe_api_reply` */

/*!50003 DROP PROCEDURE IF EXISTS  `ut_creation_user_role_association_mefe_api_reply` */;

DELIMITER $$

/*!50003 CREATE PROCEDURE `ut_creation_user_role_association_mefe_api_reply`()
    SQL SECURITY INVOKER
BEGIN

# This procedure needs the following variables:
#	- @mefe_api_request_id
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
			WHERE `id_map_user_unit_permissions` = @mefe_api_request_id
		;

END */$$
DELIMITER ;

/* Procedure structure for procedure `ut_remove_user_from_unit` */

/*!50003 DROP PROCEDURE IF EXISTS  `ut_remove_user_from_unit` */;

DELIMITER $$

/*!50003 CREATE PROCEDURE `ut_remove_user_from_unit`()
    SQL SECURITY INVOKER
BEGIN

# We only do this IF:
#	- The variable @disable_lambda != 1
#	- We have a MEFE unit ID
#	- We have a MEFE user ID
#	- The field `is_obsolete` = 1
#	- We have an `update_system_id`
#	- We have an `updated_by_id`
#	- We have an `update_method`
#	- This is done via an authorized update method
#		- 'ut_delete_user_from_role_in_a_level_1_property'
#		- 'ut_delete_user_from_role_in_a_level_2_property'
#		- 'ut_delete_user_from_role_in_a_level_3_property'
#		- ''
#		- ''

# This procedure needs the following variables:
#	- @unee_t_mefe_id
#	- @unee_t_unit_id
#	- @is_obsolete
#	- @update_method
#	- @update_system_id
#	- @updated_by_id
#	- @disable_lambda != 1

	IF @unee_t_mefe_id IS NOT NULL
		AND @unee_t_unit_id IS NOT NULL
		AND @is_obsolete = 1
		AND (@disable_lambda != 1
			OR @disable_lambda IS NULL)
		AND @update_system_id IS NOT NULL
		AND @updated_by_id IS NOT NULL
		AND (@update_method = 'ut_delete_user_from_role_in_a_level_1_property'
			OR @update_method = 'ut_delete_user_from_role_in_a_level_2_property'
			OR @update_method = 'ut_delete_user_from_role_in_a_level_3_property'
			)
	THEN

			# The specifics

				# What is this trigger (for log_purposes)
					SET @this_procedure_8_7 = 'ut_remove_user_from_unit';

				# What is the procedure associated with this trigger:
					SET @associated_procedure = 'lambda_remove_user_from_unit';
			
			# lambda:
			# https://github.com/unee-t/lambda2sns/blob/master/tests/call-lambda-as-root.sh#L5
			#	- DEV/Staging: 812644853088
			#	- Prod: 192458993663
			#	- Demo: 915001051872

					SET @lambda_key = 812644853088;

				# MEFE API Key:
					SET @key_this_envo = 'ABCDEFG';

		# The variables that we need:

			SET @remove_user_from_unit_request_id = (SELECT `id_map_user_unit_permissions`
				FROM `ut_map_user_permissions_unit_all`
				WHERE `unee_t_mefe_id` = @unee_t_mefe_id
					AND `unee_t_unit_id` = @unee_t_unit_id
				) ;

			SET @action_type = 'DEASSIGN_ROLE' ;

			SET @requestor_user_id = @updated_by_id ;
			
			SET @mefe_user_id = @unee_t_mefe_id ;

			SET @mefe_unit_id = @unee_t_unit_id ;
		
		# We insert the event in the relevant log table

			# Simulate what the Procedure `lambda_add_user_to_role_in_unit_with_visibility` does
			# Make sure to update that if you update the procedure `lambda_add_user_to_role_in_unit_with_visibility`

				# The JSON Object:

					SET @json_object = (
						JSON_OBJECT(
							'removeUserFromUnitRequestId' , @remove_user_from_unit_request_id
							, 'actionType', @action_type
							, 'requestorUserId', @requestor_user_id
							, 'userId', @mefe_user_id
							, 'unitId', @mefe_unit_id
							)
						)
						;

				# The specific lambda:

					SET @lambda = CONCAT('arn:aws:lambda:ap-southeast-1:'
						, @lambda_key
						, ':function:alambda_simple')
						;
				
				# The specific Lambda CALL:

					SET @lambda_call = CONCAT('CALL mysql.lambda_async'
						, @lambda
						, @json_object
						)
						;

			# Now that we have simulated what the CALL does, we record that

			SET @unit_name := (SELECT `uneet_name`
				FROM `ut_map_external_source_units`
				WHERE `unee_t_mefe_unit_id` = @mefe_unit_id
				);
			SET @unee_t_login := (SELECT `uneet_login_name`
				FROM `ut_map_external_source_users`
				WHERE `unee_t_mefe_user_id` = @mefe_user_id
				);

				INSERT INTO `log_lambdas`
					(`created_datetime`
					, `creation_trigger`
					, `associated_call`
					, `mefe_unit_id`
					, `unit_name`
					, `mefe_user_id`
					, `unee_t_login`
					, `payload`
					)
					VALUES
						(NOW()
						, @this_procedure_8_7
						, @associated_procedure
						, @mefe_unit_id
						, @unit_name
						, @mefe_user_id
						, @unee_t_login
						, @lambda_call
						)
						;

		# We call the Lambda procedure to remove a user from a role in a unit

			CALL `lambda_remove_user_from_unit`(@remove_user_from_unit_request_id
				, @action_type
				, @requestor_user_id
				, @mefe_user_id
				, @mefe_unit_id
				)
				;

	END IF;
END */$$
DELIMITER ;

/* Procedure structure for procedure `ut_remove_user_role_association_mefe_api_reply` */

/*!50003 DROP PROCEDURE IF EXISTS  `ut_remove_user_role_association_mefe_api_reply` */;

DELIMITER $$

/*!50003 CREATE PROCEDURE `ut_remove_user_role_association_mefe_api_reply`()
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

END */$$
DELIMITER ;

/* Procedure structure for procedure `ut_retry_assign_user_to_units_error_already_has_role` */

/*!50003 DROP PROCEDURE IF EXISTS  `ut_retry_assign_user_to_units_error_already_has_role` */;

DELIMITER $$

/*!50003 CREATE PROCEDURE `ut_retry_assign_user_to_units_error_already_has_role`()
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



END */$$
DELIMITER ;

/* Procedure structure for procedure `ut_retry_assign_user_to_units_error_ownership` */

/*!50003 DROP PROCEDURE IF EXISTS  `ut_retry_assign_user_to_units_error_ownership` */;

DELIMITER $$

/*!50003 CREATE PROCEDURE `ut_retry_assign_user_to_units_error_ownership`()
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

END */$$
DELIMITER ;

/* Procedure structure for procedure `ut_retry_create_unit_level_1` */

/*!50003 DROP PROCEDURE IF EXISTS  `ut_retry_create_unit_level_1` */;

DELIMITER $$

/*!50003 CREATE PROCEDURE `ut_retry_create_unit_level_1`()
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

END */$$
DELIMITER ;

/* Procedure structure for procedure `ut_retry_create_unit_level_2` */

/*!50003 DROP PROCEDURE IF EXISTS  `ut_retry_create_unit_level_2` */;

DELIMITER $$

/*!50003 CREATE PROCEDURE `ut_retry_create_unit_level_2`()
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

END */$$
DELIMITER ;

/* Procedure structure for procedure `ut_retry_create_unit_level_3` */

/*!50003 DROP PROCEDURE IF EXISTS  `ut_retry_create_unit_level_3` */;

DELIMITER $$

/*!50003 CREATE PROCEDURE `ut_retry_create_unit_level_3`()
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

END */$$
DELIMITER ;

/* Procedure structure for procedure `ut_update_unit_mefe_api_reply` */

/*!50003 DROP PROCEDURE IF EXISTS  `ut_update_unit_mefe_api_reply` */;

DELIMITER $$

/*!50003 CREATE PROCEDURE `ut_update_unit_mefe_api_reply`()
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

END */$$
DELIMITER ;

/* Procedure structure for procedure `ut_update_user` */

/*!50003 DROP PROCEDURE IF EXISTS  `ut_update_user` */;

DELIMITER $$

/*!50003 CREATE PROCEDURE `ut_update_user`()
    SQL SECURITY INVOKER
BEGIN

# This procedure needs to following variables:
#	- @person_id
#	- @requestor_id
#

# We only do this IF:
#	- The variable @disable_lambda != 1
#	- We have a MEFE user ID
#WIP	- There was NO change to the fact that we need to create a Unee-T account
#	- This is done via an authorized insert method:
#		- `ut_person_has_been_updated_and_ut_account_needed`
#		- ''
#		- ''
#

	SET @mefe_user_id_uu_l_1 = (SELECT `unee_t_mefe_user_id`
		FROM `ut_map_external_source_users`
		WHERE `person_id` = @person_id
		) 
		;

	IF @mefe_user_id_uu_l_1 IS NOT NULL
		AND (@disable_lambda != 1
			OR @disable_lambda IS NULL)
	THEN

			# The specifics

				# What is this trigger (for log_purposes)
					SET @this_procedure = 'ut_update_user';

				# What is the procedure associated with this trigger:
					SET @associated_procedure = 'lambda_update_user_profile';
			
			# lambda:
			# https://github.com/unee-t/lambda2sns/blob/master/tests/call-lambda-as-root.sh#L5
			#	- DEV/Staging: 812644853088
			#	- Prod: 192458993663
			#	- Demo: 915001051872

					SET @lambda_key = 812644853088;

				# MEFE API Key:
					SET @key_this_envo = 'ABCDEFG';

		# Define the variables we need:

			SET @update_user_request_id = (SELECT `id_map`
				FROM `ut_map_external_source_users`
				WHERE `person_id` = @person_id
				) 
				;

			SET @action_type = 'EDIT_USER' ;

			SET @requestor_mefe_user_id = @requestor_id ;

			SET @creator_mefe_user_id =  (SELECT `updated_by_id` 
				FROM `persons`
				WHERE `id_person` = @person_id
				)
				;

			SET @first_name = (SELECT `first_name` 
				FROM `ut_user_information_persons`
				WHERE `id_person` = @person_id
				)
				;

			SET @last_name = (SELECT `last_name` 
				FROM `ut_user_information_persons`
				WHERE `id_person` = @person_id
				)
				;

			SET @phone_number = (SELECT `phone_number` 
				FROM `ut_user_information_persons`
				WHERE `id_person` = @person_id
				)
				;

			SET @mefe_email_address = (SELECT `email_address` 
				FROM `ut_user_information_persons`
				WHERE `id_person` = @person_id
				)
				;

			SET @bzfe_email_address = (SELECT `email_address` 
				FROM `ut_user_information_persons`
				WHERE `id_person` = @person_id
				)
				;

			SET @lambda_id = @lambda_key ;
			SET @mefe_api_key = @key_this_envo ;

		# We insert the event in the relevant log table

			# Simulate what the Procedure `lambda_create_user` does
			# Make sure to update that if you update the procedure `lambda_create_user`

				# The JSON Object:

					SET @json_object = (
						JSON_OBJECT(
							'updateUserRequestId' , @update_user_request_id
							, 'actionType', @action_type
							, 'requestorUserId', @requestor_mefe_user_id
							, 'creatorId', @creator_mefe_user_id
							, 'userId', @mefe_user_id_uu_l_1
							, 'firstName', @first_name
							, 'lastName', @last_name
							, 'phoneNumber', @phone_number
							, 'emailAddress', @mefe_email_address
							, 'bzfeEmailAddress', @bzfe_email_address
							)
						)
						;

				# The specific lambda:

					SET @lambda = CONCAT('arn:aws:lambda:ap-southeast-1:'
						, @lambda_key
						, ':function:alambda_simple')
						;
				
				# The specific Lambda CALL:

					SET @lambda_call = CONCAT('CALL mysql.lambda_async'
						, @lambda
						, @json_object
						)
						;

			# Now that we have simulated what the CALL does, we record that

			SET @unee_t_login := (SELECT `uneet_login_name`
				FROM `ut_map_external_source_users`
				WHERE `unee_t_mefe_user_id` = @mefe_user_id_uu_l_1
				);

				INSERT INTO `log_lambdas`
					(`created_datetime`
					, `creation_trigger`
					, `associated_call`
					, `mefe_unit_id`
					, `mefe_user_id`
					, `unee_t_login`
					, `payload`
					)
					VALUES
						(NOW()
						, @this_procedure
						, @associated_procedure
						, 'n/a'
						, @mefe_user_id_uu_l_1
						, @unee_t_login
						, @lambda_call
						)
						;

		# We call the Lambda procedure to update the user

			CALL `lambda_update_user_profile`(@update_user_request_id
				, @action_type
				, @requestor_mefe_user_id
				, @creator_mefe_user_id
				, @mefe_user_id_uu_l_1
				, @first_name
				, @last_name
				, @phone_number
				, @mefe_email_address
				, @bzfe_email_address
				)
				;

	END IF;
END */$$
DELIMITER ;

/* Procedure structure for procedure `ut_update_user_mefe_api_reply` */

/*!50003 DROP PROCEDURE IF EXISTS  `ut_update_user_mefe_api_reply` */;

DELIMITER $$

/*!50003 CREATE PROCEDURE `ut_update_user_mefe_api_reply`()
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

END */$$
DELIMITER ;

/*Table structure for table `ut_add_information_unit_level_1` */

DROP TABLE IF EXISTS `ut_add_information_unit_level_1`;

/*!50001 DROP VIEW IF EXISTS `ut_add_information_unit_level_1` */;
/*!50001 DROP TABLE IF EXISTS `ut_add_information_unit_level_1` */;

/*!50001 CREATE TABLE  `ut_add_information_unit_level_1`(
 `unit_level_1_id` int(11) ,
 `is_create_condo` tinyint(1) ,
 `unee_t_unit_type` varchar(100) ,
 `name` varchar(255) ,
 `more_info` text ,
 `tower` varchar(50) ,
 `street_address` varchar(102) ,
 `city` varchar(50) ,
 `zip_code` varchar(50) ,
 `state` varchar(50) ,
 `country_code` varchar(10) ,
 `country` varchar(256) 
)*/;

/*Table structure for table `ut_add_information_unit_level_2` */

DROP TABLE IF EXISTS `ut_add_information_unit_level_2`;

/*!50001 DROP VIEW IF EXISTS `ut_add_information_unit_level_2` */;
/*!50001 DROP TABLE IF EXISTS `ut_add_information_unit_level_2` */;

/*!50001 CREATE TABLE  `ut_add_information_unit_level_2`(
 `unit_level_2_id` int(11) ,
 `is_create_flat` tinyint(1) ,
 `unee_t_unit_type` varchar(100) ,
 `name` varchar(50) ,
 `more_info` text ,
 `street_address` varchar(413) ,
 `city` varchar(50) ,
 `state` varchar(50) ,
 `zip_code` varchar(50) ,
 `country` varchar(256) 
)*/;

/*Table structure for table `ut_add_information_unit_level_3` */

DROP TABLE IF EXISTS `ut_add_information_unit_level_3`;

/*!50001 DROP VIEW IF EXISTS `ut_add_information_unit_level_3` */;
/*!50001 DROP TABLE IF EXISTS `ut_add_information_unit_level_3` */;

/*!50001 CREATE TABLE  `ut_add_information_unit_level_3`(
 `unit_level_3_id` int(11) ,
 `is_create_room` tinyint(1) ,
 `unee_t_unit_type` varchar(100) ,
 `name` varchar(255) ,
 `more_info` mediumtext ,
 `street_address` varchar(413) ,
 `city` varchar(50) ,
 `state` varchar(50) ,
 `zip_code` varchar(50) ,
 `country` varchar(256) 
)*/;

/*Table structure for table `ut_analysis_errors_not_an_owner_count` */

DROP TABLE IF EXISTS `ut_analysis_errors_not_an_owner_count`;

/*!50001 DROP VIEW IF EXISTS `ut_analysis_errors_not_an_owner_count` */;
/*!50001 DROP TABLE IF EXISTS `ut_analysis_errors_not_an_owner_count` */;

/*!50001 CREATE TABLE  `ut_analysis_errors_not_an_owner_count`(
 `count_reuquestor_not_an_owner` bigint(21) 
)*/;

/*Table structure for table `ut_analysis_errors_not_an_owner_list` */

DROP TABLE IF EXISTS `ut_analysis_errors_not_an_owner_list`;

/*!50001 DROP VIEW IF EXISTS `ut_analysis_errors_not_an_owner_list` */;
/*!50001 DROP TABLE IF EXISTS `ut_analysis_errors_not_an_owner_list` */;

/*!50001 CREATE TABLE  `ut_analysis_errors_not_an_owner_list`(
 `id_map_user_unit_permissions` int(11) ,
 `syst_created_datetime` timestamp ,
 `unee_t_update_ts` timestamp ,
 `is_mefe_api_success` tinyint(1) ,
 `mefe_api_error_message` text ,
 `mefe_user_id` varchar(255) ,
 `uneet_login_name` varchar(255) ,
 `unee_t_unit_id` varchar(255) ,
 `uneet_name` varchar(255) ,
 `role_type` varchar(255) 
)*/;

/*Table structure for table `ut_analysis_errors_user_already_has_a_role_count` */

DROP TABLE IF EXISTS `ut_analysis_errors_user_already_has_a_role_count`;

/*!50001 DROP VIEW IF EXISTS `ut_analysis_errors_user_already_has_a_role_count` */;
/*!50001 DROP TABLE IF EXISTS `ut_analysis_errors_user_already_has_a_role_count` */;

/*!50001 CREATE TABLE  `ut_analysis_errors_user_already_has_a_role_count`(
 `count_user_already_has_role` bigint(21) 
)*/;

/*Table structure for table `ut_analysis_errors_user_already_has_a_role_list` */

DROP TABLE IF EXISTS `ut_analysis_errors_user_already_has_a_role_list`;

/*!50001 DROP VIEW IF EXISTS `ut_analysis_errors_user_already_has_a_role_list` */;
/*!50001 DROP TABLE IF EXISTS `ut_analysis_errors_user_already_has_a_role_list` */;

/*!50001 CREATE TABLE  `ut_analysis_errors_user_already_has_a_role_list`(
 `id_map_user_unit_permissions` int(11) ,
 `syst_created_datetime` timestamp ,
 `unee_t_update_ts` timestamp ,
 `is_mefe_api_success` tinyint(1) ,
 `mefe_api_error_message` text ,
 `mefe_user_id` varchar(255) ,
 `uneet_login_name` varchar(255) ,
 `unee_t_unit_id` varchar(255) ,
 `uneet_name` varchar(255) ,
 `role_type` varchar(255) 
)*/;

/*Table structure for table `ut_analysis_mefe_api_assign_user_to_unit_creation_time` */

DROP TABLE IF EXISTS `ut_analysis_mefe_api_assign_user_to_unit_creation_time`;

/*!50001 DROP VIEW IF EXISTS `ut_analysis_mefe_api_assign_user_to_unit_creation_time` */;
/*!50001 DROP TABLE IF EXISTS `ut_analysis_mefe_api_assign_user_to_unit_creation_time` */;

/*!50001 CREATE TABLE  `ut_analysis_mefe_api_assign_user_to_unit_creation_time`(
 `id_map_user_unit_permissions` int(11) ,
 `uneet_login_name` varchar(255) ,
 `uneet_name` varchar(255) ,
 `syst_created_datetime` timestamp ,
 `syst_updated_datetime` timestamp ,
 `unee_t_update_ts` timestamp ,
 `creation_time` time 
)*/;

/*Table structure for table `ut_analysis_mefe_api_unit_creation_time` */

DROP TABLE IF EXISTS `ut_analysis_mefe_api_unit_creation_time`;

/*!50001 DROP VIEW IF EXISTS `ut_analysis_mefe_api_unit_creation_time` */;
/*!50001 DROP TABLE IF EXISTS `ut_analysis_mefe_api_unit_creation_time` */;

/*!50001 CREATE TABLE  `ut_analysis_mefe_api_unit_creation_time`(
 `id_map` int(11) ,
 `uneet_name` varchar(255) ,
 `external_property_type_id` int(11) ,
 `syst_created_datetime` timestamp ,
 `syst_updated_datetime` timestamp ,
 `uneet_created_datetime` timestamp ,
 `creation_time` time 
)*/;

/*Table structure for table `ut_analysis_mefe_api_user_creation_time` */

DROP TABLE IF EXISTS `ut_analysis_mefe_api_user_creation_time`;

/*!50001 DROP VIEW IF EXISTS `ut_analysis_mefe_api_user_creation_time` */;
/*!50001 DROP TABLE IF EXISTS `ut_analysis_mefe_api_user_creation_time` */;

/*!50001 CREATE TABLE  `ut_analysis_mefe_api_user_creation_time`(
 `id_map` int(11) ,
 `uneet_login_name` varchar(255) ,
 `syst_created_datetime` timestamp ,
 `syst_updated_datetime` timestamp ,
 `uneet_created_datetime` timestamp ,
 `creation_time` time 
)*/;

/*Table structure for table `ut_check_unee_t_update_add_user_to_unit_level_1` */

DROP TABLE IF EXISTS `ut_check_unee_t_update_add_user_to_unit_level_1`;

/*!50001 DROP VIEW IF EXISTS `ut_check_unee_t_update_add_user_to_unit_level_1` */;
/*!50001 DROP TABLE IF EXISTS `ut_check_unee_t_update_add_user_to_unit_level_1` */;

/*!50001 CREATE TABLE  `ut_check_unee_t_update_add_user_to_unit_level_1`(
 `id_map_user_unit_permissions_level_1` int(11) unsigned ,
 `external_property_type_id` int(11) ,
 `uneet_name` varchar(255) ,
 `unee_t_mefe_user_id` varchar(255) ,
 `unee_t_mefe_unit_id` varchar(255) ,
 `unee_t_update_ts` timestamp 
)*/;

/*Table structure for table `ut_check_unee_t_update_add_user_to_unit_level_2` */

DROP TABLE IF EXISTS `ut_check_unee_t_update_add_user_to_unit_level_2`;

/*!50001 DROP VIEW IF EXISTS `ut_check_unee_t_update_add_user_to_unit_level_2` */;
/*!50001 DROP TABLE IF EXISTS `ut_check_unee_t_update_add_user_to_unit_level_2` */;

/*!50001 CREATE TABLE  `ut_check_unee_t_update_add_user_to_unit_level_2`(
 `id_map_user_unit_permissions_level_2` int(11) unsigned ,
 `external_property_type_id` int(11) ,
 `uneet_name` varchar(255) ,
 `unee_t_mefe_user_id` varchar(255) ,
 `unee_t_mefe_unit_id` varchar(255) ,
 `unee_t_update_ts` timestamp 
)*/;

/*Table structure for table `ut_check_unee_t_update_add_user_to_unit_level_3` */

DROP TABLE IF EXISTS `ut_check_unee_t_update_add_user_to_unit_level_3`;

/*!50001 DROP VIEW IF EXISTS `ut_check_unee_t_update_add_user_to_unit_level_3` */;
/*!50001 DROP TABLE IF EXISTS `ut_check_unee_t_update_add_user_to_unit_level_3` */;

/*!50001 CREATE TABLE  `ut_check_unee_t_update_add_user_to_unit_level_3`(
 `id_map_user_unit_permissions_level_3` int(11) unsigned ,
 `external_property_type_id` int(11) ,
 `uneet_name` varchar(255) ,
 `unee_t_mefe_user_id` varchar(255) ,
 `unee_t_mefe_unit_id` varchar(255) ,
 `unee_t_update_ts` timestamp 
)*/;

/*Table structure for table `ut_check_unee_t_updates_persons` */

DROP TABLE IF EXISTS `ut_check_unee_t_updates_persons`;

/*!50001 DROP VIEW IF EXISTS `ut_check_unee_t_updates_persons` */;
/*!50001 DROP TABLE IF EXISTS `ut_check_unee_t_updates_persons` */;

/*!50001 CREATE TABLE  `ut_check_unee_t_updates_persons`(
 `id_person` int(11) ,
 `given_name` varchar(255) ,
 `family_name` varchar(255) ,
 `email` varchar(255) ,
 `unee_t_mefe_user_id` varchar(255) ,
 `uneet_login_name` varchar(255) ,
 `uneet_created_datetime` timestamp ,
 `is_unee_t_created_by_me` tinyint(1) ,
 `creation_method` varchar(255) ,
 `update_method` varchar(255) ,
 `organization_id` int(11) unsigned 
)*/;

/*Table structure for table `ut_check_unee_t_updates_property_level_1` */

DROP TABLE IF EXISTS `ut_check_unee_t_updates_property_level_1`;

/*!50001 DROP VIEW IF EXISTS `ut_check_unee_t_updates_property_level_1` */;
/*!50001 DROP TABLE IF EXISTS `ut_check_unee_t_updates_property_level_1` */;

/*!50001 CREATE TABLE  `ut_check_unee_t_updates_property_level_1`(
 `id_building` int(11) ,
 `designation` varchar(255) ,
 `tower` varchar(50) ,
 `unee_t_mefe_unit_id` varchar(255) ,
 `uneet_name` varchar(255) ,
 `uneet_created_datetime` timestamp ,
 `is_unee_t_created_by_me` tinyint(1) ,
 `creation_method` varchar(255) ,
 `update_method` varchar(255) ,
 `organization_id` int(11) unsigned 
)*/;

/*Table structure for table `ut_check_unee_t_updates_property_level_2` */

DROP TABLE IF EXISTS `ut_check_unee_t_updates_property_level_2`;

/*!50001 DROP VIEW IF EXISTS `ut_check_unee_t_updates_property_level_2` */;
/*!50001 DROP TABLE IF EXISTS `ut_check_unee_t_updates_property_level_2` */;

/*!50001 CREATE TABLE  `ut_check_unee_t_updates_property_level_2`(
 `system_id_unit` int(11) ,
 `designation` varchar(50) ,
 `unee_t_mefe_unit_id` varchar(255) ,
 `uneet_name` varchar(255) ,
 `uneet_created_datetime` timestamp ,
 `is_unee_t_created_by_me` tinyint(1) ,
 `creation_method` varchar(255) ,
 `update_method` varchar(255) ,
 `organization_id` int(11) unsigned 
)*/;

/*Table structure for table `ut_check_unee_t_updates_property_level_3` */

DROP TABLE IF EXISTS `ut_check_unee_t_updates_property_level_3`;

/*!50001 DROP VIEW IF EXISTS `ut_check_unee_t_updates_property_level_3` */;
/*!50001 DROP TABLE IF EXISTS `ut_check_unee_t_updates_property_level_3` */;

/*!50001 CREATE TABLE  `ut_check_unee_t_updates_property_level_3`(
 `system_id_room` int(11) ,
 `room_designation` varchar(255) ,
 `unee_t_mefe_unit_id` varchar(255) ,
 `uneet_name` varchar(255) ,
 `uneet_created_datetime` timestamp ,
 `is_unee_t_created_by_me` tinyint(1) ,
 `creation_method` varchar(255) ,
 `update_method` varchar(255) ,
 `organization_id` int(11) unsigned 
)*/;

/*Table structure for table `ut_info_external_persons` */

DROP TABLE IF EXISTS `ut_info_external_persons`;

/*!50001 DROP VIEW IF EXISTS `ut_info_external_persons` */;
/*!50001 DROP TABLE IF EXISTS `ut_info_external_persons` */;

/*!50001 CREATE TABLE  `ut_info_external_persons`(
 `id_external_persons` int(11) ,
 `external_id` varchar(255) ,
 `external_system` varchar(255) ,
 `external_table` varchar(255) ,
 `organization_id` int(11) unsigned ,
 `name` text ,
 `email` varchar(255) 
)*/;

/*Table structure for table `ut_info_mefe_users` */

DROP TABLE IF EXISTS `ut_info_mefe_users`;

/*!50001 DROP VIEW IF EXISTS `ut_info_mefe_users` */;
/*!50001 DROP TABLE IF EXISTS `ut_info_mefe_users` */;

/*!50001 CREATE TABLE  `ut_info_mefe_users`(
 `id_person` int(11) ,
 `unee_t_mefe_user_id` varchar(255) ,
 `external_person_id` varchar(255) ,
 `external_system` varchar(255) ,
 `table_in_external_system` varchar(255) ,
 `organization_id` int(11) unsigned ,
 `uneet_login_name` varchar(255) ,
 `name` text ,
 `email` varchar(255) 
)*/;

/*Table structure for table `ut_info_persons` */

DROP TABLE IF EXISTS `ut_info_persons`;

/*!50001 DROP VIEW IF EXISTS `ut_info_persons` */;
/*!50001 DROP TABLE IF EXISTS `ut_info_persons` */;

/*!50001 CREATE TABLE  `ut_info_persons`(
 `id_person` int(11) ,
 `external_id` varchar(255) ,
 `external_system` varchar(255) ,
 `external_table` varchar(255) ,
 `organization_id` int(11) unsigned ,
 `name` text ,
 `email` varchar(255) 
)*/;

/*Table structure for table `ut_list_mefe_unit_id_level_1_by_area` */

DROP TABLE IF EXISTS `ut_list_mefe_unit_id_level_1_by_area`;

/*!50001 DROP VIEW IF EXISTS `ut_list_mefe_unit_id_level_1_by_area` */;
/*!50001 DROP TABLE IF EXISTS `ut_list_mefe_unit_id_level_1_by_area` */;

/*!50001 CREATE TABLE  `ut_list_mefe_unit_id_level_1_by_area`(
 `id_area` int(11) ,
 `external_area_id` int(11) ,
 `area_name` varchar(50) ,
 `level_1_building_id` int(11) ,
 `external_level_1_building_id` int(11) ,
 `level_1_building_name` varchar(255) ,
 `external_property_type_id` int(11) ,
 `unee_t_mefe_unit_id` varchar(255) ,
 `organization_id` int(11) unsigned 
)*/;

/*Table structure for table `ut_list_mefe_unit_id_level_2_by_area` */

DROP TABLE IF EXISTS `ut_list_mefe_unit_id_level_2_by_area`;

/*!50001 DROP VIEW IF EXISTS `ut_list_mefe_unit_id_level_2_by_area` */;
/*!50001 DROP TABLE IF EXISTS `ut_list_mefe_unit_id_level_2_by_area` */;

/*!50001 CREATE TABLE  `ut_list_mefe_unit_id_level_2_by_area`(
 `id_area` int(11) ,
 `area_name` varchar(50) ,
 `level_1_building_id` int(11) ,
 `external_level_1_building_id` int(11) ,
 `level_1_building_name` varchar(255) ,
 `level_2_unit_id` int(11) ,
 `external_level_2_unit_id` int(11) ,
 `level_2_unit_name` varchar(50) ,
 `external_property_type_id` int(11) ,
 `unee_t_mefe_unit_id` varchar(255) ,
 `organization_id` int(11) unsigned 
)*/;

/*Table structure for table `ut_list_mefe_unit_id_level_3_by_area` */

DROP TABLE IF EXISTS `ut_list_mefe_unit_id_level_3_by_area`;

/*!50001 DROP VIEW IF EXISTS `ut_list_mefe_unit_id_level_3_by_area` */;
/*!50001 DROP TABLE IF EXISTS `ut_list_mefe_unit_id_level_3_by_area` */;

/*!50001 CREATE TABLE  `ut_list_mefe_unit_id_level_3_by_area`(
 `id_area` int(11) ,
 `area_name` varchar(50) ,
 `level_1_building_id` int(11) ,
 `level_1_building_name` varchar(255) ,
 `level_2_unit_id` int(11) ,
 `external_level_2_unit_id` int(11) ,
 `level_2_unit_name` varchar(50) ,
 `level_3_room_id` int(11) ,
 `external_level_3_room_id` int(11) ,
 `level_3_room_name` varchar(255) ,
 `external_property_type_id` int(11) ,
 `unee_t_mefe_unit_id` varchar(255) ,
 `organization_id` int(11) unsigned 
)*/;

/*Table structure for table `ut_list_unit_id_level_1_failed_creation` */

DROP TABLE IF EXISTS `ut_list_unit_id_level_1_failed_creation`;

/*!50001 DROP VIEW IF EXISTS `ut_list_unit_id_level_1_failed_creation` */;
/*!50001 DROP TABLE IF EXISTS `ut_list_unit_id_level_1_failed_creation` */;

/*!50001 CREATE TABLE  `ut_list_unit_id_level_1_failed_creation`(
 `unit_creation_request_id` int(11) ,
 `creation_request_ts` timestamp ,
 `mefe_api_reply_ts` timestamp ,
 `mefe_api_error_message` text ,
 `created_by_id` varchar(255) ,
 `organization_id` int(11) unsigned ,
 `building_id` int(11) ,
 `uneet_name` varchar(255) ,
 `unee_t_unit_type` varchar(100) ,
 `more_info` text ,
 `street_address` varchar(102) ,
 `city` varchar(50) ,
 `state` varchar(50) ,
 `zip_code` varchar(50) ,
 `country` varchar(256) 
)*/;

/*Table structure for table `ut_list_unit_id_level_2_failed_creation` */

DROP TABLE IF EXISTS `ut_list_unit_id_level_2_failed_creation`;

/*!50001 DROP VIEW IF EXISTS `ut_list_unit_id_level_2_failed_creation` */;
/*!50001 DROP TABLE IF EXISTS `ut_list_unit_id_level_2_failed_creation` */;

/*!50001 CREATE TABLE  `ut_list_unit_id_level_2_failed_creation`(
 `unit_creation_request_id` int(11) ,
 `creation_request_ts` timestamp ,
 `mefe_api_reply_ts` timestamp ,
 `mefe_api_error_message` text ,
 `created_by_id` varchar(255) ,
 `organization_id` int(11) unsigned ,
 `system_id_unit` int(11) ,
 `uneet_name` varchar(255) ,
 `unee_t_unit_type` varchar(100) ,
 `more_info` text ,
 `street_address` varchar(413) ,
 `city` varchar(50) ,
 `state` varchar(50) ,
 `zip_code` varchar(50) ,
 `country` varchar(256) 
)*/;

/*Table structure for table `ut_list_unit_id_level_3_failed_creation` */

DROP TABLE IF EXISTS `ut_list_unit_id_level_3_failed_creation`;

/*!50001 DROP VIEW IF EXISTS `ut_list_unit_id_level_3_failed_creation` */;
/*!50001 DROP TABLE IF EXISTS `ut_list_unit_id_level_3_failed_creation` */;

/*!50001 CREATE TABLE  `ut_list_unit_id_level_3_failed_creation`(
 `unit_creation_request_id` int(11) ,
 `creation_request_ts` timestamp ,
 `mefe_api_reply_ts` timestamp ,
 `mefe_api_error_message` text ,
 `created_by_id` varchar(255) ,
 `organization_id` int(11) unsigned ,
 `system_id_room` int(11) ,
 `uneet_name` varchar(255) ,
 `unee_t_unit_type` varchar(100) ,
 `more_info` mediumtext ,
 `street_address` varchar(413) ,
 `city` varchar(50) ,
 `state` varchar(50) ,
 `zip_code` varchar(50) ,
 `country` varchar(256) 
)*/;

/*Table structure for table `ut_organization_associated_mefe_user` */

DROP TABLE IF EXISTS `ut_organization_associated_mefe_user`;

/*!50001 DROP VIEW IF EXISTS `ut_organization_associated_mefe_user` */;
/*!50001 DROP TABLE IF EXISTS `ut_organization_associated_mefe_user` */;

/*!50001 CREATE TABLE  `ut_organization_associated_mefe_user`(
 `associated_mefe_user` varchar(255) ,
 `organization_id` int(11) unsigned 
)*/;

/*Table structure for table `ut_organization_default_area` */

DROP TABLE IF EXISTS `ut_organization_default_area`;

/*!50001 DROP VIEW IF EXISTS `ut_organization_default_area` */;
/*!50001 DROP TABLE IF EXISTS `ut_organization_default_area` */;

/*!50001 CREATE TABLE  `ut_organization_default_area`(
 `default_area_id` int(11) ,
 `default_area_name` varchar(50) ,
 `organization_id` int(11) unsigned 
)*/;

/*Table structure for table `ut_organization_default_external_system` */

DROP TABLE IF EXISTS `ut_organization_default_external_system`;

/*!50001 DROP VIEW IF EXISTS `ut_organization_default_external_system` */;
/*!50001 DROP TABLE IF EXISTS `ut_organization_default_external_system` */;

/*!50001 CREATE TABLE  `ut_organization_default_external_system`(
 `designation` varchar(255) ,
 `organization_id` int(11) unsigned 
)*/;

/*Table structure for table `ut_organization_default_table_areas` */

DROP TABLE IF EXISTS `ut_organization_default_table_areas`;

/*!50001 DROP VIEW IF EXISTS `ut_organization_default_table_areas` */;
/*!50001 DROP TABLE IF EXISTS `ut_organization_default_table_areas` */;

/*!50001 CREATE TABLE  `ut_organization_default_table_areas`(
 `area_table` varchar(255) ,
 `organization_id` int(11) unsigned 
)*/;

/*Table structure for table `ut_organization_default_table_level_1_properties` */

DROP TABLE IF EXISTS `ut_organization_default_table_level_1_properties`;

/*!50001 DROP VIEW IF EXISTS `ut_organization_default_table_level_1_properties` */;
/*!50001 DROP TABLE IF EXISTS `ut_organization_default_table_level_1_properties` */;

/*!50001 CREATE TABLE  `ut_organization_default_table_level_1_properties`(
 `properties_level_1_table` varchar(255) ,
 `organization_id` int(11) unsigned 
)*/;

/*Table structure for table `ut_organization_default_table_level_2_properties` */

DROP TABLE IF EXISTS `ut_organization_default_table_level_2_properties`;

/*!50001 DROP VIEW IF EXISTS `ut_organization_default_table_level_2_properties` */;
/*!50001 DROP TABLE IF EXISTS `ut_organization_default_table_level_2_properties` */;

/*!50001 CREATE TABLE  `ut_organization_default_table_level_2_properties`(
 `properties_level_2_table` varchar(255) ,
 `organization_id` int(11) unsigned 
)*/;

/*Table structure for table `ut_organization_default_table_level_3_properties` */

DROP TABLE IF EXISTS `ut_organization_default_table_level_3_properties`;

/*!50001 DROP VIEW IF EXISTS `ut_organization_default_table_level_3_properties` */;
/*!50001 DROP TABLE IF EXISTS `ut_organization_default_table_level_3_properties` */;

/*!50001 CREATE TABLE  `ut_organization_default_table_level_3_properties`(
 `properties_level_3_table` varchar(255) ,
 `organization_id` int(11) unsigned 
)*/;

/*Table structure for table `ut_organization_default_table_persons` */

DROP TABLE IF EXISTS `ut_organization_default_table_persons`;

/*!50001 DROP VIEW IF EXISTS `ut_organization_default_table_persons` */;
/*!50001 DROP TABLE IF EXISTS `ut_organization_default_table_persons` */;

/*!50001 CREATE TABLE  `ut_organization_default_table_persons`(
 `person_table` varchar(255) ,
 `organization_id` int(11) unsigned 
)*/;

/*Table structure for table `ut_organization_mefe_user_id` */

DROP TABLE IF EXISTS `ut_organization_mefe_user_id`;

/*!50001 DROP VIEW IF EXISTS `ut_organization_mefe_user_id` */;
/*!50001 DROP TABLE IF EXISTS `ut_organization_mefe_user_id` */;

/*!50001 CREATE TABLE  `ut_organization_mefe_user_id`(
 `mefe_user_id` varchar(255) ,
 `organization_id` int(11) unsigned 
)*/;

/*Table structure for table `ut_user_information_persons` */

DROP TABLE IF EXISTS `ut_user_information_persons`;

/*!50001 DROP VIEW IF EXISTS `ut_user_information_persons` */;
/*!50001 DROP TABLE IF EXISTS `ut_user_information_persons` */;

/*!50001 CREATE TABLE  `ut_user_information_persons`(
 `id_person` int(11) ,
 `external_person_id` varchar(255) ,
 `external_system` varchar(255) ,
 `table_in_external_system` varchar(255) ,
 `organization_id` int(11) unsigned ,
 `email_address` varchar(255) ,
 `first_name` varchar(255) ,
 `last_name` varchar(255) ,
 `phone_number` varchar(50) 
)*/;

/*View structure for view ut_add_information_unit_level_1 */

/*!50001 DROP TABLE IF EXISTS `ut_add_information_unit_level_1` */;
/*!50001 DROP VIEW IF EXISTS `ut_add_information_unit_level_1` */;

/*!50001 CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `ut_add_information_unit_level_1` AS select `a`.`id_building` AS `unit_level_1_id`,`a`.`is_creation_needed_in_unee_t` AS `is_create_condo`,`a`.`unee_t_unit_type` AS `unee_t_unit_type`,`a`.`designation` AS `name`,`a`.`description` AS `more_info`,`a`.`tower` AS `tower`,if((`a`.`address_1` is not null),concat(`a`.`address_1`,' \n',ifnull(`a`.`address_2`,'')),ifnull(`a`.`address_2`,NULL)) AS `street_address`,`a`.`city` AS `city`,`a`.`zip_postal_code` AS `zip_code`,`a`.`state` AS `state`,`a`.`country_code` AS `country_code`,`c`.`country_name` AS `country` from (`property_level_1_buildings` `a` left join `property_groups_countries` `c` on((`c`.`country_code` = `a`.`country_code`))) */;

/*View structure for view ut_add_information_unit_level_2 */

/*!50001 DROP TABLE IF EXISTS `ut_add_information_unit_level_2` */;
/*!50001 DROP VIEW IF EXISTS `ut_add_information_unit_level_2` */;

/*!50001 CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `ut_add_information_unit_level_2` AS select `a`.`system_id_unit` AS `unit_level_2_id`,`a`.`is_creation_needed_in_unee_t` AS `is_create_flat`,`a`.`unee_t_unit_type` AS `unee_t_unit_type`,`a`.`designation` AS `name`,`a`.`description` AS `more_info`,if((`b`.`address_1` is not null),concat(`b`.`designation`,' \n',if((`b`.`address_1` is not null),concat(`b`.`address_1`,' \n',ifnull(`b`.`address_2`,''),if((`a`.`unit_id` is not null),concat(' \n',' #',`a`.`unit_id`),'')),if((`b`.`address_2` is not null),concat(`b`.`address_2`,if((`a`.`unit_id` is not null),concat(' \n',' #',`a`.`unit_id`),'')),if((`a`.`unit_id` is not null),concat(' #',`a`.`unit_id`),'')))),NULL) AS `street_address`,`b`.`city` AS `city`,`b`.`state` AS `state`,`b`.`zip_postal_code` AS `zip_code`,`d`.`country_name` AS `country` from ((`property_level_2_units` `a` join `property_level_1_buildings` `b` on((`a`.`building_system_id` = `b`.`id_building`))) left join `property_groups_countries` `d` on((`d`.`country_code` = `b`.`country_code`))) */;

/*View structure for view ut_add_information_unit_level_3 */

/*!50001 DROP TABLE IF EXISTS `ut_add_information_unit_level_3` */;
/*!50001 DROP VIEW IF EXISTS `ut_add_information_unit_level_3` */;

/*!50001 CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `ut_add_information_unit_level_3` AS select `a`.`system_id_room` AS `unit_level_3_id`,`a`.`is_creation_needed_in_unee_t` AS `is_create_room`,`a`.`unee_t_unit_type` AS `unee_t_unit_type`,`a`.`room_designation` AS `name`,`a`.`room_description` AS `more_info`,if((`c`.`address_1` is not null),concat(`c`.`designation`,' \n',if((`c`.`address_1` is not null),concat(`c`.`address_1`,' \n',ifnull(`c`.`address_2`,''),if((`b`.`unit_id` is not null),concat(' \n',' #',`b`.`unit_id`),'')),if((`c`.`address_2` is not null),concat(`c`.`address_2`,if((`b`.`unit_id` is not null),concat(' \n',' #',`b`.`unit_id`),'')),if((`b`.`unit_id` is not null),concat(' #',`b`.`unit_id`),'')))),NULL) AS `street_address`,`c`.`city` AS `city`,`c`.`state` AS `state`,`c`.`zip_postal_code` AS `zip_code`,`e`.`country_name` AS `country` from (((`property_level_3_rooms` `a` join `property_level_2_units` `b` on((`a`.`system_id_unit` = `b`.`system_id_unit`))) join `property_level_1_buildings` `c` on((`b`.`building_system_id` = `c`.`id_building`))) left join `property_groups_countries` `e` on((`e`.`country_code` = `c`.`country_code`))) */;

/*View structure for view ut_analysis_errors_not_an_owner_count */

/*!50001 DROP TABLE IF EXISTS `ut_analysis_errors_not_an_owner_count` */;
/*!50001 DROP VIEW IF EXISTS `ut_analysis_errors_not_an_owner_count` */;

/*!50001 CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `ut_analysis_errors_not_an_owner_count` AS select count(`ut_analysis_errors_not_an_owner_list`.`id_map_user_unit_permissions`) AS `count_reuquestor_not_an_owner` from `ut_analysis_errors_not_an_owner_list` group by `ut_analysis_errors_not_an_owner_list`.`is_mefe_api_success` */;

/*View structure for view ut_analysis_errors_not_an_owner_list */

/*!50001 DROP TABLE IF EXISTS `ut_analysis_errors_not_an_owner_list` */;
/*!50001 DROP VIEW IF EXISTS `ut_analysis_errors_not_an_owner_list` */;

/*!50001 CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `ut_analysis_errors_not_an_owner_list` AS select `a`.`id_map_user_unit_permissions` AS `id_map_user_unit_permissions`,`a`.`syst_created_datetime` AS `syst_created_datetime`,`a`.`unee_t_update_ts` AS `unee_t_update_ts`,`a`.`is_mefe_api_success` AS `is_mefe_api_success`,`a`.`mefe_api_error_message` AS `mefe_api_error_message`,`a`.`unee_t_mefe_id` AS `mefe_user_id`,`b`.`uneet_login_name` AS `uneet_login_name`,`a`.`unee_t_unit_id` AS `unee_t_unit_id`,`c`.`uneet_name` AS `uneet_name`,`d`.`role_type` AS `role_type` from (((`ut_map_user_permissions_unit_all` `a` left join `ut_map_external_source_users` `b` on((`a`.`unee_t_mefe_id` = `b`.`unee_t_mefe_user_id`))) left join `ut_map_external_source_units` `c` on((`a`.`unee_t_unit_id` = `c`.`unee_t_mefe_unit_id`))) left join `ut_user_role_types` `d` on((`a`.`unee_t_role_id` = `d`.`id_role_type`))) where ((`a`.`is_mefe_api_success` = 0) and (`a`.`mefe_api_error_message` like '%not an owner of unit%')) */;

/*View structure for view ut_analysis_errors_user_already_has_a_role_count */

/*!50001 DROP TABLE IF EXISTS `ut_analysis_errors_user_already_has_a_role_count` */;
/*!50001 DROP VIEW IF EXISTS `ut_analysis_errors_user_already_has_a_role_count` */;

/*!50001 CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `ut_analysis_errors_user_already_has_a_role_count` AS select count(`ut_analysis_errors_user_already_has_a_role_list`.`id_map_user_unit_permissions`) AS `count_user_already_has_role` from `ut_analysis_errors_user_already_has_a_role_list` group by `ut_analysis_errors_user_already_has_a_role_list`.`is_mefe_api_success` */;

/*View structure for view ut_analysis_errors_user_already_has_a_role_list */

/*!50001 DROP TABLE IF EXISTS `ut_analysis_errors_user_already_has_a_role_list` */;
/*!50001 DROP VIEW IF EXISTS `ut_analysis_errors_user_already_has_a_role_list` */;

/*!50001 CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `ut_analysis_errors_user_already_has_a_role_list` AS select `a`.`id_map_user_unit_permissions` AS `id_map_user_unit_permissions`,`a`.`syst_created_datetime` AS `syst_created_datetime`,`a`.`unee_t_update_ts` AS `unee_t_update_ts`,`a`.`is_mefe_api_success` AS `is_mefe_api_success`,`a`.`mefe_api_error_message` AS `mefe_api_error_message`,`a`.`unee_t_mefe_id` AS `mefe_user_id`,`b`.`uneet_login_name` AS `uneet_login_name`,`a`.`unee_t_unit_id` AS `unee_t_unit_id`,`c`.`uneet_name` AS `uneet_name`,`d`.`role_type` AS `role_type` from (((`ut_map_user_permissions_unit_all` `a` left join `ut_map_external_source_users` `b` on((`a`.`unee_t_mefe_id` = `b`.`unee_t_mefe_user_id`))) left join `ut_map_external_source_units` `c` on((`a`.`unee_t_unit_id` = `c`.`unee_t_mefe_unit_id`))) left join `ut_user_role_types` `d` on((`a`.`unee_t_role_id` = `d`.`id_role_type`))) where ((`a`.`is_mefe_api_success` = 0) and (`a`.`mefe_api_error_message` like '%The invited user already has a role in this unit%')) */;

/*View structure for view ut_analysis_mefe_api_assign_user_to_unit_creation_time */

/*!50001 DROP TABLE IF EXISTS `ut_analysis_mefe_api_assign_user_to_unit_creation_time` */;
/*!50001 DROP VIEW IF EXISTS `ut_analysis_mefe_api_assign_user_to_unit_creation_time` */;

/*!50001 CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `ut_analysis_mefe_api_assign_user_to_unit_creation_time` AS select `a`.`id_map_user_unit_permissions` AS `id_map_user_unit_permissions`,`b`.`uneet_login_name` AS `uneet_login_name`,`c`.`uneet_name` AS `uneet_name`,`a`.`syst_created_datetime` AS `syst_created_datetime`,`a`.`syst_updated_datetime` AS `syst_updated_datetime`,`a`.`unee_t_update_ts` AS `unee_t_update_ts`,timediff(`a`.`unee_t_update_ts`,`a`.`syst_created_datetime`) AS `creation_time` from ((`ut_map_user_permissions_unit_all` `a` join `ut_map_external_source_users` `b` on((`a`.`unee_t_mefe_id` = `b`.`unee_t_mefe_user_id`))) join `ut_map_external_source_units` `c` on((`a`.`unee_t_unit_id` = `c`.`unee_t_mefe_unit_id`))) where (`a`.`unee_t_update_ts` is not null) order by `a`.`syst_created_datetime` desc,`a`.`unee_t_update_ts` desc,`a`.`syst_updated_datetime` desc */;

/*View structure for view ut_analysis_mefe_api_unit_creation_time */

/*!50001 DROP TABLE IF EXISTS `ut_analysis_mefe_api_unit_creation_time` */;
/*!50001 DROP VIEW IF EXISTS `ut_analysis_mefe_api_unit_creation_time` */;

/*!50001 CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `ut_analysis_mefe_api_unit_creation_time` AS select `ut_map_external_source_units`.`id_map` AS `id_map`,`ut_map_external_source_units`.`uneet_name` AS `uneet_name`,`ut_map_external_source_units`.`external_property_type_id` AS `external_property_type_id`,`ut_map_external_source_units`.`syst_created_datetime` AS `syst_created_datetime`,`ut_map_external_source_units`.`syst_updated_datetime` AS `syst_updated_datetime`,`ut_map_external_source_units`.`uneet_created_datetime` AS `uneet_created_datetime`,timediff(`ut_map_external_source_units`.`uneet_created_datetime`,`ut_map_external_source_units`.`syst_created_datetime`) AS `creation_time` from `ut_map_external_source_units` where (`ut_map_external_source_units`.`unee_t_mefe_unit_id` is not null) order by `ut_map_external_source_units`.`syst_created_datetime` desc,`ut_map_external_source_units`.`external_property_type_id`,`ut_map_external_source_units`.`uneet_created_datetime` desc,`ut_map_external_source_units`.`syst_updated_datetime` desc */;

/*View structure for view ut_analysis_mefe_api_user_creation_time */

/*!50001 DROP TABLE IF EXISTS `ut_analysis_mefe_api_user_creation_time` */;
/*!50001 DROP VIEW IF EXISTS `ut_analysis_mefe_api_user_creation_time` */;

/*!50001 CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `ut_analysis_mefe_api_user_creation_time` AS select `ut_map_external_source_users`.`id_map` AS `id_map`,`ut_map_external_source_users`.`uneet_login_name` AS `uneet_login_name`,`ut_map_external_source_users`.`syst_created_datetime` AS `syst_created_datetime`,`ut_map_external_source_users`.`syst_updated_datetime` AS `syst_updated_datetime`,`ut_map_external_source_users`.`uneet_created_datetime` AS `uneet_created_datetime`,timediff(`ut_map_external_source_users`.`uneet_created_datetime`,`ut_map_external_source_users`.`syst_created_datetime`) AS `creation_time` from `ut_map_external_source_users` where (`ut_map_external_source_users`.`unee_t_mefe_user_id` is not null) order by `ut_map_external_source_users`.`syst_created_datetime` desc,`ut_map_external_source_users`.`uneet_created_datetime` desc,`ut_map_external_source_users`.`syst_updated_datetime` desc */;

/*View structure for view ut_check_unee_t_update_add_user_to_unit_level_1 */

/*!50001 DROP TABLE IF EXISTS `ut_check_unee_t_update_add_user_to_unit_level_1` */;
/*!50001 DROP VIEW IF EXISTS `ut_check_unee_t_update_add_user_to_unit_level_1` */;

/*!50001 CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `ut_check_unee_t_update_add_user_to_unit_level_1` AS select `external_map_user_unit_role_permissions_level_1`.`id_map_user_unit_permissions_level_1` AS `id_map_user_unit_permissions_level_1`,`ut_map_external_source_units`.`external_property_type_id` AS `external_property_type_id`,`ut_map_external_source_units`.`uneet_name` AS `uneet_name`,`external_map_user_unit_role_permissions_level_1`.`unee_t_mefe_user_id` AS `unee_t_mefe_user_id`,`ut_map_external_source_units`.`unee_t_mefe_unit_id` AS `unee_t_mefe_unit_id`,`ut_map_user_permissions_unit_all`.`unee_t_update_ts` AS `unee_t_update_ts` from ((`external_map_user_unit_role_permissions_level_1` join `ut_map_user_permissions_unit_all` on((`external_map_user_unit_role_permissions_level_1`.`unee_t_mefe_user_id` = `ut_map_user_permissions_unit_all`.`unee_t_mefe_id`))) join `ut_map_external_source_units` on(((`ut_map_user_permissions_unit_all`.`unee_t_unit_id` = `ut_map_external_source_units`.`unee_t_mefe_unit_id`) and (`external_map_user_unit_role_permissions_level_1`.`unee_t_level_1_id` = `ut_map_external_source_units`.`new_record_id`)))) where (`ut_map_external_source_units`.`external_property_type_id` = 1) */;

/*View structure for view ut_check_unee_t_update_add_user_to_unit_level_2 */

/*!50001 DROP TABLE IF EXISTS `ut_check_unee_t_update_add_user_to_unit_level_2` */;
/*!50001 DROP VIEW IF EXISTS `ut_check_unee_t_update_add_user_to_unit_level_2` */;

/*!50001 CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `ut_check_unee_t_update_add_user_to_unit_level_2` AS select `external_map_user_unit_role_permissions_level_2`.`id_map_user_unit_permissions_level_2` AS `id_map_user_unit_permissions_level_2`,`ut_map_external_source_units`.`external_property_type_id` AS `external_property_type_id`,`ut_map_external_source_units`.`uneet_name` AS `uneet_name`,`external_map_user_unit_role_permissions_level_2`.`unee_t_mefe_user_id` AS `unee_t_mefe_user_id`,`ut_map_external_source_units`.`unee_t_mefe_unit_id` AS `unee_t_mefe_unit_id`,`ut_map_user_permissions_unit_all`.`unee_t_update_ts` AS `unee_t_update_ts` from ((`external_map_user_unit_role_permissions_level_2` join `ut_map_user_permissions_unit_all` on((`external_map_user_unit_role_permissions_level_2`.`unee_t_mefe_user_id` = `ut_map_user_permissions_unit_all`.`unee_t_mefe_id`))) join `ut_map_external_source_units` on(((`ut_map_user_permissions_unit_all`.`unee_t_unit_id` = `ut_map_external_source_units`.`unee_t_mefe_unit_id`) and (`external_map_user_unit_role_permissions_level_2`.`unee_t_level_2_id` = `ut_map_external_source_units`.`new_record_id`)))) where (`ut_map_external_source_units`.`external_property_type_id` = 2) */;

/*View structure for view ut_check_unee_t_update_add_user_to_unit_level_3 */

/*!50001 DROP TABLE IF EXISTS `ut_check_unee_t_update_add_user_to_unit_level_3` */;
/*!50001 DROP VIEW IF EXISTS `ut_check_unee_t_update_add_user_to_unit_level_3` */;

/*!50001 CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `ut_check_unee_t_update_add_user_to_unit_level_3` AS select `external_map_user_unit_role_permissions_level_3`.`id_map_user_unit_permissions_level_3` AS `id_map_user_unit_permissions_level_3`,`ut_map_external_source_units`.`external_property_type_id` AS `external_property_type_id`,`ut_map_external_source_units`.`uneet_name` AS `uneet_name`,`external_map_user_unit_role_permissions_level_3`.`unee_t_mefe_user_id` AS `unee_t_mefe_user_id`,`ut_map_external_source_units`.`unee_t_mefe_unit_id` AS `unee_t_mefe_unit_id`,`ut_map_user_permissions_unit_all`.`unee_t_update_ts` AS `unee_t_update_ts` from ((`external_map_user_unit_role_permissions_level_3` join `ut_map_user_permissions_unit_all` on((`external_map_user_unit_role_permissions_level_3`.`unee_t_mefe_user_id` = `ut_map_user_permissions_unit_all`.`unee_t_mefe_id`))) join `ut_map_external_source_units` on(((`ut_map_user_permissions_unit_all`.`unee_t_unit_id` = `ut_map_external_source_units`.`unee_t_mefe_unit_id`) and (`external_map_user_unit_role_permissions_level_3`.`unee_t_level_3_id` = `ut_map_external_source_units`.`new_record_id`)))) where (`ut_map_external_source_units`.`external_property_type_id` = 3) */;

/*View structure for view ut_check_unee_t_updates_persons */

/*!50001 DROP TABLE IF EXISTS `ut_check_unee_t_updates_persons` */;
/*!50001 DROP VIEW IF EXISTS `ut_check_unee_t_updates_persons` */;

/*!50001 CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `ut_check_unee_t_updates_persons` AS select `a`.`id_person` AS `id_person`,`a`.`given_name` AS `given_name`,`a`.`family_name` AS `family_name`,`a`.`email` AS `email`,`b`.`unee_t_mefe_user_id` AS `unee_t_mefe_user_id`,`b`.`uneet_login_name` AS `uneet_login_name`,`b`.`uneet_created_datetime` AS `uneet_created_datetime`,`b`.`is_unee_t_created_by_me` AS `is_unee_t_created_by_me`,`b`.`creation_method` AS `creation_method`,`b`.`update_method` AS `update_method`,`b`.`organization_id` AS `organization_id` from (`persons` `a` left join `ut_map_external_source_users` `b` on((`a`.`id_person` = `b`.`person_id`))) */;

/*View structure for view ut_check_unee_t_updates_property_level_1 */

/*!50001 DROP TABLE IF EXISTS `ut_check_unee_t_updates_property_level_1` */;
/*!50001 DROP VIEW IF EXISTS `ut_check_unee_t_updates_property_level_1` */;

/*!50001 CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `ut_check_unee_t_updates_property_level_1` AS select `a`.`id_building` AS `id_building`,`a`.`designation` AS `designation`,`a`.`tower` AS `tower`,`b`.`unee_t_mefe_unit_id` AS `unee_t_mefe_unit_id`,`b`.`uneet_name` AS `uneet_name`,`b`.`uneet_created_datetime` AS `uneet_created_datetime`,`b`.`is_unee_t_created_by_me` AS `is_unee_t_created_by_me`,`b`.`creation_method` AS `creation_method`,`b`.`update_method` AS `update_method`,`b`.`organization_id` AS `organization_id` from (`property_level_1_buildings` `a` left join `ut_map_external_source_units` `b` on(((`a`.`id_building` = `b`.`new_record_id`) and (`b`.`external_property_type_id` = 1)))) order by `a`.`area_id`,`a`.`order`,`a`.`tower` */;

/*View structure for view ut_check_unee_t_updates_property_level_2 */

/*!50001 DROP TABLE IF EXISTS `ut_check_unee_t_updates_property_level_2` */;
/*!50001 DROP VIEW IF EXISTS `ut_check_unee_t_updates_property_level_2` */;

/*!50001 CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `ut_check_unee_t_updates_property_level_2` AS select `a`.`system_id_unit` AS `system_id_unit`,`a`.`designation` AS `designation`,`b`.`unee_t_mefe_unit_id` AS `unee_t_mefe_unit_id`,`b`.`uneet_name` AS `uneet_name`,`b`.`uneet_created_datetime` AS `uneet_created_datetime`,`b`.`is_unee_t_created_by_me` AS `is_unee_t_created_by_me`,`b`.`creation_method` AS `creation_method`,`b`.`update_method` AS `update_method`,`b`.`organization_id` AS `organization_id` from ((`property_level_2_units` `a` left join `ut_map_external_source_units` `b` on(((`a`.`system_id_unit` = `b`.`new_record_id`) and (`b`.`external_property_type_id` = 2)))) join `property_level_1_buildings` `c` on((`a`.`building_system_id` = `c`.`id_building`))) order by `c`.`area_id`,`c`.`order`,`c`.`tower`,`a`.`designation` */;

/*View structure for view ut_check_unee_t_updates_property_level_3 */

/*!50001 DROP TABLE IF EXISTS `ut_check_unee_t_updates_property_level_3` */;
/*!50001 DROP VIEW IF EXISTS `ut_check_unee_t_updates_property_level_3` */;

/*!50001 CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `ut_check_unee_t_updates_property_level_3` AS select `room`.`system_id_room` AS `system_id_room`,`room`.`room_designation` AS `room_designation`,`map`.`unee_t_mefe_unit_id` AS `unee_t_mefe_unit_id`,`map`.`uneet_name` AS `uneet_name`,`map`.`uneet_created_datetime` AS `uneet_created_datetime`,`map`.`is_unee_t_created_by_me` AS `is_unee_t_created_by_me`,`map`.`creation_method` AS `creation_method`,`map`.`update_method` AS `update_method`,`map`.`organization_id` AS `organization_id` from (((`property_level_3_rooms` `room` left join `ut_map_external_source_units` `map` on(((`room`.`system_id_room` = `map`.`new_record_id`) and (`map`.`external_property_type_id` = 3)))) join `property_level_2_units` `unit` on((`room`.`system_id_unit` = `unit`.`system_id_unit`))) join `property_level_1_buildings` `building` on((`unit`.`building_system_id` = `building`.`id_building`))) order by `building`.`area_id`,`building`.`order`,`building`.`tower`,`unit`.`designation`,`room`.`room_designation` */;

/*View structure for view ut_info_external_persons */

/*!50001 DROP TABLE IF EXISTS `ut_info_external_persons` */;
/*!50001 DROP VIEW IF EXISTS `ut_info_external_persons` */;

/*!50001 CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `ut_info_external_persons` AS select `external_persons`.`id_person` AS `id_external_persons`,`external_persons`.`external_id` AS `external_id`,`external_persons`.`external_system` AS `external_system`,`external_persons`.`external_table` AS `external_table`,`external_persons`.`created_by_id` AS `organization_id`,concat(ifnull(`external_persons`.`given_name`,''),' ',ifnull(`external_persons`.`middle_name`,''),' ',ifnull(`external_persons`.`family_name`,''),' (',ifnull(`external_persons`.`alias`,''),')') AS `name`,`external_persons`.`email` AS `email` from `external_persons` */;

/*View structure for view ut_info_mefe_users */

/*!50001 DROP TABLE IF EXISTS `ut_info_mefe_users` */;
/*!50001 DROP VIEW IF EXISTS `ut_info_mefe_users` */;

/*!50001 CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `ut_info_mefe_users` AS select `persons`.`id_person` AS `id_person`,`ut_map_external_source_users`.`unee_t_mefe_user_id` AS `unee_t_mefe_user_id`,`ut_map_external_source_users`.`external_person_id` AS `external_person_id`,`ut_map_external_source_users`.`external_system` AS `external_system`,`ut_map_external_source_users`.`table_in_external_system` AS `table_in_external_system`,`persons`.`organization_id` AS `organization_id`,`ut_map_external_source_users`.`uneet_login_name` AS `uneet_login_name`,concat(ifnull(`persons`.`given_name`,''),' ',ifnull(`persons`.`middle_name`,''),' ',ifnull(`persons`.`family_name`,''),' (',ifnull(`persons`.`alias`,''),')') AS `name`,`persons`.`email` AS `email` from (`ut_map_external_source_users` join `persons` on((`ut_map_external_source_users`.`person_id` = `persons`.`id_person`))) */;

/*View structure for view ut_info_persons */

/*!50001 DROP TABLE IF EXISTS `ut_info_persons` */;
/*!50001 DROP VIEW IF EXISTS `ut_info_persons` */;

/*!50001 CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `ut_info_persons` AS select `persons`.`id_person` AS `id_person`,`persons`.`external_id` AS `external_id`,`persons`.`external_system` AS `external_system`,`persons`.`external_table` AS `external_table`,`persons`.`organization_id` AS `organization_id`,concat(ifnull(`persons`.`given_name`,''),' ',ifnull(`persons`.`middle_name`,''),' ',ifnull(`persons`.`family_name`,''),' (',ifnull(`persons`.`alias`,''),')') AS `name`,`persons`.`email` AS `email` from `persons` */;

/*View structure for view ut_list_mefe_unit_id_level_1_by_area */

/*!50001 DROP TABLE IF EXISTS `ut_list_mefe_unit_id_level_1_by_area` */;
/*!50001 DROP VIEW IF EXISTS `ut_list_mefe_unit_id_level_1_by_area` */;

/*!50001 CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `ut_list_mefe_unit_id_level_1_by_area` AS select `b`.`id_area` AS `id_area`,`d`.`area_id` AS `external_area_id`,`b`.`area_name` AS `area_name`,`a`.`id_building` AS `level_1_building_id`,`d`.`id_building` AS `external_level_1_building_id`,`a`.`designation` AS `level_1_building_name`,`c`.`external_property_type_id` AS `external_property_type_id`,`c`.`unee_t_mefe_unit_id` AS `unee_t_mefe_unit_id`,`a`.`organization_id` AS `organization_id` from (((`property_level_1_buildings` `a` join `property_groups_areas` `b` on((`a`.`area_id` = `b`.`id_area`))) join `ut_map_external_source_units` `c` on(((`a`.`external_id` = `c`.`external_property_id`) and (`a`.`external_system_id` = `c`.`external_system`) and (`a`.`external_table` = `c`.`table_in_external_system`) and (`a`.`organization_id` = `c`.`organization_id`) and (`a`.`tower` = `c`.`tower`)))) join `external_property_level_1_buildings` `d` on(((`a`.`external_id` = `d`.`external_id`) and (`a`.`external_system_id` = `d`.`external_system_id`) and (`a`.`external_table` = `d`.`external_table`) and (`a`.`tower` = `d`.`tower`) and (`a`.`organization_id` = `d`.`created_by_id`)))) where ((`c`.`external_property_type_id` = 1) and (`c`.`unee_t_mefe_unit_id` is not null)) group by `c`.`unee_t_mefe_unit_id` order by `b`.`id_area`,`a`.`designation` */;

/*View structure for view ut_list_mefe_unit_id_level_2_by_area */

/*!50001 DROP TABLE IF EXISTS `ut_list_mefe_unit_id_level_2_by_area` */;
/*!50001 DROP VIEW IF EXISTS `ut_list_mefe_unit_id_level_2_by_area` */;

/*!50001 CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `ut_list_mefe_unit_id_level_2_by_area` AS select `c`.`id_area` AS `id_area`,`c`.`area_name` AS `area_name`,`b`.`id_building` AS `level_1_building_id`,`e`.`building_system_id` AS `external_level_1_building_id`,`b`.`designation` AS `level_1_building_name`,`a`.`system_id_unit` AS `level_2_unit_id`,`e`.`system_id_unit` AS `external_level_2_unit_id`,`a`.`designation` AS `level_2_unit_name`,`d`.`external_property_type_id` AS `external_property_type_id`,`d`.`unee_t_mefe_unit_id` AS `unee_t_mefe_unit_id`,`a`.`organization_id` AS `organization_id` from ((((`property_level_2_units` `a` join `property_level_1_buildings` `b` on((`a`.`building_system_id` = `b`.`id_building`))) join `property_groups_areas` `c` on((`b`.`area_id` = `c`.`id_area`))) join `ut_map_external_source_units` `d` on(((`a`.`external_id` = `d`.`external_property_id`) and (`a`.`external_system_id` = `d`.`external_system`) and (`a`.`external_table` = `d`.`table_in_external_system`) and (`a`.`organization_id` = `d`.`organization_id`) and (`a`.`tower` = `d`.`tower`)))) join `external_property_level_2_units` `e` on(((`a`.`external_id` = `e`.`external_id`) and (`a`.`external_system_id` = `e`.`external_system_id`) and (`a`.`external_table` = `e`.`external_table`) and (`a`.`organization_id` = `e`.`created_by_id`)))) where ((`d`.`external_property_type_id` = 2) and (`d`.`unee_t_mefe_unit_id` is not null)) group by `d`.`unee_t_mefe_unit_id` order by `c`.`id_area`,`a`.`designation`,`b`.`designation` */;

/*View structure for view ut_list_mefe_unit_id_level_3_by_area */

/*!50001 DROP TABLE IF EXISTS `ut_list_mefe_unit_id_level_3_by_area` */;
/*!50001 DROP VIEW IF EXISTS `ut_list_mefe_unit_id_level_3_by_area` */;

/*!50001 CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `ut_list_mefe_unit_id_level_3_by_area` AS select `d`.`id_area` AS `id_area`,`d`.`area_name` AS `area_name`,`c`.`id_building` AS `level_1_building_id`,`c`.`designation` AS `level_1_building_name`,`b`.`system_id_unit` AS `level_2_unit_id`,`f`.`system_id_unit` AS `external_level_2_unit_id`,`b`.`designation` AS `level_2_unit_name`,`a`.`system_id_room` AS `level_3_room_id`,`f`.`system_id_room` AS `external_level_3_room_id`,`a`.`room_designation` AS `level_3_room_name`,`e`.`external_property_type_id` AS `external_property_type_id`,`e`.`unee_t_mefe_unit_id` AS `unee_t_mefe_unit_id`,`a`.`organization_id` AS `organization_id` from (((((`property_level_3_rooms` `a` join `property_level_2_units` `b` on((`a`.`system_id_unit` = `b`.`system_id_unit`))) join `property_level_1_buildings` `c` on((`b`.`building_system_id` = `c`.`id_building`))) join `property_groups_areas` `d` on((`c`.`area_id` = `d`.`id_area`))) join `ut_map_external_source_units` `e` on(((`a`.`external_id` = `e`.`external_property_id`) and (`a`.`external_system_id` = `e`.`external_system`) and (`a`.`external_table` = `e`.`table_in_external_system`) and (`a`.`organization_id` = `e`.`organization_id`) and (`b`.`tower` = `e`.`tower`)))) join `external_property_level_3_rooms` `f` on(((`a`.`external_id` = `f`.`external_id`) and (`a`.`external_system_id` = `f`.`external_system_id`) and (`a`.`external_table` = `f`.`external_table`) and (`a`.`organization_id` = `f`.`created_by_id`)))) where ((`e`.`external_property_type_id` = 3) and (`e`.`unee_t_mefe_unit_id` is not null)) group by `e`.`unee_t_mefe_unit_id` order by `d`.`id_area`,`c`.`designation`,`b`.`designation`,`a`.`room_designation` */;

/*View structure for view ut_list_unit_id_level_1_failed_creation */

/*!50001 DROP TABLE IF EXISTS `ut_list_unit_id_level_1_failed_creation` */;
/*!50001 DROP VIEW IF EXISTS `ut_list_unit_id_level_1_failed_creation` */;

/*!50001 CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `ut_list_unit_id_level_1_failed_creation` AS select `a`.`id_map` AS `unit_creation_request_id`,`a`.`syst_created_datetime` AS `creation_request_ts`,`a`.`syst_updated_datetime` AS `mefe_api_reply_ts`,`a`.`mefe_api_error_message` AS `mefe_api_error_message`,`a`.`created_by_id` AS `created_by_id`,`a`.`organization_id` AS `organization_id`,`a`.`new_record_id` AS `building_id`,`a`.`uneet_name` AS `uneet_name`,`a`.`unee_t_unit_type` AS `unee_t_unit_type`,`b`.`more_info` AS `more_info`,`b`.`street_address` AS `street_address`,`b`.`city` AS `city`,`b`.`state` AS `state`,`b`.`zip_code` AS `zip_code`,`b`.`country` AS `country` from (`ut_map_external_source_units` `a` join `ut_add_information_unit_level_1` `b` on((`b`.`unit_level_1_id` = `a`.`new_record_id`))) where (isnull(`a`.`unee_t_mefe_unit_id`) and (`a`.`external_property_type_id` = 1)) */;

/*View structure for view ut_list_unit_id_level_2_failed_creation */

/*!50001 DROP TABLE IF EXISTS `ut_list_unit_id_level_2_failed_creation` */;
/*!50001 DROP VIEW IF EXISTS `ut_list_unit_id_level_2_failed_creation` */;

/*!50001 CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `ut_list_unit_id_level_2_failed_creation` AS select `a`.`id_map` AS `unit_creation_request_id`,`a`.`syst_created_datetime` AS `creation_request_ts`,`a`.`syst_updated_datetime` AS `mefe_api_reply_ts`,`a`.`mefe_api_error_message` AS `mefe_api_error_message`,`a`.`created_by_id` AS `created_by_id`,`a`.`organization_id` AS `organization_id`,`a`.`new_record_id` AS `system_id_unit`,`a`.`uneet_name` AS `uneet_name`,`a`.`unee_t_unit_type` AS `unee_t_unit_type`,`b`.`more_info` AS `more_info`,`b`.`street_address` AS `street_address`,`b`.`city` AS `city`,`b`.`state` AS `state`,`b`.`zip_code` AS `zip_code`,`b`.`country` AS `country` from (`ut_map_external_source_units` `a` join `ut_add_information_unit_level_2` `b` on((`b`.`unit_level_2_id` = `a`.`new_record_id`))) where (isnull(`a`.`unee_t_mefe_unit_id`) and (`a`.`external_property_type_id` = 2)) */;

/*View structure for view ut_list_unit_id_level_3_failed_creation */

/*!50001 DROP TABLE IF EXISTS `ut_list_unit_id_level_3_failed_creation` */;
/*!50001 DROP VIEW IF EXISTS `ut_list_unit_id_level_3_failed_creation` */;

/*!50001 CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `ut_list_unit_id_level_3_failed_creation` AS select `a`.`id_map` AS `unit_creation_request_id`,`a`.`syst_created_datetime` AS `creation_request_ts`,`a`.`syst_updated_datetime` AS `mefe_api_reply_ts`,`a`.`mefe_api_error_message` AS `mefe_api_error_message`,`a`.`created_by_id` AS `created_by_id`,`a`.`organization_id` AS `organization_id`,`a`.`new_record_id` AS `system_id_room`,`a`.`uneet_name` AS `uneet_name`,`a`.`unee_t_unit_type` AS `unee_t_unit_type`,`b`.`more_info` AS `more_info`,`b`.`street_address` AS `street_address`,`b`.`city` AS `city`,`b`.`state` AS `state`,`b`.`zip_code` AS `zip_code`,`b`.`country` AS `country` from (`ut_map_external_source_units` `a` join `ut_add_information_unit_level_3` `b` on((`b`.`unit_level_3_id` = `a`.`new_record_id`))) where (isnull(`a`.`unee_t_mefe_unit_id`) and (`a`.`external_property_type_id` = 3)) */;

/*View structure for view ut_organization_associated_mefe_user */

/*!50001 DROP TABLE IF EXISTS `ut_organization_associated_mefe_user` */;
/*!50001 DROP VIEW IF EXISTS `ut_organization_associated_mefe_user` */;

/*!50001 CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `ut_organization_associated_mefe_user` AS select `ut_api_keys`.`mefe_user_id` AS `associated_mefe_user`,`ut_api_keys`.`organization_id` AS `organization_id` from `ut_api_keys` */;

/*View structure for view ut_organization_default_area */

/*!50001 DROP TABLE IF EXISTS `ut_organization_default_area` */;
/*!50001 DROP VIEW IF EXISTS `ut_organization_default_area` */;

/*!50001 CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `ut_organization_default_area` AS select `external_property_groups_areas`.`id_area` AS `default_area_id`,`external_property_groups_areas`.`area_name` AS `default_area_name`,`external_property_groups_areas`.`created_by_id` AS `organization_id` from `external_property_groups_areas` where ((`external_property_groups_areas`.`is_default` = 1) and (isnull(`external_property_groups_areas`.`country_code`) or (`external_property_groups_areas`.`country_code` = ''))) */;

/*View structure for view ut_organization_default_external_system */

/*!50001 DROP TABLE IF EXISTS `ut_organization_default_external_system` */;
/*!50001 DROP VIEW IF EXISTS `ut_organization_default_external_system` */;

/*!50001 CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `ut_organization_default_external_system` AS select `ut_external_sot_for_unee_t_objects`.`designation` AS `designation`,`ut_external_sot_for_unee_t_objects`.`organization_id` AS `organization_id` from `ut_external_sot_for_unee_t_objects` */;

/*View structure for view ut_organization_default_table_areas */

/*!50001 DROP TABLE IF EXISTS `ut_organization_default_table_areas` */;
/*!50001 DROP VIEW IF EXISTS `ut_organization_default_table_areas` */;

/*!50001 CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `ut_organization_default_table_areas` AS select `ut_external_sot_for_unee_t_objects`.`area_table` AS `area_table`,`ut_external_sot_for_unee_t_objects`.`organization_id` AS `organization_id` from `ut_external_sot_for_unee_t_objects` */;

/*View structure for view ut_organization_default_table_level_1_properties */

/*!50001 DROP TABLE IF EXISTS `ut_organization_default_table_level_1_properties` */;
/*!50001 DROP VIEW IF EXISTS `ut_organization_default_table_level_1_properties` */;

/*!50001 CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `ut_organization_default_table_level_1_properties` AS select `ut_external_sot_for_unee_t_objects`.`properties_level_1_table` AS `properties_level_1_table`,`ut_external_sot_for_unee_t_objects`.`organization_id` AS `organization_id` from `ut_external_sot_for_unee_t_objects` */;

/*View structure for view ut_organization_default_table_level_2_properties */

/*!50001 DROP TABLE IF EXISTS `ut_organization_default_table_level_2_properties` */;
/*!50001 DROP VIEW IF EXISTS `ut_organization_default_table_level_2_properties` */;

/*!50001 CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `ut_organization_default_table_level_2_properties` AS select `ut_external_sot_for_unee_t_objects`.`properties_level_2_table` AS `properties_level_2_table`,`ut_external_sot_for_unee_t_objects`.`organization_id` AS `organization_id` from `ut_external_sot_for_unee_t_objects` */;

/*View structure for view ut_organization_default_table_level_3_properties */

/*!50001 DROP TABLE IF EXISTS `ut_organization_default_table_level_3_properties` */;
/*!50001 DROP VIEW IF EXISTS `ut_organization_default_table_level_3_properties` */;

/*!50001 CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `ut_organization_default_table_level_3_properties` AS select `ut_external_sot_for_unee_t_objects`.`properties_level_3_table` AS `properties_level_3_table`,`ut_external_sot_for_unee_t_objects`.`organization_id` AS `organization_id` from `ut_external_sot_for_unee_t_objects` */;

/*View structure for view ut_organization_default_table_persons */

/*!50001 DROP TABLE IF EXISTS `ut_organization_default_table_persons` */;
/*!50001 DROP VIEW IF EXISTS `ut_organization_default_table_persons` */;

/*!50001 CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `ut_organization_default_table_persons` AS select `ut_external_sot_for_unee_t_objects`.`person_table` AS `person_table`,`ut_external_sot_for_unee_t_objects`.`organization_id` AS `organization_id` from `ut_external_sot_for_unee_t_objects` */;

/*View structure for view ut_organization_mefe_user_id */

/*!50001 DROP TABLE IF EXISTS `ut_organization_mefe_user_id` */;
/*!50001 DROP VIEW IF EXISTS `ut_organization_mefe_user_id` */;

/*!50001 CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `ut_organization_mefe_user_id` AS select `ut_api_keys`.`mefe_user_id` AS `mefe_user_id`,`ut_api_keys`.`organization_id` AS `organization_id` from `ut_api_keys` where ((`ut_api_keys`.`is_obsolete` = 0) or (`ut_api_keys`.`revoked_datetime` is not null)) group by `ut_api_keys`.`mefe_user_id`,`ut_api_keys`.`organization_id` */;

/*View structure for view ut_user_information_persons */

/*!50001 DROP TABLE IF EXISTS `ut_user_information_persons` */;
/*!50001 DROP VIEW IF EXISTS `ut_user_information_persons` */;

/*!50001 CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `ut_user_information_persons` AS select `persons`.`id_person` AS `id_person`,`persons`.`external_id` AS `external_person_id`,`persons`.`external_system` AS `external_system`,`persons`.`external_table` AS `table_in_external_system`,`persons`.`organization_id` AS `organization_id`,`persons`.`email` AS `email_address`,`persons`.`given_name` AS `first_name`,`persons`.`family_name` AS `last_name`,`persons`.`tel_1` AS `phone_number` from `persons` where (`persons`.`email` is not null) */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
