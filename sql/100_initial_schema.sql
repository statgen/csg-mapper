-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema csgmapper
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `csgmapper` ;

-- -----------------------------------------------------
-- Schema csgmapper
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `csgmapper` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci ;
USE `csgmapper` ;

-- -----------------------------------------------------
-- Table `csgmapper`.`centers`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `csgmapper`.`centers` ;

CREATE TABLE IF NOT EXISTS `csgmapper`.`centers` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT '',
  `name` VARCHAR(45) NOT NULL COMMENT '',
  `created_at` DATETIME NOT NULL COMMENT '',
  `modified_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '',
  PRIMARY KEY (`id`)  COMMENT '')
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `csgmapper`.`studies`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `csgmapper`.`studies` ;

CREATE TABLE IF NOT EXISTS `csgmapper`.`studies` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT '',
  `name` VARCHAR(45) NOT NULL COMMENT '',
  `created_at` DATETIME NOT NULL COMMENT '',
  `modified_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '',
  PRIMARY KEY (`id`)  COMMENT '')
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `csgmapper`.`hosts`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `csgmapper`.`hosts` ;

CREATE TABLE IF NOT EXISTS `csgmapper`.`hosts` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT '',
  `name` VARCHAR(45) NOT NULL COMMENT '',
  `created_at` DATETIME NOT NULL COMMENT '',
  `modified_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '',
  PRIMARY KEY (`id`)  COMMENT '')
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `csgmapper`.`pis`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `csgmapper`.`pis` ;

CREATE TABLE IF NOT EXISTS `csgmapper`.`pis` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT '',
  `name` VARCHAR(45) NOT NULL COMMENT '',
  `created_at` DATETIME NOT NULL COMMENT '',
  `modified_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '',
  PRIMARY KEY (`id`)  COMMENT '')
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `csgmapper`.`projects`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `csgmapper`.`projects` ;

CREATE TABLE IF NOT EXISTS `csgmapper`.`projects` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT '',
  `name` VARCHAR(45) NULL COMMENT '',
  `created_at` DATETIME NOT NULL COMMENT '',
  `modified_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '',
  PRIMARY KEY (`id`)  COMMENT '')
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `csgmapper`.`samples`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `csgmapper`.`samples` ;

CREATE TABLE IF NOT EXISTS `csgmapper`.`samples` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT '',
  `sample_id` VARCHAR(45) NOT NULL COMMENT '',
  `center_id` INT NOT NULL COMMENT '',
  `study_id` INT NOT NULL COMMENT '',
  `pi_id` INT NOT NULL COMMENT '',
  `host_id` INT NOT NULL COMMENT '',
  `project_id` INT NOT NULL COMMENT '',
  `filename` VARCHAR(45) NOT NULL COMMENT '',
  `run_dir` VARCHAR(45) NOT NULL COMMENT '',
  `state` INT NOT NULL DEFAULT 0 COMMENT '',
  `ref_build` VARCHAR(45) NOT NULL DEFAULT '38' COMMENT '',
  `fullpath` TEXT NOT NULL COMMENT '',
  `exported_at` DATETIME NULL COMMENT '',
  `created_at` DATETIME NOT NULL COMMENT '',
  `modified_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '',
  PRIMARY KEY (`id`)  COMMENT '',
  INDEX `fk_samples_1_idx` (`center_id` ASC)  COMMENT '',
  INDEX `fk_samples_2_idx` (`study_id` ASC)  COMMENT '',
  INDEX `fk_samples_3_idx` (`host_id` ASC)  COMMENT '',
  INDEX `fk_samples_4_idx` (`pi_id` ASC)  COMMENT '',
  INDEX `fk_samples_5_idx` (`project_id` ASC)  COMMENT '',
  CONSTRAINT `fk_samples_1`
    FOREIGN KEY (`center_id`)
    REFERENCES `csgmapper`.`centers` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_samples_2`
    FOREIGN KEY (`study_id`)
    REFERENCES `csgmapper`.`studies` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_samples_3`
    FOREIGN KEY (`host_id`)
    REFERENCES `csgmapper`.`hosts` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_samples_4`
    FOREIGN KEY (`pi_id`)
    REFERENCES `csgmapper`.`pis` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_samples_5`
    FOREIGN KEY (`project_id`)
    REFERENCES `csgmapper`.`projects` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `csgmapper`.`jobs`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `csgmapper`.`jobs` ;

CREATE TABLE IF NOT EXISTS `csgmapper`.`jobs` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT '',
  `sample_id` INT(11) NOT NULL COMMENT '',
  `job_id` INT NOT NULL COMMENT '',
  `cluster` VARCHAR(45) NOT NULL COMMENT '',
  `procs` INT NOT NULL COMMENT '',
  `memory` INT(11) NOT NULL COMMENT '',
  `walltime` VARCHAR(45) NOT NULL COMMENT '',
  `exit_code` INT NULL COMMENT '',
  `elapsed` INT(11) NULL DEFAULT 0 COMMENT '',
  `node` VARCHAR(45) NULL COMMENT '',
  `delay` INT NULL DEFAULT 0 COMMENT '',
  `submitted_at` DATETIME NULL COMMENT '',
  `started_at` DATETIME NULL COMMENT '',
  `ended_at` DATETIME NULL COMMENT '',
  `created_at` DATETIME NOT NULL COMMENT '',
  `modified_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '',
  PRIMARY KEY (`id`)  COMMENT '',
  INDEX `fk_jobs_1_idx` (`sample_id` ASC)  COMMENT '',
  INDEX `index4` (`cluster` ASC)  COMMENT '',
  CONSTRAINT `fk_jobs_1`
    FOREIGN KEY (`sample_id`)
    REFERENCES `csgmapper`.`samples` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `csgmapper`.`logs`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `csgmapper`.`logs` ;

CREATE TABLE IF NOT EXISTS `csgmapper`.`logs` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT '',
  `job_id` INT(11) NOT NULL COMMENT '',
  `timestamp` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '',
  `level` VARCHAR(45) NOT NULL COMMENT '',
  `message` TEXT NOT NULL COMMENT '',
  PRIMARY KEY (`id`)  COMMENT '',
  INDEX `fk_table1_1_idx` (`job_id` ASC)  COMMENT '',
  CONSTRAINT `fk_table1_1`
    FOREIGN KEY (`job_id`)
    REFERENCES `csgmapper`.`jobs` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
