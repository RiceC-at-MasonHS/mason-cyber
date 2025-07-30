-- Guacamole database initialization script
-- This will be automatically run when the MySQL container starts

-- Create the guacamole_entity table
CREATE TABLE IF NOT EXISTS `guacamole_entity` (
  `entity_id`     int(11)            NOT NULL AUTO_INCREMENT,
  `name`          varchar(128)       NOT NULL,
  `type`          enum('USER','USER_GROUP') NOT NULL,

  PRIMARY KEY (`entity_id`),
  UNIQUE KEY `guacamole_entity_name_scope` (`type`, `name`)
);

-- Create default admin user
INSERT IGNORE INTO `guacamole_entity` (`name`, `type`) VALUES ('guacadmin', 'USER');

-- Create the guacamole_user table
CREATE TABLE IF NOT EXISTS `guacamole_user` (
  `user_id`       int(11)            NOT NULL AUTO_INCREMENT,
  `entity_id`     int(11)            NOT NULL,

  -- Optionally include password salt and password hash for local users
  `password_hash` binary(32)         NULL,
  `password_salt` binary(32)         NULL,
  `password_date` datetime           NULL,

  -- Optionally include disabled/expired status
  `disabled`      boolean            NOT NULL DEFAULT 0,
  `expired`       boolean            NOT NULL DEFAULT 0,

  -- Optionally include access window restriction
  `access_window_start`    TIME     NULL,
  `access_window_end`      TIME     NULL,

  -- Optionally include valid date restriction
  `valid_from`    DATE               NULL,
  `valid_until`   DATE               NULL,

  -- Optionally include timezone restriction
  `timezone`      VARCHAR(64)        NULL,

  -- Optionally include full name
  `full_name`     VARCHAR(256)       NULL,

  -- Optionally include email address
  `email_address` VARCHAR(256)       NULL,

  -- Optionally include organization
  `organization`  VARCHAR(256)       NULL,

  -- Optionally include organizational role
  `organizational_role` VARCHAR(256) NULL,

  PRIMARY KEY (`user_id`),
  UNIQUE KEY `guacamole_user_single_entity` (`entity_id`),

  CONSTRAINT `guacamole_user_entity`
    FOREIGN KEY (`entity_id`)
    REFERENCES `guacamole_entity` (`entity_id`)
    ON DELETE CASCADE
);

-- Create default admin user with password 'guacadmin'
-- Password hash for 'guacadmin'
INSERT IGNORE INTO `guacamole_user` (
  `entity_id`,
  `password_hash`,
  `password_salt`
) VALUES (
  (SELECT `entity_id` FROM `guacamole_entity` WHERE `name` = 'guacadmin' AND `type` = 'USER'),
  UNHEX('CA458A7D494E3BE824F5E1E175A1556C0F8EEF2C2D7DF3633BEC4A29C4411960'),
  UNHEX('FE24ADC5E11E2B25288D1704ABE67A79E342ECC26064CE69C5B3177795A82264')
);

-- Simple setup - we'll configure connections manually through the web interface
