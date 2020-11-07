#!/bin/python3
"""Provides statistics on the site focusing on hits form social media
platforms."""

import os
import sys
import argparse


class StatsBuilder:

    def __init__(self):
        self._env_var_names = self._set_env_var_names()
        self._options = self._set_options()

    @staticmethod
    def _set_env_var_names() -> dict:
        """Returns the environment variable names for each type of variable
        that would be used by the scripts.
        """
        envVars = {}
        with open('../source/env_var_names.txt', 'r') as f:
            envVarsLines = f.readlines()

        for envVarLine in envVarsLines:
            varType, envVarName = envVarLine.split('=')
            envVars[varType] = envVarName.replace('\n', '')

        return envVars

    def _set_options(self) -> object:
        """Returns the user's options."""
        userOptions = {}

        optionsParser = argparse.ArgumentParser(
            description='Statistics derived from the access log.'
        )
        optionsParser.add_argument(
            '-x',
            '--start-date',
            action='store',
            help='Start date (dd-mm-yyyy)'
        )
        optionsParser.add_argument(
            '-y',
            '--end-date',
            action='store',
            help='End date (dd-mm-yyyy)'
        )
        optionsParser.add_argument(
            '-g',
            '--group-by',
            choices=['d', 'm', 'y'],
            help='Group by: d=day, m=month, y=year',
            default='d'
        )
        optionsParser.add_argument(
            '-a',
            '--access-log',
            help=f"log path directory. Not required if the access log is set \
                as an environment variable as \
                `{self.get_env_var_names()['ACCESS_LOG_PATH_ENV_VAR']}`."
        )
        optionsParser.add_argument(
            '-i',
            '--include-pattern',
            action='append',
            help='Define a pattern that must exist in each line of the log.'
        )
        optionsParser.add_argument(
            '-I',
            '--env-include-patterns',
            action='store_true',
            help=f"Patterns that must exist in each line of the log are \
            stored in the environment variable \
            `{self.get_env_var_names()['INC_PATTERN_ENV_VAR']}`."
        )
        optionsParser.add_argument(
            '-e',
            '--exclude-pattern',
            action='append',
            help='Define a pattern that must not exist in each line of the \
                log.'
        )
        optionsParser.add_argument(
            '-E',
            '--env-exclude-patterns',
            action='store_true',
            help=f"Patterns that must not exist in each line of the log are \
            stored in the environment variable \
            `{self.get_env_var_names()['EXC_PATTERN_ENV_VAR']}`."
        )

        return optionsParser.parse_args()

    def get_env_var_names(self) -> dict:
        """Retrieves the environment variables related to these scripts."""
        return self._env_var_names

    def get_options(self) -> object:
        """Retrieves user options."""
        return self._options

if __name__ == "__main__":
    StatsBuilder()