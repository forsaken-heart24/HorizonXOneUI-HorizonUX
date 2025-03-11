//
// Copyright (C) 2025 Luna
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#ifndef HORIZONUTILS_H
#define HORIZONUTILS_H

#include <string.h>
#include <stdbool.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>

// FUCKING global FUCKING variables.
extern bool WRITE_DEBUG_MESSAGES_TO_CONSOLE;
extern char *LOG4HORIZONFILE;
 
// FUCKING function FUCKING declarations.
void error_print(const char *Message);
void error_print_extended(const char *message, const char *additional_args);
bool erase_file_content(const char *__file);
int executeCommands(const char *command, bool requiresOutput);
int executeScripts(const char *__script__file, const char *__args, bool requiresOutput);

#endif