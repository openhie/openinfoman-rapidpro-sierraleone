import module namespace oi_csv =  "https://github.com/openhie/openinfoman/adapter/csv";
declare namespace csd = "urn:ihe:iti:csd:2013";
declare variable $careServicesRequest as item() external;

oi_csv:get_serialized(/,$careServicesRequest)