resource "aws_codecommit_repository" "default" {
  count           = var.enabled ? 1 : 0
  repository_name = var.repo_name
}

resource "aws_iam_role_policy_attachment" "codecommit" {
  role       = aws_iam_role.default.id
  policy_arn = aws_iam_policy.codecommit.arn
}

resource "aws_iam_policy" "codecommit" {
  name   = "${module.label.id}-codecommit"
  policy = data.aws_iam_policy_document.codecommit.json
}

data "aws_iam_policy_document" "codecommit" {
  statement {
    sid = ""

    actions = [
      "codecommit:*",
    ]

    resources = [join("", aws_codecommit_repository.default.*.arn)]
    effect    = "Allow"
  }
}
