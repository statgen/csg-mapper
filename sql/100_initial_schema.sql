-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema csg_mapper
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema csg_mapper
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `csg_mapper` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci ;
USE `csg_mapper` ;

-- -----------------------------------------------------
-- Table `csg_mapper`.`samples`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `csg_mapper`.`samples` ;

CREATE TABLE IF NOT EXISTS `csg_mapper`.`samples` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `sample_id` VARCHAR(45) NOT NULL,
  `filename` VARCHAR(45) NOT NULL,
  `center` VARCHAR(45) NOT NULL,
  `pi` VARCHAR(45) NOT NULL,
  `study` VARCHAR(45) NOT NULL,
  `host` VARCHAR(45) NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modified_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `csg_mapper`.`states`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `csg_mapper`.`states` ;

CREATE TABLE IF NOT EXISTS `csg_mapper`.`states` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `name_UNIQUE` (`name` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `csg_mapper`.`jobs`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `csg_mapper`.`jobs` ;

CREATE TABLE IF NOT EXISTS `csg_mapper`.`jobs` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `sample_id` INT(11) NOT NULL,
  `state_id` INT NOT NULL,
  `job_id` INT NOT NULL,
  `cluster` VARCHAR(45) NOT NULL,
  `procs` INT NOT NULL,
  `memory` INT(11) NOT NULL,
  `walltime` VARCHAR(45) NOT NULL,
  `build` ENUM('37','38') NOT NULL DEFAULT '37',
  `exit_code` INT NULL,
  `submitted_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `started_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ended_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `elapsed_time` INT(11) NULL DEFAULT 0,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modified_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `job_id_UNIQUE` (`job_id` ASC),
  INDEX `fk_jobs_1_idx` (`sample_id` ASC),
  INDEX `index4` (`cluster` ASC),
  INDEX `fk_jobs_2_idx` (`state_id` ASC),
  CONSTRAINT `fk_jobs_1`
    FOREIGN KEY (`sample_id`)
    REFERENCES `csg_mapper`.`samples` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_jobs_2`
    FOREIGN KEY (`state_id`)
    REFERENCES `csg_mapper`.`states` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
