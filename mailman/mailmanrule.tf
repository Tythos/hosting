# resource "cloudflare_email_routing_rule" "mailmanrule" {
#   zone_id  = var.CF_ZONE_ID
#   enabled  = true
#   name     = "Forward automation mail to ACME address"
#   priority = 0

#   actions = [{
#     type  = "forward"
#     value = [var.ACME_EMAIL]
#   }]

#   matchers = [{
#     type  = "literal"
#     field = "to"
#     value = cloudflare_email_routing_address.mailmanaddress.email
#   }]
# }
