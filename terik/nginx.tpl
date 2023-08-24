events {}

stream {
    upstream k3s_servers {
%{ for index, vm in name_vps ~}
    %{ if index <= 2 ~}
        #${vm} 
        server ${ip_yoba[index]}:6443;
    %{ endif ~}
%{ endfor ~}
    }
    server {
        listen 6443;
        proxy_pass k3s_servers;
    }
}