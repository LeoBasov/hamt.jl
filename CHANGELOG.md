# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

- performance upgrade for connecting LOS cells
- non perfect contact conditions for sufraces
- grey body radiation
- setting of background temperature

## [0.9.0] - 2025-12-07

### Added

- function initialize_ht which should be called as the first function in a test case setup

### Changed

- renamed function finish_solver to finalize_ht which should be called as the last function in a test case setup

## [0.8.1] - 2025-12-07

### Fixed

- Neumann boundary condition for curved geometries

## [0.8.0] - 2025-12-04

### Added

- added function to check correct node order for each cell

## [0.7.0] - 2024-11-15

### Added

- implemented basic surface-to-surface radiation

### Comments

- radiation calculation still have issues as it does not correctly reproduce analytical resutls
- check section in documentation on generic heat flux boundary condition

## [0.6.0] - 2024-09-27

### Added

- implemented gray body radiation to 0 K background

## [0.5.0] - 2024-09-22

### Added

- implemented use of cylinder coordinates

## [0.4.0] - 2024-09-19

### Added

- implemented solver module for 2D tringular mesh in cartesian coordinates
- implemented Dirichlet boundary condition
- implemented Neumann boundary condition

## [0.3.0] - 2024-09-16

### Added


- implemented first vtk writing capabilities

## [0.2.0] - 2024-09-16

### Added

- implemented reading of trinagular meshes in MSH2 ASCII format of Gmsh

## [0.1.0] - 2024-09-13

### Added

- project setup