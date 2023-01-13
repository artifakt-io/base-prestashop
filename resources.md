Dashboard:
https://grafana.com/grafana/dashboards/
Node Exporter Full: 1860
MySQL Exporter Quickstart and Dashboard: 14057

Local access
Prometheus: http://127.0.0.1:9090
Grafana : http://127.0.0.1:3000/login
cadvisor: http://127.0.0.1:8084/containers/
nginx: http://127.0.0.1:9113/metrics

Docker metrics: http://127.0.0.1:9323/metrics
for docker you have to change the config from docker with the following code:
{
  "builder": {
    "gc": {
      "defaultKeepStorage": "20GB",
      "enabled": true
    }
  },
  "experimental": true,
  "features": {
    "buildkit": true
  },
  "metrics-addr": "127.0.0.1:9323"
}

Nginx exporter to try fix it:
https://grafana.com/grafana/dashboards/14900-nginx/
https://stackoverflow.com/questions/64952485/nginx-prometheus-exporter-container-cannot-connect-to-nginx
https://hub.docker.com/r/nginx/nginx-prometheus-exporter
https://www.containiq.com/post/nginx-prometheus-exporter

cadvisor
https://medium.com/@carlos.edamazio/container-monitoring-with-prometheus-and-cadvisor-684be5652b33