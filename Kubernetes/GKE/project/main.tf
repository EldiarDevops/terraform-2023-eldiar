terraform {
  required_version = " >= 0.12"
}

provider "google" {
    region = "us-central1"
}

resource "google_project" "eldiar89" {
  name = "eldiar89"
  project_id = "eldiar-1234"
  billing_account = "017806-63D76C-FA71BB"
}

resource "null_resource" "cluster" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "gcloud config set project ${google_project.eldiar89.project_id}"
  }
}

resource "null_resource" "unset-project" {
	provisioner "local-exec" {
	when = destroy
	command = "gcloud config unset project"
	}
}


resource "google_project_service" "project" {
  project = "eldiar-1234"
  service = "compute.googleapis.com"

  disable_dependent_services = true
}

resource "google_project_service" "project1" {
  project = "eldiar-1234"
  service = "container.googleapis.com"

  disable_dependent_services = true
}

resource "google_project_service" "project2" {
  project = "eldiar-1234"
  service = "storage-api.googleapis.com"

  disable_dependent_services = true
}

resource "google_project_service" "project3" {
  project = "eldiar-1234"
  service = "dns.googleapis.com"

  disable_dependent_services = true
}