import os
import time
from os import system, name

device_dict = {'ROUTER': '254', 'SWITCH 1': '252', 'SWITCH 2': '253', 'WEBRELAY': '240', 'NODE': '101'}

devices_up = {}

devices_down = {}

def clear():
    if name == "nt":
        _ = system("cls")
    else:
        _ = system("clear")

def status_display(subnet_ip):
    clear()
    if devices_up:
        print("------Devices that pinged successfully--------\n")
        for device, ip in devices_up.items():
            print(device, "-", f"10.0.{subnet_ip}.{ip}")
        print("")
    if devices_down:    
        print("")
        print("------Devices that pinged unsuccessfully------\n")
        for device, ip in devices_down.items():
            print(device, "-", f"10.0.{subnet_ip}.{ip}")
        print("")

def mod_ping(ip_addr, switch_status):
    if switch_status == "yes":
        check_switch = ['252', '253']
        for s in check_switch:
            os.system(f"ping -n 1 10.0.{ip_addr}.{s} > ping_switch.txt")
            with open('ping_switch.txt', 'r') as file:
                data = file.read()
                if f"Reply from 10.0.{ip_addr}.252" in data:
                    del device_dict['SWITCH 2']
                elif f"Reply from 10.0.{ip_addr}.253" in data:
                    del device_dict['SWITCH 2']
                    device_dict['SWITCH 1'] = '253'
    for device, ip in device_dict.items():
        print(f"\n\nPinging {device} now...")
        os.system(f"ping -n 2 10.0.{ip_addr}.{ip} > ping.txt")
        with open('ping.txt', 'r') as file:
            data = file.read()
            if "TTL" in data:
                print(f'\n{device} up...')
                devices_up[device] = ip
            else:
                print(f'\n{device} down...')
                devices_down[device] = ip
    status_display(ip_addr)

def intro():
    clear()
    print("***Ping Module Test***\n")
    while True:
        add_subnet = input("Please enter IP subnet for module: ")
        if add_subnet.isnumeric():
            break
        else:
            print("Enter only numbers")
    while True:
        second_switch = input("\nIs there 2 managed switches in this module? [y/n]: ")
        if second_switch == "y":
            one_switch = "no"
            break
        elif second_switch == "n":
            one_switch = "yes"
            break
        else:
            print("Enter y or n")
    while True:
        which_node = input("\nDoes this have a Orin Node? [y/n]: ")
        if which_node == "y":
            device_dict['NODE'] = '102'
            break
        elif which_node == "n":
            break
        else:
            print("Enter y or n")
    
    mod_ping(add_subnet, one_switch)
    
intro() 



