locals {
  dashboards_flat = merge([
    for folder_name, folder in var.dashboards : {
      for url in folder.urls : "${folder_name}/${basename(url)}" => {
        folder_name = folder_name
        url         = url
      }
    }
  ]...)
}
