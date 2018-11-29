<!-- This file was automatically generated by the `build-harness`. Make all changes to `README.yaml` and run `make readme` to rebuild this file. -->
[![README Header][readme_header_img]][readme_header_link]

[![Cloud Posse][logo]](https://cpco.io/homepage)

# terraform-aws-cicd [![Build Status](https://travis-ci.org/cloudposse/terraform-aws-cicd.svg?branch=master)](https://travis-ci.org/cloudposse/terraform-aws-cicd) [![Latest Release](https://img.shields.io/github/release/cloudposse/terraform-aws-cicd.svg)](https://github.com/cloudposse/terraform-aws-cicd/releases/latest) [![Slack Community](https://slack.cloudposse.com/badge.svg)](https://slack.cloudposse.com)


Terraform module to create AWS [`CodePipeline`](https://aws.amazon.com/codepipeline/) with [`CodeBuild`](https://aws.amazon.com/codebuild/) for [`CI/CD`](https://en.wikipedia.org/wiki/CI/CD)

This module supports three use-cases:

1. **GitHub -> S3 (build artifact) -> Elastic Beanstalk (running application stack)**.
The module gets the code from a ``GitHub`` repository (public or private), builds it by executing the ``buildspec.yml`` file from the repository, pushes the built artifact to an S3 bucket,
and deploys the artifact to ``Elastic Beanstalk`` running one of the supported stacks (_e.g._ ``Java``, ``Go``, ``Node``, ``IIS``, ``Python``, ``Ruby``, etc.).
    - http://docs.aws.amazon.com/codebuild/latest/userguide/sample-maven-5m.html
    - http://docs.aws.amazon.com/codebuild/latest/userguide/sample-nodejs-hw.html
    - http://docs.aws.amazon.com/codebuild/latest/userguide/sample-go-hw.html


2. **GitHub -> ECR (Docker image) -> Elastic Beanstalk (running Docker stack)**.
The module gets the code from a ``GitHub`` repository, builds a ``Docker`` image from it by executing the ``buildspec.yml`` and ``Dockerfile`` files from the repository,
pushes the ``Docker`` image to an ``ECR`` repository, and deploys the ``Docker`` image to ``Elastic Beanstalk`` running ``Docker`` stack.
    - http://docs.aws.amazon.com/codebuild/latest/userguide/sample-docker.html


3. **GitHub -> ECR (Docker image)**.
The module gets the code from a ``GitHub`` repository, builds a ``Docker`` image from it by executing the ``buildspec.yml`` and ``Dockerfile`` files from the repository,
and pushes the ``Docker`` image to an ``ECR`` repository. This is used when we want to build a ``Docker`` image from the code and push it to ``ECR`` without deploying to ``Elastic Beanstalk``.
To activate this mode, don't specify the ``app`` and ``env`` attributes for the module.
    - http://docs.aws.amazon.com/codebuild/latest/userguide/sample-docker.html


---

This project is part of our comprehensive ["SweetOps"](https://cpco.io/sweetops) approach towards DevOps. 
[<img align="right" title="Share via Email" src="https://docs.cloudposse.com/images/ionicons/ios-email-outline-2.0.1-16x16-999999.svg"/>][share_email]
[<img align="right" title="Share on Google+" src="https://docs.cloudposse.com/images/ionicons/social-googleplus-outline-2.0.1-16x16-999999.svg" />][share_googleplus]
[<img align="right" title="Share on Facebook" src="https://docs.cloudposse.com/images/ionicons/social-facebook-outline-2.0.1-16x16-999999.svg" />][share_facebook]
[<img align="right" title="Share on Reddit" src="https://docs.cloudposse.com/images/ionicons/social-reddit-outline-2.0.1-16x16-999999.svg" />][share_reddit]
[<img align="right" title="Share on LinkedIn" src="https://docs.cloudposse.com/images/ionicons/social-linkedin-outline-2.0.1-16x16-999999.svg" />][share_linkedin]
[<img align="right" title="Share on Twitter" src="https://docs.cloudposse.com/images/ionicons/social-twitter-outline-2.0.1-16x16-999999.svg" />][share_twitter]


[![Terraform Open Source Modules](https://docs.cloudposse.com/images/terraform-open-source-modules.svg)][terraform_modules]



It's 100% Open Source and licensed under the [APACHE2](LICENSE).







We literally have [*hundreds of terraform modules*][terraform_modules] that are Open Source and well-maintained. Check them out! 







## Usage

Include this repository as a module in your existing terraform code:

```hcl
module "build" {
    source              = "git::https://github.com/cloudposse/terraform-aws-cicd.git?ref=master"
    namespace           = "global"
    name                = "app"
    stage               = "staging"

    # Enable the pipeline creation
    enabled             = "true"

    # Elastic Beanstalk
    app                 = "<(Optional) Elastic Beanstalk application name>"
    env                 = "<(Optional) Elastic Beanstalk environment name>"

    # Application repository on GitHub
    github_oauth_token  = "(Optional) <GitHub Oauth Token with permissions to access private repositories>"
    repo_owner          = "<GitHub Organization or Person name>"
    repo_name           = "<GitHub repository name of the application to be built and deployed to Elastic Beanstalk>"
    branch              = "<Branch of the GitHub repository>"

    # http://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref.html
    # http://docs.aws.amazon.com/codebuild/latest/userguide/build-spec-ref.html
    build_image         = "aws/codebuild/docker:1.12.1"
    build_compute_type  = "BUILD_GENERAL1_SMALL"

    # These attributes are optional, used as ENV variables when building Docker images and pushing them to ECR
    # For more info:
    # http://docs.aws.amazon.com/codebuild/latest/userguide/sample-docker.html
    # https://www.terraform.io/docs/providers/aws/r/codebuild_project.html
    privileged_mode     = "true"
    aws_region          = "us-east-1"
    aws_account_id      = "xxxxxxxxxx"
    image_repo_name     = "ecr-repo-name"
    image_tag           = "latest"
    # Optional extra environment variables
    environment_variables = [{
      name  = "JENKINS_URL"
      value = "https://jenkins.example.com"
    },
    {
      name  = "COMPANY_NAME"
      value = "Amazon"
    },
    {
      name = "TIME_ZONE"
      value = "Pacific/Auckland"
   }]
}
```




## Examples

### Example: GitHub, NodeJS, S3 and EB

This is an example to build a Node app, store the build artifact to an S3 bucket, and then deploy it to Elastic Beanstalk running ``Node`` stack


``buildspec.yml`` file

```yaml
version: 0.2

phases:
  install:
    commands:
      - echo Starting installation ...
  pre_build:
    commands:
      - echo Installing NPM dependencies...
      - npm install
  build:
    commands:
      - echo Build started on `date`
  post_build:
    commands:
      - echo Build completed on `date`
artifacts:
  files:
    - node_modules/**/*
    - public/**/*
    - routes/**/*
    - views/**/*
    - app.js
```

### Example: GitHub, NodeJS, Docker, ECR and EB

This is an example to build a ``Docker`` image for a Node app, push the ``Docker`` image to an ECR repository, and then deploy it to Elastic Beanstalk running ``Docker`` stack

``buildspec.yml`` file

```yaml
version: 0.2

phases:
  pre_build:
    commands:
      - echo Logging in to Amazon ECR...
      - $(aws ecr get-login --region $AWS_REGION)
  build:
    commands:
      - echo Build started on `date`
      - echo Building the Docker image...
      - docker build -t $IMAGE_REPO_NAME .
      - docker tag $IMAGE_REPO_NAME:$IMAGE_TAG $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG
  post_build:
    commands:
      - echo Build completed on `date`
      - echo Pushing the Docker image to ECR...
      - docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG
artifacts:
  files:
    - '**/*'
```

``Dockefile``

```dockerfile
FROM node:latest

WORKDIR /usr/src/app

COPY package.json package-lock.json ./
RUN npm install
COPY . .

EXPOSE 8081
CMD [ "npm", "start" ]

```



## Makefile Targets
```
Available targets:

  help                                Help screen
  help/all                            Display help for all targets
  help/short                          This help short screen
  lint                                Lint terraform code

```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| app | Elastic Beanstalk application name. If not provided or set to empty string, the ``Deploy`` stage of the pipeline will not be created | string | `` | no |
| attributes | Additional attributes (e.g. `policy` or `role`) | list | `<list>` | no |
| aws_account_id | AWS Account ID. Used as CodeBuild ENV variable when building Docker images. [For more info](http://docs.aws.amazon.com/codebuild/latest/userguide/sample-docker.html) | string | `` | no |
| aws_region | AWS Region, e.g. us-east-1. Used as CodeBuild ENV variable when building Docker images. [For more info](http://docs.aws.amazon.com/codebuild/latest/userguide/sample-docker.html) | string | `` | no |
| branch | Branch of the GitHub repository, _e.g._ ``master`` | string | - | yes |
| build_compute_type | `CodeBuild` instance size.  Possible values are: ```BUILD_GENERAL1_SMALL``` ```BUILD_GENERAL1_MEDIUM``` ```BUILD_GENERAL1_LARGE``` | string | `BUILD_GENERAL1_SMALL` | no |
| build_image | Docker image for build environment, _e.g._ `aws/codebuild/docker:1.12.1` or `aws/codebuild/eb-nodejs-6.10.0-amazonlinux-64:4.0.0` | string | `aws/codebuild/docker:1.12.1` | no |
| buildspec | Declaration to use for building the project. [For more info](http://docs.aws.amazon.com/codebuild/latest/userguide/build-spec-ref.html) | string | `` | no |
| delimiter | Delimiter to be used between `name`, `namespace`, `stage`, etc. | string | `-` | no |
| enabled | Enable ``CodePipeline`` creation | string | `true` | no |
| env | Elastic Beanstalk environment name. If not provided or set to empty string, the ``Deploy`` stage of the pipeline will not be created | string | `` | no |
| environment_variables | A list of maps, that contain both the key 'name' and the key 'value' to be used as additional environment variables for the build. | list | `<list>` | no |
| github_oauth_token | GitHub Oauth Token with permissions to access private repositories | string | - | yes |
| image_repo_name | ECR repository name to store the Docker image built by this module. Used as CodeBuild ENV variable when building Docker images. [For more info](http://docs.aws.amazon.com/codebuild/latest/userguide/sample-docker.html) | string | `UNSET` | no |
| image_tag | Docker image tag in the ECR repository, e.g. 'latest'. Used as CodeBuild ENV variable when building Docker images. [For more info](http://docs.aws.amazon.com/codebuild/latest/userguide/sample-docker.html) | string | `latest` | no |
| name | Solution name, e.g. 'app' or 'jenkins' | string | `app` | no |
| namespace | Namespace, which could be your organization name, e.g. 'cp' or 'cloudposse' | string | `global` | no |
| poll_source_changes | Periodically check the location of your source content and run the pipeline if changes are detected | string | `true` | no |
| privileged_mode | If set to true, enables running the Docker daemon inside a Docker container on the CodeBuild instance. Used when building Docker images | string | `false` | no |
| repo_name | GitHub repository name of the application to be built (and deployed to Elastic Beanstalk if configured) | string | - | yes |
| repo_owner | GitHub Organization or Person name | string | - | yes |
| stage | Stage, e.g. 'prod', 'staging', 'dev', or 'test' | string | `default` | no |
| tags | Additional tags (e.g. `map('BusinessUnit', 'XYZ')` | map | `<map>` | no |




## Help

**Got a question?**

File a GitHub [issue](https://github.com/cloudposse/terraform-aws-cicd/issues), send us an [email][email] or join our [Slack Community][slack].

[![README Commercial Support][readme_commercial_support_img]][readme_commercial_support_link]

## Commercial Support

Work directly with our team of DevOps experts via email, slack, and video conferencing. 

We provide [*commercial support*][commercial_support] for all of our [Open Source][github] projects. As a *Dedicated Support* customer, you have access to our team of subject matter experts at a fraction of the cost of a full-time engineer. 

[![E-Mail](https://img.shields.io/badge/email-hello@cloudposse.com-blue.svg)][email]

- **Questions.** We'll use a Shared Slack channel between your team and ours.
- **Troubleshooting.** We'll help you triage why things aren't working.
- **Code Reviews.** We'll review your Pull Requests and provide constructive feedback.
- **Bug Fixes.** We'll rapidly work to fix any bugs in our projects.
- **Build New Terraform Modules.** We'll [develop original modules][module_development] to provision infrastructure.
- **Cloud Architecture.** We'll assist with your cloud strategy and design.
- **Implementation.** We'll provide hands-on support to implement our reference architectures. 



## Terraform Module Development

Are you interested in custom Terraform module development? Submit your inquiry using [our form][module_development] today and we'll get back to you ASAP.


## Slack Community

Join our [Open Source Community][slack] on Slack. It's **FREE** for everyone! Our "SweetOps" community is where you get to talk with others who share a similar vision for how to rollout and manage infrastructure. This is the best place to talk shop, ask questions, solicit feedback, and work together as a community to build totally *sweet* infrastructure.

## Newsletter

Signup for [our newsletter][newsletter] that covers everything on our technology radar.  Receive updates on what we're up to on GitHub as well as awesome new projects we discover. 

## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/cloudposse/terraform-aws-cicd/issues) to report any bugs or file feature requests.

### Developing

If you are interested in being a contributor and want to get involved in developing this project or [help out](https://cpco.io/help-out) with our other projects, we would love to hear from you! Shoot us an [email][email].

In general, PRs are welcome. We follow the typical "fork-and-pull" Git workflow.

 1. **Fork** the repo on GitHub
 2. **Clone** the project to your own machine
 3. **Commit** changes to your own branch
 4. **Push** your work back up to your fork
 5. Submit a **Pull Request** so that we can review your changes

**NOTE:** Be sure to merge the latest changes from "upstream" before making a pull request!


## Copyright

Copyright © 2017-2018 [Cloud Posse, LLC](https://cpco.io/copyright)



## License 

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) 

See [LICENSE](LICENSE) for full details.

    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

      https://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.









## Trademarks

All other trademarks referenced herein are the property of their respective owners.

## About

This project is maintained and funded by [Cloud Posse, LLC][website]. Like it? Please let us know by [leaving a testimonial][testimonial]!

[![Cloud Posse][logo]][website]

We're a [DevOps Professional Services][hire] company based in Los Angeles, CA. We ❤️  [Open Source Software][we_love_open_source].

We offer [paid support][commercial_support] on all of our projects.  

Check out [our other projects][github], [follow us on twitter][twitter], [apply for a job][jobs], or [hire us][hire] to help with your cloud strategy and implementation.



### Contributors

|  [![Igor Rodionov][goruha_avatar]][goruha_homepage]<br/>[Igor Rodionov][goruha_homepage] | [![Andriy Knysh][aknysh_avatar]][aknysh_homepage]<br/>[Andriy Knysh][aknysh_homepage] |
|---|---|

  [goruha_homepage]: https://github.com/goruha
  [goruha_avatar]: https://github.com/goruha.png?size=150
  [aknysh_homepage]: https://github.com/aknysh
  [aknysh_avatar]: https://github.com/aknysh.png?size=150



[![README Footer][readme_footer_img]][readme_footer_link]
[![Beacon][beacon]][website]

  [logo]: https://cloudposse.com/logo-300x69.svg
  [docs]: https://cpco.io/docs
  [website]: https://cpco.io/homepage
  [github]: https://cpco.io/github
  [jobs]: https://cpco.io/jobs
  [hire]: https://cpco.io/hire
  [slack]: https://cpco.io/slack
  [linkedin]: https://cpco.io/linkedin
  [twitter]: https://cpco.io/twitter
  [testimonial]: https://cpco.io/leave-testimonial
  [newsletter]: https://cpco.io/newsletter
  [email]: https://cpco.io/email
  [commercial_support]: https://cpco.io/commercial-support
  [we_love_open_source]: https://cpco.io/we-love-open-source
  [module_development]: https://cpco.io/module-development
  [terraform_modules]: https://cpco.io/terraform-modules
  [readme_header_img]: https://cloudposse.com/readme/header/img?repo=cloudposse/terraform-aws-cicd
  [readme_header_link]: https://cloudposse.com/readme/header/link?repo=cloudposse/terraform-aws-cicd
  [readme_footer_img]: https://cloudposse.com/readme/footer/img?repo=cloudposse/terraform-aws-cicd
  [readme_footer_link]: https://cloudposse.com/readme/footer/link?repo=cloudposse/terraform-aws-cicd
  [readme_commercial_support_img]: https://cloudposse.com/readme/commercial-support/img?repo=cloudposse/terraform-aws-cicd
  [readme_commercial_support_link]: https://cloudposse.com/readme/commercial-support/link?repo=cloudposse/terraform-aws-cicd
  [share_twitter]: https://twitter.com/intent/tweet/?text=terraform-aws-cicd&url=https://github.com/cloudposse/terraform-aws-cicd
  [share_linkedin]: https://www.linkedin.com/shareArticle?mini=true&title=terraform-aws-cicd&url=https://github.com/cloudposse/terraform-aws-cicd
  [share_reddit]: https://reddit.com/submit/?url=https://github.com/cloudposse/terraform-aws-cicd
  [share_facebook]: https://facebook.com/sharer/sharer.php?u=https://github.com/cloudposse/terraform-aws-cicd
  [share_googleplus]: https://plus.google.com/share?url=https://github.com/cloudposse/terraform-aws-cicd
  [share_email]: mailto:?subject=terraform-aws-cicd&body=https://github.com/cloudposse/terraform-aws-cicd
  [beacon]: https://ga-beacon.cloudposse.com/UA-76589703-4/cloudposse/terraform-aws-cicd?pixel&cs=github&cm=readme&an=terraform-aws-cicd
