# IMPORT WIDGETS REV B
#
# SCRIPT OVERVIEW
# Imports a scene of widget meshes. The purpose is to facilitate reusable
# assets rather than duplicating them with every imported scene. Works in
# conjunction with a companion script called IMPORT SCENE.
#
# WHAT IT DOES
# Takes in a GLTF export from Blender, extracts MATERIALS to disk and links the
# MESHES to them. Then, it extracts the MESHES to disk and links the SCENE to
# them.
#
# SCRIPT ASSUMPTIONS:
# Base output folder is "res://widgets/"
# Subfolders exist in base folder: imports, materials, meshes, scenes, textures
#
# CHANGE LOG:
#
# REV B - After some testing, determined that files didn't need to be deleted.
# In fact, when there were problems it was because the files couldn't be
# deleted or, rather, overwritten.
#
# In order for the script to work, affected files had to be closed. The quickest
# solution was to create a new empty scene before running the script. That freed
# up the files that were active in the main Viewport as well as the Inspector.
# It's up to the user to do that.
#
# Script was still saving to a new scene file. Commented out that section since
# the GLTF could be dragdropped into an existing scene or instanced as a new
# scene. Hence, there was no need to create an additional one.
#
# REV A - Implemented basic functionality. Script saved MATERIALS, MESHES and
# a SCENE. It also linked the SCENE and MESHES to the exported files on disk.
# It deleted files if they already existed.
#
# When saving the SCENE, a non-fatal "Parse Error" is displayed if the scene
# doesn't already exist. The resulting saved scene seems to be perfectly fine.
#
# Strangely, the parse error is not displayed if the file exists. Logically,
# the file is being overwritten. Although, it's possible the file is not
# overwritten and Godot simply doesn't say anything.
#
# If a ".scn" file is used instead of ".tscn", then a parse error is not
# given. Instead, an "unrecognized binary resource file" error is shown. Again,
# the file seems perfectly fine.
#
# Tried creating a single node, packing it and saving that to a ".tscn" file. It
# generated the usual "Parse Error" message and the file was fine. Go figure...
#
# Double checked the output file path: 'res://widgets/scenes/widget_scene.tscn'
# It looked fine. Wrapped the string in single parenthesis to see if there were
# extraneous characters. Nope.
#
# Giving up, for now, since the error is non-fatal...

@tool
extends EditorScenePostImport

const _BASE_FOLDER  := "res://"
const _MATERIAL_FOLDER := _BASE_FOLDER + "materials/"
const _MESH_FOLDER := _BASE_FOLDER + "meshes/"
const _SCENE_FOLDER := _BASE_FOLDER + "scenes/"


func _post_import(scene: Node) -> Object:
	process_scene(scene)
	return scene


func process_scene(scene: Node):
	# Iterate nodes in scene
	for ch in scene.get_children():
		# Ignore object if it's not a mesh
		if not ch is MeshInstance3D:
			continue
		# Remove scene name from current mesh name
		var mesh: ArrayMesh = ch.mesh
		var mesh_name := mesh.resource_name.replace(scene.name + "_", "")
		mesh.resource_name = mesh_name
		# Save current mesh materials to disk
		var material_count := mesh.get_surface_count()
		for material_idx in material_count:
			save_material(mesh, material_idx)
		# Save current mesh to disk
		save_mesh(mesh)
	# Save updated scene to disk
	#save_scene(scene)
	print("--------Done!--------", Time.get_ticks_msec())


func save_material(mesh: ArrayMesh, material_idx: int):
	var material := mesh.surface_get_material(material_idx)
	var material_name := mesh.surface_get_name(material_idx)
	var material_path := "%s%s.tres" % [_MATERIAL_FOLDER, material_name]
	var error := ResourceSaver.save(material, material_path)
	if error != OK:
		push_error("An error occurred while saving the material to disk. %s" % error)
	else:
		#---Point mesh at saved material---
		material.resource_path = material_path
		mesh.surface_set_material(material_idx, material)


func save_mesh(mesh: ArrayMesh):
	var mesh_name := mesh.resource_name
	var mesh_path := "%s%s.res" % [_MESH_FOLDER, mesh_name]
	var error := ResourceSaver.save(mesh, mesh_path)
	if error != OK:
		push_error("An error occured while saving the mesh to disk. %s" % error)
	else:
		mesh.resource_path = mesh_path


func save_scene(scene):
	var scene_path := "%s%s.tscn" % [_SCENE_FOLDER, scene.name]
	var packed_scene := PackedScene.new()
	packed_scene.pack(scene)
	var error = ResourceSaver.save(packed_scene, scene_path)
	if error != OK:
		push_error("An error occurred while saving the scene to disk. %s" % error)
