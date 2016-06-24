import module namespace functx = "http://www.functx.com";
declare namespace csd = "urn:ihe:iti:csd:2013";
declare variable $careServicesRequest as item() external;


let $country_code := '+231'
let $cellcom_code := '77'

let $get_clean_phones := function($provider) {
  let $all_phones := $provider/csd:demographic/csd:contactPoint/csd:codedType[@code = "BP" and @codingScheme="urn:ihe:iti:csd:2013:contactPoint"]
  let $clean_phones :=
    for $phone in $all_phones
    let $raw_phones := tokenize($phone/text(),'[/\s]+')
    let $normalized_phones := 
      for $raw_phone in $raw_phones
      let $clean_phone := replace($raw_phone,'[^\d\+]/', '')
      return 
	if (string-length($clean_phone) = 0)
	then ()
        else 
	  if (starts-with($clean_phone,'0'))
	  then concat($country_code, substring($clean_phone,2))
	  else $clean_phone
    return $normalized_phones
  return $clean_phones
}

let $clean_providers := 
  for $provider in /csd:CSD/csd:providerDirectory/csd:provider
  let $clean_phones := $get_clean_phones($provider)
  where count($clean_phones) > 0
  return $provider

let $cellcom_providers := 
  for $provider in $clean_providers 
  let $clean_phones := $get_clean_phones($provider)
  let $cellcom_phones := 
    for $clean_phone in $clean_phones
    return 
      if (starts-with($clean_phone,concat($country_code,$cellcom_code))) 
      then $clean_phone
      else ()
  where (count($cellcom_phones) > 0)
  return $provider

let $multi_providers :=
  for $provider in $clean_providers
  let $clean_phones := $get_clean_phones($provider)
  where (count($clean_phones) > 1)
  return $provider

return 
  <div>
    <ul>
      <li>Total number of health workers: {count(/csd:CSD/csd:providerDirectory/csd:provider)}</li>
      <li>Total number of health workers with phone: {count($clean_providers)}</li>
      <li>Total number of health workers with cellcom phone: {count($cellcom_providers)}</li>
      <li>Total number of health workers with multiple phones: {count($multi_providers)}</li>      
    </ul>
  </div>


