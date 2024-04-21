# Wave Function Collapse 3D Plugin
Godot plugin for Wave Function Collapse 3D
# Creating a WFC object
In a 3D scene create a new wave_function_collapse node.

Add a GridMap as a child and set a MeshLibrary for gridmap

Create a new WFC_object_list resource and add it to the wfc_node 

![img.png](img.png)

# WFC docked scene
Selecting the WFC node a WFC editor dock should open
![img_3.png](img_3.png)
## BASE RULE EDIT
Plugin uses a rule based system, where you can add rules to object sides, which lets objects connect to any object with matching rule.
There are also special rules, that won't let objects connect with sides that have the same rule

You can add base rules that you can set for your objects.
When adding a rule you can change their name, color and make it special. (Maybe rename special -> ?)
![img_4.png](img_4.png)
## Add object 
Adds object to WFC object list.
For adding an object you need to provide a name and mesh. Mesh can be left empty.

![img_5.png](img_5.png)
## Edit object
![img_6.png](img_6.png)
### Different sides
You can observe the object from 6 sides and add rules to them.
### Add and remove rules
After adding a rule you can select from all predefined rules
![img_7.png](img_7.png)
### Connecting tiles
Under Connecting tiles you can see objects that connect to selected object current side.

## Duplicate object
You can dublicate an object and rotate it around y-axis. If multipiple rotations are selected then all dublicates are made 

![img_8.png](img_8.png)

## Delete object
Deletes object from WFC object list

![img_9.png](img_9.png)
## Generate
Runs WFC and places objects into the gridmap

## Clear 
Clear button clears the gridmap of all meshes

