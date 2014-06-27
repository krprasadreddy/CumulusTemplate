This repository contains the build scripts and metadata needed to configure the NPSP 3.0 DOT or at least as much as can be automated via build scripts and metadata.

To setup a new org:

1. Create a symlink named build.properties in the root and link it to a Force.com Ant Migration Tool properties file with org credentials
2. Run the command `ant installTemplate`

What's not included:
- Custom Settings
- Sample Data
- Config changes only available in the web UI
