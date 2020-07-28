# RBX-Binary-Format

The `rbx-binary-format` project aims to implement a reader and writer for the Roblox binary file format in pure Lua. The XML format is not covered by this project. This project was written and tested in Lua 5.2, but should run in Lua 5.3, LuaJIT, or Luau should the need arise. Some modification will inevitably be necessary for these versions -- if the modification is extensive, feel free to open a pull request to make it easier!

The main focus thus far has been to make the module work. As a result, writing binary files is incredibly rough around the edges and should probably not be used.

## Coverage

Reading binary files should work without any problems so long as all properties in the file are supported (see the coverage table below). Writing is barely functional, pending a few other projects.

### Property Types

| Property Type        | Reader?   | Writer? |
|:---------------------|:---------:|:-------:|
| `string`             | Yes       | No      |
| `bool`               | Yes       | No      |
| `int`                | Yes       | No      |
| `float`              | Yes       | No      |
| `double`             | Yes       | No      |
| `UDim`               | Yes       | No      |
| `UDim2`              | Yes       | No      |
| `Ray`                | Yes       | No      |
| `Faces`              | No        | No      |
| `Axes`               | No        | No      |
| `BrickColor`         | Yes       | No      |
| `Color3`             | Yes       | No      |
| `Vector2`            | Yes       | No      |
| `Vector3`            | Yes       | No      |
| `CFrame`             | Partial   | No      |
| `Enum`               | Partial   | No      |
| `Referent`           | Yes       | No      |
| `Vector3int16`       | No        | No      |
| `NumberSequence`     | Yes       | No      |
| `ColorSequence`      | Yes       | No      |
| `NumberRange`        | Yes       | No      |
| `Rect`               | Yes       | No      |
| `PhysicalProperties` | Yes       | No      |
| `Color3uint8`        | Yes       | No      |
| `int64`              | Partial\* | No      |
| `SharedString`       | Yes       | No      |

\* All Lua numbers are double so unfortunately `int64` will always be partially supported.

## Reading

To read a file, require the [main module](src/init.lua) and call `reader` with the contents of the file as an argument. It will return a table with this shape:

```lua
{
    header = {
        version = int16, -- The version of the file (currently always `0`)
        typeCount = int32, -- The number of classes in the file
        instanceCount = int32, -- The number of Instances in the file
    },
    metadata = Map<string, string>, -- Metadata for the file (currently just 'ExplicitAutoJoints' = 'true')
    sharedStrings = Array<string>, -- Shared strings for the file

    instances = Array<INST>, -- All of the INST chunks in the file
    properties = Array<PROP>, -- All of the PROP chunks in the file

    signatures = Array<string>, -- Signatures listed in the SIGN chunk, if it exists
    parentMap = Map<int32, int32>, -- Map of Instances to their parents such that referents[key].Parent == referents[value]

    referents = Map<int32, Instance>, -- Map of Instances and referents; in practice, an array of Instances
    tree = Array<Instance>, -- An array of Instances in the file, along with all of their descendants, laid out nicely
}
```

To most people, the `tree` field is all that will matter to you, as it contains all of the Instances in the file as well as their properties.

See the [rbx_lua_types](https://github.com/dekkonot/rbx-lua-types) repository for info on Instances in this module.

## Writing

To write a file, require the [main module](src/init.lua) and call `writer` with a 'tree' of Instances in the same format as the `tree` field that's returned from [`reader`](#reading). The contents of the serialized tree will be returned as a string which can then be written to a file.

**WRITING BINARY FILES IS NOT FINISHED, USE AT YOUR OWN ANNOYANCE.**

It *technically* functions but only for a very select few data types and is filled with debug info. Work is stalled until it can be switched to use the Roblox API instead of the faulty guesswork it uses right now to determine the type of properties -- there is currently no way to differentiate between doubles, floats, and integers in this module, which is a major flaw that needs to be corrected.
