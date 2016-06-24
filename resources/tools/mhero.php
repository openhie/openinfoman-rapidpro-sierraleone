<?php
/*******************************************************************
Run this script as root.                                           *
The script assumes the debian package installation.                *
The export command is not working,so all variables that            *
are set wit the export command should be set directly to the       *
 synchronize.php and iti_74_query_for_updated_services.php scripts *
********************************************************************/
	#####Set variables#####
	$ihris_user="ihris";
	$ihris_password="manage";
	$openinfoman_user="oim";
	$openinfoman_password="oim";
	$ihris_url="http://localhost/manage-demo";
	$openinfoman_url="http://localhost:5001/CSD";
	$RAPIDPRO_AUTH_TOKEN="XXX23dd821c514eXXX";
	$RAPIDPRO_URL="https://app.rapidpro.io/api/v1/contacts.json";
	$RAPIDPRO_GROUP_NAME="testing";
	$RAPIDPRO_GROUP_UUID="";
	$RAPIDPRO_SLUG="mhero";
	$ihris_to_rapidpro_script="/var/lib/openinfoman/resources/tools/synchronize.php";
	$rapidpro_to_ihris_script="/var/lib/openinfoman/resources/tools/iti_74_query_for_updated_services.php";
	//this is the name of doc to store contacts sync back from rapidpro
	$rapidpro_oim_service_dir="mhero.xml";
	$ihris_oim_service_dir="test";
	#####End of setting variables#####
	
	#####Preparing iHRIS CSD Caches#####
	$url=$ihris_url."/csd_cache?action=full_update";
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_URL,$url);
	curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "GET");
	curl_setopt($ch, CURLOPT_USERPWD, $ihris_user . ":" . $ihris_password);
	curl_setopt($ch, CURLOPT_VERBOSE, true);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	$output = curl_exec ($ch);
	curl_error($ch);
	curl_close ($ch);
	var_dump($output);
	#####End of preparing iHRIS CSD Caches#####
	
	#####Pull any new iHRIS contacts into openinfoman#####
	$doc=str_replace(".xml","",$ihris_oim_service_dir);
	exec("curl -u $openinfoman_user:$openinfoman_password $openinfoman_url/pollService/directory/$doc/update_cache");
	#####End of pulling any new iHRIS contacts into openinfoman#####

	#####Start pushing iHRIS contacts to Rapidpro#####
	if($RAPIDPRO_AUTH_TOKEN)
	exec('export RAPIDPRO_AUTH_TOKEN="'.$RAPIDPRO_AUTH_TOKEN.'"');
	if($RAPIDPRO_URL)
	exec('export RAPIDPRO_URL="'.$RAPIDPRO_URL.'"');
	
	if($RAPIDPRO_GROUP_NAME)
	exec('export RAPIDPRO_GROUP_NAME="'.$RAPIDPRO_GROUP_NAME.'"');

	exec("php $ihris_to_rapidpro_script");
	#####End of pushing iHRIS contacts to Rapidpro#####

	#####Start pulling all created contacts from Rapidpro into Openinfoman#####
	if($RAPIDPRO_SLUG)
	exec('export RAPIDPRO_SLUG="'.$RAPIDPRO_SLUG.'"');
	exec("php $rapidpro_to_ihris_script > /var/lib/openinfoman/resources/service_directories/$rapidpro_oim_service_dir");
	//initialize the doc if its not
	$doc=str_replace(".xml","",$rapidpro_oim_service_dir);
	exec("curl $openinfoman_url/initSampleDirectory/directory/$doc/load");
	//reload the doc
	exec("curl $openinfoman_url/initSampleDirectory/directory/$doc/reload");
	#####End of pulling all created contacts from Rapidpro into Openinfoman#####
	?>
