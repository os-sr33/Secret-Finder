# Secret-Finder

A Bash script that automates the discovery and scanning of JavaScript files from a given target website for hardcoded secrets, such as API keys, tokens, passwords, and client IDs.

# Features

- Uses Katana, WaybackURLs, and GAU to collect JavaScript file URLs.

- Downloads JavaScript files for offline analysis.

- Scans for hardcoded secrets using regex patterns.

- Outputs results in a readable tabular format.

- Saves findings in a found_secrets.txt file.

# Requirements

- Ensure the following tools are installed before running the script:

- Katana

- WaybackURLs

- GAU

- wget (for downloading JavaScript files)

- grep (for pattern matching)
