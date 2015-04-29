# OpenStack Continuous Integration Module

## Overview

Configures an OpenStack Continuous Integration System

## Developing

If you are adding features to this module, first ask yourself: "Does this logic
belong in the module for the service?"

An example of this is the gearman-logging.conf file needed by the zuul service.
This file should be managed by the zuul module, not managed here. What should go
in this module is high level directives and integrations such as a list of
jenkins plugins to install or a class that instantiates multiple services.
