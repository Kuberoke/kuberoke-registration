# kuberoke-registration

## Setup

- Check out this repo
- create an AWS account and configure your AWS credentials whichever way you like (e.g. IAM user)
- copy the `environments/test` folder and rename it to something identifying your event, e.g. `environments/kc-2023-chi`
- update `env.yaml` to select your desired AWS region
- inside the environment, update `ticket_codes` in the inputs inside `terragrunt.hcl` - all inputs will be upper-cased 
- run `npm install` in `/src/lambda/dynamoStreamhandler`
- create a docker container `docker run -it -e SENDGRID_API_KEY="SG.123" -v ~/.ssh:/root/.ssh -v ~/.aws:/root/.aws -v /path/to/repo:/data devopsinfra/docker-terragrunt:aws-tf-1.3.9-tg-0.44.4 /bin/bash`
- inside the container, make sure your AWS credentials are loaded correctly (e.g. set `AWS_PROFILE` env var in the container shell or in the command above if not using `default` profile)
- `cd` into your environment and run `terragrunt apply --terragrunt-source /data//terraform` to deploy your local code to the AWS account


## TODOs

- configure key pair for signing QR codes
- re-enable disabled API endpoints
- re-enable disabled QR code generation
- add static front end files and Cloudfront distribution
- improve user auth for static front end
- replace env vars hack for ticket code availability with something more robust
- check if new code also suffers from encoding issue for QR payload and fix if necessary