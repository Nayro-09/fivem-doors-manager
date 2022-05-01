CREATE TABLE IF NOT EXISTS `doors_manager` (
  `identifier` varchar(60) NOT NULL,
  `type` SMALLINT(1) NULL DEFAULT 0,
  `locked` TINYINT(1) NULL DEFAULT 0,
  `distance` DECIMAL(3, 1) DEFAULT 1.5,
  `private` TINYINT(1) NULL DEFAULT 1,
  `doors` longtext NOT NULL,
  `jobs` longtext DEFAULT NULL,
  `keys` longtext DEFAULT NULL,
  `breakable` longtext DEFAULT NULL,
  `animations` longtext DEFAULT NULL,
  `keypads` longtext DEFAULT NULL,
  `timer` SMALLINT(5) DEFAULT NULL, 
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB;