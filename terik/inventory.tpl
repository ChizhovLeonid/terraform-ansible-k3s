[Yoba_servers]
%{ for index, vm in name_vps ~}
${vm} ansible_host=${ip_yoba[index]}
%{ endfor ~}
[Yoba_servers:vars]
ansible_user=root
ansible_python_interpreter=/usr/bin/python3