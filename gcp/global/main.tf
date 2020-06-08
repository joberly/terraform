provider "google" {
  version = "~> 3.23"
  region  = "us-central1"
  zone    = "us-central1-a"
}

// Terraform config including remote state bucket

terraform {
  backend "gcs" {
    bucket = "johnoberlyiii-terraform-state"
    prefix = "terraform/gcp/global"
  }
}

// Service Accounts

data "google_service_account" "terraform" {
  account_id = "terraform"
}

data "google_storage_project_service_account" "gcs" {
}

// Infrastructure Keyring

resource "google_kms_key_ring" "infra" {
  name     = "infra"
  location = "us"
}

// Terraform state bucket

resource "google_storage_bucket" "johnoberlyiii_terraform_state" {
  name               = "johnoberlyiii-terraform-state"
  bucket_policy_only = true
  encryption {
    default_kms_key_name = google_kms_crypto_key.johnoberlyiii_terraform_state.id
  }
  logging {
    log_bucket = google_storage_bucket.johnoberlyiii_terraform_state_logs.name
  }
  versioning {
    enabled = true
  }
}

resource "google_storage_bucket_iam_member" "johnoberlyiii_terraform_state_service_account" {
  bucket = google_storage_bucket.johnoberlyiii_terraform_state.name
  role = "roles/storage.objectCreator"
  member = "serviceAccount:${data.google_service_account.terraform.email}"
}

resource "google_kms_crypto_key" "johnoberlyiii_terraform_state" {
  name     = "johnoberlyiii-terraform-state"
  key_ring = google_kms_key_ring.infra.id
}

resource "google_kms_crypto_key_iam_member" "johnoberlyiii_terraform_state_gcs" {
  crypto_key_id = google_kms_crypto_key.johnoberlyiii_terraform_state.id
  role = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member = "serviceAccount:${data.google_storage_project_service_account.gcs.email_address}"
}

// Terraform state bucket logs bucket

resource "google_storage_bucket" "johnoberlyiii_terraform_state_logs" {
  name               = "johnoberlyiii-terraform-state-logs"
  bucket_policy_only = true
  encryption {
    default_kms_key_name = google_kms_crypto_key.johnoberlyiii_terraform_state_logs.id
  }
}

resource "google_storage_bucket_iam_member" "johnoberlyiii_terraform_state_logs_gcs" {
  bucket = google_storage_bucket.johnoberlyiii_terraform_state_logs.name
  role = "roles/storage.objectCreator"
  member = "serviceAccount:${data.google_storage_project_service_account.gcs.email_address}"
}

resource "google_kms_crypto_key" "johnoberlyiii_terraform_state_logs" {
  name     = "johnoberlyiii-terraform-state-logs"
  key_ring = google_kms_key_ring.infra.id
}

resource "google_kms_crypto_key_iam_member" "johnoberlyiii_terraform_state_logs_gcs" {
  crypto_key_id = google_kms_crypto_key.johnoberlyiii_terraform_state_logs.id
  role = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member = "serviceAccount:${data.google_storage_project_service_account.gcs.email_address}"
}
