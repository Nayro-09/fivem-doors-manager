AddDoors({
    ['pStation:main'] = {
        type = 0,
        distance = 1.5,
        private = true,
        doors = {{
            hash = -1215222675,
            coords = vector3(434.747, -980.619, 30.839)
        }, {
            hash = 320433149,
            coords = vector3(434.747, -983.216, 30.839)
        }},
        jobs = {'police'},
        keys = {'police_station_key'},
        animations = {{
            coords = vector3(435.207, -981.920, 30.689),
            heading = 90.0
        }, {
            coords = vector3(434.265, -981.938, 30.709),
            heading = 270.0
        }}
    },
    ['pStation:briefing'] = {
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
    },
    ['pStation:cardTest'] = {
        type = 1,
        distance = 1.25,
        private = true,
        jobs = {'police'},
        keys = {'police_station_key'},
        doors = {{
            hash = 1557126584,
            coords = vector3(450.104, -985.738, 30.839)
        }},
        keypads = {{
            coords = vector3(449.889, -987.392, 31.100),
            rot = vector3(0.000, -0.000, -90.000)
        }, {
            coords = vector3(450.832, -987.212, 31.100),
            rot = vector3(0.000, -0.000, 180.000)
        }},
        timer = 6000
    },
    ['pStation:mainBack'] = {
        type = 1,
        distance = 1.25,
        private = false,
        jobs = {'police'},
        keys = {'police_station_key'},
        doors = {{
            hash = -2023754432,
            coords = vector3(469.968, -1014.452, 26.536)
        }, {
            hash = -2023754432,
            coords = vector3(467.372, -1014.452, 26.536)
        }},
        keypads = {{
            coords = vector3(467.372, -1015.480, 26.75),
            rot = vector3(0.000, -0.000, 90.000)
        }, {
            coords = vector3(467.372, -1013.204, 26.75),
            rot = vector3(0.000, 0.000, 90.000)
        }},
        timer = 12000
    }
});
