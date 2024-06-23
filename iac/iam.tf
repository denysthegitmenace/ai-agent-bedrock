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
  managed_policy_arns = [
    aws_iam_policy.invoke_bedrock_fm.arn,
    aws_iam_policy.access_collections.arn,
    aws_iam_policy.access_s3.arn
  ]

  tags = {
    Terraform = "true"
  }
}

resource "aws_iam_policy" "invoke_bedrock_fm" {
  name = "AmazonBedrockFoundationModelPolicyForKnowledgeBase_ai_agent_kb_service_role"
  #   role = aws_iam_role.knowledge_base_service_role.id
  path = "/service-role/"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "BedrockInvokeModelStatement",
        "Effect" : "Allow",
        "Action" : [
          "bedrock:InvokeModel"
        ],
        "Resource" : [
          "arn:aws:bedrock:us-east-1::foundation-model/cohere.embed-english-v3"
        ]
      }
  ] })
}


resource "aws_iam_policy" "access_collections" {
  name = "AmazonBedrockOSSPolicyForKnowledgeBase_ai_agent_kb_service_role"
  path = "/service-role/"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "OpenSearchServerlessAPIAccessAllStatement",
        "Effect" : "Allow",
        "Action" : [
          "aoss:APIAccessAll"
        ],
        "Resource" : [
          "arn:aws:aoss:us-east-1:627624717018:collection/xc5517cl53txt998rcdj"
        ]
      }
  ] })
}

resource "aws_iam_policy" "access_s3" {
  name = "AmazonBedrockS3PolicyForKnowledgeBase_ai_agent_kb_service_role"
  path = "/service-role/"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "S3ListBucketStatement",
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket"
        ],
        "Resource" : [
          "arn:aws:s3:::ds-bedrock-knowledge-bases"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:ResourceAccount" : [
              "627624717018"
            ]
          }
        }
      },
      {
        "Sid" : "S3GetObjectStatement",
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject"
        ],
        "Resource" : [
          "arn:aws:s3:::ds-bedrock-knowledge-bases/*"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:ResourceAccount" : [
              "627624717018"
            ]
          }
        }
      }
    ]
  })
}
