module namespace page = 'http://basex.org/modules/web-page';

(:Import other namespaces.  :)
import module namespace csd_webui =  "https://github.com/openhie/openinfoman/csd_webui";
import module namespace csr_proc = "https://github.com/openhie/openinfoman/csr_proc";
import module namespace csd_dm = "https://github.com/openhie/openinfoman/csd_dm";
import module namespace csd_mcs = "https://github.com/openhie/openinfoman/csd_mcs";
import module namespace functx = "http://www.functx.com";
import module namespace json = "http://basex.org/modules/json";
import module namespace request = "http://exquery.org/ns/request";


declare namespace csd = "urn:ihe:iti:csd:2013";


declare function page:is_rapidpro($search_name) {
  let $function := csr_proc:get_function_definition($search_name)
  let $ext := $function//csd:extension[  @urn='urn:openhie.org:openinfoman:adapter' and @type='rapidpro']
  return (count($ext) > 0) 
};


declare function page:get_actions($search_name) {
  let $function := csr_proc:get_function_definition($search_name)
  return 
    (
    for $act in $function//csd:extension[  @urn='urn:openhie.org:openinfoman:adapter:rapidpro:action']/@type
    return string($act)
  )
};



declare
  %rest:path("/CSD/csr/{$doc_name}/careServicesRequest/{$search_name}/adapter/rapidpro")
  %output:method("xhtml")
  function page:show_endpoints($search_name,$doc_name) 
{  
    if (not(page:is_rapidpro($search_name)) ) 
      then ('Not a RapidPro Compatible stored function'    )
    else 
      let $actions := page:get_actions($search_name)
      let $contents := 
      <div>
        <h2>RapidPro Operations on {$doc_name}</h2>
        { 
          if ($actions = 'get')  
	  then
	   <span>
             <h3>JSON Contacts  -- GET</h3>
	     {
	       let $url := csd_webui:generateURL(("CSD/csr/" , $doc_name , "/careServicesRequest/",$search_name, "/adapter/rapidpro/get"))
	       return <p><a href="{$url}">Get Contacts</a></p>
	     }
	   </span>
	  else ()
	}

        { 
          if ($actions = 'WebHookGET')  
	  then
	   <span>
             <h3>WebHook  -- GET</h3>
	     {
	       let $url := csd_webui:generateURL(("CSD/csr/" , $doc_name , "/careServicesRequest/",$search_name, "/adapter/rapidpro/createDXF"))
	       return <p>WebHook defined at {$url}</p>
	     }
	   </span>
	  else ()
	}
        { 
          if ($actions = 'WebHookPOST')  
	  then
	   <span>
             <h3>WebHook  -- POST</h3>
	     {
	       let $url := csd_webui:generateURL(("CSD/csr/" , $doc_name , "/careServicesRequest/",$search_name, "/adapter/rap/createDXF"))
	       return <p>WebHook defined at {$url}</p>
	     }
	   </span>
	  else ()
	}

      </div>
      return csd_webui:wrapper($contents)
};


 
declare
  %rest:path("/CSD/csr/{$doc_name}/careServicesRequest/{$search_name}/adapter/rapidpro/WebHook")
  %rest:query-param("event","{$event}")
  %rest:query-param("relayer","{$relayer}")
  %rest:query-param("relayer_phone","{$relayer_phone}")
  %rest:query-param("phone","{$phone}")
  %rest:query-param("flow","{$flow}")
  %rest:query-param("step","{$step}")
  %rest:query-param("values","{$values}")
  %output:media-type("application/json")
  %rest:POST
  %rest:GET
  function page:webhook($search_name,$doc_name,$event,$relayer,$relayer_phone,$phone,$flow,$step,$values) 
{
  if (not(page:is_rapidpro($search_name)) ) 
    then ('Not a RapidPro Compatible stored function'    )
  else 
    let $doc :=  csd_dm:open_document($doc_name)
    let $function := csr_proc:get_function_definition($search_name)

    let $careServicesRequest := 
      <csd:careServicesRequest>
       <csd:function urn="{$search_name}" resource="{$doc_name}" base_url="{csd_webui:generateURL()}">
         <csd:requestParams >
	   <event type="{$event}"/>
	   <relayer id="{$relayer}"/>
	   <relayer_phone number="{$relayer_phone}"/>
	   <phone number="{$phone}"/>
	   <flow id="{$flow}"/>
	   <step id="{$step}"/>
           <values>
	     {
	       if ($values) 
	       then    json:parse($values,map{'format':'attributes'})/json/*
	       else ()
	     }
	   </values>
	   {
	     for $param in request:parameter-names()
	     return <query name="{$param}">{request:parameter($param)}</query>
	   }
         </csd:requestParams>
       </csd:function>
      </csd:careServicesRequest>
    return csr_proc:process_CSR_stored_results( $doc,$careServicesRequest)
};


 
declare
  %rest:path("/CSD/csr/{$doc_name}/careServicesRequest/{$search_name}/adapter/rapidpro/get")
  function page:get($search_name,$doc_name) 
{
  if (not(page:is_rapidpro($search_name)) ) 
    then 
    <p>
    {csr_proc:get_function_definition($search_name)}
    {(concat('Not a RapidPro Compatible stored function: ', $search_name )    )}
    </p>
  else 
    let $doc :=  csd_dm:open_document($doc_name)
    let $function := csr_proc:get_function_definition($search_name)

    let $careServicesRequest := 
      <csd:careServicesRequest> 
       <csd:function urn="{$search_name}" resource="{$doc_name}" base_url="{csd_webui:generateURL()}">
         <csd:requestParams/>
       </csd:function>
     </csd:careServicesRequest> 
    let $content := csr_proc:process_CSR_stored_results( $doc,$careServicesRequest) 
    let $output := $function/@content-type
    let $mime := 
      if (exists($output))
      then string($output)
      else "text/html"
    return 
    ( 
      <rest:response>
	<http:response status="200" >
          <http:header name='Content-Type' value="{$mime}"/>
	  <http:header name='Content-Disposition' value="attachment; filename='{$doc_name}.json'"/>
	</http:response>
      </rest:response>
      ,$content
    )


};


