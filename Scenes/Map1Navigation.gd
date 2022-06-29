extends Navigation2D


onready var Props = get_node("../Props")

func _ready():
	trees()
	tileuseall(Props)
	$NavigationPolygonInstance.enabled = false
	$NavigationPolygonInstance.enabled = true
	
func trees():
	var polygon = $NavigationPolygonInstance.get_navigation_polygon()
	
	for tree in get_node("../YSort/Trees").get_children():
		var cutout_polygon = PoolVector2Array()
		var c_polygon_transform = tree.get_node("CutoutPolygon2D").get_global_transform()
		var c_polygon = tree.get_node("CutoutPolygon2D").get_polygon()
		
		for vertex in c_polygon:
			cutout_polygon.append(c_polygon_transform.xform(vertex))
		
		#cutout polygon from cutout_polygon
		polygon.add_outline(cutout_polygon)
		polygon.make_polygons_from_outlines()
		
		$NavigationPolygonInstance.set_navigation_polygon(polygon)

func tileuse(Tilemap, ID):
	var polygon = $NavigationPolygonInstance.get_navigation_polygon()
	var used_tiles = Tilemap.get_used_cells_by_id(ID)
	for tile in used_tiles:
		var newpolygon = PoolVector2Array()
		var polygon_offset = Tilemap.map_to_world(tile)
		var tileregion = Tilemap.get_cell_autotile_coord(tile[0],tile[1])
		var tiletransform = Tilemap.get_tileset().tile_get_shape_transform(ID, tileregion[0])
		var polygon_bp = Tilemap.get_tileset().tile_get_shape(ID, tileregion[0]).get_points()
		for vertex in polygon_bp:
			vertex += polygon_offset
			newpolygon.append(tiletransform.xform(vertex))
		polygon.add_outline(newpolygon)
	polygon.make_polygons_from_outlines()		
	$NavigationPolygonInstance.set_navigation_polygon(polygon)
	
func tileuseall(Tilemap):
	var IDs = Tilemap.get_tileset().get_tiles_ids()
	for ID in IDs:
		tileuse(Tilemap, ID)
