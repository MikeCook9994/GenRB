# CONFIGURATION DOCUMENTATION

This repository contains the source for the personal resource display (PRD) addon. This addon provides the framework for
quickly spinning up class and spec resource bars that can track resources, cooldowns, auras, etc... using the 
configuration defined below. Simply adding a configuration file to the addon conforming to the below template and standards
is all that needs to be done.

## Contract

```lua
-- note that you can specify class specific configurations by dropping _specialization in the property name below (e.g. PRD.configurations.class)
PRD.configurations.class_specialization = {
    primary* = {
        powerType* = PowerType Enum or function(): Enum.PowerType value,
        currentPower* = function(): number,
        maxPower* = number or function(): number,
        color* = rgba or function(): rgba,
        texture* = string,
        prediction = {
            enabled* = boolean or function(): boolean,
            color* = rgba or function(): rgba,
            next = function(): number
        },
        text* = {
            enabled* = boolean or function(): boolean,
            value* = function(): string
            color* = rgba or function(): rgba,
            font* = string,
            size* = number,
            flags* = string,
            xOffset* = number,
            yOffset* = number
        },
        tickMarks = {
            texture* = string,
            color* = rgba or function(): rgba
            offsets = {
                id = {
                    enabled* = boolean or function(): boolean,
                    resourceValue = number or function(): number,
                    color* = rgba or function(): rgba
                } or { 
                    number
                }
            } or function(): { number or tickMarkConfig }
        }
    },
    top* = { 
        -- identical to primary
        -- supports enabled property using same schema as other enabled properties 
    },
    bottom* = { 
        -- identical to primary
        -- supports enabled property using same schema as other enabled properties 
    },
    top_left* = { 
        -- identical to primary
        -- supports enabled property using same schema as other enabled properties 
    },
    top_right* = { 
        -- identical to primary
        -- supports enabled property using same schema as other enabled properties 
    },
    bottom_left* = { 
        -- identical to primary
        -- supports enabled property using same schema as other enabled properties 
    },
    bottom_right* = { 
        -- identical to primary
        -- supports enabled property using same schema as other enabled properties 
    },
}
```

### QUICK NOTES
* note that technically all bars are optional. If you don't even provide a primary bar, 
by default the primary bar will track the default power for the spec
* _property_ = x __or__ y indicates the value can be provided in either format
* _propertyName*_ indicates a strictly optional value (not dependent on the presence of other values). 
* If an enabled property is not provided it will be enabled
* the primary bar cannot be disabled
* If powerType is provided, currentPower/maxPower will be ignored and the default current and max power values for that power type will be used. If neither is provided the result of UnitPowerType("player") will be used as the powerType for the bar
* tickMarks can have a color that can be overridden by a color on individual objects
* tick marks can be dynamically generated in either format by functions, please avoid this behavior if it is expected that your tick marks will frequently change. It is bad practice to generate frames in excess. 

### DEFAULTS

Tick marks will default to white color. Bars will default to the color of that powertype.

| property | value |
|---|---|
| bar texture | Interface/Addons/SharedMedia/statusbar/Cilo |
| tick mark texture | Interface/Addons/SharedMedia/statusbar/Aluminium |
| font type | Friz Quadrata TT |
| font size | 14 |
| font options | outline |

## DEFINING EVENT HANDLERS

You can specify a function as an event handler in your configuration wherever the configuration template specifies `function(): return_type` as an accepted value. Event handlers all have a fixed set of inputs (arguments) and outputs (return values). They are passed into and returned from the function in the order described in the tables below

| input | type | description |
|---|---|---|
| cache | table | see the [THE CACHE OBJECT](#the-cache-object) documentation below |
| event | string | the name of the event |
| args | defined by wow api |the events args |

| output | type | description |
|---|---|---|
| shouldUpdate | boolean | true if the related entity should be updated. Not all instances of an event may require an update of the bar |
| value | * | the value to update the bar with. See [EVENT HANDLER RETURN TYPES](#event-handler-return-types)
| processFrameUpdates | boolean | if true, indicates this function should be called every fame until this event handler returns false or nil for this value. This allows us to track auras and spell cooldowns that do not have events associated with their progress.

#### FRAME UPDATES

When a function is called as a frame update it receives the cache and an event named "FRAME_UPDATE". The expected outputs are the same as handling a traditional event. Events handlers are still subscribed to events when they are being updated every frame.

#### EVENT HANDLER RETURN TYPES

The above table defines the the return type for each property that accepts an event handler in the configuration template above

| property | type | description |
|---|---|---|
| enabled | boolean | indicates whether the frame and all of its children should be displayed |
| value | string | the actual text value a FrontString will display |
| color | `{ r: number, g: number, b: number, a*: number}` | a table containing red, green, blue and optionally alpha values that detail the color of a frame |
| powerType | Enum.PowerType | https://wow.gamepedia.com/PowerType |
| currentPower | number | the current power for the bars resource |
| maxPower | number | the maximum power for the bars resource |
| offsets | `{ number }` or `{ string: { enabled: boolean, resourceValue: number, color: { r: number, g: number, b: number, a*: number} } }` | a collection of tick marks that will be generated. If generating full tick mark configs, functions are NOT supported. Please use dynamic tick mark generation intelligently. It is a bad idea to carelessly generate a large number of frames. |
| resourceValue | number | the current power value the tick mark will line up with (e.g. if resource value is 50 then the current power bar will line up with the tick mark when the current power is 50) |
| next | number | the predicted power of the resource |

#### THE "INITIAL" EVENT

All entities must (or should be) be initialized to some value. Because many entities will have values resolved via event handlers, it's required that event handlers can provide an initial value without any event data. This is because it's possible, and even likely, that the event your handler is subscribed to will never fire. 

For example, if you listen for "PLAYER_TALENT_UPDATE", it is not likely to happen in any reasonable period of time relative to the bar's initialization. It would be annoying to require yourself to change talents every time you log into the game or load a new zone just to make your bar look appropiate. 

This may result in some extra code and conditional logic in our configuration up front, but makes our experience much nicer.

To handle the initial event, your event handler should be prepared to return a reasonable value when passed an event named "INITIAL". Just like all other events, it will receive the cache object defined below.

#### THE CACHE OBJECT

Each bar (top, bottom, primary, etc...) maintains an object ("the cache") that your configuration is free to write to and read from. During initialization it is populated with the following:

* powerType (this may just be the specs default powerType if your bar is tracking an aura or cd)
* currentPower
* maxPower

If you define currentPower, maxPower, and/or powerType functions they will be called during cache initialization with the __"INITIAL"__ event as explained above. 

The cache is also just a scratch area where you are free to stick any state you want to pass from event handler to event handler.

### SPECIFYING EVENTS OR DEPENDENCIES IN YOUR CONFIGURATION

Wherever you specify an event handler you can define the events it's registered to by specifying a property of the form `${property}_event` within the same scope block as the event handler function.

```lua
    {
        primary = {
            text = {
                -- here are the events that the value's function will be called for
                value_events = { "UNIT_SPELLCAST_START" } 
                value = function(cache, event, ...)
                    -- handle the events, return a value
                end
            ...
        ...
    ...
```

To solve problems with ordering where you want to ensure one property is updated after another (e.g. a text event handler may be strictly dependent on the currentPower event handler), you can instead (or additionally) specify dependencies. Instead of listening for a wow game event you're stating that this property is dependent on some other property and when it (the dependeny) is updated, call this (the dependent's) event handler. When a function is called as a dependency, it gets all the cache and event data that the event handler's dependency received.

The syntax is functionally the same as specifying events. The `${property}_dependencies` table specifies the properties in the configuration it is dependent on. It may only depend on properties within the same bar. examples include: `currentPower`, `maxPower`, or `next` 

```lua
    {
        primary = {
            text = {
                -- here are the dependencies that will cause the defined function to be called after they are updated
                value_dependencies = { "currentPower" } 
                value = function(cache, event, ...)
                    -- handle the events, return a value
                end
            ...
        ...
    ...
```