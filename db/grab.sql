-- MySQL dump 10.13  Distrib 5.5.32, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: grab
-- ------------------------------------------------------
-- Server version	5.5.32-0ubuntu0.12.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `sites`
--

DROP TABLE IF EXISTS `sites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sites` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `mark` varchar(20) NOT NULL,
  `url` varchar(100) NOT NULL,
  `keyword` varchar(50) DEFAULT NULL,
  `tags` varchar(100) DEFAULT NULL,
  `kind` int(1) NOT NULL DEFAULT '1',
  `state` int(1) NOT NULL DEFAULT '1',
  `created_at` date DEFAULT NULL,
  `updated_at` date DEFAULT NULL,
  `match_tags` varchar(50) DEFAULT NULL,
  `ignore_tags` varchar(50) DEFAULT NULL,
  `conf` text,
  `sleep` int(3) DEFAULT '3',
  `is_subdomain` int(1) DEFAULT '0',
  `remarks` varchar(150) DEFAULT NULL,
  `is_filter_param` int(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `mark` (`mark`),
  UNIQUE KEY `url` (`url`),
  KEY `state` (`state`),
  KEY `kind` (`kind`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `web_pages`
--

DROP TABLE IF EXISTS `web_pages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `web_pages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(200) DEFAULT NULL,
  `description` text,
  `url` varchar(250) DEFAULT NULL,
  `content` varchar(350) DEFAULT NULL,
  `tags` varchar(800) DEFAULT NULL,
  `kind` int(1) NOT NULL DEFAULT '1',
  `state` int(1) NOT NULL DEFAULT '0',
  `site_id` int(11) NOT NULL,
  `mark` varchar(50) DEFAULT NULL,
  `keyword` varchar(100) DEFAULT NULL,
  `category` varchar(100) DEFAULT NULL,
  `index` varchar(50) DEFAULT NULL,
  `cover_img` text,
  `created_at` date DEFAULT NULL,
  `updated_at` date DEFAULT NULL,
  `image_group` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `url` (`url`),
  KEY `mark` (`mark`),
  KEY `category` (`category`),
  KEY `site_id` (`site_id`),
  KEY `kind` (`kind`),
  KEY `state` (`state`)
) ENGINE=InnoDB AUTO_INCREMENT=18315 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2013-11-29 11:02:13
