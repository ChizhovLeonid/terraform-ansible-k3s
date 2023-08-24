terraform {
    required_providers {
        vsphere = {
            source = "hashicorp/vsphere" #Название провайдера для работы с vsphere
            version = "2.4.1"
            }
    }
}

provider "vsphere" {
    user = "" #Логин
    password = "" #Пароль
    vsphere_server = "" #Адрес сервера
    allow_unverified_ssl = true
}

data "vsphere_datacenter" "datacenter" {
    name = "" #Название датацентра
}

data "vsphere_compute_cluster" "cluster" {
    name = "" #Название кластера
    datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
    name          = "" #Какую сеть надо использовать
    datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_datastore" "datastore" {
    name          = "" #Где будет храниться вм и откуда брать темплейт
    datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_virtual_machine" "template" {
  name = "Yoba_fett_temp" #Название темплейта
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_virtual_machine" "vm" {
    count            = 7 #Сколько надо машин
    name             = "yoba_fett${count.index + 1}" #Отображение в консоли
    resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id #Пул ресурсов (кластера)
    datastore_id     = data.vsphere_datastore.datastore.id #Где будет храниться вм и откуда брать темплейт
    num_cpus         = 4 #Количество ядер
    memory           = 4096 #Сколько озу надо
    guest_id         = "ubuntu64Guest" #Тип вм (указал случайно при установке, там дебиан)
    network_interface {
        network_id = data.vsphere_network.network.id #Какую сеть надо использовать
    }
    disk {
        label = "disk0" #Маркировка диска
        size  = 20 #Размер диска в Гб
        thin_provisioned = false
    }

    clone {
    template_uuid = data.vsphere_virtual_machine.template.id #Говорит что надо копировать

    customize {
      timeout = 1 #Чтобы не сразу шатало вм

      linux_options {
        host_name = "yoba-fett${count.index + 1}" #Название хоста, будет отображаться в самом хосте
        domain = "" #Домен
      }

      network_interface { #DHCP
      }
    }
  }
    lifecycle {
    ignore_changes = [
      clone[0].template_uuid, #Запрет на пересоздание машины, смотрит на то какие уже есть
        ]
    }
}

locals {
  ip = vsphere_virtual_machine.vm.*.default_ip_address
  name_vps = vsphere_virtual_machine.vm.*.name
}

resource "local_file" "inventory_for_ansible" {
  content = templatefile("inventory.tpl", {
    ip_yoba   = local.ip
    name_vps  = local.name_vps
  })
  filename = "hosts_list"
}

resource "local_file" "nginx_config" {
  content = templatefile("nginx.tpl", {
    ip_yoba   = local.ip
    name_vps  = local.name_vps
  })
  filename = "../Nginx/nginx.conf"
}