---
tags:
  - guide
  - linux
  - networking
  - ssh
  - automation
category: os
status:
  - learning
related: "[[SSH Basics]]"
date: 2025-11-24
---
# SSH Advanced (Config, Bastions, Remote Exec) 
## ⚙️ The Config File (`~/.ssh/config`)
Instead of typing `ssh -i ~/.ssh/lab.pem -p 7654 centos@192.168.1.10`, you can define aliases. 
1. **Create File:** `touch ~/.ssh/config && chmod 600 ~/.ssh/config` 
2. **Define Host:** 
 ```text 
	Host targaryen 
		HostName 192.168.1.10 
		User daenerys 
		Port 7654 
		IdentityFile ~/.ssh/targaryen.key 
```

1. **Connect:** `ssh targaryen` 
## ⌨️ Remote Command Execution 
You can run scripts on a server without entering a shell. 
* **Single Command:** 
	`ssh user@host "whoami; pwd"` 
* **Sudo Command (Requires TTY):** 
	`ssh -t user@host "sudo ls /root"` 
	*(The `-t` flag forces a pseudo-terminal allocation, necessary for sudo password prompts).* 
* **Local Script Execution:** 
	`ssh user@host < script.sh` 
	*(Runs a script located on YOUR machine, on the REMOTE machine).* 
## 🧱 Bastion Hosts (Jump Servers) 
A Bastion is a gateway server in a public subnet used to access private instances. 
* **The "ProxyCommand" Method:** 
	```bash 
	ssh -i private.pem -o "ProxyCommand ssh -W %h:%p -i bastion.pem user@bastionIP" user@privateIP 
	``` 
* **Explanation:** SSH connects to the Bastion, then tunnels the traffic (`-W`) to the final destination. 
## See Also 
- [[Secure File Transfer]] 
- [[Shell Scripting]]