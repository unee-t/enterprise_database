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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

/*Data for the table `uneet_enterprise_users` */

insert  into `uneet_enterprise_users`(`ID`,`username`,`password`,`email`,`fullname`,`groupid`,`active`,`organization_id`) values 
(1,'Admin','Admin_Password',NULL,'Administrator','-1',1,NULL),
(2,'tony.smith','test_password',NULL,'Tony Smith','-1',1,1),
(3,'natasha.greekoff','test_password',NULL,'Natasha Greekoff','-1',1,2);

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
