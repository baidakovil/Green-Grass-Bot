-- MySQL Script generated by MySQL Workbench
-- Sat Nov 11 12:32:42 2023
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema ggb
-- -----------------------------------------------------
-- Database schema for GreatGigBot Telegram bot

-- -----------------------------------------------------
-- Schema ggb
--
-- Database schema for GreatGigBot Telegram bot
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `ggb` ;
USE `ggb` ;

-- -----------------------------------------------------
-- Table `ggb`.`users`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ggb`.`users` (
  `user_id` BIGINT UNSIGNED NOT NULL COMMENT 'Unique identifier for this user or bot. \nThis number may have more than 32 significant bits and some programming languages may have difficulty/silent defects in interpreting it.\nBut it has at most 52 significant bits, so a 64-bit integer or double-precision float type are safe for storing this identifier.',
  `username` NVARCHAR(255) NULL COMMENT 'Convenience property. If username is available, returns a t.me link of the user',
  `first_name` NVARCHAR(255) NULL COMMENT 'User\'s or bot\'s first name',
  `last_name` NVARCHAR(255) NULL COMMENT 'Optional. User\'s or bot\'s last name',
  `language_code` NVARCHAR(45) NULL COMMENT 'Optional. IETF language tag of the user\'s language',
  `reg_datetime` DATETIME NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE INDEX `id_UNIQUE` (`user_id` ASC) VISIBLE)
ENGINE = InnoDB
COMMENT = 'Keeping user info';


-- -----------------------------------------------------
-- Table `ggb`.`events`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ggb`.`events` (
  `event_id` INT UNSIGNED NULL AUTO_INCREMENT,
  `event_date` DATE NOT NULL,
  `place` NVARCHAR(255) NOT NULL,
  `locality` NVARCHAR(255) NOT NULL,
  `country` NVARCHAR(255) NOT NULL,
  `is_festival` TINYINT(1) NULL,
  `event_source` NVARCHAR(45) NOT NULL,
  `link` NVARCHAR(2047) NULL,
  PRIMARY KEY (`event_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ggb`.`artnames`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ggb`.`artnames` (
  `art_name` NVARCHAR(45) NOT NULL,
  `check_datetime` DATETIME NULL,
  PRIMARY KEY (`art_name`),
  UNIQUE INDEX `art_name_UNIQUE` (`art_name` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ggb`.`lineups`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ggb`.`lineups` (
  `event_id` INT UNSIGNED NOT NULL,
  `art_name` NVARCHAR(45) NOT NULL,
  PRIMARY KEY (`event_id`, `art_name`),
  INDEX `fk_lineups_artnames_idx` (`art_name` ASC) VISIBLE,
  CONSTRAINT `fk_lineups_events`
    FOREIGN KEY (`event_id`)
    REFERENCES `ggb`.`events` (`event_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_lineups_artnames`
    FOREIGN KEY (`art_name`)
    REFERENCES `ggb`.`artnames` (`art_name`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ggb`.`useraccs`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ggb`.`useraccs` (
  `user_id` BIGINT UNSIGNED NOT NULL,
  `lfm` NVARCHAR(45) NOT NULL,
  PRIMARY KEY (`user_id`, `lfm`),
  CONSTRAINT `fk_useraccs_users`
    FOREIGN KEY (`user_id`)
    REFERENCES `ggb`.`users` (`user_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ggb`.`scrobbles`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ggb`.`scrobbles` (
  `user_id` BIGINT UNSIGNED NOT NULL,
  `art_name` NVARCHAR(45) NOT NULL,
  `scrobble_date` DATE NOT NULL,
  `lfm` NVARCHAR(45) NOT NULL,
  `scrobble_count` SMALLINT NULL,
  PRIMARY KEY (`user_id`, `art_name`, `scrobble_date`, `lfm`),
  INDEX `fk_scrobbles_useraccs_idx` (`lfm` ASC, `user_id` ASC) VISIBLE,
  INDEX `fk_scrobbles_artnames_idx` (`art_name` ASC) VISIBLE,
  CONSTRAINT `fk_scrobbles_useraccs`
    FOREIGN KEY (`lfm` , `user_id`)
    REFERENCES `ggb`.`useraccs` (`lfm` , `user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_scrobbles_artnames`
    FOREIGN KEY (`art_name`)
    REFERENCES `ggb`.`artnames` (`art_name`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ggb`.`usersettings`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ggb`.`usersettings` (
  `user_id` BIGINT UNSIGNED NOT NULL,
  `min_listens` TINYINT UNSIGNED NULL,
  `notice_day` SMALLINT NULL,
  `notice_time` TIME NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE INDEX `user_id_UNIQUE` (`user_id` ASC) VISIBLE,
  CONSTRAINT `fk_usersettings_users`
    FOREIGN KEY (`user_id`)
    REFERENCES `ggb`.`users` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ggb`.`sentarts`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ggb`.`sentarts` (
  `user_id` BIGINT UNSIGNED NOT NULL,
  `event_id` INT UNSIGNED NULL,
  `art_name` NVARCHAR(45) NOT NULL,
  `sent_datetime` DATETIME NULL,
  PRIMARY KEY (`user_id`, `event_id`, `art_name`),
  INDEX `fk_sentevents_events_idx` (`event_id` ASC) VISIBLE,
  INDEX `fk_sentarts_scrobbles_idx` (`art_name` ASC) VISIBLE,
  CONSTRAINT `fk_sentarts_users`
    FOREIGN KEY (`user_id`)
    REFERENCES `ggb`.`users` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_sentarts_events`
    FOREIGN KEY (`event_id`)
    REFERENCES `ggb`.`events` (`event_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_sentarts_artnames`
    FOREIGN KEY (`art_name`)
    REFERENCES `ggb`.`artnames` (`art_name`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ggb`.`artchecks`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ggb`.`artchecks` (
  `art_name` NVARCHAR(45) NOT NULL,
  `check_datetime` DATETIME NULL,
  PRIMARY KEY (`art_name`),
  UNIQUE INDEX `art_name_UNIQUE` (`art_name` ASC) VISIBLE,
  CONSTRAINT `fk_artchecks_artnames`
    FOREIGN KEY (`art_name`)
    REFERENCES `ggb`.`artnames` (`art_name`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ggb`.`lastarts`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ggb`.`lastarts` (
  `user_id` BIGINT UNSIGNED NOT NULL,
  `shorthand` NVARCHAR(2) NOT NULL,
  `art_name` NVARCHAR(45) NULL,
  `shorthand_date` DATE NULL,
  PRIMARY KEY (`user_id`, `shorthand`),
  INDEX `user_id_idx` (`user_id` ASC) VISIBLE,
  INDEX `fk_lastarts_artnames_idx` (`art_name` ASC) VISIBLE,
  CONSTRAINT `fk_lastarts_users`
    FOREIGN KEY (`user_id`)
    REFERENCES `ggb`.`users` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_lastarts_artnames`
    FOREIGN KEY (`art_name`)
    REFERENCES `ggb`.`artnames` (`art_name`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

USE `ggb`;

DELIMITER $$
USE `ggb`$$
CREATE DEFINER = CURRENT_USER TRIGGER `ggb`.`lineups_BEFORE_INSERT` BEFORE INSERT ON `lineups` FOR EACH ROW
BEGIN
IF NEW.art_name NOT IN (SELECT art_name FROM artnames) THEN
INSERT INTO artnames VALUES (NEW.art_name);
END IF;
END;$$


DELIMITER ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
