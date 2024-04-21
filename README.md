# Wave Function Collapse 3D Plugin
Godot plugin for Wave Function Collapse 3D
# Creating a WFC object
In a 3D scene create a new wave_function_collapse node.

Add a GridMap as a child and set a MeshLibrary for Gridmap

Create a new WFC_object_list resource and add it to the wfc_node 


# WFC docked scene
Selecting the WFC node in a WFC editor dock should open

## BASE RULE EDIT
Plugin uses a rule-based system, where you can add rules to object sides, which lets objects connect to any object with matching rule.
There are also special rules, that won't let objects connect with sides that have the same rule

You can add base rules that you can set for your objects.
When adding a rule you can change their name, color and make it special. (Maybe rename special -> ?)

## Add object 
Adds object to WFC object list.
For adding an object you need to provide a name and mesh. Mesh can be left empty.

## Edit object

### Different sides
You can observe the object from 6 sides and add rules to them.
### Add and remove rules
After adding a rule you can select from all predefined rules

### Connecting tiles
Under Connecting tiles you can see objects that connect to the selected object's current side.

## Duplicate object
You can duplicate an object and rotate it around the y-axis. If multiple rotations are selected then all duplicates are made 



## Delete object
Deletes object from WFC object list


## Generate
Runs WFC and places objects into the Gridmap

## Clear 
The clear button clears the Gridmap of all meshes

