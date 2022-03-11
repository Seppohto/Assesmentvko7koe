output "public_ip" {
  depends_on = [
    azurerm_public_ip.koe
  ]
  value = azurerm_public_ip.koe.*.ip_address
}
