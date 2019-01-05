/**
 *  carrefour
 *  Author: koreimy
 *  Description: 
 */

model carrefour

global {
	file fichier_shap_routes<-file('../includes/routes.shp');
	file fichier_shap_departs<-file('../includes/departs.shp');
	file fichier_shap_arrives<-file('../includes/arrivees.shp');
	file fichier_shap_enveloppes<-file('../includes/enveloppes.shp');
	file fichier_shap_feux<-file('../includes/feux.shp');
	int nb_veh<-6;
	geometry shape<-envelope(fichier_shap_enveloppes);
	graph<point,route> reseau_route;
	
	init{
		create route from:fichier_shap_routes;
		reseau_route<-as_edge_graph(list(route));
		create departs from:fichier_shap_departs;
		create arrivees from:fichier_shap_arrives;
		create feux from:fichier_shap_feux;
		create vehicules number:nb_veh{
			location<-any_location_in(one_of(departs));
			point_depart<-one_of(departs);
			point_d_arrive<-one_of(arrivees);
			le_target<-any_location_in(point_d_arrive);
		}
	}
	reflex nouveau_veh when:flip(0.1){
		create vehicules number:1{
			location<-any_location_in(one_of(departs));
			point_depart<-one_of(departs);
			point_d_arrive<-one_of(arrivees);
			le_target<-any_location_in(point_d_arrive);
		}
	}
}
species feux{
	//float size<-4.0;
	rgb value;
	float greenduration<-5.0;
	float redduration<-5.0;
	int count;
	init{
		value<-#green;
		count<-0;
	}
	reflex fonction{
		count<-count+1;
		if((value=#green)and count>=greenduration){
			value<-#red;
			count<-0;
		}
		if((value=#red) and (count>=redduration)){
			value<-#green;
			count<-0;
		}
	}
	aspect base{
		draw geometry:shape color:value;
	}
}
species route{
	rgb color_route<-#black;
	aspect base{
		draw geometry:shape color:color_route;
	}
}
species departs{
	rgb color_depart<-#green;
	aspect base {
		draw geometry:shape color:color_depart;
	}
}
species arrivees{
	rgb color_arrive<-#red;
	aspect base{
		draw geometry:shape color:color_arrive;
	}
}
species vehicules skills:[moving]{
	float speed<-4.0;
	float speed_max<-7.0;
	rgb color_veh<-#yellow;
	float size<-float(rnd(4)+1);
	departs point_depart<-nil;
	arrivees point_d_arrive<-nil;
	point le_target<-nil;
	
	reflex deplacement when:le_target!=nil{
		do goto target:le_target on:reseau_route recompute_path:false;
		if(location=le_target){
			le_target<-nil;
			do action:die;
		}
	}
	aspect base {
		draw rectangle(size,size/2) color:color_veh;
	}
}

experiment carrefour type: gui {
	/** Insert here the definition of the input and output of the model */
	output {
		display carrefour{
			species vehicules aspect:base;
			species route aspect:base;
			species departs aspect:base;
			species arrivees aspect:base;
			species feux aspect:base;
		}
	}
}
