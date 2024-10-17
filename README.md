# bcc-law (Formerly legacy_police)

## Description
A Complete Police Script for VORP Framework

Big Thanks to the Community for suggestions, feedback, help and more! Here yall go!

## Features
- Multijob Capbality
- Standalone Onduty and Offduty command
- Billing and Fining
- Community Service
- Complete Config File for easy changes
- Locale support
- Badge Toggle
- Auto Jail Capability or Manual Jail
- And more!

## Dependencies
- [Vorp Utils](https://github.com/VORPCORE/vorp_utils)
- [feather-menu](https://github.com/feather-framework/feather-menu) - Feather menu system for interactive 
- [vorp_core](https://github.com/VORPCORE/vorp-core-lua) - Core framework for RedM servers.
- [vorp_inventory](https://github.com/VORPCORE/vorp_inventory-lua) - Inventory system required for certain functionalities.
- [vorp_character](https://github.com/VORPCORE/vorp_character-lua) - Character management and job roles.
- [oxmysql](https://github.com/overextended/oxmysql) - MySQL database integration for saving reports and related data.

## Installation
1. Download or clone the `bcc-law` folder and place it in your server's `resources` directory.
2. Add `ensure bcc-law` to your `server.cfg` file to make sure the resource is loaded when the server starts.
3. Ensure that all dependencies (VORP core, VORP inventory, oxmysql, feather-menu, etc.) are properly installed on your server.
4. Customize the system by editing the `config.lua` file, including setting up your desired report types, Discord webhook settings, and language localization.
5. The system automatically handles database setup—no manual creation of tables is required.
6. Restart your server to initialize `bcc-law`.


## Disclaimers and Credits
This originally started as police_job for VORP, after a complete rework, to new VORP Notifications, All new MenuAPI, 
Removal of commands for police and added to Admins, Fully Migrated to Menu capabilities for Police, Complete new features
