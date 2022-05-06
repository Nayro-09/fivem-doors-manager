<h1 align="center">
  <br>
  Doors Manager
  <br>
</h1>

<h4 align="center">Doors Manager is an advanced door locking system using <a href="https://github.com/esx-framework/esx-legacy" target="_blank">ESX</a>.</h4>

<p align="center">
	<a href="https://fivem.net/">
	<img alt="FiveM" src="https://img.shields.io/badge/-FiveM-F6DAC4?style=flat-square&logo=fivem&logoColor=525252&logoWidth=12">
		</a>
    <a href="https://github.com/Nayro-09/fivem-doors-manager/releases">
        <img alt="GitHub release (latest by date)" src="https://img.shields.io/github/v/release/Nayro-09/fivem-doors-manager?color=C4F6E9&label=Version&style=flat-square">
    </a>
		<a href="https://github.com/Nayro-09/fivem-doors-manager">
        	<img alt="GitHub code size in bytes" src="https://img.shields.io/github/languages/code-size/Nayro-09/fivem-doors-manager?color=CFC4F6&label=Size&style=flat-square">
    </a>
    <a href="https://github.com/Nayro-09/fivem-doors-manager/releases">
        <img alt="GitHub all releases" src="https://img.shields.io/github/downloads/Nayro-09/fivem-doors-manager/total?color=C4DFF6&label=Downloads&style=flat-square">
    </a>
</p>

<p align="center">
  <a href="#Features">Features</a> •
  <a href="#Download--Installation">Download & Installation</a> •
  <a href="#How-to-use">How to use</a>
</p>

---

### Features
- Optimized
- Database (all states remain persistent after a server restart/stop)
- Item to open a door
- Can be private (require a job to open) 
- Breach system
- Multiple doors type
    - Key doors
    - Card doors

## Download & Installation
1. Download the latest version in [releases](https://github.com/Nayro-09/fivem-doors-manager/releases)
2. Add the ressource to your server folder and rename it to `doors_manager`
3. Add `ensure doors_manager` in your `server.cfg` :
4. In your database add this table :

```sql
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
```

## How to use
Try to follow this ;)
### Add Doors to the system

1. In `_doorList` folder create a new file `yourName.lua`
    - You can create as many files you want
    - Try to name your file to match an location (Ex: police_station.lua)

2. How to add a new door in the system
