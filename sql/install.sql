CREATE TABLE IF NOT EXISTS `mj_clothing_owned` (
  `id` int NOT NULL AUTO_INCREMENT,
  `owner` varchar(64) NOT NULL,
  `item_id` varchar(100) NOT NULL,
  `item_data` longtext NOT NULL,
  `purchased_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`), KEY `idx_mj_clothing_owner` (`owner`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `mj_clothing_rules` (
  `ped_model` varchar(60) NOT NULL,
  `item_id` varchar(100) NOT NULL,
  `texture` int NOT NULL DEFAULT -1,
  `state` enum('available','restricted','blacklisted') NOT NULL DEFAULT 'available',
  `jobs` longtext DEFAULT NULL,
  `note` varchar(255) DEFAULT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ped_model`,`item_id`,`texture`),
  KEY `idx_mj_clothing_state` (`state`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `mj_clothing_audit` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `admin_identifier` varchar(100) NOT NULL,
  `admin_name` varchar(100) NOT NULL,
  `ped_model` varchar(60) NOT NULL,
  `item_id` varchar(100) NOT NULL,
  `texture` int NOT NULL DEFAULT -1,
  `old_state` varchar(20) DEFAULT NULL,
  `new_state` varchar(20) NOT NULL,
  `jobs` longtext DEFAULT NULL,
  `note` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`), KEY `idx_mj_clothing_audit_item` (`ped_model`,`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE IF NOT EXISTS `mj_clothing_catalogue` (
 `ped_model` varchar(60) NOT NULL, `item_id` varchar(100) NOT NULL, `display_name` varchar(100) DEFAULT NULL,
 `price` int DEFAULT NULL, `shop` varchar(60) DEFAULT 'all', `metadata` longtext DEFAULT NULL,
 PRIMARY KEY (`ped_model`,`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `mj_clothing_outfits` (
 `id` int NOT NULL AUTO_INCREMENT, `owner` varchar(64) NOT NULL, `name` varchar(80) NOT NULL,
 `appearance` longtext NOT NULL, `favourite` tinyint(1) NOT NULL DEFAULT 0, `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
 PRIMARY KEY (`id`), KEY `idx_outfit_owner` (`owner`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `mj_clothing_current` (
 `owner` varchar(64) NOT NULL, `appearance` longtext NOT NULL, `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 PRIMARY KEY (`owner`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `mj_clothing_compatibility` (
 `ped_model` varchar(60) NOT NULL, `item_id` varchar(100) NOT NULL, `linked_components` longtext NOT NULL,
 PRIMARY KEY (`ped_model`,`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
