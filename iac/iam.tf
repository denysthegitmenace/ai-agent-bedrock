resource "aws_iam_role" "knowledge_base_service_role" {
  name        = "ai_agent_kb_service_role"
  description = "Bedrock Knowledge Base access"
  path        = "/service-role/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AmazonBedrockKnowledgeBaseTrustPolicy"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
        Condition = {
          ArnLike = {
            "aws:SourceArn" = "arn:aws:bedrock:us-east-1:627624717018:knowledge-base/*"
          }
          StringEquals = {
            "aws:SourceAccount" = "627624717018"
          }
        }
      },
    ]
  })
 #TODO #1 terraform below three policies
  managed_policy_arns = [
    "arn:aws:iam::627624717018:policy/service-role/AmazonBedrockFoundationModelPolicyForKnowledgeBase_ai_agent_kb_service_role",
    "arn:aws:iam::627624717018:policy/service-role/AmazonBedrockOSSPolicyForKnowledgeBase_ai_agent_kb_service_role",
    "arn:aws:iam::627624717018:policy/service-role/AmazonBedrockS3PolicyForKnowledgeBase_ai_agent_kb_service_role",
  ]

  tags = {
    Terraform = "true"
  }
}

# resource "aws_iam_role_policy" "knowledge_base_service_role_policy" {
#   name = "knowledge_base_service_policy"
#   role = aws_iam_role.knowledge_base_service_role.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid : "BedrockInvokeModelStatement",
#         Effect : "Allow",
#         Action : [
#           "bedrock:InvokeModel"
#         ],
#         Resource : [
#           "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v2:0"
#         ]
#       },
#       {
#         Sid : "OpenSearchServerlessAPIAccessAllStatement",
#         Effect : "Allow",
#         Action : [
#           "aoss:APIAccessAll"
#         ],
#         Resource : [
#           module.opensearch_serverless.arn
#         ]
#       },
#       {
#         Sid : "S3ListBucketStatement",
#         Effect : "Allow",
#         Action : [
#           "s3:ListBucket"
#         ],
#         Resource : [
#           "arn:aws:s3:::tt0724llm"
#         ],
#         Condition : {
#           StringEquals : {
#             "aws:ResourceAccount" : [
#               "627624717018"
#             ]
#           }
#         }
#       },
#       {
#         Sid : "S3GetObjectStatement",
#         Effect : "Allow",
#         Action : [
#           "s3:GetObject"
#         ],
#         Resource : [
#           "arn:aws:s3:::tt0724llm/*"
#         ],
#         Condition : {
#           StringEquals : {
#             "aws:ResourceAccount" : [
#               "627624717018"
#             ]
#           }
#         }
#       }
#     ]
#   })
# }

