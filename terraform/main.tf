provider "google" {
  project = "${var.project}"
  region  = "us-east1"
}

resource "google_storage_bucket" "bucket" {
  name = "cloud-function-tutorial-bucket-5abeel" # This bucket name must be unique
}

data "archive_file" "src" {
  type        = "zip"
  source_dir  = "${path.root}/../src" # Directory where your Python source code is
  output_path = "${path.root}/../generated/src.zip"
}

resource "google_storage_bucket_object" "archive" {
  name   = "${data.archive_file.src.output_md5}.zip" # or can be "src.zip"
  bucket = google_storage_bucket.bucket.name
  source = "${path.root}/../generated/src.zip"
}

resource "google_cloudfunctions_function" "function" {
  name        = "cloud-function-tutorial-5abeel"
  description = "An example Cloud Function"
  runtime     = "python37"

  environment_variables = {
    FOO = "bar7",
  }

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  trigger_http          = true
  entry_point           = "http_handler" # This is the name of the function that will be executed in your Python code
}
