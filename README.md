# COBOL Book Sample

This sample is a native console application that demonstrates a simple command line application wrapping a legacy program which can maintain a book repository using conventional COBOL file IO.

This sample is targeted towards development and debugging in Visual Studio Code. This can be run on both Windows or Linux locally or remotely using Microsoft's remote development extensions for vscode.

## 📄 Structure

The sample is structured as follows:

* `.editorconfig` - Configuration file containing source formatting options.
* `bld.bat` - Windows build script for building the sample.
* `Makefile` - Linux makefile for building the sample.
* `directives.mf` - Contains COBOL compiler directives required for building the sample.
* `src/book.cbl` - The business logic for the book repository.
* `src/cli.cbl` - Entry program that accepts a command line and calls book.
* `cpy/book-rec.cpy` - Copybook shared between programs.
* `obj/` - Directory where object and debug files get written.
* `bin/` - Directory where the application binary is written to.
* `.vscode/tasks.json` - Configuration for building the sample within vscode.
* `.vscode/launch.json` - Configuration for running and debugging the sample within vscode.
* `add-books.bat` - Windows batch script that adds sample data to the book repository.
* `add-books.sh` - Unix shell script that adds sample data to the book repository.

## ⚡ Running the Sample

### Visual Studio Code

1. Open the folder in Visual Studio Code.
2. Press F5, or Run -> Start Debugging to run the application.
3. You can debug the code by inserting a breakpoint and running the application.
4. To add a set of sample books, open a Micro Focus COBOL terminal and run `.\add-books.bat` (Windows) or `./add-books.sh` (Linux).

### Command line (Windows)

1. Open a Visual COBOL or Enterprise Developer prompt.
2. Navigate to the root directory for this sample.
3. Execute `bld.bat` to build the sample.
4. Execute `bin\book.exe` to run the sample.
5. Execute `.\add-books.bat` to add some sample data to the book repository.

### Command line (Linux)

1. Setup a devhub environment. Typically this would be done as follows:

    ```sh
    . /opt/microfocus/VisualCOBOL/bin/cobsetenv
    ```

2. Navigate to the root directory for this sample.
3. Execute `make` to build the sample.
4. Execute `bin/book` to run the sample.
5. Execute `./add-books.sh` to add some sample data to the book repository.

## 📋 Exercises

Below are some exercises that you are welcome to follow that can help you become more familiar with the Micro Focus COBOL tooling and language.

* Fix a bug that prevents the `-f` option from working correctly.
* Display the genre of the books when executing the `list` command.
* Refactor shared data items and constants between cli and book (e.g. `ws-function`, and `ws-file-status`) to a copybook that is included by both programs.
* Refactor the sample to use local variables and parameterised sections.

## ⚖️ License

Copyright (C) 2023 Micro Focus. All Rights Reserved.
This software may be used, modified, and distributed
(provided this notice is included without modification)
solely for internal demonstration purposes with other
Micro Focus software, and is otherwise subject to the EULA at
<https://www.microfocus.com/en-us/legal/software-licensing>.

THIS SOFTWARE IS PROVIDED "AS IS" AND ALL IMPLIED
WARRANTIES, INCLUDING THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE,
SHALL NOT APPLY.
TO THE EXTENT PERMITTED BY LAW, IN NO EVENT WILL
MICRO FOCUS HAVE ANY LIABILITY WHATSOEVER IN CONNECTION
WITH THIS SOFTWARE.
