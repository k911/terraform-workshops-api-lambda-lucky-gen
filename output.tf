# There should be outputs
#############
## Example ##
#############

output "api_url" {
  value = aws_api_gateway_deployment.demo.invoke_url
}

output "curl_script" {
  value = "curl ${aws_api_gateway_deployment.demo.invoke_url}/${aws_api_gateway_resource.resource.path_part}"
}
