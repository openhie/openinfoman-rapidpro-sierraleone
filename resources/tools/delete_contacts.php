<?php
$url = "http://localhost:8000/api/v1/contacts.json";
$ch = curl_init();
curl_setopt($ch, CURLOPT_HTTPHEADER, Array(
                                                   "Content-Type: application/json",
                                                   "Authorization: Token XXXYYYY",
                                                  ));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$contacts=array();
do {
                curl_setopt($ch, CURLOPT_URL, $url);
                if (! ($data  = curl_exec($ch))
                    || ! is_array(    $t_contacts = json_decode($data,true))
                    || ! array_key_exists('results',$t_contacts)
                    || ! is_array($t_contacts['results'])
                    ) {
		    echo "error on data";
                    break;
                }
                $url = false;
                if (array_key_exists('next',$t_contacts)) {
                    $url = $t_contacts['next'];
                }
                $contacts = array_merge($contacts,$t_contacts['results']);
    } while ($url);
$count=0;
foreach ($contacts as $contact) {
$count++;
$total=count($contacts);
$url="http://localhost:8000/api/v1/contacts.json?uuid=$contact[uuid]";
echo "Deleting ".$contact["uuid"]." $count/$total \n";
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "DELETE");
$output = curl_exec ($ch);
}
curl_close ($ch);
?>

