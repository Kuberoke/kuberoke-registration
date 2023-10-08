include "root" {
  path = find_in_parent_folders()
  expose = true
}

terraform {
  # TODO: use proper git source URL when released
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
    event_start_timestamp = "1696773795564"
    default_minutes_to_arrive = "30"
    email_config = yamldecode(file("email_config.yaml"))
  }
)