include "root" {
  path = find_in_parent_folders()
  expose = true
}

terraform {
  source = "somegit"
}

inputs = merge (
  include.root.locals.env,
  {
    ticket_codes = {
      invalid = "0"
      ALABS_CHI_23 = "6"
    },
    sendgrid_api_key = get_env("SENDGRID_API_KEY")
  }
)