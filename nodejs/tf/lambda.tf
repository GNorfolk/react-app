resource "aws_lambda_function" "main" {
    filename = "../nodejs.zip"
    handler = "index.handler"
    runtime = "nodejs18.x"
    function_name = "backend-service"
    role = aws_iam_role.main.arn
    timeout = 30
    source_code_hash = filebase64sha256("../nodejs.zip")
    architectures = ["arm64"]
}

resource "aws_lambda_permission" "main" {
    statement_id = "AllowExecutionFromAPIGateway"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.main.function_name
    principal = "apigateway.amazonaws.com"
    source_arn = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}