resource "aws_iam_role" "cwl_go_lambda_role" {
  name = "cwl-go-lambda-role"
  tags = var.tags

  assume_role_policy = <<ASSUME
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
ASSUME
}

resource "aws_iam_policy" "cwl_go_lambda_ec2" {
  name = "cwl-go-lambda-policy"
  tags = var.tags

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "logs:PutRetentionPolicy",
                "logs:DescribeLogGroups"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
POLICY
}


resource "aws_iam_role_policy_attachment" "attach_ec2_policy" {
  policy_arn = aws_iam_policy.cwl_go_lambda_ec2.arn
  role       = aws_iam_role.cwl_go_lambda_role.name
}