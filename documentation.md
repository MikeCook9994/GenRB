# CONFIGURATION DOCUMENTATION

## Contract
```lua
{
    (primary) = {
        (text) = {
            enabled = boolean or function(): boolean,
            (value) = function(currentPower, maxPower): string or string
            (color) = rgba or function(currentPower, maxPower): rgba,
            font = string,
            size = number,
            outline = string,
            xOffset = number,
            yOffset = number
        },
        (powerType) = PowerType Enum or function(): PowerType Enum,
        (currentPower) = function(): number,
        (maxPower) = number or function(): number,
        (color) = rgba or function(currentPower, maxPower): rgba,
        (texture) = string,
        tickMarks = {
            texture = string,
            (color) = rgba or function(): rgba
            offsets = {
                id = {
                    (enabled) = boolean or function(current, max): boolean,
                    resourceValue = number or function(): number,
                    color = rgba or function(): rgba
                } or { number }
            } or function(): { number or tickMarkConfig }
        },
        prediction = {
            (enabled) = boolean or function(): boolean,
            (color) = rgba or function(currentPower, maxPower): rgba,
            next = function(predicted, max): number
        }
    },
    (top) = { identical to primary, supports enabled property using same schema as other enabled properties },
    (bottom) = { identical to primary, supports enabled property using same schema as other enabled properties },
    (top_left) = { identical to primary, supports enabled property using same schema as other enabled properties },
    (top_right) = { identical to primary, supports enabled property using same schema as other enabled properties },
    (bottom_left) = { identical to primary, supports enabled property using same schema as other enabled properties },
    (bottom_right) = { identical to primary, supports enabled property using same schema as other enabled properties },
}
```

### NOTES
* property = x || y indicates it can be provided in either format
* (property) indicates a strictly optional value (not dependent on the presence of other values). 
* If an enabled property is not provided it will be enabled, primary bar cannot be disabled
* either powerType XOR currentPower/maxPower can be provided OR neither. If powerType is provided, currentPower/maxPower will be ignored and the currentPower powertype and maxPower powertype will be used. If neither is provided the result of UnitPowerType("player") will be used as the powerType
* the default texture for tick marks is "Interface/Addons/SharedMedia/statusbar/Aluminium"
* tickMarks can have a color that can be overridden by a color on individual objects
* tick marks can be dynamically generated in either format by functions

### DEFAULTS

| property | value |
|---|---|
| bar texture | Interface/Addons/SharedMedia/statusbar/Cilo |
| tick mark texture | |
| font type | Friz Quadrata TT |
| font size | 14 |
| font options | outline |