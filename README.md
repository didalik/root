# TODOs

Add all the leaves below as NPM packages and git submodules:
```
.
├── dak
│   ├── hex
│   │   ├── agent
│   │   └── user     # CREATED on 01/03/2024
│   └── svc
│       └── hex      # DONE on 01/04/2024
```
Make submodule `./dak/hex/user` public. FIXED on 12/16/2023.

## HEX genesis

### dak/hex/agent

- Add ClawableHexa and HEXA assets Issuer
- Add Agent
- Have Agent trust ClawableHexa and HEXA assets
- Fund Agent with ClawableHexa and HEXA assets

### dak/hex/user

- Add User CREATOR
- Have CREATOR run **dak/hex/agent: HEX genesis**
