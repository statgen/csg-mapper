-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema csg_mapper
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `csg_mapper` ;

-- -----------------------------------------------------
-- Schema csg_mapper
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `csg_mapper` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci ;
USE `csg_mapper` ;

-- -----------------------------------------------------
-- Table `csg_mapper`.`centers`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `csg_mapper`.`centers` ;

CREATE TABLE IF NOT EXISTS `csg_mapper`.`centers` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modified_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `csg_mapper`.`studies`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `csg_mapper`.`studies` ;

CREATE TABLE IF NOT EXISTS `csg_mapper`.`studies` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modified_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `csg_mapper`.`hosts`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `csg_mapper`.`hosts` ;

CREATE TABLE IF NOT EXISTS `csg_mapper`.`hosts` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modified_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `csg_mapper`.`pis`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `csg_mapper`.`pis` ;

CREATE TABLE IF NOT EXISTS `csg_mapper`.`pis` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modified_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `csg_mapper`.`samples`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `csg_mapper`.`samples` ;

CREATE TABLE IF NOT EXISTS `csg_mapper`.`samples` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `sample_id` VARCHAR(45) NOT NULL,
  `center_id` INT NOT NULL,
  `study_id` INT NOT NULL,
  `pi_id` INT NOT NULL,
  `host_id` INT NOT NULL,
  `filename` VARCHAR(45) NOT NULL,
  `run_dir` VARCHAR(45) NOT NULL,
  `state` INT NOT NULL DEFAULT 0,
  `ref_build` VARCHAR(45) NOT NULL DEFAULT '37',
  `exported_at` DATETIME NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modified_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_samples_1_idx` (`center_id` ASC),
  INDEX `fk_samples_2_idx` (`study_id` ASC),
  INDEX `fk_samples_3_idx` (`host_id` ASC),
  INDEX `fk_samples_4_idx` (`pi_id` ASC),
  CONSTRAINT `fk_samples_1`
    FOREIGN KEY (`center_id`)
    REFERENCES `csg_mapper`.`centers` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_samples_2`
    FOREIGN KEY (`study_id`)
    REFERENCES `csg_mapper`.`studies` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_samples_3`
    FOREIGN KEY (`host_id`)
    REFERENCES `csg_mapper`.`hosts` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_samples_4`
    FOREIGN KEY (`pi_id`)
    REFERENCES `csg_mapper`.`pis` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `csg_mapper`.`jobs`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `csg_mapper`.`jobs` ;

CREATE TABLE IF NOT EXISTS `csg_mapper`.`jobs` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `sample_id` INT(11) NOT NULL,
  `job_id` INT NOT NULL,
  `cluster` VARCHAR(45) NOT NULL,
  `procs` INT NOT NULL,
  `memory` INT(11) NOT NULL,
  `walltime` VARCHAR(45) NOT NULL,
  `exit_code` INT NULL,
  `elapsed` INT(11) NULL DEFAULT 0,
  `submitted_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `started_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `ended_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modified_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `job_id_UNIQUE` (`job_id` ASC),
  INDEX `fk_jobs_1_idx` (`sample_id` ASC),
  INDEX `index4` (`cluster` ASC),
  CONSTRAINT `fk_jobs_1`
    FOREIGN KEY (`sample_id`)
    REFERENCES `csg_mapper`.`samples` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
