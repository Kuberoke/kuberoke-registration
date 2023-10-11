# kuberoke-registration

## Setup

- Check out this repo
- create an AWS account and configure your AWS credentials whichever way you like (e.g. IAM user)
- copy the `environments/test` folder and rename it to something identifying your event, e.g. `environments/kc-2023-chi`
- update `env.yaml` to select your desired AWS region
- inside the environment, update `ticket_codes` in the inputs inside `terragrunt.hcl` - all inputs will be upper-cased
- configure `event_start_timestamp` (JS timestamp) and `default_minutes_to_arrive` in your inputs
- update `email_config.yaml` with the desired configuration for your emails
- run `npm install` in `/src/lambda/dynamoStreamhandler`
- create a docker container `docker run -it -e SENDGRID_API_KEY="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" -v ~/.ssh:/root/.ssh -v ~/.aws:/root/.aws -v ./:/data devopsinfra/docker-terragrunt:aws-tf-1.3.9-tg-0.44.4 /bin/bash`
- inside the container, make sure your AWS credentials are loaded correctly (e.g. set `AWS_PROFILE` env var in the container shell or in the command above if not using `default` profile)
- `cd` into your environment and run `terragrunt apply --terragrunt-source /data//terraform` to deploy your local code to the AWS account
- execute `src/generate_key.js` and put the public key into `website/index.html`
- put the private key into the secret inside AWS secrets manager (`kuberoke-[event]-keypair`, format: `{"PRIVATE_KEY":"[value from script in previous step]"}` - make sure when copying the value you don't copy any extra characters! The key should not contain spaces and the linebreaks should be replaced by `\n` in the value
`)
- fill in the other missing values in `website/index.html` (search for 'TODO')
- set a basic auth verification value in `website/auth-function.js`

## TODOs

- support placeholders in email text
- improve user auth for static front end
- replace env vars hack for ticket code availability with something more robust

## QR code contents

```
{
  email,          # as entered by the user
  name,           # as entered by the user
  code,           # as entered by the user, UPPERCASED
  timestamp,      # ms since epoch when user sent invitation confirmation by the system, probably want to use Date(timestamp)
  qrsentat,       # ms since epoch when user was sent a QR code by the system, probably want to use Date(qrsentat)
  minutestoarrive,# integer, the user was supposed to arrive within minutestoarrive from when the system sent out their QR code 
  signature       # cryptographic signature, use a public key to verify the rest of the data in the QR code with this signature
}
```

## Viewing front end

Use something like `npx http-server -S -a 0.0.0.0` to host the `index.html` file in `src/website` in an https context.

Check the `TODO`s in the file for pointers on what needs updating (simply scanning doesn't strictly require any of the values, but signature verification requires the pub key for the private key that generated the signature).