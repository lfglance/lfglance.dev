# IAM role for Lambda@Edge
resource "aws_iam_role" "lambda_edge_role" {
  provider = aws.east
  name     = "lambda_edge_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
        }
      }
    ]
  })
}

# IAM role policy for Lambda@Edge logging
resource "aws_iam_role_policy" "lambda_edge_policy" {
  provider = aws.east
  name     = "lambda_edge_policy"
  role     = aws_iam_role.lambda_edge_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "path/to/index.js"
  output_path = "lambda.zip"
}

resource "aws_lambda_function" "edge_function" {
  provider         = aws.east
  filename         = "lambda.zip"
  function_name    = "railway_host_header"
  role             = aws_iam_role.lambda_edge_role.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime          = "nodejs18.x"
  publish          = true

  depends_on = [data.archive_file.lambda]
}

