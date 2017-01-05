# ansible-cntlm

Install and configure [CNTLM](http://cntlm.sourceforge.net/).

## Requirements

In most case we need CNTLM to set enterprise proxy in order to acces to internet network. By accepting its assumption it will be strange that the ansible-cntlm role try to download last CNTLM version from internet.

During beta you **MUST** provide CNTLM package (rpm or deb) from http://sourceforge.net/projects/cntlm/files/ and register proper variable.

* `cntlm_package_file`: Configure path to package file (rpm or deb) (`string`, NO DEFAULT)

## Role variables

* `cntlm_config_template`: Configure path to template for CNTLM configuration file *cntlm.conf* (`string`, default: `cntlm.conf.j2`)
* `cntlm_username`: Configure cntlm username (`string`, default: `testuser`)
* `cntlm_domain`: Configure cntlm domain (`string`, default: `corp-uk`)
* `cntlm_pass_lm`, `cntlm_pass_nt`, `cntlm_pass_ntlm`: Configure cntlm hashed credentials (`string`, default: `1AD35398BE6565DDB5C4EF70C0593492`, `77B9081511704EE852F94227CF48A793`,  `D5826E9C665C37C80B53397D5C07BBCB`) 
* `cntlm_proxies`: Configure proxies servers (`object array`, default: `[{'ip': '10.0.0.41', 'port': '8080'}, {'ip': '10.0.0.42', 'port': '8080'}]`)
* `cntlm_no_proxy`: Configure no proxy value (`string`, default: `localhost, 127.0.0.*, 10.*, 192.168.*`)
* `cntlm_listen_ip`: Configure CNTLM listen ip (`string`, default: `0.0.0.0`)
* `cntlm_listen_port`: Configure CNTLM listen port (`string`, default: `3128`)
* `cntlm_allows`: Configure allows host to access CNTLM (`string array`, default: `['127.0.0.1']`)
* `cntlm_denies`: Configure denies host to access CNTLM (`string array`, default: `['0/0']`)

## Dependencies

None.

## Example playbook

    ---
    - hosts: localhost
      roles:
        - { role: ansible-cntlm, cntlm_package_file: files/cntlm-0.92.3-1.x86_64.rpm }

## License

MIT

# Author information

This role was created in 2015 by Thibaud Lepretre, a simple backend developer