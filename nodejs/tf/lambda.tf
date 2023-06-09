resource "aws_lambda_function" "main" {
    filename = data.archive_file.this.output_path
    handler = "index.handler"
    runtime = "nodejs18.x"
    function_name = "backend-service"
    role = aws_iam_role.main.arn
    timeout = 30
    source_code_hash = data.archive_file.this.output_base64sha256
    architectures = ["arm64"]
    vpc_config {
        subnet_ids         = [data.aws_subnet.main.id]
        security_group_ids = [aws_security_group.lambda.id]
    }
    environment {
        variables = {
            DB_HOST = "react-app.casjyk0nx1x8.eu-west-1.rds.amazonaws.com"
            DB_USER = "root"
            DB_PASS = jsondecode(data.aws_secretsmanager_secret_version.rds.secret_string)["password"]
            DB_NAME = "my-database"
        }
    }
}

data "archive_file" "this" {
  type = "zip"
  source_dir = ".."
  output_path = "../nodejs.zip"
  excludes = ["package.json", "package-lock.json", "nodejs.zip", "tf"]
}

data "aws_secretsmanager_secret" "rds" {
    name = "rds!db-088ff7c4-30ef-4bc2-95c8-23ececf641eb"
}

data "aws_secretsmanager_secret_version" "rds" {
    secret_id = data.aws_secretsmanager_secret.rds.id
}

resource "aws_lambda_permission" "main" {
    statement_id = "AllowExecutionFromAPIGateway"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.main.function_name
    principal = "apigateway.amazonaws.com"
    source_arn = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}

resource "aws_security_group" "lambda" {
    name = "react-app-nodejs-lambda-sg"
    vpc_id = data.aws_vpc.main.id
    ingress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = [data.aws_vpc.main.cidr_block]
    }
    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
    tags = {
        Name = "react-app-nodejs-lambda-sg"
    }
}