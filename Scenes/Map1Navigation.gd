extends Navigation2D


onready var Props = get_node("../Props")
var navigation_cutout_buffer = 1.5
var main_polygon_array = []

func _ready():
	main_polygon_array.append_array(trees())
	main_polygon_array.append_array(tileuseall(Props))
	main_polygon_array = polyreduce(main_polygon_array)
	addpolystonavmesh(main_polygon_array)
	refreshnavmesh()

# merges overlapping polygons in an array
func polyreduce(polygonarray):
	var final_array = []
	while(polygonarray.size()>0):
		var isolated = true
		var curpolygon = polygonarray.pop_back()
		for i in range(polygonarray.size()):
			var merged = Geometry.merge_polygons_2d(curpolygon,polygonarray[i])
			if merged.size() == 1:
				polygonarray.remove(i)
				polygonarray.append(merged[0])
				isolated = false
				break
		if isolated:
			final_array.append(curpolygon)
	return final_array

# adds all polygons in array to navigation mesh
func addpolystonavmesh(polygonarray):
	var navpolygon = $NavigationPolygonInstance.get_navigation_polygon()
	for polygon in polygonarray:
		navpolygon.add_outline(polygon)
	navpolygon.make_polygons_from_outlines()
	$NavigationPolygonInstance.set_navigation_polygon(navpolygon)

# refreshes navigation mesh	
func refreshnavmesh():
	$NavigationPolygonInstance.enabled = false
	$NavigationPolygonInstance.enabled = true

func trees():
	var polygon_array = []
	for tree in get_node("../YSort/Trees").get_children():
		var cutout_polygon = PoolVector2Array()
		var c_polygon_transform = tree.get_node("CutoutPolygon2D").get_global_transform()
		var c_polygon = tree.get_node("CutoutPolygon2D").get_polygon()
		
		for vertex in c_polygon:
			cutout_polygon.append(c_polygon_transform.xform(vertex))
		polygon_array.append(cutout_polygon)
	return polygon_array

# uses tileID and tilemap to return an array of polygons for navmesh use
func tileuse(Tilemap, ID):
	var polygon_array = []
	var used_tiles = Tilemap.get_used_cells_by_id(ID)
	for tile in used_tiles:
		var newpolygon = PoolVector2Array()
		var tilesize = Tilemap.get_cell_size()
		var polygon_offset = Tilemap.map_to_world(tile)
		var tileregion = Tilemap.get_cell_autotile_coord(tile[0],tile[1])
		# Add a translate to transform to account for increased scale later on
		var tiletransform = Tilemap.get_tileset().tile_get_shape_transform(ID, tileregion[0]).translated(Vector2(-tilesize.x*(navigation_cutout_buffer-1)/2,-tilesize.y*(navigation_cutout_buffer-1)/2))
		if not Tilemap.get_tileset().tile_get_shape(ID, tileregion[0]):
			continue
		var polygon_bp = Tilemap.get_tileset().tile_get_shape(ID, tileregion[0]).get_points()
		for vertex in polygon_bp:
			# Make navmesh bigger than collision box
			vertex *= navigation_cutout_buffer
			vertex += polygon_offset
			newpolygon.append(tiletransform.xform(vertex))
		polygon_array.append(newpolygon)
	return polygon_array
	
# gets all IDs from a tilemap to be used in tileuse, returns all polygons created from each tileuse call
func tileuseall(Tilemap):
	var polygon_array = []
	var IDs = Tilemap.get_tileset().get_tiles_ids()
	for ID in IDs:
		polygon_array.append_array(tileuse(Tilemap, ID))
	return polygon_array
