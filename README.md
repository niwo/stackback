# StackBack

Generate HTML pages with information from the CloudStack database, not available using API commands, using hugo.

Currently implemented is a list of of accounts and projects.

You can generate JSON data files using the included Ruby script:

## Usage

Generate accounts.json:

```bash
$ ./cloudstack.rb accounts > data/accounts.json
```

Generate projects.json:

```bash
$ ./cloudstack.rb projects > data/projects.json
```

Start hugo in dev mode:

```bash
$ hugo server                                                                            
...
Serving pages from memory
Web Server is available at http://localhost:1313/ (bind address 127.0.0.1)
Press Ctrl+C to stop
```
