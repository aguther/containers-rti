job "cpuloadgen" {
  # region = "global"
  datacenters = ["dc-1", "dc-2"]

  type = "service"

  group "g-cpuloadgen" {
    count = 1

    restart {
      attempts = 10
      delay    = "5s"
      interval = "60s"
      mode     = "delay"
    }

    task "t-cpuloadgen" {
      driver = "exec"

      config {
        command = "/bin/cpuloadgen"
        args    = ["cpu0=50"]
      }

      resources {
        cpu    = 2500
        memory = 50
      }
    }
  }
}
