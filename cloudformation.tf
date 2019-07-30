resource "aws_iam_role" "cloudformation" {
  name               = "${module.label.id}-cloudformation"
  assume_role_policy = data.aws_iam_policy_document.cloudformation_assume.json
}

data "aws_iam_policy_document" "cloudformation_assume" {
  statement {
    sid = ""

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = [
        "cloudformation.amazonaws.com",
        "codepipeline.amazonaws.com"
      ]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role_policy_attachment" "cloudformation" {
  role       = aws_iam_role.cloudformation.id
  policy_arn = aws_iam_policy.cloudformation.arn
}

resource "aws_iam_policy" "cloudformation" {
  name   = "${module.label.id}-cloudformation"
  policy = data.aws_iam_policy_document.cloudformation.json
}

data "aws_iam_policy_document" "cloudformation" {
  statement {
    sid = ""

    actions = [
      "cloudformation:CreateChangeSet",
      "iam:GetRole",
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:PassRole",
      "lambda:GetFunction",
      "lambda:CreateFunction",
      "lambda:DeleteFunction",
      "lambda:UpdateFunctionCode",
    ]

    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_role_policy_attachment" "cloudformation_lambda" {
  role       = aws_iam_role.cloudformation.id
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaExecute"
}

resource "aws_codepipeline" "source_build_deploy" {
  count    = var.enabled && signum(length(var.template_path)) == 1 ? 1 : 0
  name     = module.label.id
  role_arn = aws_iam_role.default.arn

  artifact_store {
    location = aws_s3_bucket.default.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["code"]

      configuration = {
        RepositoryName       = var.repo_name
        BranchName           = var.branch
        PollForSourceChanges = var.poll_source_changes
      }
    }
  }

  stage {
    name = "Build"

    action {
      name     = "Build"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"

      input_artifacts  = ["code"]
      output_artifacts = ["package"]

      configuration = {
        ProjectName = module.codebuild.project_name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "CreateChangeSet"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CloudFormation"
      input_artifacts = ["package"]
      #role_arn        = aws_iam_role.cloudformation.arn
      version         = "1"
      run_order       = 1

      configuration = {
        ActionMode    = "CHANGE_SET_REPLACE"
        StackName     = "${module.label.id}-stack"
        ChangeSetName = "${module.label.id}-changes"
        Capabilities  = var.capabilities
        RoleArn       = aws_iam_role.cloudformation.arn
        TemplatePath  = "package::${var.template_path}"
      }
    }

    action {
      name             = "DeployChangeSet"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "CloudFormation"
      #output_artifacts = ["deployment"]
      version          = "1"
      run_order        = 2

      configuration = {
        ActionMode    = "CHANGE_SET_EXECUTE"
        StackName     = "${module.label.id}-stack"
        ChangeSetName = "${module.label.id}-changes"
      }
    }
  }
}
