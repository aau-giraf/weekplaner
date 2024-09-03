# Weekplanner

This repository contains the frontend part of the weekplanner-app, which communicates with the backend (web-api repository).

The frontend uses the Flutter framework to maintain the UI, it is currently running on Flutter version 3.24.1. The language used in this repository is Dart, which is the language the Flutter framework uses.

## Running the application

You can find guides on how to setup the weekplanner application [here](https://aau-giraf.github.io/wiki/Setup/Index/)

# Branches

This repository uses the scaled trunkbased branching strategy, as explained here: [GitHub setup](https://github.com/aau-giraf/.github/blob/main/wiki/about/github.md). In this repository the "trunk" is named develop, and this is the branch that all developers should branch from when solving an issue. The naming convention for these branches are:

| Issue type | Name                     |   Example   |
| :--------: | :----------------------- | :---------: |
| User Story | feature/\<issue-number\> | feature/697 |
|    Task    | task/\<issue-number\>    |  task/918   |
|  Bug fix   | bug-fix/\<issue-number\> | bug-fix/299 |

Other than the branches being used for development and the trunk, there exists some release branches, where the newest release branch is running on the PROD-environment. The release branches can only be created by members of the release group in the organization, and they should adhere to the following naming convention:

- Naming is release-\<release-version\>, e.g. release-1.0
- A hot-fix on a release will increment the number after the dot.
- A new release will increment the number before the dot.

## License

GNU GENERAL PUBLIC LICENSE V3

Copyright 2024, Aalborg University

## Workflow badges

Dev - [![Weekplanner dev Status](https://github.com/aau-giraf/weekplanner/workflows/Flutter%20verification/badge.svg?branch=develop)](https://github.com/aau-giraf/weekplanner/actions)
