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
      FRIENDS_OF_KUBEROKE = "50"
      CHAINGUARD_CHI_23 = "6"
      CONTROLPLANE_CHI_23 = "6"
      HONEYCOMB_CHI_23 = "6"
    },
    sendgrid_api_key = get_env("SENDGRID_API_KEY")
    event_start_timestamp = "1699405200000"
    default_minutes_to_arrive = "30"
    email_config = yamldecode(file("email_config.yaml"))
  }
)