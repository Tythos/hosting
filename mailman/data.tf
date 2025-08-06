# data "cloudflare_dns_record" "cfrecorda" {
#   zone_id = var.CF_ZONE_ID

#   filter = {
#     name = {
#       exact = var.HOST_NAME
#     }
#   }
# }
