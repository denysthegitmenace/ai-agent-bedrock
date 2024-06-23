module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "ds-bedrock-knowledge-bases"

  versioning = {
    enabled = false
  }
}

data "aws_caller_identity" "current" {}


resource "aws_opensearchserverless_security_policy" "ai_agent_collection_encryption" {
  name        = "ai-agent-collection-encryption"
  type        = "encryption"
  description = "encryption security policy for ai-agent-collection"
  policy = jsonencode({
    Rules = [
      {
        Resource = [
          "collection/ai-agent-collection"
        ],
        ResourceType = "collection"
      }
    ],
    AWSOwnedKey = true
  })
}

resource "aws_opensearchserverless_security_policy" "ai_agent_collection_network" {
  name        = "ai-agent-collection-network"
  type        = "network"
  description = "Public access"
  policy = jsonencode([
    {
      Description = "Public access to collection and Dashboards endpoint for example collection",
      Rules = [
        {
          ResourceType = "collection",
          Resource = [
            "collection/ai-agent-collection"
          ]
        },
        {
          ResourceType = "dashboard"
          Resource = [
            "collection/ai-agent-collection"
          ]
        }
      ],
      AllowFromPublic = true
    }
  ])
}


resource "aws_opensearchserverless_access_policy" "ai_agent_collection_data" {
  name        = "ai-agent-collection-data"
  type        = "data"
  description = "read and write permissions"
  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "index",
          Resource = [
            "index/ai-agent-collection/*"
          ],
          Permission = [
            "aoss:UpdateIndex",
            "aoss:DescribeIndex",
            "aoss:ReadDocument",
            "aoss:WriteDocument",
            "aoss:CreateIndex"
          ]
        },
        {
          ResourceType = "collection",
          Resource = [
            "collection/ai-agent-collection"
          ],
          Permission = [
            "aoss:DescribeCollectionItems",
            "aoss:CreateCollectionItems",
            "aoss:UpdateCollectionItems"
          ]
        }
      ],
      Principal = [
        aws_iam_role.knowledge_base_service_role.arn,
        data.aws_caller_identity.current.arn
      ]
    }
  ])
}


resource "aws_opensearchserverless_collection" "ai_agent_collection" {
  name             = "ai-agent-collection"
  type             = "VECTORSEARCH"
  standby_replicas = "DISABLED"
  depends_on       = [aws_opensearchserverless_access_policy.ai_agent_collection_data, aws_opensearchserverless_security_policy.ai_agent_collection_encryption, aws_opensearchserverless_security_policy.ai_agent_collection_network]
}

# resource "aws_opensearchserverless_security_policy" "example" {
#   name        = "ai-agent-collection-encryption"
#   type        = "encryption"
#   description = "encryption security policy for ai-agent-collection"
#   policy = jsonencode({
#     Rules = [
#       {
#         Resource = [
#           "collection/ai-agent-collection"
#         ],
#         ResourceType = "collection"
#       }
#     ],
#     AWSOwnedKey = true
#   })
# }

resource "aws_bedrockagent_knowledge_base" "ai_agent_knowledge_base" {
  name     = "ai-agent-knowledge-base"
  role_arn = "arn:aws:iam::627624717018:role/service-role/ai_agent_kb_service_role"
  knowledge_base_configuration {
    vector_knowledge_base_configuration {
      embedding_model_arn = "arn:aws:bedrock:us-east-1::foundation-model/cohere.embed-english-v3"
    }
    type = "VECTOR"
  }
  storage_configuration {
    type = "OPENSEARCH_SERVERLESS"
    opensearch_serverless_configuration {
    # collection_arn = "arn:aws:aoss:us-east-1:627624717018:collection/tmlkr6fa4kpib7gvm13e"
      collection_arn    = aws_opensearchserverless_collection.ai_agent_collection.arn
      vector_index_name = "bedrock-knowledge-base-default-index"
      field_mapping {
        vector_field   = "bedrock-knowledge-base-default-vector"
        text_field     = "AMAZON_BEDROCK_TEXT_CHUNK"
        metadata_field = "AMAZON_BEDROCK_METADATA"
      }
    }
  }
}

