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
/*Table structure for table `uneet_enterprise_uggroups` */

DROP TABLE IF EXISTS `uneet_enterprise_uggroups`;

CREATE TABLE `uneet_enterprise_uggroups` (
  `GroupID` int(11) NOT NULL AUTO_INCREMENT,
  `Label` varchar(300) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  PRIMARY KEY (`GroupID`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

/*Data for the table `uneet_enterprise_uggroups` */

insert  into `uneet_enterprise_uggroups`(`GroupID`,`Label`) values 
(1,'Unee-T Manager'),
(2,'Unee-T View data'),
(3,'SuperAdmin')
;

/*Data for the table `uneet_enterprise_ugmembers` */

insert  into `uneet_enterprise_ugmembers`(`UserName`,`GroupID`) values 
('super.admin',3)
;

/*Table structure for table `uneet_enterprise_ugrights` */

DROP TABLE IF EXISTS `uneet_enterprise_ugrights`;

CREATE TABLE `uneet_enterprise_ugrights` (
  `TableName` varchar(300) COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `GroupID` int(11) NOT NULL,
  `AccessMask` varchar(10) COLLATE utf8mb4_unicode_520_ci DEFAULT NULL,
  `Page` mediumtext COLLATE utf8mb4_unicode_520_ci,
  PRIMARY KEY (`TableName`(50),`GroupID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

/*Data for the table `uneet_enterprise_ugrights` */

insert  into `uneet_enterprise_ugrights`(`TableName`,`GroupID`,`AccessMask`,`Page`) values 
('admin_members',-1,'ADESPIM',NULL),
('admin_rights',-1,'ADESPIM',NULL),
('admin_users',-1,'ADESPIM',NULL),
('All Properties by Countries',1,'S',''),
('Assign Areas to User',-1,'ADESPI',NULL),
('Assign Areas to User',1,'ADS',NULL),
('Assign Areas to User',2,'S',NULL),
('Assign Buildings to User',-1,'ADESPI',NULL),
('Assign Buildings to User',1,'ADS',NULL),
('Assign Buildings to User',2,'S',NULL),
('Assign Rooms',-1,'ADSPI',NULL),
('Assign Rooms',1,'ADS',NULL),
('Assign Rooms',2,'S',NULL),
('Assign Rooms to User',-1,'ADSPI',NULL),
('Assign Rooms to User',1,'ADS',NULL),
('Assign Rooms to User',2,'S',NULL),
('Assign Units to User',-1,'ADESPI',NULL),
('Assign Units to User',1,'ADS',NULL),
('Assign Units to User',2,'S',NULL),
('Export and Import Areas',-1,'SPI',NULL),
('Export and Import Areas',1,'SP',NULL),
('Export and Import Areas',2,'SP',NULL),
('Export and Import Buildings',-1,'SPI',NULL),
('Export and Import Buildings',1,'SP',NULL),
('Export and Import Buildings',2,'SP',NULL),
('Export and Import Rooms',-1,'SPI',NULL),
('Export and Import Rooms',1,'SP',NULL),
('Export and Import Rooms',2,'SP',NULL),
('Export and Import Units',-1,'SPI',NULL),
('Export and Import Units',1,'SP',NULL),
('Export and Import Units',2,'SP',NULL),
('Export and Import User Types',-1,'SPI',NULL),
('Export and Import User Types',1,'SP',NULL),
('Export and Import User Types',2,'SP',NULL),
('Export and Import Users',-1,'SPI',NULL),
('Export and Import Users',1,'SP',NULL),
('Export and Import Users',2,'SP',NULL),
('List of Countries',-1,'SP',NULL),
('List of Countries',1,'SP',NULL),
('List of Countries',2,'SP',NULL),
('Manage Areas',-1,'AESPI',NULL),
('Manage Areas',1,'AES',''),
('Manage Areas',2,'S',NULL),
('Manage Buildings',-1,'AESPI',NULL),
('Manage Buildings',1,'AES',''),
('Manage Buildings',2,'S',NULL),
('Manage Rooms',-1,'AESPI',NULL),
('Manage Rooms',1,'AES',''),
('Manage Rooms',2,'S',NULL),
('Manage Unee-T Users',-1,'ADESPI',NULL),
('Manage Unee-T Users',1,'AES',NULL),
('Manage Unee-T Users',2,'S',NULL),
('Manage Unit Names',-1,'ESPI',NULL),
('Manage Unit Names',2,'S',NULL),
('Manage Units',-1,'AESPI',NULL),
('Manage Units',1,'AES',''),
('Manage Units',2,'S',NULL),
('Manage User Default Notifications',-1,'ES',NULL),
('Manage User Default Notifications',1,'ES',NULL),
('Manage User Default Notifications',2,'S',NULL),
('Manage User Default Visibility',-1,'ES',NULL),
('Manage User Default Visibility',1,'ES',NULL),
('Manage User Default Visibility',2,'S',NULL),
('Manage User Types',-1,'AES',NULL),
('Manage User Types',1,'AES',NULL),
('Manage User Types',2,'S',NULL),
('Manage Users - Unee-T Enterprise UI',-1,'ADESPI',NULL),
('Manage Users - Unee-T Enterprise UI',1,'AES',''),
('Manage Users - Unee-T Enterprise UI',2,'S',NULL),
('Organization Default Area',1,'ES',''),
('Organization Default L1P',1,'ES',''),
('Organization Default L2P',1,'ES',''),
('Search All Units',-1,'S',NULL),
('Search All Units',1,'S',NULL),
('Search All Units',2,'S',NULL),
('Search Buildings',-1,'S',NULL),
('Search Buildings',1,'S',NULL),
('Search Buildings',2,'S',NULL),
('Search list of possible assignees',-1,'S',''),
('Search list of possible assignees',1,'S',''),
('Search list of possible assignees',2,'S',''),
('Search list of possible properties',1,'S',''),
('Search Rooms',-1,'S',NULL),
('Search Rooms',1,'S',NULL),
('Search Rooms',2,'S',NULL),
('Search Units',-1,'S',NULL),
('Search Units',1,'S',NULL),
('Search Units',2,'S',NULL),
('Search Users',-1,'S',NULL),
('Search Users',1,'S',NULL),
('Search Users',2,'S',NULL),
('Sources of Truth',-1,'AES',''),
('Sources of Truth',1,'AES',''),
('Super Admin - Default sot for Unee-T objects',3,'AES',''),
('Super Admin - Manage API Keys',-1,'AES',''),
('Super Admin - Manage API Keys',3,'AES',''),
('Super Admin - Manage MEFE Master User',-1,'AES',''),
('Super Admin - Manage MEFE Master User',3,'AES',''),
('Super Admin - Manage Organization',-1,'AES',''),
('Super Admin - Manage Organization',3,'AES',''),
('Super Admin - Manage User Types',-1,'AES',''),
('Super Admin - Manage User Types',3,'AES',''),
('SuperAdmin - manage UNTE admins',-1,'AES',''),
('SuperAdmin - manage UNTE admins',3,'AES',''),
('Unee-T Enterprise Account',-1,'AES',''),
('Unee-T Enterprise Account',1,'ES',''),
('Unee-T Enterprise Configuration',-1,'ES',NULL),
('Unee-T Enterprise Configuration',1,'S',NULL),
('Unee-T Enterprise Configuration',2,'S',NULL),
('uneet_enterprise_organizations',-1,'ADESPIM',NULL),
('uneet_enterprise_users',-1,'ADESPIM',NULL),
('User Permissions',-1,'AES',''),
('User Permissions',1,'AES',''),
('User Permissions',3,'AES','')
;

/*Data for the table `uneet_enterprise_users` */

insert  into `uneet_enterprise_users`(`ID`,`username`,`password`,`email`,`fullname`,`groupid`,`active`,`organization_id`) values 
#(7,'super.admin','bbL*/&~9mUE`k`i%63v|','unte.superadmin.demo@unee-t.com','Super Admin',NULL,1,1)
(7,'super.admin','imVoA~;gorNnnZ+Ywz.|','unte.superadmin.dev@unee-t.com','Super Admin',NULL,1,1)
#(7,'super.admin','\1Jq^vT,a9H473i^oq/X','unte.superadmin@unee-t.com','Super Admin',NULL,1,1)
;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
