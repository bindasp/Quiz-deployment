resource "kubernetes_namespace" "quiz" {
  metadata {
    name = "quiz"
  }
}

resource "kubernetes_service_account" "quiz" {
  metadata {
    name      = "quiz"
    namespace = "quiz"
    labels = {
      "name" = "quiz"
    }
  }
}



