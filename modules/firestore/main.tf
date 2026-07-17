resource "google_firestore_database" "default" {
  project     = var.project_id
  name        = "(default)"
  location_id = var.region
  type        = "FIRESTORE_NATIVE"

  deletion_policy = "DELETE"
}

resource "google_firestore_index" "comments_entity_tenant" {
  project    = var.project_id
  collection = "comments"
  database   = "(default)"

  fields {
    field_path = "entityId"
    order      = "ASCENDING"
  }
  fields {
    field_path = "tenantId"
    order      = "ASCENDING"
  }
  fields {
    field_path = "createdAt"
    order      = "DESCENDING"
  }

  depends_on = [google_firestore_database.default]
}

resource "google_firestore_index" "entity_likes_entity_tenant" {
  project    = var.project_id
  collection = "entityLikes"
  database   = "(default)"

  fields {
    field_path = "entityId"
    order      = "ASCENDING"
  }
  fields {
    field_path = "tenantId"
    order      = "ASCENDING"
  }
  fields {
    field_path = "__name__"
    order      = "ASCENDING"
  }

  depends_on = [google_firestore_database.default]
}