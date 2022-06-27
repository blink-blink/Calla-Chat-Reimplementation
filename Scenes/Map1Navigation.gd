extends Navigation2D

func _ready():
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
		$NavigationPolygonInstance.enabled = false
		$NavigationPolygonInstance.enabled = true
