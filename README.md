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

## Features

- Optimized
- Database (all states remain persistent after a server restart/stop)
- Item to open a door
- Can be private (require a job to open)
- Breach and repair system
- Multiple doors type
  - Key doors
  - Card doors

## Download & Installation

1. Download the latest version in [releases](https://github.com/Nayro-09/fivem-doors-manager/releases)
2. Add the ressource to your server folder and rename it to `doors_manager`
3. Add `ensure doors_manager` in your `server.cfg`
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

### Table of Contents
- [Add a Door](#Add-a-Door)
  - [Create a file](#create-a-new-file-)
  - [Naming a Door](#naming-the-Doors-)
  - [Push Doors in the database](#push-Doors-in-the-database-)
- [Configure a Door](#Configure-a-Door)
  - [Parameters](#parameters-)
  - [Key Door](#key-Door-)
  - [Card Door](#card-Door-)

## Add a Door
### Create a new file :
1. In `_doorList` folder create a new file `yourName.lua`
    - You can create as many files you want
    - Try to name your file to match an location (Ex: `police_station.lua`)

### Naming the Door :
1. In the file you have just created :
```lua
AddDoors({});
```
2. Give a name to your Door :
    - Make sure that the name is unique and easy to identify
    - I usually name my doors using the door location and the door name (Ex: `['police:mainDoor']`)
```lua
AddDoors({
    ['yourName'] = {},
});

-- You can add as many doors you want 

AddDoors({
    ['yourName1'] = {},
    ['yourName2'] = {},
    ['yourName3'] = {}
});
```

### Push Doors in the database :
1. Configure all your doors
2. Execute this command `/pushDoors`

## Configure a Door
### Parameters :
| Param      | Type     | Options                          | Required | Description                                                  |
| ---------- | -------- | -------------------------------- | -------- | ------------------------------------------------------------ |
| type       | `number` | `0` key door, `1` card door      | Yes      | The type of the door                                         |
| distance   | `number` | recommended `1.5`                | Yes      | The distance from where the player can open the door         |
| private    | `boolean`| `true`, `false`                  | Yes      | Private door can be opened only if you have the required job |
| jobs       | `table`  | `{'job1', ...}`                  | Yes / No | The jobs that can open the door                              |
| keys       | `table`  | `{'item1', ...}`                 | Yes      | The items that can open the door                             |
| doors      | `table`  | `{{hash, coords}, ...}`          | Yes      | List of doors object in-game                                 |
| breakable  | `table`  | `{'security', health}`           | No       | The door can be breached                                     |
| animations | `table`  | `{{coords, heading}, ...}`       | Yes / No | Coordinates where an animation will be played                |
| keypads    | `table`  | `{{coords, heading}, ...}`       | Yes / No | Coordinates where a keypad will be placed                    |
| timer      | `number` | recommended `6000` to `15000`    | Yes / No | The time in seconds before the door will be closed           |

---

### Doors :
| Param   | Type               | Description      |
| ------- | ------------------ | ---------------- |
| hash    | `number`           | The door hash    |
| coords  | `vector3(x, y, z)` | The door coords  |

#### Exemple :
```lua
doors = {{
    hash = -1215222675,
    coords = vector3(434.747, -980.619, 30.839)
}},
```

### Breakable (only for key door) :
| Param    | Type     | Options                       | Description             |
| -------- | -------- | ----------------------------- | ----------------------- |
| security | `string` | `'low'`, `'medium'`, `'high'` | The security level      |
| health   | `number` | recommended `300` to `850`    | The health of the doors |

#### Exemple :
```lua
breakable = {
    security = 'medium', -- low = Shotguns, crowbar, unarmed | medium = Shotguns, crowbar | high = Shotguns
    health = 450
},
```

### Animations (only for key door) :
| Param    | Type               | Description                                                |
| -------- | ------------------ | ---------------------------------------------------------- |
| coords   | `vector3(x, y, z)` | The coords where the animation will be played              |
| heading  | `number`           | The orientation of the player when the animation is played |

#### Exemple :
```lua
animations = {{
    coords = vector3(443.525, -993.242, 30.689),
    heading = 90.0
 }, {
    coords = vector3(442.470, -993.257, 30.689),
    heading = 270.0
}},
```

### Keypads (only for card door) :
| Param    | Type               | Description                                                                 |
| -------- | ------------------ | --------------------------------------------------------------------------- |
| coords   | `vector3(x, y, z)` | The coords where the animation will be played and the keypad will be placed |
| rot      | `vector3(x, y, z)` | Orientation offset for keypad placement                                     |

#### Exemple :
```lua
keypads = {{
    coords = vector3(449.889, -987.392, 31.100),
    rot = vector3(0.000, -0.000, -90.000)
}, {
    coords = vector3(450.832, -987.212, 31.100),
    rot = vector3(0.000, -0.000, 180.000)
}},
```

---

### Key Door :
<!-- ```lua
AddDoors({
    ['yourName'] = {
        type = 0,
        distance = 1.5,
        private = false,
        doors = {{
            hash = -131296141,
            coords = vector3(443.029, -994.542, 30.839)
        }, {
            hash = -131296141,
            coords = vector3(443.029, -991.942, 30.839)
        }},
        jobs = {'police'},
        keys = {'police_station_key'},
        breakable = {
            security = 'medium', -- low = Shotguns, crowbar, unarmed | medium = Shotguns, crowbar | high = Shotguns
            health = 200
        },
        animations = {{
            coords = vector3(443.525, -993.242, 30.689),
            heading = 90.0
        }, {
            coords = vector3(442.470, -993.257, 30.689),
            heading = 270.0
        }}
    }
});
``` -->

### Card Door :