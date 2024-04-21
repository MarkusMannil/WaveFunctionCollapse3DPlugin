# Wave Function Collapse 3D Plugin
Godot plugin for Wave Function Collapse 3D
# Creating a WFC object
In a 3D scene create a new wave_function_collapse node.

Add a GridMap as a child and set a MeshLibrary for Gridmap

Create a new WFC_object_list resource and add it to the wfc_node 

![img](https://github.com/MarkusMannil/WaveFunctionCollapse3DPlugin/assets/83127947/92f3a2a9-cbc3-49fd-b975-d2cacc728fbc)

# WFC docked scene
Selecting the WFC node in a WFC editor dock should open
![img_3](https://github.com/MarkusMannil/WaveFunctionCollapse3DPlugin/assets/83127947/79be93e9-5c60-4019-83ec-1df49b86775f)

## Base rule edit
Plugin uses a rule-based system, where you can add rules to object sides, which lets objects connect to any object with matching rule.
There are also special rules, that won't let objects connect with sides that have the same rule

You can add base rules that you can set for your objects.
When adding a rule you can change their name, color and make it special. (Maybe rename special -> ?)
![img_4](https://github.com/MarkusMannil/WaveFunctionCollapse3DPlugin/assets/83127947/80ff6c0c-0293-494a-af0d-cfa1c286429e)

## Add object 
Adds object to WFC object list.
For adding an object you need to provide a name and mesh. Mesh can be left empty.
![img_5](https://github.com/MarkusMannil/WaveFunctionCollapse3DPlugin/assets/83127947/e6f142d0-b828-4f2f-ae93-4c84e347ed4c)

## Edit object
![img_6](https://github.com/MarkusMannil/WaveFunctionCollapse3DPlugin/assets/83127947/104602b6-fa3c-43b0-bddb-09c87c026179)

### Different sides
You can observe the object from 6 sides and add rules to them.
### Add and remove rules
After adding a rule you can select from all predefined rules
![img_7](https://github.com/MarkusMannil/WaveFunctionCollapse3DPlugin/assets/83127947/61c14770-e85e-4c70-8413-3541ba178939)

### Connecting tiles
Under Connecting tiles you can see objects that connect to the selected object's current side.

## Duplicate object
You can duplicate an object and rotate it around the y-axis. If multiple rotations are selected then all duplicates are made 

![img_8](https://github.com/MarkusMannil/WaveFunctionCollapse3DPlugin/assets/83127947/452ffcb7-e112-48aa-a48c-f039a17ea89f)


## Delete object
Deletes object from WFC object list
![img_9](https://github.com/MarkusMannil/WaveFunctionCollapse3DPlugin/assets/83127947/bafb68f3-f943-4793-8d58-6412320799b6)


## Generate
Runs WFC and places objects into the Gridmap

## Clear 
The clear button clears the Gridmap of all meshes

