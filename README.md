# StackBack

Generate HTML pages with information from the CloudStack database, not available using API commands, using hugo.

Currently implemented is a list of of accounts and projects.

You can generate JSON data files using the included Ruby script:

Generate accounts.json:

```bash
./cloudstack.rb accounts > data/accounts.json
```

Generate projects.json:

```bash
./cloudstack.rb projects > data/projects.json
```
