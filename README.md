# Janga-Compiler

Janga is a compiler that uses python to turn text into their corrisponding tokens, then NASM assembly to create an exacutable file.

* only on mac

idk why I used NASM its kinda dumb that it only runs on mac cause it needs stuff to convert it to arm anyway but im in way to deep and to lazy to switch it.

Required downloads:
  - Python 3 (used for making the NASM assembly code)
  - xcode: xcode-select --install (is used to create the executable)
  - NASM: brew install nasm (assembly code)
  - Rosetta 2: softwareupdate --install-rosetta (translates x86 -> ARM)


Running a janga file:
  - copy the repository  
  - In terminal get into the respository folder directory with:  
      - cd [directory]  
  - Run in terminal with:  
      - python3 Janga.py [.jan text file]  

Will open a new terminal to run if the .jan requires input
