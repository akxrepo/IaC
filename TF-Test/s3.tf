# resource "aws_s3_bucket" "optus_s3_bkt" {
#   bucket = "ak-optus-s3-bkt"
# }

# resource "aws_s3_bucket_lifecycle_configuration" "optus_s3_bkt_lifecycle" {
#   bucket = aws_s3_bucket.optus_s3_bkt.id
#   rule {
#         id     = "log-cleanup"
#         status = "Enabled"

#         filter {
#           prefix = "logs/"
#         }

#         transition {
#           days          = 30
#           storage_class = "GLACIER"
#         }

#         expiration {
#           days = 365
#         }
#     }
# }