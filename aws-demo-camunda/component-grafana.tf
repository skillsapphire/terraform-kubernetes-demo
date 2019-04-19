## define bpm master component

module "grafana" {
  //source    = "github.com/eleks/terraform-kubernetes-demo/kub-component-generic"
  source    = "../kub-component-generic"
  ssh_host  = "${module.kub.bastion-ip}"

  name      = "grafana"
  namespace = "default"
  image     = "grafana/grafana"
  replicas  = 1
  #command   = ""

  mem_min   = "256Mi"
  mem_max   = "1Gi"
  cpu_min   = "0.5"
  cpu_max   = "1"
  ports     = "${local.component_ports["grafana"]}"
  env = {
    GF_AUTH_BASIC_ENABLED      = "true"
    GF_AUTH_ANONYMOUS_ENABLED  = "false"
    GF_AUTH_ANONYMOUS_ORG_ROLE = "Admin"
    GF_SERVER_ROOT_URL         = "${module.port-grafana-https.public_protocol}://${data.null_data_source.component_hosts.outputs["grafana"]}:${module.port-grafana-https.public_port}"
    GF_SECURITY_ADMIN_PASSWORD = "${var.tf_grafana_pass}"
    GF_INSTALL_PLUGINS         = "grafana-piechart-panel"
  }
  claim_volumes = [
    "default-nfs-claim:/etc/grafana/provisioning/:grafana"
  ]

  ## wait for kubernetes and persistent ready
  depends_on = ["${module.kub.ready}", "${module.persistent.ready}"]
}

## expose public ports
module "port-grafana-https" {
  //source          = "github.com/eleks/terraform-kubernetes-demo/aws-listener"
  source          = "../aws-listener"
  port            = "https"
  ports           = "${local.component_ports["grafana"]}"
  params          = "${ data.null_data_source.default_port_params.outputs }"
}

output "component-grafana" {
  value = "${module.port-grafana-https.public_protocol}://${data.null_data_source.component_hosts.outputs["grafana"]}:${module.port-grafana-https.public_port}"
}

