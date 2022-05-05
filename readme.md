# Doors Manager [ESX]
`Doors Manager` is an advanced door locking system using [ESX](https://github.com/esx-framework/esx-legacy).

### Features
- Optimized
- Based on a database (all state stay persistant after a server restart/shutdown)
- Item to open a door
- Can be private (require a job to open) 
- Breach system
- Multiple doors type
    - Key doors
    - Card doors

## Installation
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

## Configuration