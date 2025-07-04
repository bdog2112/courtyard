# IMPORT SCENE REV A
#
# OVERVIEW
# Imports a GLTF scene and links MESHES and MATERIALS to pre-existing files on
# disk. The purpose is to facilitate reusable assets rather than duplicating
# them with every imported scene. Works in conjunction with a companion script
# called  IMPORT WIDGETS.
#
# BENEFITS
# Reduces file duplication, games use less memory and scenes load faster due to
# fewer files.
#
# WHAT IT DOES
# Links MATERIALS to files on disk. Then, links the MESHES to files on disk.
# Finally, saves the SCENE to disk.
#
# STEPS
# Make sure you've imported your widgets using the separate IMPORT WIDGETS
# script. Then, setup a new scene in Blender using widget meshes. Select your
# meshes and export to GLTF file in Godot project folder. Attach this script to
# your GLTF file and reimport. Finally, use your imported scene or make new
# scenes with the meshes in your Godot widget repository
#
# REV B - Stopped saving SCENE to disk. GLTF can be dragdropped into a scene or
# instanced to create a scene.
#
# REV A - Links MATERIALS to files on disk. Then, links the MESHES to files on
# disk. Finally, saves the SCENE to disk.

@tool
extends EditorScenePostImport

const _BASE_FOLDER  := "res://widgets/"
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
	# Don't save if file already exists
	var exists = ResourceLoader.exists(material_path)
	print("evaluating %s, exists %s" % [material_path, exists])
	if not ResourceLoader.exists(material_path):
		print("trying to save %s" % material_name)
		# Save file
		var error := ResourceSaver.save(material, material_path)
		if error != OK:
			push_error("An error occurred while saving the material to disk. %s" % error)
			return
	# Point material at file on disk
	print("made it here before resource_path")
	material.resource_path = material_path
	print("made it here before set_surface")
	mesh.surface_set_material(material_idx, material)
	print("made it here after set_surface")


func save_mesh(mesh: ArrayMesh):
	var mesh_name := mesh.resource_name
	var mesh_path := "%s%s.res" % [_MESH_FOLDER, mesh_name]
	# Don't save if file already exists
	if not ResourceLoader.exists(mesh_path):
		# Save file
		var error := ResourceSaver.save(mesh, mesh_path)
		if error != OK:
			push_error("An error occured while saving the mesh to disk. %s" % error)
	# Point mesh at file on disk
	mesh.resource_path = mesh_path


func save_scene(scene):
	var scene_path := "%s%s.tscn" % [_SCENE_FOLDER, scene.name]
	var packed_scene := PackedScene.new()
	packed_scene.pack(scene)
	var error = ResourceSaver.save(packed_scene, scene_path)
	if error != OK:
		push_error("An error occurred while saving the scene to disk. %s" % error)
