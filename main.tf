provider "aws" {
  region  = "us-east-1"
  access_key = ""
  secret_key = ""
}


# Creating a s3 bucket
resource "aws_s3_bucket" "example" {
  bucket =  "website-967"
  tags = {
     Department= "Marketing"
  }
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.example.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.example.id

}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.example,
    aws_s3_bucket_public_access_block.example,
  ]

  bucket = aws_s3_bucket.example.id
  acl    = "private"


}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.example.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Configuring the S3 bucket for static website hosting

resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.example.id

  index_document {
    suffix = "index.html"
  }


  error_document {
    key = "error.html"
  }
}

# Uploading an object in S3 bucket and making public using acl

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.example.id
  key    = "index.html"
  source = " path of index.html"
  etag = filemd5("path of index.html")
  acl ="public-read"
  content_type = "text/html"
}

# Uploading an object in S3 bucket and making public using acl

resource "aws_s3_object" "object1" {
  bucket = aws_s3_bucket.example.id
  key    = "script.js"
  source = "path of script.js"
  etag = filemd5("path of script.js")
  acl ="public-read"
  content_type = "application/javascript"
}

# Uploading an object in S3 bucket and making public using acl

resource "aws_s3_object" "object2" {
  bucket = aws_s3_bucket.example.id
  key    = "style.css"
  source = "path of style.css"
  etag = filemd5("path of style.css")
  acl ="public-read"
  content_type = "text/css"
}

# Defining bucket policy for the objects in S3 bucket to deny deletion of any object

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.example.bucket
  
  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Deny",
        "Principal": "*",
        "Action": [
          "s3:DeleteObject"
        ],
        "Resource": [
          "arn:aws:s3:::${aws_s3_bucket.example.bucket}/index.html",
          "arn:aws:s3:::${aws_s3_bucket.example.bucket}/script.js",
          "arn:aws:s3:::${aws_s3_bucket.example.bucket}/style.css"
        ]

      }
    ]
  }
EOF
}

# Uploading an object in S3 bucket and making public using acl

resource "aws_s3_object" "object3" {
  bucket = aws_s3_bucket.example.id
  key    = "index.html"
  source = "path of index.html"
  etag = filemd5("path of index.html")
  acl ="public-read"
  content_type = "text/html"
}


# updating and uploading objects in s3 and getting respective version Id 

data "aws_s3_object" "example_object_version" {
  bucket = aws_s3_bucket.example.bucket
  key    = aws_s3_object.object.key
}

output "object_version_id" {
  value = data.aws_s3_object.example_object_version.version_id
}

data "aws_s3_object" "example_object3_version" {
  bucket = aws_s3_bucket.example.bucket
  key    = aws_s3_object.object3.key
}

output "object3_version_id" {
  value = data.aws_s3_object.example_object3_version.version_id
}
